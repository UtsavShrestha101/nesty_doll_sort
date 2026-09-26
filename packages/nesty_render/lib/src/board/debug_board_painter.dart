import 'dart:math' as math;
import 'dart:ui' as ui show Gradient;
import 'dart:ui'
    show
        BlendMode,
        BlurStyle,
        Canvas,
        Color,
        ColorFilter,
        FilterQuality,
        FontWeight,
        MaskFilter,
        Offset,
        Paint,
        Path,
        PathFillType,
        RRect,
        Radius,
        Rect,
        Size,
        TextDirection;

import 'package:flutter/foundation.dart'
    show Listenable, immutable, listEquals, mapEquals;
import 'package:flutter/painting.dart'
    show EdgeInsets, Shadow, TextPainter, TextSpan, TextStyle;
import 'package:flutter/rendering.dart' show CustomPainter;
import 'package:nesty_core/nesty_core.dart' show DollColor;
import 'package:nesty_render/src/board/board_geometry.dart';
import 'package:nesty_render/src/board/board_layout.dart';
import 'package:nesty_render/src/board/board_shape.dart';
import 'package:nesty_render/src/board/board_sprites.dart';
import 'package:nesty_render/src/doll/doll_paint_params.dart';
import 'package:nesty_render/src/doll/doll_renderer.dart';
import 'package:nesty_render/src/palette/doll_palette.dart';
import 'package:nesty_render/src/skin/symbol_atlas.dart';
import 'package:nesty_render/src/theme/theme_background.dart';
import 'package:nesty_render/src/tokens/render_tokens.gen.dart';

/// What one slot shows, for [DebugBoardPainter]. It only describes
/// pixels: the game or the admin fills it from nesty_core state, and the
/// painter never reads a rule (CLAUDE.md rule 2).
@immutable
final class DebugSlot {
  const DebugSlot({
    this.color,
    this.sizes = const [],
    this.buried = const [],
    this.unlockColor,
    this.glassFrame = 0,
    this.ice = 0,
    this.iceInitial,
    this.selected = false,
    this.hintTarget = false,
    this.hintSource = false,
  }) : assert(glassFrame >= 0 && glassFrame <= 2, 'glassFrame is 0–2'),
       assert(ice >= 0, 'ice is ≥ 0');

  static const empty = DebugSlot();

  /// The top nest's colour; null for an empty slot.
  final DollColor? color;

  /// The top nest's doll sizes, outer to inner (spec §2.1: `[red4, red3]`
  /// is `[4, 3]`). The outer doll is drawn; the pip bar shows them all.
  final List<int> sizes;

  /// A tower's buried nests (spec §3.2): the outer size of each, nearest
  /// the top first (depth 1, 2, …). Drawn as wood silhouettes at their true
  /// size, raised per depth (D21), with the "+N" tag.
  final List<int> buried;

  /// A locked slot's unlock colour: its symbol sits on the padlock.
  final DollColor? unlockColor;

  /// Glass case frame: 0 intact, 1 cracked, 2 shattered (no padlock).
  final int glassFrame;

  /// Remaining ice (spec §3.4); 0 for none.
  final int ice;

  /// The ice the slot started with, for the crack frame (default [ice]:
  /// frame 0).
  final int? iceInitial;

  /// Picked up: glow ring, and the doll lifted and scaled like the pick
  /// pose (NestyBoard:179).
  final bool selected;

  /// A hint's target: the glow ring at 0.85 (NestyBoard:167).
  final bool hintTarget;

  /// A hint's source: the arrow above the doll (NestyBoard:208).
  final bool hintSource;

  bool get hasNest => color != null && sizes.isNotEmpty;

  @override
  bool operator ==(Object other) =>
      other is DebugSlot &&
      other.color == color &&
      listEquals(other.sizes, sizes) &&
      listEquals(other.buried, buried) &&
      other.unlockColor == unlockColor &&
      other.glassFrame == glassFrame &&
      other.ice == ice &&
      other.iceInitial == iceInitial &&
      other.selected == selected &&
      other.hintTarget == hintTarget &&
      other.hintSource == hintSource;

  @override
  int get hashCode => Object.hash(
    color,
    Object.hashAll(sizes),
    Object.hashAll(buried),
    unlockColor,
    glassFrame,
    ice,
    iceInitial,
    selected,
    hintTarget,
    hintSource,
  );
}

/// Draws a whole static board, from a [BoardShape] and what each slot
/// holds, through the same [BoardLayout], [BoardSprites] and [DollRenderer]
/// the game uses, in NestyBoard's paint order: planks, then each slot's
/// stand, glow, buried silhouettes, doll, glass and ice, then hint arrows,
/// pips, padlock symbols, tower tags and ice badges.
///
/// For golden-free visual smoke tests and the admin's level preview
/// (spec §13.1: its board is a `CustomPainter` on nesty_render, no Flame).
/// It is not a per-frame painter: each paint lays out text and may
/// allocate. The game's Flame components draw the board themselves.
///
/// Call [prepare] once for the size it will paint at, so the sprites, the
/// doll heights and the padlock symbols are rasterized; until then (or for
/// anything that failed) it draws what it has. It repaints when [sprites]
/// or [background] change. Call [dispose] to release the padlock symbols.
final class DebugBoardPainter extends CustomPainter {
  DebugBoardPainter({
    required this.shape,
    required this.sprites,
    required this.renderer,
    this.slots = const {},
    this.padding = EdgeInsets.zero,
    this.symbols = DollSymbols.subtle,
    this.symbolAtlas,
    this.background,
  }) : super(
         repaint: background == null
             ? sprites
             : Listenable.merge([sprites, background]),
       );

  final BoardShape shape;

  /// What each slot holds, by slot id; a missing id is an empty slot.
  final Map<String, DebugSlot> slots;

  final BoardSprites sprites;
  final DollRenderer renderer;

  /// Safe-area padding of the painted area, as `BoardViewport.padding`.
  final EdgeInsets padding;

  /// Belly symbols of every doll (spec §12.3, settings `symbols`).
  final DollSymbols symbols;

  /// Draws the unlock colour's symbol on each padlock. Without it the
  /// padlock shows an ink dot in that colour.
  final SymbolAtlas? symbolAtlas;

  /// Painted behind the board when given.
  final ThemeBackground? background;

  /// The pick pose's scale (tokens.json `motion.pick.scale`; NestyBoard's
  /// `nb-wob` keyframes hold it).
  static const _pickScale = MotionTokens.pickScale;

  /// Walnut "+N" tower tag, NestyBoard:16: `#7B4824` pill, 1.5 dp `#FFF4E0`
  /// ring, `#FFEFD6` Fredoka 700 12/14, padding 2 × 6, radius 8.
  static const _tagFill = Color(0xFF7B4824);
  static const _tagRing = Color(0xFFFFF4E0);
  static const _tagText = Color(0xFFFFEFD6);

  /// Ice counter badge, NestyBoard:17: `#6FB4EA → #3E8EDE`, a 2.5 dp white
  /// ring and a `#2B6CB0` edge 3 dp below, white Fredoka 700 16.
  static const _badgeTop = Color(0xFF6FB4EA);
  static const _badgeBottom = Color(0xFF3E8EDE);
  static const _badgeRing = Color(0xFFFFFFFF);
  static const _badgeEdge = Color(0xFF2B6CB0);

  final DollPaintParams _doll = DollPaintParams();
  final Paint _targetGlow = Paint()
    ..filterQuality = FilterQuality.low
    ..color = const Color.fromRGBO(0, 0, 0, 0.85);
  final Paint _pipRing = Paint()..color = BoardTokens.pipFilledRingColor;
  final Paint _pipFill = Paint();
  final Paint _pipEmpty = Paint()..color = BoardTokens.pipEmptyColor;
  final Paint _pipInset = Paint()..color = const Color.fromRGBO(0, 0, 0, 0.6);
  final Paint _fill = Paint();
  final Paint _symbol = Paint()..filterQuality = FilterQuality.medium;

  BoardGeometry? _geometry;
  Size? _geometrySize;
  SymbolAtlasPage? _padlockPage;

  /// The layout this painter draws at [size].
  BoardGeometry layoutFor(Size size) {
    final cached = _geometry;
    if (cached != null && _geometrySize == size) return cached;
    _geometrySize = size;
    return _geometry = BoardLayout.compute(
      shape,
      BoardViewport(size: size, padding: padding),
    );
  }

  /// The glass and ice frames [slots] show, beyond what
  /// `BoardSprites.prepare` rasterizes anyway.
  Set<BoardSprite> get frames => {
    for (final slot in shape.rows.expand((row) => row))
      if (slots[slot.id] case final contents?) ...[
        if (slot.kind == SlotShapeKind.locked && contents.glassFrame != 0)
          BoardSprite.glassCase(contents.glassFrame),
        if (contents.ice > 0) BoardSprite.ice(_iceFrame(contents)),
      ],
  };

  /// Rasterizes everything a paint at [size] needs: the sprites (with
  /// [frames]), the doll heights and the padlock symbols.
  Future<BoardGeometry> prepare({
    required Size size,
    required double devicePixelRatio,
  }) async {
    final geometry = layoutFor(size);
    await Future.wait([
      sprites.prepare(
        geometry,
        devicePixelRatio: devicePixelRatio,
        also: frames,
      ),
      renderer.prepare(
        heights: geometry.dollHeights,
        devicePixelRatio: devicePixelRatio,
      ),
      _preparePadlocks(geometry, devicePixelRatio),
    ]);
    return geometry;
  }

  void dispose() {
    _padlockPage?.dispose();
    _padlockPage = null;
  }

  @override
  void paint(Canvas canvas, Size size) {
    background?.paint(canvas, size);
    final geometry = layoutFor(size);
    sprites.drawPlanks(canvas, geometry);
    final all = geometry.slots;
    for (var i = 0; i < all.length; i++) {
      _paintSlot(canvas, geometry, all[i], _contents(all[i]));
    }
    for (var i = 0; i < all.length; i++) {
      final contents = _contents(all[i]);
      if (!contents.hintSource || !_drawable(contents, geometry)) continue;
      sprites
          .forSlot(BoardSprite.hintArrow, all[i])
          ?.draw(canvas, all[i].hintArrowRect(contents.sizes.first));
    }
    for (var i = 0; i < all.length; i++) {
      _paintPips(canvas, all[i], _contents(all[i]));
    }
    for (var i = 0; i < all.length; i++) {
      _paintPadlock(canvas, all[i], _contents(all[i]));
    }
    for (var i = 0; i < all.length; i++) {
      _paintTag(canvas, all[i], _contents(all[i]));
    }
    for (var i = 0; i < all.length; i++) {
      _paintIceBadge(canvas, all[i], _contents(all[i]));
    }
  }

  @override
  bool shouldRepaint(DebugBoardPainter oldDelegate) =>
      oldDelegate.shape != shape ||
      !mapEquals(oldDelegate.slots, slots) ||
      !identical(oldDelegate.sprites, sprites) ||
      !identical(oldDelegate.renderer, renderer) ||
      oldDelegate.padding != padding ||
      oldDelegate.symbols != symbols ||
      !identical(oldDelegate.symbolAtlas, symbolAtlas) ||
      !identical(oldDelegate.background, background);

  DebugSlot _contents(SlotGeometry slot) => slots[slot.id] ?? DebugSlot.empty;

  static int _iceFrame(DebugSlot contents) => BoardLayout.iceFrame(
    remaining: contents.ice,
    initial: math.max(contents.iceInitial ?? contents.ice, contents.ice),
  );

  static bool _validSize(int size, BoardGeometry geometry) =>
      size >= 1 && size <= geometry.dollHeights.length;

  static bool _drawable(DebugSlot contents, BoardGeometry geometry) =>
      contents.hasNest && _validSize(contents.sizes.first, geometry);

  void _paintSlot(
    Canvas canvas,
    BoardGeometry geometry,
    SlotGeometry slot,
    DebugSlot contents,
  ) {
    sprites.standFor(slot)?.draw(canvas, slot.standRect);
    if (contents.selected || contents.hintTarget) {
      sprites
          .forSlot(BoardSprite.glowRing, slot)
          ?.draw(
            canvas,
            slot.glowRingRect,
            contents.selected ? null : _targetGlow,
          );
    }
    if (slot.kind == SlotShapeKind.tower) {
      // Deepest first, so each nest nearer the top covers the one below
      // (NestyBoard:168).
      for (var depth = contents.buried.length; depth >= 1; depth--) {
        final size = contents.buried[depth - 1];
        if (!_validSize(size, geometry)) continue;
        _paintDoll(
          canvas,
          slot,
          DollColor.red,
          size,
          slot.buriedBaseY(depth, buried: contents.buried.length),
          silhouette: true,
        );
      }
    }
    if (_drawable(contents, geometry)) {
      final lifted = contents.selected && slot.kind != SlotShapeKind.locked;
      _paintDoll(
        canvas,
        slot,
        contents.color!,
        contents.sizes.first,
        slot.restingBaseY -
            (lifted ? MotionTokens.pickLift * geometry.scale : 0),
        scale: lifted ? _pickScale : 1,
      );
    }
    if (slot.kind == SlotShapeKind.locked) {
      sprites
          .forSlot(BoardSprite.glassCase(contents.glassFrame), slot)
          ?.draw(canvas, slot.glassCaseRect);
    }
    if (contents.ice > 0) {
      sprites
          .forSlot(BoardSprite.ice(_iceFrame(contents)), slot)
          ?.draw(canvas, slot.iceRect);
    }
  }

  void _paintDoll(
    Canvas canvas,
    SlotGeometry slot,
    DollColor color,
    int size,
    double baseY, {
    bool silhouette = false,
    double scale = 1,
  }) {
    _doll
      ..reset()
      ..color = color
      ..height = slot.dollHeight(size)
      ..baseX = slot.centerX
      ..baseY = baseY
      ..symbols = symbols
      ..silhouette = silhouette
      ..scaleX = scale
      ..scaleY = scale;
    renderer.paint(canvas, _doll);
  }

  /// The pip bar (spec §10.3, NestyBoard:164): `maxSize` pips, biggest on
  /// the left, filled in the nest's base colour with a cream ring for the
  /// sizes inside it. The design draws none on an extra slot.
  void _paintPips(Canvas canvas, SlotGeometry slot, DebugSlot contents) {
    if (slot.kind == SlotShapeKind.extra) return;
    final radius = slot.pipDiameter / 2;
    final ring = BoardTokens.pipFilledRingWidth * slot.furnitureScale;
    final color = contents.color;
    if (color != null) _pipFill.color = DollPalette.of(color).base;
    for (var position = 0; position < slot.pipCount; position++) {
      final center = Offset(slot.pipCenterX(position), slot.pipCenterY);
      final size = slot.pipCount - position;
      if (color != null && contents.sizes.contains(size)) {
        canvas
          ..drawCircle(center, radius + ring, _pipRing)
          ..drawCircle(center, radius, _pipFill);
      } else {
        canvas.drawCircle(center, radius, _pipEmpty);
        _paintPipInset(canvas, center, radius, slot.furnitureScale);
      }
    }
  }

  /// An empty pip's `inset 0 1px 1px rgba(0,0,0,.6)` (NestyBoard:164): the
  /// pip's outside, shifted down 1 dp and blurred 1 dp, clipped to the pip.
  void _paintPipInset(Canvas canvas, Offset center, double radius, double s) {
    final pip = Rect.fromCircle(center: center, radius: radius);
    _pipInset.maskFilter = MaskFilter.blur(
      BlurStyle.normal,
      Shadow.convertRadiusToSigma(s),
    );
    canvas
      ..save()
      ..clipPath(Path()..addOval(pip))
      ..drawPath(
        Path()
          ..fillType = PathFillType.evenOdd
          ..addRect(pip.inflate(radius + 2 * s))
          ..addOval(pip.shift(Offset(0, s))),
        _pipInset,
      )
      ..restore();
  }

  /// The unlock colour's symbol on the padlock (NestyBoard:169, 12 dp ink),
  /// until the case has shattered.
  void _paintPadlock(Canvas canvas, SlotGeometry slot, DebugSlot contents) {
    final color = contents.unlockColor;
    if (slot.kind != SlotShapeKind.locked ||
        color == null ||
        contents.glassFrame >= 2) {
      return;
    }
    final swatch = DollPalette.of(color);
    final center = slot.padlockSymbolCenter;
    final side = slot.padlockSymbolSize;
    final atlas = symbolAtlas;
    final page = _padlockPage;
    final index = atlas?.indexOf(swatch.symbol) ?? -1;
    if (atlas == null || page == null || index < 0) {
      _fill.color = swatch.ink;
      canvas.drawCircle(center, side * 0.3, _fill);
      return;
    }
    // The page's cell covers the symbol box plus a margin; map the box
    // onto the padlock's square.
    final box = atlas.geometry.box(large: false);
    final k = side / box.width;
    final left = center.dx - side / 2;
    final top = center.dy - side / 2;
    final cell = page.subtleDst;
    _symbol.colorFilter = ColorFilter.mode(swatch.ink, BlendMode.srcIn);
    canvas.drawImageRect(
      page.image,
      page.subtleSrc(index),
      Rect.fromLTRB(
        left + (cell.left - box.left) * k,
        top + (cell.top - box.top) * k,
        left + (cell.right - box.left) * k,
        top + (cell.bottom - box.top) * k,
      ),
      _symbol,
    );
  }

  /// The walnut "+N" tag on a tower with buried nests (NestyBoard:168/16).
  void _paintTag(Canvas canvas, SlotGeometry slot, DebugSlot contents) {
    if (slot.kind != SlotShapeKind.tower || contents.buried.isEmpty) return;
    final s = slot.furnitureScale;
    final text = _text('+${contents.buried.length}', 12 * s, 14 / 12, _tagText);
    final origin = slot.towerTagOrigin;
    final pill = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        origin.dx,
        origin.dy,
        text.width + 12 * s,
        text.height + 4 * s,
      ),
      Radius.circular(8 * s),
    );
    _fill.color = _tagRing;
    canvas.drawRRect(pill.inflate(1.5 * s), _fill);
    _fill.color = _tagFill;
    canvas.drawRRect(pill, _fill);
    text
      ..paint(canvas, Offset(origin.dx + 6 * s, origin.dy + 2 * s))
      ..dispose();
  }

  /// The blue ice counter (NestyBoard:17/180); none once the ice is gone.
  void _paintIceBadge(Canvas canvas, SlotGeometry slot, DebugSlot contents) {
    if (contents.ice <= 0) return;
    final s = slot.furnitureScale;
    final rect = slot.iceBadgeRect;
    final center = rect.center;
    final radius = rect.width / 2;
    _fill
      ..shader = null
      ..color = _badgeEdge;
    canvas.drawCircle(center.translate(0, 3 * s), radius + 2.5 * s, _fill);
    _fill.color = _badgeRing;
    canvas.drawCircle(center, radius + 2.5 * s, _fill);
    _fill.shader = ui.Gradient.linear(rect.topCenter, rect.bottomCenter, [
      _badgeTop,
      _badgeBottom,
    ]);
    canvas.drawCircle(center, radius, _fill);
    _fill.shader = null;
    final text = _text('${contents.ice}', 16 * s, 1, _badgeRing);
    text
      ..paint(
        canvas,
        Offset(center.dx - text.width / 2, center.dy - text.height / 2),
      )
      ..dispose();
  }

  static TextPainter _text(
    String text,
    double fontSize,
    double height,
    Color color,
  ) => TextPainter(
    text: TextSpan(
      text: text,
      style: TextStyle(
        // Bundled by the game (tools/fonts); elsewhere the platform's
        // default font stands in.
        fontFamily: 'Fredoka',
        fontWeight: FontWeight.w700,
        fontSize: fontSize,
        height: height,
        color: color,
      ),
    ),
    textDirection: TextDirection.ltr,
  )..layout();

  /// One symbol page whose subtle cell is the largest padlock symbol on the
  /// board, in device px (the cell is 110 of the artboard's 768).
  Future<void> _preparePadlocks(
    BoardGeometry geometry,
    double devicePixelRatio,
  ) async {
    final atlas = symbolAtlas;
    if (atlas == null) return;
    var side = 0.0;
    for (final slot in geometry.slots) {
      if (slot.kind == SlotShapeKind.locked) {
        side = math.max(side, slot.padlockSymbolSize);
      }
    }
    if (side <= 0) return;
    final geometryOf = atlas.geometry;
    final artHeightPx = math.max(
      1,
      (side *
              devicePixelRatio *
              geometryOf.artboardHeight /
              geometryOf.subtleSize)
          .round(),
    );
    if (_padlockPage?.artHeightPx == artHeightPx) return;
    final page = await atlas.obtain(artHeightPx);
    _padlockPage?.dispose();
    _padlockPage = page;
  }
}
