import 'package:flutter/painting.dart';

/// Admin UI color tokens: "a simple light theme with Nesty accent colors"
/// (docs/DESIGN_BRIEF.md Prompt 14). Never hard-code a hex value in a widget.
///
/// TODO(design): every value below is a placeholder. Replace them with
/// `design/tokens.json` → `color.*` and `design/admin/*.png` once exported.
///
/// Doll colors are deliberately NOT here: the level editor and skin preview
/// (M5) draw dolls through nesty_render, keyed by nesty_core's doll color ids
/// (spec §12.3), so admin and game render them identically.
abstract final class AppColors {
  // Surfaces: neutral, so authored content (dolls, themes) reads true.
  static const background = Color(0xFFF7F4EF);
  static const surface = Color(0xFFFFFFFF);
  static const divider = Color(0xFFE4DDD3);

  // Nesty accent: the game's dark wood, which keeps white labels readable.
  static const accent = Color(0xFF8A5A2E);
  static const onAccent = Color(0xFFFFFBF2);

  // Text.
  static const textPrimary = Color(0xFF3A2C22);
  static const textSecondary = Color(0xFF7A6A5E);

  // Status (validation panel, publish results; spec §15).
  static const success = Color(0xFF3F9A5F);
  static const warning = Color(0xFFD99A1E);
  static const danger = Color(0xFFD1434B);
}
