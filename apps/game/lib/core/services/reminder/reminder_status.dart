import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:nesty_game/core/models/reminder_settings.dart';
import 'package:nesty_game/core/services/notifications/notification_service.dart';

part 'reminder_status.freezed.dart';

/// How `DailyReminder.enable` ended (m7-design P3.10).
enum ReminderEnableResult {
  /// The OS allowed notifications; the reminder is on and scheduled (a
  /// scheduling failure is retried at the next refresh, silently).
  enabled,

  /// The OS said no, or couldn't say: nothing is scheduled and the
  /// reminder stays off, with the chosen time kept.
  denied,
}

/// What the Settings rows and the offer read about the reminder (E4;
/// m7-design P3.10): the stored settings, the OS permission as last read,
/// and whether the daily itself is unlocked.
@freezed
abstract class ReminderStatus with _$ReminderStatus {
  const factory ReminderStatus({
    @Default(ReminderSettings()) ReminderSettings settings,
    @Default(NotificationPermission.unknown) NotificationPermission permission,

    /// The daily is unlocked (`DailyService.isUnlocked`, Level 2 won):
    /// before that Settings hides the reminder rows (default, an owner
    /// question).
    @Default(false) bool available,
  }) = _ReminderStatus;

  const ReminderStatus._();

  /// On, but the OS blocks notifications (revoked after the player turned
  /// it on): Settings keeps the row on with `settingReminderBlocked`
  /// under it, and the schedule stays, so turning notifications back on in
  /// the OS resumes it.
  bool get blocked =>
      settings.on && permission == NotificationPermission.denied;
}
