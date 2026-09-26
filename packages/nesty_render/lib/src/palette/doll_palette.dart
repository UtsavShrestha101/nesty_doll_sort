import 'dart:ui' show Color;

import 'package:flutter/foundation.dart' show immutable;
import 'package:nesty_core/nesty_core.dart';
import 'package:nesty_render/src/palette/color_math.dart';
import 'package:nesty_render/src/palette/doll_tint.dart';
import 'package:nesty_render/src/tokens/render_token_types.dart';
import 'package:nesty_render/src/tokens/render_tokens.gen.dart';

/// How one [DollColor] is painted (spec §12.3, design/README.md "Doll
/// rendering").
@immutable
final class DollSwatch {
  const DollSwatch({
    required this.color,
    required this.base,
    required this.ink,
    required this.light,
    required this.symbol,
    required this.rimColor,
    required this.tint,
  });

  final DollColor color;

  /// Mask tint for flat colours, pip-bar fill (spec §10.3) and the
  /// placeholder body (spec §12.5). For gold, a representative mid tone.
  final Color base;

  /// The darker shade: belly symbol, large-symbol ring (spec §12.3).
  final Color ink;

  /// The lighter shade, for highlights.
  final Color light;

  /// File base name of the belly symbol (`assets/symbols/<symbol>.svg`).
  final String symbol;

  /// Fill of the interior rim ellipse drawn while the lid is open.
  final Color rimColor;

  /// How the grayscale masks become this colour.
  final DollTint tint;

  /// True when the masks cannot be tinted at draw time (gold).
  bool get usesGradientMap => tint is GradientMapTint;
}

/// The doll colours of spec §12.3, from the generated `DollColorTokens`.
///
/// Base, ink and light are the design's hand-tuned table (tokens.json
/// `dollColor`), never derived: the OKLCH derivation
/// (`DollColorDerivationTokens`) is only for colours outside the table.
abstract final class DollPalette {
  /// Gray the interior rim multiplies the base by (design/README.md "Doll
  /// rendering" step 4: `base × #D6D6D6`).
  static const rimGray = 0xD6;

  /// Gold's interior rim. The gradient map has no single base to multiply,
  /// so nesty-doll.js hard-codes this colour.
  static const goldRim = Color(0xFFE9BE4E);

  /// Buried tower nests (spec §3.2, D21) tint the masks with wood.
  static const wood = SkinTokens.woodSilhouette;

  /// The silhouette's mask tint.
  static const woodTint = ModulateTint(wood);

  /// nesty-doll.js paints a silhouette's rim `wood × #CFCFCF`.
  static const woodRimGray = 0xCF;

  /// The silhouette's interior rim colour.
  static final Color woodRim = multiplyByGray(wood, woodRimGray);

  /// The swatch for [color]. Built once, so a lookup in a paint call
  /// allocates nothing (CLAUDE.md rule 8).
  static DollSwatch of(DollColor color) => _swatches[color.index];

  /// Every swatch, in `DollColor.values` order.
  static List<DollSwatch> get values => _swatches;

  static final List<DollSwatch> _swatches = List.unmodifiable([
    for (final color in DollColor.values) _swatch(color),
  ]);

  static DollSwatch _swatch(DollColor color) {
    final token = DollColorTokens.of(color);
    final DollTint tint = switch (token.tintMode) {
      DollTintMode.modulate => ModulateTint(token.base),
      DollTintMode.gradientMap => GradientMapTint(
        token.ramp,
        inputExponent: token.rampInputExponent,
      ),
    };
    return DollSwatch(
      color: color,
      base: token.base,
      ink: token.ink,
      light: token.light,
      symbol: token.symbol,
      rimColor: tint is ModulateTint
          ? multiplyByGray(token.base, rimGray)
          : goldRim,
      tint: tint,
    );
  }
}
