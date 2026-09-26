// PartRasterDollRenderer (docs/plans/m2-lottie-design.md §4, §10.2): rest
// sprites drawn from the DollPartSet the Lottie image slots show, with the
// Lottie's own transform, so sprite ↔ clip hand-offs are pixel-identical.
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_core/nesty_core.dart';
import 'package:nesty_render/nesty_render.dart';

import 'support/render_test_support.dart';

const _canvasWidth = 256;
const _canvasHeight = 400;

Future<Uint8List> _draw(void Function(ui.Canvas canvas) draw) async {
  final image = await capture(_canvasWidth, _canvasHeight, draw);
  final bytes = await rgbaOf(image);
  image.dispose();
  return bytes;
}

int _alphaSum(Uint8List rgba) {
  var total = 0;
  for (var i = 3; i < rgba.length; i += 4) {
    total += rgba[i];
  }
  return total;
}

/// What an image layer of a Lottie clip draws for a doll part once its
/// scale and anchor are compensated (m2-lottie-design §3): the raster's
/// (256r, 742r) on the base, scaled `height / (768 r)`, bilinear with
/// mipmaps, every image drawn whole.
void _lottieDraw(
  ui.Canvas canvas,
  DollPartSet set,
  List<ui.Image> images, {
  required double height,
  required double baseX,
  required double baseY,
}) {
  final r = set.artScale;
  final src = ui.Rect.fromLTWH(
    0,
    0,
    set.widthPx.toDouble(),
    set.artHeightPx.toDouble(),
  );
  final paint = ui.Paint()..filterQuality = ui.FilterQuality.medium;
  canvas
    ..save()
    ..translate(baseX, baseY)
    ..scale(height / (768 * r))
    ..translate(-256 * r, -742 * r);
  for (final image in images) {
    canvas.drawImageRect(image, src, src, paint);
  }
  canvas.restore();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late DollPartRasters parts;
  late DollPartSet placeholder;

  setUpAll(() async {
    parts = DollPartRasters();
    placeholder = await parts.preparePlaceholder(
      colors: const [DollColor.red, DollColor.teal],
      symbols: DollSymbols.large,
      artHeightPx: 387, // a multiple of 3, r = 0.504
    );
  });

  tearDownAll(() {
    placeholder.dispose();
    parts.dispose();
  });

  PartRasterDollRenderer renderer() =>
      PartRasterDollRenderer(placeholder.clone());

  DollPaintParams params({
    DollColor color = DollColor.red,
    double height = 300,
    double baseX = 128.4,
    double baseY = 331.7,
  }) => DollPaintParams()
    ..color = color
    ..height = height
    ..baseX = baseX
    ..baseY = baseY;

  group('rest sprites', () {
    test('draw body then lid exactly as the Lottie image layers do', () async {
      final r = renderer();
      addTearDown(r.dispose);
      for (final (height, baseX, baseY) in [
        (387.0, 128.0, 373.9), // the raster's own size: sampled 1:1
        (301.7, 111.3, 355.55),
        (122.2, 64.8, 140.1), // a size-1 doll, drawn down
      ]) {
        final p = params(height: height, baseX: baseX, baseY: baseY);
        final sprite = await _draw((c) => r.paint(c, p));
        final clip = await _draw(
          (c) => _lottieDraw(
            c,
            placeholder,
            [placeholder.body(p.color)!, placeholder.lid(p.color)!],
            height: height,
            baseX: baseX,
            baseY: baseY,
          ),
        );
        final diff = ImageDiff(sprite, clip, tolerance: 1);
        expect(diff.withinFraction, 1, reason: '$height: $diff');
        expect(_alphaSum(sprite), greaterThan(0));
      }
    });

    test('the silhouette is its one raster', () async {
      final r = renderer();
      addTearDown(r.dispose);
      final p = params()..silhouette = true;
      final sprite = await _draw((c) => r.paint(c, p));
      final clip = await _draw(
        (c) => _lottieDraw(
          c,
          placeholder,
          [placeholder.silhouette],
          height: p.height,
          baseX: p.baseX,
          baseY: p.baseY,
        ),
      );
      expect(ImageDiff(sprite, clip, tolerance: 1).withinFraction, 1);
    });

    test('draws the lid alone, the body alone, and lifts the lid', () async {
      final r = renderer();
      addTearDown(r.dispose);
      final p = params();
      Future<Uint8List> as(DollPart part, {double lidLift = 0}) => _draw(
        (c) => r.paint(
          c,
          p
            ..part = part
            ..lidLift = lidLift,
        ),
      );
      final full = await as(DollPart.full);
      final lid = await as(DollPart.lid);
      final body = await as(DollPart.body);
      expect(_alphaSum(lid), greaterThan(0));
      expect(_alphaSum(body), greaterThan(0));
      // Disjoint parts: their alpha adds up to the doll's (± resampling).
      expect(
        (_alphaSum(lid) + _alphaSum(body) - _alphaSum(full)).abs(),
        lessThan(_alphaSum(full) * 0.01),
      );
      expect(await as(DollPart.bodyFront), body);
      expect(_alphaSum(await as(DollPart.interior)), 0);
      // A raised lid moves up by lidLift × height.
      final raised = await as(DollPart.lid, lidLift: 0.1);
      int topRow(Uint8List rgba) {
        for (var i = 3; i < rgba.length; i += 4) {
          if (rgba[i] > 0) return (i ~/ 4) ~/ _canvasWidth;
        }
        return -1;
      }

      expect(topRow(lid) - topRow(raised), closeTo(0.1 * p.height, 1));
    });

    test('fades, scales and rotates about the base', () async {
      final r = renderer();
      addTearDown(r.dispose);
      final solid = _alphaSum(await _draw((c) => r.paint(c, params())));
      final half = _alphaSum(
        await _draw((c) => r.paint(c, params()..opacity = 0.5)),
      );
      expect(half / solid, closeTo(0.5, 0.01));
      expect(
        _alphaSum(await _draw((c) => r.paint(c, params()..opacity = 0))),
        0,
      );
      final squashed = _alphaSum(
        await _draw((c) => r.paint(c, params()..scaleY = 0.5)),
      );
      expect(squashed / solid, closeTo(0.5, 0.02));
      // A full turn is the upright doll.
      final upright = await _draw((c) => r.paint(c, params()));
      final turned = await _draw(
        (c) => r.paint(c, params()..rotation = 2 * math.pi),
      );
      expect(ImageDiff(upright, turned).withinFraction, greaterThan(0.999));
    });

    test('bakes in shadow and symbols, ignores shine and reveal', () async {
      final r = renderer();
      addTearDown(r.dispose);
      final plain = await _draw((c) => r.paint(c, params()));
      for (final change in <void Function(DollPaintParams)>[
        (p) => p.shadow = false,
        (p) => p.symbols = DollSymbols.none,
        (p) => p.shine = 0.5,
        (p) => p.reveal = 0.5,
        (p) => p.open = true,
      ]) {
        final p = params();
        change(p);
        expect(await _draw((c) => r.paint(c, p)), plain);
      }
    });

    test('a colour the set lacks draws nothing', () async {
      final r = renderer();
      addTearDown(r.dispose);
      final p = params(color: DollColor.gold);
      expect(_alphaSum(await _draw((c) => r.paint(c, p))), 0);
    });

    test(
      'is ready for every height until disposed, and owns its set',
      () async {
        final set = placeholder.clone();
        final r = PartRasterDollRenderer(set);
        await r.prepare(heights: const [50, 120], devicePixelRatio: 3);
        expect(r.isReadyFor(10), isTrue);
        expect(r.canPaint(400), isTrue);
        r.dispose();
        expect(set.debugDisposed, isTrue);
        expect(r.isReadyFor(10), isFalse);
        expect(r.canPaint(10), isFalse);
        expect(_alphaSum(await _draw((c) => r.paint(c, params()))), 0);
        await expectLater(
          r.prepare(heights: const [50], devicePixelRatio: 3),
          throwsStateError,
        );
        r.dispose(); // idempotent
      },
    );

    test('works as a FallbackDollRenderer primary', () async {
      final fallback = FallbackDollRenderer(
        primary: renderer(),
        fallback: PlaceholderDollPainter(),
      );
      addTearDown(fallback.dispose);
      await fallback.prepare(heights: const [300], devicePixelRatio: 1);
      final direct = renderer();
      addTearDown(direct.dispose);
      expect(
        await _draw((c) => fallback.paint(c, params())),
        await _draw((c) => direct.paint(c, params())),
      );
    });
  });

  group('classic skin', () {
    late SkinRasterizer rasterizer;
    late SymbolAtlas atlas;
    late SvgSkinRenderer svg;
    late PartRasterDollRenderer sprites;

    setUpAll(() async {
      rasterizer = SkinRasterizer(await loadClassic());
      atlas = await loadSymbols();
      svg = SvgSkinRenderer(rasterizer: rasterizer, symbols: atlas);
      await svg.prepare(heights: const [384], devicePixelRatio: 1);
      sprites = PartRasterDollRenderer(
        await parts.prepare(
          skin: rasterizer,
          colors: DollColor.values,
          symbols: DollSymbols.subtle,
          artHeightPx: 384,
          symbolAtlas: atlas,
        ),
      );
    });

    tearDownAll(() {
      sprites.dispose();
      svg.dispose();
      atlas.dispose();
      rasterizer.dispose();
    });

    test('at the raster size it is SvgSkinRenderer outside the band', () async {
      // Both sample their rasters 1:1 here: the base (128, 371) is the art
      // base at r = 0.5 on whole pixels.
      for (final color in [DollColor.red, DollColor.gold, DollColor.navy]) {
        final p = DollPaintParams()
          ..color = color
          ..height = 384
          ..baseX = 128
          ..baseY = 371;
        final want = await _draw((c) => svg.paint(c, p));
        final got = await _draw((c) => sprites.paint(c, p));
        for (final band in [
          const ui.Rect.fromLTRB(0, 0, 256, 194),
          const ui.Rect.fromLTRB(0, 206, 256, 400),
        ]) {
          final diff = ImageDiff(
            cropRgba(want, _canvasWidth, band),
            cropRgba(got, _canvasWidth, band),
          );
          expect(
            diff.withinFraction,
            greaterThanOrEqualTo(0.9999),
            reason: '${color.id} $diff',
          );
        }
      }
    });
  });
}
