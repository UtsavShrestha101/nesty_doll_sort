import 'dart:typed_data';

import 'package:nesty_core/src/models/doll_color.dart';
import 'package:nesty_core/src/models/level.dart';
import 'package:nesty_core/src/models/slot.dart';
import 'package:nesty_core/src/models/slot_id.dart';
import 'package:nesty_core/src/rules/engine/nest_code.dart';
import 'package:nesty_core/src/validator/layout_limits.dart';

/// The fixed part of a level's board, compiled once per [Level]
/// (docs/plans/m1-core-design.md §2): every slot's kind, cells, capacity,
/// unlock color and starting ice, plus the starting cells.
///
/// Slots are indexed row-major over the level's shelves (the order of
/// `Level.slotIds`), then the extra slots `x0`, `x1` (spec §3.6). Both extra
/// slots are always reserved, so adding one never re-lays the board out: it
/// only raises `Board.extraCount`. Index order is the `GameState.slotIds`
/// order, which the legal-move order and the solver snapshot rely on.
///
/// Each slot owns [capacity] consecutive cells from [cellOffset]: 1 for an
/// open or locked slot, the starting depth for a tower (towers only lose
/// nests, spec §3.2). A tower's cells run bottom to top and are always a
/// prefix: the top is the highest non-empty cell.
///
/// Internal to nesty_core (not exported by the barrel). The typed lists are
/// shared by every board of the level and must not be written to.
final class BoardLayout {
  BoardLayout._({
    required this.level,
    required this.gridSlotCount,
    required this.kind,
    required this.cellOffset,
    required this.capacity,
    required this.unlockColor,
    required this.initialIce,
    required this.initialCells,
    required this.lockedByColor,
    required this.initialDolls,
    required List<String> ids,
    required List<BoardPosition> positions,
  }) : maxSize = level.maxSize,
       totalSets = level.totalSets,
       slotCount = ids.length,
       cellCount = initialCells.length,
       ids = List.unmodifiable(ids),
       _positions = List.unmodifiable(positions),
       _index = {for (var i = 0; i < ids.length; i++) ids[i]: i},
       _activeIds = List.unmodifiable([
         for (var extra = 0; extra <= LayoutLimits.maxExtraSlots; extra++)
           List<String>.unmodifiable(ids.take(gridSlotCount + extra)),
       ]),
       tops = Int32List(ids.length);

  /// The layout of [level], compiled on first use and cached for that
  /// `Level` instance.
  ///
  /// Throws an [ArgumentError] for a level the engine can't lay out: one
  /// with no shelf (extra slots join the bottom shelf), with more than
  /// [maxGridSlots] slots, or with an ice counter above
  /// [LayoutLimits.maxIce] (it would wrap in [initialIce] and play as
  /// thawed; the validator reports it as `schema.valueOutOfRange`).
  factory BoardLayout.of(Level level) => _cache[level] ??= _compile(level);

  // Identity-keyed, so equal-but-distinct levels compile separately, and a
  // level that is no longer used doesn't keep its layout alive.
  static final Expando<BoardLayout> _cache = Expando('BoardLayout');

  /// [kind] of an open slot, including an extra slot (spec §3.1).
  static const int kindOpen = 0;

  /// [kind] of a tower (spec §3.2).
  static const int kindTower = 1;

  /// [kind] of a glass case (spec §3.3).
  static const int kindLocked = 2;

  /// [unlockColor] of a slot that is not a glass case.
  static const int noColor = -1;

  /// Most slots the engine lays out, extra slots included. Slot masks then
  /// use bits 0–29 only, which stay exact, positive small integers on the
  /// web (design §3). The validator's own limit is lower (spec §5.3 rule 2).
  static const int maxSlotCount = 30;

  /// Most slots a level may define: [maxSlotCount] minus the reserved extra
  /// slots.
  static const int maxGridSlots = maxSlotCount - LayoutLimits.maxExtraSlots;

  /// The level this layout was compiled from.
  final Level level;

  /// The level's `maxSize`: a full set is `maxSize..1` (spec §2.1).
  final int maxSize;

  /// Full sets in the level; completing them all wins (spec §2.3).
  final int totalSets;

  /// Slots the level defines.
  final int gridSlotCount;

  /// [gridSlotCount] plus the reserved extra slots.
  final int slotCount;

  /// Cells over all slots, extra slots included.
  final int cellCount;

  /// Per slot: [kindOpen], [kindTower] or [kindLocked], as the level defines
  /// it. An emptied tower or a broken case is marked in `Board.openedMask`.
  final Uint8List kind;

  /// Per slot: the index of its first cell.
  final Int32List cellOffset;

  /// Per slot: how many cells it owns.
  final Int32List capacity;

  /// Per slot: the `DollColor.index` that breaks its glass case (spec §3.3),
  /// or [noColor].
  final Int32List unlockColor;

  /// Per slot: its ice counter at the start (spec §3.4). The current ice is
  /// `max(0, initialIce − completedSets)`, since every completion anywhere
  /// lowers every counter by 1.
  final Int32List initialIce;

  /// The level's starting cells (nest codes, [NestCode.empty] when empty).
  final Uint16List initialCells;

  /// Per `DollColor.index`: a mask of the glass cases that color unlocks.
  final Int32List lockedByColor;

  /// Per `DollColor.index`: the level's dolls of that color, the golden doll
  /// excluded (spec §5.3 rule 4). Used to derive completions per color.
  final Int32List initialDolls;

  /// Every slot id in index order: the grid ids, then `x0` and `x1`.
  final List<String> ids;

  /// Scratch space for `Kernel` routines that make no calls out while they
  /// use it (legal-move collection). Code runs on one thread per isolate,
  /// so sharing it between the boards of a layout is safe.
  final Int32List tops;

  final List<BoardPosition> _positions;
  final Map<String, int> _index;
  final List<List<String>> _activeIds;

  /// The index of slot [id], extra slots included whether or not they were
  /// added yet, or -1 for an id the layout doesn't have.
  int indexOf(String id) => _index[id] ?? -1;

  /// The first [gridSlotCount] + [extraCount] ids: `GameState.slotIds`.
  List<String> activeIds(int extraCount) => _activeIds[extraCount];

  /// Where slot [index] sits. Extra slot n is at `(lastRow,
  /// bottomShelfLength + n)` (spec §3.6, owner override D22).
  BoardPosition positionAt(int index) => _positions[index];

  /// True when slot [index] is one of the extra slots.
  bool isExtra(int index) => index >= gridSlotCount;

  static BoardLayout _compile(Level level) {
    final shelves = level.shelves;
    if (shelves.isEmpty) {
      throw ArgumentError.value(
        level,
        'level',
        'A level needs a shelf: extra slots join the bottom one (spec §3.6)',
      );
    }
    final grid = level.slotCount;
    if (grid > maxGridSlots) {
      throw ArgumentError.value(
        level,
        'level',
        'The engine lays out at most $maxGridSlots slots, got $grid',
      );
    }
    final slotCount = grid + LayoutLimits.maxExtraSlots;
    final kind = Uint8List(slotCount);
    final cellOffset = Int32List(slotCount);
    final capacity = Int32List(slotCount);
    final unlocks = Int32List(slotCount)..fillRange(0, slotCount, noColor);
    final initialIce = Int32List(slotCount);
    final colors = DollColor.values.length;
    final lockedByColor = Int32List(colors);
    final initialDolls = Int32List(colors);
    final cells = <int>[];
    final ids = <String>[];
    final positions = <BoardPosition>[];

    void addCell(int code) {
      cells.add(code);
      if (code != NestCode.empty) {
        initialDolls[NestCode.color(code)] += NestCode.ownColorDolls(code);
      }
    }

    var index = 0;
    for (var row = 0; row < shelves.length; row++) {
      for (var col = 0; col < shelves[row].length; col++) {
        final slot = shelves[row][col];
        cellOffset[index] = cells.length;
        if (slot.ice > LayoutLimits.maxIce) {
          throw ArgumentError.value(
            level,
            'level',
            'Slot ${SlotId.grid(row, col)} has ice ${slot.ice}; the engine '
                'stores at most ${LayoutLimits.maxIce}',
          );
        }
        initialIce[index] = slot.ice;
        switch (slot) {
          case OpenSlot(:final nest):
            kind[index] = kindOpen;
            capacity[index] = 1;
            addCell(nest == null ? NestCode.empty : NestCode.of(nest));
          case TowerSlot(:final stack):
            kind[index] = kindTower;
            capacity[index] = stack.length;
            for (final nest in stack) {
              addCell(NestCode.of(nest));
            }
          case LockedSlot(:final unlockColor, :final nest):
            kind[index] = kindLocked;
            capacity[index] = 1;
            unlocks[index] = unlockColor.index;
            lockedByColor[unlockColor.index] |= 1 << index;
            addCell(nest == null ? NestCode.empty : NestCode.of(nest));
        }
        ids.add(SlotId.grid(row, col));
        positions.add(BoardPosition(row, col));
        index++;
      }
    }
    final bottomRow = shelves.length - 1;
    final bottomLength = shelves[bottomRow].length;
    for (var n = 0; n < LayoutLimits.maxExtraSlots; n++) {
      cellOffset[index] = cells.length;
      kind[index] = kindOpen;
      capacity[index] = 1;
      cells.add(NestCode.empty);
      ids.add(SlotId.extra(n));
      positions.add(BoardPosition(bottomRow, bottomLength + n));
      index++;
    }
    return BoardLayout._(
      level: level,
      gridSlotCount: grid,
      kind: kind,
      cellOffset: cellOffset,
      capacity: capacity,
      unlockColor: unlocks,
      initialIce: initialIce,
      initialCells: Uint16List.fromList(cells),
      lockedByColor: lockedByColor,
      initialDolls: initialDolls,
      ids: ids,
      positions: positions,
    );
  }
}
