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
/// Writes only when the manifest and every level file read cleanly, and
/// never over a bundle whose same-version board it would change (spec §5.2,
/// §13.3). It doesn't run the rules, the solver or the simulator; `bundle
/// check` proves the result.
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

  final bundle = authored.toBundle();
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
  cli.out.writeln(
    '${outcome.name.padRight(9)} ${LevelPaths.bundle} '
    '(${bundle.levels.length} levels, levelsVersion ${bundle.levelsVersion}). '
    'Next: dart run nesty_tools:nesty_levels bundle check',
  );
  return ExitCodes.ok;
}

/// `bundle check` (CI): the committed bundle is exactly what `bundle build`
/// makes, and every level passes rules 1–8 (admin budget, design A6), its
/// simulated tier equals the declared one (A32; tutorials may override with
/// a reason), and the bundle follows the §6.6 pattern, the §3.7 schedule,
/// 20-level chapters and the M2 layout ([BundlePolicy]).
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

  if (authored.isComplete) findings.addAll(_drift(cli, authored));

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

  if (analyses.isNotEmpty) cli.out.writeln(reportTable(analyses));
  final errors = cli.report(
    findings,
    what: 'bundle check (${authored.levels.length} levels)',
  );
  return errors == 0 ? ExitCodes.ok : ExitCodes.failed;
}

/// The committed bundle must be byte-identical to what `bundle build`
/// writes, so the game ships exactly the checked levels.
List<Finding> _drift(CliContext cli, AuthoredLevels authored) {
  final bundle = authored.toBundle();
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
  ];
}
