import 'package:flutter/material.dart';
import 'package:nesty_game/l10n/app_localizations.dart';

extension BuildContextX on BuildContext {
  /// All user-facing strings: `context.localizations.levelTitle(3)`.
  AppLocalizations get localizations => AppLocalizations.of(this);

  ThemeData get theme => Theme.of(this);

  TextTheme get textTheme => Theme.of(this).textTheme;

  // Text style getters. TODO(design): map to the design-system type scale
  // (display, h1, h2, button, body, caption, number) once tokens exist.
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
}
