import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

import 'locales/locales.dart';
import 'support/arb_checks.dart';
import 'support/arb_file.dart';
import 'support/icu.dart';

/// Plural shapes per locale (build/m7-p5/p5/l10n.md §5.1, §5.2, §5.4): for
/// each plural key and each count of 0, 1, 2, 3, 5, 11, 21, 101 and
/// 1,000,000, the branch the app shows (gen-l10n's mapping into
/// `Intl.pluralLogic`) shows the number wherever English's does. This is
/// the =1 → one trap: a copied `=1{1 pièce}` reads "1 pièce" for 0 in fr,
/// pt and hi. It also prints the keys over 1.5× English's length for the
/// reviewers. Run from `apps/game`.
void main() {
  final english = readEnglishArb();
  final files = readArbFiles();

  /// l10n.md §5.1's CLDR categories, each locale's rules file holds them.
  const cldr = {
    'en': {'one', 'other'},
    'es': {'one', 'many', 'other'},
    'pt': {'one', 'many', 'other'},
    'fr': {'one', 'many', 'other'},
    'hi': {'one', 'other'},
    'de': {'one', 'other'},
    'tr': {'one', 'other'},
    'id': {'other'},
    'ja': {'other'},
  };
  const zeroIsOne = {'pt', 'fr', 'hi'};

  group('the CLDR table', () {
    for (final MapEntry(key: code, value: categories) in cldr.entries) {
      test('$code: the rules file matches l10n.md §5.1', () {
        final rules = rulesFor(code)!;
        expect(rules.pluralCategories, categories);
        expect(rules.oneIncludesZero, zeroIsOne.contains(code));
      });

      test("$code: intl's plural rule gives the same categories", () {
        final seen = {
          for (var n = 0; n <= 2000; n++) cldrCategoryOf(n, code),
          cldrCategoryOf(1000000, code),
          cldrCategoryOf(2000000, code),
        };
        expect(seen, categories);
        expect(
          cldrCategoryOf(0, code),
          zeroIsOne.contains(code) ? 'one' : 'other',
          reason: 'whether 0 is "one" in $code',
        );
      });
    }
  });

  for (final file in files) {
    if (file.code == 'en') continue;
    test('app_${file.code}.arb: every plural shows the number where English '
        'does', () {
      final problems = [
        for (final key in file.keys)
          if (english[key] != null) ...checkPluralShape(english, file, key),
      ];
      expect(problems, isEmpty, reason: problems.join('\n'));
      final long = lengthReport(english, file);
      if (long.isNotEmpty) {
        debugPrint(
          'app_${file.code}.arb: ${long.length} keys over 1.5x English '
          '(for the reviewers):\n${long.join('\n')}',
        );
      }
    });
  }

  // 5B-5 (lead): CLDR's pt `one` covers 0, so "0 moeda" would show. Every pt
  // plural with a `one` branch has an explicit `=0` branch with the plural
  // noun, and 0 picks it.
  test('pt: every plural with a one branch writes =0 and 0 picks it', () {
    final pt = files.firstWhere((file) => file.code == 'pt');
    final problems = <String>[];
    for (final key in pt.keys) {
      final nodes = pt.parse(key);
      for (final plural in choicesIn(nodes, IcuChoiceKind.plural)) {
        if (plural.branch('one') == null) continue;
        if (plural.branch('=0') == null) {
          problems.add('$key: ${plural.name} has one but no =0');
        } else if (pickPluralBranch(plural, 0, 'pt') != '=0') {
          problems.add(
            '$key: ${plural.name} shows '
            '${pickPluralBranch(plural, 0, 'pt')} for 0',
          );
        }
      }
    }
    expect(problems, isEmpty, reason: problems.join('\n'));
  });
}
