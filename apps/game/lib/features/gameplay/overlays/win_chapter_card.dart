import 'package:flutter/material.dart';
import 'package:nesty_game/core/extensions/context_extension.dart';
import 'package:nesty_game/core/ui/nesty_ui.dart';
import 'package:nesty_game/features/gameplay/pages/chapter_progress.dart';
import 'package:nesty_game/features/museum/widgets/figurine_image.dart';

/// The win overlay's chapter card (frame 2.8; NestyOverlay `isProg`):
/// "Chapter 3 · 16 / 20", the green chapter bar, "Next up: The Baker
/// Family" (or "Chapter complete! Your prize is next." on its last level),
/// and the figurine's tile.
///
/// It grows with its text (1.3× text, long translations) instead of
/// clipping. A figurine without a name yet hides the "Next up" line.
class WinChapterCard extends StatelessWidget {
  const WinChapterCard({required this.progress, super.key});

  final ChapterProgress progress;

  static const _style = SurfaceStyle(
    color: Color(0xF5FFF9EC),
    shadows: [NestyShadow(color: AppColorTokens.surfaceEdge, dy: 5)],
  );

  @override
  Widget build(BuildContext context) {
    final l10n = context.localizations;
    final figurine = l10n.figurineName(progress.figurineId);
    final String? next = progress.isComplete
        ? l10n.winChapterDone
        : figurine.isEmpty
        ? null
        : l10n.winNextUp(figurine);
    final label = AppTextStyleTokens.cardTitle.copyWith(
      fontSize: 14,
      height: 1,
      color: AppColors.textBrown,
    );
    return NestySurface(
      style: _style,
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
                        l10n.winChapter(progress.number),
                        style: label,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      l10n.winChapterProgress(progress.done, progress.total),
                      style: label,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                NestyProgressBar(value: progress.fraction, height: 16),
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
          _FigurineTile(figurineId: progress.figurineId),
        ],
      ),
    );
  }
}

/// The win overlay's daily variant (frame 5.4, m3-design §8.4, NestyOverlay
/// `isStreak`): the flame badge, "{N}-day streak" and how many days are
/// left to the Day 7 chest, in the same 484-top slot [WinChapterCard] fills
/// on a campaign win.
class DailyStreakCard extends StatelessWidget {
  const DailyStreakCard({required this.streak, super.key});

  /// The streak after this solve (`GameplayState.dailyStreak`).
  final int streak;

  static const _style = SurfaceStyle(
    color: Color(0xF5FFF9EC),
    shadows: [NestyShadow(color: AppColorTokens.surfaceEdge, dy: 5)],
  );

  /// Days left to the next Day 7 chest (0 the day it opens): the streak
  /// counts up from 1, and the chest lands every 7th day (`streak % 7 == 0`,
  /// D76's weekly cadence).
  static int _daysToChest(int streak) => (7 - streak % 7) % 7;

  @override
  Widget build(BuildContext context) {
    final l10n = context.localizations;
    return NestySurface(
      style: _style,
      radius: const BorderRadius.all(Radius.circular(22)),
      width: double.infinity,
      padding: const EdgeInsetsDirectional.fromSTEB(12, 12, 16, 12),
      child: Row(
        children: [
          const _StreakBadge(),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  l10n.dailyWinStreak(streak),
                  style: AppTextStyleTokens.cardTitle.copyWith(
                    color: AppColors.textBrown,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  l10n.dailyWinChestHint(_daysToChest(streak).toString()),
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
