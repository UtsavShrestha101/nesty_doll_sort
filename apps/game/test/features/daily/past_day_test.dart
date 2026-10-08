import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:nesty_core/nesty_core.dart';
import 'package:nesty_game/core/models/play_entry.dart';
import 'package:nesty_game/core/models/play_request.dart';
import 'package:nesty_game/core/repository/fake_level_repository.dart';
import 'package:nesty_game/core/repository/fake_level_resolver.dart';
import 'package:nesty_game/core/services/clock/fake_clock.dart';
import 'package:nesty_game/core/services/clock/local_date.dart';
import 'package:nesty_game/core/services/daily/daily_status.dart';
import 'package:nesty_game/core/services/daily/fake_daily_service.dart';
import 'package:nesty_game/core/services/database/database_service.dart';
import 'package:nesty_game/core/services/database/fake_database_service.dart';
import 'package:nesty_game/core/services/remote_config/fake_remote_config_service.dart';
import 'package:nesty_game/core/services/save/fake_save_service.dart';
import 'package:nesty_game/core/services/save/save_document.dart';
import 'package:nesty_game/core/services/skin/skin_service.dart';
import 'package:nesty_game/core/ui/nesty_ui.dart';
import 'package:nesty_game/features/daily/cubit/daily_cubit.dart';
import 'package:nesty_game/features/daily/widgets/daily_background_loader.dart';
import 'package:nesty_game/features/daily/widgets/month_card.dart';
import 'package:nesty_game/features/daily/widgets/past_day_card.dart';
import 'package:nesty_game/features/fx/fake_fx_library.dart';
import 'package:nesty_game/features/fx/fx_library.dart';
import 'package:nesty_render/nesty_render.dart' show ChapterTheme;

import '../../core/ui/support/ui_harness.dart';
import '../../helpers/level_fixtures.dart';
import '../support/controlled_skin_service.dart';
import '../support/screen_harness.dart';

class _NoBackground implements DailyBackgroundLoader {
  @override
  Future<ui.Image?> rasterize(
    ChapterTheme theme, {
    required Size box,
    required double devicePixelRatio,
  }) async => null;
}

/// The last 7 dailies, playable (local habits 3, spec-prop §7.5c): the
/// picker's taps and non-taps, its ‹ chip, the past day's card and the
/// cubit's page state behind them.
void main() {
  setUpAll(loadBundledFonts);

  final today = LocalDate(2026, 10, 8);
  final window = [for (var i = 7; i >= 1; i--) today.addDays(-i)];

  DailyStatus statusOf({
    LocalDate? day,
    List<LocalDate>? win,
    List<LocalDate> done = const [],
    List<LocalDate> played = const [],
  }) => DailyStatus(
    today: day ?? today,
    tier: Tier.hard,
    colors: 5,
    unlocked: true,
    streak: 3,
    lit: true,
    run: 3,
    done: done,
    played: played,
    window: win ?? window,
  );

  group('DailyCubit past-day page state', () {
    late DailyCubit cubit;
    late FakeDailyService daily;
    late FakeClock clock;

    PlayEntry pastEntry(LocalDate date) => FakeLevelResolver.campaignEntry(
      entryFor(levelFrom(tutorialLevelJson)),
      0,
    ).copyWith(request: PlayRequest.pastDaily(date.yyyymmdd));

    Future<void> build({DailyStatus? status}) async {
      final save = FakeSaveService(
        initial: const SaveDocument(highestLevel: 5),
      );
      clock = FakeClock(now: DateTime(2026, 10, 8, 12));
      final resolver = FakeLevelResolver(
        FakeLevelRepository(),
        save,
        FakeRemoteConfigService(),
        clock: clock,
        generated: {
          for (final d in window)
            PlayRequest.pastDaily(d.yyyymmdd): pastEntry(d),
        },
      );
      daily = FakeDailyService(clock, status: status ?? statusOf());
      cubit = DailyCubit(daily, resolver, save, FakeRemoteConfigService());
      addTearDown(cubit.close);
      await cubit.load();
    }

    test('load prunes the archive (never mid-game), once', () async {
      await build();
      expect(daily.archivePrunes, 1);
    });

    test(
      'a window day opens its card, with its chip facts and preview',
      () async {
        await build();
        final day = today.addDays(-3);
        cubit.selectPastDate(day);
        var data = cubit.state.data!;
        expect(data.selectedPastDate, day);
        expect(data.pastTier, DifficultyCurve.dailyTier(day.yyyymmdd));
        expect(
          data.pastColorCount,
          DifficultyCurve.dailyParams(day.yyyymmdd).colors,
        );
        expect(data.pastPreviewColors, isNull);
        await Future<void>.delayed(Duration.zero);
        data = cubit.state.data!;
        expect(data.pastPreviewColors, isNotEmpty);
        expect(cubit.pastPlayRequest(), PlayRequest.pastDaily(day.yyyymmdd));
      },
    );

    test('another day switches the card; the same day closes it', () async {
      await build();
      cubit.selectPastDate(today.addDays(-3));
      cubit.selectPastDate(today.addDays(-2));
      expect(cubit.state.data!.selectedPastDate, today.addDays(-2));
      cubit.selectPastDate(today.addDays(-2));
      expect(cubit.state.data!.selectedPastDate, isNull);
      expect(cubit.pastPlayRequest(), isNull);
    });

    test(
      'today, a future day and a day older than the window never open',
      () async {
        await build();
        for (final d in [today, today.addDays(1), today.addDays(-8)]) {
          cubit.selectPastDate(d);
          expect(cubit.state.data!.selectedPastDate, isNull);
        }
      },
    );

    test('the board open outside the window can still be chosen', () async {
      final old = today.addDays(-9);
      await build(status: statusOf().copyWith(archiveInProgress: old));
      cubit.selectPastDate(old);
      expect(cubit.state.data!.selectedPastDate, old);
    });

    test('refresh keeps the card open on the month (frame 14.3e)', () async {
      await build();
      final day = today.addDays(-3);
      cubit.selectPastDate(day);
      daily.status = statusOf(played: [day]);
      cubit.refresh();
      final data = cubit.state.data!;
      expect(data.selectedPastDate, day);
      expect(data.status.played, [day]);
    });

    test('paging goes back one month and forward, never further, and only '
        'while the window reaches it', () async {
      final early = LocalDate(2026, 10, 3);
      await build(
        status: statusOf(
          day: early,
          win: [for (var i = 7; i >= 1; i--) early.addDays(-i)],
        ),
      );
      cubit.showMonth(-2);
      expect(cubit.state.data!.monthOffset, 0);
      cubit.showMonth(-1);
      expect(cubit.state.data!.monthOffset, -1);
      cubit.showMonth(0);
      expect(cubit.state.data!.monthOffset, 0);

      await build();
      cubit.showMonth(-1);
      expect(cubit.state.data!.monthOffset, 0);
    });

    test('Play past midnight rolls the screen over and starts nothing: the '
        'chosen day may have left the window', () async {
      await build();
      final oldest = today.addDays(-7);
      cubit.selectPastDate(oldest);
      expect(cubit.state.data!.selectedPastDate, oldest);
      clock.setDate(today.addDays(1));
      daily.status = statusOf(
        day: today.addDays(1),
        win: [for (var i = 6; i >= 0; i--) today.addDays(-i)],
      );
      expect(cubit.pastPlayRequest(), isNull);
      final data = cubit.state.data!;
      expect(data.status.today, today.addDays(1));
      expect(data.selectedPastDate, isNull);
    });

    test('a new day clears the card and the page', () async {
      await build();
      cubit.selectPastDate(today.addDays(-1));
      daily.status = statusOf(
        day: today.addDays(1),
        win: [for (var i = 6; i >= 0; i--) today.addDays(-i)],
      );
      cubit.refresh();
      final data = cubit.state.data!;
      expect(data.selectedPastDate, isNull);
      expect(data.monthOffset, 0);
    });
  });

  group('MonthCard picker', () {
    Future<List<LocalDate>> pump(
      WidgetTester tester,
      DailyStatus status, {
      LocalDate? selected,
      int offset = 0,
      List<int>? paged,
      bool interactive = true,
    }) async {
      final taps = <LocalDate>[];
      await pumpScreen(
        tester,
        Material(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: MonthCard(
              status: status,
              selected: selected,
              monthOffset: offset,
              onSelect: interactive ? taps.add : null,
              onShowMonth: interactive ? (o) => paged?.add(o) : null,
            ),
          ),
        ),
      );
      return taps;
    }

    String openLabel(LocalDate d, String state) =>
        testL10n.dailyMonthDayOpenSemantics(
          testL10n.dailyMonthDaySemantics(
            state,
            DateFormat.MMMMd(testLocaleCode).format(d.startOfDay),
          ),
        );

    testWidgets('a window day is a 48 dp button; older, blank, today and '
        'future days are inert', (tester) async {
      final handle = tester.ensureSemantics();
      final taps = await pump(tester, statusOf());
      final day = today.addDays(-3);
      final finder = find.bySemanticsLabel(openLabel(day, 'other'));
      expect(finder, findsOne);
      expect(tester.getSize(finder).height, greaterThanOrEqualTo(48));
      await tester.tap(finder);
      expect(taps, [day]);

      // Older than the window: its number, nothing else.
      await tester.tap(find.text('${today.addDays(-8).day}'));
      // Today and a future day.
      await tester.tap(find.text('${today.day}'));
      await tester.tap(find.text('${today.addDays(2).day}'));
      expect(taps, [day]);
      expect(find.bySemanticsLabel(RegExp('open to play')), findsNWidgets(7));
      handle.dispose();
    });

    testWidgets("today's cell scrolls up to today's card while the window's "
        'days are open, and is a 48 dp button then (habits.month.cell.today.'
        'tap)', (tester) async {
      Future<int> pumpToday(DailyStatus status) async {
        var shown = 0;
        await pumpScreen(
          tester,
          Material(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: MonthCard(
                status: status,
                onSelect: (_) {},
                onShowToday: () => shown++,
              ),
            ),
          ),
        );
        await tester.tap(find.text('${today.day}'));
        return shown;
      }

      final handle = tester.ensureSemantics();
      expect(await pumpToday(statusOf()), 1);
      final cell = find.bySemanticsLabel(
        testL10n.dailyMonthDaySemantics(
          'today',
          DateFormat.MMMMd(testLocaleCode).format(today.startOfDay),
        ),
      );
      expect(tester.getSemantics(cell).flagsCollection.isButton, isTrue);
      expect(tester.getSize(cell).height, greaterThanOrEqualTo(48));
      // No window (the archive off): the rows stay small, so today is inert.
      expect(await pumpToday(statusOf(win: const [])), 0);
      handle.dispose();
    });

    testWidgets('a solved or played-later window day opens too', (
      tester,
    ) async {
      final solved = today.addDays(-2);
      final later = today.addDays(-4);
      final taps = await pump(
        tester,
        statusOf(done: [solved], played: [later]),
      );
      await tester.tap(find.text('${solved.day}'));
      await tester.tap(find.text('${later.day}'));
      expect(taps, [solved, later]);
    });

    testWidgets('with no onSelect the grid is inert and shows no hint', (
      tester,
    ) async {
      final taps = await pump(tester, statusOf(), interactive: false);
      await tester.tap(find.text('${today.addDays(-3).day}'));
      expect(taps, isEmpty);
      expect(find.text(testL10n.dailyMonthHint), findsNothing);
    });

    testWidgets('the hint line shows while days are open', (tester) async {
      await pump(tester, statusOf());
      expect(find.text(testL10n.dailyMonthHint), findsOne);
    });

    testWidgets('the chosen day is marked selected', (tester) async {
      final handle = tester.ensureSemantics();
      final day = today.addDays(-3);
      await pump(tester, statusOf(), selected: day);
      expect(
        tester.getSemantics(find.bySemanticsLabel(openLabel(day, 'other'))),
        isSemantics(isSelected: true),
      );
      handle.dispose();
    });

    testWidgets('no ‹ chip when the window stays in this month', (
      tester,
    ) async {
      await pump(tester, statusOf());
      expect(find.byIcon(NestyIcons.chevronLeft), findsNothing);
    });

    testWidgets('the ‹ chip pages back, and › pages forward, in the same '
        'tap target', (tester) async {
      final handle = tester.ensureSemantics();
      final early = LocalDate(2026, 10, 3);
      final status = statusOf(
        day: early,
        win: [for (var i = 7; i >= 1; i--) early.addDays(-i)],
      );
      final paged = <int>[];
      await pump(tester, status, paged: paged);
      final back = find.bySemanticsLabel(
        testL10n.dailyMonthShowSemantics(
          DateFormat.LLLL(testLocaleCode).format(DateTime(2026, 9)),
        ),
      );
      expect(back, findsOne);
      expect(tester.getSize(back).height, greaterThanOrEqualTo(48));
      await tester.tap(back);
      expect(paged, [-1]);

      // Paged back: September's grid, › back to October, no today ring.
      await pump(tester, status, offset: -1, paged: paged);
      expect(find.byIcon(NestyIcons.chevronRight), findsOne);
      expect(find.text('30'), findsOne);
      await tester.tap(find.byIcon(NestyIcons.chevronRight));
      expect(paged, [-1, 0]);
      handle.dispose();
    });
  });

  group('PastDayCard', () {
    DailyState stateOf({
      List<LocalDate> done = const [],
      List<LocalDate> played = const [],
      bool preview = true,
    }) => DailyState(
      status: statusOf(done: done, played: played),
      previewColors: preview
          ? const [DollColor.purple, DollColor.yellow, DollColor.red]
          : null,
      pastTier: Tier.hard,
      pastColorCount: 5,
      selectedPastDate: today.addDays(-3),
    );

    Future<void> pump(
      WidgetTester tester,
      DailyState state, {
      VoidCallback? onPlay,
      double textScale = 1,
      bool reduceMotion = false,
    }) => pumpScreen(
      tester,
      MultiRepositoryProvider(
        providers: [
          RepositoryProvider<SkinService>.value(value: ControlledSkinService()),
          RepositoryProvider<DatabaseService>.value(
            value: FakeDatabaseService(),
          ),
          RepositoryProvider<FxLibrary>.value(value: FakeFxLibrary()),
          RepositoryProvider<DailyBackgroundLoader>.value(
            value: _NoBackground(),
          ),
        ],
        child: Scaffold(
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: PastDayReveal(
              child: PastDayCard(
                state: state,
                date: today.addDays(-3),
                onPlay: onPlay ?? () {},
              ),
            ),
          ),
        ),
      ),
      textScale: textScale,
      reduceMotion: reduceMotion,
    );

    testWidgets('date title, colours · tier, Play with no coin chip, then '
        'the note', (tester) async {
      var played = 0;
      await pump(tester, stateOf(), onPlay: () => played++);
      await tester.pump(const Duration(milliseconds: 400));
      final date = today.addDays(-3);
      expect(
        find.text(
          testL10n.pastDailyTitle(
            DateFormat.MMMEd(testLocaleCode).format(date.startOfDay),
          ),
        ),
        findsOne,
      );
      expect(
        find.text(testL10n.dailyPuzzleInfo(5, testL10n.tierName('hard'))),
        findsOne,
      );
      expect(find.text(testL10n.dailyPlay), findsOne);
      expect(find.byType(CoinIcon), findsNothing);
      expect(find.text(testL10n.pastDailyNote), findsOne);
      expect(find.text(testL10n.pastDailyPlayAgain), findsNothing);
      expect(tester.getSize(find.byKey(PastDayCard.playKey)).height, 60);
      await tester.tap(find.byKey(PastDayCard.playKey));
      expect(played, 1);
    });

    testWidgets('solved on the day: the dimmed preview, the green pill and '
        'Play again', (tester) async {
      await pump(tester, stateOf(done: [today.addDays(-3)]));
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.text(testL10n.pastDailySolvedOnDay), findsOne);
      expect(find.text(testL10n.pastDailyPlayAgain), findsOne);
      expect(find.text(testL10n.dailyPlay), findsNothing);
      expect(find.text(testL10n.pastDailyNote), findsOne);
    });

    testWidgets('played later says so', (tester) async {
      await pump(tester, stateOf(played: [today.addDays(-3)]));
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.text(testL10n.pastDailySolvedLater), findsOne);
      expect(find.text(testL10n.pastDailyPlayAgain), findsOne);
    });

    testWidgets('it opens with a fade, with no slide under reduced motion', (
      tester,
    ) async {
      await pump(tester, stateOf(), reduceMotion: true);
      await tester.pump(const Duration(milliseconds: 160));
      final fade = tester.widget<FadeTransition>(
        find
            .descendant(
              of: find.byType(PastDayReveal),
              matching: find.byType(FadeTransition),
            )
            .first,
      );
      expect(fade.opacity.value, 1);
    });
  });
}
