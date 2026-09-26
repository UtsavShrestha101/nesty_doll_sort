import 'package:nesty_core/src/models/game_state.dart';
import 'package:nesty_core/src/solver/search.dart';
import 'package:nesty_core/src/solver/solver.dart';

/// A search that runs in steps, so the caller can interleave other work and
/// drop a stale request between steps (design §6): the game's worker isolate
/// calls `advance(2000)` in a loop and abandons the run when a newer request
/// arrives; the web admin awaits between chunks to keep the page responsive.
///
/// Running a fresh `SolverRun` to the end gives exactly the result of
/// `Solver.solve` with the same state and budget, however the work is
/// chunked: the search only pauses between node expansions.
final class SolverRun {
  /// Prepares a search from [state] limited to [budget] stored nodes. No
  /// search work happens until [advance].
  ///
  /// Throws a [RangeError] when [budget] is below 1: the starting board is
  /// always stored, so a search needs room for at least one node.
  SolverRun(this.state, {this.budget = SolverBudgets.admin}) {
    RangeError.checkValueInInterval(budget, 1, maxBudget, 'budget');
  }

  /// The largest budget a run accepts. Node indexes stay well inside the
  /// 32-bit typed lists the search uses, on the VM and the web.
  static const int maxBudget = 0x3FFFFFFF;

  /// The state the search started from.
  final GameState state;

  /// The node budget.
  final int budget;

  AStarSearch? _search;

  /// Searches until the run finishes or about [maxNodes] more nodes are
  /// stored (it stops after the expansion that reaches them). Returns true
  /// when the run is finished ([isDone]). Throws a [RangeError] when
  /// [maxNodes] is below 1.
  bool advance(int maxNodes) {
    if (maxNodes < 1) throw RangeError.range(maxNodes, 1, null, 'maxNodes');
    final search = _search ??= AStarSearch(state, budget);
    return search.advance(maxNodes < maxBudget ? maxNodes : maxBudget);
  }

  /// True once the search found a win, proved there is none, or used up the
  /// budget.
  bool get isDone => _search?.isDone ?? false;

  /// Nodes stored so far.
  int get nodes => _search?.nodes ?? 0;

  /// The result. Throws a [StateError] before [isDone].
  SolveResult get result =>
      _search?.result ??
      (throw StateError('SolverRun.result before the run is done'));
}
