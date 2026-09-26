import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_render/nesty_render.dart';
import 'package:nesty_render/svg_tools.dart';
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

String _asset(String id) =>
    File('../../apps/game/assets/skins/$id/skin.svg').readAsStringSync();

// The design export still carries the C2PA <metadata> the asset sync strips.
String _design(String id) =>
    File('../../design/skins/$id/$id.svg').readAsStringSync();

void main() {
  group('SkinSvgSplitter', () {
    final source = _asset('classic');
    final layers = SkinSvgSplitter.split(source);
    final original = XmlDocument.parse(source).rootElement;

    test('yields the eight spec §12.2 groups', () {
      expect(layers.groups.keys.toList(), skinGroupIds);
    });

    test('each layer is a valid standalone SVG on the artboard', () {
      for (final id in skinGroupIds) {
        final svg = layers[id];
        expect(validateSvg(svg), isEmpty, reason: id); // no dangling url(#…)
        final root = XmlDocument.parse(svg).rootElement;
        expect(root.getAttribute('viewBox'), '0 0 512 768', reason: id);
        expect(root.getAttribute('xmlns'), svgNamespaceUri, reason: id);
        // Sized by the viewBox, so flutter_svg reports the artboard.
        expect(root.getAttribute('width'), isNull, reason: id);
        expect(root.getAttribute('height'), isNull, reason: id);
      }
    });

    test('copies every <defs> into every layer', () {
      final defs = original.childElements
          .where((e) => e.name.local == 'defs')
          .map((e) => e.toXmlString())
          .toList();
      expect(defs, isNotEmpty);
      for (final id in skinGroupIds) {
        final root = XmlDocument.parse(layers[id]).rootElement;
        final copied = root.childElements
            .where((e) => e.name.local == 'defs')
            .map((e) => e.toXmlString())
            .toList();
        expect(copied, defs, reason: id);
      }
    });

    test('keeps each group verbatim, with its own clip-path', () {
      for (final id in skinGroupIds) {
        final group = original.childElements.firstWhere(
          (e) => e.getAttribute('id') == id,
        );
        final root = XmlDocument.parse(layers[id]).rootElement;
        final drawn = root.childElements
            .where((e) => e.name.local != 'defs')
            .toList();
        expect(drawn, hasLength(1), reason: id);
        expect(drawn.single.toXmlString(), group.toXmlString(), reason: id);
      }
      String? clip(String id) => XmlDocument.parse(layers[id])
          .rootElement
          .childElements
          .firstWhere((e) => e.name.local == 'g')
          .getAttribute('clip-path');
      expect(clip('bottom_detail'), 'url(#clip-bottom)');
      expect(clip('top_detail'), 'url(#clip-top)');
      expect(clip('face'), isNull);
    });

    test('strips the design export metadata', () {
      final raw = _design('classic');
      expect(raw, contains('<metadata>'));
      final split = SkinSvgSplitter.split(raw);
      for (final id in skinGroupIds) {
        expect(split[id], isNot(contains('metadata')), reason: id);
        expect(split[id], isNot(contains('c2pa')), reason: id);
        expect(split[id], layers[id], reason: id);
      }
    });

    for (final skin in _skins) {
      test('splits the bundled $skin skin', () {
        final split = SkinSvgSplitter.split(_asset(skin));
        expect(split.groups, hasLength(8));
        for (final id in skinGroupIds) {
          expect(validateSvg(split[id]), isEmpty, reason: '$skin/$id');
        }
      });
    }

    test('rejects an SVG that breaks spec §12.2, listing every issue', () {
      const bad =
          '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 100 100">'
          '<g id="shadow"><text>hi</text></g></svg>';
      expect(
        () => SkinSvgSplitter.split(bad),
        throwsA(
          isA<SkinSvgException>().having(
            (e) => e.issues.map((i) => i.code).toSet(),
            'codes',
            containsAll(['forbiddenElement', 'skinArtboard', 'skinGroups']),
          ),
        ),
      );
    });

    test('rejects malformed XML', () {
      expect(
        () => SkinSvgSplitter.split('<svg'),
        throwsA(isA<SkinSvgException>()),
      );
    });
  });

  test('the splitter stays pure Dart (package:xml + svg_tools only)', () {
    // The admin and Flutter-free tools split skins the same way (spec §12.2).
    final source = File(
      'lib/src/skin/svg/skin_svg_splitter.dart',
    ).readAsStringSync();
    final imports = RegExp(
      r'''^import\s+'([^']+)';''',
      multiLine: true,
    ).allMatches(source).map((m) => m[1]!).toList();
    expect(imports, isNotEmpty);
    for (final uri in imports) {
      expect(
        uri.startsWith('package:xml/') ||
            uri.startsWith('package:nesty_render/src/svg_tools/'),
        isTrue,
        reason: uri,
      );
    }
  });

  group('SkinLayers', () {
    test('requires every group', () {
      expect(() => SkinLayers({'shadow': '<svg/>'}), throwsArgumentError);
    });

    test('rejects an unknown group id', () {
      final layers = SkinSvgSplitter.split(_asset('classic'));
      expect(() => layers['hat'], throwsArgumentError);
    });

    test('is unmodifiable', () {
      final layers = SkinSvgSplitter.split(_asset('classic'));
      expect(() => layers.groups['shadow'] = '', throwsUnsupportedError);
    });
  });
}
