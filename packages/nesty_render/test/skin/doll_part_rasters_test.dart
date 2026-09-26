// DollPartRasters (docs/plans/m2-lottie-design.md §4, §17 "Render"): the
// whole-artboard lid/body/silhouette rasters the Lottie image slots and the
// rest sprites share, split hard at art y 400 (PROGRESS D45).
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_core/nesty_core.dart';
import 'package:nesty_render/nesty_render.dart';

import '../doll/support/render_test_support.dart';

ui.Image _blank(int width, int height) {
  final recorder = ui.PictureRecorder();
  ui.Canvas(recorder);
  return recorder.endRecording().toImageSync(width, height);
}

// The goldens' size: the artboard at half scale, so the art base (256, 742)
// and the split (y 400) land on whole pixels and every renderer samples its
// rasters 1:1.
const _px = 384;
const _width = 256;
const _r = _px / 768;

// The band D45 gives up: `bottom_mask` starts at y 388 and `top_mask` runs
// to 412 in the skin, where the hard split draws the body instead.
const _bandTop = 388 * _r;
const _bandBottom = 412 * _r;
const _above = ui.Rect.fromLTRB(0, 0, _width * 1.0, _bandTop);
const _below = ui.Rect.fromLTRB(0, _bandBottom, _width * 1.0, _px * 1.0);

/// Composes a set's doll as the rest sprites and the Lottie do: body, then
/// lid, at the raster's own size.
Future<Uint8List> _composed(DollPartSet set, DollColor? color) async {
  final image = await capture(set.widthPx, set.artHeightPx, (canvas) {
    final paint = ui.Paint();
    if (color == null) {
      canvas.drawImage(set.silhouette, ui.Offset.zero, paint);
      return;
    }
    canvas
      ..drawImage(set.body(color)!, ui.Offset.zero, paint)
      ..drawImage(set.lid(color)!, ui.Offset.zero, paint);
  });
  final bytes = await rgbaOf(image);
  image.dispose();
  return bytes;
}

Future<Uint8List> _painted(DollRenderer renderer, DollPaintParams p) async {
  final image = await capture(_width, _px, (c) => renderer.paint(c, p));
  final bytes = await rgbaOf(image);
  image.dispose();
  return bytes;
}

DollPaintParams _params(DollColor? color, DollSymbols symbols) {
  final p = DollPaintParams()
    ..height = _px.toDouble()
    ..baseX = 256 * _r
    ..baseY = 742 * _r
    ..symbols = symbols;
  if (color == null) {
    p.silhouette = true;
  } else {
    p.color = color;
  }
  return p;
}

/// The alpha of every pixel row of [image], summed.
Future<List<int>> _rowAlpha(ui.Image image) async {
  final rgba = await rgbaOf(image);
  return [
    for (var y = 0; y < image.height; y++)
      [
        for (var x = 0; x < image.width; x++)
          rgba[(y * image.width + x) * 4 + 3],
      ].fold(0, (a, b) => a + b),
  ];
}

void _expectOutsideBand(Uint8List want, Uint8List got, String what) {
  for (final (name, region) in [('above', _above), ('below', _below)]) {
    final diff = ImageDiff(
      cropRgba(want, _width, region),
      cropRgba(got, _width, region),
    );
    printOnFailure('$what $name the band: $diff');
    // Measured against SvgSkinRenderer: 100 % within 8/255, every pixel
    // within 6/255 or better. The same pictures at the same scale, tinted
    // through a layer instead of at draw time.
    expect(diff.withinFraction, greaterThanOrEqualTo(0.9999), reason: '$diff');
    expect(diff.meanDiff, lessThan(0.25), reason: '$diff');
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('DollPartRasters.artHeightPxFor', () {
    test('samples the tallest doll 1:1', () {
      expect(
        DollPartRasters.artHeightPxFor(
          tallestDollHeight: 150,
          devicePixelRatio: 3,
        ),
        450,
      );
      expect(
        DollPartRasters.artHeightPxFor(
          tallestDollHeight: 117,
          devicePixelRatio: 2.625,
        ),
        309, // 307.125 up to a multiple of 3: 206 px wide exactly
      );
    });

    test('always gives a whole-pixel artboard width', () {
      for (var h = 60.0; h <= 150; h += 7.3) {
        final px = DollPartRasters.artHeightPxFor(
          tallestDollHeight: h,
          devicePixelRatio: 2.75,
        );
        expect(px % 3, 0);
        expect(px, greaterThanOrEqualTo(h * 2.75));
      }
    });

    test('rejects non-positive sizes', () {
      expect(
        () => DollPartRasters.artHeightPxFor(
          tallestDollHeight: 0,
          devicePixelRatio: 3,
        ),
        throwsArgumentError,
      );
    });
  });

  group('DollPartRasters.splitRowPx', () {
    test('is the first row whose centre is at or below art y 400', () {
      expect(DollPartRasters.splitRowPx(artHeightPx: 384), 200);
      expect(DollPartRasters.splitRowPx(artHeightPx: 768), 400);
      // 400 · 450/768 = 234.375: row 234's centre (234.5) is below it.
      expect(DollPartRasters.splitRowPx(artHeightPx: 450), 234);
      // 400 · 309/768 = 160.94: row 160's centre (160.5) is above it.
      expect(DollPartRasters.splitRowPx(artHeightPx: 309), 161);
      for (var px = 1; px <= 600; px++) {
        final row = DollPartRasters.splitRowPx(artHeightPx: px);
        final split = 400 * px / 768;
        expect((row - split).abs(), lessThanOrEqualTo(0.5), reason: '$px');
      }
    });

    test("follows the skin's splitY", () {
      expect(DollPartRasters.splitRowPx(artHeightPx: 768, splitY: 380), 380);
    });
  });

  group('DollPartSet', () {
    // 450 px tall → r = 450 / 768, 300 px wide.
    const artHeightPx = 450;
    const widthPx = 300;

    DollPartSet build({int width = widthPx}) => DollPartSet(
      skinKey: 'classic@1',
      symbols: DollSymbols.subtle,
      artHeightPx: artHeightPx,
      lids: {
        DollColor.red: _blank(width, artHeightPx),
        DollColor.blue: _blank(width, artHeightPx),
      },
      bodies: {
        DollColor.red: _blank(width, artHeightPx),
        DollColor.blue: _blank(width, artHeightPx),
      },
      silhouette: _blank(width, artHeightPx),
    );

    test('exposes the compensation scale and the parts per colour', () {
      final set = build();
      expect(set.artScale, closeTo(0.5859375, 1e-12));
      expect(set.widthPx, widthPx);
      expect(set.colors, [DollColor.red, DollColor.blue]);
      expect(set.lid(DollColor.red), isNotNull);
      expect(set.body(DollColor.blue), isNotNull);
      expect(set.lid(DollColor.gold), isNull);
      // 2 colours × (lid + body) + silhouette, RGBA8.
      expect(set.byteSize, 5 * widthPx * artHeightPx * 4);
      set.dispose();
    });

    test('rejects rasters that are not the whole artboard', () {
      expect(() => build(width: 256), throwsArgumentError);
      expect(
        () => DollPartSet(
          skinKey: 'classic@1',
          symbols: DollSymbols.none,
          artHeightPx: artHeightPx,
          lids: {DollColor.red: _blank(widthPx, artHeightPx)},
          bodies: const {},
          silhouette: _blank(widthPx, artHeightPx),
        ),
        throwsArgumentError,
      );
    });

    test('clones share pixels and dispose independently', () {
      final set = build();
      final clone = set.clone();
      set.dispose();
      expect(set.debugDisposed, isTrue);
      expect(clone.debugDisposed, isFalse);
      expect(clone.lid(DollColor.red)!.debugDisposed, isFalse);
      expect(set.clone, throwsStateError);
      clone.dispose();
    });
  });

  group('DollPartRasters.prepare (classic)', () {
    late SkinRasterizer rasterizer;
    late SymbolAtlas atlas;
    late SvgSkinRenderer svg;
    late DollPartRasters parts;
    final sets = <DollSymbols, DollPartSet>{};

    setUpAll(() async {
      rasterizer = SkinRasterizer(await loadClassic());
      atlas = await loadSymbols();
      svg = SvgSkinRenderer(rasterizer: rasterizer, symbols: atlas);
      await svg.prepare(heights: const [384], devicePixelRatio: 1);
      parts = DollPartRasters(maxBytes: 64 << 20);
      for (final mode in DollSymbols.values) {
        sets[mode] = await parts.prepare(
          skin: rasterizer,
          colors: DollColor.values,
          symbols: mode,
          artHeightPx: _px,
          symbolAtlas: atlas,
        );
      }
    });

    tearDownAll(() {
      for (final set in sets.values) {
        set.dispose();
      }
      parts.dispose();
      svg.dispose();
      atlas.dispose();
      rasterizer.dispose();
    });

    test('holds every colour on the whole artboard', () {
      final set = sets[DollSymbols.subtle]!;
      expect(set.skinKey, 'classic@1');
      expect(set.symbols, DollSymbols.subtle);
      expect(set.artHeightPx, _px);
      expect(set.widthPx, _width);
      expect(set.artScale, _r);
      expect(set.colors, DollColor.values);
    });

    test(
      'the lid is empty from the split row down, the body above it',
      () async {
        final split = DollPartRasters.splitRowPx(artHeightPx: _px);
        for (final color in [DollColor.red, DollColor.gold]) {
          final set = sets[DollSymbols.large]!;
          final lid = await _rowAlpha(set.lid(color)!);
          final body = await _rowAlpha(set.body(color)!);
          expect(lid.sublist(split).every((a) => a == 0), isTrue);
          expect(body.sublist(0, split).every((a) => a == 0), isTrue);
          // Both reach the split: nothing is lost there.
          expect(lid[split - 1], greaterThan(0));
          expect(body[split], greaterThan(0));
        }
      },
    );

    test('splits at 400r on a fractional row too', () async {
      const px = 450; // 150 dp at DPR 3: the split is at 234.375 px
      final set = await parts.prepare(
        skin: rasterizer,
        colors: const [DollColor.teal],
        symbols: DollSymbols.subtle,
        artHeightPx: px,
        symbolAtlas: atlas,
      );
      addTearDown(set.dispose);
      expect(set.widthPx, 300);
      final lid = await _rowAlpha(set.lid(DollColor.teal)!);
      final body = await _rowAlpha(set.body(DollColor.teal)!);
      const split = 400 * px / 768;
      // Rows wholly below 400r hold no lid, rows wholly above it no body…
      expect(lid.sublist(split.ceil()).every((a) => a == 0), isTrue);
      expect(body.sublist(0, split.floor()).every((a) => a == 0), isTrue);
      // …and the row that 400r crosses belongs to one part only.
      final row = DollPartRasters.splitRowPx(artHeightPx: px);
      expect(row, 234);
      expect(lid[row], 0);
      expect(body[row], greaterThan(0));
    });

    test(
      'lid over body equals SvgSkinRenderer outside the 388–412 band',
      () async {
        for (final mode in DollSymbols.values) {
          for (final color in DollColor.values) {
            _expectOutsideBand(
              await _painted(svg, _params(color, mode)),
              await _composed(sets[mode]!, color),
              '${color.id} ${mode.name}',
            );
          }
        }
      },
    );

    test('matches the design renders outside the band', () async {
      for (final (name, color, mode) in [
        ('red', DollColor.red, DollSymbols.subtle),
        ('navy', DollColor.navy, DollSymbols.subtle),
        ('gold', DollColor.gold, DollSymbols.subtle),
        ('green_large_symbol', DollColor.green, DollSymbols.large),
        ('gold_large_symbol', DollColor.gold, DollSymbols.large),
        ('silhouette', null, DollSymbols.subtle),
      ]) {
        final render = await rasterizeSvg(readRender(name), scale: _r);
        final want = await rgbaOf(render);
        render.dispose();
        final got = await _composed(sets[mode]!, color);
        for (final region in [_above, _below]) {
          final diff = ImageDiff(
            cropRgba(want, _width, region),
            cropRgba(got, _width, region),
          );
          // The goldens' gate (svg_skin_renderer_golden_test.dart).
          expect(
            diff.withinFraction,
            greaterThanOrEqualTo(0.999),
            reason: '$name $diff',
          );
          expect(diff.meanDiff, lessThan(0.5), reason: '$name $diff');
        }
      }
    });

    test('gold draws the ramp-rewritten masks, not a tint', () async {
      // Parity above already pins gold to SvgSkinRenderer's gradient-mapped
      // layers; here gold must also differ from every flat tint, which a
      // modulate filter over the gray mask would give.
      final set = sets[DollSymbols.none]!;
      final gold = await rgbaOf(set.lid(DollColor.gold)!);
      for (final flat in [DollColor.yellow, DollColor.orange]) {
        final other = await rgbaOf(set.lid(flat)!);
        expect(ImageDiff(gold, other).meanDiff, greaterThan(2));
      }
    });

    test('the symbol modes change only the bodies', () async {
      final box = ui.Rect.fromCircle(
        center: SkinTokens.symbolAnchor * _r,
        radius: (SkinTokens.badgeRadius + SkinTokens.badgeStroke) * _r,
      );
      Future<Uint8List> symbolBox(DollSymbols mode) async => cropRgba(
        await rgbaOf(sets[mode]!.body(DollColor.blue)!),
        _width,
        box,
      );
      final none = await symbolBox(DollSymbols.none);
      final subtle = await symbolBox(DollSymbols.subtle);
      final large = await symbolBox(DollSymbols.large);
      expect(ImageDiff(none, subtle).meanDiff, greaterThan(1));
      expect(ImageDiff(subtle, large).meanDiff, greaterThan(1));
      // The cream disc (tokens `skin.badgeFill`) under the large symbol's
      // ring, just inside it.
      final disc = await rgbaOf(sets[DollSymbols.large]!.body(DollColor.blue)!);
      final at = SkinTokens.symbolAnchor.translate(0, 80) * _r;
      final i = (at.dy.round() * _width + at.dx.round()) * 4;
      expect(disc.sublist(i, i + 4), [0xFF, 0xF8, 0xEC, 0xFF]);
      // Lids don't depend on the mode.
      for (final mode in [DollSymbols.subtle, DollSymbols.large]) {
        expect(
          ImageDiff(
            await rgbaOf(sets[DollSymbols.none]!.lid(DollColor.blue)!),
            await rgbaOf(sets[mode]!.lid(DollColor.blue)!),
            tolerance: 0,
          ).withinFraction,
          1,
        );
      }
    });

    test('the silhouette stands on its shadow', () async {
      final set = sets[DollSymbols.subtle]!;
      final alpha = await _rowAlpha(set.silhouette);
      // Below the masks' base (y 742, 760 with the crop margin) only the
      // shadow is drawn.
      final shadowRows = alpha.sublist((750 * _r).ceil(), (766 * _r).floor());
      expect(shadowRows.every((a) => a > 0), isTrue);
      final withShadow = _params(null, DollSymbols.subtle);
      _expectOutsideBand(
        await _painted(svg, withShadow),
        await _composed(set, null),
        'silhouette',
      );
    });

    test('caches per image and clones', () async {
      // 11 lids, 3 × 11 bodies, one silhouette so far (and the teal set).
      final before = parts.length;
      final bytes = parts.byteSize;
      final again = await parts.prepare(
        skin: rasterizer,
        colors: const [DollColor.red, DollColor.gold],
        symbols: DollSymbols.subtle,
        artHeightPx: _px,
        symbolAtlas: atlas,
      );
      expect(parts.length, before);
      expect(parts.byteSize, bytes);
      expect(again.colors, [DollColor.red, DollColor.gold]);
      // The clone survives the cache.
      parts.clear();
      expect(parts.byteSize, 0);
      expect(again.lid(DollColor.red)!.debugDisposed, isFalse);
      expect(
        ImageDiff(
          await _composed(again, DollColor.red),
          await _composed(sets[DollSymbols.subtle]!, DollColor.red),
          tolerance: 0,
        ).withinFraction,
        1,
      );
      again.dispose();
    });
  });

  group('DollPartRasters cache', () {
    late SkinRasterizer rasterizer;

    setUpAll(() async {
      rasterizer = SkinRasterizer(await loadClassic());
    });

    tearDownAll(() => rasterizer.dispose());

    Future<DollPartSet> prepare(
      DollPartRasters parts,
      List<DollColor> colors, {
      DollSymbols symbols = DollSymbols.subtle,
      int px = 96,
    }) => parts.prepare(
      skin: rasterizer,
      colors: colors,
      symbols: symbols,
      artHeightPx: px,
    );

    test('a new symbols mode rasterizes only the bodies', () async {
      final parts = DollPartRasters();
      addTearDown(parts.dispose);
      final a = await prepare(parts, const [DollColor.red, DollColor.blue]);
      expect(parts.length, 5); // 2 lids, 2 bodies, the silhouette
      final b = await prepare(parts, const [
        DollColor.red,
        DollColor.blue,
      ], symbols: DollSymbols.large);
      expect(parts.length, 7);
      final c = await prepare(parts, const [DollColor.blue, DollColor.teal]);
      expect(parts.length, 9); // teal's lid and body
      for (final set in [a, b, c]) {
        set.dispose();
      }
    });

    test('concurrent requests share one rasterization', () async {
      final parts = DollPartRasters();
      addTearDown(parts.dispose);
      final sets = await Future.wait([
        prepare(parts, const [DollColor.red, DollColor.green]),
        prepare(parts, const [DollColor.green, DollColor.red]),
        prepare(parts, const [DollColor.green]),
      ]);
      expect(parts.length, 5);
      expect(sets[0].colors, [DollColor.red, DollColor.green]);
      expect(sets[1].colors, [DollColor.red, DollColor.green]);
      expect(sets[2].colors, [DollColor.green]);
      for (final set in sets) {
        set.dispose();
      }
    });

    test(
      'evicts least recently used images and keeps the newest set',
      () async {
        // One 64 × 96 image is 24 KiB: room for about one 2-colour set.
        final parts = DollPartRasters(maxBytes: 5 * 64 * 96 * 4);
        addTearDown(parts.dispose);
        final a = await prepare(parts, const [DollColor.red, DollColor.blue]);
        expect(parts.length, 5);
        final b = await prepare(parts, const [DollColor.pink, DollColor.navy]);
        // The silhouette is shared; red and blue went.
        expect(parts.length, 5);
        expect(parts.byteSize, lessThanOrEqualTo(parts.maxBytes));
        // Evicted images stay valid in the clones.
        expect(a.lid(DollColor.red)!.debugDisposed, isFalse);
        // Nothing smaller than the newest set: it is always kept whole.
        final tiny = DollPartRasters(maxBytes: 0);
        addTearDown(tiny.dispose);
        final c = await prepare(tiny, const [DollColor.red]);
        expect(tiny.length, 3);
        for (final set in [a, b, c]) {
          set.dispose();
        }
      },
    );

    test('is unusable after dispose', () async {
      final parts = DollPartRasters()..dispose();
      await expectLater(
        prepare(parts, const [DollColor.red]),
        throwsStateError,
      );
      await expectLater(
        parts.preparePlaceholder(
          colors: const [DollColor.red],
          symbols: DollSymbols.none,
          artHeightPx: 96,
        ),
        throwsStateError,
      );
    });

    test('a dispose mid-prepare fails it and frees what lands', () async {
      final parts = DollPartRasters();
      final pending = prepare(parts, const [DollColor.orange]);
      parts.dispose();
      await expectLater(pending, throwsStateError);
      expect(parts.length, 0);
    });

    test('a skin that fails throws, for the placeholder fallback', () async {
      final broken = SkinRasterizer(await loadClassic())..dispose();
      final parts = DollPartRasters();
      addTearDown(parts.dispose);
      await expectLater(
        parts.prepare(
          skin: broken,
          colors: const [DollColor.red],
          symbols: DollSymbols.subtle,
          artHeightPx: 96,
        ),
        throwsStateError,
      );
      expect(parts.length, 0);
      // The cache keeps working.
      final set = await prepare(parts, const [DollColor.red]);
      set.dispose();
    });

    test('rejects a zero height', () async {
      final parts = DollPartRasters();
      addTearDown(parts.dispose);
      await expectLater(
        prepare(parts, const [DollColor.red], px: 0),
        throwsArgumentError,
      );
    });
  });

  group('DollPartRasters.preparePlaceholder', () {
    late SymbolAtlas atlas;
    late PlaceholderDollPainter painter;
    late DollPartRasters parts;
    late DollPartSet set;

    setUpAll(() async {
      atlas = await loadSymbols();
      painter = PlaceholderDollPainter(symbols: atlas);
      await painter.prepare(heights: const [384], devicePixelRatio: 1);
      parts = DollPartRasters();
      set = await parts.preparePlaceholder(
        colors: const [DollColor.red, DollColor.gold, DollColor.navy],
        symbols: DollSymbols.subtle,
        artHeightPx: _px,
        symbolAtlas: atlas,
      );
    });

    tearDownAll(() {
      set.dispose();
      parts.dispose();
      painter.dispose();
      atlas.dispose();
    });

    test('is the placeholder art', () {
      expect(set.skinKey, DollPartRasters.placeholderKey);
      expect(set.colors, [DollColor.red, DollColor.navy, DollColor.gold]);
      expect(set.symbols, DollSymbols.subtle);
    });

    test('splits on the same row as the skin', () async {
      final split = DollPartRasters.splitRowPx(artHeightPx: _px);
      final lid = await _rowAlpha(set.lid(DollColor.red)!);
      final body = await _rowAlpha(set.body(DollColor.red)!);
      expect(lid.sublist(split).every((a) => a == 0), isTrue);
      expect(body.sublist(0, split).every((a) => a == 0), isTrue);
    });

    test(
      'lid over body is the placeholder doll, seam and symbol included',
      () async {
        for (final color in set.colors) {
          final diff = ImageDiff(
            await _painted(painter, _params(color, DollSymbols.subtle)),
            await _composed(set, color),
          );
          // One recording cut on a whole row: every pixel is the same.
          expect(diff.withinFraction, 1, reason: '${color.id} $diff');
          expect(diff.meanDiff, lessThan(0.05), reason: '${color.id} $diff');
        }
      },
    );

    test('the silhouette includes the shadow', () async {
      final diff = ImageDiff(
        await _painted(painter, _params(null, DollSymbols.subtle)),
        await _composed(set, null),
      );
      expect(diff.withinFraction, 1, reason: '$diff');
      final alpha = await _rowAlpha(set.silhouette);
      expect(alpha[(760 * _r).round()], greaterThan(0));
    });
  });

  group('byte budget (m2-lottie-design §4)', () {
    test('five colours and the silhouette at 150 dp × DPR 3', () async {
      final px = DollPartRasters.artHeightPxFor(
        tallestDollHeight: 150,
        devicePixelRatio: 3,
      );
      final parts = DollPartRasters();
      addTearDown(parts.dispose);
      final set = await parts.preparePlaceholder(
        colors: const [
          DollColor.red,
          DollColor.blue,
          DollColor.green,
          DollColor.yellow,
          DollColor.purple,
        ],
        symbols: DollSymbols.subtle,
        artHeightPx: px,
      );
      addTearDown(set.dispose);
      // "At 150 dp × DPR 3 = 450 px, a part is 300×450 = 0.54 MB."
      const part = 300 * 450 * 4;
      expect(part, 540000);
      expect(set.widthPx * set.artHeightPx * 4, part);
      // "Five colours plus the silhouette come to about 5.9 MB."
      expect(set.byteSize, 11 * part);
      expect(set.byteSize, lessThan(6000000));
      // The cache holds the same pixels once, not twice.
      expect(parts.byteSize, set.byteSize);
      // "…and gold adds 1.1."
      final gold = await parts.preparePlaceholder(
        colors: const [
          DollColor.red,
          DollColor.blue,
          DollColor.green,
          DollColor.yellow,
          DollColor.purple,
          DollColor.gold,
        ],
        symbols: DollSymbols.subtle,
        artHeightPx: px,
      );
      addTearDown(gold.dispose);
      expect(gold.byteSize - set.byteSize, 2 * part);
      expect(gold.byteSize - set.byteSize, lessThan(1100000));
      // The default cache budget holds a worst-case board twice over.
      expect(parts.maxBytes, greaterThan(2 * gold.byteSize));
    });
  });
}
