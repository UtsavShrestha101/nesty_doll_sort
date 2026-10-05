import '../support/locale_rules.dart';

/// English: the template's rules. The lists are E1's respect lists (D92;
/// `test/ethics/respect_copy_test.dart` before phase 5B), moved here
/// unchanged except that the taunts' two stems ("embarrass", "humiliat")
/// and "chat" are marked as stems, which the old per-test regexes left
/// whole-word by accident (the old taunt self-test matched them as
/// prefixes).
const enRules = LocaleRules(
  code: 'en',
  pluralCategories: {'one', 'other'},
  match: MatchMode.words,
  denied: [
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
  ],
  taunts: [
    'loser', 'too slow', 'slow', 'slowpoke', 'beat you', 'beaten', //
    'crushed', 'destroyed', 'easy win', 'try harder', 'give up', 'gave up',
    'fail', 'failed', 'failure', 'defeat', 'defeated', 'pathetic', 'weak',
    'haha', 'ha ha', 'nice try', 'better luck', 'you lost', 'you lose',
    'embarrass*', 'humiliat*', 'noob', 'gg',
  ],
  starDenied: [
    'fail', 'failed', 'failure', 'try again', 'poor', 'bad', 'wrong', //
    'not enough', 'too many',
  ],
  streakWords: ['streak*'],
  computerStem: 'computer',
  humanStatus: ['online', 'typing', 'player 2', 'opponent is', 'chat*'],
);
