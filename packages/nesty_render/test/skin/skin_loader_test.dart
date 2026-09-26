import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_render/nesty_render.dart';
import 'package:nesty_render/svg_tools.dart';

import '../doll/support/render_test_support.dart';

const _skins = [
  'classic',
  'forest',
  'forest-bear',
  'ocean',
  'space',
  'sweets',
  'winter',
];

/// Serves fixed strings, recording the keys asked for.
final class _MapBundle extends CachingAssetBundle {
  _MapBundle(this.files);

  final Map<String, String> files;
  final requested = <String>[];

  @override
  Future<ByteData> load(String key) async {
    requested.add(key);
    final text = files[key];
    if (text == null) throw FlutterError('Unable to load asset: "$key".');
    return ByteData.sublistView(Uint8List.fromList(text.codeUnits));
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AssetBundleSkinLoader', () {
    final loader = AssetBundleSkinLoader(bundle: FileAssetBundle());

    test('uses the game asset layout by default', () {
      expect(loader.svgKey('classic'), 'assets/skins/classic/skin.svg');
      expect(loader.manifestKey('classic'), 'assets/skins/classic/skin.json');
    });

    for (final id in _skins) {
      test('loads and splits the bundled $id skin', () async {
        final skin = await loader.load(id);
        expect(skin.manifest.skinId, id);
        expect(skin.layers.groups.keys, skinGroupIds);
      });
    }

    test('reads from a custom base path (the admin can reuse it)', () async {
      final bundle = _MapBundle({
        'web/skins/classic/skin.json':
            '{"skinId":"classic","splitY":400,"lidLiftPx":120,'
            '"symbolAnchor":[256,590],"symbolSize":110,"version":2}',
        'web/skins/classic/skin.svg': File(
          '$gameAssetsDir/skins/classic/skin.svg',
        ).readAsStringSync(),
      });
      final skin = await AssetBundleSkinLoader(
        bundle: bundle,
        basePath: 'web/skins',
      ).load('classic');
      expect(skin.manifest.version, 2);
      expect(
        bundle.requested,
        containsAll([
          'web/skins/classic/skin.json',
          'web/skins/classic/skin.svg',
        ]),
      );
    });

    test('a missing skin is a SkinLoadException', () {
      expect(
        loader.load('no-such-skin'),
        throwsA(
          isA<SkinLoadException>().having(
            (e) => e.skinId,
            'id',
            'no-such-skin',
          ),
        ),
      );
    });

    test('an id that is not kebab-case never reaches the bundle', () async {
      final bundle = _MapBundle({});
      final strict = AssetBundleSkinLoader(bundle: bundle);
      for (final id in ['../classic', 'Classic', 'a/b', '']) {
        await expectLater(strict.load(id), throwsA(isA<SkinLoadException>()));
      }
      expect(bundle.requested, isEmpty);
    });

    test(
      'an invalid manifest or SVG is a SkinLoadException with the cause',
      () async {
        final bundle = _MapBundle({
          'assets/skins/bad/skin.json': '{"skinId":"bad"}',
          'assets/skins/bad/skin.svg': '<svg/>',
        });
        await expectLater(
          AssetBundleSkinLoader(bundle: bundle).load('bad'),
          throwsA(
            isA<SkinLoadException>().having(
              (e) => e.cause,
              'cause',
              isA<SkinManifestException>(),
            ),
          ),
        );
      },
    );
  });
}
