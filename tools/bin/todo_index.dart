// Indexes every tagged work marker (see tools/lib/src/todo/todo_scanner.dart)
// into docs/TODO_INDEX.md, grouped by milestone, so future-milestone work
// is tracked in one place.
//
// Usage: dart run nesty_tools:todo_index [--check]
//   (default) rewrite docs/TODO_INDEX.md if it changed.
//   --check   write nothing; exit 1 if the index is stale, a tag is
//             unknown, or a code comment carries an untagged marker.
// Both modes exit 1 on untagged or unknown-tag markers.
import 'dart:io';

import 'package:nesty_tools/src/cli_args.dart';
import 'package:nesty_tools/src/file_writes.dart';
import 'package:nesty_tools/src/repo_root.dart';
import 'package:nesty_tools/src/todo/todo_index.dart';
import 'package:nesty_tools/src/todo/todo_scanner.dart';
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
    stdout.writeln('Usage: dart run nesty_tools:todo_index [--check]');
    return;
  }
  final check = args.flag('check');
  final root = findRepoRoot();
  final markers = scanRepo(root);
  final violations = checkTodos(markers);
  final index = renderTodoIndex(markers);
  final outcome = writeStringIfChanged(
    File(p.join(root.path, todoIndexPath)),
    index,
    dryRun: check,
  );

  final tagged = markers.where((m) => m.hasValidTag).length;
  stdout.writeln(
    '${check && outcome != WriteOutcome.unchanged ? 'STALE' : outcome.name.padRight(9)} '
    '$todoIndexPath ($tagged tagged markers)',
  );
  for (final v in violations) {
    stderr.writeln(v);
  }
  if (violations.isNotEmpty) {
    stderr.writeln(
      '${violations.length} marker(s) need a tag: ${allowedTags.join(', ')}.',
    );
    exitCode = 1;
  }
  if (check && outcome != WriteOutcome.unchanged) {
    stderr.writeln('Run: dart run nesty_tools:todo_index');
    exitCode = 1;
  }
}
