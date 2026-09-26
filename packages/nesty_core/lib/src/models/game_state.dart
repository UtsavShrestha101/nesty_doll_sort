import 'package:nesty_core/src/models/doll_color.dart';
import 'package:nesty_core/src/models/level.dart';
import 'package:nesty_core/src/models/slot.dart';
import 'package:nesty_core/src/models/slot_id.dart';
import 'package:nesty_core/src/rules/engine/board.dart';
import 'package:nesty_core/src/rules/engine/board_layout.dart';
import 'package:nesty_core/src/rules/engine/kernel.dart';
import 'package:nesty_core/src/rules/engine/nest_code.dart';

/// An immutable snapshot of a level in play (spec §4 `State`).
///
/// Slots are named by stable ids (`r{row}c{col}`, then `x0`, `x1` for extra
/// slots, see `SlotId`) and read back as [Slot] views: a tower that emptied
/// or a lock that broke shows as an [OpenSlot], and ice shows its current
/// counter (docs/plans/m1-core-design.md §2).
///
/// New states come only from the rules engine (`Rules.tryMove`,
/// `GameSession`); nothing outside core builds one except
/// [GameState.initial].
///
/// Internally a state wraps the engine's packed board (a compiled layout,
/// four header ints and a `Uint16List` of nest codes, design §2), which is
/// never written to again, so a state costs a few dozen bytes and the
/// solver can load it without conversion.
final class GameState {
  GameState._(this._board);

  /// The level's starting board: nothing completed, no moves, no extra slots.
  ///
  /// [level] should pass validation rules 1–6 (spec §5.3). The engine throws
  /// an [ArgumentError] for a level it can't lay out: one with no shelf or
  /// with more slots than it supports (`BoardLayout.maxGridSlots`).
  factory GameState.initial(Level level) =>
      GameState._(Board(BoardLayout.of(level)));

  final Board _board;

  /// The level being played.
  Level get level => _board.layout.level;

  /// Every slot id in board order: the level's grid ids row-major, then the
  /// extra slots `x0`, `x1` that have been added (spec §3.6).
  List<String> get slotIds => _board.layout.activeIds(_board.extraCount);

  /// The current view of the slot [id]. Throws an [ArgumentError] for an id
  /// that is not in [slotIds].
  Slot slot(String id) => _slotView(_indexOf(id));

  /// Where the slot [id] sits. Extra slots are on the bottom shelf, right of
  /// its authored slots (spec §3.6, D22). Throws an [ArgumentError] for an id
  /// that is not in [slotIds].
  BoardPosition positionOf(String id) => _board.layout.positionAt(_indexOf(id));

  /// Full sets completed so far (spec §4 `completedSets`).
  int get completedSets => _board.completedSets;

  /// Full sets in the level; completing them all wins (spec §2.3).
  int get totalSets => _board.layout.totalSets;

  /// Moves applied so far. Undo lowers it again (spec §2.4).
  int get moveCount => _board.moveCount;

  /// Extra slots added so far, 0–2 (spec §3.6).
  int get extraSlotCount => _board.extraCount;

  /// Full sets of [color] completed so far (spec §4 `completedByColor`).
  ///
  /// Derived rather than stored (design §2): every completion of [color]
  /// takes `maxSize` of its dolls off the board, or one fewer when the set
  /// holds the golden doll (§3.5), so rounding the removed count up gives
  /// the sets. Gold itself never forms a set of its own and reads 0.
  int completedOf(DollColor color) {
    if (color.isWild) return 0;
    final layout = _board.layout;
    final cells = _board.cells;
    var remaining = 0;
    for (var i = 0; i < cells.length; i++) {
      final code = cells[i];
      if (code != NestCode.empty && NestCode.color(code) == color.index) {
        remaining += NestCode.ownColorDolls(code);
      }
    }
    final removed = layout.initialDolls[color.index] - remaining;
    final maxSize = layout.maxSize;
    return maxSize <= 0 ? 0 : (removed + maxSize - 1) ~/ maxSize;
  }

  /// True when every set is complete (spec §2.3).
  bool get isWon => completedSets == totalSets;

  int _indexOf(String id) {
    final index = _board.layout.indexOf(id);
    if (index < 0 || index >= _board.activeSlotCount) {
      throw ArgumentError.value(id, 'id', 'No such slot on this board');
    }
    return index;
  }

  Slot _slotView(int index) {
    final board = _board;
    final layout = board.layout;
    final ice = Kernel.iceOf(board, index);
    if (Kernel.isTower(board, index)) {
      final start = layout.cellOffset[index];
      final end = Kernel.topCell(board, index);
      return TowerSlot([
        for (var cell = start; cell <= end; cell++)
          NestCode.toNest(board.cells[cell]),
      ], ice: ice);
    }
    final code = Kernel.top(board, index);
    final nest = code == NestCode.empty ? null : NestCode.toNest(code);
    if (Kernel.isLocked(board, index)) {
      return LockedSlot(
        unlockColor: DollColor.values[layout.unlockColor[index]],
        nest: nest,
        ice: ice,
      );
    }
    // An open or extra slot, an emptied tower or a broken case (§3.2, §3.3).
    return OpenSlot(nest: nest, ice: ice);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GameState &&
          other.hashCode == hashCode &&
          other.level == level &&
          other._board.sameAs(_board);

  // Cached: states are immutable and undo histories compare them.
  @override
  late final int hashCode = Object.hash(level, _board.contentHash);

  @override
  String toString() =>
      'GameState(${level.id}, sets $completedSets/$totalSets, '
      'moves $moveCount, extra $extraSlotCount)';
}

/// Engine access to a state's packed board, for the rules facade, the
/// session, the solver, the simulator and the generator.
///
/// Internal to nesty_core: the barrel exports only [GameState] from this
/// library, so apps can't reach a state's board.
abstract final class GameStateBoard {
  /// The state wrapping [board], which it takes over: the caller must never
  /// change [board] again.
  static GameState adopt(Board board) => GameState._(board);

  /// The state of a copy of [board]; [board] stays the caller's.
  static GameState freeze(Board board) => GameState._(Board.copyOf(board));

  /// The state's own board, for reading only: changing it would change an
  /// immutable state.
  static Board peek(GameState state) => state._board;

  /// A new mutable copy of the state's board.
  static Board thaw(GameState state) => Board.copyOf(state._board);

  /// Copies the state's board into [target], a board of the same layout
  /// shape, without allocating.
  static void load(GameState state, Board target) =>
      target.copyFrom(state._board);
}
