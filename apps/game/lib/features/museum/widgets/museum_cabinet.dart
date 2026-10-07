import 'dart:math' as math;

import 'package:nesty_game/core/common_imports.dart';
import 'package:nesty_game/core/ui/nesty_ui.dart';
import 'package:nesty_game/features/museum/cubit/museum_cubit.dart';
import 'package:nesty_game/features/museum/widgets/figurine_image.dart';
import 'package:nesty_game/features/museum/widgets/museum_idle_figurine.dart';

/// The walnut cabinet (frames 6.1, 6.1c; tokens `layout.museum.cabinet`):
/// two columns of niches, one per chapter, five rows for the ten families.
/// A collected family idles under a warm light (`ui_museum_idle`) with a
/// brass plate of its name; the next one wears a green ring and "14 to go"; a locked one is
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
          colors: [
            AppColorTokens.walnutCabinetTop,
            AppColorTokens.walnutCabinetBottom,
          ],
        ),
        shadows: AppShadowTokens.cabinet,
      ),
      radius: BorderRadius.circular(MuseumTokens.cabinetRadius),
      width: double.infinity,
      // `layout.museum.cabinet.height` 402 = 5 rows of 72 + 4 gaps of 6 + 2 x 9.
      padding: const EdgeInsets.all(9),
      child: LayoutBuilder(
        builder: (context, box) {
          // The niche's name column: the niche (a share of the width, less
          // the gaps) minus its padding, art and gap. IntrinsicHeight below
          // can't hold a LayoutBuilder, so the names are told this width.
          final niche =
              (box.maxWidth - MuseumTokens.cabinetGap * (columns - 1)) /
              columns;
          // Large text on a phone gives the figurine less of the niche so a
          // long family name keeps a column to wrap in (l10n overflow, M7
          // 5B): a 48 dp figurine instead of 62.
          final art = MediaQuery.textScalerOf(context).scale(1) > 1.15
              ? _Niche.largeTextArt
              : MuseumTokens.cabinetArt;
          final nameWidth = math.max(0.0, niche - 4 - 8 - art - 6);
          return Column(
            children: [
              for (var r = 0; r < rows.length; r++) ...[
                if (r > 0) const SizedBox(height: MuseumTokens.cabinetGap),
                IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (var c = 0; c < columns; c++) ...[
                        if (c > 0)
                          const SizedBox(width: MuseumTokens.cabinetGap),
                        Expanded(
                          child: c < rows[r].length
                              ? _Niche(
                                  entry: rows[r][c],
                                  index: r * columns + c,
                                  nameWidth: nameWidth,
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
          );
        },
      ),
    );
  }
}

class _Niche extends StatelessWidget {
  const _Niche({
    required this.entry,
    required this.index,
    required this.nameWidth,
    required this.onTap,
  });

  /// The width of the name column (see [MuseumCabinet.build]).
  final double nameWidth;

  final MuseumEntry entry;
  final int index;
  final VoidCallback onTap;

  // Row pitch 78 in frame 6.1: a 72 dp niche = 4 + 62 art + 6.
  static const double minHeight = MuseumTokens.cabinetArt;

  /// The figurine's size under large text (see [MuseumCabinet.build]).
  static const double largeTextArt = 48;

  // NestyHub:116-118: a collected niche's face has a warm light over its
  // gradient (drawn in the child), a locked one is darker; the next one wears
  // a 2 dp green ring.
  static const _earnedStyle = SurfaceStyle(
    gradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [AppColorTokens.shelfFaceTop, AppColorTokens.shelfFaceBottom],
    ),
    shadows: _nicheShadows,
  );

  static const _lockedStyle = SurfaceStyle(
    gradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        AppColorTokens.shelfFaceLockedTop,
        AppColorTokens.shelfFaceLockedBottom,
      ],
    ),
    shadows: _nicheShadows,
  );

  static const _nextStyle = SurfaceStyle(
    gradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        AppColorTokens.shelfFaceLockedTop,
        AppColorTokens.shelfFaceLockedBottom,
      ],
    ),
    shadows: [
      ..._nicheShadows,
      NestyShadow(color: AppColorTokens.museumNextRing, spread: 2),
    ],
  );

  /// `inset 0 3px 8px rgba(0,0,0,.35), inset 0 -5px 0 #A56A34`.
  static const _nicheShadows = [
    NestyShadow(color: AppColorTokens.shelfShadow, inset: true, dy: 3, blur: 8),
    NestyShadow(color: AppColorTokens.shelfLip, inset: true, dy: -5),
  ];

  /// A collected niche's warm light: `radial-gradient(ellipse 70% 80% at 30%
  /// 0, rgba(255,226,160,.5), 0 at 70%)`.
  static const _light = RadialGradient(
    center: Alignment(-0.4, -1),
    radius: 0.8,
    colors: [AppColorTokens.shelfLight, Color(0x00FFE2A0)],
    stops: [0, 0.7],
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
        ? l10n.museumNicheNextSemantics(name, toGo)
        : l10n.museumNicheLockedSemantics(name, entry.chapterNumber);
    final art = FigurineImage(
      figurineId: entry.figurineId,
      locked: !entry.earned,
      size: MuseumTokens.cabinetArt,
    );
    final Widget figure;
    if (entry.earned) {
      // `ui_museum_idle` (m7-4 J.2): a random start frame per niche, frame 0
      // under reduce motion; the still art while the file isn't ready.
      figure = MuseumIdleFigurine(figurineId: entry.figurineId);
    } else if (entry.isNext) {
      figure = art;
    } else {
      figure = Opacity(opacity: MuseumTokens.cabinetLockedOpacity, child: art);
    }
    final shrink = MediaQuery.textScalerOf(context).scale(1) > 1.15;
    final shownFigure = shrink
        ? SizedBox.square(
            dimension: largeTextArt,
            child: FittedBox(
              child: SizedBox.square(
                dimension: MuseumTokens.cabinetArt,
                child: figure,
              ),
            ),
          )
        : figure;
    return TactileSurface(
      style: entry.earned
          ? _earnedStyle
          : entry.isNext
          ? _nextStyle
          : _lockedStyle,
      radius: BorderRadius.circular(16),
      onPressed: onTap,
      padding: EdgeInsets.zero,
      semanticLabel: label,
      excludeChildSemantics: true,
      alignment: AlignmentDirectional.centerStart,
      child: _Light(
        on: entry.earned,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(4, 4, 8, 6),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: minHeight),
            child: Row(
              children: [
                shownFigure,
                const SizedBox(width: 6),
                Expanded(
                  child: _Text(
                    entry: entry,
                    name: name,
                    start: start,
                    end: end,
                    toGo: toGo,
                    nameWidth: nameWidth,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// A collected niche's warm light under its content ([on]); nothing for the
/// others. Clipped to the niche's corners.
class _Light extends StatelessWidget {
  const _Light({required this.on, required this.child});

  final bool on;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (!on) return child;
    // The niche aligns its content loosely, so the light asks for the whole
    // niche (an expanding box; a LayoutBuilder would break the row's
    // IntrinsicHeight) and not only the content's height.
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: SizedBox.expand(
        child: DecoratedBox(
          decoration: const BoxDecoration(gradient: _Niche._light),
          child: Align(
            alignment: AlignmentDirectional.centerStart,
            child: child,
          ),
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
    required this.nameWidth,
  });

  final double nameWidth;

  final MuseumEntry entry;
  final String name;
  final int start;
  final int end;
  final int toGo;

  @override
  Widget build(BuildContext context) {
    final l10n = context.localizations;
    if (entry.earned) return _BrassPlate(name, width: nameWidth - 16);
    if (entry.isNext) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Wraps to 3 lines, then scales to 0.75× (textFit): a long family
          // name in a 56 dp column is never cut.
          ShrinkToFitText(
            name,
            style: MuseumTypeTokens.nextName,
            maxLines: 3,
            minFontScale: 0.75,
            textAlign: TextAlign.start,
            fixedWidth: nameWidth,
          ),
          const SizedBox(height: 3),
          // Scales down to the niche instead of cutting ("19 to go" at
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
                l10n.museumNextChip(toGo),
                style: AppTextStyleTokens.cardTitle.copyWith(
                  fontSize: 10.5,
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
  const _BrassPlate(this.name, {required this.width});

  final String name;

  /// The name's width inside the plate's padding.
  final double width;

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
    child: ShrinkToFitText(
      name,
      style: MuseumTypeTokens.plateName,
      maxLines: 3,
      minFontScale: 0.75,
      textAlign: TextAlign.start,
      fixedWidth: width,
    ),
  );
}
