import 'package:nesty_core/nesty_core.dart';
import 'package:nesty_render/nesty_render.dart';

/// The shape the board lays [state] out with (docs/plans/m2-lottie-design.md
/// §5): the level's own slot kinds, so a tower keeps its taller stand and a
/// lock its case for the whole level (a broken lock and an emptied tower read
/// back as open slots in core, but the furniture doesn't change under the
/// dolls), plus the extra slots on the bottom shelf (D22, D172).
///
/// Pure, per event: the game, its tests and the page (which prepares the
/// level's skin for the same geometry) all call it, so they agree.
BoardShape boardShapeOf(GameState state) {
  final level = state.level;
  final rows = <List<SlotShape>>[];
  for (var r = 0; r < level.shelves.length; r++) {
    final shelf = level.shelves[r];
    rows.add([
      for (var c = 0; c < shelf.length; c++)
        SlotShape(
          SlotId.grid(r, c),
          switch (shelf[c]) {
            TowerSlot() => SlotShapeKind.tower,
            LockedSlot() => SlotShapeKind.locked,
            OpenSlot() => SlotShapeKind.open,
          },
          // A sealed size-5 or size-6 doll gets the tall case (m7-3), so the
          // layout needs its size (a case sealed at the start keeps it).
          lockedSize: switch (shelf[c]) {
            LockedSlot(:final nest) => nest?.outerSize,
            _ => null,
          },
        ),
    ]);
  }
  for (final id in state.slotIds) {
    if (SlotId.isExtra(id)) rows.last.add(SlotShape(id, SlotShapeKind.extra));
  }
  return BoardShape(rows: rows, maxSize: level.maxSize);
}

/// [state] laid out on [viewport]: `BoardLayout.compute(boardShapeOf(state),
/// viewport)`.
BoardGeometry boardGeometryOf(GameState state, BoardViewport viewport) =>
    BoardLayout.compute(boardShapeOf(state), viewport);
