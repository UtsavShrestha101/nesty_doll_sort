/// Stable slot ids (spec §4): `r{row}c{col}` for a slot the level defines and
/// `x{n}` for the n-th extra slot, both 0-based (design A7).
///
/// Every API that names a slot (moves, events, undo, the solver snapshot)
/// uses these strings, so a slot keeps its id for the whole level: an emptied
/// tower or a broken lock changes what the slot is, not what it is called.
abstract final class SlotId {
  static const String _extraPrefix = 'x';

  /// The id of the slot at [row] and [col] of the level, such as `r0c1`.
  static String grid(int row, int col) {
    RangeError.checkNotNegative(row, 'row');
    RangeError.checkNotNegative(col, 'col');
    return 'r${row}c$col';
  }

  /// The id of the [n]-th extra slot (spec §3.6), such as `x0`.
  static String extra(int n) {
    RangeError.checkNotNegative(n, 'n');
    return '$_extraPrefix$n';
  }

  /// True for an extra-slot id made by [extra].
  static bool isExtra(String id) => id.startsWith(_extraPrefix);
}

/// Where a slot sits on the board: its shelf [row] (0 is the top shelf) and
/// its [col] within that shelf.
///
/// Extra slots are appended to the bottom shelf (spec §3.6, owner override
/// D22), so `x0` sits at `(lastRow, bottomShelfLength)` and `x1` one column
/// further right.
final class BoardPosition {
  const BoardPosition(this.row, this.col);

  final int row;
  final int col;

  @override
  bool operator ==(Object other) =>
      other is BoardPosition && other.row == row && other.col == col;

  @override
  int get hashCode => Object.hash(row, col);

  @override
  String toString() => '($row, $col)';
}
