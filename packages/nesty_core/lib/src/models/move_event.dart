import 'package:nesty_core/src/models/doll_color.dart';
import 'package:nesty_core/src/models/nest.dart';

/// Which way a merge went (spec §2.2).
enum NestDirection {
  /// Rule 2: the moving nest `M` goes inside the target's top nest `T`
  /// (`M.outer.size == T.inner.size − 1`).
  inside,

  /// Rule 3, the "swallow": `T` goes inside `M`
  /// (`T.outer.size == M.inner.size − 1`). The merged nest stays in the
  /// target slot.
  swallow,
}

/// Something that happened during one applied move, for the game to animate
/// (spec §4; CLAUDE.md rule 10: Flame renders state and plays these).
///
/// One move yields its events in this order (docs/plans/m1-core-design.md
/// §3, owner override A2):
///
/// 1. [Picked] — the nest leaves its source slot.
/// 2. [Placed] or [NestedInto] — it lands on the target.
/// 3. [Revealed] for the source tower, if its next nest became the top.
/// 4. [Completed] — the merged nest was a full set and left the board.
/// 5. [Revealed] for the destination tower, if the completion uncovered a
///    nest there. It comes after [Completed], because the completed set has
///    to leave before the nest under it shows.
/// 6. [Unlocked] for each glass case of the completed color, in slot order.
/// 7. [IceCracked] or [IceShattered] for each iced slot, in slot order.
/// 8. [Won] or [OutOfMoves], when the move ended the level.
///
/// At most one set completes per move, so 4–7 happen at most once each.
sealed class MoveEvent {
  const MoveEvent();
}

/// The moving nest `M` was lifted out of slot [slotId].
final class Picked extends MoveEvent {
  const Picked({
    required this.slotId,
    required this.nest,
    required this.fromTower,
    required this.leftEmptyTower,
  });

  /// The source slot.
  final String slotId;

  /// The moving nest `M`.
  final Nest nest;

  /// True when the source was a tower holding at least one nest (its top
  /// nest was taken, spec §3.2). A tower that emptied earlier acts as an
  /// open slot, so a pick from it is not "from a tower".
  final bool fromTower;

  /// True when this pick emptied a tower, which is now an open slot
  /// (spec §3.2).
  final bool leftEmptyTower;

  @override
  bool operator ==(Object other) =>
      other is Picked &&
      other.slotId == slotId &&
      other.nest == nest &&
      other.fromTower == fromTower &&
      other.leftEmptyTower == leftEmptyTower;

  @override
  int get hashCode =>
      Object.hash(Picked, slotId, nest, fromTower, leftEmptyTower);

  @override
  String toString() =>
      'Picked($slotId, $nest, fromTower: $fromTower, '
      'leftEmptyTower: $leftEmptyTower)';
}

/// The moving nest landed in the empty slot [slotId] (spec §2.2 rule 1).
final class Placed extends MoveEvent {
  const Placed({
    required this.fromId,
    required this.slotId,
    required this.nest,
  });

  /// The source slot.
  final String fromId;

  /// The target slot, now holding [nest].
  final String slotId;

  /// The moving nest.
  final Nest nest;

  @override
  bool operator ==(Object other) =>
      other is Placed &&
      other.fromId == fromId &&
      other.slotId == slotId &&
      other.nest == nest;

  @override
  int get hashCode => Object.hash(Placed, fromId, slotId, nest);

  @override
  String toString() => 'Placed($fromId -> $slotId, $nest)';
}

/// The moving nest merged with the target's top nest in slot [slotId]
/// (spec §2.2 rules 2 and 3).
final class NestedInto extends MoveEvent {
  const NestedInto({
    required this.fromId,
    required this.slotId,
    required this.direction,
    required this.moving,
    required this.target,
    required this.merged,
  });

  /// The source slot.
  final String fromId;

  /// The target slot, which holds [merged] (until it completes).
  final String slotId;

  /// Whether `M` went inside `T` or swallowed it.
  final NestDirection direction;

  /// The moving nest `M`.
  final Nest moving;

  /// The target's top nest `T` before the merge.
  final Nest target;

  /// The merged nest. Its outer size sets the clack pitch (spec §11.3).
  final Nest merged;

  @override
  bool operator ==(Object other) =>
      other is NestedInto &&
      other.fromId == fromId &&
      other.slotId == slotId &&
      other.direction == direction &&
      other.moving == moving &&
      other.target == target &&
      other.merged == merged;

  @override
  int get hashCode => Object.hash(
    NestedInto,
    fromId,
    slotId,
    direction,
    moving,
    target,
    merged,
  );

  @override
  String toString() =>
      'NestedInto($fromId -> $slotId, ${direction.name}, '
      '$moving + $target = $merged)';
}

/// A tower's next nest became its top and its color shows (spec §3.2).
final class Revealed extends MoveEvent {
  const Revealed({
    required this.slotId,
    required this.nest,
    required this.hiddenBelow,
  });

  /// The tower slot.
  final String slotId;

  /// The new top nest, now in color.
  final Nest nest;

  /// How many nests are still hidden under it.
  final int hiddenBelow;

  @override
  bool operator ==(Object other) =>
      other is Revealed &&
      other.slotId == slotId &&
      other.nest == nest &&
      other.hiddenBelow == hiddenBelow;

  @override
  int get hashCode => Object.hash(Revealed, slotId, nest, hiddenBelow);

  @override
  String toString() => 'Revealed($slotId, $nest, hiddenBelow: $hiddenBelow)';
}

/// The merged nest in [slotId] was a full set: it celebrates, flies to the
/// counter and frees its place (spec §2.1, §4).
final class Completed extends MoveEvent {
  const Completed({
    required this.slotId,
    required this.color,
    required this.setsCompleted,
    required this.totalSets,
    required this.leftEmptyTower,
  });

  /// The slot the full set left.
  final String slotId;

  /// The completed set's color.
  final DollColor color;

  /// Sets completed so far, including this one.
  final int setsCompleted;

  /// Sets in the level (the family counter's denominator).
  final int totalSets;

  /// True when [slotId] is a tower that had nothing left under the set, so
  /// it is now an open slot (spec §3.2).
  final bool leftEmptyTower;

  @override
  bool operator ==(Object other) =>
      other is Completed &&
      other.slotId == slotId &&
      other.color == color &&
      other.setsCompleted == setsCompleted &&
      other.totalSets == totalSets &&
      other.leftEmptyTower == leftEmptyTower;

  @override
  int get hashCode => Object.hash(
    Completed,
    slotId,
    color,
    setsCompleted,
    totalSets,
    leftEmptyTower,
  );

  @override
  String toString() =>
      'Completed($slotId, ${color.id}, $setsCompleted/$totalSets, '
      'leftEmptyTower: $leftEmptyTower)';
}

/// A glass case broke: the first full set of [unlockColor] completed, so the
/// slot is an open slot from now on (spec §3.3).
final class Unlocked extends MoveEvent {
  const Unlocked({required this.slotId, required this.unlockColor});

  final String slotId;

  /// The case's unlock color (the color that just completed).
  final DollColor unlockColor;

  @override
  bool operator ==(Object other) =>
      other is Unlocked &&
      other.slotId == slotId &&
      other.unlockColor == unlockColor;

  @override
  int get hashCode => Object.hash(Unlocked, slotId, unlockColor);

  @override
  String toString() => 'Unlocked($slotId, ${unlockColor.id})';
}

/// A completion lowered the ice on [slotId] to [remaining], still above 0
/// (spec §3.4).
final class IceCracked extends MoveEvent {
  const IceCracked({required this.slotId, required this.remaining});

  final String slotId;

  /// The ice counter after the drop, at least 1.
  final int remaining;

  @override
  bool operator ==(Object other) =>
      other is IceCracked &&
      other.slotId == slotId &&
      other.remaining == remaining;

  @override
  int get hashCode => Object.hash(IceCracked, slotId, remaining);

  @override
  String toString() => 'IceCracked($slotId, remaining: $remaining)';
}

/// The ice on [slotId] reached 0 and shattered; the slot works normally
/// (spec §3.4). A drop from 1 to 0 emits only this event, not an
/// [IceCracked] first (design A9).
final class IceShattered extends MoveEvent {
  const IceShattered({required this.slotId});

  final String slotId;

  @override
  bool operator ==(Object other) =>
      other is IceShattered && other.slotId == slotId;

  @override
  int get hashCode => Object.hash(IceShattered, slotId);

  @override
  String toString() => 'IceShattered($slotId)';
}

/// Every doll is in a completed set: the level is won (spec §2.3).
final class Won extends MoveEvent {
  const Won({required this.moveCount});

  /// Moves made, including this one.
  final int moveCount;

  @override
  bool operator ==(Object other) =>
      other is Won && other.moveCount == moveCount;

  @override
  int get hashCode => Object.hash(Won, moveCount);

  @override
  String toString() => 'Won(moveCount: $moveCount)';
}

/// The level is not won and no legal move is left (spec §2.3, design A22).
/// The game opens the "Out of moves" sheet.
final class OutOfMoves extends MoveEvent {
  const OutOfMoves();

  @override
  bool operator ==(Object other) => other is OutOfMoves;

  @override
  int get hashCode => (OutOfMoves).hashCode;

  @override
  String toString() => 'OutOfMoves()';
}
