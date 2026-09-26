// CLAUDE.md rule 8: nothing a renderer runs every frame may allocate. Dart
// has no allocation counter a test can read, so this guards the source: the
// per-frame methods sit between "Hot path" / "End of hot path" markers, and
// no allocating construct may appear between them.
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

const _files = [
  'lib/src/doll/svg_skin_renderer.dart',
  'lib/src/doll/placeholder_doll_painter.dart',
  'lib/src/doll/fallback_doll_renderer.dart',
  'lib/src/doll/doll_effects.dart',
  // Sprite lookups and draws run in the Flame board's render (render §1).
  'lib/src/board/board_sprites.dart',
];

// Constructors of the objects rule 8 names, collection building, iterator
// loops, closures over collections and string building.
final _forbidden = <String, RegExp>{
  'Paint()': RegExp(r'\bPaint\('),
  'Path()': RegExp(r'\bPath\('),
  'Rect.from…': RegExp(r'\bRect\.from'),
  'RRect': RegExp(r'\bRRect\b'),
  'Offset(…)': RegExp(r'\bOffset\('),
  'Size(…)': RegExp(r'\bSize\('),
  'Color(…)': RegExp(r'\bColor(\.from\w+)?\('),
  'with…() colour copies': RegExp(r'\.with(Values|Alpha|Opacity)\('),
  'ColorFilter': RegExp(r'\bColorFilter\b'),
  'Gradient/Shader': RegExp(r'\b(Gradient|ImageShader)\b'),
  'List/Map/Set building': RegExp(
    r'\b(List|Map|Set)\.|\.to(List|Set)\(|<\w+>\[|\[\s*\]',
  ),
  'map/where/expand': RegExp(r'\.(map|where|expand|fold|forEach)\('),
  'for-in (iterator)': RegExp(r'\bfor\s*\(\s*(final|var)\s+\w+\s+in\b'),
  'string interpolation': RegExp(r'''['"][^'"\n]*\$'''),
  // Review RENDER-8: typed lists (a Float64List matrix for
  // canvas.transform), `Offset & Size`, Rect/Offset-making getters and
  // methods, image and mask filters, and closures passed or assigned.
  'typed list': RegExp(r'\b(Float|Int|Uint)(8|16|32|64)(Clamped)?List\s*[(.]'),
  'Offset & Size': RegExp(r'&\s*\w*[Ss]ize\b'),
  'Rect/Offset maker': RegExp(
    r'\.(shift|inflate|deflate|intersect|expandToInclude)\(|'
    r'\.(center|topLeft|topRight|bottomLeft|bottomRight)\b',
  ),
  'ImageFilter/MaskFilter': RegExp(r'\b(ImageFilter|MaskFilter)\b'),
  'closure': RegExp(r'[(,=]\s*\([^()]*\)\s*(=>|\{)'),
};

void main() {
  for (final path in _files) {
    test('$path hot path allocates nothing', () {
      final source = File(path).readAsStringSync();
      final regions = RegExp(
        r'// ── Hot path:[^\n]*\n([\s\S]*?)// ── End of hot path\. ──',
      ).allMatches(source).toList();
      expect(regions, isNotEmpty, reason: 'no hot-path markers in $path');
      final offending = <String>[];
      for (final region in regions) {
        final lines = region[1]!.split('\n');
        for (final line in lines) {
          final code = line.replaceFirst(RegExp(r'//.*$'), '');
          _forbidden.forEach((what, pattern) {
            if (pattern.hasMatch(code)) offending.add('$what: ${line.trim()}');
          });
        }
      }
      expect(offending, isEmpty);
    });
  }

  test('the guard catches what it should and passes what it should', () {
    bool flagged(String line) =>
        _forbidden.values.any((pattern) => pattern.hasMatch(line));
    for (final bad in [
      'final p = Paint()..color = c;',
      'canvas.clipPath(Path()..addOval(r));',
      'canvas.drawRect(Rect.fromLTWH(0, 0, w, h), paint);',
      'canvas.drawCircle(Offset(x, y), 3, paint);',
      'paint.color = color.withValues(alpha: 0.5);',
      'paint.color = Color.fromARGB(a, 0, 0, 0);',
      'for (final slot in _slots) {',
      'final names = slots.map((s) => s.px).toList();',
      "debugPrint('frame \$n');",
      'final xs = <double>[];',
      'canvas.transform(Float64List.fromList(m));',
      'final m = Float32List(16);',
      'canvas.drawRect(Offset.zero & size, paint);',
      'final r = rect.shift(delta);',
      'final c = layer.dst.center;',
      'paint.maskFilter = MaskFilter.blur(BlurStyle.normal, 2);',
      'paint.imageFilter = ImageFilter.blur(sigmaX: 2);',
      '_slots.sort((a, b) => a.px - b.px);',
      'final f = () {};',
      'visit(board, (from, to) => count++);',
    ]) {
      expect(flagged(bad), isTrue, reason: bad);
    }
    for (final good in [
      'for (var i = 0; i < _slots.length; i++) {',
      'if (_slots[i].px >= target) return _slots[i];',
      'canvas.drawImageRect(l.image, l.src, l.dst, paint);',
      'canvas.clipRect(Rect.zero);',
      '..translate(-DollArt.base.dx, -DollArt.base.dy);',
      '_fade.color = _alpha[(opacity.clamp(0.0, 1.0) * 255).round()];',
      'bool canPaint(double height) => !_disposed && _slots.isNotEmpty;',
      'if (p.shine >= 0 && p.shine <= 1) {',
      'canvas.scale(k * p.scaleX, k * p.scaleY);',
      'if ((mask & bit) != 0) return;',
      'canvas.translate(p.baseX, p.baseY);',
    ]) {
      expect(flagged(good), isFalse, reason: good);
    }
  });

  test('the renderers paint inside their hot path', () {
    for (final path in _files.take(3)) {
      final source = File(path).readAsStringSync();
      final hot = RegExp(
        r'// ── Hot path:[^\n]*\n([\s\S]*?)// ── End of hot path\. ──',
      ).allMatches(source).map((m) => m[1]!).join();
      expect(
        hot,
        contains('void paint(Canvas canvas, DollPaintParams p)'),
        reason: path,
      );
      expect(hot, contains('bool isReadyFor(double height)'), reason: path);
      expect(hot, contains('bool canPaint(double height)'), reason: path);
    }
  });
}
