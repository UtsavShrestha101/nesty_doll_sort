import 'package:nesty_game/core/common_imports.dart';
import 'package:nesty_game/core/services/music/jingle_cues.dart';
import 'package:nesty_game/core/services/save/save_document.dart';
import 'package:nesty_game/core/ui/art/ui_art_library.dart';
import 'package:nesty_game/core/ui/widgets/modal/modal_semantics_scope.dart';
import 'package:nesty_game/features/fx/chest/chest_reward_sequence.dart';
import 'package:nesty_game/features/fx/chest/reward_flight.dart';
import 'package:nesty_game/features/fx/fx_library.dart';
import 'package:nesty_game/features/gameplay/game/timeline/feedback_sink.dart';

/// The milestone chest modal (E5; spec-prop §7.3; docs/plans/m7-design.md
/// §9, §15.4): opens after Continue when `GameplayState.chest != null`,
/// before Chapter complete and the next level. Its own contents (the coins
/// and hints) are already in the save (m7-design §9 step 3, a kill between
/// the win and this modal loses nothing): its buttons only dismiss.
///
/// The arrival, idle, open and collect moment is [ChestRewardSequence]
/// (shared with [DailyChestModal], m7-design "owner-chest" lane): this
/// widget only supplies the copy and the chest's fixed contents. It opens
/// closed on `ui_chest` (frames 10.3b–10.3d).
class MilestoneChestModal extends StatelessWidget {
  const MilestoneChestModal({
    required this.chest,
    required this.onCollect,
    this.feedback,
    this.jingleCues,
    this.library,
    this.uiArt,
    this.coinTarget,
    this.hintTarget,
    this.onCoinsRevealed,
    this.onHintLanded,
    super.key,
  });

  final ChestGrant chest;

  /// Dismisses the modal once opened and collected; grants nothing
  /// (already paid).
  final VoidCallback onCollect;

  /// Plays the sequence's clacks, chip-pop ticks and the open's success
  /// haptic; null is silent.
  final FeedbackSink? feedback;

  /// Plays `jingle_reward` on open.
  final JingleCues? jingleCues;

  final FxLibrary? library;

  /// The UI art behind `ui_chest` and the flight sprites.
  final UiArtLibrary? uiArt;

  /// Where the coin (and hint) flights land: the HUD's coin pill and the
  /// Hint booster button, read live by `gameplay_view.dart`. Null bursts in
  /// place instead of flying (m7-design chest sequence step 4).
  final RewardFlightTarget? coinTarget;
  final RewardFlightTarget? hintTarget;

  /// Called with the cumulative coins released as each flight sprite
  /// lands, so the HUD's coin hold (m7-design §9) can count up in step
  /// instead of jumping once the modal closes.
  final ValueChanged<int>? onCoinsRevealed;

  /// Called once the hint sprite lands (or immediately, with nothing to
  /// fly to), so the Hint booster's badge can pulse.
  final VoidCallback? onHintLanded;

  /// The closed chest's size, for a test to compare against the open one's.
  @visibleForTesting
  static const double closedSize = 130;

  @override
  Widget build(BuildContext context) {
    final l10n = context.localizations;
    final body = chest.source == ChestSource.bonus
        ? l10n.chestMilestoneBodyBonus(chest.number)
        : l10n.chestMilestoneBody(chest.number);
    // Over the level's HUD and booster bar, which can't be reached while it
    // is up (review R11).
    return ModalSemanticsScope(
      child: ChestRewardSequence(
        title: l10n.chestMilestoneTitle,
        streakRibbon: true,
        // copy.md G.9's body already says "Here's what's inside".
        body: body,
        coins: chest.coins,
        hints: chest.hints,
        onCollect: onCollect,
        feedback: feedback,
        jingleCues: jingleCues,
        library: library,
        uiArt: uiArt,
        coinTarget: coinTarget,
        hintTarget: hintTarget,
        onCoinsRevealed: onCoinsRevealed,
        onHintLanded: onHintLanded,
        closedChestSize: closedSize,
      ),
    );
  }
}
