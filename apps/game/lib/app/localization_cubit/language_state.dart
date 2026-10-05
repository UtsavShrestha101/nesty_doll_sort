part of 'language_cubit.dart';

@freezed
abstract class LanguageState with _$LanguageState {
  const factory LanguageState({
    /// The language setting as persisted: [LocaleSetting.system] (follow
    /// the phone; the default) or the code a sheet tap pinned.
    @Default(SettingsDefaults.locale) String storedLanguageCode,

    /// The language the app renders in: [storedLanguageCode] resolved by
    /// [AppLocaleResolver] against the phone's languages and the catalogs
    /// present. Always a supported storage-style code (`en`, `pt_BR`).
    @Default(AppLocaleResolver.fallbackCode) String currentLanguageCode,

    /// The locale highlighted in a language picker before it's confirmed.
    @Default(AppLocaleResolver.fallbackCode) String selectedLanguageCode,
    @Default(false) bool isLoading,

    /// The last [LanguageCubit.changeLanguage] failed to persist. The UI maps
    /// this to an ARB string — the state carries no user-facing text.
    @Default(false) bool hasError,
  }) = _LanguageState;

  const LanguageState._();

  /// [currentLanguageCode] as a [Locale]; accepts `pt_BR` style codes.
  Locale get locale => AppLocaleResolver.localeFor(currentLanguageCode);

  /// No language was picked: the app follows the phone's.
  bool get followsPhone => storedLanguageCode == LocaleSetting.system;
}
