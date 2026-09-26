// Memory and time of the skin pipeline against the design doc §1
// "Performance budget": classic doll layers at DPR 3, cropped, 3–6 MB
// (≤ 8 MB for maxSize 6); raster at level load ≤ 250 ms on a low-end phone.
// flutter_tester rasterizes on the host CPU, so the times printed here are
// indicative only; the byte counts are exact (RGBA8 per image).
import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_core/nesty_core.dart';
import 'package:nesty_render/nesty_render.dart';

import 'support/render_test_support.dart';

// BoardTokens: 3 shelves, slotMaxDollHeight 150 × the size fractions.
final _maxSize6 = [for (final f in BoardTokens.dollHeightFractions) 150 * f];
final _maxSize4 = _maxSize6.take(4).toList();

String _mb(int bytes) => '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('classic at DPR 3 fits the layer budget', () async {
    final watch = Stopwatch()..start();
    final source = await loadClassic();
    final loadMs = watch.elapsedMilliseconds;
    final rasterizer = SkinRasterizer(source);
    final atlas = await loadSymbols();
    final cache = SkinCache(maxBytes: 64 << 20);
    addTearDown(() {
      cache.clear();
      atlas.dispose();
      rasterizer.dispose();
    });

    watch.reset();
    await rasterizer.ensureReady();
    final parseMs = watch.elapsedMilliseconds;

    final four = SvgSkinRenderer(
      rasterizer: rasterizer,
      cache: cache,
      symbols: atlas,
    );
    watch.reset();
    await four.prepare(heights: _maxSize4, devicePixelRatio: 3);
    final fourMs = watch.elapsedMilliseconds;
    final fourLayers = cache.byteSize;
    final fourTotal = four.preparedByteSize;

    final six = SvgSkinRenderer(
      rasterizer: rasterizer,
      cache: cache,
      symbols: atlas,
    );
    watch.reset();
    await six.prepare(heights: _maxSize6, devicePixelRatio: 3);
    final sixMs = watch.elapsedMilliseconds; // 4 cache hits + 2 new heights
    final sixLayers = cache.byteSize;
    final sixTotal = six.preparedByteSize;

    // Paint cost on the UI thread: 15 slots × a few dolls ≈ 60 paints.
    final params = DollPaintParams()
      ..baseX = 100
      ..baseY = 200;
    final recorder = PictureRecorder();
    final canvas = Canvas(recorder);
    watch.reset();
    const frames = 200;
    for (var f = 0; f < frames; f++) {
      for (var d = 0; d < 60; d++) {
        params
          ..color = DollColor.values[d % 11]
          ..height = _maxSize6[d % 6]
          ..lidLift = d.isEven ? 0 : 0.3;
        six.paint(canvas, params);
      }
    }
    final paintUs = watch.elapsedMicroseconds / frames;
    recorder.endRecording().dispose();

    // The numbers are this test's deliverable (memory/time report), so
    // they are printed on success too.
    // ignore: avoid_print
    print(
      'classic @DPR3: load+split ${loadMs}ms, parse+probe ${parseMs}ms; '
      'maxSize 4 prepare ${fourMs}ms, layers ${_mb(fourLayers)}, '
      'with symbols ${_mb(fourTotal)}; maxSize 6 prepare ${sixMs}ms '
      '(2 new heights), layers ${_mb(sixLayers)}, with symbols '
      '${_mb(sixTotal)}; 60 paints ${paintUs.toStringAsFixed(0)}µs/frame',
    );
    expect(six.preparedPixelHeights, [189, 243, 297, 351, 401, 450]);
    expect(fourLayers, lessThan(6 << 20)); // design: 3–6 MB
    expect(sixLayers, lessThan(8 << 20)); // design: ≤ 8 MB at maxSize 6
    expect(sixTotal - sixLayers, lessThan(3 << 20)); // symbol pages

    four.dispose();
    six.dispose();
  });

  // docs/plans/m2-lottie-design.md §4 "Budget": the game's doll art is the
  // part rasters alone (the SVG layer sets above stay for the admin and the
  // goldens). At 150 dp × DPR 3 a part is 300×450 = 0.54 MB; five colours
  // plus the silhouette ≈ 5.9 MB, gold adds 1.1.
  test('classic part rasters at DPR 3 fit the Lottie budget', () async {
    final rasterizer = SkinRasterizer(await loadClassic());
    final atlas = await loadSymbols();
    final parts = DollPartRasters();
    addTearDown(() {
      parts.dispose();
      atlas.dispose();
      rasterizer.dispose();
    });
    await rasterizer.ensureReady();

    final px = DollPartRasters.artHeightPxFor(
      tallestDollHeight: 150,
      devicePixelRatio: 3,
    );
    const five = [
      DollColor.red,
      DollColor.blue,
      DollColor.green,
      DollColor.yellow,
      DollColor.purple,
    ];
    final watch = Stopwatch()..start();
    final set = await parts.prepare(
      skin: rasterizer,
      colors: five,
      symbols: DollSymbols.subtle,
      artHeightPx: px,
      symbolAtlas: atlas,
    );
    final prepareMs = watch.elapsedMilliseconds;
    watch.reset();
    final withGold = await parts.prepare(
      skin: rasterizer,
      colors: [...five, DollColor.gold],
      symbols: DollSymbols.subtle,
      artHeightPx: px,
      symbolAtlas: atlas,
    );
    final goldMs = watch.elapsedMilliseconds; // 2 new images, 11 cache hits
    // The typical M2 board: 117 dp tallest (maxSize 4) at DPR 3.
    final typicalPx = DollPartRasters.artHeightPxFor(
      tallestDollHeight: 117,
      devicePixelRatio: 3,
    );
    final typical = await parts.prepare(
      skin: rasterizer,
      colors: five,
      symbols: DollSymbols.subtle,
      artHeightPx: typicalPx,
      symbolAtlas: atlas,
    );

    // Rest-sprite cost on the UI thread: 60 dolls a frame, 3 heights.
    final sprites = PartRasterDollRenderer(set.clone());
    final params = DollPaintParams()
      ..baseX = 100
      ..baseY = 200;
    final recorder = PictureRecorder();
    final canvas = Canvas(recorder);
    watch.reset();
    const frames = 200;
    for (var f = 0; f < frames; f++) {
      for (var d = 0; d < 60; d++) {
        params
          ..color = five[d % 5]
          ..height = _maxSize6[3 + d % 3];
        sprites.paint(canvas, params);
      }
    }
    final paintUs = watch.elapsedMicroseconds / frames;
    recorder.endRecording().dispose();
    sprites.dispose();

    // ignore: avoid_print
    print(
      'classic part rasters @DPR3: $px px, 5 colours + silhouette '
      '${_mb(set.byteSize)} in ${prepareMs}ms; + gold '
      '${_mb(withGold.byteSize)} (+${goldMs}ms); 117 dp ($typicalPx px) '
      '${_mb(typical.byteSize)}; 60 rest sprites '
      '${paintUs.toStringAsFixed(0)}µs/frame',
    );
    expect(px, 450);
    expect(set.byteSize, 11 * 300 * 450 * 4); // 5.94 MB
    expect(withGold.byteSize - set.byteSize, 2 * 300 * 450 * 4); // 1.08 MB
    expect(typical.byteSize, lessThan(set.byteSize));
    // The cache holds each image once, however many sets share it.
    expect(
      parts.byteSize,
      withGold.byteSize + typical.byteSize,
      reason: 'the gold set reuses the five colours and the silhouette',
    );
    for (final s in [set, withGold, typical]) {
      s.dispose();
    }
  });
}
