import 'dart:io';

import 'package:nesty_tools/src/levels/finding.dart';
import 'package:nesty_tools/src/levels/fixtures_check.dart';
import 'package:nesty_tools/src/levels/level_paths.dart';
import 'package:nesty_tools/src/repo_root.dart';
import 'package:test/test.dart';

import 'support/scratch_repo.dart';

String expectationsSource({
  String moves = "'001_one': 2,",
  String unsolvable = "'001_stuck',",
}) =>
    '''
// A comment quoting a nest [red2, red1] and a brace } must not confuse it.
library;

/// Doc comment: can't stop the parse either.
const Map<String, int> solvableFixtureMoves = {
  // Comment inside the map: '999_fake': 1, [x]
  $moves
};

const List<String> unsolvableFixtures = [
  // The reason, with "quotes" and a ] bracket.
  $unsolvable
];

const String budgetLimitedFixture = '001_one';

const int budgetLimitedBudget = 1;
''';

const String stuckLevel =
    '{"schemaVersion":1,"id":"u001_stuck","maxSize":3,"shelves":['
    '[{"type":"locked","unlockColor":"blue","nest":["red3","red2"]},'
    '{"type":"locked","unlockColor":"red","nest":["blue3","blue2"]}],'
    '[{"type":"open","nest":["red1"]},{"type":"open","nest":["blue1"]},'
    '{"type":"open","nest":null}]]}';

void main() {
  group('parseFixtureExpectations', () {
    test('reads the consts and ignores comments', () {
      final e = parseFixtureExpectations(expectationsSource());
      expect(e.solvableMoves, {'001_one': 2});
      expect(e.unsolvable, ['001_stuck']);
      expect(e.budgetLimited, '001_one');
      expect(e.budgetLimitedBudget, 1);
    });

    test('a file without the consts is an error, never "no fixtures"', () {
      expect(
        () => parseFixtureExpectations('const x = 1;'),
        throwsFormatException,
      );
    });

    test('reads nesty_core\'s real expectations', () {
      final root = findRepoRoot();
      final e = parseFixtureExpectations(
        LevelPaths.file(
          root,
          LevelPaths.fixtureExpectations,
        ).readAsStringSync(),
      );
      expect(e.solvableMoves['001_l1_tutorial'], 2);
      expect(e.solvableMoves['003_spec_5_1_example'], 4);
      expect(e.unsolvable, contains('001_lock_deadlock'));
      expect(e.budgetLimited, isNotNull);
      expect(e.budgetLimitedBudget, isNotNull);
    });
  });

  test('nesty_core\'s fixtures pass (the real repo)', () {
    final check = checkFixtures(findRepoRoot());
    expect(check.findings, isEmpty);
    expect(check.passed, isTrue);
    expect(check.results.length, greaterThanOrEqualTo(11));
    final tutorial = check.results.firstWhere(
      (r) => r.name == '001_l1_tutorial',
    );
    expect(tutorial.solve!.solution, hasLength(2));
  });

  group('fixtures check in a scratch repo', () {
    late ScratchRepo repo;
    setUp(() {
      repo = ScratchRepo.create()
        ..write(
          '${LevelPaths.fixturesDir}/solvable/001_one.json',
          tutorial1('001_one'),
        )
        ..write(
          '${LevelPaths.fixturesDir}/unsolvable/001_stuck.json',
          stuckLevel,
        );
    });
    tearDown(() => repo.delete());

    void writeExpectations(String source) =>
        repo.write(LevelPaths.fixtureExpectations, source);

    test('passes when files and expectations agree', () {
      writeExpectations(expectationsSource());
      final run = repo.run(['fixtures', 'check']);
      expect(run.exitCode, 0, reason: '$run');
      expect(run.out, contains('solvable/001_one'));
      expect(run.out, contains('unknown at 1 nodes'));
      expect(run.out, contains('fixtures check (2 fixtures): OK'));
    });

    test('a wrong move count or verdict fails', () {
      writeExpectations(
        expectationsSource(moves: "'001_one': 3,", unsolvable: "'001_stuck',"),
      );
      final moves = repo.run(['fixtures', 'check']);
      expect(moves.exitCode, 1);
      expect(moves.err, contains(FindingCodes.fixtureMoves));

      repo.write(
        '${LevelPaths.fixturesDir}/solvable/002_stuck.json',
        stuckLevel.replaceFirst('u001_stuck', '002_stuck'),
      );
      writeExpectations(
        expectationsSource(moves: "'001_one': 2, '002_stuck': 5,"),
      );
      final verdict = repo.run(['fixtures', 'check']);
      expect(verdict.exitCode, 1);
      expect(verdict.err, contains(FindingCodes.fixtureVerdict));
      expect(verdict.err, contains('unsolvable'));
    });

    test('files and expectations must name each other', () {
      writeExpectations(
        expectationsSource(unsolvable: "'001_stuck', '002_gone',"),
      );
      repo.write(
        '${LevelPaths.fixturesDir}/solvable/003_new.json',
        tutorial1('003_new'),
      );
      final run = repo.run(['fixtures', 'check']);
      expect(run.exitCode, 1);
      expect(run.err, contains(FindingCodes.fixtureMissingFile));
      expect(run.err, contains('002_gone'));
      expect(run.err, contains(FindingCodes.fixtureNoExpectation));
      expect(run.err, contains('003_new'));
    });

    test('fixtures are canonical, unique and pass rules 1–7', () {
      writeExpectations(
        expectationsSource(moves: "'001_one': 2, '002_dup': 2, '003_ice': 2,"),
      );
      repo
        ..write(
          '${LevelPaths.fixturesDir}/solvable/002_dup.json',
          tutorial1('001_one'),
        )
        ..write(
          '${LevelPaths.fixturesDir}/solvable/003_ice.json',
          tutorial1('003_ice').replaceFirst(
            '{"type":"open","nest":null}',
            '{"type":"open","nest":null,"ice":0}',
          ),
        );
      final run = repo.run(['fixtures', 'check']);
      expect(run.exitCode, 1);
      expect(run.err, contains(FindingCodes.fixtureDuplicateId));
      expect(run.err, contains(FindingCodes.fixtureNotCanonical));
    });

    test('missing expectations file', () {
      final run = repo.run(['fixtures', 'check']);
      expect(run.exitCode, 1);
      expect(run.err, contains(FindingCodes.fixtureExpectationsUnreadable));
      expect(
        File(repo.file(LevelPaths.fixtureExpectations).path).existsSync(),
        isFalse,
      );
    });
  });
}
