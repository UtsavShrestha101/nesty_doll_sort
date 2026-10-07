import 'dart:async';

import 'package:nesty_game/core/common_imports.dart';
import 'package:nesty_game/core/services/login_gift/login_gift_reward.dart';
import 'package:nesty_game/core/services/music/jingle_cues.dart';
import 'package:nesty_game/core/ui/nesty_ui.dart';
import 'package:nesty_game/core/ui/theme/locale_script.dart';
import 'package:nesty_game/features/fx/chest/chest_reward_sequence.dart';
import 'package:nesty_game/features/fx/fx_library.dart';
import 'package:nesty_game/features/gameplay/game/timeline/feedback_sink.dart';
import 'package:nesty_game/features/login_gift/cubit/login_gift_cubit.dart';
import 'package:nesty_game/features/login_gift/widgets/gift_anchors.dart';
import 'package:nesty_game/features/login_gift/widgets/gift_tally.dart';

/// The daily gift's Day 7 chest (frames 13.6b–13.6d, 13.6r; `gift.chest`):
/// the chest card of 10.3b and 5.6 (`layout.chestCard` at `topDay7` 176,
/// `ui_chest` arriving) with the house orange ribbon, titled "Day 7 gift"
/// ("Day 7" where that doesn't fit), and what the gift holds, 100 coins
/// and an extra slot, from the first frame (spec-prop 1.1 rule 2). Open,
/// then Collect; no Double it. Nothing here pays: `LoginGiftCubit.claim`
/// paid when the sheet's Claim was pressed, so Collect only dismisses.
///
/// Collect works as 10.3d (`gift.claim.day7`): the scrim drops to
/// rgba(60,30,10,.18), six coins fly to Home's pill, which ticks up and
/// rings, and the slot flies to the tally under the pill ([GiftTally]).
/// Reduce motion (13.6r): the chest cross-fades open, and Collect updates
/// the pill and the tally with no flights.
class GiftChestModal extends StatefulWidget {
  const GiftChestModal({
    required this.reward,
    required this.onCoinsRevealed,
    required this.onCollect,
    this.anchors,
    this.hints = 0,
    this.slots = 0,
    this.feedback,
    this.library,
    this.uiArt,
    super.key,
  });

  final LoginGiftReward reward;

  /// Home's coin pill (null: nothing to fly to, the pill updates at once).
  final GiftAnchors? anchors;

  /// The player's hint and extra slot totals after the claim, the tally's
  /// counts.
  final int hints;
  final int slots;
  final ValueChanged<int> onCoinsRevealed;
  final VoidCallback onCollect;
  final FeedbackSink? feedback;
  final FxLibrary? library;
  final UiArtLibrary? uiArt;

  /// Opens the chest over [context]'s screen (Home) for the Day 7 [grant]
  /// that [cubit] has already paid. Collect releases the pill's cap and
  /// closes once the flights are home.
  static Future<void> show(
    BuildContext context, {
    required LoginGiftCubit cubit,
    required LoginGiftGrant grant,
    GiftAnchors? anchors,
    JingleCues? jingleCues,
    FeedbackSink? feedback,
    FxLibrary? library,
    UiArtLibrary? uiArt,
  }) {
    final totals = cubit.state.data;
    return showGeneralDialog<void>(
      context: context,
      barrierDismissible: false,
      barrierLabel: '',
      // The sequence draws its own scrim and arrival.
      barrierColor: const Color(0x00000000),
      transitionDuration: Duration.zero,
      pageBuilder: (dialogContext, _, _) => PopScope(
        // The reward is paid; leaving only through Collect keeps the pill's
        // cap from being left held.
        canPop: false,
        child: Material(
          type: MaterialType.transparency,
          child: GiftChestModal(
            reward: grant.reward,
            anchors: anchors,
            hints: totals?.hints ?? grant.reward.hints,
            slots: totals?.slots ?? grant.reward.slots,
            feedback: feedback,
            library: library,
            uiArt: uiArt,
            onCoinsRevealed: cubit.coinsLanded,
            onCollect: () {
              cubit.releaseCoins();
              // 5.6's sounds (`gift.claim.sound`): the sequence plays
              // `chest_wiggle` and `chest_open`; `jingle_reward` plays as
              // the Daily's day-7 Collect plays it.
              jingleCues?.reward();
              Navigator.of(dialogContext).pop();
            },
          ),
        ),
      ),
    );
  }

  /// The ribbon's room: the card keeps 56 clear each side of it (ModalCard),
  /// and its own padding is 22 + 22.
  static const double ribbonPadding = 112 + 44;

  @override
  State<GiftChestModal> createState() => _GiftChestModalState();
}

class _GiftChestModalState extends State<GiftChestModal>
    with SingleTickerProviderStateMixin {
  GiftTallyHandle? _tally;
  Rect? _pill;
  Timer? _close;

  /// The pill ring (`motion.chest.collect.pillRing`): on in 80 ms as the
  /// first coin lands, off over 240 ms after the last, above the chest's
  /// dim (`gift.tally.layer`'s neighbour in 13.6d).
  late final AnimationController _ring;

  @override
  void initState() {
    super.initState();
    _ring = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: ChestCollectTokens.pillRingInMs),
      reverseDuration: const Duration(
        milliseconds: ChestCollectTokens.pillRingOutMs,
      ),
    );
  }

  @override
  void dispose() {
    _close?.cancel();
    _ring.dispose();
    // The tally outlives the chest: whatever hasn't landed lands now.
    _tally?.landAll();
    super.dispose();
  }

  /// "Day 7 gift", or "Day 7" where the full title would shrink below
  /// textFit.giftChestTitle's 0.85 on this phone. The ribbon is one line
  /// and never cuts.
  String _title(BuildContext context) {
    final l10n = context.localizations;
    final width =
        MediaQuery.sizeOf(context).width -
        ChestCardTokens.cardLeft -
        ChestCardTokens.cardRight -
        GiftChestModal.ribbonPadding;
    return FitText.pick(
      full: l10n.giftChestTitle,
      short: l10n.giftChestTitleShort,
      style: context.scriptStyle(
        AppTextStyleTokens.button.copyWith(fontSize: 18),
      ),
      maxWidth: width,
      scaler: MediaQuery.textScalerOf(context),
      direction: Directionality.of(context),
      minScale: TextFitTokens.giftChestTitleMinScale,
    );
  }

  /// Collect starts: the tally slides out under the pill for the slot (and
  /// a tuned track's hints).
  void _onCollectStart() {
    final reward = widget.reward;
    _pill = widget.anchors?.pill();
    final pill = _pill;
    final entries = [
      if (reward.hints > 0)
        GiftTallyEntry(
          kind: GiftTallyKind.hint,
          added: reward.hints,
          total: widget.hints,
        ),
      if (reward.slots > 0)
        GiftTallyEntry(
          kind: GiftTallyKind.slot,
          added: reward.slots,
          total: widget.slots,
        ),
    ];
    if (pill == null || entries.isEmpty) return;
    _tally = GiftTally.show(context, pill: pill, entries: entries);
  }

  void _onCoinsRevealed(int landed) {
    widget.onCoinsRevealed(landed);
    if (context.reduceMotion || _pill == null) return;
    if (landed > 0 && !_ring.isForwardOrCompleted) unawaited(_ring.forward());
  }

  void _onCollect() {
    if (_ring.value <= 0) {
      widget.onCollect();
      return;
    }
    // The ring fades over 240 ms after the last coin, then the chest goes.
    unawaited(_ring.reverse());
    _close = Timer(
      const Duration(milliseconds: ChestCollectTokens.pillRingOutMs),
      () {
        if (mounted) widget.onCollect();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.localizations;
    final reward = widget.reward;
    return ModalSemanticsScope(
      child: Stack(
        fit: StackFit.expand,
        children: [
          ChestRewardSequence(
            title: _title(context),
            // The contents show from the start, so one line serves closed
            // and open (`gift_chest_body`).
            body: l10n.giftChestBody,
            cardTop: ChestCardTokens.cardTopDay7,
            coins: reward.coins,
            hints: reward.hints,
            slots: reward.slots,
            onCollect: _onCollect,
            feedback: widget.feedback,
            library: widget.library,
            uiArt: widget.uiArt,
            coinTarget: widget.anchors?.coinDisc,
            hintTarget: () => _tally?.discOf(GiftTallyKind.hint),
            slotTarget: () => _tally?.discOf(GiftTallyKind.slot),
            onCollectStart: _onCollectStart,
            onCoinsRevealed: _onCoinsRevealed,
            onHintLanded: () => _tally?.land(GiftTallyKind.hint),
            onSlotLanded: () => _tally?.land(GiftTallyKind.slot),
          ),
          IgnorePointer(
            child: AnimatedBuilder(
              animation: _ring,
              builder: (context, _) =>
                  CustomPaint(painter: _PillRingPainter(_pill, _ring.value)),
            ),
          ),
        ],
      ),
    );
  }
}

/// The pill ring at Home's pill, above the chest's dim.
class _PillRingPainter extends CustomPainter {
  const _PillRingPainter(this.pill, this.opacity);

  final Rect? pill;
  final double opacity;

  @override
  void paint(Canvas canvas, Size size) {
    final pill = this.pill;
    if (pill == null || opacity <= 0) return;
    // The modal fills the screen from its origin: screen and local agree.
    RingGlowPainter.paintRing(
      canvas,
      RRect.fromRectAndRadius(pill, Radius.circular(pill.height / 2)),
      ChestCollectTokens.pillRingShadow,
      opacity: opacity,
    );
  }

  @override
  bool shouldRepaint(_PillRingPainter oldDelegate) =>
      oldDelegate.pill != pill || oldDelegate.opacity != opacity;
}
