import 'package:nesty_game/core/common_imports.dart';
import 'package:nesty_game/core/services/daily/daily_service.dart';
import 'package:nesty_game/core/ui/nesty_ui.dart';
import 'package:nesty_game/core/ui/theme/locale_script.dart';

/// The Daily before Level 2 (frame 12.14, the design's NestyHabits
/// `dailyLocked` scene): one calm card, the Daily's puzzle piece, a title,
/// a line and Play for the level the player is on. No lock, no countdown,
/// no word about what they are missing (D92).
///
/// TODO(design): tokens.json holds no entry for this card's sizes; they are
/// the scene's (card radius 32, 76 dp piece, title 26, body 16, 58 dp
/// button).
class DailyLockedCard extends StatelessWidget {
  const DailyLockedCard({
    required this.playLevelNumber,
    required this.onPlay,
    super.key,
  });

  /// The level the button plays (the player's current one).
  final int playLevelNumber;
  final VoidCallback onPlay;

  static const _radius = 32.0;
  static const _pieceSize = 76.0;

  /// The welcome card's face and shadow stack, deeper: edge 7, drop 0 14 24
  /// at 0.16.
  static final _style = SurfaceStyle(
    gradient: HabitsWelcomeTokens.cardFace,
    shadows: [
      HabitsWelcomeTokens.cardShadow[0],
      HabitsWelcomeTokens.cardShadow[1].copyWith(dy: 7),
      HabitsWelcomeTokens.cardShadow[2].copyWith(
        dy: 14,
        blur: 24,
        color: HabitsWelcomeTokens.cardShadow[2].color.withValues(alpha: 0.16),
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    final l10n = context.localizations;
    final piece = HabitsWelcomeTokens.discNewEdge;
    return NestySurface(
      style: _style,
      radius: BorderRadius.circular(_radius),
      padding: const EdgeInsets.fromLTRB(22, 30, 22, 22),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: ExcludeSemantics(
              child: NestySurface(
                style: SurfaceStyle(
                  gradient: HabitsWelcomeTokens.discNewFace,
                  shadows: [piece.first, piece.last.copyWith(dy: 5)],
                ),
                radius: BorderRadius.circular(24),
                width: _pieceSize,
                height: _pieceSize,
                alignment: Alignment.center,
                child: const Icon(
                  NestyIcons.extension,
                  size: 44,
                  color: HabitsWelcomeTokens.discNewGlyphColor,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Semantics(
            header: true,
            child: BalancedText(
              l10n.dailyLockedTitle,
              style: context.scriptStyle(
                AppTextStyleTokens.cardTitle.copyWith(
                  fontSize: 26,
                  height: 1.15,
                  color: AppColorTokens.textBrown,
                ),
                role: ScriptTextRole.title,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            l10n.dailyLockedBody(DailyService.unlockAfterLevel),
            textAlign: TextAlign.center,
            style: context.scriptStyle(
              HabitsWelcomeTokens.body.copyWith(
                fontSize: 16,
                height: 1.45,
                fontWeight: FontWeight.w600,
              ),
              role: ScriptTextRole.body,
            ),
          ),
          const SizedBox(height: 24),
          TactileButton(
            label: l10n.playLevel(playLevelNumber),
            icon: NestyIcons.playArrow,
            onPressed: onPlay,
          ),
        ],
      ),
    );
  }
}
