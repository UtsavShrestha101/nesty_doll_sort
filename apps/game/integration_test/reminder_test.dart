import 'dart:async' show unawaited;
import 'dart:convert';
import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:nesty_game/core/dependency_injection/di.dart';
import 'package:nesty_game/core/services/database/database_service.dart';
import 'package:nesty_game/core/services/notifications/notification_service.dart';
import 'package:nesty_game/core/ui/nesty_ui.dart';
import 'package:nesty_game/features/gameplay/pages/gameplay_view.dart';
import 'package:nesty_game/features/settings/pages/settings_page.dart';
import 'package:nesty_game/main_dev.dart' as app;

import 'support/board_probe.dart';
import 'support/phone_language.dart';
import 'support/resume_scenario.dart';

/// The optional Android reminder check (E4; m7-design P3.13; plan-m7
/// "Verification"): on a fresh install whose `POST_NOTIFICATIONS` was
/// granted beforehand, so no OS dialog can open, it wins levels 1 and 2
/// (the daily unlocks, so Settings shows the reminder row, Q139), turns
/// "Daily reminder" on in Settings and expects the real
/// `flutter_local_notifications` schedule to hold the one pending reminder
/// (`NotificationService.hasPendingDaily`), then turns it off and expects
/// none. It never taps the offer's "Yes, remind me".
///
/// `nesty-test --android --only reminder` runs it (README "Testing"); by
/// hand:
///
/// ```sh
/// cd apps/game
/// adb uninstall com.futrix.nesty.dev
/// flutter build apk --debug --flavor dev -t integration_test/reminder_test.dart
/// adb install build/app/outputs/flutter-apk/app-dev-debug.apk
/// adb shell pm grant com.futrix.nesty.dev android.permission.POST_NOTIFICATIONS
/// flutter drive --flavor dev --driver test_driver/integration_test.dart \
///   --target integration_test/reminder_test.dart \
///   --use-application-binary build/app/outputs/flutter-apk/app-dev-debug.apk \
///   -d <emulator>
/// ```
///
/// iOS is skipped: `simctl privacy` can't grant notifications, and the
/// permission alert can't be tapped from `flutter drive`. The owner checks a
/// delivered reminder on a phone.
void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  binding.framePolicy = LiveTestWidgetsFlutterBindingFramePolicy.fullyLive;

  testWidgets(
    'Settings turns the daily reminder on (one pending) and off (none)',
    (tester) async {
      pinEnglishPhone(tester);
      app.main();
      final board = Board(tester);
      await tester.pumpUntil(
        () => find.byType(GameplayView).evaluate().isNotEmpty,
        timeout: const Duration(seconds: 60),
        reason: 'level 1 on a fresh save (uninstall the app first)',
      );
      await ResumeScenario.winTutorialLevels(tester, board);

      final notifications = get<NotificationService>();
      final database = get<DatabaseService>();
      Future<bool> pending() async {
        bool? answer;
        unawaited(notifications.hasPendingDaily().then((p) => answer = p));
        await tester.pumpUntil(
          () => answer != null,
          reason: 'the pending reminder read',
        );
        return answer!;
      }

      expect(database.reminder.on, isFalse, reason: 'off on a fresh install');
      expect(await pending(), isFalse, reason: 'nothing scheduled yet');

      await tester.tap(find.bySemanticsLabel('Settings'));
      await tester.pumpUntil(
        () => find.byType(SettingsPage).evaluate().isNotEmpty,
        reason: 'Settings',
      );
      await tester.pumpFor(const Duration(milliseconds: 600));
      final toggle = find.byWidgetPredicate(
        (widget) =>
            widget is NestyToggle && widget.semanticLabel == 'Daily reminder',
      );
      await tester.scrollUntilVisible(
        toggle,
        200,
        scrollable: find
            .descendant(
              of: find.byType(SettingsPage),
              matching: find.byType(Scrollable),
            )
            .first,
      );

      // On: the permission was granted before the launch, so the OS
      // answers without a dialog, and the one reminder is scheduled.
      await tester.tap(toggle);
      await tester.pumpUntil(
        () => database.reminder.on,
        timeout: const Duration(seconds: 20),
        reason: 'the reminder on (was POST_NOTIFICATIONS granted?)',
      );
      await tester.pumpUntil(
        () => find.text('Time').evaluate().isNotEmpty,
        reason: 'the time row',
      );
      final onPending = await pending();
      expect(onPending, isTrue, reason: 'one pending daily reminder');

      // Off: cancelled.
      await tester.tap(toggle);
      await tester.pumpUntil(
        () => !database.reminder.on,
        reason: 'the reminder off',
      );
      await tester.pumpFor(const Duration(milliseconds: 500));
      final offPending = await pending();
      expect(offPending, isFalse, reason: 'cancelled');

      final data = {
        'platform': Platform.operatingSystem,
        'pendingWhenOn': onPending,
        'pendingWhenOff': offPending,
      };
      binding.reportData = {'reminder': data};
      // ignore: avoid_print
      print('NESTY_REMINDER ${jsonEncode(data)}');
    },
    skip: !Platform.isAndroid,
    timeout: const Timeout(Duration(minutes: 5)),
  );
}
