import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// The English ARB carries Claude Design's copy.md (m7-4) line for line
/// (phase 5, 5m-copy; the D171 rule that the design's copy is the English
/// source). Every `- <id>: <text>` line of copy.md, and each `one:` and
/// `other:` branch of a plural, must be a string the ARB can say, so a
/// copy change fails here until the ARB follows it. The ARB keeps its own
/// key names (a description cites the copy.md id); this test only compares
/// the words, with each `{placeholder}` standing for any name.
///
/// Run from `apps/game`: it reads `../../design/copy.md`.
void main() {
  late Map<String, Object?> arb;
  late List<_CopyLine> copy;

  setUpAll(() {
    arb =
        jsonDecode(File('lib/l10n/app_en.arb').readAsStringSync())
            as Map<String, Object?>;
    copy = _parseCopy(File('../../design/copy.md').readAsStringSync());
  });

  /// Ids whose English the ARB legitimately words differently, each with
  /// the reason.
  const elsewhere = <String, String>{
    // The price is catalog data (`BundledCatalogRepository`), not a string.
    'forest_bear_price': 'a catalog price, not ARB text',
    // The chip's "3" is `{total}` in the ARB (the step count is data).
    'tut_step_chip': 'STEP {} OF {}',
    // "left" is the respect rules' scarcity word (E1, spec-prop §1.1): the
    // string keeps the rule and drops the word, and asks the owner.
    'a11y_freezes': '{} streak freeze',
  };

  test('copy.md is parsed (a section per heading, plurals as branches)', () {
    expect(copy.length, greaterThan(300));
    expect(
      copy.any((l) => l.section == 'A11y' && l.id == 'a11y_skin_owned'),
      isTrue,
    );
    expect(
      copy.any((l) => l.section == 'Short forms' && l.id == 'win_title_short'),
      isTrue,
    );
    expect(
      copy.where((l) => l.id == 'daily_chest_title').map((l) => l.branch),
      ['one', 'other'],
    );
  });

  test('every copy.md line is in the ARB', () {
    final sayable = <String>{};
    for (final entry in arb.entries) {
      final value = entry.value;
      if (entry.key.startsWith('@') || value is! String) continue;
      sayable.addAll(_leaves(value));
    }
    final missing = <String>[];
    for (final line in copy) {
      final override = elsewhere[line.id];
      if (override != null) {
        if (override.contains('{}')) {
          expect(sayable, contains(override), reason: line.id);
        }
        continue;
      }
      final text = _normalise(line.text);
      // An English `one` branch prints the count as the digit 1, so the
      // ARB's `=1{1 coin}` says the same as copy.md's `one: {count} coin`.
      final asOne = line.branch == 'one'
          ? [
              for (final placeholder in RegExp(
                '{[a-z]+}',
              ).allMatches(line.text).map((m) => m.group(0)!).toSet())
                _normalise(line.text.replaceAll(placeholder, '1')),
            ]
          : const <String>[];
      if (!sayable.contains(text) && !asOne.any(sayable.contains)) {
        missing.add('${line.section} ${line.id}: ${line.text}');
      }
    }
    expect(missing, isEmpty, reason: 'copy.md lines the ARB does not say');
  });

  test('the lines m7-4 withdrew are not in the ARB', () {
    final all = [
      for (final entry in arb.entries)
        if (!entry.key.startsWith('@') && entry.value is String)
          entry.value! as String,
    ];
    for (final old in const [
      // m7-4 rewrote them without "Slow", "Quick", "before", "ends", "lost".
      'Relaxed · Slow',
      'Careful · Slow',
      'Careful · Quick',
      'Checks each move twice before it makes it.',
      'Quick, tidy and hard to catch.',
      'You completed every family before',
      'The race ends here.',
      'nothing lost',
      // Withdrawn ids' English.
      'Levels with 3 stars',
      'Families home',
      // m7-3's own wording for the screen-reader strings.
      'Get more coins',
      'watch an ad for one more',
      'computer player,',
    ]) {
      expect(
        all.where((v) => v.contains(old)),
        isEmpty,
        reason: '"$old" is gone from copy.md',
      );
    }
  });
}

class _CopyLine {
  const _CopyLine(this.section, this.id, this.branch, this.text);

  final String section;
  final String id;

  /// `one` or `other` for a plural's branch, null for a plain line.
  final String? branch;
  final String text;
}

List<_CopyLine> _parseCopy(String source) {
  final lines = <_CopyLine>[];
  String? section;
  String? pluralId;
  for (final line in const LineSplitter().convert(source)) {
    final heading = RegExp(r'^## (.*)$').firstMatch(line);
    if (heading != null) {
      section = heading.group(1)!.trim();
      pluralId = null;
      continue;
    }
    if (section == null || section.startsWith('Changes')) continue;
    final plain = RegExp(r'^- ([a-z0-9_]+):\s*(.*)$').firstMatch(line);
    if (plain != null) {
      final text = plain.group(2)!;
      if (text.isEmpty) {
        pluralId = plain.group(1);
      } else {
        pluralId = null;
        lines.add(_CopyLine(section, plain.group(1)!, null, text));
      }
      continue;
    }
    final branch = RegExp(r'^  - (one|other): (.*)$').firstMatch(line);
    if (branch != null && pluralId != null) {
      lines.add(
        _CopyLine(section, pluralId, branch.group(1), branch.group(2)!),
      );
    }
  }
  return lines;
}

/// `{name}` stands for any placeholder.
String _normalise(String text) =>
    text.replaceAll(RegExp(r'\{[A-Za-z_0-9]+\}'), '{}').trim();

/// Every string an ICU message can say: the whole message and each branch
/// of a plural or select, nested ones flattened to `{}`, and each line of a
/// multi-line message.
Set<String> _leaves(String message) {
  final out = <String>{};
  void collect(String text) {
    final buffer = StringBuffer();
    var i = 0;
    while (i < text.length) {
      if (text[i] != '{') {
        buffer.write(text[i]);
        i++;
        continue;
      }
      final close = _closing(text, i);
      final inner = text.substring(i + 1, close);
      final icu = RegExp(
        r'^\s*\w+\s*,\s*(plural|select)\s*,(.*)$',
        dotAll: true,
      ).firstMatch(inner);
      if (icu != null) {
        var body = icu.group(2)!;
        while (true) {
          final head = RegExp(r'^\s*[^\s{]+\s*\{').firstMatch(body);
          if (head == null) break;
          final end = _closing(body, head.end - 1);
          final branch = body.substring(head.end, end);
          collect(branch);
          body = body.substring(end + 1);
        }
      }
      buffer.write('{}');
      i = close + 1;
    }
    final flat = buffer.toString();
    out.add(_normalise(flat));
    for (final line in flat.split('\n')) {
      out.add(_normalise(line));
    }
  }

  collect(message);
  return out;
}

int _closing(String text, int open) {
  var depth = 0;
  for (var i = open; i < text.length; i++) {
    if (text[i] == '{') depth++;
    if (text[i] == '}') {
      depth--;
      if (depth == 0) return i;
    }
  }
  throw FormatException('Unbalanced braces in "$text"');
}
