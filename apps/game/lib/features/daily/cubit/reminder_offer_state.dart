part of 'reminder_offer_cubit.dart';

/// Where the one-time reminder offer stands (E4; spec-prop §7.9;
/// docs/plans/m7-design.md P3.10).
enum ReminderOfferStep {
  /// Nothing shows: not solved today, already offered, or already on.
  hidden,

  /// "Want a note when tomorrow's puzzle is ready?", with the time chip,
  /// Yes and No thanks.
  ask,

  /// Yes was tapped and the OS is being asked: the buttons are disabled.
  asking,

  /// The OS allowed it: the page closes the card and shows the "Reminder
  /// set for {time}." toast (frame 10.2c), then dismisses.
  enabled,

  /// The OS said no (the reminder stays on and blocked, D190): "Notifications
  /// are off for Nesty" with Open phone settings and Not now (frame 10.2d).
  denied,
}

/// The offer card's state (m7-design P3.10).
@freezed
abstract class ReminderOfferState with _$ReminderOfferState {
  const factory ReminderOfferState({
    @Default(ReminderOfferStep.hidden) ReminderOfferStep step,

    /// The time the chip shows: the solve's hour, minute 0 (Q81), until the
    /// player changes it.
    @Default(ReminderSettings.defaultHour) int hour,
    @Default(ReminderSettings.defaultMinute) int minute,
  }) = _ReminderOfferState;
}
