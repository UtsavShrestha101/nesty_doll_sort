// CLAUDE.md rule 8 for the FX runtime (docs/plans/m2-lottie-design.md §14):
// nothing our code runs per tick or per frame allocates, except the new
// `Offset`s lottie's position and scale callbacks must return (PROGRESS
// D42). Dart has no allocation counter a test can read, so, as in
// nesty_render's hot_path_allocation_test, this guards the source: the
// per-frame code sits between "Hot path" / "End of hot path" markers, and
// no allocating construct may appear between them.
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

const _dir = 'lib/features/fx';

/// Each file with its hot paths (under [_dir] unless the path says
/// otherwise), and what D42 allows there.
const _files = <String, Set<String>>{
  'fx_player.dart': {},
  'fx_images.dart': {},
  'fx_pool.dart': {},
  'fx_drawable.dart': {},
  'fx_text_overlay.dart': {},
  'lottie_fx_component.dart': {},
  'lottie_fx_view.dart': {},
  // The callbacks return new Offsets (the API's return type); everything
  // static is cached.
  'fx_delegates.dart': {'Offset(…)'},
  // The counter's and ribbons' Flutter label, painted by the text overlay
  // (review PERF-RULES-2).
  'lib/core/ui/lottie/lottie_label.dart': {},
};

final _forbidden = <String, RegExp>{
  'Paint()': RegExp(r'\bPaint\('),
  'Path()': RegExp(r'\bPath\('),
  'Rect.from…': RegExp(r'\bRect\.from'),
  'Offset(…)': RegExp(r'\bOffset\('),
  'Size(…)': RegExp(r'\bSize\('),
  'Color(…)': RegExp(r'\bColor(\.from\w+)?\('),
  'Vector2(…)': RegExp(r'\bVector2\('),
  'PictureRecorder': RegExp(r'\bPictureRecorder\b'),
  'List/Map/Set building': RegExp(
    r'\b(List|Map|Set)\.|\.to(List|Set)\(|<\w+>\[|\[\s*\]',
  ),
  'map/where/expand': RegExp(r'\.(map|where|expand|fold|forEach)\('),
  'for-in (iterator)': RegExp(r'\bfor\s*\(\s*(final|var)\s+\w+\s+in\b'),
  'string interpolation': RegExp(r'''['"][^'"\n]*\$'''),
  'Rect/Offset maker': RegExp(
    r'\.(shift|inflate|deflate|intersect|expandToInclude)\(|'
    r'\.(center|topLeft|topRight|bottomLeft|bottomRight)\b',
  ),
  'closure': RegExp(r'[(,=:]\s*\([^()]*\)\s*(=>|\{)'),
};

void main() {
  for (final MapEntry(key: name, value: allowed) in _files.entries) {
    test('$name hot paths allocate nothing', () {
      final path = name.startsWith('lib/') ? name : '$_dir/$name';
      final source = File(path).readAsStringSync();
      final regions = RegExp(
        r'// ── Hot path:[^\n]*\n([\s\S]*?)// ── End of hot path\. ──',
      ).allMatches(source).toList();
      expect(regions, isNotEmpty, reason: 'no hot-path markers in $name');
      final offending = <String>[];
      for (final region in regions) {
        for (final line in region[1]!.split('\n')) {
          final code = line.replaceFirst(RegExp(r'//.*$'), '');
          _forbidden.forEach((what, pattern) {
            if (!allowed.contains(what) && pattern.hasMatch(code)) {
              offending.add('$what: ${line.trim()}');
            }
          });
        }
      }
      expect(offending, isEmpty);
    });
  }

  test('the guard catches what it should', () {
    bool flagged(String line) =>
        _forbidden.values.any((pattern) => pattern.hasMatch(line));
    for (final bad in [
      'final v = Vector2(x, y);',
      'final r = ui.PictureRecorder();',
      'return Offset(x, y);',
      'for (final clip in _clips) {',
      "debugPrint('pool \$name');",
      'onEnd: () => release(c),',
    ]) {
      expect(flagged(bad), isTrue, reason: bad);
    }
    for (final good in [
      'for (var i = 0; i < _items.length; i++) {',
      'canvas.drawPicture(_rest!);',
      'drawable.draw(canvas, _rect, fit: BoxFit.fill);',
      'if (clip.advance(dtMs)) onFinished?.call(this);',
    ]) {
      expect(flagged(good), isFalse, reason: good);
    }
  });
}
