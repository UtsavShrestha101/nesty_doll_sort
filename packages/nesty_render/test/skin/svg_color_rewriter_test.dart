import 'dart:io';

import 'package:flutter/painting.dart' show Color;
import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_core/nesty_core.dart';
import 'package:nesty_render/nesty_render.dart';
import 'package:xml/xml.dart';

const _skins = [
  'classic',
  'forest',
  'forest-bear',
  'ocean',
  'space',
  'sweets',
  'winter',
];

SkinLayers _layers(String id) => SkinSvgSplitter.split(
  File('../../apps/game/assets/skins/$id/skin.svg').readAsStringSync(),
);

Color _gold(int gray) => DollPalette.of(DollColor.gold).tint.mapGray(gray);

void main() {
  group('gold ramp: known grays vs design/generator/nesty-doll.js', () {
    // Read off renders/gold.svg, which the JS generator wrote: every gray
    // the classic masks use and the colour the ramp turned it into.
    const expected = {
      0xFF: '#FFE89A',
      0xF3: '#F1C758',
      0xD0: '#C8952A',
      0xA6: '#956816',
      0x8E: '#7C5410',
      0x8A: '#795110',
      0xB8: '#AA791B',
      0xE2: '#DEAD3B',
      0xC2: '#B6841F',
      0xF2: '#F0C452',
    };
    expected.forEach((gray, hex) {
      test('#${gray.toRadixString(16).toUpperCase() * 3} → $hex', () {
        expect(hexOf(_gold(gray)), hex);
      });
    });

    test('every value in renders/gold.svg is reproduced', () {
      final render = File(
        '../../design/skins/classic/renders/gold.svg',
      ).readAsStringSync();
      final rewritten = XmlDocument.parse(
        SvgColorRewriter.rewriteGrays(_layers('classic')['bottom_mask'], _gold),
      );
      final stops = {
        for (final g in rewritten.rootElement.descendantElements)
          if (g.getAttribute('id') == 'bm-shade')
            for (final s in g.childElements) s.getAttribute('stop-color'),
      };
      for (final stop in stops) {
        expect(render, contains('stop-color="$stop"'));
      }
    });
  });

  group('SvgColorRewriter.rewriteGrays', () {
    const svg =
        '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 512 768">'
        '<defs>'
        '<linearGradient id="used"><stop offset="0" stop-color="#808080"/>'
        '<stop offset="1" stop-color="#FF0000"/></linearGradient>'
        '<linearGradient id="unused"><stop offset="0" stop-color="#808080"/>'
        '</linearGradient>'
        '<linearGradient id="child" href="#parent"/>'
        '<radialGradient id="parent"><stop offset="0" stop-color="#FFF"/>'
        '</radialGradient>'
        '</defs>'
        '<g id="bottom_mask">'
        '<rect fill="#404040" stroke="#FFF4E0"/>'
        '<rect fill="url(#used)" stroke="none"/>'
        '<circle fill="url(#child)" stroke="#999" opacity=".5"/>'
        '<path fill="currentColor"/>'
        '</g></svg>';

    String mapped(int g) => hexOf(Color.fromARGB(255, g, 0, 0));
    final out = XmlDocument.parse(
      SvgColorRewriter.rewriteGrays(svg, (g) => Color.fromARGB(255, g, 0, 0)),
    );
    XmlElement byId(String id) => out.rootElement.descendantElements.firstWhere(
      (e) => e.getAttribute('id') == id,
    );
    List<XmlElement> shapes() => out.rootElement.descendantElements
        .where((e) => const {'rect', 'circle', 'path'}.contains(e.name.local))
        .toList();

    test('rewrites gray fills and strokes of the drawn content', () {
      expect(shapes()[0].getAttribute('fill'), mapped(0x40));
      expect(shapes()[2].getAttribute('stroke'), mapped(0x99));
    });

    test('leaves non-gray, none, currentColor and opacity alone', () {
      expect(shapes()[0].getAttribute('stroke'), '#FFF4E0');
      expect(shapes()[1].getAttribute('stroke'), 'none');
      expect(shapes()[2].getAttribute('opacity'), '.5');
      expect(shapes()[3].getAttribute('fill'), 'currentColor');
    });

    test('rewrites the gray stops of referenced gradients only', () {
      final used = byId('used').childElements.toList();
      expect(used[0].getAttribute('stop-color'), mapped(0x80));
      expect(used[1].getAttribute('stop-color'), '#FF0000');
      expect(
        byId('unused').childElements.single.getAttribute('stop-color'),
        '#808080',
      );
    });

    test('follows href to the stops a gradient inherits', () {
      expect(
        byId('parent').childElements.single.getAttribute('stop-color'),
        mapped(0xFF),
      );
    });

    test('an identity map changes no colour', () {
      final layer = _layers('classic')['top_mask'];
      final same = SvgColorRewriter.rewriteGrays(
        layer,
        (g) => Color.fromARGB(255, g, g, g),
      );
      expect(SvgColorRewriter.nonGrayColors(same), isEmpty);
      expect(
        XmlDocument.parse(same).toXmlString(),
        XmlDocument.parse(
          layer.replaceAllMapped(
            RegExp(r'#([0-9A-Fa-f]{6})\b'),
            (m) => '#${m[1]!.toUpperCase()}',
          ),
        ).toXmlString(),
      );
    });
  });

  group('SvgColorRewriter.nonGrayColors', () {
    for (final skin in _skins) {
      test('the $skin masks are pure grayscale (modulate == the JS tint)', () {
        final layers = _layers(skin);
        for (final mask in SkinManifest.supportedTinted) {
          expect(
            SvgColorRewriter.nonGrayColors(layers[mask]),
            isEmpty,
            reason: '$skin/$mask',
          );
        }
      });
    }

    test('finds colour in a detail layer', () {
      expect(
        SvgColorRewriter.nonGrayColors(_layers('classic')['bottom_detail']),
        contains('#E8B94A'),
      );
    });
  });
}
