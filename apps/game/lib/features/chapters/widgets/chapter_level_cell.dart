import 'package:nesty_core/nesty_core.dart' show Tier;
import 'package:nesty_game/core/common_imports.dart';
import 'package:nesty_game/core/ui/nesty_ui.dart';
import 'package:nesty_game/features/chapters/cubit/chapters_cubit.dart';

/// One level cell of the open chapter's grid (frames 10.4, 11.5; tokens
/// `layout.chapters.current.grid`; menus spec 3): 62 tall, radius 14.
///
/// **Won:** a white cell with a 2 dp `surfaceTrack` inset, the number, the
/// stars (`StarRow`, 11 dp) and "Best N"; a tap opens the level card.
/// **Current:** `gradient.primary` on a 4 dp `primaryEdge` with a soft 4 dp
/// ring, the number and a play arrow; a tap plays the campaign. **Locked:**
/// the sunk fill, the number in `textMuted` and a lock; no tap, no ripple.
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

  static const _wonStyle = SurfaceStyle(
    color: AppColorTokens.surfaceWhite,
    shadows: [
      NestyShadow(color: AppColorTokens.surfaceTrack, inset: true, spread: 2),
    ],
  );

  static const _currentStyle = SurfaceStyle(
    gradient: ChaptersTokens.currentTileFill,
    shadows: [
      NestyShadow(color: AppColorTokens.primaryEdge, dy: 4),
      NestyShadow(color: Color(0x47F2893B), spread: 4),
    ],
  );

  static const _lockedStyle = SurfaceStyle(
    color: AppColorTokens.surfaceSunk,
    shadows: [],
  );

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
    return parts.join(', ');
  }

  String _won(AppLocalizations l10n) {
    final base = level.bestMoves == null
        ? l10n.chaptersLevelSemanticsWonNoBest(level.order)
        : l10n.chaptersLevelSemanticsWon(level.order, level.bestMoves!);
    final stars = level.stars;
    return stars == null ? base : '$base, ${l10n.starsSemantics(stars)}';
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
        ? AppColorTokens.textMuted
        : AppColorTokens.textPrimary;
    final content = FittedBox(
      fit: BoxFit.scaleDown,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          NestyNumberText(
            level.order,
            style: AppTextStyleTokens.number.copyWith(
              fontSize: 20,
              height: 1.1,
              color: textColor,
            ),
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
              size: 20,
              color: Color(0xFFFFFFFF),
            ),
          if (locked)
            const Icon(
              NestyIcons.lock,
              size: 16,
              color: AppColorTokens.textMuted,
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
    final mark = level.isChest
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
