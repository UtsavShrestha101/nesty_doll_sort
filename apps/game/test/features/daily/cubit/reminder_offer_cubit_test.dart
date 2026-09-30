import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_core/nesty_core.dart';
import 'package:nesty_game/core/models/reminder_settings.dart';
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

/// `ReminderOfferCubit` (E4; spec-prop §7.9 "offered once"; docs/plans/
/// m7-design.md P3.10): reminder lane test plan §3. The frozen-hidden case
/// (a fresh, unsolved daily) is already pinned by
/// `test/contracts/m7_phase3_test.dart`.
void main() {
  late FakeDatabaseService settings;
  late FakeNotificationService notifications;
  late FakeDailyService daily;
  late FakeClock clock;
  late DailyReminder reminder;
  late FakeSystemSettingsService systemSettings;

  DailyStatus solvedStatus({int? minuteOfDay}) => DailyStatus(
    today: LocalDate(2026, 9, 26),
    tier: Tier.hard,
    colors: 5,
    unlocked: true,
    solvedToday: true,
    solve: DailySolve(
      date: LocalDate(2026, 9, 26),
      moves: 18,
      families: 5,
      minuteOfDay: minuteOfDay,
    ),
  );

  setUp(() {
    settings = FakeDatabaseService();
    notifications = FakeNotificationService();
    clock = FakeClock(now: DateTime(2026, 9, 26, 14, 30));
    daily = FakeDailyService(clock);
    reminder = DailyReminder(notifications, settings, daily);
    systemSettings = FakeSystemSettingsService();
  });

  tearDown(() async {
    await reminder.dispose();
    await settings.close();
  });

  ReminderOfferCubit build() => ReminderOfferCubit(
    reminder,
    settings,
    daily,
    clock,
    systemSettings: systemSettings,
  );

  test('hidden when today is not solved', () async {
    daily.status = solvedStatus().copyWith(solvedToday: false);
    final cubit = build();
    addTearDown(cubit.close);
    await cubit.load();
    expect(cubit.state.data?.step, ReminderOfferStep.hidden);
    expect(settings.reminder.offered, isFalse);
  });

  test('hidden when the daily is locked', () async {
    daily.unlocked = false;
    daily.status = solvedStatus();
    final cubit = build();
    addTearDown(cubit.close);
    await cubit.load();
    expect(cubit.state.data?.step, ReminderOfferStep.hidden);
  });

  test('hidden once already offered (a later solved day)', () async {
    await settings.setReminder(const ReminderSettings(offered: true));
    daily.status = solvedStatus();
    final cubit = build();
    addTearDown(cubit.close);
    await cubit.load();
    expect(cubit.state.data?.step, ReminderOfferStep.hidden);
  });

  test('hidden over the session fallback, where "offered" cannot be kept '
      '(M7 review R30)', () async {
    final fallback = SessionFallbackDatabaseService();
    final overFallback = DailyReminder(notifications, fallback, daily);
    addTearDown(() async {
      await overFallback.dispose();
      await fallback.close();
    });
    daily.status = solvedStatus(minuteOfDay: 9 * 60);
    final cubit = ReminderOfferCubit(overFallback, fallback, daily, clock);
    addTearDown(cubit.close);
    await cubit.load();
    expect(cubit.state.data?.step, ReminderOfferStep.hidden);
    expect(fallback.reminder.offered, isFalse);
  });

  test('hidden once already on', () async {
    await settings.setReminder(const ReminderSettings(on: true, offered: true));
    daily.status = solvedStatus();
    final cubit = build();
    addTearDown(cubit.close);
    await cubit.load();
    expect(cubit.state.data?.step, ReminderOfferStep.hidden);
  });

  group('the first appearance', () {
    test('shows ask, at the solve\'s hour, and writes offered once', () async {
      daily.status = solvedStatus(minuteOfDay: 8 * 60 + 5); // 8:05 AM
      final cubit = build();
      addTearDown(cubit.close);

      await cubit.load();

      expect(cubit.state.data?.step, ReminderOfferStep.ask);
      expect(cubit.state.data?.hour, 8);
      expect(cubit.state.data?.minute, 0);
      expect(settings.reminder.offered, isTrue);
      expect(settings.reminder.hour, 8);
      expect(settings.reminder.minute, 0);
      expect(settings.reminder.on, isFalse);
    });

    test('falls back to the clock\'s hour when the solve has none', () async {
      daily.status = solvedStatus();
      final cubit = build();
      addTearDown(cubit.close);

      await cubit.load();

      expect(cubit.state.data?.hour, 14); // clock.now() is 14:30
      expect(settings.reminder.hour, 14);
    });

    test(
      'a second load, later, never shows it again (already offered)',
      () async {
        daily.status = solvedStatus(minuteOfDay: 8 * 60);
        final first = build();
        await first.load();
        expect(first.state.data?.step, ReminderOfferStep.ask);
        await first.close();

        // A fresh cubit, as a new page visit would build.
        final second = build();
        addTearDown(second.close);
        await second.load();
        expect(second.state.data?.step, ReminderOfferStep.hidden);
      },
    );
  });

  test(
    'setTime updates only this cubit\'s own draft, not the settings',
    () async {
      daily.status = solvedStatus(minuteOfDay: 8 * 60);
      final cubit = build();
      addTearDown(cubit.close);
      await cubit.load();

      cubit.setTime(hour: 21, minute: 30);

      expect(cubit.state.data?.hour, 21);
      expect(cubit.state.data?.minute, 30);
      expect(settings.reminder.hour, 8); // unchanged until accept()
    },
  );

  group('accept (Yes, remind me)', () {
    test('granted: enabled, persisting the chosen time', () async {
      daily.status = solvedStatus(minuteOfDay: 8 * 60);
      final cubit = build();
      addTearDown(cubit.close);
      await cubit.load();
      cubit.setTime(hour: 21, minute: 15);

      await cubit.accept();

      expect(cubit.state.data?.step, ReminderOfferStep.enabled);
      expect(settings.reminder.on, isTrue);
      expect(settings.reminder.hour, 21);
      expect(settings.reminder.minute, 15);
      expect(notifications.requestCount, 1);
    });

    test('denied: shows the denied step, and the reminder stays ON and '
        'blocked (D190)', () async {
      notifications.permissionAnswer = NotificationPermission.denied;
      daily.status = solvedStatus(minuteOfDay: 8 * 60);
      final cubit = build();
      addTearDown(cubit.close);
      await cubit.load();
      cubit.setTime(hour: 20, minute: 45);

      await cubit.accept();

      expect(cubit.state.data?.step, ReminderOfferStep.denied);
      expect(settings.reminder.on, isTrue);
      expect(settings.reminder.hour, 20);
      expect(settings.reminder.minute, 45);
      expect(reminder.status.blocked, isTrue);
    });

    test('denied, then Open phone settings, then back with notifications '
        'allowed: enabled', () async {
      notifications.permissionAnswer = NotificationPermission.denied;
      daily.status = solvedStatus(minuteOfDay: 8 * 60);
      final cubit = build();
      addTearDown(cubit.close);
      await cubit.load();
      await cubit.accept();

      await cubit.openPhoneSettings();
      expect(systemSettings.openCalls, 1);
      expect(cubit.state.data?.step, ReminderOfferStep.denied);

      // The player allowed them in the phone; the app's resume refresh
      // reads the new permission.
      notifications.permissionAnswer = NotificationPermission.granted;
      await reminder.refresh();
      await Future<void>.delayed(Duration.zero);

      expect(cubit.state.data?.step, ReminderOfferStep.enabled);
    });

    test('Open phone settings does nothing outside the denied step', () async {
      daily.status = solvedStatus(minuteOfDay: 8 * 60);
      final cubit = build();
      addTearDown(cubit.close);
      await cubit.load();

      await cubit.openPhoneSettings();

      expect(systemSettings.openCalls, 0);
    });

    test('passes through an "asking" step while the OS is asked', () async {
      daily.status = solvedStatus(minuteOfDay: 8 * 60);
      final cubit = build();
      addTearDown(cubit.close);
      await cubit.load();

      final states = <ReminderOfferStep>[];
      final subscription = cubit.stream.listen(
        (value) => states.add(value.data!.step),
      );
      await cubit.accept();
      // A broadcast stream's async delivery can still have the last emit's
      // microtask pending right after `accept()` resolves; give it one more
      // turn before reading what the listener saw.
      await Future<void>.delayed(Duration.zero);
      await subscription.cancel();

      expect(states, contains(ReminderOfferStep.asking));
      expect(states.last, ReminderOfferStep.enabled);
    });
  });

  test('decline (No thanks): hidden, nothing further stored', () async {
    daily.status = solvedStatus(minuteOfDay: 8 * 60);
    final cubit = build();
    addTearDown(cubit.close);
    await cubit.load();

    await cubit.decline();

    expect(cubit.state.data?.step, ReminderOfferStep.hidden);
    expect(settings.reminder.on, isFalse);
    expect(settings.reminder.offered, isTrue); // load()'s own write stands
  });

  test('dismiss closes the enabled step', () async {
    daily.status = solvedStatus(minuteOfDay: 8 * 60);
    final cubit = build();
    addTearDown(cubit.close);
    await cubit.load();
    await cubit.accept();
    expect(cubit.state.data?.step, ReminderOfferStep.enabled);

    cubit.dismiss();

    expect(cubit.state.data?.step, ReminderOfferStep.hidden);
  });

  test('dismiss closes the denied step', () async {
    notifications.permissionAnswer = NotificationPermission.denied;
    daily.status = solvedStatus(minuteOfDay: 8 * 60);
    final cubit = build();
    addTearDown(cubit.close);
    await cubit.load();
    await cubit.accept();
    expect(cubit.state.data?.step, ReminderOfferStep.denied);

    cubit.dismiss();

    expect(cubit.state.data?.step, ReminderOfferStep.hidden);
  });
}
