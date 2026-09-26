// Spec §6.5 step 2: "Shuffle the segments into towers (top segments of towers
// should not be immediately mergeable too often) and open slots. Leave
// emptySlots empty." Step 3: "Place locked and ice slots on randomly chosen
// occupied slots, respecting validation rule 6."
// Design: bottom shelf ≤ 4 so both extra slots fit (owner override D22);
// A12 locks on occupied open slots, ice n in [1, min(3, totalSets − 1)];
// A13 at most ⌊towers/2⌋ mergeable tower tops.
import 'package:nesty_core/nesty_core.dart';
import 'package:nesty_core/src/generator/placement.dart';
import 'package:nesty_core/src/generator/segments.dart';
import 'package:test/test.dart';

Nest _n(DollColor color, int outer, [int length = 1]) =>
    Nest.run(color, outer: outer, length: length);

/// A total order on nests: color, then outer size, then length.
int _byNest(Nest a, Nest b) {
  if (a.color != b.color) return a.color.index - b.color.index;
  if (a.outerSize != b.outerSize) return a.outerSize - b.outerSize;
  return a.length - b.length;
}

/// A plan over [lengths] whose slot i is a tower when [towers] contains i,
/// holding [nests][i] bottom to top.
BoardPlan _plan(List<int> lengths, List<List<Nest>> nests, Set<int> towers) {
  final slots = [
    for (var i = 0; i < nests.length; i++)
      SlotPlan(tower: towers.contains(i))..nests.addAll(nests[i]),
  ];
  return BoardPlan(lengths, slots);
}

/// The segments and roles of a whole board, as `Generator.buildAttempt`
/// makes them.
({List<Nest> segments, SlotRoles roles, List<int> lengths}) _board(
  int seed, {
  required int colors,
  required int maxSize,
  required int shelves,
  required int slotsPerShelf,
  required int towers,
  required int towerDepth,
  required int emptySlots,
  int setsPerColor = 1,
}) {
  final prng = Prng(seed);
  final lengths = shelfLengths(shelves, slotsPerShelf);
  final slotCount = lengths.fold(0, (a, b) => a + b);
  final occupied = slotCount - towers - emptySlots;
  final segments = cutSets(
    prng,
    chooseColors(prng, colors),
    setsPerColor,
    maxSize,
    occupied + towers * towerDepth,
  );
  final roles = assignRoles(prng, slotCount, towers, emptySlots);
  return (segments: segments, roles: roles, lengths: lengths);
}

void main() {
  group('shelfLengths', () {
    test('every shelf has slotsPerShelf, the bottom one at most 4 (D22)', () {
      expect(shelfLengths(2, 3), [3, 3]);
      expect(shelfLengths(3, 4), [4, 4, 4]);
      expect(shelfLengths(3, 5), [5, 5, 4]);
      expect(shelfLengths(1, 5), [4]);
      expect(shelfLengths(4, 2), [2, 2, 2, 2]);
    });
  });

  group('assignRoles', () {
    test('partitions the slots into towers, empty and occupied open', () {
      for (var seed = 0; seed < 20; seed++) {
        final roles = assignRoles(Prng(seed), 12, 4, 2);
        expect(roles.towers, hasLength(4));
        expect(roles.empty, hasLength(2));
        expect(roles.occupiedOpen, hasLength(6));
        final all = [...roles.towers, ...roles.empty, ...roles.occupiedOpen]
          ..sort();
        expect(all, [for (var i = 0; i < 12; i++) i]);
        for (final list in [roles.towers, roles.empty, roles.occupiedOpen]) {
          expect(list, orderedEquals(List<int>.of(list)..sort()));
        }
      }
    });

    test('reaches every slot as a tower over seeds', () {
      final seen = <int>{};
      for (var seed = 0; seed < 40; seed++) {
        seen.addAll(assignRoles(Prng(seed), 6, 1, 1).towers);
      }
      expect(seen, {0, 1, 2, 3, 4, 5});
    });
  });

  group('mergeableTowerTops', () {
    const lengths = [3];

    test('counts a tower whose top merges with an open nest', () {
      // red2 fits inside red3 (§2.2 rule 2).
      final plan = _plan(
        lengths,
        [
          [_n(DollColor.blue, 3), _n(DollColor.red, 2)],
          [_n(DollColor.red, 3)],
          [],
        ],
        {0},
      );
      expect(mergeableTowerTops(plan, 3), 1);
    });

    test('counts a swallow too (§2.2 rule 3)', () {
      final plan = _plan(
        lengths,
        [
          [_n(DollColor.blue, 3), _n(DollColor.red, 3)],
          [_n(DollColor.red, 2, 2)],
          [],
        ],
        {0},
      );
      expect(mergeableTowerTops(plan, 3), 1);
    });

    test(
      'ignores the buried nests, other colors and non-consecutive sizes',
      () {
        final plan = _plan(
          lengths,
          [
            // The buried red2 would fit red3, but only the top counts.
            [_n(DollColor.red, 2), _n(DollColor.blue, 1)],
            [_n(DollColor.red, 3)],
            [_n(DollColor.blue, 3)],
          ],
          {0},
        );
        expect(mergeableTowerTops(plan, 3), 0);
      },
    );

    test('counts both towers when their tops merge with each other', () {
      final plan = _plan(
        lengths,
        [
          [_n(DollColor.blue, 1), _n(DollColor.red, 3)],
          [_n(DollColor.blue, 3), _n(DollColor.red, 2)],
          [_n(DollColor.blue, 2)],
        ],
        {0, 1},
      );
      expect(mergeableTowerTops(plan, 3), 2);
    });
  });

  group('dealSegments', () {
    test('fills towers to depth and each occupied open slot with one', () {
      for (var seed = 0; seed < 20; seed++) {
        final b = _board(
          seed,
          colors: 4,
          maxSize: 4,
          shelves: 3,
          slotsPerShelf: 3,
          towers: 3,
          towerDepth: 3,
          emptySlots: 1,
        );
        final expected = List.of(b.segments);
        final plan = dealSegments(
          Prng(seed),
          b.segments,
          b.roles,
          b.lengths,
          3,
          4,
        );
        expect(plan.slots, hasLength(9));
        for (var i = 0; i < 9; i++) {
          final slot = plan.slots[i];
          if (b.roles.towers.contains(i)) {
            expect(slot.tower, isTrue);
            expect(slot.nests, hasLength(3));
          } else {
            expect(slot.tower, isFalse);
            expect(slot.nests, hasLength(b.roles.empty.contains(i) ? 0 : 1));
          }
        }
        // Every segment is dealt exactly once.
        final dealt = [for (final s in plan.slots) ...s.nests];
        expect(dealt..sort(_byNest), expected..sort(_byNest));
      }
    });

    test('keeps at most ⌊towers/2⌋ mergeable tower tops when it can (A13)', () {
      var constrained = 0;
      for (var seed = 0; seed < 40; seed++) {
        final b = _board(
          seed,
          colors: 4,
          maxSize: 3,
          shelves: 2,
          slotsPerShelf: 4,
          towers: 3,
          towerDepth: 2,
          emptySlots: 1,
        );
        final plan = dealSegments(
          Prng(seed),
          b.segments,
          b.roles,
          b.lengths,
          2,
          3,
        );
        final count = mergeableTowerTops(plan, 3);
        expect(count, lessThanOrEqualTo(1), reason: 'seed $seed');
        if (count == 1) constrained++;
      }
      // The limit allows one, and some deals use it.
      expect(constrained, greaterThan(0));
    });

    test('keeps the best deal when no deal meets the limit', () {
      // One tower of depth 1 and one open nest: the two halves of a single
      // set always merge, so the limit (0) can't be met; the deal is kept.
      final segments = [_n(DollColor.red, 3), _n(DollColor.red, 2, 2)];
      const roles = (towers: [0], empty: <int>[], occupiedOpen: [1]);
      final plan = dealSegments(Prng(1), segments, roles, const [2], 1, 3);
      expect(mergeableTowerTops(plan, 3), 1);
      expect(plan.slots[0].tower, isTrue);
      expect(plan.slots[0].nests, hasLength(1));
      expect(plan.slots[1].nests, hasLength(1));
    });

    test('builds a level with the plan as slots, bottom shelf last', () {
      final plan = _plan(
        const [2, 1],
        [
          [_n(DollColor.red, 3)],
          [],
          [_n(DollColor.red, 2), _n(DollColor.blue, 3, 3)],
        ],
        {2},
      );
      plan.slots[0].unlockColor = DollColor.blue;
      plan.slots[2].ice = 2;
      final level = plan.toLevel(
        id: 'x',
        maxSize: 3,
        generatorVersion: 1,
        seed: 5,
      );
      expect(level.shelves, [
        [
          LockedSlot(unlockColor: DollColor.blue, nest: _n(DollColor.red, 3)),
          OpenSlot(),
        ],
        [
          TowerSlot([_n(DollColor.red, 2), _n(DollColor.blue, 3, 3)], ice: 2),
        ],
      ]);
      expect(level.generatorVersion, 1);
      expect(level.seed, 5);
    });
  });

  group('placeLocks', () {
    const colors = [DollColor.red, DollColor.blue, DollColor.green];

    BoardPlan openBoard(List<DollColor> sealed) => _plan(
      [sealed.length],
      [
        for (final color in sealed) [_n(color, 2)],
      ],
      const {},
    );

    test('locks the requested number of occupied open slots', () {
      for (var seed = 0; seed < 20; seed++) {
        final plan = openBoard(colors);
        expect(
          placeLocks(Prng(seed), plan, const [0, 1, 2], colors, 1, 2),
          isTrue,
        );
        expect(plan.slots.where((s) => s.unlockColor != null), hasLength(2));
      }
    });

    test('one set per color: never opens on the sealed color, no wait cycle '
        '(rule 6, design §3)', () {
      for (var seed = 0; seed < 60; seed++) {
        final plan = openBoard(const [
          DollColor.red,
          DollColor.blue,
          DollColor.green,
          DollColor.red,
        ]);
        placeLocks(Prng(seed), plan, const [0, 1, 2, 3], colors, 1, 3);
        final waits = <DollColor, Set<DollColor>>{};
        for (final slot in plan.slots) {
          final unlock = slot.unlockColor;
          if (unlock == null) continue;
          final sealed = slot.nests.single.color;
          expect(unlock, isNot(sealed));
          (waits[sealed] ??= {}).add(unlock);
        }
        // No color waits on itself through any chain of cases.
        for (final start in waits.keys) {
          final seen = <DollColor>{};
          final stack = [...waits[start]!];
          while (stack.isNotEmpty) {
            final color = stack.removeLast();
            expect(color, isNot(start), reason: 'seed $seed');
            if (seen.add(color)) stack.addAll(waits[color] ?? const {});
          }
        }
      }
    });

    test('fails when every arrangement would deadlock', () {
      // Two colors, one set each, every slot locked: some case seals red and
      // some seals blue, and each would have to open on the other.
      final plan = openBoard(const [
        DollColor.red,
        DollColor.blue,
        DollColor.red,
        DollColor.blue,
      ]);
      expect(
        placeLocks(
          Prng(3),
          plan,
          const [0, 1, 2, 3],
          const [DollColor.red, DollColor.blue],
          1,
          4,
        ),
        isFalse,
      );
    });

    test('several sets per color may open on the sealed color', () {
      var own = 0;
      for (var seed = 0; seed < 40; seed++) {
        final plan = openBoard(const [DollColor.red]);
        placeLocks(Prng(seed), plan, const [0], colors, 2, 1);
        if (plan.slots.single.unlockColor == DollColor.red) own++;
      }
      expect(own, greaterThan(0));
    });

    test('draws nothing with no locks', () {
      final a = Prng(11);
      final b = Prng(11);
      expect(
        placeLocks(a, openBoard(colors), const [0, 1, 2], colors, 1, 0),
        isTrue,
      );
      expect(a.nextU32(), b.nextU32());
    });
  });

  group('placeIce', () {
    test('ices occupied, unlocked slots with 1..min(3, sets − 1) (A12)', () {
      for (final sets in [2, 3, 4, 8]) {
        for (var seed = 0; seed < 20; seed++) {
          final plan = _plan(
            const [3, 3],
            [
              [_n(DollColor.red, 3)],
              [],
              [_n(DollColor.red, 2), _n(DollColor.blue, 3)],
              [_n(DollColor.red, 1)],
              [_n(DollColor.blue, 2, 2)],
              [_n(DollColor.pink, 2)],
            ],
            const {2},
          );
          plan.slots[3].unlockColor = DollColor.blue;
          placeIce(Prng(seed), plan, 3, sets);
          final iced = [
            for (var i = 0; i < 6; i++)
              if (plan.slots[i].ice > 0) i,
          ];
          expect(iced, hasLength(3));
          // Slot 1 is empty and slot 3 is a glass case.
          expect(iced, isNot(contains(1)));
          expect(iced, isNot(contains(3)));
          final maxIce = sets - 1 < 3 ? sets - 1 : 3;
          for (final i in iced) {
            expect(plan.slots[i].ice, inInclusiveRange(1, maxIce));
          }
        }
      }
    });

    test('reaches every counter over seeds', () {
      final seen = <int>{};
      for (var seed = 0; seed < 40; seed++) {
        final plan = _plan(
          const [2],
          [
            [_n(DollColor.red, 3)],
            [_n(DollColor.red, 2, 2)],
          ],
          const {},
        );
        placeIce(Prng(seed), plan, 1, 5);
        seen.add(plan.slots.map((s) => s.ice).reduce((a, b) => a + b));
      }
      expect(seen, {1, 2, 3});
    });
  });
}
