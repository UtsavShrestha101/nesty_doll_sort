import 'dart:async';

import 'package:nesty_game/core/common_imports.dart';
import 'package:nesty_game/core/models/play_request.dart';
import 'package:nesty_game/core/ui/art/theme_thumbnail_loader.dart';
import 'package:nesty_game/core/ui/nesty_ui.dart';
import 'package:nesty_game/core/ui/widgets/home/stars_chip.dart';
import 'package:nesty_game/features/chapters/cubit/chapters_cubit.dart';
import 'package:nesty_game/features/chapters/widgets/chapter_level_cell.dart';
import 'package:nesty_game/features/chapters/widgets/level_card.dart';
import 'package:nesty_game/features/museum/widgets/figurine_image.dart';
import 'package:nesty_render/nesty_render.dart' show ChapterTheme;

/// One chapter on the Chapters screen (frames 10.4, 11.5; menus spec 3):
/// a **folded row** (a finished or a locked chapter: its theme crop, kicker,
/// name, doll family and star total) or, [expanded], the **open card** (the
/// theme header, the family row and the 5-column level grid).
///
/// Only one card is open at a time and the page owns which ([expanded],
/// [onToggle]): the current chapter opens by default, a tap on a finished row
/// opens it in place. A locked row is inert (a disabled node, no tap).
class ChapterSectionCard extends StatelessWidget {
  const ChapterSectionCard({
    required this.section,
    required this.expanded,
    required this.onToggle,
    required this.onPlay,
    super.key,
  });

  final ChapterSection section;
  final bool expanded;
  final VoidCallback onToggle;

  /// A tapped cell's or the level card's request.
  final ValueChanged<PlayRequest> onPlay;

  @override
  Widget build(BuildContext context) {
    if (!section.reached) return _LockedRow(section: section);
    if (expanded) {
      return _OpenCard(section: section, onToggle: onToggle, onPlay: onPlay);
    }
    return _FoldedRow(section: section, onTap: onToggle);
  }
}

const _rowStyle = SurfaceStyle(
  color: AppColorTokens.surfaceWhite,
  shadows: [
    NestyShadow(color: Color(0xFFFFFFFF), inset: true, dy: 2),
    NestyShadow(color: AppColorTokens.surfaceEdge, dy: 5),
  ],
);

const _lockedStyle = SurfaceStyle(
  color: AppColorTokens.surfaceSunk,
  shadows: [NestyShadow(color: AppColorTokens.surfaceEdge, dy: 3)],
);

ChapterTheme _themeOf(ChapterSection section) =>
    ChapterTheme.byId(section.themeId) ??
    ChapterTheme.byId(section.chapterId) ??
    ChapterTheme.ch01;

/// The kicker under which every row and header reads "CHAPTER 4 · LEVELS
/// 61–80"; a row allows two lines, never an ellipsis.
///
/// The level range never splits: a line may break after an en dash, so a
/// narrow row read "LEVELS 181–" over "200" (the phase-4 device run,
/// 2026-09-30) where frame 10.4 wraps before the range. Word joiners
/// (U+2060, zero width) on both sides of the dash keep it whole.
String _kicker(AppLocalizations l10n, ChapterSection section) => l10n
    .chaptersKicker(section.number, section.firstLevel, section.lastLevel)
    .replaceAll('–', kickerRangeDash);

/// The kicker's en dash between two word joiners (see [_kicker]).
@visibleForTesting
const String kickerRangeDash = '\u2060–\u2060';

class _FoldedRow extends StatelessWidget {
  const _FoldedRow({required this.section, required this.onTap});

  final ChapterSection section;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.localizations;
    final name = l10n.chapterName(section.chapterId);
    final label = l10n.chaptersRowSemantics(
      section.number,
      name,
      section.firstLevel,
      section.lastLevel,
      section.stars,
      section.starsPossible,
    );
    return Semantics(
      expanded: false,
      child: TactileSurface(
        style: _rowStyle,
        radius: BorderRadius.circular(ChaptersTokens.foldedRowRadius),
        onPressed: onTap,
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(8, 7, 10, 7),
        semanticLabel: label,
        semanticValue: null,
        excludeChildSemantics: true,
        alignment: AlignmentDirectional.centerStart,
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            minHeight:
                ChaptersTokens.foldedRowHeight - 14, // 56 with the padding
          ),
          child: Row(
            children: [
              _Thumb(theme: _themeOf(section)),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _kicker(l10n, section),
                      style: _kickerStyle,
                      maxLines: 3,
                    ),
                    ShrinkToFitText(
                      l10n.chapterName(section.chapterId),
                      maxLines: 2,
                      minFontScale: 0.75,
                      textAlign: TextAlign.start,
                      style: AppTextStyleTokens.cardTitle.copyWith(
                        fontSize: 19,
                        height: 1.1,
                        color: AppColorTokens.textPrimary,
                      ),
                    ),
                    if (section.perfect)
                      Text(
                        l10n.chaptersAllThreeStars,
                        style: AppTextStyleTokens.caption.copyWith(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColorTokens.successEdge,
                        ),
                        maxLines: 3,
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              if (section.figurineId.isNotEmpty && _roomForFamily(context)) ...[
                FigurineImage(
                  figurineId: section.figurineId,
                  locked: !section.figurineEarned,
                  size: ChaptersTokens.foldedRowFigurine.height,
                ),
                const SizedBox(width: 8),
              ],
              StarsChip(
                earned: section.stars,
                total: section.starsPossible,
                perfect: section.perfect,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Whether a row has room for the doll family beside its text: frame 10.4
/// draws it at 390 dp. On a narrower phone, or at 1.3× text, the text takes
/// the room instead, so it wraps and never cuts (the shared rule); the
/// family is on the open card's own row either way.
bool _roomForFamily(BuildContext context) =>
    MediaQuery.sizeOf(context).width >= 380 &&
    MediaQuery.textScalerOf(context).scale(1) < 1.15;

final _kickerStyle = AppTextStyleTokens.caption.copyWith(
  fontSize: 11,
  fontWeight: FontWeight.w800,
  letterSpacing: 11 * 0.06,
  height: 1.15,
  color: AppColorTokens.textSecondary,
);

/// A locked chapter: the sunk surface, the theme crop greyed, the family
/// silhouette at half strength and a lock (frame 10.4). Inert.
class _LockedRow extends StatelessWidget {
  const _LockedRow({required this.section});

  final ChapterSection section;

  @override
  Widget build(BuildContext context) {
    final l10n = context.localizations;
    final name = l10n.chapterName(section.chapterId);
    return Semantics(
      container: true,
      enabled: false,
      label: l10n.chaptersRowLockedSemantics(
        section.number,
        name,
        section.firstLevel,
        section.lastLevel,
      ),
      excludeSemantics: true,
      child: NestySurface(
        style: _lockedStyle,
        radius: BorderRadius.circular(ChaptersTokens.foldedRowRadius),
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(8, 7, 12, 7),
        alignment: AlignmentDirectional.centerStart,
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            minHeight: ChaptersTokens.foldedRowHeight - 14,
          ),
          child: Row(
            children: [
              _Thumb(theme: _themeOf(section), locked: true),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _kicker(l10n, section),
                      style: _kickerStyle,
                      maxLines: 3,
                    ),
                    ShrinkToFitText(
                      name,
                      maxLines: 2,
                      minFontScale: 0.75,
                      textAlign: TextAlign.start,
                      style: AppTextStyleTokens.cardTitle.copyWith(
                        fontSize: 19,
                        height: 1.1,
                        // Frame: #8A6A4E, nearest token `textMuted`
                        // (`TODO(design)`, menus spec §11 gap 9).
                        color: AppColorTokens.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              if (section.figurineId.isNotEmpty && _roomForFamily(context))
                Opacity(
                  opacity: 0.5,
                  child: FigurineImage(
                    figurineId: section.figurineId,
                    locked: true,
                    size: ChaptersTokens.foldedRowFigurine.height,
                  ),
                ),
              const SizedBox(width: 10),
              const Icon(
                NestyIcons.lock,
                size: 18,
                color: AppColorTokens.textMuted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A theme crop at the row's 84×42, radius 12, with the frame's faint white
/// inset line.
class _Thumb extends StatelessWidget {
  const _Thumb({required this.theme, this.locked = false});

  final ChapterTheme theme;
  final bool locked;

  @override
  Widget build(BuildContext context) => Stack(
    children: [
      ThemeThumbnail(
        theme: theme,
        size: ChaptersTokens.foldedRowThumb,
        locked: locked,
      ),
      Positioned.fill(
        child: IgnorePointer(
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0x8CFFFFFF), width: 2),
            ),
          ),
        ),
      ),
    ],
  );
}

/// The open chapter (frame 10.4): a 3 dp ring in its palette's `accentTop`,
/// the theme header (a crop clipped to 92 with the scrim, the kicker and the
/// name in `onAccent`), the doll family with its progress and star total,
/// and the level grid.
class _OpenCard extends StatelessWidget {
  const _OpenCard({
    required this.section,
    required this.onToggle,
    required this.onPlay,
  });

  final ChapterSection section;
  final VoidCallback onToggle;
  final ValueChanged<PlayRequest> onPlay;

  static const double _radius = 26;

  @override
  Widget build(BuildContext context) {
    final l10n = context.localizations;
    final theme = _themeOf(section);
    final palette = theme.palette;
    final name = l10n.chapterName(section.chapterId);
    final style = SurfaceStyle(
      color: AppColorTokens.surfaceWhite,
      shadows: [
        const NestyShadow(color: AppColorTokens.surfaceEdge, dy: 5),
        NestyShadow(
          color: palette.accentTop,
          spread: ChaptersTokens.currentRingWidth,
        ),
      ],
    );
    final levelsToGo = section.total - section.won;
    return NestySurface(
      style: style,
      radius: BorderRadius.circular(_radius),
      width: double.infinity,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(_radius),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _Header(
              section: section,
              theme: theme,
              name: name,
              onToggle: onToggle,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      if (section.figurineId.isNotEmpty) ...[
                        FigurineImage(
                          figurineId: section.figurineId,
                          locked: !section.figurineEarned,
                          size: ChaptersTokens.foldedRowFigurine.height,
                        ),
                        const SizedBox(width: 10),
                      ],
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (section.figurineId.isNotEmpty)
                              ShrinkToFitText(
                                l10n.figurineName(section.figurineId),
                                maxLines: 2,
                                minFontScale: 0.7,
                                textAlign: TextAlign.start,
                                style: AppTextStyleTokens.cardTitle.copyWith(
                                  fontSize: 20,
                                  height: 1.1,
                                  color: AppColorTokens.textPrimary,
                                ),
                              ),
                            const SizedBox(height: 6),
                            _AccentBar(
                              value: section.total == 0
                                  ? 0
                                  : section.won / section.total,
                              colorTop: palette.accentTop,
                              color: palette.accent,
                              semanticLabel: l10n.winChapterProgress(
                                section.won,
                                section.total,
                              ),
                            ),
                            if (levelsToGo > 0) ...[
                              const SizedBox(height: 3),
                              Align(
                                alignment: AlignmentDirectional.centerEnd,
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    l10n.museumLevelsToGo(levelsToGo),
                                    style: AppTextStyleTokens.caption.copyWith(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: AppColorTokens.textSecondary,
                                    ),
                                    maxLines: 1,
                                    softWrap: false,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      StarsChip(
                        earned: section.stars,
                        total: section.starsPossible,
                        perfect: section.perfect,
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  NestyGrid(
                    columns: ChaptersTokens.currentGridColumns,
                    wideColumns: ChaptersTokens.currentGridColumns,
                    spacing: ChaptersTokens.currentGridGap,
                    runSpacing: ChaptersTokens.currentGridGap,
                    children: [
                      for (final level in section.levels)
                        ChapterLevelCell(
                          level: level,
                          onTap: switch (level.status) {
                            ChapterLevelStatus.locked => null,
                            ChapterLevelStatus.current => () => onPlay(
                              level.request!,
                            ),
                            ChapterLevelStatus.won => () => unawaited(
                              LevelCard.show(
                                context,
                                level: level,
                                onPlay: onPlay,
                              ),
                            ),
                          },
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The open card's header: the theme crop (358 wide, clipped to 92), the
/// scrim, and the kicker and name in `onAccent`. A tap folds the card.
class _Header extends StatelessWidget {
  const _Header({
    required this.section,
    required this.theme,
    required this.name,
    required this.onToggle,
  });

  final ChapterSection section;
  final ChapterTheme theme;
  final String name;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final l10n = context.localizations;
    final palette = theme.palette;
    final label = l10n.chaptersRowSemantics(
      section.number,
      name,
      section.firstLevel,
      section.lastLevel,
      section.stars,
      section.starsPossible,
    );
    return Semantics(
      container: true,
      button: true,
      expanded: true,
      label: label,
      onTap: onToggle,
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onToggle,
        child: SizedBox(
          height: ChaptersTokens.currentHeaderHeight,
          child: Stack(
            fit: StackFit.expand,
            children: [
              LayoutBuilder(
                builder: (context, constraints) => OverflowBox(
                  alignment: Alignment.topLeft,
                  minWidth: 0,
                  maxWidth: constraints.maxWidth,
                  minHeight: 0,
                  maxHeight: ChaptersTokens.currentHeaderHeight,
                  child: ThemeThumbnail(
                    theme: theme,
                    radius: 0,
                    size: Size(
                      constraints.maxWidth,
                      ChaptersTokens.currentHeaderHeight,
                    ),
                  ),
                ),
              ),
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: ChaptersTokens.currentHeaderScrim,
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                child: Align(
                  alignment: AlignmentDirectional.bottomStart,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ShrinkToFitText(
                        _kicker(l10n, section),
                        maxLines: 1,
                        minFontScale: 0.7,
                        textAlign: TextAlign.start,
                        style: AppTextStyleTokens.cardTitle.copyWith(
                          fontSize: 13,
                          letterSpacing: 13 * 0.06,
                          color: palette.onAccent,
                        ),
                      ),
                      ShrinkToFitText(
                        name,
                        maxLines: 1,
                        minFontScale: 0.6,
                        textAlign: TextAlign.start,
                        style: AppTextStyleTokens.cardTitle.copyWith(
                          fontSize: 28,
                          height: 1.1,
                          color: palette.onAccent,
                          shadows: [
                            Shadow(
                              color: palette.accentEdge,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The open chapter's own progress bar in its palette (a 10 dp track and a
/// gradient fill), drawn here instead of adding a colour parameter to the
/// shared `NestyProgressBar`.
class _AccentBar extends StatelessWidget {
  const _AccentBar({
    required this.value,
    required this.colorTop,
    required this.color,
    required this.semanticLabel,
  });

  final double value;
  final Color colorTop;
  final Color color;
  final String semanticLabel;

  static const double _height = 10;

  @override
  Widget build(BuildContext context) {
    final fraction = value.clamp(0.0, 1.0);
    return Semantics(
      label: semanticLabel,
      value: context.localizations.progressPercent(fraction),
      excludeSemantics: true,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(_height / 2),
        // The full width of its column, and a track and a fill that fill
        // the height: in a start-aligned Column a bare height left the
        // track 0 wide and the fill 0 tall, so no bar showed at all (the
        // phase-4 device run, 2026-09-30).
        child: SizedBox(
          height: _height,
          width: double.infinity,
          child: Stack(
            children: [
              const Positioned.fill(
                child: ColoredBox(color: AppColorTokens.surfaceTrack),
              ),
              FractionallySizedBox(
                widthFactor: fraction,
                heightFactor: 1,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [colorTop, color],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
