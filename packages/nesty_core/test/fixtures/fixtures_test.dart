// The level fixtures (README.md) are what they claim to be: canonical spec
// §5.1 JSON that passes validation rules 1–7, named exactly as
// test/solver/fixture_expectations.dart lists them, and with the hand-worked
// optimal move counts and unsolvability confirmed by an exhaustive
// breadth-first search over the public Rules API. The search is a test
// oracle, independent of the solver, so the solver's own tests can trust
// these numbers.
//
// VM only: fixtures are read with dart:io.
@TestOn('vm')
library;

import 'dart:convert';

import 'package:nesty_core/nesty_core.dart';
import 'package:test/test.dart';

import '../solver/fixture_expectations.dart';
import 'fixture_loader.dart';

void main() {
  final solvable = loadFixtures(FixtureFolder.solvable);
  final unsolvable = loadFixtures(FixtureFolder.unsolvable);
  final all = [...solvable, ...unsolvable];

  test('the expectations name exactly the files on disk', () {
    expect(solvable.map((f) => f.name), solvableFixtureMoves.keys);
    expect(unsolvable.map((f) => f.name), unsolvableFixtures);
    expect(solvableFixtureMoves.keys, contains(budgetLimitedFixture));
  });

  test('file names follow <nnn>_<what_it_covers>.json', () {
    for (final fixture in all) {
      expect(fixture.name, matches(RegExp(r'^\d{3}_[a-z0-9_]+$')));
    }
  });

  test('level ids are unique', () {
    final ids = [for (final fixture in all) fixture.level.id];
    expect(ids.toSet(), hasLength(ids.length));
  });

  for (final fixture in all) {
    group('$fixture', () {
      test('decodes without issues', () {
        expect(fixture.decoded.issues, isEmpty);
        expect(fixture.decoded.isOk, isTrue);
      });

      test('is canonical: values and key order survive a round trip', () {
        expect(
          LevelCodec.encodeString(fixture.level),
          jsonEncode(jsonDecode(fixture.source)),
        );
      });

      test('passes validation rules 1–7', () {
        final report = Validator.validateJson(
          jsonDecode(fixture.source),
          options: ValidationOptions.loader,
        );
        expect(report.issues, isEmpty);
        expect(report.level, fixture.level);
      });
    });
  }

  group('solvable fixtures: the optimal move count', () {
    for (final fixture in solvable) {
      final expected = solvableFixtureMoves[fixture.name]!;

      test('${fixture.name}: at least nests − sets = the §6.3 lower bound', () {
        final level = fixture.level;
        expect(
          expected,
          greaterThanOrEqualTo(nestCount(level) - level.totalSets),
        );
      });

      if (fixture.name == budgetLimitedFixture) {
        // Too many exact states for a breadth-first search, but merges alone
        // win it, so the lower bound is reached: every merge, in any order,
        // joins two segments of one set.
        test('${fixture.name}: merges alone win in $expected moves', () {
          final level = fixture.level;
          expect(nestCount(level) - level.totalSets, expected);
          var state = GameState.initial(level);
          var moves = 0;
          while (!Rules.isWon(state)) {
            final merge = Rules.legalMoves(
              state,
            ).firstWhere((move) => !state.slot(move.to).isEmpty);
            state = (Rules.tryMove(state, merge) as MoveApplied).state;
            moves++;
          }
          expect(moves, expected);
        });
        continue;
      }

      test('${fixture.name}: $expected moves by exhaustive search', () {
        expect(breadthFirst(fixture.level).depth, expected);
      });
    }
  });

  group('unsolvable fixtures: no reachable state is won', () {
    // Exact reachable states (the hand-worked arguments in
    // fixture_expectations.dart), matched by the independent search the
    // expectations were cross-checked with.
    const reachable = {
      '001_lock_deadlock': 6,
      '002_never_thawing_ice': 28,
      '003_no_space_dead_end': 3,
    };
    for (final fixture in unsolvable) {
      test(fixture.name, () {
        final search = breadthFirst(fixture.level);
        expect(search.depth, isNull, reason: 'a won state was reached');
        expect(search.states, reachable[fixture.name]);
      });
    }
  });
}

int nestCount(Level level) => [
  for (final shelf in level.shelves)
    for (final slot in shelf) slot.nests.length,
].fold(0, (sum, n) => sum + n);

/// Every state reachable from the level's start, level by level: the depth
/// of the first won state (the optimal move count, every move costing 1), or
/// null when none is reachable, and how many distinct states were seen.
({int? depth, int states}) breadthFirst(Level level, {int cap = 100000}) {
  var frontier = [GameState.initial(level)];
  final seen = {stateKey(frontier.single)};
  for (var depth = 0; frontier.isNotEmpty; depth++) {
    if (frontier.any(Rules.isWon)) return (depth: depth, states: seen.length);
    final next = <GameState>[];
    for (final state in frontier) {
      for (final move in Rules.legalMoves(state)) {
        final after = (Rules.tryMove(state, move) as MoveApplied).state;
        if (seen.add(stateKey(after))) next.add(after);
      }
    }
    if (seen.length > cap) throw StateError('More than $cap states');
    frontier = next;
  }
  return (depth: null, states: seen.length);
}

/// The board as the player sees it (slot views show emptied towers, broken
/// cases and current ice) plus the sets completed. Unlike `GameState ==` it
/// ignores `moveCount`, so the same board reached by different paths is one
/// state.
String stateKey(GameState state) =>
    '${state.completedSets}: '
    '${[for (final id in state.slotIds) state.slot(id)].join(' | ')}';
