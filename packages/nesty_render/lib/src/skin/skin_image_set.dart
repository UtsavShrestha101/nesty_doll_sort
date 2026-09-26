import 'dart:ui' as ui;

import 'package:nesty_render/src/skin/skin_layer.dart';

/// One cropped layer raster and where it goes.
final class SkinLayerImage {
  SkinLayerImage({required this.image, required this.dst})
    : src = ui.Rect.fromLTWH(
        0,
        0,
        image.width.toDouble(),
        image.height.toDouble(),
      );

  SkinLayerImage._(this.image, this.src, this.dst);

  final ui.Image image;

  /// The whole image, for `drawImageRect` (built once, never per frame).
  final ui.Rect src;

  /// Where [image] covers the artboard, in art units (512 × 768 space). Its
  /// edges sit on whole pixels at the raster scale, so a doll drawn at the
  /// prepared height on a whole-pixel base is sampled 1:1.
  final ui.Rect dst;

  int get byteSize => image.width * image.height * 4;

  SkinLayerImage clone() => SkinLayerImage._(image.clone(), src, dst);

  void dispose() => image.dispose();
}

/// Every [SkinLayer] of one skin rasterized at one height.
///
/// Handles follow `ui.Image.clone` semantics: [clone] gives an independent
/// handle to the same pixels, and the memory is freed when the last handle
/// is disposed. The cache keeps one handle and gives renderers clones, so
/// evicting from the cache never pulls an image out from under a frame.
final class SkinImageSet {
  SkinImageSet({
    required this.skinKey,
    required this.artHeightPx,
    required this.pxPerArt,
    required List<SkinLayerImage?> layers,
  }) : _layers = List.unmodifiable(layers) {
    if (layers.length != SkinLayer.values.length) {
      throw ArgumentError.value(layers.length, 'layers', 'one per SkinLayer');
    }
  }

  /// `SkinManifest.cacheKey` of the skin.
  final String skinKey;

  /// Physical pixels the full artboard height maps to (logical doll height
  /// × device pixel ratio, rounded).
  final int artHeightPx;

  /// Physical pixels per art unit ([artHeightPx] / artboard height).
  final double pxPerArt;

  final List<SkinLayerImage?> _layers;
  bool _disposed = false;

  /// The raster of [layer], or null when the group is empty.
  SkinLayerImage? operator [](SkinLayer layer) => _layers[layer.index];

  /// GPU bytes held by this set's images (RGBA8).
  int get byteSize {
    var total = 0;
    for (final l in _layers) {
      total += l?.byteSize ?? 0;
    }
    return total;
  }

  bool get debugDisposed => _disposed;

  SkinImageSet clone() {
    if (_disposed) throw StateError('SkinImageSet used after dispose');
    return SkinImageSet(
      skinKey: skinKey,
      artHeightPx: artHeightPx,
      pxPerArt: pxPerArt,
      layers: [for (final l in _layers) l?.clone()],
    );
  }

  void dispose() {
    if (_disposed) return;
    _disposed = true;
    for (final l in _layers) {
      l?.dispose();
    }
  }
}
