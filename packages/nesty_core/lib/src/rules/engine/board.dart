import 'dart:typed_data';

import 'package:nesty_core/src/rules/engine/board_layout.dart';
import 'package:nesty_core/src/validator/layout_limits.dart';

/// The dynamic part of a board in play: a header of four ints plus one
/// `Uint16List` of nest codes (docs/plans/m1-core-design.md §2). The
/// `Kernel` is the only code that applies moves to it (CLAUDE.md rule 2).
///
/// - [cells]: one nest code per cell of the [layout].
/// - [completedSets]: full sets completed. Current ice and completions per
///   color are derived from it and the cells, not stored.
/// - [openedMask]: bit i set when slot i was a tower that emptied or a glass
///   case that broke; both then act as open slots (spec §3.2, §3.3).
/// - [extraCount]: extra slots added, 0–2 (spec §3.6).
/// - [moveCount]: moves applied (spec §4 `moveCount`).
///
/// Mutable on purpose: the solver and the simulator reuse boards instead of
/// allocating per move (CLAUDE.md rule 8). A `GameState` wraps a board that
/// is never written again.
///
/// Internal to nesty_core (not exported by the barrel).
final class Board {
  /// The layout's starting board: nothing completed, no moves, no extras.
  Board(this.layout) : cells = Uint16List.fromList(layout.initialCells);

  /// An independent copy of [other].
  Board.copyOf(Board other)
    : layout = other.layout,
      cells = Uint16List.fromList(other.cells),
      completedSets = other.completedSets,
      openedMask = other.openedMask,
      extraCount = other.extraCount,
      moveCount = other.moveCount;

  final BoardLayout layout;
  final Uint16List cells;
  int completedSets = 0;
  int openedMask = 0;
  int extraCount = 0;
  int moveCount = 0;

  /// Slots in play: the level's plus the extra slots added so far. Slot
  /// indexes from here to `layout.slotCount` are reserved, empty extras.
  int get activeSlotCount => layout.gridSlotCount + extraCount;

  /// Back to the layout's starting board; with [keepExtraSlots] the added
  /// extra slots stay, empty (owner override D22: they survive Restart).
  void reset({bool keepExtraSlots = false}) {
    cells.setAll(0, layout.initialCells);
    completedSets = 0;
    openedMask = 0;
    moveCount = 0;
    if (!keepExtraSlots) extraCount = 0;
  }

  /// Makes this board equal to [other], which must have the same layout
  /// shape. Allocation-free.
  void copyFrom(Board other) {
    if (other.cells.length != cells.length) {
      throw ArgumentError.value(other, 'other', 'Board of another layout');
    }
    cells.setAll(0, other.cells);
    completedSets = other.completedSets;
    openedMask = other.openedMask;
    extraCount = other.extraCount;
    moveCount = other.moveCount;
  }

  /// Adds the next extra slot (spec §3.6). Returns false when both are in
  /// play already.
  bool addExtraSlot() {
    if (extraCount >= LayoutLimits.maxExtraSlots) return false;
    extraCount++;
    return true;
  }

  /// True when [other] holds the same header and cells.
  bool sameAs(Board other) {
    if (completedSets != other.completedSets ||
        openedMask != other.openedMask ||
        extraCount != other.extraCount ||
        moveCount != other.moveCount ||
        cells.length != other.cells.length) {
      return false;
    }
    for (var i = 0; i < cells.length; i++) {
      if (cells[i] != other.cells[i]) return false;
    }
    return true;
  }

  /// A hash consistent with [sameAs], for in-memory use only.
  int get contentHash => Object.hash(
    completedSets,
    openedMask,
    extraCount,
    moveCount,
    Object.hashAll(cells),
  );
}
