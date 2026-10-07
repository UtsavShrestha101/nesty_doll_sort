import 'dart:math' as math;

import 'package:flutter/foundation.dart' show immutable;
import 'package:flutter/painting.dart';
import 'package:nesty_game/core/ui/tokens/ui_token_types.dart';
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

  /// This style with another box width or shadow colour: a ribbon whose
  /// band is narrowed for the screen keeps its text inside it (m7-5,
  /// tokens.winRibbon.size), and the chapter ribbon's shadow takes the
  /// chapter's fold colour (tokens.theme.ribbonTint).
  LottieLabelStyle copyWith({double? maxWidth, Color? shadowColor}) =>
      LottieLabelStyle(
        fontSize: fontSize,
        color: color,
        maxWidth: maxWidth ?? this.maxWidth,
        maxHeight: maxHeight,
        baseline: baseline,
        restNull: restNull,
        canvas: canvas,
        shadowOffset: shadowOffset,
        shadowColor: shadowColor ?? this.shadowColor,
      );

  @override
  bool operator ==(Object other) =>
      other is LottieLabelStyle &&
      other.fontSize == fontSize &&
      other.color == color &&
      other.maxWidth == maxWidth &&
      other.maxHeight == maxHeight &&
      other.baseline == baseline &&
      other.restNull == restNull &&
      other.canvas == canvas &&
      other.shadowOffset == shadowOffset &&
      other.shadowColor == shadowColor;

  @override
  int get hashCode => Object.hash(
    fontSize,
    color,
    maxWidth,
    maxHeight,
    baseline,
    restNull,
    canvas,
    shadowOffset,
    shadowColor,
  );

  /// The text style at [size] (the fitted size).
  TextStyle textStyle([double? size]) => DisplayFace.apply(
    TextStyle(
      fontFamily: AppFontTokens.displayFamily,
      fontFamilyFallback: AppFontTokens.displayFallback,
      fontWeight: FontWeight.w700,
      fontSize: size ?? fontSize,
      height: 1,
      leadingDistribution: TextLeadingDistribution.even,
      color: color,
      shadows: shadowOffset == null || shadowColor == null
          ? null
          : [Shadow(color: shadowColor!, offset: shadowOffset!)],
    ),
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
  /// (LOTTIE.md v3 "Text layers"): white Fredoka Bold 24 in the
  /// `tokens.winRibbon.size.textBox` (266 × 40, m7-5) centred on the
  /// anchor, inside the 290-wide band, with a `#96400A` 35 % shadow 2 below.
  /// A band narrowed for the screen narrows the box with it
  /// ([copyWith], `FxRibbon.labelFor`). The baseline sits 0.36 em below the
  /// null, as the file's own preview text does, so the letters centre on
  /// the band.
  static const winRibbon = LottieLabelStyle(
    fontSize: 24,
    color: Color(0xFFFFFFFF),
    // WinRibbonTokens.textBox (a test pins it: a const can't read a Size).
    maxWidth: 266,
    maxHeight: 40,
    baseline: Offset(0, 8.64),
    restNull: Offset(205, 55),
    canvas: Size(410, 110),
    shadowOffset: Offset(0, 2),
    shadowColor: Color(0x5996400A),
  );

  /// "CHAPTER {n} · {name}" on the `ribbon` null (205,50) of the 410×100
  /// canvas: white Fredoka Bold 20 in the `textFit.chapterRibbon` box
  /// (312 × 32, inside the 336-wide band) centred on the anchor, with a
  /// `#1C4F82` 35 % shadow 2 below (the chapter's `ribbonFold` at 35 % when
  /// it is tinted, tokens.theme.ribbonTint).
  static const chapterRibbon = LottieLabelStyle(
    fontSize: 20,
    color: Color(0xFFFFFFFF),
    // TextFitTokens.chapterRibbonBox (pinned by a test).
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
/// screen, and how wide their band is (LOTTIE.md m7-5; tokens.winRibbon.size).
///
/// The canvas is drawn at full size, centred on the screen: it may start
/// left of 0 and end past the right edge, but what it draws fits. A band is
/// never wider than the screen − 70 (`WinRibbonTokens.maxWidthInset`): the
/// 290 win band fits a 360 dp phone with its tails 13 dp from each edge, and
/// the 336 chapter band narrows below 406 dp (frame 4.7: 320 on a 390
/// phone). A narrower band is set through the files' named rects, never by
/// scaling the canvas (`FxDrawableParams.ribbonBandWidth`).
abstract final class LottieRibbonFit {
  /// The band's width on a screen [screenWidth] wide: [authored], or the
  /// screen − 70 when that is narrower.
  static double bandWidthFor(double authored, double screenWidth) => math.max(
    0,
    math.min(authored, screenWidth - WinRibbonTokens.maxWidthInset),
  );

  /// The rect of a ribbon's [canvas] centred on a screen [screenWidth]
  /// wide, its centre (the ribbon's anchor) [centerY] down, at full size.
  static Rect rectFor(
    Size canvas, {
    required double screenWidth,
    required double centerY,
  }) => Rect.fromLTWH(
    (screenWidth - canvas.width) / 2,
    centerY - canvas.height / 2,
    canvas.width,
    canvas.height,
  );
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

  /// The share of [style]'s font size [text] is drawn at in its box: 1 when
  /// it fits, less when it shrinks (so a caller can pick a short form below
  /// textFit's `minScale`).
  static double fitOf(
    LottieLabelStyle style,
    String text,
    TextDirection direction,
  ) {
    final painter = LottieLabelPainter(style, textDirection: direction)
      ..text = text;
    final fit = painter.fontSize / style.fontSize;
    painter.dispose();
    return fit;
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
