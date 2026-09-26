import 'dart:typed_data';

import 'package:nesty_core/src/models/move.dart';
import 'package:nesty_core/src/rules/engine/board.dart';
import 'package:nesty_core/src/rules/engine/kernel.dart';
import 'package:nesty_core/src/solver/solver.dart';

/// Where a hint's move came from.
enum HintSource {
  /// The first move of an optimal solution.
  solver,

  /// The budget ran out, so the §6.3 fallback picked it (design A3).
  fallback,

  /// No move: the state is proven unsolvable, or no legal move exists.
  none,
}

/// The answer to a hint request (spec §4 `hint(state, budget) → Move?`).
final class HintResult {
  const HintResult({
    required this.source,
    required this.verdict,
    required this.nodes,
    this.move,
  });

  /// The suggested move, or null when [source] is [HintSource.none].
  final Move? move;

  final HintSource source;

  /// The search verdict behind the hint. [SolveVerdict.unsolvable] means the
  /// game shows the soft-stuck banner and charges nothing (D22).
  final SolveVerdict verdict;

  /// Nodes the search stored.
  final int nodes;

  @override
  bool operator ==(Object other) =>
      other is HintResult &&
      other.move == move &&
      other.source == source &&
      other.verdict == verdict &&
      other.nodes == nodes;

  @override
  int get hashCode => Object.hash(move, source, verdict, nodes);

  @override
  String toString() =>
      'HintResult(${move ?? 'no move'}, ${source.name}, ${verdict.name}, '
      'nodes $nodes)';
}

/// The fallback hint of spec §6.3 and design A3 on [board], as a
/// `LegalMove` entry, or -1 when there is no legal move:
/// 1. the first legal merge (a merge never takes an empty slot, so it is
///    §6.3's "first legal merge that doesn't take the last empty slot");
/// 2. else the first placement that isn't pointless (a lone nest from an
///    open slot into an empty one, §6.3) and still leaves an empty open slot
///    to play into;
/// 3. else A3's "any placement" ("any move into an empty slot", §6.3): the
///    first one that isn't pointless, so the hint never suggests a move
///    that changes nothing while a real one exists, else the first
///    placement.
///
/// "First" is `Rules.legalMoves` order. Internal to nesty_core; used by
/// `Solver.fallbackHint` and the isolate snapshot.
int fallbackHintEntry(Board board) {
  final moves = Int32List(Kernel.legalMoveCapacity(board.layout));
  final count = Kernel.collectLegalMoves(board, moves);
  for (var i = 0; i < count; i++) {
    if (MoveOutcome.isMerge(LegalMove.outcome(moves[i]))) return moves[i];
  }
  // No merge, so every legal move is a placement. Every open-like source
  // holds a lone nest (spec §3.1), so its placements are the pointless ones;
  // the others come from towers.
  final after = Board.copyOf(board);
  var firstUseful = -1;
  for (var i = 0; i < count; i++) {
    final entry = moves[i];
    final from = LegalMove.from(entry);
    if (Kernel.isOpenLike(board, from)) continue;
    if (firstUseful < 0) firstUseful = entry;
    after.copyFrom(board);
    Kernel.tryApply(after, from, LegalMove.to(entry));
    if (_hasEmptyOpenSlot(after)) return entry;
  }
  if (firstUseful >= 0) return firstUseful;
  return count == 0 ? -1 : moves[0];
}

/// True when some slot in play is open-like, usable (not iced, not a
/// locked case) and empty: somewhere a placement can go (spec §3.1, §4).
bool _hasEmptyOpenSlot(Board board) {
  for (var slot = 0; slot < board.activeSlotCount; slot++) {
    if (Kernel.isOpenLike(board, slot) &&
        Kernel.isInteractable(board, slot) &&
        Kernel.topCell(board, slot) < 0) {
      return true;
    }
  }
  return false;
}
