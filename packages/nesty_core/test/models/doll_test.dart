// Spec §2.1: "Doll: has a color (see §12.3) and a size from 1 (smallest) to
// maxSize (3–6, set per level)." Spec §5.1: "Dolls are written compactly as
// "<color><size>", for example "red4"."
import 'package:nesty_core/nesty_core.dart';
import 'package:test/test.dart';

void main() {
  group('Doll', () {
    test('holds its color and size', () {
      const doll = Doll(DollColor.red, 4);
      expect(doll.color, DollColor.red);
      expect(doll.size, 4);
    });

    test('token is the compact level-JSON form (spec §5.1)', () {
      expect(const Doll(DollColor.red, 4).token, 'red4');
      expect(const Doll(DollColor.navy, 1).token, 'navy1');
      expect(const Doll(DollColor.gold, 3).token, 'gold3');
    });

    test('toString is the token', () {
      expect(const Doll(DollColor.blue, 2).toString(), 'blue2');
    });

    test('sizes run from 1 to 6 (spec §2.1)', () {
      expect(Doll.minSize, 1);
      expect(Doll.maxSize, 6);
    });

    test('asserts the size range', () {
      expect(() => Doll(DollColor.red, 0), throwsA(isA<AssertionError>()));
      expect(() => Doll(DollColor.red, 7), throwsA(isA<AssertionError>()));
    }, testOn: 'vm');

    test('equality is by value', () {
      expect(
        const Doll(DollColor.red, 4),
        equals(Doll(DollColor.red, int.parse('4'))),
      );
      expect(
        const Doll(DollColor.red, 4).hashCode,
        Doll(DollColor.red, int.parse('4')).hashCode,
      );
      expect(
        const Doll(DollColor.red, 4),
        isNot(equals(const Doll(DollColor.red, 3))),
      );
      expect(
        const Doll(DollColor.red, 4),
        isNot(equals(const Doll(DollColor.blue, 4))),
      );
    });
  });
}
