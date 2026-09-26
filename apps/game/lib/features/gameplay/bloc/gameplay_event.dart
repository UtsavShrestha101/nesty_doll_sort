part of 'gameplay_bloc.dart';

/// Everything the gameplay bloc handles, strictly in order (FIFO,
/// `BaseAsyncBloc`). Input events are intents from the Flame board and the
/// HUD (CLAUDE.md rule 10); the result events come back from the solver.
sealed class GameplayEvent {
  const GameplayEvent();
}

/// Load level [levelNumber] (1-based global play order, spec §7.1).
final class GameplayStarted extends GameplayEvent {
  const GameplayStarted(this.levelNumber);

  final int levelNumber;
}

/// A tap on slot [slotId]'s column (hit test: `BoardGeometry.slotAt`). The
/// board drops taps on slots its timeline has reserved.
final class SlotTapped extends GameplayEvent {
  const SlotTapped(this.slotId);

  final String slotId;
}

/// A drag began on slot [slotId]: select it (the board then moves the
/// lifted doll with the finger). Every drag the board starts must end with
/// a [SlotDragDropped], with a null slot when the gesture was cancelled.
final class SlotDragStarted extends GameplayEvent {
  const SlotDragStarted(this.slotId);

  final String slotId;
}

/// The drag was released over slot [slotId], or over no slot (null: cancel).
final class SlotDragDropped extends GameplayEvent {
  const SlotDragDropped(this.slotId);

  final String? slotId;
}

/// Undo on the booster bar or the Out-of-Moves sheet (spec §2.4, §8).
final class UndoPressed extends GameplayEvent {
  const UndoPressed();
}

/// Restart from the pause dialog or the Out-of-Moves sheet (spec §2.4):
/// always free, extra slots kept (D22).
final class RestartPressed extends GameplayEvent {
  const RestartPressed();
}

/// Hint on the booster bar (spec §8, frame 3.1).
final class HintPressed extends GameplayEvent {
  const HintPressed();
}

/// +1 Slot on the booster bar or the Out-of-Moves sheet (spec §3.6, frame
/// 3.6).
final class ExtraSlotPressed extends GameplayEvent {
  const ExtraSlotPressed();
}

/// Continue on the win overlay (frame 2.8): load the next level in play
/// order, or show All Levels Done (frame 4.9) past the last one.
final class NextLevelPressed extends GameplayEvent {
  const NextLevelPressed();
}

/// The pause dialog opened or closed; input is locked while [paused].
final class PauseChanged extends GameplayEvent {
  const PauseChanged({required this.paused});

  final bool paused;
}

/// The soft-stuck debounce (300 ms after the move with [moveSeq]) elapsed.
final class SoftStuckCheckDue extends GameplayEvent {
  const SoftStuckCheckDue(this.moveSeq);

  final int moveSeq;
}

/// A hint came back for the board after move [moveSeq]; dropped when a move
/// has happened since (stale). Null: superseded or failed.
final class HintResultArrived extends GameplayEvent {
  const HintResultArrived({required this.result, required this.moveSeq});

  final HintResult? result;
  final int moveSeq;
}

/// A soft-stuck verdict came back for the board after move [moveSeq];
/// dropped when stale. Null: superseded or failed.
final class SoftStuckResultArrived extends GameplayEvent {
  const SoftStuckResultArrived({required this.verdict, required this.moveSeq});

  final SolveVerdict? verdict;
  final int moveSeq;
}
