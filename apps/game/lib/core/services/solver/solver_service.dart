import 'package:nesty_core/nesty_core.dart';

/// Runs the nesty_core solver off the UI isolate for the gameplay bloc
/// (spec §2.3, §6.3; CLAUDE.md rule 8).
///
/// The real implementation, `IsolateSolverService`, keeps one long-lived
/// worker isolate: it sends `SolverSnapshot.encode(state)` with a request
/// id, steps `SolverSnapshot.start(...)` with `advance(2000)` and an await
/// between chunks (`solver_worker.dart`), and maps the result with
/// `SolverSnapshot.readHint` / `readVerdict` on the calling side.
///
/// **Latest wins:** one request is in flight at a time. A new request (of
/// either kind) or [cancel] supersedes the running one, whose future then
/// completes with null. The bloc never awaits these inside `handleEvent`:
/// results come back as events tagged with the move sequence they were
/// asked for, and stale ones are dropped (m2-lottie-design §11).
///
/// Never throws: a worker that fails or can't start completes with null
/// (the hint then uses core's `Solver.fallbackHint`).
abstract interface class SolverService {
  /// The hint for [state]: `Solver.hint` with `SolverBudgets.hint` (30k
  /// nodes). A `HintResult` with no move and verdict `unsolvable` is the
  /// soft-stuck answer (D22: no move, nothing charged).
  Future<HintResult?> hint(GameState state);

  /// The soft-stuck check for [state]: `Solver.softStuck` with
  /// `SolverBudgets.softStuck` (20k nodes). Only `unsolvable` shows the
  /// banner (spec §2.3).
  Future<SolveVerdict?> softStuck(GameState state);

  /// Supersedes the request in flight, if any.
  void cancel();

  /// Stops the worker. Pending futures complete with null.
  Future<void> dispose();
}
