import 'package:flutter_test/flutter_test.dart';

import 'locales/locales.dart';
import 'support/arb_checks.dart';
import 'support/arb_file.dart';
import 'support/icu.dart';

/// The l10n checkers' own tests (build/m7-p5/p5/l10n.md §3.2, §5.4): fed
/// the synthetic catalogs in `test/l10n/fixtures/` (never `lib/l10n`, which
/// every app build turns into code), the bad French file trips every rule
/// and the good one trips none. So a green `arb_parity_test` or
/// `respect_copy_test` means the rule held, not that the checker was blind.
/// Run from `apps/game`.
void main() {
  const fixtures = 'test/l10n/fixtures';
  final badEnglish = readEnglishArb('$fixtures/bad');
  final bad = readArbFiles('$fixtures/bad').singleWhere((f) => f.code == 'fr');
  final goodEnglish = readEnglishArb('$fixtures/good');
  final good = readArbFiles(
    '$fixtures/good',
  ).singleWhere((f) => f.code == 'fr');
  final fr = rulesFor('fr')!;
  // The fixtures' catalog has none of the real French allow-list's keys
  // (checkIdentical flags an allowed key English lacks), so the identical
  // check runs on the same rules without it.
  final frNoAllowList = LocaleRules(
    code: fr.code,
    pluralCategories: fr.pluralCategories,
    match: fr.match,
    denied: fr.denied,
    taunts: fr.taunts,
    starDenied: fr.starDenied,
    streakWords: fr.streakWords,
    computerStem: fr.computerStem,
    humanStatus: fr.humanStatus,
    oneIncludesZero: fr.oneIncludesZero,
    exemptions: fr.exemptions,
  );

  List<String> messages(ArbFile english, ArbFile file) => [
    for (final key in file.keys) ...checkMessage(english, file, key, fr),
  ];

  List<String> shapes(ArbFile english, ArbFile file) => [
    for (final key in file.keys)
      if (english[key] != null) ...checkPluralShape(english, file, key),
  ];

  Matcher hasLine(String key, String fragment) =>
      contains(allOf(startsWith('fr $key'), contains(fragment)));

  group('a good translation passes every checker', () {
    test('file, keys, messages, identical, shapes', () {
      expect(checkFileShape(good), isEmpty);
      expect(checkKeySet(goodEnglish, good), isEmpty);
      expect(messages(goodEnglish, good), isEmpty);
      expect(checkIdentical(goodEnglish, good, frNoAllowList), isEmpty);
      expect(shapes(goodEnglish, good), isEmpty);
    });

    test('respect, the computer, human status', () {
      expect(respectOffences(fr, good), isEmpty);
      expect(computerOffences(goodEnglish, rulesFor('en')!, good, fr), isEmpty);
      expect(humanStatusOffences(fr, good), isEmpty);
    });
  });

  group('a bad translation trips each rule', () {
    test('@@locale must match the file name, and no @key blocks', () {
      final problems = checkFileShape(bad);
      expect(problems, contains(contains('@@locale is "de"')));
      expect(problems, hasLine('@play', 'no @key blocks'));
    });

    test('a missing English key and an extra key', () {
      final problems = checkKeySet(badEnglish, bad);
      expect(problems, hasLine('appName', 'missing'));
      expect(problems, hasLine('extraKey', 'not an English key'));
    });

    test('a message that does not parse', () {
      expect(checkMessage(badEnglish, bad, 'raceWinBody', fr), [
        allOf(startsWith('fr raceWinBody'), contains('ICU error')),
      ]);
    });

    test('a lost placeholder and an invented one', () {
      final problems = checkMessage(badEnglish, bad, 'greeting', fr);
      expect(problems, hasLine('greeting', '{name} is missing'));
      expect(problems, hasLine('greeting', '{nom} is not in English'));
    });

    test('a plural with no other, a category fr lacks, and =1 beside '
        'one', () {
      final problems = checkMessage(
        badEnglish,
        bad,
        'chaptersStarsSemantics',
        fr,
      );
      expect(problems, hasLine('chaptersStarsSemantics', 'no "other"'));
      expect(problems, hasLine('chaptersStarsSemantics', '"few", not a CLDR'));
      expect(
        problems,
        hasLine('chaptersStarsSemantics', 'both "one" and "=1"'),
      );
      expect(problems, hasLine('chaptersStarsSemantics', '{total} is missing'));
    });

    test("the =1 → one trap: a literal digit in fr's one, shown for 0", () {
      expect(checkMessage(badEnglish, bad, 'coins', fr), [
        allOf(startsWith('fr coins'), contains('literal digit')),
      ]);
      // Shown for 0 in fr: "1 pièce" where English says "0 coins".
      expect(
        checkPluralShape(badEnglish, bad, 'coins'),
        contains(allOf(contains('{count} = 0'), contains('"=1"'))),
      );
    });

    test('the =1 → one trap is caught for pt and hi too, never for de', () {
      final english = ArbFile('en', {
        'coins': '{count, plural, =1{1 coin} other{{count} coins}}',
      });
      for (final code in ['pt', 'hi', 'de']) {
        final file = ArbFile(code, {
          'coins': '{count, plural, =1{1 x} other{{count} x}}',
        });
        final trapped = checkPluralShape(english, file, 'coins').isNotEmpty;
        expect(trapped, code != 'de', reason: code);
        expect(
          checkMessage(english, file, 'coins', rulesFor(code)!).isNotEmpty,
          code != 'de',
          reason: code,
        );
      }
    });

    test('the rival switch must stay =1, =2, other', () {
      expect(
        checkMessage(badEnglish, bad, 'raceRivalName', fr),
        contains(contains('exactly =1, =2, other')),
      );
    });

    test("a select must keep English's cases", () {
      final problems = checkMessage(badEnglish, bad, 'pick', fr);
      expect(problems, hasLine('pick', 'case "c" English lacks'));
      expect(problems, hasLine('pick', 'lacks English\'s case "b"'));
    });

    test('a plural on a String placeholder', () {
      final english = ArbFile('en', {
        'hello': 'Hi {name}',
        '@hello': {
          'placeholders': {
            'name': {'type': 'String'},
          },
        },
      });
      final file = ArbFile('fr', {
        'hello': '{name, plural, one{Salut {name}} other{Salut {name}}}',
      });
      expect(
        checkMessage(english, file, 'hello', fr),
        contains(contains('not a number')),
      );
    });

    test('a translator marker, and a range without its en dash', () {
      final problems = checkMessage(badEnglish, bad, 'chaptersKicker', fr);
      expect(problems, hasLine('chaptersKicker', 'translation marker'));
      expect(problems, hasLine('chaptersKicker', 'en dash'));
    });

    test('a value left in English', () {
      expect(
        checkIdentical(badEnglish, bad, frNoAllowList),
        contains(allOf(startsWith('fr play'), contains('identical'))),
      );
    });

    test('loss, urgency, a taunt, a star line and the streak in the '
        'reminder', () {
      final problems = respectOffences(fr, bad);
      expect(problems, hasLine('dailyStreakKeep', '"vite"'));
      expect(problems, hasLine('dailyStreakKeep', '"avant"'));
      expect(problems, hasLine('raceLossTitle', '"lent"'));
      expect(problems, hasLine('raceLossTitle', '"tu as perdu"'));
      expect(problems, hasLine('winStarsTarget', '"échoué"'));
      expect(problems, hasLine('reminderNotificationBody', '"série*"'));
    });

    test('a rival surface that does not say "ordinateur"', () {
      final problems = computerOffences(badEnglish, rulesFor('en')!, bad, fr);
      expect(problems, hasLine('raceComputerTag', 'ordinateur'));
      expect(problems, hasLine('badgeHint[first_race]', 'ordinateur'));
      expect(
        problems,
        isNot(contains(startsWith('fr badgeHint[first_family]'))),
        reason: 'English names no computer there',
      );
    });

    test('a human status on a race string', () {
      expect(
        humanStatusOffences(fr, bad),
        contains(allOf(startsWith('fr raceStripThinking'), contains('ligne'))),
      );
    });
  });

  group('exemptions', () {
    const lax = LocaleRules(
      code: 'fr',
      pluralCategories: {'one', 'many', 'other'},
      match: MatchMode.words,
      denied: ['avant'],
      taunts: ['lent'],
      starDenied: [],
      streakWords: [],
      computerStem: 'ordinateur',
      humanStatus: [],
      exemptions: {
        'dailyStreakKeep': {'avant': 'not allowed here'},
        'raceWinBody': {'avant': 'the rival was still sorting before the end'},
      },
    );

    test('only the four rival and race keys may exempt a word', () {
      expect(
        exemptionProblems(lax, null),
        contains(allOf(contains('dailyStreakKeep'), contains('no exemption'))),
      );
    });

    test('an exemption the value no longer needs fails', () {
      final file = ArbFile('fr', {'raceWinBody': '{rival} triait encore.'});
      expect(
        exemptionProblems(lax, file),
        contains(contains('no longer needed')),
      );
    });

    test('an exempt word is skipped for its key only', () {
      final file = ArbFile('fr', {
        'raceWinBody': 'Fini avant {rival}.',
        'raceLeaveBody': 'Arrête avant la fin.',
      });
      expect(wordOffences(lax, file, 'raceWinBody', lax.denied), isEmpty);
      expect(wordOffences(lax, file, 'raceLeaveBody', lax.denied), ['avant']);
    });
  });

  group('matching per script (l10n.md §3.2 item 3)', () {
    test('whole words: no match inside another word', () {
      final es = rulesFor('es')!;
      expect(es.matches('solo', 'Solo hoy'), isTrue);
      expect(es.matches('solo', 'Consolo'), isFalse);
      expect(es.matches('perder*', 'No perderás nada'), isTrue);
      expect(es.matches('antes de que', 'antes  de que'), isTrue);
    });

    test('German compounds and stems', () {
      final de = rulesFor('de')!;
      expect(de.matches('verlust~', 'Kein Serienverlust'), isTrue);
      expect(de.matches('serie~', 'Deine Tagesserie'), isTrue);
      expect(de.matches('verpass*', 'Verpasse nichts'), isTrue);
      expect(de.matches('nur', 'Nurse'), isFalse);
      expect(de.matches('bevor', 'Vor dem Start'), isFalse);
    });

    test('Turkish: every entry is a stem, with Turkish case folding', () {
      final tr = rulesFor('tr')!;
      expect(tr.matches('kaybet', 'SERİNİ KAYBETME'), isTrue);
      expect(tr.matches('seri', 'Serini koru'), isTrue);
      expect(tr.fold('IŞIK İSİM'), 'ışık isim');
      expect(tr.matches('acele', 'Bir zaman'), isFalse);
    });

    test('Indonesian: clitics match, verb affixes do not', () {
      final id = rulesFor('id')!;
      expect(id.matches('hilang', 'Hilangnya seri'), isTrue);
      expect(id.matches('kalah', 'Kamu kalah'), isTrue);
      expect(id.matches('kalah', 'Kalahkan {rival}'), isFalse);
    });

    test('Devanagari: the nukta is stripped, matras stay inside a word', () {
      final hi = rulesFor('hi')!;
      expect(LocaleRules.stripNukta('ज़्यादा'), 'ज्यादा');
      expect(LocaleRules.stripNukta('ज़'), 'ज');
      expect(hi.matches('बहुत ज्यादा', 'बहुत ज़्यादा चालें'), isTrue);
      expect(hi.matches('टूट*', 'स्ट्रीक टूटेगी'), isTrue);
      expect(hi.matches('अभी', 'अभीष्ट'), isFalse);
    });

    test('Japanese: substrings', () {
      final ja = rulesFor('ja')!;
      expect(ja.matches('急いで', '今すぐ急いでください'), isTrue);
      expect(ja.matches('連続', '7日連続'), isTrue);
    });

    test('curly and straight apostrophes match alike', () {
      expect(rulesFor('fr')!.matches("n'oublie pas", 'N’oublie pas'), isTrue);
      expect(rulesFor('en')!.matches("don't", 'Don’t go'), isTrue);
    });
  });

  group('every rules file', () {
    for (final code in launchArbCodes) {
      test('$code: each entry matches its own words, and nothing repeats', () {
        final rules = rulesFor(code)!;
        expect(rules.computerStem.trim(), isNotEmpty);
        for (final list in [
          rules.denied,
          rules.taunts,
          rules.starDenied,
          rules.streakWords,
          rules.humanStatus,
        ]) {
          expect(list.toSet(), hasLength(list.length), reason: '$list');
          for (final entry in list) {
            final words = entry.replaceAll(RegExp(r'[*~]$'), '');
            expect(rules.matches(entry, words), isTrue, reason: entry);
          }
        }
        expect(rules.namesComputer(rules.computerStem), isTrue);
        expect(exemptionProblems(rules, null), isEmpty);
      });
    }

    test('pt_BR inherits pt', () {
      expect(rulesFor('pt_BR'), same(rulesFor('pt')));
    });
  });

  group('the ICU reader', () {
    test('reads nested plurals, selects and literal apostrophes', () {
      final nodes = parseIcu(
        "{a, plural, =1{{b, select, x{It's {c}} other{}}} other{{a} n}} d",
      );
      expect(referencedPlaceholders(nodes), {'a', 'b', 'c'});
      expect(choicesIn(nodes, IcuChoiceKind.select).single.keys, [
        'x',
        'other',
      ]);
      expect(readableText(nodes), contains("It's"));
    });

    test('rejects what gen-l10n would', () {
      for (final source in ['{a', 'b}', '{a, number}', '{a, plural, =1{x}']) {
        expect(
          () => parseIcu(source),
          throwsA(isA<IcuFormatException>()),
          reason: source,
        );
      }
    });

    test('picks the branch the app shows', () {
      final plural =
          parseIcu('{n, plural, =1{1 x} other{{n} x}}').single as IcuChoice;
      expect(pickPluralBranch(plural, 0, 'en'), 'other');
      expect(pickPluralBranch(plural, 0, 'fr'), '=1');
      expect(pickPluralBranch(plural, 0, 'de'), 'other');
      expect(pickPluralBranch(plural, 1, 'de'), '=1');
    });
  });
}
