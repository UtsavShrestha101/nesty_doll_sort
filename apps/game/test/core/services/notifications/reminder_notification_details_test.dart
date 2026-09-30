import 'dart:ui' show Color;

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_game/core/services/notifications/reminder_notification_details.dart';
import 'package:nesty_game/core/ui/tokens/ui_tokens.gen.dart';
import 'package:timezone/data/latest_10y.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

/// Pure builders, unit-tested without the plugin (m7-design P3.10; reminder
/// lane test plan §3): the notification details, the init settings, the
/// next-occurrence calculator (with DST in `America/New_York`) and the
/// fixed-offset zone fallback.
void main() {
  // Synchronous, and `group` bodies run immediately at declaration time (not
  // deferred like `setUpAll`), so the database must be ready before any
  // `tz.getLocation` call below, including the ones inside a `group`.
  tzdata.initializeTimeZones();

  group('reminderNotificationDetails', () {
    test('Android: no badge, default importance, the stand-in icon', () {
      final details = reminderNotificationDetails(
        channelName: 'Daily reminder',
        channelDescription: 'One note a day',
      );
      final android = details.android!;
      expect(android.channelId, reminderChannelId);
      expect(android.channelName, 'Daily reminder');
      expect(android.channelDescription, 'One note a day');
      expect(android.importance, Importance.defaultImportance);
      expect(android.priority, Priority.defaultPriority);
      expect(android.channelShowBadge, isFalse);
      expect(android.icon, reminderNotificationIcon);
    });

    test('Android: the accent is the notification color #F2893B (R4)', () {
      final android = reminderNotificationDetails(
        channelName: 'Daily reminder',
        channelDescription: 'One note a day',
      ).android!;
      expect(android.color, AppColorTokens.notificationAccent);
      expect(android.color, const Color(0xFFF2893B));
    });

    test('iOS: nothing shown while the app is in the foreground', () {
      final details = reminderNotificationDetails(
        channelName: 'Daily reminder',
        channelDescription: 'One note a day',
      );
      final ios = details.iOS!;
      expect(ios.presentAlert, isFalse);
      expect(ios.presentBanner, isFalse);
      expect(ios.presentList, isFalse);
      expect(ios.presentSound, isFalse);
      expect(ios.presentBadge, isFalse);
    });

    test('iOS: a sound for the background (M7 review R10)', () {
      // FLN 22.3.1 attaches the default sound only when presentSound is
      // true or `sound` is set; an empty name matches no custom file, so iOS
      // plays its default sound in the background (FLN's documented idiom).
      final ios = reminderNotificationDetails(
        channelName: 'Daily reminder',
        channelDescription: 'One note a day',
      ).iOS!;
      expect(ios.sound, '');
    });
  });

  test('reminderInitializationSettings never asks for the permission', () {
    final settings = reminderInitializationSettings();
    expect(settings.android!.defaultIcon, reminderNotificationIcon);
    final ios = settings.iOS!;
    expect(ios.requestAlertPermission, isFalse);
    expect(ios.requestBadgePermission, isFalse);
    expect(ios.requestSoundPermission, isFalse);
  });

  group('nextDailyOccurrence', () {
    final utc = tz.getLocation('Etc/UTC');

    test('today, when the time is still ahead', () {
      final now = tz.TZDateTime(utc, 2026, 6, 1, 10, 0);
      final next = nextDailyOccurrence(now, hour: 19, minute: 0);
      expect(next, tz.TZDateTime(utc, 2026, 6, 1, 19, 0));
    });

    test('tomorrow, once the time has passed', () {
      final now = tz.TZDateTime(utc, 2026, 6, 1, 20, 0);
      final next = nextDailyOccurrence(now, hour: 19, minute: 0);
      expect(next, tz.TZDateTime(utc, 2026, 6, 2, 19, 0));
    });

    test('exactly at the target time counts as passed (a future instant)', () {
      final now = tz.TZDateTime(utc, 2026, 6, 1, 19, 0);
      final next = nextDailyOccurrence(now, hour: 19, minute: 0);
      expect(next, tz.TZDateTime(utc, 2026, 6, 2, 19, 0));
    });

    test('rolls over a month/year boundary', () {
      final now = tz.TZDateTime(utc, 2025, 12, 31, 20, 0);
      final next = nextDailyOccurrence(now, hour: 19, minute: 0);
      expect(next, tz.TZDateTime(utc, 2026, 1, 1, 19, 0));
    });

    group('DST in America/New_York', () {
      final newYork = tz.getLocation('America/New_York');

      test('spring forward (2026-03-08, 2 AM -> 3 AM EDT)', () {
        // The evening before, past 7 PM EST (UTC-5): the next occurrence is
        // the transition day's own 7 PM, now EDT (UTC-4) — built fresh from
        // that day's calendar components, not by adding a fixed 24 h.
        final now = tz.TZDateTime(newYork, 2026, 3, 7, 20, 0);
        final next = nextDailyOccurrence(now, hour: 19, minute: 0);
        expect(next.year, 2026);
        expect(next.month, 3);
        expect(next.day, 8);
        expect(next.hour, 19);
        expect(next.minute, 0);
        expect(next.timeZoneOffset, const Duration(hours: -4)); // EDT
        // 23 wall-clock hours apart (20:00 -> next day's 19:00), but the
        // spring-forward skips one real hour, so only 22 physically pass.
        expect(next.difference(now), const Duration(hours: 22));
      });

      test('fall back (2026-11-01, 2 AM -> 1 AM EST)', () {
        final now = tz.TZDateTime(newYork, 2026, 10, 31, 20, 0);
        final next = nextDailyOccurrence(now, hour: 19, minute: 0);
        expect(next.year, 2026);
        expect(next.month, 11);
        expect(next.day, 1);
        expect(next.hour, 19);
        expect(next.minute, 0);
        expect(next.timeZoneOffset, const Duration(hours: -5)); // EST
        // 23 wall-clock hours apart, but the fall-back repeats one real
        // hour, so 24 physically pass.
        expect(next.difference(now), const Duration(hours: 24));
      });

      test('a request made during the transition day itself still lands '
          'today, at the new offset', () {
        // 6 AM on the spring-forward day is already EDT (the jump was at
        // 2 AM), and 7 PM hasn't happened yet.
        final now = tz.TZDateTime(newYork, 2026, 3, 8, 6, 0);
        final next = nextDailyOccurrence(now, hour: 19, minute: 0);
        expect((next.year, next.month, next.day), (2026, 3, 8));
        expect(next.timeZoneOffset, const Duration(hours: -4));
      });
    });

    // M7 review R34: a time inside a spring-forward gap doesn't exist that
    // day, and the zone normalises it to the hour after (02:30 -> 03:30).
    // The platform takes the repeating time of day from the date it is
    // sent, so the gap day is skipped and the chosen time kept.
    group('a time inside the spring-forward gap', () {
      final newYork = tz.getLocation('America/New_York');
      final berlin = tz.getLocation('Europe/Berlin');

      void expectAt(tz.TZDateTime next, (int, int, int, int, int) expected) {
        expect((
          next.year,
          next.month,
          next.day,
          next.hour,
          next.minute,
        ), expected);
      }

      test('the evening before the gap day skips it', () {
        final now = tz.TZDateTime(newYork, 2026, 3, 7, 20, 0);
        final next = nextDailyOccurrence(now, hour: 2, minute: 30);
        expectAt(next, (2026, 3, 9, 2, 30));
        expect(next.timeZoneOffset, const Duration(hours: -4));
      });

      test('the gap day itself, before 2 AM, skips it too', () {
        final now = tz.TZDateTime(newYork, 2026, 3, 8, 1, 0);
        final next = nextDailyOccurrence(now, hour: 2, minute: 30);
        expectAt(next, (2026, 3, 9, 2, 30));
      });

      test('Europe/Berlin (2026-03-29, 2 AM -> 3 AM CEST)', () {
        final now = tz.TZDateTime(berlin, 2026, 3, 28, 20, 0);
        final next = nextDailyOccurrence(now, hour: 2, minute: 0);
        expectAt(next, (2026, 3, 30, 2, 0));
      });

      test('a time just outside the gap is kept on the gap day', () {
        final now = tz.TZDateTime(newYork, 2026, 3, 7, 20, 0);
        final next = nextDailyOccurrence(now, hour: 3, minute: 0);
        expectAt(next, (2026, 3, 8, 3, 0));
      });

      test('the fall-back overlap (01:30 happens twice) is kept', () {
        final now = tz.TZDateTime(newYork, 2026, 10, 31, 20, 0);
        final next = nextDailyOccurrence(now, hour: 1, minute: 30);
        expectAt(next, (2026, 11, 1, 1, 30));
      });
    });
  });

  group('fixedOffsetLocation', () {
    test('a positive offset', () {
      final location = fixedOffsetLocation(
        const Duration(hours: 5, minutes: 30),
      );
      expect(
        location.currentTimeZone.offset,
        const Duration(hours: 5, minutes: 30),
      );
      expect(location.currentTimeZone.isDst, isFalse);
    });

    test('a negative offset', () {
      final location = fixedOffsetLocation(const Duration(hours: -8));
      expect(location.currentTimeZone.offset, const Duration(hours: -8));
    });

    test('zero offset', () {
      final location = fixedOffsetLocation(Duration.zero);
      expect(location.currentTimeZone.offset, Duration.zero);
    });

    // M7 review R9: the name is what FLN sends as `timeZoneName`, and
    // Android's `ZoneId.of` throws on a name it doesn't know.
    test('is named GMT±HH:MM, which java.time.ZoneId and NSTimeZone parse', () {
      expect(
        fixedOffsetLocation(const Duration(hours: 5, minutes: 45)).name,
        'GMT+05:45',
      );
      expect(fixedOffsetLocation(const Duration(hours: -8)).name, 'GMT-08:00');
      expect(
        fixedOffsetLocation(const Duration(hours: -9, minutes: -30)).name,
        'GMT-09:30',
      );
      expect(fixedOffsetLocation(Duration.zero).name, 'GMT+00:00');
    });

    test("takes the device's own zone id as its name when there is one", () {
      final location = fixedOffsetLocation(
        const Duration(hours: 2),
        deviceZoneId: 'Europe/Amsterdam',
      );
      expect(location.name, 'Europe/Amsterdam');
      expect(location.currentTimeZone.offset, const Duration(hours: 2));
      expect(
        fixedOffsetLocation(const Duration(hours: 2), deviceZoneId: '').name,
        'GMT+02:00',
      );
    });

    test('a fixed-offset location still resolves the next occurrence', () {
      final location = fixedOffsetLocation(const Duration(hours: 2));
      final now = tz.TZDateTime(location, 2026, 6, 1, 20, 0);
      final next = nextDailyOccurrence(now, hour: 19, minute: 0);
      expect(next, tz.TZDateTime(location, 2026, 6, 2, 19, 0));
    });
  });

  // The skip memo's zone (m7-design P3.10 "skips a call identical to the
  // last (plan, zone) of this process"). A fallback named after the device's
  // id keeps its name across a DST change, so the offset is part of it.
  group('reminderZoneKey', () {
    test('the same name at another offset is another zone', () {
      final winter = fixedOffsetLocation(
        const Duration(hours: 1),
        deviceZoneId: 'Europe/Amsterdam',
      );
      final summer = fixedOffsetLocation(
        const Duration(hours: 2),
        deviceZoneId: 'Europe/Amsterdam',
      );
      expect(reminderZoneKey(winter), isNot(reminderZoneKey(summer)));
    });

    test('the same location is the same zone', () {
      final newYork = tz.getLocation('America/New_York');
      expect(reminderZoneKey(newYork), reminderZoneKey(newYork));
    });
  });
}
