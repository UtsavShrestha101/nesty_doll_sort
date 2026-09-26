import 'package:flutter/material.dart';
import 'package:nesty_admin/core/ui/colors/app_colors.dart';

/// The single (light) theme, built from [AppColors] like the game's theme.
///
/// TODO(design): radii, spacing, table and form styles from
/// `design/tokens.json` and `design/admin/*.png` (DESIGN_BRIEF Prompt 14).
/// TODO(design): bundle the brand fonts as assets rather than using
/// google_fonts, which downloads at runtime.
abstract final class AppTheme {
  /// Built once: ThemeData is large, and the root rebuilds on session changes.
  static final ThemeData light = _buildLight();

  static ThemeData _buildLight() {
    const scheme = ColorScheme.light(
      primary: AppColors.accent,
      onPrimary: AppColors.onAccent,
      surface: AppColors.surface,
      onSurface: AppColors.textPrimary,
      onSurfaceVariant: AppColors.textSecondary,
      outlineVariant: AppColors.divider,
      error: AppColors.danger,
    );
    final base = ThemeData(useMaterial3: true, colorScheme: scheme);
    return base.copyWith(
      scaffoldBackgroundColor: AppColors.background,
      dividerColor: AppColors.divider,
      textTheme: base.textTheme.apply(
        bodyColor: AppColors.textPrimary,
        displayColor: AppColors.textPrimary,
      ),
    );
  }
}
