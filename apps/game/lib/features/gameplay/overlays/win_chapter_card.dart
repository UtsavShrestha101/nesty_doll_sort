import 'package:flutter/material.dart';
import 'package:nesty_game/core/extensions/context_extension.dart';
import 'package:nesty_game/core/ui/nesty_ui.dart';
import 'package:nesty_game/features/gameplay/pages/chapter_progress.dart';

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
          const _FigurineTile(),
        ],
      ),
    );
  }
}

/// The 62×62 figurine tile (`#F3E2C6` with a 2 px `#EAD3B0` ring).
///
/// TODO(M3): the chapter's locked figurine art (`museum/0N-*-locked.svg`)
/// once the museum set is bundled; a museum glyph stands in.
class _FigurineTile extends StatelessWidget {
  const _FigurineTile();

  @override
  Widget build(BuildContext context) => const ExcludeSemantics(
    child: SizedBox.square(
      dimension: 62,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Color(0xFFF3E2C6),
          borderRadius: BorderRadius.all(Radius.circular(14)),
          border: Border.fromBorderSide(
            BorderSide(color: AppColorTokens.surfaceTrack, width: 2),
          ),
        ),
        child: Icon(NestyIcons.museum, size: 32, color: AppColors.chevron),
      ),
    ),
  );
}
