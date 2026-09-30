import 'package:nesty_game/core/common_imports.dart';
import 'package:nesty_game/core/ui/nesty_ui.dart';
import 'package:nesty_game/features/gameplay/widgets/booster_bar.dart';
import 'package:nesty_game/features/race/cubit/race_cubit.dart';

/// The wood bar under the board, in a race (frame 9.3; `layout.raceBar`;
/// phase 4 ui-spec-game §2.1): before Start, the four booster slots are
/// hidden and one `VersusButton` (168×58, radius 18, `gradient.versus`, edge
/// 6, `play_arrow` and "Start") sits over slots 2 and 3, with no scrim and no
/// countdown (vs-computer rule 4). Once running, exactly Undo in slot 1 and
/// Restart in slot 4, slots 2 and 3 left empty wood; Undo's badge is always
/// `BoosterBadge.infinite()` (undo is free and unlimited in a race, spec-prop
/// §7.7, whatever Settings' Relaxed mode says).
class RaceActionBar extends StatelessWidget {
  const RaceActionBar({
    required this.ready,
    required this.onStart,
    required this.canUndo,
    required this.onUndo,
    required this.onRestart,
    super.key,
  });

  /// The race hasn't started yet ([RacePhase.ready]): show Start instead of
  /// the boosters.
  final bool ready;
  final VoidCallback onStart;

  final bool canUndo;
  final VoidCallback onUndo;
  final VoidCallback onRestart;

  @override
  Widget build(BuildContext context) {
    final l10n = context.localizations;
    final bottom = MediaQuery.paddingOf(context).bottom;
    final width = BoosterBar.buttonWidth(MediaQuery.sizeOf(context).width);
    // The two empty slots between Undo and Restart (`raceBar.hiddenSlots`).
    final between = 3 * BoosterBarTokens.gap + 2 * width;
    return WoodBar(
      height: BoosterBar.height + bottom,
      padding: EdgeInsets.only(top: BoosterBarTokens.topInset, bottom: bottom),
      child: Align(
        alignment: Alignment.topCenter,
        child: ready
            ? SizedBox(
                width: RaceBarTokens.startWidth,
                child: TactileButton(
                  label: l10n.raceStart,
                  icon: NestyIcons.playArrow,
                  variant: TactileButtonVariant.versus,
                  size: TactileButtonSize.large,
                  onPressed: onStart,
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  BoosterButton(
                    icon: NestyIcons.undo,
                    label: l10n.boosterUndo,
                    width: width,
                    badge: const BoosterBadge.infinite(),
                    onPressed: canUndo ? onUndo : null,
                  ),
                  SizedBox(width: between),
                  BoosterButton(
                    icon: NestyIcons.restartAlt,
                    label: l10n.restart,
                    width: width,
                    onPressed: onRestart,
                  ),
                ],
              ),
      ),
    );
  }
}
