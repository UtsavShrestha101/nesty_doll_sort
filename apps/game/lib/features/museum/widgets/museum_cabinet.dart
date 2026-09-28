import 'dart:math' as math;

import 'package:nesty_game/core/common_imports.dart';
import 'package:nesty_game/core/ui/nesty_ui.dart';
import 'package:nesty_game/features/museum/cubit/museum_cubit.dart';
import 'package:nesty_game/features/museum/widgets/figurine_image.dart';

/// The walnut cabinet (frame 6.1; docs/plans/m3-design.md §10.6): 4 shelves
/// of up to 3 figurines each (the 10th sits alone on its own shelf, left
/// column). Tapping any figurine calls [onTapEntry], which the page uses to
/// open the 6.2/6.3 modal.
class MuseumCabinet extends StatelessWidget {
  const MuseumCabinet({
    required this.entries,
    required this.onTapEntry,
    super.key,
  });

  final List<MuseumEntry> entries;
  final ValueChanged<MuseumEntry> onTapEntry;

  static const int itemsPerShelf = 3;

  @override
  Widget build(BuildContext context) {
    final shelves = <List<MuseumEntry>>[
      for (var i = 0; i < entries.length; i += itemsPerShelf)
        entries.sublist(i, math.min(i + itemsPerShelf, entries.length)),
    ];
    return NestySurface(
      style: const SurfaceStyle(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.walnutTop, AppColors.walnutBottom],
        ),
        shadows: [
          NestyShadow(color: AppColors.walnutHighlight, inset: true, dy: 3),
          NestyShadow(color: AppColors.walnutEdge, dy: 5),
        ],
      ),
      radius: const BorderRadius.all(Radius.circular(24)),
      padding: const EdgeInsets.all(10),
      child: Column(
        children: [
          for (var i = 0; i < shelves.length; i++) ...[
            if (i > 0) const SizedBox(height: 8),
            _Shelf(entries: shelves[i], onTapEntry: onTapEntry),
          ],
        ],
      ),
    );
  }
}

class _Shelf extends StatelessWidget {
  const _Shelf({required this.entries, required this.onTapEntry});

  final List<MuseumEntry> entries;
  final ValueChanged<MuseumEntry> onTapEntry;

  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: const BorderRadius.all(Radius.circular(AppRadii.md)),
    child: Column(
      children: [
        NestySurface(
          style: SurfaceStyle(
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [AppColors.shelfFaceTop, AppColors.shelfFaceBottom],
            ),
            shadows: [
              NestyShadow(
                color: AppColors.walnutEdge.withValues(alpha: 0.25),
                inset: true,
                dy: 6,
                blur: 10,
              ),
            ],
          ),
          radius: BorderRadius.zero,
          height: 104,
          padding: const EdgeInsets.fromLTRB(6, 0, 6, 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              for (var i = 0; i < MuseumCabinet.itemsPerShelf; i++)
                Expanded(
                  child: i < entries.length
                      ? _CabinetItem(
                          entry: entries[i],
                          onTap: () => onTapEntry(entries[i]),
                        )
                      : const SizedBox.shrink(),
                ),
            ],
          ),
        ),
        const PlankStrip(height: 12),
      ],
    ),
  );
}

class _CabinetItem extends StatelessWidget {
  const _CabinetItem({required this.entry, required this.onTap});

  final MuseumEntry entry;
  final VoidCallback onTap;

  static const _transparent = SurfaceStyle(
    color: Color(0x00000000),
    shadows: [],
  );

  @override
  Widget build(BuildContext context) {
    final l10n = context.localizations;
    final showColor = entry.earned || entry.isNext;
    final label = entry.earned
        ? l10n.museumFamilyLabel(l10n.figurineShortName(entry.figurineId))
        : entry.isNext
        ? l10n.museumSoonLabel(l10n.figurineShortName(entry.figurineId))
        : l10n.winChapter(entry.chapterNumber);
    return TactileSurface(
      style: _transparent,
      radius: BorderRadius.zero,
      onPressed: onTap,
      padding: const EdgeInsets.only(top: 4),
      semanticLabel: label,
      excludeChildSemantics: true,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Opacity(
                opacity: showColor ? 1 : 0.55,
                child: FigurineImage(
                  figurineId: entry.figurineId,
                  locked: !entry.earned,
                ),
              ),
              if (entry.isNext)
                PositionedDirectional(
                  end: -4,
                  top: -6,
                  child: _ProgressChip(done: entry.done, total: entry.total),
                ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyleTokens.cardTitle.copyWith(
              fontSize: 10.5,
              color: showColor
                  ? AppColorTokens.textPrimary
                  : AppColorTokens.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}

/// The next figurine's "N/total" badge (frame 6.1's "15/20" chip).
class _ProgressChip extends StatelessWidget {
  const _ProgressChip({required this.done, required this.total});

  final int done;
  final int total;

  @override
  Widget build(BuildContext context) => NestySurface(
    style: const SurfaceStyle(
      color: AppColorTokens.success,
      shadows: [NestyShadow(color: AppColorTokens.successEdge, dy: 2)],
    ),
    radius: const BorderRadius.all(Radius.circular(8)),
    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
    child: Text(
      context.localizations.homeMuseumProgress(done, total),
      style: AppTextStyleTokens.cardTitle.copyWith(
        fontSize: 10,
        color: AppColorTokens.surfaceWhite,
      ),
    ),
  );
}
