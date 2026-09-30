import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// E1, the respect rules (spec-prop §1, §1.1; docs/plans/
/// offline-game-brainstorm.md §5; docs/plans/m7-design.md §17): every
/// streak, freeze, chest and not-enough-coins string is value-framed, with
/// no loss, guilt, urgency or scarcity wording ("Play today to add to your
/// streak", never "keep your streak"; "Freeze used", never "Streak
/// saved!").
///
/// Phase 2 adds vs Computer's keys (`race*`, `hudRace*`, m7-design P2.12):
/// a loss is warm, and nothing hurries the player (spec-prop §1.1 rules 3,
/// 4); every string a race shows, its reused keys included, is also free
/// of taunts (vs-computer rule 10). Phase 3 (m7-design P3.12) adds the
/// daily reminder's, the share card's and the star rating's keys to
/// [checkedPrefixes]: the reminder never mentions a streak (spec-prop
/// §7.9), and no star string grades a win as a failure (star-rating.md
/// "Keeping a 1★ win a win": never "only", "missed", "failed" or "try
/// again"). Phase 4 (copy.md m7-3) puts Claude Design's lines in and
/// adds its new race keys; four of its rival lines use denied words about
/// the computer, each exempt for its key and word only, with its reason
/// ([exemptions]; phase 4 decision on Q-P4-2). Run from `apps/game`.
void main() {
  late Map<String, Object?> arb;

  setUpAll(() {
    arb =
        jsonDecode(File('lib/l10n/app_en.arb').readAsStringSync())
            as Map<String, Object?>;
  });

  /// The key families under the rule: the daily streak, its freezes and
  /// chests, the milestone chest, the streak's records row, and
  /// NotEnoughCoinsDialog (D112). `notNow` (its "Not now" button, shared
  /// with any future dialog) is deliberately not under a checked prefix:
  /// [denied]'s "now" targets urgency copy like "Buy now", and would
  /// word-match the standard, non-urgent decline "Not now" (the opposite of
  /// urgency) as a false positive.
  const checkedPrefixes = [
    'dailyStreak',
    'dailyFreezes',
    'dailySaved',
    'dailyChest',
    'dailyWin',
    'streakBadge',
    'chest',
    'winChest',
    'recordsLongestStreak',
    'notEnoughCoins',
    // vs Computer (m7-design P2.12).
    'race',
    'hudRace',
    // The reminder, the share card and the stars (m7-design P3.12).
    'reminder',
    'settingReminder',
    'dailyShare',
    'stars',
    'winStars',
    'chaptersStars',
    'recordsStars',
    'recordsThreeStar',
  ];

  /// Wording a value-framed string never uses (lower case, whole words or
  /// phrases): loss, guilt, urgency and scarcity.
  const denied = [
    // Loss.
    'lose', 'loses', 'losing', 'lost', 'loss', 'reset', 'resets', 'break',
    'breaks', 'broke', 'broken', 'gone', 'miss', 'missed', 'missing',
    'keep your', 'save your', 'saved', 'saving', 'ruin', 'ruined',
    // Guilt.
    "don't", 'do not', 'dont', 'forget', 'forgot', 'forgotten', 'shame',
    'sad', 'disappoint', 'disappointed', 'let down', 'abandon', 'miss you',
    // Urgency.
    'hurry', 'quick', 'quickly', 'now', 'before', 'expire', 'expires',
    'expired', 'ends', 'ending', 'deadline', 'last chance', 'today only',
    'running out', 'run out', 'soon',
    // Scarcity.
    'only', 'left', 'limited', 'rare', 'exclusive', 'while it lasts',
    'last one',
  ];

  /// copy.md m7-3's rival lines use words the lists deny, about the
  /// computer, never the player (phase 4 decision on Q-P4-2; lead note 10):
  /// each is exempt for that key and word only, with the reason it isn't the
  /// wording the rule is about. Any other key, or any other word in these
  /// keys, is still checked.
  const exemptions = <String, Map<String, String>>{
    'raceRivalSkill': {
      'slow':
          "the computer rival's own pace (\"Relaxed · Slow\"), shown before "
          'a race to pick an easy one; never said of the player',
      'quick':
          "rival 3's pace (\"Careful · Quick\"), the computer's, not a "
          'hurry for the player: no timer or countdown exists',
    },
    'raceRivalBlurb': {
      'before':
          "rival 2's personality (\"Checks each move twice before it makes "
          'it"): the order of its own thinking, not a deadline',
      'quick':
          "rival 3's personality (\"Quick, tidy and hard to catch\"), the "
          "computer's pace, not urgency for the player",
    },
    'raceLeaveBody': {
      'ends':
          'the confirm says what Leave race does ("The race ends here"): '
          'information the player asked for, not a deadline',
      'lost':
          '"nothing lost": it reassures that leaving costs nothing '
          '(spec-prop §7.7), the opposite of loss framing',
    },
    'raceWinBody': {
      'before':
          '"before {rival}": the player finished first; it names the '
          'result, not a time limit',
    },
  };

  bool exempt(String key, String word) =>
      exemptions[key]?.containsKey(word) ?? false;

  List<String> checkedKeys() => [
    for (final key in arb.keys)
      if (!key.startsWith('@') &&
          checkedPrefixes.any((prefix) => key.startsWith(prefix)))
        key,
  ];

  test('the checked key families exist', () {
    final keys = checkedKeys();
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
  });

  test('no streak, freeze or chest string uses loss, guilt, urgency or '
      'scarcity wording', () {
    final offences = <String>[];
    for (final key in checkedKeys()) {
      final value = (arb[key]! as String).toLowerCase();
      for (final word in denied) {
        if (exempt(key, word)) continue;
        final pattern = RegExp('(^|[^a-z])${RegExp.escape(word)}(\$|[^a-z])');
        if (pattern.hasMatch(value)) offences.add('$key: "$word" in "$value"');
      }
    }
    expect(offences, isEmpty);
  });

  test('each exemption is still needed, and scoped to its key', () {
    // A copy change that drops the word should drop the exemption too.
    for (final MapEntry(key: key, value: words) in exemptions.entries) {
      final value = (arb[key]! as String).toLowerCase();
      for (final word in words.keys) {
        expect(
          RegExp('(^|[^a-z])${RegExp.escape(word)}(\$|[^a-z])').hasMatch(value),
          isTrue,
          reason: '$key no longer says "$word": drop its exemption',
        );
        expect(words[word], isNotEmpty, reason: '$key "$word" needs a reason');
      }
    }
    // Scoped: the same word in another race key still offends.
    expect(exempt('raceLossBody', 'lost'), isFalse);
    expect(exempt('raceStart', 'quick'), isFalse);
  });

  test('the deny-list catches the copy M7 rewrote', () {
    bool offends(String text) => denied.any(
      (word) => RegExp(
        '(^|[^a-z])${RegExp.escape(word)}(\$|[^a-z])',
      ).hasMatch(text.toLowerCase()),
    );
    expect(offends('Play today to keep your streak'), isTrue);
    expect(offends('Streak saved!'), isTrue);
    expect(offends('0 left'), isTrue);
    expect(offends("Don't lose your streak!"), isTrue);
    expect(offends('Play today to add to your streak'), isFalse);
    expect(offends('Freeze used'), isFalse);
  });

  /// Every string a race shows (m7-design P2.11; spec-prop §7.7, §1.1
  /// rules 3–5): the race's own keys and the ones its screens reuse.
  const raceSurfaceKeys = [
    'raceSelectTitle',
    'raceSelectSubtitle',
    'raceComputerTag',
    'raceRivalName',
    'raceRivalBlurb',
    'raceRivalSkill',
    'raceRivalReward',
    'raceRivalLocked',
    'raceRivalNew',
    'raceRivalSemantics',
    'raceStart',
    'raceStartHint',
    'raceStripReady',
    'raceStripThinking',
    'raceStripStartingOver',
    'raceStripFinished',
    'raceStripPlayerFinished',
    'raceStripFamilies',
    'raceStripSemantics',
    'raceAnnounceStart',
    'raceAnnounceFamily',
    'raceAnnounceStartingOver',
    'raceAnnounceFinished',
    'raceAnnounceWon',
    'raceAnnounceLost',
    'raceWinTitle',
    'raceWinBody',
    'raceWinCoins',
    'raceLossTitle',
    'raceLossBody',
    'raceRivalUnlockedTitle',
    'raceRivalUnlockedBody',
    'raceRematch',
    'raceNewRace',
    'raceBackToRivals',
    'raceFailedTitle',
    'raceFailedBody',
    'racePauseHeader',
    'racePauseSubtitle',
    'raceLeaveTitle',
    'raceLeaveBody',
    'raceLeaveKeep',
    'raceQuit',
    // Reused on the race's screens (P2.11 "Reused, no new key").
    'homeVsComputerTile',
    'homeVsComputerLocked',
    'recordsRacesHeader',
    'winCoins',
    'winMovesOnly',
    'oomUndoFreeUnlimited',
    'retry',
  ];

  /// What a computer rival never says to the player (vs-computer rule 10:
  /// a loss is warm; brainstorm §5 question 5: nothing shames a loss).
  const taunts = [
    'loser',
    'too slow',
    'slow',
    'slowpoke',
    'beat you',
    'beaten',
    'crushed',
    'destroyed',
    'easy win',
    'try harder',
    'give up',
    'gave up',
    'fail',
    'failed',
    'failure',
    'defeat',
    'defeated',
    'pathetic',
    'weak',
    'haha',
    'ha ha',
    'nice try',
    'better luck',
    'you lost',
    'you lose',
    'embarrass',
    'humiliat',
    'noob',
    'gg',
  ];

  bool matchesAny(List<String> words, String text) => words.any(
    (word) =>
        RegExp('(^|[^a-z])${RegExp.escape(word)}').hasMatch(text.toLowerCase()),
  );

  test('every string a race shows is free of taunting, loss, guilt, '
      'urgency and scarcity wording', () {
    final offences = <String>[];
    for (final key in raceSurfaceKeys) {
      expect(arb.containsKey(key), isTrue, reason: 'missing "$key"');
      final value = arb[key]! as String;
      for (final word in [...taunts, ...denied]) {
        if (exempt(key, word)) continue;
        final pattern = RegExp('(^|[^a-z])${RegExp.escape(word)}(\$|[^a-z])');
        if (pattern.hasMatch(value.toLowerCase())) {
          offences.add('$key: "$word" in "$value"');
        }
      }
    }
    expect(offences, isEmpty);
  });

  /// What a star string never says (star-rating.md "Keeping a 1★ win a
  /// win"; brainstorm §5 question 5): a win is never graded as a failure.
  /// On top of [denied] ("only", "missed" …), which already covers them.
  const starDenied = [
    'fail',
    'failed',
    'failure',
    'try again',
    'poor',
    'bad',
    'wrong',
    'not enough',
    'too many',
  ];

  test('no star string grades a win as a failure (m7-design P3.12)', () {
    final offences = <String>[];
    for (final key in checkedKeys()) {
      if (!const [
        'stars',
        'winStars',
        'chaptersStars',
        'recordsStars',
        'recordsThreeStar',
      ].any(key.startsWith)) {
        continue;
      }
      final value = (arb[key]! as String).toLowerCase();
      for (final word in starDenied) {
        final pattern = RegExp('(^|[^a-z])${RegExp.escape(word)}(\$|[^a-z])');
        if (pattern.hasMatch(value)) offences.add('$key: "$word" in "$value"');
      }
    }
    expect(offences, isEmpty);
    expect(
      ['Only 1 star', 'You missed 3 stars', 'Try again for 3 stars'].where((
        text,
      ) {
        final lower = text.toLowerCase();
        return [...denied, ...starDenied].any(
          (word) => RegExp(
            '(^|[^a-z])${RegExp.escape(word)}(\$|[^a-z])',
          ).hasMatch(lower),
        );
      }),
      hasLength(3),
      reason: 'the lists catch a shaming star line',
    );
  });

  test('the reminder never mentions a streak (spec-prop §7.9)', () {
    final keys = [
      for (final key in arb.keys)
        if (!key.startsWith('@') &&
            (key.startsWith('reminder') || key.startsWith('settingReminder')))
          key,
    ];
    expect(keys, contains('reminderNotificationBody'));
    for (final key in keys) {
      expect(
        (arb[key]! as String).toLowerCase(),
        isNot(contains('streak')),
        reason: key,
      );
    }
  });

  test('the taunt list catches a taunting loss', () {
    expect(matchesAny(taunts, 'Too slow!'), isTrue);
    expect(matchesAny(taunts, 'Better luck next time'), isTrue);
    expect(matchesAny(taunts, 'You lost to the computer'), isTrue);
    expect(matchesAny(taunts, 'The computer finished first'), isFalse);
    expect(matchesAny(taunts, 'So close! Rematch?'), isFalse);
  });
}
