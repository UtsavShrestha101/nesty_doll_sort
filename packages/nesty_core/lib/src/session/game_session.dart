import 'package:nesty_core/src/models/game_state.dart';
import 'package:nesty_core/src/models/level.dart';
import 'package:nesty_core/src/models/move.dart';
import 'package:nesty_core/src/models/move_result.dart';
import 'package:nesty_core/src/models/session_types.dart';
import 'package:nesty_core/src/rules/rules.dart';
import 'package:nesty_core/src/validator/layout_limits.dart';

/// One play-through of a level: the current board, the undo history and the
/// extra slots (spec §2.4, §3.6, §4). The game's gameplay bloc and the
/// admin's playtest board both drive one (spec §13.1, §15).
///
/// Moves go through `Rules.tryMove`, so the session adds no rule of its own
/// beyond history and extra-slot bookkeeping (CLAUDE.md rule 2).
///
/// - Undo reverts the last move; the history is cleared when a set
///   completes, so the completing move can't be undone (spec §2.4).
/// - [addExtraSlot] appends an empty open slot to the bottom shelf, at most
///   [maxExtraSlots] per level. It is not a move and pushes no undo entry,
///   and extra slots survive undo and [restart] (owner override D22).
final class GameSession {
  /// Starts [level] from its initial board.
  ///
  /// Throws an [ArgumentError] for a level the engine can't lay out (see
  /// `GameState.initial`).
  GameSession(this.level) : _state = GameState.initial(level);

  /// Resumes [level] at [state] with the undo [history] (oldest first), for
  /// the in-progress save (spec §13.3). [undosUsed] carries the saved count
  /// over, so the free undos of §7.3 aren't granted again on resume.
  ///
  /// Throws an [ArgumentError] when [state] or an entry of [history] is not
  /// a board of [level].
  GameSession.restore(
    this.level,
    GameState state,
    List<UndoEntry> history, {
    int undosUsed = 0,
  }) : _state = state,
       _undosUsed = undosUsed {
    if (state.level != level) {
      throw ArgumentError.value(state, 'state', 'Not a board of ${level.id}');
    }
    for (final entry in history) {
      if (entry.before.level != level) {
        throw ArgumentError.value(entry, 'history', 'Not for ${level.id}');
      }
    }
    RangeError.checkNotNegative(undosUsed, 'undosUsed');
    _history.addAll(history);
  }

  /// Extra slots per level (spec §3.6, D22).
  static const int maxExtraSlots = LayoutLimits.maxExtraSlots;

  /// The level being played.
  final Level level;

  GameState _state;
  final List<UndoEntry> _history = [];
  int _undosUsed = 0;

  /// The current board.
  GameState get state => _state;

  /// Tries the move [from] → [to]. An applied move pushes an undo entry (or
  /// clears the history when it completes a set); a rejected one changes
  /// nothing.
  MoveResult move(String from, String to) {
    final move = Move(from, to);
    final result = Rules.tryMove(_state, move);
    if (result is MoveApplied) {
      if (result.completedSet) {
        // Spec §2.4: completions and unlocks are permanent.
        _history.clear();
      } else {
        _history.add(
          UndoEntry(before: _state, move: move, events: result.events),
        );
      }
      _state = result.state;
    }
    return result;
  }

  /// The undo history, oldest first, for the in-progress save.
  List<UndoEntry> get history => List.unmodifiable(_history);

  /// True when there is a move to undo.
  bool get canUndo => _history.isNotEmpty;

  /// Moves that can be undone in a row right now.
  int get undoDepth => _history.length;

  /// Moves this session has undone (the game charges after the free undos,
  /// spec §7.3). [restart] keeps the count: it counts undos per level, like
  /// the extra slots that also survive a restart (D22).
  int get undosUsed => _undosUsed;

  /// Reverts the last move (spec §2.4) and keeps the current extra slots.
  /// Returns null when there is nothing to undo.
  UndoResult? undo() {
    if (_history.isEmpty) return null;
    final entry = _history.removeLast();
    _state = _withExtraSlots(entry.before, _state.extraSlotCount);
    _undosUsed++;
    return UndoResult(revertedMove: entry.move, restoredState: _state);
  }

  /// True while fewer than [maxExtraSlots] extra slots were added.
  bool get canAddExtraSlot => _state.extraSlotCount < maxExtraSlots;

  /// Adds the next extra slot (`x0`, then `x1`) to the bottom shelf. Returns
  /// null when [canAddExtraSlot] is false.
  ExtraSlotAdded? addExtraSlot() {
    if (!canAddExtraSlot) return null;
    final board = GameStateBoard.thaw(_state)..addExtraSlot();
    _state = GameStateBoard.adopt(board);
    final slotId = _state.slotIds.last;
    return ExtraSlotAdded(
      slotId: slotId,
      position: _state.positionOf(slotId),
      state: _state,
    );
  }

  /// Back to the initial board with the history cleared; extra slots stay
  /// (spec §2.4, D22).
  void restart() {
    final extraSlots = _state.extraSlotCount;
    _state = _withExtraSlots(GameState.initial(level), extraSlots);
    _history.clear();
  }

  /// Spec §2.3.
  bool get isWon => Rules.isWon(_state);

  /// Spec §2.3, design A22.
  bool get isOutOfMoves => Rules.isOutOfMoves(_state);

  /// Sets completed so far.
  int get setsCompleted => _state.completedSets;

  /// Sets in the level.
  int get totalSets => level.totalSets;

  /// `Rules.legalMoves` of the current board.
  List<Move> legalMoves() => Rules.legalMoves(_state);

  /// [state] with [extraSlots] extra slots in play. Extra slots only ever
  /// grow, and one added after [state] was taken is empty in it, so raising
  /// the count restores exactly "that board, plus the current stands".
  static GameState _withExtraSlots(GameState state, int extraSlots) {
    if (state.extraSlotCount == extraSlots) return state;
    final board = GameStateBoard.thaw(state)..extraCount = extraSlots;
    return GameStateBoard.adopt(board);
  }
}
