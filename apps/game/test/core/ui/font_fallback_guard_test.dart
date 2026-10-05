import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Every `TextStyle` built by hand in `lib/` that names a `fontFamily` also
/// lists `fontFamilyFallback` (tokens fontFallback, l10n.md §4.6). Without it
/// a Devanagari or Japanese string in that style falls to the system font:
/// the wrong face, and tofu on a phone without one. The generated token
/// styles carry it already; this guards the hand-written ones.
void main() {
  test('no hand-built TextStyle names a family without its fallback', () {
    final offenders = <String>[];
    for (final file in Directory('lib').listSync(recursive: true)) {
      if (file is! File || !file.path.endsWith('.dart')) continue;
      final source = file.readAsStringSync();
      for (final match in RegExp(r'\bTextStyle\(').allMatches(source)) {
        final body = _balanced(source, match.end);
        if (body == null) continue;
        if (RegExp(r'\bfontFamily:').hasMatch(body) &&
            !body.contains('fontFamilyFallback:')) {
          final line = '\n'.allMatches(source.substring(0, match.start)).length;
          offenders.add('${file.path}:${line + 1}');
        }
      }
    }
    expect(
      offenders,
      isEmpty,
      reason:
          'Add fontFamilyFallback: AppFontTokens.displayFallback (Fredoka) or '
          'bodyFallback (Nunito) to:\n${offenders.join('\n')}',
    );
  });

  test('the scan sees the styles it guards', () {
    // A style with a family and no fallback is caught; the generated ones
    // (which carry it) are not.
    expect(
      _balanced("TextStyle(fontFamily: 'X', fontSize: 1)", 10),
      contains('fontFamily'),
    );
    final tokens = File(
      'lib/core/ui/tokens/ui_tokens.gen.dart',
    ).readAsStringSync();
    expect(RegExp(r'\bfontFamily:').hasMatch(tokens), isTrue);
  });
}

/// The text of the argument list that starts just after an opening paren at
/// [start] - 1, or null when it never closes.
String? _balanced(String source, int start) {
  var depth = 1;
  for (var i = start; i < source.length; i++) {
    final c = source[i];
    if (c == '(') depth++;
    if (c == ')') {
      depth--;
      if (depth == 0) return source.substring(start, i);
    }
  }
  return null;
}
