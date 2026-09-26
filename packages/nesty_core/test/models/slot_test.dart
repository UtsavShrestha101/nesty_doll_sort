// Spec §3.1 "Open slot: holds 0 or 1 nest." §3.2 "Tower slot: holds a stack
// of nests (bottom → top), up to 4 deep. Only the top nest can be picked up
// or merged into." §3.3 "Locked slot (glass case) ... may contain a nest
// that is visible behind glass." §3.4 "Ice (modifier on any slot)" with a
// counter n.
import 'package:nesty_core/nesty_core.dart';
import 'package:test/test.dart';

void main() {
  final red43 = Nest.run(DollColor.red, outer: 4, length: 2);
  final blue2 = Nest.run(DollColor.blue, outer: 2, length: 1);
  final green4 = Nest.run(DollColor.green, outer: 4, length: 1);
  final red21 = Nest.run(DollColor.red, outer: 2, length: 2);

  group('OpenSlot (spec §3.1)', () {
    test('empty by default, with no ice', () {
      final slot = OpenSlot();
      expect(slot.nest, isNull);
      expect(slot.nests, isEmpty);
      expect(slot.isEmpty, isTrue);
      expect(slot.ice, 0);
      expect(slot.isFrozen, isFalse);
    });

    test('holds one nest', () {
      final slot = OpenSlot(nest: red43);
      expect(slot.nest, red43);
      expect(slot.nests, [red43]);
      expect(slot.isEmpty, isFalse);
    });

    test('iced when ice > 0 (spec §3.4)', () {
      final slot = OpenSlot(nest: red43, ice: 2);
      expect(slot.ice, 2);
      expect(slot.isFrozen, isTrue);
    });

    test('equality by nest and ice', () {
      expect(OpenSlot(nest: red43), OpenSlot(nest: red43));
      expect(OpenSlot(nest: red43).hashCode, OpenSlot(nest: red43).hashCode);
      expect(OpenSlot(), OpenSlot());
      expect(OpenSlot(nest: red43), isNot(OpenSlot()));
      expect(OpenSlot(nest: red43), isNot(OpenSlot(nest: red43, ice: 1)));
    });
  });

  group('TowerSlot (spec §3.2)', () {
    test('stack is bottom to top; top is the last nest', () {
      final slot = TowerSlot([blue2, green4, red21]);
      expect(slot.stack, [blue2, green4, red21]);
      expect(slot.nests, [blue2, green4, red21]);
      expect(slot.top, red21);
      expect(slot.hiddenCount, 2);
      expect(slot.isEmpty, isFalse);
    });

    test('a single-nest tower hides nothing', () {
      final slot = TowerSlot([green4]);
      expect(slot.top, green4);
      expect(slot.hiddenCount, 0);
    });

    test('is never empty (spec §3.2, §5.3 rule 5)', () {
      expect(() => TowerSlot([]), throwsArgumentError);
    });

    test('can hold more than 4 nests so the validator can report it', () {
      final slot = TowerSlot(List.filled(5, blue2));
      expect(slot.stack, hasLength(5));
    });

    test('copies the stack and exposes it unmodifiable', () {
      final source = [blue2, green4];
      final slot = TowerSlot(source);
      source.add(red21);
      expect(slot.stack, [blue2, green4]);
      expect(() => slot.stack.add(red21), throwsUnsupportedError);
    });

    test('equality by stack and ice', () {
      expect(TowerSlot([blue2, green4]), TowerSlot([blue2, green4]));
      expect(
        TowerSlot([blue2, green4]).hashCode,
        TowerSlot([blue2, green4]).hashCode,
      );
      expect(TowerSlot([blue2, green4]), isNot(TowerSlot([green4, blue2])));
      expect(TowerSlot([green4]), isNot(TowerSlot([green4], ice: 1)));
    });
  });

  group('LockedSlot (spec §3.3)', () {
    test('holds its unlock color and an optional nest', () {
      final slot = LockedSlot(unlockColor: DollColor.red, nest: green4);
      expect(slot.unlockColor, DollColor.red);
      expect(slot.nest, green4);
      expect(slot.nests, [green4]);
      final empty = LockedSlot(unlockColor: DollColor.red);
      expect(empty.nest, isNull);
      expect(empty.isEmpty, isTrue);
    });

    test('equality by unlock color, nest and ice', () {
      expect(
        LockedSlot(unlockColor: DollColor.red, nest: green4),
        LockedSlot(unlockColor: DollColor.red, nest: green4),
      );
      expect(
        LockedSlot(unlockColor: DollColor.red, nest: green4).hashCode,
        LockedSlot(unlockColor: DollColor.red, nest: green4).hashCode,
      );
      expect(
        LockedSlot(unlockColor: DollColor.red, nest: green4),
        isNot(LockedSlot(unlockColor: DollColor.blue, nest: green4)),
      );
      expect(
        LockedSlot(unlockColor: DollColor.red),
        isNot(LockedSlot(unlockColor: DollColor.red, ice: 3)),
      );
    });
  });

  test('negative ice is rejected on every kind (spec §3.4)', () {
    expect(() => OpenSlot(ice: -1), throwsRangeError);
    expect(() => TowerSlot([blue2], ice: -1), throwsRangeError);
    expect(
      () => LockedSlot(unlockColor: DollColor.red, ice: -1),
      throwsRangeError,
    );
  });

  test('kinds never equal each other, even with the same nest', () {
    final open = OpenSlot(nest: green4);
    final tower = TowerSlot([green4]);
    final locked = LockedSlot(unlockColor: DollColor.red, nest: green4);
    expect(open, isNot(tower));
    expect(open, isNot(locked));
    expect(tower, isNot(locked));
  });

  test('a switch over Slot is exhaustive with the three kinds', () {
    String kind(Slot slot) => switch (slot) {
      OpenSlot() => 'open',
      TowerSlot() => 'tower',
      LockedSlot() => 'locked',
    };
    expect(kind(OpenSlot()), 'open');
    expect(kind(TowerSlot([blue2])), 'tower');
    expect(kind(LockedSlot(unlockColor: DollColor.red)), 'locked');
  });

  test('toString shows kind, contents and ice', () {
    expect(OpenSlot().toString(), 'open(empty)');
    expect(
      OpenSlot(nest: red43, ice: 2).toString(),
      'open([red4, red3], ice 2)',
    );
    expect(TowerSlot([blue2, green4]).toString(), 'tower([blue2] [green4])');
    expect(
      LockedSlot(unlockColor: DollColor.red, nest: green4).toString(),
      'locked(red: [green4])',
    );
  });
}
