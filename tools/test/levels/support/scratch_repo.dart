import 'dart:convert';
import 'dart:io';

import 'package:nesty_tools/src/levels/cli.dart';
import 'package:path/path.dart' as p;

/// The design's tutorial boards (design §4 TUT1/TUT2), with a chosen id.
String tutorial1(String id) => jsonEncode({
  'schemaVersion': 1,
  'id': id,
  'maxSize': 3,
  'shelves': [
    [
      {
        'type': 'open',
        'nest': ['red3'],
      },
      {'type': 'open', 'nest': null},
      {
        'type': 'open',
        'nest': ['red2'],
      },
    ],
    [
      {'type': 'open', 'nest': null},
      {
        'type': 'open',
        'nest': ['red1'],
      },
      {'type': 'open', 'nest': null},
    ],
  ],
});

String tutorial2(String id) => jsonEncode({
  'schemaVersion': 1,
  'id': id,
  'maxSize': 3,
  'shelves': [
    [
      {
        'type': 'open',
        'nest': ['red3'],
      },
      {
        'type': 'open',
        'nest': ['blue2'],
      },
      {'type': 'open', 'nest': null},
    ],
    [
      {
        'type': 'open',
        'nest': ['red2', 'red1'],
      },
      {
        'type': 'open',
        'nest': ['blue3'],
      },
      {
        'type': 'open',
        'nest': ['blue1'],
      },
    ],
  ],
});

/// A manifest entry.
Map<String, Object?> manifestEntry(
  int order,
  String id, {
  String tier = 'easy',
  String chapterId = 'ch01',
  int version = 1,
  String? tierOverride,
}) => {
  'order': order,
  'id': id,
  'chapterId': chapterId,
  'tier': tier,
  'version': version,
  'tierOverride': ?tierOverride,
};

/// What one `nesty_levels` run printed and returned.
final class CliRun {
  const CliRun(this.exitCode, this.out, this.err);

  final int exitCode;
  final String out;
  final String err;

  @override
  String toString() => 'exit $exitCode\n--- out\n$out--- err\n$err';
}

/// A throwaway repo root (a `pubspec.yaml` named `nesty_workspace`) for the
/// level tools to read and write, deleted after each test.
final class ScratchRepo {
  ScratchRepo._(this.root);

  factory ScratchRepo.create() {
    final dir = Directory.systemTemp.createTempSync('nesty_levels_test_');
    File(
      p.join(dir.path, 'pubspec.yaml'),
    ).writeAsStringSync('name: nesty_workspace\n');
    return ScratchRepo._(dir);
  }

  final Directory root;

  File file(String relative) =>
      File(p.joinAll([root.path, ...p.posix.split(relative)]));

  void write(String relative, String content) {
    final f = file(relative);
    f.parent.createSync(recursive: true);
    f.writeAsStringSync(content);
  }

  String read(String relative) => file(relative).readAsStringSync();

  /// `tools/levels/manifest.json` with [entries].
  void writeManifest(
    List<Map<String, Object?>> entries, {
    int levelsVersion = 0,
  }) => write(
    'tools/levels/manifest.json',
    const JsonEncoder.withIndent('  ').convert({
      'format': 'nesty.levels.manifest',
      'manifestVersion': 1,
      'levelsVersion': levelsVersion,
      'levels': entries,
    }),
  );

  /// `tools/levels/authored/<id>.json`.
  void writeLevel(String id, String json) =>
      write('tools/levels/authored/$id.json', json);

  /// The two tutorials as L0001 and L0002, declared easy (spec §6.6).
  void writeTutorials() {
    writeLevel('L0001', tutorial1('L0001'));
    writeLevel('L0002', tutorial2('L0002'));
    writeManifest([manifestEntry(1, 'L0001'), manifestEntry(2, 'L0002')]);
  }

  /// Runs `nesty_levels` in-process with [cwd] (relative to the root) as
  /// the current directory.
  CliRun run(List<String> arguments, {String cwd = '.'}) {
    final out = StringBuffer();
    final err = StringBuffer();
    final code = runNestyLevels(
      arguments,
      out: out,
      err: err,
      root: root,
      cwd: Directory(p.normalize(p.join(root.path, cwd))),
    );
    return CliRun(code, out.toString(), err.toString());
  }

  void delete() => root.deleteSync(recursive: true);
}
