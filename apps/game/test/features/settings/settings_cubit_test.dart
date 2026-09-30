import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_game/core/base/base_async_state.dart';
import 'package:nesty_game/core/models/reminder_settings.dart';
import 'package:nesty_game/core/models/symbols_mode.dart';
import 'package:nesty_game/core/services/app_info/fake_app_info_service.dart';
import 'package:nesty_game/core/services/clock/fake_clock.dart';
import 'package:nesty_game/core/services/daily/fake_daily_service.dart';
import 'package:nesty_game/core/services/database/fake_database_service.dart';
import 'package:nesty_game/core/services/notifications/fake_notification_service.dart';
import 'package:nesty_game/core/services/notifications/notification_service.dart';
import 'package:nesty_game/core/services/reminder/daily_reminder.dart';
import 'package:nesty_game/core/services/save/fake_save_service.dart';
import 'package:nesty_game/core/services/system_settings/fake_system_settings_service.dart';
import 'package:nesty_game/features/settings/cubit/settings_cubit.dart';

/// A [FakeNotificationService] whose OS prompt stays up until [answer]:
/// a second request meanwhile fails at once as the plugin's
/// `permissionRequestInProgress` does, which reads as unknown (M7 review
/// R35).
class _PromptUpNotifications extends FakeNotificationService {
  Completer<NotificationPermission>? _prompt;

  /// The player answers the prompt.
  void answer(NotificationPermission permission) =>
      _prompt!.complete(permission);

  @override
  Future<NotificationPermission> requestPermission() {
    requestCount++;
    final prompt = _prompt;
    if (prompt != null && !prompt.isCompleted) {
      return Future.value(NotificationPermission.unknown);
    }
    return (_prompt = Completer()).future;
  }
}

/// Builds the reminder from fakes, [unlocked] by default (m7-design P3.10).
DailyReminder _reminder(
  FakeDatabaseService database, {
  FakeNotificationService? notifications,
  bool unlocked = true,
}) => DailyReminder(
  notifications ?? FakeNotificationService(),
  database,
  FakeDailyService(FakeClock())..unlocked = unlocked,
);

void main() {
  blocTest<SettingsCubit, AsyncValue<SettingsState>>(
    'reads the toggles, the symbols mode, the app info and the player id',
    build: () {
      final database = FakeDatabaseService();
      final save = FakeSaveService();
      return SettingsCubit(
        database,
        FakeAppInfoService(),
        save,
        _reminder(database),
      );
    },
    setUp: () async {},
    act: (cubit) => cubit.load(),
    expect: () => [
      const AsyncValue<SettingsState>.loading(),
      predicate<AsyncValue<SettingsState>>((v) {
        final data = v.data;
        return data != null &&
            data.soundEnabled &&
            data.musicEnabled &&
            data.hapticsEnabled &&
            data.symbolsMode == SymbolsMode.large &&
            data.version == '1.0.0' &&
            data.buildNumber == '42';
      }),
    ],
  );

  test('the player id comes from SaveService.load, once it has run', () async {
    final save = FakeSaveService();
    await save.load();
    final database = FakeDatabaseService();
    final cubit = SettingsCubit(
      database,
      FakeAppInfoService(),
      save,
      _reminder(database),
    );
    addTearDown(cubit.close);
    await cubit.load();
    expect(cubit.state.data?.playerId, save.playerId);
    expect(cubit.state.data?.playerId, isNotEmpty);
  });

  test('toggles write DatabaseService only, and update the state', () async {
    final database = FakeDatabaseService();
    final cubit = SettingsCubit(
      database,
      FakeAppInfoService(),
      FakeSaveService(),
      _reminder(database),
    );
    addTearDown(cubit.close);
    await cubit.load();

    await cubit.setSoundEnabled(false);
    expect(cubit.state.data?.soundEnabled, isFalse);
    expect(database.soundEnabled, isFalse);

    await cubit.setMusicEnabled(false);
    expect(cubit.state.data?.musicEnabled, isFalse);
    expect(database.musicEnabled, isFalse);

    await cubit.setHapticsEnabled(false);
    expect(cubit.state.data?.hapticsEnabled, isFalse);
    expect(database.hapticsEnabled, isFalse);

    await cubit.setSymbolsMode(SymbolsMode.subtle);
    expect(cubit.state.data?.symbolsMode, SymbolsMode.subtle);
    expect(database.symbolsMode, SymbolsMode.subtle);
  });

  test('a toggle before load does nothing (no data to update yet)', () async {
    final database = FakeDatabaseService();
    final cubit = SettingsCubit(
      database,
      FakeAppInfoService(),
      FakeSaveService(),
      _reminder(database),
    );
    addTearDown(cubit.close);
    await cubit.setSoundEnabled(false);
    expect(cubit.state.hasData, isFalse);
  });

  group('the daily reminder (E4; m7-design P3.10)', () {
    test('is unavailable before the daily unlocks', () async {
      final database = FakeDatabaseService();
      final cubit = SettingsCubit(
        database,
        FakeAppInfoService(),
        FakeSaveService(),
        _reminder(database, unlocked: false),
      );
      addTearDown(cubit.close);
      await cubit.load();
      expect(cubit.state.data?.reminder.available, isFalse);
    });

    test('setReminderOn(true) grants, persists and schedules', () async {
      final database = FakeDatabaseService();
      addTearDown(database.close);
      final notifications = FakeNotificationService();
      final reminder = _reminder(database, notifications: notifications);
      final cubit = SettingsCubit(
        database,
        FakeAppInfoService(),
        FakeSaveService(),
        reminder,
      );
      addTearDown(cubit.close);
      await cubit.load();

      final ok = await cubit.setReminderOn(true);

      expect(ok, isTrue);
      expect(database.reminder.on, isTrue);
      expect(notifications.requestCount, 1);
      expect(notifications.scheduled, isNotNull);
      expect(cubit.state.data?.reminder.settings.on, isTrue);
    });

    test('setReminderOn(true) denied reports false and leaves it ON and '
        'blocked (D190)', () async {
      final database = FakeDatabaseService();
      addTearDown(database.close);
      final notifications = FakeNotificationService()
        ..permissionAnswer = NotificationPermission.denied;
      final reminder = _reminder(database, notifications: notifications);
      final system = FakeSystemSettingsService();
      final cubit = SettingsCubit(
        database,
        FakeAppInfoService(),
        FakeSaveService(),
        reminder,
        systemSettings: system,
      );
      addTearDown(cubit.close);
      await cubit.load();

      final ok = await cubit.setReminderOn(true);

      expect(ok, isFalse);
      expect(database.reminder.on, isTrue);
      expect(cubit.state.data?.reminder.blocked, isTrue);
      expect(notifications.scheduled, isNotNull);
    });

    test('openPhoneSettings calls SystemSettingsService', () async {
      final database = FakeDatabaseService();
      addTearDown(database.close);
      final system = FakeSystemSettingsService();
      final cubit = SettingsCubit(
        database,
        FakeAppInfoService(),
        FakeSaveService(),
        _reminder(database),
        systemSettings: system,
      );
      addTearDown(cubit.close);
      await cubit.load();

      expect(await cubit.openPhoneSettings(), isTrue);
      expect(system.openCalls, 1);
    });

    test('a blocked reminder clears when the phone allows notifications '
        'and the app resumes', () async {
      final database = FakeDatabaseService();
      addTearDown(database.close);
      final notifications = FakeNotificationService()
        ..permissionAnswer = NotificationPermission.denied;
      final reminder = _reminder(database, notifications: notifications);
      final cubit = SettingsCubit(
        database,
        FakeAppInfoService(),
        FakeSaveService(),
        reminder,
      );
      addTearDown(cubit.close);
      await cubit.load();
      await cubit.setReminderOn(true);
      expect(cubit.state.data?.reminder.blocked, isTrue);

      notifications.permissionAnswer = NotificationPermission.granted;
      await reminder.refresh();
      await Future<void>.delayed(Duration.zero);

      expect(cubit.state.data?.reminder.blocked, isFalse);
      expect(cubit.state.data?.reminder.settings.on, isTrue);
    });

    test(
      'turning a blocked reminder off (the toggle) still turns it off',
      () async {
        final database = FakeDatabaseService();
        addTearDown(database.close);
        final notifications = FakeNotificationService()
          ..permissionAnswer = NotificationPermission.denied;
        final cubit = SettingsCubit(
          database,
          FakeAppInfoService(),
          FakeSaveService(),
          _reminder(database, notifications: notifications),
        );
        addTearDown(cubit.close);
        await cubit.load();
        await cubit.setReminderOn(true);

        await cubit.setReminderOn(false);

        expect(database.reminder.on, isFalse);
        expect(notifications.scheduled, isNull);
      },
    );

    test('a second on while the OS asks is ignored: no false "blocked", '
        'and the first answer decides', () async {
      final database = FakeDatabaseService();
      addTearDown(database.close);
      final notifications = _PromptUpNotifications();
      final reminder = _reminder(database, notifications: notifications);
      final cubit = SettingsCubit(
        database,
        FakeAppInfoService(),
        FakeSaveService(),
        reminder,
      );
      addTearDown(cubit.close);
      await cubit.load();

      final first = cubit.setReminderOn(true);
      await pumpEventQueue();
      expect(notifications.requestCount, 1, reason: 'the prompt is up');

      final second = await cubit.setReminderOn(true);

      expect(second, isTrue, reason: 'a double tap shows no blocked toast');
      expect(notifications.requestCount, 1, reason: 'asked once');
      expect(database.reminder.on, isFalse);

      notifications.answer(NotificationPermission.granted);
      expect(await first, isTrue);
      expect(database.reminder.on, isTrue);
      expect(cubit.state.data?.reminder.settings.on, isTrue);
      expect(notifications.scheduled, isNotNull);
    });

    test('setReminderOn(false) cancels the schedule', () async {
      final database = FakeDatabaseService();
      addTearDown(database.close);
      await database.setReminder(const ReminderSettings(on: true, hour: 8));
      final notifications = FakeNotificationService();
      final reminder = _reminder(database, notifications: notifications);
      final cubit = SettingsCubit(
        database,
        FakeAppInfoService(),
        FakeSaveService(),
        reminder,
      );
      addTearDown(cubit.close);
      await cubit.load();
      expect(cubit.state.data?.reminder.settings.on, isTrue);

      final ok = await cubit.setReminderOn(false);

      expect(ok, isTrue);
      expect(database.reminder.on, isFalse);
      expect(notifications.cancelCalls, greaterThan(0));
    });

    test('setReminderTime stores the new time and reschedules', () async {
      final database = FakeDatabaseService();
      addTearDown(database.close);
      await database.setReminder(const ReminderSettings(on: true));
      final notifications = FakeNotificationService();
      final reminder = _reminder(database, notifications: notifications);
      final cubit = SettingsCubit(
        database,
        FakeAppInfoService(),
        FakeSaveService(),
        reminder,
      );
      addTearDown(cubit.close);
      await cubit.load();

      await cubit.setReminderTime(hour: 8, minute: 15);

      expect(database.reminder.hour, 8);
      expect(database.reminder.minute, 15);
      expect(notifications.scheduled?.hour, 8);
      expect(notifications.scheduled?.minute, 15);
    });

    test('follows DailyReminder.changes after load', () async {
      final database = FakeDatabaseService();
      addTearDown(database.close);
      final notifications = FakeNotificationService();
      final reminder = _reminder(database, notifications: notifications);
      final cubit = SettingsCubit(
        database,
        FakeAppInfoService(),
        FakeSaveService(),
        reminder,
      );
      addTearDown(cubit.close);
      await cubit.load();

      // Enabling through the reminder directly (not the cubit's own method)
      // still reaches the cubit's state, because it follows `changes`.
      await reminder.enable(hour: 9, minute: 0);
      await Future<void>.delayed(Duration.zero);

      expect(cubit.state.data?.reminder.settings.on, isTrue);
      expect(cubit.state.data?.reminder.settings.hour, 9);
    });
  });
}
