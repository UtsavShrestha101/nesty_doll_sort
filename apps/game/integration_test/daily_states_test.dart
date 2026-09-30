import 'dart:convert';
import 'dart:io' show Platform;

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:nesty_game/core/dependency_injection/di.dart';
import 'package:nesty_game/core/models/reduce_motion_mode.dart';
import 'package:nesty_game/core/models/symbols_mode.dart';
import 'package:nesty_game/core/services/clock/local_date.dart';
import 'package:nesty_game/core/services/clock/system_clock.dart';
import 'package:nesty_game/core/services/database/database_service.dart';
import 'package:nesty_game/core/services/save/in_memory_save_service.dart';
import 'package:nesty_game/core/services/save/save_document.dart';
import 'package:nesty_game/core/services/save/save_service.dart';
import 'package:nesty_game/core/ui/nesty_ui.dart';
import 'package:nesty_game/features/daily/pages/daily_page.dart';
import 'package:nesty_game/features/gameplay/bloc/gameplay_bloc.dart';
import 'package:nesty_game/features/gameplay/pages/gameplay_view.dart';
import 'package:nesty_game/features/home/pages/home_page.dart';
import 'package:nesty_game/features/settings/pages/settings_page.dart';
import 'package:nesty_game/main_dev.dart' as app;

import 'support/board_probe.dart';
import 'support/seeded_save.dart';

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
/// - `settings`: Relaxed mode, Reduce motion, Sound, Haptics and Color
///   symbols in Settings (10.2e), then a board where Undo shows the
///   unlimited glyph and undoes past the free ones.
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
      final today = _fakeToday();
      await switch (_scenario) {
        'paused' => _seedPaused(today),
        'settings' => _seedSettings(),
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
        case 'settings':
          await _settings(tester, board, shots);
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
/// no freeze covered the gap.
Future<void> _seedPaused(LocalDate today) => seedSave(
  _base(
    DailyProgress(
      streak: 4,
      done: [for (var back = 6; back >= 3; back--) today.addDays(-back)],
    ),
  ),
);

Future<void> _seedSettings() => seedSave(_base(const DailyProgress()));

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
}) async {
  await tester.tap(find.text('Play'));
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
  await tester.pumpFor(const Duration(milliseconds: 1200));
  expect(find.text('+300 coins'), findsOneWidget, reason: 'contents first');
  expect(find.text('Open'), findsOneWidget);
  expect(find.text('Collect'), findsNothing);
  await shots.take('d_03_day7_chest_closed');

  await tester.tap(find.text('Open'));
  await tester.pumpUntil(
    () => find.text('Collect').evaluate().isNotEmpty,
    reason: 'the open chest with Collect (5.6b)',
  );
  await tester.pumpFor(const Duration(milliseconds: 1000));
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
  await tester.tap(find.text('No thanks'));
  await tester.pumpUntil(
    () => find.text(offerTitle).evaluate().isEmpty,
    reason: 'No thanks closes the offer',
  );
  final reminder = get<DatabaseService>().reminder;
  expect(reminder.offered && !reminder.on, isTrue, reason: '$reminder');
  await tester.pumpFor(const Duration(milliseconds: 500));
  await shots.take('d_06_daily_after_day7');
}

Future<void> _paused(WidgetTester tester, Board board, _Shots shots) async {
  await shots.take('d_10_home_paused');
  await _openDaily(tester, shots, 'd_11_paused_card');
  expect(find.text('4 days'), findsOneWidget, reason: 'the count never drops');
  expect(find.text('Paused'), findsOneWidget);
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
  await board.waitForLevel(3);
  expect(board.state.relaxed, isTrue);
  expect(find.byIcon(NestyIcons.allInclusive), findsOneWidget);
  await board.move('r1c2', 'r2c1');
  for (var undo = 1; undo <= 3; undo++) {
    await board.waitIdle();
    await tester.tap(find.text('Undo'));
    await tester.pumpFor(const Duration(milliseconds: 600));
    await board.waitIdle();
    if (undo < 3) await board.move('r1c2', 'r2c1');
  }
  expect(
    find.text('Out of moves'),
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
