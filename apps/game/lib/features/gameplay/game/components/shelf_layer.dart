import 'dart:ui';

import 'package:flame/components.dart';
import 'package:nesty_core/nesty_core.dart' show DollColor;
import 'package:nesty_game/features/fx/fx_id.dart';
import 'package:nesty_game/features/gameplay/game/components/board_scene.dart';
import 'package:nesty_game/features/gameplay/game/components/slot_decor.dart';
import 'package:nesty_game/features/gameplay/game/timeline/hand_tween.dart';
import 'package:nesty_render/nesty_render.dart';

/// The furniture under every doll (NestyBoard:12–17, :161–168;
/// docs/plans/m2-lottie-design.md §8 z-order): the planks as a tiled
/// shader, each slot's stand, the true-size wood silhouettes of a tower's
/// buried nests (D21), the pip bars and the walnut "+N" tags.
///
/// It also draws the static stand-ins of the Lottie pieces that sit on the
/// stands when their file failed to load (rule 3, §10.7): the glow ring
/// under the selection and the hint's target.
///
/// Every frame draws straight from the scene with precomputed paints, paths
/// and text (CLAUDE.md rule 8). A re-pitch lerps the moving slots, a shake
/// moves a tower's silhouettes, and a reveal drop moves them one step down.
class ShelfLayer extends Component {
  ShelfLayer(this.scene, {super.priority});

  final BoardScene scene;

  /// The plank's mid tone (BoardSprites' own fallback), for a board without
  /// art (the fake env, rule 3).
  static final Paint _plankFallback = Paint()..color = const Color(0xFFDCA15D);

  /// A flat stand when the board art is unavailable (rule 3).
  static final Paint _standFallback = Paint()..color = const Color(0xFFB9793F);
  static final RRect _standUnit = RRect.fromRectAndRadius(
    const Rect.fromLTWH(0, 0, 1, 1),
    const Radius.circular(0.12),
  );

  /// The hint target's glow is the selection's at 85 % (NestyBoard:167).
  static final Paint _targetGlow = Paint()
    ..filterQuality = FilterQuality.low
    ..color = const Color.fromRGBO(0, 0, 0, 0.85);

  static final Paint _pipRing = Paint()..color = BoardTokens.pipFilledRingColor;
  static final Paint _pipEmpty = Paint()..color = BoardTokens.pipEmptyColor;
  static final List<Paint> _pipFills = List.unmodifiable([
    for (final color in DollColor.values)
      Paint()..color = DollPalette.of(color).base,
  ]);

  final DollPaintParams _doll = DollPaintParams();

  // The empty pip's `inset 0 1px 1px rgba(0,0,0,.6)` (NestyBoard:164), in
  // pip-local coordinates, per furniture scale (a board has 1–3).
  final List<_PipInset> _insets = [];

  /// The inset of pips [diameter] wide at furniture scale [scale]: built
  /// per layout by [relayout]; built here only for a size it didn't know.
  _PipInset _insetFor(double diameter, double scale) {
    for (var i = 0; i < _insets.length; i++) {
      final inset = _insets[i];
      if (inset.diameter == diameter && inset.scale == scale) return inset;
    }
    final inset = _PipInset(diameter, scale);
    _insets.add(inset);
    return inset;
  }

  /// A new layout (a level, the start or end of a re-pitch, a resize): the
  /// pip insets of every slot of the committed layout are built now, per
  /// event, so no frame builds one.
  void relayout() {
    _insets.clear();
    final slots = scene.geometry?.slots;
    if (slots == null) return;
    for (final slot in slots) {
      _insetFor(slot.pipDiameter, slot.furnitureScale);
    }
  }

  // ── Hot path: runs every frame. No allocation (CLAUDE.md rule 8). ──

  @override
  void render(Canvas canvas) {
    final geometry = scene.geometry;
    if (geometry == null) return;
    final sprites = scene.sprites;
    final r = scene.repitch;
    _planks(canvas, geometry, sprites);
    final slots = scene.slots;
    for (var i = 0; i < slots.length; i++) {
      _stand(canvas, slots[i], sprites, r);
    }
    _glowFallbacks(canvas, sprites, r);
    for (var i = 0; i < slots.length; i++) {
      _silhouettes(canvas, slots[i], r);
    }
    for (var i = 0; i < slots.length; i++) {
      _pips(canvas, slots[i], r);
    }
    for (var i = 0; i < slots.length; i++) {
      final slot = slots[i];
      // The tag is the stand's label: it stays put while the tower above it
      // shakes (§9.3 shakes the composition, sprite, silhouettes and badge).
      if (slot.decor.hasTag) {
        slot.decor.paintTag(canvas, slot.tagX(r), slot.tagY(r));
      }
    }
  }

  void _planks(Canvas canvas, BoardGeometry geometry, BoardSprites? sprites) {
    if (sprites != null) {
      sprites.drawPlanks(canvas, geometry);
      return;
    }
    final shelves = geometry.shelves;
    for (var i = 0; i < shelves.length; i++) {
      canvas.drawRect(shelves[i].plankRect, _plankFallback);
    }
  }

  void _stand(
    Canvas canvas,
    SlotState slot,
    BoardSprites? sprites,
    RepitchTween? r,
  ) {
    // `ui_extra_slot` draws the pulsing stand while it plays.
    if (slot.pulses > 0) return;
    final left = slot.standLeft(r);
    final top = slot.standTop(r);
    final width = slot.standWidth(r);
    final height = slot.standHeight(r);
    final sprite = sprites?.standFor(slot.geometry);
    if (sprite != null) {
      SpriteDraw.box(canvas, sprite, left, top, width, height);
      return;
    }
    canvas
      ..save()
      ..translate(left, top)
      ..scale(width, height)
      ..drawRRect(_standUnit, _standFallback)
      ..restore();
  }

  /// §10.7: without `fx_select_glow`, the selection and the hint's target
  /// keep a static glow ring.
  void _glowFallbacks(Canvas canvas, BoardSprites? sprites, RepitchTween? r) {
    if (sprites == null || scene.isAvailable(FxId.fxSelectGlow)) return;
    final selected = scene.selectedSlotId;
    if (selected != null) _glow(canvas, selected, sprites, r, null);
    final hint = scene.hint;
    if (hint != null) _glow(canvas, hint.to, sprites, r, _targetGlow);
  }

  void _glow(
    Canvas canvas,
    String slotId,
    BoardSprites sprites,
    RepitchTween? r,
    Paint? paint,
  ) {
    final slot = scene.slot(slotId);
    if (slot == null) return;
    final sprite = sprites.forSlot(BoardSprite.glowRing, slot.geometry);
    if (sprite == null) return;
    final ring = slot.geometry.glowRingRect;
    final dx = slot.centerX(r) - slot.geometry.centerX;
    final dy = slot.surfaceY(r) - slot.geometry.surfaceY;
    SpriteDraw.box(
      canvas,
      sprite,
      ring.left + dx,
      ring.top + dy,
      ring.width,
      ring.height,
      paint,
    );
  }

  /// D21: each buried nest at its true size, raised a step per depth,
  /// deepest first so the nearer one covers it. Every skin's buried nests
  /// are the same wood-grain blank (owner decision 3e): the level's part
  /// rasters draw `board/doll-silhouette.svg` for them. During a reveal
  /// (§9.1) `doll_reveal` drops the new top itself and the rest shift one
  /// step down with it.
  void _silhouettes(Canvas canvas, SlotState slot, RepitchTween? r) {
    final buried = slot.view.buried;
    if (buried.isEmpty) return;
    final reveal = slot.reveal;
    final renderer = scene.renderer;
    final x = slot.centerX(r) + slot.shakeX;
    for (var depth = buried.length; depth >= 1; depth--) {
      final size = buried[depth - 1];
      if (size < 1 || size > slot.geometry.pipCount) continue;
      final baseY = reveal == null
          ? slot.buriedBaseY(depth, r)
          : reveal.buriedBaseY(depth);
      _silhouette(canvas, renderer, x, baseY, slot.dollHeight(size, r));
    }
  }

  void _silhouette(
    Canvas canvas,
    DollRenderer renderer,
    double x,
    double baseY,
    double height,
  ) {
    _doll
      ..reset()
      ..silhouette = true
      ..height = height
      ..baseX = x
      ..baseY = baseY
      ..symbols = scene.symbols;
    renderer.paint(canvas, _doll);
  }

  /// The pip bar (spec §10.3, NestyBoard:164): `maxSize` pips, biggest on
  /// the left, filled in the top nest's colour with a cream ring for the
  /// sizes it holds. None on an extra slot.
  void _pips(Canvas canvas, SlotState slot, RepitchTween? r) {
    final g = slot.geometry;
    if (g.kind == SlotShapeKind.extra) return;
    final view = slot.view;
    final count = g.pipCount;
    final radius = g.pipDiameter / 2;
    final ring = BoardTokens.pipFilledRingWidth * g.furnitureScale;
    final y = slot.pipCenterY(r);
    final color = view.color;
    final fill = color == null ? null : _pipFills[color.index];
    final inset = _insetFor(g.pipDiameter, g.furnitureScale);
    for (var position = 0; position < count; position++) {
      canvas
        ..save()
        ..translate(slot.pipCenterX(position, r), y);
      if (fill != null && view.fills(count - position)) {
        canvas
          ..drawCircle(Offset.zero, radius + ring, _pipRing)
          ..drawCircle(Offset.zero, radius, fill);
      } else {
        canvas
          ..drawCircle(Offset.zero, radius, _pipEmpty)
          ..clipPath(inset.clip)
          ..drawPath(inset.shadow, inset.paint);
      }
      canvas.restore();
    }
  }

  // ── End of hot path. ──
}

/// An empty pip's inset shadow at one size: the pip's outside, shifted down
/// 1 dp and blurred 1 dp, clipped to the pip (built once per layout).
final class _PipInset {
  _PipInset(this.diameter, this.scale) {
    final radius = diameter / 2;
    final pip = Rect.fromCircle(center: Offset.zero, radius: radius);
    clip = Path()..addOval(pip);
    shadow = Path()
      ..fillType = PathFillType.evenOdd
      ..addRect(pip.inflate(radius + 2 * scale))
      ..addOval(pip.shift(Offset(0, scale)));
    paint = Paint()
      ..color = const Color.fromRGBO(0, 0, 0, 0.6)
      ..maskFilter = MaskFilter.blur(
        BlurStyle.normal,
        Shadow.convertRadiusToSigma(scale),
      );
  }

  final double diameter;
  final double scale;
  late final Path clip;
  late final Path shadow;
  late final Paint paint;
}
