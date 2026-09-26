// Goldens without committed binaries (design doc §3): each expectation is a
// design reference render (design/skins/classic/renders/*.svg, produced by
// design/generator/nesty-doll.js) rasterized with flutter_svg, and the
// actual image is SvgSkinRenderer drawing the same doll from the split,
// cropped, cached layers. Both at half the artboard (256 wide).
import 'dart:typed_data';
import 'dart:ui' show Rect;

import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_core/nesty_core.dart';
import 'package:nesty_render/nesty_render.dart';

import 'support/render_test_support.dart';

const _width = 256;
const _height = 384; // the doll height: the full artboard at scale 0.5
const _scale = _height / 768;

// The `_open` renders use viewBox "0 -140 512 908" for the raised lid.
const _openTop = -140;
const _openHeight = 908;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late SkinRasterizer rasterizer;
  late SymbolAtlas symbols;
  late SvgSkinRenderer renderer;

  setUpAll(() async {
    rasterizer = SkinRasterizer(await loadClassic());
    symbols = await loadSymbols();
    renderer = SvgSkinRenderer(rasterizer: rasterizer, symbols: symbols);
    await renderer.prepare(heights: const [384], devicePixelRatio: 1);
  });

  tearDownAll(() {
    renderer.dispose();
    symbols.dispose();
    rasterizer.dispose();
  });

  Future<Uint8List> expected(String render) async {
    final image = await rasterizeSvg(readRender(render), scale: _scale);
    final bytes = await rgbaOf(image);
    image.dispose();
    return bytes;
  }

  Future<Uint8List> actual(
    void Function(DollPaintParams p) setUp, {
    int viewTop = 0,
    int viewHeight = 768,
  }) async {
    final params = DollPaintParams()
      ..height = _height.toDouble()
      ..baseX = 256 * _scale
      ..baseY = (742 - viewTop) * _scale;
    setUp(params);
    final image = await capture(
      _width,
      (viewHeight * _scale).round(),
      (canvas) => renderer.paint(canvas, params),
    );
    final bytes = await rgbaOf(image);
    image.dispose();
    return bytes;
  }

  void expectMatch(Uint8List a, Uint8List b, String what) {
    final diff = ImageDiff(a, b);
    printOnFailure('$what: $diff');
    // Design doc §3 set ≥ 99 % of pixels within 8/255 and a mean below
    // 1.5/255. The renderer reaches ≥ 99.98 % and ≤ 0.14, and a 1 % slack
    // let a missing subtle symbol pass (review RENDER-5), so the gate is
    // what the renderer achieves, with headroom.
    expect(diff.withinFraction, greaterThanOrEqualTo(0.999), reason: '$diff');
    expect(diff.meanDiff, lessThan(0.5), reason: '$diff');
  }

  // The belly symbol's box (tokens `skin.symbolAnchor`, `symbolSize`; the
  // large mode's disc of `badgeRadius`), in the 256-wide image: the colour-
  // blind cue (spec §12.3) is compared on its own, so a symbol regression
  // can't hide in the whole doll's pixel count.
  final subtleBox = Rect.fromCenter(
    center: SkinTokens.symbolAnchor * _scale,
    width: SkinTokens.symbolSize * _scale,
    height: SkinTokens.symbolSize * _scale,
  );
  final largeBox = Rect.fromCircle(
    center: SkinTokens.symbolAnchor * _scale,
    radius: (SkinTokens.badgeRadius + SkinTokens.badgeStroke) * _scale,
  );

  // Measured: ≤ 0.23/255 (subtle), ≤ 0.07/255 (large) over the box.
  const symbolMeanGate = 0.5;

  void expectSymbolMatch(Uint8List a, Uint8List b, Rect box, String what) {
    final diff = ImageDiff(cropRgba(a, _width, box), cropRgba(b, _width, box));
    printOnFailure('$what symbol box: $diff');
    expect(diff.withinFraction, greaterThanOrEqualTo(0.995), reason: '$diff');
    expect(diff.meanDiff, lessThan(symbolMeanGate), reason: '$diff');
  }

  group('closed, subtle symbol', () {
    for (final color in DollColor.values) {
      test('${color.id} matches renders/${color.id}.svg', () async {
        final want = await expected(color.id);
        final got = await actual((p) => p.color = color);
        expectMatch(want, got, color.id);
        expectSymbolMatch(want, got, subtleBox, color.id);
      });
    }
  });

  group('open lid', () {
    for (final color in DollColor.values) {
      test('${color.id} matches renders/${color.id}_open.svg', () async {
        expectMatch(
          await expected('${color.id}_open'),
          await actual(
            (p) => p
              ..color = color
              ..lidLift = rasterizer.manifest.openLidLift,
            viewTop: _openTop,
            viewHeight: _openHeight,
          ),
          '${color.id}_open',
        );
      });
    }
  });

  group('large symbols', () {
    for (final color in DollColor.values) {
      test(
        '${color.id} matches renders/${color.id}_large_symbol.svg',
        () async {
          final want = await expected('${color.id}_large_symbol');
          final got = await actual(
            (p) => p
              ..color = color
              ..symbols = DollSymbols.large,
          );
          expectMatch(want, got, '${color.id}_large_symbol');
          expectSymbolMatch(want, got, largeBox, '${color.id}_large_symbol');
        },
      );
    }
  });

  test('silhouette matches renders/silhouette.svg', () async {
    expectMatch(
      await expected('silhouette'),
      await actual(
        (p) => p
          ..silhouette = true
          // Ignored for silhouettes (spec §3.2: the colour stays hidden).
          ..color = DollColor.blue,
      ),
      'silhouette',
    );
  });

  group('the comparison has teeth', () {
    test('the expectation is a real doll, not an empty image', () async {
      final red = await expected('red');
      var opaque = 0;
      for (var i = 3; i < red.length; i += 4) {
        if (red[i] == 255) opaque++;
      }
      // The doll covers well over a third of its 2:3 box.
      expect(opaque / (red.length / 4), greaterThan(0.4));
    });

    test('another colour fails the gate', () async {
      final diff = ImageDiff(
        await expected('red'),
        await actual((p) => p.color = DollColor.pink),
      );
      expect(diff.withinFraction, lessThan(0.9), reason: '$diff');
    });

    test('a missing symbol fails the gate', () async {
      final diff = ImageDiff(
        await expected('red_large_symbol'),
        await actual(
          (p) => p
            ..color = DollColor.red
            ..symbols = DollSymbols.none,
        ),
      );
      expect(diff.withinFraction, lessThan(0.99), reason: '$diff');
    });

    // Review RENDER-5: the default (subtle) symbol is the colour-blind cue,
    // and it scored 99.02 % against its render when missing, inside the old
    // 1 % slack.
    for (final color in [DollColor.red, DollColor.navy, DollColor.yellow]) {
      test('a missing subtle symbol fails ($color)', () async {
        final want = await expected(color.id);
        final got = await actual(
          (p) => p
            ..color = color
            ..symbols = DollSymbols.none,
        );
        final whole = ImageDiff(want, got);
        final box = ImageDiff(
          cropRgba(want, _width, subtleBox),
          cropRgba(got, _width, subtleBox),
        );
        expect(whole.withinFraction, lessThan(0.999), reason: '$whole');
        expect(box.withinFraction, lessThan(0.995), reason: '$box');
      });
    }

    test('subtle ink at 100 % instead of 94 % fails the symbol box', () async {
      // The render with its symbol at full ink (the one opacity="0.94" in
      // it is the symbol's): each ink pixel moves by only ~5/255, inside the
      // per-pixel tolerance, so only the symbol box's mean can tell.
      final source = readRender('red');
      expect('opacity="0.94"'.allMatches(source), hasLength(1));
      final image = await rasterizeSvg(
        source.replaceFirst('opacity="0.94"', 'opacity="1"'),
        scale: _scale,
      );
      final fullInk = await rgbaOf(image);
      image.dispose();
      final got = await actual((p) => p.color = DollColor.red);
      final box = ImageDiff(
        cropRgba(fullInk, _width, subtleBox),
        cropRgba(got, _width, subtleBox),
      );
      expect(
        box.meanDiff,
        greaterThanOrEqualTo(symbolMeanGate),
        reason: '$box',
      );
    });

    test('a 4 px shift fails the gate', () async {
      final diff = ImageDiff(
        await expected('red'),
        await actual(
          (p) => p
            ..color = DollColor.red
            ..baseX += 4,
        ),
      );
      expect(diff.withinFraction, lessThan(0.99), reason: '$diff');
    });
  });

  group('parts', () {
    test('body then lid equals the whole closed doll', () async {
      final full = await actual((p) => p.color = DollColor.teal);
      final params = DollPaintParams()
        ..color = DollColor.teal
        ..height = _height.toDouble()
        ..baseX = 128
        ..baseY = 742 * _scale;
      final image = await capture(_width, _height, (canvas) {
        renderer
          ..paint(canvas, params..part = DollPart.body)
          ..paint(canvas, params..part = DollPart.lid);
      });
      expectMatch(full, await rgbaOf(image), 'body + lid');
      image.dispose();
    });

    test('a raised lid alone leaves the body out', () async {
      final lid = await actual(
        (p) => p
          ..color = DollColor.blue
          ..part = DollPart.lid
          ..lidLift = 0.3,
        viewTop: -300,
        viewHeight: 1068,
      );
      // Nothing is painted below the raised lid's hem (art y 412 − 0.3·768,
      // plus the crop padding).
      final hemRow = ((412 - 0.3 * 768 + 300 + 16) * _scale).ceil();
      var belowHem = 0;
      for (var i = hemRow * _width * 4 + 3; i < lid.length; i += 4) {
        if (lid[i] != 0) belowHem++;
      }
      expect(belowHem, 0);
    });
  });

  group('effects', () {
    test('reveal 0 is the silhouette and reveal 1 the coloured doll', () async {
      expectMatch(
        await actual((p) => p.silhouette = true),
        await actual(
          (p) => p
            ..color = DollColor.green
            ..reveal = 0,
        ),
        'reveal 0',
      );
      expectMatch(
        await actual((p) => p.color = DollColor.green),
        await actual(
          (p) => p
            ..color = DollColor.green
            ..reveal = 1,
        ),
        'reveal 1',
      );
    });

    test('mid reveal is coloured at the belly and wood at the top', () async {
      final half = await actual(
        (p) => p
          ..color = DollColor.green
          ..reveal = 0.4,
      );
      final silhouette = await actual((p) => p.silhouette = true);
      final coloured = await actual((p) => p.color = DollColor.green);
      int at(int x, int y) => (y * _width + x) * 4;
      final belly = at(128, (476 * _scale).round()); // the wipe's centre
      final crown = at(128, (60 * _scale).round()); // head top: outside
      expect(
        half.sublist(belly, belly + 4),
        coloured.sublist(belly, belly + 4),
      );
      expect(
        half.sublist(crown, crown + 4),
        silhouette.sublist(crown, crown + 4),
      );
    });

    test('the shine brightens only pixels inside the doll', () async {
      final plain = await actual((p) => p.color = DollColor.navy);
      final shiny = await actual(
        (p) => p
          ..color = DollColor.navy
          ..shine = 0.5,
      );
      var brighter = 0;
      var outside = 0;
      for (var i = 0; i < plain.length; i += 4) {
        final changed = shiny[i] != plain[i] || shiny[i + 3] != plain[i + 3];
        if (!changed) continue;
        if (plain[i + 3] == 0) outside++;
        if (shiny[i] > plain[i]) brighter++;
      }
      expect(outside, 0);
      expect(brighter, greaterThan(1000));
    });

    test('shine at 0 and 1 is clear of the doll', () async {
      final plain = await actual((p) => p.color = DollColor.navy);
      for (final t in [0.0, 1.0]) {
        expectMatch(
          plain,
          await actual(
            (p) => p
              ..color = DollColor.navy
              ..shine = t,
          ),
          'shine $t',
        );
      }
    });

    test('opacity 0.5 halves the alpha of the whole doll', () async {
      final solid = await actual((p) => p.color = DollColor.orange);
      final faded = await actual(
        (p) => p
          ..color = DollColor.orange
          ..opacity = 0.5,
      );
      for (var i = 3; i < solid.length; i += 4 * 97) {
        expect((faded[i] - solid[i] * 0.5).abs(), lessThanOrEqualTo(2));
      }
    });

    test('opacity 0 draws nothing', () async {
      final none = await actual(
        (p) => p
          ..color = DollColor.orange
          ..opacity = 0,
      );
      expect(none.every((b) => b == 0), isTrue);
    });
  });
}
