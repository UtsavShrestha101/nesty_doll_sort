import 'dart:math' as math;

import 'package:intl/intl.dart';
import 'package:nesty_game/core/common_imports.dart';
import 'package:nesty_game/core/services/clock/local_date.dart';
import 'package:nesty_game/core/ui/nesty_ui.dart';
import 'package:nesty_game/core/ui/theme/locale_script.dart';
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

  /// Opens the modal for [chapterId] as a dialog on the root navigator (like
  /// `LevelCard.show`), so the scrim covers the whole screen, the safe bands
  /// and the shell's bottom nav included (frame 6.2).
  ///
  /// The dialog's own route has no [MuseumCubit] above it, so [cubit] is
  /// passed in: a save change while the modal is open (a win completing its
  /// chapter) still reaches it. [onPlay] gets the latest state once the
  /// dialog has closed.
  static Future<void> show(
    BuildContext context, {
    required MuseumCubit cubit,
    required String chapterId,
    required ValueChanged<MuseumState> onPlay,
  }) {
    final reduce = context.reduceMotion;
    return showGeneralDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierLabel: context.localizations.closeSemantics,
      barrierColor: AppColorTokens.scrim,
      transitionDuration: Duration(milliseconds: reduce ? 120 : 240),
      transitionBuilder: (context, animation, _, child) => FadeTransition(
        opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
        child: reduce
            ? child
            : ScaleTransition(
                scale: Tween(begin: 0.96, end: 1.0).animate(
                  CurvedAnimation(parent: animation, curve: Curves.easeOut),
                ),
                child: child,
              ),
      ),
      // A general dialog's page has no Material above it: a transparent one
      // gives the text the app's defaults and paints nothing.
      pageBuilder: (dialogContext, _, _) => Material(
        type: MaterialType.transparency,
        child: BlocBuilder<MuseumCubit, AsyncValue<MuseumState>>(
          bloc: cubit,
          builder: (context, value) {
            final state = value.data;
            if (state == null) return const SizedBox.shrink();
            for (final entry in state.entries) {
              if (entry.chapterId != chapterId) continue;
              return FigurineModal(
                entry: entry,
                homeLevelNumber: state.homeLevelNumber,
                onClose: () => Navigator.of(dialogContext).pop(),
                onPlay: () {
                  Navigator.of(dialogContext).pop();
                  onPlay(state);
                },
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  /// The card's top under the safe area (frame 6.2: 128 - 59).
  static const double _frameTop = 69;

  /// [_frameTop], or half the slack on a screen too short for the card at
  /// its smallest (spotlight 200 + 330 at 1.0x text), so it never overflows.
  static double _inset(BuildContext context) {
    final media = MediaQuery.of(context);
    final smallest =
        _Spotlight._minHeight + 330 * math.max(1, media.textScaler.scale(1));
    final slack = media.size.height - media.padding.vertical - smallest;
    return math.max(0, math.min(_frameTop, slack / 2));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.localizations;
    final earned = entry.earned;
    final flavor = l10n.figurineFlavor(entry.figurineId);
    // Over the cabinet, whose shelves can't be reached while it is up
    // (review R11); the figurine's name names it.
    return ModalSemanticsScope(
      child: Stack(
        fit: StackFit.expand,
        children: [
          // The scrim is the dialog route's barrier (see [show]).
          Align(
            alignment: Alignment.topCenter,
            child: Padding(
              // The card hangs from the top, as frame 6.2 draws it (top 128
              // on the 844 frame, 59 of that the status bar): 69 dp under
              // the safe area, less on a short phone so it still fits.
              padding: EdgeInsets.fromLTRB(
                22,
                MediaQuery.paddingOf(context).top + _inset(context),
                22,
                0,
              ),
              child: ModalCard(
                onClose: onClose,
                closeSemanticLabel: l10n.closeSemantics,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _Spotlight(entry: entry, inset: _inset(context)),
                    const SizedBox(height: 16),
                    Semantics(
                      header: true,
                      namesRoute: true,
                      child: Text(
                        l10n.figurineName(entry.figurineId),
                        textAlign: TextAlign.center,
                        style: AppTextStyleTokens.h2,
                      ),
                    ),
                    if (earned && flavor.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        flavor,
                        textAlign: TextAlign.center,
                        style: context.scriptStyle(
                          AppTextStyleTokens.body.copyWith(
                            fontStyle: FontStyle.italic,
                            color: AppColorTokens.iconBrown,
                          ),
                          role: ScriptTextRole.body,
                        ),
                      ),
                    ],
                    if (!earned) ...[
                      const SizedBox(height: 8),
                      Text(
                        l10n.museumLockedText(entry.chapterNumber),
                        textAlign: TextAlign.center,
                        style: context.scriptStyle(
                          AppTextStyleTokens.body.copyWith(
                            color: AppColorTokens.iconBrown,
                          ),
                          role: ScriptTextRole.body,
                        ),
                      ),
                    ],
                    const SizedBox(height: 14),
                    if (earned)
                      Center(
                        child: _CollectedChip(collectedOn: entry.collectedOn),
                      )
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
      ),
    );
  }
}

class _Spotlight extends StatelessWidget {
  const _Spotlight({required this.entry, required this.inset});

  final MuseumEntry entry;

  /// The card's gap under the safe area, which the panel gives back.
  final double inset;

  /// The art panel (`layout.museumDetail.spotlight`: 300 tall, or 200 on a
  /// phone under 760 dp, radius 24); a big text size still gives some of it
  /// back so the card fits (the figurine shrinks with it).
  static const double _height = MuseumDetailTokens.spotlightHeight;
  static const double _minHeight = MuseumDetailTokens.spotlightHeightShort;
  static const double _artMax = 272;

  @override
  Widget build(BuildContext context) {
    final earned = entry.earned;
    // The card (title, text, chip or bar and button) takes about 330 dp at
    // 1.0x text; what is left of the screen is the panel's.
    final media = MediaQuery.of(context);
    final room =
        media.size.height -
        media.padding.vertical -
        inset -
        330 * math.max(1, media.textScaler.scale(1));
    return SizedBox(
      height: math.min(
        media.size.height < MuseumDetailTokens.spotlightShortBelow
            ? _minHeight
            : _height,
        math.max(room, _minHeight),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final art = math.min(
            _artMax,
            math.min(constraints.maxWidth - 32, constraints.maxHeight - 28),
          );
          return ClipRRect(
            borderRadius: const BorderRadius.all(
              Radius.circular(MuseumDetailTokens.spotlightPanelRadius),
            ),
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
                  // The spotlight's cone (NestyShop:110), under the figurine.
                  Positioned(
                    top: SpotlightConePainter.top,
                    left: 0,
                    right: 0,
                    height: SpotlightConePainter.height,
                    child: ExcludeSemantics(
                      child: Align(
                        alignment: Alignment.topCenter,
                        child: CustomPaint(
                          size: const Size(
                            SpotlightConePainter.width,
                            SpotlightConePainter.height,
                          ),
                          painter: SpotlightConePainter.shared,
                        ),
                      ),
                    ),
                  ),
                  // The art sits 6 dp above the panel's bottom (272 at top 22
                  // in the 300 panel, NestyShop:111).
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 6,
                    child: Center(
                      // The heading under the art names the figurine, so a
                      // reader hears it once (semantics tour: no label twice
                      // in a row).
                      child: ExcludeSemantics(
                        child: FigurineImage(
                          figurineId: entry.figurineId,
                          locked: !earned,
                          size: art,
                        ),
                      ),
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
            color: AppColorTokens.textBrown,
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
        // Frame 6.2: about 147 x 32, radius 16.
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              NestyIcons.checkCircle,
              size: 20,
              color: AppColorTokens.successEdge,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: AppTextStyleTokens.cardTitle.copyWith(
                fontSize: 15,
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
                color: AppColorTokens.textBrown,
              ),
            ),
            Text(
              l10n.homeMuseumProgress(entry.done, entry.total),
              style: AppTextStyleTokens.cardTitle.copyWith(
                fontSize: 13,
                color: AppColorTokens.textBrown,
              ),
            ),
          ],
        ),
        const SizedBox(height: 7),
        // Named, so it isn't a bare percent (review R37).
        NestyProgressBar(
          value: entry.total == 0 ? 0 : entry.done / entry.total,
          height: 16,
          semanticLabel: l10n.winChapter(entry.chapterNumber),
        ),
      ],
    );
  }
}

/// The modal's spotlight cone (`layout.museumDetail.spotlight.cone`, drawn in
/// code): 250×320, white at 55 % fading to 0 down the box, clipped to
/// `polygon(38% 0, 62% 0, 100% 100%, 0 100%)`, 10 dp above the panel's top.
/// The path and the paint are built once, never per frame (rule 8).
class SpotlightConePainter extends CustomPainter {
  SpotlightConePainter._();

  /// The one instance every modal shares.
  static final shared = SpotlightConePainter._();

  static const double width = MuseumDetailTokens.spotlightConeWidth;
  static const double height = MuseumDetailTokens.spotlightConeHeight;

  /// The cone's top, relative to the spotlight's.
  static const double top = MuseumDetailTokens.spotlightConeTop;

  /// The trapezoid, in the cone's own box.
  static final Path path = Path()
    ..moveTo(width * MuseumDetailTokens.spotlightConeTopLeft, 0)
    ..lineTo(width * MuseumDetailTokens.spotlightConeTopRight, 0)
    ..lineTo(width, height)
    ..lineTo(0, height)
    ..close();

  static final Paint _paint = Paint()
    ..shader = MuseumDetailTokens.spotlightConeFill.createShader(
      const Rect.fromLTWH(0, 0, width, height),
    );

  @override
  void paint(Canvas canvas, Size size) => canvas.drawPath(path, _paint);

  @override
  bool shouldRepaint(SpotlightConePainter oldDelegate) => false;
}
