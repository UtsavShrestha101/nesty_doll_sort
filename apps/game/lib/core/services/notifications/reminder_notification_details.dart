import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:nesty_game/core/ui/tokens/ui_tokens.gen.dart';
import 'package:timezone/timezone.dart' as tz;

/// Pure builders for the daily reminder's one notification (E4, spec-prop
/// §7.9; docs/plans/m7-design.md P3.10), kept free of the plugin's platform
/// channel so every one of them is unit-tested without it.

/// The Android notification channel id: a platform contract with the phone's
/// own per-channel settings, so never rename or reuse it.
const String reminderChannelId = 'daily_reminder';

/// The small icon Android shows, a resource name (`android:` init settings
/// and `AndroidNotificationDetails.icon` both take it as a string, so R8's
/// resource shrinker can't see the reference — `res/raw/keep.xml` keeps it).
/// Claude Design's `ui/notification/ic_notification.svg`, converted by
/// `sync_design_assets` into `res/drawable/ic_notification.xml` (m7-3).
const String reminderNotificationIcon = 'ic_notification';

/// The one notification's platform details, in [channelName]/
/// [channelDescription] (the player's language, from `ReminderPlan`): no
/// badge on either platform, default importance on Android (no heads-up),
/// nothing shown at all on iOS while the app is in the foreground
/// (`DailyReminder`'s doc: the OS shows the alert and the sound only in the
/// background).
NotificationDetails reminderNotificationDetails({
  required String channelName,
  required String channelDescription,
}) => NotificationDetails(
  android: AndroidNotificationDetails(
    reminderChannelId,
    channelName,
    channelDescription: channelDescription,
    importance: Importance.defaultImportance,
    priority: Priority.defaultPriority,
    channelShowBadge: false,
    icon: reminderNotificationIcon,
    color: AppColorTokens.notificationAccent, // #F2893B (R4, frame 10.2g).
  ),
  iOS: const DarwinNotificationDetails(
    presentAlert: false,
    presentBanner: false,
    presentList: false,
    presentSound: false,
    presentBadge: false,
    // FLN 22.3.1 attaches the default sound only when `presentSound` is true
    // or a `sound` is named, so without one the reminder would be silent in
    // the background too (M7 review R10). An empty name matches no custom
    // file, so iOS plays its default sound (FLN's documented idiom), while
    // the foreground still reads `presentSound: false` and shows nothing.
    sound: '',
  ),
);

/// The plugin's init settings: every Darwin request flag is false and
/// Android shows no prompt at `initialize` either way, so
/// `NotificationService.requestPermission` is the only place that can ever
/// ask (spec-prop §7.9: only after the player's own Yes).
InitializationSettings reminderInitializationSettings() =>
    const InitializationSettings(
      android: AndroidInitializationSettings(reminderNotificationIcon),
      iOS: DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      ),
    );

/// The next local instant [hour]:[minute] fires after [now], in [now]'s own
/// zone: today if that time hasn't passed yet, else tomorrow, skipping a day
/// on which [hour]:[minute] doesn't exist.
///
/// Each candidate is built straight from calendar components
/// (`TZDateTime(location, year, month, day, hour, minute)`), never from
/// `now.add(const Duration(days: 1))`: the latter is a fixed physical
/// duration and would land on the wrong wall-clock hour across a DST
/// transition (for example 7 PM America/New_York the day of a fall-back
/// would land on 6 PM UTC-equivalent). Building from components instead asks
/// the zone anew for each day's own offset, which is what
/// `DateTimeComponents.time`'s own daily repeat relies on too.
///
/// A time inside a spring-forward gap (02:30 on 2026-03-08 in
/// America/New_York) is normalised by the zone to the hour after (03:30),
/// and both platforms take the repeating time of day from the date they are
/// sent, so such a day is skipped: the platform always gets the chosen time
/// (M7 review R34). The fall-back overlap keeps its first 01:30.
tz.TZDateTime nextDailyOccurrence(
  tz.TZDateTime now, {
  required int hour,
  required int minute,
}) {
  tz.TZDateTime? firstAfterNow;
  // Two gap days in a row don't happen; a week is only a bound.
  for (var days = 0; days < 7; days++) {
    final candidate = tz.TZDateTime(
      now.location,
      now.year,
      now.month,
      now.day + days,
      hour,
      minute,
    );
    if (!candidate.isAfter(now)) continue;
    if (candidate.hour == hour && candidate.minute == minute) return candidate;
    firstAfterNow ??= candidate;
  }
  return firstAfterNow ??
      tz.TZDateTime(
        now.location,
        now.year,
        now.month,
        now.day + 1,
        hour,
        minute,
      );
}

/// A fixed-offset [tz.Location] for a device whose IANA zone id
/// (`FlutterTimezone.getLocalTimezone()`) the bundled `timezone` database
/// doesn't recognise, or whose id couldn't be read (m7-design P3.10 "an
/// unknown id falls back to a fixed location at the device's current offset,
/// re-synced on resume").
///
/// Its name is what FLN sends the platform as `timeZoneName`, and Android's
/// side calls `ZoneId.of(timeZoneName)`, which throws on a name it doesn't
/// know (M7 review R9). So it is [deviceZoneId] when the device gave one
/// (the platform that reported it resolves it, with that zone's own DST
/// rules, so the reminder keeps the chosen local time there; `latest_10y`
/// lacks IANA's backward links such as `Europe/Amsterdam`), else
/// `GMT±HH:MM`, which `java.time.ZoneId` and `NSTimeZone` both parse. The
/// Dart side only uses the fixed [offset] to pick the first day.
tz.Location fixedOffsetLocation(Duration offset, {String? deviceZoneId}) {
  final totalMinutes = offset.inMinutes;
  final sign = totalMinutes < 0 ? '-' : '+';
  final absMinutes = totalMinutes.abs();
  final hh = (absMinutes ~/ 60).toString().padLeft(2, '0');
  final mm = (absMinutes % 60).toString().padLeft(2, '0');
  final gmt = 'GMT$sign$hh:$mm';
  final name = deviceZoneId != null && deviceZoneId.isNotEmpty
      ? deviceZoneId
      : gmt;
  return tz.Location(name, <int>[tz.minTime], <int>[0], <tz.TimeZone>[
    tz.TimeZone(offset, isDst: false, abbreviation: gmt),
  ]);
}

/// The zone half of `LocalNotificationService`'s "skip a call identical to
/// the last (plan, zone)" memo: [location]'s name and its current UTC
/// offset. A fallback named after the device's id keeps its name across a
/// DST change, so the offset makes the next refresh after one reschedule;
/// that also repairs a 02:xx reminder the platform's own repeat moved to
/// 03:xx across a spring-forward.
String reminderZoneKey(tz.Location location) =>
    '${location.name}@${location.currentTimeZone.offset.inMinutes}';
