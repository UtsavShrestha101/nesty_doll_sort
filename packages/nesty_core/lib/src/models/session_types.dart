import 'package:nesty_core/src/models/equality.dart';
import 'package:nesty_core/src/models/game_state.dart';
import 'package:nesty_core/src/models/move.dart';
import 'package:nesty_core/src/models/move_event.dart';
import 'package:nesty_core/src/models/slot_id.dart';

/// One entry of a `GameSession`'s undo history (spec §2.4): the board
/// [before] the [move], and the [events] the move produced.
///
/// The history is cleared whenever a set completes, so an entry never spans
/// a completion or an unlock (spec §2.4: "Completions and unlocks are
/// permanent"). It is part of the in-progress save (spec §13.3 `undo`).
final class UndoEntry {
  UndoEntry({
    required this.before,
    required this.move,
    required List<MoveEvent> events,
  }) : events = List.unmodifiable(events);

  /// The board before [move].
  final GameState before;

  /// The move this entry reverts.
  final Move move;

  /// What [move] did, so the game can play it backwards.
  final List<MoveEvent> events;

  @override
  bool operator ==(Object other) =>
      other is UndoEntry &&
      other.before == before &&
      other.move == move &&
      listEquals(other.events, events);

  @override
  int get hashCode => Object.hash(before, move, Object.hashAll(events));

  @override
  String toString() => 'UndoEntry($move)';
}

/// What `GameSession.undo()` did: it reverted [revertedMove], and the board is
/// now [restoredState] (spec §2.4).
///
/// Extra slots survive an undo (design §3): [restoredState] has the same
/// extra slots as the board it replaced, even if they were added after the
/// reverted move.
final class UndoResult {
  const UndoResult({required this.revertedMove, required this.restoredState});

  final Move revertedMove;
  final GameState restoredState;

  @override
  bool operator ==(Object other) =>
      other is UndoResult &&
      other.revertedMove == revertedMove &&
      other.restoredState == restoredState;

  @override
  int get hashCode => Object.hash(revertedMove, restoredState);

  @override
  String toString() => 'UndoResult($revertedMove)';
}

/// What `GameSession.addExtraSlot()` did: the empty open slot [slotId] now
/// sits at [position] on the bottom shelf, and the board is [state]
/// (spec §3.6, owner override D22).
///
/// Adding a slot is not a move: it pushes no undo entry and doesn't count
/// toward the move count.
final class ExtraSlotAdded {
  const ExtraSlotAdded({
    required this.slotId,
    required this.position,
    required this.state,
  });

  /// `x0` or `x1`.
  final String slotId;

  /// Bottom shelf, right of its authored slots.
  final BoardPosition position;

  /// The board with the new slot.
  final GameState state;

  @override
  bool operator ==(Object other) =>
      other is ExtraSlotAdded &&
      other.slotId == slotId &&
      other.position == position &&
      other.state == state;

  @override
  int get hashCode => Object.hash(slotId, position, state);

  @override
  String toString() => 'ExtraSlotAdded($slotId at $position)';
}
