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

    test('reads the one CSS name the design writes, white (tokens v3)', () {
      expect(parseCssColor('white'), 0xFFFFFFFF);
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

  group('tokens v3 shapes', () {
    test('parseCssLinearGradient: angle and stops, rgba commas and all', () {
      final versus = parseCssLinearGradient(
        'linear-gradient(180deg, #7B8BEF, #4E5FD9)',
      );
      expect(versus.angle, 180);
      expect([for (final s in versus.stops) s.color], [0xFF7B8BEF, 0xFF4E5FD9]);
      final scrim = parseCssLinearGradient(
        'linear-gradient(180deg,rgba(20,40,70,0) 25%,rgba(20,40,70,.62))',
      );
      expect(scrim.stops.first.color, 0x00142846);
      expect(scrim.stops.first.position, const FractionStop(0.25));
      expect(scrim.stops.last.color, 0x9E142846);
      for (final bad in [
        'linear-gradient(to bottom, #000, #fff)',
        'linear-gradient(180deg, #000)',
        'radial-gradient(#000, #fff)',
      ]) {
        expect(() => parseCssLinearGradient(bad), throwsFormatException);
        expect(isCssLinearGradient(bad), isFalse);
      }
    });

    test('tryParseFontSpec: family, weight, size, colour, tabular, tail', () {
      final name = tryParseFontSpec('Fredoka 700 16 #5B3A21')!;
      expect(
        (name.family, name.weight, name.size, name.color, name.tabular),
        ('Fredoka', 700, 16.0, 0xFF5B3A21, false),
      );
      expect(name.tail, isNull);
      expect(tryParseFontSpec('Nunito 800 9.5')!.size, 9.5);
      expect(tryParseFontSpec('Nunito 800 9.5')!.color, isNull);
      expect(
        tryParseFontSpec('Fredoka 700 17 #3242A8 tabular')!.tabular,
        isTrue,
      );
      expect(tryParseFontSpec('Fredoka 700 21 white')!.color, 0xFFFFFFFF);
      expect(
        tryParseFontSpec('Nunito 800 11 #6E4526, sentence case')!.tail,
        'sentence case',
      );
      expect(
        tryParseFontSpec('Fredoka 700 11.5 #4A3008 on a brass gradient')!.tail,
        'on a brass gradient',
      );
      expect(
        tryParseFontSpec('Nunito 700 12 #8A5B3A; thinking = three dots')!.tail,
        'thinking = three dots',
      );
      for (final notFont in [
        'Roboto 700 16',
        'Fredoka bold 16',
        'Fredoka 700',
        '#5B3A21',
        'gradient.success, Fredoka 700 12',
      ]) {
        expect(tryParseFontSpec(notFont), isNull, reason: notFont);
      }
    });

    test('tryParseStroke: <n>px <color>', () {
      expect(tryParseStroke('2px #FFFDF7'), (width: 2.0, color: 0xFFFFFDF7));
      expect(tryParseStroke('1.5px #D8B07A')!.width, 1.5);
      expect(tryParseStroke('4px rgba(242,137,59,.28)')!.color, 0x47F2893B);
      for (final notStroke in [
        '2 #FFF',
        '2px',
        '3px chapter accentTop',
        '0 2px 0 #FFF',
        'inset 1.5px #F2C230',
      ]) {
        expect(tryParseStroke(notStroke), isNull, reason: notStroke);
      }
    });

    test('parseConicRays: one lit wedge per period, fading to clear', () {
      final rays = parseConicRays(
        'repeating-conic-gradient(rgba(255,200,90,.55) 0deg 9deg, '
        'rgba(255,200,90,0) 9deg 24deg)',
      );
      expect(rays, (color: 0x8CFFC85A, litDeg: 9.0, periodDeg: 24.0));
      for (final bad in [
        // The clear stop is another colour.
        'repeating-conic-gradient(rgba(255,200,90,.55) 0deg 9deg, '
            'rgba(0,0,0,0) 9deg 24deg)',
        // It doesn't start where the ray ends.
        'repeating-conic-gradient(rgba(255,200,90,.55) 0deg 9deg, '
            'rgba(255,200,90,0) 10deg 24deg)',
        // 25° doesn't divide the circle.
        'repeating-conic-gradient(rgba(255,200,90,.55) 0deg 9deg, '
            'rgba(255,200,90,0) 9deg 25deg)',
        'conic-gradient(#fff, #000)',
      ]) {
        expect(() => parseConicRays(bad), throwsFormatException, reason: bad);
      }
    });
  });
}
