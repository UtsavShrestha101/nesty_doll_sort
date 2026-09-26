import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:nesty_core/nesty_core.dart';
import 'package:nesty_render/src/palette/doll_palette.dart';
import 'package:nesty_render/src/skin/symbol_atlas.dart';

/// One colour's belly symbol in its ink, alone in an image, for a square
/// box of [side] units: the padlock's `unlock_symbol` Lottie image slot,
/// 12 × 12 (LOTTIE.md "Image slots", docs/plans/m2-lottie-design.md §3).
///
/// The image is the symbol's atlas cell copied 1:1 (the symbol fitted in
/// its box as design/generator/nesty-doll.js does, plus the cell's 1 px
/// margin), so it is never resampled on the way in. [scale] and [origin]
/// are the `FxRaster` terms that place it in the declared box: the FX
/// runtime draws it as `FxRaster(image, scale: scale, origin: origin)`.
///
/// Handles follow `ui.Image.clone` semantics, like `SkinImageSet`.
final class SymbolRaster {
  SymbolRaster._(this.image, this.scale, this.origin, this.side);

  final ui.Image image;

  /// Raster px per box unit: about the `pixelsPerUnit` asked for (the atlas
  /// page height is a whole number of px).
  final double scale;

  /// Where [image]'s top-left sits in the box, in box units. Negative: the
  /// cell's margin reaches past the box.
  final ui.Offset origin;

  /// The box side, in units.
  final double side;

  int get byteSize => image.width * image.height * 4;

  SymbolRaster clone() => SymbolRaster._(image.clone(), scale, origin, side);

  void dispose() => image.dispose();

  /// Rasterizes [color]'s symbol (`DollSwatch.symbol`) in its ink
  /// (`DollSwatch.ink`) for a [side]-unit box drawn at [pixelsPerUnit]
  /// device px per unit. For the padlock: `side` 12 and `pixelsPerUnit =
  /// SlotGeometry.furnitureScale × devicePixelRatio`.
  ///
  /// Null when [atlas] has no symbol for [color] (the slot then draws
  /// nothing, rule 3). Off the hot path: at level load.
  static Future<SymbolRaster?> rasterize(
    SymbolAtlas atlas,
    DollColor color, {
    required double pixelsPerUnit,
    double side = 12,
  }) async {
    if (!(pixelsPerUnit > 0) || !(side > 0)) {
      throw ArgumentError('pixelsPerUnit and side must be positive');
    }
    final swatch = DollPalette.of(color);
    final index = atlas.indexOf(swatch.symbol);
    if (index < 0) return null;
    final geometry = atlas.geometry;
    // The subtle cell's box (110 art units) is the declared box.
    final unitsPerArt = side / geometry.subtleSize;
    // The page whose px per art unit gives pixelsPerUnit px per box unit.
    final artHeightPx = math.max(
      1,
      (pixelsPerUnit * unitsPerArt * geometry.artboardHeight).round(),
    );
    final page = await atlas.obtain(artHeightPx);
    try {
      final src = page.subtleSrc(index);
      final width = src.width.round();
      final height = src.height.round();
      final recorder = ui.PictureRecorder();
      ui.Canvas(recorder).drawImageRect(
        page.image,
        src,
        ui.Rect.fromLTWH(0, 0, width.toDouble(), height.toDouble()),
        ui.Paint()
          ..colorFilter = ui.ColorFilter.mode(swatch.ink, ui.BlendMode.srcIn),
      );
      final picture = recorder.endRecording();
      final ui.Image image;
      try {
        image = await picture.toImage(width, height);
      } finally {
        picture.dispose();
      }
      final box = geometry.box(large: false);
      final cell = page.subtleDst;
      return SymbolRaster._(
        image,
        page.pxPerArt / unitsPerArt,
        ui.Offset(
          (cell.left - box.left) * unitsPerArt,
          (cell.top - box.top) * unitsPerArt,
        ),
        side,
      );
    } finally {
      page.dispose();
    }
  }
}
