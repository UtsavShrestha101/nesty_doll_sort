import 'dart:async' show unawaited;
import 'dart:convert';
import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:nesty_game/bootstrap.dart';
import 'package:nesty_game/core/dependency_injection/di.dart';
import 'package:nesty_game/core/flavor/flavor.dart';
import 'package:nesty_game/core/flavor/flavor_config.dart';
import 'package:nesty_game/core/flavor/flavor_values.dart';
import 'package:nesty_game/core/models/play_request.dart';
import 'package:nesty_game/core/router/app_router.dart';
import 'package:nesty_game/core/services/database/database_service.dart';
import 'package:nesty_game/core/services/save/save_document.dart';
import 'package:nesty_game/core/ui/nesty_ui.dart';
import 'package:nesty_game/core/ui/widgets/home/text_link.dart';
import 'package:nesty_game/features/daily/pages/daily_page.dart';
import 'package:nesty_game/features/gameplay/bloc/gameplay_bloc.dart';
import 'package:nesty_game/features/gameplay/pages/gameplay_view.dart';
import 'package:nesty_game/features/gameplay/widgets/generating_overlay.dart';
import 'package:nesty_game/features/home/pages/home_page.dart';
import 'package:nesty_game/features/home/showcase/showcase_dolls.dart';
import 'package:nesty_game/features/race/pages/rival_select_page.dart';
import 'package:nesty_game/features/settings/pages/settings_page.dart';
import 'package:nesty_game/features/splash/pages/splash_page.dart';

import 'support/board_probe.dart';
import 'support/fault_services.dart';
import 'support/hint_solver.dart';
import 'support/phone_language.dart';
import 'support/seeded_save.dart';
import 'support/time_picker_probe.dart';

/// The failure states on a device (phase 5, architecture.md §1.3; D169):
/// one fault per run, chosen by `--dart-define=NESTY_FAULT_SCENARIO=<name>`
/// and installed by `support/fault_services.dart` through the test-only
/// seam `bootstrap(beforeRunApp:)`. Nothing in `lib/` knows about faults.
///
/// - `race_failed` (9.3f): rival select's Start, the race board fails to
///   generate: "This race didn't set up", then Back to races.
/// - `reminder_granted` (10.2c): the daily solved, the offer's Yes, the
///   phone allows notifications: the "Reminder set for …" toast. Then
///   Settings (m7-4): the reminder on with its Time row (10.2e), a new time
///   confirmed by the app-wide toast 4 dp under the safe top (m7-4 1.5),
///   the switch off with the Time row gone (10.2h), and on again with the
///   last time back.
/// - `reminder_denied` (10.2d, 10.2f): the same Yes, the phone refuses: the
///   offer's "Notifications are off" step, then Settings' reminder row
///   "Off in your phone's settings"; its Turn off link (m7-4 4.16, Q158)
///   switches the reminder off in the game: the Off row (10.2h).
/// - `generating` (12.5): bonus level 10 is held in generation: the
///   generating card, then the board once the test lets it go.
/// - `bonus_failed` (12.6): bonus level 10 fails to generate: "The shelves
///   need a moment", then Back to Home.
/// - `splash_loaded` (10.8): the splash held after the showcase art is in:
///   the `00b_splash_loaded` shot, then level 1 opens.
/// - `storage` (12.10) and `content` (12.11): the splash's first load fails
///   as a full disk or on the bundled content; Try again opens level 1.
///
/// The phone's own permission dialog and its settings page are never
/// opened: the reminder scenarios answer through a fake notification
/// service (`reminder_test.dart` checks the real one on Android).
///
/// ```sh
/// cd apps/game
/// flutter drive --flavor dev --driver test_driver/integration_test.dart \
///   --target integration_test/faults_test.dart \
///   --dart-define=NESTY_FAULT_SCENARIO=storage -d <device>
/// ```
///
/// `nesty-test` runs each scenario from a fresh install (`--only faults`).
/// Screenshots are prefixed `f_`.
const _define = String.fromEnvironment(
  'NESTY_FAULT_SCENARIO',
  defaultValue: 'storage',
);

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  binding.framePolicy = LiveTestWidgetsFlutterBindingFramePolicy.fullyLive;
  final scenario = FaultScenario.parse(_define);

  testWidgets(
    'a failure state on a device: ${scenario.define}',
    (tester) async {
      pinEnglishPhone(tester);
      final seed = _seedFor(scenario);
      if (seed != null) await seedSave(seed);

      // `main_dev.dart`'s own start, with the fault installed between DI
      // and runApp.
      final faults = FaultServices(scenario);
      FlavorConfig(
        flavor: Flavor.dev,
        values: const FlavorValues(appTitle: '[DEV] Nesty'),
      );
      bootstrap(beforeRunApp: faults.install);
      final board = Board(tester);
      final shots = _Shots(binding, tester);

      switch (scenario) {
        case FaultScenario.storage:
          await _splashFailure(
            tester,
            board,
            shots,
            title: 'Your phone is nearly full',
            shot: 'f_splash_storage',
          );
        case FaultScenario.content:
          await _splashFailure(
            tester,
            board,
            shots,
            title: 'The shelves didn’t unpack',
            shot: 'f_splash_content',
          );
        case FaultScenario.splashLoaded:
          await _splashLoaded(tester, board, shots, faults);
        case FaultScenario.generating:
          await _home(tester);
          await _generating(tester, board, shots, faults);
        case FaultScenario.bonusFailed:
          await _home(tester);
          await _bonusFailed(tester, shots);
        case FaultScenario.raceFailed:
          await _home(tester);
          await _raceFailed(tester, shots);
        case FaultScenario.reminderGranted:
          await _home(tester);
          await _reminderOffer(tester, board);
          await tester.pumpUntil(
            () => find.textContaining('Reminder set for').evaluate().isNotEmpty,
            reason: 'the "Reminder set" toast (10.2c)',
          );
          await tester.pumpFor(const Duration(milliseconds: 300));
          await shots.take('f_reminder_set');
          expect(get<DatabaseService>().reminder.on, isTrue);
          expect(faults.notifications!.scheduled, isNotNull);
          await _settingsFromDaily(tester);
          await _reminderSettings(tester, shots);
        case FaultScenario.reminderDenied:
          await _home(tester);
          await _reminderOffer(tester, board);
          await _reminderDenied(tester, shots, faults);
      }

      // Merged, never replaced: `takeScreenshot` keeps the shots in
      // `reportData['screenshots']`.
      binding.reportData = {
        ...?binding.reportData,
        'faults': {
          'scenario': scenario.define,
          'platform': Platform.operatingSystem,
        },
      };
      // ignore: avoid_print
      print('NESTY_FAULTS ${jsonEncode({'scenario': scenario.define})}');
    },
    timeout: const Timeout(Duration(minutes: 8)),
  );
}

/// The save each scenario starts from (null: a fresh install).
SaveDocument? _seedFor(FaultScenario scenario) => switch (scenario) {
  // A fresh install: the held splash hands over to level 1 (E9).
  FaultScenario.storage ||
  FaultScenario.content ||
  FaultScenario.splashLoaded => null,
  // Past Level 20: vs Computer is open, rival 1 selectable.
  FaultScenario.raceFailed => const SaveDocument(
    currentLevel: 21,
    highestLevel: 21,
    tutorialDone: true,
  ),
  // Level 3 next: the daily is unlocked and unsolved today; Home opens.
  _ => const SaveDocument(
    currentLevel: 3,
    highestLevel: 3,
    coins: 880,
    tutorialDone: true,
  ),
};

/// Home after the splash, settled.
Future<void> _home(WidgetTester tester) async {
  await tester.pumpUntil(
    () =>
        find.byType(SplashPage).evaluate().isEmpty &&
        find.byType(HomePage).evaluate().isNotEmpty,
    timeout: const Duration(seconds: 60),
    reason: 'Home for the seeded save (uninstall the app first)',
  );
  await tester.pumpFor(const Duration(milliseconds: 800));
}

/// Frames 12.10 and 12.11: the splash's error card, then Try again loads
/// for real and opens level 1 (a fresh install, E9).
Future<void> _splashFailure(
  WidgetTester tester,
  Board board,
  _Shots shots, {
  required String title,
  required String shot,
}) async {
  await tester.pumpUntil(
    () => find.text(title).evaluate().isNotEmpty,
    timeout: const Duration(seconds: 60),
    reason: 'the splash error card "$title"',
  );
  // The optional art load (skin, showcase dolls) runs beside the failed
  // content load and lands later on a slower phone: wait for it so the
  // wordmark's perched doll is the art, as on iOS (audit f12-10/f12-11).
  await tester.pumpUntil(
    () => get<ShowcaseDolls>().current.value != null,
    timeout: const Duration(seconds: 60),
    reason: 'the showcase art behind the error card',
  );
  await tester.pumpFor(const Duration(milliseconds: 600));
  expect(find.byType(SplashPage), findsOneWidget);
  expect(find.text('Try again'), findsOneWidget);
  await shots.take(shot);
  await tester.tap(find.text('Try again'));
  await tester.pumpUntil(
    () => find.byType(GameplayView).evaluate().isNotEmpty,
    timeout: const Duration(seconds: 60),
    reason: 'level 1 after Try again',
  );
  await board.waitForLevel(1);
  expect(find.byType(HomePage), findsNothing, reason: 'E9: no Home first');
}

/// Frame 10.8 (`00b_splash_loaded`): the splash once the showcase dolls'
/// art is in and has crossfaded over the fallback dolls. The level load is
/// held (`splash_loaded`), so the shot waits for `ShowcaseDolls.current` and
/// the 360 ms crossfade without racing the handover to level 1; then the
/// load is let go and level 1 opens (a fresh install, E9).
Future<void> _splashLoaded(
  WidgetTester tester,
  Board board,
  _Shots shots,
  FaultServices faults,
) async {
  await tester.pumpUntil(
    () => find.byType(SplashPage).evaluate().isNotEmpty,
    reason: 'the splash',
  );
  await tester.pumpUntil(
    () => get<ShowcaseDolls>().current.value != null,
    timeout: const Duration(seconds: 60),
    reason: 'the showcase art on the splash',
  );
  // The shelf dolls crossfade from the placeholders in 360 ms.
  await tester.pumpFor(const Duration(milliseconds: 360));
  expect(find.byType(SplashPage), findsOneWidget, reason: 'the splash is held');
  await shots.take('00b_splash_loaded');
  faults.release();
  final released = Stopwatch()..start();
  try {
    await tester.pumpUntil(
      () => find.byType(GameplayView).evaluate().isNotEmpty,
      timeout: const Duration(seconds: 60),
      reason: 'level 1 after the held splash',
    );
  } on TestFailure {
    // Say where it stopped (the 2026-10-05 gate timed out here once).
    fail(
      'level 1 after the held splash, ${released.elapsed.inSeconds} s after '
      'the release: ${_splashState()}',
    );
  }
  await board.waitForLevel(1);
  expect(find.byType(HomePage), findsNothing, reason: 'E9: no Home first');
}

/// What the screen shows when level 1 doesn't come: the splash's progress
/// and error, or the routes.
String _splashState() {
  final views = find.byType(SplashView).evaluate();
  final routes = get<AppRouter>().stack.map((page) => page.name).join(' > ');
  if (views.isEmpty) return 'no splash; routes: $routes';
  final view = views.first.widget as SplashView;
  return 'the splash is up at ${view.progress}, error ${view.error?.kind}; '
      'routes: $routes';
}

/// Frame 12.5: bonus level 10 opens behind the generating card, held until
/// the shot, then its board.
Future<void> _generating(
  WidgetTester tester,
  Board board,
  _Shots shots,
  FaultServices faults,
) async {
  unawaited(
    get<AppRouter>().push(GameplayRoute(request: const PlayRequest.bonus(10))),
  );
  await tester.pumpUntil(
    () => find.byType(GeneratingOverlay).evaluate().isNotEmpty,
    reason: 'the generating card (12.5)',
    step: const Duration(milliseconds: 16),
  );
  await tester.pumpFor(const Duration(milliseconds: 800));
  expect(find.text('Setting up the shelves…'), findsOneWidget);
  await shots.take('f_generating');
  faults.release();
  await tester.pumpUntil(
    () =>
        find.byType(GeneratingOverlay).evaluate().isEmpty &&
        board.bloc.state.data?.status == GameplayStatus.playing &&
        board.game.skin != null,
    timeout: const Duration(seconds: 60),
    reason: 'bonus level 10 after the hold',
  );
  await board.waitIdle();
}

/// Frame 12.6: bonus level 10 couldn't be made; Back to Home.
Future<void> _bonusFailed(WidgetTester tester, _Shots shots) async {
  unawaited(
    get<AppRouter>().push(GameplayRoute(request: const PlayRequest.bonus(10))),
  );
  final body = bindLastWord(
    'This level didn’t set up. Try again, or head back home.',
  );
  await tester.pumpUntil(
    () => find.text(body).evaluate().isNotEmpty,
    timeout: const Duration(seconds: 30),
    reason: 'the failure card (12.6)',
  );
  await tester.pumpFor(const Duration(milliseconds: 600));
  expect(find.text('The shelves need a moment'), findsOneWidget);
  expect(find.text('Try again'), findsOneWidget);
  await shots.take('f_bonus_failed');
  await tester.tap(find.text('Back to Home'));
  await tester.pumpUntil(
    () =>
        find.byType(GameplayView).evaluate().isEmpty &&
        find.byType(HomePage).evaluate().isNotEmpty,
    reason: 'Back to Home',
  );
}

/// Frame 9.3f: the race board couldn't be made; Back to races.
Future<void> _raceFailed(WidgetTester tester, _Shots shots) async {
  final tile = find.descendant(
    of: find.byType(HomePage),
    matching: find.text('vs Computer'),
  );
  await tester.tap(tile);
  await tester.pumpUntil(
    () => find.byType(RivalSelectView).evaluate().isNotEmpty,
    reason: 'rival select',
  );
  await tester.pumpFor(const Duration(milliseconds: 600));
  await tester.tap(find.text('Start'));
  final body = bindLastWord(
    'This race didn’t set up. Try again, or pick another race.',
  );
  await tester.pumpUntil(
    () => find.text(body).evaluate().isNotEmpty,
    timeout: const Duration(seconds: 30),
    reason: 'the race failure card (9.3f)',
  );
  await tester.pumpFor(const Duration(milliseconds: 600));
  expect(find.text('The shelves need a moment'), findsOneWidget);
  await shots.take('f_race_failed');
  await tester.tap(find.text('Back to races'));
  await tester.pumpUntil(
    () =>
        find.byType(GameplayView).evaluate().isEmpty &&
        find.byType(RivalSelectView).evaluate().isNotEmpty,
    reason: 'Back to races',
  );
}

/// Today's daily solved from Home, back on the Daily screen, and the
/// one-time offer's Yes (frame 10.2). The fake notification service
/// answers the permission.
Future<void> _reminderOffer(WidgetTester tester, Board board) async {
  await tester.tap(find.text('Daily Puzzle'));
  await tester.pumpUntil(
    () => find.byType(DailyPage).evaluate().isNotEmpty,
    reason: 'the Daily screen',
  );
  await tester.pumpFor(const Duration(seconds: 1));
  await tester.tap(find.text('Play'));
  await tester.pumpUntil(
    () =>
        find.byType(GameplayView).evaluate().isNotEmpty &&
        board.game.geometry != null &&
        board.game.skin != null,
    timeout: const Duration(seconds: 30),
    reason: "today's daily with its skin",
  );
  await solveWithHints(tester, board);
  await board.waitForWinOverlay();
  await tester.pumpFor(const Duration(milliseconds: 1500));
  await tester.tap(find.text('Back to Daily'));
  const offerTitle = 'Want a note when tomorrow’s puzzle is ready?';
  await tester.pumpUntil(
    () => find.text(offerTitle).evaluate().isNotEmpty,
    reason: 'the reminder offer (10.2)',
  );
  await tester.pumpFor(const Duration(milliseconds: 600));
  await tester.ensureVisible(find.text('Yes, remind me'));
  await tester.pumpFor(const Duration(milliseconds: 300));
  await tester.tap(find.text('Yes, remind me'));
}

/// Frames 10.2d and 10.2f: the denied step, Not now, then Settings' row.
Future<void> _reminderDenied(
  WidgetTester tester,
  _Shots shots,
  FaultServices faults,
) async {
  await tester.pumpUntil(
    () => find.text('Notifications are off for Nesty').evaluate().isNotEmpty,
    reason: 'the denied step (10.2d)',
  );
  await tester.pumpFor(const Duration(milliseconds: 600));
  expect(find.text('Open phone settings'), findsOneWidget);
  expect(faults.notifications!.requestCount, 1, reason: 'asked once');
  await shots.take('f_notifications_off');
  await tester.tap(find.text('Not now'));
  await tester.pumpUntil(
    () => find.text('Notifications are off for Nesty').evaluate().isEmpty,
    reason: 'Not now closes the offer',
  );
  await tester.pumpFor(const Duration(milliseconds: 400));
  await _settingsFromDaily(tester);
  const blocked = 'Off in your phone’s settings';
  await tester.pumpUntil(
    () => find.text(blocked).evaluate().isNotEmpty,
    reason: 'the blocked reminder row (10.2f)',
  );
  await tester.ensureVisible(find.text(blocked));
  await tester.pumpFor(const Duration(milliseconds: 400));
  // m7-4 4.16 (Q158, "Build it"): Turn off sits beside Open phone
  // settings, in a 48 dp box.
  final turnOff = find.ancestor(
    of: find.text('Turn off'),
    matching: find.byType(TextLink),
  );
  expect(turnOff, findsOneWidget);
  expect(tester.getSize(turnOff).height, greaterThanOrEqualTo(48));
  await shots.take('f_settings_blocked');

  // Turn off stops the reminder in the game, never opening the phone's
  // settings: the Off row (10.2h), no Time row, no blocked line.
  await tester.tap(find.text('Turn off'));
  await tester.pumpUntil(
    () => find.text(blocked).evaluate().isEmpty,
    reason: 'Turn off clears the blocked row',
  );
  await tester.pumpFor(const Duration(milliseconds: 400));
  expect(get<DatabaseService>().reminder.on, isFalse);
  expect(find.byType(SettingsPage), findsOneWidget, reason: 'still here');
  expect(find.text('Time'), findsNothing);
  expect(tester.widget<NestyToggle>(_reminderToggle).value, isFalse);
  await shots.take('f_settings_turned_off');
}

/// Settings' Daily reminder switch.
final _reminderToggle = find.byWidgetPredicate(
  (w) => w is NestyToggle && w.semanticLabel == 'Daily reminder',
);

/// From the Daily screen: Back to Home, then Settings from the gear.
Future<void> _settingsFromDaily(WidgetTester tester) async {
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
    reason: 'back Home',
  );
  await tester.pumpFor(const Duration(milliseconds: 400));
  await tester.tap(find.bySemanticsLabel('Settings'));
  await tester.pumpUntil(
    () => find.byType(SettingsPage).evaluate().isNotEmpty,
    reason: 'Settings',
  );
  await tester.pumpFor(const Duration(milliseconds: 800));
}

/// Frames 10.2e and 10.2h with the reminder on (`reminder_granted`), and
/// the app-wide toast (m7-4 1.5).
Future<void> _reminderSettings(WidgetTester tester, _Shots shots) async {
  final database = get<DatabaseService>();
  final time = find.text('Time');
  await tester.ensureVisible(_reminderToggle);
  await tester.pumpFor(const Duration(milliseconds: 300));
  expect(tester.widget<NestyToggle>(_reminderToggle).value, isTrue);
  expect(time, findsOneWidget, reason: 'the Time row while it is on');
  await shots.take('f_settings_reminder_on');

  // A time picked in Settings is confirmed by the app's own toast, 4 dp
  // under the safe top (toast.app; frames' y 58 under a 54 status bar).
  await tester.tap(time);
  await tester.waitForTimePicker('the time picker from the Time row');
  await tester.confirmTimePicker();
  final toast = find.byType(ToastCard);
  await tester.pumpUntil(
    () => toast.evaluate().isNotEmpty,
    reason: 'the "Reminder set" toast from Settings',
  );
  await tester.pumpFor(const Duration(milliseconds: 600));
  expect(find.textContaining('Reminder set for'), findsOneWidget);
  expect(tester.widget<ToastCard>(toast).placement, ToastPlacement.app);
  final safeTop = MediaQueryData.fromView(tester.view).padding.top;
  expect(tester.getTopLeft(toast).dy, closeTo(safeTop + 4, 1));
  await shots.take('f_settings_time_toast');
  await tester.pumpUntil(
    () => toast.evaluate().isEmpty,
    timeout: const Duration(seconds: 10),
    reason: 'the toast gone',
  );

  // The switch off: the Off row, the Time row hidden (10.2h).
  final hour = database.reminder.hour;
  final minute = database.reminder.minute;
  await tester.tap(_reminderToggle);
  await tester.pumpUntil(
    () => time.evaluate().isEmpty,
    reason: 'the Time row hidden once the reminder is off',
  );
  await tester.pumpFor(const Duration(milliseconds: 400));
  expect(database.reminder.on, isFalse);
  await shots.take('f_settings_reminder_off');

  // On again: the Time row with the last time picked.
  await tester.tap(_reminderToggle);
  await tester.pumpUntil(
    () => time.evaluate().isNotEmpty,
    reason: 'the Time row back',
  );
  expect(database.reminder.on, isTrue);
  expect((database.reminder.hour, database.reminder.minute), (hour, minute));
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
