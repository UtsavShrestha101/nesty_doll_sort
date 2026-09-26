// SymbolRaster: the unlock colour's symbol in its ink for the padlock's
// `unlock_symbol` Lottie slot (12 × 12, docs/plans/m2-lottie-design.md §3).
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_core/nesty_core.dart';
import 'package:nesty_render/nesty_render.dart';

import '../doll/support/render_test_support.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late SymbolAtlas atlas;

  setUpAll(() async => atlas = await loadSymbols());
  tearDownAll(() => atlas.dispose());

  /// Draws [raster] into a 12-unit box at [px] device px per unit as a
  /// compensated Lottie image layer (authored scale 1, anchor (6, 6) at
  /// the box centre).
  Future<Uint8List> asLottie(SymbolRaster raster, double px) async {
    final side = (12 * px).ceil();
    final image = await capture(side, side, (canvas) {
      const a = ui.Offset(6, 6);
      final anchor = (a - raster.origin) * raster.scale;
      final whole =
          ui.Offset.zero &
          ui.Size(raster.image.width * 1.0, raster.image.height * 1.0);
      canvas
        ..scale(px)
        ..translate(a.dx, a.dy)
        ..scale(1 / raster.scale)
        ..translate(-anchor.dx, -anchor.dy)
        ..drawImageRect(
          raster.image,
          whole,
          whole,
          ui.Paint()..filterQuality = ui.FilterQuality.medium,
        );
    });
    final bytes = await rgbaOf(image);
    image.dispose();
    return bytes;
  }

  test('is the atlas cell 1:1, placed by scale and origin', () async {
    for (final px in [3.0, 2.625, 1.0]) {
      final raster = await SymbolRaster.rasterize(
        atlas,
        DollColor.teal,
        pixelsPerUnit: px,
      );
      addTearDown(raster!.dispose);
      expect(raster.side, 12);
      // The page height is whole px: within one page px of the request.
      expect(raster.scale, closeTo(px, 12 / 110 * 768 / 110));
      // The cell's 1 px margin (and its outward snap) reach past the box.
      expect(raster.origin.dx, lessThan(0));
      expect(raster.origin.dx, greaterThan(-2.5 / raster.scale));
      expect(raster.origin.dy, lessThan(0));
      expect(raster.origin.dy, greaterThan(-2.5 / raster.scale));
      expect(
        raster.image.width,
        greaterThanOrEqualTo((12 * raster.scale).floor()),
      );
      expect(raster.byteSize, raster.image.width * raster.image.height * 4);
    }
  });

  test('draws the symbol in its ink inside the box', () async {
    const px = 3.0;
    final raster = await SymbolRaster.rasterize(
      atlas,
      DollColor.navy,
      pixelsPerUnit: px,
    );
    addTearDown(raster!.dispose);
    final rgba = await asLottie(raster, px);
    final ink = DollPalette.of(DollColor.navy).ink;
    var opaque = 0;
    for (var i = 0; i < rgba.length; i += 4) {
      if (rgba[i + 3] != 255) continue;
      opaque++;
      expect(
        [rgba[i], rgba[i + 1], rgba[i + 2]],
        [(ink.r * 255).round(), (ink.g * 255).round(), (ink.b * 255).round()],
      );
    }
    expect(opaque, greaterThan(20));
  });

  test("matches the debug board's padlock symbol", () async {
    // DebugBoardPainter maps the atlas's subtle box onto the padlock square
    // (the static fallback of m2-lottie-design §8).
    const px = 3.0;
    final raster = await SymbolRaster.rasterize(
      atlas,
      DollColor.orange,
      pixelsPerUnit: px,
    );
    addTearDown(raster!.dispose);
    final page = await atlas.obtain(251); // 12 × 3 px over the 110 box
    addTearDown(page.dispose);
    final index = atlas.indexOf(DollPalette.of(DollColor.orange).symbol);
    final box = atlas.geometry.box(large: false);
    final k = 12 / box.width;
    final cell = page.subtleDst;
    final want = await capture(36, 36, (canvas) {
      canvas
        ..scale(px)
        ..drawImageRect(
          page.image,
          page.subtleSrc(index),
          ui.Rect.fromLTRB(
            (cell.left - box.left) * k,
            (cell.top - box.top) * k,
            (cell.right - box.left) * k,
            (cell.bottom - box.top) * k,
          ),
          ui.Paint()
            ..filterQuality = ui.FilterQuality.medium
            ..colorFilter = ui.ColorFilter.mode(
              DollPalette.of(DollColor.orange).ink,
              ui.BlendMode.srcIn,
            ),
        );
    });
    final diff = ImageDiff(await rgbaOf(want), await asLottie(raster, px));
    want.dispose();
    expect(diff.withinFraction, greaterThan(0.99), reason: '$diff');
    expect(diff.meanDiff, lessThan(1), reason: '$diff');
  });

  test('clones dispose independently; no symbol is null', () async {
    final raster = await SymbolRaster.rasterize(
      atlas,
      DollColor.red,
      pixelsPerUnit: 2,
    );
    final clone = raster!.clone();
    raster.dispose();
    expect(clone.image.debugDisposed, isFalse);
    clone.dispose();

    final empty = await SymbolAtlas.fromSvgs(const {});
    addTearDown(empty.dispose);
    expect(
      await SymbolRaster.rasterize(empty, DollColor.red, pixelsPerUnit: 2),
      isNull,
    );
    await expectLater(
      SymbolRaster.rasterize(atlas, DollColor.red, pixelsPerUnit: 0),
      throwsArgumentError,
    );
  });
}
