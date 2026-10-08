import 'package:nesty_game/core/common_imports.dart';
import 'package:nesty_game/core/services/records/badge.dart';
import 'package:nesty_game/core/ui/nesty_ui.dart';
import 'package:nesty_game/core/ui/theme/locale_script.dart';
import 'package:nesty_game/features/museum/cubit/museum_cubit.dart';
import 'package:nesty_game/features/museum/widgets/figurine_image.dart';

/// The Museum's lead card (frames 6.1, 6.1b, 6.1c; tokens `layout.museum.
/// nextCard`; NestyHub:107-110): the next family to earn, made the screen's
/// focus, 150 tall (more only when text grows): its locked figurine
/// (118×132, cream tinted), "NEXT FAMILY" (Fredoka 700 11), its name (20),
/// "Chapter 4 · 14 levels to go" (Nunito 800 12), a green progress bar and
/// "Play Level 67" ([onPlay], the same request Home's PLAY starts), a 38 dp
/// face in a 48 dp touch box.
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
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: MuseumTokens.nextCardHeight),
      child: NestySurface(
        style: _style,
        radius: BorderRadius.circular(MuseumTokens.nextCardRadius),
        width: double.infinity,
        alignment: Alignment.center,
        padding: const EdgeInsetsDirectional.fromSTEB(8, 0, 14, 0),
        child: next == null
            ? _AllHome(count: state.collectedCount)
            : _Next(
                entry: next,
                levelsToGo: state.levelsToGo,
                homeLevelNumber: state.homeLevelNumber,
                onPlay: onPlay,
              ),
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
          height: MuseumTokens.nextCardArt.height,
          child: Align(
            alignment: Alignment.bottomCenter,
            child: FigurineImage(
              figurineId: entry.figurineId,
              locked: true,
              size: MuseumTokens.nextCardArt.width,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              ShrinkToFitText(
                l10n.museumNextFamilyKicker,
                maxLines: 1,
                overflowLines: 2,
                minFontScale: 0.75,
                textAlign: TextAlign.start,
                style: MuseumTypeTokens.kicker.copyWith(
                  letterSpacing: context.script.tracking(11 * 0.08),
                ),
              ),
              const SizedBox(height: 6),
              ShrinkToFitText(
                l10n.figurineName(entry.figurineId),
                maxLines: 2,
                minFontScale: 0.6,
                textAlign: TextAlign.start,
                style: AppTextStyleTokens.cardTitle.copyWith(
                  fontSize: 20,
                  height: 1.1,
                  color: AppColorTokens.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                l10n.museumNextLine(entry.chapterNumber, levelsToGo),
                style: MuseumTypeTokens.nextLine,
                maxLines: 2,
              ),
              const SizedBox(height: 6),
              NestyProgressBar(
                value: entry.total == 0 ? 0 : entry.done / entry.total,
                height: 10,
                semanticLabel: l10n.museumNextLine(
                  entry.chapterNumber,
                  levelsToGo,
                ),
              ),
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: TactileButton(
                  label: l10n.playLevel(homeLevelNumber),
                  onPressed: onPlay,
                  icon: NestyIcons.playArrow,
                  // NestyHub:110: a 36 face; `compact` (38) is the nearest
                  // size, in the 48 dp touch box (spec §10.3).
                  size: TactileButtonSize.compact,
                  expand: false,
                  minTouchSize: const Size(48, 48),
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

  @override
  Widget build(BuildContext context) {
    final l10n = context.localizations;
    return Row(
      children: [
        // `museum_full.svg` at 92 dp is the card's centrepiece (m7-5
        // choice 12; NestyHub:114).
        UiArtImage.square(
          UiArt.badge(BadgeId.museumFull, earned: true),
          extent: 92,
        ),
        // NestyHub's all-home row: a 12 dp gap.
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Frame 6.1c sets it on one line: it may shrink a little (to
              // 0.9) to stay there, and only a longer translation wraps. On
              // two lines it may go to the readability floor (es at 1.3×
              // needs 0.85 beside the 92 dp badge).
              ShrinkToFitText(
                l10n.museumAllHome,
                maxLines: 1,
                minFontScale: 0.9,
                overflowLines: 2,
                overflowMinFontScale: 0.75,
                textAlign: TextAlign.start,
                style: AppTextStyleTokens.cardTitle.copyWith(
                  fontSize: 24,
                  height: 1.1,
                  color: AppColorTokens.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                l10n.museumFullSub(count),
                style: AppTextStyleTokens.row.copyWith(
                  fontSize: 13,
                  height: 1.3,
                  color: AppColorTokens.textBrown,
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
