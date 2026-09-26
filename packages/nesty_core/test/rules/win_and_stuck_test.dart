// Spec §2.3: "Win: every doll on the board has been completed into full
// sets"; "Out of moves: there is no legal move at all (no empty open slot
// and no possible merge)". §4 ends a move's events with Won or OutOfMoves
// (design A22: not won and legalMoves empty).
import 'package:nesty_core/nesty_core.dart';
import 'package:test/test.dart';

import 'support/boards.dart';

void main() {
  group('Won', () {
    test('the last completion ends the events with Won(moveCount)', () {
      // Tutorial board L1 (design TUT1): 2 moves.
      final l1 = GameState.initial(
        board(3, [
          [open('red3'), open(), open('red2')],
          [open(), open('red1'), open()],
        ]),
      );
      expect(Rules.isWon(l1), isFalse);
      final one = apply(l1, 'r0c2>r0c0');
      expect(one.events.last, isNot(isA<Won>()));
      final two = apply(one.state, 'r1c1>r0c0');
      expect(two.events.last, const Won(moveCount: 2));
      expect(two.events.whereType<Won>(), hasLength(1));
      expect(two.state.isWon, isTrue);
      expect(Rules.isWon(two.state), isTrue);
      expect(two.state.completedSets, two.state.totalSets);
    });

    test('tutorial board L2 is won in 3 with the swallow', () {
      // design TUT2: r0 [red3] [blue2] null, r1 [red2,red1] [blue3] [blue1].
      final l2 = GameState.initial(
        board(3, [
          [open('red3'), open('blue2'), open()],
          [open('red2 red1'), open('blue3'), open('blue1')],
        ]),
      );
      final swallow = apply(l2, 'r0c0>r1c0');
      expect(
        (swallow.events[1] as NestedInto).direction,
        NestDirection.swallow,
      );
      final won = play(swallow.state, ['r1c2>r0c1', 'r0c1>r1c1']);
      expect(won.isWon, isTrue);
      expect(won.moveCount, 3);
    });

    test('Won comes after the ice events of the same move', () {
      final state = GameState.initial(
        board(3, [
          [open('red3 red2'), open('red1'), open(null, 1)],
        ]),
      );
      expect(apply(state, 'r0c1>r0c0').events, [
        Picked(
          slotId: 'r0c1',
          nest: nest('red1'),
          fromTower: false,
          leftEmptyTower: false,
        ),
        NestedInto(
          fromId: 'r0c1',
          slotId: 'r0c0',
          direction: NestDirection.inside,
          moving: nest('red1'),
          target: nest('red3 red2'),
          merged: nest('red3 red2 red1'),
        ),
        const Completed(
          slotId: 'r0c0',
          color: DollColor.red,
          setsCompleted: 1,
          totalSets: 1,
          leftEmptyTower: false,
        ),
        const IceShattered(slotId: 'r0c2'),
        const Won(moveCount: 1),
      ]);
    });

    test('a won board has no moves but is not "out of moves"', () {
      final won = apply(
        GameState.initial(
          board(3, [
            [open('red3 red2'), open('red1')],
          ]),
        ),
        'r0c1>r0c0',
      );
      expect(won.events.whereType<OutOfMoves>(), isEmpty);
      expect(Rules.legalMoves(won.state), isEmpty);
      expect(Rules.isOutOfMoves(won.state), isFalse);
    });
  });

  group('OutOfMoves', () {
    // maxSize 3. The middle dolls are sealed in cases only their own color
    // could break, so no merge is possible, and r0c2 is the only empty slot.
    // A move from an open slot always leaves that slot empty, so only the
    // pick from the tower can fill the board.
    final state = GameState.initial(
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
    );

    test('legal moves exist while an open slot is empty', () {
      expect(Rules.isOutOfMoves(state), isFalse);
      expect(Rules.legalMoves(state), [
        mv('r0c0>r0c2'),
        mv('r0c1>r0c2'),
        mv('r1c0>r0c2'),
      ]);
    });

    test('a move from an open slot frees that slot again', () {
      expect(apply(state, 'r0c1>r0c2').events.last, isA<Placed>());
    });

    test('filling the last empty slot ends with OutOfMoves', () {
      // The tower shows [blue1], which fits neither [blue3] nor anything
      // else.
      final result = apply(state, 'r0c0>r0c2');
      expect(result.events, [
        Picked(
          slotId: 'r0c0',
          nest: nest('red3'),
          fromTower: true,
          leftEmptyTower: false,
        ),
        Placed(fromId: 'r0c0', slotId: 'r0c2', nest: nest('red3')),
        Revealed(slotId: 'r0c0', nest: nest('blue1'), hiddenBelow: 0),
        const OutOfMoves(),
      ]);
      expect(Rules.isOutOfMoves(result.state), isTrue);
      expect(Rules.isWon(result.state), isFalse);
      expect(Rules.legalMoves(result.state), isEmpty);
    });

    test('empty slots do not help when no nest can be picked', () {
      // After red completes, the only nests left are frozen or locked.
      final state = GameState.initial(
        board(3, [
          [
            open('red3 red2'),
            open('red1'),
            locked(DollColor.blue, 'blue3 blue2'),
          ],
          [open('blue1', 5), open()],
        ]),
      );
      final result = apply(state, 'r0c1>r0c0');
      expect(result.events.sublist(2), [
        const Completed(
          slotId: 'r0c0',
          color: DollColor.red,
          setsCompleted: 1,
          totalSets: 2,
          leftEmptyTower: false,
        ),
        const IceCracked(slotId: 'r1c0', remaining: 4),
        const OutOfMoves(),
      ]);
      expect(Rules.isOutOfMoves(result.state), isTrue);
    });
  });
}
