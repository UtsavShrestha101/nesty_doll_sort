// The solver on the level fixtures (test/fixtures/, spec §6.3, §18 M1):
// every solvable fixture is solved in its hand-worked optimal move count
// (fixture_expectations.dart) by a line that replays to Won; every
// unsolvable fixture is proven unsolvable after storing exactly the
// canonical states an independent oracle finds; a tiny budget gives
// `unknown`, never `unsolvable`; and validation rule 8 (spec §5.3) runs the
// real solver by default.
//
// VM only: fixtures are read with dart:io. The parity suite
// (test/parity/solver_parity_test.dart) repeats the key numbers on the web.
@TestOn('vm')
library;

import 'dart:convert';

import 'package:nesty_core/nesty_core.dart';
import 'package:test/test.dart';

import '../fixtures/fixture_loader.dart';
import 'fixture_expectations.dart';
import 'support/parity_levels.dart';
import 'support/solver_oracle.dart';

void main() {
  final solvable = loadFixtures(FixtureFolder.solvable);
  final unsolvable = loadFixtures(FixtureFolder.unsolvable);

  group('solvable fixtures, admin budget', () {
    for (final fixture in solvable) {
      final moves = solvableFixtureMoves[fixture.name]!;
      test('${fixture.name}: optimal in $moves moves, replays to Won', () {
        final start = GameState.initial(fixture.level);
        final result = Solver.solve(start);
        expectOptimalWin(start, result, moves);
        expect(result.nodes, lessThanOrEqualTo(SolverBudgets.admin));
        expect(result.branching, greaterThan(0));
      });
    }

    test('the default budget is the admin budget', () {
      final start = GameState.initial(solvable.first.level);
      expect(Solver.solve(start), Solver.solve(start, budget: 500000));
    });
  });

  group('unsolvable fixtures are proven, never unknown', () {
    for (final fixture in unsolvable) {
      test(fixture.name, () {
        final start = GameState.initial(fixture.level);
        final oracle = reachableCanonicalStates(start);
        expect(oracle.depth, isNull);
        final result = Solver.solve(start);
        expect(result.verdict, SolveVerdict.unsolvable);
        expect(result.solution, isNull);
        // An exhausted search stored every reachable canonical state once.
        expect(result.nodes, oracle.states);
        // Proven with the smallest budgets that fit them, too.
        expect(
          Solver.solve(start, budget: oracle.states).verdict,
          SolveVerdict.unsolvable,
        );
        expect(Solver.softStuck(start), SolveVerdict.unsolvable);
      });
    }
  });

  group('a budget too small is unknown, never unsolvable (spec §6.3)', () {
    final large = fixture(FixtureFolder.solvable, budgetLimitedFixture);
    final start = GameState.initial(large.level);

    test('$budgetLimitedFixture at $budgetLimitedBudget nodes', () {
      final result = Solver.solve(start, budget: budgetLimitedBudget);
      expect(result.verdict, SolveVerdict.unknown);
      expect(result.solution, isNull);
      expect(result.nodes, budgetLimitedBudget);
    });

    test('every budget gives the optimal win or unknown', () {
      final full = Solver.solve(start);
      for (var budget = 1; budget <= full.nodes; budget++) {
        final result = Solver.solve(start, budget: budget);
        expect(result.verdict, isNot(SolveVerdict.unsolvable));
        expect(result.nodes, lessThanOrEqualTo(budget));
        if (result.verdict == SolveVerdict.solved) {
          expect(result, full, reason: 'budget $budget');
        }
      }
      expect(Solver.solve(start, budget: full.nodes), full);
    });

    test('the soft-stuck check says unknown, which shows no banner', () {
      expect(
        Solver.softStuck(start, budget: budgetLimitedBudget),
        SolveVerdict.unknown,
      );
    });
  });

  group('hints on the fixtures', () {
    for (final fixture in solvable) {
      test('${fixture.name}: the first move of an optimal line', () {
        final start = GameState.initial(fixture.level);
        final moves = solvableFixtureMoves[fixture.name]!;
        final hint = Solver.hint(start, budget: SolverBudgets.admin);
        expect(hint.source, HintSource.solver);
        expect(hint.verdict, SolveVerdict.solved);
        expect(hint.move, Solver.solve(start).solution!.first);
        // Following the hint keeps an optimal line.
        final after = replay(start, [hint.move!]);
        final rest = Solver.solve(after);
        expect(rest.solution, hasLength(moves - 1));
      });
    }

    for (final fixture in unsolvable) {
      test('${fixture.name}: no move, verdict unsolvable (D22)', () {
        final hint = Solver.hint(GameState.initial(fixture.level));
        expect(hint.move, isNull);
        expect(hint.source, HintSource.none);
        expect(hint.verdict, SolveVerdict.unsolvable);
      });
    }

    test('$budgetLimitedFixture at $budgetLimitedBudget: the fallback', () {
      final start = GameState.initial(
        fixture(FixtureFolder.solvable, budgetLimitedFixture).level,
      );
      final hint = Solver.hint(start, budget: budgetLimitedBudget);
      expect(hint.verdict, SolveVerdict.unknown);
      expect(hint.source, HintSource.fallback);
      expect(hint.nodes, budgetLimitedBudget);
      expect(hint.move, Solver.fallbackHint(start));
    });
  });

  test('the parity suite\'s copies of the fixtures match the files', () {
    // test/parity/solver_parity_test.dart can't read files (it runs on the
    // web), so it keeps JSON copies; they must not drift from the fixtures.
    var copies = 0;
    for (final fixture in [...solvable, ...unsolvable]) {
      final key = fixture.folder == FixtureFolder.unsolvable
          ? 'u${fixture.name}'
          : fixture.name;
      final copy = parityLevels[key];
      if (copy == null) continue;
      copies++;
      expect(LevelCodec.decode(copy).level, fixture.level, reason: key);
    }
    expect(copies, parityLevels.length - 1, reason: 'all but the large board');
  });

  group('validation rule 8 runs the solver by default (spec §5.3)', () {
    for (final fixture in solvable) {
      test('${fixture.name}: valid, with the solution in the report', () {
        final report = Validator.validateJson(jsonDecode(fixture.source));
        expect(report.issues, isEmpty);
        expect(report.isValid, isTrue);
        expect(
          report.solve!.solution,
          hasLength(solvableFixtureMoves[fixture.name]),
        );
      });
    }

    for (final fixture in unsolvable) {
      test('${fixture.name}: solver.unsolvable', () {
        final report = Validator.validateJson(jsonDecode(fixture.source));
        final nodes = Solver.solve(GameState.initial(fixture.level)).nodes;
        expect(report.issues.map((i) => i.code), [IssueCodes.unsolvable]);
        expect(report.issues.single.args, {'nodes': nodes});
        expect(report.solve!.verdict, SolveVerdict.unsolvable);
      });
    }

    test('$budgetLimitedFixture with a budget of $budgetLimitedBudget: '
        'solver.unproven', () {
      final large = fixture(FixtureFolder.solvable, budgetLimitedFixture);
      final report = Validator.validate(
        large.level,
        options: const ValidationOptions(solverBudget: budgetLimitedBudget),
      );
      expect(report.issues.map((i) => i.code), [IssueCodes.unproven]);
      expect(report.issues.single.args, {
        'nodes': budgetLimitedBudget,
        'budget': budgetLimitedBudget,
      });
    });
  });
}
