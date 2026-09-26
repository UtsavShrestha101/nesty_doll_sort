part of 'language_cubit.dart';

@freezed
abstract class LanguageState with _$LanguageState {
  const factory LanguageState({
    /// The locale the app is rendered in (persisted).
    @Default(SettingsDefaults.locale) String currentLanguageCode,

    /// The locale highlighted in a language picker before it's confirmed.
    @Default(SettingsDefaults.locale) String selectedLanguageCode,
    @Default(false) bool isLoading,

    /// The last [LanguageCubit.changeLanguage] failed to persist. The UI maps
    /// this to an ARB string — the state carries no user-facing text.
    @Default(false) bool hasError,
  }) = _LanguageState;

  const LanguageState._();

  /// [currentLanguageCode] as a [Locale]; accepts `pt_BR` style codes.
  Locale get locale {
    final parts = currentLanguageCode.split('_');
    return parts.length > 1 ? Locale(parts[0], parts[1]) : Locale(parts[0]);
  }
}
