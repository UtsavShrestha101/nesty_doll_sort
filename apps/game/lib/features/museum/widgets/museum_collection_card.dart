import 'package:nesty_game/core/common_imports.dart';
import 'package:nesty_game/core/ui/nesty_ui.dart';
import 'package:nesty_game/features/museum/cubit/museum_cubit.dart';
import 'package:nesty_game/features/museum/widgets/figurine_image.dart';

/// The Museum's lead card (frames 6.1, 6.1b, 6.1c; tokens `layout.museum.
/// nextCard`): the next family to earn, made the screen's focus: its locked
/// figurine (118×132, cream tinted), "NEXT FAMILY", its name, "Chapter 4 · 14
/// levels to go", a green progress bar and "Play Level 67" ([onPlay], the
/// same request Home's PLAY starts).
///
/// Once [MuseumState.allCollected] the card celebrates instead (6.1c): a
/// brass disc with the museum house, "Every family is home." and "Full House
/// · all 10 families", with no Play button.
class MuseumCollectionCard extends StatelessWidget {
  const MuseumCollectionCard({
    required this.state,
    required this.onPlay,
    super.key,
  });

  final MuseumState state;

  /// Plays [MuseumState.homeRequest] (`LevelResolver.homeRequest`), the
  /// same request the figurine modal's own "Play Level N" starts.
  final VoidCallback onPlay;

  static const _style = SurfaceStyle(
    gradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [AppColorTokens.canvasCream, AppColorTokens.woodLight],
    ),
    shadows: [
      NestyShadow(color: Color(0xB3FFFFFF), inset: true, dy: 2),
      NestyShadow(color: AppColorTokens.surfaceEdge, dy: 5),
    ],
  );

  @override
  Widget build(BuildContext context) {
    final next = state.next;
    return NestySurface(
      style: _style,
      radius: BorderRadius.circular(MuseumTokens.nextCardRadius),
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 12, 16, 14),
      child: next == null
          ? _AllHome(count: state.collectedCount)
          : _Next(
              entry: next,
              levelsToGo: state.levelsToGo,
              homeLevelNumber: state.homeLevelNumber,
              onPlay: onPlay,
            ),
    );
  }
}

class _Next extends StatelessWidget {
  const _Next({
    required this.entry,
    required this.levelsToGo,
    required this.homeLevelNumber,
    required this.onPlay,
  });

  final MuseumEntry entry;
  final int levelsToGo;
  final int homeLevelNumber;
  final VoidCallback onPlay;

  @override
  Widget build(BuildContext context) {
    final l10n = context.localizations;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // The card's art box is 118×132; the figurine is square, so it
        // fills the width and is cream tinted by its own locked art.
        SizedBox(
          width: MuseumTokens.nextCardArt.width,
          child: FigurineImage(
            figurineId: entry.figurineId,
            locked: true,
            size: MuseumTokens.nextCardArt.width,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                l10n.museumNextFamily.toUpperCase(),
                style: AppTextStyleTokens.caption.copyWith(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 13 * 0.08,
                  color: AppColorTokens.textAccent,
                ),
                maxLines: 1,
              ),
              const SizedBox(height: 2),
              ShrinkToFitText(
                l10n.figurineName(entry.figurineId),
                maxLines: 2,
                minFontScale: 0.6,
                textAlign: TextAlign.start,
                style: AppTextStyleTokens.cardTitle.copyWith(
                  fontSize: 26,
                  height: 1.05,
                  color: AppColorTokens.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                l10n.museumNextLine(entry.chapterNumber, levelsToGo),
                style: AppTextStyleTokens.row.copyWith(
                  fontSize: 15,
                  color: AppColorTokens.textSecondary,
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 8),
              NestyProgressBar(
                value: entry.total == 0 ? 0 : entry.done / entry.total,
                height: 10,
                semanticLabel: l10n.museumNextLine(
                  entry.chapterNumber,
                  levelsToGo,
                ),
              ),
              const SizedBox(height: 10),
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: TactileButton(
                  label: l10n.playLevel(homeLevelNumber),
                  onPressed: onPlay,
                  icon: NestyIcons.playArrow,
                  size: TactileButtonSize.small,
                  expand: false,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// 6.1c: the brass disc, the title and "Full House · all N families".
class _AllHome extends StatelessWidget {
  const _AllHome({required this.count});

  final int count;

  static const _disc = SurfaceStyle(
    gradient: AppGradientTokens.gold,
    shadows: [
      NestyShadow(color: Color(0x66FFFFFF), inset: true, dy: 2),
      NestyShadow(color: Color(0xFF8A5C12), dy: 5),
    ],
  );

  @override
  Widget build(BuildContext context) {
    final l10n = context.localizations;
    return Row(
      children: [
        NestySurface(
          style: _disc,
          radius: BorderRadius.circular(42),
          width: 84,
          height: 84,
          alignment: Alignment.center,
          child: const Icon(
            IconUses.familiesHome,
            size: 48,
            color: Color(0xFFFFFFFF),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              ShrinkToFitText(
                l10n.museumAllHome,
                maxLines: 2,
                minFontScale: 0.6,
                textAlign: TextAlign.start,
                style: AppTextStyleTokens.cardTitle.copyWith(
                  fontSize: 30,
                  height: 1.05,
                  color: AppColorTokens.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                l10n.museumFullSub(count),
                style: AppTextStyleTokens.row.copyWith(
                  fontSize: 16,
                  color: AppColorTokens.textSecondary,
                ),
                maxLines: 2,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
