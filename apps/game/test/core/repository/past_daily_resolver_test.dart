import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_core/nesty_core.dart';
import 'package:nesty_game/core/models/play_request.dart';
import 'package:nesty_game/core/repository/default_level_resolver.dart';
import 'package:nesty_game/core/repository/fake_catalog_repository.dart';
import 'package:nesty_game/core/repository/fake_level_repository.dart';
import 'package:nesty_game/core/repository/fake_level_resolver.dart';
import 'package:nesty_game/core/repository/fixture_levels.dart';
import 'package:nesty_game/core/repository/level_resolver.dart';
import 'package:nesty_game/core/services/clock/fake_clock.dart';
import 'package:nesty_game/core/services/generator/fake_level_generator_service.dart';
import 'package:nesty_game/core/services/remote_config/fake_remote_config_service.dart';
import 'package:nesty_game/core/services/remote_config/remote_config_keys.dart';
import 'package:nesty_game/core/services/save/fake_save_service.dart';
import 'package:nesty_game/core/services/save/save_document.dart';

/// The resolver's past-day case (plan-local-habits §3, §7.5c). Today is the
/// FakeClock's 2026-09-26, so the default window is 20260919 … 20260925.
InProgressLevel _board(PlayRequest request, Level level) => InProgressLevel(
  request: request,
  levelId: level.id,
  levelVersion: Generator.version,
  session: const {'format': 1},
  level: LevelCodec.encode(level),
  tier: Tier.easy,
);

void main() {
  late FakeSaveService save;
  late FakeRemoteConfigService config;
  late FakeClock clock;
  late FakeLevelRepository levels;

  setUp(() {
    config = FakeRemoteConfigService();
    clock = FakeClock();
    levels = FakeLevelRepository(entries: FixtureLevels.entries());
    save = FakeSaveService(
      initial: const SaveDocument(currentLevel: 5, highestLevel: 5),
    );
  });

  DefaultLevelResolver real({FakeSaveService? withSave}) =>
      DefaultLevelResolver(
        levels,
        FakeLevelGeneratorService(),
        config,
        withSave ?? save,
        FakeCatalogRepository(),
        clock,
      );

  FakeLevelResolver fake({FakeSaveService? withSave}) {
    final resolver = FakeLevelResolver(
      levels,
      withSave ?? save,
      config,
      clock: clock,
    );
    return resolver;
  }

  Future<List<LevelResolver>> both({FakeSaveService? withSave}) async {
    final r = real(withSave: withSave);
    final f = fake(withSave: withSave);
    // The fake serves the board a test files for that date's daily.
    final daily = await r.resolve(const PlayRequest.daily(20260924));
    f.generated[const PlayRequest.daily(20260924)] = daily!;
    return [r, f];
  }

  group('the window', () {
    test('pays 0 and plays the very board of that date\'s daily', () async {
      final r = real();
      final past = await r.resolve(const PlayRequest.pastDaily(20260924));
      final daily = await r.resolve(const PlayRequest.daily(20260924));
      expect(past, isNotNull);
      expect(past!.rewardCoins, 0);
      expect(past.request, const PlayRequest.pastDaily(20260924));
      expect(past.level, daily!.level);
      expect(past.tier, daily.tier);
      expect(daily.rewardCoins, RemoteConfigKeys.dailyReward.defaultValue);
    });

    test(
      'both resolvers accept the whole window and refuse outside it',
      () async {
        for (final resolver in await both()) {
          for (final date in [20260919, 20260924, 20260925]) {
            final entry = resolver is FakeLevelResolver && date != 20260924
                ? null
                : await resolver.resolve(PlayRequest.pastDaily(date));
            if (resolver is DefaultLevelResolver || date == 20260924) {
              expect(entry, isNotNull, reason: '$date in $resolver');
            }
          }
          // Refused: today, the future, too old, not a date.
          for (final date in [
            20260926,
            20260927,
            20271001,
            20260918,
            20250101,
            20260230,
          ]) {
            expect(
              await resolver.resolve(PlayRequest.pastDaily(date)),
              isNull,
              reason: '$date in $resolver',
            );
          }
        }
      },
    );

    test('a locked Daily refuses every date', () async {
      final locked = FakeSaveService(
        initial: const SaveDocument(currentLevel: 2, highestLevel: 2),
      );
      for (final resolver in await both(withSave: locked)) {
        expect(
          await resolver.resolve(const PlayRequest.pastDaily(20260924)),
          isNull,
        );
      }
    });

    test('daily_archive_days moves the window; 0 turns it off; a bad value '
        'reads as 7', () async {
      config.setOverride(RemoteConfigKeys.dailyArchiveDays, 3);
      var r = real();
      expect(await r.resolve(const PlayRequest.pastDaily(20260923)), isNotNull);
      expect(await r.resolve(const PlayRequest.pastDaily(20260922)), isNull);

      config.setOverride(RemoteConfigKeys.dailyArchiveDays, 0);
      r = real();
      expect(await r.resolve(const PlayRequest.pastDaily(20260925)), isNull);

      config.setOverride(RemoteConfigKeys.dailyArchiveDays, 99);
      r = real();
      expect(await r.resolve(const PlayRequest.pastDaily(20260829)), isNotNull);
      expect(await r.resolve(const PlayRequest.pastDaily(20260828)), isNull);
    });

    test('the window follows the clock', () async {
      final r = real();
      expect(await r.resolve(const PlayRequest.pastDaily(20260919)), isNotNull);
      clock.advance(const Duration(days: 1));
      expect(await r.resolve(const PlayRequest.pastDaily(20260919)), isNull);
      expect(await r.resolve(const PlayRequest.pastDaily(20260926)), isNotNull);
    });
  });

  group('a board open on screen past midnight', () {
    test(
      'its date is accepted outside the window, restored from the save',
      () async {
        final level = (await real().resolve(
          const PlayRequest.daily(20260901),
        ))!.level;
        const old = PlayRequest.pastDaily(20260901);
        final withBoard = FakeSaveService(
          initial: const SaveDocument(currentLevel: 5, highestLevel: 5),
        )..saveInProgress(_board(old, level));
        final r = real(withSave: withBoard);
        final entry = await r.resolve(old);
        expect(entry, isNotNull);
        expect(entry!.level, level);
        expect(entry.rewardCoins, 0);
        // Another old date, with no board of its own, is still refused.
        expect(await r.resolve(const PlayRequest.pastDaily(20260902)), isNull);
        // And the fake mirrors it.
        final f = fake(withSave: withBoard)..generated[old] = entry;
        expect((await f.resolve(old))?.rewardCoins, 0);
        expect(await f.resolve(const PlayRequest.pastDaily(20260902)), isNull);
      },
    );

    test('a past day never continues into another board', () {
      expect(real().next(const PlayRequest.pastDaily(20260924)), isNull);
      expect(fake().next(const PlayRequest.pastDaily(20260924)), isNull);
    });
  });
}
