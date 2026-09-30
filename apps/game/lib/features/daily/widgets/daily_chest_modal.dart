import 'package:nesty_game/core/common_imports.dart';
import 'package:nesty_game/core/services/music/jingle_cues.dart';
import 'package:nesty_game/core/ui/widgets/modal/modal_semantics_scope.dart';
import 'package:nesty_game/features/fx/chest/chest_reward_sequence.dart';
import 'package:nesty_game/features/fx/chest/reward_flight.dart';
import 'package:nesty_game/features/fx/fx_library.dart';
import 'package:nesty_game/features/gameplay/game/timeline/feedback_sink.dart';

/// The day-7 chest (frame 5.6), on opening Daily while `chestPending`: the
/// same arrival/idle/open/collect moment as [MilestoneChestModal]
/// ("in this too we need to have animations, gamification", m7-design
/// "owner-chest" lane), just coins and no hint chip.
///
/// The Daily screen has no HUD: `daily_page.dart` passes its
/// `ScreenHeader`'s coin pill as [coinTarget], so the coins fly there and
/// [onCoinsRevealed] ticks the pill up one landing at a time. Without a
/// target the coins burst and count up in place instead of flying
/// (m7-design chest sequence step 4).
///
/// [feedback] and [jingleCues] are also optional and, today, not passed by
/// `daily_page.dart` either: `DailyCubit.collectChest()` and the page's own
/// `onCollect` closure already decide when the real reward jingle plays
/// (tied to the collect actually landing), so leaving these null here
/// costs nothing today and lets whoever wires them later turn on this
/// widget's own clacks/chip-pop/open-success cues without a second change.
// Frames 5.6 and 5.6b (m7-3): the chest arrives closed with the contents
// shown, Open, then the burst. The look is `ChestRewardSequence`'s (the
// `ui_chest` Lottie and `ChestModalTokens`, lane O), shared with the
// milestone chest.
// TODO(M6): "Double it" (a rewarded ad) sits above Collect.
class DailyChestModal extends StatelessWidget {
  const DailyChestModal({
    required this.coins,
    required this.onCollect,
    this.feedback,
    this.jingleCues,
    this.library,
    this.coinTarget,
    this.onCoinsRevealed,
    super.key,
  });

  final int coins;
  final VoidCallback onCollect;
  final FeedbackSink? feedback;
  final JingleCues? jingleCues;
  final FxLibrary? library;
  final RewardFlightTarget? coinTarget;
  final ValueChanged<int>? onCoinsRevealed;

  @override
  Widget build(BuildContext context) {
    final l10n = context.localizations;
    // Over the Daily screen, whose Play and Back can't be reached while it
    // is up (review R11).
    return ModalSemanticsScope(
      child: ChestRewardSequence(
        title: l10n.dailyChestTitle,
        streakRibbon: true,
        // copy.md G.9 `chest_streak_body`: the contents show from the start
        // (spec-prop §1.1 rule 2), so one line serves closed and open.
        body: l10n.dailyChestBody,
        coins: coins,
        onCollect: onCollect,
        feedback: feedback,
        jingleCues: jingleCues,
        library: library,
        coinTarget: coinTarget,
        onCoinsRevealed: onCoinsRevealed,
      ),
    );
  }
}
