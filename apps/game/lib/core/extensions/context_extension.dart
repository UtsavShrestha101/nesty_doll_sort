import 'package:flutter/material.dart';
import 'package:nesty_game/core/ui/theme/app_text_styles.dart';
import 'package:nesty_game/core/ui/tokens/ui_tokens.gen.dart';
import 'package:nesty_game/l10n/app_localizations.dart';

extension BuildContextX on BuildContext {
  /// All user-facing strings: `context.localizations.levelTitle(3)`.
  AppLocalizations get localizations => AppLocalizations.of(this);

  ThemeData get theme => Theme.of(this);

  TextTheme get textTheme => Theme.of(this).textTheme;

  // ── Material roles (mapped onto the design scale in AppTheme) ──

  TextStyle get displayLarge => textTheme.displayLarge ?? const TextStyle();
  TextStyle get displayMedium => textTheme.displayMedium ?? const TextStyle();
  TextStyle get displaySmall => textTheme.displaySmall ?? const TextStyle();

  TextStyle get headlineLarge => textTheme.headlineLarge ?? const TextStyle();
  TextStyle get headlineMedium => textTheme.headlineMedium ?? const TextStyle();
  TextStyle get headlineSmall => textTheme.headlineSmall ?? const TextStyle();

  TextStyle get titleLarge => textTheme.titleLarge ?? const TextStyle();
  TextStyle get titleMedium => textTheme.titleMedium ?? const TextStyle();
  TextStyle get titleSmall => textTheme.titleSmall ?? const TextStyle();

  TextStyle get bodyLarge => textTheme.bodyLarge ?? const TextStyle();
  TextStyle get bodyMedium => textTheme.bodyMedium ?? const TextStyle();
  TextStyle get bodySmall => textTheme.bodySmall ?? const TextStyle();

  TextStyle get labelLarge => textTheme.labelLarge ?? const TextStyle();
  TextStyle get labelMedium => textTheme.labelMedium ?? const TextStyle();
  TextStyle get labelSmall => textTheme.labelSmall ?? const TextStyle();

  // ── The design's type scale (tokens.json `fontSize`, AppTextStyles) ──

  /// Fredoka 56/56/700.
  TextStyle get displayText => AppTextStyles.display;

  /// Fredoka 40/42/700.
  TextStyle get h1Text => AppTextStyles.h1;

  /// Fredoka 30/33/700.
  TextStyle get sheetTitleText => AppTextStyles.sheetTitle;

  /// Fredoka 28/31/700.
  TextStyle get h2Text => AppTextStyles.h2;

  /// Fredoka 26/26/700.
  TextStyle get screenTitleText => AppTextStyles.screenTitle;

  /// Fredoka 20/22/700.
  TextStyle get cardTitleText => AppTextStyles.cardTitle;

  /// Fredoka 21/21/700.
  TextStyle get buttonText => AppTextStyles.button;

  /// Fredoka 17/17/700.
  TextStyle get buttonSmallText => AppTextStyles.buttonSmall;

  /// Fredoka 18/18/700.
  TextStyle get hudLevelText => AppTextStyles.hudLevel;

  /// Fredoka 17/17/700 (tabular pending PROGRESS Q29).
  TextStyle get numberText => AppTextStyles.number;

  /// Fredoka 13/13/600.
  TextStyle get boosterLabelText => AppTextStyles.boosterLabel;

  /// Fredoka 11/11/700 +0.06 em.
  TextStyle get tierChipText => AppTextStyles.tierChip;

  /// Fredoka 12/12/700.
  TextStyle get tabLabelText => AppTextStyles.tabLabel;

  /// Nunito 16/23/600.
  TextStyle get bodyText => AppTextStyles.body;

  /// Nunito 14/20/600.
  TextStyle get bodySmallText => AppTextStyles.bodySmall;

  /// Nunito 17/17/700.
  TextStyle get rowText => AppTextStyles.row;

  /// Nunito 12/16/700.
  TextStyle get captionText => AppTextStyles.caption;

  // ── Motion ──

  /// The platform's "reduce motion" setting (PROGRESS D48).
  bool get reduceMotion => MediaQuery.maybeDisableAnimationsOf(this) ?? false;

  /// A `tokens.motion.ui` duration, halved under reduced motion (D48:
  /// "widget transitions follow tokens.motion.ui × 0.5").
  Duration uiDuration(int milliseconds) {
    final scale = reduceMotion
        ? UiMotionTokens.reducedMotionDurationScale
        : 1.0;
    return Duration(microseconds: (milliseconds * 1000 * scale).round());
  }
}
