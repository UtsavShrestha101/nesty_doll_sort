import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart' show RenderParagraph;
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

import '../../support/screen_harness.dart';

/// The one-time reminder offer (E4; frames 10.2, 10.2c, 10.2d; ui-spec-menus
/// §6.2; phase 4 architecture §3.9).
void main() {
  late FakeDatabaseService settings;
  late FakeNotificationService notifications;
  late FakeDailyService daily;
  late FakeSystemSettingsService systemSettings;
  late DailyReminder reminder;
  late ReminderOfferCubit cubit;

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

  setUp(() {
    settings = FakeDatabaseService();
    notifications = FakeNotificationService();
    daily = FakeDailyService(FakeClock())..status = solvedStatus();
    systemSettings = FakeSystemSettingsService();
    reminder = DailyReminder(notifications, settings, daily);
    cubit = ReminderOfferCubit(
      reminder,
      settings,
      daily,
      FakeClock(),
      systemSettings: systemSettings,
    );
  });

  tearDown(() async {
    await reminder.dispose();
    await settings.close();
  });

  Future<void> pumpDialog(WidgetTester tester) async {
    await pumpScreen(
      tester,
      BlocProvider.value(value: cubit, child: const ReminderOfferDialog()),
    );
    await cubit.load();
    await tester.pump();
  }

  Future<void> settle(WidgetTester tester) async {
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
  }

  const title = 'Want a note when tomorrow’s puzzle is ready?';

  testWidgets('nothing renders while hidden', (tester) async {
    daily.status = solvedStatus().copyWith(solvedToday: false);
    await pumpDialog(tester);
    expect(find.text(title), findsNothing);
  });

  testWidgets('the ask step: title, body, time chip, Change time, Yes, '
      'No thanks', (tester) async {
    await pumpDialog(tester);
    await settle(tester);

    expect(find.text(title), findsOneWidget);
    expect(find.textContaining('One quiet note a day'), findsOneWidget);
    expect(find.textContaining('Every day at'), findsOneWidget);
    expect(find.text('Change time'), findsOneWidget);
    expect(find.text('Yes, remind me'), findsOneWidget);
    expect(find.text('No thanks'), findsOneWidget);
    // Modal: no close disc (ui-spec-menus §6.2).
    expect(find.bySemanticsLabel('Close'), findsNothing);
  });

  testWidgets('its text has the app\'s defaults with no Material around it '
      '(the Daily page draws it beside its Scaffold): no underline', (
    tester,
  ) async {
    // The device run (2026-09-30) found every line of the card underlined
    // in yellow: the fallback style Text gets with no Material above it.
    await pumpDialog(tester);
    await settle(tester);
    expect(find.byType(Scaffold), findsNothing, reason: 'as on the page');
    for (final text in [title, 'Yes, remind me', 'No thanks']) {
      final paragraph = tester.renderObject<RenderParagraph>(find.text(text));
      final decorations = <TextDecoration?>[];
      paragraph.text.visitChildren((InlineSpan span) {
        decorations.add(span.style?.decoration);
        return true;
      });
      expect(
        decorations.where((d) => d != null && d != TextDecoration.none),
        isEmpty,
        reason: text,
      );
    }
  });

  testWidgets('the time chip names its own action for a screen reader', (
    tester,
  ) async {
    await pumpDialog(tester);
    await settle(tester);
    expect(
      find.bySemanticsLabel(RegExp(r'Every day at .*, Change time')),
      findsOneWidget,
    );
  });

  testWidgets('a tap on the scrim does nothing', (tester) async {
    await pumpDialog(tester);
    await settle(tester);
    await tester.tapAt(const Offset(4, 300));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text(title), findsOneWidget);
  });

  testWidgets('system back is No thanks', (tester) async {
    await pumpDialog(tester);
    await settle(tester);
    await tester.binding.handlePopRoute();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text(title), findsNothing);
    expect(settings.reminder.on, isFalse);
    expect(settings.reminder.offered, isTrue);
  });

  testWidgets('No thanks closes the card and never turns it on', (
    tester,
  ) async {
    await pumpDialog(tester);
    await settle(tester);
    await tester.tap(find.text('No thanks'));
    await settle(tester);
    expect(find.text('No thanks'), findsNothing);
    expect(settings.reminder.on, isFalse);
    expect(settings.reminder.offered, isTrue);
    expect(notifications.requestCount, 0);
  });

  testWidgets('Yes (allowed): the card closes and the "Reminder set" toast '
      'shows, the OS asked once', (tester) async {
    await pumpDialog(tester);
    await settle(tester);
    await tester.tap(find.text('Yes, remind me'));
    await settle(tester);

    expect(find.text(title), findsNothing);
    expect(find.textContaining('Reminder set for'), findsOneWidget);
    expect(notifications.requestCount, 1);
    expect(settings.reminder.on, isTrue);
    await tester.pump(const Duration(seconds: 4));
  });

  testWidgets('Yes (denied): the card becomes "Notifications are off for '
      'Nesty" with Open phone settings and Not now; the reminder stays on '
      '(D190)', (tester) async {
    notifications.permissionAnswer = NotificationPermission.denied;
    await pumpDialog(tester);
    await settle(tester);
    await tester.tap(find.text('Yes, remind me'));
    await settle(tester);

    expect(find.text('Notifications are off for Nesty'), findsOneWidget);
    expect(find.textContaining('your note will arrive at'), findsOneWidget);
    expect(find.text('Open phone settings'), findsOneWidget);
    expect(find.text('Not now'), findsOneWidget);
    expect(find.text('Yes, remind me'), findsNothing);
    expect(settings.reminder.on, isTrue);
    expect(reminder.status.blocked, isTrue);
  });

  testWidgets('the denied card: Open phone settings calls the service, Not '
      'now closes it', (tester) async {
    notifications.permissionAnswer = NotificationPermission.denied;
    await pumpDialog(tester);
    await settle(tester);
    await tester.tap(find.text('Yes, remind me'));
    await settle(tester);

    await tester.tap(find.text('Open phone settings'));
    await settle(tester);
    expect(systemSettings.openCalls, 1);
    expect(find.text('Notifications are off for Nesty'), findsOneWidget);

    await tester.tap(find.text('Not now'));
    await settle(tester);
    expect(find.text('Notifications are off for Nesty'), findsNothing);
    // Still on and blocked: closing the card changes no setting.
    expect(settings.reminder.on, isTrue);
  });

  testWidgets('the denied card, back with notifications allowed: the '
      'toast shows and the card is gone', (tester) async {
    notifications.permissionAnswer = NotificationPermission.denied;
    await pumpDialog(tester);
    await settle(tester);
    await tester.tap(find.text('Yes, remind me'));
    await settle(tester);
    await tester.tap(find.text('Open phone settings'));
    await settle(tester);

    notifications.permissionAnswer = NotificationPermission.granted;
    await tester.runAsync(() => reminder.refresh());
    await settle(tester);

    expect(find.text('Notifications are off for Nesty'), findsNothing);
    expect(find.textContaining('Reminder set for'), findsOneWidget);
    await tester.pump(const Duration(seconds: 4));
  });

  testWidgets('never mentions the streak', (tester) async {
    await pumpDialog(tester);
    await settle(tester);
    expect(find.textContaining('streak'), findsNothing);
    expect(find.textContaining('Streak'), findsNothing);
  });

  testWidgets('reduced motion: the card is there at once', (tester) async {
    await pumpScreen(
      tester,
      BlocProvider.value(value: cubit, child: const ReminderOfferDialog()),
      reduceMotion: true,
    );
    await cubit.load();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 130));
    expect(find.text(title), findsOneWidget);
  });
}
