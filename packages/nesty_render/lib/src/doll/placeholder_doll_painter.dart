import 'dart:math' as math;
import 'dart:typed_data' show Float64List;
import 'dart:ui';

import 'package:nesty_render/src/doll/doll_art.dart';
import 'package:nesty_render/src/doll/doll_effects.dart';
import 'package:nesty_render/src/doll/doll_paint_params.dart';
import 'package:nesty_render/src/doll/doll_renderer.dart';
import 'package:nesty_render/src/palette/doll_palette.dart';
import 'package:nesty_render/src/skin/symbol_atlas.dart';
import 'package:nesty_render/src/tokens/render_tokens.gen.dart';

/// The procedural doll of spec §12.5 and `layout.fallbackDoll` (E.19), drawn
/// in code: two stacked rounded shapes in the doll colour, each with a darker
/// bottom band (a circular head, 0.36 h, and a rounded body, 0.48 h × 0.52
/// w), a cream face disc (0.19 h) on the head and a cream belly disc (0.2 h)
/// with the colour's symbol in ink. No painted details and no shine.
///
/// It has the same API and art-space geometry as the skin renderer (base,
/// lid lift, rim, symbols, silhouette, reveal), is always ready, and is what
/// `FallbackDollRenderer` draws until a skin is prepared, when a skin fails
/// to load, and on the splash's first frames (Q58). Everything is built in
/// the constructor; painting allocates nothing (CLAUDE.md rule 8).
///
/// In the game it also draws the rule-3 part rasters
/// (`DollPartRasters.preparePlaceholder`): its closed doll cut on the lid
/// split row, for the Lottie image slots and the rest sprites alike when
/// the skin fails (docs/plans/m2-lottie-design.md §4).
///
/// Symbols come from [symbols] once [prepare] has obtained a page; without
/// an atlas (widget tests, the fake DI env) the discs are drawn without one.
final class PlaceholderDollPainter implements DollRenderer {
  PlaceholderDollPainter({SymbolAtlas? symbols, this.maxPreparedHeights = 8})
    : _symbols = symbols {
    for (final swatch in DollPalette.values) {
      _base.add(Paint()..color = swatch.tint.mapGray(0xFF));
      _shade.add(Paint()..color = swatch.tint.mapGray(_shadeGray));
      _rimOuter.add(Paint()..color = swatch.rimColor);
      _symbolSubtle.add(
        Paint()
          ..filterQuality = FilterQuality.medium
          ..colorFilter = ColorFilter.mode(
            swatch.ink.withValues(alpha: DollArt.subtleSymbolOpacity),
            BlendMode.srcIn,
          ),
      );
      _symbolLarge.add(
        Paint()
          ..filterQuality = FilterQuality.medium
          ..colorFilter = ColorFilter.mode(swatch.ink, BlendMode.srcIn),
      );
      _symbolIndex.add(symbols?.indexOf(swatch.symbol) ?? -1);
    }
  }

  final int maxPreparedHeights;
  final SymbolAtlas? _symbols;
  final _pages = <SymbolAtlasPage>[]; // ascending pixel height
  final _pageUse = <int>[];
  double _devicePixelRatio = 1;
  int _tick = 0;
  bool _disposed = false;

  final _fx = DollEffects();
  final _base = <Paint>[];
  final _shade = <Paint>[];
  final _rimOuter = <Paint>[];
  final _symbolSubtle = <Paint>[];
  final _symbolLarge = <Paint>[];
  final _symbolIndex = <int>[];
  final Paint _woodBase = Paint()..color = DollPalette.woodTint.mapGray(0xFF);
  final Paint _woodShade = Paint()
    ..color = DollPalette.woodTint.mapGray(_shadeGray);
  final Paint _shadowPaint = Paint()..shader = _shadowShader();
  final Paint _disc = Paint()..color = FallbackDollTokens.faceColor;
  final Paint _rimInner = Paint()
    ..color = SkinTokens.interiorRimInnerFill.withValues(
      alpha: SkinTokens.interiorRimInnerOpacity,
    );

  @override
  Future<void> prepare({
    required Iterable<double> heights,
    required double devicePixelRatio,
  }) async {
    if (_disposed) {
      throw StateError('PlaceholderDollPainter used after dispose');
    }
    _devicePixelRatio = devicePixelRatio;
    final atlas = _symbols;
    if (atlas == null) return;
    final tick = ++_tick;
    final wanted = <int>{
      for (final h in heights)
        if (h.isFinite && h > 0) math.max(1, (h * devicePixelRatio).round()),
    };
    final missing = <int>[];
    for (final px in wanted) {
      final i = _pageIndex(px);
      if (i >= 0) {
        _pageUse[i] = tick;
      } else {
        missing.add(px);
      }
    }
    final pages = await Future.wait([
      for (final px in missing) atlas.obtain(px),
    ]);
    for (final page in pages) {
      if (_disposed || _pageIndex(page.artHeightPx) >= 0) {
        page.dispose();
        continue;
      }
      var at = 0;
      while (at < _pages.length && _pages[at].artHeightPx < page.artHeightPx) {
        at++;
      }
      _pages.insert(at, page);
      _pageUse.insert(at, tick);
    }
    while (_pages.length > math.max(1, maxPreparedHeights)) {
      var oldest = -1;
      for (var i = 0; i < _pages.length; i++) {
        if (wanted.contains(_pages[i].artHeightPx)) continue;
        if (oldest < 0 || _pageUse[i] < _pageUse[oldest]) oldest = i;
      }
      if (oldest < 0) break;
      _pages.removeAt(oldest).dispose();
      _pageUse.removeAt(oldest);
    }
  }

  @override
  void dispose() {
    if (_disposed) return;
    _disposed = true;
    for (final page in _pages) {
      page.dispose();
    }
    _pages.clear();
    _pageUse.clear();
  }

  // ── Hot path: runs every frame. No allocation (CLAUDE.md rule 8). ──

  /// Always true: the placeholder needs nothing rasterized.
  @override
  bool isReadyFor(double height) => !_disposed;

  /// Always true, like [isReadyFor].
  @override
  bool canPaint(double height) => !_disposed;

  @override
  void paint(Canvas canvas, DollPaintParams p) {
    if (_disposed || p.height <= 0 || p.opacity <= 0) return;
    final k = p.height / DollArt.height;
    canvas
      ..save()
      ..translate(p.baseX, p.baseY);
    if (p.rotation != 0) canvas.rotate(p.rotation);
    canvas
      ..scale(k * p.scaleX, k * p.scaleY)
      ..translate(-DollArt.base.dx, -DollArt.base.dy);
    final fading = p.opacity < 1;
    if (fading) _fx.beginFade(canvas, p.opacity);

    if (p.silhouette) {
      _paintSilhouette(canvas, shadow: p.shadow);
    } else if (p.reveal >= 0 && p.reveal < 1) {
      _paintSilhouette(canvas, shadow: p.shadow);
      if (p.reveal > 0) {
        canvas.save();
        _fx.clipReveal(canvas, p.reveal);
        _paintColored(canvas, p, shadow: false);
        canvas.restore();
      }
    } else {
      _paintColored(canvas, p, shadow: p.shadow);
    }
    // No shine: the fallback has no painted details (E.19).

    if (fading) canvas.restore();
    canvas.restore();
  }

  void _paintColored(Canvas canvas, DollPaintParams p, {required bool shadow}) {
    final ci = p.color.index;
    final part = p.part;
    if (part == DollPart.interior) {
      _paintRim(canvas, ci);
      return;
    }
    // The front body leaves the rim to the interior pass (DollPart docs);
    // its body is already cut at the split line.
    final front = part == DollPart.bodyFront;
    final body = part != DollPart.lid;
    final lid = part == DollPart.full || part == DollPart.lid;
    final raised = p.open || p.lidLift > 0;
    if (body) {
      if (shadow) canvas.drawOval(_shadowRect, _shadowPaint);
      canvas
        ..save()
        ..clipRect(_bodyClip);
      _paintShapes(canvas, _base[ci], _shade[ci]);
      canvas.restore();
      _paintBelly(canvas, p, ci);
      if (raised && !front) _paintRim(canvas, ci);
    }
    if (lid) {
      final lift = p.lidLift * DollArt.height;
      if (lift != 0) canvas.translate(0, -lift);
      canvas
        ..save()
        ..clipRect(_lidClip);
      _paintShapes(canvas, _base[ci], _shade[ci]);
      canvas
        ..restore()
        ..drawCircle(_headCenter, _faceRadius, _disc);
      if (lift != 0) canvas.translate(0, lift);
    }
  }

  void _paintRim(Canvas canvas, int ci) {
    canvas
      ..drawPath(DollArt.rimOuter, _rimOuter[ci])
      ..drawPath(DollArt.rimInner, _rimInner);
  }

  void _paintSilhouette(Canvas canvas, {required bool shadow}) {
    if (shadow) canvas.drawOval(_shadowRect, _shadowPaint);
    _paintShapes(canvas, _woodBase, _woodShade);
  }

  /// The body, then the head over it: each its darker shape with the base
  /// colour over all but its bottom band.
  void _paintShapes(Canvas canvas, Paint base, Paint shade) {
    canvas
      ..drawPath(_bodyShape, shade)
      ..drawPath(_bodyLit, base)
      ..drawPath(_headShape, shade)
      ..drawPath(_headLit, base);
  }

  /// The cream belly disc and, unless symbols are off, the colour's symbol
  /// in ink on it (`layout.fallbackDoll.belly`).
  void _paintBelly(Canvas canvas, DollPaintParams p, int ci) {
    canvas.drawCircle(SkinTokens.symbolAnchor, _bellyRadius, _disc);
    if (p.symbols == DollSymbols.none) return;
    final page = _pageFor(p.height);
    final index = _symbolIndex[ci];
    if (page == null || index < 0) return;
    if (p.symbols == DollSymbols.large) {
      canvas.drawImageRect(
        page.image,
        page.largeSrc(index),
        page.largeDst,
        _symbolLarge[ci],
      );
    } else {
      canvas.drawImageRect(
        page.image,
        page.subtleSrc(index),
        page.subtleDst,
        _symbolSubtle[ci],
      );
    }
  }

  SymbolAtlasPage? _pageFor(double height) {
    if (_pages.isEmpty) return null;
    final target = height * _devicePixelRatio - 0.5 - 1e-6;
    for (var i = 0; i < _pages.length; i++) {
      if (_pages[i].artHeightPx >= target) return _pages[i];
    }
    return _pages[_pages.length - 1];
  }

  // ── End of hot path. ──

  int _pageIndex(int px) {
    for (var i = 0; i < _pages.length; i++) {
      if (_pages[i].artHeightPx == px) return i;
    }
    return -1;
  }

  // Geometry, in art units on the same 512 × 768 board as the skins, so a
  // fallback and a skinned doll of one height line up. The sizes are the
  // design's `layout.fallbackDoll`: every size is a diameter (m7-6 item 20).
  static const _art = DollArt.height;
  static const _headRadius = FallbackDollTokens.headSize * _art / 2;
  static const _headCenter = Offset(DollArt.width / 2, 270);
  static const _faceRadius = FallbackDollTokens.faceSize * _art / 2;
  static const _bellyRadius = FallbackDollTokens.bellySize * _art / 2;
  static const _bodyWidth = FallbackDollTokens.bodyWidth * DollArt.width;
  static const _bodyHeight = FallbackDollTokens.bodyHeight * _art;
  static const _bodyRadius = FallbackDollTokens.bodyRadius * _art;

  /// The darker bottom band: 3 dp at the design's 150 dp doll.
  static const _shadeBand = FallbackDollTokens.headShade / 150 * _art;

  /// The band's tone: the shading gradient's darker stop.
  static const _shadeGray = 0xB8;

  static const _shadowRect = Rect.fromLTRB(66, 720, 446, 768);
  static const _lidClip = Rect.fromLTRB(
    0,
    -1,
    DollArt.width,
    SkinTokens.splitY,
  );
  static const _bodyClip = Rect.fromLTRB(
    0,
    SkinTokens.splitY,
    DollArt.width,
    DollArt.height,
  );

  static final Path _headShape = Path()
    ..addOval(Rect.fromCircle(center: _headCenter, radius: _headRadius));
  static final Path _bodyShape = Path()
    ..addRRect(
      RRect.fromLTRBR(
        (DollArt.width - _bodyWidth) / 2,
        DollArt.base.dy - _bodyHeight,
        (DollArt.width + _bodyWidth) / 2,
        DollArt.base.dy,
        const Radius.circular(_bodyRadius),
      ),
    );
  static final Path _headLit = _lit(_headShape);
  static final Path _bodyLit = _lit(_bodyShape);

  /// [shape] without its bottom band: where the shape and itself raised by
  /// the band overlap.
  static Path _lit(Path shape) => Path.combine(
    PathOperation.intersect,
    shape,
    shape.shift(const Offset(0, -_shadeBand)),
  );

  // The classic `shadow-grad`, squashed to the contact ellipse.
  static Shader _shadowShader() {
    final c = _shadowRect.center;
    final sy = _shadowRect.height / _shadowRect.width;
    return Gradient.radial(
      c,
      _shadowRect.width / 2,
      const [Color(0x612A1608), Color(0x2E2A1608), Color(0x002A1608)],
      const [0, 0.6, 1],
      TileMode.clamp,
      Float64List.fromList([
        1, 0, 0, 0, //
        0, sy, 0, 0, //
        0, 0, 1, 0, //
        0, c.dy * (1 - sy), 0, 1, //
      ]),
    );
  }
}
