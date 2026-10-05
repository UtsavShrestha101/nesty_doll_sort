import 'package:flutter/material.dart';
import 'package:nesty_game/core/extensions/context_extension.dart';
import 'package:nesty_game/core/services/chest/milestone_chest.dart';
import 'package:nesty_game/core/ui/nesty_ui.dart';
import 'package:nesty_game/features/fx/fx_library.dart';
import 'package:nesty_game/features/gameplay/pages/chapter_progress.dart';
import 'package:nesty_game/features/gameplay/widgets/lottie_doll.dart';
import 'package:nesty_game/features/museum/widgets/figurine_image.dart';

/// The solid cream card over the scrim (ui-spec-game §1 "InfoCard"; tokens.json
/// `layout.replayCard.card`): `rgba(255,249,236,.97)` with a 5 dp `#D8B07A`
/// edge. The progress card, the streak card and the replay reason card.
const SurfaceStyle winInfoCardStyle = SurfaceStyle(
  color: ReplayCardTokens.cardFill,
  shadows: [NestyShadow(color: AppColorTokens.surfaceEdge, dy: 5)],
);

/// The win overlay's progress card (frames 2.8, 10.3, 12.4; ui-spec-game
/// §2.2): "Chapter 3" and "16 / 20" over the green bar (16 tall), a line
/// under it and a 62 dp tile.
///
/// - A campaign win: the label and count stay the chapter's, and the next line
///   is "Next up: The Baker Family" (or the chapter's prize) with the
///   figurine's locked tile.
/// - [chestLevelsLeft] (the milestone chest nearer than the figurine, C2):
///   only the next line ("3 levels to the chest") and the tile (the closed
///   chest at 78 %) change. The bar and count are still the chapter's.
/// - [bonusNumber] (Bonus Endless, 12.4): "Bonus Level 7", "7 / 10" and a bar
///   of the 10-level cycle, then the chest line and tile.
///
/// It grows with its text (1.3× text, long translations) instead of clipping.
class WinChapterCard extends StatelessWidget {
  const WinChapterCard({
    required this.progress,
    this.chestLevelsLeft,
    this.bonusNumber,
    this.isReplay = false,
    super.key,
  });

  final ChapterProgress progress;
  final int? chestLevelsLeft;

  /// The bonus level's number: the card counts the 10-level chest cycle.
  final int? bonusNumber;
  final bool isReplay;

  /// The bonus card's cycle length (`MilestoneChest.bonusEvery`).
  static const int bonusCycle = MilestoneChestCountdown.cycle;

  /// A bonus level's place in its 10-level cycle, 1–10.
  static int bonusPosition(int number) => (number - 1) % bonusCycle + 1;

  @override
  Widget build(BuildContext context) {
    final l10n = context.localizations;
    final chestLeft = chestLevelsLeft;
    final bonus = bonusNumber;
    // Right after the chest opens the cycle restarts at ten: nothing to
    // count down to yet.
    final chestLine = chestLeft == null || chestLeft >= bonusCycle
        ? null
        : l10n.winChestCountdown(chestLeft);
    final figurine = l10n.figurineName(progress.figurineId);
    final String? next = bonus != null
        ? chestLine
        : chestLeft != null
        ? chestLine
        : isReplay
        ? null
        : progress.isComplete
        ? l10n.winChapterDone
        : figurine.isEmpty
        ? null
        : l10n.winNextUp(figurine);
    final label = AppTextStyleTokens.cardTitle.copyWith(
      fontSize: 14,
      height: 1,
      color: AppColors.textBrown,
    );
    final count = bonus == null
        ? l10n.winChapterProgress(progress.done, progress.total)
        : l10n.winChapterProgress(bonusPosition(bonus), bonusCycle);
    final barValue = bonus == null
        ? progress.fraction
        : bonusPosition(bonus) / bonusCycle;
    return NestySurface(
      style: winInfoCardStyle,
      radius: const BorderRadius.all(Radius.circular(22)),
      width: double.infinity,
      padding: const EdgeInsetsDirectional.fromSTEB(16, 12, 12, 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        bonus == null
                            ? l10n.winChapter(progress.number)
                            : l10n.bonusLevelTitle(bonus),
                        style: label,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(count, style: label),
                  ],
                ),
                const SizedBox(height: 8),
                NestyProgressBar(value: barValue, height: 16),
                if (next != null) ...[
                  const SizedBox(height: 7),
                  Text(
                    next,
                    style: AppTextStyles.caption.copyWith(
                      fontSize: 13,
                      height: 1.2,
                      color: AppColorTokens.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 12),
          bonus != null || chestLeft != null
              ? const _ChestTile()
              : _FigurineTile(figurineId: progress.figurineId),
        ],
      ),
    );
  }
}

/// The milestone chest's cadence (`MilestoneChest.chapterPosition`/
/// `.bonusEvery`, both 10).
abstract final class MilestoneChestCountdown {
  static const int cycle = MilestoneChest.bonusEvery;
}

/// The replay card's reason card (frames 10.5, 11.4–11.4b; `layout.replayCard`):
/// the `replay` glyph and "A replay for fun: coins come from new levels.", and,
/// under a dashed divider, the 3-star target row (only below 3 stars): an
/// empty star and "3 stars at 15 moves or fewer". One node for screen readers
/// for the reason, and the target row its own.
class ReplayReasonCard extends StatelessWidget {
  const ReplayReasonCard({this.starTarget, super.key});

  /// `GameplayState.starTarget`: the moves for 3 stars, null at 3 stars.
  final int? starTarget;

  @override
  Widget build(BuildContext context) {
    final l10n = context.localizations;
    final target = starTarget;
    return NestySurface(
      style: winInfoCardStyle,
      radius: BorderRadius.circular(ReplayCardTokens.cardRadius),
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 12, 16, 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Semantics(
            container: true,
            label: l10n.winReplayReason,
            excludeSemantics: true,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 2),
                  child: Icon(
                    IconUses.replay,
                    size: 22,
                    color: Color(0xFFC4631E),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    l10n.winReplayReason,
                    style: ReplayCardTokens.reason.copyWith(height: 1.4),
                  ),
                ),
              ],
            ),
          ),
          if (target != null) ...[
            const SizedBox(height: 10),
            const _DashedDivider(),
            const SizedBox(height: 10),
            Semantics(
              container: true,
              label: l10n.winStarsTarget(target),
              excludeSemantics: true,
              child: Row(
                children: [
                  UiArtImage.square(
                    UiArt.starEmpty,
                    extent: ReplayCardTokens.targetRowStarSize,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      l10n.winStarsTarget(target),
                      style: ReplayCardTokens.targetRowText,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// The replay card's dashed rule: 1.5 dp `#EAD3B0`.
class _DashedDivider extends StatelessWidget {
  const _DashedDivider();

  @override
  Widget build(BuildContext context) => const SizedBox(
    height: 1.5,
    width: double.infinity,
    child: CustomPaint(painter: _DashPainter()),
  );
}

final class _DashPainter extends CustomPainter {
  const _DashPainter();

  static final Paint _paint = Paint()
    ..color = AppColorTokens.surfaceTrack
    ..strokeWidth = 1.5;

  @override
  void paint(Canvas canvas, Size size) {
    for (var x = 0.0; x < size.width; x += 8) {
      canvas.drawLine(
        Offset(x, size.height / 2),
        Offset((x + 4).clamp(0, size.width), size.height / 2),
        _paint,
      );
    }
  }

  @override
  bool shouldRepaint(_DashPainter oldDelegate) => false;
}

/// The win overlay's daily variant (frame 5.4, m3-design §8.4, NestyOverlay
/// `isStreak`): the flame badge, "{N}-day streak" and how many days are
/// left to the Day 7 chest, in the same 484-top slot [WinChapterCard] fills
/// on a campaign win.
///
/// [relit] (E2; m7-design §8, §15.7): the solve restarted a paused streak,
/// so the two lines become "Streak relit!" / "Your N-day streak is glowing
/// again" instead of the count and the chest hint (D98: a moment, not a
/// stored state). A relit card wears the `auto_awesome` glyph at the flame
/// disc's top-right corner, and `fx_twinkle` plays once on it as the card
/// lands (`motion.relitTwinkle`, m7-4 4.17); under reduced motion the glyph
/// alone. The moves sit in the chips row above it (frame 10.1).
class DailyStreakCard extends StatelessWidget {
  const DailyStreakCard({
    required this.streak,
    this.relit = false,
    this.library,
    super.key,
  });

  /// The streak after this solve (`GameplayState.dailyStreak`).
  final int streak;
  final bool relit;

  /// The Lottie library for a relit card's twinkle.
  final FxLibrary? library;

  /// A relit card's `relitGlow` ring (NestyMeta `0 0 0 3px rgba(255,205,80,
  /// .6)`, the same as the daily page's relit streak card).
  static const _relitStyle = SurfaceStyle(
    color: ReplayCardTokens.cardFill,
    shadows: [
      NestyShadow(color: AppColorTokens.surfaceEdge, dy: 5),
      NestyShadow(color: AppColorTokens.relitGlow, spread: 3),
    ],
  );

  /// The relit glyph's key, for tests.
  static const relitGlyphKey = Key('relit-glyph');

  /// The relit mark's one `fx_twinkle`, a 32 dp box (the file's canvas) on
  /// the glyph's centre.
  static const double twinkleSize = 32;

  /// The glyph's box and where its top-right sits: 8 dp outside the 52 dp
  /// flame disc's corner (`motion.relitTwinkle.place`, frame 10.7b).
  static const double _discSize = 52;

  /// Days left to the next Day 7 chest (0 the day it opens): the streak
  /// counts up from 1, and the chest lands every 7th day (`streak % 7 == 0`,
  /// D76's weekly cadence).
  static int _daysToChest(int streak) => (7 - streak % 7) % 7;

  @override
  Widget build(BuildContext context) {
    final l10n = context.localizations;
    final title = relit
        ? l10n.dailyStreakRelitTitle
        : l10n.dailyWinStreak(streak);
    final body = relit
        ? l10n.dailyStreakRelitBody(streak)
        : l10n.dailyWinChestHint(_daysToChest(streak).toString());
    return NestySurface(
      style: relit ? _relitStyle : winInfoCardStyle,
      radius: const BorderRadius.all(Radius.circular(22)),
      width: double.infinity,
      padding: const EdgeInsetsDirectional.fromSTEB(12, 12, 16, 12),
      child: Row(
        children: [
          if (relit)
            // The glyph's box sits 8 dp outside the disc's corner; the card
            // keeps its own padding, so the mark may overhang the disc.
            SizedBox(
              width: DailyStreakCard._discSize,
              height: DailyStreakCard._discSize,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  const _StreakBadge(),
                  PositionedDirectional(
                    end: RelitTwinkleTokens.placeInset,
                    top: RelitTwinkleTokens.placeInset,
                    child: _RelitMark(library: library),
                  ),
                ],
              ),
            )
          else
            const _StreakBadge(),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: AppTextStyleTokens.cardTitle.copyWith(
                    color: AppColors.textBrown,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  body,
                  style: AppTextStyles.caption.copyWith(
                    fontSize: 13,
                    height: 1.3,
                    color: AppColorTokens.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// A relit streak's mark (`motion.relitTwinkle`): the `auto_awesome` glyph,
/// 22 dp `#FFE08A` with a soft glow, and one `fx_twinkle` over it as the card
/// lands. Reduced motion: the glyph only.
class _RelitMark extends StatelessWidget {
  const _RelitMark({this.library});

  final FxLibrary? library;

  @override
  Widget build(BuildContext context) {
    const size = RelitTwinkleTokens.glyphSize;
    const twinkle = DailyStreakCard.twinkleSize;
    return ExcludeSemantics(
      child: SizedBox.square(
        dimension: size,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            Icon(
              NestyIcons.autoAwesome,
              key: DailyStreakCard.relitGlyphKey,
              size: size,
              color: RelitTwinkleTokens.glyphColor,
              shadows: [
                for (final glow in RelitTwinkleTokens.glyphGlow)
                  Shadow(color: glow.color, blurRadius: glow.blur),
              ],
            ),
            if (!context.reduceMotion)
              Positioned(
                left: (size - twinkle) / 2,
                top: (size - twinkle) / 2,
                child: LottieTwinkle(
                  size: twinkle,
                  once: true,
                  library: library,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// The 52 px flame disc (NestyOverlay `isStreak`'s icon).
class _StreakBadge extends StatelessWidget {
  const _StreakBadge();

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: Container(
      width: 52,
      height: 52,
      decoration: const BoxDecoration(
        gradient: AppGradientTokens.streak,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(color: AppColorTokens.streakEdge, offset: Offset(0, 3)),
        ],
      ),
      child: const Icon(
        NestyIcons.localFireDepartment,
        size: 32,
        color: Color(0xFFFFF6E6),
      ),
    ),
  );
}

/// The 62×62 figurine tile (`#F3E2C6` with a 2 px `#EAD3B0` ring): the
/// chapter's own figurine, still locked (it is earned on the chapter's
/// completion, the separate Chapter complete overlay, m3-design §9.1, §9.3).
class _FigurineTile extends StatelessWidget {
  const _FigurineTile({required this.figurineId});

  final String figurineId;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: const BoxDecoration(
      color: Color(0xFFF3E2C6),
      borderRadius: BorderRadius.all(Radius.circular(14)),
      border: Border.fromBorderSide(
        BorderSide(color: AppColorTokens.surfaceTrack, width: 2),
      ),
    ),
    child: SizedBox.square(
      dimension: 62,
      child: Center(
        child: FigurineImage(figurineId: figurineId, locked: true, size: 52),
      ),
    ),
  );
}

/// The chest tile of the chest countdown line (frame 10.3): the same 62 dp
/// tile with the closed chest's art at 78 %.
class _ChestTile extends StatelessWidget {
  const _ChestTile();

  static const double _scale = 0.78;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: const BoxDecoration(
      color: Color(0xFFF3E2C6),
      borderRadius: BorderRadius.all(Radius.circular(14)),
      border: Border.fromBorderSide(
        BorderSide(color: AppColorTokens.surfaceTrack, width: 2),
      ),
    ),
    child: SizedBox.square(
      dimension: 62,
      child: Center(
        child: UiArtImage(
          UiArt.chestClosed,
          size: Size(62 * _scale, 62 * _scale / UiArt.chestClosed.aspectRatio),
        ),
      ),
    ),
  );
}
