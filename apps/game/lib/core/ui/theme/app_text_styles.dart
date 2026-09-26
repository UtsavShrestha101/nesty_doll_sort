import 'package:nesty_game/core/ui/tokens/ui_tokens.gen.dart';

/// The type scale of `design/tokens.json` `fontSize` (the generated
/// `AppTextStyleTokens`) in the default text colour, built once.
///
/// Widgets copy a style and change only its colour or shadow, so the size,
/// weight, family and line height always come from the tokens.
///
/// TODO(M7): tabular figures for coins and counters (PROGRESS Q29; moved
/// from M2, the approach waits on the owner). Fredoka has no `tnum`, so
/// [number]'s `FontFeature.tabularFigures()` does nothing yet;
/// `NestyNumberText` is the one place to change once the owner picks one.
abstract final class AppTextStyles {
  static const _ink = AppColorTokens.textPrimary;

  /// Fredoka 56/56/700.
  static final display = AppTextStyleTokens.display.copyWith(color: _ink);

  /// Fredoka 40/42/700.
  static final h1 = AppTextStyleTokens.h1.copyWith(color: _ink);

  /// Fredoka 30/33/700: sheet titles ("No moves left!").
  static final sheetTitle = AppTextStyleTokens.sheetTitle.copyWith(color: _ink);

  /// Fredoka 28/31/700.
  static final h2 = AppTextStyleTokens.h2.copyWith(color: _ink);

  /// Fredoka 26/26/700: screen headers.
  static final screenTitle = AppTextStyleTokens.screenTitle.copyWith(
    color: _ink,
  );

  /// Fredoka 20/22/700.
  static final cardTitle = AppTextStyleTokens.cardTitle.copyWith(color: _ink);

  /// Fredoka 21/21/700.
  static final button = AppTextStyleTokens.button.copyWith(color: _ink);

  /// Fredoka 17/17/700.
  static final buttonSmall = AppTextStyleTokens.buttonSmall.copyWith(
    color: _ink,
  );

  /// Fredoka 18/18/700: the level pill.
  static final hudLevel = AppTextStyleTokens.hudLevel.copyWith(color: _ink);

  /// Fredoka 17/17/700, tabular once Q29 is settled (see above).
  static final number = AppTextStyleTokens.number.copyWith(color: _ink);

  /// Fredoka 13/13/600.
  static final boosterLabel = AppTextStyleTokens.boosterLabel.copyWith(
    color: _ink,
  );

  /// Fredoka 11/11/700 +0.06 em.
  static final tierChip = AppTextStyleTokens.tierChip.copyWith(color: _ink);

  /// Fredoka 12/12/700.
  static final tabLabel = AppTextStyleTokens.tabLabel.copyWith(color: _ink);

  /// Nunito 16/23/600.
  static final body = AppTextStyleTokens.body.copyWith(color: _ink);

  /// Nunito 14/20/600.
  static final bodySmall = AppTextStyleTokens.bodySmall.copyWith(color: _ink);

  /// Nunito 17/17/700: list rows and toggle labels.
  static final row = AppTextStyleTokens.row.copyWith(color: _ink);

  /// Nunito 12/16/700.
  static final caption = AppTextStyleTokens.caption.copyWith(color: _ink);
}
