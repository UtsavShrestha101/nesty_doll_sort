import 'package:freezed_annotation/freezed_annotation.dart';

part 'reminder_plan.freezed.dart';

/// What the one daily reminder shows and when (E4; spec-prop §7.9;
/// docs/plans/m7-design.md P3.10): built by `DailyReminder.planFor` from
/// the settings and the ARB copy in the player's language, handed to
/// `NotificationService.scheduleDaily`.
@freezed
abstract class ReminderPlan with _$ReminderPlan {
  const factory ReminderPlan({
    /// The local time of day it fires, every day (0–23, 0–59).
    required int hour,
    required int minute,

    /// `reminderNotificationTitle`: "Today's puzzle is ready" (spec-prop
    /// §7.9's words). The same warm text every day; it never names the
    /// streak.
    required String title,

    /// `reminderNotificationBody`.
    required String body,

    /// Android's notification channel, as the system settings list it
    /// (`reminderChannelName`, `reminderChannelDescription`).
    required String channelName,
    required String channelDescription,
  }) = _ReminderPlan;
}
