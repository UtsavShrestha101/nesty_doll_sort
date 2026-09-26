// svg_tools.dart is imported by the pure-Dart tools (`dart run`), which can't
// compile dart:ui or Flutter. This guard fails the moment someone adds such
// an import to the library or anything it pulls in.
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

final _directive = RegExp(
  r'''^\s*(?:import|export)\s+['"]([^'"]+)['"]''',
  multiLine: true,
);

void main() {
  test('svg_tools imports only package:xml, dart:core-level libraries and '
      'its own sources', () {
    const allowedDart = {'dart:core', 'dart:convert', 'dart:collection'};
    final pending = ['lib/svg_tools.dart'];
    final seen = <String>{};
    final offending = <String>[];
    while (pending.isNotEmpty) {
      final path = pending.removeLast();
      if (!seen.add(path)) continue;
      final source = File(path).readAsStringSync();
      for (final match in _directive.allMatches(source)) {
        final uri = match.group(1)!;
        if (uri.startsWith('package:nesty_render/src/svg_tools/')) {
          pending.add('lib/${uri.substring('package:nesty_render/'.length)}');
        } else if (uri.startsWith('package:xml/') ||
            allowedDart.contains(uri)) {
          continue;
        } else {
          offending.add('$path → $uri');
        }
      }
    }
    expect(seen, hasLength(greaterThan(1)), reason: 'scanner found nothing');
    expect(offending, isEmpty);
  });
}
