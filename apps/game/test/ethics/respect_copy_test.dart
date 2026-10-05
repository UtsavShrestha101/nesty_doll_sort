import 'package:flutter_test/flutter_test.dart';

import '../l10n/locales/locales.dart';
import '../l10n/support/arb_checks.dart';
import '../l10n/support/arb_file.dart';

/// E1, the respect rules (spec-prop §1, §1.1; docs/plans/
/// offline-game-brainstorm.md §5; docs/plans/m7-design.md §17), in every
/// language the game ships (phase 5B; build/m7-p5/p5/l10n.md §3): every
/// streak, freeze, chest and not-enough-coins string is value-framed, with
/// no loss, guilt, urgency or scarcity wording ("Play today to add to your
/// streak", never "keep your streak"; "Freeze used", never "Streak
/// saved!").
///
/// Phase 2 adds vs Computer's keys (`race*`, `hudRace*`, m7-design P2.12):
/// a loss is warm, and nothing hurries the player (spec-prop §1.1 rules 3,
/// 4); every string a race shows, its reused keys included, is also free
/// of taunts (vs-computer rule 10). Phase 3 (m7-design P3.12) adds the
/// daily reminder's, the share card's and the star rating's keys: the
/// reminder never mentions a streak (spec-prop §7.9), and no star string
/// grades a win as a failure (star-rating.md "Keeping a 1★ win a win").
/// copy.md m7-4 rewrote the four lines m7-3 had exempt (Gentle / Steady /
/// Lively pace, "stops here", "keep everything", "was still sorting"), so
/// English needs no exemption.
///
/// Each locale's lists are in `test/l10n/locales/<code>.dart`, matched per
/// script (`LocaleRules.match`: whole words, German compounds, Turkish and
/// Indonesian stems, Devanagari without the nukta, Japanese substrings).
/// A locale may exempt a word only in the four rival and race keys
/// (`LocaleRules.exemptableKeys`), and only while its value needs it. The
/// key families are in `test/l10n/support/arb_checks.dart`. Every
/// `lib/l10n/app_<code>.arb` that exists is checked; `pt_BR` uses `pt`'s
/// lists. Run from `apps/game`.
void main() {
  final english = readEnglishArb();
  final files = readArbFiles();
  final en = rulesFor('en')!;

  test('the checked key families exist', () {
    final keys = keysWithPrefix(english, checkedPrefixes).toList();
    for (final key in [
      'dailyStreakKeep',
      'dailyStreakPaused',
      'dailyStreakRelitTitle',
      'dailyFreezes',
      'dailySavedTitle',
      'dailyChestTitle',
      'dailyWinChestHint',
      'chestMilestoneTitle',
      'winChestCountdown',
      'notEnoughCoinsTitle',
      'raceLossTitle',
      'raceLossBody',
      'raceStripStartingOver',
      'raceLeaveBody',
      'reminderOfferTitle',
      'reminderNotificationTitle',
      'settingReminder',
      'dailyShareText',
      'starsFirstTip',
      'winStarsTarget',
    ]) {
      expect(keys, contains(key));
    }
    for (final key in raceSurfaceKeys) {
      expect(english[key], isNotNull, reason: 'missing "$key"');
    }
  });

  for (final file in files) {
    final rules = rulesFor(file.code)!;

    group('app_${file.code}.arb', () {
      List<String> offences(
        Iterable<String> keys,
        List<String> Function(LocaleRules) list,
      ) => [
        for (final key in keys)
          for (final word in wordOffences(rules, file, key, list(rules)))
            '$key: "$word" in "${file[key]}"',
      ];

      test('no streak, freeze or chest string uses loss, guilt, urgency or '
          'scarcity wording', () {
        final found = offences(
          keysWithPrefix(file, checkedPrefixes),
          (r) => r.denied,
        );
        expect(found, isEmpty, reason: found.join('\n'));
      });

      test('every string a race shows is free of taunting, loss, guilt, '
          'urgency and scarcity wording', () {
        final found = offences(
          raceSurfaceKeys,
          (r) => [...r.taunts, ...r.denied],
        );
        expect(found, isEmpty, reason: found.join('\n'));
      });

      test('no star string grades a win as a failure (m7-design P3.12)', () {
        final found = offences(
          keysWithPrefix(file, starPrefixes),
          (r) => [...r.denied, ...r.starDenied],
        );
        expect(found, isEmpty, reason: found.join('\n'));
      });

      test('the reminder never mentions a streak (spec-prop §7.9)', () {
        final keys = keysWithPrefix(file, reminderPrefixes).toList();
        if (file.code != 'pt_BR') {
          expect(keys, contains('reminderNotificationBody'));
        }
        final found = [
          for (final key in keys)
            for (final word in rules.offences(rules.streakWords, file[key]!))
              '$key: "$word" in "${file[key]}"',
        ];
        expect(found, isEmpty, reason: found.join('\n'));
      });

      test('exemptions only in the four rival and race keys, each still '
          'needed', () {
        final problems = exemptionProblems(rules, file);
        expect(problems, isEmpty, reason: problems.join('\n'));
      });
    });
  }

  group('English', () {
    test('copy.md m7-4 rewrote the four rival and race lines: no exemption '
        'is left', () {
      expect(en.exemptions, isEmpty);
      // The words m7-3 needed an exemption for. They are gone from the
      // copy, so every checked key passes the full lists.
      const rewritten = {
        'raceRivalSkill': ['slow', 'quick'],
        'raceRivalBlurb': ['before', 'quick'],
        'raceLeaveBody': ['ends', 'lost'],
        'raceWinBody': ['before'],
      };
      expect(rewritten.keys.toSet(), LocaleRules.exemptableKeys);
      for (final MapEntry(key: key, value: words) in rewritten.entries) {
        for (final word in words) {
          expect(
            en.matches(word, english[key]!),
            isFalse,
            reason: '$key says "$word" again',
          );
        }
      }
      expect(
        english['raceRivalSkill'],
        '{number, plural, =1{Gentle pace} =2{Steady pace} other{Lively pace}}',
      );
      expect(
        english['raceWinBody'],
        'Every family is complete. {rival} was still sorting.',
      );
      expect(
        english['raceLeaveBody'],
        'The race stops here. No coins, and you keep everything.',
      );
    });

    test('the deny-list catches the copy M7 rewrote', () {
      bool offends(String text) => en.offences(en.denied, text).isNotEmpty;
      expect(offends('Play today to keep your streak'), isTrue);
      expect(offends('Streak saved!'), isTrue);
      expect(offends('0 left'), isTrue);
      expect(offends("Don't lose your streak!"), isTrue);
      expect(offends('Don’t lose your streak!'), isTrue);
      expect(offends('Play today to add to your streak'), isFalse);
      expect(offends('Freeze used'), isFalse);
    });

    test('the star lists catch a shaming star line', () {
      expect(
        ['Only 1 star', 'You missed 3 stars', 'Try again for 3 stars'].where(
          (text) =>
              en.offences([...en.denied, ...en.starDenied], text).isNotEmpty,
        ),
        hasLength(3),
      );
    });

    test('the taunt list catches a taunting loss', () {
      bool taunts(String text) => en.offences(en.taunts, text).isNotEmpty;
      expect(taunts('Too slow!'), isTrue);
      expect(taunts('Better luck next time'), isTrue);
      expect(taunts('You lost to the computer'), isTrue);
      expect(taunts('How embarrassing'), isTrue);
      expect(taunts('The computer finished first'), isFalse);
      expect(taunts('So close! Rematch?'), isFalse);
    });

    test('the reminder check catches a streak line', () {
      expect(en.offences(en.streakWords, 'Keep your 5-day streaks'), [
        'streak*',
      ]);
    });
  });
}
