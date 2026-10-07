import 'package:flutter/material.dart';
import 'package:nesty_game/core/ui/theme/app_text_styles.dart';
import 'package:nesty_game/core/ui/theme/locale_script.dart';
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
  static final ThemeData light = _buildLight(LocaleScript.latin);

  static final _byScript = <LocaleScript, ThemeData>{LocaleScript.latin: light};

  /// The theme for [locale]'s script: the same, but in Turkish the Material
  /// roles that are Fredoka draw in Baloo 2 (whole strings, m7-5 item 28).
  /// One theme per script, built on first use.
  static ThemeData forLocale(Locale locale) {
    final script = LocaleScript.forLocale(locale);
    return _byScript.putIfAbsent(script, () => _buildLight(script));
  }

  static ThemeData _buildLight(LocaleScript script) {
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
      textTheme: _textTheme(script),
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
  static TextTheme _textTheme(LocaleScript script) {
    TextStyle role(TextStyle style) =>
        script.display(style).copyWith(letterSpacing: style.letterSpacing ?? 0);
    return TextTheme(
      displayLarge: role(AppTextStyles.display),
      displayMedium: role(AppTextStyles.h1),
      displaySmall: role(AppTextStyles.sheetTitle),
      headlineLarge: role(AppTextStyles.h2),
      headlineMedium: role(AppTextStyles.screenTitle),
      headlineSmall: role(AppTextStyles.cardTitle),
      titleLarge: role(AppTextStyles.button),
      titleMedium: role(AppTextStyles.hudLevel),
      titleSmall: role(AppTextStyles.buttonSmall),
      bodyLarge: role(AppTextStyles.body),
      bodyMedium: role(AppTextStyles.bodySmall),
      bodySmall: role(AppTextStyles.caption),
      labelLarge: role(AppTextStyles.row),
      labelMedium: role(AppTextStyles.boosterLabel),
      labelSmall: role(AppTextStyles.tierChip),
    );
  }
}
