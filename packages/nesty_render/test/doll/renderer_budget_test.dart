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
}
