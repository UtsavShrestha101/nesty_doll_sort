// CLAUDE.md is loaded into every Claude Code session so that a session can
// find its way without reading the whole repo. That only works while it
// matches the repo, so this test fails when something it must name is added
// without a CLAUDE.md update (CLAUDE.md "Keeping this file current").
//
// It checks only what can be listed mechanically: workspace members,
// top-level folders, nesty_tools scripts, path-scoped rules, the game's
// feature folders and every DI-bound service interface. The prose sections
// (Current state, the gameplay flow) are kept current by the rule itself.
import 'dart:io';

import 'package:nesty_tools/src/repo_root.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

void main() {
  final root = findRepoRoot();
  final claudeMd = File(p.join(root.path, 'CLAUDE.md')).readAsStringSync();

  bool names(String token) => claudeMd.contains(token);

  List<String> dirNames(String relative) {
    final dir = Directory(p.join(root.path, relative));
    if (!dir.existsSync()) return const [];
    return [
      for (final e in dir.listSync())
        if (e is Directory) p.basename(e.path),
    ]..sort();
  }

  String fix(String what) =>
      'CLAUDE.md is missing $what. Add it (see "Keeping this file current" '
      'in CLAUDE.md), then re-run `cd tools && dart test`.';

  test('names every workspace member', () {
    final pubspec = File(p.join(root.path, 'pubspec.yaml')).readAsStringSync();
    final block = RegExp(
      r'^workspace:\s*\n((?:\s+-\s+.+\n?)+)',
      multiLine: true,
    ).firstMatch(pubspec);
    expect(block, isNotNull, reason: 'root pubspec.yaml has no workspace:');
    final members = [
      for (final m in RegExp(r'-\s+(\S+)').allMatches(block!.group(1)!))
        m.group(1)!,
    ];
    expect(members, isNotEmpty);
    final missing = [
      for (final m in members)
        if (!names('$m/')) m,
    ];
    expect(missing, isEmpty, reason: fix('workspace members $missing'));
  });

  test('names every top-level folder in the repository layout', () {
    // Build output and tool caches are not part of the layout.
    const ignored = {'build', '.dart_tool', '.git', '.idea'};
    final missing = [
      for (final d in dirNames('.'))
        if (!ignored.contains(d) && !names('  $d/')) d,
    ];
    expect(missing, isEmpty, reason: fix('top-level folders $missing'));
  });

  test('names every nesty_tools script', () {
    final bin = Directory(p.join(root.path, 'tools', 'bin'));
    final scripts = [
      for (final f in bin.listSync())
        if (f is File && f.path.endsWith('.dart'))
          p.basenameWithoutExtension(f.path),
    ]..sort();
    expect(scripts, isNotEmpty);
    final missing = [
      for (final s in scripts)
        if (!names('nesty_tools:$s')) s,
    ];
    expect(missing, isEmpty, reason: fix('`nesty_tools:` scripts $missing'));
  });

  test('names every path-scoped rule in .claude/rules', () {
    final dir = Directory(p.join(root.path, '.claude', 'rules'));
    if (!dir.existsSync()) return;
    final rules = [
      for (final f in dir.listSync())
        if (f is File && f.path.endsWith('.md'))
          p.basenameWithoutExtension(f.path),
    ]..sort();
    final missing = [
      for (final r in rules)
        if (!names('`$r`')) r,
    ];
    expect(missing, isEmpty, reason: fix('.claude/rules entries $missing'));
  });

  test("names every feature folder of the game's Code map", () {
    final missing = [
      for (final f in dirNames('apps/game/lib/features'))
        if (!names('`$f`') && !names('features/$f')) f,
    ];
    expect(missing, isEmpty, reason: fix('apps/game features $missing'));
  });

  test('names every DI-bound service interface of both apps', () {
    // `@LazySingleton(as: Foo, …)`, `@Singleton(as: Foo)`, `@Injectable(as:
    // Foo)` in hand-written sources. Comment lines are skipped: di.dart
    // quotes the annotation as an example.
    final binding = RegExp(
      r'@(?:LazySingleton|Singleton|Injectable)\(\s*as:\s*(\w+)',
    );
    final generated = RegExp(r'\.(g|freezed|gr|config|gen)\.dart$');
    final interfaces = <String>{};
    for (final app in ['apps/game/lib', 'apps/admin/lib']) {
      final dir = Directory(p.join(root.path, app));
      for (final f in dir.listSync(recursive: true)) {
        if (f is! File ||
            !f.path.endsWith('.dart') ||
            generated.hasMatch(f.path)) {
          continue;
        }
        for (final line in f.readAsLinesSync()) {
          if (line.trimLeft().startsWith('//')) continue;
          for (final m in binding.allMatches(line)) {
            interfaces.add(m.group(1)!);
          }
        }
      }
    }
    expect(interfaces, isNotEmpty);
    final missing = [
      for (final i in interfaces.toList()..sort())
        if (!RegExp('\\b$i\\b').hasMatch(claudeMd)) i,
    ];
    expect(missing, isEmpty, reason: fix('service interfaces $missing'));
  });
}
