import 'dart:io';

import 'package:flutter/painting.dart' show Color;
import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_core/nesty_core.dart';
import 'package:nesty_render/nesty_render.dart';
import 'package:xml/xml.dart';

const _jsPath = '../../design/generator/nesty-doll.js';
const _renders = '../../design/skins/classic/renders';
const _classicSkin = '../../apps/game/assets/skins/classic/skin.svg';

void main() {
  // Spec §12.3, copied verbatim so a typo in the tokens fails here.
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

  group('DollPalette', () {
    test('has one swatch per DollColor, in enum order', () {
      expect(DollPalette.values, hasLength(DollColor.values.length));
      for (final color in DollColor.values) {
        expect(DollPalette.of(color).color, color);
        expect(identical(DollPalette.of(color), DollPalette.of(color)), isTrue);
      }
    });

    test('base, ink, light and symbol are the generated tokens', () {
      for (final color in DollColor.values) {
        final swatch = DollPalette.of(color);
        final token = DollColorTokens.of(color);
        expect(swatch.base, token.base, reason: color.id);
        expect(swatch.ink, token.ink, reason: color.id);
        expect(swatch.light, token.light, reason: color.id);
        expect(swatch.symbol, token.symbol, reason: color.id);
      }
    });

    test('the flat colours are the exact spec §12.3 hex', () {
      specHex.forEach((color, hex) {
        expect(hexOf(DollPalette.of(color).base), hex, reason: color.id);
      });
    });

    test('matches the design generator PRESETS (hand-tuned, not derived)', () {
      final js = File(_jsPath).readAsStringSync();
      final preset = RegExp(
        r"(\w+): \{ name: '[^']+', base: '(#[0-9A-F]{6})', ink: '(#[0-9A-F]{6})', "
        r"light: '(#[0-9A-F]{6})', symbol: '(\w+)'",
      );
      final found = {
        for (final m in preset.allMatches(js))
          m[1]!: (base: m[2]!, ink: m[3]!, light: m[4]!, symbol: m[5]!),
      };
      expect(found.keys.toSet(), DollColor.values.map((c) => c.id).toSet());
      for (final color in DollColor.values) {
        final swatch = DollPalette.of(color);
        final js = found[color.id]!;
        expect(hexOf(swatch.base), js.base, reason: color.id);
        expect(hexOf(swatch.ink), js.ink, reason: color.id);
        expect(hexOf(swatch.light), js.light, reason: color.id);
        expect(swatch.symbol, js.symbol, reason: color.id);
      }
    });

    test('flat colours modulate by their base; gold is the gradient map', () {
      for (final color in DollColor.values) {
        final swatch = DollPalette.of(color);
        if (color == DollColor.gold) {
          final tint = swatch.tint as GradientMapTint;
          expect(swatch.usesGradientMap, isTrue);
          expect(tint.inputExponent, 2);
          expect(
            [for (final s in tint.ramp) (s.position, hexOf(s.color))],
            const [
              (0.0, '#4A3008'),
              (0.3, '#7A5210'),
              (0.55, '#B07E1C'),
              (0.75, '#D9A634'),
              (0.9, '#F0C452'),
              (1.0, '#FFE89A'),
            ],
          );
        } else {
          expect(swatch.tint, ModulateTint(swatch.base), reason: color.id);
          expect(swatch.usesGradientMap, isFalse);
        }
      }
    });

    test("gold's base is a representative tone, not one of the ramp stops", () {
      final gold = DollPalette.of(DollColor.gold);
      final ramp = (gold.tint as GradientMapTint).ramp;
      expect(ramp.map((s) => s.color), isNot(contains(gold.base)));
    });

    test('rim colours equal the interior rim of the _open renders', () {
      final fill = RegExp(
        r'<g id="interior"><ellipse [^>]*fill="(#[0-9A-F]{6})"',
      );
      for (final color in DollColor.values) {
        final svg = File('$_renders/${color.id}_open.svg').readAsStringSync();
        final rim = fill.firstMatch(svg)![1];
        expect(hexOf(DollPalette.of(color).rimColor), rim, reason: color.id);
      }
      expect(DollPalette.woodRim, multiplyByGray(DollPalette.wood, 0xCF));
    });

    test('the wood silhouette tint is tokens woodSilhouette', () {
      expect(DollPalette.wood, SkinTokens.woodSilhouette);
      expect(DollPalette.woodTint, const ModulateTint(Color(0xFFE6C08C)));
    });
  });

  group('tint parity with the design renders', () {
    // Every gray the classic masks use, mapped by our tint, must equal the
    // colour nesty-doll.js baked into the matching reference render.
    final skin = XmlDocument.parse(File(_classicSkin).readAsStringSync());

    void expectParity(String render, DollTint tint) {
      final doc = XmlDocument.parse(
        File('$_renders/$render.svg').readAsStringSync(),
      );
      var checked = 0;
      for (final mask in SkinManifest.supportedTinted) {
        final ours = _group(skin, mask);
        final theirs = _group(doc, mask);
        final a = [ours, ...ours.descendantElements];
        final b = [theirs, ...theirs.descendantElements];
        expect(b, hasLength(a.length), reason: '$render $mask structure');
        for (var i = 0; i < a.length; i++) {
          for (final attr in const ['fill', 'stroke']) {
            final gray = grayLevelOf(a[i].getAttribute(attr) ?? '');
            if (gray == null) continue;
            expect(
              b[i].getAttribute(attr),
              hexOf(tint.mapGray(gray)),
              reason: '$render $mask <${a[i].name.local}> $attr',
            );
            checked++;
          }
          final ref = RegExp(
            r'url\(#(.+)\)',
          ).firstMatch(a[i].getAttribute('fill') ?? '');
          if (ref == null) continue;
          final stops = _stops(skin, ref[1]!);
          final tinted = _stops(doc, '${ref[1]}__tint');
          expect(tinted, hasLength(stops.length));
          for (var s = 0; s < stops.length; s++) {
            expect(
              tinted[s],
              hexOf(tint.mapGray(grayLevelOf(stops[s])!)),
              reason: '$render ${ref[1]} stop $s',
            );
            checked++;
          }
        }
      }
      expect(checked, greaterThan(15), reason: 'found the mask colours');
    }

    for (final color in DollColor.values) {
      test('${color.id}.svg', () {
        expectParity(color.id, DollPalette.of(color).tint);
      });
    }

    test(
      'silhouette.svg',
      () => expectParity('silhouette', DollPalette.woodTint),
    );
  });

  group('colour math', () {
    test('multiplyByGray rounds like the JS', () {
      expect(hexOf(multiplyByGray(const Color(0xFFE5484D), 0xF3)), '#DA4549');
      expect(
        multiplyByGray(const Color(0xFF123456), 255),
        const Color(0xFF123456),
      );
      expect(
        multiplyByGray(const Color(0xFF123456), 0),
        const Color(0xFF000000),
      );
    });

    test('rampColor hits every stop exactly and holds past the last', () {
      final ramp = DollColorTokens.gold.ramp;
      for (final stop in ramp) {
        expect(rampColor(ramp, stop.position), stop.color);
      }
      // Past the last stop: the last colour (the JS fall-through). Inputs
      // are gray² in 0–1, so nothing ever falls below the first stop.
      expect(rampColor(ramp, 2), ramp.last.color);
    });

    test('grayLevelOf accepts #rgb/#rrggbb grays only', () {
      expect(grayLevelOf('#FFFFFF'), 255);
      expect(grayLevelOf('#8e8e8e'), 0x8E);
      expect(grayLevelOf('#AAA'), 0xAA);
      expect(grayLevelOf('#FFF4E0'), isNull);
      expect(grayLevelOf('white'), isNull);
      expect(grayLevelOf('none'), isNull);
      expect(grayLevelOf('url(#a)'), isNull);
      expect(grayLevelOf(' #FFFFFF'), isNull);
    });
  });
}

XmlElement _group(XmlDocument doc, String id) =>
    doc.rootElement.childElements.firstWhere((e) => e.getAttribute('id') == id);

List<String> _stops(XmlDocument doc, String gradientId) => [
  for (final e in doc.rootElement.descendantElements)
    if (e.getAttribute('id') == gradientId)
      for (final stop in e.childElements) stop.getAttribute('stop-color')!,
];
