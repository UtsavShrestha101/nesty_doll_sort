import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_core/nesty_core.dart';
import 'package:nesty_game/core/services/clock/fake_clock.dart';
import 'package:nesty_game/core/services/clock/local_date.dart';
import 'package:nesty_game/core/services/daily/daily_status.dart';
import 'package:nesty_game/core/services/daily/fake_daily_service.dart';
import 'package:nesty_game/core/services/database/fake_database_service.dart';
import 'package:nesty_game/core/services/notifications/fake_notification_service.dart';
import 'package:nesty_game/core/services/notifications/notification_service.dart';
import 'package:nesty_game/core/services/reminder/daily_reminder.dart';
import 'package:nesty_game/core/services/save/save_document.dart';
import 'package:nesty_game/core/services/system_settings/fake_system_settings_service.dart';
import 'package:nesty_game/features/daily/cubit/reminder_offer_cubit.dart';
import 'package:nesty_game/features/daily/widgets/reminder_offer_dialog.dart';

import '../core/ui/support/ui_harness.dart';
import '../features/support/screen_harness.dart';

/// The reminder offer (E4; frames 10.2, 10.2c, 10.2d) at every step, at the five
/// acceptance sizes and both text scales (reminder lane test plan §3).
void main() {
  setUpAll(loadBundledFonts);

  DailyStatus solvedStatus() => DailyStatus(
    today: LocalDate(2026, 9, 26),
    tier: Tier.hard,
    colors: 5,
    unlocked: true,
    solvedToday: true,
    solve: DailySolve(
      date: LocalDate(2026, 9, 26),
      moves: 18,
      families: 5,
      minuteOfDay: 19 * 60,
    ),
  );

  Future<void> pumpStep(
    WidgetTester tester, {
    required Size size,
    required double textScale,
    NotificationPermission permission = NotificationPermission.granted,
    String? tapLabel,
  }) async {
    final settings = FakeDatabaseService();
    addTearDown(settings.close);
    final notifications = FakeNotificationService()
      ..permissionAnswer = permission;
    final daily = FakeDailyService(FakeClock())..status = solvedStatus();
    final reminder = DailyReminder(notifications, settings, daily);
    addTearDown(reminder.dispose);
    final cubit = ReminderOfferCubit(
      reminder,
      settings,
      daily,
      FakeClock(),
      systemSettings: FakeSystemSettingsService(),
    );
    addTearDown(cubit.close);

    await pumpScreen(
      tester,
      BlocProvider.value(value: cubit, child: const ReminderOfferDialog()),
      size: size,
      textScale: textScale,
    );
    await cubit.load();
    await tester.pump();
    if (tapLabel != null) {
      // A short screen at 1.3× scrolls the card: bring the button in.
      await tester.ensureVisible(find.text(tapLabel));
      await tester.tap(find.text(tapLabel));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
    }
  }

  for (final size in overflowScreenSizes) {
    for (final scale in textScales) {
      final label =
          '${size.width.toInt()}×${size.height.toInt()} at $scale× text';

      testWidgets('the ask step fits $label', (tester) async {
        await pumpStep(tester, size: size, textScale: scale);
        await expectAccessibleLayout(tester);
      });

      testWidgets('the set step (card gone, toast up) fits $label', (
        tester,
      ) async {
        await pumpStep(
          tester,
          size: size,
          textScale: scale,
          tapLabel: 'Yes, remind me',
        );
        expect(find.textContaining('Reminder set for'), findsOneWidget);
        await expectAccessibleLayout(tester);
        await tester.pump(const Duration(seconds: 4));
      });

      testWidgets('the denied step fits $label', (tester) async {
        await pumpStep(
          tester,
          size: size,
          textScale: scale,
          permission: NotificationPermission.denied,
          tapLabel: 'Yes, remind me',
        );
        expect(find.text('Open phone settings'), findsOneWidget);
        await expectAccessibleLayout(tester);
      });
    }
  }
}
