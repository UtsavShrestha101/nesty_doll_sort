import 'dart:convert';
import 'dart:io';

import 'package:nesty_core/nesty_core.dart';
import 'package:nesty_tools/src/cli_args.dart';
import 'package:nesty_tools/src/file_writes.dart';
import 'package:nesty_tools/src/levels/authored_levels.dart';
import 'package:nesty_tools/src/levels/cli_context.dart';
import 'package:nesty_tools/src/levels/finding.dart';
import 'package:nesty_tools/src/levels/generator_params_json.dart';
import 'package:nesty_tools/src/levels/level_analysis.dart';
import 'package:nesty_tools/src/levels/level_paths.dart';
import 'package:nesty_tools/src/levels/text_table.dart';
import 'package:path/path.dart' as p;

/// `generate`: runs the core generator (spec §6.5) on a batch of params and
/// prints each level's attempt, tier and metrics. The batch is one of:
///
/// - `--params <json|file> --seed S [--count N]`: the params for seeds S,
///   S+1, …, S+N−1. The seed is explicit (CLAUDE.md rule 7), so a batch
///   always reproduces.
/// - `--bonus N [--count C]`: Bonus Endless levels N … N+C−1, with the
///   curve's params and seeds (`DifficultyCurve.bonusParams`, spec §7.1).
/// - `--daily YYYYMMDD`: that date's daily puzzle (`dailyParams`, §7.5).
///
/// `--verify` validates every generated level again with rules 1–8 on a
/// fresh admin-budget solve (the M1 acceptance check, spec §18). With
/// `--out DIR`, each level is written to `DIR/<id>.json` (canonical, 2-space
/// indent); without it, each level's compact JSON follows the table, one
/// per line. Fails when any params give no level or a level fails
/// `--verify`.
int runGenerate(CliContext cli, List<String> arguments) {
  final args = cli.parse(
    arguments,
    flags: {'verify'},
    options: {'params', 'seed', 'count', 'bonus', 'daily', 'out'},
  );
  if (args.rest.isNotEmpty) {
    throw UsageError('generate takes no positional arguments: ${args.rest}');
  }
  final findings = <Finding>[];
  final batch = _batch(cli, args, findings);
  if (batch == null) {
    cli.report(findings);
    return ExitCodes.failed;
  }

  final outDir = args.options['out'] == null
      ? null
      : Directory(p.normalize(p.join(cli.cwd.path, args.options['out']!)));
  final verify = args.flag('verify');
  final rows = <List<String>>[];
  final levels = <Level>[];
  final written = <String, int>{};
  for (final params in batch) {
    final subject = params.id ?? 'seed ${params.seed}';
    switch (Generator.generate(params)) {
      case GeneratorSuccess(
        :final level,
        :final solve,
        :final simulation,
        :final attempt,
        :final tierMatched,
      ):
        var status = tierMatched ? 'ok' : 'closest tier';
        if (verify) {
          final report = Validator.validate(level);
          findings.addAll([
            for (final issue in report.issues)
              Finding.fromIssue(issue, subject: level.id),
          ]);
          if (!report.isValid) status = 'FAILED verify';
        }
        rows.add([
          '${params.seed}',
          level.id,
          params.targetTier.id,
          simulation.tier.id,
          '$attempt',
          '${solve.solution?.length ?? '-'}',
          '${solve.nodes}',
          percent(simulation.casual),
          percent(simulation.smart),
          status,
        ]);
        if (outDir == null) {
          levels.add(level);
        } else if (written.containsKey(level.id)) {
          findings.add(
            Finding(
              FindingCodes.generatorFailed,
              'Seed ${params.seed} generated id "${level.id}", already '
              'written for seed ${written[level.id]}; not overwritten',
              subject: subject,
            ),
          );
        } else {
          written[level.id] = params.seed;
          writeStringIfChanged(
            File(p.join(outDir.path, '${level.id}.json')),
            '${LevelCodec.encodeString(level, indent: '  ')}\n',
          );
        }
      case final GeneratorFailure failure:
        rows.add([
          '${params.seed}',
          params.id ?? '-',
          params.targetTier.id,
          '-',
          '-',
          '-',
          '-',
          '-',
          '-',
          'FAILED',
        ]);
        findings.addAll(generatorFailureFindings(failure, subject));
    }
  }

  cli.out.writeln(
    renderTable(
      [
        'seed',
        'id',
        'target',
        'tier',
        'attempt',
        'moves',
        'nodes',
        'casual',
        'smart',
        'status',
      ],
      rows,
      rightAligned: const {0, 4, 5, 6, 7, 8},
    ),
  );
  for (final level in levels) {
    cli.out.writeln(LevelCodec.encodeString(level));
  }
  if (outDir != null) {
    cli.out.writeln(
      'Wrote ${written.length} level(s) to '
      '${LevelPaths.display(cli.root, outDir)}',
    );
  }
  final errors = cli.report(
    findings,
    what: 'generate ${batch.length} level(s)',
  );
  return errors == 0 ? ExitCodes.ok : ExitCodes.failed;
}

/// The params to generate, from exactly one of `--params`, `--bonus` and
/// `--daily`; null after adding findings when `--params` can't be read.
List<GeneratorParams>? _batch(
  CliContext cli,
  CliArgs args,
  List<Finding> findings,
) {
  final sources = [
    for (final name in const ['params', 'bonus', 'daily'])
      if (args.options.containsKey(name)) name,
  ];
  if (sources.length != 1) {
    throw const UsageError(
      'Give exactly one of --params (with --seed), --bonus or --daily.',
    );
  }
  switch (sources.single) {
    case 'bonus':
      if (args.options.containsKey('seed')) {
        throw const UsageError('--bonus uses the curve\'s seeds; drop --seed.');
      }
      final first = cli.intOption(
        args,
        'bonus',
        fallback: 1,
        min: 1,
        max: DifficultyCurve.maxLevelNumber,
      );
      final count = cli.intOption(
        args,
        'count',
        fallback: 1,
        min: 1,
        max: DifficultyCurve.maxLevelNumber - first + 1,
      );
      return [
        for (var n = first; n < first + count; n++)
          DifficultyCurve.bonusParams(n),
      ];
    case 'daily':
      if (args.options.containsKey('seed') ||
          args.options.containsKey('count')) {
        throw const UsageError(
          '--daily generates one date\'s puzzle, seeded with the date; drop '
          '--seed and --count.',
        );
      }
      final date = cli.intOption(args, 'daily', fallback: 0);
      try {
        return [DifficultyCurve.dailyParams(date)];
      } on RangeError {
        throw UsageError('--daily $date is not a date written as YYYYMMDD.');
      }
  }

  if (!args.options.containsKey('seed')) {
    throw const UsageError(
      '--params needs --seed (spec §6.5: explicit seeds).',
    );
  }
  final seed = cli.intOption(args, 'seed', fallback: 0, max: Prng.maxSeed);
  final count = cli.intOption(
    args,
    'count',
    fallback: 1,
    min: 1,
    max: Prng.maxSeed - seed + 1,
  );
  final paramsText = args.options['params']!;
  final Object? json;
  final String subject;
  if (paramsText.trimLeft().startsWith('{')) {
    subject = '--params';
    try {
      json = jsonDecode(paramsText);
    } on FormatException catch (e) {
      throw UsageError('--params is not valid JSON: ${e.message}');
    }
  } else {
    final file = File(p.normalize(p.join(cli.cwd.path, paramsText)));
    subject = LevelPaths.display(cli.root, file);
    final read = readJsonFile(file, root: cli.root, findings: findings);
    if (read == null) return null;
    json = read.value;
  }
  final parse = parseGeneratorParams(json, subject: subject);
  findings.addAll(parse.findings);
  final make = parse.params;
  if (make == null) return null;
  return [for (var k = 0; k < count; k++) make(seed + k)];
}
