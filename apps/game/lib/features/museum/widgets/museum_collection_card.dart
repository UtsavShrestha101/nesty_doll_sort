import 'package:nesty_game/core/common_imports.dart';
import 'package:nesty_game/core/ui/nesty_ui.dart';
import 'package:nesty_game/features/museum/cubit/museum_cubit.dart';

/// The Museum's collection card (frame 6.1; docs/plans/m3-design.md §10.6):
/// "Collection" + a progress bar + "N / 10", then either the next
/// figurine's chapter line or, once [MuseumState.allCollected],
/// `museumAllHome` (a design gap: no frame shows every chapter collected).
class MuseumCollectionCard extends StatelessWidget {
  const MuseumCollectionCard({required this.state, super.key});

  final MuseumState state;

  @override
  Widget build(BuildContext context) {
    final l10n = context.localizations;
    final next = state.next;
    return NestySurface(
      style: SurfaceStyle(
        color: AppColorTokens.surface.withValues(alpha: 0.92),
        shadows: const [NestyShadow(color: AppColorTokens.surfaceEdge, dy: 3)],
      ),
      radius: const BorderRadius.all(Radius.circular(20)),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                l10n.museumCollection,
                style: AppTextStyleTokens.cardTitle.copyWith(
                  fontSize: 15,
                  color: AppColors.textBrown,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: NestyProgressBar(
                  value: state.totalChapters == 0
                      ? 0
                      : state.collectedCount / state.totalChapters,
                  height: 12,
                  semanticLabel: l10n.museumCollection,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                l10n.museumCount(state.collectedCount, state.totalChapters),
                style: AppTextStyleTokens.cardTitle.copyWith(
                  fontSize: 15,
                  color: AppColors.textBrown,
                ),
              ),
            ],
          ),
          const SizedBox(height: 7),
          Text(
            next == null
                ? l10n.museumAllHome
                : l10n.museumNextLine(
                    next.chapterNumber,
                    next.done,
                    next.total,
                    l10n.figurineName(next.figurineId),
                  ),
            style: AppTextStyleTokens.row.copyWith(
              fontSize: 13,
              color: AppColorTokens.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
