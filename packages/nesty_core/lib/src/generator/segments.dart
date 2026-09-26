/// Spec §6.5 step 1: the level's colors, its full sets, and the cut of each
/// set into consecutive segments (the nests the board starts with).
///
/// Every PRNG draw here is part of what `Generator.version` pins: the draw
/// order is documented on each function, and changing it changes generated
/// levels (spec §6.5, §7.5).
///
/// Internal to nesty_core (not exported by the barrel).
library;

import 'package:nesty_core/src/models/doll_color.dart';
import 'package:nesty_core/src/models/nest.dart';
import 'package:nesty_core/src/prng/prng.dart';

/// The 10 non-gold colors in `DollColor` order: the generator's palette
/// (design A11). Gold is v1.1 and never generated (spec §3.5, D22).
final List<DollColor> generatorPalette = List.unmodifiable([
  for (final color in DollColor.values)
    if (!color.isWild) color,
]);

/// [count] distinct colors from [generatorPalette], sorted by `DollColor`
/// index (design A11).
///
/// Draws: one full `Prng.shuffle` of a copy of the palette (9 draws); the
/// first [count] colors are kept. Sorting afterwards makes the set order,
/// and so every later draw, independent of where a color landed in the
/// shuffle.
List<DollColor> chooseColors(Prng prng, int count) {
  final pool = List.of(generatorPalette);
  prng.shuffle(pool);
  return pool.take(count).toList()..sort((a, b) => a.index - b.index);
}

/// How many segments each of [sets] full sets is cut into, so that they
/// total [segmentCount] (the nests the board holds).
///
/// Every set gets at least 2 segments, because a 1-segment set would start
/// as a full set, which §5.3 rule 3 forbids (design A10), and at most
/// [maxSize] (one per doll, spec §6.5 step 1). The remaining
/// `segmentCount − 2·sets` cuts are dealt one at a time: each draws
/// `Prng.pick` over the sets that still have room, in set order. The caller
/// guarantees `2·sets ≤ segmentCount ≤ maxSize·sets`
/// (`gen.segmentsInfeasible`).
List<int> dealSegmentCounts(
  Prng prng,
  int sets,
  int maxSize,
  int segmentCount,
) {
  final counts = List.filled(sets, 2);
  final room = <int>[];
  for (var extra = segmentCount - 2 * sets; extra > 0; extra--) {
    room.clear();
    for (var set = 0; set < sets; set++) {
      if (counts[set] < maxSize) room.add(set);
    }
    counts[prng.pick(room)]++;
  }
  return counts;
}

/// The segments of one full set of [color], `maxSize..1`, cut at
/// `segments − 1` distinct random boundaries (spec §6.5 step 1). The result
/// runs from the outer (largest) segment to the inner one.
///
/// A boundary `b` in `1..maxSize−1` falls between sizes `b + 1` and `b`.
/// Draws: a partial Fisher–Yates over the boundaries `[1, …, maxSize − 1]`,
/// one `nextInt(n − j)` for each of the first `segments − 1` positions `j`,
/// including a final `nextInt(1)` when every boundary is cut.
List<Nest> cutSet(Prng prng, DollColor color, int maxSize, int segments) {
  final boundaries = [for (var b = 1; b < maxSize; b++) b];
  final cuts = segments - 1;
  for (var j = 0; j < cuts; j++) {
    final r = j + prng.nextInt(boundaries.length - j);
    final swap = boundaries[j];
    boundaries[j] = boundaries[r];
    boundaries[r] = swap;
  }
  final chosen = boundaries.sublist(0, cuts)..sort((a, b) => b - a);
  final nests = <Nest>[];
  var outer = maxSize;
  for (final boundary in chosen) {
    nests.add(Nest.run(color, outer: outer, length: outer - boundary));
    outer = boundary;
  }
  nests.add(Nest.run(color, outer: outer, length: outer));
  return nests;
}

/// Spec §6.5 step 1 for a whole level: [colors] × [setsPerColor] full sets,
/// in color order, cut into exactly [segmentCount] segments.
///
/// Draws: [dealSegmentCounts], then [cutSet] for each set in order. The
/// segments come back set by set, each set outer to inner.
List<Nest> cutSets(
  Prng prng,
  List<DollColor> colors,
  int setsPerColor,
  int maxSize,
  int segmentCount,
) {
  final setColors = [
    for (final color in colors)
      for (var i = 0; i < setsPerColor; i++) color,
  ];
  final counts = dealSegmentCounts(
    prng,
    setColors.length,
    maxSize,
    segmentCount,
  );
  return [
    for (var set = 0; set < setColors.length; set++)
      ...cutSet(prng, setColors[set], maxSize, counts[set]),
  ];
}
