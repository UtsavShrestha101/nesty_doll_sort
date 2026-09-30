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
/// 20 dp star (`UiArt.starFilled`) and the fraction in `coinText`. It sits on
/// Home's chapter card (32 tall), Chapters' folded rows and the open
/// chapter's header (28 tall).
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
    super.key,
  });

  final int earned;
  final int total;
  final double height;
  final bool perfect;

  static const double starSize = 20;

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
        padding: EdgeInsetsDirectional.only(start: 6, end: height / 2 - 2),
        alignment: Alignment.center,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            UiArtImage.square(UiArt.starFilled, extent: starSize),
            const SizedBox(width: 3),
            Text(
              l10n.chaptersStarsTotal(earned, total),
              style: AppTextStyleTokens.number.copyWith(
                fontSize: 16,
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
