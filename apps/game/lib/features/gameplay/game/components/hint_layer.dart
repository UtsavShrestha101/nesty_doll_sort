import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:nesty_core/nesty_core.dart' show Move;
import 'package:nesty_game/features/fx/fx_id.dart';
import 'package:nesty_game/features/gameplay/game/components/board_scene.dart';
import 'package:nesty_game/features/gameplay/game/components/slot_decor.dart';
import 'package:nesty_render/nesty_render.dart';

/// The hint's dashed guide arc from the source nest to the target (frame
/// 3.1, NestyBoard:19, :206–208; docs/plans/m2-lottie-design.md §7
/// `HintShownEffect`). The arrow over the source and the target's glow are
/// Lottie clips in the `FxLayer`; this is the static path between them.
///
/// The design's hint frame draws `curve([s.cx − 16, s.dt + 66], [352, 480],
/// [t.cx + 48, t.dt + 6])`: from over the source doll's upper body, 66
/// below its top (two thirds of that 99 dp doll; never lower than two
/// thirds of a smaller one), to beside the target doll's head on the side
/// the arc comes from,
/// the quadratic's control point 0.4 × the chord off its middle toward that
/// side, so the arrowhead (NestyBoard:185 `head`, along the last tangent)
/// points into the target's head. Generalized here:
/// - the arc arrives on the source's side of the target (from its right
///   when the source is right of it); for a move within one column, from
///   the board's middle, where there is room;
/// - an empty target ends beside the head of the doll that will stand
///   there (the moving nest), not the tallest size's;
/// - a mostly horizontal chord bulges up, over the dolls.
///
/// Its dashes (`2 10`, round caps, a cream underlay under `#F2893B`) and the
/// arrowhead are built into paths once per hint ([show]); every frame only
/// draws them (CLAUDE.md rule 8).
///
/// Without `ui_hint_arrow` (a failed load, rule 3) it also draws the static
/// hint-arrow sprite over the source.
class HintLayer extends Component {
  HintLayer(this.scene, {super.priority});

  final BoardScene scene;

  /// `ARC.guide` (NestyBoard:246): `#F2893B` 4 dp over a
  /// `rgba(255,250,240,.95)` 8 dp underlay, dashes `2 10`.
  static const arcColor = Color(0xFFF2893B);
  static const arcUnderlay = Color.fromRGBO(255, 250, 240, 0.95);
  static const arcWidth = 4.0;
  static const arcUnderlayWidth = 8.0;
  static const dash = 2.0;
  static const gap = 10.0;

  /// How far the control point sits off the chord's middle, per chord
  /// length (the design's hint frame: 135 of 341).
  // TODO(design): frame 3.1 shows one arc (r0c3 → r2c0); the curve for
  // other moves (same shelf, one column, upward, the extra slots) is
  // generalized from it here and needs a design check (BACKLOG "Design
  // gaps").
  static const bulge = 0.4;

  /// The design's offsets, in reference units at board scale 1: the start
  /// sits 16 toward the target from the source's centre and 66 below its
  /// doll's top, but no deeper than two thirds of the doll (a small doll);
  /// the end 48 beside the target's centre and 6 below its doll's top.
  static const startInset = 16.0;
  static const startBelowTop = 66.0;
  static const startDepth = 2 / 3;
  static const endBeside = 48.0;
  static const endBelowTop = 6.0;

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

  /// The arc's end points and control point, for tests.
  Offset? start;
  Offset? control;
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
    start = control = end = null;
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
    // +1: the arc arrives from the target's right (NestyBoard:208, the
    // source is right of the target), −1 from its left.
    final side = arrivalSide(
      sourceX: source.centerX,
      targetX: target.centerX,
      middleX: geometry.fit.x(BoardLayoutConstants.centerX),
    );
    final a = Offset(
      source.centerX - startInset * s * side,
      source.dollTopY(moverSize) +
          math.min(
            startBelowTop * s,
            source.dollHeight(moverSize) * startDepth,
          ),
    );
    final e = Offset(
      target.centerX + endBeside * s * side,
      target.dollTopY(targetSize) + endBelowTop * s,
    );
    final chord = e - a;
    final length = chord.distance;
    if (length <= 0) return;
    // The normal toward the arrival side (a mostly horizontal chord bulges
    // up), so the last tangent heads into the target's head.
    var normal = Offset(chord.dy, -chord.dx) / length;
    final preference = Offset(side * chord.dy.abs(), -chord.dx.abs());
    if (normal.dx * preference.dx + normal.dy * preference.dy < 0) {
      normal = -normal;
    }
    final c = (a + e) / 2 + normal * (bulge * length);
    start = a;
    control = c;
    end = e;

    final arc = Path()
      ..moveTo(a.dx, a.dy)
      ..quadraticBezierTo(c.dx, c.dy, e.dx, e.dy);
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
    final tangent = e - c;
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
    SpriteDraw.box(
      canvas,
      sprite,
      g.centerX + BoardLayoutConstants.hintArrowOffsetX * fs,
      g.dollTopY(size) + BoardLayoutConstants.hintArrowOffsetY * fs,
      BoardLayoutConstants.hintArrowWidth * fs,
      BoardLayoutConstants.hintArrowHeight * fs,
    );
  }

  // ── End of hot path. ──
}
