// Spec §3.2 tower slots, with the §4 steps that touch them: only the top
// can be picked or merged into, a pick reveals the next nest, a tower takes
// no placement, an empty tower becomes an open slot, and a completion on a
// tower top reveals what was under it (after `Completed`, design A2).
import 'package:nesty_core/nesty_core.dart';
import 'package:test/test.dart';

import 'support/boards.dart';

void main() {
  group('picking from a tower', () {
    final state = pickingBoard();

    test('only the top nest can be picked', () {
      expect(Rules.canPick(state, 'r0c0'), isTrue);
      expect(Rules.legalTargets(state, 'r0c0'), ['r0c1', 'r1c2']);
      expect(state.slot('r0c0'), isA<TowerSlot>());
      expect((state.slot('r0c0') as TowerSlot).top, nest('red1'));
    });

    test('the pick reveals the next nest, with its hidden count', () {
      final result = apply(state, 'r0c0>r0c1');
      expect(result.events, [
        Picked(
          slotId: 'r0c0',
          nest: nest('red1'),
          fromTower: true,
          leftEmptyTower: false,
        ),
        Placed(fromId: 'r0c0', slotId: 'r0c1', nest: nest('red1')),
        Revealed(slotId: 'r0c0', nest: nest('green2'), hiddenBelow: 1),
      ]);
      expect(result.state.slot('r0c0'), tower(['blue3', 'green2']));
    });

    test('nests reveal one by one down to the last', () {
      // [green2] goes inside [green3], then the tower shows blue3.
      final one = apply(state, 'r0c0>r0c1').state;
      final two = apply(one, 'r0c0>r0c2');
      expect(two.events.last, isA<Revealed>());
      expect(
        two.events.last,
        Revealed(slotId: 'r0c0', nest: nest('blue3'), hiddenBelow: 0),
      );
      expect(two.state.slot('r0c0'), tower(['blue3']));
    });

    test('taking the last nest empties the tower into an open slot', () {
      final state = play(pickingBoard(), ['r0c0>r0c1', 'r0c0>r0c2']);
      final last = apply(state, 'r0c0>r1c0');
      expect(
        last.events.first,
        Picked(
          slotId: 'r0c0',
          nest: nest('blue3'),
          fromTower: true,
          leftEmptyTower: true,
        ),
      );
      expect(last.events.whereType<Revealed>(), isEmpty);
      expect(last.state.slot('r0c0'), open());
    });
  });

  group('an emptied tower (spec §3.2 "becomes a normal open slot")', () {
    final emptied = apply(
      GameState.initial(
        board(3, [
          [
            tower(['red1']),
            open('red3 red2'),
            open('blue1'),
          ],
          [open('blue3 blue2'), open(), open()],
        ]),
      ),
      'r0c0>r1c1',
    ).state;

    test('reads back as an empty open slot', () {
      expect(emptied.slot('r0c0'), open());
    });

    test('takes a placement', () {
      final placed = apply(emptied, 'r0c2>r0c0');
      expect(placed.events[1], isA<Placed>());
      expect(placed.state.slot('r0c0'), open('blue1'));
    });

    test('a pick from it is no longer "from a tower"', () {
      final refilled = apply(emptied, 'r0c2>r0c0').state;
      final picked = apply(refilled, 'r0c0>r1c2');
      expect(
        picked.events.first,
        Picked(
          slotId: 'r0c0',
          nest: nest('blue1'),
          fromTower: false,
          leftEmptyTower: false,
        ),
      );
    });
  });

  group('merging into a tower top', () {
    final state = GameState.initial(
      board(4, [
        [
          tower(['blue4', 'green3', 'red3 red2']),
          open('red1'),
          open('red4'),
        ],
        [open('green2'), open('blue3 blue2'), open()],
      ]),
    );

    test('M goes inside the top; the nests below stay hidden', () {
      // [red1] inside [red3, red2]: 1 == 2 − 1. Not full (maxSize 4).
      final result = apply(state, 'r0c1>r0c0');
      expect(
        result.events[1],
        NestedInto(
          fromId: 'r0c1',
          slotId: 'r0c0',
          direction: NestDirection.inside,
          moving: nest('red1'),
          target: nest('red3 red2'),
          merged: nest('red3 red2 red1'),
        ),
      );
      expect(result.events, hasLength(2));
      expect(
        result.state.slot('r0c0'),
        tower(['blue4', 'green3', 'red3 red2 red1']),
      );
    });

    test('the swallow keeps the merged nest on the tower', () {
      // [red4] swallows [red3, red2]: 3 == 4 − 1.
      final result = apply(state, 'r0c2>r0c0');
      expect((result.events[1] as NestedInto).direction, NestDirection.swallow);
      expect(
        result.state.slot('r0c0'),
        tower(['blue4', 'green3', 'red4 red3 red2']),
      );
      expect(result.state.slot('r0c2'), open());
    });

    test('a tower top can be the moving nest of a merge', () {
      // [red3, red2] goes inside [red4]: 3 == 4 − 1.
      final result = apply(state, 'r0c0>r0c2');
      expect(result.state.slot('r0c2'), open('red4 red3 red2'));
      expect(
        result.events.last,
        Revealed(slotId: 'r0c0', nest: nest('green3'), hiddenBelow: 1),
      );
    });
  });

  group('a set completing on a tower top', () {
    test('Completed comes first, then the next nest is revealed', () {
      final state = GameState.initial(
        board(3, [
          [
            tower(['green3', 'blue3', 'red3 red2']),
            open('red1'),
          ],
          [open('blue2 blue1'), open('green2 green1')],
        ]),
      );
      final result = apply(state, 'r0c1>r0c0');
      expect(result.events, [
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
          totalSets: 3,
          leftEmptyTower: false,
        ),
        Revealed(slotId: 'r0c0', nest: nest('blue3'), hiddenBelow: 1),
      ]);
      expect(result.state.slot('r0c0'), tower(['green3', 'blue3']));
    });

    test('a completion that takes the last nest leaves an open slot', () {
      final state = GameState.initial(
        board(3, [
          [
            tower(['red3 red2']),
            open('red1'),
          ],
          [open('blue3 blue2'), open('blue1')],
        ]),
      );
      final result = apply(state, 'r0c1>r0c0');
      expect(
        result.events[2],
        const Completed(
          slotId: 'r0c0',
          color: DollColor.red,
          setsCompleted: 1,
          totalSets: 2,
          leftEmptyTower: true,
        ),
      );
      expect(result.events.whereType<Revealed>(), isEmpty);
      expect(result.state.slot('r0c0'), open());
      // It takes placements from now on.
      expect(Rules.legalTargets(result.state, 'r1c1'), contains('r0c0'));
    });

    test('a set completing in an open slot says leftEmptyTower false', () {
      final state = GameState.initial(
        board(3, [
          [
            open('red3 red2'),
            tower(['blue3', 'red1']),
          ],
          [open('blue2 blue1'), open()],
        ]),
      );
      // The tower's top is the moving nest; the set completes in r0c0.
      final result = apply(state, 'r0c1>r0c0');
      expect(result.events, [
        Picked(
          slotId: 'r0c1',
          nest: nest('red1'),
          fromTower: true,
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
        Revealed(slotId: 'r0c1', nest: nest('blue3'), hiddenBelow: 0),
        const Completed(
          slotId: 'r0c0',
          color: DollColor.red,
          setsCompleted: 1,
          totalSets: 2,
          leftEmptyTower: false,
        ),
      ]);
    });
  });
}

// maxSize 3: a three-deep tower with red1 on top.
GameState pickingBoard() => GameState.initial(
  board(3, [
    [
      tower(['blue3', 'green2', 'red1']),
      open(),
      open('green3'),
    ],
    [open('blue2 blue1'), open('green1'), open('red3 red2')],
  ]),
);
