import 'package:nesty_tools/src/tokens/css_values.dart';
import 'package:test/test.dart';

void main() {
  group('parseCssColor', () {
    test('parses #RRGGBB as opaque ARGB', () {
      expect(parseCssColor('#E5484D'), 0xFFE5484D);
      expect(parseCssColor('#fbe7c4'), 0xFFFBE7C4);
    });

    test('expands #RGB and reads #RRGGBBAA alpha last', () {
      expect(parseCssColor('#FA0'), 0xFFFFAA00);
      expect(parseCssColor('#11223380'), 0x80112233);
    });

    test('parses rgba() with alpha rounded to 8 bits', () {
      expect(parseCssColor('rgba(60,30,10,0.55)'), 0x8C3C1E0A);
      expect(parseCssColor('rgba(255, 255, 255, .22)'), 0x38FFFFFF);
      expect(parseCssColor('rgb(1,2,3)'), 0xFF010203);
    });

    for (final bad in [
      'red',
      '#12345',
      'rgba(1,2,3)',
      'rgb(1,2,3,0.5)',
      'rgba(256,0,0,1)',
      'rgba(0,0,0,1.5)',
      'hsl(0,0%,0%)',
    ]) {
      test('rejects "$bad"', () {
        expect(() => parseCssColor(bad), throwsFormatException);
      });
    }
  });

  group('parseGradientStop', () {
    test('an implicit stop', () {
      final stop = parseGradientStop('#F7A15E');
      expect(stop.color, 0xFFF7A15E);
      expect(stop.position, const ImplicitStop());
    });

    test('a percentage stop such as 60%', () {
      expect(
        parseGradientStop('#F2893B 60%').position,
        const FractionStop(0.6),
      );
      expect(parseGradientStop('#A56A34 100%').position, const FractionStop(1));
    });

    test('a pixel stop such as 14px', () {
      expect(parseGradientStop('#BD7B40 14px').position, const PxStop(14));
    });

    test('a unitless 0', () {
      expect(parseGradientStop('#D8995A 0').position, const FractionStop(0));
    });

    for (final bad in ['#D8995A 14', '#D8995A 120%', '#D8995A 1em', '']) {
      test('rejects "$bad"', () {
        expect(() => parseGradientStop(bad), throwsFormatException);
      });
    }
  });

  group('resolveStopPositions', () {
    test('spreads implicit stops like CSS', () {
      expect(
        resolveStopPositions(const [
          ImplicitStop(),
          FractionStop(0.5),
          ImplicitStop(),
        ]),
        const [FractionStop(0), FractionStop(0.5), FractionStop(1)],
      );
      expect(
        resolveStopPositions(const [
          ImplicitStop(),
          ImplicitStop(),
          ImplicitStop(),
          FractionStop(0.9),
        ]),
        const [
          FractionStop(0),
          FractionStop(0.3),
          FractionStop(0.6),
          FractionStop(0.9),
        ],
      );
    });

    test('keeps px stops as they are', () {
      expect(
        resolveStopPositions(const [
          FractionStop(0),
          PxStop(14),
          FractionStop(1),
        ]),
        const [FractionStop(0), PxStop(14), FractionStop(1)],
      );
    });

    test('cannot resolve an implicit stop next to a px stop', () {
      expect(
        () => resolveStopPositions(const [
          FractionStop(0),
          ImplicitStop(),
          PxStop(14),
          FractionStop(1),
        ]),
        throwsFormatException,
      );
    });

    test('needs two stops', () {
      expect(
        () => resolveStopPositions(const [ImplicitStop()]),
        throwsFormatException,
      );
    });
  });

  group('parseCubicBezier', () {
    test('parses integers and leading-dot decimals', () {
      expect(parseCubicBezier('cubic-bezier(0.34,1.56,0.64,1)'), [
        0.34,
        1.56,
        0.64,
        1,
      ]);
      expect(parseCubicBezier('cubic-bezier(.55, 0, 1, .45)'), [
        0.55,
        0,
        1,
        0.45,
      ]);
    });

    for (final bad in [
      'ease-in',
      'cubic-bezier(0,1,1)',
      'cubic-bezier(1.2,0,0.5,1)',
      'cubic-bezier(a,0,0,1)',
    ]) {
      test('rejects "$bad"', () {
        expect(() => parseCubicBezier(bad), throwsFormatException);
      });
    }
  });

  group('parseBoxShadowList', () {
    test('parses a list with inset, hex and rgba layers', () {
      final layers = parseBoxShadowList(
        'inset 0 2px 0 #FFFFFF, 0 5px 0 #D8B07A, 0 9px 14px rgba(90,50,20,0.22)',
      );
      expect(layers, hasLength(3));
      expect(layers[0], (
        inset: true,
        dx: 0.0,
        dy: 2.0,
        blur: 0.0,
        spread: 0.0,
        color: 0xFFFFFFFF,
      ));
      expect(layers[1].inset, isFalse);
      expect(layers[1].dy, 5);
      expect(layers[2], (
        inset: false,
        dx: 0.0,
        dy: 9.0,
        blur: 14.0,
        spread: 0.0,
        color: 0x385A3214,
      ));
    });

    test('parses negative offsets, a spread and color-first order', () {
      final layers = parseBoxShadowList(
        'rgba(60,25,5,0.30) 0 -10px 30px 2px, inset 0 2px 3px #000',
      );
      expect(layers[0].dy, -10);
      expect(layers[0].blur, 30);
      expect(layers[0].spread, 2);
      expect(layers[0].color, 0x4D3C1905);
      expect(layers[1].inset, isTrue);
      expect(layers[1].blur, 3);
    });

    for (final bad in [
      '0 2px 0',
      '0 #FFF 2px',
      '2px #FFF',
      '0 2em 0 #FFF',
      '0 2px -1px #FFF',
      'inset inset 0 2px #FFF',
      '0 2px #FFF,',
      '0 2px rgba(0,0,0,0.5',
    ]) {
      test('rejects "$bad"', () {
        expect(() => parseBoxShadowList(bad), throwsFormatException);
      });
    }
  });

  group('cssAngleToAlignment', () {
    test('180deg is top center to bottom center', () {
      final a = cssAngleToAlignment(180);
      expect([a.beginX, a.beginY, a.endX, a.endY], [0, -1, 0, 1]);
    });

    test('90deg is left to right', () {
      final a = cssAngleToAlignment(90);
      expect([a.beginX, a.beginY, a.endX, a.endY], [-1, 0, 1, 0]);
    });

    test('diagonals reach the corners of a square box', () {
      final a = cssAngleToAlignment(135);
      expect([a.beginX, a.beginY, a.endX, a.endY], [-1, -1, 1, 1]);
    });
  });

  test('farthestCornerRadius', () {
    expect(farthestCornerRadius(0.5, 0.5), closeTo(0.7071, 1e-4));
    expect(farthestCornerRadius(0.35, 0.3), closeTo(0.9552, 1e-4));
  });
}
