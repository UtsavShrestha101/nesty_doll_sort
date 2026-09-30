import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_game/core/ui/art/theme_thumbnail_loader.dart';
import 'package:nesty_render/nesty_render.dart' show ChapterTheme;

import 'support/ui_harness.dart';

/// A bundle that answers every theme's `background.svg` with one flat SVG
/// (1290 wide like the real art, a saturated red), so the loader runs its
/// real crop and raster path without the multi-megabyte art.
class _FlatBundle extends CachingAssetBundle {
  int loads = 0;

  @override
  Future<ByteData> load(String key) async {
    loads++;
    final svg = utf8.encode(
      '<svg xmlns="http://www.w3.org/2000/svg" width="1290" height="2796" '
      'viewBox="0 0 1290 2796"><rect width="1290" height="2796" '
      'fill="#FF0000"/></svg>',
    );
    return ByteData.sublistView(Uint8List.fromList(svg));
  }
}

/// The thumbnails of the phase 4 architecture §3.2 (lead note 4): the crop of
/// each chapter's art at a card's size, kept in an LRU, one header image, and
/// `palette.band` until an image lands.
void main() {
  setUpAll(loadBundledFonts);

  const rowBox = Size(84, 42);

  test('renders the crop at the box size times the pixel ratio', () async {
    final loader = AssetThemeThumbnailLoader(bundle: _FlatBundle());
    addTearDown(loader.clear);
    final image = await loader.thumbnail(
      ChapterTheme.ch03,
      box: const Size(158, 74),
      devicePixelRatio: 2,
    );
    expect(image, isNotNull);
    expect(image!.width, 316);
    expect(image.height, 148);
  });

  test('the pixel ratio is capped at 2 like the theme background', () async {
    final loader = AssetThemeThumbnailLoader(bundle: _FlatBundle());
    addTearDown(loader.clear);
    final image = await loader.thumbnail(
      ChapterTheme.ch01,
      box: rowBox,
      devicePixelRatio: 3,
    );
    expect(image!.width, 168);
  });

  test('a second request for the same crop is the cached image, with no '
      'second decode', () async {
    final bundle = _FlatBundle();
    final loader = AssetThemeThumbnailLoader(bundle: bundle);
    addTearDown(loader.clear);
    final first = await loader.thumbnail(
      ChapterTheme.ch02,
      box: rowBox,
      devicePixelRatio: 1,
    );
    expect(
      loader.cached(ChapterTheme.ch02, box: rowBox, devicePixelRatio: 1),
      same(first),
    );
    final again = await loader.thumbnail(
      ChapterTheme.ch02,
      box: rowBox,
      devicePixelRatio: 1,
    );
    expect(again, same(first));
    expect(bundle.loads, 1);
  });

  test(
    'the locked look greys the crop (grayscale 0.7, brightness 1.06)',
    () async {
      final loader = AssetThemeThumbnailLoader(bundle: _FlatBundle());
      addTearDown(loader.clear);
      Future<List<int>> pixel(bool locked) async {
        final image = await loader.thumbnail(
          ChapterTheme.ch01,
          box: rowBox,
          devicePixelRatio: 1,
          locked: locked,
        );
        final bytes = await image!.toByteData();
        return [bytes!.getUint8(0), bytes.getUint8(1), bytes.getUint8(2)];
      }

      final normal = await pixel(false);
      final locked = await pixel(true);
      expect(normal, [255, 0, 0]);
      // CSS grayscale(.7) then brightness(1.06) on pure red: the red falls to
      // 0.3 + 0.7 x 0.2126 (x 1.06), green and blue rise to 0.7 x their luma.
      expect(locked[0], closeTo(121, 2));
      expect(locked[1], closeTo(40, 2));
      expect(locked[2], closeTo(40, 2));
    },
  );

  test('the header image is kept apart: one at a time, and it never evicts '
      'a row', () async {
    final loader = AssetThemeThumbnailLoader(bundle: _FlatBundle());
    addTearDown(loader.clear);
    final row = await loader.thumbnail(
      ChapterTheme.ch01,
      box: rowBox,
      devicePixelRatio: 1,
    );
    final headerA = await loader.thumbnail(
      ChapterTheme.ch02,
      box: const Size(358, 92),
      devicePixelRatio: 1,
    );
    final headerB = await loader.thumbnail(
      ChapterTheme.ch03,
      box: const Size(358, 92),
      devicePixelRatio: 1,
    );
    expect(loader.headerCount, 1);
    expect(headerA!.debugDisposed, isTrue, reason: 'replaced by the next');
    expect(headerB!.debugDisposed, isFalse);
    expect(row!.debugDisposed, isFalse);
    expect(loader.smallCount, 1);
  });

  test('loads run one at a time, in the order asked', () async {
    final bundle = _FlatBundle();
    final loader = AssetThemeThumbnailLoader(bundle: bundle);
    addTearDown(loader.clear);
    final futures = [
      for (final theme in [ChapterTheme.ch01, ChapterTheme.ch02])
        loader.thumbnail(theme, box: rowBox, devicePixelRatio: 1),
    ];
    final images = await Future.wait(futures);
    expect(images.every((i) => i != null), isTrue);
    expect(bundle.loads, 2);
  });

  test('a failed decode is null, never thrown (rule 3)', () async {
    final loader = AssetThemeThumbnailLoader(bundle: _BrokenBundle());
    addTearDown(loader.clear);
    final image = await loader.thumbnail(
      ChapterTheme.ch01,
      box: rowBox,
      devicePixelRatio: 1,
    );
    expect(image, isNull);
    // And it can be asked again afterwards.
    expect(
      loader.cached(ChapterTheme.ch01, box: rowBox, devicePixelRatio: 1),
      isNull,
    );
  });

  test('a degenerate box is null without touching the bundle', () async {
    final bundle = _FlatBundle();
    final loader = AssetThemeThumbnailLoader(bundle: bundle);
    expect(
      await loader.thumbnail(
        ChapterTheme.ch01,
        box: Size.zero,
        devicePixelRatio: 1,
      ),
      isNull,
    );
    expect(bundle.loads, 0);
  });

  group('ThemeThumbnail', () {
    testWidgets('is the palette band until an image lands, then the crop', (
      tester,
    ) async {
      final loader = AssetThemeThumbnailLoader(bundle: _FlatBundle());
      addTearDown(loader.clear);
      await pumpUi(
        tester,
        ThemeThumbnailScope(
          loader: loader,
          child: const Center(
            child: ThemeThumbnail(theme: ChapterTheme.ch04, size: rowBox),
          ),
        ),
      );
      expect(find.byType(RawImage), findsNothing);
      final band = tester.widget<ColoredBox>(
        find.descendant(
          of: find.byType(ThemeThumbnail),
          matching: find.byType(ColoredBox),
        ),
      );
      expect(band.color, ChapterTheme.ch04.palette.band);
      expect(tester.getSize(find.byType(ThemeThumbnail)), rowBox);

      await tester.runAsync(() async {
        await loader.thumbnail(
          ChapterTheme.ch04,
          box: rowBox,
          devicePixelRatio: 1,
        );
        await Future<void>.delayed(const Duration(milliseconds: 50));
      });
      await tester.pump();
      expect(find.byType(RawImage), findsOneWidget);
    });

    testWidgets('a failing loader leaves the band and throws nothing', (
      tester,
    ) async {
      final loader = FakeThemeThumbnailLoader();
      await pumpUi(
        tester,
        ThemeThumbnailScope(
          loader: loader,
          child: const Center(
            child: ThemeThumbnail(
              theme: ChapterTheme.ch07,
              size: Size(158, 74),
              radius: 16,
              locked: true,
            ),
          ),
        ),
      );
      await tester.pump();
      expect(find.byType(RawImage), findsNothing);
      expect(loader.requests.single.theme, ChapterTheme.ch07);
      expect(loader.requests.single.locked, isTrue);
      expect(tester.takeException(), isNull);
    });

    testWidgets('is decorative: it adds no semantics of its own', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await pumpUi(
        tester,
        ThemeThumbnailScope(
          loader: FakeThemeThumbnailLoader(),
          child: const Center(
            child: ThemeThumbnail(theme: ChapterTheme.ch01, size: rowBox),
          ),
        ),
      );
      expect(tester.getSemantics(find.byType(ThemeThumbnail)).label, isEmpty);
      handle.dispose();
    });
  });
}

class _BrokenBundle extends CachingAssetBundle {
  @override
  Future<ByteData> load(String key) async => throw FlutterError('no art');
}
