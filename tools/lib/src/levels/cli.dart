import 'dart:io';

import 'package:nesty_tools/src/levels/cli_context.dart';
import 'package:nesty_tools/src/levels/commands/bundle_commands.dart';
import 'package:nesty_tools/src/levels/commands/fixtures_command.dart';
import 'package:nesty_tools/src/levels/commands/generate_command.dart';
import 'package:nesty_tools/src/levels/commands/inspect_commands.dart';
import 'package:nesty_tools/src/repo_root.dart';

/// `--help` text of `nesty_levels`.
const String nestyLevelsUsage = '''
Usage: dart run nesty_tools:nesty_levels <command> [arguments]

Level tools for Nesty (tools/README.md, tools/levels/README.md). Every rule,
the solver, the simulator and the generator come from nesty_core.

A [path] is a level file (spec §5.1), a bundle, the manifest
(tools/levels/manifest.json) or a folder of level files, relative to the
current directory. With no path, commands read the game's bundle
(apps/game/assets/levels/bundle.json).

Commands:
  validate [paths] [--loader] [--budget N]
      Validation rules 1–8 of spec §5.3 (--loader: rules 1–7, as the game's
      loader does).
  solve [paths] [--budget N]
      The optimal solution, nodes and branching (spec §6.3). Fails unless
      every level is solved.
  simulate [paths] [--runs N] [--seed S] [--move-cap N]
      Casual and smart bots and the tier they suggest (spec §6.4).
  report [paths] [--budget N] [--json]
      Rules, solver and simulator in one table.
  report [paths] --stars [--star3-slack 20] [--star2-slack 60] [--runs 300]
      The star shares instead: per chapter and bot, the won runs at 3, 2
      and 1 stars against each level's par (spec-prop §7.10). A report,
      never a gate.
  bundle build
      tools/levels/manifest.json + tools/levels/authored/ → the game's bundle,
      each level with its par: the solver's optimal moves (rule 8 at the
      admin budget; a level it doesn't prove stops the build).
  bundle check
      CI: the bundle is fresh (pars included), every level passes rules 1–8,
      its simulated tier is its declared tier, and the bundle follows the
      §6.6 tier pattern, the §3.7 schedule and the M2 layout; no two
      consecutive levels share a layout, and from L31 none is expert only
      (E12).
  generate --params <json|file> --seed S [--count N] [--out DIR]
      The generator (spec §6.5) for seeds S … S+N−1.
  fixtures check
      nesty_core's solver fixtures give their expected verdicts and moves.

--budget defaults to the admin budget (500000 nodes, spec §6.3).
Exit codes: 0 ok, 1 a check failed, 64 bad usage.''';

/// Runs `nesty_levels` with [arguments] and returns the exit code. Output
/// goes to [out] (reports) and [err] (findings). [root] defaults to the repo
/// root above [cwd], which defaults to the current directory; tests pass a
/// scratch repo.
int runNestyLevels(
  List<String> arguments, {
  required StringSink out,
  required StringSink err,
  Directory? root,
  Directory? cwd,
}) {
  if (arguments.isEmpty) {
    err.writeln(nestyLevelsUsage);
    return ExitCodes.usage;
  }
  if (arguments.contains('--help') || arguments.first == 'help') {
    out.writeln(nestyLevelsUsage);
    return ExitCodes.ok;
  }
  final workingDir = cwd ?? Directory.current;
  final cli = CliContext(
    out: out,
    err: err,
    root: root ?? findRepoRoot(workingDir.path),
    cwd: workingDir,
  );
  final rest = arguments.sublist(1);
  try {
    return switch (arguments.first) {
      'validate' => runValidate(cli, rest),
      'solve' => runSolve(cli, rest),
      'simulate' => runSimulate(cli, rest),
      'report' => runReport(cli, rest),
      'generate' => runGenerate(cli, rest),
      'bundle' => switch (rest.firstOrNull) {
        'build' => runBundleBuild(cli, rest.sublist(1)),
        'check' => runBundleCheck(cli, rest.sublist(1)),
        _ => throw const UsageError('Use "bundle build" or "bundle check".'),
      },
      'fixtures' => switch (rest.firstOrNull) {
        'check' => runFixturesCheck(cli, rest.sublist(1)),
        _ => throw const UsageError('Use "fixtures check".'),
      },
      final other => throw UsageError('Unknown command "$other".'),
    };
  } on UsageError catch (e) {
    err
      ..writeln(e.message)
      ..writeln('Run "dart run nesty_tools:nesty_levels --help" for usage.');
    return ExitCodes.usage;
  }
}
