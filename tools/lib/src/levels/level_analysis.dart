import 'package:nesty_core/nesty_core.dart';

/// Spec §5.3 rule 8's codes: a level that fails only these still plays
/// (rules 1–7 hold), so it can be simulated.
const Set<String> _rule8Codes = {IssueCodes.unsolvable, IssueCodes.unproven};

/// Validation (rules 1–8), the rule-8 solve and the simulation of one level:
/// the numbers the admin shows (spec §5.2 `metrics`, §6.1).
final class LevelAnalysis {
  const LevelAnalysis(this.validation, this.simulation);

  /// The validator's report. Its `solve` is the rule-8 search, when it ran.
  final ValidationReport validation;

  /// The simulation, when rules 1–7 hold and it was asked for.
  final SimulationResult? simulation;

  bool get isValid => validation.isValid;

  SolveResult? get solve => validation.solve;

  /// Spec §5.2 `metrics.solverMoves`: the optimal solution's length.
  int? get solverMoves => solve?.solution?.length;

  /// The star rating's par (spec-prop §7.10, D146): [solverMoves] when rule
  /// 8 solved the level, which `bundle build` writes and `bundle check`
  /// compares. Null when rule 8 didn't solve it, and for a board already won
  /// at its start (a par is 1 or more).
  int? get par {
    final moves = solverMoves;
    return moves != null && moves >= 1 ? moves : null;
  }
}

/// Runs the one validator (with [options]) and, when [simulate] and rules
/// 1–7 hold, the simulator with [simulatorParams] (CLAUDE.md rule 2: every
/// number comes from nesty_core).
LevelAnalysis analyzeLevel(
  Level level, {
  ValidationOptions options = ValidationOptions.admin,
  bool simulate = true,
  SimulatorParams simulatorParams = const SimulatorParams(),
}) {
  final report = Validator.validate(level, options: options);
  final playable = !report.issues.any(
    (issue) => issue.isError && !_rule8Codes.contains(issue.code),
  );
  return LevelAnalysis(
    report,
    simulate && playable ? Simulator.run(level, simulatorParams) : null,
  );
}

/// `wins/runs` as a percentage with one decimal, rounded down: `65.3%`.
String percent(BotStats stats) {
  final tenths = stats.wins * 1000 ~/ stats.runs;
  return '${tenths ~/ 10}.${tenths % 10}%';
}

/// A move list as `r0c0>r0c2 r1c1>r0c0`.
String movesText(List<Move> moves) =>
    moves.map((m) => '${m.from}>${m.to}').join(' ');
