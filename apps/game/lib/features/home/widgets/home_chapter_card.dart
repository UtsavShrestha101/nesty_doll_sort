import 'package:flutter/widgets.dart';
import 'package:nesty_game/core/extensions/context_extension.dart';
import 'package:nesty_game/core/ui/icons/icon_uses.dart';
import 'package:nesty_game/core/ui/theme/locale_script.dart';
import 'package:nesty_game/core/ui/tokens/ui_token_types.dart';
import 'package:nesty_game/core/ui/tokens/ui_tokens.gen.dart';
import 'package:nesty_game/core/ui/widgets/home/stars_chip.dart';
import 'package:nesty_game/core/ui/widgets/surface/nesty_surface.dart';
import 'package:nesty_game/core/ui/widgets/surface/surface_style.dart';
import 'package:nesty_game/core/ui/widgets/tactile/tactile_surface.dart';
import 'package:nesty_render/nesty_render.dart' show ChapterTheme;

/// Home's chapter card (frame 2.1, `layout.home.chapterCard`; menus spec
/// 1.1): the chapter the PLAY level is in, its name and its star total.
/// A tap opens Chapters.
///
/// The icon tile is the chapter's own palette (`accentTop → accent`, a 4 dp
/// `accentEdge`), and its kicker is `accentEdge`. In Bonus Endless ([bonus],
/// frame 12.2) the tile is `gradient.bonus`, the kicker reads "BONUS
/// ENDLESS", the name "Bonus levels" and the chip the whole campaign's
/// stars.
///
/// At least [minHeight] tall, growing with 1.3× text; the chip keeps its size
/// and the name shrinks before it ellipsises.
class HomeChapterCard extends StatelessWidget {
  const HomeChapterCard({
    required this.chapterNumber,
    required this.chapterId,
    required this.stars,
    required this.starsPossible,
    required this.onTap,
    this.bonus = false,
    super.key,
  });

  final int chapterNumber;
  final String chapterId;
  final int stars;
  final int starsPossible;
  final bool bonus;
  final VoidCallback onTap;

  static const double minHeight = HomeTokens.chapterCardHeight;

  static const _style = SurfaceStyle(
    gradient: AppGradientTokens.surface,
    shadows: [
      NestyShadow(color: Color(0xFFFFFFFF), inset: true, dy: 2),
      NestyShadow(color: AppColorTokens.surfaceEdge, dy: 5),
      NestyShadow(color: Color(0x335A3214), dy: 10, blur: 16),
    ],
  );

  @override
  Widget build(BuildContext context) {
    final l10n = context.localizations;
    final palette = (ChapterTheme.byId(chapterId) ?? ChapterTheme.ch01).palette;
    final name = l10n.chapterName(chapterId);
    final kicker = bonus
        ? l10n.homeBonusKicker
        : l10n.homeChapterKicker(chapterNumber);
    final title = bonus ? l10n.homeBonusName : name;
    final label = bonus
        ? l10n.homeBonusCardSemantics(stars, starsPossible)
        : l10n.homeChapterCardSemantics(
            chapterNumber,
            name,
            stars,
            starsPossible,
          );
    final tileStyle = SurfaceStyle(
      gradient: bonus
          ? AppGradientTokens.bonus
          : LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [palette.accentTop, palette.accent],
            ),
      shadows: [
        const NestyShadow(color: Color(0x59FFFFFF), inset: true, dy: 2),
        NestyShadow(
          color: bonus ? AppColorTokens.bonusEdge : palette.accentEdge,
          dy: 4,
        ),
      ],
    );
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: minHeight),
      child: TactileSurface(
        style: _style,
        radius: BorderRadius.circular(HomeTokens.chapterCardRadius),
        onPressed: onTap,
        width: double.infinity,
        padding: const EdgeInsetsDirectional.fromSTEB(8, 8, 10, 12),
        semanticLabel: label,
        excludeChildSemantics: true,
        alignment: AlignmentDirectional.centerStart,
        child: Row(
          children: [
            NestySurface(
              style: tileStyle,
              radius: BorderRadius.circular(14),
              width: HomeTokens.chapterCardIcon,
              height: HomeTokens.chapterCardIcon,
              alignment: Alignment.center,
              child: const Icon(
                IconUses.chapters,
                size: 26,
                color: Color(0xFFFFFFFF),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    kicker,
                    style: AppTextStyleTokens.cardTitle.copyWith(
                      fontSize: 11,
                      height: 1,
                      letterSpacing: context.script.tracking(11 * 0.08),
                      color: bonus
                          ? AppColorTokens.bonusEdge
                          : palette.accentEdge,
                    ),
                  ),
                  // textFit.cardsAndSheets: a card's title wraps (the card
                  // grows) instead of shrinking to a fraction. A `Text`
                  // rather than `ShrinkToFitText`: the row above asks this
                  // column for its intrinsic height, which a LayoutBuilder
                  // can't give.
                  Text(
                    title,
                    style: context.scriptStyle(
                      AppTextStyleTokens.cardTitle.copyWith(
                        fontSize: 17,
                        height: 1.1,
                        color: AppColorTokens.textPrimary,
                      ),
                      role: ScriptTextRole.title,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 6),
            StarsChip(
              earned: stars,
              total: starsPossible,
              height: StarsChip.homeHeight,
              all: bonus,
            ),
          ],
        ),
      ),
    );
  }
}

/// Home's Records button (frame 2.1, `layout.home.recordsButton`): 62 wide,
/// as tall as the chapter card beside it, radius 20, `military_tech` in
/// `primaryEdge` over "Records". Opens Records.
class HomeRecordsButton extends StatelessWidget {
  const HomeRecordsButton({
    required this.label,
    required this.onTap,
    super.key,
  });

  final String label;
  final VoidCallback onTap;

  static const double width = 62;

  static const _style = SurfaceStyle(
    gradient: AppGradientTokens.surface,
    shadows: [
      NestyShadow(color: Color(0xFFFFFFFF), inset: true, dy: 2),
      NestyShadow(color: AppColorTokens.surfaceEdge, dy: 5),
      NestyShadow(color: Color(0x335A3214), dy: 10, blur: 16),
    ],
  );

  @override
  Widget build(BuildContext context) => SizedBox(
    width: width,
    child: TactileSurface(
      style: _style,
      radius: BorderRadius.circular(HomeTokens.recordsButtonRadius),
      onPressed: onTap,
      width: width,
      semanticLabel: label,
      excludeChildSemantics: true,
      padding: const EdgeInsets.fromLTRB(2, 6, 2, 10),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              IconUses.records,
              size: 26,
              color: AppColorTokens.primaryEdge,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              // NestyHub:26: Fredoka 700 11, `#6E4526`.
              style: AppTextStyleTokens.cardTitle.copyWith(
                fontSize: 11,
                height: 1,
                color: AppColorTokens.iconBrown,
              ),
              maxLines: 1,
              softWrap: false,
            ),
          ],
        ),
      ),
    ),
  );
}
