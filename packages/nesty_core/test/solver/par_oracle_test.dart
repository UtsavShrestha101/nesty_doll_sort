// The star rating's par is the true minimum (spec-prop §7.10, D125, D146;
// m7-design P3.3).
//
// Spec-prop §7.10: "**Par** is the fewest moves that solve the level from
// its start, the solver's optimal solution (§6.3)." star-rating.md "Rules"
// 1: "It is the solver's optimal solution: A* with a consistent heuristic
// (spec §6.3) finds the true minimum. `nesty_levels bundle build` computes
// it with the admin budget and writes it into each bundle entry."
//
// `bundle build` takes the par from validation rule 8 (spec §5.3) at the
// admin budget: the length of `ValidationReport.solve.solution`. Here that
// same number must equal, on every solvable fixture, both the hand-worked
// optimum (fixture_expectations.dart) and the shortest win an independent
// breadth-first search over every legal move finds (no pruning,
// test/solver/support/solver_oracle.dart), so the solver's pruning can
// never make par longer than a line the player can play. The random boards
// of search_test.dart check the same A* optimality on 120 more levels.
//
// VM only: the fixtures are read with dart:io.
@TestOn('vm')
library;

import 'package:nesty_core/nesty_core.dart';
import 'package:test/test.dart';

import '../fixtures/fixture_loader.dart';
import 'fixture_expectations.dart';
import 'support/random_levels.dart';
import 'support/solver_oracle.dart';

/// The par `nesty_levels bundle build` writes: rule 8's solution length at
/// the admin budget, or null when rule 8 did not prove the level.
int? parOf(Level level) => Validator.validate(level).solve?.solution?.length;

void main() {
  group('par on the solvable fixtures', () {
    for (final fixture in loadFixtures(FixtureFolder.solvable)) {
      final expected = solvableFixtureMoves[fixture.name]!;
      test('${fixture.name}: par $expected, the shortest line the BFS '
          'oracle finds', () {
        final start = GameState.initial(fixture.level);
        final par = parOf(fixture.level);
        expect(par, expected, reason: 'the hand-worked optimum');
        final oracle = reachableCanonicalStates(start, cap: 2000000);
        expect(oracle.depth, par, reason: 'breadth-first, every legal move');
        expect(par, greaterThanOrEqualTo(1));
      });
    }
  });

  test('the unsolvable fixtures have no par', () {
    for (final fixture in loadFixtures(FixtureFolder.unsolvable)) {
      expect(parOf(fixture.level), isNull, reason: fixture.name);
    }
  });

  test('par is the BFS depth on the random oracle boards that pass rules '
      '1–7', () {
    // Random boards need not follow rules 1–7 (full sets, lock colors, …);
    // rule 8, and so a par, only exists for those that do.
    var proven = 0;
    for (var seed = 1; seed <= 120; seed++) {
      final level = randomLevel(seed);
      final report = Validator.validate(level);
      if (report.solve == null) continue;
      final oracle = reachableCanonicalStates(GameState.initial(level));
      final par = report.solve!.solution?.length;
      expect(par, oracle.depth, reason: 'seed $seed');
      if (par != null) proven++;
    }
    // 46 of the 120 pass rules 1–7 and all of them solve; the rest are
    // checked by search_test.dart without the validator.
    expect(proven, greaterThanOrEqualTo(40));
  });
}
