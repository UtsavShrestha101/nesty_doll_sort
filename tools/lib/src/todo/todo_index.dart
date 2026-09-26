import 'dart:io';

import 'package:nesty_tools/src/todo/todo_scanner.dart';
import 'package:path/path.dart' as p;

/// Repo-relative path of the generated index.
const todoIndexPath = 'docs/TODO_INDEX.md';

// Never scanned: VCS/tool/build output, the owner's design exports, vendored
// or platform-generated trees, and Claude Code config (whose docs describe
// the marker convention rather than carrying work items).
const _skippedDirs = {
  '.git',
  '.dart_tool',
  '.claude',
  '.idea',
  '.vscode',
  '.gradle',
  '.kotlin',
  '.cxx',
  '.symlinks',
  '.pub-cache',
  '.fvm',
  'build',
  'coverage',
  'ephemeral',
  'node_modules',
  'Pods',
};
const _skippedRootDirs = {'design'};

// Generated files: their markers belong to (and are fixed in) the generator.
final _generated = RegExp(
  r'(\.(g|freezed|gr|config|gen)\.dart|\.g\.yaml|/app_localizations[^/]*\.dart'
  r'|/GeneratedPluginRegistrant\.[a-z]+)$',
);
const _skippedFiles = {'pubspec.lock', todoIndexPath};

// Spec §18 milestone names, plus the non-milestone tags.
const _tagTitles = {
  'M1': 'Core (`nesty_core`)',
  'M2': 'Playable game',
  'M3': 'App shell and meta',
  'M4': 'Firebase content',
  'M5': 'Admin panel',
  'M6': 'Monetization',
  'M7': 'Art and polish',
  'M8': 'Release prep',
  'v1.1': 'After v1 (e.g. the golden doll, spec §3.5)',
  'design': 'Waiting on a design export or decision from the owner',
  'later': 'Unscheduled (spec §19 "Later ideas")',
};

/// Every scanned file under [root], repo-relative with `/` separators,
/// sorted.
List<String> scannableFiles(Directory root) {
  final files = <String>[];
  void walk(Directory dir) {
    final entries = dir.listSync(followLinks: false)
      ..sort((a, b) => a.path.compareTo(b.path));
    for (final entity in entries) {
      final name = p.basename(entity.path);
      final relative = p.posix.joinAll(
        p.split(p.relative(entity.path, from: root.path)),
      );
      if (entity is Directory) {
        if (_skippedDirs.contains(name)) continue;
        if (dir.path == root.path && _skippedRootDirs.contains(name)) continue;
        walk(entity);
      } else if (entity is File) {
        final ext = name.contains('.') ? name.split('.').last : '';
        if (!scannedExtensions.contains(ext)) continue;
        if (_skippedFiles.contains(relative) || _skippedFiles.contains(name)) {
          continue;
        }
        if (_generated.hasMatch('/$relative')) continue;
        files.add(relative);
      }
    }
  }

  walk(root);
  return files..sort();
}

/// Scans every first-party file under [root].
List<TodoMarker> scanRepo(Directory root) => [
  for (final relative in scannableFiles(root))
    ...scanTodos(
      relative,
      File(p.join(root.path, relative)).readAsStringSync(),
    ),
];

/// Renders the index for [markers]. Deterministic: markers are ordered by
/// tag, then path, then line, and nothing time-dependent is written.
String renderTodoIndex(List<TodoMarker> markers) {
  final valid = markers.where((m) => m.hasValidTag).toList()
    ..sort((a, b) {
      final byPath = a.path.compareTo(b.path);
      return byPath != 0 ? byPath : a.line.compareTo(b.line);
    });
  final byTag = {
    for (final tag in allowedTags)
      tag: [
        for (final m in valid)
          if (m.tags.contains(tag)) m,
      ],
  };
  final out = StringBuffer()
    ..writeln('# TODO index')
    ..writeln()
    ..writeln(
      '<!-- GENERATED — do not edit; run dart run nesty_tools:todo_index -->',
    )
    ..writeln()
    ..writeln(
      'Every tagged `TODO(<tag>)` / `FIXME(<tag>)` marker in first-party code '
      'and docs, grouped by milestone (spec §18), so no future-milestone work '
      'is lost. When you start a milestone, work through its section; when '
      'you finish one, its section must be empty or every entry moved to a '
      'later tag on purpose.',
    )
    ..writeln()
    ..writeln(
      '- **Tags:** `M1`…`M8`, `v1.1`, `design`, `later`; combinations like '
      '`M3/M4` are listed under each milestone they name.',
    )
    ..writeln(
      '- **Rules:** `dart run nesty_tools:todo_index --check` (CI) fails when '
      'this file is stale, when a tag is unknown, or when a code comment has a '
      '`TODO`/`FIXME` without a tag. Markers inside `backticks` or fenced code '
      'blocks are references, not work items, and are not indexed.',
    )
    ..writeln(
      '- **Not scanned:** `design/`, `.claude/`, build output and generated '
      'files (`*.g.dart`, `*.freezed.dart`, `*.gr.dart`, `*.config.dart`, '
      '`*.gen.dart`, gen-l10n output).',
    )
    ..writeln()
    ..writeln('| Tag | Scope | Open |')
    ..writeln('|---|---|---:|');
  for (final tag in allowedTags) {
    out.writeln('| $tag | ${_tagTitles[tag]} | ${byTag[tag]!.length} |');
  }
  out
    ..writeln()
    ..writeln('Total: ${valid.length} markers.');
  for (final tag in allowedTags) {
    final items = byTag[tag]!;
    out
      ..writeln()
      ..writeln('## $tag — ${_tagTitles[tag]}')
      ..writeln();
    if (items.isEmpty) {
      out.writeln('_None._');
      continue;
    }
    for (final m in items) {
      final also = m.tags.where((t) => t != tag).toList();
      final text = m.text.isEmpty ? '_(no description)_' : m.text;
      out.writeln(
        '- `${m.location}` '
        '${m.kind == 'FIXME' ? '**FIXME** ' : ''}'
        '${also.isEmpty ? '' : '(also ${also.join(', ')}) '}'
        '— $text',
      );
    }
  }
  return out.toString();
}
