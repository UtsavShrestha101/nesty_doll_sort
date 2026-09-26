import 'dart:convert';
import 'dart:io';

import 'package:nesty_core/nesty_core.dart';
import 'package:nesty_tools/src/levels/authored_levels.dart';
import 'package:nesty_tools/src/levels/finding.dart';
import 'package:nesty_tools/src/levels/level_paths.dart';
import 'package:path/path.dart' as p;

/// What `packages/nesty_core/test/solver/fixture_expectations.dart` says the
/// solver must find in each fixture (Q19).
final class FixtureExpectations {
  const FixtureExpectations({
    required this.solvableMoves,
    required this.unsolvable,
    this.budgetLimited,
    this.budgetLimitedBudget,
  });

  /// Optimal move count by fixture name (file name without `.json`).
  final Map<String, int> solvableMoves;

  /// The unsolvable fixtures' names.
  final List<String> unsolvable;

  /// A solvable fixture a search with [budgetLimitedBudget] nodes can't
  /// finish, so it must answer `unknown` (spec §6.3).
  final String? budgetLimited;
  final int? budgetLimitedBudget;
}

/// Reads the expectation consts from the Dart source of
/// fixture_expectations.dart without running it: `solvableFixtureMoves`
/// (`'name': moves` entries), `unsolvableFixtures` (`'name'` entries),
/// `budgetLimitedFixture` and `budgetLimitedBudget`. Comments are dropped
/// first, because they quote nests such as `[red2, red1]`. A shape these
/// patterns don't find is an error, never an empty expectation.
FixtureExpectations parseFixtureExpectations(String source) {
  final code = source.replaceAll(RegExp(r'//[^\n]*'), '');
  final moves = RegExp(
    r'solvableFixtureMoves\s*=\s*\{([^}]*)\}',
  ).firstMatch(code);
  final unsolvable = RegExp(
    r'unsolvableFixtures\s*=\s*\[([^\]]*)\]',
  ).firstMatch(code);
  if (moves == null || unsolvable == null) {
    throw const FormatException(
      'solvableFixtureMoves = {…} or unsolvableFixtures = […] not found',
    );
  }
  final budgetFixture = RegExp(
    r"budgetLimitedFixture\s*=\s*'([^']+)'",
  ).firstMatch(code);
  final budget = RegExp(r'budgetLimitedBudget\s*=\s*(\d+)').firstMatch(code);
  return FixtureExpectations(
    solvableMoves: {
      for (final m in RegExp(
        r"'([^']+)'\s*:\s*(\d+)",
      ).allMatches(moves.group(1)!))
        m.group(1)!: int.parse(m.group(2)!),
    },
    unsolvable: [
      for (final m in RegExp(r"'([^']+)'").allMatches(unsolvable.group(1)!))
        m.group(1)!,
    ],
    budgetLimited: budgetFixture?.group(1),
    budgetLimitedBudget: budget == null ? null : int.parse(budget.group(1)!),
  );
}

/// One fixture's result.
final class FixtureResult {
  const FixtureResult({
    required this.folder,
    required this.name,
    this.expectedMoves,
    this.solve,
    this.budgetSolve,
  });

  /// `solvable` or `unsolvable`: the folder is the expected verdict.
  final String folder;
  final String name;

  /// The expected optimal moves (solvable fixtures).
  final int? expectedMoves;

  /// The admin-budget solve, when the fixture decoded and passed rules 1–7.
  final SolveResult? solve;

  /// The budget-limited solve, for the budget-limited fixture.
  final SolveResult? budgetSolve;
}

/// Everything `fixtures check` found.
final class FixturesCheck {
  const FixturesCheck(this.results, this.findings);

  final List<FixtureResult> results;
  final List<Finding> findings;

  bool get passed => !findings.any((f) => f.isError);
}

/// `nesty_levels fixtures check`: nesty_core's solver fixtures
/// (packages/nesty_core/test/fixtures/README.md) are what they claim, run
/// through the real codec, validator and solver.
///
/// For every file: it decodes with no issues, it is canonical (the same
/// values in the same key order as `LevelCodec.encode`), it passes rules 1–7,
/// and no two fixtures share an id. A solvable fixture solves at the admin
/// budget in exactly its expected optimal moves; an unsolvable one is proven
/// unsolvable; the budget-limited one is `unknown` at its small budget,
/// never `unsolvable` (spec §6.3). Every file has an expectation and every
/// expectation a file.
FixturesCheck checkFixtures(Directory root) {
  final findings = <Finding>[];
  final expectationsFile = LevelPaths.file(
    root,
    LevelPaths.fixtureExpectations,
  );
  final expectationsSubject = LevelPaths.display(root, expectationsFile);
  final FixtureExpectations expectations;
  try {
    expectations = parseFixtureExpectations(
      expectationsFile.readAsStringSync(),
    );
  } on FileSystemException catch (e) {
    return FixturesCheck(const [], [
      Finding(
        FindingCodes.fixtureExpectationsUnreadable,
        e.message,
        subject: expectationsSubject,
      ),
    ]);
  } on FormatException catch (e) {
    return FixturesCheck(const [], [
      Finding(
        FindingCodes.fixtureExpectationsUnreadable,
        e.message,
        subject: expectationsSubject,
      ),
    ]);
  }

  final results = <FixtureResult>[];
  final seenIds = <String, String>{};
  final onDisk = <String, Set<String>>{'solvable': {}, 'unsolvable': {}};
  for (final folder in onDisk.keys) {
    final dir = LevelPaths.dir(root, '${LevelPaths.fixturesDir}/$folder');
    final files = dir.existsSync()
        ? ([
            for (final f in dir.listSync().whereType<File>())
              if (f.path.endsWith('.json')) f,
          ]..sort((a, b) => a.path.compareTo(b.path)))
        : <File>[];
    for (final file in files) {
      final name = p.basenameWithoutExtension(file.path);
      onDisk[folder]!.add(name);
      results.add(
        _checkFixture(
          file,
          folder: folder,
          name: name,
          root: root,
          expectations: expectations,
          seenIds: seenIds,
          findings: findings,
        ),
      );
    }
  }

  // Both directions, so a renamed or deleted file can't pass silently.
  void missing(String folder, Iterable<String> names) {
    for (final name in names) {
      if (!onDisk[folder]!.contains(name)) {
        findings.add(
          Finding(
            FindingCodes.fixtureMissingFile,
            'An expectation names $folder/$name.json, which does not exist',
            subject: expectationsSubject,
          ),
        );
      }
    }
  }

  missing('solvable', expectations.solvableMoves.keys);
  missing('unsolvable', expectations.unsolvable);
  if (expectations.budgetLimited case final name?) {
    missing('solvable', [name]);
  }
  return FixturesCheck(results, findings);
}

FixtureResult _checkFixture(
  File file, {
  required String folder,
  required String name,
  required Directory root,
  required FixtureExpectations expectations,
  required Map<String, String> seenIds,
  required List<Finding> findings,
}) {
  final subject = LevelPaths.display(root, file);
  final solvable = folder == 'solvable';
  final expectedMoves = solvable ? expectations.solvableMoves[name] : null;
  final hasExpectation = solvable
      ? expectedMoves != null
      : expectations.unsolvable.contains(name);
  if (!hasExpectation) {
    findings.add(
      Finding(
        FindingCodes.fixtureNoExpectation,
        'No entry for "$name" in '
        '${solvable ? 'solvableFixtureMoves' : 'unsolvableFixtures'} '
        '(${LevelPaths.fixtureExpectations})',
        subject: subject,
      ),
    );
  }
  FixtureResult result([SolveResult? solve, SolveResult? budgetSolve]) =>
      FixtureResult(
        folder: folder,
        name: name,
        expectedMoves: expectedMoves,
        solve: solve,
        budgetSolve: budgetSolve,
      );

  final json = readJsonFile(file, root: root, findings: findings);
  if (json == null) return result();
  final decoded = LevelCodec.decode(json.value);
  findings.addAll([
    for (final issue in decoded.issues)
      Finding.fromIssue(issue, subject: subject),
  ]);
  final level = decoded.level;
  if (level == null) return result();

  // Same values in the same key order as the canonical encoder (the file's
  // own whitespace is free).
  if (jsonEncode(json.value) != LevelCodec.encodeString(level)) {
    findings.add(
      Finding(
        FindingCodes.fixtureNotCanonical,
        'Not in canonical form: keys must follow LevelCodec.encode\'s order '
        'and "ice": 0 must be left out (spec §5.1, design A20)',
        subject: subject,
      ),
    );
  }
  final owner = seenIds[level.id];
  if (owner != null) {
    findings.add(
      Finding(
        FindingCodes.fixtureDuplicateId,
        'Level id "${level.id}" is also used by $owner',
        subject: subject,
      ),
    );
  } else {
    seenIds[level.id] = subject;
  }

  final report = Validator.validate(level, options: ValidationOptions.loader);
  findings.addAll([
    for (final issue in report.issues)
      Finding.fromIssue(issue, subject: subject),
  ]);
  if (!report.isValid) return result();

  final start = GameState.initial(level);
  final solve = Solver.solve(start);
  final expectedVerdict = solvable
      ? SolveVerdict.solved
      : SolveVerdict.unsolvable;
  if (solve.verdict != expectedVerdict) {
    findings.add(
      Finding(
        FindingCodes.fixtureVerdict,
        'Expected ${expectedVerdict.name} (its folder), the solver says '
        '${solve.verdict.name} after ${solve.nodes} nodes',
        subject: subject,
      ),
    );
  } else if (expectedMoves != null && solve.solution!.length != expectedMoves) {
    findings.add(
      Finding(
        FindingCodes.fixtureMoves,
        'Expected an optimal $expectedMoves moves, the solver found '
        '${solve.solution!.length}',
        subject: subject,
      ),
    );
  }

  SolveResult? budgetSolve;
  final budget = expectations.budgetLimitedBudget;
  if (name == expectations.budgetLimited && solvable && budget != null) {
    budgetSolve = Solver.solve(start, budget: budget);
    if (budgetSolve.verdict != SolveVerdict.unknown) {
      findings.add(
        Finding(
          FindingCodes.fixtureVerdict,
          'With a budget of $budget nodes the solver must answer unknown '
          '(spec §6.3), but it says ${budgetSolve.verdict.name}',
          subject: subject,
        ),
      );
    }
  }
  return result(solve, budgetSolve);
}
