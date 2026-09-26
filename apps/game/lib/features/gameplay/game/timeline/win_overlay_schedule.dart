import 'package:nesty_game/core/services/audio/audio_service.dart';
import 'package:nesty_game/core/services/haptics/haptics_service.dart';
import 'package:nesty_game/features/fx/fx_cue.dart';
import 'package:nesty_game/features/fx/fx_id.dart';
import 'package:nesty_game/features/fx/fx_spec.gen.dart';
import 'package:nesty_game/features/gameplay/game/timeline/board_timeline.dart'
    show FxSpecLookup;
import 'package:nesty_game/features/gameplay/game/timeline/fx_segment.dart';
import 'package:nesty_game/features/gameplay/game/timeline/motion_spec.dart';

/// The win overlay's timing from its open (frame 2.8;
/// docs/plans/m2-lottie-design.md §7 "Win overlay", PROGRESS D47), as pure
/// data the overlay widget plays: its Lottie segments, when each starts,
/// and its cues. Built from the files' specs at [MotionSpec]'s speed.
final class WinOverlaySchedule {
  const WinOverlaySchedule._({
    required this.cues,
    required this.ribbon,
    required this.ribbonHoldFrame,
    required this.confetti,
    required this.hop,
    required this.hopStartsMs,
    required this.coinBurstAtMs,
    required this.coinBurst,
    required this.countUpStartMs,
    required this.countUpEndMs,
    required this.twinkle,
  });

  /// For [families] completed families hopping on the plank.
  factory WinOverlaySchedule.of(
    MotionSpec motion, {
    required int families,
    FxSpecLookup specOf = fxSpecOf,
  }) {
    final oneShot = motion.oneShotSpeed;
    final coinsAt = motion.ms(FxTiming.winCoinsMs);
    final ribbon = FxSegment.whole(specOf(FxId.uiWinRibbon), speed: oneShot);
    return WinOverlaySchedule._(
      cues: [
        const FxCue(atMs: 0, sound: SoundEffect.win, haptic: HapticPattern.win),
        FxCue(atMs: coinsAt, sound: SoundEffect.coins),
      ],
      ribbon: ribbon,
      ribbonHoldFrame: ribbon.to,
      confetti: motion.confetti
          ? FxSegment.whole(specOf(FxId.fxConfetti), speed: oneShot)
          : null,
      // Ambient: paused on frame 0 under reduced motion (speed 0).
      hop: FxSegment.whole(
        specOf(FxId.dollWinHop),
        loop: true,
        speed: motion.ambientLoopSpeed,
      ),
      hopStartsMs: [
        for (var i = 0; i < families; i++)
          motion.ms(FxTiming.winFamilyStaggerMs * i),
      ],
      coinBurstAtMs: coinsAt,
      coinBurst: FxSegment.whole(specOf(FxId.fxCoinBurst), speed: oneShot),
      countUpStartMs: coinsAt,
      countUpEndMs: motion.ms(FxTiming.winCoinsMs + winCountUpMs),
      twinkle: FxSegment.whole(
        specOf(FxId.fxTwinkle),
        loop: true,
        speed: motion.ambientLoopSpeed,
      ),
    );
  }

  /// The "+N" count-up's length at 1× (§9.7, hand-coded, easeOut).
  // TODO(M7): tune by feel (BACKLOG "Animation polish").
  static const winCountUpMs = 600.0;

  /// `win` + the win haptic at the open, `coins` with the coin burst.
  final List<FxCue> cues;

  /// `ui_win_ribbon` once from the open, then it rests on
  /// [ribbonHoldFrame].
  final FxSegment ribbon;
  final double ribbonHoldFrame;

  /// `fx_confetti` from the open, or null under reduced motion.
  final FxSegment? confetti;

  /// `doll_win_hop` per family, looping, starting at [hopStartsMs] (150 ms
  /// apart).
  final FxSegment hop;
  final List<double> hopStartsMs;

  /// `fx_coin_burst` on the "+N" pill's coin.
  final double coinBurstAtMs;
  final FxSegment coinBurst;

  /// The "+N" count-up, from 0 to the reward.
  final double countUpStartMs;
  final double countUpEndMs;

  /// `fx_twinkle`, ambient.
  final FxSegment twinkle;
}
