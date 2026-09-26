// Spec §5.1 (level JSON) and §4: "Level { maxSize, shelves:
// List<List<Slot>>, goldPresent? }", slots named "r{row}c{col}".
// Spec §2.3: "Win: every doll on the board has been completed into full
// sets", so the number of sets is what the family counter counts to.
import 'package:nesty_core/nesty_core.dart';
import 'package:test/test.dart';

import 'spec_example_level.dart';

void main() {
  group('Level', () {
    test('keeps the §5.1 fields, with schema version 1 by default', () {
      final level = specExampleLevel();
      expect(level.id, 'L0042');
      expect(level.maxSize, 4);
      expect(level.schemaVersion, 1);
      expect(Level.currentSchemaVersion, 1);
      expect(level.generatorVersion, isNull);
      expect(level.seed, isNull);
      expect(level.shelves, hasLength(2));
      expect(level.shelves.map((s) => s.length), [3, 3]);
    });

    test('keeps generator metadata (design A20)', () {
      final level = Level(
        id: 'B0001',
        maxSize: 3,
        shelves: const [],
        generatorVersion: 1,
        seed: 1000001,
      );
      expect(level.generatorVersion, 1);
      expect(level.seed, 1000001);
    });

    test('slot ids are row-major r{row}c{col} (spec §4)', () {
      expect(specExampleLevel().slotIds, [
        'r0c0',
        'r0c1',
        'r0c2',
        'r1c0',
        'r1c1',
        'r1c2',
      ]);
      expect(specExampleLevel().slotCount, 6);
    });

    test('rows may differ in length', () {
      final level = Level(
        id: 'T',
        maxSize: 3,
        shelves: [
          [OpenSlot(), OpenSlot(), OpenSlot(), OpenSlot()],
          [OpenSlot(), OpenSlot()],
        ],
      );
      expect(level.slotIds, ['r0c0', 'r0c1', 'r0c2', 'r0c3', 'r1c0', 'r1c1']);
      expect(level.positionOf('r1c1'), const BoardPosition(1, 1));
    });

    test('slot and positionOf look slots up by id', () {
      final level = specExampleLevel();
      expect(level.slot('r0c0'), OpenSlot(nest: nest(DollColor.red, 4, 2)));
      expect(level.slot('r0c2'), isA<TowerSlot>());
      expect(
        level.slot('r1c0'),
        LockedSlot(
          unlockColor: DollColor.red,
          nest: nest(DollColor.green, 3, 3),
        ),
      );
      expect(level.slot('r1c1').ice, 2);
      expect(level.positionOf('r0c2'), const BoardPosition(0, 2));
      expect(level.positionOf('r1c0'), const BoardPosition(1, 0));
    });

    test('unknown ids throw an ArgumentError, extra ids included', () {
      final level = specExampleLevel();
      for (final id in ['r2c0', 'r0c3', 'x0', '', 'R0C0']) {
        expect(() => level.slot(id), throwsArgumentError, reason: id);
        expect(() => level.positionOf(id), throwsArgumentError, reason: id);
      }
    });

    group('sets', () {
      test('the §5.1 example holds one set each of red, green and blue', () {
        final level = specExampleLevel();
        // red: red4 red3 + red2 red1; green: green4 + green3..1;
        // blue: blue2 + blue4 blue3 + blue1. DollColor order.
        expect(level.setsByColor, {
          DollColor.red: 1,
          DollColor.green: 1,
          DollColor.blue: 1,
        });
        expect(level.setsByColor.keys, [
          DollColor.red,
          DollColor.green,
          DollColor.blue,
        ]);
        expect(level.totalSets, 3);
      });

      test('counts k sets of one color (spec §5.3 rule 4)', () {
        final level = Level(
          id: 'T',
          maxSize: 3,
          shelves: [
            [
              OpenSlot(nest: nest(DollColor.red, 3, 2)),
              OpenSlot(nest: nest(DollColor.red, 1)),
              OpenSlot(nest: nest(DollColor.red, 3)),
            ],
            [OpenSlot(nest: nest(DollColor.red, 2, 2)), OpenSlot()],
          ],
        );
        expect(level.setsByColor, {DollColor.red: 2});
        expect(level.totalSets, 2);
      });

      test('gold is not a set of its own (spec §3.5, §5.3 rule 4)', () {
        final level = Level(
          id: 'T',
          maxSize: 3,
          shelves: [
            [
              OpenSlot(nest: nest(DollColor.red, 3, 3)),
              OpenSlot(nest: nest(DollColor.gold, 2)),
            ],
          ],
        );
        expect(level.setsByColor, {DollColor.red: 1});
      });

      test('an empty board has no sets', () {
        final level = Level(
          id: 'T',
          maxSize: 3,
          shelves: [
            [OpenSlot(), OpenSlot()],
          ],
        );
        expect(level.setsByColor, isEmpty);
        expect(level.totalSets, 0);
      });

      test('setsByColor is unmodifiable', () {
        expect(
          () => specExampleLevel().setsByColor[DollColor.pink] = 1,
          throwsUnsupportedError,
        );
      });
    });

    test('copies shelves and exposes them unmodifiable', () {
      final row = <Slot>[OpenSlot(), OpenSlot()];
      final shelves = [row];
      final level = Level(id: 'T', maxSize: 3, shelves: shelves);
      row.add(OpenSlot());
      shelves.add([OpenSlot()]);
      expect(level.shelves, hasLength(1));
      expect(level.shelves.single, hasLength(2));
      expect(() => level.shelves.add([]), throwsUnsupportedError);
      expect(() => level.shelves.first.add(OpenSlot()), throwsUnsupportedError);
    });

    test('holds rule-breaking data for the validator (spec §5.3)', () {
      // Five shelves, maxSize 9 and incomplete sets are all representable;
      // the validator reports them.
      final level = Level(
        id: 'T',
        maxSize: 9,
        shelves: List.generate(
          5,
          (_) => [OpenSlot(nest: nest(DollColor.red, 2))],
        ),
      );
      expect(level.shelves, hasLength(5));
    });

    test('equality is structural', () {
      expect(specExampleLevel(), specExampleLevel());
      expect(specExampleLevel().hashCode, specExampleLevel().hashCode);
      final other = Level(
        id: 'L0042',
        maxSize: 4,
        shelves: specExampleLevel().shelves,
        seed: 7,
      );
      expect(other, isNot(specExampleLevel()));
      final moved = Level(
        id: 'L0042',
        maxSize: 4,
        shelves: specExampleLevel().shelves.reversed.toList(),
      );
      expect(moved, isNot(specExampleLevel()));
    });

    test('toString names the level and its rows', () {
      expect(
        specExampleLevel().toString(),
        'Level(L0042, maxSize 4, 3/3 slots)',
      );
    });
  });
}
