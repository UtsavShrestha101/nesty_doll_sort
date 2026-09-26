// Spec §2.1: "Nest: one or more dolls of the same color nested together.
// They are stored from the outer doll to the inner doll, and sizes must be
// consecutive and decreasing. Examples: [red4, red3] and [blue2] are valid.
// [red4, red2] is invalid." "Full set: a nest containing every size from
// maxSize down to 1."
import 'package:nesty_core/nesty_core.dart';
import 'package:test/test.dart';

void main() {
  group('Nest.run', () {
    test('[red4, red3]: outer 4, length 2, inner 3', () {
      final nest = Nest.run(DollColor.red, outer: 4, length: 2);
      expect(nest.color, DollColor.red);
      expect(nest.outerSize, 4);
      expect(nest.length, 2);
      expect(nest.innerSize, 3);
      expect(nest.outer, const Doll(DollColor.red, 4));
      expect(nest.inner, const Doll(DollColor.red, 3));
      expect(nest.dolls, const [
        Doll(DollColor.red, 4),
        Doll(DollColor.red, 3),
      ]);
    });

    test('[blue2]: a single doll is a nest (spec §2.1)', () {
      final nest = Nest.run(DollColor.blue, outer: 2, length: 1);
      expect(nest.outer, nest.inner);
      expect(nest.dolls, const [Doll(DollColor.blue, 2)]);
    });

    test('accepts every size 1..6 and every length down to size 1', () {
      for (var outer = 1; outer <= 6; outer++) {
        for (var length = 1; length <= outer; length++) {
          final nest = Nest.run(DollColor.teal, outer: outer, length: length);
          expect(nest.innerSize, outer - length + 1);
          expect(nest.dolls, hasLength(length));
        }
      }
    });

    for (final (outer, length) in [(0, 1), (7, 1), (3, 0), (3, 4), (1, 2)]) {
      test('rejects outer $outer, length $length with a RangeError', () {
        expect(
          () => Nest.run(DollColor.red, outer: outer, length: length),
          throwsRangeError,
        );
      });
    }
  });

  group('Nest.tryFromDolls', () {
    Nest? parse(List<(DollColor, int)> dolls) =>
        Nest.tryFromDolls([for (final (c, s) in dolls) Doll(c, s)]);

    test('builds the spec §2.1 valid examples', () {
      expect(
        parse([(DollColor.red, 4), (DollColor.red, 3)]),
        Nest.run(DollColor.red, outer: 4, length: 2),
      );
      expect(
        parse([(DollColor.blue, 2)]),
        Nest.run(DollColor.blue, outer: 2, length: 1),
      );
    });

    test('rejects [red4, red2]: sizes must be consecutive (spec §2.1)', () {
      expect(parse([(DollColor.red, 4), (DollColor.red, 2)]), isNull);
    });

    test('rejects an empty nest', () {
      expect(parse([]), isNull);
    });

    test('rejects mixed colors', () {
      expect(parse([(DollColor.red, 4), (DollColor.blue, 3)]), isNull);
    });

    test('rejects increasing or repeated sizes (outer to inner decreases)', () {
      expect(parse([(DollColor.red, 3), (DollColor.red, 4)]), isNull);
      expect(parse([(DollColor.red, 3), (DollColor.red, 3)]), isNull);
    });

    test('reads a nest down to size 1', () {
      final nest = parse([
        (DollColor.green, 3),
        (DollColor.green, 2),
        (DollColor.green, 1),
      ]);
      expect(nest, Nest.run(DollColor.green, outer: 3, length: 3));
    });

    test('gold alone is a nest; gold inside a color waits for v1.1', () {
      expect(
        parse([(DollColor.gold, 3)]),
        Nest.run(DollColor.gold, outer: 3, length: 1),
      );
      expect(parse([(DollColor.red, 4), (DollColor.gold, 3)]), isNull);
    });

    test('round-trips dolls for every nest', () {
      for (var outer = 1; outer <= 6; outer++) {
        for (var length = 1; length <= outer; length++) {
          final nest = Nest.run(DollColor.pink, outer: outer, length: length);
          expect(Nest.tryFromDolls(nest.dolls), nest);
        }
      }
    });
  });

  group('full sets (spec §2.1)', () {
    test('every size from maxSize down to 1 is a full set', () {
      expect(Nest.run(DollColor.red, outer: 3, length: 3).isFullSet(3), isTrue);
      expect(Nest.run(DollColor.red, outer: 6, length: 6).isFullSet(6), isTrue);
    });

    test('a run that stops above size 1 is not', () {
      expect(
        Nest.run(DollColor.red, outer: 4, length: 3).isFullSet(4),
        isFalse,
      );
    });

    test('a run that starts below maxSize is not', () {
      expect(
        Nest.run(DollColor.red, outer: 3, length: 3).isFullSet(4),
        isFalse,
      );
    });
  });

  test('containsSize is exactly the sizes inside (the pip bar, §10.3)', () {
    final nest = Nest.run(DollColor.red, outer: 5, length: 3); // 5, 4, 3
    expect(
      [for (var s = 1; s <= 6; s++) nest.containsSize(s)],
      [false, false, true, true, true, false],
    );
  });

  test('dolls is unmodifiable', () {
    final nest = Nest.run(DollColor.red, outer: 4, length: 2);
    expect(
      () => nest.dolls.add(const Doll(DollColor.red, 2)),
      throwsUnsupportedError,
    );
  });

  test('equality is by color, outer size and length', () {
    final a = Nest.run(DollColor.red, outer: 4, length: 2);
    expect(a, Nest.run(DollColor.red, outer: 4, length: 2));
    expect(a.hashCode, Nest.run(DollColor.red, outer: 4, length: 2).hashCode);
    expect(a, isNot(Nest.run(DollColor.red, outer: 4, length: 1)));
    expect(a, isNot(Nest.run(DollColor.red, outer: 3, length: 2)));
    expect(a, isNot(Nest.run(DollColor.blue, outer: 4, length: 2)));
  });

  test('toString is the level-JSON shape', () {
    expect(
      Nest.run(DollColor.red, outer: 4, length: 2).toString(),
      '[red4, red3]',
    );
  });
}
