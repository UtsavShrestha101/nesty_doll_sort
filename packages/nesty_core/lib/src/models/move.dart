/// A move: pick up the whole nest from slot [from] and drop it on slot [to]
/// (spec §2.2). Both are slot ids (`r0c1`, `x0`, …, see `SlotId`).
///
/// A move is only a request; `Rules.tryMove` decides whether it is legal.
final class Move {
  const Move(this.from, this.to);

  /// The source slot id.
  final String from;

  /// The target slot id.
  final String to;

  @override
  bool operator ==(Object other) =>
      other is Move && other.from == from && other.to == to;

  @override
  int get hashCode => Object.hash(from, to);

  @override
  String toString() => '$from -> $to';
}
