import 'dart:math' as math;

import 'package:intl/intl.dart';
import 'package:nesty_game/core/common_imports.dart';
import 'package:nesty_game/core/services/clock/local_date.dart';
import 'package:nesty_game/core/ui/nesty_ui.dart';
import 'package:nesty_game/features/museum/cubit/museum_cubit.dart';
import 'package:nesty_game/features/museum/widgets/figurine_image.dart';

/// The figurine detail modal (frames 6.2/6.3; docs/plans/m3-design.md
/// §10.6): a spotlight, the chapter chip, the name, and either
/// [MuseumEntry.earned]'s flavor text + "Collected" chip (6.2) or
/// [entry]'s chapter progress bar + "Play Level N" (6.3, shown for the
/// next figurine too, not only a fully locked one).
class FigurineModal extends StatelessWidget {
  const FigurineModal({
    required this.entry,
    required this.homeLevelNumber,
    required this.onClose,
    required this.onPlay,
    super.key,
  });

  final MuseumEntry entry;
  final int homeLevelNumber;
  final VoidCallback onClose;
  final VoidCallback onPlay;

  @override
  Widget build(BuildContext context) {
    final l10n = context.localizations;
    final earned = entry.earned;
    final flavor = l10n.figurineFlavor(entry.figurineId);
    return Stack(
      fit: StackFit.expand,
      children: [
        const Scrim(),
        Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 22),
            child: ModalCard(
              onClose: onClose,
              closeSemanticLabel: l10n.closeSemantics,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _Spotlight(entry: entry),
                  const SizedBox(height: 16),
                  Text(
                    l10n.figurineName(entry.figurineId),
                    textAlign: TextAlign.center,
                    style: AppTextStyleTokens.h2,
                  ),
                  if (earned && flavor.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      flavor,
                      textAlign: TextAlign.center,
                      style: AppTextStyleTokens.body.copyWith(
                        fontStyle: FontStyle.italic,
                        color: AppColors.iconBrown,
                      ),
                    ),
                  ],
                  if (!earned) ...[
                    const SizedBox(height: 8),
                    Text(
                      l10n.museumLockedText(entry.chapterNumber),
                      textAlign: TextAlign.center,
                      style: AppTextStyleTokens.body.copyWith(
                        color: AppColors.iconBrown,
                      ),
                    ),
                  ],
                  const SizedBox(height: 14),
                  if (earned)
                    _CollectedChip(collectedOn: entry.collectedOn)
                  else ...[
                    _ChapterBar(entry: entry),
                    const SizedBox(height: 16),
                    TactileButton(
                      label: l10n.playLevel(homeLevelNumber),
                      onPressed: onPlay,
                      icon: NestyIcons.playArrow,
                      size: TactileButtonSize.medium,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _Spotlight extends StatelessWidget {
  const _Spotlight({required this.entry});

  final MuseumEntry entry;

  static const double _height = 200;
  static const double _artMax = 272;

  @override
  Widget build(BuildContext context) {
    final earned = entry.earned;
    return SizedBox(
      height: _height,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final art = math.min(
            _artMax,
            math.min(constraints.maxWidth - 32, constraints.maxHeight - 20),
          );
          return ClipRRect(
            borderRadius: const BorderRadius.all(Radius.circular(24)),
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(0, -0.4),
                  radius: 0.85,
                  colors: earned
                      ? const [
                          AppColors.spotlightEarnedTop,
                          AppColors.spotlightEarnedMid,
                          AppColors.spotlightEarnedEdge,
                        ]
                      : const [
                          AppColors.spotlightLockedTop,
                          AppColors.spotlightLockedMid,
                          AppColors.spotlightLockedEdge,
                        ],
                  stops: const [0, 0.7, 1],
                ),
              ),
              child: Stack(
                children: [
                  Center(
                    child: FigurineImage(
                      figurineId: entry.figurineId,
                      locked: !earned,
                      size: art,
                    ),
                  ),
                  PositionedDirectional(
                    start: 12,
                    top: 12,
                    child: _ChapterChip(entry: entry),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ChapterChip extends StatelessWidget {
  const _ChapterChip({required this.entry});

  final MuseumEntry entry;

  @override
  Widget build(BuildContext context) {
    final l10n = context.localizations;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColorTokens.surface.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        child: Text(
          l10n.museumChapterChip(
            entry.chapterNumber,
            l10n.chapterName(entry.themeId),
          ),
          style: AppTextStyleTokens.cardTitle.copyWith(
            fontSize: 12,
            color: AppColors.textBrown,
          ),
        ),
      ),
    );
  }
}

class _CollectedChip extends StatelessWidget {
  const _CollectedChip({required this.collectedOn});

  final LocalDate? collectedOn;

  @override
  Widget build(BuildContext context) {
    final l10n = context.localizations;
    final date = collectedOn;
    final label = date == null
        ? l10n.museumCollected
        : l10n.museumCollectedOn(
            DateFormat.MMMd(
              Localizations.localeOf(context).toString(),
            ).format(date.startOfDay),
          );
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColorTokens.successTint,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              NestyIcons.checkCircle,
              size: 17,
              color: AppColorTokens.successEdge,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: AppTextStyleTokens.cardTitle.copyWith(
                fontSize: 13,
                color: AppColorTokens.successEdge,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChapterBar extends StatelessWidget {
  const _ChapterBar({required this.entry});

  final MuseumEntry entry;

  @override
  Widget build(BuildContext context) {
    final l10n = context.localizations;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              l10n.winChapter(entry.chapterNumber),
              style: AppTextStyleTokens.cardTitle.copyWith(
                fontSize: 13,
                color: AppColors.textBrown,
              ),
            ),
            Text(
              l10n.homeMuseumProgress(entry.done, entry.total),
              style: AppTextStyleTokens.cardTitle.copyWith(
                fontSize: 13,
                color: AppColors.textBrown,
              ),
            ),
          ],
        ),
        const SizedBox(height: 7),
        NestyProgressBar(
          value: entry.total == 0 ? 0 : entry.done / entry.total,
          height: 16,
        ),
      ],
    );
  }
}
