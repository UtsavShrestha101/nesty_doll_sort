import 'dart:convert';

import 'package:nesty_core/nesty_core.dart';
import 'package:nesty_tools/src/levels/finding.dart';
import 'package:nesty_tools/src/levels/level_paths.dart';
import 'package:test/test.dart';

import 'support/scratch_repo.dart';

void main() {
  late ScratchRepo repo;
  setUp(() => repo = ScratchRepo.create());
  tearDown(() => repo.delete());

  void writeFiles() {
    repo
      ..write('levels/one.json', tutorial1('One'))
      ..write('levels/two.json', tutorial2('Two'))
      ..write(
        'broken.json',
        '{"schemaVersion":1,"id":"Bad","maxSize":3,"shelves":[['
            '{"type":"open","nest":["red3","red1"]},{"type":"open","nest":null}]]}',
      );
  }

  group('usage', () {
    test('--help prints the commands', () {
      final run = repo.run(['--help']);
      expect(run.exitCode, 0);
      for (final command in [
        'validate',
        'solve',
        'simulate',
        'report',
        'bundle build',
        'bundle check',
        'generate',
        'fixtures check',
      ]) {
        expect(run.out, contains(command));
      }
    });

    test('bad usage exits 64', () {
      expect(repo.run([]).exitCode, 64);
      expect(repo.run(['frobnicate']).exitCode, 64);
      expect(repo.run(['validate', '--chek']).exitCode, 64);
      expect(repo.run(['solve', '--budget', '0']).exitCode, 64);
      expect(repo.run(['solve', '--budget=lots']).exitCode, 64);
      expect(repo.run(['simulate', '--runs', '0']).exitCode, 64);
      expect(repo.run(['fixtures']).exitCode, 64);
      final run = repo.run(['validate', '--chek']);
      expect(run.err, contains('--loader'));
      expect(run.err, contains('--help'));
    });
  });

  group('validate', () {
    test('level files and folders, relative to the current directory', () {
      writeFiles();
      final run = repo.run(['validate', 'one.json', 'two.json'], cwd: 'levels');
      expect(run.exitCode, 0, reason: '$run');
      expect(
        run.out,
        contains('ok      One  (levels/one.json)  solved in 2 moves'),
      );
      expect(run.out, contains('ok      Two'));

      final folder = repo.run(['validate', 'levels']);
      expect(folder.exitCode, 0);
      expect(folder.out, contains('One'));
      expect(folder.out, contains('Two'));
      expect(folder.out, contains('validate 2 level(s): OK'));
    });

    test('an invalid level fails with its issue codes', () {
      writeFiles();
      final run = repo.run(['validate', 'broken.json', 'levels/one.json']);
      expect(run.exitCode, 1);
      expect(run.err, contains(IssueCodes.notConsecutive));
      expect(run.err, contains('broken.json'));
      expect(run.out, contains('ok      One'), reason: 'the rest still runs');
    });

    test('--loader checks rules 1–7 only, like the game (design A6)', () {
      repo.write(
        'deadlock.json',
        '{"schemaVersion":1,"id":"D","maxSize":3,"shelves":['
            '[{"type":"locked","unlockColor":"blue","nest":["red3","red2"]},'
            '{"type":"locked","unlockColor":"red","nest":["blue3","blue2"]}],'
            '[{"type":"open","nest":["red1"]},{"type":"open","nest":["blue1"]},'
            '{"type":"open","nest":null}]]}',
      );
      final full = repo.run(['validate', 'deadlock.json']);
      expect(full.exitCode, 1);
      expect(full.err, contains(IssueCodes.unsolvable));
      expect(repo.run(['validate', 'deadlock.json', '--loader']).exitCode, 0);
    });

    test('a small --budget leaves a level unproven (spec §6.3)', () {
      writeFiles();
      final run = repo.run(['validate', 'levels/two.json', '--budget', '1']);
      expect(run.exitCode, 1);
      expect(run.err, contains(IssueCodes.unproven));
    });

    test('unreadable and non-JSON inputs are findings', () {
      repo.write('nope.json', '{');
      final run = repo.run(['validate', 'nope.json', 'missing.json']);
      expect(run.exitCode, 1);
      expect(run.err, contains(FindingCodes.invalidJson));
      expect(run.err, contains(FindingCodes.unreadable));
    });

    test('no path means the game bundle; the manifest reads authored/', () {
      repo.writeTutorials();
      repo.run(['bundle', 'build']);
      final bundle = repo.run(['validate']);
      expect(bundle.exitCode, 0, reason: '$bundle');
      expect(bundle.out, contains('(${LevelPaths.bundle})'));
      final manifest = repo.run(['validate', LevelPaths.manifest]);
      expect(manifest.exitCode, 0);
      expect(manifest.out, contains('(tools/levels/authored/L0001.json)'));
    });

    test('a bundle entry that does not decode is reported', () {
      repo.writeTutorials();
      repo.run(['bundle', 'build']);
      repo.write(
        LevelPaths.bundle,
        repo
            .read(LevelPaths.bundle)
            .replaceFirst('"tier": "easy"', '"tier": "?"'),
      );
      final run = repo.run(['validate']);
      expect(run.exitCode, 1);
      expect(run.err, contains(IssueCodes.bundleUnknownTier));
      expect(run.out, contains('L0002'));
    });
  });

  group('solve', () {
    test('prints the verdict, moves and solution (spec §6.3)', () {
      writeFiles();
      final run = repo.run(['solve', 'levels/one.json']);
      expect(run.exitCode, 0, reason: '$run');
      expect(run.out, contains('One  solved  2 moves  nodes 3'));
      expect(run.out, matches(RegExp(r'\n  r\dc\d>r\dc\d r\dc\d>r\dc\d\n')));
    });

    test('fails unless every level is solved', () {
      writeFiles();
      final budget = repo.run(['solve', 'levels/two.json', '--budget=1']);
      expect(budget.exitCode, 1);
      expect(budget.out, contains('unknown'));
      final invalid = repo.run(['solve', 'broken.json']);
      expect(invalid.exitCode, 1);
      expect(invalid.err, contains(IssueCodes.notConsecutive));
    });
  });

  group('simulate', () {
    test('prints both bots, the tier and the seed (spec §6.4)', () {
      writeFiles();
      final level = LevelCodec.decodeString(tutorial1('One')).level!;
      final run = repo.run(['simulate', 'levels/one.json']);
      expect(run.exitCode, 0, reason: '$run');
      expect(run.out, contains('300/300 100.0%'));
      expect(run.out, contains('easy'));
      expect(run.out, contains('${Simulator.defaultSeed(level)}'));
    });

    test('takes --runs, --seed and --move-cap', () {
      writeFiles();
      final run = repo.run([
        'simulate',
        'levels/two.json',
        '--runs',
        '10',
        '--seed=5',
        '--move-cap',
        '0',
      ]);
      expect(run.exitCode, 0, reason: '$run');
      expect(run.out, contains('0/10 0.0%'), reason: 'no moves, no wins');
      expect(run.out, contains('superhard'));
      expect(run.out, contains(' 5'));
    });
  });

  group('report', () {
    test('one row per level with the metrics', () {
      repo.writeTutorials();
      final run = repo.run(['report', LevelPaths.manifest]);
      expect(run.exitCode, 0, reason: '$run');
      final lines = run.out.trim().split('\n');
      expect(lines.first, startsWith('order  id'));
      expect(lines[1], startsWith('    1  L0001  ch01     easy      easy'));
      expect(lines[1], endsWith('2      3  ok'));
      expect(lines, hasLength(3));
    });

    test('--json is machine-readable', () {
      writeFiles();
      // Rule 4 fails (red has no size 1), which the codec can represent.
      repo.write(
        'rule4.json',
        tutorial1('Bad').replaceFirst('"nest":["red1"]', '"nest":null'),
      );
      final run = repo.run([
        'report',
        'levels',
        'rule4.json',
        'broken.json',
        '--json',
      ]);
      expect(run.exitCode, 1, reason: 'rule4.json and broken.json are bad');
      final rows = (jsonDecode(run.out) as List).cast<Map<String, Object?>>();
      expect(
        rows.map((r) => r['id']),
        ['One', 'Two', 'Bad'],
        reason: 'broken.json does not decode, so it has no row',
      );
      expect(run.err, contains(IssueCodes.notConsecutive));
      final one = rows.first;
      expect(one['valid'], isTrue);
      expect(one['tier'], 'easy');
      expect(one['casualWins'], 300);
      expect(one['smartWins'], 300);
      expect(one['runs'], 300);
      expect(one['verdict'], 'solved');
      expect(one['solverMoves'], 2);
      expect(one['nodes'], 3);
      expect(one['issues'], isEmpty);
      final bad = rows.last;
      expect(bad['valid'], isFalse);
      expect(bad['tier'], isNull);
      expect(bad['source'], 'rule4.json');
      expect((bad['issues']! as List).map((i) => (i as Map)['code']), [
        IssueCodes.notFullSets,
      ]);
    });

    test('an unsolvable level is still simulated (rules 1–7 hold)', () {
      repo.write(
        'deadlock.json',
        '{"schemaVersion":1,"id":"D","maxSize":3,"shelves":['
            '[{"type":"locked","unlockColor":"blue","nest":["red3","red2"]},'
            '{"type":"locked","unlockColor":"red","nest":["blue3","blue2"]}],'
            '[{"type":"open","nest":["red1"]},{"type":"open","nest":["blue1"]},'
            '{"type":"open","nest":null}]]}',
      );
      final run = repo.run(['report', 'deadlock.json']);
      expect(run.exitCode, 1);
      expect(run.out, contains('superhard'));
      expect(run.out, contains(IssueCodes.unsolvable));
    });
  });
}
