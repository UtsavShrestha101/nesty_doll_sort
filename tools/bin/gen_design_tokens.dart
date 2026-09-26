// Generates the Dart design tokens from design/tokens.json:
//   packages/nesty_render/lib/src/tokens/render_tokens.gen.dart
//   apps/game/lib/core/ui/tokens/ui_tokens.gen.dart
//
// Usage: dart run nesty_tools:gen_design_tokens [--check]
//   --check  write nothing; exit 1 if either file is stale (CI drift check).
import 'dart:io';

import 'package:nesty_tools/src/cli_args.dart';
import 'package:nesty_tools/src/dart_format.dart';
import 'package:nesty_tools/src/file_writes.dart';
import 'package:nesty_tools/src/repo_root.dart';
import 'package:nesty_tools/src/tokens/design_tokens_codegen.dart';
import 'package:nesty_tools/src/tokens/token_reader.dart';
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
    stdout.writeln('Usage: dart run nesty_tools:gen_design_tokens [--check]');
    return;
  }
  final root = findRepoRoot();
  final check = args.flag('check');
  final source = File(p.join(root.path, tokensJsonPath)).readAsStringSync();
  final output = generateDesignTokens(source);
  var stale = false;
  for (final MapEntry(key: relative, value: code) in output.files.entries) {
    final target = p.join(root.path, relative);
    final formatted = await formatDart(code, targetPath: target);
    final outcome = writeStringIfChanged(
      File(target),
      formatted,
      dryRun: check,
    );
    if (outcome != WriteOutcome.unchanged) stale = true;
    stdout.writeln(
      '${check && outcome != WriteOutcome.unchanged ? 'STALE' : outcome.name.padRight(9)} $relative',
    );
  }
  final uses = output.reader.uses;
  stdout.writeln(
    '${uses.length} token leaves: '
    '${uses.values.where((u) => u is! DocumentedOnly).length} emitted, '
    '${uses.values.whereType<DocumentedOnly>().length} documented only.',
  );
  if (check && stale) {
    stderr.writeln(
      'Design tokens are stale. Run: dart run nesty_tools:gen_design_tokens',
    );
    exitCode = 1;
  }
}
