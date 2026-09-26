// The A* search (spec §6.3, docs/plans/m1-core-design.md §3): optimal
// against an exhaustive oracle on random boards, the §6.3 pruning, node
// budgets that end in `unknown` and never `unsolvable`, resumable runs that
// give exactly Solver.solve's result, and extra slots.
//
// Platform-neutral: levels are built in code (random ones with the core
// PRNG), so this suite also runs on node and chrome.
import 'package:nesty_core/nesty_core.dart';
import 'package:nesty_core/src/solver/search.dart';
import 'package:test/test.dart';

import '../rules/support/boards.dart';
import 'support/random_levels.dart';
import 'support/solver_oracle.dart';

/// Pruning probe (see the pruning test): a tower whose top blue2 merges
/// with blue3 and blue1 in open slots, two empty slots, and red3/red2 in
/// open slots.
Level pruningProbe() => board(3, [
  [
    tower(['red1', 'blue2']),
    open('blue3'),
    open('blue1'),
    open(),
    open(),
  ],
  [open('red3'), open('red2')],
]);

/// Spec §5.3 unsolvable fixture 003 (no space): both towers' tops are size 3
/// with one empty slot, so either placement fills the board.
Level noSpace() => board(3, [
  [
    tower(['green2 green1', 'red3', 'blue3']),
    tower(['blue2 blue1', 'red2 red1', 'green3']),
    open(),
  ],
]);

void main() {
  group('optimal and exact on random boards (oracle: breadth-first)', () {
    for (var seed = 1; seed <= 120; seed++) {
      test('seed $seed', () {
        final start = GameState.initial(randomLevel(seed));
        final oracle = reachableCanonicalStates(start);
        final result = Solver.solve(start);
        if (oracle.depth == null) {
          expect(result.verdict, SolveVerdict.unsolvable);
          expect(result.nodes, oracle.states);
        } else {
          expectOptimalWin(start, result, oracle.depth!);
          expect(result.nodes, lessThanOrEqualTo(oracle.states));
        }
      });
    }

    test('a cheaper path reroutes a waiting state; still optimal', () {
      // Seeds found by search: A* first reaches a state along a longer line,
      // then a shorter one before expanding it (design §3).
      for (final seed in [192, 372]) {
        final start = GameState.initial(randomLevel(seed));
        final search = AStarSearch(start, SolverBudgets.admin)
          ..advance(SolverBudgets.admin);
        expect(search.reroutes, greaterThan(0), reason: 'seed $seed');
        expectOptimalWin(
          start,
          search.result!,
          reachableCanonicalStates(start).depth!,
        );
      }
    });

    test('the random boards cover both verdicts, towers, cases and ice', () {
      final levels = [
        for (var seed = 1; seed <= 120; seed++) randomLevel(seed),
      ];
      final slots = [
        for (final level in levels)
          for (final shelf in level.shelves) ...shelf,
      ];
      expect(slots.whereType<TowerSlot>(), isNotEmpty);
      expect(slots.whereType<LockedSlot>(), isNotEmpty);
      expect(slots.where((s) => s.ice > 0), isNotEmpty);
      final verdicts = {
        for (final level in levels)
          Solver.solve(GameState.initial(level)).verdict,
      };
      expect(verdicts, {SolveVerdict.solved, SolveVerdict.unsolvable});
    });
  });

  group('pruning (spec §6.3, design A30)', () {
    test('the first expansion generates only the useful moves', () {
      final start = GameState.initial(pruningProbe());
      // The rules allow 16 moves: the tower top has 2 merges and 2
      // placements; blue3, blue1, red3 and red2 each have 1 merge and 2
      // placements into the empty slots.
      expect(Rules.legalMoves(start), hasLength(16));
      final search = AStarSearch(start, SolverBudgets.admin)..advance(1);
      expect(search.expansions, 1);
      // Kept: the tower's 2 merges and 1 of its placements (every empty
      // slot gives the same canonical board); blue3 and blue1 into the
      // tower; red3 with red2 in one direction only (both are free). Gone:
      // every placement of a lone open-slot nest (pointless) and the other
      // direction of the red merge.
      expect(search.successors, 6);
      expect(search.nodes, 7, reason: 'the root and 6 distinct states');
    });

    test('pruning keeps the proof: no-space dead end', () {
      final start = GameState.initial(noSpace());
      final result = Solver.solve(start);
      expect(result.verdict, SolveVerdict.unsolvable);
      expect(result.nodes, reachableCanonicalStates(start).states);
    });
  });

  group('budgets (spec §6.3)', () {
    test('an exhausted budget is unknown, then unsolvable once it fits', () {
      final start = GameState.initial(noSpace());
      final states = reachableCanonicalStates(start).states;
      for (var budget = 1; budget < states; budget++) {
        final result = Solver.solve(start, budget: budget);
        expect(result.verdict, SolveVerdict.unknown, reason: '$budget');
        expect(result.nodes, budget);
      }
      expect(
        Solver.solve(start, budget: states).verdict,
        SolveVerdict.unsolvable,
      );
    });

    test('a budget below 1 is a RangeError', () {
      final start = GameState.initial(noSpace());
      expect(() => Solver.solve(start, budget: 0), throwsRangeError);
      expect(() => Solver.start(start, budget: -1), throwsRangeError);
      expect(() => Solver.hint(start, budget: 0), throwsRangeError);
      expect(() => Solver.softStuck(start, budget: 0), throwsRangeError);
    });
  });

  group('edge states', () {
    test('a won state is solved with no moves', () {
      final won = play(GameState.initial(tut1Level()), [
        'r1c1>r0c2',
        'r0c2>r0c0',
      ]);
      expect(won.isWon, isTrue);
      final result = Solver.solve(won);
      expect(result.verdict, SolveVerdict.solved);
      expect(result.solution, isEmpty);
      expect(result.nodes, 1);
      expect(result.branching, 0);
    });

    test('a state with no legal move is unsolvable after one node', () {
      final stuck = GameState.initial(
        board(3, [
          [
            tower(['red2 red1', 'blue3']),
            tower(['blue2 blue1', 'green3']),
            tower(['green2 green1', 'red3']),
          ],
        ]),
      );
      expect(Rules.isOutOfMoves(stuck), isTrue);
      final result = Solver.solve(stuck, budget: 1);
      expect(result.verdict, SolveVerdict.unsolvable);
      expect(result.nodes, 1);
    });

    test('extra slots are searched: they turn a dead end solvable', () {
      final session = GameSession(noSpace())..addExtraSlot();
      final start = session.state;
      final oracle = reachableCanonicalStates(start);
      // Two placements free red3 and [red2, red1]; then three merges.
      expect(oracle.depth, 5);
      final result = Solver.solve(start);
      expectOptimalWin(start, result, 5);
      expect(result.solution!.expand((m) => [m.from, m.to]), contains('x0'));
    });

    test('a mid-game state is searched from where it is', () {
      final start = play(GameState.initial(tut1Level()), ['r1c1>r0c2']);
      final result = Solver.solve(start);
      expectOptimalWin(start, result, 1);
      // Both are free slots, so the solver tries the pair's merge from the
      // lower index only: red3 swallows [red2, red1].
      expect(result.solution!.single, const Move('r0c0', 'r0c2'));
    });
  });

  group('SolverRun (design §6)', () {
    final levels = {
      'pruning probe': pruningProbe(),
      'no space': noSpace(),
      for (final seed in [3, 7, 11, 19, 42]) 'random $seed': randomLevel(seed),
    };

    for (final MapEntry(key: name, value: level) in levels.entries) {
      test('$name: stepping gives exactly Solver.solve', () {
        final start = GameState.initial(level);
        for (final budget in [3, 40, SolverBudgets.admin]) {
          final expected = Solver.solve(start, budget: budget);
          for (final step in [1, 2, 7]) {
            final run = Solver.start(start, budget: budget);
            var calls = 0;
            while (!run.advance(step)) {
              calls++;
              expect(run.isDone, isFalse);
            }
            expect(run.result, expected, reason: 'budget $budget step $step');
            expect(run.nodes, expected.nodes);
            expect(calls, lessThanOrEqualTo(expected.nodes));
          }
        }
      });
    }

    test('before and after the search', () {
      final start = GameState.initial(pruningProbe());
      final run = SolverRun(start, budget: 100);
      expect(run.isDone, isFalse);
      expect(run.nodes, 0);
      expect(() => run.result, throwsStateError);
      expect(() => run.advance(0), throwsRangeError);
      while (!run.advance(1)) {}
      final result = run.result;
      expect(run.advance(1), isTrue, reason: 'a finished run stays done');
      expect(run.result, result);
      expect(Solver.start(start, budget: 100).budget, 100);
      expect(Solver.start(start).state, start);
    });

    test('a huge step is clamped, not rejected', () {
      final run = SolverRun(GameState.initial(pruningProbe()));
      // 2^40 as a literal: `1 << 40` is 0 on the web (JS masks shift counts).
      expect(run.advance(0x10000000000), isTrue);
    });
  });
}

/// Tutorial level 1 (design TUT1): red3, red2 and red1 apart.
Level tut1Level() => board(3, [
  [open('red3'), open(), open('red2')],
  [open(), open('red1'), open()],
]);
