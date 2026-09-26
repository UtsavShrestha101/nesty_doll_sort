import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_render/nesty_render.dart';

import '../doll/support/render_test_support.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late SymbolAtlas atlas;

  setUpAll(() async {
    atlas = await loadSymbols();
  });

  tearDownAll(() => atlas.dispose());

  group('SymbolAtlas', () {
    test("loads every palette colour's symbol", () {
      expect(atlas.names, hasLength(11));
      for (final swatch in DollPalette.values) {
        expect(atlas.indexOf(swatch.symbol), greaterThanOrEqualTo(0));
      }
      expect(atlas.indexOf('umbrella'), -1);
      expect(atlas.geometry, SymbolGeometry.standard);
    });

    test('lays out whole-pixel cells around the design boxes', () async {
      final page = await atlas.obtain(384);
      addTearDown(page.dispose);
      expect(page.pxPerArt, 0.5);
      // 110 and 117 art-unit boxes centred on (256, 590), plus 1 px margins.
      final subtle = SymbolGeometry.standard.box(large: false);
      final large = SymbolGeometry.standard.box(large: true);
      expect(page.subtleDst.contains(subtle.topLeft), isTrue);
      expect(
        page.subtleDst.contains(subtle.bottomRight - const Offset(1e-3, 1e-3)),
        isTrue,
      );
      expect(page.largeDst.contains(large.topLeft), isTrue);
      for (final dst in [page.subtleDst, page.largeDst]) {
        for (final edge in [dst.left, dst.top, dst.right, dst.bottom]) {
          final px = edge * page.pxPerArt;
          expect(px, closeTo(px.roundToDouble(), 1e-6));
        }
      }
      for (var i = 0; i < atlas.names.length; i++) {
        expect(page.subtleSrc(i).width, page.subtleDst.width * 0.5);
        expect(page.largeSrc(i).height, page.largeDst.height * 0.5);
      }
    });

    test('cells are white alpha masks with content', () async {
      final page = await atlas.obtain(200);
      addTearDown(page.dispose);
      final rgba = await rgbaOf(page.image);
      var covered = 0;
      for (var i = 0; i < rgba.length; i += 4) {
        final a = rgba[i + 3];
        if (a == 0) continue;
        covered++;
        // Premultiplied white: every colour channel equals alpha.
        expect(rgba[i], a);
        expect(rgba[i + 1], a);
        expect(rgba[i + 2], a);
      }
      expect(covered, greaterThan(atlas.names.length * 50));
    });

    test('keeps at most maxPages pages; clones outlive eviction', () async {
      final small = await SymbolAtlas.load(FileAssetBundle(), maxPages: 2);
      addTearDown(small.dispose);
      final first = await small.obtain(100);
      (await small.obtain(110)).dispose();
      (await small.obtain(120)).dispose();
      expect(first.image.debugDisposed, isFalse);
      first.dispose();
      small.clear();
      final again = await small.obtain(100);
      expect(again.artHeightPx, 100);
      again.dispose();
    });

    test('refuses work after dispose', () async {
      final own = await SymbolAtlas.load(FileAssetBundle(), names: ['heart']);
      expect(own.names, ['heart']);
      own.dispose();
      expect(own.obtain(100), throwsStateError);
    });
  });
}
