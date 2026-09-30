import 'package:nesty_game/core/common_imports.dart';
import 'package:nesty_game/core/models/play_request.dart';
import 'package:nesty_game/core/ui/nesty_ui.dart';
import 'package:nesty_game/features/chapters/cubit/chapters_cubit.dart';

/// The level card (frame 10.4b; menus spec 3): what a tap on a won level in
/// Chapters opens. A `ModalCard` with the "Level 62" ribbon and a close disc:
/// the stars (40/48/40), "3 stars at 15 moves or fewer", the "Best 16" chip
/// and Play, which replays the level (no coins, and the win card says why).
///
/// A level already at 3 stars has no target line, and one won before best
/// moves were kept has no "Best" chip. Nothing here decides a rule: the
/// stars, the best and the target come from the cubit (core's star rule and
/// the save), and Play is `ChapterLevel.request`.
class LevelCard extends StatelessWidget {
  const LevelCard({
    required this.level,
    required this.onPlay,
    required this.onClose,
    super.key,
  });

  final ChapterLevel level;

  /// Play was tapped (the caller closes the card first).
  final VoidCallback onPlay;
  final VoidCallback onClose;

  /// Opens the card over [context]. [onPlay] runs with the level's request
  /// after the card has closed; the close disc, the scrim and system back
  /// only close it.
  static Future<void> show(
    BuildContext context, {
    required ChapterLevel level,
    required ValueChanged<PlayRequest> onPlay,
  }) {
    final request = level.request;
    if (request == null) return Future<void>.value();
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
      // A general dialog's page has no Material above it, so its text wore
      // the no-Material yellow double underline on a device (the phase-4
      // device run, 2026-09-30). A transparent Material gives it the app's
      // text defaults and paints nothing itself.
      pageBuilder: (dialogContext, _, _) => Material(
        type: MaterialType.transparency,
        child: LevelCard(
          level: level,
          onClose: () => Navigator.of(dialogContext).pop(),
          onPlay: () {
            Navigator.of(dialogContext).pop();
            onPlay(request);
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.localizations;
    final stars = (level.stars ?? 0).clamp(0, 3);
    final target = level.target;
    final best = level.bestMoves;
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
        child: Semantics(
          scopesRoute: true,
          explicitChildNodes: true,
          child: ModalCard(
            title: l10n.levelTitle(level.order),
            onClose: onClose,
            closeSemanticLabel: l10n.closeSemantics,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (level.stars != null) ...[
                  _Stars(count: stars),
                  const SizedBox(height: 12),
                ],
                if (target != null && stars < 3) ...[
                  Text(
                    l10n.winStarsTarget(target),
                    textAlign: TextAlign.center,
                    style: AppTextStyleTokens.body.copyWith(
                      fontSize: 17,
                      color: AppColorTokens.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 14),
                ],
                if (best != null) ...[
                  _BestChip(best: best),
                  const SizedBox(height: 18),
                ],
                TactileButton(
                  label: l10n.chaptersLevelPlay,
                  size: TactileButtonSize.medium,
                  onPressed: onPlay,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// The level's stars, 40 / 48 / 40 (frame 10.4b): earned ones are the filled
/// art, the rest the empty outline, never grey.
class _Stars extends StatelessWidget {
  const _Stars({required this.count});

  final int count;

  static const _sizes = [40.0, 48.0, 40.0];

  @override
  Widget build(BuildContext context) => Semantics(
    label: context.localizations.starsSemantics(count),
    excludeSemantics: true,
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        for (var i = 0; i < 3; i++) ...[
          if (i > 0) const SizedBox(width: 6),
          UiArtImage.square(
            i < count ? UiArt.starFilled : UiArt.starEmpty,
            extent: _sizes[i],
          ),
        ],
      ],
    ),
  );
}

/// "Best 16" with the `route` glyph on a 44 tall white pill (frame 10.4b).
class _BestChip extends StatelessWidget {
  const _BestChip({required this.best});

  final int best;

  static const _style = SurfaceStyle(
    color: AppColorTokens.surfaceWhite,
    shadows: [NestyShadow(color: AppColorTokens.surfaceEdge, dy: 4)],
  );

  @override
  Widget build(BuildContext context) => NestySurface(
    style: _style,
    radius: BorderRadius.circular(22),
    height: 44,
    padding: const EdgeInsetsDirectional.only(start: 6, end: 18),
    alignment: Alignment.center,
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const NestySurface(
          style: SurfaceStyle(color: AppColorTokens.woodLight, shadows: []),
          radius: BorderRadius.all(Radius.circular(16)),
          width: 32,
          height: 32,
          alignment: Alignment.center,
          child: Icon(
            IconUses.bestMoves,
            size: 20,
            color: AppColorTokens.primaryEdge,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          context.localizations.chaptersBestMoves(best),
          style: AppTextStyleTokens.number.copyWith(
            fontSize: 20,
            color: AppColorTokens.textPrimary,
          ),
          maxLines: 1,
          softWrap: false,
        ),
      ],
    ),
  );
}
