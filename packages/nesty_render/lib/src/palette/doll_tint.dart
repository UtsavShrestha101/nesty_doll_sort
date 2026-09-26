import 'dart:math' as math;
import 'dart:ui' show Color;

import 'package:flutter/foundation.dart' show immutable, listEquals;
import 'package:nesty_render/src/palette/color_math.dart';
import 'package:nesty_render/src/tokens/render_token_types.dart';

/// How a doll colour turns the grayscale mask layers of a skin into colour
/// (design/README.md "Doll rendering" step 1, spec §12.2).
///
/// Sealed so every painter handles both kinds: the flat colours can be
/// tinted at draw time with one `ColorFilter`, gold cannot.
@immutable
sealed class DollTint {
  const DollTint();

  /// The colour a mask pixel of gray level [gray] (0–255) becomes: the
  /// JS `tint(g)` of design/generator/nesty-doll.js.
  Color mapGray(int gray);
}

/// Multiplies each mask pixel by [color] (`BlendMode.modulate`). Linear in
/// the gray level, so tinting the rasterized gray mask gives the same pixels
/// as tinting the SVG before rasterizing.
final class ModulateTint extends DollTint {
  const ModulateTint(this.color);

  final Color color;

  @override
  Color mapGray(int gray) => multiplyByGray(color, gray);

  @override
  bool operator ==(Object other) =>
      other is ModulateTint && other.color == color;

  @override
  int get hashCode => color.hashCode;
}

/// Maps each mask pixel's gray level through [ramp] after raising it to
/// [inputExponent] (gold: tokens.json `rampInput: gray^2`).
///
/// Not linear, so it cannot be a `ColorFilter` on the gray raster: the skin
/// pipeline rewrites the mask SVG's gray values through [mapGray] and
/// rasterizes gold separately (PROGRESS D19 "per stop and pre-rasterized").
final class GradientMapTint extends DollTint {
  const GradientMapTint(this.ramp, {this.inputExponent = 1});

  final List<RampStop> ramp;
  final double inputExponent;

  @override
  Color mapGray(int gray) =>
      rampColor(ramp, math.pow(gray / 255, inputExponent).toDouble());

  @override
  bool operator ==(Object other) =>
      other is GradientMapTint &&
      other.inputExponent == inputExponent &&
      listEquals(
        [for (final s in other.ramp) (s.position, s.color)],
        [for (final s in ramp) (s.position, s.color)],
      );

  @override
  int get hashCode => Object.hash(
    inputExponent,
    Object.hashAll([for (final s in ramp) Object.hash(s.position, s.color)]),
  );
}
