import 'dart:convert';
import 'dart:io';
import 'dart:ui' show Offset, Size;

import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_render/nesty_render.dart';
import 'package:nesty_render/svg_tools.dart';

const _skins = [
  'classic',
  'forest',
  'forest-bear',
  'ocean',
  'space',
  'sweets',
  'winter',
];

String _json(String id) =>
    File('../../apps/game/assets/skins/$id/skin.json').readAsStringSync();

Matcher _throwsCodes(List<String> codes) => throwsA(
  isA<SkinManifestException>().having(
    (e) => e.issues.map((i) => i.code).toList(),
    'codes',
    containsAll(codes),
  ),
);

void main() {
  group('SkinManifest', () {
    for (final id in _skins) {
      test('parses the bundled $id skin.json', () {
        final m = SkinManifest.parse(_json(id), expectedSkinId: id);
        expect(m.skinId, id);
        expect(m.version, 1);
        expect(m.groups, skinGroupIds);
        expect(m.tinted, SkinManifest.supportedTinted);
        expect(m.lidGroups, SkinManifest.supportedLidGroups);
        // Every shipped skin matches the design tokens.
        expect(m.splitY, SkinTokens.splitY);
        expect(m.lidLiftPx, SkinTokens.lidLiftPx);
        expect(m.symbolAnchor, SkinTokens.symbolAnchor);
        expect(m.symbolSize, SkinTokens.symbolSize);
        expect(m.artboard, SkinTokens.artboard);
      });
    }

    test('reads the classic values', () {
      final m = SkinManifest.parse(_json('classic'), expectedSkinId: 'classic');
      expect(m.name, 'Classic');
      expect(m.cacheKey, 'classic@1');
      expect(m.openLidLift, 120 / 768);
    });

    test('the spec §12.2 minimal sidecar gets the token defaults', () {
      final m = SkinManifest.fromJson({
        'skinId': 'plain',
        'splitY': 380,
        'lidLiftPx': 100,
        'symbolAnchor': [250, 600],
        'symbolSize': 96,
        'version': 3,
      });
      expect(m.name, isNull);
      expect(m.splitY, 380);
      expect(m.lidLiftPx, 100);
      expect(m.symbolAnchor, const Offset(250, 600));
      expect(m.symbolSize, 96);
      expect(m.artboard, const Size(512, 768));
      expect(m.groups, skinGroupIds);
      expect(m.tinted, SkinManifest.supportedTinted);
      expect(m.lidGroups, SkinManifest.supportedLidGroups);
      expect(m.cacheKey, 'plain@3');
    });

    test('has value equality', () {
      final a = SkinManifest.parse(_json('classic'));
      final b = SkinManifest.parse(_json('classic'));
      expect(a, b);
      expect(a.hashCode, b.hashCode);
      expect(a, isNot(SkinManifest.parse(_json('ocean'))));
    });

    test('reports the validator issues', () {
      final json = jsonDecode(_json('classic')) as Map<String, Object?>
        ..remove('version')
        ..['splitY'] = 900
        ..['extra'] = true;
      expect(
        () => SkinManifest.fromJson(json),
        _throwsCodes([
          'manifestMissingKey',
          'manifestBadValue',
          'manifestUnknownKey',
        ]),
      );
    });

    test('requires the folder name as the skin id', () {
      expect(
        () => SkinManifest.parse(_json('classic'), expectedSkinId: 'ocean'),
        _throwsCodes(['manifestBadValue']),
      );
    });

    test('rejects a layer plan the renderer cannot draw', () {
      final json = jsonDecode(_json('classic')) as Map<String, Object?>
        ..['tinted'] = ['bottom_mask', 'top_mask', 'face'];
      expect(
        () => SkinManifest.fromJson(json),
        _throwsCodes(['manifestUnsupportedLayers']),
      );
      final lid = jsonDecode(_json('classic')) as Map<String, Object?>
        ..['lidGroups'] = ['top_mask', 'face'];
      expect(
        () => SkinManifest.fromJson(lid),
        _throwsCodes(['manifestUnsupportedLayers']),
      );
    });

    test('accepts the supported plan in any order', () {
      final json = jsonDecode(_json('classic')) as Map<String, Object?>
        ..['tinted'] = ['top_mask', 'bottom_mask'];
      expect(SkinManifest.fromJson(json).tinted, ['top_mask', 'bottom_mask']);
    });

    test('rejects malformed JSON and non-objects', () {
      expect(() => SkinManifest.parse('{'), _throwsCodes(['manifestNotJson']));
      expect(
        () => SkinManifest.parse('[]'),
        _throwsCodes(['manifestNotObject']),
      );
    });
  });
}
