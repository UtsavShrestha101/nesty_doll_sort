// Mechanically enforces CLAUDE.md rules 2 and 7 and spec §6.5 on every file
// in nesty_core/lib, so a Flutter import, dart:math Random or a wall-clock
// read fails `dart test` instead of slipping through review.
import 'dart:io';
import 'dart:isolate';

import 'package:test/test.dart';

import 'support/core_guards.dart';
import 'support/dart_source_scanner.dart';

void main() {
  late Directory packageRoot;
  late Map<String, ScannedSource> libFiles;

  setUpAll(() async {
    packageRoot = await _packageRoot();
    final lib = Directory('${packageRoot.path}/lib');
    libFiles = {
      for (final file in lib.listSync(recursive: true).whereType<File>())
        if (file.path.endsWith('.dart'))
          file.path
              .substring(packageRoot.path.length + 1)
              .replaceAll(r'\', '/'): ScannedSource.parse(
            file.readAsStringSync(),
          ),
    };
  });

  test('finds the library sources, so the guards are not vacuous', () {
    expect(libFiles.keys, contains('lib/nesty_core.dart'));
    expect(libFiles.keys, contains('lib/src/models/doll_color.dart'));
  });

  group('nesty_core/lib', () {
    for (final guard in coreGuards) {
      test(guard.description, () {
        final violations = [
          for (final MapEntry(key: path, value: source) in libFiles.entries)
            for (final (line, detail) in guard.check(source))
              Violation(path, line, detail),
        ];
        expect(
          violations,
          isEmpty,
          reason: 'Offending code:\n${violations.join('\n')}',
        );
      });
    }
  });

  test('pubspec does not depend on the Flutter SDK (CLAUDE.md rule 2)', () {
    final pubspec = File('${packageRoot.path}/pubspec.yaml').readAsStringSync();
    expect(
      pubspec,
      isNot(matches(RegExp(r'^\s*sdk:\s*flutter\b', multiLine: true))),
    );
  });
}

/// Locates the package through the package config rather than the working
/// directory, so the guard also works when tests are started from the
/// workspace root.
Future<Directory> _packageRoot() async {
  final barrel = await Isolate.resolvePackageUri(
    Uri.parse('package:nesty_core/nesty_core.dart'),
  );
  if (barrel == null) {
    throw StateError('package:nesty_core is not in the package config.');
  }
  return File.fromUri(barrel).parent.parent;
}
