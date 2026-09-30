import 'package:freezed_annotation/freezed_annotation.dart';

part 'reminder_settings.freezed.dart';

/// The opt-in daily reminder's settings (E4; spec-prop §7.9, §13.3
/// `"reminder": {"on": false, "hour": 19, "minute": 0, "offered": true}`;
/// docs/plans/m7-design.md P3.10). Stored flat in the settings box under
/// `SettingsKeys.reminderOn`, `reminderHour`, `reminderMinute` and
/// `reminderOffered`, read and written only through `DatabaseService`.
///
/// Off on a fresh install: "off until the player accepts" (spec-prop §7.9).
@freezed
abstract class ReminderSettings with _$ReminderSettings {
  const factory ReminderSettings({
    /// The player turned the reminder on (the offer's Yes, or Settings).
    @Default(false) bool on,

    /// The local time it fires, 0–23 and 0–59. The default is 19:00 (plan
    /// decision 15); the offer replaces it with the hour of the first
    /// solve (Q81) when it first appears.
    @Default(ReminderSettings.defaultHour) int hour,
    @Default(ReminderSettings.defaultMinute) int minute,

    /// The one-time offer has appeared on the Daily screen ("offered once",
    /// spec-prop §7.9): it never shows again, answered or not. Yes sets
    /// [on]; No thanks changes nothing else.
    @Default(false) bool offered,
  }) = _ReminderSettings;

  const ReminderSettings._();

  /// 19:00 until the first solve's hour is known (plan decision 15).
  static const int defaultHour = 19;
  static const int defaultMinute = 0;

  /// Whether [hour]:[minute] is a time of day (0–23, 0–59); a stored value
  /// outside it reads as the default.
  static bool isValidTime(int hour, int minute) =>
      hour >= 0 && hour < 24 && minute >= 0 && minute < 60;
}
