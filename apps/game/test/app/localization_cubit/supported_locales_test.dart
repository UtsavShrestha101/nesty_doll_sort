import 'dart:io';
import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_game/app/localization_cubit/app_locale_resolver.dart';
import 'package:nesty_game/features/settings/widgets/language_sheet.dart';
import 'package:nesty_game/l10n/app_localizations.dart';

import 'support/launch_catalogs.dart';

/// The supported-locale list is gated on the ARBs present (M7 phase 5B,
/// l10n plan §1.4, §9.1 item 1): gen-l10n builds
/// `AppLocalizations.supportedLocales` from `lib/l10n/app_*.arb`, and
/// `AppLocaleResolver.app` reads that list, so a launch language turns on
/// when its translator's ARB lands, with no code change, and the build
/// never names a catalog that doesn't exist. These tests pin that the list
/// is exactly the ARB files, English first, and only launch languages.
void main() {
  Set<String> arbCodes() {
    final pattern = RegExp(r'^app_(.+)\.arb$');
    return {
      for (final entity in Directory('lib/l10n').listSync())
        if (pattern.firstMatch(entity.uri.pathSegments.last) case final m?)
          m.group(1)!,
    };
  }

  test('supportedLocales is exactly the ARB files present', () {
    expect(
      AppLocalizations.supportedLocales.map((l) => l.toString()).toSet(),
      arbCodes(),
      reason:
          'run `LANE=<lane> bash build/m7-p5/bin/codegen.sh l10n` after '
          'adding or removing an ARB',
    );
  });

  test('English is first whatever catalogs exist (l10n.yaml '
      'preferred-supported-locales)', () {
    expect(AppLocalizations.supportedLocales.first, const Locale('en'));
    expect(
      File('l10n.yaml').readAsStringSync(),
      contains(
        RegExp(r'^preferred-supported-locales:\s*\[en\]', multiLine: true),
      ),
    );
  });

  test('every catalog is one of the nine launch languages (spec §16)', () {
    final launchLanguages = {
      for (final locale in nineLaunchCatalogs) locale.languageCode,
    };
    for (final locale in AppLocalizations.supportedLocales) {
      expect(launchLanguages, contains(locale.languageCode), reason: '$locale');
    }
  });

  test("the sheet's codes are the nine, and each resolves to itself once "
      'its catalog exists', () {
    expect(launchLanguages.map((l) => l.code), nineLaunchCodes);
    final nine = AppLocaleResolver(nineLaunchCatalogs);
    for (final code in nineLaunchCodes) {
      expect(nine.resolve(code, const [Locale('ko')]), code);
    }
  });

  test('iOS lists the nine languages in CFBundleLocalizations', () {
    final plist = File('ios/Runner/Info.plist').readAsStringSync();
    final block = RegExp(
      r'<key>CFBundleLocalizations</key>\s*<array>(.*?)</array>',
      dotAll: true,
    ).firstMatch(plist);
    expect(block, isNotNull, reason: 'CFBundleLocalizations is missing');
    final codes = RegExp(
      '<string>([^<]+)</string>',
    ).allMatches(block!.group(1)!).map((m) => m.group(1)).toList();
    // iOS spells regions with a hyphen.
    expect(codes, nineLaunchCodes.map((c) => c.replaceAll('_', '-')).toList());
  });
}
