import 'dart:ui' show Color, Offset, Rect;

import 'package:flutter/foundation.dart' show immutable;

// Value types for the generated render_tokens.gen.dart. Hand-written (and
// editable) so behaviour can grow here while the values stay generated from
// design/tokens.json.

/// How a doll color tints the grayscale mask layers (design/README.md
/// "Doll rendering", step 1).
enum DollTintMode {
  /// Multiply every mask pixel by the base color (`BlendMode.modulate`).
  modulate,

  /// Map the mask's gray level through [DollColorToken.ramp] (gold).
  gradientMap,
}

/// One stop of a gradient-map ramp: [position] in 0–1 of the (shaped)
/// gray input, and the output [color].
@immutable
final class RampStop {
  const RampStop(this.position, this.color);

  final double position;
  final Color color;
}

/// The design values for one `DollColor` (tokens.json `dollColor.<id>`).
@immutable
final class DollColorToken {
  const DollColorToken({
    required this.id,
    required this.name,
    required this.base,
    required this.ink,
    required this.light,
    required this.symbol,
    this.wild = false,
    this.tintMode = DollTintMode.modulate,
    this.ramp = const [],
    this.rampInputExponent = 1,
  });

  /// The `nesty_core` `DollColor.id`.
  final String id;

  /// The design's English name (tooling only; players see ARB strings).
  final String name;

  /// Mask tint, pip fill and placeholder body color.
  final Color base;

  /// Darker shade for the belly symbol and rings.
  final Color ink;

  /// Lighter shade for highlights.
  final Color light;

  /// File base name of the belly symbol in `assets/symbols/`.
  final String symbol;

  /// True for the wild gold doll (spec §3.5, v1.1).
  final bool wild;

  final DollTintMode tintMode;

  /// Gradient-map stops when [tintMode] is [DollTintMode.gradientMap].
  final List<RampStop> ramp;

  /// The ramp input is `gray ^ rampInputExponent` (tokens: `gray^2`).
  final double rampInputExponent;
}

/// One hop of the completion bounce (tokens.json `motion.complete.hops`).
@immutable
final class MotionHop {
  const MotionHop({required this.height, required this.durationMs});

  /// Peak height in logical px.
  final double height;

  final int durationMs;
}

/// An ellipse in skin artboard coordinates: center and radii.
@immutable
final class TokenEllipse {
  const TokenEllipse({
    required this.cx,
    required this.cy,
    required this.rx,
    required this.ry,
  });

  final double cx;
  final double cy;
  final double rx;
  final double ry;

  /// The bounding rectangle, for `Canvas.drawOval`.
  Rect get rect =>
      Rect.fromCenter(center: Offset(cx, cy), width: rx * 2, height: ry * 2);
}
