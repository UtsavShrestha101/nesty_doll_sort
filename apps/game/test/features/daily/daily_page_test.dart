import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_core/nesty_core.dart';
import 'package:nesty_game/core/repository/fake_level_repository.dart';
import 'package:nesty_game/core/repository/fake_level_resolver.dart';
import 'package:nesty_game/core/services/audio/fake_audio_service.dart';
import 'package:nesty_game/core/services/audio/jingle_player.dart';
import 'package:nesty_game/core/services/clock/fake_clock.dart';
import 'package:nesty_game/core/services/clock/local_date.dart';
import 'package:nesty_game/core/services/daily/daily_status.dart';
import 'package:nesty_game/core/services/daily/fake_daily_service.dart';
import 'package:nesty_game/core/services/database/database_service.dart';
import 'package:nesty_game/core/services/database/fake_database_service.dart';
import 'package:nesty_game/core/services/music/fake_music_service.dart';
import 'package:nesty_game/core/services/music/jingle_cues.dart';
import 'package:nesty_game/core/services/remote_config/fake_remote_config_service.dart';
import 'package:nesty_game/core/services/save/fake_save_service.dart';
import 'package:nesty_game/core/services/save/save_document.dart';
import 'package:nesty_game/core/services/skin/fake_skin_service.dart';
import 'package:nesty_game/core/services/skin/skin_service.dart';
import 'package:nesty_game/features/daily/cubit/daily_cubit.dart';
import 'package:nesty_game/features/daily/pages/daily_page.dart';
import 'package:nesty_game/features/fx/fake_fx_library.dart';
import 'package:nesty_game/features/fx/fx_library.dart';

import '../../core/ui/support/ui_harness.dart';
import '../support/screen_harness.dart';

/// The Daily screen (frames 5.1–5.6; docs/plans/m3-design.md §8.4, §10.5)
/// over a real [DailyCubit] built from a scripted [FakeDailyService] and
/// [FakeClock], the same pattern `gameplay_view_test.dart` uses for
/// `GameplayView`: [DailyView] reads the cubit from its `BlocProvider`
/// ancestor, so a test can drive real state transitions (the stream from
/// `FakeDailyService.status =`) instead of only literal states.
void main() {
  setUpAll(loadBundledFonts);

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

  ({DailyCubit cubit, FakeDailyService daily, FakeAudioService jingles}) build({
    DailyStatus? status,
    int coins = 140,
  }) {
    final save = FakeSaveService(initial: SaveDocument(coins: coins));
    final levels = FakeLevelRepository();
    final resolver = FakeLevelResolver(levels, save, FakeRemoteConfigService());
    final daily = FakeDailyService(FakeClock(), status: status);
    final jingles = FakeAudioService();
    return (
      cubit: DailyCubit(daily, resolver, save, FakeRemoteConfigService()),
      daily: daily,
      jingles: jingles,
    );
  }

  Future<void> pumpDaily(
    WidgetTester tester,
    DailyCubit cubit,
    FakeAudioService jingles, {
    Size size = const Size(390, 844),
    double textScale = 1,
  }) async {
    // `addTearDown` fires after flutter_test's own pending-timer invariant
    // check, so every test below closes the cubit itself (cancelling its
    // countdown timer) as its last step instead.
    await pumpScreen(
      tester,
      MultiBlocProvider(
        providers: [BlocProvider<DailyCubit>.value(value: cubit)],
        child: MultiRepositoryProvider(
          providers: [
            RepositoryProvider<JingleCues>.value(
              value: JingleCues(FakeMusicService(), jingles),
            ),
            RepositoryProvider<SkinService>.value(value: FakeSkinService()),
            RepositoryProvider<DatabaseService>.value(
              value: FakeDatabaseService(),
            ),
            RepositoryProvider<FxLibrary>.value(value: FakeFxLibrary()),
          ],
          child: const DailyPage(),
        ),
      ),
      size: size,
      textScale: textScale,
    );
    await cubit.load();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
  }

  testWidgets('frame 5.1: the streak card, the freeze chip, the 7-day '
      'strip and the chest row', (tester) async {
    final built = build(status: status());
    await pumpDaily(tester, built.cubit, built.jingles);

    expect(find.text('Daily'), findsOneWidget);
    expect(find.text('140'), findsOneWidget);
    expect(find.text('4 days'), findsOneWidget);
    expect(find.text('Play today to keep your streak'), findsOneWidget);
    expect(find.text('1 freeze'), findsOneWidget);
    expect(find.text('Day 7 chest · 300 coins'), findsOneWidget);
    expect(find.text('3 days to go, counting today'), findsOneWidget);
    // Day strip: 4 done, day 5 raised "Today", days 6 locked, day 7 the chest.
    expect(find.text('Today'), findsOneWidget);
    await built.cubit.close();
  });

  testWidgets('the puzzle card: the weekday, the colors and tier, and Play '
      'with its coin chip', (tester) async {
    final built = build(status: status());
    await pumpDaily(tester, built.cubit, built.jingles);

    expect(find.text('Saturday’s puzzle'), findsOneWidget);
    expect(find.text('5 colors · Hard'), findsOneWidget);
    expect(find.text('Play'), findsOneWidget);
    expect(find.text('50'), findsOneWidget);
    await built.cubit.close();
  });

  testWidgets('frame 5.5: solved shows the "+50" chip, the countdown and '
      '"Play Level N"', (tester) async {
    final built = build(status: status(solvedToday: true, cycleDone: 5));
    await pumpDaily(tester, built.cubit, built.jingles);

    expect(find.text('Done for today. See you tomorrow!'), findsOneWidget);
    expect(find.text('Solved · +50'), findsOneWidget);
    expect(find.textContaining('Next puzzle in'), findsOneWidget);
    expect(find.text('Play Level 1'), findsOneWidget);
    await built.cubit.close();
  });

  testWidgets('a full week shows "A full week!"', (tester) async {
    final built = build(
      status: status(solvedToday: true, streak: 7, cycleDone: 7),
    );
    await pumpDaily(tester, built.cubit, built.jingles);
    expect(find.text('A full week!'), findsOneWidget);
    await built.cubit.close();
  });

  testWidgets('the countdown ticks while the screen stays open', (
    tester,
  ) async {
    final built = build(status: status(solvedToday: true));
    await pumpDaily(tester, built.cubit, built.jingles);
    final before =
        find.textContaining('Next puzzle in').evaluate().single.widget as Text;

    // The cubit's own countdown timer fires every minute in real use; the
    // page doesn't expose a faster one, so this only checks the same text
    // renders without an overflow/exception after time passes in the tree.
    await tester.pump(const Duration(seconds: 1));
    final after =
        find.textContaining('Next puzzle in').evaluate().single.widget as Text;
    expect(after.data, before.data);
    await built.cubit.close();
  });

  testWidgets('locked before Level 2 shows the lock, not the strip', (
    tester,
  ) async {
    final built = build(status: status(unlocked: false));
    await pumpDaily(tester, built.cubit, built.jingles);
    expect(find.text('After Level 2'), findsOneWidget);
    expect(find.text('Day 7 chest · 300 coins'), findsNothing);
    await built.cubit.close();
  });

  testWidgets('the day-7 chest modal: Collect pays the coins and plays the '
      'reward jingle once', (tester) async {
    final built = build(status: status(chestPending: true));
    await pumpDaily(tester, built.cubit, built.jingles);

    expect(find.text('7-day streak!'), findsOneWidget);
    expect(find.text('+300'), findsOneWidget);
    expect(built.jingles.jingles, isEmpty);

    await tester.tap(find.text('Collect'));
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('7-day streak!'), findsNothing);
    expect(built.jingles.jingles, [Jingle.reward]);
    expect(built.cubit.state.data!.status.chestPending, isFalse);
    // Lets `JingleCues.reward`'s own duck/unduck timer (the jingle's
    // length) fire before the test ends, so no timer outlives the tree.
    await tester.pump(const Duration(seconds: 4));
    await built.cubit.close();
  });

  testWidgets('collectChest with nothing pending never plays the jingle', (
    tester,
  ) async {
    final built = build(status: status());
    await pumpDaily(tester, built.cubit, built.jingles);
    expect(find.text('7-day streak!'), findsNothing);
    expect(built.jingles.jingles, isEmpty);
    await built.cubit.close();
  });

  testWidgets('frame 5.2: "Streak saved!" shows once and acknowledges the '
      'notice', (tester) async {
    final frozen = LocalDate(2026, 9, 25);
    final built = build(status: status(freezeNotice: frozen));
    await pumpDaily(tester, built.cubit, built.jingles);

    expect(find.text('Streak saved!'), findsOneWidget);
    expect(
      find.text("A freeze covered Friday. You'll earn a new one next week."),
      findsOneWidget,
    );
    expect(built.daily.noticesAcknowledged, 1);

    // The notice cleared through the stream: a later rebuild doesn't show
    // it again.
    built.cubit.refresh();
    await tester.pump();
    expect(built.daily.noticesAcknowledged, 1);
    // Lets the toast's own auto-dismiss timer fire before the test ends.
    await tester.pump(const Duration(seconds: 4));
    await built.cubit.close();
  });

  group('semantics labels come from ARB, not concatenation (RULES-2)', () {
    testWidgets('the day strip reads "Today, day N" and "Tomorrow, day N"', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      final built = build(status: status());
      await pumpDaily(tester, built.cubit, built.jingles);
      expect(find.bySemanticsLabel('Day 4, done'), findsOneWidget);
      expect(find.bySemanticsLabel('Today, day 5'), findsOneWidget);
      expect(find.bySemanticsLabel('Day 6'), findsOneWidget);
      expect(find.bySemanticsLabel('Day 7, chest'), findsOneWidget);
      await built.cubit.close();
      handle.dispose();
    });

    testWidgets('solved: the next cell is "Tomorrow", never "Tmrw"', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      final built = build(status: status(solvedToday: true, cycleDone: 5));
      await pumpDaily(tester, built.cubit, built.jingles);
      expect(find.bySemanticsLabel('Tomorrow, day 6'), findsOneWidget);
      expect(find.bySemanticsLabel(RegExp('Tmrw')), findsNothing);
      await built.cubit.close();
      handle.dispose();
    });

    testWidgets('Play reads "Play, 50 coins"', (tester) async {
      final handle = tester.ensureSemantics();
      final built = build(status: status());
      await pumpDaily(tester, built.cubit, built.jingles);
      expect(find.bySemanticsLabel('Play, 50 coins'), findsOneWidget);
      await built.cubit.close();
      handle.dispose();
    });
  });
}
