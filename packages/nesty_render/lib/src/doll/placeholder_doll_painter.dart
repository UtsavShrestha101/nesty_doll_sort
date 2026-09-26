import 'dart:math' as math;
import 'dart:typed_data' show Float64List;
import 'dart:ui';

import 'package:nesty_render/src/doll/doll_art.dart';
import 'package:nesty_render/src/doll/doll_effects.dart';
import 'package:nesty_render/src/doll/doll_paint_params.dart';
import 'package:nesty_render/src/doll/doll_renderer.dart';
import 'package:nesty_render/src/palette/doll_palette.dart';
import 'package:nesty_render/src/palette/doll_tint.dart';
import 'package:nesty_render/src/skin/symbol_atlas.dart';
import 'package:nesty_render/src/tokens/render_token_types.dart';
import 'package:nesty_render/src/tokens/render_tokens.gen.dart';

/// The procedural doll of spec §12.5, drawn in code: a rounded body and a
/// circular head shaded with a radial gradient of the doll colour, a white
/// oval face with dot eyes, the lid split line and the belly symbol.
///
/// It has the same API and art-space geometry as the skin renderer (base,
/// lid lift, rim, symbols, silhouette, shine, reveal), is always ready, and
/// is what `FallbackDollRenderer` draws until a skin is prepared or when a
/// skin fails to load. Everything is built in the constructor; painting
/// allocates nothing (CLAUDE.md rule 8).
///
/// In the game it also draws the rule-3 part rasters
/// (`DollPartRasters.preparePlaceholder`): its closed doll cut on the lid
/// split row, for the Lottie image slots and the rest sprites alike when
/// the skin fails (docs/plans/m2-lottie-design.md §4).
///
/// Symbols come from [symbols] once [prepare] has obtained a page; without
/// an atlas (widget tests, the fake DI env) the doll is drawn without one.
final class PlaceholderDollPainter implements DollRenderer {
  PlaceholderDollPainter({SymbolAtlas? symbols, this.maxPreparedHeights = 8})
    : _symbols = symbols {
    for (final swatch in DollPalette.values) {
      _bodyPaint.add(Paint()..shader = _bodyShader(swatch.tint));
      _headPaint.add(Paint()..shader = _headShader(swatch.tint));
      _seamPaint.add(
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 6
          ..strokeCap = StrokeCap.round
          ..color = swatch.ink.withValues(alpha: 0.55),
      );
      _rimOuter.add(Paint()..color = swatch.rimColor);
      _ring.add(
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = SkinTokens.badgeStroke
          ..color = swatch.ink,
      );
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
  final _bodyPaint = <Paint>[];
  final _headPaint = <Paint>[];
  final _seamPaint = <Paint>[];
  final _rimOuter = <Paint>[];
  final _ring = <Paint>[];
  final _symbolSubtle = <Paint>[];
  final _symbolLarge = <Paint>[];
  final _symbolIndex = <int>[];
  final Paint _woodBody = Paint()..shader = _bodyShader(DollPalette.woodTint);
  final Paint _woodHead = Paint()..shader = _headShader(DollPalette.woodTint);
  final Paint _shadowPaint = Paint()..shader = _shadowShader();
  final Paint _face = Paint()..color = _faceColor;
  final Paint _eye = Paint()..color = _eyeColor;
  final Paint _discFill = Paint()..color = SkinTokens.badgeFill;
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
    // The sweep crosses the whole closed doll, so only the full part.
    if (p.shine >= 0 && p.shine <= 1 && p.part == DollPart.full) {
      canvas
        ..save()
        ..clipPath(_shape);
      _fx.paintBand(canvas, p.shine);
      canvas.restore();
    }

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
        ..clipRect(_bodyClip)
        ..drawPath(_body, _bodyPaint[ci])
        ..restore();
      _paintSymbol(canvas, p, ci);
      if (raised) {
        if (!front) _paintRim(canvas, ci);
      } else if (lid) {
        canvas.drawLine(_seamStart, _seamEnd, _seamPaint[ci]);
      }
    }
    if (lid) {
      final lift = p.lidLift * DollArt.height;
      if (lift != 0) canvas.translate(0, -lift);
      canvas
        ..save()
        ..clipRect(_lidClip)
        ..drawPath(_body, _bodyPaint[ci])
        ..restore()
        ..drawCircle(_headCenter, _headRadius, _headPaint[ci])
        ..drawOval(_faceRect, _face)
        ..drawCircle(_leftEye, _eyeRadius, _eye)
        ..drawCircle(_rightEye, _eyeRadius, _eye);
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
    canvas
      ..drawPath(_body, _woodBody)
      ..drawCircle(_headCenter, _headRadius, _woodHead);
  }

  void _paintSymbol(Canvas canvas, DollPaintParams p, int ci) {
    if (p.symbols == DollSymbols.none) return;
    final page = _pageFor(p.height);
    final index = _symbolIndex[ci];
    if (p.symbols == DollSymbols.large) {
      canvas
        ..drawPath(_disc, _discFill)
        ..drawPath(_disc, _ring[ci]);
      if (page != null && index >= 0) {
        canvas.drawImageRect(
          page.image,
          page.largeSrc(index),
          page.largeDst,
          _symbolLarge[ci],
        );
      }
    } else if (page != null && index >= 0) {
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
  // placeholder and a skinned doll of one height line up.
  // TODO(design): the handoff has no frame for the spec §12.5 placeholder;
  // its proportions, face and seam (ink at 55 %, 6 units) follow the classic
  // skin and the mask shading until the owner wants a designed fallback.
  static const _headCenter = Offset(256, 196);
  static const _headRadius = 150.0;
  static const _faceRect = Rect.fromLTRB(164, 110, 348, 302); // classic face
  static const _leftEye = Offset(220, 226);
  static const _rightEye = Offset(292, 226);
  static const _eyeRadius = 11.0;
  static const _faceColor = Color(0xFFFFF8EE);
  static const _eyeColor = Color(0xFF2B1A10); // classic eye ink
  static const _bodyBounds = Rect.fromLTRB(50, 300, 462, 742);
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
  static final Path _disc = DollArt.ellipsePath(
    TokenEllipse(
      cx: SkinTokens.symbolAnchor.dx,
      cy: SkinTokens.symbolAnchor.dy,
      rx: SkinTokens.badgeRadius,
      ry: SkinTokens.badgeRadius,
    ),
  );

  static final Path _body = Path()
    ..moveTo(256, 300)
    ..cubicTo(392, 300, 462, 420, 462, 580)
    ..cubicTo(462, 690, 420, 742, 360, 742)
    ..lineTo(152, 742)
    ..cubicTo(92, 742, 50, 690, 50, 580)
    ..cubicTo(50, 420, 120, 300, 256, 300)
    ..close();

  static final Path _shape = Path.combine(
    PathOperation.union,
    _body,
    Path()..addOval(Rect.fromCircle(center: _headCenter, radius: _headRadius)),
  );

  // Where the body's right edge crosses splitY: the seam spans it, inset so
  // the round caps stay inside the outline.
  static final double _seamHalf = _bodyHalfWidthAt(SkinTokens.splitY) - 10;
  static final Offset _seamStart = Offset(256 - _seamHalf, SkinTokens.splitY);
  static final Offset _seamEnd = Offset(256 + _seamHalf, SkinTokens.splitY);

  static double _bodyHalfWidthAt(double y) {
    // The first cubic, (256,300) → (462,580), bisected on y.
    double at(double t, double a, double b, double c, double d) {
      final u = 1 - t;
      return u * u * u * a +
          3 * u * u * t * b +
          3 * u * t * t * c +
          t * t * t * d;
    }

    var lo = 0.0;
    var hi = 1.0;
    for (var i = 0; i < 40; i++) {
      final mid = (lo + hi) / 2;
      if (at(mid, 300, 300, 420, 580) < y) {
        lo = mid;
      } else {
        hi = mid;
      }
    }
    return at(lo, 256, 392, 462, 462) - 256;
  }

  // The skins' mask shading: the gray stops of classic `bm-shade` /
  // `tm-shade` (#FFF, #F3F3F3, #D0D0D0, #A6A6A6) through the colour's tint,
  // so gold gets its gradient map here too.
  static List<Color> _stops(DollTint tint) => [
    tint.mapGray(0xFF),
    tint.mapGray(0xF3),
    tint.mapGray(0xD0),
    tint.mapGray(0xA6),
  ];
  static const _stopPositions = [0.0, 0.5, 0.82, 1.0];

  static Shader _bodyShader(DollTint tint) => Gradient.radial(
    Offset(
      _bodyBounds.left + _bodyBounds.width * 0.38,
      _bodyBounds.top + _bodyBounds.height * 0.36,
    ),
    _bodyBounds.longestSide * 0.78,
    _stops(tint),
    _stopPositions,
  );

  static Shader _headShader(DollTint tint) => Gradient.radial(
    Offset(
      _headCenter.dx - _headRadius + 2 * _headRadius * 0.36,
      _headCenter.dy - _headRadius + 2 * _headRadius * 0.3,
    ),
    2 * _headRadius * 0.8,
    _stops(tint),
    _stopPositions,
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
