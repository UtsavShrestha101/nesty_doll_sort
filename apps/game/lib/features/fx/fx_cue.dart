import 'package:nesty_game/core/services/audio/audio_service.dart';
import 'package:nesty_game/core/services/haptics/haptics_service.dart';
import 'package:nesty_game/features/fx/fx_spec.dart';

/// A sound and/or haptic the board timeline fires at a time inside a clip
/// (LOTTIE.md "When each one plays"; m2-lottie-design §7).
///
/// Cues are built once per event, when a batch is scheduled, never per
/// frame. Times are at 1× and scale with the motion speed (reduced motion
/// halves them, PROGRESS D48).
final class FxCue {
  const FxCue({
    required this.atMs,
    this.sound,
    this.haptic,
    this.dollSize,
    this.comboStep,
  }) : assert(sound != null || haptic != null, 'a cue plays something'),
       assert(atMs >= 0);

  /// A cue [frames] composition frames into a clip.
  FxCue.atFrame(
    double frames, {
    SoundEffect? sound,
    HapticPattern? haptic,
    int? dollSize,
    int? comboStep,
  }) : this(
         atMs: FxSpec.msOf(frames),
         sound: sound,
         haptic: haptic,
         dollSize: dollSize,
         comboStep: comboStep,
       );

  /// Offset from the start of the clip (or batch) it belongs to, at 1×.
  final double atMs;

  final SoundEffect? sound;
  final HapticPattern? haptic;

  /// `AudioService.play`'s `dollSize` (the clack pitch).
  final int? dollSize;

  /// `AudioService.play`'s `comboStep` (`complete_{step}`).
  final int? comboStep;

  /// This cue [ms] later, e.g. a clip cue placed on the batch timeline.
  FxCue shifted(double ms) => FxCue(
    atMs: atMs + ms,
    sound: sound,
    haptic: haptic,
    dollSize: dollSize,
    comboStep: comboStep,
  );

  @override
  bool operator ==(Object other) =>
      other is FxCue &&
      other.atMs == atMs &&
      other.sound == sound &&
      other.haptic == haptic &&
      other.dollSize == dollSize &&
      other.comboStep == comboStep;

  @override
  int get hashCode => Object.hash(atMs, sound, haptic, dollSize, comboStep);

  @override
  String toString() =>
      'FxCue(@${atMs.toStringAsFixed(1)} ms, ${sound?.name}, ${haptic?.name})';
}

/// Times inside the files that the timeline sequences on, and the few gaps
/// no file covers. Frame values are read from the exports (the audit's
/// per-file table); `fx_spec_test` checks each against the file's length.
///
/// All at 1× (60 fps frames, or ms where named so).
abstract final class FxTiming {
  /// `doll_nest` / `doll_swallow`: the lid shuts (270 ms). The clack and the
  /// nest haptic fire here, so at `doll_move` 16 f + 16.2 f = 536.7 ms after
  /// the move starts.
  static const nestClackFrame = 16.2;

  /// `doll_invalid`: the mover reaches its closest point and the target
  /// starts shaking (180 ms): `bonk` and the invalid haptic.
  static const invalidImpactFrame = 10.8;

  /// `doll_invalid`'s `target` shake: 3 × 80 ms at ±6 from frame 10.8 to
  /// 25.2. The hand-coded case, ice and silhouette shake uses these same
  /// keyframes (m2-lottie-design §9).
  static const invalidShakeStartFrame = 10.8;
  static const invalidShakeEndFrame = 25.2;
  static const invalidShakeAmplitude = 6.0;
  static const invalidShakeKeyframes = [0.0, -6.0, 6.0, -6.0, 6.0, -6.0, 0.0];

  /// `doll_complete`: the set leaves its slot and flies (700 ms). Dust,
  /// sparkles, unlocks, ice and a destination reveal start here.
  static const completeFlyFrame = 42.0;

  /// `doll_complete`'s `travel` null holds at S until [completeFlyFrame].
  static const completeHoldEndFrame = 42.0;

  /// `ui_family_counter`: the old and new counts swap at the bump's peak.
  static const counterSwapFrame = 6.0;

  /// `fx_glass_unlock`: the freed doll's hop, over which the hand-coded
  /// 11 dp settle onto the stand surface is blended (frames 42–54).
  static const unlockHopStartFrame = 42.0;
  static const unlockHopEndFrame = 54.0;

  /// The 11 dp between the case floor (`caseTop + 123`) and the stand
  /// surface (`caseTop + 134`), in composition units.
  static const unlockSettleUnits = 11.0;

  /// `fx_ice`: one crack segment; stage n rests on frame
  /// `iceStageFrames × n` (0 intact, 16, 32, 48).
  static const iceStageFrames = 16.0;

  /// A sparkle is spawned on the flying set this often, from
  /// [completeFlyFrame] to the end of `doll_complete` (LOTTIE.md).
  static const sparkleIntervalMs = 60.0;

  /// Stagger between the slot events (unlocks, then ice) of one completion,
  /// in core order.
  static const slotEventStaggerMs = 80.0;

  /// From the end of a winning batch to the win overlay.
  static const wonDelayMs = 250.0;

  /// Win overlay: `fx_coin_burst`, the `coins` sound and the count-up
  /// start here.
  static const winCoinsMs = 700.0;

  /// Win overlay: families start hopping this far apart (App Flow 2.8).
  static const winFamilyStaggerMs = 150.0;

  /// Hand-coded (no file): the revealed nest's D21 drop onto the stand and
  /// the deeper silhouettes' one-step shift, before `doll_reveal` plays.
  // TODO(M7): tune by feel (BACKLOG "Animation polish").
  static const revealDropMs = 120.0;
}
