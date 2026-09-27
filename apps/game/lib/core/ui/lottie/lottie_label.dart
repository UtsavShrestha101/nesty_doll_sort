import 'dart:math' as math;

import 'package:flutter/foundation.dart' show immutable;
import 'package:flutter/painting.dart';
import 'package:nesty_game/core/ui/tokens/ui_tokens.gen.dart';

/// How a localized label is drawn over a Lottie whose own text layers are
/// hidden (PROGRESS D44, docs/plans/m2-lottie-design.md §12): Fredoka 700 at
/// [fontSize] in [color], with an optional hard shadow, its baseline centred
/// on [baseline] in the null's space, shrunk to fit a [maxWidth] ×
/// [maxHeight] box centred on the null (fit, don't wrap).
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
    this.maxHeight = double.infinity,
    this.shadowOffset,
    this.shadowColor,
  });

  final double fontSize;
  final Color color;

  /// The text box's width, centred on the null, in composition units: a
  /// wider label is laid out again at `fontSize × maxWidth / width`.
  final double maxWidth;

  /// The box's height: a label whose line is taller shrinks the same way.
  final double maxHeight;

  /// The label's baseline centre relative to the null's position, at
  /// [fontSize]. A label shrunk to fit keeps its visual centre: its
  /// baseline sits at `baseline.dy × fitted / fontSize`.
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

  /// "Level Complete!" on the `ribbon` null (205,55) of the 410×110 canvas
  /// (LOTTIE.md v3 "Text layers"): white Fredoka Bold 24 in a 312 × 40 box
  /// centred on the anchor, inside the 336-wide band, with a `#96400A` 35 %
  /// shadow 2 below. The baseline sits 0.36 em below the null, as the
  /// file's own preview text does, so the letters centre on the band.
  static const winRibbon = LottieLabelStyle(
    fontSize: 24,
    color: Color(0xFFFFFFFF),
    maxWidth: 312,
    maxHeight: 40,
    baseline: Offset(0, 8.64),
    restNull: Offset(205, 55),
    canvas: Size(410, 110),
    shadowOffset: Offset(0, 2),
    shadowColor: Color(0x5996400A),
  );

  /// "CHAPTER {n} · {name}" on the `ribbon` null (205,50) of the 410×100
  /// canvas: white Fredoka Bold 20 in a 312 × 32 box centred on the anchor,
  /// with a `#1C4F82` 35 % shadow 2 below.
  static const chapterRibbon = LottieLabelStyle(
    fontSize: 20,
    color: Color(0xFFFFFFFF),
    maxWidth: 312,
    maxHeight: 32,
    baseline: Offset(0, 7.2),
    restNull: Offset(205, 50),
    canvas: Size(410, 100),
    shadowOffset: Offset(0, 2),
    shadowColor: Color(0x591C4F82),
  );
}

/// Where the two ribbons (`ui_win_ribbon`, `ui_chapter_ribbon`) sit on a
/// screen (LOTTIE.md v3 "Ribbons"): their 410-wide canvas centred on the
/// screen at [scaleFor]. At full size on a 390 dp screen the canvas is wider
/// than the screen, but the ribbon is 380 dp at rest; its tails pass the
/// edges by up to 6 dp for about 100 ms during the 106 % pop (the owner
/// accepted this, 2026-09-26).
abstract final class LottieRibbonFit {
  /// The screen width the ribbons are drawn for at full size.
  static const referenceScreenWidth = 390.0;

  /// `min(1, screenWidth / 390)`: full size on a 390 dp screen and wider,
  /// shrunk with a narrower one.
  static double scaleFor(double screenWidth) {
    if (screenWidth <= 0) return 0;
    return screenWidth >= referenceScreenWidth
        ? 1
        : screenWidth / referenceScreenWidth;
  }

  /// The rect of a ribbon's [canvas] centred on a screen [screenWidth]
  /// wide, its centre (the ribbon's anchor) [centerY] down: it may start
  /// left of 0 and end past the screen's right edge.
  static Rect rectFor(
    Size canvas, {
    required double screenWidth,
    required double centerY,
  }) {
    final scale = scaleFor(screenWidth);
    final width = canvas.width * scale;
    final height = canvas.height * scale;
    return Rect.fromLTWH(
      (screenWidth - width) / 2,
      centerY - height / 2,
      width,
      height,
    );
  }
}

/// Lays out one label once per text change and paints it at a null's
/// transform, allocation-free per frame (rule 8: the counter and ribbons
/// repaint every frame while they play).
///
/// Labels are part of the artwork's band, so they ignore the text scaler;
/// the box fit keeps a long translation (German in capitals) inside it,
/// and the overlay widget gives screen readers the text.
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
    final width = _painter.width;
    final height = _painter.height;
    var fit = 1.0;
    if (width > style.maxWidth && width > 0) fit = style.maxWidth / width;
    if (height > style.maxHeight && height > 0) {
      fit = math.min(fit, style.maxHeight / height);
    }
    if (fit < 1) _layout(style.fontSize * fit);
  }

  /// The font size after fitting.
  double get fontSize => _fontSize;

  /// The laid-out label's size.
  Size get size => _painter.size;

  /// The laid-out label's box in the null's space (its origin at the
  /// null): inside the style's box for any text.
  Rect get bounds => _origin & _painter.size;

  void _layout(double fontSize) {
    _fontSize = fontSize;
    _painter
      ..text = TextSpan(text: _text, style: style.textStyle(fontSize))
      ..layout();
    final baselineFromTop = _painter.computeDistanceToActualBaseline(
      TextBaseline.alphabetic,
    );
    final b = style.baseline;
    _origin = Offset(
      b.dx - _painter.width / 2,
      b.dy * fontSize / style.fontSize - baselineFromTop,
    );
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
