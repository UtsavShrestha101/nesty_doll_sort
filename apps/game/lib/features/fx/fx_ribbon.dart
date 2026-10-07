import 'package:flutter/rendering.dart';
import 'package:nesty_game/core/ui/lottie/lottie_label.dart';
import 'package:nesty_game/core/ui/tokens/ui_token_types.dart'
    show RibbonColors;
import 'package:nesty_game/core/ui/tokens/ui_tokens.gen.dart';
import 'package:nesty_game/features/fx/fx_id.dart';
import 'package:nesty_game/features/fx/fx_spec.gen.dart';

/// The two ribbon files and their bands (LOTTIE.md m7-5; tokens
/// `winRibbon.size`): `ui_win_ribbon` draws a 290 × 56 band with its tails
/// to 334, `ui_chapter_ribbon` a 336 × 48 band. Both name their rects
/// (`band_rect`, `edge_rect`, `hi_rect`), so the game sets a narrower band
/// on a narrow phone instead of scaling the file
/// (`FxDrawableParams.ribbonBandWidth`); the text box narrows with it.
enum FxRibbon {
  /// The win, daily and race ribbon (9.4, 9.5, 5.4, 2.8).
  win(FxId.uiWinRibbon, WinRibbonTokens.bandSize),

  /// The new-chapter ribbon (4.7). Its band stays 336 (LOTTIE.md m7-5).
  chapter(FxId.uiChapterRibbon, Size(336, 48));

  const FxRibbon(this.id, this.band);

  final FxId id;

  /// The band as authored (`band_rect`, `edge_rect`).
  final Size band;

  /// The tails reach this far past the band on each side (334 − 290 = 44).
  static const double tailReach = 22;

  /// `hi_rect` is this much narrower than the band (274 / 290, 320 / 336).
  static const double hiInset = 16;

  /// The ribbon of [id], or null for any other file.
  static FxRibbon? of(FxId id) => switch (id) {
    FxId.uiWinRibbon => win,
    FxId.uiChapterRibbon => chapter,
    _ => null,
  };

  /// The label's style at the authored band.
  LottieLabelStyle get label => switch (this) {
    win => LottieLabelStyles.winRibbon,
    chapter => LottieLabelStyles.chapterRibbon,
  };

  /// The band's width on a screen [screenWidth] wide: as authored, or the
  /// screen − 70 when that is narrower (`WinRibbonTokens.maxWidthInset`).
  double bandWidthFor(double screenWidth) =>
      LottieRibbonFit.bandWidthFor(band.width, screenWidth);

  /// The ribbon's width at rest, its tails included, for a band
  /// [bandWidth] wide (334 for the authored win band).
  double reachFor(double bandWidth) => bandWidth + 2 * tailReach;

  /// The label's style on a band [bandWidth] wide: the text box keeps its
  /// margin to the band (266 in 290, 312 in 336), so a long title shrinks
  /// or takes its short form inside a narrowed band. [shadow] recolours
  /// the label's shadow (the chapter's fold, tokens.theme.ribbonTint).
  LottieLabelStyle labelFor(double bandWidth, {Color? shadow}) {
    final base = label;
    final width = base.maxWidth - (band.width - bandWidth);
    if (width == base.maxWidth && shadow == null) return base;
    return base.copyWith(maxWidth: width, shadowColor: shadow);
  }
}

/// A ribbon's rest look without its file (rule 3, R10): what the file holds
/// on after its pop, on its canvas around the anchor, with the band
/// [bandWidth] wide (the authored one by default). The band (radius 16) over
/// its edge 6 below, a 30 % white highlight 16 narrower, and the tails 22
/// past the band with a 12 notch and the fold under them, in [colors]: the
/// same shapes as the file (LOTTIE.md m7-5).
final class RibbonRestPainter extends CustomPainter {
  RibbonRestPainter({
    required this.ribbon,
    required this.colors,
    double? bandWidth,
  }) : bandWidth = bandWidth ?? ribbon.band.width;

  final FxRibbon ribbon;
  final RibbonColors colors;
  final double bandWidth;

  /// `hi_fill` as authored: white at 30 % (never tinted).
  static const _highlight = Color(0x4DFFFFFF);

  @override
  void paint(Canvas canvas, Size size) {
    final spec = fxSpecOf(ribbon.id);
    final half = bandWidth / 2;
    final h = ribbon.band.height;
    final band = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset.zero, width: bandWidth, height: h),
      const Radius.circular(16),
    );
    final shine = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(0, -h / 2 + 5),
        width: bandWidth - FxRibbon.hiInset,
        height: 5,
      ),
      const Radius.circular(2.5),
    );
    final top = -h / 2 + 14;
    final bottom = h / 2 + 10;
    final tail = Paint()..color = colors.tail;
    final fold = Paint()..color = colors.fold;
    canvas
      ..save()
      ..scale(size.width / spec.width, size.height / spec.height)
      ..translate(spec.anchor.dx, spec.anchor.dy);
    for (final side in const [-1.0, 1.0]) {
      final inner = (half - 14) * side;
      final outer = (half + FxRibbon.tailReach) * side;
      canvas
        ..drawPath(
          Path()
            ..moveTo(inner, top)
            ..lineTo(outer, top)
            ..lineTo((half + 10) * side, 8)
            ..lineTo(outer, bottom)
            ..lineTo(inner, bottom)
            ..close(),
          tail,
        )
        ..drawPath(
          Path()
            ..moveTo(inner, h / 2)
            ..lineTo(half * side, h / 2)
            ..lineTo(half * side, bottom)
            ..close(),
          fold,
        );
    }
    canvas
      ..drawRRect(band.shift(const Offset(0, 6)), Paint()..color = colors.edge)
      ..drawRRect(band, Paint()..color = colors.band)
      ..drawRRect(shine, Paint()..color = _highlight)
      ..restore();
  }

  @override
  bool shouldRepaint(RibbonRestPainter oldDelegate) =>
      oldDelegate.ribbon != ribbon ||
      oldDelegate.colors.band != colors.band ||
      oldDelegate.colors.edge != colors.edge ||
      oldDelegate.colors.tail != colors.tail ||
      oldDelegate.colors.fold != colors.fold ||
      oldDelegate.bandWidth != bandWidth;
}
