import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_game/l10n/app_localizations.dart';

/// Android 13+'s per-app language list (spec §16): `res/xml/locales_config.xml`
/// names the nine launch languages and the manifest points at it, so the
/// system's "system" value follows it with no code change. Run from
/// `apps/game`.
void main() {
  final xml = File(
    'android/app/src/main/res/xml/locales_config.xml',
  ).readAsStringSync();
  final listed = [
    for (final match in RegExp(
      r'<locale android:name="([^"]+)"',
    ).allMatches(xml))
      match.group(1)!,
  ];

  test('the XML lists exactly the supported languages', () {
    // The pt catalog is the Brazilian one: the setting lists pt-BR only.
    final supported = {
      for (final locale in AppLocalizations.supportedLocales)
        if (!(locale.languageCode == 'pt' && locale.countryCode == null))
          locale.toLanguageTag(),
    };
    expect(listed.toSet(), supported);
    expect(listed, hasLength(9));
    expect(listed.toSet(), hasLength(listed.length));
  });

  test('the manifest points at it', () {
    final manifest = File(
      'android/app/src/main/AndroidManifest.xml',
    ).readAsStringSync();
    expect(manifest, contains('android:localeConfig="@xml/locales_config"'));
  });
}
