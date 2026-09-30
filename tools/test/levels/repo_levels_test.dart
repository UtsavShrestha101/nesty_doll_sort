// The committed levels themselves: the bundle in apps/game is fresh and
// passes everything `bundle check` enforces (CI runs the same command), the
// tutorials are the design's boards (design §4 TUT1/TUT2), levels 31–200
// keep to the chapter plan they were made for (brainstorm §4, D92), and
// every level carries its star-rating par (spec-prop §7.10, D146) without
// any level's data or version moving.
import 'dart:convert';
import 'dart:io';

import 'package:nesty_core/nesty_core.dart';
import 'package:nesty_tools/src/levels/authored_levels.dart';
import 'package:nesty_tools/src/levels/cli.dart';
import 'package:nesty_tools/src/levels/level_analysis.dart';
import 'package:nesty_tools/src/levels/level_paths.dart';
import 'package:nesty_tools/src/repo_root.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

/// FNV-1a 64 over [text]'s UTF-16 code units, as 16 hex digits: a digest
/// to pin with (VM only, where ints are 64-bit and multiplication wraps).
String fnv1a64(String text) {
  var hash = 0xcbf29ce484222325;
  for (final unit in text.codeUnits) {
    hash = (hash ^ unit) * 0x100000001b3;
  }
  return hash.toUnsigned(64).toRadixString(16).padLeft(16, '0');
}

/// The tutorial's scripted moves, read from the game's script
/// (`apps/game/lib/features/gameplay/bloc/tutorial_script.dart`, spec §7.6),
/// so a change there can't slip past the par check. The tools can't import
/// the app, so its constants are read from the source.
Map<String, List<Move>> tutorialPrefixes(Directory root) {
  final source = File(
    p.join(
      root.path,
      'apps/game/lib/features/gameplay/bloc/tutorial_script.dart',
    ),
  ).readAsStringSync();
  String constant(String name) {
    final match = RegExp(
      "static const String $name = '([^']+)';",
    ).firstMatch(source);
    if (match == null) fail('$name is not in tutorial_script.dart');
    return match[1]!;
  }

  return {
    'L0001': [
      Move(constant('_l1From'), constant('_l1To')),
      Move(constant('_l1SecondFrom'), constant('_l1SecondTo')),
    ],
    'L0002': [Move(constant('_l2From'), constant('_l2To'))],
  };
}

/// What a board holds, for the chapter-plan checks.
({int towers, int locked, List<int> ice, int colors}) contents(Level level) {
  var towers = 0;
  var locked = 0;
  final ice = <int>[];
  final colors = <DollColor>{};
  for (final shelf in level.shelves) {
    for (final slot in shelf) {
      if (slot is TowerSlot) towers++;
      if (slot is LockedSlot) locked++;
      if (slot.ice > 0) ice.add(slot.ice);
      for (final nest in slot.nests) {
        colors.addAll(nest.dolls.map((d) => d.color));
      }
    }
  }
  return (towers: towers, locked: locked, ice: ice, colors: colors.length);
}

/// What a player sees of a board's structure, for the near-duplicate check.
({
  List<int> shape,
  int towers,
  int deepest,
  int glass,
  int iced,
  int empty,
  int maxSize,
})
structureOf(Level level) {
  var towers = 0;
  var deepest = 0;
  var glass = 0;
  var iced = 0;
  var empty = 0;
  for (final shelf in level.shelves) {
    for (final slot in shelf) {
      if (slot.ice > 0) iced++;
      switch (slot) {
        case TowerSlot(:final stack):
          towers++;
          if (stack.length > deepest) deepest = stack.length;
        case LockedSlot():
          glass++;
        case OpenSlot(:final nest):
          if (nest == null) empty++;
      }
    }
  }
  return (
    shape: [for (final shelf in level.shelves) shelf.length],
    towers: towers,
    deepest: deepest,
    glass: glass,
    iced: iced,
    empty: empty,
    maxSize: level.maxSize,
  );
}

void main() {
  final root = findRepoRoot();

  test('bundle check passes on the committed levels', () {
    final out = StringBuffer();
    final err = StringBuffer();
    final code = runNestyLevels(
      ['bundle', 'check'],
      out: out,
      err: err,
      root: root,
      cwd: root,
    );
    expect(code, 0, reason: '$out$err');
  });

  test('the game bundle decodes cleanly and starts with the tutorials', () {
    final bundle = LevelBundleCodec.decodeString(
      LevelPaths.file(root, LevelPaths.bundle).readAsStringSync(),
    );
    expect(bundle.issues, isEmpty);
    final levels = bundle.bundle!.levels;
    expect(levels.first.level.id, 'L0001');
    expect(levels[1].level.id, 'L0002');
    for (final entry in levels.take(2)) {
      final solve = Solver.solve(GameState.initial(entry.level));
      expect(
        solve.solution,
        hasLength(entry.order == 1 ? 2 : 3),
        reason: 'design §4: L1 is 2 moves, L2 is 3',
      );
    }
  });

  // Spec-prop §7.10 (D125, D146): "**Par** is the fewest moves that solve
  // the level from its start, the solver's optimal solution (§6.3). It is
  // computed when the level bundle is built, and checked with it."
  // star-rating.md "Rules" 1: "The level JSON doesn't change, so no level
  // version moves (L1–L30 stay byte-identical)."
  group('par (the star rating)', () {
    late List<LevelBundleEntry> levels;
    setUpAll(() {
      levels = LevelBundleCodec.decodeString(
        LevelPaths.file(root, LevelPaths.bundle).readAsStringSync(),
      ).bundle!.levels;
    });

    test('every one of the 200 entries has a par of 1 or more: the '
        "solver's optimum at the admin budget", () {
      expect(levels, hasLength(200));
      for (final entry in levels) {
        final solve = Solver.solve(GameState.initial(entry.level));
        expect(entry.par, isNotNull, reason: entry.level.id);
        expect(entry.par, greaterThanOrEqualTo(1), reason: entry.level.id);
        expect(entry.par, solve.solution!.length, reason: entry.level.id);
      }
    });

    test('the tutorials: L1 par 2, L2 par 3 (design §4)', () {
      expect(levels[0].par, 2);
      expect(levels[1].par, 3);
    });

    test("L1–L30's level data and versions are what shipped before stars", () {
      // FNV-1a 64 of the canonical JSON of L1–L30's id, version and data,
      // taken from the bundle before par was added (2026-09-29; it equals
      // the committed M3 bundle's). Adding par may change only the entries'
      // `par` keys, never a level's board or version.
      final text = jsonEncode([
        for (final entry in levels.take(30))
          {
            'id': entry.level.id,
            'version': entry.version,
            'data': LevelCodec.encode(entry.level),
          },
      ]);
      expect(fnv1a64(text), '6eb213699ab72200');
      expect({for (final entry in levels) entry.version}, {1});
    });

    test("each tutorial's scripted moves lie on an optimal line, so its "
        'first play can reach 3 stars (Q148)', () {
      final prefixes = tutorialPrefixes(root);
      // The script as m3-design §10.4 describes it: L1's two moves are the
      // whole solve; L2 scripts only the swallow.
      expect(prefixes['L0001'], [
        const Move('r0c2', 'r0c0'),
        const Move('r1c1', 'r0c0'),
      ]);
      expect(prefixes['L0002'], [const Move('r0c0', 'r1c0')]);
      for (final entry in levels.take(2)) {
        final prefix = prefixes[entry.level.id]!;
        var state = GameState.initial(entry.level);
        for (final move in prefix) {
          final result = Rules.tryMove(state, move);
          expect(result, isA<MoveApplied>(), reason: '${entry.level.id} $move');
          state = (result as MoveApplied).state;
        }
        final rest = Rules.isWon(state)
            ? 0
            : Solver.solve(state).solution!.length;
        expect(
          prefix.length + rest,
          entry.par,
          reason: '${entry.level.id}: the script plus the best finish',
        );
      }
    });
  });

  test('the authored tutorials are the design boards of the fixtures', () {
    final authored = loadAuthoredLevels(
      LevelPaths.file(root, LevelPaths.manifest),
      root: root,
    );
    expect(authored.findings, isEmpty);
    for (final (index, fixture) in [
      '001_l1_tutorial',
      '002_l2_swallow',
    ].indexed) {
      final level = LevelCodec.decodeString(
        LevelPaths.file(
          root,
          '${LevelPaths.fixturesDir}/solvable/$fixture.json',
        ).readAsStringSync(),
      ).level!;
      expect(authored.levels[index].level.shelves, level.shelves);
      expect(authored.levels[index].level.maxSize, level.maxSize);
    }
  });

  group('levels 31–200 keep to the chapter plan (brainstorm §4)', () {
    late Map<int, Level> byOrder;
    late Map<int, int> moves;
    setUpAll(() {
      final authored = loadAuthoredLevels(
        LevelPaths.file(root, LevelPaths.manifest),
        root: root,
      );
      byOrder = {for (final l in authored.levels) l.entry.order: l.level};
      moves = {
        for (final MapEntry(key: order, value: level) in byOrder.entries)
          order: Solver.solve(GameState.initial(level)).solution!.length,
      };
    });

    test('200 levels in ten chapters', () {
      expect(byOrder.keys, [for (var o = 1; o <= 200; o++) o]);
    });

    test('glass, ice and maxSize 5 each arrive alone and easy', () {
      final l31 = contents(byOrder[31]!);
      expect((l31.towers, l31.locked), (0, 1), reason: 'L31: one glass case');
      expect(l31.ice, isEmpty);
      final l51 = contents(byOrder[51]!);
      expect((l51.towers, l51.locked), (0, 0), reason: 'L51: ice alone');
      expect(l51.ice, [1], reason: 'L51: one ice, counter 1');
      final l71 = contents(byOrder[71]!);
      expect(byOrder[71]!.maxSize, 5);
      expect((l71.towers, l71.locked), (0, 0), reason: 'L71: maxSize 5 alone');
      expect(l71.ice, isEmpty);
      expect(l71.colors, lessThanOrEqualTo(4), reason: 'few colors');
    });

    test('maxSize 6 is exactly the super hard slots L130, L140 … L200', () {
      expect(
        [
          for (final MapEntry(key: order, value: level) in byOrder.entries)
            if (level.maxSize == 6) order,
        ],
        [for (var o = 130; o <= 200; o += 10) o],
      );
    });

    test('every chapter finale from chapter 2 is its longest level', () {
      for (var chapter = 2; chapter <= 10; chapter++) {
        final finale = chapter * 20;
        for (var order = finale - 19; order < finale; order++) {
          expect(
            moves[order],
            lessThan(moves[finale]!),
            reason: 'L$order against the chapter $chapter finale L$finale',
          );
        }
      }
    });

    test('the baseline rises through a chapter: from L31 each level needs '
        'at least the moves of the level 10 before it, but the intro '
        'levels', () {
      for (var order = 31; order <= 200; order++) {
        if (const {51, 71}.contains(order)) continue;
        if ((order - 1) % 20 < 10) continue; // the chapter's first block
        expect(
          moves[order],
          greaterThanOrEqualTo(moves[order - 10]!),
          reason: 'L$order against L${order - 10}',
        );
      }
    });

    test('from L31 every level is solved from its start within the '
        "device's soft-stuck budget (spec §6.3)", () {
      for (var order = 31; order <= 200; order++) {
        final solve = Solver.solve(
          GameState.initial(byOrder[order]!),
          budget: SolverBudgets.softStuck,
        );
        expect(solve.verdict, SolveVerdict.solved, reason: 'L$order');
      }
    });
  });

  test('no two levels within two of each other read alike (the H/S '
      "review's near-duplicate finding), but the adjacent easy pairs the "
      'chapter plan leaves no knob to separate', () {
    final authored = loadAuthoredLevels(
      LevelPaths.file(root, LevelPaths.manifest),
      root: root,
    );
    final levels = {for (final l in authored.levels) l.entry.order: l};
    // Two levels read alike when nothing structural tells them apart: glass
    // cases, iced slots, the deepest tower, empty slots, the tier, maxSize,
    // a tower count two or more apart, and, two levels apart, the shelf
    // shape. The colour count, one tower more or less and the move count
    // never do on their own (calibrated on the review's L32/L34, L52/L54,
    // L72/L74 and L131/L132).
    //
    // These side-by-side easy pairs differ only in their shelf count (two
    // shelves against three). Chapters 5 and 8 fix glass, ice, depth and
    // empty slots; chapter 8's towers are its row's count or one more, and
    // chapter 5's easy boards with two towers more take a medium's 17-18
    // moves (tools/levels/README.md, Q-10).
    const allowed = {(81, 82), (91, 92), (141, 142), (151, 152)};
    final near = <String>[];
    for (var order = 21; order <= 200; order++) {
      for (final gap in const [1, 2]) {
        final other = order + gap;
        // L1-L30 shipped before M7; the check starts with the new levels.
        if (other < 31 || !levels.containsKey(other)) continue;
        final a = structureOf(levels[order]!.level);
        final b = structureOf(levels[other]!.level);
        final apart =
            a.glass != b.glass ||
            a.iced != b.iced ||
            a.deepest != b.deepest ||
            a.empty != b.empty ||
            a.maxSize != b.maxSize ||
            levels[order]!.entry.tier != levels[other]!.entry.tier ||
            (a.towers - b.towers).abs() >= 2 ||
            (gap == 2 && a.shape.join(',') != b.shape.join(','));
        if (!apart && !allowed.contains((order, other))) {
          near.add('L$order/L$other');
        }
      }
    }
    expect(near, isEmpty);
  });

  test('from L31 only the grand finale L200 never wins by chance (the H/S '
      "review's casual 0/300 finding; L200 is Q-9's default)", () {
    final authored = loadAuthoredLevels(
      LevelPaths.file(root, LevelPaths.manifest),
      root: root,
    );
    final never = [
      for (final l in authored.levels)
        if (l.entry.order >= 31 &&
            analyzeLevel(l.level).simulation!.casual.wins == 0)
          l.entry.order,
    ];
    expect(never, [200]);
  });
}
