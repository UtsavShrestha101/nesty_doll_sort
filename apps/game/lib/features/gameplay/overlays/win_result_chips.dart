import 'package:flutter/material.dart';
import 'package:nesty_game/core/extensions/a11y_join_extension.dart';
import 'package:nesty_game/core/extensions/context_extension.dart';
import 'package:nesty_game/core/ui/nesty_ui.dart';
import 'package:nesty_game/core/ui/theme/locale_script.dart';

/// The win card's moves chip (ui-spec-game §1 "ResultChips"; tokens.json
/// `layout.winStars.movesChip`): a 38 dp `#F6E2C2` disc with the `route`
/// glyph, then "Moves 18" or "Moves 18 · Best 16" in Nunito 800 15, on the
/// cream surface. [newBest] puts the green "New best!" chip on its top edge
/// (a replay that raised the level's stars, frame 11.4).
///
/// [large] is a past day's win (tokens.json `habits.pastDay.win`, frame
/// 14.3d): the pill stands where the coins were, so "Moves 18" is in Fredoka
/// 700 28 `#5B3A21`, padded 10 20 10 10 with a 10 dp gap.
///
/// One node for screen readers: the chip's text, then "New best!".
class WinMovesChip extends StatelessWidget {
  const WinMovesChip({
    required this.text,
    this.newBest = false,
    this.large = false,
    super.key,
  });

  final String text;
  final bool newBest;
  final bool large;

  static TextStyle get _largeText => DisplayFace.of(
    const TextStyle(
      fontFamily: 'Fredoka',
      fontSize: 28,
      fontWeight: FontWeight.w700,
      height: 1,
      color: AppColorTokens.textPrimary,
      fontFamilyFallback: AppFontTokens.displayFallback,
      fontFeatures: [FontFeature.tabularFigures()],
    ),
  );

  static const _style = SurfaceStyle(
    gradient: AppGradientTokens.surface,
    shadows: [
      NestyShadow(color: Color(0xFFFFFFFF), inset: true, dy: 2),
      NestyShadow(color: AppColorTokens.surfaceEdge, dy: 5),
    ],
  );

  /// The "New best!" chip's key, for tests.
  @visibleForTesting
  static const Key newBestKey = Key('win-new-best');

  @override
  Widget build(BuildContext context) {
    final l10n = context.localizations;
    final chip = NestySurface(
      style: _style,
      radius: BorderRadius.circular(WinStarsTokens.movesChipRadius),
      height: WinStarsTokens.movesChipHeight,
      padding: large
          ? const EdgeInsetsDirectional.fromSTEB(10, 10, 20, 10)
          : const EdgeInsetsDirectional.fromSTEB(10, 10, 18, 10),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: WinStarsTokens.movesChipIconDisc,
            height: WinStarsTokens.movesChipIconDisc,
            decoration: const BoxDecoration(
              color: Color(0xFFF6E2C2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              IconUses.bestMoves,
              size: 24,
              color: AppColors.iconBrown,
            ),
          ),
          SizedBox(width: large ? 10 : 8),
          Text(
            text,
            style: large
                ? context.scriptStyle(_largeText)
                : WinStarsTokens.movesChipText,
          ),
        ],
      ),
    );
    return Semantics(
      label: newBest ? l10n.joinSentences([text, l10n.winStarsNewBest]) : text,
      excludeSemantics: true,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topCenter,
        children: [
          chip,
          if (newBest)
            Positioned(
              top: WinStarsTokens.newBestChipTopOffset,
              child: _NewBestChip(key: newBestKey, label: l10n.winStarsNewBest),
            ),
        ],
      ),
    );
  }
}

class _NewBestChip extends StatelessWidget {
  const _NewBestChip({required this.label, super.key});

  final String label;

  @override
  Widget build(BuildContext context) => NestySurface(
    style: SurfaceStyle(
      gradient: WinStarsTokens.newBestChipFill,
      shadows: [
        NestyShadow(
          color: WinStarsTokens.newBestChipEdge.color,
          dy: WinStarsTokens.newBestChipEdge.width,
        ),
        NestyShadow(
          color: WinStarsTokens.newBestChipRing.color,
          spread: WinStarsTokens.newBestChipRing.width,
        ),
      ],
    ),
    radius: BorderRadius.circular(WinStarsTokens.newBestChipRadius),
    height: WinStarsTokens.newBestChipHeight,
    padding: const EdgeInsets.symmetric(horizontal: 12),
    alignment: Alignment.center,
    child: Text(
      label,
      style: AppTextStyleTokens.button.copyWith(
        fontSize: 14,
        height: 1,
        color: const Color(0xFFFFFFFF),
      ),
    ),
  );
}

/// The note and tip pill under the win card (frames 11.2c, 11.4b;
/// `layout.winStars.notePill`): `rgba(40,20,8,.66)`, radius 14, Nunito 700 13
/// `#FFF1DC`, balanced. Plain text, one node.
class WinNotePill extends StatelessWidget {
  const WinNotePill({required this.text, super.key});

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 24),
    child: DecoratedBox(
      decoration: BoxDecoration(
        color: WinStarsTokens.notePillFill,
        borderRadius: BorderRadius.circular(WinStarsTokens.notePillRadius),
      ),
      child: Padding(
        padding: WinStarsTokens.notePillPadding,
        child: Center(
          // `text-wrap: balance` (frame 11.2): two even lines, no orphan.
          child: BalancedText(
            text,
            style: WinStarsTokens.notePillText.copyWith(height: 1.3),
          ),
        ),
      ),
    ),
  );
}
