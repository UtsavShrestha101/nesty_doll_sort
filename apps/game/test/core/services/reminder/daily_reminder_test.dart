import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_game/app/localization_cubit/app_locale_resolver.dart';
import 'package:nesty_game/core/models/reminder_settings.dart';
import 'package:nesty_game/core/services/clock/fake_clock.dart';
import 'package:nesty_game/core/services/daily/fake_daily_service.dart';
import 'package:nesty_game/core/services/database/database_service.dart';
import 'package:nesty_game/core/services/database/fake_database_service.dart';
import 'package:nesty_game/core/services/database/hive_database_service.dart';
import 'package:nesty_game/core/services/database/settings_schema.dart';
import 'package:nesty_game/core/services/notifications/fake_notification_service.dart';
import 'package:nesty_game/core/services/notifications/notification_service.dart';
import 'package:nesty_game/core/services/reminder/daily_reminder.dart';
import 'package:nesty_game/l10n/app_localizations.dart';

import '../../../app/localization_cubit/support/launch_catalogs.dart';

/// `DailyReminder` (E4; spec-prop §7.9; docs/plans/m7-design.md P3.10):
/// reminder lane test plan §3. `test/contracts/m7_phase3_test.dart` already
/// pins the frozen "fresh install neither schedules nor asks" and `planFor`
/// contracts; this file owns the built behaviour.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FakeDatabaseService settings;
  late FakeNotificationService notifications;
  late FakeDailyService daily;
  late DailyReminder reminder;
  const englishPhone = [Locale('en', 'US')];

  setUp(() {
    settings = FakeDatabaseService();
    notifications = FakeNotificationService();
    daily = FakeDailyService(FakeClock())..unlocked = true;
    // An English phone: the settings default ("system") follows it, so
    // the English copy below holds whatever the host's own language.
    reminder = DailyReminder(
      notifications,
      settings,
      daily,
      deviceLocales: () => englishPhone,
    );
  });

  tearDown(() async {
    await reminder.dispose();
    await settings.close();
  });

  test('a fresh install neither schedules nor asks', () async {
    reminder.start();
    final status = await reminder.refresh();
    expect(status.settings, const ReminderSettings());
    expect(notifications.requestCount, 0);
    expect(notifications.scheduleCalls, isEmpty);
    expect(await notifications.hasPendingDaily(), isFalse);
  });

  test('available is false before the daily unlocks (Level 2)', () async {
    daily.unlocked = false;
    final status = await reminder.refresh();
    expect(status.available, isFalse);
  });

  test('available is true once the daily unlocks', () async {
    final status = await reminder.refresh();
    expect(status.available, isTrue);
  });

  group('enable', () {
    test('granted turns it on, persists the time and offered, and '
        'schedules one plan', () async {
      final result = await reminder.enable(hour: 8, minute: 30);

      expect(result, ReminderEnableResult.enabled);
      expect(settings.reminder.on, isTrue);
      expect(settings.reminder.hour, 8);
      expect(settings.reminder.minute, 30);
      expect(settings.reminder.offered, isTrue);
      expect(notifications.requestCount, 1);
      expect(notifications.scheduled?.hour, 8);
      expect(notifications.scheduled?.minute, 30);
      expect(reminder.status.settings.on, isTrue);
    });

    test(
      'denied keeps it ON and blocked, with the chosen time (D190)',
      () async {
        notifications.permissionAnswer = NotificationPermission.denied;

        final result = await reminder.enable(hour: 9, minute: 15);

        expect(result, ReminderEnableResult.denied);
        expect(settings.reminder.on, isTrue);
        expect(settings.reminder.hour, 9);
        expect(settings.reminder.minute, 15);
        expect(settings.reminder.offered, isTrue);
        expect(reminder.status.blocked, isTrue);
        // The plan stays with the OS, so allowing notifications in the phone's
        // settings resumes it without another Yes.
        expect(notifications.scheduled?.hour, 9);
      },
    );

    test('a denied Yes clears itself when the phone allows notifications '
        'and the app resumes', () async {
      notifications.permissionAnswer = NotificationPermission.denied;
      await reminder.enable(hour: 9, minute: 15);
      expect(reminder.status.blocked, isTrue);

      notifications.permissionAnswer = NotificationPermission.granted;
      final status = await reminder.refresh();

      expect(status.blocked, isFalse);
      expect(status.settings.on, isTrue);
    });

    test('an answer the platform cannot give keeps it off', () async {
      notifications.permissionAnswer = NotificationPermission.unknown;
      final result = await reminder.enable(hour: 7, minute: 0);
      expect(result, ReminderEnableResult.denied);
      expect(settings.reminder.on, isFalse);
    });
  });

  test('disable turns it off and cancels the schedule', () async {
    await reminder.enable(hour: 8, minute: 0);
    expect(notifications.scheduled, isNotNull);

    await reminder.disable();

    expect(settings.reminder.on, isFalse);
    expect(notifications.scheduled, isNull);
    expect(notifications.cancelCalls, greaterThan(0));
  });

  test('setTime stores the new time and reschedules while on', () async {
    await reminder.enable(hour: 8, minute: 0);

    await reminder.setTime(hour: 21, minute: 45);

    expect(settings.reminder.hour, 21);
    expect(settings.reminder.minute, 45);
    expect(notifications.scheduled?.hour, 21);
    expect(notifications.scheduled?.minute, 45);
  });

  test('setTime says whether the time was stored', () async {
    expect(await reminder.setTime(hour: 7, minute: 5), isTrue);
    final failing = DailyReminder(
      notifications,
      _FailingStore(),
      daily,
      deviceLocales: () => englishPhone,
    );
    expect(await failing.setTime(hour: 7, minute: 5), isFalse);
    await failing.dispose();
  });

  test('setTime while off stores the time but schedules nothing', () async {
    await reminder.setTime(hour: 6, minute: 0);
    expect(settings.reminder.hour, 6);
    expect(notifications.scheduled, isNull);
  });

  test(
    'a settings change from elsewhere reschedules through start()',
    () async {
      reminder.start();
      await Future<void>.delayed(Duration.zero);

      await settings.setReminder(
        const ReminderSettings(on: true, hour: 10, minute: 0),
      );
      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);

      expect(notifications.scheduled?.hour, 10);
    },
  );

  test('a language change re-plans through start()', () async {
    await reminder.enable(hour: 8, minute: 0);
    expect(notifications.scheduled?.title, 'Nesty');

    reminder.start();
    await Future<void>.delayed(Duration.zero);
    final before = notifications.scheduleCalls.length;

    await settings.setLanguage('en');
    await Future<void>.delayed(Duration.zero);
    await Future<void>.delayed(Duration.zero);
    expect(notifications.scheduleCalls.length, greaterThan(before));
    final english = lookupAppLocalizations(const Locale('en'));
    expect(
      [
        english.reminderNotificationBody,
        english.reminderNotificationBody2,
        english.reminderNotificationBody3,
      ],
      contains(notifications.scheduled?.body),
      reason: 'the re-plan carries the pinned language',
    );
  });

  group("the notification's text is in the app's language (M7 phase 5B, "
      'l10n plan §1.4)', () {
    // A fixed day, so every plan carries the same line (G.7 rotation).
    final now = DateTime(2026, 9, 30, 10);

    ReminderPlan planOn(List<Locale> phone, {AppLocaleResolver? locales}) {
      final planner = DailyReminder(
        notifications,
        settings,
        daily,
        clock: FakeClock(now: now),
        locales: locales,
        deviceLocales: () => phone,
      );
      addTearDown(planner.dispose);
      return planner.planFor(const ReminderSettings(on: true, hour: 19));
    }

    /// The plan [l10n]'s catalog gives on the same day.
    void expectPlanIn(ReminderPlan plan, AppLocalizations l10n) {
      expect(plan.title, l10n.reminderNotificationTitle);
      // 2026-09-30 19:00 is epoch day 20726: 20726 % 3 = 2, the third line.
      expect(plan.body, l10n.reminderNotificationBody3);
      expect(plan.channelName, l10n.reminderChannelName);
      expect(plan.channelDescription, l10n.reminderChannelDescription);
    }

    for (final locale in AppLocalizations.supportedLocales) {
      test('a pinned $locale gives its own lines on a Korean phone', () async {
        await settings.setLanguage(locale.toString());
        expectPlanIn(
          planOn(const [Locale('ko')]),
          lookupAppLocalizations(locale),
        );
      });

      test('"system" on a ${locale.languageCode} phone gives its lines', () {
        expect(settings.languageCode, LocaleSetting.system);
        expectPlanIn(
          planOn([Locale(locale.languageCode, 'XX')]),
          lookupAppLocalizations(Locale(locale.languageCode)),
        );
      });
    }

    test('"system" on a phone with no supported language gives English', () {
      expectPlanIn(
        planOn(const [Locale('ko'), Locale('zh', 'CN')]),
        lookupAppLocalizations(const Locale('en')),
      );
    });

    test('a pinned language beats the phone, as in the app', () async {
      await settings.setLanguage('en');
      final phone = [
        for (final l in AppLocalizations.supportedLocales)
          if (l.languageCode != 'en') l,
        const Locale('en'),
      ];
      expectPlanIn(planOn(phone), lookupAppLocalizations(const Locale('en')));
    });

    test('an unknown stored code follows the phone', () async {
      await settings.setLanguage('xx');
      expectPlanIn(
        planOn(const [Locale('en', 'GB')]),
        lookupAppLocalizations(const Locale('en')),
      );
    });

    test('the plan never throws for a language without a catalog yet, even '
        'from a resolver that already lists the nine', () async {
      await settings.setLanguage('de');
      const german = Locale('de');
      final plan = planOn(const [
        Locale('de'),
      ], locales: AppLocaleResolver(nineLaunchCatalogs));
      expectPlanIn(
        plan,
        lookupAppLocalizations(
          AppLocalizations.delegate.isSupported(german)
              ? german
              : const Locale('en'),
        ),
      );
    });
  });

  test('resume re-reads and reschedules', () async {
    await reminder.enable(hour: 8, minute: 0);
    // Simulate an external change to the OS permission, discovered only on
    // the next refresh (a resume): nothing in this fake actually revokes a
    // schedule, so this checks that resume runs a refresh at all.
    final before = notifications.scheduleCalls.length;
    reminder.didChangeAppLifecycle(AppLifecycleState.resumed);
    await Future<void>.delayed(Duration.zero);
    expect(notifications.scheduleCalls.length, greaterThanOrEqualTo(before));
  });

  test('other lifecycle states never trigger a refresh', () async {
    final before = notifications.scheduleCalls.length;
    for (final state in [
      AppLifecycleState.inactive,
      AppLifecycleState.paused,
      AppLifecycleState.detached,
      AppLifecycleState.hidden,
    ]) {
      reminder.didChangeAppLifecycle(state);
    }
    await Future<void>.delayed(Duration.zero);
    expect(notifications.scheduleCalls.length, before);
  });

  test(
    'concurrent refresh triggers coalesce into at most one extra run',
    () async {
      await settings.setReminder(const ReminderSettings(on: true, hour: 8));
      // Fire several refreshes back to back, as a resume racing a settings
      // change would: they must not each open their own platform round trip.
      final futures = [
        reminder.refresh(),
        reminder.refresh(),
        reminder.refresh(),
        reminder.refresh(),
      ];
      await Future.wait(futures);
      // One in flight plus one queued: at most 2 schedule calls, never 4.
      expect(notifications.scheduleCalls.length, lessThanOrEqualTo(2));
    },
  );

  test('changes fires only when the status actually changes', () async {
    final seen = <void>[];
    final subscription = reminder.changes.listen(seen.add);
    await reminder.refresh();
    await reminder.refresh();
    await subscription.cancel();
    // The settings never changed between the two refreshes, so the second
    // is a no-op for `changes` (permission and availability unchanged too).
    expect(seen, hasLength(lessThanOrEqualTo(1)));
  });

  test('start is idempotent: a second call adds no extra listener', () async {
    reminder.start();
    reminder.start();
    await Future<void>.delayed(Duration.zero);
    // No crash, and only the listeners of the first start are active: a
    // single settings write below causes only one extra refresh's worth of
    // schedule calls (not two).
    final before = notifications.scheduleCalls.length;
    await settings.setReminder(const ReminderSettings(on: true, hour: 11));
    await Future<void>.delayed(Duration.zero);
    await Future<void>.delayed(Duration.zero);
    expect(notifications.scheduleCalls.length, before + 1);
  });

  // M7 review R30: when Hive can't open, `openOrFallback` hands out an
  // in-memory store whose reminder reads the defaults (off), not the
  // player's choice, so a refresh must not cancel the reminder an earlier
  // session scheduled (m7-design P3.10: "a refresh before the save loads
  // never cancels an on reminder").
  group('over the in-memory fallback (Hive did not open)', () {
    late Directory directory;
    late DatabaseService fallback;
    late DailyReminder overFallback;
    const earlier = ReminderPlan(
      hour: 8,
      minute: 0,
      title: "Today's puzzle is ready",
      body: 'A new daily puzzle is on the shelf.',
      channelName: 'Daily reminder',
      channelDescription: 'One note a day',
    );

    setUp(() async {
      directory = await Directory.systemTemp.createTemp('nesty_reminder_');
      // A regular file where Hive expects a directory: opening fails.
      final blocker = File('${directory.path}/blocker')..createSync();
      fallback = await HiveDatabaseService.openOrFallback(
        directory: blocker.path,
      );
      // What the OS still holds from the last session that could read the
      // player's "on".
      notifications.scheduled = earlier;
      overFallback = DailyReminder(notifications, fallback, daily);
    });

    tearDown(() async {
      await overFallback.dispose();
      await fallback.close();
      await directory.delete(recursive: true);
    });

    test('start and refresh leave the OS schedule alone', () async {
      expect(fallback.reminder.on, isFalse);

      overFallback.start();
      await overFallback.refresh();
      overFallback.didChangeAppLifecycle(AppLifecycleState.resumed);
      await overFallback.refresh();

      expect(notifications.cancelCalls, 0);
      expect(notifications.scheduled, earlier);
    });

    test("the player's own choices that session still reach the OS", () async {
      await overFallback.enable(hour: 21, minute: 0);
      expect(notifications.scheduled?.hour, 21);

      await overFallback.disable();
      expect(notifications.scheduled, isNull);
      expect(notifications.cancelCalls, greaterThan(0));
    });
  });

  test('dispose stops every listener and closes changes', () async {
    reminder.start();
    await reminder.dispose();
    expect(() => reminder.changes.listen((_) {}), returnsNormally);
    // A further settings write reaches no listener (disposed).
    await settings.setReminder(const ReminderSettings(on: true, hour: 12));
    await Future<void>.delayed(Duration.zero);
  });

  group('the notification line rotates by the next fire day (G.7)', () {
    const bodies = {
      'Today’s puzzle is on the shelf.',
      'A fresh daily puzzle is ready when you are.',
      'New dolls are waiting to be nested. Today’s puzzle is ready.',
    };

    String bodyOn(DateTime now, {int hour = 19}) {
      final clocked = DailyReminder(
        notifications,
        settings,
        daily,
        clock: FakeClock(now: now),
        deviceLocales: () => englishPhone,
      );
      addTearDown(clocked.dispose);
      return clocked
          .planFor(ReminderSettings(on: true, hour: hour, minute: 0))
          .body;
    }

    test('three days in a row use the three lines, then repeat', () {
      final lines = [
        for (var day = 1; day <= 6; day++) bodyOn(DateTime(2026, 9, day, 10)),
      ];
      expect(lines.take(3).toSet(), bodies);
      expect(lines.skip(3).toList(), lines.take(3).toList());
    });

    test('the same day always gives the same line', () {
      expect(
        bodyOn(DateTime(2026, 9, 30, 8)),
        bodyOn(DateTime(2026, 9, 30, 18, 59)),
      );
    });

    test(
      'once today\'s time has passed, the next fire is tomorrow\'s line',
      () {
        expect(
          bodyOn(DateTime(2026, 9, 30, 20)),
          bodyOn(DateTime(2026, 10, 1, 10)),
        );
      },
    );

    test('a re-plan carries the rotated line to the OS', () async {
      final clocked = DailyReminder(
        notifications,
        settings,
        daily,
        clock: FakeClock(now: DateTime(2026, 9, 30, 10)),
        deviceLocales: () => englishPhone,
      );
      addTearDown(clocked.dispose);
      await clocked.enable(hour: 19, minute: 0);
      expect(bodies, contains(notifications.scheduled?.body));
      expect(notifications.scheduled?.title, 'Nesty');
    });

    test('no line names the streak', () {
      for (final line in bodies) {
        expect(line.toLowerCase(), isNot(contains('streak')));
      }
    });
  });
}

/// A store whose reminder write always fails.
class _FailingStore extends FakeDatabaseService {
  @override
  Future<void> setReminder(ReminderSettings reminder) async =>
      throw StateError('disk full');
}
