import 'package:flutter/painting.dart';
import 'package:nesty_game/core/ui/theme/locale_script.dart';
import 'package:nesty_game/core/ui/tokens/ui_tokens.gen.dart';

/// The type scale of `design/tokens.json` `fontSize` (the generated
/// `AppTextStyleTokens`) in the default text colour, built once.
///
/// Widgets copy a style and change only its colour or shadow, so the size,
/// weight, family and line height always come from the tokens.
///
/// TODO(M8): tabular figures for coins and counters (PROGRESS Q29; moved
/// from M2, the approach waits on the owner). Fredoka has no `tnum`, so
/// [number]'s `FontFeature.tabularFigures()` does nothing yet;
/// `NestyNumberText` is the one place to change once the owner picks one.
abstract final class AppTextStyles {
  static const _ink = AppColorTokens.textPrimary;

  /// A Fredoka style in the UI language: Turkish draws it in Baloo 2, whole
  /// strings (m7-5 item 28, [LocaleScript.display]); every other language
  /// gets the style itself. The getters below read the language
  /// [LocaleScriptScope] sets at the app root.
  static TextStyle _face(TextStyle style) =>
      LocaleScript.current.display(style);

  /// Fredoka 56/56/700.
  static TextStyle get display => _face(_display);
  static final _display = AppTextStyleTokens.display.copyWith(color: _ink);

  /// Fredoka 40/42/700.
  static TextStyle get h1 => _face(_h1);
  static final _h1 = AppTextStyleTokens.h1.copyWith(color: _ink);

  /// Fredoka 30/33/700: sheet titles ("No moves left!").
  static TextStyle get sheetTitle => _face(_sheetTitle);
  static final _sheetTitle = AppTextStyleTokens.sheetTitle.copyWith(
    color: _ink,
  );

  /// Fredoka 28/31/700.
  static TextStyle get h2 => _face(_h2);
  static final _h2 = AppTextStyleTokens.h2.copyWith(color: _ink);

  /// Fredoka 26/26/700: screen headers.
  static TextStyle get screenTitle => _face(_screenTitle);
  static final _screenTitle = AppTextStyleTokens.screenTitle.copyWith(
    color: _ink,
  );

  /// Fredoka 20/22/700.
  static TextStyle get cardTitle => _face(_cardTitle);
  static final _cardTitle = AppTextStyleTokens.cardTitle.copyWith(color: _ink);

  /// Fredoka 21/21/700.
  static TextStyle get button => _face(_button);
  static final _button = AppTextStyleTokens.button.copyWith(color: _ink);

  /// Fredoka 17/17/700.
  static TextStyle get buttonSmall => _face(_buttonSmall);
  static final _buttonSmall = AppTextStyleTokens.buttonSmall.copyWith(
    color: _ink,
  );

  /// Fredoka 18/18/700: the level pill.
  static TextStyle get hudLevel => _face(_hudLevel);
  static final _hudLevel = AppTextStyleTokens.hudLevel.copyWith(color: _ink);

  /// Fredoka 17/17/700, tabular once Q29 is settled (see above).
  static TextStyle get number => _face(_number);
  static final _number = AppTextStyleTokens.number.copyWith(color: _ink);

  /// Fredoka 13/13/600.
  static TextStyle get boosterLabel => _face(_boosterLabel);
  static final _boosterLabel = AppTextStyleTokens.boosterLabel.copyWith(
    color: _ink,
  );

  /// Fredoka 11/11/700 +0.06 em.
  static TextStyle get tierChip => _face(_tierChip);
  static final _tierChip = AppTextStyleTokens.tierChip.copyWith(color: _ink);

  /// Fredoka 12/12/700.
  static TextStyle get tabLabel => _face(_tabLabel);
  static final _tabLabel = AppTextStyleTokens.tabLabel.copyWith(color: _ink);

  /// Nunito 16/23/600.
  static final body = AppTextStyleTokens.body.copyWith(color: _ink);

  /// Nunito 14/20/600.
  static final bodySmall = AppTextStyleTokens.bodySmall.copyWith(color: _ink);

  /// Nunito 17/17/700: list rows and toggle labels.
  static final row = AppTextStyleTokens.row.copyWith(color: _ink);

  /// Nunito 12/16/700.
  static final caption = AppTextStyleTokens.caption.copyWith(color: _ink);
}
