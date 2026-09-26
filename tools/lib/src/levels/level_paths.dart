import 'dart:io';

import 'package:path/path.dart' as p;

/// Where the level tools read and write, relative to the repo root
/// (tools/levels/README.md, design §4).
abstract final class LevelPaths {
  /// The authored levels' manifest: order, id, chapter, declared tier.
  static const String manifest = 'tools/levels/manifest.json';

  /// One pure spec §5.1 level per file, named `<id>.json`.
  static const String authoredDir = 'tools/levels/authored';

  /// The game's offline levels (spec §13.4), written by `bundle build`.
  static const String bundle = 'apps/game/assets/levels/bundle.json';

  /// nesty_core's solver fixtures (packages/nesty_core/test/fixtures/).
  static const String fixturesDir = 'packages/nesty_core/test/fixtures';

  /// The fixtures' expected optimal move counts and verdicts.
  static const String fixtureExpectations =
      'packages/nesty_core/test/solver/fixture_expectations.dart';

  /// The authored file of level [id], next to [manifestFile].
  static File authoredFile(File manifestFile, String id) =>
      File(p.join(manifestFile.parent.path, 'authored', '$id.json'));

  /// [relative] (posix) under [root].
  static File file(Directory root, String relative) =>
      File(p.joinAll([root.path, ...p.posix.split(relative)]));

  /// [relative] (posix) under [root].
  static Directory dir(Directory root, String relative) =>
      Directory(p.joinAll([root.path, ...p.posix.split(relative)]));

  /// [file] relative to [root] with `/` separators, for messages that read
  /// the same on every OS; an absolute path when it is outside [root].
  static String display(Directory root, FileSystemEntity file) {
    final relative = p.relative(file.path, from: root.path);
    return relative.startsWith('..')
        ? p.absolute(file.path)
        : p.split(relative).join('/');
  }
}
