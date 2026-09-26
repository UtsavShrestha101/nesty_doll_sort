// Keeps test/parity/ runnable on every platform (design §5, D11). A parity
// file that imports dart:io, or is limited with @TestOn, compiles or runs
// only on the VM, and the VM/web comparison it was written for silently
// stops happening. This guard fails `dart test` instead.
//
// It is the one VM-only file here, because it reads the sources with
// dart:io. The web runs skip it.
@TestOn('vm')
@Tags(['parity'])
library;

import 'dart:io';
import 'dart:isolate';

import 'package:test/test.dart';

import '../support/dart_source_scanner.dart';

const _self = 'parity_guard_test.dart';

// Libraries the web platforms (chrome, node) don't have.
final _vmOnlyLibrary = RegExp(r'^dart:(io|isolate|ffi|mirrors|cli)$');

void main() {
  late Map<String, ScannedSource> files;

  setUpAll(() async {
    final dir = Directory('${(await _packageRoot()).path}/test/parity');
    files = {
      for (final file in dir.listSync(recursive: true).whereType<File>())
        if (file.path.endsWith('.dart') && !file.path.endsWith('/$_self'))
          file.path.substring(dir.path.length + 1).replaceAll(r'\', '/'):
              ScannedSource.parse(file.readAsStringSync()),
    };
  });

  test('finds the parity sources, so the checks are not vacuous', () {
    expect(files.keys, containsAll(['parity.dart', 'prng_parity_test.dart']));
  });

  test('no parity file imports a VM-only library', () {
    final offending = [
      for (final MapEntry(key: path, value: source) in files.entries)
        for (final directive in directives(source))
          for (final uri in directive.uris)
            if (_vmOnlyLibrary.hasMatch(uri)) '$path:${directive.line} $uri',
    ];
    expect(offending, isEmpty, reason: offending.join('\n'));
  });

  test('every parity test file is tagged parity and not platform-limited', () {
    final tags = RegExp(r'''@Tags\(\s*(const\s*)?\[[^\]]*['"]parity['"]''');
    final problems = [
      for (final MapEntry(key: path, value: source) in files.entries)
        if (path.endsWith('_test.dart')) ...[
          if (!tags.hasMatch(source.codeAndStrings))
            "$path: missing @Tags(['parity'])",
          if (source.code.contains('@TestOn'))
            '$path: @TestOn keeps it off some platforms',
        ],
    ];
    expect(problems, isEmpty, reason: problems.join('\n'));
  });
}

/// Locates the package through the package config, so the guard also works
/// when tests start from the workspace root.
Future<Directory> _packageRoot() async {
  final barrel = await Isolate.resolvePackageUri(
    Uri.parse('package:nesty_core/nesty_core.dart'),
  );
  if (barrel == null) {
    throw StateError('package:nesty_core is not in the package config.');
  }
  return File.fromUri(barrel).parent.parent;
}
