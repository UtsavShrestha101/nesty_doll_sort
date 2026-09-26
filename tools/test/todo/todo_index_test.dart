import 'dart:io';

import 'package:nesty_tools/src/repo_root.dart';
import 'package:nesty_tools/src/todo/todo_index.dart';
import 'package:nesty_tools/src/todo/todo_scanner.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

// Built from pieces so this file's own source never contains a marker the
// scanner would index.
const t =
    'TO'
    'DO';
const f =
    'FIX'
    'ME';

List<String> _tags(List<TodoMarker> m) => [for (final x in m) '${x.tag}'];

void main() {
  group('scanTodos in Dart', () {
    test('indexes a tagged marker with its continuation lines', () {
      final markers = scanTodos('lib/a.dart', '''
void main() {}
// $t(M2): export the painter
// and the board layout (spec §10.3).

// unrelated comment
''');
      expect(markers, hasLength(1));
      expect(markers.single.line, 2);
      expect(markers.single.tag, 'M2');
      expect(
        markers.single.text,
        'export the painter and the board layout (spec §10.3).',
      );
    });

    test('splits two markers on one line and stops at the next marker', () {
      final markers = scanTodos('lib/a.dart', '''
/// $t(M3): tier badge. $t(design): final styling.
/// more styling notes
// $t(M2): first
// (spec §10.3). $t(M7): second
''');
      expect(_tags(markers), ['M3', 'design', 'M2', 'M7']);
      expect(markers[0].text, 'tier badge.');
      expect(markers[1].text, 'final styling. more styling notes');
      expect(markers[2].text, 'first (spec §10.3).');
      expect(markers[3].text, 'second');
    });

    test('keeps code spans in the text but ignores markers inside them', () {
      final markers = scanTodos('lib/a.dart', '''
// $t(M4): replace `Fake` with `Real`.

// leave a `// $t(design):` note when a design is missing
''');
      expect(markers, hasLength(1));
      expect(markers.single.text, 'replace `Fake` with `Real`.');
    });

    test('ignores markers outside comments and similar words', () {
      final markers = scanTodos('lib/a.dart', '''
final pattern = '$t';
// never write ${t}_TRANSLATE: placeholders, and list ${t}s here
''');
      expect(markers, isEmpty);
    });

    test('reads block comments', () {
      final markers = scanTodos('lib/a.dart', '''
/*
 * $t(M5): upload limits
 * by content type
 */
''');
      expect(markers.single.tag, 'M5');
      expect(markers.single.text, 'upload limits by content type');
    });

    test('drops a paren the marker was nested in', () {
      final markers = scanTodos(
        'lib/a.dart',
        '// Home ($t(M3): pause menu).\n',
      );
      expect(markers.single.text, 'pause menu.');
    });

    test('accepts combined tags', () {
      final m = scanTodos('lib/a.dart', '// $t(M3/M4/M6): flip\n').single;
      expect(m.tags, ['M3', 'M4', 'M6']);
      expect(m.hasValidTag, isTrue);
    });
  });

  group('scanTodos in other file types', () {
    test('YAML, shell and rules comments', () {
      expect(_tags(scanTodos('a.yaml', 'key: 1 # $t(M4): sync\n')), ['M4']);
      expect(_tags(scanTodos('a.sh', 'echo "#x" # $t(M8): sign\n')), ['M8']);
      expect(_tags(scanTodos('storage.rules', '// $t(M5): limits\n')), ['M5']);
      expect(scanTodos('a.yaml', 'url: a#$t(M4)\n'), isEmpty);
    });

    test('plist comments', () {
      expect(_tags(scanTodos('Info.plist', '<!-- $t(M6): ATT string -->\n')), [
        'M6',
      ]);
    });

    test('Markdown prose, not code', () {
      final markers = scanTodos('README.md', '''
Intro with `$t(M8)` in code.
<!-- $t(M1): decide the fixture
format -->

```
// $t(M2): inside a fence
```
- a list item with $t(M3): a real one
''');
      expect(_tags(markers), ['M1', 'M3']);
      expect(markers.first.text, 'decide the fixture format');
    });

    test('unknown extensions are skipped', () {
      expect(scanTodos('a.json', '// $t(M1): x'), isEmpty);
    });
  });

  group('checkTodos', () {
    test('flags untagged markers in code but not in Markdown prose', () {
      final markers = [
        ...scanTodos('lib/a.dart', '// $t: tidy up\n// $f later\n'),
        ...scanTodos('notes.md', 'A $t: in prose\n'),
      ];
      final violations = checkTodos(markers);
      expect(violations.map((v) => v.marker.location), [
        'lib/a.dart:1',
        'lib/a.dart:2',
      ]);
      expect(violations.first.message, contains('without a tag'));
    });

    test('flags unknown tags everywhere', () {
      final violations = checkTodos([
        ...scanTodos('lib/a.dart', '// $t(M9): x\n// $t(bob): y\n'),
        ...scanTodos('a.md', '$t(M2/M10): z\n'),
      ]);
      expect(violations, hasLength(3));
      expect(violations.first.message, contains('Unknown tag "M9"'));
    });

    test('accepts every allowed tag', () {
      final source = allowedTags.map((tag) => '// $t($tag): x').join('\n');
      expect(checkTodos(scanTodos('lib/a.dart', source)), isEmpty);
    });
  });

  group('renderTodoIndex', () {
    final markers = [
      ...scanTodos('lib/b.dart', '// $t(M3/M4): both\n'),
      ...scanTodos('lib/a.dart', '// $t(M4): first\n\n// $f(M4): broken\n'),
      ...scanTodos('lib/c.dart', '// $t(nope): skipped\n'),
    ];
    final index = renderTodoIndex(markers);

    test('lists combos under every milestone they name, sorted by path', () {
      final m3 = index.indexOf('## M3');
      final m4 = index.indexOf('## M4');
      final m5 = index.indexOf('## M5');
      expect(
        index.substring(m3, m4),
        contains('`lib/b.dart:1` (also M4) — both'),
      );
      final m4Section = index.substring(m4, m5);
      expect(
        m4Section.indexOf('lib/a.dart:1'),
        lessThan(m4Section.indexOf('lib/a.dart:3')),
      );
      expect(m4Section, contains('`lib/a.dart:3` **FIXME** — broken'));
      expect(m4Section, contains('(also M3) — both'));
      expect(index, contains('| M4 | Firebase content | 3 |'));
      expect(index, isNot(contains('skipped')));
    });

    test('is deterministic', () {
      expect(renderTodoIndex(markers.reversed.toList()), index);
    });
  });

  test('scannableFiles skips design, config, build and generated files', () {
    final root = Directory.systemTemp.createTempSync('nesty_todo_');
    addTearDown(() => root.deleteSync(recursive: true));
    for (final path in [
      'lib/a.dart',
      'lib/a.g.dart',
      'lib/a.freezed.dart',
      'lib/router.gr.dart',
      'lib/di.config.dart',
      'lib/tokens.gen.dart',
      'lib/l10n/app_localizations_en.dart',
      'lib/hive_adapters.g.yaml',
      'design/tokens.md',
      '.claude/agents/x.md',
      'apps/game/build/x.dart',
      'apps/game/.dart_tool/x.dart',
      'docs/TODO_INDEX.md',
      'docs/PROGRESS.md',
      'pubspec.lock',
      'pubspec.yaml',
      'firebase/storage.rules',
      'data.json',
    ]) {
      File(p.join(root.path, path))
        ..parent.createSync(recursive: true)
        ..writeAsStringSync('');
    }
    expect(scannableFiles(root), [
      'docs/PROGRESS.md',
      'firebase/storage.rules',
      'lib/a.dart',
      'pubspec.yaml',
    ]);
  });

  group('this repository', () {
    final root = findRepoRoot();
    final markers = scanRepo(root);

    test('has no untagged or unknown-tag markers', () {
      expect(checkTodos(markers).map((v) => '$v'), isEmpty);
    });

    test('docs/TODO_INDEX.md is up to date', () {
      expect(
        File(p.join(root.path, todoIndexPath)).readAsStringSync(),
        renderTodoIndex(markers),
        reason: 'run dart run nesty_tools:todo_index',
      );
    });
  });
}
