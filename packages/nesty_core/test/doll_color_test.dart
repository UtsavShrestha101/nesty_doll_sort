import 'package:nesty_core/nesty_core.dart';
import 'package:test/test.dart';

void main() {
  group('DollColor', () {
    test('has exactly the spec §12.3 colors, in table order', () {
      expect(DollColor.values.map((c) => c.id), [
        'red',
        'orange',
        'yellow',
        'green',
        'teal',
        'blue',
        'purple',
        'pink',
        'navy',
        'brown',
        'gold',
      ]);
    });

    test('ids are unique lowercase letters, so "red4" splits at the digit', () {
      final ids = DollColor.values.map((c) => c.id).toList();
      expect(ids.toSet(), hasLength(ids.length));
      for (final id in ids) {
        expect(id, matches(RegExp(r'^[a-z]+$')), reason: id);
      }
    });

    test('only gold is wild (spec §3.5)', () {
      expect(DollColor.values.where((c) => c.isWild), [DollColor.gold]);
    });

    group('fromId', () {
      test('round-trips every id', () {
        for (final color in DollColor.values) {
          expect(DollColor.fromId(color.id), same(color));
        }
      });

      for (final bad in ['', 'Red', 'RED', ' red', 'red ', 'red4', 'grey']) {
        test('rejects "$bad" with a FormatException', () {
          expect(
            () => DollColor.fromId(bad),
            throwsA(
              isA<FormatException>()
                  .having((e) => e.message, 'message', contains('"$bad"'))
                  .having((e) => e.source, 'source', bad),
            ),
          );
        });
      }

      test('lists the valid ids in the error message', () {
        expect(
          () => DollColor.fromId('grey'),
          throwsA(
            isA<FormatException>().having(
              (e) => e.message,
              'message',
              contains(
                'red, orange, yellow, green, teal, blue, purple, pink, '
                'navy, brown, gold',
              ),
            ),
          ),
        );
      });
    });
  });
}
