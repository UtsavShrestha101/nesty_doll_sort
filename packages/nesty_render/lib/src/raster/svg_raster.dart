import 'dart:math' as math;
import 'dart:typed_data' show ByteData;
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart' show immutable;
import 'package:flutter/painting.dart' show ColorFilter;
import 'package:flutter_svg/flutter_svg.dart';

// SVG → ui.Image, once per needed size (spec §12.2 "rasterizes each layer
// once per needed size into ui.Image (through flutter_svg →
// Picture.toImage)", CLAUDE.md rule 8). Shared by the skin rasterizer, the
// symbol atlas, the board sprites and the theme background.

/// Parses [source] with flutter_svg into a picture in its own coordinate
/// space (`PictureInfo.size`: the SVG's width/height, else its viewBox).
///
/// The caller owns the result and must `picture.dispose()` it. flutter_svg's
/// global byte cache entry for [source] is evicted afterwards: callers keep
/// the picture, so the cached bytes would only duplicate it.
Future<PictureInfo> loadSvgPicture(String source) async {
  final loader = SvgStringLoader(source);
  try {
    return await vg.loadPicture(loader, null);
  } finally {
    svg.cache.evict(loader.cacheKey(null));
  }
}

/// One picture to draw into a raster, with an optional group [opacity] and
/// [colorFilter] (applied through a layer, like SVG group opacity).
@immutable
final class SvgRasterPart {
  const SvgRasterPart(this.picture, {this.opacity = 1, this.colorFilter});

  final ui.Picture picture;
  final double opacity;
  final ColorFilter? colorFilter;
}

/// Draws [parts] in order into a [width] × [height] image. A point `p` of
/// the pictures lands on pixel `p × scale − (left, top)`, so a crop is just
/// a non-zero [left]/[top] and a smaller size.
Future<ui.Image> rasterizePictures(
  List<SvgRasterPart> parts, {
  required int width,
  required int height,
  required double scale,
  double left = 0,
  double top = 0,
}) async {
  final recorder = ui.PictureRecorder();
  final canvas = ui.Canvas(recorder)
    ..translate(-left, -top)
    ..scale(scale);
  for (final part in parts) {
    final layered = part.opacity < 1 || part.colorFilter != null;
    if (layered) {
      final paint = ui.Paint()
        ..color = ui.Color.fromRGBO(0, 0, 0, part.opacity.clamp(0, 1));
      if (part.colorFilter case final filter?) paint.colorFilter = filter;
      canvas.saveLayer(null, paint);
    }
    canvas.drawPicture(part.picture);
    if (layered) canvas.restore();
  }
  final picture = recorder.endRecording();
  try {
    return await picture.toImage(math.max(1, width), math.max(1, height));
  } finally {
    picture.dispose();
  }
}

/// Parses and rasterizes [source] in one go (for one-off rasters such as
/// board sprites). [width]/[height] default to the SVG's size × [scale].
Future<ui.Image> rasterizeSvg(
  String source, {
  required double scale,
  int? width,
  int? height,
  double left = 0,
  double top = 0,
  ColorFilter? colorFilter,
}) async {
  final info = await loadSvgPicture(source);
  try {
    return await rasterizePictures(
      [SvgRasterPart(info.picture, colorFilter: colorFilter)],
      width: width ?? (info.size.width * scale).ceil(),
      height: height ?? (info.size.height * scale).ceil(),
      scale: scale,
      left: left,
      top: top,
    );
  } finally {
    info.picture.dispose();
  }
}

/// The bounds of [image]'s non-transparent pixels, as a rect with integer
/// edges (right/bottom exclusive), or null when every pixel is transparent.
/// Used by the skin crop probe.
Future<ui.Rect?> alphaBounds(ui.Image image) async {
  final bytes = await image.toByteData();
  if (bytes == null) return null;
  return alphaBoundsOf(bytes, image.width, image.height);
}

/// [alphaBounds] over raw RGBA bytes.
ui.Rect? alphaBoundsOf(ByteData rgba, int width, int height) {
  var minX = width;
  var minY = height;
  var maxX = -1;
  var maxY = -1;
  for (var y = 0; y < height; y++) {
    final row = y * width * 4;
    for (var x = 0; x < width; x++) {
      if (rgba.getUint8(row + x * 4 + 3) == 0) continue;
      if (x < minX) minX = x;
      if (x > maxX) maxX = x;
      if (y < minY) minY = y;
      if (y > maxY) maxY = y;
    }
  }
  if (maxX < 0) return null;
  return ui.Rect.fromLTRB(
    minX.toDouble(),
    minY.toDouble(),
    maxX + 1.0,
    maxY + 1.0,
  );
}
