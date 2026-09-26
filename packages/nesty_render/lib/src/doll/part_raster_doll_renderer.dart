import 'dart:ui';

import 'package:nesty_core/nesty_core.dart';
import 'package:nesty_render/src/doll/doll_art.dart';
import 'package:nesty_render/src/doll/doll_effects.dart';
import 'package:nesty_render/src/doll/doll_paint_params.dart';
import 'package:nesty_render/src/doll/doll_renderer.dart';
import 'package:nesty_render/src/skin/doll_part_rasters.dart';

/// The game's rest sprites: dolls drawn from the same [DollPartSet] the
/// Lottie image slots show (docs/plans/m2-lottie-design.md §4, PROGRESS
/// D45), so a sprite and a clip's first or last frame are pixel-identical
/// and the hand-off between them never jumps.
///
/// A doll is the body, then the lid, or the silhouette, each one image
/// draw with the Lottie's own transform: the raster's (256r, 742r) on the
/// base point, scaled `height / (768·r)`, `FilterQuality.medium` (the FX
/// runtime's `LottieDrawable.filterQuality`), and no pixel snapping. The
/// tallest doll samples its raster 1:1; smaller ones draw it down.
///
/// Of [DollPaintParams] it honours `color`, `height`, the base,
/// `silhouette`, `part` ([DollPart.lid] alone, [DollPart.body] and
/// [DollPart.bodyFront] as the body, [DollPart.interior] as nothing),
/// `lidLift`, `opacity`, `rotation` and `scaleX`/`scaleY`. The rasters
/// bake the rest in:
/// - `shadow`: every body and the silhouette stand on their shadow, as in
///   the Lottie slots;
/// - `symbols`: the bodies carry [DollPartSet.symbols]; a settings change
///   rebuilds the set (`SkinService.prepareForLevel`);
/// - `open`, `shine` and `reveal` are ignored: the rim, the completion
///   shine and the reveal wipe are drawn by the Lottie files.
///
/// A colour the set doesn't hold draws nothing.
///
/// Owns [parts]: [dispose] disposes it. Pass a clone to keep your own.
final class PartRasterDollRenderer implements DollRenderer {
  PartRasterDollRenderer(this.parts)
    : _src = Rect.fromLTWH(
        0,
        0,
        parts.widthPx.toDouble(),
        parts.artHeightPx.toDouble(),
      ),
      _toRaster = parts.artScale,
      _toArt = 1 / parts.artScale,
      _lids = List.generate(
        DollColor.values.length,
        (i) => parts.lid(DollColor.values[i]),
        growable: false,
      ),
      _bodies = List.generate(
        DollColor.values.length,
        (i) => parts.body(DollColor.values[i]),
        growable: false,
      );

  /// The rasters this renderer draws, owned.
  final DollPartSet parts;

  // Built once: the source and destination of every image draw, in raster
  // px (the whole image, as lottie's image layer draws it).
  final Rect _src;

  /// Raster px per art unit (`r`) and its inverse.
  final double _toRaster;
  final double _toArt;

  /// Per `DollColor.index`, null for colours the set doesn't hold.
  final List<Image?> _lids;
  final List<Image?> _bodies;

  final _fx = DollEffects();
  final Paint _paint = Paint()..filterQuality = FilterQuality.medium;
  bool _disposed = false;

  /// Nothing to do: [parts] was rasterized by `DollPartRasters` for the
  /// whole board before this renderer was made.
  @override
  Future<void> prepare({
    required Iterable<double> heights,
    required double devicePixelRatio,
  }) async {
    if (_disposed) {
      throw StateError('PartRasterDollRenderer used after dispose');
    }
  }

  @override
  void dispose() {
    if (_disposed) return;
    _disposed = true;
    parts.dispose();
  }

  // ── Hot path: runs every frame. No allocation (CLAUDE.md rule 8). ──

  /// True until disposed: one set serves every doll height on the board.
  @override
  bool isReadyFor(double height) => !_disposed;

  /// Same as [isReadyFor].
  @override
  bool canPaint(double height) => !_disposed;

  @override
  void paint(Canvas canvas, DollPaintParams p) {
    if (_disposed || p.height <= 0 || p.opacity <= 0) return;
    final part = p.part;
    Image? body;
    Image? lid;
    if (p.silhouette) {
      body = parts.silhouette;
    } else if (part != DollPart.interior) {
      final ci = p.color.index;
      if (part != DollPart.lid) body = _bodies[ci];
      if (part == DollPart.full || part == DollPart.lid) lid = _lids[ci];
    }
    if (body == null && lid == null) return;
    final k = p.height / DollArt.height;
    canvas
      ..save()
      ..translate(p.baseX, p.baseY);
    if (p.rotation != 0) canvas.rotate(p.rotation);
    canvas
      ..scale(k * p.scaleX, k * p.scaleY)
      ..translate(-DollArt.base.dx, -DollArt.base.dy);
    // In art units here, so the fade layer shares DollEffects' bounds.
    final fading = p.opacity < 1;
    if (fading) _fx.beginFade(canvas, p.opacity);
    canvas.scale(_toArt);
    if (body != null) canvas.drawImageRect(body, _src, _src, _paint);
    if (lid != null) {
      final lift = p.lidLift * DollArt.height * _toRaster;
      if (lift != 0) canvas.translate(0, -lift);
      canvas.drawImageRect(lid, _src, _src, _paint);
    }
    if (fading) canvas.restore();
    canvas.restore();
  }

  // ── End of hot path. ──
}
