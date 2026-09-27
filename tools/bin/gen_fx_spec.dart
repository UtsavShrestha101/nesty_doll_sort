// Generates apps/game/lib/features/fx/fx_spec.gen.dart (a const FxSpec per
// FxId: frames, canvas, markers, anchor, kind, travel S/T, size roles, image
// layers with their authored static scale/anchor, text layers, colour fills,
// loop) from design/lottie/*.json and the LOTTIE.md v3 contract table
// (lib/src/fx/lottie_contract.dart). The exports are validated first, the
// same way sync_design_assets validates them; nothing is written on an issue.
//
// Usage: dart run nesty_tools:gen_fx_spec [--check]
//   --check  write nothing; exit 1 if the file is stale (CI drift check).
import 'dart:io';

import 'package:nesty_tools/src/cli_args.dart';
import 'package:nesty_tools/src/dart_format.dart';
import 'package:nesty_tools/src/file_writes.dart';
import 'package:nesty_tools/src/fx/fx_spec_codegen.dart';
import 'package:nesty_tools/src/fx/lottie_sources.dart';
import 'package:nesty_tools/src/repo_root.dart';
import 'package:path/path.dart' as p;

Future<void> main(List<String> arguments) async {
  final CliArgs args;
  try {
    args = CliArgs.parse(arguments, flags: {'check', 'help'});
  } on FormatException catch (e) {
    stderr.writeln(e.message);
    exitCode = 64;
    return;
  }
  if (args.flag('help')) {
    stdout.writeln('Usage: dart run nesty_tools:gen_fx_spec [--check]');
    return;
  }
  final root = findRepoRoot();
  final sources = readDesignLottie(root);
  if (sources.issues.isNotEmpty) {
    stderr.writeln('Lottie exports failed validation; nothing was written:');
    for (final issue in sources.issues) {
      stderr.writeln('  $issue');
    }
    exitCode = 1;
    return;
  }
  final facts = fxSpecFactsOf(sources);
  final target = p.join(root.path, fxSpecGenPath);
  final source = await formatDart(fxSpecSource(facts), targetPath: target);
  final check = args.flag('check');
  final outcome = writeStringIfChanged(File(target), source, dryRun: check);
  stdout.writeln(
    '${check && outcome != WriteOutcome.unchanged ? 'STALE' : outcome.name.padRight(9)} '
    '$fxSpecGenPath (${facts.length} files)',
  );
  if (check && outcome != WriteOutcome.unchanged) {
    stderr.writeln('Run: dart run nesty_tools:gen_fx_spec');
    exitCode = 1;
  }
}
