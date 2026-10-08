// Generates the home-screen widget's native strings from the game's ARBs
// (stage 4 of the local habits; docs/plans/plan-local-habits.md §4): the
// gallery name, its description and the "open the game" title, which exist
// before Dart runs.
//   iOS     apps/game/ios/NestyWidget/<lang>.lproj/Localizable.strings
//   Android apps/game/android/app/src/main/res/values[-<lang>]/widget_strings.xml
//
// Usage: dart run nesty_tools:gen_widget_strings [--check]
//   --check  write nothing; exit 1 if any file is stale or missing (CI).
import 'dart:io';

import 'package:nesty_tools/src/cli_args.dart';
import 'package:nesty_tools/src/file_writes.dart';
import 'package:nesty_tools/src/repo_root.dart';
import 'package:nesty_tools/src/widget/widget_strings_codegen.dart';
import 'package:path/path.dart' as p;

void main(List<String> arguments) {
  final CliArgs args;
  try {
    args = CliArgs.parse(arguments, flags: {'check', 'help'});
  } on FormatException catch (e) {
    stderr.writeln(e.message);
    exitCode = 64;
    return;
  }
  if (args.flag('help')) {
    stdout.writeln('Usage: dart run nesty_tools:gen_widget_strings [--check]');
    return;
  }
  final check = args.flag('check');
  final root = findRepoRoot();

  final arbs = <String, Map<String, Object?>>{};
  for (final locale in widgetStringsLocales) {
    for (final code in [locale.arb, ?locale.fallbackArb]) {
      if (arbs.containsKey(code)) continue;
      final file = File(p.join(root.path, widgetArbDir, 'app_$code.arb'));
      if (!file.existsSync()) {
        stderr.writeln('$widgetArbDir/app_$code.arb: missing');
        exitCode = 1;
        return;
      }
      arbs[code] = decodeArb(file.readAsStringSync());
    }
  }

  final Map<String, String> files;
  try {
    files = widgetStringFiles(arbs);
  } on FormatException catch (e) {
    stderr.writeln(e.message);
    exitCode = 1;
    return;
  }

  var stale = 0;
  for (final MapEntry(key: path, value: content) in files.entries) {
    final outcome = writeStringIfChanged(
      File(p.join(root.path, path)),
      content,
      dryRun: check,
    );
    if (outcome != WriteOutcome.unchanged) stale++;
    stdout.writeln(
      '${check && outcome != WriteOutcome.unchanged ? 'STALE' : outcome.name.padRight(9)} '
      '$path',
    );
  }
  stdout.writeln(
    '${files.length} files, ${widgetStringsLocales.length} languages'
    '${check ? ' (check)' : ''}',
  );
  if (check && stale > 0) {
    stderr.writeln('Run: dart run nesty_tools:gen_widget_strings');
    exitCode = 1;
  }
}
