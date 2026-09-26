import 'package:nesty_core/src/codec/level_codec.dart';
import 'package:nesty_core/src/codec/level_issue.dart';
import 'package:nesty_core/src/models/equality.dart';
import 'package:nesty_core/src/models/game_state.dart';
import 'package:nesty_core/src/models/level.dart';
import 'package:nesty_core/src/rules/rules.dart';
import 'package:nesty_core/src/solver/solver.dart';
import 'package:nesty_core/src/validator/level_checks.dart';

/// A search that proves a level solvable for rule 8 (spec §5.3, §6.3).
/// `Solver.solve` has this shape and is the default; tests pass fakes.
typedef LevelSolver = SolveResult Function(GameState state, {int budget});

/// What the [Validator] checks.
final class ValidationOptions {
  const ValidationOptions({
    this.checkSolvable = true,
    this.solverBudget = SolverBudgets.admin,
    this.solver = Solver.solve,
  });

  /// The admin and the level tools: rules 1–8, rule 8 with the admin budget
  /// (spec §5.3, §6.3).
  static const ValidationOptions admin = ValidationOptions();

  /// The game's level loader: rules 1–7. Bundled levels were proven solvable
  /// in CI (`nesty_levels bundle check`), so the game doesn't search again
  /// (owner override A6).
  static const ValidationOptions loader = ValidationOptions(
    checkSolvable: false,
  );

  /// Whether rule 8 (the solver proves the level solvable) runs.
  final bool checkSolvable;

  /// Node budget for rule 8.
  final int solverBudget;

  /// The search rule 8 runs, called once on the level's starting board with
  /// [solverBudget]. Defaults to `Solver.solve`, the one solver of spec
  /// §6.3, so [admin] proves rule 8 without every caller passing it.
  ///
  /// When it is explicitly null and [checkSolvable] is set, rule 8 can't
  /// run and reports `solver.unproven` as an error, so an unchecked level is
  /// never mistaken for a proven one.
  final LevelSolver? solver;

  @override
  bool operator ==(Object other) =>
      other is ValidationOptions &&
      other.checkSolvable == checkSolvable &&
      other.solverBudget == solverBudget &&
      other.solver == solver;

  @override
  int get hashCode => Object.hash(checkSolvable, solverBudget, solver);

  @override
  String toString() =>
      'ValidationOptions(checkSolvable: $checkSolvable, '
      'solverBudget: $solverBudget${solver == null ? ', no solver' : ''})';
}

/// Every issue the [Validator] found, and what it learned on the way.
final class ValidationReport {
  ValidationReport({List<LevelIssue> issues = const [], this.level, this.solve})
    : issues = List.unmodifiable(issues);

  /// The level that was checked: the input of `Validator.validate`, or what
  /// `Validator.validateJson` decoded (null when it couldn't decode one).
  final Level? level;

  /// Every problem, errors and warnings, in the order found.
  final List<LevelIssue> issues;

  /// The rule-8 search, when it ran. The admin shows its solution and
  /// metrics (spec §6.1).
  final SolveResult? solve;

  /// True when no issue is an error: the level may be published or played.
  bool get isValid => !issues.any((issue) => issue.isError);

  /// The error issues only.
  List<LevelIssue> get errors => [
    for (final issue in issues)
      if (issue.isError) issue,
  ];

  @override
  bool operator ==(Object other) =>
      other is ValidationReport &&
      other.level == level &&
      other.solve == solve &&
      listEquals(other.issues, issues);

  @override
  int get hashCode => Object.hash(level, solve, Object.hashAll(issues));

  @override
  String toString() =>
      'ValidationReport(${level?.id}, ${isValid ? 'valid' : 'invalid'}, '
      '$issues)';
}

/// The level checks of spec §5.3, shared by the admin and the game loader.
///
/// Issues are collected, not fail-fast, in rule order. Besides rules 1–6 the
/// validator checks what a [Level] can hold but the level format forbids:
/// the id length (design A21), the `generatorVersion` and `seed` ranges
/// (A20), ice counters above `LayoutLimits.maxIce` (which the engine can't
/// store), doll sizes above `maxSize` (§2.1) and gold, which is v1.1 (owner
/// override D22). Rules 7 (a legal first move) and 8 (solvable) only run
/// when there is no error so far, because the rules engine needs a
/// well-formed board (design §3).
///
/// Every path is a JSON pointer into the level's JSON (`LevelCodec.encode`),
/// whether the level came from JSON or was built in code.
abstract final class Validator {
  /// Checks [level] against rules 1–8 (rule 8 only when
  /// [ValidationOptions.checkSolvable]).
  static ValidationReport validate(
    Level level, {
    ValidationOptions options = ValidationOptions.admin,
  }) {
    final issues = checkLevel(level);
    if (issues.any((issue) => issue.isError)) {
      return ValidationReport(issues: issues, level: level);
    }

    final start = GameState.initial(level);
    // Rule 7 runs the one §4 implementation (CLAUDE.md rule 2).
    if (Rules.legalMoves(start).isEmpty) {
      issues.add(
        LevelIssue(
          code: IssueCodes.noLegalFirstMove,
          message: 'The starting board has no legal move',
        ),
      );
      return ValidationReport(issues: issues, level: level);
    }

    if (!options.checkSolvable) {
      return ValidationReport(issues: issues, level: level);
    }
    final solve = _rule8(start, options, issues);
    return ValidationReport(issues: issues, level: level, solve: solve);
  }

  /// Decodes [json] with the level codec, then [validate]s the result. Codec
  /// issues and rule issues come back in one report. When the JSON can't be
  /// decoded, the report holds the codec's issues and no level.
  static ValidationReport validateJson(
    Object? json, {
    ValidationOptions options = ValidationOptions.admin,
  }) {
    final decoded = LevelCodec.decode(json);
    final level = decoded.level;
    if (level == null) return ValidationReport(issues: decoded.issues);
    final report = validate(level, options: options);
    return ValidationReport(
      issues: [...decoded.issues, ...report.issues],
      level: level,
      solve: report.solve,
    );
  }

  /// Rule 8: only a `solved` verdict proves the level. An exhausted budget is
  /// `unknown`, never `unsolvable` (spec §6.3), so it is `solver.unproven`.
  static SolveResult? _rule8(
    GameState start,
    ValidationOptions options,
    List<LevelIssue> issues,
  ) {
    final solver = options.solver;
    final budget = options.solverBudget;
    if (solver == null) {
      issues.add(
        LevelIssue(
          code: IssueCodes.unproven,
          message:
              'Rule 8 was not checked: no solver was given, so the level is '
              'not proven solvable',
          args: {'nodes': 0, 'budget': budget},
        ),
      );
      return null;
    }
    final result = solver(start, budget: budget);
    switch (result.verdict) {
      case SolveVerdict.solved:
        break;
      case SolveVerdict.unsolvable:
        issues.add(
          LevelIssue(
            code: IssueCodes.unsolvable,
            message:
                'The level can never be won (searched ${result.nodes} '
                'states)',
            args: {'nodes': result.nodes},
          ),
        );
      case SolveVerdict.unknown:
        issues.add(
          LevelIssue(
            code: IssueCodes.unproven,
            message:
                'Not proven solvable within $budget nodes (searched '
                '${result.nodes})',
            args: {'nodes': result.nodes, 'budget': budget},
          ),
        );
    }
    return result;
  }
}
