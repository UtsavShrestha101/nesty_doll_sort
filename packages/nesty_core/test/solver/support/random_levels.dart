// Small random boards for property tests of the solver against the
// exhaustive oracle (solver_oracle.dart): maxSize 3, two or three colors,
// each set cut into consecutive segments, dealt into open slots and depth-2
// towers with one or two empty slots, and sometimes a glass case or ice.
//
// They are not meant to be good levels, only varied, small enough for a
// breadth-first search, and deterministic: the core PRNG makes the same
// boards on every platform (spec §6.5).
library;

import 'package:nesty_core/nesty_core.dart';

/// The random board for [seed].
Level randomLevel(int seed) {
  final prng = Prng(seed);
  const maxSize = 3;
  final colors = [...DollColor.values.where((c) => !c.isWild)];
  prng.shuffle(colors);
  final used = colors.take(2 + prng.nextInt(2)).toList();

  final segments = <Nest>[];
  for (final color in used) {
    // Cut the run 3..1 at each of its two boundaries with probability 1/2.
    var outer = maxSize;
    var length = 1;
    for (var size = maxSize - 1; size >= 1; size--) {
      if (prng.nextBool()) {
        segments.add(Nest.run(color, outer: outer, length: length));
        outer = size;
        length = 1;
      } else {
        length++;
      }
    }
    segments.add(Nest.run(color, outer: outer, length: length));
  }
  prng.shuffle(segments);

  final slots = <Slot>[];
  var next = 0;
  final towers = prng.nextInt(2);
  for (var t = 0; t < towers && next + 1 < segments.length; t++) {
    slots.add(TowerSlot([segments[next], segments[next + 1]]));
    next += 2;
  }
  for (; next < segments.length; next++) {
    slots.add(OpenSlot(nest: segments[next]));
  }
  for (var e = 1 + prng.nextInt(2); e > 0; e--) {
    slots.add(OpenSlot());
  }

  // Sometimes seal one occupied open slot behind glass, or freeze one.
  final occupied = [
    for (var i = 0; i < slots.length; i++)
      if (slots[i] case OpenSlot(:final nest?)) (i, nest),
  ];
  if (occupied.isNotEmpty && prng.nextInt(4) == 0) {
    final (i, nest) = prng.pick(occupied);
    final others = used.where((c) => c != nest.color).toList();
    slots[i] = LockedSlot(unlockColor: prng.pick(others), nest: nest);
  } else if (occupied.isNotEmpty && prng.nextInt(4) == 0) {
    final (i, nest) = prng.pick(occupied);
    slots[i] = OpenSlot(nest: nest, ice: 1);
  }

  prng.shuffle(slots);
  return Level(
    id: 'random_$seed',
    maxSize: maxSize,
    shelves: [
      for (var start = 0; start < slots.length; start += 4)
        slots.sublist(
          start,
          start + 4 < slots.length ? start + 4 : slots.length,
        ),
    ],
  );
}
