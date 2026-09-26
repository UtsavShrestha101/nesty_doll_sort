import 'dart:math' as math;

import 'package:flutter/foundation.dart' show immutable, listEquals;
import 'package:flutter/painting.dart';
import 'package:nesty_game/core/ui/tokens/ui_token_types.dart';
import 'package:nesty_game/core/ui/tokens/ui_tokens.gen.dart';

/// How one design surface looks: a face (colour or gradient) plus a CSS
/// `box-shadow` stack, transcribed layer for layer from tokens.json `shadow`
/// or the prototypes (CSS order: the first layer paints on top).
///
/// A tactile surface (design/README.md "Tactile depth") has a solid bottom
/// edge layer (`0 Npx 0 color`). Pressed, the face moves down by
/// `edge − 2` px and the edge shrinks to 2 px, so the edge's bottom stays
/// put ([travel], [pressed]).
@immutable
final class SurfaceStyle {
  const SurfaceStyle({
    required this.shadows,
    this.color,
    this.gradient,
    this.pressedShadows,
    this.pressTravel,
  }) : assert(
         color != null || gradient != null,
         'A surface needs a face colour or gradient',
       );

  /// A flat face. Ignored when [gradient] is set.
  final Color? color;

  /// A gradient face, laid over the surface's own box.
  final Gradient? gradient;

  /// The resting shadow stack, CSS order.
  final List<NestyShadow> shadows;

  /// The pressed stack, the same length and order as [shadows]. Null
  /// derives it (see [pressed]).
  final List<NestyShadow>? pressedShadows;

  /// How far the face moves down when pressed. Null derives it from the
  /// edge ([travel]).
  final double? pressTravel;

  /// The solid bottom edge's height at rest, or 0 for a flat surface.
  double get edge {
    for (final layer in shadows) {
      if (layer.isSolidEdge) return layer.dy;
    }
    return 0;
  }

  /// "Buttons move down by (edge − 2) px" (tokens.json `shadow.pressed`).
  double get travel =>
      pressTravel ?? math.max(0, edge - AppShadowTokens.pressedEdge);

  /// The pressed stack: [pressedShadows], or derived from [shadows]. The
  /// solid edge shrinks to 2 px; a soft drop shadow tightens the way the
  /// Design System sheet's pressed states do (primary `0 10 18 → 0 4 8`,
  /// raised `0 9 14 → 0 3 6`: offset × 0.4, blur × 0.45). Insets and rings
  /// stay as they are.
  List<NestyShadow> get pressed =>
      pressedShadows ??
      [
        for (final layer in shadows)
          if (layer.isSolidEdge)
            layer.copyWith(dy: math.min(layer.dy, AppShadowTokens.pressedEdge))
          else if (!layer.inset && layer.blur > 0)
            layer.copyWith(dy: layer.dy * 0.4, blur: layer.blur * 0.45)
          else
            layer,
      ];

  SurfaceStyle copyWith({
    Color? color,
    Gradient? gradient,
    List<NestyShadow>? shadows,
    List<NestyShadow>? pressedShadows,
    double? pressTravel,
  }) => SurfaceStyle(
    color: color ?? this.color,
    gradient: gradient ?? this.gradient,
    shadows: shadows ?? this.shadows,
    pressedShadows: pressedShadows ?? this.pressedShadows,
    pressTravel: pressTravel ?? this.pressTravel,
  );

  @override
  bool operator ==(Object other) =>
      other is SurfaceStyle &&
      other.color == color &&
      other.gradient == gradient &&
      other.pressTravel == pressTravel &&
      listEquals(other.shadows, shadows) &&
      listEquals(other.pressedShadows, pressedShadows);

  @override
  int get hashCode => Object.hash(
    color,
    gradient,
    pressTravel,
    Object.hashAll(shadows),
    pressedShadows == null ? null : Object.hashAll(pressedShadows!),
  );
}
