// Hints and the soft-stuck check (spec §2.3, §6.3, design A3/A4, D22): the
// solver's first move when solved, the fallback when the budget runs out,
// no move when the state is proven unsolvable, and each fallback branch.
//
// Platform-neutral: levels are built in code.
import 'package:nesty_core/nesty_core.dart';
import 'package:test/test.dart';

import '../rules/support/boards.dart';
import 'support/solver_oracle.dart';

/// Tutorial level 1 (design TUT1).
Level tut1() => board(3, [
  [open('red3'), open(), open('red2')],
  [open(), open('red1'), open()],
]);

/// No merge anywhere (blue3, green3 and red3 are all size 3); a tower whose
/// top green3 hides red1; [extraEmpty] + 1 empty open slots.
Level noMerge({int extraEmpty = 1}) => board(3, [
  [
    open('blue3'),
    tower(['red2 red1', 'green3']),
    open(),
    for (var i = 0; i < extraEmpty; i++) open(),
  ],
  [open('red3')],
]);

/// A board rich enough that a tiny budget runs out.
Level busy() => board(4, [
  [open('red4'), open('blue2'), open('green3 green2'), open('red1')],
  [open('blue4 blue3'), open('green1'), open('red3 red2'), open()],
  [open('green4'), open('blue1')],
]);

void main() {
  group('Solver.fallbackHint (design A3)', () {
    test('1: the first legal merge', () {
      final state = GameState.initial(busy());
      final merges = [
        for (final move in Rules.legalMoves(state))
          if (!state.slot(move.to).isEmpty) move,
      ];
      expect(merges, isNotEmpty);
      expect(Solver.fallbackHint(state), merges.first);
    });

    test('2: skips pointless placements for one that leaves an empty slot', () {
      final state = GameState.initial(noMerge());
      final moves = Rules.legalMoves(state);
      // The first legal move is blue3 into an empty open slot: pointless.
      expect(moves.first, const Move('r0c0', 'r0c2'));
      // The tower's top into the first empty slot leaves the other empty.
      expect(Solver.fallbackHint(state), const Move('r0c1', 'r0c2'));
    });

    test('2: an emptied tower counts as the empty slot left', () {
      final state = GameState.initial(
        board(3, [
          [
            open('blue3'),
            tower(['green3']),
            open(),
          ],
          [open('red3')],
        ]),
      );
      // green3 leaves the tower, which opens: an empty slot remains.
      expect(Solver.fallbackHint(state), const Move('r0c1', 'r0c2'));
    });

    test('3: takes the last slot rather than suggest a pointless move', () {
      final state = GameState.initial(noMerge(extraEmpty: 0));
      // Only r0c2 is empty. blue3 or red3 moving there changes nothing; the
      // tower's top moving there fills the board but reveals red2, red1.
      expect(Rules.legalMoves(state).first, const Move('r0c0', 'r0c2'));
      expect(Solver.fallbackHint(state), const Move('r0c1', 'r0c2'));
    });

    test('3: only pointless placements left: the first of them', () {
      final state = GameState.initial(
        board(3, [
          [open('blue3'), open('red3'), open()],
          [open('green3')],
        ]),
      );
      expect(Solver.fallbackHint(state), Rules.legalMoves(state).first);
    });

    test('null when there is no legal move', () {
      final state = GameState.initial(
        board(3, [
          [
            tower(['red2 red1', 'blue3']),
            tower(['blue2 blue1', 'green3']),
            tower(['green2 green1', 'red3']),
          ],
        ]),
      );
      expect(Solver.fallbackHint(state), isNull);
    });
  });

  group('Solver.hint', () {
    test('solved: the first move of the optimal solution', () {
      final state = GameState.initial(tut1());
      final hint = Solver.hint(state);
      final solve = Solver.solve(state, budget: SolverBudgets.hint);
      expect(hint.source, HintSource.solver);
      expect(hint.verdict, SolveVerdict.solved);
      expect(hint.move, solve.solution!.first);
      expect(hint.nodes, solve.nodes);
      expect(Solver.solve(replay(state, [hint.move!])).solution, hasLength(1));
    });

    test('unknown: the fallback move, marked as such', () {
      final state = GameState.initial(busy());
      final hint = Solver.hint(state, budget: 2);
      expect(hint.verdict, SolveVerdict.unknown);
      expect(hint.source, HintSource.fallback);
      expect(hint.move, Solver.fallbackHint(state));
      expect(hint.nodes, 2);
    });

    test('unsolvable: no move and the verdict, nothing to charge (D22)', () {
      final state = GameState.initial(
        board(3, [
          [
            tower(['green2 green1', 'red3', 'blue3']),
            tower(['blue2 blue1', 'red2 red1', 'green3']),
            open(),
          ],
        ]),
      );
      final hint = Solver.hint(state);
      expect(hint.move, isNull);
      expect(hint.source, HintSource.none);
      expect(hint.verdict, SolveVerdict.unsolvable);
      expect(hint.nodes, greaterThan(0));
    });

    test('out of moves: no move, unsolvable', () {
      final state = GameState.initial(
        board(3, [
          [
            tower(['red2 red1', 'blue3']),
            tower(['blue2 blue1', 'green3']),
            tower(['green2 green1', 'red3']),
          ],
        ]),
      );
      final hint = Solver.hint(state);
      expect(hint.move, isNull);
      expect(hint.source, HintSource.none);
      expect(hint.verdict, SolveVerdict.unsolvable);
    });

    test('won: nothing left to hint', () {
      final won = play(GameState.initial(tut1()), ['r1c1>r0c2', 'r0c2>r0c0']);
      final hint = Solver.hint(won);
      expect(hint.move, isNull);
      expect(hint.source, HintSource.none);
      expect(hint.verdict, SolveVerdict.solved);
    });

    test('hintFrom gives the hint of a search the caller ran', () {
      for (final (level, budget) in [
        (tut1(), SolverBudgets.hint),
        (busy(), 2),
        (noMerge(extraEmpty: 0), SolverBudgets.hint),
      ]) {
        final state = GameState.initial(level);
        final run = Solver.start(state, budget: budget);
        while (!run.advance(1)) {}
        expect(
          Solver.hintFrom(state, run.result),
          Solver.hint(state, budget: budget),
        );
      }
    });

    test('the default budget is the hint budget', () {
      final state = GameState.initial(busy());
      expect(
        Solver.hint(state),
        Solver.hint(state, budget: SolverBudgets.hint),
      );
    });
  });

  group('Solver.softStuck (spec §2.3)', () {
    test('only a proof of no win is unsolvable', () {
      final stuck = GameState.initial(
        board(3, [
          [
            tower(['green2 green1', 'red3', 'blue3']),
            tower(['blue2 blue1', 'red2 red1', 'green3']),
            open(),
          ],
        ]),
      );
      expect(Solver.softStuck(stuck), SolveVerdict.unsolvable);
      expect(Solver.softStuck(GameState.initial(tut1())), SolveVerdict.solved);
      expect(
        Solver.softStuck(GameState.initial(busy()), budget: 2),
        SolveVerdict.unknown,
      );
    });

    test('the default budget is the soft-stuck budget', () {
      final state = GameState.initial(busy());
      expect(
        Solver.softStuck(state),
        Solver.solve(state, budget: SolverBudgets.softStuck).verdict,
      );
    });
  });
}
