import 'dart:typed_data';

import 'package:nesty_core/src/models/game_state.dart';
import 'package:nesty_core/src/models/move.dart';
import 'package:nesty_core/src/models/move_result.dart';
import 'package:nesty_core/src/rules/engine/board.dart';
import 'package:nesty_core/src/rules/engine/kernel.dart';
import 'package:nesty_core/src/rules/engine/move_log.dart';
import 'package:nesty_core/src/rules/event_builder.dart';

/// The game rules of spec §4, as queries and moves on a [GameState].
///
/// A thin facade over the allocation-free rules engine
/// (`src/rules/engine/`), which is the only implementation of §4: the
/// session, the solver, the simulator and the generator all run the same
/// code (CLAUDE.md rule 2, docs/plans/m1-core-design.md §0).
abstract final class Rules {
  /// Spec §4 `interactable(slot)`: not iced, and not a glass case that is
  /// still locked. False for an unknown [slotId].
  static bool isInteractable(GameState state, String slotId) {
    final board = GameStateBoard.peek(state);
    final slot = board.layout.indexOf(slotId);
    return Kernel.isInteractable(board, slot);
  }

  /// Spec §4 `canPick(s)`: interactable and holding a nest. False for an
  /// unknown [slotId].
  static bool canPick(GameState state, String slotId) {
    final board = GameStateBoard.peek(state);
    final slot = board.layout.indexOf(slotId);
    return Kernel.canPick(board, slot);
  }

  /// Spec §4 `tryMove(src, dst)`: the board after [move] and its events, or
  /// the reason it is invalid. A rejected move changes nothing.
  static MoveResult tryMove(GameState state, Move move) {
    final board = GameStateBoard.peek(state);
    final layout = board.layout;
    final from = layout.indexOf(move.from);
    final to = layout.indexOf(move.to);
    final outcome = Kernel.check(board, from, to);
    if (!MoveOutcome.isLegal(outcome)) {
      return MoveRejected(move: move, reason: MoveOutcome.reasonOf(outcome));
    }
    final next = Board.copyOf(board);
    final log = MoveLog();
    Kernel.tryApply(next, from, to, log);
    return MoveApplied(
      move: move,
      state: GameStateBoard.adopt(next),
      events: EventBuilder.build(next, log),
      completedSet: log.completed,
    );
  }

  /// Every legal move, ordered by source and then target, each in
  /// `state.slotIds` order. The order is part of the contract: the simulator
  /// and the fallback hint pick from this list, and determinism depends on
  /// it (spec §6.4, §6.5).
  static List<Move> legalMoves(GameState state) {
    final board = GameStateBoard.peek(state);
    final ids = board.layout.ids;
    final buffer = Int32List(Kernel.legalMoveCapacity(board.layout));
    final count = Kernel.collectLegalMoves(board, buffer);
    return List.unmodifiable([
      for (var i = 0; i < count; i++)
        Move(ids[LegalMove.from(buffer[i])], ids[LegalMove.to(buffer[i])]),
    ]);
  }

  /// The slots the nest in [from] can legally be dropped on, in
  /// `state.slotIds` order; empty when [from] can't be picked. The game
  /// highlights these and uses them for the tap policy (D22).
  static List<String> legalTargets(GameState state, String from) {
    final board = GameStateBoard.peek(state);
    final layout = board.layout;
    final source = layout.indexOf(from);
    if (!Kernel.canPick(board, source)) return const [];
    return List.unmodifiable([
      for (var to = 0; to < board.activeSlotCount; to++)
        if (MoveOutcome.isLegal(Kernel.check(board, source, to)))
          layout.ids[to],
    ]);
  }

  /// Spec §2.3: every set is complete.
  static bool isWon(GameState state) =>
      Kernel.isWon(GameStateBoard.peek(state));

  /// Spec §2.3, design A22: not won, and [legalMoves] is empty.
  static bool isOutOfMoves(GameState state) =>
      Kernel.isOutOfMoves(GameStateBoard.peek(state));
}
