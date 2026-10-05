import 'package:flutter/widgets.dart';
import 'package:nesty_game/core/ui/tokens/ui_tokens.gen.dart';

/// What a text's role needs of its line height in a tall script
/// (tokens.json `font.scripts`, m7-4 9.1).
enum ScriptTextRole {
  /// One line in a box with a fixed height: the style's own height stays,
  /// and ascenders aren't clipped because `Text` never clips.
  singleLine,

  /// A paragraph that may wrap: the script's body line-height floor.
  body,

  /// A heading that may wrap: the script's title line-height floor.
  title,
}

/// The script the UI language is drawn in, and what its faces need
/// (tokens.json `font.scripts`; the values come from the generated
/// `AppFontTokens`, never literals).
///
/// * Hindi (Devanagari, Baloo 2): size 1.0, wrapped text no tighter than
///   1.5 (body) and 1.3 (titles), no tracking (tracking breaks a headline).
/// * Japanese (M PLUS Rounded 1c): size 0.94, wrapped text no tighter than
///   1.6 and 1.3, letter spacing always 0.
/// * Everything else (Latin): untouched.
///
/// The face itself needs no code: every generated style lists both script
/// families as fallbacks, and the engine picks a glyph's face per glyph, so
/// Latin letters and digits stay Fredoka and Nunito. The size factor is
/// applied once for the whole app by [LocaleScriptScope] through the text
/// scaler, so no style here scales a font size.
@immutable
final class LocaleScript {
  const LocaleScript._(
    this.sizeFactor,
    this.bodyLineHeight,
    this.titleLineHeight,
    this.dropsTracking,
  );

  /// Latin: no change.
  static const latin = LocaleScript._(1, 0, 0, false);

  static const _devanagari = LocaleScript._(
    AppFontTokens.devaSizeFactor,
    AppFontTokens.devaBodyLineHeight,
    AppFontTokens.devaTitleLineHeight,
    true,
  );

  static const _japanese = LocaleScript._(
    AppFontTokens.jpanSizeFactor,
    AppFontTokens.jpanBodyLineHeight,
    AppFontTokens.jpanTitleLineHeight,
    true,
  );

  /// The script of [locale]'s language.
  static LocaleScript forLocale(Locale locale) {
    final code = locale.languageCode;
    if (AppFontTokens.devaLocales.contains(code)) return _devanagari;
    if (AppFontTokens.jpanLocales.contains(code)) return _japanese;
    return latin;
  }

  /// The script of the UI language in [context].
  static LocaleScript of(BuildContext context) =>
      forLocale(Localizations.maybeLocaleOf(context) ?? const Locale('en'));

  /// The share of every font size the script is drawn at.
  final double sizeFactor;

  /// The minimum `height` of a wrapped body, and of a wrapped title; 0 for
  /// Latin (no floor).
  final double bodyLineHeight;
  final double titleLineHeight;

  /// Whether tracked (letter-spaced) text loses its tracking.
  final bool dropsTracking;

  /// Whether this is not Latin.
  bool get isTall => bodyLineHeight > 0;

  /// [base] as the script wants it for [role]: tracking removed where the
  /// script drops it, and a wrapping role's line height lifted to the
  /// floor. A single-line text keeps its height.
  TextStyle style(
    TextStyle base, {
    ScriptTextRole role = ScriptTextRole.singleLine,
  }) {
    if (this == latin) return base;
    final floor = switch (role) {
      ScriptTextRole.singleLine => 0.0,
      ScriptTextRole.body => bodyLineHeight,
      ScriptTextRole.title => titleLineHeight,
    };
    final height = base.height;
    return base.copyWith(
      letterSpacing: dropsTracking && (base.letterSpacing ?? 0) > 0
          ? 0
          : base.letterSpacing,
      height: floor > 0 && (height == null || height < floor) ? floor : height,
    );
  }

  /// [spacing] unless the script drops tracking.
  double tracking(double spacing) => dropsTracking ? 0 : spacing;
}

/// A `TextStyle` through the UI language's script (see [LocaleScript.style]).
extension LocaleScriptStyle on BuildContext {
  /// The script rules of the UI language.
  LocaleScript get script => LocaleScript.of(this);

  /// [base] as the UI language's script wants it for [role].
  TextStyle scriptStyle(
    TextStyle base, {
    ScriptTextRole role = ScriptTextRole.singleLine,
  }) => LocaleScript.of(this).style(base, role: role);
}

/// Applies the script's size factor once, below the system text scaling
/// (`MediaQuery.textScaler` × factor): Japanese is drawn at 0.94 of every
/// size, Latin and Devanagari at 1.0. Painters that ignore the text scaler
/// (the Lottie labels, the board) are not affected.
class LocaleScriptScope extends StatelessWidget {
  const LocaleScriptScope({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final factor = LocaleScript.of(context).sizeFactor;
    if (factor == 1) return child;
    final media = MediaQuery.of(context);
    return MediaQuery(
      data: media.copyWith(
        textScaler: _ScriptTextScaler(media.textScaler, factor),
      ),
      child: child,
    );
  }
}

/// [inner] with every size multiplied by [factor]. Equal when both are.
@immutable
final class _ScriptTextScaler extends TextScaler {
  const _ScriptTextScaler(this.inner, this.factor);

  final TextScaler inner;
  final double factor;

  @override
  double scale(double fontSize) => inner.scale(fontSize) * factor;

  @override
  double get textScaleFactor => scale(1);

  @override
  TextScaler clamp({
    double minScaleFactor = 0,
    double maxScaleFactor = double.infinity,
  }) => _ScriptTextScaler(
    inner.clamp(
      minScaleFactor: minScaleFactor / factor,
      maxScaleFactor: maxScaleFactor / factor,
    ),
    factor,
  );

  @override
  bool operator ==(Object other) =>
      other is _ScriptTextScaler &&
      other.inner == inner &&
      other.factor == factor;

  @override
  int get hashCode => Object.hash(inner, factor);
}
