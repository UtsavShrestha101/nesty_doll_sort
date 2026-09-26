import 'package:nesty_core/src/models/equality.dart';
import 'package:nesty_core/src/models/game_state.dart';
import 'package:nesty_core/src/models/move.dart';
import 'package:nesty_core/src/rules/engine/kernel.dart';
import 'package:nesty_core/src/solver/hint.dart';
import 'package:nesty_core/src/solver/solver_run.dart';

/// The outcome of a search (spec §6.3).
enum SolveVerdict {
  /// A winning line was found; with A* it is optimal.
  solved,

  /// The whole reachable state space was searched and no win exists. This is
  /// a proof, so the visited set confirms hash hits (design §3).
  unsolvable,

  /// The node budget ran out first. Never reported as [unsolvable]
  /// (spec §6.3).
  unknown,
}

/// Node budgets of spec §6.3. A node is a distinct canonical state the
/// search stored (design A5).
abstract final class SolverBudgets {
  /// The admin's solvability proof (§5.3 rule 8), and the generator's.
  static const int admin = 500000;

  /// A hint on the device.
  static const int hint = 30000;

  /// The background soft-stuck check after each move (§2.3).
  static const int softStuck = 20000;
}

/// What a search found (spec §6.1, §6.3).
final class SolveResult {
  SolveResult({
    required this.verdict,
    required this.nodes,
    required this.branching,
    List<Move>? solution,
  }) : solution = solution == null ? null : List.unmodifiable(solution);

  final SolveVerdict verdict;

  /// The optimal winning moves from the searched state when [verdict] is
  /// [SolveVerdict.solved], else null. Its length is the level's
  /// `metrics.solverMoves` (spec §5.2).
  final List<Move>? solution;

  /// Distinct canonical states stored (design A5, A19).
  final int nodes;

  /// Successors generated per expanded node (design A19). A display metric
  /// only: determinism tests compare [verdict], [solution] and [nodes].
  final double branching;

  @override
  bool operator ==(Object other) =>
      other is SolveResult &&
      other.verdict == verdict &&
      other.nodes == nodes &&
      other.branching == branching &&
      _solutionEquals(other.solution, solution);

  @override
  int get hashCode => Object.hash(
    verdict,
    nodes,
    branching,
    solution == null ? null : Object.hashAll(solution!),
  );

  @override
  String toString() =>
      'SolveResult(${verdict.name}, '
      '${solution == null ? 'no solution' : '${solution!.length} moves'}, '
      'nodes $nodes)';
}

bool _solutionEquals(List<Move>? a, List<Move>? b) =>
    a == null || b == null ? a == b : listEquals(a, b);

/// The solver of spec §6.2–§6.3: A* over canonical states with
/// `h = nestsOnBoard − setsRemaining`, the §6.3 pruning, node budgets, and
/// hints with the §6.3 fallback.
///
/// Pure and synchronous. The game runs it in its own isolate through
/// [SolverRun] steps or `SolverSnapshot` (CLAUDE.md rule 8); core never
/// imports `dart:isolate` (design §6).
///
/// Every budget counts nodes, never time (spec §6.3), so the same state and
/// budget give the same result on every device and platform. A budget below
/// 1 throws a [RangeError] (see [SolverRun]).
abstract final class Solver {
  /// Searches from [state] until it finds the optimal win, proves there is
  /// none, or stores [budget] nodes.
  ///
  /// A state that is already won is `solved` with an empty solution. Only
  /// an exhausted search is `unsolvable`; running out of budget is
  /// `unknown` (spec §6.3).
  static SolveResult solve(
    GameState state, {
    int budget = SolverBudgets.admin,
  }) {
    final run = SolverRun(state, budget: budget);
    while (!run.advance(budget)) {}
    return run.result;
  }

  /// A resumable search from [state]; see [SolverRun.advance].
  static SolverRun start(GameState state, {int budget = SolverBudgets.admin}) =>
      SolverRun(state, budget: budget);

  /// The hint for [state] (spec §6.3, design A3/A4): the first move of the
  /// solution when solved; the [fallbackHint] when the budget runs out; no
  /// move when the state is proven unsolvable (the game then shows the
  /// soft-stuck banner and charges nothing, D22).
  static HintResult hint(GameState state, {int budget = SolverBudgets.hint}) =>
      hintFrom(state, solve(state, budget: budget));

  /// The hint for [state] given a finished [search] of it, for a caller that
  /// stepped a [SolverRun] itself: the same answer [hint] gives for that
  /// search. A won state gets no move (there is nothing left to do).
  static HintResult hintFrom(GameState state, SolveResult search) {
    switch (search.verdict) {
      case SolveVerdict.solved:
        final solution = search.solution!;
        return HintResult(
          move: solution.isEmpty ? null : solution.first,
          source: solution.isEmpty ? HintSource.none : HintSource.solver,
          verdict: SolveVerdict.solved,
          nodes: search.nodes,
        );
      case SolveVerdict.unsolvable:
        // Owner override (design, D22): a proven dead end gets no move.
        return HintResult(
          source: HintSource.none,
          verdict: SolveVerdict.unsolvable,
          nodes: search.nodes,
        );
      case SolveVerdict.unknown:
        final move = fallbackHint(state);
        return HintResult(
          move: move,
          source: move == null ? HintSource.none : HintSource.fallback,
          verdict: SolveVerdict.unknown,
          nodes: search.nodes,
        );
    }
  }

  /// The soft-stuck check (spec §2.3): only [SolveVerdict.unsolvable] shows
  /// the banner.
  static SolveVerdict softStuck(
    GameState state, {
    int budget = SolverBudgets.softStuck,
  }) => solve(state, budget: budget).verdict;

  /// The hint without search (spec §6.3, design A3): the first legal merge;
  /// else the first placement that isn't pointless (a lone nest from an
  /// open slot into an empty one) and still leaves an empty open slot; else
  /// any placement, preferring one that isn't pointless; null when there is
  /// no legal move. "First" is `Rules.legalMoves` order.
  static Move? fallbackHint(GameState state) {
    final board = GameStateBoard.peek(state);
    final entry = fallbackHintEntry(board);
    if (entry < 0) return null;
    final ids = board.layout.ids;
    return Move(ids[LegalMove.from(entry)], ids[LegalMove.to(entry)]);
  }
}
