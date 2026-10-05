import 'package:flutter/material.dart';
import 'package:nesty_game/core/ui/theme/app_text_styles.dart';
import 'package:nesty_game/core/ui/tokens/ui_tokens.gen.dart';

/// The single (light) theme, built from `design/tokens.json` (the generated
/// `ui_tokens.gen.dart`). Spec §12.1 describes one cozy look; there is no
/// dark mode in v1.
///
/// Nunito is the default family and the Material text roles map onto the
/// design's type scale (Fredoka for display, buttons and numbers). Both are
/// bundled in assets/fonts, never fetched at runtime (rule 3), with the
/// Devanagari and Japanese faces as every style's `fontFamilyFallback`. The design's
/// own widgets (`core/ui/widgets`) read `AppTextStyles` directly; the theme
/// covers the Material widgets that remain (text fields, dialogs, the dev
/// picker).
abstract final class AppTheme {
  /// Built once: ThemeData is large and App rebuilds on locale changes.
  static final ThemeData light = _buildLight();

  static ThemeData _buildLight() {
    const scheme = ColorScheme.light(
      primary: AppColorTokens.primary,
      onPrimary: Colors.white,
      primaryContainer: AppColorTokens.warningTint,
      onPrimaryContainer: AppColorTokens.textPrimary,
      secondary: AppColorTokens.ad,
      onSecondary: Colors.white,
      tertiary: AppColorTokens.success,
      onTertiary: Colors.white,
      surface: AppColorTokens.surface,
      onSurface: AppColorTokens.textPrimary,
      onSurfaceVariant: AppColorTokens.textSecondary,
      surfaceContainerHighest: AppColorTokens.surfaceSunk,
      outline: AppColorTokens.surfaceEdge,
      outlineVariant: AppColorTokens.surfaceTrack,
      error: AppColorTokens.danger,
      onError: Colors.white,
      scrim: AppColorTokens.scrim,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      fontFamily: AppFontTokens.bodyFamily,
      // Devanagari and Japanese glyphs (hi, ja; l10n.md §4.6) for any
      // Material text that takes the default family, such as the time
      // picker. The token styles below carry their own role's list.
      fontFamilyFallback: AppFontTokens.bodyFallback,
      textTheme: _textTheme,
      scaffoldBackgroundColor: AppColorTokens.canvasCream,
      canvasColor: AppColorTokens.canvasCream,
      disabledColor: AppColorTokens.disabledText,
      dividerColor: AppColorTokens.divider,
      // The design's controls give feedback by moving (the tactile press),
      // never with an ink ripple.
      splashFactory: NoSplash.splashFactory,
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      hoverColor: Colors.transparent,
      iconTheme: const IconThemeData(color: AppColorTokens.iconBrown, size: 26),
      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: AppColorTokens.primary,
      ),
    );
  }

  /// Material roles → the token scale. Every entry sets `letterSpacing`, so
  /// Material's English-like geometry (e.g. bodyLarge +0.5) never leaks in
  /// when the theme is localized.
  static final TextTheme _textTheme = TextTheme(
    displayLarge: _role(AppTextStyles.display),
    displayMedium: _role(AppTextStyles.h1),
    displaySmall: _role(AppTextStyles.sheetTitle),
    headlineLarge: _role(AppTextStyles.h2),
    headlineMedium: _role(AppTextStyles.screenTitle),
    headlineSmall: _role(AppTextStyles.cardTitle),
    titleLarge: _role(AppTextStyles.button),
    titleMedium: _role(AppTextStyles.hudLevel),
    titleSmall: _role(AppTextStyles.buttonSmall),
    bodyLarge: _role(AppTextStyles.body),
    bodyMedium: _role(AppTextStyles.bodySmall),
    bodySmall: _role(AppTextStyles.caption),
    labelLarge: _role(AppTextStyles.row),
    labelMedium: _role(AppTextStyles.boosterLabel),
    labelSmall: _role(AppTextStyles.tierChip),
  );

  static TextStyle _role(TextStyle style) =>
      style.copyWith(letterSpacing: style.letterSpacing ?? 0);
}
