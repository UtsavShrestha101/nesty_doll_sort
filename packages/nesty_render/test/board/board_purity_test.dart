// The board layout is pure math shared with the admin's CustomPainter
// preview (spec §13.1, .claude/rules/flame.md): no Flame, no widgets, no
// rendering objects. This guard fails the moment one of its files imports
// anything heavier than dart:ui geometry.
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

final _directive = RegExp(
  r'''^\s*(?:import|export)\s+['"]([^'"]+)['"]''',
  multiLine: true,
);

/// The board's painting files: they rasterize and draw on top of the layout
/// (render §1 "board_sprites"; the admin's debug board), so they may use
/// flutter_svg, services, rendering and the doll renderer. They are not
/// layout math, and the layout never imports them.
const _painting = {
  'lib/src/board/board_sprites.dart',
  'lib/src/board/debug_board_painter.dart',
};

void main() {
  test('lib/src/board imports only geometry and its own sources', () {
    const allowed = {
      'dart:math',
      'dart:ui',
      'package:flutter/foundation.dart',
      'package:flutter/painting.dart',
      'package:nesty_render/src/tokens/render_token_types.dart',
      'package:nesty_render/src/tokens/render_tokens.gen.dart',
    };
    final files = Directory('lib/src/board')
        .listSync()
        .whereType<File>()
        .where((f) => f.path.endsWith('.dart'))
        .where((f) => !_painting.contains(f.path))
        .toList();
    expect(files, hasLength(5), reason: 'scanner found the board sources');
    final offending = <String>[];
    for (final file in files) {
      final source = file.readAsStringSync();
      for (final match in _directive.allMatches(source)) {
        final uri = match.group(1)!;
        final paintingImport = _painting.any(
          (path) => uri == 'package:nesty_render/${path.substring(4)}',
        );
        if (allowed.contains(uri) ||
            (uri.startsWith('package:nesty_render/src/board/') &&
                !paintingImport)) {
          continue;
        }
        offending.add('${file.path} → $uri');
      }
    }
    expect(offending, isEmpty);
  });

  test('the board painting files use no Flame and no widgets', () {
    final offending = <String>[];
    for (final path in _painting) {
      final source = File(path).readAsStringSync();
      for (final match in _directive.allMatches(source)) {
        final uri = match.group(1)!;
        if (uri.startsWith('package:flame') ||
            uri == 'package:flutter/widgets.dart' ||
            uri == 'package:flutter/material.dart' ||
            uri == 'package:flutter/cupertino.dart') {
          offending.add('$path → $uri');
        }
      }
    }
    expect(offending, isEmpty);
  });
}
