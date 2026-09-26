// Spec §4: "MoveEvent types (the game animates them in this order): Picked,
// Placed, NestedInto(dstId, direction: inside|swallow), Revealed(slotId),
// Completed(slotId, color), Unlocked(slotId), IceCracked(slotId, remaining),
// IceShattered(slotId), Won, OutOfMoves." Design §3 adds the payloads the
// animations need. Ordering is the engine's job and is tested there; these
// tests pin the event shapes and their value semantics.
import 'package:nesty_core/nesty_core.dart';
import 'package:test/test.dart';

import 'spec_example_level.dart';

void main() {
  final red43 = nest(DollColor.red, 4, 2);
  final red21 = nest(DollColor.red, 2, 2);
  final red4321 = nest(DollColor.red, 4, 4);
  final green4 = nest(DollColor.green, 4);

  // Two independently built instances of every event kind, plus one that
  // differs in each field.
  final cases = <String, (MoveEvent Function(), List<MoveEvent>)>{
    'Picked': (
      () => Picked(
        slotId: 'r0c2',
        nest: red21,
        fromTower: true,
        leftEmptyTower: false,
      ),
      [
        Picked(
          slotId: 'r0c1',
          nest: red21,
          fromTower: true,
          leftEmptyTower: false,
        ),
        Picked(
          slotId: 'r0c2',
          nest: red43,
          fromTower: true,
          leftEmptyTower: false,
        ),
        Picked(
          slotId: 'r0c2',
          nest: red21,
          fromTower: false,
          leftEmptyTower: false,
        ),
        Picked(
          slotId: 'r0c2',
          nest: red21,
          fromTower: true,
          leftEmptyTower: true,
        ),
      ],
    ),
    'Placed': (
      () => Placed(fromId: 'r0c0', slotId: 'r0c1', nest: red43),
      [
        Placed(fromId: 'r1c2', slotId: 'r0c1', nest: red43),
        Placed(fromId: 'r0c0', slotId: 'x0', nest: red43),
        Placed(fromId: 'r0c0', slotId: 'r0c1', nest: red21),
      ],
    ),
    'NestedInto': (
      () => NestedInto(
        fromId: 'r0c2',
        slotId: 'r0c0',
        direction: NestDirection.inside,
        moving: red21,
        target: red43,
        merged: red4321,
      ),
      [
        NestedInto(
          fromId: 'r1c2',
          slotId: 'r0c0',
          direction: NestDirection.inside,
          moving: red21,
          target: red43,
          merged: red4321,
        ),
        NestedInto(
          fromId: 'r0c2',
          slotId: 'r0c1',
          direction: NestDirection.inside,
          moving: red21,
          target: red43,
          merged: red4321,
        ),
        NestedInto(
          fromId: 'r0c2',
          slotId: 'r0c0',
          direction: NestDirection.swallow,
          moving: red21,
          target: red43,
          merged: red4321,
        ),
        NestedInto(
          fromId: 'r0c2',
          slotId: 'r0c0',
          direction: NestDirection.inside,
          moving: red43,
          target: red43,
          merged: red4321,
        ),
        NestedInto(
          fromId: 'r0c2',
          slotId: 'r0c0',
          direction: NestDirection.inside,
          moving: red21,
          target: red21,
          merged: red4321,
        ),
        NestedInto(
          fromId: 'r0c2',
          slotId: 'r0c0',
          direction: NestDirection.inside,
          moving: red21,
          target: red43,
          merged: red43,
        ),
      ],
    ),
    'Revealed': (
      () => Revealed(slotId: 'r0c2', nest: green4, hiddenBelow: 1),
      [
        Revealed(slotId: 'r0c1', nest: green4, hiddenBelow: 1),
        Revealed(slotId: 'r0c2', nest: red21, hiddenBelow: 1),
        Revealed(slotId: 'r0c2', nest: green4, hiddenBelow: 0),
      ],
    ),
    'Completed': (
      () => const Completed(
        slotId: 'r0c2',
        color: DollColor.red,
        setsCompleted: 1,
        totalSets: 3,
        leftEmptyTower: false,
      ),
      [
        const Completed(
          slotId: 'r0c0',
          color: DollColor.red,
          setsCompleted: 1,
          totalSets: 3,
          leftEmptyTower: false,
        ),
        const Completed(
          slotId: 'r0c2',
          color: DollColor.blue,
          setsCompleted: 1,
          totalSets: 3,
          leftEmptyTower: false,
        ),
        const Completed(
          slotId: 'r0c2',
          color: DollColor.red,
          setsCompleted: 2,
          totalSets: 3,
          leftEmptyTower: false,
        ),
        const Completed(
          slotId: 'r0c2',
          color: DollColor.red,
          setsCompleted: 1,
          totalSets: 4,
          leftEmptyTower: false,
        ),
        const Completed(
          slotId: 'r0c2',
          color: DollColor.red,
          setsCompleted: 1,
          totalSets: 3,
          leftEmptyTower: true,
        ),
      ],
    ),
    'Unlocked': (
      () => const Unlocked(slotId: 'r1c0', unlockColor: DollColor.red),
      [
        const Unlocked(slotId: 'r1c1', unlockColor: DollColor.red),
        const Unlocked(slotId: 'r1c0', unlockColor: DollColor.blue),
      ],
    ),
    'IceCracked': (
      () => const IceCracked(slotId: 'r1c1', remaining: 1),
      [
        const IceCracked(slotId: 'r1c2', remaining: 1),
        const IceCracked(slotId: 'r1c1', remaining: 2),
      ],
    ),
    'IceShattered': (
      () => const IceShattered(slotId: 'r1c1'),
      [const IceShattered(slotId: 'r1c2')],
    ),
    'Won': (() => const Won(moveCount: 4), [const Won(moveCount: 5)]),
    'OutOfMoves': (() => const OutOfMoves(), <MoveEvent>[]),
  };

  group('MoveEvent value semantics', () {
    for (final MapEntry(key: kind, value: (make, different)) in cases.entries) {
      test('$kind: equal when every field is equal', () {
        expect(make(), make());
        expect(make().hashCode, make().hashCode);
      });

      test('$kind: unequal when any field differs', () {
        for (final other in different) {
          expect(make(), isNot(other), reason: '$other');
        }
      });
    }

    test('events of different kinds are never equal', () {
      final samples = [for (final (make, _) in cases.values) make()];
      for (var i = 0; i < samples.length; i++) {
        for (var j = 0; j < samples.length; j++) {
          if (i != j) expect(samples[i], isNot(samples[j]));
        }
      }
    });
  });

  test('payloads carry what the animations need (design §3)', () {
    final event = NestedInto(
      fromId: 'r0c2',
      slotId: 'r0c0',
      direction: NestDirection.inside,
      moving: red21,
      target: red43,
      merged: red4321,
    );
    // The clack pitch comes from the merged nest's outer size (spec §11.3).
    expect(event.merged.outerSize, 4);
    expect(event.direction, NestDirection.inside);
    expect(
      const Completed(
        slotId: 'r0c2',
        color: DollColor.red,
        setsCompleted: 1,
        totalSets: 3,
        leftEmptyTower: false,
      ).toString(),
      'Completed(r0c2, red, 1/3, leftEmptyTower: false)',
    );
  });

  test('NestDirection is inside or swallow (spec §2.2 rules 2 and 3)', () {
    expect(NestDirection.values, [NestDirection.inside, NestDirection.swallow]);
  });

  test('a switch over MoveEvent is exhaustive with the ten kinds', () {
    String kind(MoveEvent event) => switch (event) {
      Picked() => 'Picked',
      Placed() => 'Placed',
      NestedInto() => 'NestedInto',
      Revealed() => 'Revealed',
      Completed() => 'Completed',
      Unlocked() => 'Unlocked',
      IceCracked() => 'IceCracked',
      IceShattered() => 'IceShattered',
      Won() => 'Won',
      OutOfMoves() => 'OutOfMoves',
    };
    for (final MapEntry(key: name, value: (make, _)) in cases.entries) {
      expect(kind(make()), name);
    }
  });
}
