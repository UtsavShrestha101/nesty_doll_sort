// One move that produces every kind of event but the last one, to pin the
// §4 animation order (docs/plans/m1-core-design.md §3, owner override A2):
// Picked, NestedInto, the source tower's Revealed, Completed, the
// destination tower's Revealed, Unlocked (slot order), IceShattered /
// IceCracked (slot order).
import 'package:nesty_core/nesty_core.dart';
import 'package:test/test.dart';

import 'support/boards.dart';

void main() {
  // maxSize 3: one red, green and blue set each.
  //   r0: tower [[green3], [red1]] | tower [[blue3], [red3, red2]]
  //       | locked(red) [green2, green1]
  //   r1: [blue2, blue1] ice 1 | empty, ice 2 | empty
  final state = GameState.initial(
    board(3, [
      [
        tower(['green3', 'red1']),
        tower(['blue3', 'red3 red2']),
        locked(DollColor.red, 'green2 green1'),
      ],
      [open('blue2 blue1', 1), open(null, 2), open()],
    ]),
  );

  test('a tower-to-tower completion emits all events in §4 order', () {
    final result = apply(state, 'r0c0>r0c1');
    expect(result.events, [
      Picked(
        slotId: 'r0c0',
        nest: nest('red1'),
        fromTower: true,
        leftEmptyTower: false,
      ),
      NestedInto(
        fromId: 'r0c0',
        slotId: 'r0c1',
        direction: NestDirection.inside,
        moving: nest('red1'),
        target: nest('red3 red2'),
        merged: nest('red3 red2 red1'),
      ),
      Revealed(slotId: 'r0c0', nest: nest('green3'), hiddenBelow: 0),
      const Completed(
        slotId: 'r0c1',
        color: DollColor.red,
        setsCompleted: 1,
        totalSets: 3,
        leftEmptyTower: false,
      ),
      Revealed(slotId: 'r0c1', nest: nest('blue3'), hiddenBelow: 0),
      const Unlocked(slotId: 'r0c2', unlockColor: DollColor.red),
      const IceShattered(slotId: 'r1c0'),
      const IceCracked(slotId: 'r1c1', remaining: 1),
    ]);
    expect(result.completedSet, isTrue);
  });

  test('the board after it matches the events', () {
    final after = apply(state, 'r0c0>r0c1').state;
    expect(after.slot('r0c0'), tower(['green3']));
    expect(after.slot('r0c1'), tower(['blue3']));
    expect(after.slot('r0c2'), open('green2 green1'));
    expect(after.slot('r1c0'), open('blue2 blue1'));
    expect(after.slot('r1c1'), open(null, 1));
    expect(after.completedSets, 1);
    expect(after.completedOf(DollColor.red), 1);
    expect(after.completedOf(DollColor.green), 0);
    expect(after.moveCount, 1);
  });

  test('the remaining two sets finish the level in two more moves', () {
    final after = apply(state, 'r0c0>r0c1').state;
    // [green2, green1] into [green3]: the tower empties on completion.
    final green = apply(after, 'r0c2>r0c0');
    expect(
      green.events[2],
      const Completed(
        slotId: 'r0c0',
        color: DollColor.green,
        setsCompleted: 2,
        totalSets: 3,
        leftEmptyTower: true,
      ),
    );
    // The last ice (r1c1, 1 → 0) shatters on this completion.
    expect(green.events.last, const IceShattered(slotId: 'r1c1'));
    // [blue3] swallows [blue2, blue1] from the other tower.
    final blue = apply(green.state, 'r0c1>r1c0');
    expect(blue.events, [
      Picked(
        slotId: 'r0c1',
        nest: nest('blue3'),
        fromTower: true,
        leftEmptyTower: true,
      ),
      NestedInto(
        fromId: 'r0c1',
        slotId: 'r1c0',
        direction: NestDirection.swallow,
        moving: nest('blue3'),
        target: nest('blue2 blue1'),
        merged: nest('blue3 blue2 blue1'),
      ),
      const Completed(
        slotId: 'r1c0',
        color: DollColor.blue,
        setsCompleted: 3,
        totalSets: 3,
        leftEmptyTower: false,
      ),
      const Won(moveCount: 3),
    ]);
  });
}
