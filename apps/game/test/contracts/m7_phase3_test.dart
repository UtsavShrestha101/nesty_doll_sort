import 'dart:convert';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_core/nesty_core.dart';
import 'package:nesty_game/core/models/play_entry.dart';
import 'package:nesty_game/core/models/play_request.dart';
import 'package:nesty_game/core/models/reminder_settings.dart';
import 'package:nesty_game/core/repository/fake_catalog_repository.dart';
import 'package:nesty_game/core/repository/fake_level_repository.dart';
import 'package:nesty_game/core/repository/fake_level_resolver.dart';
import 'package:nesty_game/core/repository/fixture_levels.dart';
import 'package:nesty_game/core/services/audio/fake_audio_service.dart';
import 'package:nesty_game/core/services/clock/fake_clock.dart';
import 'package:nesty_game/core/services/clock/local_date.dart';
import 'package:nesty_game/core/services/daily/daily_status.dart';
import 'package:nesty_game/core/services/daily/fake_daily_service.dart';
import 'package:nesty_game/core/services/daily/streak_daily_service.dart';
import 'package:nesty_game/core/services/database/database_service.dart';
import 'package:nesty_game/core/services/database/fake_database_service.dart';
import 'package:nesty_game/core/services/music/fake_music_service.dart';
import 'package:nesty_game/core/services/music/jingle_cues.dart';
import 'package:nesty_game/core/services/notifications/fake_notification_service.dart';
import 'package:nesty_game/core/services/records/record_rules.dart';
import 'package:nesty_game/core/services/records/records_summary.dart';
import 'package:nesty_game/core/services/records/star_rules.dart';
import 'package:nesty_game/core/services/reminder/daily_reminder.dart';
import 'package:nesty_game/core/services/remote_config/fake_remote_config_service.dart';
import 'package:nesty_game/core/services/remote_config/remote_config_keys.dart';
import 'package:nesty_game/core/services/save/fake_save_service.dart';
import 'package:nesty_game/core/services/save/save_document.dart';
import 'package:nesty_game/core/services/save/save_document_codec.dart';
import 'package:nesty_game/core/services/skin/fake_skin_service.dart';
import 'package:nesty_game/core/services/skin/skin_service.dart';
import 'package:nesty_game/core/ui/nesty_ui.dart';
import 'package:nesty_game/features/chapters/cubit/chapters_cubit.dart';
import 'package:nesty_game/features/daily/cubit/daily_cubit.dart';
import 'package:nesty_game/features/daily/cubit/reminder_offer_cubit.dart';
import 'package:nesty_game/features/daily/pages/daily_page.dart';
import 'package:nesty_game/features/daily/widgets/daily_background_loader.dart';
import 'package:nesty_game/features/fx/fake_fx_library.dart';
import 'package:nesty_game/features/fx/fx_library.dart';
import 'package:nesty_game/features/gameplay/bloc/gameplay_bloc.dart';
import 'package:nesty_render/nesty_render.dart' show ChapterTheme;

import '../features/support/screen_harness.dart';

/// The plumbing the M7 phase-3 contracts froze and implemented for star
/// ratings (D125), the share card (E3) and the reminder (E4)
/// (docs/plans/m7-design.md P3.1): each lane owns the full behaviour tests
/// of its part (P3.13); these pin that the frozen surface is wired.
void main() {
  /// [entry] with [par] overridden (stars-app gave [FixtureLevels] their
  /// own solver pars; a test that needs a specific value, or none, rebuilds
  /// the entry with it).
  LevelBundleEntry withPar(LevelBundleEntry entry, int? par) =>
      LevelBundleEntry(
        order: entry.order,
        chapterId: entry.chapterId,
        tier: entry.tier,
        version: entry.version,
        rewardCoins: entry.rewardCoins,
        level: entry.level,
        par: par,
      );

  List<LevelBundleEntry> parEntries() => [
    for (final entry in FixtureLevels.entries())
      withPar(entry, entry.order + 1),
  ];

  group('StarRules (m7-design P3.5)', () {
    test('slackOf clamps each key into 0..maxSlackPct', () {
      final config = FakeRemoteConfigService();
      expect(StarRules.slackOf(config), (star3: 20, star2: 60));
      config
        ..setOverride(RemoteConfigKeys.star3SlackPct, -5)
        ..setOverride(RemoteConfigKeys.star2SlackPct, 5000);
      expect(StarRules.slackOf(config), (
        star3: 0,
        star2: StarRating.maxSlackPct,
      ));
    });

    test('keyOf, targetFor and PlayEntry.par: bundled boards only', () {
      final entry = withPar(FixtureLevels.entries().first, 12);
      final campaign = FakeLevelResolver.campaignEntry(entry, 10);
      final replay = campaign.copyWith(request: const PlayRequest.replay(1));
      final daily = campaign.copyWith(
        request: const PlayRequest.daily(20260928),
      );
      final bonus = campaign.copyWith(request: const PlayRequest.bonus(1));
      const slack = (star3: 20, star2: 60);
      expect(campaign.par, 12);
      expect(replay.par, 12);
      expect(daily.par, isNull);
      expect(bonus.par, isNull);
      expect(StarRules.keyOf(campaign), entry.level.id);
      expect(StarRules.keyOf(replay), entry.level.id);
      expect(StarRules.keyOf(daily), isNull);
      expect(StarRules.targetFor(replay, slack), 15);
      expect(
        StarRules.targetFor(
          FakeLevelResolver.campaignEntry(
            withPar(FixtureLevels.entries().first, null),
            10,
          ),
          slack,
        ),
        isNull,
      );
    });

    test('backfill: the best moves unassisted, 1 star without a best', () {
      const slack = (star3: 20, star2: 60);
      expect(StarRules.backfill(par: 12, best: null, slack: slack), 1);
      expect(StarRules.backfill(par: 12, best: 15, slack: slack), 3);
      expect(StarRules.backfill(par: 12, best: 16, slack: slack), 2);
      expect(StarRules.backfill(par: 12, best: 21, slack: slack), 1);
    });
  });

  group('the save: best stars, the tip and the daily solve (P3.4)', () {
    LevelWinRecord win(PlayRequest request, {int? stars, String? key}) =>
        LevelWinRecord(
          request: request,
          rewardCoins: request.isReplay ? 0 : 10,
          moves: 14,
          starsKey: key,
          stars: stars,
        );

    test('keeps the highest per level id, the tip once below 3 stars', () {
      final save = FakeSaveService();
      final first = save.recordLevelWin(
        win(const PlayRequest.campaign(1), stars: 2, key: 'L0001'),
      );
      expect(first.stars, 2);
      expect(first.previousStars, isNull);
      expect(first.showStarTip, isTrue);
      // Phase 4 (D191): the card marks it once it has shown it.
      expect(save.document.starTipShown, isFalse);
      save.markStarTipShown();
      expect(save.document.starTipShown, isTrue);
      final raised = save.recordLevelWin(
        win(const PlayRequest.replay(1), stars: 3, key: 'L0001'),
      );
      expect((raised.stars, raised.previousStars), (3, 2));
      expect(raised.showStarTip, isFalse);
      final lower = save.recordLevelWin(
        win(const PlayRequest.replay(1), stars: 1, key: 'L0001'),
      );
      expect((lower.stars, lower.previousStars), (3, 3));
      expect(lower.showStarTip, isFalse);
      expect(save.document.levelStars, {'L0001': 3});
    });

    test('best stars are kept per level id across a new level version (Q117), '
        'unlike best moves, which are kept per version', () {
      final save = FakeSaveService();
      save.recordLevelWin(
        LevelWinRecord(
          request: const PlayRequest.campaign(1),
          rewardCoins: 10,
          moves: 2,
          bestKey: LevelBests.key('L0001', 1),
          starsKey: 'L0001',
          stars: 3,
        ),
      );
      // A later version of the same level id (M4 content) starts a new
      // best-moves history, but the level's stars stay: they are never
      // lowered, whatever version earned them.
      save.recordLevelWin(
        LevelWinRecord(
          request: const PlayRequest.campaign(1),
          rewardCoins: 10,
          moves: 9,
          bestKey: LevelBests.key('L0001', 2),
          starsKey: 'L0001',
          stars: 1,
        ),
      );
      expect(save.document.levelStars, {'L0001': 3});
      expect(save.bestMovesFor(LevelBests.key('L0001', 1)), 2);
      expect(save.bestMovesFor(LevelBests.key('L0001', 2)), 9);
    });

    test('a 3-star win shows no tip; stars pay nothing', () {
      final plain = FakeSaveService()
        ..recordLevelWin(win(const PlayRequest.campaign(1)));
      final starred = FakeSaveService();
      final outcome = starred.recordLevelWin(
        win(const PlayRequest.campaign(1), stars: 3, key: 'L0001'),
      );
      expect(outcome.showStarTip, isFalse);
      expect(starred.document.starTipShown, isFalse);
      expect(starred.document.coins, plain.document.coins);
      expect(starred.document.copyWith(levelStars: const {}), plain.document);
    });

    test('generated boards and out-of-range stars write no stars', () {
      final save = FakeSaveService()
        ..recordLevelWin(win(const PlayRequest.bonus(1), stars: 3, key: 'B'))
        ..recordLevelWin(
          win(const PlayRequest.campaign(1), stars: 4, key: 'L0001'),
        )
        ..recordLevelWin(
          win(const PlayRequest.campaign(2), stars: 0, key: 'L0002'),
        )
        ..recordLevelWin(
          win(const PlayRequest.race(rival: 1, raceNo: 1), stars: 3, key: 'R'),
        );
      expect(save.document.levelStars, isEmpty);
      expect(save.document.starTipShown, isFalse);
    });

    test("a daily's first solve of its date keeps lastSolve", () {
      final date = LocalDate(2026, 9, 28);
      final progress = DailyProgress(
        streak: 1,
        lit: true,
        run: 1,
        lastDate: date,
        done: [date],
      );
      LevelWinRecord daily(int moves) => LevelWinRecord(
        request: PlayRequest.daily(date.yyyymmdd),
        rewardCoins: 50,
        moves: moves,
        families: 5,
        minuteOfDay: 1150,
        daily: progress,
        starsKey: 'D',
        stars: 3,
      );
      final save = FakeSaveService()..recordLevelWin(daily(18));
      final solve = DailySolve(
        date: date,
        moves: 18,
        families: 5,
        minuteOfDay: 1150,
      );
      expect(save.document.daily.lastSolve, solve);
      expect(save.document.levelStars, isEmpty);
      // The same date again (the clock went back) keeps the first solve.
      save.recordLevelWin(daily(30));
      expect(save.document.daily.lastSolve, solve);
    });
  });

  // Schema 2's phase-3 fields. Since schema 3 (plan-login-gift §7.5b) a
  // `'schema': 2` document below is read through the 2 → 3 step, so these
  // also hold the fields through the migration.
  group('the codec (schema 2, P3.4)', () {
    test('round-trips the phase-3 fields', () {
      final date = LocalDate(2026, 9, 28);
      final doc = SaveDocument(
        levelStars: const {'L0001': 3, 'L0002': 1},
        starTipShown: true,
        daily: DailyProgress(
          lastSolve: DailySolve(
            date: date,
            moves: 18,
            families: 5,
            minuteOfDay: 1150,
          ),
        ),
        inProgress: const InProgressLevel(
          request: PlayRequest.campaign(4),
          levelId: 'L0004',
          levelVersion: 1,
          session: {},
          hinted: true,
        ),
      );
      final json = SaveDocumentCodec.encode(doc);
      final keys = json.keys.toList();
      expect(keys.indexOf('levelStars'), keys.indexOf('levelBests') + 1);
      expect(keys.indexOf('starTipShown'), keys.indexOf('levelStars') + 1);
      final read = SaveDocumentCodec.read(SaveDocumentCodec.write(doc));
      expect(read.document.levelStars, doc.levelStars);
      expect(read.document.starTipShown, isTrue);
      expect(read.document.daily.lastSolve, doc.daily.lastSolve);
      expect(read.document.inProgress?.hinted, isTrue);
    });

    test('reads them leniently', () {
      final raw = {
        'schema': 2,
        'levelStars': {'L1': 0, 'L2': 4, 'L3': 2.0, '': 3, 'L4': 'x'},
        'starTipShown': 'yes',
        'daily': {
          'lastSolve': {
            'date': '2026-09-28',
            'moves': -1,
            'families': 'x',
            'minute': 1440,
          },
        },
        'inProgress': {
          'kind': 'campaign',
          'number': 4,
          'levelId': 'L0004',
          'levelVersion': 1,
          'session': <String, Object?>{},
          'hinted': 'x',
        },
      };
      final doc = SaveDocumentCodec.read(jsonEncode(raw)).document;
      expect(doc.levelStars, {'L3': 2});
      expect(doc.starTipShown, isFalse);
      expect(doc.daily.lastSolve, DailySolve(date: LocalDate(2026, 9, 28)));
      expect(doc.inProgress?.hinted, isFalse);
      final bad = SaveDocumentCodec.read(
        jsonEncode({
          'schema': 2,
          'daily': {
            'lastSolve': {'date': 'soon'},
          },
        }),
      ).document;
      expect(bad.daily.lastSolve, isNull);
    });
  });

  group('backfillLevelStars (Q120)', () {
    test('gives won levels with a par their best moves stars, once', () {
      final entries = parEntries(); // pars 2, 3, 4
      final levels = FakeLevelRepository(entries: entries);
      final first = entries[0];
      final save = FakeSaveService(
        initial: SaveDocument(
          currentLevel: 3,
          highestLevel: 3,
          levelBests: {'${first.level.id}@${first.version}': 2},
        ),
      );
      var changes = 0;
      final subscription = save.changes.listen((_) => changes++);
      addTearDown(subscription.cancel);
      expect(save.backfillLevelStars(levels), 2);
      expect(save.document.levelStars, {
        first.level.id: 3,
        entries[1].level.id: 1,
      });
      // Idempotent: nothing to give the second time.
      expect(save.backfillLevelStars(levels), 0);
      expect(save.document.starTipShown, isFalse);
    });

    test('never lowers an entry, and skips par-less levels', () {
      final entries = [
        withPar(FixtureLevels.entries()[0], null),
        withPar(FixtureLevels.entries()[1], 3),
      ];
      final save = FakeSaveService(
        initial: SaveDocument(
          currentLevel: 3,
          highestLevel: 3,
          levelStars: {entries[1].level.id: 3},
        ),
      );
      expect(save.backfillLevelStars(FakeLevelRepository(entries: entries)), 0);
      expect(save.document.levelStars, {entries[1].level.id: 3});
    });
  });

  group('Records and Chapters totals (P3.5, P3.7)', () {
    test('RecordsSummary sums levelStars over the levels with a par', () {
      const doc = SaveDocument(levelStars: {'L0001': 3, 'L0002': 2});
      final summary = RecordsSummary.of(doc, levelCount: 3, starLevels: 3);
      expect(summary.stars, 5);
      expect(summary.starsPossible, 9);
      expect(summary.threeStarLevels, 1);
      expect(
        StarRules.levelsWithPar(FakeLevelRepository(entries: parEntries())),
        3,
      );
    });

    test(
      "ChaptersCubit fills each won cell's stars and the chapter total",
      () async {
        final entries = parEntries();
        final save = FakeSaveService(
          initial: SaveDocument(
            currentLevel: 3,
            highestLevel: 3,
            levelStars: {entries[0].level.id: 2},
          ),
        );
        final cubit = ChaptersCubit(
          save,
          FakeLevelRepository(entries: entries),
          FakeCatalogRepository(),
        );
        addTearDown(cubit.close);
        await cubit.load();
        final chapter = cubit.state.data!.chapters.first;
        expect(chapter.levels[0].stars, 2);
        expect(chapter.levels[1].stars, isNull);
        expect(chapter.levels[2].stars, isNull);
        expect(chapter.stars, 2);
        expect(chapter.starsPossible, 9);
      },
    );
  });

  test('DailyStatus.solve is today’s solve only (P3.8)', () {
    final today = LocalDate(2026, 9, 26);
    final solve = DailySolve(date: today, moves: 18, families: 5);
    final save = FakeSaveService(
      initial: SaveDocument(
        currentLevel: 3,
        highestLevel: 3,
        daily: DailyProgress(
          streak: 1,
          lit: true,
          run: 1,
          lastDate: today,
          done: [today],
          lastSolve: solve,
        ),
      ),
    );
    final clock = FakeClock(now: DateTime(2026, 9, 26, 20));
    final daily = StreakDailyService(save, clock, FakeRemoteConfigService());
    expect(daily.refresh().solve, solve);
    clock.advance(const Duration(days: 1));
    expect(daily.refresh().solve, isNull);
  });

  group('the reminder is off and silent on a fresh install (P3.10)', () {
    test('DailyReminder schedules nothing and never asks', () async {
      final notifications = FakeNotificationService();
      final settings = FakeDatabaseService();
      addTearDown(settings.close);
      final reminder = DailyReminder(
        notifications,
        settings,
        FakeDailyService(FakeClock())..unlocked = false,
      );
      addTearDown(reminder.dispose);
      reminder.start();
      final status = await reminder.refresh();
      expect(status.settings, const ReminderSettings());
      expect(status.available, isFalse);
      expect(status.blocked, isFalse);
      expect(notifications.requestCount, 0);
      expect(notifications.scheduleCalls, isEmpty);
      expect(await notifications.hasPendingDaily(), isFalse);
    });

    test('planFor builds the same warm copy at the chosen time', () {
      final settings = FakeDatabaseService();
      addTearDown(settings.close);
      final reminder = DailyReminder(
        FakeNotificationService(),
        settings,
        FakeDailyService(FakeClock()),
      );
      addTearDown(reminder.dispose);
      final plan = reminder.planFor(
        const ReminderSettings(on: true, hour: 8, minute: 30),
      );
      expect((plan.hour, plan.minute), (8, 30));
      // copy.md G.7 `notification_title` (phase 4).
      expect(plan.title, 'Nesty');
      expect(plan.title.toLowerCase(), isNot(contains('streak')));
      expect(plan.body.toLowerCase(), isNot(contains('streak')));
      expect(plan.channelName, 'Daily puzzle');
    });

    test('ReminderOfferCubit is frozen hidden', () async {
      final settings = FakeDatabaseService();
      addTearDown(settings.close);
      final daily = FakeDailyService(FakeClock());
      final reminder = DailyReminder(
        FakeNotificationService(),
        settings,
        daily,
      );
      addTearDown(reminder.dispose);
      final cubit = ReminderOfferCubit(reminder, settings, daily, FakeClock());
      addTearDown(cubit.close);
      await cubit.load();
      expect(cubit.state.data?.step, ReminderOfferStep.hidden);
      expect(settings.reminder.offered, isFalse);
    });
  });

  group('the frozen widgets', () {
    testWidgets('StarRow: one semantics node, three star arts (m7-3)', (
      tester,
    ) async {
      await pumpScreen(tester, const Center(child: StarRow(count: 2)));
      expect(find.bySemanticsLabel('2 of 3 stars'), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(StarRow),
          matching: find.byType(UiArtImage),
        ),
        findsNWidgets(3),
      );
      expect(tester.getSize(find.byType(StarRow)).height, StarRow.sizeCard);
      expect(
        (StarRow.sizeWin, StarRow.sizeCard, StarRow.sizeCell),
        (44, 20, 11),
      );
    });

    testWidgets(
      "DailyView shows its reminder offer only while today's solved",
      (tester) async {
        Future<void> pumpWith({required bool solved}) async {
          final save = FakeSaveService();
          final resolver = FakeLevelResolver(
            FakeLevelRepository(),
            save,
            FakeRemoteConfigService(),
          );
          final daily = FakeDailyService(
            FakeClock(),
            status: DailyStatus(
              today: LocalDate(2026, 9, 26),
              tier: Tier.hard,
              colors: 5,
              unlocked: true,
              streak: 1,
              lit: true,
              run: 1,
              solvedToday: solved,
              cycleDone: solved ? 1 : 0,
            ),
          );
          final cubit = DailyCubit(
            daily,
            resolver,
            save,
            FakeRemoteConfigService(),
          );
          await pumpScreen(
            tester,
            BlocProvider<DailyCubit>.value(
              value: cubit,
              child: MultiRepositoryProvider(
                providers: [
                  RepositoryProvider<JingleCues>.value(
                    value: JingleCues(FakeMusicService(), FakeAudioService()),
                  ),
                  RepositoryProvider<SkinService>.value(
                    value: FakeSkinService(),
                  ),
                  RepositoryProvider<DatabaseService>.value(
                    value: FakeDatabaseService(),
                  ),
                  RepositoryProvider<FxLibrary>.value(value: FakeFxLibrary()),
                  RepositoryProvider<DailyBackgroundLoader>.value(
                    value: const _NoDailyBackground(),
                  ),
                ],
                child: const DailyView(reminderOffer: Text('offer-slot')),
              ),
            ),
          );
          await cubit.load();
          await tester.pump();
          await tester.pump(const Duration(milliseconds: 300));
          expect(
            find.text('offer-slot', skipOffstage: false),
            solved ? findsOneWidget : findsNothing,
          );
          await cubit.close();
        }

        await pumpWith(solved: false);
        await pumpWith(solved: true);
      },
    );
  });

  test('GameplayState.starsNewBest only on a replay that raised them', () {
    final entry = FixtureLevels.entries().first;
    final play = FakeLevelResolver.campaignEntry(entry, 10);
    GameplayState state(PlayEntry play, {int? stars, int? previous}) =>
        GameplayState(
          play: play,
          entry: entry,
          board: GameState.initial(entry.level),
          stars: stars,
          previousStars: previous,
        );
    final replay = play.copyWith(request: const PlayRequest.replay(1));
    expect(state(replay, stars: 3, previous: 2).starsNewBest, isTrue);
    expect(state(replay, stars: 2, previous: 2).starsNewBest, isFalse);
    expect(state(replay, stars: 2).starsNewBest, isFalse);
    expect(state(play, stars: 3, previous: 1).starsNewBest, isFalse);
  });
}

/// No art: nothing here checks the Daily card's background.
class _NoDailyBackground implements DailyBackgroundLoader {
  const _NoDailyBackground();

  @override
  Future<ui.Image?> rasterize(
    ChapterTheme theme, {
    required Size box,
    required double devicePixelRatio,
  }) async => null;
}
