import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/painting.dart' show ColorFilter;
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_render/nesty_render.dart';

import '../doll/support/render_test_support.dart';

const _square =
    '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 100 50">'
    '<rect x="10" y="10" width="20" height="20" fill="#808080"/></svg>';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('rasterizeSvg', () {
    test('defaults to the SVG size times the scale', () async {
      final image = await rasterizeSvg(_square, scale: 2);
      addTearDown(image.dispose);
      expect(image.width, 200);
      expect(image.height, 100);
      expect(await alphaBounds(image), const ui.Rect.fromLTRB(20, 20, 60, 60));
    });

    test('crops with left/top and an explicit size', () async {
      final image = await rasterizeSvg(
        _square,
        scale: 1,
        left: 10,
        top: 10,
        width: 20,
        height: 20,
      );
      addTearDown(image.dispose);
      final rgba = await rgbaOf(image);
      expect(rgba.every((b) => b == 0x80 || b == 0xFF), isTrue);
    });

    test('applies a colour filter', () async {
      final image = await rasterizeSvg(
        _square,
        scale: 1,
        colorFilter: const ColorFilter.mode(
          ui.Color(0xFFFF0000),
          ui.BlendMode.modulate,
        ),
      );
      addTearDown(image.dispose);
      final rgba = await rgbaOf(image);
      final at = (15 * 100 + 15) * 4;
      expect(rgba.sublist(at, at + 4), [0x80, 0, 0, 0xFF]);
    });

    test('evicts its bytes from the flutter_svg cache', () async {
      const loader = SvgStringLoader(_square);
      final info = await loadSvgPicture(_square);
      info.picture.dispose();
      expect(svg.cache.evict(loader.cacheKey(null)), isFalse);
    });
  });

  group('rasterizePictures', () {
    test('draws parts in order with group opacity', () async {
      final info = await loadSvgPicture(_square);
      addTearDown(info.picture.dispose);
      final image = await rasterizePictures(
        [SvgRasterPart(info.picture, opacity: 0.5)],
        width: 100,
        height: 50,
        scale: 1,
      );
      addTearDown(image.dispose);
      final rgba = await rgbaOf(image);
      final at = (15 * 100 + 15) * 4;
      expect(rgba[at + 3], closeTo(128, 1));
    });
  });

  group('alphaBoundsOf', () {
    test('finds the opaque box, exclusive right/bottom', () {
      final bytes = ByteData(4 * 5 * 4);
      bytes.setUint8((1 * 5 + 2) * 4 + 3, 1);
      bytes.setUint8((3 * 5 + 3) * 4 + 3, 255);
      expect(alphaBoundsOf(bytes, 5, 4), const ui.Rect.fromLTRB(2, 1, 4, 4));
    });

    test('is null when everything is transparent', () {
      expect(alphaBoundsOf(ByteData(4 * 3 * 3), 3, 3), isNull);
    });
  });
}
