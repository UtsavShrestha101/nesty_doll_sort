import 'package:nesty_core/nesty_core.dart' show Tier;
import 'package:nesty_game/core/common_imports.dart';
import 'package:nesty_game/core/ui/nesty_ui.dart';
import 'package:nesty_game/features/chapters/cubit/chapters_cubit.dart';

/// One level cell of the open chapter's grid (frames 10.4, 11.5; tokens
/// `layout.chapters.current.grid`; menus spec 3): 62 tall, radius 14.
///
/// **Won:** a `cream` cell with a 1.5 dp `surfaceTrack` inset, the number,
/// the stars (`StarRow`, 11 dp) and "Best N"; a tap opens the level card.
/// **Current:** `gradient.primary` on a 4 dp `primaryEdge` with a soft 4 dp
/// ring, the number and a play arrow; a tap plays the campaign. **Locked:**
/// the `lockedCellFace` fill, the number in `lockedCellNumber` and a lock in
/// `lockedCellLock` (the 10th and 20th show their mark instead, at 0.8); no
/// tap, no ripple.
///
/// A Hard or Super Hard level that is won or current gets a 2 dp inset edge
/// in the tier's colour (`tierEdgeHard`, `tierEdgeSuperHard`); a locked cell
/// never previews a difficulty. The chapter's 10th level carries the closed
/// chest (18×15, top-right, inset 5), the 20th a flag (16, `primaryEdge`).
///
/// One semantics node: the level, its state and, for the marked levels, "has
/// a milestone chest" or "last level of the chapter".
class ChapterLevelCell extends StatelessWidget {
  const ChapterLevelCell({required this.level, required this.onTap, super.key});

  final ChapterLevel level;

  /// Null for a locked cell (no tap, no ripple).
  final VoidCallback? onTap;

  static const double height = ChaptersTokens.currentGridTileHeight;
  static const BorderRadius _radius = BorderRadius.all(
    Radius.circular(ChaptersTokens.currentGridTileRadius),
  );

  /// NestyHub:310: `#FFF6E6` with `inset 0 0 0 1.5px #EAD3B0`.
  static const _wonStyle = SurfaceStyle(
    color: AppColorTokens.cream,
    shadows: [
      NestyShadow(color: AppColorTokens.surfaceTrack, inset: true, spread: 1.5),
    ],
  );

  static const _currentStyle = SurfaceStyle(
    gradient: ChaptersTokens.currentTileFill,
    shadows: [
      NestyShadow(color: AppColorTokens.primaryEdge, dy: 4),
      NestyShadow(color: Color(0x47F2893B), spread: 4),
    ],
  );

  /// `chapters.lockedCell`: `#F1E3CC` with the sunk inset shadow.
  static const _lockedStyle = SurfaceStyle(
    color: ChaptersTokens.lockedCellFace,
    shadows: ChaptersTokens.lockedCellShadow,
  );

  /// A locked cell's chest and flag marks (NestyHub:311 `markOp`).
  static const double lockedMarkOpacity = 0.8;

  /// The tier edge colour: only for a reached cell (won or current) of a
  /// tier that shows a badge elsewhere (`TierChip.shows`).
  Color? _tierEdge() {
    if (level.status == ChapterLevelStatus.locked) return null;
    if (!TierChip.shows(level.tier)) return null;
    return level.tier == Tier.superhard
        ? AppColorTokens.tierEdgeSuperHard
        : AppColorTokens.tierEdgeHard;
  }

  String _semantics(AppLocalizations l10n) {
    final parts = <String>[
      switch (level.status) {
        ChapterLevelStatus.won => _won(l10n),
        ChapterLevelStatus.current => l10n.chaptersLevelSemanticsCurrent(
          level.order,
        ),
        ChapterLevelStatus.locked => l10n.chaptersLevelSemanticsLocked(
          level.order,
        ),
      },
      if (level.isChest) l10n.chaptersLevelChestSemantics,
      if (level.isFinale) l10n.chaptersLevelFinaleSemantics,
    ];
    // Each part is a sentence (copy.md A11y `a11y_level_*`): one stop and
    // a space between them.
    return l10n.joinSentences(parts, closing: true);
  }

  String _won(AppLocalizations l10n) {
    final stars = level.stars;
    final best = level.bestMoves;
    if (stars != null && best != null) {
      return l10n.chaptersLevelSemanticsWon(level.order, stars, best);
    }
    // A save from before stars or bests were kept, or a level without a par:
    // say what it holds.
    if (best != null) {
      return l10n.chaptersLevelSemanticsWonBestOnly(level.order, best);
    }
    final base = l10n.chaptersLevelSemanticsWonNoBest(level.order);
    return stars == null
        ? base
        : l10n.joinList([base, l10n.starsSemantics(stars)]);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.localizations;
    final won = level.status == ChapterLevelStatus.won;
    final current = level.status == ChapterLevelStatus.current;
    final locked = level.status == ChapterLevelStatus.locked;
    final textColor = current
        ? const Color(0xFFFFFFFF)
        : locked
        ? ChaptersTokens.lockedCellNumber
        : AppColorTokens.textPrimary;
    final content = FittedBox(
      fit: BoxFit.scaleDown,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          NestyNumberText(
            level.order,
            style: ChaptersTypeTokens.cellNumber.copyWith(color: textColor),
          ),
          if (won && level.stars != null)
            StarRow(
              count: level.stars!,
              size: ChaptersTokens.currentGridMiniStar,
            ),
          if (won && level.bestMoves != null)
            Text(
              l10n.chaptersBestMoves(level.bestMoves!),
              style: ChaptersTokens.currentGridBest,
              maxLines: 1,
              softWrap: false,
            ),
          if (current)
            const Icon(
              NestyIcons.playArrow,
              size: 22,
              color: Color(0xFFFFFFFF),
            ),
          if (locked && !level.isChest && !level.isFinale)
            const Icon(
              NestyIcons.lock,
              size: 13,
              color: ChaptersTokens.lockedCellLock,
            ),
        ],
      ),
    );
    final style = won
        ? _wonStyle
        : current
        ? _currentStyle
        : _lockedStyle;
    // A locked cell isn't tactile at all: a plain surface, no ripple, no
    // button role.
    final face = onTap == null
        ? NestySurface(
            style: style,
            radius: _radius,
            width: double.infinity,
            height: height,
            alignment: Alignment.center,
            child: content,
          )
        : TactileSurface(
            style: style,
            radius: _radius,
            onPressed: onTap,
            width: double.infinity,
            height: height,
            semanticLabel: _semantics(l10n),
            excludeChildSemantics: true,
            alignment: Alignment.center,
            child: content,
          );
    final edge = _tierEdge();
    final markOpacity = locked ? lockedMarkOpacity : 1.0;
    final markArt = level.isChest
        ? UiArtImage(
            UiArt.chestClosed,
            size: Size(18, 18 / UiArt.chestClosed.aspectRatio),
          )
        : level.isFinale
        ? const Icon(
            IconUses.chapterFinale,
            size: 16,
            color: AppColorTokens.primaryEdge,
          )
        : null;
    final mark = markArt == null
        ? null
        : Opacity(opacity: markOpacity, child: markArt);
    final cell = Stack(
      clipBehavior: Clip.none,
      children: [
        face,
        if (edge != null)
          Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: _radius,
                  border: Border.all(
                    color: edge,
                    width: ChaptersTokens.currentTierEdgeWidth,
                  ),
                ),
              ),
            ),
          ),
        if (mark != null)
          PositionedDirectional(
            end: 5,
            top: 5,
            child: IgnorePointer(child: mark),
          ),
      ],
    );
    if (onTap != null) return cell;
    return Semantics(
      container: true,
      label: _semantics(l10n),
      enabled: false,
      excludeSemantics: true,
      child: cell,
    );
  }
}
