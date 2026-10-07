import 'package:nesty_game/core/common_imports.dart';
import 'package:nesty_game/core/ui/nesty_ui.dart';

/// "Races won" (frame 10.6; tokens `layout.records.racesCard`): a white card
/// with a row per computer rival, each with its portrait (40), its name, the
/// Computer tag beside it (spec-prop §1.1 rule 5: a computer is always
/// labelled one, here too) and its wins on the right. No wins is an en dash
/// in `textMuted`; a rival the player hasn't unlocked has the locked portrait
/// and a muted name.
class RacesWonCard extends StatelessWidget {
  const RacesWonCard({required this.wins, required this.unlocked, super.key});

  /// Races won per rival, rivals 1-3.
  final List<int> wins;

  /// Whether each rival is unlocked, rivals 1-3.
  final List<bool> unlocked;

  static const _style = SurfaceStyle(
    color: AppColorTokens.surfaceWhite,
    shadows: [
      NestyShadow(color: Color(0xFFFFFFFF), inset: true, dy: 2),
      NestyShadow(color: AppColorTokens.surfaceEdge, dy: 4),
    ],
  );

  @override
  Widget build(BuildContext context) {
    final l10n = context.localizations;
    return NestySurface(
      style: _style,
      radius: BorderRadius.circular(20),
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.recordsRacesHeader,
            style: AppTextStyleTokens.cardTitle.copyWith(
              fontSize: 16,
              height: 1,
              color: AppColorTokens.textPrimary,
            ),
            maxLines: 1,
          ),
          const SizedBox(height: 4),
          for (var i = 0; i < wins.length; i++) ...[
            if (i > 0)
              const ColoredBox(
                color: AppColorTokens.divider,
                child: SizedBox(height: 1.5),
              ),
            _RivalRow(
              number: i + 1,
              wins: wins[i],
              unlocked: i < unlocked.length ? unlocked[i] : i == 0,
            ),
          ],
        ],
      ),
    );
  }
}

class _RivalRow extends StatelessWidget {
  const _RivalRow({
    required this.number,
    required this.wins,
    required this.unlocked,
  });

  final int number;
  final int wins;
  final bool unlocked;

  @override
  Widget build(BuildContext context) {
    final l10n = context.localizations;
    final name = l10n.raceRivalName(number);
    final count = NestyNumberText.formatCount(context, wins);
    return Semantics(
      container: true,
      label: unlocked
          ? l10n.recordsRaceSemantics(name, wins)
          : l10n.recordsRaceLockedSemantics(name),
      excludeSemantics: true,
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          minHeight: RecordsTokens.racesCardRowHeight,
        ),
        child: Row(
          children: [
            _Portrait(number: number, unlocked: unlocked),
            const SizedBox(width: 12),
            Expanded(
              child: Wrap(
                spacing: 6,
                runSpacing: 4,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(
                    name,
                    // NestyHub:137: Fredoka 600 16/1; a locked rival `#A48B72`.
                    style: RecordsTypeTokens.rowName.copyWith(
                      color: unlocked
                          ? AppColorTokens.textPrimary
                          : AppColorTokens.disabledText,
                    ),
                    maxLines: 1,
                  ),
                  const ComputerTag(),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              unlocked && wins > 0 ? count : '–',
              style: RecordsTypeTokens.rowValue.copyWith(
                color: unlocked && wins > 0
                    ? AppColorTokens.textPrimary
                    : AppColorTokens.disabledText,
              ),
              maxLines: 1,
            ),
          ],
        ),
      ),
    );
  }
}

/// A rival's 40 dp portrait on a white ring (frame 10.6); the locked
/// portrait for a rival not yet unlocked.
class _Portrait extends StatelessWidget {
  const _Portrait({required this.number, required this.unlocked});

  final int number;
  final bool unlocked;

  static const _ring = SurfaceStyle(
    color: AppColorTokens.surfaceWhite,
    shadows: [
      NestyShadow(color: AppColorTokens.surfaceWhite, spread: 2),
      NestyShadow(color: Color(0x1F5A3214), dy: 2, blur: 4),
    ],
  );

  @override
  Widget build(BuildContext context) => NestySurface(
    style: _ring,
    radius: BorderRadius.circular(RecordsTokens.racesCardPortrait / 2),
    width: RecordsTokens.racesCardPortrait,
    height: RecordsTokens.racesCardPortrait,
    alignment: Alignment.center,
    child: UiArtImage.square(
      UiArt.rival(unlocked ? number : null),
      extent: RecordsTokens.racesCardPortrait,
    ),
  );
}
