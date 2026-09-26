import 'package:nesty_core/src/models/equality.dart';
import 'package:nesty_core/src/models/game_state.dart';
import 'package:nesty_core/src/models/move.dart';
import 'package:nesty_core/src/models/move_event.dart';

/// Why a move was rejected (spec §2.2 "any other drop is invalid", §4
/// `require` lines). A rejected move changes nothing.
///
/// Every reason looks the same to the player (the target shakes and the
/// selection clears, D22); the reason exists for tests, analytics and the
/// admin playtest.
///
/// When several apply, the engine reports the first in this precedence,
/// which follows the order of spec §4 (`src != dst`, then `canPick(src)`
/// where `interactable` is checked before `top(src) != null`, then
/// `interactable(dst)`, then the merge rules): [unknownSlot], [sameSlot],
/// [sourceFrozen], [sourceLocked], [sourceEmpty], [targetFrozen],
/// [targetLocked], [colorMismatch], [sizeMismatch], [targetOccupied].
enum InvalidMoveReason {
  /// `from` or `to` is not an id in `GameState.slotIds`.
  unknownSlot,

  /// `from == to` (spec §4 `require src != dst`). The game treats tapping
  /// the selected slot again as a cancel and never sends this (§2.2).
  sameSlot,

  /// The source slot holds no nest (spec §4 `canPick`: `top(src) != null`).
  sourceEmpty,

  /// The source slot is iced (spec §3.4, §4 `interactable`).
  sourceFrozen,

  /// The source is a glass case that hasn't broken yet (spec §3.3).
  sourceLocked,

  /// The target slot is iced (spec §3.4).
  targetFrozen,

  /// The target is a glass case that hasn't broken yet (spec §3.3).
  targetLocked,

  /// The target's top nest has a different color (spec §4 `colorsMatch`).
  colorMismatch,

  /// Same color, but neither `M.outer.size == T.inner.size − 1` (inside) nor
  /// `T.outer.size == M.inner.size − 1` (swallow) holds (spec §2.2).
  sizeMismatch,

  /// The `else invalid` branch of spec §4 for a target without a top nest
  /// that doesn't accept a placement. Every empty interactable slot kind of
  /// spec §3 accepts one (an empty tower and a broken lock act as open
  /// slots), so the engine should never return this; it keeps the enum
  /// total over §4's branches.
  targetOccupied,
}

/// What `Rules.tryMove` returns: the move was applied, or rejected.
sealed class MoveResult {
  const MoveResult();

  /// The move that was tried.
  Move get move;
}

/// The move was legal: [state] is the board after it, and [events] say what
/// happened, in animation order (see [MoveEvent]).
final class MoveApplied extends MoveResult {
  MoveApplied({
    required this.move,
    required this.state,
    required List<MoveEvent> events,
    required this.completedSet,
  }) : events = List.unmodifiable(events);

  @override
  final Move move;

  /// The board after the move.
  final GameState state;

  /// The move's events, in the order the game animates them.
  final List<MoveEvent> events;

  /// True when the move completed a set, which also clears the undo history
  /// (spec §2.4). At most one set completes per move.
  final bool completedSet;

  @override
  bool operator ==(Object other) =>
      other is MoveApplied &&
      other.move == move &&
      other.state == state &&
      other.completedSet == completedSet &&
      listEquals(other.events, events);

  @override
  int get hashCode => Object.hash(
    MoveApplied,
    move,
    state,
    completedSet,
    Object.hashAll(events),
  );

  @override
  String toString() => 'MoveApplied($move, $events)';
}

/// The move was invalid and nothing changed (spec §2.2).
final class MoveRejected extends MoveResult {
  const MoveRejected({required this.move, required this.reason});

  @override
  final Move move;

  /// The first rule the move broke.
  final InvalidMoveReason reason;

  /// The slot the rejected drop aimed at, which the game shakes (spec §2.2,
  /// D22). Always `move.to`.
  String get targetId => move.to;

  @override
  bool operator ==(Object other) =>
      other is MoveRejected && other.move == move && other.reason == reason;

  @override
  int get hashCode => Object.hash(MoveRejected, move, reason);

  @override
  String toString() => 'MoveRejected($move, ${reason.name})';
}
