import 'package:nesty_game/core/services/notifications/reminder_plan.dart';

export 'package:nesty_game/core/services/notifications/reminder_plan.dart';

/// The OS notification permission, as far as the app can read it without
/// asking (m7-design P3.10).
enum NotificationPermission {
  /// Notifications may show.
  granted,

  /// The player (or the OS) turned them off for the app.
  denied,

  /// Not asked yet, or the platform can't say.
  unknown,
}

/// Local notifications for the opt-in daily reminder (E4; spec-prop §7.9,
/// §1.1 rule 7: local, opt-in, value-framed, at most one a day;
/// docs/plans/m7-design.md P3.10). No network is involved (rule 3).
///
/// Implementations: `LocalNotificationService` (real env, over
/// `flutter_local_notifications` with `timezone` and `flutter_timezone`)
/// and `FakeNotificationService` (fake env and tests: records the plan and
/// answers a set permission). `DailyReminder` is the only caller.
///
/// Every method never throws: a platform failure is logged under
/// `nesty.notifications` and reads as a false, `unknown` or no-op result.
abstract interface class NotificationService {
  /// Sets the plugin up. Idempotent, and it never asks for the permission
  /// (iOS `requestAlertPermission: false` and the rest; Android shows no
  /// prompt at init).
  Future<void> initialize();

  /// The permission as it stands, without a prompt.
  Future<NotificationPermission> permission();

  /// The OS prompt when the permission is undecided (Android 13+
  /// `POST_NOTIFICATIONS`, iOS's alert), else the stored answer. Called
  /// only after the player's own Yes (spec-prop §7.9).
  Future<NotificationPermission> requestPermission();

  /// Schedules the one repeating daily reminder at [plan]'s local time,
  /// replacing any earlier one (one id, [reminderId]): inexact, so no
  /// exact-alarm permission. False when it couldn't be scheduled.
  Future<bool> scheduleDaily(ReminderPlan plan);

  /// Cancels the daily reminder (nothing scheduled is fine).
  Future<void> cancelDaily();

  /// Whether the daily reminder is pending with the OS (diagnostics and
  /// the Android device check).
  Future<bool> hasPendingDaily();
}

/// The daily reminder's notification id: a platform contract with the
/// devices that scheduled it, so never reuse or change it.
const int reminderId = 1;
