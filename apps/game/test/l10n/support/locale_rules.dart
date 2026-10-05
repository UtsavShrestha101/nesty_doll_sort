/// One locale's string rules (build/m7-p5/p5/l10n.md §3.2, §5.1): its CLDR
/// plural categories, the respect rules' word lists in its own language,
/// the word that names the computer rival, and what the parity check may
/// let through. Each locale has its file in `test/l10n/locales/<code>.dart`;
/// its translator refines the lists, and its reviewer extends them.
library;

/// How a locale's list entries match its copy (§3.2 item 3).
enum MatchMode {
  /// Whole words between letter boundaries (`\p{L}\p{M}`), case-folded. An
  /// entry ending in `*` is a stem (a prefix); an entry ending in `~`
  /// matches anywhere, inside a compound too (German).
  words,

  /// Every entry is a stem: Turkish (agglutinative) lists only stems, and
  /// case-folds the Turkish way (İ→i, I→ı) first.
  turkishStems,

  /// Indonesian: whole words that may carry an enclitic or a particle
  /// (-nya, -lah, -kah, -pun, -mu, -ku); `*` is still a stem. Affixed
  /// forms (ke-…-an, ber-, me-) are listed as their own entries, so "kalah"
  /// never matches "kalahkan" ("beat").
  indonesian,

  /// Devanagari: [words] after the nukta is stripped (U+093C, and
  /// U+0958–095F to their base letters) from both sides.
  devanagari,

  /// Japanese: substrings (no word boundaries); markers are ignored.
  substrings,
}

/// Why a value may equal its English one in a locale (a loanword, a brand).
typedef IdenticalReason = String;

final class LocaleRules {
  const LocaleRules({
    required this.code,
    required this.pluralCategories,
    required this.match,
    required this.denied,
    required this.taunts,
    required this.starDenied,
    required this.streakWords,
    required this.computerStem,
    required this.humanStatus,
    this.oneIncludesZero = false,
    this.exemptions = const {},
    this.identicalAllowed = const {},
  });

  /// The ARB file's locale (`app_<code>.arb`), e.g. `fr` or `pt`.
  final String code;

  /// CLDR's integer plural categories (§5.1). A plural in this locale may
  /// use these keywords, `=0`, `=1`, `=2` and `other`.
  final Set<String> pluralCategories;

  /// CLDR's `one` takes 0 too (fr, pt, hi): gen-l10n's `=1` then shows for
  /// 0 (§5.2), so `one` must carry the number.
  final bool oneIncludesZero;

  final MatchMode match;

  /// Loss, guilt, urgency and scarcity wording (§3.3; the English list is
  /// E1's respect list, D92).
  final List<String> denied;

  /// What a computer rival never says (vs-computer rule 10).
  final List<String> taunts;

  /// A star line never grades a win as a failure (star-rating.md).
  final List<String> starDenied;

  /// The reminder never names the streak (spec-prop §7.9).
  final List<String> streakWords;

  /// The word for "computer" (case-insensitive substring) every rival
  /// surface keeps (spec-prop §1.1 rule 5).
  final String computerStem;

  /// A computer rival never shows a human status (vs-computer rule 11).
  final List<String> humanStatus;

  /// Key → the words of [denied] or [taunts] that key may use, with why.
  /// Only [exemptableKeys] may appear, and each word must still be needed.
  final Map<String, Map<String, String>> exemptions;

  /// Key → why its value may equal English (a loanword such as de "Museum").
  final Map<String, IdenticalReason> identicalAllowed;

  /// The only keys any locale may exempt a word in (§3.2 item 4): the four
  /// rival and race lines whose meaning needs a "slow", "quick", "before",
  /// "ends" or "lost" word. copy.md m7-4 rewrote English so it needs none.
  static const exemptableKeys = {
    'raceRivalSkill',
    'raceRivalBlurb',
    'raceLeaveBody',
    'raceWinBody',
  };

  /// [text] folded for matching in this locale.
  String fold(String text) {
    var folded = text
        .replaceAll('’', "'")
        .replaceAll('ʼ', "'")
        .replaceAll(RegExp('[   ⁠]'), ' ');
    if (match == MatchMode.turkishStems) {
      folded = folded.replaceAll('İ', 'i').replaceAll('I', 'ı');
    }
    folded = folded.toLowerCase();
    if (match == MatchMode.devanagari) folded = stripNukta(folded);
    return folded;
  }

  /// Whether [entry] (a list entry, with its `*` or `~` marker) occurs in
  /// [text].
  bool matches(String entry, String text) =>
      _patternFor(entry).hasMatch(fold(text));

  /// The entries of [list] that occur in [text].
  List<String> offences(List<String> list, String text) {
    final folded = fold(text);
    return [
      for (final entry in list)
        if (_patternFor(entry).hasMatch(folded)) entry,
    ];
  }

  /// [text] names the computer.
  bool namesComputer(String text) => fold(text).contains(fold(computerStem));

  static const _before = r'(?<![\p{L}\p{M}])';
  static const _after = r'(?![\p{L}\p{M}])';
  static const _indonesianClitics = '(?:nya|lah|kah|pun|mu|ku)?';

  RegExp _patternFor(String entry) {
    var word = entry;
    var stem = false;
    var anywhere = false;
    if (word.endsWith('*')) {
      stem = true;
      word = word.substring(0, word.length - 1);
    } else if (word.endsWith('~')) {
      anywhere = true;
      word = word.substring(0, word.length - 1);
    }
    final body = fold(
      word,
    ).split(RegExp(r'\s+')).map(RegExp.escape).join(r'\s+');
    final source = switch (match) {
      MatchMode.substrings => body,
      _ when anywhere => body,
      MatchMode.turkishStems => '$_before$body',
      _ when stem => '$_before$body',
      MatchMode.indonesian => '$_before$body$_indonesianClitics$_after',
      MatchMode.words || MatchMode.devanagari => '$_before$body$_after',
    };
    return RegExp(source, unicode: true);
  }

  /// Devanagari with the nukta dropped, so "ज़्यादा" and "ज्यादा" match the
  /// same entry (§3.2 item 3).
  static String stripNukta(String text) {
    const precomposed = {
      'क़': 'क',
      'ख़': 'ख',
      'ग़': 'ग',
      'ज़': 'ज',
      'ड़': 'ड',
      'ढ़': 'ढ',
      'फ़': 'फ',
      'य़': 'य',
    };
    final out = StringBuffer();
    for (final rune in text.runes) {
      final char = String.fromCharCode(rune);
      if (rune == 0x093C) continue;
      out.write(precomposed[char] ?? char);
    }
    return out.toString();
  }
}
