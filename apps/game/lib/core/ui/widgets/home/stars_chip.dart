import 'package:flutter/widgets.dart';
import 'package:nesty_game/core/extensions/context_extension.dart';
import 'package:nesty_game/core/ui/art/ui_art.dart';
import 'package:nesty_game/core/ui/art/ui_art_image.dart';
import 'package:nesty_game/core/ui/tokens/ui_token_types.dart';
import 'package:nesty_game/core/ui/tokens/ui_tokens.gen.dart';
import 'package:nesty_game/core/ui/widgets/surface/nesty_surface.dart';
import 'package:nesty_game/core/ui/widgets/surface/surface_style.dart';

/// The chapter's star total, "39/60" (menus spec 0.2; tokens
/// `layout.chapters.foldedRow.starsChip`, `perfectChip`): a white pill with a
/// star (`UiArt.starFilled`) and the fraction in `coinText`. Two sizes, as
/// the scenes draw them (NestyHub:25 and :74-76): Home's chapter card, 30
/// tall (star 20, Fredoka 700 15, gap 4, padding 0 10 0 6), and Chapters'
/// folded rows and open header, 28 tall (star 18, 14, gap 3, padding 0 9 0 5).
///
/// [perfect] (every level at 3 stars) swaps the sand inset line for the gold
/// one and adds the soft gold ring (`ChaptersTokens.perfectChip*`).
///
/// One semantics node, `chaptersStarsSemantics`.
class StarsChip extends StatelessWidget {
  const StarsChip({
    required this.earned,
    required this.total,
    this.height = 28,
    this.perfect = false,
    this.all = false,
    super.key,
  });

  final int earned;
  final int total;
  final double height;
  final bool perfect;

  /// The whole campaign's total (Home's Bonus Endless chip, frame 12.2):
  /// reads `chaptersStarsTotalAll`.
  final bool all;

  /// The Home chip's height (NestyHub:25).
  static const double homeHeight = 30;

  bool get _large => height >= homeHeight;

  /// The star's side: 20 in the 30 dp chip, 18 in the 28 dp one.
  double get starSize => _large ? 20 : 18;

  @override
  Widget build(BuildContext context) {
    final l10n = context.localizations;
    final style = SurfaceStyle(
      color: AppColorTokens.surfaceWhite,
      shadows: [
        NestyShadow(
          color: perfect
              ? ChaptersTokens.perfectChipInset.color
              : AppColorTokens.surfaceTrack,
          inset: true,
          spread: perfect ? ChaptersTokens.perfectChipInset.width : 1.5,
        ),
        if (perfect)
          NestyShadow(
            color: ChaptersTokens.perfectChipRing.color,
            spread: ChaptersTokens.perfectChipRing.width,
          ),
      ],
    );
    return Semantics(
      label: l10n.chaptersStarsSemantics(earned, total),
      excludeSemantics: true,
      child: NestySurface(
        style: style,
        radius: BorderRadius.circular(height / 2),
        height: height,
        padding: EdgeInsetsDirectional.only(
          start: _large ? 6 : 5,
          end: height / 2 - 5,
        ),
        alignment: Alignment.center,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            UiArtImage.square(UiArt.starFilled, extent: starSize),
            SizedBox(width: _large ? 4 : 3),
            Text(
              all
                  ? l10n.chaptersStarsTotalAll(earned, total)
                  : l10n.chaptersStarsTotal(earned, total),
              style: AppTextStyleTokens.number.copyWith(
                fontSize: height / 2,
                height: 1,
                color: AppColorTokens.coinText,
              ),
              maxLines: 1,
              softWrap: false,
            ),
          ],
        ),
      ),
    );
  }
}
