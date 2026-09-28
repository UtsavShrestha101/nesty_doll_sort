import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_core/nesty_core.dart';
import 'package:nesty_game/core/base/base_async_state.dart';
import 'package:nesty_game/core/models/play_entry.dart';
import 'package:nesty_game/core/models/play_request.dart';
import 'package:nesty_game/core/repository/fake_level_repository.dart';
import 'package:nesty_game/core/repository/fake_level_resolver.dart';
import 'package:nesty_game/core/services/clock/fake_clock.dart';
import 'package:nesty_game/core/services/clock/local_date.dart';
import 'package:nesty_game/core/services/daily/daily_status.dart';
import 'package:nesty_game/core/services/daily/fake_daily_service.dart';
import 'package:nesty_game/core/services/daily/streak_daily_service.dart';
import 'package:nesty_game/core/services/remote_config/fake_remote_config_service.dart';
import 'package:nesty_game/core/services/save/fake_save_service.dart';
import 'package:nesty_game/core/services/save/save_document.dart';
import 'package:nesty_game/features/daily/cubit/daily_cubit.dart';

import '../../helpers/level_fixtures.dart';

/// `DailyCubit` over a scripted [FakeDailyService] and [FakeLevelResolver]
/// (docs/plans/m3-design.md §8.4, §10.5): the mapping into [DailyState],
/// the countdown, the streams from `SaveService`/`DailyService`, and the
/// puzzle preview.
void main() {
  final today = LocalDate(2026, 9, 26);

  DailyStatus status({
    bool unlocked = true,
    int streak = 4,
    int freezes = 1,
    bool solvedToday = false,
    int cycleDone = 4,
    bool chestPending = false,
    LocalDate? freezeNotice,
    bool inProgress = false,
  }) => DailyStatus(
    today: today,
    tier: Tier.hard,
    colors: 5,
    unlocked: unlocked,
    streak: streak,
    freezes: freezes,
    solvedToday: solvedToday,
    cycleDone: cycleDone,
    chestPending: chestPending,
    freezeNotice: freezeNotice,
    inProgress: inProgress,
  );

  FakeSaveService save({int coins = 0, int currentLevel = 56}) =>
      FakeSaveService(
        initial: SaveDocument(coins: coins, currentLevel: currentLevel),
      );

  /// A campaign entry at every play order up to [currentLevel], so
  /// `FakeLevelResolver.homeRequest` resolves to `campaign(currentLevel)`
  /// instead of falling through to Bonus Endless.
  FakeLevelRepository levelsThrough(int currentLevel) {
    final level = levelFrom(tutorialLevelJson);
    return FakeLevelRepository(
      entries: [
        for (var order = 1; order <= currentLevel; order++)
          entryFor(level, order: order),
      ],
    );
  }

  ({
    DailyCubit cubit,
    FakeDailyService daily,
    FakeLevelResolver resolver,
    FakeSaveService save,
    FakeClock clock,
  })
  build({
    DailyStatus? status,
    FakeSaveService? save,
    FakeLevelRepository? levels,
    Map<PlayRequest, PlayEntry>? generated,
    Duration countdownInterval = const Duration(minutes: 1),
  }) {
    final theSave = save ?? FakeSaveService();
    final theLevels = levels ?? FakeLevelRepository();
    final resolver = FakeLevelResolver(
      theLevels,
      theSave,
      FakeRemoteConfigService(),
      generated: generated,
    );
    final clock = FakeClock();
    final daily = FakeDailyService(clock, status: status);
    return (
      cubit: DailyCubit(
        daily,
        resolver,
        theSave,
        FakeRemoteConfigService(),
        countdownInterval: countdownInterval,
      ),
      daily: daily,
      resolver: resolver,
      save: theSave,
      clock: clock,
    );
  }

  test('load reads the status, the coins, the reward defaults and the home '
      'request', () async {
    final built = build(
      status: status(),
      save: save(coins: 140),
      levels: levelsThrough(56),
    );
    expect(built.cubit.state, const AsyncValue<DailyState>.initial());
    final states = <AsyncValue<DailyState>>[];
    final sub = built.cubit.stream.listen(states.add);
    await built.cubit.load();
    await sub.cancel();

    expect(states.first, const AsyncValue<DailyState>.loading());
    final data = built.cubit.state.data!;
    expect(data.coins, 140);
    expect(data.rewardCoins, 50);
    expect(data.chestCoins, 300);
    expect(data.homeLevelNumber, 56);
    expect(data.homeRequest, const PlayRequest.campaign(56));
    expect(data.status.streak, 4);
  });

  test(
    'a save change updates the coin pill without touching the status',
    () async {
      final built = build(status: status(streak: 2), save: save(coins: 10));
      await built.cubit.load();
      built.save.addCoins(15);
      await Future<void>.delayed(Duration.zero);
      final data = built.cubit.state.data!;
      expect(data.coins, 25);
      expect(data.status.streak, 2);
    },
  );

  test(
    'a daily change (collectChest, a new day) refreshes the status',
    () async {
      final built = build(status: status(chestPending: true));
      await built.cubit.load();
      expect(built.cubit.state.data!.status.chestPending, isTrue);

      final collected = built.cubit.collectChest();
      expect(collected, isTrue);
      await Future<void>.delayed(Duration.zero);
      expect(built.cubit.state.data!.status.chestPending, isFalse);
    },
  );

  test('collectChest with nothing pending collects nothing', () async {
    final built = build(status: status());
    await built.cubit.load();
    expect(built.cubit.collectChest(), isFalse);
  });

  test(
    'acknowledgeFreezeNotice clears the notice through the stream',
    () async {
      final frozen = LocalDate(2026, 9, 25);
      final built = build(status: status(freezeNotice: frozen));
      await built.cubit.load();
      expect(built.cubit.state.data!.status.freezeNotice, frozen);

      built.cubit.acknowledgeFreezeNotice();
      await Future<void>.delayed(Duration.zero);
      expect(built.cubit.state.data!.status.freezeNotice, isNull);
      expect(built.daily.noticesAcknowledged, 1);
    },
  );

  test('the countdown ticks on its interval', () async {
    final built = build(
      status: status(),
      countdownInterval: const Duration(milliseconds: 10),
    );
    await built.cubit.load();
    final first = built.cubit.state.data!.untilNextPuzzle;
    built.clock.advance(const Duration(minutes: 5));
    await Future<void>.delayed(const Duration(milliseconds: 30));
    final second = built.cubit.state.data!.untilNextPuzzle;
    expect(second, isNot(first));
    expect(second, first! - const Duration(minutes: 5));
    await built.cubit.close();
  });

  test('the puzzle preview resolves to the level colours', () async {
    final level = levelFrom(tutorialLevelJson);
    final request = PlayRequest.daily(today.yyyymmdd);
    final built = build(
      status: status(),
      generated: {
        request: PlayEntry(
          request: request,
          level: level,
          tier: Tier.hard,
          levelVersion: 1,
          rewardCoins: 50,
          themeId: 'ch01',
        ),
      },
    );
    await built.cubit.load();
    await Future<void>.delayed(Duration.zero);
    final data = built.cubit.state.data!;
    expect(data.previewColors, [DollColor.red]);
    expect(data.previewFailed, isFalse);
  });

  test('a puzzle that fails to resolve hides the preview', () async {
    final built = build(status: status());
    await built.cubit.load();
    await Future<void>.delayed(Duration.zero);
    final data = built.cubit.state.data!;
    expect(data.previewColors, isNull);
    expect(data.previewFailed, isTrue);
  });

  group('the Daily screen rolls over at midnight (CORRECTNESS-8)', () {
    final saturday = LocalDate(2026, 9, 26);
    final sunday = LocalDate(2026, 9, 27);

    PlayEntry entry(PlayRequest request, String color) => PlayEntry(
      request: request,
      level: levelFrom(tutorialLevelJson.replaceAll('red', color)),
      tier: Tier.hard,
      levelVersion: 1,
      rewardCoins: 50,
      themeId: 'ch01',
    );

    /// The real streak service (it reconciles with the clock only on
    /// `refresh`, and never publishes a new day by itself) over a save
    /// whose Saturday daily is already solved.
    ({DailyCubit cubit, FakeClock clock}) buildReal({
      required DateTime now,
      bool solvedSaturday = true,
      Duration countdownInterval = const Duration(milliseconds: 10),
    }) {
      final clock = FakeClock(now: now);
      final theSave = FakeSaveService(
        initial: SaveDocument(
          currentLevel: 12,
          highestLevel: 12,
          daily: solvedSaturday
              ? DailyProgress(streak: 5, lastDate: saturday, done: [saturday])
              : DailyProgress(
                  streak: 4,
                  lastDate: saturday.addDays(-1),
                  done: [saturday.addDays(-1)],
                ),
        ),
      );
      final remote = FakeRemoteConfigService();
      final daily = StreakDailyService(theSave, clock, remote);
      final saturdayRequest = PlayRequest.daily(saturday.yyyymmdd);
      final sundayRequest = PlayRequest.daily(sunday.yyyymmdd);
      final resolver = FakeLevelResolver(
        FakeLevelRepository(),
        theSave,
        remote,
        generated: {
          saturdayRequest: entry(saturdayRequest, 'red'),
          sundayRequest: entry(sundayRequest, 'blue'),
        },
      );
      return (
        cubit: DailyCubit(
          daily,
          resolver,
          theSave,
          remote,
          countdownInterval: countdownInterval,
        ),
        clock: clock,
      );
    }

    test('the countdown tick past midnight shows the new day, unsolved, '
        'with its own preview and a fresh countdown', () async {
      final built = buildReal(now: DateTime(2026, 9, 26, 23, 59, 30));
      await built.cubit.load();
      await Future<void>.delayed(Duration.zero);
      var data = built.cubit.state.data!;
      expect(data.status.today, saturday);
      expect(data.status.solvedToday, isTrue);
      expect(data.previewColors, [DollColor.red]);

      built.clock.set(DateTime(2026, 9, 27, 0, 1));
      await Future<void>.delayed(const Duration(milliseconds: 40));
      data = built.cubit.state.data!;
      expect(data.status.today, sunday);
      expect(data.status.solvedToday, isFalse);
      expect(data.previewColors, [DollColor.blue]);
      expect(data.untilNextPuzzle, const Duration(hours: 23, minutes: 59));
      await built.cubit.close();
    });

    test('Play right after midnight (before any tick) starts today’s '
        'puzzle, not the one the screen still shows', () async {
      final built = buildReal(
        now: DateTime(2026, 9, 26, 23, 59),
        solvedSaturday: false,
        countdownInterval: const Duration(hours: 1),
      );
      await built.cubit.load();
      expect(built.cubit.state.data!.status.today, saturday);

      built.clock.set(DateTime(2026, 9, 27, 0, 1));
      expect(
        built.cubit.dailyPlayRequest(),
        PlayRequest.daily(sunday.yyyymmdd),
      );
      // The screen rolled over with it.
      expect(built.cubit.state.data!.status.today, sunday);
      await built.cubit.close();
    });
  });
}
