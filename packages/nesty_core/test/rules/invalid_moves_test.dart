// Spec §2.2 "any other drop is invalid" and the `require` lines of §4:
// every InvalidMoveReason, the order they are checked in (the precedence
// documented on InvalidMoveReason, which follows §4: `src != dst`, then
// `canPick(src)` = interactable before `top != null`, then
// `interactable(dst)`, then the merge rules), and that a rejected move
// changes nothing.
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

  group('each reason', () {
    test('unknownSlot: an id that is not on the board', () {
      expect(rejection(example, 'nope>r0c1'), InvalidMoveReason.unknownSlot);
      expect(rejection(example, 'r0c0>r9c9'), InvalidMoveReason.unknownSlot);
      expect(rejection(example, 'r0c0>r0c3'), InvalidMoveReason.unknownSlot);
    });

    test('unknownSlot: an extra slot that was not added yet', () {
      expect(rejection(example, 'r0c0>x0'), InvalidMoveReason.unknownSlot);
      expect(rejection(example, 'x1>r0c1'), InvalidMoveReason.unknownSlot);
    });

    test('sameSlot: src == dst (§4 `require src != dst`)', () {
      expect(rejection(example, 'r0c0>r0c0'), InvalidMoveReason.sameSlot);
    });

    test('sourceEmpty: nothing to pick up (§4 `top(src) != null`)', () {
      expect(rejection(example, 'r0c1>r0c0'), InvalidMoveReason.sourceEmpty);
    });

    test('sourceFrozen: an iced slot cannot be picked from (§3.4)', () {
      expect(rejection(example, 'r1c1>r0c1'), InvalidMoveReason.sourceFrozen);
    });

    test('sourceLocked: a nest behind glass cannot be used (§3.3)', () {
      expect(rejection(example, 'r1c0>r0c1'), InvalidMoveReason.sourceLocked);
    });

    test('targetFrozen: an iced slot cannot be dropped onto (§3.4)', () {
      // [blue1] would otherwise fit nothing here either; frozen wins.
      expect(rejection(example, 'r1c2>r1c1'), InvalidMoveReason.targetFrozen);
    });

    test('targetLocked: a glass case takes nothing (§3.3)', () {
      expect(rejection(example, 'r0c0>r1c0'), InvalidMoveReason.targetLocked);
    });

    test('colorMismatch: T and M differ in color (§4 `colorsMatch`)', () {
      // [blue1] onto [red4, red3].
      expect(rejection(example, 'r1c2>r0c0'), InvalidMoveReason.colorMismatch);
      // [red2, red1] onto [blue1].
      expect(rejection(example, 'r0c2>r1c2'), InvalidMoveReason.colorMismatch);
    });

    test('sizeMismatch: same color but neither rule 2 nor rule 3 fits', () {
      final state = GameState.initial(
        board(4, [
          [open('red4'), open('red2'), open('red1')],
          [open('red3 red2'), open('red3'), open('blue1')],
        ]),
      );
      // [red4] onto [red2]: 4 != 2 − 1 and 2 != 4 − 1.
      expect(rejection(state, 'r0c0>r0c1'), InvalidMoveReason.sizeMismatch);
      // Equal sizes never nest.
      expect(rejection(state, 'r1c1>r1c0'), InvalidMoveReason.sizeMismatch);
      // [red3, red2] onto [red3]: a nest is never split (§2.2 "a whole
      // nest").
      expect(rejection(state, 'r1c0>r1c1'), InvalidMoveReason.sizeMismatch);
      // Two sizes apart in either direction.
      expect(rejection(state, 'r0c2>r1c1'), InvalidMoveReason.sizeMismatch);
      expect(rejection(state, 'r1c1>r0c2'), InvalidMoveReason.sizeMismatch);
    });

    test('a tower takes no placement: a non-fitting drop is invalid', () {
      // §3.2 "You cannot place a new nest onto a tower": the tower's top is
      // what the drop is judged against.
      final state = GameState.initial(
        board(4, [
          [
            tower(['blue2', 'green4']),
            open('red1'),
            open('green1'),
          ],
          [open(), open('red4'), open('blue1')],
        ]),
      );
      expect(rejection(state, 'r0c1>r0c0'), InvalidMoveReason.colorMismatch);
      expect(rejection(state, 'r0c2>r0c0'), InvalidMoveReason.sizeMismatch);
    });
  });

  group('targetOccupied', () {
    // §4's `else invalid` for an empty target that is not open. Every empty
    // interactable slot is open-like (an emptied tower and a broken case act
    // as open slots, §3.2, §3.3), so no move in play is rejected this way.
    test('is never the reason on any reachable board', () {
      final states = <GameState>[example];
      var state = example;
      for (final move in ['r0c0>r0c2', 'r1c0>r0c2', 'r1c2>r0c2']) {
        state = apply(state, move).state;
        states.add(state);
      }
      for (final s in states) {
        for (final from in s.slotIds) {
          for (final to in [...s.slotIds, 'x0', 'nope']) {
            final result = Rules.tryMove(s, Move(from, to));
            if (result is MoveRejected) {
              expect(
                result.reason,
                isNot(InvalidMoveReason.targetOccupied),
                reason: '$from -> $to',
              );
            }
          }
        }
      }
    });
  });

  group('precedence (spec §4 order)', () {
    final state = GameState.initial(
      board(4, [
        [
          open(null, 1), // r0c0: iced, empty
          locked(DollColor.red), // r0c1: an empty glass case
          locked(DollColor.red, 'blue4', 2), // r0c2: iced glass case
        ],
        [open('red4 red3'), open(), open('blue3')], // r1c0, r1c1, r1c2
      ]),
    );

    test('an unknown id beats every other check', () {
      expect(rejection(state, 'nope>nope'), InvalidMoveReason.unknownSlot);
      expect(rejection(state, 'r0c0>nope'), InvalidMoveReason.unknownSlot);
    });

    test('sameSlot beats the source checks', () {
      expect(rejection(state, 'r0c2>r0c2'), InvalidMoveReason.sameSlot);
      expect(rejection(state, 'r1c1>r1c1'), InvalidMoveReason.sameSlot);
    });

    test('ice beats the lock (interactable checks ice first)', () {
      expect(rejection(state, 'r0c2>r1c1'), InvalidMoveReason.sourceFrozen);
      expect(rejection(state, 'r1c0>r0c2'), InvalidMoveReason.targetFrozen);
    });

    test('an iced or locked source beats an empty one', () {
      // §4 `canPick = interactable && top != null`: interactable first.
      expect(rejection(state, 'r0c0>r1c1'), InvalidMoveReason.sourceFrozen);
      expect(rejection(state, 'r0c1>r1c1'), InvalidMoveReason.sourceLocked);
    });

    test('source checks beat target checks', () {
      expect(rejection(state, 'r1c1>r0c0'), InvalidMoveReason.sourceEmpty);
      expect(rejection(state, 'r1c1>r0c1'), InvalidMoveReason.sourceEmpty);
    });

    test('an empty glass case is still locked, not a place to drop', () {
      expect(rejection(state, 'r1c0>r0c1'), InvalidMoveReason.targetLocked);
    });

    test('color is checked before size', () {
      // [blue3] onto [red4, red3]: wrong color and no fit.
      expect(rejection(state, 'r1c2>r1c0'), InvalidMoveReason.colorMismatch);
    });
  });

  group('a rejected move changes nothing', () {
    test('the state it was tried on is unchanged', () {
      final before = views(example);
      for (final move in [
        'nope>r0c1',
        'r0c0>r0c0',
        'r0c1>r0c0',
        'r1c1>r0c1',
        'r1c0>r0c1',
        'r1c2>r1c1',
        'r0c0>r1c0',
        'r1c2>r0c0',
      ]) {
        rejection(example, move);
      }
      expect(views(example), before);
      expect(example.moveCount, 0);
    });

    test('MoveRejected carries the move and aims the shake at `to`', () {
      final result = Rules.tryMove(example, mv('r1c2>r0c0'));
      expect(
        result,
        const MoveRejected(
          move: Move('r1c2', 'r0c0'),
          reason: InvalidMoveReason.colorMismatch,
        ),
      );
      expect((result as MoveRejected).targetId, 'r0c0');
    });
  });
}
