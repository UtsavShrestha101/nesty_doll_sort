import 'package:nesty_core/nesty_core.dart' show StarRating;
import 'package:nesty_game/core/services/audio/audio_service.dart';
import 'package:nesty_game/core/services/haptics/haptics_service.dart';
import 'package:nesty_game/core/ui/tokens/ui_tokens.gen.dart'
    show StarMotionTokens;
import 'package:nesty_game/features/fx/fx_cue.dart';
import 'package:nesty_game/features/fx/fx_id.dart';
import 'package:nesty_game/features/fx/fx_spec.dart' show FxSpec;
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
    required this.starsStartMs,
    required this.starCues,
    required this.starFlourishCue,
  });

  /// For [families] completed families hopping on the plank, and [stars]
  /// (1–3) this win earned; null for a board with no stars (daily, bonus,
  /// race, or a level without a par, m7-design P3.7).
  factory WinOverlaySchedule.of(
    MotionSpec motion, {
    required int families,
    int? stars,
    FxSpecLookup specOf = fxSpecOf,
  }) {
    final oneShot = motion.oneShotSpeed;
    final coinsAt = motion.ms(FxTiming.winCoinsMs);
    final ribbon = FxSegment.whole(specOf(FxId.uiWinRibbon), speed: oneShot);
    final starsStart = motion.ms(FxTiming.winCoinsMs + winCountUpMs);
    final starCues = _starCues(motion, starsStart, stars ?? 0);
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
      countUpEndMs: starsStart,
      twinkle: FxSegment.whole(
        specOf(FxId.fxTwinkle),
        loop: true,
        speed: motion.ambientLoopSpeed,
      ),
      starsStartMs: starsStart,
      starCues: starCues,
      starFlourishCue: stars == StarRating.maxStars && !motion.isReduced
          ? FxCue(
              atMs: starsStart + starSegmentMs * stars! + starFlourishMs,
              haptic: HapticPattern.complete,
            )
          : null,
    );
  }

  /// The "+N" count-up's length at 1× (§9.7, easeOut): from `coins @700`
  /// (LOTTIE.md) to the stars' start (tokens.json `motion.stars.startMs`
  /// 1300), so the count lands as the first star does.
  static const winCountUpMs = StarMotionTokens.startMs - FxTiming.winCoinsMs;

  /// One `ui_stars` star segment (`star_1…star_3`, 20 frames) at 1×, the
  /// gap between two stars' cues (tokens.json `motion.stars.perStarMs`).
  static final double starSegmentMs = FxSpec.msOf(
    StarMotionTokens.segmentFrames.toDouble(),
  );

  /// The 3-star `flourish` segment (frames 60–120), so the success haptic
  /// lands after it (frame 11.3).
  static final double starFlourishMs = FxSpec.msOf(
    (StarMotionTokens.flourishEndFrame - StarMotionTokens.flourishStartFrame)
        .toDouble(),
  );

  /// The cue of each star (1-based) this win earned: `star_1…star_3`'s
  /// sound and a light haptic at each segment's start, [starSegmentMs]
  /// apart. Under reduced motion (Q146, D191) only the highest star's, at
  /// [start], with one light haptic.
  static List<FxCue> _starCues(MotionSpec motion, double start, int stars) {
    if (stars < 1) return const [];
    SoundEffect soundOf(int star) => switch (star) {
      1 => SoundEffect.star1,
      2 => SoundEffect.star2,
      _ => SoundEffect.star3,
    };
    if (motion.isReduced) {
      return [
        FxCue(atMs: start, sound: soundOf(stars), haptic: HapticPattern.pick),
      ];
    }
    return [
      for (var i = 0; i < stars; i++)
        FxCue(
          atMs: start + starSegmentMs * i,
          sound: soundOf(i + 1),
          haptic: HapticPattern.pick,
        ),
    ];
  }

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

  /// [StarRow.reveal]'s `delay` (m7-design P3.7, D149): after both `win`'s
  /// and `coins`' loud parts and the count-up, so the rising clacks are
  /// never masked — the ui-spec's 300 ms sat in `win`'s loudest part, the
  /// architecture's 1,000 ms in the coin burst. 1,300 ms at 1×, 650 ms
  /// under reduced motion (D48).
  final double starsStartMs;

  /// One [FxCue] per star this win earned (empty without stars): `star_n`'s
  /// sound and a light haptic, [starSegmentMs] apart. Under reduced motion
  /// one cue, the highest star's (Q146, D191). `StarRow.reveal`'s `onStar`
  /// fires them as each star starts.
  final List<FxCue> starCues;

  /// The 3-star success haptic (`HapticPattern.complete`, no sound), after
  /// the flourish; null below 3 stars and under reduced motion (no
  /// flourish). Fired by `StarRow.reveal`'s `onFlourishEnd`.
  final FxCue? starFlourishCue;
}
