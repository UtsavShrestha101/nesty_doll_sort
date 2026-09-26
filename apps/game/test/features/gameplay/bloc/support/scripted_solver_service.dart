import 'dart:async';

import 'package:nesty_core/nesty_core.dart';
import 'package:nesty_game/core/services/solver/solver_service.dart';

/// A [SolverService] a test scripts: it records every request, answers
/// with [onHint] / [onSoftStuck] (core's solver by default), and with
/// [holdHints] / [holdSoftStuck] keeps the answer back until the test
/// completes it, so a move can make it stale first.
final class ScriptedSolverService implements SolverService {
  ScriptedSolverService({
    this.onHint = Solver.hint,
    this.onSoftStuck = Solver.softStuck,
    this.holdHints = false,
    this.holdSoftStuck = false,
  });

  HintResult? Function(GameState state) onHint;
  SolveVerdict? Function(GameState state) onSoftStuck;
  bool holdHints;
  bool holdSoftStuck;

  final List<GameState> hintRequests = [];
  final List<GameState> softStuckRequests = [];
  final List<Completer<HintResult?>> heldHints = [];
  final List<Completer<SolveVerdict?>> heldSoftStuck = [];
  int cancelCount = 0;

  @override
  Future<HintResult?> hint(GameState state) {
    hintRequests.add(state);
    if (!holdHints) return Future.value(onHint(state));
    final held = Completer<HintResult?>();
    heldHints.add(held);
    return held.future;
  }

  @override
  Future<SolveVerdict?> softStuck(GameState state) {
    softStuckRequests.add(state);
    if (!holdSoftStuck) return Future.value(onSoftStuck(state));
    final held = Completer<SolveVerdict?>();
    heldSoftStuck.add(held);
    return held.future;
  }

  @override
  void cancel() => cancelCount++;

  @override
  Future<void> dispose() async {}
}
