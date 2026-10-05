import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_game/app/localization_cubit/app_locale_resolver.dart';
import 'package:nesty_game/core/services/database/settings_schema.dart';
import 'package:nesty_game/l10n/app_localizations.dart';

import 'support/launch_catalogs.dart';

/// `AppLocaleResolver` (M7 phase 5B; l10n plan §1.4, §9.1 items 1–2): the
/// language setting to the rendered language.
void main() {
  final nine = AppLocaleResolver(nineLaunchCatalogs);
  const system = LocaleSetting.system;

  group('"system" follows the phone: the first supported language in its '
      'list, else English', () {
    final cases = <(List<Locale>, String)>[
      (const [Locale('de', 'AT')], 'de'),
      (const [Locale('de')], 'de'),
      (const [Locale('es', 'MX')], 'es'),
      (const [Locale('es', 'ES')], 'es'),
      (const [Locale('es', '419')], 'es'),
      (const [Locale('fr', 'CA')], 'fr'),
      (const [Locale('ja', 'JP')], 'ja'),
      (const [Locale('hi', 'IN')], 'hi'),
      (const [Locale('tr', 'TR')], 'tr'),
      (const [Locale('id', 'ID')], 'id'),
      (const [Locale('en', 'GB')], 'en'),
      // Older Androids report Indonesian under its legacy code.
      (const [Locale('in', 'ID')], 'id'),
      // The first *supported* entry wins, not the first entry.
      (const [Locale('zh', 'CN'), Locale('fr', 'CA')], 'fr'),
      (const [Locale('ko'), Locale('it'), Locale('ja')], 'ja'),
      (const [Locale('de'), Locale('fr')], 'de'),
      (const [Locale('ko')], 'en'),
      (const [Locale('zh', 'TW'), Locale('ru')], 'en'),
      (const <Locale>[], 'en'),
    ];
    for (final (phone, expected) in cases) {
      test('$phone → $expected', () {
        expect(nine.resolve(system, phone), expected);
        expect(nine.resolveDevice(phone), expected);
      });
    }
  });

  group('every Portuguese phone gets Brazilian Portuguese (pt_BR)', () {
    for (final phone in const [
      Locale('pt', 'PT'),
      Locale('pt', 'BR'),
      Locale('pt', 'AO'),
      Locale('pt'),
    ]) {
      test('$phone → pt_BR', () {
        expect(nine.resolve(system, [phone]), 'pt_BR');
      });
    }

    test('even when only app_pt.arb exists (no pt_BR entry)', () {
      final ptOnly = AppLocaleResolver(const [Locale('en'), Locale('pt')]);
      expect(ptOnly.resolve(system, const [Locale('pt', 'PT')]), 'pt_BR');
    });
  });

  group('a pinned language wins over the phone', () {
    test('ja pinned on a German phone renders Japanese', () {
      expect(nine.resolve('ja', const [Locale('de')]), 'ja');
    });

    test('a stored "en" stays English on a German phone', () {
      expect(nine.resolve('en', const [Locale('de')]), 'en');
    });

    test('pt_BR pinned on an English phone renders pt_BR', () {
      expect(nine.resolve('pt_BR', const [Locale('en', 'US')]), 'pt_BR');
    });

    test('"system" vs a pin on the same phone', () {
      const phone = [Locale('fr', 'FR')];
      expect(nine.resolve(system, phone), 'fr');
      expect(nine.resolve('tr', phone), 'tr');
    });
  });

  group('a stored code without a catalog behaves as "system"', () {
    test('an unknown code follows the phone', () {
      expect(nine.resolve('xx', const [Locale('de')]), 'de');
      expect(nine.resolve('it', const [Locale('ko')]), 'en');
      expect(nine.resolve('', const [Locale('ja')]), 'ja');
    });

    test('until its ARB lands, a launch language resolves like today: '
        'English', () {
      final englishOnly = AppLocaleResolver(const [Locale('en')]);
      expect(englishOnly.resolve('de', const [Locale('de')]), 'en');
      expect(englishOnly.resolve(system, const [Locale('ja')]), 'en');
      expect(englishOnly.supports('de'), isFalse);
      expect(englishOnly.supports('en'), isTrue);
    });
  });

  test('supports reads the language of a regional code, never "system"', () {
    expect(nine.supports('pt_BR'), isTrue);
    expect(nine.supports('pt-BR'), isTrue);
    expect(nine.supports('de'), isTrue);
    expect(nine.supports(system), isFalse);
    expect(nine.supports('ko'), isFalse);
  });

  test('localeFor parses storage codes into a Locale', () {
    expect(AppLocaleResolver.localeFor('pt_BR'), const Locale('pt', 'BR'));
    expect(AppLocaleResolver.localeFor('pt-BR'), const Locale('pt', 'BR'));
    expect(AppLocaleResolver.localeFor('en'), const Locale('en'));
  });

  group('resolveForMaterialApp answers as the resolver, from the supported '
      'list', () {
    test('the exact entry when there is one', () {
      expect(
        nine.resolveForMaterialApp(const [
          Locale('pt', 'PT'),
        ], nineLaunchCatalogs),
        const Locale('pt', 'BR'),
      );
      expect(
        nine.resolveForMaterialApp(const [
          Locale('de', 'AT'),
        ], nineLaunchCatalogs),
        const Locale('de'),
      );
    });

    test("else the language's entry", () {
      const supported = [Locale('en'), Locale('pt')];
      final resolver = AppLocaleResolver(supported);
      expect(
        resolver.resolveForMaterialApp(const [Locale('pt', 'BR')], supported),
        const Locale('pt'),
      );
    });

    test('English (never supportedLocales.first) for an unsupported phone', () {
      const alphabetical = [Locale('de'), Locale('en'), Locale('fr')];
      final resolver = AppLocaleResolver(alphabetical);
      expect(
        resolver.resolveForMaterialApp(const [Locale('ko')], alphabetical),
        const Locale('en'),
      );
      expect(
        resolver.resolveForMaterialApp(null, alphabetical),
        const Locale('en'),
      );
    });
  });

  test('AppLocaleResolver.app covers exactly the catalogs present, each '
      'resolving to itself', () {
    final app = AppLocaleResolver.app;
    for (final locale in AppLocalizations.supportedLocales) {
      expect(app.supports(locale.toString()), isTrue, reason: '$locale');
      expect(
        AppLocaleResolver.localeFor(app.resolve(system, [locale])).languageCode,
        locale.languageCode,
        reason: '$locale',
      );
    }
    expect(app.resolve(system, const [Locale('ko')]), 'en');
  });
}
