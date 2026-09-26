import 'package:flutter/painting.dart';

/// UI color tokens: "cream, warm wood and soft pastels" (spec §12.1,
/// docs/DESIGN_BRIEF.md Prompt 1). Never hard-code a hex value in a widget.
///
/// TODO(M2): every value below is a placeholder. Replace them with the
/// generated `AppColorTokens` (design/tokens.json `color.*`).
///
/// Doll colors are deliberately NOT here: they belong to the rendering
/// package (nesty_render) keyed by nesty_core's doll color ids (spec §12.3),
/// so the game and admin draw dolls identically.
abstract final class AppColors {
  // Surfaces.
  static const background = Color(0xFFFFF4E0); // background cream
  static const surface = Color(0xFFFFFBF2);

  // Wood.
  static const woodLight = Color(0xFFE9C48E);
  static const woodMid = Color(0xFFC98E52);
  static const woodDark = Color(0xFF8A5A2E);

  // Text.
  static const textPrimary = Color(0xFF4A3323);
  static const textSecondary = Color(0xFF8A7262);
  static const textOnWood = Color(0xFFFFFBF2);

  // Status.
  static const success = Color(0xFF6FBF8A);
  static const warning = Color(0xFFF4C15D);
  static const danger = Color(0xFFE5676A);

  // Accents.
  static const coinGold = Color(0xFFF2B53A);
  static const adPurple = Color(0xFF9A7BE6); // rewarded-ad buttons (§9.1)

  // Tier badges (spec §6.6): red "HARD", purple "SUPER HARD".
  static const badgeHard = Color(0xFFE5484D);
  static const badgeSuperHard = Color(0xFF8E4EC6);

  static const disabled = Color(0xFFD9CBB8);
}
