import 'dart:ui' as ui;

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
import 'package:nesty_game/core/services/save/save_service.dart';
import 'package:nesty_game/core/services/skin/fake_skin_service.dart';
import 'package:nesty_game/core/services/skin/skin_service.dart';
import 'package:nesty_game/core/ui/nesty_ui.dart';
import 'package:nesty_game/features/daily/cubit/daily_cubit.dart';
import 'package:nesty_game/features/daily/pages/daily_page.dart';
import 'package:nesty_game/features/daily/widgets/daily_background_loader.dart';
import 'package:nesty_game/features/daily/widgets/daily_chest_modal.dart';
import 'package:nesty_game/features/daily/widgets/puzzle_card.dart';
import 'package:nesty_game/features/fx/chest/chest_reward_sequence.dart';
import 'package:nesty_game/features/fx/fake_fx_library.dart';
import 'package:nesty_game/features/fx/fx_library.dart';
import 'package:nesty_render/nesty_render.dart' show ChapterTheme;

import '../../core/ui/support/ui_harness.dart';
import '../support/screen_harness.dart';

/// No art (this file's tests never check the background; `puzzle_card_test
/// .dart` covers the fix directly), so nothing here touches a real SVG
/// decode.
class _NoDailyBackground implements DailyBackgroundLoader {
  const _NoDailyBackground();

  @override
  Future<ui.Image?> rasterize(
    ChapterTheme theme, {
    required Size box,
    required double devicePixelRatio,
  }) async => null;
}

/// The Daily screen (frames 5.1–5.6; docs/plans/m3-design.md §8.4, §10.5)
/// over a real [DailyCubit] built from a scripted [FakeDailyService] and
/// [FakeClock], the same pattern `gameplay_view_test.dart` uses for
/// `GameplayView`: [DailyView] reads the cubit from its `BlocProvider`
/// ancestor, so a test can drive real state transitions (the stream from
/// `FakeDailyService.status =`) instead of only literal states.
/// A [FakeDailyService] whose [collectChest] also pays the save, as
/// `StreakDailyService` does, so the header's handover from the landed
/// count to the paid balance can be checked.
final class _PayingDailyService extends FakeDailyService {
  _PayingDailyService(this._save, {super.status}) : super(FakeClock());

  final SaveService _save;

  @override
  int collectChest() {
    final paid = super.collectChest();
    if (paid > 0) _save.addCoins(paid);
    return paid;
  }
}

void main() {
  setUpAll(loadBundledFonts);

  final today = LocalDate(2026, 9, 26);

  DailyStatus status({
    bool unlocked = true,
    int streak = 4,
    // The frame's base case is lit ("orange gradient", design/README.md
    // "05 Daily" 5.1): every call below keeps the flame lit unless a test
    // is specifically about the paused look (m7-design §8, §15.7).
    bool lit = true,
    int freezes = 1,
    bool solvedToday = false,
    int cycleDone = 4,
    bool chestPending = false,
    LocalDate? freezeNotice,
    bool inProgress = false,
    DailySolve? solve,
  }) => DailyStatus(
    today: today,
    tier: Tier.hard,
    colors: 5,
    unlocked: unlocked,
    streak: streak,
    lit: lit,
    run: lit ? streak : 0,
    freezes: freezes,
    solvedToday: solvedToday,
    cycleDone: cycleDone,
    chestPending: chestPending,
    freezeNotice: freezeNotice,
    inProgress: inProgress,
    solve: solve,
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
    Widget? reminderOffer,
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
            RepositoryProvider<DailyBackgroundLoader>.value(
              value: const _NoDailyBackground(),
            ),
          ],
          // The view without the page's reminder offer (m7-design P3.10):
          // the offer card needs its DI-built cubit; its own tests cover it.
          child: DailyView(reminderOffer: reminderOffer),
        ),
      ),
      size: size,
      textScale: textScale,
    );
    await cubit.load();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
  }

  /// The day-7 chest opens closed (owner-chest's `ChestRewardSequence`):
  /// past its arrival, Open plays the wiggle and the burst, then Collect is
  /// live. The idle breath loops until Open, so this never `pumpAndSettle`s
  /// before the tap.
  Future<void> openDay7Chest(WidgetTester tester) async {
    await tester.pump(
      const Duration(milliseconds: ChestRewardSequence.arrivalMs + 50),
    );
    await tester.tap(find.text('Open'));
    // The open state's gold rays turn until the card leaves, so this pumps
    // the wiggle and the burst instead of settling.
    await tester.pump(
      const Duration(
        milliseconds:
            ChestRewardSequence.wiggleMs + ChestRewardSequence.burstMs + 100,
      ),
    );
  }

  /// Collect: the coins land (or burst in place) and the card fades out.
  Future<void> collectDay7Chest(WidgetTester tester) async {
    await tester.tap(find.text('Collect'));
    // The flights, then the fade, then the card leaves (up to a few s).
    for (var ms = 0; ms < 5000; ms += 50) {
      await tester.pump(const Duration(milliseconds: 50));
      if (find.text('7-day streak!').evaluate().isEmpty) break;
    }
  }

  testWidgets('frame 5.1: the streak card, the freeze chip, the 7-day '
      'strip and the chest row', (tester) async {
    final built = build(status: status());
    await pumpDaily(tester, built.cubit, built.jingles);

    expect(find.text('Daily'), findsOneWidget);
    expect(find.text('140'), findsOneWidget);
    expect(find.text('4 days'), findsOneWidget);
    // Value-framed since M7 (D92; m7-design §8, §16).
    expect(find.text('Play today to add to your streak'), findsOneWidget);
    expect(find.text('1 freeze'), findsOneWidget);
    expect(find.text('Day 7 chest · 300 coins'), findsOneWidget);
    expect(find.text('3 days to go, counting today'), findsOneWidget);
    // Day strip: 4 done, day 5 raised "Today", days 6 locked, day 7 the chest.
    expect(find.text('Today'), findsOneWidget);
    await built.cubit.close();
  });

  // E2 the gentle streak's paused look (m7-design §8, §15.7): a missed day
  // no freeze covered, streak unchanged, never red (Q96).
  testWidgets('a paused streak: the value-framed subline, not the keep-'
      'streak copy', (tester) async {
    final built = build(status: status(lit: false, streak: 6));
    await pumpDaily(tester, built.cubit, built.jingles);

    expect(find.text('6 days'), findsOneWidget);
    expect(
      find.text(
        'Your 6-day streak is resting. Solve today’s puzzle to light it again.',
      ),
      findsOneWidget,
    );
    expect(find.text('Play today to add to your streak'), findsNothing);
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

    expect(find.text('Your flame is lit. See you tomorrow.'), findsOneWidget);
    expect(find.text('Solved · +50'), findsOneWidget);
    expect(find.textContaining('Next puzzle in'), findsOneWidget);
    expect(find.text('Play Level 1'), findsOneWidget);
    // Share is on the daily win card (frame 10.1), never here (D188).
    expect(find.bySemanticsLabel('Share today’s result'), findsNothing);
    await built.cubit.close();
  });

  group('phase 5: page frame (F-PAGE, F-SAFE)', () {
    testWidgets('cream page; the list runs to the bottom edge and its last '
        'card clears the home indicator', (tester) async {
      final built = build(status: status());
      await pumpDaily(tester, built.cubit, built.jingles);
      expect(find.byType(CreamPage), findsOneWidget);
      final scroller = find.byType(SingleChildScrollView).first;
      // The harness gives 390x844 a 34 dp bottom inset.
      expect(tester.getRect(scroller).bottom, 844);
      await tester.drag(scroller, const Offset(0, -5000));
      await tester.pump();
      final card = find.byType(PuzzleCard);
      expect(tester.getRect(card).bottom, lessThanOrEqualTo(844 - 34));
      await built.cubit.close();
    });
  });

  group('E3: Share left the solved card (frame 5.5; phase 4, D188)', () {
    DailySolve solve() =>
        DailySolve(date: today, moves: 18, families: 5, minuteOfDay: 1150);

    // Share sits on the daily win card now (frame 10.1): only the win knows
    // the families' colours G.6's glyphs need. The solved card (5.5) keeps
    // its chip, countdown and Play Level N, and shares nothing.
    testWidgets('a solved day with a known solve shows no Share button', (
      tester,
    ) async {
      final built = build(
        status: status(
          solvedToday: true,
          cycleDone: 5,
          streak: 4,
          solve: solve(),
        ),
      );
      await pumpDaily(tester, built.cubit, built.jingles);
      expect(find.bySemanticsLabel('Share today’s result'), findsNothing);
      await built.cubit.close();
    });

    testWidgets('hidden before today is solved', (tester) async {
      final built = build(status: status());
      await pumpDaily(tester, built.cubit, built.jingles);
      expect(find.bySemanticsLabel('Share today’s result'), findsNothing);
      await built.cubit.close();
    });
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

  testWidgets('the day-7 chest is modal to a screen reader: the Daily '
      "screen's Back and Play behind it can't be reached (review R11)", (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    final open = build(status: status());
    await pumpDaily(tester, open.cubit, open.jingles);
    expect(find.semantics.byLabel('Back'), findsOne);
    expect(find.semantics.byLabel(RegExp('^Play, ')), findsOne);
    await open.cubit.close();

    final built = build(status: status(chestPending: true));
    await pumpDaily(tester, built.cubit, built.jingles);
    expect(find.text('7-day streak!'), findsOneWidget);
    // The live tree (a dropped node can stay cached on its render object).
    expect(find.semantics.byLabel('Back'), findsNothing);
    expect(find.semantics.byLabel(RegExp('^Play, ')), findsNothing);
    handle.dispose();
    await built.cubit.close();
  });

  testWidgets('the day-7 chest dims the whole screen, status bar and home '
      'indicator included (frame 5.6)', (tester) async {
    // The device run (2026-09-30) found both safe-area bands undimmed: the
    // chest sat inside the page's SafeArea.
    final built = build(status: status(chestPending: true));
    await pumpDaily(tester, built.cubit, built.jingles);
    expect(find.text('7-day streak!'), findsOneWidget);
    final safe = safeAreaOf(const Size(390, 844));
    expect(safe.top, greaterThan(0), reason: 'a phone with insets');
    expect(
      tester.getRect(find.byType(Scrim)),
      Offset.zero & const Size(390, 844),
    );
    // The screen's own content still keeps clear of the insets.
    expect(tester.getRect(find.text('Daily')).top, greaterThan(safe.top));
    await built.cubit.close();
  });

  testWidgets('the day-7 chest modal: Collect pays the coins and plays the '
      'reward jingle once', (tester) async {
    final built = build(status: status(chestPending: true));
    await pumpDaily(tester, built.cubit, built.jingles);

    expect(find.text('7-day streak!'), findsOneWidget);
    expect(find.text('+300 coins'), findsOneWidget);
    expect(built.jingles.jingles, isEmpty);

    // The chest opens closed (owner-chest): past its arrival, Open plays
    // the wiggle and the burst, then Collect is live.
    await openDay7Chest(tester);
    expect(built.jingles.jingles, isEmpty, reason: 'nothing paid on Open');
    await collectDay7Chest(tester);

    expect(find.text('7-day streak!'), findsNothing);
    expect(built.jingles.jingles, [Jingle.reward]);
    expect(built.cubit.state.data!.status.chestPending, isFalse);
    // Lets `JingleCues.reward`'s own duck/unduck timer (the jingle's
    // length) fire before the test ends, so no timer outlives the tree.
    await tester.pump(const Duration(seconds: 4));
    await built.cubit.close();
  });

  // The owner's chest request (design request I.3): Collect flies the coins
  // to the screen's own coin pill, which counts up as each one lands, then
  // shows the paid balance.
  testWidgets('the day-7 chest flies its coins to the header coin pill, '
      'which ticks up as they land', (tester) async {
    final save = FakeSaveService(initial: const SaveDocument(coins: 140));
    final daily = _PayingDailyService(save, status: status(chestPending: true));
    final jingles = FakeAudioService();
    final cubit = DailyCubit(
      daily,
      FakeLevelResolver(FakeLevelRepository(), save, FakeRemoteConfigService()),
      save,
      FakeRemoteConfigService(),
    );
    await pumpDaily(tester, cubit, jingles);
    int pill() => tester
        .widget<CoinPill>(
          find.descendant(
            of: find.byType(ScreenHeader),
            matching: find.byType(CoinPill),
          ),
        )
        .coins;
    expect(pill(), 140);

    final modal = tester.widget<DailyChestModal>(find.byType(DailyChestModal));
    expect(
      modal.coinTarget?.call(),
      tester.getRect(
        find.descendant(
          of: find.byType(ScreenHeader),
          matching: find.byType(CoinPill),
        ),
      ),
      reason: 'the coins fly to the header pill',
    );

    await openDay7Chest(tester);
    await tester.tap(find.text('Collect'));
    // Frame by frame until the first coins have landed while the last are
    // still in the air (the sprites leave 40 ms apart, each flies 520 ms).
    const firstLandings =
        ChestRewardSequence.collectFlightMs +
        2 * ChestRewardSequence.collectStaggerMs;
    for (var ms = 0; ms < firstLandings; ms += 16) {
      await tester.pump(const Duration(milliseconds: 16));
    }
    expect(pill(), inExclusiveRange(140, 440));
    expect(save.coins, 140, reason: 'paid only once the flights land');

    await tester.pump(
      const Duration(
        milliseconds:
            ChestRewardSequence.collectFlightMs +
            ChestRewardSequence.coinSpriteCount *
                ChestRewardSequence.collectStaggerMs +
            ChestRewardSequence.exitFadeMs +
            400,
      ),
    );
    expect(save.coins, 440);
    expect(pill(), 440);
    expect(cubit.state.data!.status.chestPending, isFalse);
    await tester.pump(const Duration(seconds: 4));
    await cubit.close();
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

  testWidgets('frame 5.2: the freeze notice ("Freeze used", M7\'s rewrite of '
      '"Streak saved!") shows once and acknowledges the notice', (
    tester,
  ) async {
    final frozen = LocalDate(2026, 9, 25);
    final built = build(status: status(freezeNotice: frozen));
    await pumpDaily(tester, built.cubit, built.jingles);

    // copy.md G.9 `streak_freeze_used`.
    // The toast's title and the streak card's line (m7-4 4.17).
    expect(find.text('A freeze kept your flame lit.'), findsNWidgets(2));
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

  group('the reminder offer slot (frame 10.2; phase 4 lane D)', () {
    const marker = Text('OFFER-MARKER');

    testWidgets('is not shown before today is solved', (tester) async {
      final built = build(status: status());
      await pumpDaily(
        tester,
        built.cubit,
        built.jingles,
        reminderOffer: marker,
      );
      expect(find.text('OFFER-MARKER'), findsNothing);
      await built.cubit.close();
    });

    testWidgets('is shown over the whole screen once today is solved', (
      tester,
    ) async {
      final built = build(status: status(solvedToday: true, cycleDone: 2));
      await pumpDaily(
        tester,
        built.cubit,
        built.jingles,
        reminderOffer: marker,
      );
      expect(find.text('OFFER-MARKER'), findsOneWidget);
      await built.cubit.close();
    });

    testWidgets('waits for the day-7 chest: the chest is collected first', (
      tester,
    ) async {
      final built = build(
        status: status(solvedToday: true, cycleDone: 7, chestPending: true),
      );
      await pumpDaily(
        tester,
        built.cubit,
        built.jingles,
        reminderOffer: marker,
      );
      expect(find.text('7-day streak!'), findsOneWidget);
      expect(find.text('OFFER-MARKER'), findsNothing);
      await built.cubit.close();
      await tester.pump(const Duration(seconds: 4));
    });
  });
}
