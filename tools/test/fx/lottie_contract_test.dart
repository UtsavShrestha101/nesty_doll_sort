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

/// The text under `## [heading]`, up to the next `## `.
String _section(String markdown, String heading) {
  final start = markdown.indexOf('## $heading\n');
  if (start == -1) throw StateError('LOTTIE.md has no "## $heading"');
  final rest = markdown.substring(start + heading.length + 4);
  final end = rest.indexOf('\n## ');
  return end == -1 ? rest : rest.substring(0, end);
}

/// The rows of the markdown table under `## [heading]`.
List<List<String>> _table(String markdown, String heading) => [
  for (final line in _section(markdown, heading).split('\n'))
    if (line.startsWith('| `'))
      [for (final cell in line.split('|').skip(1)) cell.trim()]..removeLast(),
];

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

/// A number as LOTTIE.md writes it, with a typographic minus (`−18`).
double _num(String text) => double.parse(text.replaceAll('−', '-'));

/// One row of LOTTIE.md's "Image slots" table, read into slot ids and
/// their pixel sizes.
final class _SlotRow {
  _SlotRow(this.cell, this.ids, this.sizes, {required this.reference});

  final String cell;

  /// Every slot id the row names, expanded.
  final List<String> ids;

  /// Each id's px size (the ids of a reference row are skipped).
  final List<(String, (double, double))> sizes;

  /// m7-3's "the same rasters as the board files": a row that lists slots
  /// already given above, for another file.
  final bool reference;
}

/// The slot ids of one first cell, one list per backticked token, with
/// three expansions:
/// - `glass_case_0/1/2` → `glass_case_0`, `glass_case_1`, `glass_case_2`;
/// - `ice_0` … `ice_3` → the ids in between join `ice_0`'s list;
/// - m7-3's "`mover`, `revealed` (lid and body)": each bare role before the
///   parenthesis → `<role>_lid`, `<role>_body`.
List<List<String>> _slotGroups(String cell) {
  final tokens = RegExp(r'`([a-z0-9_/]+)`').allMatches(cell).toList();
  final lidAndBody = cell.indexOf('(lid and body)');
  final groups = <List<String>>[];
  for (final (i, token) in tokens.indexed) {
    final id = token[1]!;
    if (lidAndBody != -1 && token.start < lidAndBody) {
      groups.add(['${id}_lid', '${id}_body']);
    } else if (id.contains('/')) {
      final [first, ...more] = id.split('/');
      final base = first.substring(0, first.lastIndexOf('_') + 1);
      groups.add([first, ...more.map((n) => '$base$n')]);
    } else if (i + 1 < tokens.length &&
        cell.substring(token.end, tokens[i + 1].start).contains('…')) {
      final base = id.substring(0, id.lastIndexOf('_') + 1);
      final from = int.parse(id.split('_').last);
      final to = int.parse(tokens[i + 1][1]!.split('_').last);
      groups.add([id, for (var n = from + 1; n < to; n++) '$base$n']);
    } else {
      groups.add([id]);
    }
  }
  return groups;
}

List<_SlotRow> _imageSlotRows() {
  final rows = <_SlotRow>[];
  for (final [cell, supplies, ...] in _table(
    _read('$designLottieDir/$lottieContractDoc'),
    'Image slots',
  )) {
    final groups = _slotGroups(cell);
    // "… at 3×: 348×156, 120×150 and 270×102 px (116×52, 40×50 and 90×34
    // dp)": each group takes the next px size of the second cell (dp sizes
    // in parentheses are skipped), or all of them take the only one.
    final pixels = [
      for (final m in RegExp(
        r'(\d+)×(\d+)',
      ).allMatches(supplies.replaceAll(RegExp(r'\([^)]*dp[^)]*\)'), '')))
        (double.parse(m[1]!), double.parse(m[2]!)),
    ];
    expect(pixels, isNotEmpty, reason: cell);
    final reference = supplies.startsWith('the same rasters as');
    rows.add(
      _SlotRow(
        cell,
        [for (final g in groups) ...g],
        [
          if (!reference)
            for (final (i, group) in groups.indexed)
              for (final id in group)
                (id, pixels.length == 1 ? pixels.single : pixels[i]),
        ],
        reference: reference,
      ),
    );
  }
  return rows;
}

void main() {
  final rows = _filesTable();

  test('lists the LOTTIE.md files in table order (37 since m7-4)', () {
    expect(rows, hasLength(37));
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

        // Segments: "`lift` 0–7", a rest marker with no end, "`rest_0`
        // 0" (dr 0), or m7-3's "`rest` = frame 0" (`ui_extra_slot`). A bare
        // "rest = frame 0" (no backticks) is prose, not a marker. LOTTIE.md
        // lists `fx_ice`'s rest markers last; the contract keeps the JSON's
        // order, which the validator checks.
        final markers = [
          for (final m in RegExp(
            r'`(\w+)` (?:= frame )?(\d+)(?:–(\d+))?',
          ).allMatches(row.segments))
            LottieMarker(
              m[1]!,
              double.parse(m[2]!),
              m[3] == null ? 0 : double.parse(m[3]!) - double.parse(m[2]!),
            ),
        ];
        expect(c.markers.toSet(), markers.toSet());
        expect(c.markers, hasLength(markers.length));

        // Kind: board space, segmented (markers) or in place. A marker
        // that only names the rest frame (dr 0 alone) or the whole-file
        // `loop` of an intro card doesn't make a file segmented.
        final segments = markers.where(
          (m) =>
              !(m.duration == 0 && markers.every((n) => n.duration == 0)) &&
              !(m.name == 'loop' && m.start == 0 && m.end == c.frames),
        );
        expect(
          c.kind,
          row.canvas == 'board'
              ? LottieKind.boardSpace
              : segments.isNotEmpty
              ? LottieKind.segmented
              : LottieKind.inPlace,
        );

        // Anchor: board-space files are placed by their top-left and carry
        // S → T; a "doll base" wins over a case/ice corner; "center" is the
        // canvas centre; a "box" (the intro cards' "illustration box") is
        // placed by its top-left, and so is `ui_stars`, whose "canvas top"
        // is set by `layout.winStars`.
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
          if (row.anchor.contains('canvas top')) {
            anchor = LottiePoint.zero;
          } else if (first != null) {
            anchor = _pointOf(first);
          } else if (row.anchor == 'center') {
            anchor = LottiePoint(w / 2, h / 2);
          } else {
            expect(row.anchor, contains('box'));
            anchor = LottiePoint.zero;
          }
          expect(c.anchor, anchor);
        }

        // doll_reveal's drop: "the `drop` null lowers the doll from
        // (0, −18) to (0, 0)".
        final drop = RegExp(
          r'`drop` null lowers the doll from \(([−\d.]+), ([−\d.]+)\) to '
          r'\(0, 0\)',
        ).firstMatch(row.anchor);
        expect(
          c.dropFrom,
          drop == null ? isNull : LottiePoint(_num(drop[1]!), _num(drop[2]!)),
        );
        expect(c.hookLayers.contains('drop'), drop != null);

        // m7-1: "stand surface (100, 212) = the `case_size` null": the
        // anchor null is also a scale null the game drives.
        final scaleNull = RegExp(
          r'= the `(\w+)` null',
        ).firstMatch(row.anchor)?[1];
        expect(c.scaleNulls, {?scaleNull});
        if (scaleNull != null) expect(c.requiredLayers, contains(scaleNull));
      });
    }
  });

  test('the image slots are LOTTIE.md "Image slots", each used somewhere', () {
    final ids = <String>{};
    for (final row in _imageSlotRows()) {
      if (row.reference) {
        // "the same rasters as the board files": slots listed above.
        expect(ids, containsAll(row.ids), reason: row.cell);
      }
      // m7-3's rows may name a v3 slot again for a new file (`mover`,
      // `doll_silhouette` in `ui_intro_towers`); its size must agree (the
      // next test).
      ids.addAll(row.ids);
    }
    final contractIds = lottieImageSlots.map((s) => s.id).toList();
    expect(contractIds.toSet(), hasLength(contractIds.length));
    expect(contractIds.toSet(), ids);
    expect({for (final c in lottieContracts) ...c.imageAssets}, ids);
  });

  test(
    'declared sizes are LOTTIE.md "Image slots" pixel sizes (3× boards)',
    () {
      final sizes = <String, (double, double)>{};
      for (final row in _imageSlotRows()) {
        for (final (id, size) in row.sizes) {
          expect(sizes[id] ?? size, size, reason: '$id in ${row.cell}');
          sizes[id] = size;
        }
      }
      for (final slot in lottieImageSlots) {
        expect((slot.width, slot.height), sizes[slot.id], reason: slot.id);
      }
    },
  );

  test('every parent null LOTTIE.md "Format" names is required', () {
    final format = _section(
      _read('$designLottieDir/$lottieContractDoc'),
      'Format',
    );
    final list = RegExp(r'on a parent null \(([^)]*)\)').firstMatch(format);
    final nulls = [
      for (final m in RegExp(r'`(\w+)`').allMatches(list![1]!)) m[1]!,
    ];
    expect(nulls, containsAll(['glow_pulse', 'shatter_burst', 'arrow_bob']));
    final required = {for (final c in lottieContracts) ...c.requiredLayers};
    expect(required, containsAll(nulls));
  });

  test('the named fills and rectangles are LOTTIE.md "Tint and width"', () {
    final section = _section(
      _read('$designLottieDir/$lottieContractDoc'),
      'Tint and width',
    );
    final fills = {
      for (final m in RegExp(r"'(\w+_fill)'").allMatches(section)) m[1]!,
      // "`hi_fill` stays white at its authored opacity": named, not tinted.
      for (final m in RegExp(r'`(\w+_fill)`').allMatches(section)) m[1]!,
    };
    final rects = {
      for (final m in RegExp(r"'(\w+_rect)'|`(\w+_rect)`").allMatches(section))
        m[1] ?? m[2]!,
    };
    expect(fills, {
      'band_fill',
      'edge_fill',
      'hi_fill',
      'tail_fill',
      'fold_fill',
    });
    expect(rects, {'pill_rect', 'glow_rect'});
    expect(
      [
        for (final c in lottieContracts)
          if (c.tintFills.isNotEmpty) c.name,
      ],
      ['ui_family_counter', 'ui_win_ribbon', 'ui_chapter_ribbon'],
    );
    for (final name in ['ui_win_ribbon', 'ui_chapter_ribbon']) {
      expect(lottieContractOf(name)!.tintFills, fills, reason: name);
    }
    final counter = lottieContractOf('ui_family_counter')!;
    expect(counter.sizedRects, rects);
    expect(counter.tintFills, {
      for (final r in rects) r.replaceAll('_rect', '_fill'),
    });
    // "move the doll mark with transformPosition(const ['icon'], …)".
    expect(section, contains("transformPosition(const ['icon']"));
    expect(counter.requiredLayers, contains('icon'));
  });

  test('the m7-5 ribbons take a width through LOTTIE.md\'s named rects', () {
    final changes = _section(
      _read('$designLottieDir/$lottieContractDoc'),
      'Changes',
    );
    final start = changes.indexOf('### m7-5');
    expect(start, isNot(-1), reason: 'LOTTIE.md "### m7-5"');
    final m75 = changes.substring(start, changes.indexOf('\n### ', start + 1));
    for (final name in ['ui_win_ribbon', 'ui_chapter_ribbon']) {
      final row = m75
          .split('\n')
          .firstWhere((line) => line.startsWith('- **`$name`'));
      final rects = {
        for (final m in RegExp(r'`(\w+_rect)`').allMatches(row)) m[1]!,
      };
      expect(rects, {'band_rect', 'edge_rect', 'hi_rect'}, reason: name);
      expect(lottieContractOf(name)!.sizedRects, rects, reason: name);
    }
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
        // Every file that draws a doll part sizes that role (`family_2_lid`
        // is `family2`'s). `doll_silhouette` is a wood blank, not a role:
        // `doll_reveal` sizes it through `doll`, the intro towers through
        // their `buried` null.
        final roles = {
          for (final id in c.imageAssets)
            if (RegExp(r'^(\w+)_(lid|body)$').firstMatch(id) case final m?)
              LottieRole.ofPrefix(m[1]!)!,
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
