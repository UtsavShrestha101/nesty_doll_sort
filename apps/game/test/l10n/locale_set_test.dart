import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_game/features/settings/widgets/language_sheet.dart';
import 'package:nesty_game/l10n/app_localizations.dart';

import 'locales/locales.dart';
import 'support/arb_file.dart';

/// The launch set (spec §16; build/m7-p5/p5/l10n.md §5.3, §5.4): the ARB
/// files are only launch locales; once 5B-5 sets [requireAllLaunchLocales]
/// they are exactly the nine (with `pt_BR` beside `pt`), the generated
/// `supportedLocales` follow the files, and every row of the language
/// sheet has a catalog. Until then the "all nine" tests are skipped, so
/// English alone (and each translation as it lands) is green. Run from
/// `apps/game`.
void main() {
  final codes = [for (final file in readArbFiles()) file.code];
  const skipUntil5B5 = requireAllLaunchLocales
      ? false
      : 'until 5B-5 sets requireAllLaunchLocales (test/l10n/support/'
            'arb_file.dart)';

  test('every ARB file is a launch locale', () {
    expect(codes, contains('en'));
    for (final code in codes) {
      expect(launchArbCodes, contains(code), reason: 'app_$code.arb');
    }
  });

  test('pt_BR only beside pt (pt holds the Brazilian catalog)', () {
    if (codes.contains('pt_BR')) expect(codes, contains('pt'));
  });

  test('the files are exactly the nine launch locales', () {
    expect(codes.toSet(), launchArbCodes.toSet());
  }, skip: skipUntil5B5);

  test('supportedLocales follow the files (gen-l10n has run)', () {
    final supported = {
      for (final locale in AppLocalizations.supportedLocales) locale.toString(),
    };
    expect(supported, codes.toSet());
  }, skip: skipUntil5B5);

  test('every language sheet row has a catalog', () {
    for (final language in launchLanguages) {
      final parts = language.code.split('_');
      final locale = Locale(parts.first, parts.length > 1 ? parts[1] : null);
      expect(
        AppLocalizations.delegate.isSupported(locale),
        isTrue,
        reason: language.code,
      );
    }
  }, skip: skipUntil5B5);
}
