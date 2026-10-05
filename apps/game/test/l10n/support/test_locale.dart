import 'package:flutter/widgets.dart';
import 'package:nesty_game/l10n/app_localizations.dart';

/// The locale a host test run lays screens out in (build/m7-p5/p5/l10n.md
/// §6.2): `flutter test test/overflow --dart-define=NESTY_TEST_LOCALE=de`.
/// English by default. `pumpScreen` and `pumpUi` pass it to their
/// `MaterialApp`, and a test finds its copy through [testL10n], never a
/// hard-coded English string.
const testLocaleCode = String.fromEnvironment(
  'NESTY_TEST_LOCALE',
  defaultValue: 'en',
);

/// [testLocaleCode] as a [Locale] (`pt_BR` → `Locale('pt', 'BR')`).
final Locale testLocale = localeOfCode(testLocaleCode);

/// The strings of [testLocale]. Throws a [StateError] that names the
/// missing catalog when the run asks for a locale with no generated code,
/// rather than laying the screens out in English unseen.
final AppLocalizations testL10n = _lookup(testLocale);

/// A stored or ARB locale code as a [Locale].
Locale localeOfCode(String code) {
  final parts = code.split(RegExp('[_-]'));
  return Locale(parts.first, parts.length > 1 ? parts[1] : null);
}

/// [locale] has a generated catalog (its ARB exists and gen-l10n ran).
bool hasCatalog(Locale locale) => AppLocalizations.delegate.isSupported(locale);

AppLocalizations _lookup(Locale locale) {
  if (!hasCatalog(locale)) {
    throw StateError(
      'NESTY_TEST_LOCALE=$testLocaleCode has no catalog: add '
      'lib/l10n/app_$testLocaleCode.arb and run gen-l10n (supported: '
      '${AppLocalizations.supportedLocales.join(', ')})',
    );
  }
  return lookupAppLocalizations(locale);
}

/// [locale] (by default [testLocale]) once its catalog is known to
/// exist: the pump helpers call it, so a run asking for a locale with no
/// catalog fails with [testL10n]'s message instead of a delegate error.
Locale checkedLocale([Locale? locale]) {
  final chosen = locale ?? testLocale;
  if (chosen == testLocale) {
    testL10n.localeName;
  } else if (!hasCatalog(chosen)) {
    throw StateError('no catalog for $chosen');
  }
  return chosen;
}
