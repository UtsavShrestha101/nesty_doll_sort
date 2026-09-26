// Spec §4 `legalMoves(state)`, `canPick`, `interactable`, and the facade's
// legalTargets. The order (by source, then by target, each in
// state.slotIds order) is part of the contract, because the simulator and
// the fallback hint pick from the list (spec §6.4, §6.5).
import 'package:nesty_core/nesty_core.dart';
import 'package:test/test.dart';

import '../models/spec_example_level.dart' show specExampleLevel;
import 'support/boards.dart';

void main() {
  // The §5.1 example:
  //   r0: open [red4, red3] | open empty | tower [[blue2], [green4], [red2, red1]]
  //   r1: locked(red) [green3, green2, green1] | open [blue4, blue3] ice 2
  //       | open [blue1]
  final example = GameState.initial(specExampleLevel());

  group('on the §5.1 example', () {
    test('legalMoves, worked out from the rules, in contract order', () {
      // Pickable: r0c0, the tower top r0c2, r1c2 (r0c1 is empty, r1c0 is
      // locked, r1c1 is iced). Targets: r0c0, r0c1, r0c2, r1c2.
      //   [red4, red3] -> r0c1 place; -> r0c2 swallow (2 == 3 − 1)
      //   [red2, red1] -> r0c0 inside (2 == 3 − 1); -> r0c1 place
      //   [blue1]      -> r0c1 place (every other target is red)
      expect(Rules.legalMoves(example), [
        mv('r0c0>r0c1'),
        mv('r0c0>r0c2'),
        mv('r0c2>r0c0'),
        mv('r0c2>r0c1'),
        mv('r1c2>r0c1'),
      ]);
    });

    test('legalTargets per source', () {
      expect(Rules.legalTargets(example, 'r0c0'), ['r0c1', 'r0c2']);
      expect(Rules.legalTargets(example, 'r0c2'), ['r0c0', 'r0c1']);
      expect(Rules.legalTargets(example, 'r1c2'), ['r0c1']);
    });

    test('legalTargets is empty when the source cannot be picked', () {
      for (final id in ['r0c1', 'r1c0', 'r1c1', 'x0', 'nope']) {
        expect(Rules.legalTargets(example, id), isEmpty, reason: id);
      }
    });

    test('canPick and isInteractable per slot kind (spec §4)', () {
      const interactable = {
        'r0c0': true, // open with a nest
        'r0c1': true, // empty open slot
        'r0c2': true, // tower
        'r1c0': false, // glass case
        'r1c1': false, // ice 2
        'r1c2': true,
      };
      const pickable = {
        'r0c0': true,
        'r0c1': false,
        'r0c2': true,
        'r1c0': false,
        'r1c1': false,
        'r1c2': true,
      };
      for (final id in example.slotIds) {
        expect(Rules.isInteractable(example, id), interactable[id], reason: id);
        expect(Rules.canPick(example, id), pickable[id], reason: id);
      }
    });

    test('unknown ids are neither interactable nor pickable', () {
      for (final id in ['x0', 'x1', 'r2c0', 'nope', '']) {
        expect(Rules.isInteractable(example, id), isFalse, reason: id);
        expect(Rules.canPick(example, id), isFalse, reason: id);
      }
    });
  });

  group('completeness', () {
    // Every (from, to) pair over the board plus some unknown ids: a move is
    // in legalMoves exactly when tryMove applies it.
    void expectComplete(GameState state) {
      final legal = Rules.legalMoves(state).toSet();
      for (final from in [...state.slotIds, 'x0', 'x1', 'nope']) {
        for (final to in [...state.slotIds, 'x0', 'x1', 'nope']) {
          final move = Move(from, to);
          final applied = Rules.tryMove(state, move) is MoveApplied;
          expect(legal.contains(move), applied, reason: '$move on $state');
        }
      }
    }

    test('along a line of play through the §5.1 example', () {
      var state = example;
      expectComplete(state);
      for (final move in ['r0c0>r0c2', 'r1c0>r0c2', 'r1c2>r0c2']) {
        state = apply(state, move).state;
        expectComplete(state);
      }
    });

    test('with extra slots, which come last in the target order', () {
      final session = GameSession(specExampleLevel())..addExtraSlot();
      expectComplete(session.state);
      expect(Rules.legalTargets(session.state, 'r0c0'), ['r0c1', 'r0c2', 'x0']);
      session.addExtraSlot();
      expectComplete(session.state);
      expect(Rules.legalMoves(session.state).take(4), [
        mv('r0c0>r0c1'),
        mv('r0c0>r0c2'),
        mv('r0c0>x0'),
        mv('r0c0>x1'),
      ]);
    });

    test('the list does not change when the state is reused', () {
      expect(Rules.legalMoves(example), Rules.legalMoves(example));
    });
  });

  test('a full board with no fitting pair has no legal move', () {
    final state = GameState.initial(
      board(3, [
        [open('red3'), open('red1')],
        [open('blue3'), open('blue1')],
      ]),
    );
    expect(Rules.legalMoves(state), isEmpty);
    expect(Rules.isOutOfMoves(state), isTrue);
  });
}
