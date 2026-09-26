// The level JSON example of spec §5.1, played to the end:
//
//   r0: open [red4, red3] | open empty | tower [[blue2], [green4], [red2, red1]]
//   r1: locked(red) [green3, green2, green1] | open [blue4, blue3] ice 2
//       | open [blue1]
//
// Design §5: "swallow into tower completes red → reveals green4, unlocks
// r1c0, ice → 1; optimal 4 moves". Every expectation below is worked out
// from the rules text (§2.2, §3.2–§3.4, §4), not from running the engine.
import 'package:nesty_core/nesty_core.dart';
import 'package:test/test.dart';

import '../models/spec_example_level.dart' show specExampleLevel;
import 'support/boards.dart';

void main() {
  final start = GameState.initial(specExampleLevel());

  // 1. [red4, red3] swallows the tower top [red2, red1] (2 == 3 − 1): a full
  //    red set, which leaves the tower and shows [green4]; the red case
  //    breaks; the ice on r1c1 drops 2 → 1.
  final m1 = apply(start, 'r0c0>r0c2');
  // 2. The freed [green3, green2, green1] goes inside [green4] (3 == 4 − 1):
  //    full; the tower shows [blue2]; the ice 1 → 0 shatters.
  final m2 = apply(m1.state, 'r1c0>r0c2');
  // 3. [blue1] goes inside [blue2] on the tower (1 == 2 − 1).
  final m3 = apply(m2.state, 'r1c2>r0c2');
  // 4. The thawed [blue4, blue3] swallows [blue2, blue1] (2 == 3 − 1): the
  //    last set, which empties the tower.
  final m4 = apply(m3.state, 'r1c1>r0c2');

  test('move 1: swallow into the tower completes red', () {
    expect(m1.events, [
      Picked(
        slotId: 'r0c0',
        nest: nest('red4 red3'),
        fromTower: false,
        leftEmptyTower: false,
      ),
      NestedInto(
        fromId: 'r0c0',
        slotId: 'r0c2',
        direction: NestDirection.swallow,
        moving: nest('red4 red3'),
        target: nest('red2 red1'),
        merged: nest('red4 red3 red2 red1'),
      ),
      const Completed(
        slotId: 'r0c2',
        color: DollColor.red,
        setsCompleted: 1,
        totalSets: 3,
        leftEmptyTower: false,
      ),
      Revealed(slotId: 'r0c2', nest: nest('green4'), hiddenBelow: 1),
      const Unlocked(slotId: 'r1c0', unlockColor: DollColor.red),
      const IceCracked(slotId: 'r1c1', remaining: 1),
    ]);
    expect(m1.completedSet, isTrue);
  });

  test('the board after move 1', () {
    final s = m1.state;
    expect(s.slot('r0c0'), open());
    expect(s.slot('r0c1'), open());
    expect(s.slot('r0c2'), tower(['blue2', 'green4']));
    expect(s.slot('r1c0'), open('green3 green2 green1'));
    expect(s.slot('r1c1'), open('blue4 blue3', 1));
    expect(s.slot('r1c2'), open('blue1'));
    expect(s.completedSets, 1);
    expect(s.completedOf(DollColor.red), 1);
    expect(s.moveCount, 1);
    expect(s.isWon, isFalse);
  });

  test('move 2: green completes on the tower and the ice shatters', () {
    expect(m2.events, [
      Picked(
        slotId: 'r1c0',
        nest: nest('green3 green2 green1'),
        fromTower: false,
        leftEmptyTower: false,
      ),
      NestedInto(
        fromId: 'r1c0',
        slotId: 'r0c2',
        direction: NestDirection.inside,
        moving: nest('green3 green2 green1'),
        target: nest('green4'),
        merged: nest('green4 green3 green2 green1'),
      ),
      const Completed(
        slotId: 'r0c2',
        color: DollColor.green,
        setsCompleted: 2,
        totalSets: 3,
        leftEmptyTower: false,
      ),
      Revealed(slotId: 'r0c2', nest: nest('blue2'), hiddenBelow: 0),
      const IceShattered(slotId: 'r1c1'),
    ]);
    expect(m2.state.slot('r1c1'), open('blue4 blue3'));
  });

  test('move 3: a plain merge on the tower top', () {
    expect(m3.events, [
      Picked(
        slotId: 'r1c2',
        nest: nest('blue1'),
        fromTower: false,
        leftEmptyTower: false,
      ),
      NestedInto(
        fromId: 'r1c2',
        slotId: 'r0c2',
        direction: NestDirection.inside,
        moving: nest('blue1'),
        target: nest('blue2'),
        merged: nest('blue2 blue1'),
      ),
    ]);
    expect(m3.completedSet, isFalse);
    expect(m3.state.slot('r0c2'), tower(['blue2 blue1']));
  });

  test('move 4: the last set empties the tower and wins', () {
    expect(m4.events, [
      Picked(
        slotId: 'r1c1',
        nest: nest('blue4 blue3'),
        fromTower: false,
        leftEmptyTower: false,
      ),
      NestedInto(
        fromId: 'r1c1',
        slotId: 'r0c2',
        direction: NestDirection.swallow,
        moving: nest('blue4 blue3'),
        target: nest('blue2 blue1'),
        merged: nest('blue4 blue3 blue2 blue1'),
      ),
      const Completed(
        slotId: 'r0c2',
        color: DollColor.blue,
        setsCompleted: 3,
        totalSets: 3,
        leftEmptyTower: true,
      ),
      const Won(moveCount: 4),
    ]);
    final end = m4.state;
    expect(end.isWon, isTrue);
    for (final id in end.slotIds) {
      expect(end.slot(id), open(), reason: id);
    }
    for (final color in [DollColor.red, DollColor.green, DollColor.blue]) {
      expect(end.completedOf(color), 1, reason: color.id);
    }
  });

  test('4 moves is optimal: the §6.3 heuristic is 4 at the start', () {
    // h = nestsOnBoard − setsRemaining never overestimates (§6.3): every
    // merge lowers the nest count by exactly 1 and a placement by 0. The
    // start has 7 nests (the tower holds 3) and 3 sets to make.
    final nests = [
      for (final id in start.slotIds) ...start.slot(id).nests,
    ].length;
    expect(nests, 7);
    expect(nests - (start.totalSets - start.completedSets), 4);
    expect(m4.state.moveCount, 4);
  });
}
