import 'arb_file.dart';
import 'icu.dart';
import 'locale_rules.dart';

/// The l10n checkers (build/m7-p5/p5/l10n.md §3, §5.2–§5.4). Each returns
/// its problems as lines (`<code> <key>: what`), empty when the file
/// passes, so a test can print them all at once and a self-test can feed
/// a bad synthetic catalog and expect a line.

// ── Key families ─────────────────────────────────────────────────────────

/// The respect rule's key families (E1, D92): the daily streak, its
/// freezes and chests, the milestone chest, the streak's records row,
/// NotEnoughCoinsDialog, vs Computer, the reminder, the share card and the
/// stars. `notNow` stays out ("Not now" is the opposite of urgency).
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
  'race',
  'hudRace',
  'reminder',
  'settingReminder',
  'dailyShare',
  'stars',
  'winStars',
  'chaptersStars',
  'recordsStars',
  'recordsThreeStar',
];

/// The star keys, held to [LocaleRules.starDenied] on top.
const starPrefixes = [
  'stars',
  'winStars',
  'chaptersStars',
  'recordsStars',
  'recordsThreeStar',
];

/// The reminder's keys, which never name the streak (spec-prop §7.9).
const reminderPrefixes = ['reminder', 'settingReminder'];

/// Every string a race shows (m7-design P2.11): its own keys and the ones
/// its screens reuse, held to the taunts as well as the denied words.
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
  'raceRivalCardSemantics',
  'raceRivalLockedSemantics',
  'raceRivalSelectedSemantics',
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
  'raceRivalUnlockedRace',
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

/// The rival surfaces that name the computer in English, pinned so the
/// derived set ([computerKeys]) can't shrink unseen: the 11 keys of
/// `arb_keys_m7_test.dart` plus Home's and Records' race labels (l10n.md
/// §7.1).
const pinnedComputerKeys = [
  'raceComputerTag',
  'raceRivalSemantics',
  'raceStripSemantics',
  'raceAnnounceStart',
  'raceAnnounceFamily',
  'raceAnnounceStartingOver',
  'raceAnnounceFinished',
  'raceAnnounceLost',
  'racePauseHeader',
  'raceSelectTitle',
  'homeVsComputerTile',
  'homeVsComputerSemantics',
  'recordsRaceSemantics',
  'recordsRaceLockedSemantics',
];

/// The plurals that are a number switch, not a count: rival 1, 2, 3
/// (l10n.md §5.2 rule 2). Every locale keeps exactly `=1`, `=2`, `other`.
const rivalSwitchKeys = ['raceRivalName', 'raceRivalBlurb', 'raceRivalSkill'];

/// Plurals that spell their small numbers as words (§5.2 rule 3): their
/// count is never 0 where `=1` would show, or they have `=0`.
const spelledPluralKeys = ['extraSlotLimitToast', 'dailyFreezes'];

/// Values that may equal English in every locale: the brand and pure
/// formats (l10n.md §5.4). A value with no letters at all is allowed too.
const globalIdenticalAllowed = {
  'appName',
  'reminderNotificationTitle',
  'progressPercent',
  'familyCounter',
  'winChapterProgress',
  'homeMuseumProgress',
  'museumCount',
  'raceStripFamilies',
  'chaptersStarsTotal',
  'recordsBadgesCount',
  'winCoins',
  'introTowersBuriedTag',
  'introIceCount',
  'boardTowerHidden',
  'boardIceCount',
  'hintGainedTag',
  'dailyShareGlyph',
};

/// The counts the plural shape check tries (l10n.md §5.4).
const shapeCounts = [0, 1, 2, 3, 5, 11, 21, 101, 1000000];

Iterable<String> keysWithPrefix(ArbFile file, List<String> prefixes) =>
    file.keys.where((key) => prefixes.any(key.startsWith));

// ── File and key set ─────────────────────────────────────────────────────

/// `@@locale` matches the file name, a translation carries no `@key`
/// blocks (descriptions stay in English), and every value is a string.
List<String> checkFileShape(ArbFile file) {
  final problems = <String>[];
  final tag = file.localeTag;
  if (file.code != 'en' || tag != null) {
    if (tag != file.code) {
      problems.add(
        '${file.code}: @@locale is ${tag == null ? 'missing' : '"$tag"'}, '
        'the file name says "${file.code}"',
      );
    }
  }
  if (file.code != 'en') {
    for (final key in file.metadataKeys) {
      problems.add('${file.code} $key: a translation has no @key blocks');
    }
  }
  for (final key in file.keys) {
    if (file.json[key] is! String) {
      problems.add('${file.code} $key: the value is not a string');
    }
  }
  return problems;
}

/// Every English key is translated and no key is extra; `pt_BR` (only its
/// `@@locale`, falling back to `pt`) may hold a subset.
List<String> checkKeySet(ArbFile english, ArbFile file) {
  final englishKeys = english.keys.toSet();
  final keys = file.keys.toSet();
  return [
    if (file.code != 'pt_BR')
      for (final key in englishKeys.difference(keys))
        '${file.code} $key: missing (every English key is translated)',
    for (final key in keys.difference(englishKeys))
      '${file.code} $key: not an English key',
  ];
}

// ── One message ──────────────────────────────────────────────────────────

/// [key]'s value in [file] against English: it parses; it references the
/// same placeholders; every plural has `other`, uses only the locale's
/// CLDR keywords plus `=0`, `=1`, `=2`, gives no parameter twice, and in a
/// locale whose `one` takes 0 carries no literal digit in `one`; a plural
/// is added only on a number; the rival switches stay `=1 =2 other`;
/// selects keep English's cases and `other`; no translator marker (`TODO`,
/// `XXX` …); ranges keep "–".
List<String> checkMessage(
  ArbFile english,
  ArbFile file,
  String key,
  LocaleRules rules,
) {
  final value = file[key];
  final source = english[key];
  if (value == null || source == null) return const [];
  final where = '${file.code} $key';
  final List<IcuNode> nodes;
  final List<IcuNode> englishNodes;
  try {
    englishNodes = english.parse(key);
  } on IcuFormatException catch (error) {
    return ['en $key: $error'];
  }
  try {
    nodes = file.parse(key);
  } on IcuFormatException catch (error) {
    return ['$where: $error'];
  }
  final problems = <String>[];

  final expected = referencedPlaceholders(englishNodes);
  final actual = referencedPlaceholders(nodes);
  for (final name in expected.difference(actual)) {
    problems.add('$where: placeholder {$name} is missing');
  }
  for (final name in actual.difference(expected)) {
    problems.add('$where: placeholder {$name} is not in English');
  }

  final englishPlurals = {
    for (final plural in choicesIn(englishNodes, IcuChoiceKind.plural))
      plural.name,
  };
  for (final plural in choicesIn(nodes, IcuChoiceKind.plural)) {
    problems.addAll(_checkPlural(where, plural, rules, key, englishNodes));
    if (!englishPlurals.contains(plural.name) &&
        !_isNumber(english, key, plural.name)) {
      problems.add(
        '$where: a plural on {${plural.name}}, which is not a number',
      );
    }
  }

  if (rivalSwitchKeys.contains(key)) {
    for (final plural in choicesIn(nodes, IcuChoiceKind.plural)) {
      final keys = plural.keys.toList()..sort();
      if (keys.join(' ') != '=1 =2 other') {
        problems.add(
          '$where: the rival switch must be exactly =1, =2, other '
          '(found ${plural.keys.join(', ')})',
        );
      }
    }
  }

  final englishSelects = _selectCases(englishNodes);
  final selects = _selectCases(nodes);
  for (final MapEntry(key: name, value: cases) in selects.entries) {
    final want = englishSelects[name];
    if (want == null) {
      problems.add('$where: a select on {$name}, which English has not');
      continue;
    }
    for (final extra in cases.difference(want)) {
      problems.add('$where: select {$name} has a case "$extra" English lacks');
    }
    for (final missing in want.difference(cases)) {
      problems.add('$where: select {$name} lacks English\'s case "$missing"');
    }
  }
  for (final name in englishSelects.keys) {
    if (!selects.containsKey(name)) {
      problems.add('$where: the select on {$name} is gone');
    }
  }

  if (RegExp(r'\b(TODO|TRANSLATE|XXX|FIXME)\b').hasMatch(value)) {
    problems.add('$where: a translation marker is left in "$value"');
  }
  if (source.contains('–') && !value.contains('–')) {
    problems.add(
      '$where: the range lost its en dash "–" (U+2013), which the app '
      'joins with word joiners',
    );
  }
  return problems;
}

bool _isNumber(ArbFile english, String key, String placeholder) {
  final meta = english.json['@$key'];
  if (meta is! Map<String, Object?>) return false;
  final placeholders = meta['placeholders'];
  if (placeholders is! Map<String, Object?>) return false;
  final entry = placeholders[placeholder];
  if (entry is! Map<String, Object?>) return false;
  return const {'int', 'num', 'double'}.contains(entry['type']);
}

Map<String, Set<String>> _selectCases(List<IcuNode> nodes) {
  final cases = <String, Set<String>>{};
  for (final select in choicesIn(nodes, IcuChoiceKind.select)) {
    cases.putIfAbsent(select.name, () => {}).addAll(select.keys);
  }
  return cases;
}

List<String> _checkPlural(
  String where,
  IcuChoice plural,
  LocaleRules rules,
  String key,
  List<IcuNode> englishNodes,
) {
  final problems = <String>[];
  final name = '{${plural.name}}';
  if (!plural.keys.contains('other')) {
    problems.add('$where: plural $name has no "other"');
  }
  final seen = <String, String>{};
  for (final branch in plural.keys) {
    final parameter = pluralParameterOf(branch);
    if (parameter == null) {
      problems.add(
        '$where: plural $name has "$branch"; gen-l10n takes =0, =1, =2, '
        'zero, one, two, few, many and other',
      );
      continue;
    }
    if (!branch.startsWith('=') &&
        branch != 'other' &&
        !rules.pluralCategories.contains(branch)) {
      problems.add(
        '$where: plural $name uses "$branch", not a CLDR category of '
        '${rules.code} (${rules.pluralCategories.join(', ')})',
      );
    }
    final earlier = seen[parameter];
    if (earlier != null) {
      problems.add(
        '$where: plural $name has both "$earlier" and "$branch"; gen-l10n '
        'keeps the first and drops the second',
      );
    }
    seen.putIfAbsent(parameter, () => branch);
  }
  // §5.2 rule 1: where `one` takes 0, `one` (or `=1`, which gen-l10n
  // turns into `one`) carries the number, unless an `=0` branch catches 0
  // first. A `one` without `{var}` is wrong when it spells a digit ("1
  // pièce" for 0), or when English shows the number in that plural; a pure
  // grammar switch ("est" / "sont") may leave it out.
  if (rules.oneIncludesZero &&
      !rivalSwitchKeys.contains(key) &&
      !spelledPluralKeys.contains(key) &&
      seen['zero'] == null) {
    final oneKey = seen['one'];
    final body = oneKey == null ? null : plural.branch(oneKey);
    if (body != null && !referencedPlaceholders(body).contains(plural.name)) {
      final digit = RegExp(r'\d').hasMatch(readableText(body));
      final englishShows = choicesIn(englishNodes, IcuChoiceKind.plural).any(
        (english) =>
            english.name == plural.name &&
            referencedPlaceholders(
              english.branch('other') ?? const [],
            ).contains(plural.name),
      );
      if (digit || englishShows) {
        problems.add(
          '$where: plural $name\'s "$oneKey" is shown for 0 too in '
          '${rules.code} but ${digit ? 'spells a literal digit' : 'hides the number'}'
          '; write one{{${plural.name}} …}',
        );
      }
    }
  }
  return problems;
}

// ── Plural shapes ────────────────────────────────────────────────────────

/// For each count of [shapeCounts], wherever English's branch shows the
/// number, the branch [file]'s locale picks (gen-l10n + `Intl.pluralLogic`,
/// [pickPluralBranch]) must show it too: `{var}` or the digits. This is
/// the =1 → one trap of §5.2 (fr, pt, hi print "1 …" for 0).
List<String> checkPluralShape(ArbFile english, ArbFile file, String key) {
  if (rivalSwitchKeys.contains(key)) return const [];
  final List<IcuNode> englishNodes;
  final List<IcuNode> nodes;
  try {
    englishNodes = english.parse(key);
    nodes = file.parse(key);
  } on IcuFormatException {
    return const []; // checkMessage reports it.
  }
  final problems = <String>[];
  for (final plural in choicesIn(englishNodes, IcuChoiceKind.plural)) {
    final mine = choicesIn(
      nodes,
      IcuChoiceKind.plural,
    ).where((p) => p.name == plural.name).toList();
    for (final count in shapeCounts) {
      if (count == 0 && spelledPluralKeys.contains(key)) continue;
      final englishBranch = plural.branch(
        pickPluralBranch(plural, count, 'en'),
      )!;
      if (!_shows(englishBranch, plural.name, count)) continue;
      for (final local in mine) {
        final pick = pickPluralBranch(local, count, file.localeName);
        final body = local.branch(pick);
        if (body == null || !_shows(body, plural.name, count)) {
          problems.add(
            '${file.code} $key: at {${plural.name}} = $count the app shows '
            '"$pick" (${body == null ? 'missing' : bodyText(body).trim()}), '
            'which hides the number English shows',
          );
        }
      }
    }
  }
  return problems;
}

bool _shows(List<IcuNode> body, String name, int count) =>
    referencedPlaceholders(body).contains(name) ||
    RegExp('(?<!\\d)$count(?!\\d)').hasMatch(readableText(body));

/// Keys whose translation is over [ratio]× the English length (readable
/// text), for the reviewers (l10n.md §5.4).
List<String> lengthReport(ArbFile english, ArbFile file, {double ratio = 1.5}) {
  final lines = <String>[];
  for (final key in file.keys) {
    if (english[key] == null) continue;
    try {
      final from = readableText(english.parse(key)).trim().length;
      final to = readableText(file.parse(key)).trim().length;
      if (from > 0 && to > from * ratio) {
        lines.add('${file.code} $key: $to vs $from characters');
      }
    } on IcuFormatException {
      continue;
    }
  }
  return lines;
}

// ── Identical to English ─────────────────────────────────────────────────

/// No value equals English unless the brand or a pure format
/// ([globalIdenticalAllowed], or no letters at all) or the locale's
/// [LocaleRules.identicalAllowed], each still needed.
List<String> checkIdentical(ArbFile english, ArbFile file, LocaleRules rules) {
  if (file.code == 'en') return const [];
  final problems = <String>[];
  for (final key in file.keys) {
    final source = english[key];
    if (source == null || file[key] != source) continue;
    if (globalIdenticalAllowed.contains(key) ||
        rules.identicalAllowed.containsKey(key)) {
      continue;
    }
    if (!RegExp(r'\p{L}', unicode: true).hasMatch(_safeReadable(file, key))) {
      continue;
    }
    problems.add(
      '${file.code} $key: identical to English ("$source"); translate it '
      'or allow it in locales/${rules.code}.dart with a reason',
    );
  }
  for (final MapEntry(key: key, value: reason)
      in rules.identicalAllowed.entries) {
    if (english[key] == null) {
      problems.add('${rules.code} $key: identicalAllowed names no English key');
    } else if (reason.trim().isEmpty) {
      problems.add('${rules.code} $key: identicalAllowed needs a reason');
    } else if (file[key] != null && file[key] != english[key]) {
      problems.add(
        '${file.code} $key: identicalAllowed is no longer needed (the value '
        'differs from English)',
      );
    }
  }
  return problems;
}

String _safeReadable(ArbFile file, String key) {
  try {
    return readableText(file.parse(key));
  } on IcuFormatException {
    return file[key]!;
  }
}

// ── Respect, the computer, human status ──────────────────────────────────

/// The words of [list] that [key]'s value uses in [file], less the
/// locale's exemptions for that key.
List<String> wordOffences(
  LocaleRules rules,
  ArbFile file,
  String key,
  List<String> list,
) {
  if (file[key] == null) return const [];
  final exempt = rules.exemptions[key]?.keys.toSet() ?? const <String>{};
  final text = _safeReadable(file, key);
  return [
    for (final word in rules.offences(list, text))
      if (!exempt.contains(word)) word,
  ];
}

/// The respect rules for one catalog (l10n.md §3.2): the checked families
/// against the denied words, every race string against the taunts too,
/// the stars against the star words, and the reminder against the streak.
List<String> respectOffences(LocaleRules rules, ArbFile file) {
  final problems = <String>[];
  void add(String key, List<String> words, String rule) {
    for (final word in words) {
      problems.add(
        '${file.code} $key: "$word" ($rule) in "${_safeReadable(file, key).trim()}"',
      );
    }
  }

  for (final key in keysWithPrefix(file, checkedPrefixes)) {
    add(
      key,
      wordOffences(rules, file, key, rules.denied),
      'loss, guilt, '
      'urgency or scarcity',
    );
  }
  for (final key in raceSurfaceKeys) {
    add(key, wordOffences(rules, file, key, rules.taunts), 'a taunt');
    if (!checkedPrefixes.any(key.startsWith)) {
      add(
        key,
        wordOffences(rules, file, key, rules.denied),
        'loss, guilt, '
        'urgency or scarcity',
      );
    }
  }
  for (final key in keysWithPrefix(file, starPrefixes)) {
    add(
      key,
      wordOffences(rules, file, key, rules.starDenied),
      'a star line '
      'grading a win as a failure',
    );
  }
  for (final key in keysWithPrefix(file, reminderPrefixes)) {
    add(
      key,
      rules.offences(rules.streakWords, _safeReadable(file, key)),
      'the reminder names the streak',
    );
  }
  return problems;
}

/// A locale's exemptions are only for [LocaleRules.exemptableKeys], only
/// for words on its own lists, and each is still needed by its value.
List<String> exemptionProblems(LocaleRules rules, ArbFile? file) {
  final problems = <String>[];
  for (final MapEntry(key: key, value: words) in rules.exemptions.entries) {
    if (!LocaleRules.exemptableKeys.contains(key)) {
      problems.add(
        '${rules.code} $key: no exemption allowed here (only '
        '${LocaleRules.exemptableKeys.join(', ')})',
      );
      continue;
    }
    for (final MapEntry(key: word, value: reason) in words.entries) {
      if (!rules.denied.contains(word) && !rules.taunts.contains(word)) {
        problems.add('${rules.code} $key: "$word" is on no list to exempt');
      }
      if (reason.trim().isEmpty) {
        problems.add('${rules.code} $key: "$word" needs a reason');
      }
      if (file != null &&
          file[key] != null &&
          !rules.matches(word, _safeReadable(file, key))) {
        problems.add(
          '${rules.code} $key: the "$word" exemption is no longer needed',
        );
      }
    }
  }
  return problems;
}

/// The English keys that name the computer: [pinnedComputerKeys] plus
/// every value with the word.
Set<String> computerKeys(ArbFile english, LocaleRules englishRules) => {
  ...pinnedComputerKeys,
  for (final key in english.keys)
    if (englishRules.namesComputer(_safeReadable(english, key))) key,
};

/// Every rival surface names the computer in [file]'s language (spec-prop
/// §1.1 rule 5): a select's case where English names it, else the value.
List<String> computerOffences(
  ArbFile english,
  LocaleRules englishRules,
  ArbFile file,
  LocaleRules rules,
) {
  final problems = <String>[];
  for (final key in computerKeys(english, englishRules)) {
    if (file[key] == null) continue;
    final List<IcuNode> englishNodes;
    final List<IcuNode> nodes;
    try {
      englishNodes = english.parse(key);
      nodes = file.parse(key);
    } on IcuFormatException {
      continue; // checkMessage reports it.
    }
    final englishSelect = _wholeSelect(englishNodes);
    final select = _wholeSelect(nodes);
    if (englishSelect != null && select != null) {
      for (final branch in englishSelect.branches) {
        if (!englishRules.namesComputer(readableText(branch.body))) continue;
        final body = select.branch(branch.key);
        if (body == null || !rules.namesComputer(readableText(body))) {
          problems.add(
            '${file.code} $key[${branch.key}]: does not say '
            '"${rules.computerStem}"',
          );
        }
      }
    } else if (!rules.namesComputer(readableText(nodes))) {
      problems.add(
        '${file.code} $key: does not say "${rules.computerStem}" '
        '("${readableText(nodes).trim()}")',
      );
    }
  }
  return problems;
}

IcuChoice? _wholeSelect(List<IcuNode> nodes) => switch (nodes) {
  [IcuChoice(kind: IcuChoiceKind.select) && final select] => select,
  _ => null,
};

/// The race's keys, which name no human status (vs-computer rule 11).
List<String> humanStatusOffences(LocaleRules rules, ArbFile file) => [
  for (final key in {
    ...keysWithPrefix(file, const ['race', 'hudRace']),
  })
    for (final word in rules.offences(
      rules.humanStatus,
      _safeReadable(file, key),
    ))
      '${file.code} $key: "$word" reads as a human status',
];
