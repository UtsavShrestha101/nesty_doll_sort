part of 'settings_cubit.dart';

/// What Settings shows (frames 8.1, 8.2; spec §10.2 #13;
/// docs/plans/m3-design.md §10.2).
@freezed
abstract class SettingsState with _$SettingsState {
  const factory SettingsState({
    @Default(true) bool soundEnabled,
    @Default(true) bool musicEnabled,
    @Default(true) bool hapticsEnabled,
    @Default(SymbolsMode.subtle) SymbolsMode symbolsMode,

    /// `AppInfoService.load()`'s version and build (the footer).
    @Default('') String version,
    @Default('') String buildNumber,

    /// `SaveService.playerId` (the footer).
    @Default('') String playerId,
  }) = _SettingsState;
}
