import 'dart:ui' show Locale, PlatformDispatcher;

import 'package:nesty_game/core/services/database/settings_schema.dart';
import 'package:nesty_game/l10n/app_localizations.dart';

/// Turns the language setting (`DatabaseService.languageCode`) into the
/// language the app renders in (spec §16; M7 phase 5B, l10n plan §1.4).
///
/// - A pinned code (a row tapped in Settings' language sheet) wins when its
///   language has a catalog.
/// - [LocaleSetting.system] (the default), or a stored code whose language
///   has no catalog, follows the phone: the first language in the phone's
///   list that has one, else English.
/// - Every `pt_*` phone gets Brazilian Portuguese (`pt_BR`, the sheet's
///   code); any other regional variant gets its language (`es_MX` → `es`,
///   `de_AT` → `de`).
///
/// The result is always a storage-style code (`en`, `de`, `pt_BR`), the
/// same codes the language sheet stores, so a resolved and a pinned
/// language compare equal.
///
/// Pure: no binding, no clock. [LanguageCubit] (the app's rendering) and
/// `DailyReminder` (the notification's text) resolve through the same
/// instance, so the app and its reminder never disagree.
class AppLocaleResolver {
  AppLocaleResolver(Iterable<Locale> supportedLocales)
    : _languages = {
        for (final locale in supportedLocales) _language(locale.languageCode),
      };

  /// Over the catalogs gen-l10n built from `lib/l10n/app_*.arb`: a language
  /// turns on when its ARB lands (until then it resolves to English), so
  /// the nine launch languages never need a code change here.
  static final app = AppLocaleResolver(AppLocalizations.supportedLocales);

  /// English: the template catalog, always present, and the answer when
  /// nothing else matches.
  static const fallbackCode = 'en';

  /// The sheet's code for Portuguese: Brazilian for every `pt_*` phone.
  static const portugueseCode = 'pt_BR';

  /// The phone's preferred locales, in order, as the engine reports them.
  /// The app root (`App`) feeds the binding's own list to [LanguageCubit]
  /// and follows its changes; this read is the default for code that runs
  /// outside the widget tree (`DailyReminder`).
  static List<Locale> platformLocales() => PlatformDispatcher.instance.locales;

  final Set<String> _languages;

  /// Whether [code]'s language (`pt_BR` → `pt`) has a catalog.
  bool supports(String code) => _languages.contains(_languageOfCode(code));

  /// The language to render for the stored [setting] on a phone whose
  /// preferred locales are [deviceLocales].
  String resolve(String setting, List<Locale> deviceLocales) =>
      supports(setting)
      ? _codeFor(_languageOfCode(setting))
      : resolveDevice(deviceLocales);

  /// The first language in [deviceLocales] that has a catalog, else
  /// [fallbackCode].
  String resolveDevice(Iterable<Locale> deviceLocales) {
    for (final locale in deviceLocales) {
      final language = _language(locale.languageCode);
      if (_languages.contains(language)) return _codeFor(language);
    }
    return fallbackCode;
  }

  /// `MaterialApp.localeListResolutionCallback`: the same answer as
  /// [resolveDevice], as the matching entry of [supported] (the exact
  /// locale, else the language's). `App` passes its resolved locale as the
  /// one-entry list, so this only keeps Flutter's own matching (and its
  /// `supportedLocales.first` fallback) from ever picking differently.
  Locale resolveForMaterialApp(
    List<Locale>? locales,
    Iterable<Locale> supported,
  ) {
    final wanted = localeFor(resolveDevice(locales ?? const []));
    Locale? sameLanguage;
    for (final locale in supported) {
      if (locale == wanted) return locale;
      if (locale.languageCode == wanted.languageCode) {
        sameLanguage ??= locale;
      }
    }
    return sameLanguage ?? wanted;
  }

  /// [code] as a [Locale]; accepts `pt_BR` (and `pt-BR`) style codes.
  static Locale localeFor(String code) {
    final parts = code.split(RegExp('[_-]'));
    return parts.length > 1 ? Locale(parts[0], parts[1]) : Locale(parts[0]);
  }

  static String _codeFor(String language) =>
      language == 'pt' ? portugueseCode : language;

  static String _languageOfCode(String code) =>
      _language(code.split(RegExp('[_-]')).first);

  /// The legacy ISO code for Indonesian (`in`), which older Android
  /// versions still report, read as `id` (dart:ui already canonicalises it
  /// on most phones). Codes arrive lower case (dart:ui's and the sheet's),
  /// so no case transform runs here (l10n plan §9.1 item 8).
  static String _language(String language) =>
      language == 'in' ? 'id' : language;
}
