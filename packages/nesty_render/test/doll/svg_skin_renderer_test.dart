import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_core/nesty_core.dart';
import 'package:nesty_render/nesty_render.dart';

import 'support/render_test_support.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late SkinSource classic;
  late SkinRasterizer rasterizer;
  late SymbolAtlas atlas;

  setUpAll(() async {
    classic = await loadClassic();
    rasterizer = SkinRasterizer(classic);
    atlas = await loadSymbols();
  });

  tearDownAll(() {
    atlas.dispose();
    rasterizer.dispose();
  });

  Future<Uint8List> draw(
    DollRenderer r,
    DollPaintParams p,
    int w,
    int h,
  ) async {
    final image = await capture(w, h, (c) => r.paint(c, p));
    final bytes = await rgbaOf(image);
    image.dispose();
    return bytes;
  }

  int opaque(Uint8List rgba) {
    var n = 0;
    for (var i = 3; i < rgba.length; i += 4) {
      if (rgba[i] > 0) n++;
    }
    return n;
  }

  group('SvgSkinRenderer', () {
    test('is ready only for prepared heights at the prepared DPR', () async {
      final r = SvgSkinRenderer(rasterizer: rasterizer, symbols: atlas);
      addTearDown(r.dispose);
      expect(r.isReadyFor(99), isFalse);
      expect(r.canPaint(99), isFalse, reason: 'nothing prepared yet');
      await r.prepare(heights: const [63, 99, 99], devicePixelRatio: 3);
      expect(r.preparedPixelHeights, [189, 297]);
      expect(r.isReadyFor(63), isTrue);
      expect(r.isReadyFor(99), isTrue);
      expect(r.isReadyFor(81), isFalse);
      expect(r.manifest.skinId, 'classic');
      expect(r.preparedByteSize, greaterThan(0));
    });

    test(
      'heights accumulate and the least recently prepared go first',
      () async {
        final r = SvgSkinRenderer(
          rasterizer: rasterizer,
          symbols: atlas,
          maxPreparedHeights: 3,
        );
        addTearDown(r.dispose);
        await r.prepare(heights: const [40, 50], devicePixelRatio: 1);
        await r.prepare(heights: const [60], devicePixelRatio: 1);
        expect(r.preparedPixelHeights, [40, 50, 60]);
        await r.prepare(heights: const [50, 70], devicePixelRatio: 1);
        expect(r.preparedPixelHeights, [50, 60, 70]);
        // A request larger than the limit keeps everything it asked for.
        await r.prepare(heights: const [10, 20, 30, 40], devicePixelRatio: 1);
        expect(r.preparedPixelHeights, [10, 20, 30, 40]);
      },
    );

    test('draws an unprepared height from the nearest set, scaled', () async {
      final r = SvgSkinRenderer(rasterizer: rasterizer, symbols: atlas);
      addTearDown(r.dispose);
      await r.prepare(heights: const [120], devicePixelRatio: 1);
      final p = DollPaintParams()
        ..height = 60
        ..baseX = 20
        ..baseY = 58;
      expect(r.isReadyFor(60), isFalse);
      expect(r.canPaint(60), isTrue);
      expect(opaque(await draw(r, p, 40, 60)), greaterThan(40 * 60 * 0.4));
    });

    test('an upright doll lands on whole device pixels', () async {
      // Review RENDER-9: layout bases are fractional; the rasters are made
      // to be sampled 1:1 from a whole-pixel base.
      final r = SvgSkinRenderer(rasterizer: rasterizer, symbols: atlas);
      addTearDown(r.dispose);
      await r.prepare(heights: const [60], devicePixelRatio: 2);
      Future<Uint8List> at(double x, double y, {double scale = 1}) {
        final p = DollPaintParams()
          ..height = 60
          ..baseX = x
          ..baseY = y
          ..scaleX = scale;
        // A 2× canvas, as the game's is at DPR 2.
        return capture(80, 140, (c) {
          c.scale(2);
          r.paint(c, p);
        }).then((image) async {
          final bytes = await rgbaOf(image);
          image.dispose();
          return bytes;
        });
      }

      // 20.2 dp = 40.4 px snaps to 40 px, 20.3 dp = 40.6 px to 41 px.
      expect(await at(20.2, 58.2), await at(20, 58));
      expect(await at(20.3, 58.3), await at(20.5, 58.5));
      // A scaled doll keeps its exact position.
      expect(
        await at(20.2, 58, scale: 0.9),
        isNot(await at(20, 58, scale: 0.9)),
      );
    });

    test('shares one cache between renderers', () async {
      final cache = SkinCache();
      addTearDown(cache.clear);
      final a = SvgSkinRenderer(rasterizer: rasterizer, cache: cache);
      final b = SvgSkinRenderer(rasterizer: rasterizer, cache: cache);
      await a.prepare(heights: const [80, 90], devicePixelRatio: 1);
      await b.prepare(heights: const [90, 100], devicePixelRatio: 1);
      expect(cache.length, 3);
      a.dispose();
      // b's images are its own handles.
      final p = DollPaintParams()
        ..height = 90
        ..baseX = 30
        ..baseY = 87;
      expect(opaque(await draw(b, p, 60, 90)), greaterThan(0));
      b.dispose();
      expect(cache.length, 3, reason: 'a shared cache is not the renderer’s');
    });

    test('after dispose it paints nothing and refuses to prepare', () async {
      final r = SvgSkinRenderer(rasterizer: rasterizer);
      await r.prepare(heights: const [50], devicePixelRatio: 1);
      r.dispose();
      final p = DollPaintParams()
        ..height = 50
        ..baseX = 16
        ..baseY = 48;
      expect(opaque(await draw(r, p, 34, 50)), 0);
      expect(r.preparedPixelHeights, isEmpty);
      expect(
        r.prepare(heights: const [50], devicePixelRatio: 1),
        throwsStateError,
      );
    });

    group('nest z-order (review RENDER-1)', () {
      // Host red 4 opened for a nest and a blue 3 mid-drop, placed as the
      // design's nest frame places them (NestyBoard.dc.html: the guest's
      // base at the split line + 0.55 × its height).
      const w = 256;
      const h = 420;
      const hostHeight = 300.0;
      const baseX = 128.0;
      const baseY = 380.0;
      const k = hostHeight / 768;
      const guestHeight = hostHeight * 0.66 / 0.78;
      double artY(double y) => baseY - (742 - y) * k;
      final guestBase = artY(400) + guestHeight * 0.55;

      late SvgSkinRenderer r;
      setUp(() async {
        r = SvgSkinRenderer(rasterizer: rasterizer, symbols: atlas);
        await r.prepare(
          heights: const [hostHeight, guestHeight],
          devicePixelRatio: 1,
        );
      });
      tearDown(() => r.dispose());

      DollPaintParams host(DollPart part, {double lidLift = 0.3}) =>
          DollPaintParams()
            ..color = DollColor.red
            ..height = hostHeight
            ..baseX = baseX
            ..baseY = baseY
            ..lidLift = lidLift
            ..part = part;
      final guest = DollPaintParams()
        ..color = DollColor.blue
        ..height = guestHeight
        ..baseX = baseX
        ..baseY = guestBase
        ..shadow = false;

      Future<Uint8List> frame(List<DollPaintParams> passes) async {
        final image = await capture(w, h, (c) {
          for (final pass in passes) {
            r.paint(c, pass);
          }
        });
        final bytes = await rgbaOf(image);
        image.dispose();
        return bytes;
      }

      int at(Uint8List rgba, double x, double y) =>
          (y.floor() * w + x.floor()) * 4;
      bool same(Uint8List a, Uint8List b, int i) {
        for (var c = 0; c < 4; c++) {
          if ((a[i + c] - b[i + c]).abs() > 8) return false;
        }
        return true;
      }

      test('the doll going in covers the hollow above the split', () async {
        final nest = await frame([
          host(DollPart.lid),
          host(DollPart.interior),
          guest,
          host(DollPart.bodyFront),
        ]);
        final guestAlone = await frame([guest]);
        // Art y 397 of the host: inside the rim's dark ellipse, above the
        // split. The guest's own colour must show there.
        final hollow = at(nest, baseX, artY(397));
        expect(same(nest, guestAlone, hollow), isTrue);
        // The old order (host body with its rim drawn after the guest)
        // painted the dark hollow across the guest's belly.
        final old = await frame([
          host(DollPart.lid),
          guest,
          host(DollPart.body),
        ]);
        expect(same(old, guestAlone, hollow), isFalse);
      });

      test('the host body hides the doll inside below the split', () async {
        final nest = await frame([
          host(DollPart.lid),
          host(DollPart.interior),
          guest,
          host(DollPart.bodyFront),
        ]);
        final closed = await frame([host(DollPart.full, lidLift: 0)]);
        // Below the rim (art y 419) and the closed lid's overlap.
        for (final y in [430.0, 500.0, 700.0]) {
          final i = at(nest, baseX, artY(y));
          expect(same(nest, closed, i), isTrue, reason: 'art y $y');
        }
      });

      test(
        'interior draws only the rim, bodyFront nothing above the split',
        () async {
          final interior = await frame([host(DollPart.interior)]);
          final front = await frame([host(DollPart.bodyFront)]);
          var rim = 0;
          var above = 0;
          for (var y = 0; y < h; y++) {
            for (var x = 0; x < w; x++) {
              final i = (y * w + x) * 4 + 3;
              if (interior[i] > 0) rim++;
              if (front[i] > 0 && y < artY(400) - 1) above++;
            }
          }
          // The rim ellipse has radii 148 × 21 art units: π × 57.8 × 8.2
          // ≈ 1490 px here.
          expect(rim, inInclusiveRange(1300, 1800));
          expect(above, 0);
        },
      );

      test('shadow: false leaves the ground under the doll clear', () async {
        final withShadow = await frame([host(DollPart.full, lidLift: 0)]);
        final without = await frame([
          host(DollPart.full, lidLift: 0)..shadow = false,
        ]);
        // Art y 760: below the base, only the shadow reaches it.
        final i = at(withShadow, baseX, artY(760));
        expect(withShadow[i + 3], greaterThan(0));
        expect(without[i + 3], 0);
      });
    });

    test('moves the symbol to the anchor the skin.json asks for', () async {
      final moved = SkinRasterizer(
        SkinSource(
          manifest: const SkinManifest(
            skinId: 'moved',
            version: 1,
            symbolAnchor: Offset(256, 520),
          ),
          layers: classic.layers,
        ),
      );
      final r = SvgSkinRenderer(rasterizer: moved, symbols: atlas);
      addTearDown(() {
        r.dispose();
        moved.dispose();
      });
      await r.prepare(heights: const [384], devicePixelRatio: 1);
      Future<Uint8List> mode(DollSymbols s) => draw(
        r,
        DollPaintParams()
          ..color = DollColor.red
          ..symbols = s
          ..height = 384
          ..baseX = 128
          ..baseY = 371,
        256,
        384,
      );
      final none = await mode(DollSymbols.none);
      final subtle = await mode(DollSymbols.subtle);
      var sumY = 0;
      var n = 0;
      for (var i = 0; i < none.length; i += 4) {
        if (none[i] == subtle[i]) continue;
        sumY += (i ~/ 4) ~/ 256;
        n++;
      }
      expect(n, greaterThan(100));
      // The heart's centre of mass sits near art y 520 (pixel 260).
      expect(sumY / n, closeTo(260, 8));
    });
  });
}
