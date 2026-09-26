import 'package:flutter/foundation.dart' show immutable;
import 'package:flutter/painting.dart';
import 'package:nesty_game/core/ui/tokens/ui_tokens.gen.dart';

/// How a localized label is drawn over a Lottie whose own text layers are
/// hidden (PROGRESS D44, docs/plans/m2-lottie-design.md §12): Fredoka 700 at
/// [fontSize] in [color], with an optional hard shadow, its baseline centred
/// on [baseline] in the null's space, shrunk to fit [maxWidth].
///
/// The FX lane's `LottieFxView` captures the null's transform each frame
/// and paints a [LottieLabelPainter] with it; [LottieTextOverlay] draws the
/// same label statically when the file is missing.
@immutable
final class LottieLabelStyle {
  const LottieLabelStyle({
    required this.fontSize,
    required this.color,
    required this.maxWidth,
    required this.baseline,
    required this.restNull,
    required this.canvas,
    this.shadowOffset,
    this.shadowColor,
  });

  final double fontSize;
  final Color color;

  /// The band's usable width in composition units: a wider label is laid out
  /// again at `fontSize × maxWidth / width` (fit, don't wrap).
  final double maxWidth;

  /// The label's baseline centre relative to the null's position.
  final Offset baseline;

  /// The null's resting position in the composition (its value while a hold
  /// skips the position callback).
  final Offset restNull;

  /// The composition's canvas size.
  final Size canvas;

  /// The shadow's offset from the label, and its colour.
  final Offset? shadowOffset;
  final Color? shadowColor;

  /// The text style at [size] (the fitted size).
  TextStyle textStyle([double? size]) => TextStyle(
    fontFamily: AppFontTokens.displayFamily,
    fontWeight: FontWeight.w700,
    fontSize: size ?? fontSize,
    height: 1,
    leadingDistribution: TextLeadingDistribution.even,
    color: color,
    shadows: shadowOffset == null || shadowColor == null
        ? null
        : [Shadow(color: shadowColor!, offset: shadowOffset!)],
  );
}

/// The three text-carrying files of lottie §12 (`ui_family_counter`,
/// `ui_win_ribbon`, `ui_chapter_ribbon`), with the table's values.
abstract final class LottieLabelStyles {
  /// "{done} / {total}" on the `counter` null (60,30); cream `#FFF5E0`, 13.
  /// TODO(design): the 52 max width is a guess (lottie §12).
  static const familyCounter = LottieLabelStyle(
    fontSize: 13,
    color: Color(0xFFFFF5E0),
    maxWidth: 52,
    baseline: Offset(7, 4.6),
    restNull: Offset(60, 30),
    canvas: Size(120, 60),
  );

  /// "Level Complete!" on the `ribbon` null (180,55); white 28 with a
  /// `#96400A` 35 % shadow 2 below; band 260 − 2 × 14.
  static const winRibbon = LottieLabelStyle(
    fontSize: 28,
    color: Color(0xFFFFFFFF),
    maxWidth: 232,
    baseline: Offset(0, 10.08),
    restNull: Offset(180, 55),
    canvas: Size(360, 110),
    shadowOffset: Offset(0, 2),
    shadowColor: Color(0x5996400A),
  );

  /// "CHAPTER {n} · {name}" on the `ribbon` null (180,50); white 20 with a
  /// `#1C4F82` 35 % shadow 2 below; band 290 − 2 × 14.
  static const chapterRibbon = LottieLabelStyle(
    fontSize: 20,
    color: Color(0xFFFFFFFF),
    maxWidth: 262,
    baseline: Offset(0, 7.2),
    restNull: Offset(180, 50),
    canvas: Size(360, 100),
    shadowOffset: Offset(0, 2),
    shadowColor: Color(0x591C4F82),
  );
}

/// Lays out one label once per text change and paints it at a null's
/// transform, allocation-free per frame (rule 8: the counter and ribbons
/// repaint every frame while they play).
///
/// Labels are part of the artwork's band, so they ignore the text scaler;
/// the band's fit keeps a long translation inside it, and the overlay
/// widget gives screen readers the text.
final class LottieLabelPainter {
  LottieLabelPainter(
    this.style, {
    TextDirection textDirection = TextDirection.ltr,
  }) : _painter = TextPainter(
         textDirection: textDirection,
         textAlign: TextAlign.center,
         maxLines: 1,
         textScaler: TextScaler.noScaling,
       );

  final LottieLabelStyle style;
  final TextPainter _painter;
  String? _text;
  double _fontSize = 0;

  /// Where the laid-out text's top-left goes in the null's space: its
  /// baseline centred on [LottieLabelStyle.baseline]. Computed per layout,
  /// so a paint allocates nothing (review PERF-RULES-2).
  Offset _origin = Offset.zero;

  /// The label's text. Relayouts only when it changes.
  String get text => _text ?? '';
  set text(String value) {
    if (value == _text) return;
    _text = value;
    _layout(style.fontSize);
    if (_painter.width > style.maxWidth && _painter.width > 0) {
      _layout(style.fontSize * style.maxWidth / _painter.width);
    }
  }

  /// The font size after fitting.
  double get fontSize => _fontSize;

  /// The laid-out label's size.
  Size get size => _painter.size;

  void _layout(double fontSize) {
    _fontSize = fontSize;
    _painter
      ..text = TextSpan(text: _text, style: style.textStyle(fontSize))
      ..layout();
    final baselineFromTop = _painter.computeDistanceToActualBaseline(
      TextBaseline.alphabetic,
    );
    final b = style.baseline;
    _origin = Offset(b.dx - _painter.width / 2, b.dy - baselineFromTop);
  }

  // ── Hot path: every repaint of the counter and ribbons. No allocation. ──

  /// Paints the label for a null at [nullPosition] (composition units)
  /// scaled by [nullScale], in the canvas's current transform (the
  /// composition's space).
  void paint(Canvas canvas, Offset nullPosition, {double nullScale = 1}) {
    final text = _text;
    if (text == null || text.isEmpty) return;
    canvas
      ..save()
      ..translate(nullPosition.dx, nullPosition.dy)
      ..scale(nullScale);
    _painter.paint(canvas, _origin);
    canvas.restore();
  }

  // ── End of hot path. ──

  void dispose() => _painter.dispose();
}
