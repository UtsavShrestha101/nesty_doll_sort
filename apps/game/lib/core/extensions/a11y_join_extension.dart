import 'package:nesty_game/l10n/app_localizations.dart';

/// Folds the parts of one screen-reader label through the ARB's two
/// separators (`a11yJoinList`, `a11yJoinSentences`), so each language writes
/// its own punctuation (Japanese uses 、 and 。). No part of a label is
/// joined with English punctuation in code (l10n.md §1.2).
extension A11yJoin on AppLocalizations {
  /// [parts] as a list: "first, second, third". Empty parts are skipped.
  String joinList(Iterable<String> parts) =>
      _fold(parts, (first, second) => a11yJoinList(first, second));

  /// [parts] as sentences: "First. Second. Third". Empty parts are skipped,
  /// and a part that already ends a sentence keeps its own mark: a full stop
  /// (. 。 ।) gets no second one, and ! or ? takes none after it ("Streak
  /// relit! 5 days"). With [closing] the last sentence ends in the
  /// language's full stop too ("First. Second."). The stop and the gap after
  /// it are read off `a11yJoinSentences`, so a language writes its own
  /// (Hindi "। ", Japanese "。" with no gap).
  String joinSentences(Iterable<String> parts, {bool closing = false}) {
    final separator = a11yJoinSentences(
      '\u0001',
      '\u0002',
    ).replaceAll('\u0001', '').replaceAll('\u0002', '');
    final gap = separator.substring(separator.trimRight().length);
    final all = _fold(
      parts,
      (first, second) => _endsSentence(first)
          ? '$first$gap$second'
          : a11yJoinSentences(first, second),
    );
    if (!closing || all.isEmpty || _endsSentence(all)) return all;
    return '$all${separator.trim()}';
  }

  static String _fold(
    Iterable<String> parts,
    String Function(String first, String second) join,
  ) {
    var all = '';
    for (final part in parts) {
      if (part.isEmpty) continue;
      all = all.isEmpty ? part : join(all, part);
    }
    return all;
  }

  /// The marks that end a sentence in the launch locales: the full stops
  /// (Latin, Japanese, Devanagari) and the half- and full-width ! and ?.
  static const _sentenceEnds = ['.', '。', '।', '!', '?', '！', '？'];

  static bool _endsSentence(String text) => _sentenceEnds.any(text.endsWith);
}
