import 'dart:math' as math;
import 'dart:ui';

import 'package:nesty_core/nesty_core.dart';
import 'package:nesty_render/src/doll/doll_art.dart';
import 'package:nesty_render/src/doll/doll_effects.dart';
import 'package:nesty_render/src/doll/doll_paint_params.dart';
import 'package:nesty_render/src/doll/doll_renderer.dart';
import 'package:nesty_render/src/palette/doll_palette.dart';
import 'package:nesty_render/src/palette/doll_tint.dart';
import 'package:nesty_render/src/skin/skin_cache.dart';
import 'package:nesty_render/src/skin/skin_image_set.dart';
import 'package:nesty_render/src/skin/skin_layer.dart';
import 'package:nesty_render/src/skin/skin_manifest.dart';
import 'package:nesty_render/src/skin/skin_rasterizer.dart';
import 'package:nesty_render/src/skin/symbol_atlas.dart';
import 'package:nesty_render/src/tokens/render_token_types.dart';
import 'package:nesty_render/src/tokens/render_tokens.gen.dart';

/// Draws dolls from a layered SVG skin (spec §12.2): every layer is
/// rasterized once per prepared height ([SkinCache]) and a frame is only
/// `drawImageRect`s plus the rim/disc paths, with paints, filters and paths
/// built in the constructor (CLAUDE.md rule 8).
///
/// Flat colours tint the gray masks with one cached
/// `ColorFilter.mode(base, BlendMode.modulate)` each; gold draws its own
/// pre-rasterized gradient-mapped masks (D19).
///
/// The rasterizer, [symbols] and [cache] are shared, not owned: dispose them
/// yourself. A renderer made without a cache creates and owns a private one.
final class SvgSkinRenderer implements DollRenderer {
  SvgSkinRenderer({
    required SkinRasterizer rasterizer,
    SkinCache? cache,
    SymbolAtlas? symbols,
    this.maxPreparedHeights = 8,
  }) : _rasterizer = rasterizer,
       _cache = cache ?? SkinCache(),
       _ownsCache = cache == null,
       _symbols = symbols,
       _manifest = rasterizer.manifest {
    final colors = DollColor.values.length;
    _maskPaint = List.filled(colors, _plain);
    _bodyMask = List.filled(colors, SkinLayer.bottomMask);
    _lidMask = List.filled(colors, SkinLayer.lidMask);
    _symbolIndex = List.filled(colors, -1);
    for (final swatch in DollPalette.values) {
      final i = swatch.color.index;
      switch (swatch.tint) {
        case ModulateTint(:final color):
          _maskPaint[i] = _imagePaint()
            ..colorFilter = ColorFilter.mode(color, BlendMode.modulate);
        case GradientMapTint():
          _bodyMask[i] = SkinLayer.goldBottomMask;
          _lidMask[i] = SkinLayer.goldLidMask;
      }
      _symbolIndex[i] = symbols?.indexOf(swatch.symbol) ?? -1;
    }
    _symbolSubtle = [
      for (final s in DollPalette.values)
        _imagePaint()
          ..colorFilter = ColorFilter.mode(
            s.ink.withValues(alpha: DollArt.subtleSymbolOpacity),
            BlendMode.srcIn,
          ),
    ];
    _symbolLarge = [
      for (final s in DollPalette.values)
        _imagePaint()..colorFilter = ColorFilter.mode(s.ink, BlendMode.srcIn),
    ];
    _ring = [
      for (final s in DollPalette.values)
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = SkinTokens.badgeStroke
          ..color = s.ink,
    ];
    _rimOuter = [
      for (final s in DollPalette.values) Paint()..color = s.rimColor,
    ];
    _disc = DollArt.ellipsePath(
      TokenEllipse(
        cx: _manifest.symbolAnchor.dx,
        cy: _manifest.symbolAnchor.dy,
        rx: SkinTokens.badgeRadius,
        ry: SkinTokens.badgeRadius,
      ),
    );
  }

  /// Most heights kept prepared; older ones are released first.
  final int maxPreparedHeights;

  final SkinRasterizer _rasterizer;
  final SkinCache _cache;
  final bool _ownsCache;
  final SymbolAtlas? _symbols;
  final SkinManifest _manifest;

  final _slots = <_Slot>[]; // ascending pixel height
  final _building = <int, Future<void>>{};
  double _devicePixelRatio = 1;
  int _tick = 0;
  bool _disposed = false;

  final _fx = DollEffects();
  static Paint _imagePaint() => Paint()..filterQuality = FilterQuality.medium;
  final Paint _plain = _imagePaint();
  final Paint _discFill = Paint()..color = SkinTokens.badgeFill;
  final Paint _rimInner = Paint()
    ..color = SkinTokens.interiorRimInnerFill.withValues(
      alpha: SkinTokens.interiorRimInnerOpacity,
    );
  late final List<Paint> _maskPaint;
  late final List<SkinLayer> _bodyMask;
  late final List<SkinLayer> _lidMask;
  late final List<int> _symbolIndex;
  late final List<Paint> _symbolSubtle;
  late final List<Paint> _symbolLarge;
  late final List<Paint> _ring;
  late final List<Paint> _rimOuter;
  late final Path _disc;

  /// The skin this renderer draws.
  SkinManifest get manifest => _manifest;

  /// Artboard pixel heights currently prepared, ascending (for tests and
  /// memory reports).
  List<int> get preparedPixelHeights => [for (final s in _slots) s.px];

  /// GPU bytes of the prepared layer and symbol images.
  int get preparedByteSize {
    var total = 0;
    for (final s in _slots) {
      total += s.set.byteSize + (s.symbols?.byteSize ?? 0);
    }
    return total;
  }

  @override
  Future<void> prepare({
    required Iterable<double> heights,
    required double devicePixelRatio,
  }) async {
    if (_disposed) throw StateError('SvgSkinRenderer used after dispose');
    _devicePixelRatio = devicePixelRatio;
    final tick = ++_tick;
    final wanted = <int>{
      for (final h in heights)
        if (h.isFinite && h > 0) math.max(1, (h * devicePixelRatio).round()),
    };
    final waits = <Future<void>>[];
    for (final px in wanted) {
      final slot = _slotAt(px);
      if (slot != null) {
        slot.lastUsed = tick;
      } else {
        waits.add(_building[px] ??= _build(px, tick));
      }
    }
    await Future.wait(waits);
    for (final px in wanted) {
      _slotAt(px)?.lastUsed = tick;
    }
    _evict(wanted);
  }

  @override
  void dispose() {
    if (_disposed) return;
    _disposed = true;
    for (final slot in _slots) {
      slot.dispose();
    }
    _slots.clear();
    if (_ownsCache) _cache.clear();
  }

  // ── Hot path: runs every frame. No allocation (CLAUDE.md rule 8). ──

  @override
  bool isReadyFor(double height) {
    final target = height * _devicePixelRatio;
    for (var i = 0; i < _slots.length; i++) {
      if ((_slots[i].px - target).abs() <= 0.5 + 1e-6) return true;
    }
    return false;
  }

  /// True once any height is prepared: [paint] draws every other height
  /// from the nearest larger raster (else the largest), resampled.
  @override
  bool canPaint(double height) => !_disposed && _slots.isNotEmpty;

  @override
  void paint(Canvas canvas, DollPaintParams p) {
    if (_disposed || _slots.isEmpty || p.height <= 0 || p.opacity <= 0) {
      return;
    }
    final slot = _slotFor(p.height);
    final set = slot.set;
    final k = p.height / DollArt.height;
    // The rasters are cropped so a doll at its prepared height on a whole
    // device pixel is sampled 1:1 (SkinRasterizer); layout positions are
    // fractional (cx 55.5 at DPR 3 is 166.5 px), so an upright, unscaled
    // doll's base is snapped to the device grid (review RENDER-9). Rotated
    // or scaled dolls are resampled anyway and keep their exact position.
    var baseX = p.baseX;
    var baseY = p.baseY;
    if (p.rotation == 0 && p.scaleX == 1 && p.scaleY == 1) {
      final dpr = _devicePixelRatio;
      baseX = (baseX * dpr).roundToDouble() / dpr;
      baseY = (baseY * dpr).roundToDouble() / dpr;
    }
    canvas
      ..save()
      ..translate(baseX, baseY);
    if (p.rotation != 0) canvas.rotate(p.rotation);
    canvas
      ..scale(k * p.scaleX, k * p.scaleY)
      ..translate(-DollArt.base.dx, -DollArt.base.dy);
    final fading = p.opacity < 1;
    if (fading) _fx.beginFade(canvas, p.opacity);

    if (p.silhouette) {
      _paintSilhouette(canvas, set, shadow: p.shadow);
    } else if (p.reveal >= 0 && p.reveal < 1) {
      // Spec §3.2 reveal: the wood silhouette, then the coloured doll
      // through a growing circle (without a second shadow).
      _paintSilhouette(canvas, set, shadow: p.shadow);
      if (p.reveal > 0) {
        canvas.save();
        _fx.clipReveal(canvas, p.reveal);
        _paintColored(canvas, p, slot, shadow: false);
        canvas.restore();
      }
    } else {
      _paintColored(canvas, p, slot, shadow: p.shadow);
    }
    // The sweep crosses the whole closed doll, so only the full part.
    if (p.shine >= 0 && p.shine <= 1 && p.part == DollPart.full) {
      _paintShine(canvas, set, p.shine);
    }

    if (fading) canvas.restore();
    canvas.restore();
  }

  void _paintColored(
    Canvas canvas,
    DollPaintParams p,
    _Slot slot, {
    required bool shadow,
  }) {
    final set = slot.set;
    final ci = p.color.index;
    final part = p.part;
    if (part == DollPart.interior) {
      _paintRim(canvas, ci);
      return;
    }
    final front = part == DollPart.bodyFront;
    final body = part != DollPart.lid;
    final lid = part == DollPart.full || part == DollPart.lid;
    if (front) {
      // The nest frame's body: only below the split, so the doll inside
      // shows through the hollow above it.
      canvas
        ..save()
        ..clipRect(DollArt.bodyFrontClip);
    }
    if (body) {
      if (shadow) _draw(canvas, set[SkinLayer.shadow], _plain);
      _draw(canvas, set[_bodyMask[ci]], _maskPaint[ci]);
      _draw(canvas, set[SkinLayer.bottomDetail], _plain);
      _paintSymbol(canvas, p.symbols, ci, slot);
      // design/README.md "Doll rendering" step 4: the rim goes in before
      // the lid, whenever the lid is up. The front body leaves it to the
      // interior pass, drawn under the doll inside.
      if (!front && (p.open || p.lidLift > 0)) _paintRim(canvas, ci);
    }
    if (lid) {
      final lift = p.lidLift * DollArt.height;
      if (lift != 0) canvas.translate(0, -lift);
      _draw(canvas, set[_lidMask[ci]], _maskPaint[ci]);
      _draw(canvas, set[SkinLayer.lidOverlay], _plain);
      if (lift != 0) canvas.translate(0, lift);
    }
    // shine_bottom is the last group of the SVG: over the lid, as there.
    if (body) _draw(canvas, set[SkinLayer.bodyShine], _plain);
    if (front) canvas.restore();
  }

  void _paintRim(Canvas canvas, int ci) {
    canvas
      ..drawPath(DollArt.rimOuter, _rimOuter[ci])
      ..drawPath(DollArt.rimInner, _rimInner);
  }

  void _paintSymbol(Canvas canvas, DollSymbols mode, int ci, _Slot slot) {
    if (mode == DollSymbols.none) return;
    final page = slot.symbols;
    final index = _symbolIndex[ci];
    if (mode == DollSymbols.large) {
      canvas
        ..drawPath(_disc, _discFill)
        ..drawPath(_disc, _ring[ci]);
      if (page != null && index >= 0) {
        canvas.drawImageRect(
          page.image,
          page.largeSrc(index),
          slot.largeDst,
          _symbolLarge[ci],
        );
      }
    } else if (page != null && index >= 0) {
      canvas.drawImageRect(
        page.image,
        page.subtleSrc(index),
        slot.subtleDst,
        _symbolSubtle[ci],
      );
    }
  }

  void _paintSilhouette(
    Canvas canvas,
    SkinImageSet set, {
    required bool shadow,
  }) {
    if (shadow) _draw(canvas, set[SkinLayer.shadow], _plain);
    _draw(canvas, set[SkinLayer.silhouette], _plain);
  }

  // The band inside a layer clipped to the doll's box, then cut to the
  // doll's shape with the silhouette's alpha (dstIn).
  void _paintShine(Canvas canvas, SkinImageSet set, double progress) {
    final shape = set[SkinLayer.silhouette];
    if (shape == null) return;
    canvas
      ..saveLayer(shape.dst, _plain)
      ..clipRect(shape.dst);
    _fx.paintBand(canvas, progress);
    canvas
      ..drawImageRect(shape.image, shape.src, shape.dst, _fx.dstIn)
      ..restore();
  }

  static void _draw(Canvas canvas, SkinLayerImage? layer, Paint paint) {
    if (layer != null) {
      canvas.drawImageRect(layer.image, layer.src, layer.dst, paint);
    }
  }

  // The prepared height itself, else the next larger one (downscaling looks
  // better than upscaling), else the largest.
  _Slot _slotFor(double height) {
    final target = height * _devicePixelRatio - 0.5 - 1e-6;
    for (var i = 0; i < _slots.length; i++) {
      if (_slots[i].px >= target) return _slots[i];
    }
    return _slots[_slots.length - 1];
  }

  // ── End of hot path. ──

  _Slot? _slotAt(int px) {
    for (final slot in _slots) {
      if (slot.px == px) return slot;
    }
    return null;
  }

  Future<void> _build(int px, int tick) async {
    try {
      final set = await _cache.obtain(_rasterizer, px);
      SymbolAtlasPage? page;
      try {
        page = await _symbols?.obtain(px);
      } on Object {
        set.dispose();
        rethrow;
      }
      if (_disposed) {
        set.dispose();
        page?.dispose();
        return;
      }
      final slot = _Slot(px, set, page, _manifest, _symbols?.geometry)
        ..lastUsed = tick;
      var at = 0;
      while (at < _slots.length && _slots[at].px < px) {
        at++;
      }
      _slots.insert(at, slot);
    } finally {
      final removed = _building.remove(px);
      assert(removed != null, 'building $px');
    }
  }

  void _evict(Set<int> keep) {
    while (_slots.length > math.max(1, maxPreparedHeights)) {
      _Slot? oldest;
      for (final slot in _slots) {
        if (keep.contains(slot.px)) continue;
        if (oldest == null || slot.lastUsed < oldest.lastUsed) oldest = slot;
      }
      if (oldest == null) return;
      _slots.remove(oldest);
      oldest.dispose();
    }
  }
}

/// One prepared height: its layer images and symbol page (clones this
/// renderer owns) and the symbol boxes placed for this skin.
final class _Slot {
  _Slot(
    this.px,
    this.set,
    this.symbols,
    SkinManifest manifest,
    SymbolGeometry? geometry,
  ) : subtleDst = _place(
        symbols?.subtleDst,
        geometry,
        manifest.symbolAnchor,
        geometry == null ? 1 : manifest.symbolSize / geometry.subtleSize,
      ),
      largeDst = _place(symbols?.largeDst, geometry, manifest.symbolAnchor, 1);

  final int px;
  final SkinImageSet set;
  final SymbolAtlasPage? symbols;
  final Rect subtleDst;
  final Rect largeDst;
  int lastUsed = 0;

  void dispose() {
    set.dispose();
    symbols?.dispose();
  }

  // Atlas cells are laid out for the atlas geometry; a skin whose
  // skin.json moves or resizes the symbol box gets the cell moved/scaled to
  // match (every shipped skin equals the tokens, so this is the identity).
  static Rect _place(
    Rect? cell,
    SymbolGeometry? geometry,
    Offset anchor,
    double ratio,
  ) {
    if (cell == null || geometry == null) return Rect.zero;
    final from = geometry.anchor;
    return Rect.fromLTRB(
      anchor.dx + (cell.left - from.dx) * ratio,
      anchor.dy + (cell.top - from.dy) * ratio,
      anchor.dx + (cell.right - from.dx) * ratio,
      anchor.dy + (cell.bottom - from.dy) * ratio,
    );
  }
}
