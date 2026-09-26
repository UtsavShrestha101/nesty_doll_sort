import 'dart:math' as math;
import 'dart:ui' show Offset, Path, Rect;

import 'package:nesty_render/src/tokens/render_token_types.dart';
import 'package:nesty_render/src/tokens/render_tokens.gen.dart';

/// Doll geometry in skin artboard units (512 × 768, spec §12.2) that every
/// renderer shares.
abstract final class DollArt {
  static const width = 512.0;
  static const height = 768.0;

  /// The art point that `DollPaintParams.baseX/baseY` place: bottom centre
  /// of the body (design/README.md "Board layout": "the base is at 742/768
  /// of the art height").
  static const base = Offset(256, 742);

  /// design/README.md "Doll rendering" step 3: the symbol is "filled with
  /// ink at 94% opacity" (the JS `opacity="0.94"`).
  static const subtleSymbolOpacity = 0.94;

  /// Centre of the tower reveal wipe: `circle(… at 50% 62%)` of the doll
  /// box in the motion prototype (`mo-r-paint`).
  static const revealCenter = Offset(width / 2, height * 0.62);

  /// The wipe's final radius, the prototype's `circle(75%)`: CSS resolves
  /// a percentage radius against the box diagonal / √2.
  static final double revealMaxRadius =
      0.75 * math.sqrt(width * width + height * height) / math.sqrt2;

  /// Layer bounds while fading (opacity < 1): the artboard plus room for a
  /// lid raised by a full doll height.
  static const fadeBounds = Rect.fromLTRB(-64, -height, width + 64, 832);

  /// The completion shine band (prototype `mo-c-shine`: a 115° linear
  /// gradient, transparent 40 % → white 90 % at 50 % → transparent 60 %,
  /// over a 250 %-wide background). 115° tilts the band 25° from vertical.
  static const shineTiltRadians = 25 * math.pi / 180;

  /// Half the band's width across its stripes: 10 % of the CSS gradient
  /// line (2.5 × 512 × sin 115° + 768 × |cos 115°| ≈ 1485 units).
  static const shineHalfWidth = 148.5;

  /// Peak white alpha at the band's centre.
  static const shinePeakAlpha = 0.9;

  /// Where `DollPart.bodyFront` draws: the art below the split line (the
  /// nest frame clips its body to `inset(52.1% 0 0 0)`, art y 400), with
  /// room below for the shadow.
  static const bodyFrontClip = Rect.fromLTRB(
    -width,
    SkinTokens.splitY,
    2 * width,
    2 * height,
  );

  /// Interior rim ellipses (tokens `skin.interiorRim`), built once.
  static final Path rimOuter = ellipsePath(SkinTokens.interiorRimOuter);
  static final Path rimInner = ellipsePath(SkinTokens.interiorRimInner);

  /// [e] as the four cubics flutter_svg turns an SVG `<ellipse>` into
  /// (vector_graphics_compiler `PathBuilder.addOval`), not `Path.addOval`'s
  /// exact conics: on a flat 148 × 21 rim the two antialias differently by
  /// a visible fraction of a pixel, and the design renders use the cubics.
  static Path ellipsePath(TokenEllipse e) {
    const magic = 0.551915024494; // vector_graphics _kArcApproximationMagic
    final mx = magic * e.rx;
    final my = magic * e.ry;
    final x = e.cx;
    final y = e.cy;
    return Path()
      ..moveTo(x, y - e.ry)
      ..cubicTo(x + mx, y - e.ry, x + e.rx, y - my, x + e.rx, y)
      ..cubicTo(x + e.rx, y + my, x + mx, y + e.ry, x, y + e.ry)
      ..cubicTo(x - mx, y + e.ry, x - e.rx, y + my, x - e.rx, y)
      ..cubicTo(x - e.rx, y - my, x - mx, y - e.ry, x, y - e.ry)
      ..close();
  }
}
