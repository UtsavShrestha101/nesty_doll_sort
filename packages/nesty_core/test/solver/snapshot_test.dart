// The solver's isolate boundary (design §6, CLAUDE.md rule 8): a state
// travels as a versioned, self-contained Int32List and comes back equal;
// SolverSnapshot.run and a stepped SolverTask answer exactly what
// Solver.hint and Solver.softStuck answer on the state; and a malformed
// snapshot is a FormatException, never a board the rules can't handle.
//
// Platform-neutral: levels are built in code.
import 'dart:typed_data';

import 'package:nesty_core/nesty_core.dart';
import 'package:nesty_core/src/models/game_state.dart';
import 'package:test/test.dart';

import '../models/spec_example_level.dart';
import '../rules/support/boards.dart';

/// Tutorial level 1 (design TUT1).
Level tut1() => board(3, [
  [open('red3'), open(), open('red2')],
  [open(), open('red1'), open()],
]);

/// Spec §5.3 unsolvable fixture 003 (no space) built in code.
Level noSpace() => board(3, [
  [
    tower(['green2 green1', 'red3', 'blue3']),
    tower(['blue2 blue1', 'red2 red1', 'green3']),
    open(),
  ],
]);

/// Every kind of state the game sends: starts, mid-game boards with an
/// emptied tower, a broken case and cracked ice, extra slots, generator
/// metadata, a non-ASCII id and a golden doll.
Map<String, GameState> sampleStates() {
  final example = GameState.initial(specExampleLevel());
  final session = GameSession(specExampleLevel())
    ..move('r0c0', 'r0c2')
    ..addExtraSlot()
    ..addExtraSlot();
  final generated = Level(
    id: 'Лёд ❄ 042',
    maxSize: 3,
    generatorVersion: 7,
    seed: Prng.maxSeed,
    shelves: noSpace().shelves,
  );
  final golden = board(3, [
    [open('red3'), open('gold2'), open('red1')],
    [open(), open('blue3 blue2 blue1')],
  ]);
  return {
    'spec §5.1 example': example,
    'after the red swallow (tower reveals, case breaks, ice cracks)': play(
      example,
      ['r0c0>r0c2'],
    ),
    'blue done, tower emptied': play(example, [
      'r0c0>r0c2',
      'r0c2>r1c0',
      'r1c2>r0c2',
    ]),
    'two extra slots': session.state,
    'generator metadata, non-ASCII id': GameState.initial(generated),
    'gold merged into red': play(GameState.initial(golden), ['r0c1>r0c0']),
    'won': play(GameState.initial(tut1()), ['r1c1>r0c2', 'r0c2>r0c0']),
  };
}

void main() {
  group('encode and decode', () {
    for (final MapEntry(key: name, value: state) in sampleStates().entries) {
      test('round trip: $name', () {
        final snapshot = SolverSnapshot.encode(state);
        expect(snapshot[0], SolverSnapshot.version);
        expect(snapshot[1], snapshot.length);
        expect(snapshot.every((v) => v >= 0), isTrue);
        final decoded = SolverSnapshot.decode(snapshot);
        expect(decoded, state);
        expect(decoded.level, state.level);
        expect(decoded.slotIds, state.slotIds);
        expect(decoded.moveCount, state.moveCount);
        expect(decoded.completedSets, state.completedSets);
        for (final id in state.slotIds) {
          expect(decoded.slot(id), state.slot(id), reason: id);
        }
        expect(Rules.legalMoves(decoded), Rules.legalMoves(state));
        expect(SolverSnapshot.encode(decoded), snapshot);
      });
    }

    test('a small board stays around a hundred ints', () {
      final snapshot = SolverSnapshot.encode(
        GameState.initial(specExampleLevel()),
      );
      expect(snapshot.length, lessThan(100));
    });

    test('encode refuses what the format can not carry', () {
      Level withSeed(int seed) =>
          Level(id: 'S', maxSize: 3, shelves: noSpace().shelves, seed: seed);
      expect(
        () => SolverSnapshot.encode(GameState.initial(withSeed(-1))),
        throwsArgumentError,
      );
    });
  });

  group('run answers what the solver answers', () {
    final states = {
      ...sampleStates(),
      'no space (unsolvable)': GameState.initial(noSpace()),
    };
    for (final MapEntry(key: name, value: state) in states.entries) {
      test(name, () {
        final snapshot = SolverSnapshot.encode(state);
        for (final budget in [2, SolverBudgets.hint]) {
          final hintResult = SolverSnapshot.run(
            snapshot,
            SolverSnapshot.taskHint,
            budget,
            requestId: 41,
          );
          expect(hintResult, hasLength(SolverSnapshot.resultLength));
          expect(hintResult[SolverSnapshot.resultRequestId], 41);
          expect(
            SolverSnapshot.readHint(hintResult, state),
            Solver.hint(state, budget: budget),
          );
          final solve = Solver.solve(state, budget: budget);
          expect(
            hintResult[SolverSnapshot.resultSolutionLength],
            solve.solution?.length ?? SolverSnapshot.noSolution,
          );

          final stuck = SolverSnapshot.run(
            snapshot,
            SolverSnapshot.taskSoftStuck,
            budget,
            requestId: -7,
          );
          expect(stuck[SolverSnapshot.resultRequestId], -7);
          expect(
            SolverSnapshot.readVerdict(stuck),
            Solver.softStuck(state, budget: budget),
          );
          expect(stuck[SolverSnapshot.resultNodes], solve.nodes);
          expect(stuck[SolverSnapshot.resultSource], HintSource.none.index);
          expect(stuck[SolverSnapshot.resultFromIndex], SolverSnapshot.noSlot);
          expect(stuck[SolverSnapshot.resultToIndex], SolverSnapshot.noSlot);
        }
      });
    }

    test('a stepped task gives exactly the run result', () {
      final snapshot = SolverSnapshot.encode(
        GameState.initial(specExampleLevel()),
      );
      for (final task in [
        SolverSnapshot.taskHint,
        SolverSnapshot.taskSoftStuck,
      ]) {
        final expected = SolverSnapshot.run(snapshot, task, 500, requestId: 3);
        final stepped = SolverSnapshot.start(snapshot, task, 500, requestId: 3);
        expect(stepped.isDone, isFalse);
        expect(() => stepped.result, throwsStateError);
        while (!stepped.advance(1)) {}
        expect(stepped.result, expected);
        expect(stepped.nodes, expected[SolverSnapshot.resultNodes]);
        expect(stepped.state, GameState.initial(specExampleLevel()));
      }
    });

    test('bad arguments', () {
      final snapshot = SolverSnapshot.encode(GameState.initial(noSpace()));
      expect(() => SolverSnapshot.run(snapshot, 2, 10), throwsArgumentError);
      expect(
        () => SolverSnapshot.run(snapshot, SolverSnapshot.taskHint, 0),
        throwsRangeError,
      );
      expect(
        () => SolverSnapshot.start(
          snapshot,
          SolverSnapshot.taskHint,
          10,
          requestId: 1 << 31,
        ),
        throwsRangeError,
      );
    });
  });

  group('malformed snapshots are FormatExceptions', () {
    final swallowed = play(GameState.initial(specExampleLevel()), [
      'r0c0>r0c2',
    ]);
    final good = SolverSnapshot.encode(swallowed);
    // Offsets into `good` (see the format on SolverSnapshot): the id
    // 'L0042' ends the fixed header, and the board ends the snapshot.
    const shelfCountAt = 10 + 1 + 5;
    final cells = GameStateBoard.peek(swallowed).cells.length;
    final boardAt = good.length - (5 + cells);

    Int32List changed(int at, int value) =>
        Int32List.fromList(good)..[at] = value;

    final cases = <String, Int32List>{
      'empty': Int32List(0),
      'another version': changed(0, 2),
      'length field': changed(1, good.length + 1),
      'truncated': Int32List.fromList(good.sublist(0, good.length - 1))
        ..[1] = good.length - 1,
      'trailing int': Int32List.fromList([...good, 0])..[1] = good.length + 1,
      'no shelves': changed(shelfCountAt, 0),
      'unknown slot kind': changed(shelfCountAt + 3, 3),
      'completed sets above the total': changed(boardAt, 4),
      'opened mask marks an open slot': changed(boardAt + 1, 1),
      'extra slots above 2': changed(boardAt + 2, 3),
      // Nest code layout: color << 6 | outer << 3 | length.
      'a nest code with a color past the enum': changed(
        good.length - cells,
        (15 << 6) | (3 << 3) | 1,
      ),
      // The last cell is x1's; red1 is code 1 << 3 | 1.
      'a nest in an extra slot not in play': changed(good.length - 1, 9),
      // green4 gone from the middle of the tower, a nest above it.
      'a tower with a gap': changed(boardAt + 5 + 3, 0)..[boardAt + 5 + 4] = 9,
      // The red set left the board, but the counter says none did: the
      // search would start from h < 0.
      'completed sets below what the cells lost': changed(boardAt, 0),
      // blue2 vanished from the tower's bottom: not a whole set.
      'dolls lost that are not a whole set': changed(boardAt + 5 + 2, 0),
    };
    for (final MapEntry(key: name, value: snapshot) in cases.entries) {
      test(name, () {
        expect(
          () => SolverSnapshot.decode(snapshot),
          throwsA(isA<FormatException>()),
        );
      });
    }

    test('every cell emptied with no set completed', () {
      // A 1-set level with its board wiped: without the set check, the
      // search threw a RangeError (h = 0 nests − 1 set left) from the queue.
      final start = SolverSnapshot.encode(GameState.initial(tut1()));
      final cellCount = GameStateBoard.peek(
        GameState.initial(tut1()),
      ).cells.length;
      final wiped = Int32List.fromList(start)
        ..fillRange(start.length - cellCount, start.length, 0);
      expect(
        () => SolverSnapshot.decode(wiped),
        throwsA(isA<FormatException>()),
      );
      expect(
        () => SolverSnapshot.run(wiped, SolverSnapshot.taskHint, 30000),
        throwsA(isA<FormatException>()),
      );
    });

    test('the offsets above point where they claim', () {
      expect(good[shelfCountAt], 2);
      expect(good[boardAt], 1, reason: 'one set completed');
      expect(good[boardAt + 4], cells, reason: 'the cell count');
      // Cells 2–4 are the tower's (bottom to top): blue2, green4, and the
      // top cell the swallow emptied.
      expect(good.sublist(boardAt + 5 + 2, boardAt + 5 + 5), [
        (5 << 6) | (2 << 3) | 1,
        (3 << 6) | (4 << 3) | 1,
        0,
      ]);
      expect(SolverSnapshot.decode(good), swallowed);
    });
  });
}
