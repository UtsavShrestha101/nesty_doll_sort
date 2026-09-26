import 'dart:io';

import 'package:nesty_tools/src/fx/lottie_contract.dart';
import 'package:nesty_tools/src/repo_root.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

final _root = findRepoRoot();

String _read(String relative) =>
    File(p.join(_root.path, relative)).readAsStringSync();

/// One row of LOTTIE.md's "Files" table, read the way the contract table
/// was written from it.
final class _Row {
  _Row(this.name, this.canvas, this.anchor, this.length, this.segments);

  final String name;
  final String canvas;
  final String anchor;
  final String length;
  final String segments;
}

/// The rows of the markdown table under `## [heading]`.
List<List<String>> _table(String markdown, String heading) {
  final start = markdown.indexOf('## $heading\n');
  if (start == -1) throw StateError('LOTTIE.md has no "## $heading"');
  final rest = markdown.substring(start + heading.length + 4);
  final end = rest.indexOf('\n## ');
  final section = end == -1 ? rest : rest.substring(0, end);
  return [
    for (final line in section.split('\n'))
      if (line.startsWith('| `'))
        [for (final cell in line.split('|').skip(1)) cell.trim()]..removeLast(),
  ];
}

List<_Row> _filesTable() => [
  for (final cells in _table(
    _read('$designLottieDir/$lottieContractDoc'),
    'Files',
  ))
    _Row(cells[0].replaceAll('`', ''), cells[1], cells[2], cells[3], cells[4]),
];

final _pair = RegExp(r'\(([\d.]+), ([\d.]+)\)');

LottiePoint _pointOf(RegExpMatch m) =>
    LottiePoint(double.parse(m[1]!), double.parse(m[2]!));

void main() {
  final rows = _filesTable();

  test('lists the LOTTIE.md files in table order (29, not the 28 it says)', () {
    expect(rows, hasLength(29));
    expect(
      [for (final c in lottieContracts) c.name],
      [for (final r in rows) r.name],
    );
  });

  group('each entry matches its LOTTIE.md row', () {
    for (final (i, row) in rows.indexed) {
      test(row.name, () {
        final c = lottieContracts[i];

        // Canvas: "board" is the 390×844 reference screen.
        final (w, h) = row.canvas == 'board'
            ? (390.0, 844.0)
            : switch (row.canvas.split('×')) {
                [final w, final h] => (double.parse(w), double.parse(h)),
                _ => fail('canvas "${row.canvas}"'),
              };
        expect((c.width, c.height), (w, h));

        // Length: "41 f", "180 f, loop", "18 f, then hold".
        final frames = RegExp(r'^(\d+) f').firstMatch(row.length);
        expect(c.frames, int.parse(frames![1]!));
        expect(c.loops, row.length.contains('loop'));

        // Segments: "`lift` 0–7", or "`crack_2` 16" (ends where the next
        // one starts, or at the end of the file).
        final found = RegExp(
          r'`(\w+)` (\d+)(?:–(\d+))?',
        ).allMatches(row.segments).toList();
        final markers = [
          for (final (j, m) in found.indexed)
            LottieMarker(
              m[1]!,
              double.parse(m[2]!),
              double.parse(
                    m[3] ??
                        (j + 1 < found.length
                            ? found[j + 1][2]!
                            : '${c.frames}'),
                  ) -
                  double.parse(m[2]!),
            ),
        ];
        expect(c.markers, markers);

        // Kind: board space, segmented (markers) or in place.
        expect(
          c.kind,
          row.canvas == 'board'
              ? LottieKind.boardSpace
              : markers.isNotEmpty
              ? LottieKind.segmented
              : LottieKind.inPlace,
        );

        // Anchor: board-space files are placed by their top-left and carry
        // S → T; a "doll base" wins over a case/ice corner; "center" is the
        // canvas centre; a "box" is placed by its top-left.
        if (row.canvas == 'board') {
          final st = RegExp(
            r'S \(([\d.]+), ([\d.]+)\) → T \(([\d.]+), ([\d.]+)\)',
          ).firstMatch(row.anchor)!;
          expect(
            c.travelS,
            LottiePoint(double.parse(st[1]!), double.parse(st[2]!)),
          );
          expect(
            c.travelT,
            LottiePoint(double.parse(st[3]!), double.parse(st[4]!)),
          );
          expect(c.anchor, LottiePoint.zero);
          expect(c.hookLayers, contains('travel'));
          expect(
            c.hookLayers.contains('target_pos'),
            row.anchor.contains('`target_pos`'),
          );
        } else {
          expect(c.travelS, isNull);
          expect(c.travelT, isNull);
          final dollBase = RegExp(
            r'doll base (\([\d.]+, [\d.]+\))',
          ).firstMatch(row.anchor);
          final first = _pair.firstMatch(dollBase?[1] ?? row.anchor);
          final LottiePoint anchor;
          if (first != null) {
            anchor = _pointOf(first);
          } else if (row.anchor == 'center') {
            anchor = LottiePoint(w / 2, h / 2);
          } else {
            expect(row.anchor, contains('box'));
            anchor = LottiePoint.zero;
          }
          expect(c.anchor, anchor);
        }
      });
    }
  });

  test('the image slots are LOTTIE.md "Image slots", each used somewhere', () {
    final ids = <String>[];
    for (final cells in _table(
      _read('$designLottieDir/$lottieContractDoc'),
      'Image slots',
    )) {
      final cell = cells[0];
      final tokens = RegExp(r'`([a-z0-9_/]+)`').allMatches(cell).toList();
      for (final (i, token) in tokens.indexed) {
        final id = token[1]!;
        final base = id.substring(0, id.lastIndexOf('_') + 1);
        if (id.contains('/')) {
          // `glass_case_0/1/2`
          final [first, ...more] = id.split('/');
          ids
            ..add(first)
            ..addAll(more.map((n) => '$base$n'));
          continue;
        }
        ids.add(id);
        // `ice_0` … `ice_3`
        if (i + 1 < tokens.length &&
            cell.substring(token.end, tokens[i + 1].start).contains('…')) {
          final from = int.parse(id.split('_').last);
          final to = int.parse(tokens[i + 1][1]!.split('_').last);
          for (var n = from + 1; n < to; n++) {
            ids.add('$base$n');
          }
        }
      }
    }
    expect(lottieImageSlots.map((s) => s.id).toSet(), ids.toSet());
    expect(ids.toSet(), hasLength(ids.length));
    expect({for (final c in lottieContracts) ...c.imageAssets}, ids.toSet());
  });

  test('the text files are the three LOTTIE.md "Text layers" names', () {
    expect(
      [
        for (final c in lottieContracts)
          if (c.textLayers.isNotEmpty) c.name,
      ],
      ['ui_family_counter', 'ui_win_ribbon', 'ui_chapter_ribbon'],
    );
  });

  test(
    'size roles, rim and tint follow LOTTIE.md "Doll size, rim and tint"',
    () {
      for (final c in lottieContracts) {
        // Every file that draws a doll part sizes that role.
        final roles = {
          for (final id in c.imageAssets)
            if (id.endsWith('_lid') ||
                id.endsWith('_body') ||
                id == 'doll_silhouette')
              LottieRole.values.byName(id.split('_').first),
        };
        expect(c.roles, roles, reason: c.name);
      }
      expect(
        [
          for (final c in lottieContracts)
            if (c.fills.contains('rim_tint')) c.name,
        ],
        ['doll_nest', 'doll_swallow'],
      );
      expect(
        [
          for (final c in lottieContracts)
            if (c.fills.contains('tint')) c.name,
        ],
        ['doll_reveal', 'fx_twinkle'],
      );
    },
  );

  group('agrees with the game\'s frozen enums', () {
    test('FxId: same files, same order, member = camelCase file name', () {
      final source = _read('apps/game/lib/features/fx/fx_id.dart');
      final members = [
        for (final m in RegExp(
          r"^\s+(\w+)\('([a-z0-9_]+)', FxHost\.\w+\)[,;]",
          multiLine: true,
        ).allMatches(source))
          (m[1]!, m[2]!),
      ];
      expect(members, [
        for (final c in lottieContracts) (lottieMemberName(c.name), c.name),
      ]);
    });

    test('FxImageSlot: same ids, declared sizes and member names', () {
      final source = _read('apps/game/lib/features/fx/fx_image_source.dart');
      final slots = [
        for (final m in RegExp(
          r"(\w+)\(\s*'([a-z0-9_]+)',\s*(\d+),\s*(\d+)",
        ).allMatches(source))
          (m[1]!, m[2]!, double.parse(m[3]!), double.parse(m[4]!)),
      ];
      expect(slots, [
        for (final s in lottieImageSlots)
          (lottieMemberName(s.id), s.id, s.width, s.height),
      ]);
    });

    test('FxKind and FxRole member names', () {
      final spec = _read('apps/game/lib/features/fx/fx_spec.dart');
      for (final kind in LottieKind.values) {
        expect(spec, contains('  ${kind.name},'), reason: kind.name);
      }
      final slots = _read('apps/game/lib/features/fx/fx_image_source.dart');
      for (final role in LottieRole.values) {
        expect(slots, contains('  ${role.name},'), reason: role.name);
      }
    });
  });

  test('member names are lowerCamelCase', () {
    expect(lottieMemberName('doll_pick'), 'dollPick');
    expect(lottieMemberName('glass_case_0'), 'glassCase0');
    expect(lottieMemberName('ui_win_ribbon'), 'uiWinRibbon');
    expect(lottieMemberName('ice_shatter'), 'iceShatter');
  });
}
