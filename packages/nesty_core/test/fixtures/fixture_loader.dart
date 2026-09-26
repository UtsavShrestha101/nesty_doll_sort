// Reads the level fixtures in this folder (see README.md) for the codec,
// validator and solver tests.
//
// VM only: it reads files with dart:io, which the web test platforms (chrome,
// node) don't have. A test that imports it must carry @TestOn('vm').
library;

import 'dart:io';
import 'dart:isolate';

import 'package:nesty_core/nesty_core.dart';

/// The two fixture folders. The folder a file sits in is its expected
/// solver verdict.
enum FixtureFolder { solvable, unsolvable }

/// One fixture file, read and decoded.
final class Fixture {
  Fixture._(this.folder, this.name, this.source, this.decoded);

  final FixtureFolder folder;

  /// The file name without `.json`, such as `001_l1_tutorial`: the key of
  /// test/solver/fixture_expectations.dart.
  final String name;

  /// The file's text.
  final String source;

  /// What `LevelCodec.decodeString(source)` returned.
  final LevelDecodeResult decoded;

  /// The decoded level. Throws a [StateError] naming the issues when the
  /// file doesn't decode, so a broken fixture fails loudly.
  Level get level =>
      decoded.level ??
      (throw StateError('Fixture $folder/$name: ${decoded.issues}'));

  @override
  String toString() => '${folder.name}/$name';
}

/// Every fixture in [folder], sorted by name.
///
/// Synchronous, so a test file can declare one test per fixture in `main`.
List<Fixture> loadFixtures(FixtureFolder folder) {
  final directory = Directory('${fixturesDirectory().path}/${folder.name}');
  final files = [
    for (final entity in directory.listSync())
      if (entity is File && entity.path.endsWith('.json')) entity,
  ]..sort((a, b) => a.path.compareTo(b.path));
  return [for (final file in files) _read(folder, file)];
}

Fixture _read(FixtureFolder folder, File file) {
  final source = file.readAsStringSync();
  final base = file.uri.pathSegments.last;
  return Fixture._(
    folder,
    base.substring(0, base.length - '.json'.length),
    source,
    LevelCodec.decodeString(source),
  );
}

/// Every fixture in both folders.
List<Fixture> loadAllFixtures() => [
  for (final folder in FixtureFolder.values) ...loadFixtures(folder),
];

/// The fixture with [name] in [folder]. Throws a [StateError] when there is
/// none.
Fixture fixture(FixtureFolder folder, String name) =>
    loadFixtures(folder).firstWhere(
      (f) => f.name == name,
      orElse: () => throw StateError('No fixture ${folder.name}/$name'),
    );

/// This folder, found through the package config rather than the working
/// directory, so the tests also work when started from the workspace root.
Directory fixturesDirectory() {
  final barrel = Isolate.resolvePackageUriSync(
    Uri.parse('package:nesty_core/nesty_core.dart'),
  );
  if (barrel == null) {
    throw StateError('package:nesty_core is not in the package config.');
  }
  final packageRoot = File.fromUri(barrel).parent.parent;
  return Directory('${packageRoot.path}/test/fixtures');
}
