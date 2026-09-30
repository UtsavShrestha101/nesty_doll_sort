// The owner's rule (CLAUDE.md "Testing", PROGRESS D169): `nesty-test` covers
// every feature. docs/TEST_COVERAGE.md says what checks each one, on the host
// and on a device. This test fails when a game feature folder or an
// on-device check is added without its row there, or when an on-device check
// exists that `tools/scripts/nesty-test` never runs.
//
// It can't judge whether a row's device step is enough; the rule and the
// review do that. It keeps the table from silently falling behind.
import 'dart:io';

import 'package:nesty_tools/src/repo_root.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

void main() {
  final root = findRepoRoot();
  final coverage = File(
    p.join(root.path, 'docs', 'TEST_COVERAGE.md'),
  ).readAsStringSync();
  final nestyTest = File(
    p.join(root.path, 'tools', 'scripts', 'nesty-test'),
  ).readAsStringSync();

  String fix(String what) =>
      '$what. Give each its row in docs/TEST_COVERAGE.md and its step in '
      '`tools/scripts/nesty-test` (CLAUDE.md "Testing", D169), then re-run '
      '`cd tools && dart test`.';

  final integrationTests = [
    for (final f in Directory(
      p.join(root.path, 'apps', 'game', 'integration_test'),
    ).listSync())
      if (f is File && f.path.endsWith('_test.dart')) p.basename(f.path),
  ]..sort();

  test('has a row for every game feature folder', () {
    final features = [
      for (final e in Directory(
        p.join(root.path, 'apps', 'game', 'lib', 'features'),
      ).listSync())
        if (e is Directory) p.basename(e.path),
    ]..sort();
    expect(features, isNotEmpty);
    final missing = [
      for (final f in features)
        if (!coverage.contains('`features/$f`')) f,
    ];
    expect(missing, isEmpty, reason: fix('Features without a row: $missing'));
  });

  test('names every on-device check', () {
    expect(integrationTests, isNotEmpty);
    final missing = [
      for (final t in integrationTests)
        if (!coverage.contains(t)) t,
    ];
    expect(
      missing,
      isEmpty,
      reason: fix('On-device checks not in the table: $missing'),
    );
  });

  test('nesty-test runs every on-device check', () {
    // The script drives each check by its file name (`drive <file> …`).
    final missing = [
      for (final t in integrationTests)
        if (!nestyTest.contains(t)) t,
    ];
    expect(
      missing,
      isEmpty,
      reason: fix('On-device checks nesty-test never runs: $missing'),
    );
  });
}
