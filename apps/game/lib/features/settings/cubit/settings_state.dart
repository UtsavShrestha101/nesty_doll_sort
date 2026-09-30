part of 'settings_cubit.dart';

/// What Settings shows (frames 8.1, 8.2; spec §10.2 #13;
/// docs/plans/m3-design.md §10.2).
@freezed
abstract class SettingsState with _$SettingsState {
  const factory SettingsState({
    @Default(true) bool soundEnabled,
    @Default(true) bool musicEnabled,
    @Default(true) bool hapticsEnabled,
    @Default(SettingsDefaults.symbols) SymbolsMode symbolsMode,

    /// Relaxed mode (E6; docs/plans/m7-design.md §10, §15.5).
    @Default(SettingsDefaults.relaxed) bool relaxedMode,

    /// The reduce-motion override (E14; m7-design §14, §15.5).
    @Default(SettingsDefaults.reduceMotion) ReduceMotionMode reduceMotion,

    /// `AppInfoService.load()`'s version and build (the footer).
    @Default('') String version,
    @Default('') String buildNumber,

    /// `SaveService.playerId` (the footer).
    @Default('') String playerId,

    /// The opt-in daily reminder (E4; spec-prop §7.9; m7-design P3.10):
    /// hidden until `reminder.available` (the daily is unlocked, Q139).
    @Default(ReminderStatus()) ReminderStatus reminder,
  }) = _SettingsState;
}
