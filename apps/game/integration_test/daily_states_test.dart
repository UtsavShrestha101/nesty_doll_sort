import 'dart:async';
import 'dart:convert';
import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:intl/intl.dart';
import 'package:nesty_game/core/dependency_injection/di.dart';
import 'package:nesty_game/core/models/reduce_motion_mode.dart';
import 'package:nesty_game/core/models/reminder_settings.dart';
import 'package:nesty_game/core/models/symbols_mode.dart';
import 'package:nesty_game/core/router/app_router.dart';
import 'package:nesty_game/core/services/clock/local_date.dart';
import 'package:nesty_game/core/services/clock/system_clock.dart';
import 'package:nesty_game/core/services/daily/daily_service.dart';
import 'package:nesty_game/core/services/database/database_service.dart';
import 'package:nesty_game/core/services/save/in_memory_save_service.dart';
import 'package:nesty_game/core/services/save/save_document.dart';
import 'package:nesty_game/core/services/save/save_service.dart';
import 'package:nesty_game/core/ui/nesty_ui.dart';
import 'package:nesty_game/core/ui/widgets/home/streak_look.dart';
import 'package:nesty_game/features/daily/pages/daily_page.dart';
import 'package:nesty_game/features/daily/widgets/daily_locked_card.dart';
import 'package:nesty_game/features/daily/widgets/month_card.dart';
import 'package:nesty_game/features/daily/widgets/past_day_card.dart';
import 'package:nesty_game/features/daily/widgets/streak_card.dart';
import 'package:nesty_game/features/gameplay/bloc/gameplay_bloc.dart';
import 'package:nesty_game/features/gameplay/overlays/out_of_moves_sheet.dart';
import 'package:nesty_game/features/gameplay/overlays/past_day_win_card.dart';
import 'package:nesty_game/features/gameplay/overlays/win_chapter_card.dart'
    show DailyStreakCard;
import 'package:nesty_game/features/gameplay/pages/gameplay_view.dart';
import 'package:nesty_game/features/home/pages/home_page.dart';
import 'package:nesty_game/features/settings/pages/settings_page.dart';
import 'package:nesty_game/features/welcome_back/widgets/welcome_back_card.dart';
import 'package:nesty_game/main_dev.dart' as app;

import 'support/board_probe.dart';
import 'support/phone_language.dart';
import 'support/seeded_save.dart';
import 'support/time_picker_probe.dart';

/// The daily's and Settings' states on a device (phase 4 lane D; m7-design
/// P4.6; architecture §7.3; frames 5.6, 5.6b, 10.2, 10.2d, 10.2e, 10.7,
/// 10.7b, 8.1): a seeded save, `NESTY_FAKE_DATE`, and one scenario per run,
/// chosen by `--dart-define=NESTY_DAILY_SCENARIO=<name>`:
///
/// - `chest` (the default): a 6-day streak lit through yesterday. Home,
///   Daily (the lit card, the strip), Play, solve with hints, Back to Daily,
///   the day-7 chest opens CLOSED with its contents shown (5.6), Open
///   (5.6b), Collect, then the one-time reminder offer (10.2) answered "No
///   thanks".
/// - `paused`: a 4-day streak whose flame is paused (a missed day, no
///   freeze). The Daily card is paused (10.7); a solve relights it: the win
///   card reads "Streak relit!" (10.7b) and Daily shows the lit card again.
/// - `saved` (phase 5): a freeze covers yesterday on the first open (5.2,
///   "Streak saved!").
/// - `settings`: Relaxed mode, Reduce motion, Sound, Haptics and Color
///   symbols in Settings (10.2e), then a board where Undo shows the
///   unlimited glyph and undoes past the free ones, with the Relaxed mode
///   toast at the board's first frame (10.9).
///
/// Phase 5 also shoots the offer's time picker (10.2b) in `chest`, and the
/// Daily and Settings screens scrolled to their ends (F-SAFE). After
/// Claude Design's m7-4: `saved` shoots the freeze toast with the streak
/// card's freeze line (5.2), then the line kept once the toast has gone;
/// `paused` checks the paused card's freeze chip (5.2b) and, after the
/// relight, Home's Daily badge glowing on the first visit and never again
/// (m7-4 4.10, `motion.relitHome`); `settings` checks the 48 dp Reduce
/// motion control (10.2e).
///
/// The local habits (plan-local-habits §1–§2, D297) add two:
/// - `welcome`: the app last opened three days ago, a 4-day streak paused.
///   Home shows the welcome-back card with the paused line (14.1b
///   stand-in); its Play goes to today's daily over the Daily screen; the
///   win's Back to Daily lands on the Daily, and Home then has no card.
/// - `month`: on the 31st (`nesty-test` passes 20261031), the Daily's
///   month of played days: solved days lit, a frozen day's mark, days not
///   played plain, today marked (14.2 stand-in), each by its screen-reader
///   label.
/// - `locked` (m7-6 12.14): Level 1 won, Level 2 not: Home's Daily tile opens
///   the Daily before it unlocks; its button plays Level 2.
///
/// - `archive` (local habits 3, `nesty-test` passes 20261103): a paused
///   streak, today's daily played two moves and left. The Daily's month shows
///   its window across the 1st (the ‹ October chip), a window day opens its
///   card (14.3b), Play opens the board with the date pill and no coin pill
///   (14.3c), its win is the date card with no streak or coins (14.3d), Back
///   to Daily lands on the month with the played-later mark (14.3e), the
///   streak is unchanged and today's board resumes with its two moves.
///
/// ```sh
/// cd apps/game
/// flutter drive --flavor dev --driver test_driver/integration_test.dart \
///   --target integration_test/daily_states_test.dart \
///   --dart-define=NESTY_FAKE_DATE=20260926 \
///   --dart-define=NESTY_DAILY_SCENARIO=chest -d <device>
/// ```
///
/// `nesty-test` runs each scenario from a fresh install. Written, and run
/// by the device stage, never by the lane. Screenshots are prefixed `d_`.
/// Not on a device: the OS permission dialog and the phone's settings page
/// (the reminder's Yes is never tapped here; `reminder_test.dart` covers
/// the Android schedule, and the widget tests the denied card), haptics.
const _scenario = String.fromEnvironment(
  'NESTY_DAILY_SCENARIO',
  defaultValue: 'chest',
);

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  binding.framePolicy = LiveTestWidgetsFlutterBindingFramePolicy.fullyLive;

  testWidgets(
    'the daily and Settings states: $_scenario',
    (tester) async {
      pinEnglishPhone(tester);
      final today = _fakeToday();
      await switch (_scenario) {
        'paused' => _seedPaused(today),
        'saved' => _seedSaved(today),
        'settings' => _seedSettings(),
        'welcome' => _seedWelcome(today),
        'month' => _seedMonth(today),
        'archive' => _seedArchive(today),
        'locked' => _seedLocked(),
        _ => _seedChest(today),
      };

      app.main();
      final board = Board(tester);
      final shots = _Shots(binding, tester);
      await tester.pumpUntil(
        () => find.byType(HomePage).evaluate().isNotEmpty,
        timeout: const Duration(seconds: 60),
        reason: 'Home for the seeded save (uninstall the app first)',
      );
      await tester.pumpFor(const Duration(milliseconds: 800));

      switch (_scenario) {
        case 'paused':
          await _paused(tester, board, shots);
        case 'saved':
          await _saved(tester, shots);
        case 'settings':
          await _settings(tester, board, shots);
        case 'welcome':
          await _welcome(tester, board, shots);
        case 'locked':
          await _locked(tester, shots);
        case 'month':
          await _month(tester, shots);
        case 'archive':
          await _archive(tester, board, shots);
        default:
          await _chest(tester, board, shots);
      }
      // Merged, never replaced: `takeScreenshot` keeps the shots in
      // `reportData['screenshots']`, and the driver only writes what is
      // still there at the end.
      binding.reportData = {
        ...?binding.reportData,
        'daily_states': {
          'scenario': _scenario,
          'platform': Platform.operatingSystem,
        },
      };
      // ignore: avoid_print
      print('NESTY_DAILY_STATES ${jsonEncode({'scenario': _scenario})}');
    },
    timeout: const Timeout(Duration(minutes: 8)),
  );
}

/// `NESTY_FAKE_DATE` as a date; the run fails without it, since the seeds
/// are dated against it.
LocalDate _fakeToday() {
  const define = SystemClock.fakeDateDefine;
  expect(
    define,
    isNotEmpty,
    reason: 'pass --dart-define=NESTY_FAKE_DATE=yyyymmdd (dev flavor)',
  );
  return LocalDate.fromYyyymmdd(int.parse(define));
}

SaveDocument _base(DailyProgress daily) => SaveDocument(
  // Level 3 next: the daily is unlocked (Level 2 won). Both fields, so
  // Home's PLAY is level 3's (`currentLevel` alone defaults to 1).
  currentLevel: 3,
  highestLevel: 3,
  coins: 880,
  daily: daily,
);

/// Six days lit through yesterday: today's solve is day 7.
Future<void> _seedChest(LocalDate today) => seedSave(
  _base(
    DailyProgress(
      streak: 6,
      lit: true,
      run: 6,
      lastDate: today.addDays(-1),
      done: [for (var back = 6; back >= 1; back--) today.addDays(-back)],
    ),
  ),
);

/// Four days counted, the flame out: the last solve was three days ago and
/// no freeze covered the gap. This week's freeze is already spent
/// (`freezes` 0, `freezeWeek` this week): `refresh()` grants a week's
/// freeze unless `freezeWeek` is that week, and frame 10.7 is the paused
/// card with none to cover a miss (architecture.md §1.3).
Future<void> _seedPaused(LocalDate today) => seedSave(
  _base(
    DailyProgress(
      streak: 4,
      freezeWeek: today.isoWeekKey,
      done: [for (var back = 6; back >= 3; back--) today.addDays(-back)],
    ),
  ),
  // The one-time reminder offer (10.2) has been shown, so it doesn't cover
  // the Daily screen's Back after the relighting solve.
  settings: const SeededSettings(reminder: ReminderSettings(offered: true)),
);

/// Frame 5.2's "first open after a missed day": four days lit through the
/// day before yesterday, one freeze held from last week. Opening the app
/// covers yesterday with it (the "Streak saved!" notice) and leaves none
/// this week (architecture.md §1.3).
Future<void> _seedSaved(LocalDate today) => seedSave(
  _base(
    DailyProgress(
      streak: 4,
      lit: true,
      run: 4,
      lastDate: today.addDays(-2),
      freezes: 1,
      freezeWeek: today.addDays(-7).isoWeekKey,
      done: [for (var back = 5; back >= 2; back--) today.addDays(-back)],
    ),
  ),
);

Future<void> _seedSettings() => seedSave(_base(const DailyProgress()));

/// Welcome back (plan-local-habits §1): last opened three days ago, a
/// 4-day streak paused (as `paused`: this week's freeze already spent), so
/// the first open finds the gap and Home shows the card's paused line.
Future<void> _seedWelcome(LocalDate today) => seedSave(
  _base(
    DailyProgress(
      streak: 4,
      freezeWeek: today.isoWeekKey,
      done: [for (var back = 6; back >= 3; back--) today.addDays(-back)],
    ),
  ),
  settings: SeededSettings(
    reminder: const ReminderSettings(offered: true),
    lastOpenDate: today.addDays(-3).toString(),
  ),
);

/// 12.14: Level 1 won, so the Daily (after Level 2) is not open yet.
Future<void> _seedLocked() => seedSave(
  const SaveDocument(currentLevel: 2, highestLevel: 2, coins: 880),
  settings: const SeededSettings(reminder: ReminderSettings(offered: true)),
);

/// The month of played days (plan-local-habits §2), dated against the
/// 31st: solves on the 3rd–5th, 8th, 9th, 12th, 20th–22nd and yesterday,
/// a freeze on the 13th, lit through yesterday (no gap to reconcile).
Future<void> _seedMonth(LocalDate today) {
  LocalDate day(int d) => LocalDate(today.year, today.month, d);
  final done = [
    for (final d in [3, 4, 5, 8, 9, 12, 20, 21, 22, 30]) day(d),
  ];
  return seedSave(
    _base(
      DailyProgress(
        streak: done.length,
        lit: true,
        run: 1,
        lastDate: today.addDays(-1),
        freezeWeek: today.isoWeekKey,
        done: done,
        frozen: [day(13)],
        // Its "Streak saved" notice was seen on the 14th, so the Daily
        // opens without the toast over the strip.
        noticeDate: day(13),
      ),
    ),
    settings: const SeededSettings(reminder: ReminderSettings(offered: true)),
  );
}

/// The past dailies (plan-local-habits §3), dated against the 3rd of a
/// month so the 7-day window reaches the month before: a paused 4-day
/// streak (this week's freeze spent, no notice to show), the reminder offer
/// already shown.
Future<void> _seedArchive(LocalDate today) => seedSave(
  _base(
    DailyProgress(
      streak: 4,
      freezeWeek: today.isoWeekKey,
      done: [for (var back = 6; back >= 3; back--) today.addDays(-back)],
    ),
  ),
  settings: const SeededSettings(reminder: ReminderSettings(offered: true)),
);

Future<void> _openDaily(WidgetTester tester, _Shots shots, String name) async {
  await tester.tap(find.text('Daily Puzzle'));
  await tester.pumpUntil(
    () => find.byType(DailyPage).evaluate().isNotEmpty,
    reason: 'the Daily screen',
  );
  await tester.pumpFor(const Duration(seconds: 1));
  await shots.take(name);
}

/// Plays today's daily to its win with the solver's own hints (the puzzle
/// comes from the date, so no move is scripted). With [shots], each intro
/// card the board opens on is shot first (`d_<prefix>_intro_<mechanic>`).
Future<void> _playDailyToWin(
  WidgetTester tester,
  Board board, {
  _Shots? shots,
  String prefix = '',
  String start = 'Play',
  Finder? startFinder,
  Future<void> Function()? afterStart,
}) async {
  await tester.tap(startFinder ?? find.text(start));
  await tester.pumpUntil(
    () =>
        find.byType(GameplayView).evaluate().isNotEmpty &&
        board.game.geometry != null &&
        board.game.skin != null,
    timeout: const Duration(seconds: 30),
    reason: "today's daily with its skin",
  );
  // Settle first: the board's intro cards (this save has seen none, and
  // the day's board may have towers or glass) come up just after the
  // board, and a Hint tapped before them lands on the card (the device
  // run, 2026-09-30).
  await board.waitIdle();
  await tester.pumpFor(const Duration(milliseconds: 1200));
  if (afterStart != null) await afterStart();
  final hintButton = find.text('Hint');
  for (var i = 0; i < 40; i++) {
    for (
      var shown = board.state.intro;
      shown != null;
      shown = board.state.intro
    ) {
      await tester.pumpFor(const Duration(milliseconds: 400));
      await shots?.take('d_${prefix}_intro_${shown.name}');
      await tester.tap(find.text('Got it'));
      await tester.pumpUntil(
        () => board.state.intro != shown,
        reason: 'the ${shown.name} intro card dismissed',
      );
    }
    // Won by the last hint: a won board stays input-locked under its win
    // card, so it never goes idle (the device run timed out there).
    if (board.state.status != GameplayStatus.playing) break;
    await board.waitIdle();
    if (board.state.status != GameplayStatus.playing) break;
    // A dismissed card fades out over the booster bar for a moment and
    // takes a tap meant for Hint (the device run, 2026-09-30): wait until
    // Hint itself is the one hit.
    await tester.pumpUntil(
      () => hintButton.hitTestable().evaluate().isNotEmpty,
      reason:
          'Hint uncovered (intro ${board.state.intro}, paused '
          '${board.state.paused}, status ${board.state.status})',
    );
    await tester.tap(hintButton);
    await tester.pumpUntil(
      () => board.state.hint != null,
      timeout: const Duration(seconds: 15),
      reason: 'a hint',
    );
    final hint = board.state.hint!;
    await board.move(hint.from, hint.to);
  }
  await board.waitForWinOverlay();
  await tester.pumpFor(const Duration(milliseconds: 1500));
}

Future<void> _chest(WidgetTester tester, Board board, _Shots shots) async {
  await _openDaily(tester, shots, 'd_01_lit_6_days');
  expect(find.text('6 days'), findsOneWidget);
  await _playDailyToWin(tester, board, shots: shots, prefix: '01b');
  await shots.take('d_02_daily_win_day7');
  await tester.tap(find.text('Back to Daily'));

  // 5.6: the chest arrives closed with its contents shown, before Open.
  await tester.pumpUntil(
    () => find.text('7-day streak!').evaluate().isNotEmpty,
    reason: 'the day-7 chest modal',
  );
  // The chest's `arrive` (it drops in and squashes) has to be over for the
  // shot to show the settled art size (frame 5.6, `artFit`).
  await tester.pumpFor(const Duration(milliseconds: 2200));
  expect(find.text('+300 coins'), findsOneWidget, reason: 'contents first');
  expect(find.text('Open'), findsOneWidget);
  expect(find.text('Collect'), findsNothing);
  await shots.take('d_03_day7_chest_closed');

  await tester.tap(find.text('Open'));
  await tester.pumpUntil(
    () => find.text('Collect').evaluate().isNotEmpty,
    reason: 'the open chest with Collect (5.6b)',
  );
  // Past the burst, the open pose settled with Collect showing (5.6b).
  await tester.pumpFor(const Duration(milliseconds: 2000));
  expect(find.text('Collect'), findsOneWidget);
  await shots.take('d_04_day7_chest_open');
  await tester.tap(find.text('Collect'));
  await tester.pumpUntil(
    () => find.text('7-day streak!').evaluate().isEmpty,
    timeout: const Duration(seconds: 10),
    reason: 'the chest closed after Collect',
  );

  // 10.2: the one-time reminder offer, after the first solve.
  const offerTitle = 'Want a note when tomorrow’s puzzle is ready?';
  await tester.pumpUntil(
    () => find.text(offerTitle).evaluate().isNotEmpty,
    reason: 'the reminder offer',
  );
  await tester.pumpFor(const Duration(milliseconds: 600));
  await shots.take('d_05_reminder_offer');
  // Frame 10.2b: "Change time" opens the phone's time picker over the
  // offer; Cancel keeps the offered time (architecture.md §1.3).
  await tester.ensureVisible(find.text('Change time'));
  await tester.pumpFor(const Duration(milliseconds: 300));
  await tester.tap(find.text('Change time'));
  await tester.waitForTimePicker('the time picker (10.2b)');
  await shots.take('d_05b_time_picker');
  await tester.cancelTimePicker();
  await tester.pumpFor(const Duration(milliseconds: 400));
  expect(find.text(offerTitle), findsOneWidget, reason: 'the offer stays');
  await tester.tap(find.text('No thanks'));
  await tester.pumpUntil(
    () => find.text(offerTitle).evaluate().isEmpty,
    reason: 'No thanks closes the offer',
  );
  final reminder = get<DatabaseService>().reminder;
  expect(reminder.offered && !reminder.on, isTrue, reason: '$reminder');
  await tester.pumpFor(const Duration(milliseconds: 500));
  await shots.take('d_06_daily_after_day7');
  // F-SAFE (lane RD): scrolled to the end, the last card clears the home
  // indicator and the cream gradient runs to the screen's bottom edge.
  await _scrollToEnd(tester, DailyPage);
  await shots.take('d_07_daily_bottom');
}

/// Scrolls [page]'s first vertical scrollable to its end and lets it
/// settle.
Future<void> _scrollToEnd(WidgetTester tester, Type page) async {
  final position = tester
      .stateList<ScrollableState>(
        find.descendant(
          of: find.byType(page),
          matching: find.byType(Scrollable),
        ),
      )
      .map((state) => state.position)
      .firstWhere((position) => position.axis == Axis.vertical);
  position.jumpTo(position.maxScrollExtent);
  await tester.pumpFor(const Duration(milliseconds: 500));
}

/// Frame 5.2: the first open after a missed day a freeze covered. The Daily
/// screen shows the freeze notice once as a toast (copy.md G.9
/// `streak_freeze_used`), the streak card's line reads "A freeze kept your
/// flame lit." (m7-4 4.17) and its freeze chip has none left this week
/// ("No freeze", `dailyFreezes`: copy.md's "0 left" is an owner question).
/// The card keeps its line after the toast has gone, until the solve.
Future<void> _saved(WidgetTester tester, _Shots shots) async {
  await shots.take('d_02a_home_saved');
  await tester.tap(find.text('Daily Puzzle'));
  const line = 'A freeze kept your flame lit.';
  final card = find.byType(StreakCard);
  final cardLine = find.descendant(of: card, matching: find.text(line));
  final toast = find.byType(ToastCard);
  await tester.pumpUntil(
    () => cardLine.evaluate().isNotEmpty && toast.evaluate().isNotEmpty,
    reason: 'the freeze toast and the card\'s freeze line (5.2)',
  );
  await tester.pumpFor(const Duration(milliseconds: 500));
  expect(find.text('4 days'), findsOneWidget);
  expect(find.descendant(of: toast, matching: find.text(line)), findsOneWidget);
  expect(
    find.descendant(of: card, matching: find.text('No freeze')),
    findsOneWidget,
    reason: 'the week\'s freeze is spent',
  );
  await shots.take('d_02b_streak_saved');
  // The toast leaves on its own; the line stays for the visit.
  await tester.pumpUntil(
    () => toast.evaluate().isEmpty,
    timeout: const Duration(seconds: 10),
    reason: 'the freeze toast gone',
  );
  await tester.pumpFor(const Duration(milliseconds: 300));
  expect(cardLine, findsOneWidget, reason: 'the card keeps its line');
  await shots.take('d_02c_streak_saved_card');
}

Future<void> _paused(WidgetTester tester, Board board, _Shots shots) async {
  await shots.take('d_10_home_paused');
  // Frames 5.2b and 10.7: the paused card before the solve, the number
  // kept, "Paused", and the freeze chip with none left.
  await _openDaily(tester, shots, 'd_11_paused_card');
  expect(find.text('4 days'), findsOneWidget, reason: 'the count never drops');
  expect(find.text('Paused'), findsOneWidget);
  expect(
    find.descendant(
      of: find.byType(StreakCard),
      matching: find.text('No freeze'),
    ),
    findsOneWidget,
  );
  await _playDailyToWin(tester, board);
  // 10.7b: the win card says the flame is lit again.
  expect(find.text('Streak relit!'), findsOneWidget);
  await shots.take('d_12_streak_relit');
  await tester.tap(find.text('Back to Daily'));
  await tester.pumpUntil(
    () =>
        find.byType(GameplayView).evaluate().isEmpty &&
        find.byType(DailyPage).evaluate().isNotEmpty,
    reason: 'back on the Daily screen',
  );
  await tester.pumpFor(const Duration(milliseconds: 800));
  expect(find.text('5 days'), findsOneWidget);
  expect(find.text('Paused'), findsNothing);
  await shots.take('d_13_lit_again');

  // m7-4 4.10 (`motion.relitHome`): the first Home visit after the relight
  // rings the Daily tile's badge for 2,400 ms, fades it over 400, and never
  // again. Home heard of the relight while the Daily screen covered it;
  // the glow waits for Home to show.
  final relitBadge = find.byWidgetPredicate(
    (w) => w is StreakBadge && w.look == StreakLook.relit,
  );
  await tester.tap(
    find.descendant(
      of: find.byType(DailyPage),
      matching: find.bySemanticsLabel('Back'),
    ),
  );
  await tester.pumpUntil(
    () =>
        find.byType(DailyPage).evaluate().isEmpty &&
        find.byType(HomePage).evaluate().isNotEmpty,
    reason: 'Home after the relight',
  );
  await tester.pumpFor(const Duration(milliseconds: 400));
  expect(relitBadge, findsOneWidget, reason: 'the relit glow on Home (4.10)');
  await shots.take('d_14_home_relit_glow');
  await tester.pumpUntil(
    () => relitBadge.evaluate().isEmpty,
    timeout: const Duration(seconds: 8),
    reason: 'the relit glow over (2,400 + 400 ms)',
  );
  expect(get<DatabaseService>().relitGlowSeen, isNotNull);
  // A second visit: the plain lit badge.
  await tester.tap(find.text('Daily Puzzle'));
  await tester.pumpUntil(
    () => find.byType(DailyPage).evaluate().isNotEmpty,
    reason: 'the Daily screen again',
  );
  await tester.pumpFor(const Duration(milliseconds: 800));
  await tester.tap(
    find.descendant(
      of: find.byType(DailyPage),
      matching: find.bySemanticsLabel('Back'),
    ),
  );
  await tester.pumpUntil(
    () =>
        find.byType(DailyPage).evaluate().isEmpty &&
        find.byType(HomePage).evaluate().isNotEmpty,
    reason: 'Home again',
  );
  await tester.pumpFor(const Duration(milliseconds: 600));
  expect(relitBadge, findsNothing, reason: 'the glow shows once');
  await shots.take('d_15_home_glow_once');
}

Future<void> _welcome(WidgetTester tester, Board board, _Shots shots) async {
  // 14.1b: the card on Home after three days away, the number kept.
  final card = find.byType(WelcomeBackCard);
  await tester.pumpUntil(
    () => card.evaluate().isNotEmpty,
    reason: 'the welcome-back card after three days away',
  );
  await tester.pumpFor(const Duration(milliseconds: 900));
  expect(
    find.descendant(of: card, matching: find.text('Welcome back!')),
    findsOneWidget,
  );
  expect(
    find.descendant(of: card, matching: find.textContaining('is resting')),
    findsOneWidget,
    reason: 'the paused line keeps the number',
  );
  expect(
    get<DatabaseService>().lastOpenDate,
    _fakeToday().toString(),
    reason: 'the open date is written once the gap is read',
  );
  await shots.take('d_30_welcome_card');

  // Its Play goes to today's daily over the Daily screen, so the win's
  // Back to Daily lands there; Home then has no card (today is solved).
  // The whole card is the Play button (14.1): tap its headline.
  await _playDailyToWin(
    tester,
    board,
    startFinder: find.descendant(
      of: card,
      matching: find.text('Welcome back!'),
    ),
  );
  await shots.take('d_31_welcome_daily_win');
  await tester.tap(find.text('Back to Daily'));
  await tester.pumpUntil(
    () =>
        find.byType(GameplayView).evaluate().isEmpty &&
        find.byType(DailyPage).evaluate().isNotEmpty,
    reason: 'the Daily screen under the board',
  );
  await tester.pumpFor(const Duration(milliseconds: 800));
  await tester.tap(
    find.descendant(
      of: find.byType(DailyPage),
      matching: find.bySemanticsLabel('Back'),
    ),
  );
  await tester.pumpUntil(
    () =>
        find.byType(DailyPage).evaluate().isEmpty &&
        find.byType(HomePage).evaluate().isNotEmpty,
    reason: 'Home after the solve',
  );
  await tester.pumpFor(const Duration(milliseconds: 600));
  expect(card, findsNothing, reason: 'the card goes once today is solved');
  await shots.take('d_32_home_after_welcome');
}

Future<void> _locked(WidgetTester tester, _Shots shots) async {
  // Home's Daily tile is inert until then; it says why.
  expect(find.text('After Level 2'), findsOneWidget);
  // Before stage 4 nothing in the app opens the Daily this early: the
  // home-screen widget's link will (DELIVERY item 12). Open it as that link
  // does.
  unawaited(get<AppRouter>().push(const DailyRoute()));
  await tester.pumpUntil(
    () => find.byType(DailyLockedCard).evaluate().isNotEmpty,
    reason: 'the Daily before Level 2 (12.14)',
  );
  await tester.pumpFor(const Duration(milliseconds: 800));
  expect(find.text('Your first daily puzzle is close'), findsOneWidget);
  expect(find.byType(MonthCard), findsNothing, reason: 'no month yet');
  await shots.take('d_38_daily_locked');
  await tester.tap(find.text('Play Level 2'));
  await tester.pumpUntil(
    () => find.byType(GameplayView).evaluate().isNotEmpty,
    timeout: const Duration(seconds: 30),
    reason: "12.14's button plays Level 2",
  );
  await tester.pumpFor(const Duration(milliseconds: 800));
  await shots.take('d_39_locked_play_level2');
}

Future<void> _month(WidgetTester tester, _Shots shots) async {
  await _openDaily(tester, shots, 'd_35_daily_month_top');
  final month = find.byType(MonthCard);
  await tester.ensureVisible(month);
  await tester.pumpFor(const Duration(milliseconds: 600));
  await shots.take('d_36_month');
  final handle = tester.ensureSemantics();
  String label(int d, String state) =>
      '${DateFormat.MMMMd('en').format(DateTime(2026, 10, d))}, $state';
  for (final (d, state) in [
    (3, 'solved'),
    (30, 'solved'),
    (13, 'covered by a freeze'),
    (1, 'not played'),
    (14, 'not played'),
    (31, 'today'),
  ]) {
    expect(
      find.descendant(
        of: month,
        matching: find.bySemanticsLabel(label(d, state)),
      ),
      findsOneWidget,
      reason: 'October $d: $state',
    );
  }
  handle.dispose();
  expect(
    find.descendant(of: month, matching: find.textContaining('issed')),
    findsNothing,
  );
  await _scrollToEnd(tester, DailyPage);
  await shots.take('d_37_daily_month_bottom');
}

/// The solver's hint, applied [count] times on an open board (no intro card
/// is expected: the seed's board may open one, which is dismissed first).
Future<void> _hintMoves(WidgetTester tester, Board board, int count) async {
  await board.waitIdle();
  await tester.pumpFor(const Duration(milliseconds: 1200));
  for (var i = 0; i < count; i++) {
    for (
      var shown = board.state.intro;
      shown != null;
      shown = board.state.intro
    ) {
      await tester.pumpFor(const Duration(milliseconds: 400));
      await tester.tap(find.text('Got it'));
      await tester.pumpUntil(
        () => board.state.intro != shown,
        reason: 'the ${shown.name} intro card dismissed',
      );
    }
    await board.waitIdle();
    final hintButton = find.text('Hint');
    await tester.pumpUntil(
      () => hintButton.hitTestable().evaluate().isNotEmpty,
      reason: 'Hint uncovered',
    );
    await tester.tap(hintButton);
    await tester.pumpUntil(
      () => board.state.hint != null,
      timeout: const Duration(seconds: 15),
      reason: 'a hint',
    );
    final hint = board.state.hint!;
    await board.move(hint.from, hint.to);
  }
  await board.waitIdle();
}

Future<void> _archive(WidgetTester tester, Board board, _Shots shots) async {
  final today = _fakeToday();
  final handle = tester.ensureSemantics();
  String label(LocalDate d, String state) =>
      '${DateFormat.MMMMd('en').format(d.startOfDay)}, $state';
  Finder open(LocalDate d, String state) =>
      find.bySemanticsLabel('${label(d, state)}, open to play');

  // Today's board, two moves in, left through Pause > Home.
  await tester.tap(find.text('Daily Puzzle'));
  await tester.pumpUntil(
    () => find.byType(DailyPage).evaluate().isNotEmpty,
    reason: 'the Daily screen',
  );
  await tester.pumpFor(const Duration(seconds: 1));
  final before = get<DailyService>().refresh();
  expect(before.lit, isFalse, reason: 'the seeded streak is paused');
  await tester.tap(find.text('Play'));
  await tester.pumpUntil(
    () =>
        find.byType(GameplayView).evaluate().isNotEmpty &&
        board.game.geometry != null &&
        board.game.skin != null,
    timeout: const Duration(seconds: 30),
    reason: "today's daily with its skin",
  );
  await _hintMoves(tester, board, 2);
  final movesBefore = board.state.board.moveCount;
  expect(movesBefore, greaterThanOrEqualTo(2));
  await tester.tap(find.bySemanticsLabel('Pause'));
  await tester.pumpUntil(
    () => find.text('Paused').evaluate().isNotEmpty,
    reason: 'the pause dialog',
  );
  await tester.tap(find.text('Home'));
  await tester.pumpUntil(
    () => find.byType(GameplayView).evaluate().isEmpty,
    reason: 'off the board',
  );
  await tester.pumpFor(const Duration(milliseconds: 800));
  if (find.byType(DailyPage).evaluate().isEmpty) {
    await tester.tap(find.text('Daily Puzzle'));
    await tester.pumpUntil(
      () => find.byType(DailyPage).evaluate().isNotEmpty,
      reason: 'the Daily screen again',
    );
    await tester.pumpFor(const Duration(seconds: 1));
  }

  // 14.3a: the window across the 1st, the ‹ chip, older days inert.
  final month = find.byType(MonthCard);
  await tester.ensureVisible(month);
  await tester.pumpFor(const Duration(milliseconds: 600));
  await shots.take('d_40_month_window');
  expect(find.bySemanticsLabel('Show October'), findsOneWidget);
  final target = today.addDays(-2);
  expect(open(target, 'not played'), findsOneWidget);
  expect(
    find.bySemanticsLabel(RegExp('open to play')),
    findsNWidgets(7),
    reason: 'seven days are open: the window, not the older days or today',
  );

  // 14.3b: a tap opens the card; no coin chip.
  await tester.tap(open(target, 'not played'));
  await tester.pumpUntil(
    () => find.byType(PastDayCard).evaluate().isNotEmpty,
    reason: "the past day's card",
  );
  await tester.pumpFor(const Duration(milliseconds: 1200));
  await shots.take('d_41_past_card');
  expect(
    find.descendant(
      of: find.byType(PastDayCard),
      matching: find.byType(CoinIcon),
    ),
    findsNothing,
  );
  expect(find.text('Just for fun. Your streak stays as it is.'), findsOne);

  // 14.3c: the board wears the date pill and no coin pill.
  await _playDailyToWin(
    tester,
    board,
    startFinder: find.byKey(PastDayCard.playKey),
    afterStart: () async {
      expect(find.byType(CoinPill), findsNothing);
      expect(
        find.text(DateFormat.MMMd('en').format(target.startOfDay)),
        findsOneWidget,
        reason: 'the date pill',
      );
      await shots.take('d_42_past_board');
    },
  );

  // 14.3d: the date card, no streak, no coins, no Share.
  expect(find.byType(PastDayWinCard), findsOneWidget);
  expect(find.text('Share'), findsNothing);
  expect(find.byType(DailyStreakCard), findsNothing);
  await shots.take('d_43_past_win');
  await tester.tap(find.text('Back to Daily'));
  await tester.pumpUntil(
    () =>
        find.byType(GameplayView).evaluate().isEmpty &&
        find.byType(DailyPage).evaluate().isNotEmpty,
    reason: 'the Daily screen under the board',
  );
  await tester.pumpFor(const Duration(milliseconds: 900));

  // 14.3e: the month shows the played-later mark; the streak is unchanged.
  await tester.ensureVisible(month);
  await tester.pumpFor(const Duration(milliseconds: 600));
  expect(open(target, 'played later'), findsOneWidget);
  await shots.take('d_44_month_after');
  final after = get<DailyService>().refresh();
  expect(after.streak, before.streak);
  expect(after.lit, before.lit);
  expect(after.done, before.done);
  expect(after.solvedToday, isFalse);
  expect(get<SaveService>().coins, 880, reason: 'a past day pays nothing');

  // Today's board is where it was left.
  await tester.tap(find.text('Play').first);
  await tester.pumpUntil(
    () =>
        find.byType(GameplayView).evaluate().isNotEmpty &&
        board.game.geometry != null &&
        board.game.skin != null,
    timeout: const Duration(seconds: 30),
    reason: "today's daily again",
  );
  await board.waitIdle();
  await tester.pumpFor(const Duration(milliseconds: 1200));
  expect(board.state.board.moveCount, movesBefore);
  await shots.take('d_45_today_resumes');
  handle.dispose();
}

Future<void> _settings(WidgetTester tester, Board board, _Shots shots) async {
  final database = get<DatabaseService>();
  await tester.tap(find.bySemanticsLabel('Settings'));
  await tester.pumpUntil(
    () => find.byType(SettingsPage).evaluate().isNotEmpty,
    reason: 'Settings',
  );
  await tester.pumpFor(const Duration(milliseconds: 800));
  await shots.take('d_20_settings');

  Finder toggle(String label) => find.byWidgetPredicate(
    (w) => w is NestyToggle && w.semanticLabel == label,
  );

  // Sound and Haptics: their states are written (haptics can't be felt).
  await tester.tap(toggle('Sound'));
  await tester.pumpFor(const Duration(milliseconds: 400));
  expect(database.soundEnabled, isFalse);
  await tester.tap(toggle('Haptics'));
  await tester.pumpFor(const Duration(milliseconds: 400));
  expect(database.hapticsEnabled, isFalse);
  await shots.take('d_21_sound_haptics_off');
  await tester.tap(toggle('Sound'));
  await tester.tap(toggle('Haptics'));
  await tester.pumpFor(const Duration(milliseconds: 400));

  // The daily is unlocked, so the reminder row is there: off, no Time row.
  expect(find.text('Daily reminder'), findsOneWidget);
  expect(find.text('Time'), findsNothing);

  await tester.ensureVisible(find.text('Reduce motion'));
  // Frame 10.2e (m7-4 4.16): the three-way control is 48 tall.
  final track = find
      .descendant(
        of: find.byType(SettingsSegmentedRow<ReduceMotionMode>),
        matching: find.byType(NestySurface),
      )
      .first;
  expect(tester.getSize(track).height, 48);
  await tester.tap(find.text('On'));
  await tester.pumpFor(const Duration(milliseconds: 400));
  expect(database.reduceMotion, ReduceMotionMode.on);
  await shots.take('d_22_reduce_motion_on');
  await tester.tap(find.text('System'));
  await tester.pumpFor(const Duration(milliseconds: 400));
  expect(database.reduceMotion, ReduceMotionMode.system);

  await tester.ensureVisible(toggle('Relaxed mode'));
  await tester.tap(toggle('Relaxed mode'));
  await tester.pumpFor(const Duration(milliseconds: 400));
  expect(database.relaxedMode, isTrue);
  await shots.take('d_23_relaxed_on');

  await tester.ensureVisible(find.text('Subtle'));
  await tester.tap(find.text('Subtle'));
  await tester.pumpFor(const Duration(milliseconds: 400));
  expect(database.symbolsMode, SymbolsMode.subtle);
  await tester.tap(find.text('Large'));
  await tester.pumpFor(const Duration(milliseconds: 400));
  expect(database.symbolsMode, SymbolsMode.large);
  await shots.take('d_24_symbols_large');
  // F-SAFE (lane RD): Settings scrolled to the end, the last row clear of
  // the home indicator, the gradient to the bottom edge.
  await _scrollToEnd(tester, SettingsPage);
  await shots.take('d_26_settings_bottom');

  await tester.tap(find.bySemanticsLabel('Close'));
  await tester.pumpUntil(
    () => find.byType(HomePage).evaluate().isNotEmpty,
    reason: 'Home after Settings',
  );
  // Past Settings' closing transition: a PLAY tapped while Home still
  // slides in misses (the device run, 2026-09-30).
  await tester.pumpFor(const Duration(milliseconds: 800));

  // A board: Undo wears the unlimited glyph and undoes past the two free
  // ones (level 3's own opening moves, as the resume scenario plays them).
  // The dev flavor's boosters never run out, which hides every badge, the
  // relaxed "∞" too (`BoosterBarModel.of`): debug-only, turn that off
  // before the level opens, as the playthrough does (README "Testing").
  final save = get<SaveService>();
  (save as InMemorySaveService).debugUnlimitedBoosters = false;
  final coins = save.coins;
  await tester.tap(find.bySemanticsLabel('Play level 3'));
  // Frame 10.9: "Relaxed mode is on…", once per launch, on the first level
  // entered with the mode on; shot as it shows, well within its 2.5 s
  // (architecture.md §1.3).
  const relaxedToast = 'Relaxed mode is on. Undo as often as you like.';
  await tester.pumpUntil(
    () => find.text(relaxedToast).evaluate().isNotEmpty,
    reason: 'the Relaxed mode toast (10.9)',
    step: const Duration(milliseconds: 16),
  );
  await tester.pumpFor(const Duration(milliseconds: 400));
  await shots.take('d_24b_relaxed_toast');
  await board.waitForLevel(3);
  expect(board.state.relaxed, isTrue);
  expect(find.byIcon(NestyIcons.allInclusive), findsOneWidget);
  // Frame 8.4: the board with Large symbols, once the toast (2.5 s) is gone.
  expect(database.symbolsMode, SymbolsMode.large);
  await tester.pumpUntil(
    () => find.text(relaxedToast).evaluate().isEmpty,
    reason: 'the Relaxed toast gone',
  );
  await tester.pumpFor(const Duration(milliseconds: 600));
  await shots.take('d_24c_symbols_large_board');
  await board.move('r1c2', 'r2c1');
  for (var undo = 1; undo <= 3; undo++) {
    await board.waitIdle();
    await tester.tap(find.text('Undo'));
    await tester.pumpFor(const Duration(milliseconds: 600));
    await board.waitIdle();
    if (undo < 3) await board.move('r1c2', 'r2c1');
  }
  expect(
    find.byType(OutOfMovesSheet),
    findsNothing,
    reason: 'a third undo costs nothing in Relaxed mode',
  );
  expect(save.coins, coins, reason: 'a third undo costs nothing (Relaxed)');
  expect(board.state.board.moveCount, 0, reason: 'every undo applied');
  await shots.take('d_25_relaxed_undo_board');
  save.debugUnlimitedBoosters = null;
}

final class _Shots {
  _Shots(this._binding, this._tester);

  final IntegrationTestWidgetsFlutterBinding _binding;
  final WidgetTester _tester;
  bool _converted = false;

  Future<void> take(String name) async {
    if (Platform.isAndroid && !_converted) {
      await _binding.convertFlutterSurfaceToImage();
      _converted = true;
    }
    await _tester.pump();
    final bytes = await _binding.takeScreenshot(name);
    expect(bytes, isNotEmpty, reason: name);
  }
}
