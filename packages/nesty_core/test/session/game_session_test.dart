// GameSession (spec §2.4 undo and permanence, §3.6 extra slot with the
// owner override D22, §4 core API): undo reverts the last move, the history
// is cleared whenever a set completes, a rejected move pushes nothing,
// addExtraSlot appends x0 then x1 to the bottom shelf (max 2, not a move,
// kept through undo and restart), and restart goes back to the start.
import 'package:nesty_core/nesty_core.dart';
import 'package:test/test.dart';

import '../models/spec_example_level.dart' show specExampleLevel;
import '../rules/support/boards.dart';

void main() {
  // Tutorial board L1 (design TUT1): won in 2 moves.
  //   r0: [red3] | empty | [red2]
  //   r1: empty | [red1] | empty
  final l1 = board(3, [
    [open('red3'), open(), open('red2')],
    [open(), open('red1'), open()],
  ]);

  group('a new session', () {
    final session = GameSession(l1);

    test('is at the initial board with nothing to undo', () {
      expect(session.level, l1);
      expect(session.state, GameState.initial(l1));
      expect(session.canUndo, isFalse);
      expect(session.undoDepth, 0);
      expect(session.undosUsed, 0);
      expect(session.history, isEmpty);
      expect(session.undo(), isNull);
    });

    test('reports the level and board status', () {
      expect(session.setsCompleted, 0);
      expect(session.totalSets, 1);
      expect(session.isWon, isFalse);
      expect(session.isOutOfMoves, isFalse);
      expect(session.legalMoves(), Rules.legalMoves(session.state));
      expect(session.canAddExtraSlot, isTrue);
    });
  });

  group('move', () {
    test('returns what Rules.tryMove returns and adopts its state', () {
      final session = GameSession(l1);
      final expected = Rules.tryMove(session.state, mv('r0c2>r0c0'));
      final result = session.move('r0c2', 'r0c0');
      expect(result, expected);
      expect(session.state, (result as MoveApplied).state);
    });

    test('an applied move pushes the board before it', () {
      final session = GameSession(l1);
      final before = session.state;
      final result = session.move('r0c2', 'r0c0') as MoveApplied;
      expect(session.undoDepth, 1);
      expect(session.canUndo, isTrue);
      expect(session.history.single.before, before);
      expect(session.history.single.move, mv('r0c2>r0c0'));
      expect(session.history.single.events, result.events);
    });

    test('a rejected move changes nothing and pushes nothing', () {
      final session = GameSession(l1)..move('r0c2', 'r0c1');
      final state = session.state;
      final result = session.move('r1c0', 'r0c0');
      expect(result, isA<MoveRejected>());
      expect((result as MoveRejected).reason, InvalidMoveReason.sourceEmpty);
      expect(session.state, same(state));
      expect(session.undoDepth, 1);
    });

    test('the history is a snapshot the caller cannot change', () {
      final session = GameSession(l1)..move('r0c2', 'r0c1');
      final history = session.history;
      expect(() => history.clear(), throwsUnsupportedError);
      session.move('r0c1', 'r0c0');
      expect(history, hasLength(1));
      expect(session.history, hasLength(2));
    });
  });

  group('undo (spec §2.4)', () {
    test('reverts the last move, move count included', () {
      final session = GameSession(l1);
      final before = session.state;
      session.move('r0c2', 'r0c1');
      final undone = session.undo();
      expect(
        undone,
        UndoResult(revertedMove: mv('r0c2>r0c1'), restoredState: before),
      );
      expect(session.state, before);
      expect(session.state.moveCount, 0);
      expect(session.canUndo, isFalse);
      expect(session.undosUsed, 1);
    });

    test('walks back several moves, last first', () {
      final session = GameSession(l1);
      final s0 = session.state;
      session.move('r0c2', 'r0c1');
      final s1 = session.state;
      session.move('r0c1', 'r1c0');
      expect(session.undoDepth, 2);
      expect(session.undo()!.revertedMove, mv('r0c1>r1c0'));
      expect(session.state, s1);
      expect(session.undo()!.revertedMove, mv('r0c2>r0c1'));
      expect(session.state, s0);
      expect(session.undo(), isNull);
      expect(session.undosUsed, 2);
    });

    test('a completion clears the history; that move cannot be undone', () {
      final session = GameSession(specExampleLevel())
        ..move('r1c2', 'r0c1'); // [blue1] into the empty slot
      expect(session.undoDepth, 1);
      final result = session.move('r0c0', 'r0c2') as MoveApplied; // red set
      expect(result.completedSet, isTrue);
      expect(session.canUndo, isFalse);
      expect(session.undoDepth, 0);
      expect(session.undo(), isNull);
      expect(session.state, result.state);
      // Later moves can be undone again, back to just after the completion.
      session.move('r0c1', 'r0c0');
      session.undo();
      expect(session.state, result.state);
    });

    test('completions and unlocks are permanent (spec §2.4)', () {
      final session = GameSession(specExampleLevel())..move('r0c0', 'r0c2');
      session.undo();
      expect(session.setsCompleted, 1);
      expect(session.state.slot('r1c0'), isA<OpenSlot>());
      expect(session.state.slot('r1c1').ice, 1);
    });
  });

  group('addExtraSlot (spec §3.6, D22)', () {
    test('appends x0 then x1 to the bottom shelf, at most two', () {
      final session = GameSession(specExampleLevel());
      final first = session.addExtraSlot()!;
      expect(first.slotId, 'x0');
      expect(first.position, const BoardPosition(1, 3));
      expect(first.state, session.state);
      expect(first.state.slot('x0'), open());
      final second = session.addExtraSlot()!;
      expect(second.slotId, 'x1');
      expect(second.position, const BoardPosition(1, 4));
      expect(session.canAddExtraSlot, isFalse);
      expect(session.addExtraSlot(), isNull);
      expect(session.state.extraSlotCount, GameSession.maxExtraSlots);
    });

    test('is not a move: no undo entry, no move count', () {
      final session = GameSession(l1)..move('r0c2', 'r0c1');
      session.addExtraSlot();
      expect(session.undoDepth, 1);
      expect(session.state.moveCount, 1);
      // The earlier move is still the one undo reverts.
      expect(session.undo()!.revertedMove, mv('r0c2>r0c1'));
    });

    test('the new slot takes nests like any open slot', () {
      final session = GameSession(l1)..addExtraSlot();
      final result = session.move('r0c0', 'x0') as MoveApplied;
      expect(result.events[1], isA<Placed>());
      expect(session.state.slot('x0'), open('red3'));
    });

    test('rescues an out-of-moves board', () {
      // From win_and_stuck_test: the tower pick fills the last slot.
      final session = GameSession(
        board(3, [
          [
            tower(['blue1', 'red3']),
            open('red1'),
            open(),
          ],
          [
            open('blue3'),
            locked(DollColor.red, 'red2'),
            locked(DollColor.blue, 'blue2'),
          ],
        ]),
      )..move('r0c0', 'r0c2');
      expect(session.isOutOfMoves, isTrue);
      session.addExtraSlot();
      expect(session.isOutOfMoves, isFalse);
      expect(session.legalMoves(), [
        mv('r0c0>x0'),
        mv('r0c1>x0'),
        mv('r0c2>x0'),
        mv('r1c0>x0'),
      ]);
    });
  });

  group('extra slots survive undo', () {
    test('an undo keeps the extra slots added after the move', () {
      final session = GameSession(l1)..move('r0c2', 'r0c1');
      final before = session.history.single.before;
      session.addExtraSlot();
      final undone = session.undo()!;
      expect(undone.restoredState.slotIds, [...before.slotIds, 'x0']);
      expect(undone.restoredState.slot('x0'), open());
      for (final id in before.slotIds) {
        expect(undone.restoredState.slot(id), before.slot(id), reason: id);
      }
      expect(undone.restoredState.moveCount, 0);
    });

    test('undoing a move into the extra slot empties it but keeps it', () {
      final session = GameSession(l1)..addExtraSlot();
      session.move('r0c0', 'x0');
      session.undo();
      expect(session.state.slotIds.last, 'x0');
      expect(session.state.slot('x0'), open());
      expect(session.state.slot('r0c0'), open('red3'));
    });
  });

  group('restart (spec §2.4 "resets the level to its start")', () {
    test('goes back to the initial board and clears the history', () {
      final session = GameSession(specExampleLevel())
        ..move('r0c0', 'r0c2') // completes red, breaks r1c0, ice 2 → 1
        ..move('r1c2', 'r0c1');
      session.restart();
      expect(session.state, GameState.initial(specExampleLevel()));
      expect(session.canUndo, isFalse);
      expect(session.setsCompleted, 0);
      expect(session.state.slot('r1c0'), isA<LockedSlot>());
      expect(session.state.slot('r1c1').ice, 2);
    });

    test('keeps the extra slots, empty (D22)', () {
      final session = GameSession(l1)
        ..addExtraSlot()
        ..move('r0c0', 'x0')
        ..addExtraSlot();
      session.restart();
      expect(session.state.slotIds, [...l1.slotIds, 'x0', 'x1']);
      expect(session.state.slot('x0'), open());
      expect(session.state.slot('r0c0'), open('red3'));
      expect(session.state.moveCount, 0);
      expect(session.canAddExtraSlot, isFalse);
    });

    test('keeps the undo count, which is per level (§7.3)', () {
      final session = GameSession(l1)..move('r0c2', 'r0c1');
      session.undo();
      session.restart();
      expect(session.undosUsed, 1);
    });
  });

  group('restore (spec §13.3 in-progress save)', () {
    test('resumes the board and its undo history', () {
      final original = GameSession(l1)
        ..addExtraSlot()
        ..move('r0c2', 'r0c1')
        ..move('r0c1', 'x0');
      final resumed = GameSession.restore(
        l1,
        original.state,
        original.history,
        undosUsed: 1,
      );
      expect(resumed.state, original.state);
      expect(resumed.undoDepth, 2);
      expect(resumed.undosUsed, 1);
      expect(resumed.undo(), original.undo());
      expect(resumed.state, original.state);
      expect(resumed.undosUsed, 2);
    });

    test('an equal level rebuilt from data resumes too', () {
      final original = GameSession(l1)..move('r0c2', 'r0c1');
      final rebuilt = board(3, [
        [open('red3'), open(), open('red2')],
        [open(), open('red1'), open()],
      ]);
      final resumed = GameSession.restore(
        rebuilt,
        original.state,
        original.history,
      );
      expect(resumed.move('r0c1', 'r0c0'), isA<MoveApplied>());
      resumed.restart();
      expect(resumed.state, GameState.initial(l1));
    });

    test('refuses a state or history of another level', () {
      final other = GameSession(specExampleLevel())..move('r1c2', 'r0c1');
      expect(
        () => GameSession.restore(l1, other.state, const []),
        throwsArgumentError,
      );
      expect(
        () => GameSession.restore(l1, GameState.initial(l1), other.history),
        throwsArgumentError,
      );
      expect(
        () => GameSession.restore(
          l1,
          GameState.initial(l1),
          const [],
          undosUsed: -1,
        ),
        throwsRangeError,
      );
    });
  });

  test('a won session', () {
    final session = GameSession(l1)
      ..move('r0c2', 'r0c0')
      ..move('r1c1', 'r0c0');
    expect(session.isWon, isTrue);
    expect(session.setsCompleted, session.totalSets);
    expect(session.isOutOfMoves, isFalse);
    expect(session.canUndo, isFalse);
    expect(session.legalMoves(), isEmpty);
  });
}
