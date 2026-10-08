import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:nesty_tools/src/assets/design_asset_sync.dart';
import 'package:nesty_tools/src/assets/widget_native_art.dart';
import 'package:nesty_tools/src/repo_root.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';
import 'package:xml/xml.dart';

const _ns = 'xmlns="http://www.w3.org/2000/svg"';

String _svg(String body, {String box = '0 0 48 48'}) =>
    '<svg $_ns viewBox="$box">$body</svg>';

/// A PNG with a `caBX` chunk between IHDR and IDAT, as the design export
/// writes them. The chunk CRCs are not checked by the stripper.
Uint8List _png({bool withManifest = true}) {
  List<int> chunk(String type, List<int> data) {
    final length = ByteData(4)..setUint32(0, data.length);
    return [
      ...length.buffer.asUint8List(),
      ...type.codeUnits,
      ...data,
      0, 0, 0, 0, // crc (not checked)
    ];
  }

  return Uint8List.fromList([
    0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, //
    ...chunk('IHDR', List.filled(13, 1)),
    if (withManifest) ...chunk('caBX', 'c2pa manifest'.codeUnits),
    ...chunk('IDAT', [1, 2, 3]),
    ...chunk('IEND', const []),
  ]);
}

void main() {
  final root = findRepoRoot();
  final tokens =
      jsonDecode(
            File(p.join(root.path, 'design/tokens.json')).readAsStringSync(),
          )
          as Map<String, Object?>;

  group('stripPngMetadata', () {
    test('drops the C2PA chunk and keeps every other byte', () {
      final stripped = stripPngMetadata(_png());
      expect(stripped, _png(withManifest: false));
      expect(String.fromCharCodes(stripped), isNot(contains('c2pa')));
    });

    test('is idempotent', () {
      final once = stripPngMetadata(_png());
      expect(stripPngMetadata(once), once);
    });

    test('refuses what is not a PNG, or is cut short', () {
      expect(() => stripPngMetadata([1, 2, 3]), throwsFormatException);
      expect(
        () => stripPngMetadata(_png().sublist(0, 30)),
        throwsFormatException,
      );
    });
  });

  group('widgetVectorOf', () {
    WidgetVector convert(String body, {String box = '0 0 48 48'}) =>
        widgetVectorOf(
          _svg(body, box: box),
          source: 'design/ui/widget/x.svg',
          widthDp: 44,
          heightDp: 44,
        );

    test('writes one path per shape, with ARGB colours', () {
      final vector = convert(
        '<path d="M0 0H4V4Z" fill="#F2702B" fill-rule="evenodd"/>'
        '<path d="M1 1H2V2Z" fill="#FFF"/>',
      );
      expect(vector.issues, isEmpty);
      final xml = XmlDocument.parse(vector.xml!);
      final vectorElement = xml.rootElement;
      expect(vectorElement.getAttribute('android:width'), '44dp');
      expect(vectorElement.getAttribute('android:viewportWidth'), '48');
      final paths = vectorElement.childElements.toList();
      expect(paths, hasLength(2));
      expect(paths[0].getAttribute('android:fillColor'), '#FFF2702B');
      expect(paths[0].getAttribute('android:fillType'), 'evenOdd');
      expect(paths[1].getAttribute('android:fillColor'), '#FFFFFFFF');
      expect(paths[1].getAttribute('android:fillType'), isNull);
    });

    test('turns an ellipse, a circle and a rounded rect into arcs', () {
      final vector = convert(
        '<ellipse cx="24.2" cy="35.6" rx="4.1" ry="5" fill="#FFF1DE"/>'
        '<circle cx="10" cy="10" r="2" fill="#000000"/>'
        '<rect x="2" y="5" width="44" height="41" rx="13" fill="#C9960A"/>'
        '<rect x="0" y="0" width="4" height="4" fill="#C9960A"/>',
      );
      expect(vector.issues, isEmpty);
      final data = XmlDocument.parse(vector.xml!).rootElement.childElements
          .map((e) => e.getAttribute('android:pathData'))
          .toList();
      expect(
        data[0],
        'M20.1 35.6A4.1 5 0 1 0 28.3 35.6A4.1 5 0 1 0 20.1 35.6Z',
      );
      expect(data[1], 'M8 10A2 2 0 1 0 12 10A2 2 0 1 0 8 10Z');
      expect(data[2], startsWith('M15 5H33A13 13 0 0 1 46'));
      expect(data[3], 'M0 0H4V4H0Z');
    });

    test('flattens groups and drops the metadata', () {
      final vector = widgetVectorOf(
        '<svg $_ns viewBox="0 0 24 32" xmlns:c2pa="http://c2pa.org/manifest">'
        '<metadata><c2pa:manifest>AAAA</c2pa:manifest></metadata>'
        '<g><path d="M0 0H4V4Z" fill="#000000"/></g></svg>',
        source: 'design/ui/widget/doll.svg',
        widthDp: 18,
        heightDp: 24,
      );
      expect(vector.issues, isEmpty);
      expect(vector.xml, isNot(contains('c2pa')));
      expect(vector.xml, contains('android:width="18dp"'));
      expect(vector.xml, contains('android:viewportHeight="32"'));
    });

    test('refuses what a vector drawable cannot take', () {
      expect(convert('<path d="M0 0" fill="url(#a)"/>').xml, isNull);
      expect(convert('<text fill="#000">a</text>').xml, isNull);
      expect(convert('').issues, contains('no shapes'));
      expect(
        widgetVectorOf(
          '<svg $_ns viewBox="0 0 48"><path d="M0 0" fill="#000"/></svg>',
          source: 's',
          widthDp: 1,
          heightDp: 1,
        ).xml,
        isNull,
      );
    });
  });

  group('the iOS catalog files', () {
    test('every set has the three scales; only the doll is a template', () {
      for (final set in widgetImageSets.keys) {
        final contents =
            jsonDecode(iosImageSetContents(set)) as Map<String, Object?>;
        final images = contents['images']! as List;
        expect(images.map((i) => (i as Map)['scale']), ['1x', '2x', '3x']);
        expect(images.map((i) => (i as Map)['filename']), [
          '$set.png',
          '$set@2x.png',
          '$set@3x.png',
        ]);
        expect(
          (contents['properties'] as Map?)?['template-rendering-intent'],
          set == 'WidgetDoll' ? 'template' : isNull,
        );
      }
    });
  });

  group('the real widget art', () {
    final plan = planWidgetNativeArt(root, tokens);

    test('converts with no issues', () {
      expect(plan.issues, isEmpty);
    });

    test('plans the iOS catalog, the Android drawables and the preview', () {
      final paths = plan.files.map((f) => f.path).toList();
      const ios = 'apps/game/ios/NestyWidget/Assets.xcassets';
      const res = 'apps/game/android/app/src/main/res';
      expect(paths, contains('$ios/Contents.json'));
      for (final set in widgetImageSets.keys) {
        for (final name in [
          '$set.png',
          '$set@2x.png',
          '$set@3x.png',
          'Contents.json',
        ]) {
          expect(paths, contains('$ios/$set.imageset/$name'));
        }
      }
      for (final drawable in widgetAndroidDrawables.keys) {
        expect(paths, contains('$res/$drawable'));
      }
      expect(
        paths,
        contains('$res/drawable-nodpi/nesty_widget_preview_2x2.png'),
      );
      expect(
        paths.where((path) => path.contains('preview_4x2')),
        isEmpty,
        reason: 'one provider has one previewImage slot',
      );
      expect(paths, orderedEquals([...paths]..sort()));
    });

    test('ships no C2PA data', () {
      for (final file in plan.files) {
        expect(
          String.fromCharCodes(file.bytes),
          isNot(contains('c2pa')),
          reason: file.path,
        );
      }
    });

    test('the night drawable is the dark unlit flame under the same name', () {
      String xmlOf(String drawable) => utf8.decode(
        plan.files.firstWhere((f) => f.path.endsWith('/res/$drawable')).bytes,
      );
      final day = xmlOf('drawable/nesty_widget_flame_unlit.xml');
      final night = xmlOf('drawable-night/nesty_widget_flame_unlit.xml');
      expect(day, contains('#FFC9AE8C'));
      expect(night, contains('#FF8A6A4E'));
      expect(night, isNot(contains('#FFC9AE8C')));
    });

    test('the doll is a black template at its 24×32 viewport', () {
      final xml = utf8.decode(
        plan.files
            .firstWhere(
              (f) => f.path.endsWith('drawable/nesty_widget_doll.xml'),
            )
            .bytes,
      );
      expect(xml, contains('android:fillColor="#FF000000"'));
      expect(xml, contains('android:viewportWidth="24"'));
      expect(xml, contains('android:viewportHeight="32"'));
      expect(xml, contains('android:fillType="evenOdd"'));
    });

    test('the sync plan carries every generated file, and is in sync', () {
      final sync = planDesignAssetSync(root);
      expect(sync.issues, isEmpty);
      final outputs = {for (final o in sync.outputs) o.path: o.bytes};
      for (final file in plan.files) {
        expect(outputs.containsKey(file.path), isTrue, reason: file.path);
        final onDisk = File(p.join(root.path, file.path));
        expect(onDisk.existsSync(), isTrue, reason: '${file.path} is missing');
        expect(
          onDisk.readAsBytesSync(),
          file.bytes,
          reason:
              '${file.path} is stale: run dart run nesty_tools:sync_design_assets',
        );
      }
    });
  });
}
