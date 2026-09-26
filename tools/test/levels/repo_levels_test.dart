// The committed levels themselves: the bundle in apps/game is fresh and
// passes everything `bundle check` enforces (CI runs the same command), and
// the tutorials are the design's boards (design §4 TUT1/TUT2).
import 'package:nesty_core/nesty_core.dart';
import 'package:nesty_tools/src/levels/authored_levels.dart';
import 'package:nesty_tools/src/levels/cli.dart';
import 'package:nesty_tools/src/levels/level_paths.dart';
import 'package:nesty_tools/src/repo_root.dart';
import 'package:test/test.dart';

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
}
