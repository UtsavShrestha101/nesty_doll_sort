import 'package:nesty_core/nesty_core.dart';
import 'package:nesty_game/features/gameplay/bloc/tap_policy.dart'
    show SlotNudgeKind;

/// What the board must show for one bloc transition: the Flame board plays
/// it through the board timeline, then settles on `GameplayState.board`
/// (m2-lottie-design §7, §11; CLAUDE.md rule 10: the board never owns game
/// truth).
///
/// Named `…Effect` so none clashes with nesty_core's exported `MoveApplied`,
/// `MoveRejected`, `ExtraSlotAdded`, `Completed`, `Won` or `Placed`
/// (PROGRESS D27, D52). Each new effect comes with a new
/// `GameplayState.effectSeq`, so an effect equal to the previous one still
/// reaches the page's `BlocListener`.
sealed class BoardEffect {
  const BoardEffect();
}

/// The selection moved (tap policy, frame 2.6; PROGRESS D22).
///
/// [previous] settles (`doll_pick` settle, `fx_select_glow` out) and
/// [selected] lifts (`doll_pick` lift then wobble, glow in then pulse,
/// `pick` sound and haptic). With [byDrag] and no [selected], a drag was
/// released over nothing (or back over its own slot): the doll returns from
/// the finger to [previous] by `doll_move` (drag cancel).
///
/// With [byDrag] and [selected], a drag picked [selected] up. When a tap had
/// already lifted that same nest, [previous] is null: the doll is already
/// in the air, so nothing settles and the drag holds it from there.
final class SelectionChangedEffect extends BoardEffect {
  const SelectionChangedEffect({
    this.previous,
    this.selected,
    this.byDrag = false,
  });

  final String? previous;
  final String? selected;
  final bool byDrag;

  @override
  bool operator ==(Object other) =>
      other is SelectionChangedEffect &&
      other.previous == previous &&
      other.selected == selected &&
      other.byDrag == byDrag;

  @override
  int get hashCode =>
      Object.hash(SelectionChangedEffect, previous, selected, byDrag);

  @override
  String toString() =>
      'SelectionChangedEffect($previous -> $selected, byDrag: $byDrag)';
}

/// Core applied a move: play its `MoveEvent`s in order. With [byDrag], the
/// flight starts from where the finger released the doll, not from the
/// lifted pose over the source.
final class MoveAppliedEffect extends BoardEffect {
  const MoveAppliedEffect({required this.result, this.byDrag = false});

  /// nesty_core's result: the move, the board after it and its events.
  final MoveApplied result;
  final bool byDrag;

  @override
  bool operator ==(Object other) =>
      other is MoveAppliedEffect &&
      other.result == result &&
      other.byDrag == byDrag;

  @override
  int get hashCode => Object.hash(MoveAppliedEffect, result, byDrag);

  @override
  String toString() => 'MoveAppliedEffect(${result.move}, byDrag: $byDrag)';
}

/// Core rejected [source] → [target] (or the tap policy made it invalid):
/// the target shakes, the lifted nest drifts back and the selection clears
/// (`doll_invalid`; after a drag, `doll_move` back from the finger plus
/// `doll_invalid` with the mover hidden). `bonk` and the invalid haptic at
/// 180 ms.
final class MoveRejectedEffect extends BoardEffect {
  const MoveRejectedEffect({
    required this.source,
    required this.target,
    required this.reason,
    this.byDrag = false,
  });

  final String source;
  final String target;

  /// Core's reason; every reason looks the same to the player (D22).
  final InvalidMoveReason reason;
  final bool byDrag;

  @override
  bool operator ==(Object other) =>
      other is MoveRejectedEffect &&
      other.source == source &&
      other.target == target &&
      other.reason == reason &&
      other.byDrag == byDrag;

  @override
  int get hashCode =>
      Object.hash(MoveRejectedEffect, source, target, reason, byDrag);

  @override
  String toString() =>
      'MoveRejectedEffect($source -> $target, ${reason.name}, '
      'byDrag: $byDrag)';
}

/// Why the whole board was replaced.
enum BoardResetReason {
  /// The level was loaded.
  start,

  /// Restart (spec §2.4): the initial board, extra slots kept (D22).
  restart,

  /// Undo (spec §2.4): the board before [BoardResetEffect.undo]'s move.
  undo,
}

/// Replace the board with [snapshot] without replaying events: clips are
/// cancelled, reservations cleared, sprites rebuilt. The selection and the
/// hint are gone too (the state has none). An undo may animate the reverted
/// nest back from its target to its source (M7 polish); the others cut.
final class BoardResetEffect extends BoardEffect {
  const BoardResetEffect({
    required this.snapshot,
    required this.reason,
    this.undo,
  });

  final GameState snapshot;
  final BoardResetReason reason;

  /// Set when [reason] is [BoardResetReason.undo].
  final UndoResult? undo;

  @override
  bool operator ==(Object other) =>
      other is BoardResetEffect &&
      other.snapshot == snapshot &&
      other.reason == reason &&
      other.undo == undo;

  @override
  int get hashCode => Object.hash(BoardResetEffect, snapshot, reason, undo);

  @override
  String toString() => 'BoardResetEffect(${reason.name})';
}

/// Show the hint (frame 3.1): `ui_hint_arrow` over [move]'s source, the
/// dashed arc, `fx_select_glow` on its target. Cleared by any tap.
final class HintShownEffect extends BoardEffect {
  const HintShownEffect(this.move);

  final Move move;

  @override
  bool operator ==(Object other) =>
      other is HintShownEffect && other.move == move;

  @override
  int get hashCode => Object.hash(HintShownEffect, move);

  @override
  String toString() => 'HintShownEffect($move)';
}

/// Remove the hint's arrow, arc and target glow.
final class HintClearedEffect extends BoardEffect {
  const HintClearedEffect();

  @override
  bool operator ==(Object other) => other is HintClearedEffect;

  @override
  int get hashCode => (HintClearedEffect).hashCode;

  @override
  String toString() => 'HintClearedEffect()';
}

/// +1 Slot (frame 3.6): the bottom row re-pitches over 300 ms and the new
/// stand starts pulsing (`ui_extra_slot`). No cue of its own: whatever
/// button the player tapped (the booster bar, the buy popup's confirm)
/// already played `button` + the selection haptic when it activated
/// (`TactileSurface`), so the timeline doesn't repeat it (BACKLOG "+1 Slot
/// plays button twice"; review fix pass, m2-lottie-design §7).
final class ExtraSlotAddedEffect extends BoardEffect {
  const ExtraSlotAddedEffect(this.result);

  /// nesty_core's result: the new slot, where it sits, and the board.
  final ExtraSlotAdded result;

  @override
  bool operator ==(Object other) =>
      other is ExtraSlotAddedEffect && other.result == result;

  @override
  int get hashCode => Object.hash(ExtraSlotAddedEffect, result);

  @override
  String toString() => 'ExtraSlotAddedEffect(${result.slotId})';
}

/// A tap on an unpickable slot with nothing lifted (E.13; frame 12.13;
/// `TapPolicy.tap`'s `NudgeSlot`): the board plays [kind]'s nudge on
/// [slotId] (the empty stand's dip, the padlock's ping or the ice counter's
/// bump; lane B), never the invalid shake. Nothing else changes.
final class SlotNudgeEffect extends BoardEffect {
  const SlotNudgeEffect(this.slotId, this.kind);

  final String slotId;
  final SlotNudgeKind kind;

  @override
  bool operator ==(Object other) =>
      other is SlotNudgeEffect && other.slotId == slotId && other.kind == kind;

  @override
  int get hashCode => Object.hash(SlotNudgeEffect, slotId, kind);

  @override
  String toString() => 'SlotNudgeEffect($slotId, ${kind.name})';
}
