import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_core/nesty_core.dart';
import 'package:nesty_render/nesty_render.dart';

void main() {
  // Spec §12.3, copied verbatim so a typo in the palette fails here.
  const specHex = <DollColor, String>{
    DollColor.red: '#E5484D',
    DollColor.orange: '#F2893B',
    DollColor.yellow: '#F5C518',
    DollColor.green: '#46A758',
    DollColor.teal: '#12A594',
    DollColor.blue: '#3E8EDE',
    DollColor.purple: '#8E4EC6',
    DollColor.pink: '#E93D82',
    DollColor.navy: '#2F3E8F',
    DollColor.brown: '#A0673C',
  };

  int argb(String hex) => 0xFF000000 | int.parse(hex.substring(1), radix: 16);

  group('DollPalette', () {
    test('covers every DollColor with an opaque base color', () {
      for (final color in DollColor.values) {
        expect(DollPalette.of(color).base.a, 1.0, reason: color.id);
      }
    });

    test('uses the exact spec §12.3 hex for every flat color', () {
      expect(
        specHex.keys.toSet(),
        DollColor.values.toSet()..remove(DollColor.gold),
      );
      specHex.forEach((color, hex) {
        expect(
          DollPalette.of(color).base.toARGB32(),
          argb(hex),
          reason: '${color.id} should be $hex',
        );
      });
    });

    test('flat colors have no gradient', () {
      for (final color in specHex.keys) {
        expect(DollPalette.of(color).gradient, isNull, reason: color.id);
      }
    });

    test('gold is a gradient, as spec §12.3 says', () {
      final gold = DollPalette.of(DollColor.gold);
      expect(gold.gradient, isNotNull);
      expect(gold.gradient, hasLength(greaterThanOrEqualTo(2)));
      expect(gold.gradient, contains(gold.base));
    });

    test('flat colors are distinct', () {
      final values = specHex.keys.map((c) => DollPalette.of(c).base).toSet();
      expect(values, hasLength(specHex.length));
    });
  });
}
