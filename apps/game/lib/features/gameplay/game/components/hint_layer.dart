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
/// The arc is a quadratic from beside the source doll's middle to beside the
/// target's head, bulging away from the board's middle (the design's hint
/// frame: `curve([s.cx − 16, s.dt + 66], [352, 480], [t.cx + 48, t.dt + 6])`,
/// generalized: the control point sits 0.4 × the chord off its middle). Its
/// dashes (`2 10`, round caps, a cream underlay under `#F2893B`) and the
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
  /// length (the design's hint frame: 138 of 341).
  // TODO(design): frame 3.1 shows one arc (r0c3 → r2c0); the curve for
  // other moves (same shelf, neighbours, the extra slots) is generalized
  // from it here and needs a design check (BACKLOG "Design gaps").
  static const bulge = 0.4;

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
    final sourceSize = _sizeOn(move.from, geometry);
    final targetSize = _sizeOn(move.to, geometry);
    final towardTarget = target.centerX < source.centerX ? -1.0 : 1.0;
    final sourceTop = source.dollTopY(sourceSize);
    final targetTop = target.dollTopY(targetSize);
    final sourceHeight = source.dollHeight(sourceSize);
    // Beside the source doll's middle (66 of the design's 99 dp doll), and
    // beside the target's head, on the side the arc comes from.
    final a = Offset(
      source.centerX + 16 * s * towardTarget,
      sourceTop + sourceHeight * 2 / 3,
    );
    final e = Offset(target.centerX - 48 * s * towardTarget, targetTop + 6 * s);
    final chord = e - a;
    final length = chord.distance;
    if (length <= 0) return;
    // The normal that bulges away from the board's middle (a mostly
    // horizontal chord bulges up).
    var normal = Offset(chord.dy, -chord.dx) / length;
    final middle = (a + e) / 2;
    final outward = middle.dx >= geometry.fit.x(BoardLayoutConstants.centerX)
        ? 1.0
        : -1.0;
    final preference = Offset(outward * chord.dy.abs(), -chord.dx.abs());
    if (normal.dx * preference.dx + normal.dy * preference.dy < 0) {
      normal = -normal;
    }
    final c = middle + normal * (bulge * length);
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

  /// The outer size of [slotId]'s top nest (the tallest size for an empty
  /// slot).
  int _sizeOn(String slotId, BoardGeometry geometry) {
    final view = scene.slot(slotId)?.view;
    return view != null && view.hasNest
        ? view.outerSize
        : geometry.shape.maxSize;
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
