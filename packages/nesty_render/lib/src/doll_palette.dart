import 'dart:ui' show Color;

import 'package:flutter/foundation.dart' show immutable;
import 'package:nesty_core/nesty_core.dart';

// TODO(M7): add `ink` and `light` shades to DollSwatch.
// TODO(design): take base/ink/light from design/tokens.json
// `dollColor.<id>.{base,ink,light}` once it exists.

/// How one [DollColor] is painted.
///
/// A class rather than a bare [Color] so the darker "ink" shade (belly
/// symbol, spec §12.3) and the lighter highlight shade can be added without
/// changing call sites.
@immutable
final class DollSwatch {
  const DollSwatch({required this.base, this.gradient});

  /// The flat color: tint for the skin's mask layers (spec §12.2), pip-bar
  /// fill (spec §10.3) and the placeholder painter's base (spec §12.5). For
  /// gold it is a mid tone of [gradient], for places that cannot paint one.
  final Color base;

  /// Gradient stops, top to bottom, for colors that are not flat. Only gold
  /// has one (spec §12.3 "gradient").
  final List<Color>? gradient;
}

/// The doll colors of spec §12.3.
///
/// Every swatch is a compile-time constant, so looking one up in a paint
/// call allocates nothing (CLAUDE.md rule 8).
abstract final class DollPalette {
  /// The swatch for [color]. The exhaustive switch makes adding a color to
  /// [DollColor] without a swatch a compile error.
  static DollSwatch of(DollColor color) => switch (color) {
    DollColor.red => _red,
    DollColor.orange => _orange,
    DollColor.yellow => _yellow,
    DollColor.green => _green,
    DollColor.teal => _teal,
    DollColor.blue => _blue,
    DollColor.purple => _purple,
    DollColor.pink => _pink,
    DollColor.navy => _navy,
    DollColor.brown => _brown,
    DollColor.gold => _gold,
  };

  // Spec §12.3 hex values, exactly.
  static const _red = DollSwatch(base: Color(0xFFE5484D));
  static const _orange = DollSwatch(base: Color(0xFFF2893B));
  static const _yellow = DollSwatch(base: Color(0xFFF5C518));
  static const _green = DollSwatch(base: Color(0xFF46A758));
  static const _teal = DollSwatch(base: Color(0xFF12A594));
  static const _blue = DollSwatch(base: Color(0xFF3E8EDE));
  static const _purple = DollSwatch(base: Color(0xFF8E4EC6));
  static const _pink = DollSwatch(base: Color(0xFFE93D82));
  static const _navy = DollSwatch(base: Color(0xFF2F3E8F));
  static const _brown = DollSwatch(base: Color(0xFFA0673C));

  // The spec only says "gradient" for gold. These stops are a placeholder
  // metallic ramp so gold is distinguishable until the design lands.
  // TODO(M7): final metallic gold rendering (spec §12.3, §3.5).
  // TODO(design): replace with design/tokens.json `dollColor.gold`.
  static const _gold = DollSwatch(
    base: Color(0xFFD9A93A),
    gradient: [Color(0xFFFFE9A3), Color(0xFFD9A93A), Color(0xFF9C6F1E)],
  );
}
