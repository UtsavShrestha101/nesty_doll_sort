import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:nesty_core/nesty_core.dart' show Move;
import 'package:nesty_game/features/fx/fx_id.dart';
import 'package:nesty_game/features/gameplay/game/components/board_scene.dart';
import 'package:nesty_game/features/gameplay/game/components/slot_decor.dart';
import 'package:nesty_render/nesty_render.dart';

/// The hint's dashed guide arc from the source nest to the target (tokens
/// v3 `layout.hintArc`, E.15; docs/plans/m2-lottie-design.md §7
/// `HintShownEffect`). The arrow over the source and the target's glow are
/// Lottie clips in the `FxLayer`; this is the static path between them.
///
/// A cubic from 8 dp above the source doll's top (where the arrow's tip is)
/// to 8 dp above the target doll's top, both handles rising 42 dp above the
/// higher end (56 dp when the two are on different shelves), so it arches
/// over the dolls between them and the arrowhead drops into the target's
/// head. Generalized where the design draws no frame:
/// - a move within one column (no sideways travel) bows to the side the
///   design's 3.1 arc arrives from, so the arch doesn't fold onto itself;
/// - an empty target ends over the head of the doll that will stand there
///   (the moving nest), not the tallest size's.
///
/// Its dashes (6 dp on, 6 dp off, 3 dp wide, `#F2893B`, on a cream
/// underlay) and the arrowhead are built into paths once per hint ([show])
/// and layout; every frame only draws them (CLAUDE.md rule 8).
///
/// Without `ui_hint_arrow` (a failed load, rule 3) it also draws the static
/// hint-arrow sprite over the source.
class HintLayer extends Component {
  HintLayer(this.scene, {super.priority});

  final BoardScene scene;

  /// `layout.hintArc`: `#F2893B` 3 dp over a `rgba(255,250,240,.95)`
  /// underlay, dashes 6 on and 6 off.
  static const arcColor = HintArcTokens.color;
  static const arcUnderlay = Color.fromRGBO(255, 250, 240, 0.95);
  static const arcWidth = HintArcTokens.width;

  /// The underlay is 3 dp wider than the line (frame 3.1's cream ring).
  static const arcUnderlayWidth = arcWidth + 3;

  /// The dashes are drawn with round caps, which add half a line width at
  /// each end: the path's dash is shortened and its gap lengthened by the
  /// width, so the pattern reads 6 on and 6 off.
  static const dash = HintArcTokens.dashOn - arcWidth;
  static const gap = HintArcTokens.dashOff + arcWidth;

  /// How far a same-column arc bows sideways, in reference units.
  static const columnBow = 24.0;

  Move? _move;
  Path? _dashes;
  Path? _head;
  final Paint _under = Paint()
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round
    ..color = arcUnderlay;
  final Paint _line = Paint()
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round
    ..color = arcColor;
  final Paint _headFill = Paint()..color = arcColor;
  final Paint _headStroke = Paint()
    ..style = PaintingStyle.stroke
    ..strokeJoin = StrokeJoin.round
    ..color = arcUnderlay;

  /// The move the arc shows, or null.
  Move? get move => _move;

  /// The dashed arc, for tests; null while hidden.
  Path? get dashes => _dashes;

  /// How many times the paths were built (once per hint and layout).
  int get builds => _builds;
  int _builds = 0;

  /// The arc's end points and control points, for tests.
  Offset? start;
  Offset? control1;
  Offset? control2;
  Offset? end;

  /// Shows [move]'s arc (null hides it): `SetHintArc`.
  void show(Move? move) {
    _move = move;
    rebuild();
  }

  /// Builds the paths again for the current layout (a re-pitch's end, a
  /// resize). Per event.
  void rebuild() {
    _dashes = null;
    _head = null;
    start = control1 = control2 = end = null;
    final move = _move;
    final geometry = scene.geometry;
    if (move == null || geometry == null) return;
    final source = geometry.slotOrNull(move.from);
    final target = geometry.slotOrNull(move.to);
    if (source == null || target == null) return;
    final s = geometry.scale;
    final moverSize = _sizeOn(move.from, geometry);
    // An empty target: the head of the nest that will stand there.
    final targetSize = _sizeOn(move.to, geometry, empty: moverSize);
    const above = HintArcTokens.endOffsetAboveDoll;
    final a = Offset(source.centerX, source.dollTopY(moverSize) - above * s);
    final e = Offset(target.centerX, target.dollTopY(targetSize) - above * s);
    // Both handles rise above the higher end: 42, or 56 across shelves.
    final lift =
        (source.row == target.row
            ? HintArcTokens.handleLift
            : HintArcTokens.handleLiftCrossRow) *
        s;
    final top = math.min(a.dy, e.dy) - lift;
    // One column: bow toward the side the arc arrives from.
    final bow = (a.dx - e.dx).abs() < 2 * s
        ? columnBow *
              s *
              arrivalSide(
                sourceX: source.centerX,
                targetX: target.centerX,
                middleX: geometry.fit.x(BoardLayoutConstants.centerX),
              )
        : 0.0;
    final c1 = Offset(a.dx + bow, top);
    final c2 = Offset(e.dx + bow, top);
    start = a;
    control1 = c1;
    control2 = c2;
    end = e;

    final arc = Path()
      ..moveTo(a.dx, a.dy)
      ..cubicTo(c1.dx, c1.dy, c2.dx, c2.dy, e.dx, e.dy);
    final dashes = Path();
    for (final metric in arc.computeMetrics()) {
      for (var d = 0.0; d < metric.length; d += (dash + gap) * s) {
        dashes.addPath(
          metric.extractPath(d, math.min(d + dash * s, metric.length)),
          Offset.zero,
        );
      }
    }
    // The arrowhead along the last tangent (NestyBoard:185 `head`).
    final tangent = e - c2;
    final unit = tangent / (tangent.distance == 0 ? 1 : tangent.distance);
    final perp = Offset(-unit.dy, unit.dx);
    final tip = e + unit * (12 * s);
    final left = e - perp * (9 * s) - unit * (4 * s);
    final right = e + perp * (9 * s) - unit * (4 * s);
    _head = Path()
      ..moveTo(tip.dx, tip.dy)
      ..lineTo(left.dx, left.dy)
      ..lineTo(right.dx, right.dy)
      ..close();
    _dashes = dashes;
    _under.strokeWidth = arcUnderlayWidth * s;
    _line.strokeWidth = arcWidth * s;
    _headStroke.strokeWidth = 2 * s;
    _builds++;
  }

  /// Which side of the target the arc arrives on: +1 from its right, −1
  /// from its left. From the source's side; within one column, from the
  /// board's middle ([middleX]).
  static double arrivalSide({
    required double sourceX,
    required double targetX,
    required double middleX,
  }) {
    const epsilon = 0.5;
    if (sourceX > targetX + epsilon) return 1;
    if (sourceX < targetX - epsilon) return -1;
    return targetX <= middleX ? 1 : -1;
  }

  /// The outer size of [slotId]'s top nest, or [empty] (the tallest size by
  /// default) for an empty slot.
  int _sizeOn(String slotId, BoardGeometry geometry, {int? empty}) {
    final view = scene.slot(slotId)?.view;
    return view != null && view.hasNest
        ? view.outerSize
        : (empty ?? geometry.shape.maxSize);
  }

  // ── Hot path: runs every frame. No allocation (CLAUDE.md rule 8). ──

  @override
  void render(Canvas canvas) {
    final dashes = _dashes;
    if (dashes == null) return;
    canvas
      ..drawPath(dashes, _under)
      ..drawPath(dashes, _line);
    final head = _head;
    if (head != null) {
      canvas
        ..drawPath(head, _headFill)
        ..drawPath(head, _headStroke);
    }
    _arrowFallback(canvas);
  }

  /// §10.7: without `ui_hint_arrow`, the static arrow sprite over the
  /// source (NestyBoard:208).
  void _arrowFallback(Canvas canvas) {
    final move = _move;
    if (move == null || scene.isAvailable(FxId.uiHintArrow)) return;
    final slot = scene.slot(move.from);
    final sprites = scene.sprites;
    if (slot == null || sprites == null) return;
    final g = slot.geometry;
    final sprite = sprites.forSlot(BoardSprite.hintArrow, g);
    if (sprite == null) return;
    final size = slot.view.hasNest ? slot.view.outerSize : g.pipCount;
    final fs = g.furnitureScale;
    final width = BoardLayoutConstants.hintArrowWidth * fs;
    final height = BoardLayoutConstants.hintArrowHeight * fs;
    // The same place as the Lottie's, clear of the HUD (hintArrowCenterY).
    SpriteDraw.box(
      canvas,
      sprite,
      g.hintArrowCenterX(size) - width / 2,
      g.hintArrowCenterY(size) - height / 2,
      width,
      height,
    );
  }

  // ── End of hot path. ──
}
