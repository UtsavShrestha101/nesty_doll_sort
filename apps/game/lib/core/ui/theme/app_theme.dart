import 'package:flutter/material.dart';
import 'package:nesty_game/core/ui/colors/app_colors.dart';

/// The single (light) theme. Spec §12.1 describes one cozy look; there is no
/// dark mode in v1.
///
/// TODO(M2): chunky rounded buttons with a pressed bottom edge, radii,
/// shadows and spacing from the generated tokens (`ui_tokens.gen.dart`).
/// TODO(M2): fonts — Fredoka (display/headings) and Nunito (body), already
/// bundled in assets/fonts (`AppFontTokens`); never google_fonts, which
/// downloads at runtime and would break the offline first launch (rule 3).
abstract final class AppTheme {
  /// Built once: ThemeData is large and App rebuilds on locale changes.
  static final ThemeData light = _buildLight();

  static ThemeData _buildLight() {
    const scheme = ColorScheme.light(
      primary: AppColors.woodMid,
      onPrimary: AppColors.textOnWood,
      secondary: AppColors.adPurple,
      onSecondary: AppColors.textOnWood,
      surface: AppColors.surface,
      onSurface: AppColors.textPrimary,
      error: AppColors.danger,
    );
    final base = ThemeData(useMaterial3: true, colorScheme: scheme);
    return base.copyWith(
      scaffoldBackgroundColor: AppColors.background,
      disabledColor: AppColors.disabled,
      textTheme: base.textTheme.apply(
        bodyColor: AppColors.textPrimary,
        displayColor: AppColors.textPrimary,
      ),
    );
  }
}
