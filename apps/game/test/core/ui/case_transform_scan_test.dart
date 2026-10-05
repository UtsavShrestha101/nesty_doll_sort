import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// No code changes the case of a string a player reads (l10n.md §1.2): a
/// transform follows the phone's locale at best and the wrong rules at
/// worst (Turkish "i" becomes "I", not "İ"). Capitals are the ARB's: each
/// language writes its own (`museumNextFamilyKicker`).
void main() {
  test('lib/ never calls toUpperCase or toLowerCase on user-facing text', () {
    // A hex id, not text: the one allowed use.
    const allowed = {'lib/core/services/save/in_memory_save_service.dart'};
    final offenders = <String>[];
    for (final file in Directory('lib').listSync(recursive: true)) {
      if (file is! File || !file.path.endsWith('.dart')) continue;
      if (allowed.contains(file.path)) continue;
      final lines = file.readAsLinesSync();
      for (var i = 0; i < lines.length; i++) {
        if (RegExp(r'\.to(Upper|Lower)Case\(').hasMatch(lines[i])) {
          offenders.add('${file.path}:${i + 1}');
        }
      }
    }
    expect(offenders, isEmpty, reason: offenders.join('\n'));
  });
}
