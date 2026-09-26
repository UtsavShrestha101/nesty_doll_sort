// Spec §6.5 step 1: "Create the full sets. Split each set's run maxSize..1
// into 1–maxSize consecutive segments at random cut points." Design A10: at
// least 2 segments per set, since a 1-segment set would start as a full set
// (§5.3 rule 3). Design A11: colors are chosen by the PRNG from the 10
// non-gold colors.
import 'package:nesty_core/nesty_core.dart';
import 'package:nesty_core/src/generator/segments.dart';
import 'package:test/test.dart';

/// Every size of [nests], largest first, with repeats: the dolls they hold.
List<int> _sizes(Iterable<Nest> nests) =>
    [for (final nest in nests) ...nest.dolls.map((d) => d.size)]
      ..sort((a, b) => b - a);

void main() {
  group('generatorPalette', () {
    test('is the 10 non-gold colors in DollColor order (A11)', () {
      expect(generatorPalette, [
        for (final color in DollColor.values)
          if (color != DollColor.gold) color,
      ]);
      expect(generatorPalette, hasLength(10));
    });

    test('cannot be modified', () {
      expect(() => generatorPalette.add(DollColor.red), throwsUnsupportedError);
    });
  });

  group('chooseColors', () {
    test('returns count distinct palette colors in DollColor order', () {
      for (var count = 1; count <= 10; count++) {
        for (var seed = 0; seed < 20; seed++) {
          final colors = chooseColors(Prng(seed), count);
          expect(colors, hasLength(count));
          expect(colors.toSet(), hasLength(count));
          expect(colors.every(generatorPalette.contains), isTrue);
          expect(
            colors,
            orderedEquals(
              List<DollColor>.of(colors)..sort((a, b) => a.index - b.index),
            ),
          );
        }
      }
    });

    test('is deterministic for a seed', () {
      expect(chooseColors(Prng(42), 4), chooseColors(Prng(42), 4));
    });

    test('draws the same 9 values whatever the count', () {
      // One full shuffle of the palette, so the stream after it doesn't
      // depend on how many colors were kept.
      final a = Prng(7);
      final b = Prng(7);
      chooseColors(a, 1);
      chooseColors(b, 10);
      expect(a.nextU32(), b.nextU32());
    });

    test('reaches every color over seeds', () {
      final seen = <DollColor>{};
      for (var seed = 0; seed < 50; seed++) {
        seen.addAll(chooseColors(Prng(seed), 3));
      }
      expect(seen, generatorPalette.toSet());
    });
  });

  group('dealSegmentCounts', () {
    test('every set gets 2..maxSize segments, summing to the count', () {
      for (var maxSize = 3; maxSize <= 6; maxSize++) {
        for (var sets = 1; sets <= 6; sets++) {
          for (var count = 2 * sets; count <= maxSize * sets; count++) {
            final counts = dealSegmentCounts(Prng(count), sets, maxSize, count);
            expect(counts, hasLength(sets));
            expect(counts.fold(0, (a, b) => a + b), count);
            expect(counts.every((k) => k >= 2 && k <= maxSize), isTrue);
          }
        }
      }
    });

    test('the extremes need no choice: all 2, or all maxSize', () {
      expect(dealSegmentCounts(Prng(1), 4, 5, 8), [2, 2, 2, 2]);
      expect(dealSegmentCounts(Prng(1), 4, 5, 20), [5, 5, 5, 5]);
    });

    test('spreads the extra cuts over different sets', () {
      final seen = <String>{};
      for (var seed = 0; seed < 40; seed++) {
        seen.add(dealSegmentCounts(Prng(seed), 3, 4, 7).join(','));
      }
      expect(seen, containsAll(['3,2,2', '2,3,2', '2,2,3']));
    });
  });

  group('cutSet', () {
    test('cuts maxSize..1 into consecutive runs, outer to inner', () {
      for (var maxSize = 3; maxSize <= 6; maxSize++) {
        for (var segments = 2; segments <= maxSize; segments++) {
          for (var seed = 0; seed < 10; seed++) {
            final nests = cutSet(Prng(seed), DollColor.teal, maxSize, segments);
            expect(nests, hasLength(segments));
            expect(nests.every((n) => n.color == DollColor.teal), isTrue);
            expect(nests.first.outerSize, maxSize);
            expect(nests.last.innerSize, 1);
            for (var i = 1; i < nests.length; i++) {
              expect(nests[i].outerSize, nests[i - 1].innerSize - 1);
            }
            expect(nests.any((n) => n.isFullSet(maxSize)), isFalse);
          }
        }
      }
    });

    test('maxSize segments are the single dolls', () {
      expect(cutSet(Prng(3), DollColor.red, 4, 4), [
        for (var size = 4; size >= 1; size--)
          Nest.run(DollColor.red, outer: size, length: 1),
      ]);
    });

    test('reaches every cut point over seeds', () {
      final seen = <int>{};
      for (var seed = 0; seed < 40; seed++) {
        seen.add(cutSet(Prng(seed), DollColor.red, 5, 2).first.innerSize);
      }
      // The first segment ends at size 5, 4, 3 or 2.
      expect(seen, {2, 3, 4, 5});
    });
  });

  group('cutSets', () {
    test('holds setsPerColor full sets of every color, set by set', () {
      final colors = [DollColor.red, DollColor.blue, DollColor.pink];
      final segments = cutSets(Prng(9), colors, 2, 4, 17);
      expect(segments, hasLength(17));
      for (final color in colors) {
        expect(_sizes(segments.where((n) => n.color == color)), [
          4,
          4,
          3,
          3,
          2,
          2,
          1,
          1,
        ]);
      }
      // Set order follows the colors: every red set comes before blue.
      final firstBlue = segments.indexWhere((n) => n.color == DollColor.blue);
      expect(
        segments.skip(firstBlue).any((n) => n.color == DollColor.red),
        isFalse,
      );
    });

    test('is deterministic for a seed', () {
      final colors = [DollColor.green, DollColor.navy];
      expect(
        cutSets(Prng(5), colors, 1, 5, 7),
        cutSets(Prng(5), colors, 1, 5, 7),
      );
    });
  });
}
