import 'dart:io';
import 'dart:ui' show Locale;

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
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
import 'package:nesty_game/core/services/notifications/reminder_notification_details.dart';
import 'package:nesty_game/core/services/reminder/daily_reminder.dart';
import 'package:nesty_game/core/services/save/save_document.dart';
import 'package:nesty_game/features/daily/cubit/reminder_offer_cubit.dart';
import 'package:nesty_game/l10n/app_localizations.dart';

import '../l10n/locales/locales.dart';
import '../l10n/support/arb_file.dart';

/// E1, the respect rules for the daily reminder (E4; spec-prop §7.9 "local,
/// opt-in, off until the player accepts, at most one a day, never naming
/// the streak", §1.1 rule 7; docs/plans/m7-design.md P3.12): off on a fresh
/// install with nothing scheduled or asked; the OS permission only after
/// the player's Yes; one notification id; no badge; the same text whatever
/// the streak. Run from `apps/game`.
void main() {
  // `DailyReminder.start` follows the app lifecycle through the binding.
  TestWidgetsFlutterBinding.ensureInitialized();

  late FakeDatabaseService settings;
  late FakeNotificationService notifications;
  late FakeClock clock;
  late FakeDailyService daily;
  late DailyReminder reminder;

  final today = LocalDate(2026, 9, 29);

  DailyStatus solved({int streak = 1, bool lit = true}) => DailyStatus(
    today: today,
    tier: Tier.medium,
    colors: 5,
    unlocked: true,
    streak: streak,
    lit: lit,
    solvedToday: true,
    solve: DailySolve(date: today, moves: 18, families: 5, minuteOfDay: 1150),
  );

  setUp(() {
    settings = FakeDatabaseService();
    notifications = FakeNotificationService();
    clock = FakeClock(now: DateTime(2026, 9, 29, 19, 10));
    daily = FakeDailyService(clock);
    reminder = DailyReminder(notifications, settings, daily);
  });

  tearDown(() async {
    await reminder.dispose();
    await settings.close();
  });

  ReminderOfferCubit offer() {
    final cubit = ReminderOfferCubit(reminder, settings, daily, clock);
    addTearDown(cubit.close);
    return cubit;
  }

  group('a fresh install', () {
    test('the reminder is off, never offered, at 19:00', () {
      expect(settings.reminder, const ReminderSettings());
      expect(settings.reminder.on, isFalse);
      expect(settings.reminder.offered, isFalse);
      expect((settings.reminder.hour, settings.reminder.minute), (19, 0));
    });

    test('the launch sync schedules nothing and asks nothing', () async {
      reminder.start();
      await reminder.refresh();
      expect(notifications.requestCount, 0);
      expect(notifications.scheduleCalls, isEmpty);
      expect(await notifications.hasPendingDaily(), isFalse);
      expect(reminder.status.settings.on, isFalse);
    });

    test('an unsolved daily shows no offer and asks nothing', () async {
      final cubit = offer();
      await cubit.load();
      expect(cubit.state.data?.step, ReminderOfferStep.hidden);
      expect(settings.reminder.offered, isFalse);
      expect(notifications.requestCount, 0);
    });
  });

  group('the permission is asked only after Yes', () {
    test('the offer appearing asks nothing; No thanks asks nothing, stays '
        'off and never offers again', () async {
      daily.status = solved();
      final cubit = offer();
      await cubit.load();
      expect(cubit.state.data?.step, ReminderOfferStep.ask);
      expect(notifications.requestCount, 0);

      await cubit.decline();
      expect(cubit.state.data?.step, ReminderOfferStep.hidden);
      expect(notifications.requestCount, 0);
      expect(notifications.scheduleCalls, isEmpty);
      expect(settings.reminder.on, isFalse);
      expect(settings.reminder.offered, isTrue);

      final again = offer();
      await again.load();
      expect(again.state.data?.step, ReminderOfferStep.hidden);
      expect(notifications.requestCount, 0);
    });

    test('Yes asks once, then schedules one reminder', () async {
      daily.status = solved();
      final cubit = offer();
      await cubit.load();
      await cubit.accept();
      expect(cubit.state.data?.step, ReminderOfferStep.enabled);
      expect(notifications.requestCount, 1);
      expect(await notifications.hasPendingDaily(), isTrue);
      expect(settings.reminder.on, isTrue);
    });

    test('a denied Yes stays on and blocked, and never asks the OS twice '
        '(D190, supersedes D160)', () async {
      // The player said Yes; the OS said no. G.7's denied body promises
      // "your note will arrive at {time}" once notifications are allowed,
      // so the reminder keeps the player's choice, shows as blocked (the
      // Settings row's "Open phone settings", 10.2f) and is still planned:
      // nothing is delivered while the OS blocks it.
      notifications.permissionAnswer = NotificationPermission.denied;
      daily.status = solved();
      final cubit = offer();
      await cubit.load();
      await cubit.accept();
      expect(cubit.state.data?.step, ReminderOfferStep.denied);
      expect(notifications.requestCount, 1);
      expect(settings.reminder.on, isTrue);
      expect(reminder.status.blocked, isTrue);
      expect(await notifications.hasPendingDaily(), isTrue);
      // A refresh (launch, resume) re-plans without a second OS ask.
      await reminder.refresh();
      expect(notifications.requestCount, 1);
      expect(reminder.status.blocked, isTrue);
    });

    test('in the code, only DailyReminder.enable asks the OS', () {
      // Every call of `requestPermission(` outside the notification
      // services themselves (the interface and its two implementations).
      final calls = <String>[];
      for (final entity in Directory('lib').listSync(recursive: true)) {
        if (entity is! File || !entity.path.endsWith('.dart')) continue;
        if (entity.path.contains('core/services/notifications/')) continue;
        final lines = entity.readAsLinesSync();
        for (var i = 0; i < lines.length; i++) {
          final code = lines[i].split('//').first;
          if (code.contains('requestPermission(')) {
            calls.add('${entity.path}:${i + 1}');
          }
        }
      }
      expect(calls, hasLength(1), reason: calls.join('\n'));
      expect(calls.single, contains('core/services/reminder/daily_reminder'));
      // And `enable`'s callers are the player's own Yes: the offer's
      // accept and Settings' toggle.
      final enableCallers = <String>{};
      for (final entity in Directory('lib').listSync(recursive: true)) {
        if (entity is! File || !entity.path.endsWith('.dart')) continue;
        if (entity.path.endsWith('daily_reminder.dart')) continue;
        final source = entity.readAsStringSync();
        if (RegExp(r'\.enable\(\s*hour:').hasMatch(source)) {
          enableCallers.add(entity.path.split('/').last);
        }
      }
      expect(enableCallers, {
        'reminder_offer_cubit.dart',
        'settings_cubit.dart',
      });
    });
  });

  group('one notification id', () {
    test(
      'turning it on, re-timing and re-syncing keep one pending plan',
      () async {
        await reminder.enable(hour: 19, minute: 0);
        await reminder.setTime(hour: 8, minute: 30);
        await settings.setLanguage('fr');
        await reminder.refresh();
        await reminder.refresh();
        expect(await notifications.hasPendingDaily(), isTrue);
        expect(notifications.scheduled!.hour, 8);
        expect(notifications.scheduled!.minute, 30);
        await reminder.disable();
        expect(await notifications.hasPendingDaily(), isFalse);
      },
    );

    test('the real service schedules, cancels and reads only reminderId', () {
      expect(reminderId, 1);
      final source = File(
        'lib/core/services/notifications/local_notification_service.dart',
      ).readAsStringSync();
      final ids = RegExp(r'\bid:\s*([A-Za-z0-9_]+)').allMatches(source);
      expect(ids, isNotEmpty);
      expect(ids.map((match) => match.group(1)).toSet(), {'reminderId'});
      // No other kind of notification: no immediate show, no periodic one.
      expect(source, isNot(contains('.show(')));
      expect(source, isNot(contains('periodicallyShow')));
    });
  });

  test('no badge on either platform, and none ever asked for', () {
    final details = reminderNotificationDetails(
      channelName: 'Daily reminder',
      channelDescription: 'One note a day',
    );
    expect(details.android!.channelShowBadge, isFalse);
    expect(details.iOS!.presentBadge, isFalse);
    final init = reminderInitializationSettings();
    expect(init.iOS!.requestBadgePermission, isFalse);
    expect(init.iOS!.requestAlertPermission, isFalse);
    expect(init.iOS!.requestSoundPermission, isFalse);
    final source = File(
      'lib/core/services/notifications/local_notification_service.dart',
    ).readAsStringSync();
    expect(source, contains('badge: false'));
    expect(source, isNot(contains('badge: true')));
    expect(details.android!.importance, Importance.defaultImportance);
  });

  test('the notification text is the same whatever the streak, a paused '
      'one included, and never names it', () async {
    final plans = <(String, String)>[];
    for (final status in [
      solved(streak: 0, lit: false),
      solved(streak: 12),
      solved(streak: 12, lit: false),
    ]) {
      daily.status = status;
      await reminder.enable(hour: 19, minute: 0);
      final plan = notifications.scheduled!;
      plans.add((plan.title, plan.body));
    }
    expect(plans.toSet(), hasLength(1));
    final (title, body) = plans.first;
    for (final text in [title, body]) {
      expect(text.toLowerCase(), isNot(contains('streak')));
      expect(text, isNot(contains('12')));
    }
  });

  /// Phase 5B (build/m7-p5/p5/l10n.md §3.2 item 5, §7.1): in every language
  /// the game ships, the scheduled plan is that language's own lines (the
  /// stored language picks them, as the app's own setting does), and none
  /// of them names the streak in that language's words
  /// (`LocaleRules.streakWords`). A catalog gen-l10n hasn't turned into
  /// code yet is skipped with its reason.
  group('in every language the game ships', () {
    for (final file in readArbFiles()) {
      final parts = file.code.split('_');
      final locale = Locale(parts.first, parts.length > 1 ? parts[1] : null);
      final generated = AppLocalizations.delegate.isSupported(locale);

      test(
        '${file.code}: the plan reads its own lines and never names the '
        'streak',
        () async {
          await settings.setLanguage(file.code);
          daily.status = solved(streak: 12);
          await reminder.enable(hour: 19, minute: 0);
          final plan = notifications.scheduled!;
          final l10n = lookupAppLocalizations(locale);
          expect(plan.title, l10n.reminderNotificationTitle);
          expect([
            l10n.reminderNotificationBody,
            l10n.reminderNotificationBody2,
            l10n.reminderNotificationBody3,
          ], contains(plan.body));
          expect(plan.channelName, l10n.reminderChannelName);
          expect(plan.channelDescription, l10n.reminderChannelDescription);
          final rules = rulesFor(file.code)!;
          for (final text in [
            plan.title,
            plan.body,
            plan.channelName,
            plan.channelDescription,
          ]) {
            expect(rules.offences(rules.streakWords, text), isEmpty);
            expect(text, isNot(contains('12')));
          }
        },
        skip: generated
            ? false
            : 'app_${file.code}.arb has no generated code yet (gen-l10n)',
      );
    }
  });
}
