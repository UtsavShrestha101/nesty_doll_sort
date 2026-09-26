// Generates apps/game/lib/core/ui/icons/nesty_icons.gen.dart (const
// IconData per bundled glyph) from the font subset's codepoints file, which
// tools/fonts/build_fonts.sh writes next to NestySymbolsRounded.ttf.
//
// Usage: dart run nesty_tools:gen_nesty_icons [--check]
//   --check  write nothing; exit 1 if the file is stale (CI drift check).
import 'dart:io';

import 'package:nesty_tools/src/cli_args.dart';
import 'package:nesty_tools/src/dart_format.dart';
import 'package:nesty_tools/src/file_writes.dart';
import 'package:nesty_tools/src/icons/nesty_icons_codegen.dart';
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
    stdout.writeln('Usage: dart run nesty_tools:gen_nesty_icons [--check]');
    return;
  }
  final root = findRepoRoot();
  final glyphs = parseGlyphList(
    File(p.join(root.path, glyphListPath)).readAsStringSync(),
  );
  final codepoints = parseCodepoints(
    File(p.join(root.path, iconCodepointsPath)).readAsStringSync(),
  );
  final target = p.join(root.path, nestyIconsPath);
  final source = await formatDart(
    nestyIconsSource(glyphs: glyphs, codepoints: codepoints),
    targetPath: target,
  );
  final check = args.flag('check');
  final outcome = writeStringIfChanged(File(target), source, dryRun: check);
  stdout.writeln(
    '${check && outcome != WriteOutcome.unchanged ? 'STALE' : outcome.name.padRight(9)} '
    '$nestyIconsPath (${glyphs.length} glyphs)',
  );
  if (check && outcome != WriteOutcome.unchanged) {
    stderr.writeln('Run: dart run nesty_tools:gen_nesty_icons');
    exitCode = 1;
  }
}
