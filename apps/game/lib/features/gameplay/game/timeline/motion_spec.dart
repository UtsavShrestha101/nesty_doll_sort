import 'package:nesty_render/nesty_render.dart' show MotionTokens;

/// How the board plays its motion: the durations, and which motions exist at
/// all (docs/plans/m2-lottie-design.md §13, PROGRESS D48).
///
/// The page reads `MediaQuery.disableAnimationsOf(context)` and passes
/// [MotionSpec.of] into the board timeline. Every one-shot clip, hand-coded
/// tween, cue offset, stagger and delay runs at [durationScale]; loops that
/// carry information stay at 1×.
final class MotionSpec {
  const MotionSpec({
    this.durationScale = 1,
    this.shake = true,
    this.wobble = true,
    this.confetti = true,
    this.ambientLoops = true,
  }) : assert(durationScale > 0);

  /// Everything as authored.
  static const standard = MotionSpec();

  /// Reduced motion (tokens.json `motion.reducedMotion`): one-shots at half
  /// duration, no shake, no wobble, no confetti, ambient loops paused on
  /// frame 0.
  static const reduced = MotionSpec(
    durationScale: MotionTokens.reducedMotionDurationScale,
    shake: MotionTokens.reducedMotionShake,
    wobble: MotionTokens.reducedMotionWobble,
    confetti: MotionTokens.reducedMotionConfetti,
    ambientLoops: false,
  );

  /// [reduced] when the platform asks for less motion, else [standard].
  static MotionSpec of({required bool reduceMotion}) =>
      reduceMotion ? reduced : standard;

  /// Multiplies every one-shot duration, offset, stagger and delay: 1, or
  /// 0.5 under reduced motion.
  final double durationScale;

  /// `doll_invalid`'s target shake, `fx_ice`'s crack shake and the
  /// hand-coded case, ice and silhouette shake (§9.3).
  final bool shake;

  /// `doll_pick`'s wobble loop. Without it the lifted doll holds `lift`'s
  /// last frame.
  final bool wobble;

  /// `fx_confetti` on the win overlay.
  final bool confetti;

  /// `doll_idle`, `fx_twinkle` and `doll_win_hop` loop; without it they
  /// rest on frame 0.
  final bool ambientLoops;

  /// Playback speed of one-shot clips and segments: `1 / durationScale`.
  double get oneShotSpeed => 1 / durationScale;

  /// Playback speed of the loops that carry information (`fx_select_glow`
  /// pulse, `ui_hint_arrow`, `ui_extra_slot`, `ui_booster_glow`): always 1.
  double get informationalLoopSpeed => 1;

  /// Playback speed of ambient loops: 1, or 0 (paused on frame 0).
  double get ambientLoopSpeed => ambientLoops ? 1 : 0;

  /// [ms] at 1× as played at this spec.
  double ms(double ms) => ms * durationScale;

  bool get isReduced => this != standard;

  @override
  bool operator ==(Object other) =>
      other is MotionSpec &&
      other.durationScale == durationScale &&
      other.shake == shake &&
      other.wobble == wobble &&
      other.confetti == confetti &&
      other.ambientLoops == ambientLoops;

  @override
  int get hashCode =>
      Object.hash(durationScale, shake, wobble, confetti, ambientLoops);

  @override
  String toString() =>
      'MotionSpec(×$durationScale, shake: $shake, wobble: $wobble, '
      'confetti: $confetti, ambient: $ambientLoops)';
}
