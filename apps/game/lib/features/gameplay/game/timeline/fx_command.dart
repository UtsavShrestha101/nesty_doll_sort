import 'package:nesty_core/nesty_core.dart';
import 'package:nesty_game/features/fx/fx_id.dart';
import 'package:nesty_game/features/gameplay/bloc/board_effect.dart';
import 'package:nesty_game/features/gameplay/game/timeline/fx_clip.dart';
import 'package:nesty_game/features/gameplay/game/timeline/fx_placement.dart';
import 'package:nesty_game/features/gameplay/game/timeline/fx_segment.dart';
import 'package:nesty_game/features/gameplay/game/timeline/hand_tween.dart';

/// Executes the board timeline's commands: the Flame board
/// (docs/plans/m2-lottie-design.md §7, §10, §16 "Flame board").
///
/// **Timing protocol.** Commands arrive from `BoardTimeline.advance(dt)`
/// (and from `schedule`, for the batch's time-0 commands) in time order;
/// commands due in one call run in the same frame, before anything renders.
/// [lateMs] (≥ 0) is how long ago the command was due: place a new or
/// re-segmented clip that far into its segment. Advance the live clips'
/// own players by `dt` *before* calling `advance`, so a command's clip is
/// not advanced twice in its first frame.
abstract interface class FxCommandSink {
  void execute(FxCommand command, double lateMs);
}

/// One thing the board does at [atMs] into its batch (real ms, at the
/// batch's motion speed).
sealed class FxCommand {
  const FxCommand(this.atMs) : assert(atMs >= 0);

  final double atMs;
}

/// Take a component from [clip]'s pool, place it and play [segment]. Hide
/// the top-doll sprite of every slot in `clip.hides` from now on.
final class StartClip extends FxCommand {
  const StartClip(super.atMs, this.clip, this.segment);

  final FxClip clip;
  final FxSegment segment;

  @override
  String toString() => '@${atMs.toStringAsFixed(1)} start $clip $segment';
}

/// Switch the live [clip] to [segment]: `doll_pick` lift → wobble or hold →
/// settle, `fx_select_glow` in → pulse → out, an ice stage.
final class PlayClipSegment extends FxCommand {
  const PlayClipSegment(super.atMs, this.clip, this.segment);

  final FxClip clip;
  final FxSegment segment;

  @override
  String toString() => '@${atMs.toStringAsFixed(1)} play $clip $segment';
}

/// Move the live [clip] to [placement] with [params]: the layout changed
/// under it (the +1 Slot re-pitch, §9.5).
final class PlaceClip extends FxCommand {
  const PlaceClip(super.atMs, this.clip, this.placement, this.params);

  final FxClip clip;
  final FxPlacement placement;
  final FxClipParams params;

  @override
  String toString() => '@${atMs.toStringAsFixed(1)} place $clip $placement';
}

/// The live [clip] no longer draws its slots' dolls (the completed set took
/// off at t0 + 700): stop hiding `clip.hides`, keep playing.
final class ReleaseClipSlots extends FxCommand {
  const ReleaseClipSlots(super.atMs, this.clip);

  final FxClip clip;

  @override
  String toString() => '@${atMs.toStringAsFixed(1)} release $clip';
}

/// Return the live [clip] to its pool and stop hiding `clip.hides` (if
/// `ReleaseClipSlots` hasn't already).
final class StopClip extends FxCommand {
  const StopClip(super.atMs, this.clip);

  final FxClip clip;

  @override
  String toString() => '@${atMs.toStringAsFixed(1)} stop $clip';
}

/// Play [segment] on [slotId]'s own paused composition ([fx] is
/// `fxGlassUnlock` or `fxIce`, §8): the unlock, a crack, the shatter, or a
/// hold on the new rest frame (re-record the cached rest picture). [shake]
/// is false under reduced motion (`fx_ice`'s `ice` null goes static).
final class PlaySlotFx extends FxCommand {
  const PlaySlotFx(
    super.atMs,
    this.slotId,
    this.fx,
    this.segment, {
    this.shake = true,
  });

  final String slotId;
  final FxId fx;
  final FxSegment segment;
  final bool shake;

  @override
  String toString() =>
      '@${atMs.toStringAsFixed(1)} slotFx $slotId ${fx.fileName} $segment';
}

/// [slotId]'s [fx] composition is done (unlocked or shattered): dispose it
/// and its cached rest picture. From now on the slot's sprite draws its
/// doll (a slot draws no sprite while it has a composition).
final class ReleaseSlotFx extends FxCommand {
  const ReleaseSlotFx(super.atMs, this.slotId, this.fx);

  final String slotId;
  final FxId fx;

  @override
  String toString() =>
      '@${atMs.toStringAsFixed(1)} releaseSlotFx $slotId ${fx.fileName}';
}

/// From now on [slotId]'s rest sprites follow [state]: its top doll (at the
/// base its slot view in [state] implies: the case floor only while it is a
/// `LockedSlot`), its buried silhouettes, the "+N" tower tag, the pips and
/// the ice badge. Doesn't touch the slot's composition.
///
/// Until its first `SyncSlot` in a batch a slot keeps showing what it
/// showed before, so the landing, the take-off and the counts change
/// exactly when the table says (§7, §9.6).
final class SyncSlot extends FxCommand {
  const SyncSlot(super.atMs, this.slotId, this.state);

  final String slotId;
  final GameState state;

  @override
  String toString() => '@${atMs.toStringAsFixed(1)} sync $slotId';
}

/// Start drawing with [tween] (§9) and hide `tween.hides`' top sprites.
final class StartTween extends FxCommand {
  const StartTween(super.atMs, this.tween);

  final HandTween tween;

  @override
  String toString() =>
      '@${atMs.toStringAsFixed(1)} tween ${tween.runtimeType} '
      '${tween.slotId ?? ''}';
}

/// [tween] reached its end: stop applying it (commit a `RepitchTween`'s
/// new layout) and show `tween.hides` again.
final class EndTween extends FxCommand {
  const EndTween(super.atMs, this.tween);

  final HandTween tween;

  @override
  String toString() =>
      '@${atMs.toStringAsFixed(1)} endTween ${tween.runtimeType} '
      '${tween.slotId ?? ''}';
}

/// Show the hint's dashed arc from [move]'s source to its target (frame
/// 3.1, a static path), or hide it when [move] is null.
final class SetHintArc extends FxCommand {
  const SetHintArc(super.atMs, this.move);

  final Move? move;

  @override
  String toString() => '@${atMs.toStringAsFixed(1)} hintArc $move';
}

/// A completed set reached the family counter: the HUD's `onFamilyLanded`
/// bumps `ui_family_counter` to [setsCompleted] / [totalSets] and plays a
/// sparkle [sparkleScale]× the trail's over the counter (§7).
final class FamilyLanded extends FxCommand {
  const FamilyLanded(
    super.atMs, {
    required this.setsCompleted,
    required this.totalSets,
    this.sparkleScale = LottieGeometry.counterSparkleScale,
  });

  final int setsCompleted;
  final int totalSets;
  final double sparkleScale;

  @override
  String toString() =>
      '@${atMs.toStringAsFixed(1)} familyLanded $setsCompleted/$totalSets';
}

/// The winning batch is done (+ `FxTiming.wonDelayMs`): `onWon` opens the
/// win overlay.
final class BoardWon extends FxCommand {
  const BoardWon(super.atMs, {required this.moveCount});

  final int moveCount;

  @override
  String toString() => '@${atMs.toStringAsFixed(1)} won';
}

/// The board went idle after the move that left no legal move:
/// `onOutOfMoves` opens the sheet (frame 3.5).
final class BoardOutOfMoves extends FxCommand {
  const BoardOutOfMoves(super.atMs);

  @override
  String toString() => '@${atMs.toStringAsFixed(1)} outOfMoves';
}

/// The board was replaced ([BoardResetEffect]): return every clip to its
/// pool, end every tween, clear every sprite hide, and rebuild sprites and
/// the paused glass/ice compositions from [snapshot] (glass on frame 0,
/// ice on `BoardTimeline.iceRestFrame`).
final class ResetBoard extends FxCommand {
  const ResetBoard(super.atMs, this.snapshot, this.reason);

  final GameState snapshot;
  final BoardResetReason reason;

  @override
  String toString() => '@${atMs.toStringAsFixed(1)} reset ${reason.name}';
}
