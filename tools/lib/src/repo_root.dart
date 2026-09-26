import 'dart:io';

import 'package:path/path.dart' as p;

/// Finds the Nesty workspace root: the nearest ancestor of [start] (default:
/// the current directory) whose `pubspec.yaml` declares `name:
/// nesty_workspace`.
///
/// Every script resolves its paths from here, so `dart run
/// nesty_tools:<script>` works from the repo root, from `tools/` or from any
/// member directory.
Directory findRepoRoot([String? start]) {
  var dir = Directory(p.absolute(start ?? Directory.current.path));
  while (true) {
    final pubspec = File(p.join(dir.path, 'pubspec.yaml'));
    if (pubspec.existsSync() &&
        RegExp(
          r'^name:\s*nesty_workspace\s*$',
          multiLine: true,
        ).hasMatch(pubspec.readAsStringSync())) {
      return dir;
    }
    final parent = dir.parent;
    if (parent.path == dir.path) {
      throw StateError(
        'Could not find the Nesty workspace root (a pubspec.yaml with '
        '"name: nesty_workspace") above ${start ?? Directory.current.path}.',
      );
    }
    dir = parent;
  }
}
