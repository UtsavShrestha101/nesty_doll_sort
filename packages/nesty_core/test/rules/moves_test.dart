// Spec §2.2 / §4: the three legal drops. Expected boards and events come
// from the spec text:
//   1. an empty open slot takes the nest;
//   2. same color and `M.outer.size == T.inner.size − 1`: M goes inside T;
//   3. same color and `T.outer.size == M.inner.size − 1`: T goes inside M
//      (the swallow), and the merged nest stays in the target slot.
import 'package:nesty_core/nesty_core.dart';
import 'package:test/test.dart';

import 'support/boards.dart';

void main() {
  // maxSize 4, nothing completes in these moves.
  final start = GameState.initial(
    board(4, [
      [open('red4 red3'), open(), open('red2')],
      [open('red1'), open('blue4'), open('blue3 blue2')],
    ]),
  );

  group('rule 1: place into an empty open slot', () {
    final result = apply(start, 'r0c0>r0c1');

    test('the whole nest moves and the source is left empty', () {
      expect(result.state.slot('r0c1'), open('red4 red3'));
      expect(result.state.slot('r0c0'), open());
    });

    test('events are Picked then Placed', () {
      expect(result.events, [
        Picked(
          slotId: 'r0c0',
          nest: nest('red4 red3'),
          fromTower: false,
          leftEmptyTower: false,
        ),
        Placed(fromId: 'r0c0', slotId: 'r0c1', nest: nest('red4 red3')),
      ]);
      expect(result.completedSet, isFalse);
    });

    test('the other slots are untouched', () {
      for (final id in ['r0c2', 'r1c0', 'r1c1', 'r1c2']) {
        expect(result.state.slot(id), start.slot(id), reason: id);
      }
    });
  });

  group('rule 2: M goes inside T', () {
    // M = [red2] (outer 2), T = [red4, red3] (inner 3): 2 == 3 − 1.
    final result = apply(start, 'r0c2>r0c0');

    test('the merged nest is T.dolls ++ M.dolls in the target slot', () {
      expect(result.state.slot('r0c0'), open('red4 red3 red2'));
      expect(result.state.slot('r0c2'), open());
    });

    test('NestedInto names the direction and the three nests', () {
      expect(result.events, [
        Picked(
          slotId: 'r0c2',
          nest: nest('red2'),
          fromTower: false,
          leftEmptyTower: false,
        ),
        NestedInto(
          fromId: 'r0c2',
          slotId: 'r0c0',
          direction: NestDirection.inside,
          moving: nest('red2'),
          target: nest('red4 red3'),
          merged: nest('red4 red3 red2'),
        ),
      ]);
    });

    test('M may hold several dolls', () {
      // M = [blue3, blue2] (outer 3), T = [blue4] (inner 4): 3 == 4 − 1.
      final merged = apply(start, 'r1c2>r1c1');
      expect(merged.state.slot('r1c1'), open('blue4 blue3 blue2'));
      expect((merged.events[1] as NestedInto).direction, NestDirection.inside);
    });
  });

  group('rule 3: the swallow, T goes inside M', () {
    // M = [red4, red3] (inner 3), T = [red2] (outer 2): 2 == 3 − 1.
    final result = apply(start, 'r0c0>r0c2');

    test('the merged nest is M.dolls ++ T.dolls and stays in the target', () {
      expect(result.state.slot('r0c2'), open('red4 red3 red2'));
      expect(result.state.slot('r0c0'), open());
    });

    test('NestedInto says swallow', () {
      expect(
        result.events[1],
        NestedInto(
          fromId: 'r0c0',
          slotId: 'r0c2',
          direction: NestDirection.swallow,
          moving: nest('red4 red3'),
          target: nest('red2'),
          merged: nest('red4 red3 red2'),
        ),
      );
    });

    test('the direction depends on which of the two nests moves', () {
      // M = [red1] onto T = [red2]: inside (1 == 2 − 1), not a swallow.
      final inside = apply(
        GameState.initial(
          board(4, [
            [open('red2'), open('red1')],
          ]),
        ),
        'r0c1>r0c0',
      );
      expect((inside.events[1] as NestedInto).direction, NestDirection.inside);
      // M = [red2] onto T = [red1]: swallow (1 == 2 − 1).
      final swallow = apply(
        GameState.initial(
          board(4, [
            [open('red2'), open('red1')],
          ]),
        ),
        'r0c0>r0c1',
      );
      expect(
        (swallow.events[1] as NestedInto).direction,
        NestDirection.swallow,
      );
      expect(swallow.state.slot('r0c1'), open('red2 red1'));
    });
  });

  group('moveCount (spec §4 `moveCount++`)', () {
    test('counts every applied move and nothing else', () {
      expect(start.moveCount, 0);
      final one = apply(start, 'r0c0>r0c1').state;
      expect(one.moveCount, 1);
      final two = apply(one, 'r0c2>r0c1').state;
      expect(two.moveCount, 2);
      expect(Rules.tryMove(two, mv('r0c0>r0c2')), isA<MoveRejected>());
      expect(two.moveCount, 2);
    });
  });

  group('purity', () {
    test('tryMove never changes the state it was given', () {
      final before = views(start);
      apply(start, 'r0c0>r0c1');
      apply(start, 'r0c2>r0c0');
      expect(views(start), before);
      expect(start.moveCount, 0);
    });

    test('the same move on the same state gives equal results', () {
      expect(apply(start, 'r0c0>r0c2'), apply(start, 'r0c0>r0c2'));
    });
  });
}
