import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:injectable/injectable.dart';
import 'package:nesty_game/core/dependency_injection/app_env.dart';
import 'package:nesty_game/core/services/notifications/notification_service.dart';
import 'package:nesty_game/core/services/notifications/reminder_notification_details.dart';
import 'package:timezone/data/latest_10y.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

/// The real [NotificationService] (m7-design P3.10): local notifications
/// through `flutter_local_notifications`, scheduled in the device's IANA
/// zone (`timezone` data `latest_10y`, the zone from `flutter_timezone`),
/// one repeating inexact daily reminder with id [reminderId],
/// `AndroidScheduleMode.inexactAllowWhileIdle` and
/// `DateTimeComponents.time`; no badge, nothing shown while the app is open
/// (iOS), default importance (Android, no heads-up).
///
/// Its constructor touches no plugin (`FlutterLocalNotificationsPlugin()` is
/// only a facade over the platform channel; nothing crosses it until a
/// method is called), so the real env resolves it in `di_test` and a bare
/// unit test can build it. [plugin] lets a test hand it a double whose
/// platform-specific implementation throws, to prove every method below
/// still keeps its "never throws" promise (rule 3).
///
/// Every method catches everything and logs under `nesty.notifications`; a
/// failure reads as `false`, `unknown` or a no-op, never an exception.
@LazySingleton(as: NotificationService, env: [AppEnv.real])
class LocalNotificationService implements NotificationService {
  LocalNotificationService({
    @ignoreParam FlutterLocalNotificationsPlugin? plugin,
  }) : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;
  bool _initialized = false;

  /// The last (plan, zone) [scheduleDaily] actually sent to the plugin, so a
  /// `refresh` that changed nothing skips a second platform call (m7-design
  /// P3.10 "skips a call identical to the last (plan, zone) of this
  /// process"). The zone is [reminderZoneKey]: its name and current offset.
  ({ReminderPlan plan, String zone})? _lastScheduled;

  @override
  Future<void> initialize() async {
    if (_initialized) return;
    try {
      tzdata.initializeTimeZones();
      await _syncTimeZone();
      await _plugin.initialize(settings: reminderInitializationSettings());
      _initialized = true;
    } on Object catch (error, stack) {
      _log('initialize failed', error, stack);
    }
  }

  /// Reads the device's IANA zone and makes it `tz.local`; an unrecognised
  /// id (or a failed platform read) falls back to a fixed offset at the
  /// device's current UTC offset (m7-design P3.10), named so the platform
  /// can resolve it ([fixedOffsetLocation]). Called again by
  /// [scheduleDaily], so a resume or a settings change re-syncs it (a time
  /// zone change is picked up at the next launch or resume, per the design's
  /// documented limit).
  Future<void> _syncTimeZone() async {
    String? deviceZoneId;
    try {
      final info = await FlutterTimezone.getLocalTimezone();
      deviceZoneId = info.identifier;
      try {
        tz.setLocalLocation(tz.getLocation(info.identifier));
        return;
      } on tz.LocationNotFoundException catch (error, stack) {
        _log('unrecognised time zone ${info.identifier}', error, stack);
      }
    } on Object catch (error, stack) {
      _log('reading the device time zone failed', error, stack);
    }
    tz.setLocalLocation(
      fixedOffsetLocation(
        DateTime.now().timeZoneOffset,
        deviceZoneId: deviceZoneId,
      ),
    );
  }

  @override
  Future<NotificationPermission> permission() async {
    try {
      if (defaultTargetPlatform == TargetPlatform.android) {
        final android = _plugin
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >();
        return _fromBool(await android?.areNotificationsEnabled());
      }
      if (defaultTargetPlatform == TargetPlatform.iOS) {
        final ios = _plugin
            .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin
            >();
        final options = await ios?.checkPermissions();
        return _fromBool(options?.isEnabled);
      }
      return NotificationPermission.unknown;
    } on Object catch (error, stack) {
      _log('permission read failed', error, stack);
      return NotificationPermission.unknown;
    }
  }

  @override
  Future<NotificationPermission> requestPermission() async {
    try {
      await initialize();
      if (defaultTargetPlatform == TargetPlatform.android) {
        final android = _plugin
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >();
        return _fromBool(await android?.requestNotificationsPermission());
      }
      if (defaultTargetPlatform == TargetPlatform.iOS) {
        final ios = _plugin
            .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin
            >();
        return _fromBool(
          await ios?.requestPermissions(alert: true, badge: false, sound: true),
        );
      }
      return NotificationPermission.unknown;
    } on Object catch (error, stack) {
      _log('requestPermission failed', error, stack);
      return NotificationPermission.unknown;
    }
  }

  @override
  Future<bool> scheduleDaily(ReminderPlan plan) async {
    try {
      await initialize();
      await _syncTimeZone();
      final zone = reminderZoneKey(tz.local);
      final last = _lastScheduled;
      if (last != null && last.plan == plan && last.zone == zone) {
        return true;
      }
      final scheduledDate = nextDailyOccurrence(
        tz.TZDateTime.now(tz.local),
        hour: plan.hour,
        minute: plan.minute,
      );
      await _plugin.zonedSchedule(
        id: reminderId,
        title: plan.title,
        body: plan.body,
        scheduledDate: scheduledDate,
        notificationDetails: reminderNotificationDetails(
          channelName: plan.channelName,
          channelDescription: plan.channelDescription,
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
      );
      _lastScheduled = (plan: plan, zone: zone);
      return true;
    } on Object catch (error, stack) {
      _log('scheduleDaily failed', error, stack);
      return false;
    }
  }

  @override
  Future<void> cancelDaily() async {
    try {
      await _plugin.cancel(id: reminderId);
    } on Object catch (error, stack) {
      _log('cancelDaily failed', error, stack);
    } finally {
      // However the platform call went, the app must not think it has a
      // schedule pending: the next `on` reschedules for real.
      _lastScheduled = null;
    }
  }

  @override
  Future<bool> hasPendingDaily() async {
    try {
      final pending = await _plugin.pendingNotificationRequests();
      return pending.any((request) => request.id == reminderId);
    } on Object catch (error, stack) {
      _log('hasPendingDaily failed', error, stack);
      return false;
    }
  }

  static NotificationPermission _fromBool(bool? value) => switch (value) {
    true => NotificationPermission.granted,
    false => NotificationPermission.denied,
    null => NotificationPermission.unknown,
  };

  static void _log(String message, Object error, StackTrace? stack) {
    developer.log(
      message,
      name: 'nesty.notifications',
      error: error,
      stackTrace: stack,
    );
    // developer.log never reaches the `flutter run` terminal.
    if (kDebugMode) debugPrint('[nesty.notifications] $message: $error');
  }
}
