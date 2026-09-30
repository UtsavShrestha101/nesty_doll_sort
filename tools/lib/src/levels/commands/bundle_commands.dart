import 'dart:math';

import 'package:nesty_core/nesty_core.dart';
import 'package:nesty_tools/src/file_writes.dart';
import 'package:nesty_tools/src/levels/authored_levels.dart';
import 'package:nesty_tools/src/levels/bundle_policy.dart';
import 'package:nesty_tools/src/levels/cli_context.dart';
import 'package:nesty_tools/src/levels/commands/inspect_commands.dart';
import 'package:nesty_tools/src/levels/finding.dart';
import 'package:nesty_tools/src/levels/level_analysis.dart';
import 'package:nesty_tools/src/levels/level_inputs.dart';
import 'package:nesty_tools/src/levels/level_paths.dart';

/// `bundle build`: tools/levels/manifest.json + authored/ →
/// apps/game/assets/levels/bundle.json (design §4).
///
/// Writes only when the manifest and every level file read cleanly, every
/// level has a proven par, and never over a bundle whose same-version board
/// it would change (spec §5.2, §13.3).
///
/// Par (spec-prop §7.10, D146): "the fewest moves that solve the level from
/// its start, the solver's optimal solution (§6.3). It is computed when the
/// level bundle is built, and checked with it." Each level runs the one
/// validator (rules 1–8, rule 8 at the admin budget of 500,000 nodes), and
/// its solution's length is the par: A* with the consistent heuristic finds
/// the true minimum. A level it doesn't prove (rules 1–7 fail, unsolvable,
/// or unknown within the budget) is `build.parUnproven` with the
/// validator's errors, and nothing is written. The simulator doesn't run
/// here; `bundle check` proves the rest.
int runBundleBuild(CliContext cli, List<String> arguments) {
  cli.parse(arguments);
  final authored = loadAuthoredLevels(
    LevelPaths.file(cli.root, LevelPaths.manifest),
    root: cli.root,
  );
  final findings = [...authored.findings];
  if (!authored.isComplete) {
    cli.report(findings);
    cli.err.writeln('Nothing written.');
    return ExitCodes.failed;
  }

  final pars = <String, int>{};
  for (final level in authored.levels) {
    final id = level.entry.id;
    final analysis = analyzeLevel(level.level, simulate: false);
    final par = analysis.par;
    if (par != null) {
      pars[id] = par;
      continue;
    }
    findings
      ..add(
        Finding(
          FindingCodes.parUnproven,
          'No par: ${_unprovenReason(analysis)}, so it can\'t get stars. '
          'The solver must prove every level at the admin budget '
          '(spec-prop §7.10)',
          subject: id,
        ),
      )
      ..addAll([
        for (final issue in analysis.validation.errors)
          Finding.fromIssue(issue, subject: id),
      ]);
  }
  if (findings.any((f) => f.isError)) {
    cli.report(findings);
    cli.err.writeln('Nothing written.');
    return ExitCodes.failed;
  }

  final bundle = authored.toBundle(pars: pars);
  final file = LevelPaths.file(cli.root, LevelPaths.bundle);
  if (file.existsSync()) {
    final previous = LevelBundleCodec.decodeString(file.readAsStringSync());
    if (previous.bundle case final old?) {
      findings.addAll(checkVersionBumps(old, bundle));
    } else {
      findings.add(
        Finding(
          FindingCodes.unreadable,
          'The current bundle does not decode, so level versions can\'t be '
          'compared with it (${previous.issues.first.code})',
          subject: LevelPaths.bundle,
          severity: FindingSeverity.warning,
        ),
      );
    }
  }
  if (findings.any((f) => f.isError)) {
    cli.report(findings);
    cli.err.writeln('Nothing written.');
    return ExitCodes.failed;
  }

  final outcome = writeStringIfChanged(
    file,
    LevelBundleCodec.encodeString(bundle),
  );
  cli.report(findings);
  final parRange = pars.isEmpty
      ? ''
      : ', par ${pars.values.reduce(min)}–${pars.values.reduce(max)}';
  cli.out.writeln(
    '${outcome.name.padRight(9)} ${LevelPaths.bundle} '
    '(${bundle.levels.length} levels, levelsVersion ${bundle.levelsVersion}'
    '$parRange). Next: dart run nesty_tools:nesty_levels bundle check',
  );
  return ExitCodes.ok;
}

String _unprovenReason(LevelAnalysis analysis) {
  final solve = analysis.solve;
  if (solve == null) return 'rules 1–7 fail, so the solver never ran';
  return switch (solve.verdict) {
    SolveVerdict.unsolvable => 'the solver proved it unsolvable',
    SolveVerdict.unknown =>
      'not solved within ${SolverBudgets.admin} nodes (spec §6.3)',
    SolveVerdict.solved => 'its solution has no move',
  };
}

/// `bundle check` (CI): the committed bundle is exactly what `bundle build`
/// makes, with each entry's par the solver's optimum (spec-prop §7.10;
/// `bundle.parMismatch` names an entry whose par is missing or differs),
/// and every level passes rules 1–8 (admin budget, design A6), its
/// simulated tier equals the declared one (A32; tutorials may override with
/// a reason), and the bundle follows the §6.6 pattern, the §3.7 schedule,
/// 20-level chapters, the M2 layout and E12's variety and smart-bot gates
/// ([BundlePolicy]).
int runBundleCheck(CliContext cli, List<String> arguments) {
  cli.parse(arguments);
  final authored = loadAuthoredLevels(
    LevelPaths.file(cli.root, LevelPaths.manifest),
    root: cli.root,
  );
  final findings = [...authored.findings];
  if (authored.manifest == null) {
    cli.report(findings, what: 'bundle check');
    return ExitCodes.failed;
  }

  // The pars come from the rule-8 solve the loop below already runs.
  final pars = <String, int>{};
  final analyses = <(LevelInput, LevelAnalysis)>[];
  for (final level in authored.levels) {
    final entry = level.entry;
    final subject = entry.id;
    final input = LevelInput(
      source: LevelPaths.display(cli.root, level.file),
      level: level.level,
      order: entry.order,
      chapterId: entry.chapterId,
      declaredTier: entry.tier,
      tierOverride: entry.tierOverride,
    );
    final analysis = analyzeLevel(level.level);
    analyses.add((input, analysis));
    if (analysis.par case final par?) pars[subject] = par;
    findings
      ..addAll([
        for (final issue in analysis.validation.issues)
          Finding.fromIssue(issue, subject: subject),
      ])
      ..addAll(
        BundlePolicy.check(
          order: entry.order,
          chapterId: entry.chapterId,
          declared: entry.tier,
          level: level.level,
          subject: subject,
        ),
      );
    if (analysis.simulation case final simulation?) {
      findings.addAll(
        BundlePolicy.checkTier(
          order: entry.order,
          declared: entry.tier,
          tierOverride: entry.tierOverride,
          simulation: simulation,
          level: level.level,
          subject: subject,
        ),
      );
    }
  }
  findings.addAll(
    BundlePolicy.checkVariety([
      for (final level in authored.levels)
        (order: level.entry.order, level: level.level, subject: level.entry.id),
    ]),
  );

  // Drift first, as a stale bundle is the first thing to fix.
  if (authored.isComplete) {
    findings.insertAll(authored.findings.length, _drift(cli, authored, pars));
  }

  if (analyses.isNotEmpty) cli.out.writeln(reportTable(analyses));
  final errors = cli.report(
    findings,
    what: 'bundle check (${authored.levels.length} levels)',
  );
  return errors == 0 ? ExitCodes.ok : ExitCodes.failed;
}

/// The committed bundle must be byte-identical to what `bundle build`
/// writes with [pars], so the game ships exactly the checked levels and
/// their proven pars.
List<Finding> _drift(
  CliContext cli,
  AuthoredLevels authored,
  Map<String, int> pars,
) {
  final bundle = authored.toBundle(pars: pars);
  final file = LevelPaths.file(cli.root, LevelPaths.bundle);
  if (!file.existsSync()) {
    return const [
      Finding(
        FindingCodes.bundleMissing,
        'Missing. Run: dart run nesty_tools:nesty_levels bundle build',
        subject: LevelPaths.bundle,
      ),
    ];
  }
  final committed = file.readAsStringSync();
  if (committed == LevelBundleCodec.encodeString(bundle)) return const [];
  final previous = LevelBundleCodec.decodeString(committed).bundle;
  return [
    const Finding(
      FindingCodes.bundleDrift,
      'Out of date with tools/levels/. Run: dart run '
      'nesty_tools:nesty_levels bundle build',
      subject: LevelPaths.bundle,
    ),
    if (previous != null) ...checkVersionBumps(previous, bundle),
    if (previous != null) ..._parMismatches(previous, pars),
  ];
}

/// Spec-prop §7.10: par "is computed when the level bundle is built, and
/// checked with it". One `bundle.parMismatch` per committed entry whose par
/// is missing or differs from [pars] (the solver's). A level the solver
/// didn't prove has no par to compare: rule 8 already fails it.
List<Finding> _parMismatches(LevelBundle committed, Map<String, int> pars) => [
  for (final entry in committed.levels)
    if (pars[entry.level.id] case final solver? when entry.par != solver)
      Finding(
        FindingCodes.parMismatch,
        '${entry.par == null ? 'no par committed' : 'committed ${entry.par}'}'
        ', the solver\'s $solver. Run: dart run nesty_tools:nesty_levels '
        'bundle build',
        subject: entry.level.id,
      ),
];
