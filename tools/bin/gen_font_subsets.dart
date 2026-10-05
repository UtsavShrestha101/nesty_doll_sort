// Writes tools/fonts/subset/{hi,ja}.txt, the character lists
// tools/fonts/build_fonts.sh cuts the Devanagari (Baloo 2) and Japanese
// (M PLUS Rounded 1c) fonts to (docs l10n.md §4.3–§4.5): each script's
// whole blocks, plus the characters outside them that the game's
// app_<locale>.arb, intl's dates, the Flutter SDK's material_<locale>.arb
// and the language's autonym use and Fredoka and Nunito don't draw. The
// SDK is found through $FLUTTER_ROOT or the `flutter` on PATH.
//
// Usage: dart run nesty_tools:gen_font_subsets [--check]
//   --check  write nothing; exit 1 if a list is stale (CI drift check).
// After a list changes, run tools/fonts/build_fonts.sh to rebuild the fonts.
import 'dart:convert';
import 'dart:io';

import 'package:nesty_tools/src/cli_args.dart';
import 'package:nesty_tools/src/file_writes.dart';
import 'package:nesty_tools/src/fonts/font_subsets.dart';
import 'package:nesty_tools/src/repo_root.dart';
import 'package:nesty_tools/src/tokens/design_tokens_codegen.dart';
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
    stdout.writeln('Usage: dart run nesty_tools:gen_font_subsets [--check]');
    return;
  }
  final root = findRepoRoot();
  final tokens =
      jsonDecode(File(p.join(root.path, tokensJsonPath)).readAsStringSync())
          as Map<String, Object?>;
  final scripts =
      (tokens['font']! as Map<String, Object?>)['scripts']!
          as Map<String, Object?>;
  final lists = await generateFontSubsets(
    root: root,
    flutterSdk: findFlutterSdk(),
    fontScripts: scripts,
  );
  final check = args.flag('check');
  var stale = false;
  for (final MapEntry(key: path, value: source) in lists.entries) {
    final outcome = writeStringIfChanged(
      File(p.join(root.path, path)),
      source,
      dryRun: check,
    );
    final changed = outcome != WriteOutcome.unchanged;
    stale |= changed;
    final count = '\n'.allMatches(source).length;
    stdout.writeln(
      '${check && changed ? 'STALE' : outcome.name.padRight(9)} '
      '$path ($count lines)',
    );
  }
  if (check && stale) {
    stderr.writeln(
      'Run: dart run nesty_tools:gen_font_subsets, then '
      'tools/fonts/build_fonts.sh',
    );
    exitCode = 1;
  } else if (!check && stale) {
    stdout.writeln('Now rebuild the fonts: tools/fonts/build_fonts.sh');
  }
}
