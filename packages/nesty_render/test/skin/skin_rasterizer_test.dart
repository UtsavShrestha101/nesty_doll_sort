import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_render/nesty_render.dart';
import 'package:nesty_render/svg_tools.dart';

import '../doll/support/render_test_support.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late SkinRasterizer rasterizer;

  setUpAll(() async {
    rasterizer = SkinRasterizer(await loadClassic());
  });

  tearDownAll(() => rasterizer.dispose());

  group('SkinLayer plan', () {
    test('covers every group; tint and lid flags follow spec §12.2', () {
      final drawn = {
        for (final l in SkinLayer.values)
          if (l != SkinLayer.silhouette) ...l.groups,
      };
      expect(drawn, containsAll(skinGroupIds));
      for (final l in SkinLayer.values) {
        if (l.tinted) {
          expect(SkinManifest.supportedTinted, containsAll(l.groups));
        }
        if (l.lid) {
          expect(SkinManifest.supportedLidGroups, containsAll(l.groups));
        } else if (l != SkinLayer.silhouette) {
          for (final g in l.groups) {
            expect(SkinManifest.supportedLidGroups, isNot(contains(g)));
          }
        }
      }
    });
  });

  group('SkinRasterizer', () {
    test('probes a crop inside the artboard for every layer', () async {
      final crops = await rasterizer.cropRects();
      expect(crops.keys, SkinLayer.values);
      for (final entry in crops.entries) {
        final crop = entry.value!;
        expect(crop.left, greaterThanOrEqualTo(0), reason: '${entry.key}');
        expect(crop.top, greaterThanOrEqualTo(0), reason: '${entry.key}');
        expect(crop.right, lessThanOrEqualTo(512), reason: '${entry.key}');
        expect(crop.bottom, lessThanOrEqualTo(768), reason: '${entry.key}');
        expect(crop.isEmpty, isFalse, reason: '${entry.key}');
      }
      // The crops follow the art: the lid is above splitY, the shadow at
      // the base, and gold reuses the gray masks' boxes.
      expect(crops[SkinLayer.lidMask]!.bottom, lessThan(450));
      expect(crops[SkinLayer.bottomMask]!.top, greaterThan(350));
      expect(crops[SkinLayer.shadow]!.top, greaterThan(700));
      expect(crops[SkinLayer.goldBottomMask], crops[SkinLayer.bottomMask]);
      expect(crops[SkinLayer.goldLidMask], crops[SkinLayer.lidMask]);
    });

    test(
      'rasterizes each layer on whole pixels at the requested height',
      () async {
        final set = await rasterizer.rasterize(450); // 150 dp at DPR 3
        addTearDown(set.dispose);
        expect(set.artHeightPx, 450);
        expect(set.pxPerArt, 450 / 768);
        expect(set.skinKey, 'classic@1');
        for (final layer in SkinLayer.values) {
          final image = set[layer]!;
          expect(image.src.width, image.image.width, reason: '$layer');
          expect(
            image.dst.width * set.pxPerArt,
            closeTo(image.image.width, 1e-6),
          );
          expect(
            image.dst.height * set.pxPerArt,
            closeTo(image.image.height, 1e-6),
          );
          // Edges land on the artboard's pixel grid at this scale.
          final left = image.dst.left * set.pxPerArt;
          final top = image.dst.top * set.pxPerArt;
          expect(left, closeTo(left.roundToDouble(), 1e-6), reason: '$layer');
          expect(top, closeTo(top.roundToDouble(), 1e-6), reason: '$layer');
        }
        // Cropping pays: far less than 9 full 300 × 450 artboards.
        expect(set.byteSize, lessThan(9 * 300 * 450 * 4 * 0.6));
      },
    );

    test('rejects a zero height', () {
      expect(rasterizer.rasterize(0), throwsArgumentError);
    });

    test('a disposed rasterizer refuses work; its sets stay valid', () async {
      final own = SkinRasterizer(await loadClassic());
      final set = await own.rasterize(96);
      own.dispose();
      expect(own.rasterize(96), throwsStateError);
      expect(set.debugDisposed, isFalse);
      expect(set[SkinLayer.bottomMask]!.image.debugDisposed, isFalse);
      set.dispose();
    });
  });

  group('SkinImageSet', () {
    test('clones are independent handles', () async {
      final set = await rasterizer.rasterize(120);
      final clone = set.clone();
      set.dispose();
      expect(set.debugDisposed, isTrue);
      expect(clone[SkinLayer.shadow]!.image.debugDisposed, isFalse);
      expect(() => set.clone(), throwsStateError);
      clone.dispose();
    });
  });

  group('SkinCache', () {
    test('rasterizes a height once and hands out clones', () async {
      final cache = SkinCache();
      addTearDown(cache.clear);
      final results = await Future.wait([
        cache.obtain(rasterizer, 200),
        cache.obtain(rasterizer, 200),
      ]);
      expect(cache.length, 1);
      expect(cache.contains('classic@1', 200), isTrue);
      expect(identical(results[0], results[1]), isFalse);
      final again = await cache.obtain(rasterizer, 200);
      expect(cache.length, 1);
      expect(cache.byteSize, again.byteSize);
      for (final set in [...results, again]) {
        set.dispose();
      }
      // The cache's own handle survives its clones.
      final last = await cache.obtain(rasterizer, 200);
      expect(last[SkinLayer.lidMask]!.image.debugDisposed, isFalse);
      last.dispose();
    });

    test(
      'evicts least recently used sets past maxBytes, keeping the newest',
      () async {
        final probe = await rasterizer.rasterize(300);
        final oneSet = probe.byteSize;
        probe.dispose();
        final cache = SkinCache(maxBytes: (oneSet * 2.5).round());
        addTearDown(cache.clear);
        (await cache.obtain(rasterizer, 300)).dispose();
        (await cache.obtain(rasterizer, 290)).dispose();
        (await cache.obtain(rasterizer, 300)).dispose(); // 300 is now newest
        (await cache.obtain(rasterizer, 310)).dispose();
        expect(cache.contains('classic@1', 290), isFalse);
        expect(cache.contains('classic@1', 300), isTrue);
        expect(cache.contains('classic@1', 310), isTrue);
        expect(cache.byteSize, lessThanOrEqualTo(cache.maxBytes));

        final tiny = SkinCache(maxBytes: 0);
        final kept = await tiny.obtain(rasterizer, 100);
        expect(tiny.length, 1, reason: 'the newest set is always kept');
        kept.dispose();
        tiny.clear();
      },
    );

    test('clear() frees the cache but not the clones renderers hold', () async {
      final cache = SkinCache();
      final held = await cache.obtain(rasterizer, 150);
      cache.clear();
      expect(cache.length, 0);
      expect(cache.byteSize, 0);
      expect(held[SkinLayer.bottomMask]!.image.debugDisposed, isFalse);
      held.dispose();
    });
  });
}
