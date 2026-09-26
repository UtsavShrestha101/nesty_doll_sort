import 'dart:ui' as ui;

import 'package:flutter/painting.dart' show ColorFilter;
import 'package:flutter/services.dart' show AssetBundle;
import 'package:nesty_core/nesty_core.dart';
import 'package:nesty_render/nesty_render.dart';

/// Rasterizes a colour's belly symbol in its ink for the glass case's
/// padlock: `fx_glass_unlock`'s `unlock_symbol` slot (12 × 12 declared,
/// LOTTIE.md "Image slots"), at [sizePx] square.
abstract interface class UnlockSymbolRasterizer {
  /// Throws when the symbol art can't be loaded.
  Future<ui.Image> rasterize(DollColor color, int sizePx);
}

/// [UnlockSymbolRasterizer] over the bundled `assets/symbols/<name>.svg`
/// (the same files as `SymbolAtlas`), filling the square and tinted with
/// `DollSwatch.ink` (`srcIn`). Each file is read once.
// TODO(M5): switch to nesty_render's ink-tinted `SymbolRaster`
// (docs/plans/m2-lottie-design.md §16) before the first locked levels
// (L31+) ship in M5's level bundle; no M2 level has a lock (moved from M2).
final class BundledUnlockSymbolRasterizer implements UnlockSymbolRasterizer {
  BundledUnlockSymbolRasterizer(
    this._bundle, {
    this.basePath = 'assets/symbols',
  });

  /// Every symbol SVG is a 128 × 128 box (`SymbolAtlas.fromSvgs`).
  static const symbolArtSize = 128.0;

  final AssetBundle _bundle;
  final String basePath;
  final Map<String, String> _svgs = {};

  @override
  Future<ui.Image> rasterize(DollColor color, int sizePx) async {
    final swatch = DollPalette.of(color);
    final name = swatch.symbol;
    final svg = _svgs[name] ??= await _bundle.loadString(
      '$basePath/$name.svg',
      cache: false,
    );
    final side = sizePx < 1 ? 1 : sizePx;
    return rasterizeSvg(
      svg,
      scale: side / symbolArtSize,
      width: side,
      height: side,
      colorFilter: ColorFilter.mode(swatch.ink, ui.BlendMode.srcIn),
    );
  }
}
