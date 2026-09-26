// CLAUDE.md rule 8 for the Flame board (docs/plans/m2-lottie-design.md §14):
// what the board runs every tick and every frame (its update, the drag
// follow, every render, the scene's lerps) must not allocate. Dart has no
// allocation counter a test can read, so, as nesty_render's
// hot_path_allocation_test and the FX and timeline lanes' guards do, this
// guards the source: per-frame code sits between "Hot path" / "End of hot
// path" markers, and no allocating construct may appear between them.
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

const _dir = 'lib/features/gameplay/game/components';

const _files = [
  'board_component.dart',
  'board_scene.dart',
  'fx_layer.dart',
  'shelf_layer.dart',
  'slot_component.dart',
  'slot_decor.dart',
  'nest_component.dart',
  'hint_layer.dart',
];

final _forbidden = <String, RegExp>{
  'Paint()': RegExp(r'\bPaint\('),
  'Path()': RegExp(r'\bPath\('),
  'Rect.from…': RegExp(r'\bRect\.from'),
  'Offset(…)': RegExp(r'\bOffset\('),
  'Size(…)': RegExp(r'\bSize\('),
  'Color(…)': RegExp(r'\bColor(\.from\w+)?\('),
  'Vector2(…)': RegExp(r'\bVector2\('),
  'TextPainter / TextSpan': RegExp(r'\b(TextPainter|TextSpan|TextStyle)\('),
  'PictureRecorder': RegExp(r'\bPictureRecorder\b'),
  'Gradient / shader': RegExp(r'\b(Gradient\.\w+|ImageShader)\('),
  'intent / command construction': RegExp(
    r'\b(SlotTapped|SlotDragStarted|SlotDragDropped|SlotView|SlotState|'
    r'FxPlan|FxRange|_PipInset|_LiveClip|_Pending)(\.\w+)?\(',
  ),
  'List/Map/Set building': RegExp(
    r'\b(List|Map|Set)\.|\.to(List|Set)\(|<\w+>\[|\[\s*\]',
  ),
  'map/where/expand': RegExp(r'\.(map|where|expand|fold|forEach|any)\('),
  'for-in (iterator)': RegExp(r'\bfor\s*\(\s*(final|var)\s+\w+\s+in\b'),
  'string interpolation': RegExp(r'''['"][^'"\n]*\$'''),
  'Rect/Offset maker': RegExp(
    r'\.(shift|inflate|deflate|intersect|expandToInclude)\(|'
    r'\.(center|topLeft|topRight|bottomLeft|bottomRight)\b|'
    r'Offset\.lerp|Rect\.lerp',
  ),
  'closure': RegExp(r'[(,=:]\s*\([^()]*\)\s*(=>|\{)'),
};

final _region = RegExp(
  r'// ── Hot path:[^\n]*\n([\s\S]*?)// ── End of hot path\. ──',
);

String _hot(String name) => _region
    .allMatches(File('$_dir/$name').readAsStringSync())
    .map((m) => m[1]!)
    .join();

void main() {
  for (final name in _files) {
    test('$name hot paths allocate nothing', () {
      final source = File('$_dir/$name').readAsStringSync();
      final regions = _region.allMatches(source).toList();
      expect(regions, isNotEmpty, reason: 'no hot-path markers in $name');
      final offending = <String>[];
      for (final region in regions) {
        for (final line in region[1]!.split('\n')) {
          final code = line.replaceFirst(RegExp(r'//.*$'), '');
          // `case StartClip():` is an object pattern, not a construction.
          if (code.trimLeft().startsWith('case ')) continue;
          _forbidden.forEach((what, pattern) {
            if (pattern.hasMatch(code)) offending.add('$what: ${line.trim()}');
          });
        }
      }
      expect(offending, isEmpty);
    });
  }

  test('the per-frame entry points are inside the hot paths', () {
    final expected = <String, List<String>>{
      'board_component.dart': [
        'void update(double dt)',
        'void _afterAdvance(BoardTimeline timeline)',
        'void _followDrag(BoardTimeline timeline)',
        'void moveDrag(int pointer, double x, double y)',
        // _UnmountedSlots
        'void render(Canvas canvas)',
      ],
      'board_scene.dart': [
        'double get shakeX',
        'double centerX(RepitchTween? r)',
        'double restBaseY(RepitchTween? r)',
        'double buriedBaseY(int depth, RepitchTween? r)',
      ],
      'fx_layer.dart': [
        'void advance(double dtMs)',
        'void followRepitch(RepitchTween repitch)',
      ],
      'shelf_layer.dart': ['void render(Canvas canvas)', 'void _pips('],
      'slot_component.dart': [
        'bool get drawsGlassFallback',
        'bool get compositionDraws',
        'bool _draws(LottieFxComponent? component)',
        'void advance(double dtMs)',
        'void place()',
        'void updateTree(double dt)',
        'void update(double dt)',
        'void renderTree(Canvas canvas)',
        'int get _glassFrame',
        'double get _iceFrame',
        'void render(Canvas canvas)',
      ],
      'slot_decor.dart': [
        'void paintTag(Canvas canvas, double x, double y)',
        'void paintBadge(Canvas canvas, double x, double y)',
        'static void box(',
      ],
      'nest_component.dart': ['void render(Canvas canvas)'],
      'hint_layer.dart': [
        'void render(Canvas canvas)',
        'void _arrowFallback(Canvas canvas)',
      ],
    };
    for (final MapEntry(key: name, value: signatures) in expected.entries) {
      final hot = _hot(name);
      for (final signature in signatures) {
        expect(hot, contains(signature), reason: '$name: $signature');
      }
    }
  });

  test('the guard catches what it should and passes what it should', () {
    bool flagged(String line) =>
        !line.trimLeft().startsWith('case ') &&
        _forbidden.values.any((pattern) => pattern.hasMatch(line));
    for (final bad in [
      'final base = Offset(scene.dragBaseX, scene.dragBaseY);',
      'onIntent?.call(SlotTapped(id));',
      'final view = SlotView.of(board, slot.id);',
      'for (final slot in scene.slots) {',
      'final live = _live.where((l) => l.clip.slotId == id).toList();',
      "debugPrint('drag \$x');",
      'final center = rect.center;',
      '_insets.add(_PipInset(d, s));',
    ]) {
      expect(flagged(bad), isTrue, reason: bad);
    }
    for (final good in [
      'for (var i = 0; i < slots.length; i++) {',
      'canvas.drawCircle(Offset.zero, radius, fill);',
      'slot.decor.paintTag(canvas, slot.tagX(r), slot.tagY(r));',
      'case StartClip():',
      'final frame = scene.geometry?.fit.frame;',
      'SpriteDraw.box(canvas, sprite, left, top, width, height);',
    ]) {
      expect(flagged(good), isFalse, reason: good);
    }
  });
}
