import 'package:flutter_test/flutter_test.dart';

import 'locales/locales.dart';
import 'support/arb_checks.dart';
import 'support/arb_file.dart';

/// Placeholder and plural parity for every catalog (build/m7-p5/p5/l10n.md
/// §5.2–§5.4; spec §16): for each `lib/l10n/app_<code>.arb` that exists,
/// its `@@locale`, its key set (every English key, no extra one; `pt_BR` a
/// subset), no `@key` blocks, every message parsing with English's
/// placeholders, CLDR-valid plurals, English's select cases, the rival
/// switches, no translator marker, the ranges' "–", and nothing left in
/// English unless allowed. English runs the message checks too, so a
/// broken template fails here first.
///
/// Until 5B-5 sets [requireAllLaunchLocales], a locale with no ARB yet is
/// simply not checked; `locale_set_test.dart` then demands all nine.
/// Reads the files, not the generated code, so a translator runs it
/// before any gen-l10n. Run from `apps/game`.
void main() {
  final english = readEnglishArb();
  final files = readArbFiles();

  test('the template is there', () {
    expect(files.first.code, 'en');
    expect(english.keys, isNotEmpty);
  });

  for (final file in files) {
    final rules = rulesFor(file.code);

    group('app_${file.code}.arb', () {
      test('is a launch locale with its rules file', () {
        expect(
          launchArbCodes,
          contains(file.code),
          reason: 'spec §16 names the nine launch languages',
        );
        expect(rules, isNotNull, reason: 'test/l10n/locales/${file.code}.dart');
      });

      test('@@locale matches the file, no @key blocks, string values', () {
        expect(checkFileShape(file), isEmpty);
      });

      test('the key set equals English', () {
        expect(checkKeySet(english, file), isEmpty);
      });

      test('every message parses and keeps its placeholders, plurals and '
          'selects', () {
        final problems = [
          for (final key in file.keys)
            ...checkMessage(english, file, key, rules!),
        ];
        expect(problems, isEmpty, reason: problems.join('\n'));
      });

      test('nothing is left in English unless allowed', () {
        final problems = checkIdentical(english, file, rules!);
        expect(problems, isEmpty, reason: problems.join('\n'));
      });
    });
  }

  test('the global allowlist names English keys', () {
    for (final key in globalIdenticalAllowed) {
      expect(english[key], isNotNull, reason: key);
    }
  });
}
