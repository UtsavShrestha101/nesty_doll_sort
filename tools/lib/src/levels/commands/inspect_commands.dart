import 'dart:convert';

import 'package:nesty_core/nesty_core.dart';
import 'package:nesty_tools/src/cli_args.dart';
import 'package:nesty_tools/src/levels/cli_context.dart';
import 'package:nesty_tools/src/levels/finding.dart';
import 'package:nesty_tools/src/levels/level_analysis.dart';
import 'package:nesty_tools/src/levels/level_inputs.dart';
import 'package:nesty_tools/src/levels/text_table.dart';

/// `validate [paths] [--loader] [--budget N]`: spec §5.3 rules 1–8 (with
/// `--loader`, rules 1–7 like the game's loader, design A6).
int runValidate(CliContext cli, List<String> arguments) {
  final args = cli.parse(arguments, flags: {'loader'}, options: {'budget'});
  final options = ValidationOptions(
    checkSolvable: !args.flag('loader'),
    solverBudget: _budget(cli, args),
  );
  final loaded = cli.inputs(args);
  final findings = [...loaded.findings];
  for (final input in loaded.inputs) {
    final report = Validator.validate(input.level, options: options);
    final solve = report.solve;
    cli.out.writeln(
      '${report.isValid ? 'ok    ' : 'FAILED'}  ${input.label}  '
      '(${input.source})'
      '${solve?.solution == null ? '' : '  solved in ${solve!.solution!.length} moves, ${solve.nodes} nodes'}',
    );
    findings.addAll(_issues(input, report.issues));
  }
  final errors = cli.report(
    findings,
    what: 'validate ${loaded.inputs.length} level(s)',
  );
  return errors == 0 ? ExitCodes.ok : ExitCodes.failed;
}

/// `solve [paths] [--budget N]`: the optimal solution, nodes and branching
/// (spec §6.3). Fails unless every level is solved.
int runSolve(CliContext cli, List<String> arguments) {
  final args = cli.parse(arguments, options: {'budget'});
  final budget = _budget(cli, args);
  final loaded = cli.inputs(args);
  final findings = [...loaded.findings];
  var unsolved = 0;
  for (final input in loaded.inputs) {
    final playable = _playable(input, findings);
    if (!playable) {
      unsolved++;
      continue;
    }
    final result = Solver.solve(GameState.initial(input.level), budget: budget);
    final solution = result.solution;
    cli.out.writeln(
      '${input.label}  ${result.verdict.name}'
      '${solution == null ? '' : '  ${solution.length} moves'}'
      '  nodes ${result.nodes}  branching ${result.branching.toStringAsFixed(2)}',
    );
    if (solution != null && solution.isNotEmpty) {
      cli.out.writeln('  ${movesText(solution)}');
    }
    if (result.verdict != SolveVerdict.solved) unsolved++;
  }
  final errors = cli.report(findings);
  if (unsolved > 0) {
    cli.err.writeln('$unsolved level(s) not solved within $budget nodes.');
  }
  return errors == 0 && unsolved == 0 ? ExitCodes.ok : ExitCodes.failed;
}

/// `simulate [paths] [--runs N] [--seed S] [--move-cap N]`: the casual and
/// smart bots and the tier they suggest (spec §6.4).
int runSimulate(CliContext cli, List<String> arguments) {
  final args = cli.parse(arguments, options: {'runs', 'seed', 'move-cap'});
  final params = SimulatorParams(
    runs: cli.intOption(
      args,
      'runs',
      fallback: SimulatorParams.defaultRuns,
      min: 1,
      max: 0xFFFFFFFF,
    ),
    moveCap: cli.intOption(
      args,
      'move-cap',
      fallback: SimulatorParams.defaultMoveCap,
    ),
    seed: args.options.containsKey('seed')
        ? cli.intOption(args, 'seed', fallback: 0, max: Prng.maxSeed)
        : null,
  );
  final loaded = cli.inputs(args);
  final findings = [...loaded.findings];
  final rows = <List<String>>[];
  for (final input in loaded.inputs) {
    if (!_playable(input, findings)) continue;
    final sim = Simulator.run(input.level, params);
    rows.add([
      input.label,
      input.declaredTier?.id ?? '-',
      sim.tier.id,
      '${sim.casual.wins}/${sim.casual.runs} ${percent(sim.casual)}',
      '${sim.smart.wins}/${sim.smart.runs} ${percent(sim.smart)}',
      sim.expertOnly ? 'yes' : 'no',
      '${sim.seed}',
    ]);
  }
  if (rows.isNotEmpty) {
    cli.out.writeln(
      renderTable([
        'id',
        'declared',
        'tier',
        'casual',
        'smart',
        'expertOnly',
        'seed',
      ], rows),
    );
  }
  final errors = cli.report(findings);
  return errors == 0 ? ExitCodes.ok : ExitCodes.failed;
}

/// `report [paths] [--budget N] [--json]`: rules 1–8, the solve and the
/// simulation in one table, the admin's level list columns (spec §15 #2).
int runReport(CliContext cli, List<String> arguments) {
  final args = cli.parse(arguments, flags: {'json'}, options: {'budget'});
  final options = ValidationOptions(solverBudget: _budget(cli, args));
  final loaded = cli.inputs(args);
  final findings = [...loaded.findings];
  final analyses = [
    for (final input in loaded.inputs)
      (input, analyzeLevel(input.level, options: options)),
  ];
  for (final (input, analysis) in analyses) {
    findings.addAll(_issues(input, analysis.validation.issues));
  }

  if (args.flag('json')) {
    cli.out.writeln(
      const JsonEncoder.withIndent('  ').convert([
        for (final (input, analysis) in analyses) reportJson(input, analysis),
      ]),
    );
  } else if (analyses.isNotEmpty) {
    cli.out.writeln(reportTable(analyses));
  }
  final errors = cli.report(findings);
  return errors == 0 ? ExitCodes.ok : ExitCodes.failed;
}

/// The report columns shared by `report` and `bundle check`: order, id,
/// chapter, declared and simulated tier, casual %, smart %, solver moves,
/// nodes and the status.
String reportTable(List<(LevelInput, LevelAnalysis)> analyses) => renderTable(
  [
    'order',
    'id',
    'chapter',
    'declared',
    'simulated',
    'casual',
    'smart',
    'moves',
    'nodes',
    'status',
  ],
  [
    for (final (input, analysis) in analyses)
      [
        input.order?.toString() ?? '-',
        input.label,
        input.chapterId ?? '-',
        input.declaredTier?.id ?? '-',
        analysis.simulation?.tier.id ?? '-',
        analysis.simulation == null
            ? '-'
            : percent(analysis.simulation!.casual),
        analysis.simulation == null ? '-' : percent(analysis.simulation!.smart),
        analysis.solverMoves?.toString() ?? '-',
        analysis.solve?.nodes.toString() ?? '-',
        _status(analysis),
      ],
  ],
  rightAligned: const {0, 5, 6, 7, 8},
);

/// One `report --json` row: spec §5.2's `tier` and `metrics` plus the
/// declared metadata and the issues.
Map<String, Object?> reportJson(LevelInput input, LevelAnalysis analysis) {
  final sim = analysis.simulation;
  final solve = analysis.solve;
  return {
    'id': input.label,
    'source': input.source,
    'order': input.order,
    'chapterId': input.chapterId,
    'declaredTier': input.declaredTier?.id,
    'valid': analysis.isValid,
    'tier': sim?.tier.id,
    'expertOnly': sim?.expertOnly,
    'casualWins': sim?.casual.wins,
    'smartWins': sim?.smart.wins,
    'runs': sim?.casual.runs,
    'verdict': solve?.verdict.name,
    'solverMoves': analysis.solverMoves,
    'nodes': solve?.nodes,
    'branching': solve == null
        ? null
        : double.parse(solve.branching.toStringAsFixed(3)),
    'issues': [
      for (final issue in analysis.validation.issues)
        {
          'code': issue.code,
          'severity': issue.severity.name,
          'path': issue.path,
          'message': issue.message,
        },
    ],
  };
}

String _status(LevelAnalysis analysis) {
  if (analysis.isValid) {
    return analysis.simulation?.expertOnly ?? false ? 'ok, expert only' : 'ok';
  }
  return analysis.validation.errors.map((i) => i.code).toSet().join(', ');
}

int _budget(CliContext cli, CliArgs args) => cli.intOption(
  args,
  'budget',
  fallback: SolverBudgets.admin,
  min: 1,
  max: SolverRun.maxBudget,
);

/// Rules 1–7 (the loader's check): the engine can lay out and play the
/// level. Adds the issues to [findings] and returns false when it can't.
bool _playable(LevelInput input, List<Finding> findings) {
  final report = Validator.validate(
    input.level,
    options: ValidationOptions.loader,
  );
  findings.addAll(_issues(input, report.issues));
  return report.isValid;
}

List<Finding> _issues(LevelInput input, List<LevelIssue> issues) => [
  for (final issue in issues)
    Finding.fromIssue(issue, subject: '${input.label} (${input.source})'),
];
