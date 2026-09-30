import 'dart:math' as math;

import 'package:nesty_game/core/common_imports.dart';
import 'package:nesty_game/core/ui/nesty_ui.dart';
import 'package:nesty_game/features/museum/cubit/museum_cubit.dart';
import 'package:nesty_game/features/museum/widgets/figurine_image.dart';

/// The walnut cabinet (frames 6.1, 6.1c; tokens `layout.museum.cabinet`):
/// two columns of niches, one per chapter, five rows for the ten families.
/// A collected family bobs gently under a warm light with a brass plate of
/// its name; the next one wears a green ring and "14 to go"; a locked one is
/// dimmed with its chapter and levels on two lines. Tapping any niche calls
/// [onTapEntry] (the page opens the 6.2/6.3 modal, unchanged).
class MuseumCabinet extends StatelessWidget {
  const MuseumCabinet({
    required this.entries,
    required this.onTapEntry,
    super.key,
  });

  final List<MuseumEntry> entries;
  final ValueChanged<MuseumEntry> onTapEntry;

  static const int columns = MuseumTokens.cabinetColumns;

  @override
  Widget build(BuildContext context) {
    final rows = <List<MuseumEntry>>[
      for (var i = 0; i < entries.length; i += columns)
        entries.sublist(i, math.min(i + columns, entries.length)),
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
      radius: BorderRadius.circular(MuseumTokens.cabinetRadius),
      width: double.infinity,
      padding: const EdgeInsets.all(8),
      child: Column(
        children: [
          for (var r = 0; r < rows.length; r++) ...[
            if (r > 0) const SizedBox(height: MuseumTokens.cabinetGap),
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (var c = 0; c < columns; c++) ...[
                    if (c > 0) const SizedBox(width: MuseumTokens.cabinetGap),
                    Expanded(
                      child: c < rows[r].length
                          ? _Niche(
                              entry: rows[r][c],
                              index: r * columns + c,
                              onTap: () => onTapEntry(rows[r][c]),
                            )
                          : const SizedBox.shrink(),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _Niche extends StatelessWidget {
  const _Niche({required this.entry, required this.index, required this.onTap});

  final MuseumEntry entry;
  final int index;
  final VoidCallback onTap;

  static const double minHeight = 66;

  static const _style = SurfaceStyle(
    gradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Color(0xFF5B3319), Color(0xFF4E2C14)],
    ),
    shadows: [NestyShadow(color: Color(0xFF9A6232), dy: 4)],
  );

  static const _nextStyle = SurfaceStyle(
    gradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Color(0xFF5B3319), Color(0xFF4E2C14)],
    ),
    shadows: [
      NestyShadow(color: AppColorTokens.successRing, inset: true, spread: 2),
      NestyShadow(color: Color(0xFF9A6232), dy: 4),
    ],
  );

  @override
  Widget build(BuildContext context) {
    final l10n = context.localizations;
    final name = l10n.figurineName(entry.figurineId);
    final start = (entry.chapterNumber - 1) * entry.total + 1;
    final end = start + entry.total - 1;
    final toGo = (entry.total - entry.done).clamp(0, entry.total);
    final label = entry.earned
        ? l10n.museumNicheCollectedSemantics(name)
        : entry.isNext
        ? l10n.museumNicheNextSemantics(name, entry.chapterNumber, toGo)
        : l10n.museumNicheLockedSemantics(entry.chapterNumber, start, end);
    final art = FigurineImage(
      figurineId: entry.figurineId,
      locked: !entry.earned,
      size: MuseumTokens.cabinetArt,
    );
    final Widget figure;
    if (entry.earned) {
      figure = _Bob(index: index, child: art);
    } else if (entry.isNext) {
      figure = art;
    } else {
      figure = Opacity(opacity: MuseumTokens.cabinetLockedOpacity, child: art);
    }
    return TactileSurface(
      style: entry.isNext ? _nextStyle : _style,
      radius: BorderRadius.circular(22),
      onPressed: onTap,
      padding: const EdgeInsets.fromLTRB(4, 4, 8, 6),
      semanticLabel: label,
      excludeChildSemantics: true,
      alignment: AlignmentDirectional.centerStart,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: minHeight),
        child: Row(
          children: [
            figure,
            const SizedBox(width: 4),
            Expanded(
              child: _Text(
                entry: entry,
                name: name,
                start: start,
                end: end,
                toGo: toGo,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Text extends StatelessWidget {
  const _Text({
    required this.entry,
    required this.name,
    required this.start,
    required this.end,
    required this.toGo,
  });

  final MuseumEntry entry;
  final String name;
  final int start;
  final int end;
  final int toGo;

  @override
  Widget build(BuildContext context) {
    final l10n = context.localizations;
    if (entry.earned) return _BrassPlate(name);
    if (entry.isNext) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            name,
            style: AppTextStyleTokens.cardTitle.copyWith(
              fontSize: 12,
              height: 1.1,
              color: const Color(0xFFFFFFFF),
            ),
            maxLines: 3,
          ),
          const SizedBox(height: 3),
          // Scales down to the niche instead of cutting ("19 levels to go" at
          // 1.3× text on a 360 dp phone).
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: AlignmentDirectional.centerStart,
            child: NestySurface(
              style: const SurfaceStyle(
                gradient: AppGradientTokens.success,
                shadows: [
                  NestyShadow(color: AppColorTokens.successEdge, dy: 2),
                ],
              ),
              radius: BorderRadius.circular(10),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              child: Text(
                l10n.museumLevelsToGo(toGo),
                style: AppTextStyleTokens.cardTitle.copyWith(
                  fontSize: 11,
                  height: 1.1,
                  color: const Color(0xFFFFFFFF),
                ),
                maxLines: 1,
                softWrap: false,
              ),
            ),
          ),
        ],
      );
    }
    // Locked: two lines, or the one short line when they wouldn't fit
    // (narrow phones or 1.3× text).
    final narrow =
        MediaQuery.sizeOf(context).width < 360 ||
        MediaQuery.textScalerOf(context).scale(1) > 1.15;
    final style = MuseumTokens.cabinetLockedLabel.copyWith(
      height: 1.25,
      color: AppColorTokens.textOnWoodMuted,
    );
    if (narrow) {
      return Text(
        l10n.museumLockedShelfShort(entry.chapterNumber, start, end),
        style: style,
        maxLines: 2,
      );
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.museumLockedLine1(entry.chapterNumber), style: style),
        Text(l10n.museumLockedLine2(start, end), style: style, maxLines: 2),
      ],
    );
  }
}

/// A collected family's brass name plate (`gradient.gold`, Fredoka 700 11.5
/// `#4A3008`), up to three lines, growing rather than cutting.
class _BrassPlate extends StatelessWidget {
  const _BrassPlate(this.name);

  final String name;

  @override
  Widget build(BuildContext context) => NestySurface(
    style: const SurfaceStyle(
      gradient: AppGradientTokens.gold,
      shadows: [
        NestyShadow(color: Color(0x80FFFFFF), inset: true, dy: 1),
        NestyShadow(color: Color(0xFF8A5C12), dy: 2),
      ],
    ),
    radius: BorderRadius.circular(10),
    width: double.infinity,
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
    child: Text(
      name,
      style: MuseumTokens.cabinetNamePlate.copyWith(height: 1.15),
      maxLines: 3,
    ),
  );
}

/// A collected figurine's idle bob (tokens `museum.cabinet.collectedIdle`:
/// 3 dp, a 2.6-3.4 s period varied per niche, phase staggered by [index]).
/// Static under reduce motion.
class _Bob extends StatefulWidget {
  const _Bob({required this.index, required this.child});

  final int index;
  final Widget child;

  @override
  State<_Bob> createState() => _BobState();
}

class _BobState extends State<_Bob> with SingleTickerProviderStateMixin {
  AnimationController? _controller;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (context.reduceMotion) {
      _controller?.dispose();
      _controller = null;
      return;
    }
    if (_controller != null) return;
    // Seeded by the niche's index: the same on every visit and in tests.
    final span =
        MuseumTokens.cabinetCollectedIdleMaxPeriodMs -
        MuseumTokens.cabinetCollectedIdleMinPeriodMs;
    final periodMs =
        MuseumTokens.cabinetCollectedIdleMinPeriodMs +
        (widget.index * 137) % (span + 1);
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: periodMs),
      value: (widget.index * 0.23) % 1,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    if (controller == null) return widget.child;
    return AnimatedBuilder(
      animation: controller,
      child: widget.child,
      builder: (context, child) => Transform.translate(
        offset: Offset(
          0,
          -MuseumTokens.cabinetCollectedIdleBob *
              Curves.easeInOut.transform(controller.value),
        ),
        child: child,
      ),
    );
  }
}
