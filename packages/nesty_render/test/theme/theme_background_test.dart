// ThemeBackground (render §1 "theme_background"): the chapter SVG
// rasterized once to cover the screen, top-centre, DPR ≤ 2, one image at a
// time, over the design's fallback colour (NestyBoard:73 `BG`).
import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_render/nesty_render.dart';

import '../doll/support/render_test_support.dart';

const _reference = ui.Size(390, 844);

/// A 100 × 200 art: red band on top (y 0–10), green band at the bottom
/// (y 190–200), a blue marker at x 45–55 on y 50–60, grey elsewhere.
const _probeArt =
    '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 100 200" '
    'width="100" height="200">'
    '<rect width="100" height="200" fill="#808080"/>'
    '<rect width="100" height="10" fill="#FF0000"/>'
    '<rect y="190" width="100" height="10" fill="#00FF00"/>'
    '<rect x="45" y="50" width="10" height="10" fill="#0000FF"/>'
    '</svg>';

Future<List<int>> _pixel(ui.Image image, int x, int y) async {
  final rgba = await rgbaOf(image);
  final at = (y * image.width + x) * 4;
  return rgba.sublist(at, at + 4);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ChapterTheme', () {
    test('ids, fallback colours (tokens v3 palette band) and bundled art', () {
      expect(ChapterTheme.values.map((t) => t.id), [
        for (var n = 1; n <= 10; n++) 'ch${n.toString().padLeft(2, '0')}',
      ]);
      // m7-3 (phase 4 architecture §3.1): the fallback is the palette's
      // `band`, so ch01–ch06 leave NestyBoard's BG map too.
      expect(ChapterTheme.values.map((t) => t.fallbackColor), const [
        ui.Color(0xFFFBEAD0),
        ui.Color(0xFFE9E6E8),
        ui.Color(0xFFE6F5F7),
        ui.Color(0xFFEEF1F5),
        ui.Color(0xFF2C305F),
        ui.Color(0xFFEEF6E6),
        ui.Color(0xFFF7E6D8),
        ui.Color(0xFFFBEBD5),
        ui.Color(0xFFEFE9F4),
        ui.Color(0xFFF8E6DA),
      ]);
      for (final theme in ChapterTheme.values) {
        expect(theme.token, ChapterThemeTokens.chapters[theme.index]);
        expect(theme.token.id, theme.id);
        expect(theme.palette, same(theme.token.palette));
        expect(theme.fallbackColor, theme.palette.band);
        expect(theme.assetKey(), 'assets/themes/${theme.id}/background.svg');
        expect(
          File('$gameAssetsDir/themes/${theme.id}/background.svg').existsSync(),
          isTrue,
          reason: theme.id,
        );
        expect(ChapterTheme.byId(theme.id), theme);
      }
      expect(ChapterTheme.byId('ch99'), isNull);
    });

    test('chapter numbers map to themes; 11+ cycle the ten in order', () {
      for (var chapter = 1; chapter <= 10; chapter++) {
        expect(ChapterTheme.forChapter(chapter).chapter, chapter);
      }
      expect(ChapterTheme.forChapter(11), ChapterTheme.ch01);
      expect(ChapterTheme.forChapter(20), ChapterTheme.ch10);
      expect(() => ChapterTheme.forChapter(0), throwsArgumentError);
    });
  });

  group('ThemeCover', () {
    const art = ui.Size(1290, 2796);

    test('the reference screen is covered edge to edge', () {
      final cover = ThemeCover.of(art, _reference);
      expect(cover.scale, closeTo(390 / 1290, 1e-12));
      expect(cover.left, 0);
      expect(art.height * cover.scale, greaterThanOrEqualTo(844));
    });

    test('wide screens cut the bottom; tall ones cut both sides', () {
      final wide = ThemeCover.of(art, const ui.Size(768, 1024));
      expect(wide.scale, closeTo(768 / 1290, 1e-12));
      expect(wide.left, 0);
      final tall = ThemeCover.of(art, const ui.Size(360, 800));
      expect(tall.scale, closeTo(800 / 2796, 1e-12));
      expect(tall.left, lessThan(0));
      expect(tall.left, closeTo((360 - 1290 * 800 / 2796) / 2, 1e-9));
    });
  });

  group('ThemeBackground', () {
    test('memory math: DPR is capped at 2 (render §1: ≈ 5.3 MB)', () {
      final background = ThemeBackground.fromLoader((_) async => _probeArt);
      addTearDown(background.dispose);
      expect(background.pixelRatioFor(3), 2);
      expect(background.pixelRatioFor(1.5), 1.5);
      final at3 = background.pixelSizeFor(_reference, 3);
      expect((at3.width, at3.height), (780, 1688));
      expect(at3.width * at3.height * 4, 5266560);
      final at15 = background.pixelSizeFor(_reference, 1.5);
      expect((at15.width, at15.height), (585, 1266));
    });

    test('rasterizes the bundled art at screen size', () async {
      final background = ThemeBackground(bundle: FileAssetBundle());
      addTearDown(background.dispose);
      for (final theme in ChapterTheme.values) {
        await background.show(theme, size: _reference, devicePixelRatio: 3);
        final image = background.image!;
        expect((image.width, image.height), (780, 1688), reason: theme.id);
        expect(background.byteSize, 5266560);
        expect(background.shownTheme, theme);
        expect(background.imagePixelRatio, 2);
        expect(background.color, theme.fallbackColor);
        // The art is full-bleed: every corner is painted.
        for (final (x, y) in [(0, 0), (779, 0), (0, 1687), (779, 1687)]) {
          expect((await _pixel(image, x, y))[3], 255, reason: theme.id);
        }
      }
    });

    test('covers top-centre', () async {
      final background = ThemeBackground.fromLoader((_) async => _probeArt);
      addTearDown(background.dispose);
      // Square screen: scale 1, the art's top half shows.
      await background.show(
        ChapterTheme.ch01,
        size: const ui.Size(100, 100),
        devicePixelRatio: 1,
      );
      var image = background.image!;
      expect(await _pixel(image, 50, 2), [255, 0, 0, 255]);
      expect(await _pixel(image, 50, 55), [0, 0, 255, 255]);
      expect(await _pixel(image, 50, 99), [128, 128, 128, 255]);
      // Narrow screen: scale 1, the art is cut equally left and right, so
      // the marker at art x 45–55 lands at 20–30.
      await background.show(
        ChapterTheme.ch01,
        size: const ui.Size(50, 200),
        devicePixelRatio: 1,
      );
      image = background.image!;
      expect(await _pixel(image, 25, 55), [0, 0, 255, 255]);
      expect(await _pixel(image, 10, 55), [128, 128, 128, 255]);
      expect(await _pixel(image, 25, 195), [0, 255, 0, 255]);
      // Wide screen: scale 2, only the top quarter shows.
      await background.show(
        ChapterTheme.ch01,
        size: const ui.Size(200, 100),
        devicePixelRatio: 1,
      );
      image = background.image!;
      expect(await _pixel(image, 100, 5), [255, 0, 0, 255]);
      expect(await _pixel(image, 100, 99), [128, 128, 128, 255]);
    });

    test('holds one image at a time and reuses the parsed art', () async {
      var loads = 0;
      final background = ThemeBackground.fromLoader((_) async {
        loads++;
        return _probeArt;
      });
      addTearDown(background.dispose);
      var notified = 0;
      background.addListener(() => notified++);
      await background.show(
        ChapterTheme.ch01,
        size: const ui.Size(100, 100),
        devicePixelRatio: 2,
      );
      final first = background.image!;
      expect(notified, 1);
      // The same request again does nothing.
      await background.show(
        ChapterTheme.ch01,
        size: const ui.Size(100, 100),
        devicePixelRatio: 2,
      );
      expect(background.image, same(first));
      // A resize re-rasterizes without reloading, and frees the old image.
      await background.show(
        ChapterTheme.ch01,
        size: const ui.Size(120, 100),
        devicePixelRatio: 2,
      );
      expect(loads, 1);
      expect(first.debugDisposed, isTrue);
      expect(background.image!.width, 240);
      // A new theme loads its art.
      await background.show(
        ChapterTheme.ch02,
        size: const ui.Size(120, 100),
        devicePixelRatio: 2,
      );
      expect(loads, 2);
      expect(background.byteSize, 240 * 200 * 4);
    });

    test('the latest request wins', () async {
      final gates = <ChapterTheme, Completer<String>>{
        ChapterTheme.ch01: Completer(),
        ChapterTheme.ch02: Completer(),
      };
      final background = ThemeBackground.fromLoader(
        (theme) => gates[theme]!.future,
      );
      addTearDown(background.dispose);
      const size = ui.Size(50, 50);
      final older = background.show(
        ChapterTheme.ch01,
        size: size,
        devicePixelRatio: 1,
      );
      final newer = background.show(
        ChapterTheme.ch02,
        size: size,
        devicePixelRatio: 1,
      );
      expect(background.theme, ChapterTheme.ch02);
      expect(background.color, ChapterTheme.ch02.fallbackColor);
      gates[ChapterTheme.ch02]!.complete(_probeArt);
      await newer;
      gates[ChapterTheme.ch01]!.complete(_probeArt);
      await older;
      expect(background.shownTheme, ChapterTheme.ch02);
      expect(background.byteSize, 50 * 50 * 4);
    });

    test('bad art keeps the fallback colour and is reported', () async {
      final errors = <Object>[];
      final background = ThemeBackground.fromLoader(
        (_) async => throw const FileSystemException('gone'),
        onError: (error, _) => errors.add(error),
      );
      addTearDown(background.dispose);
      await background.show(
        ChapterTheme.ch05,
        size: _reference,
        devicePixelRatio: 2,
      );
      expect(errors, hasLength(1));
      expect(background.image, isNull);
      expect(background.color, ChapterTheme.ch05.fallbackColor);
      final painted = await capture(10, 10, (canvas) {
        ThemeBackgroundPainter(background).paint(canvas, const ui.Size(10, 10));
      });
      // ch05's palette band, #2C305F.
      expect(await _pixel(painted, 5, 5), [0x2C, 0x30, 0x5F, 0xFF]);
    });

    test('paints the raster over the colour, scaled to cover', () async {
      final background = ThemeBackground.fromLoader((_) async => _probeArt);
      addTearDown(background.dispose);
      await background.show(
        ChapterTheme.ch01,
        size: const ui.Size(100, 100),
        devicePixelRatio: 1,
      );
      final painter = ThemeBackgroundPainter(background);
      expect(painter.shouldRepaint(ThemeBackgroundPainter(background)), false);
      // Painted at twice the size it was rasterized for: still top-centred.
      final painted = await capture(200, 200, (canvas) {
        painter.paint(canvas, const ui.Size(200, 200));
      });
      expect(await _pixel(painted, 100, 5), [255, 0, 0, 255]);
      expect(await _pixel(painted, 100, 110), [0, 0, 255, 255]);
    });

    test('rejects a bad pixel ratio and use after dispose', () {
      final background = ThemeBackground.fromLoader((_) async => _probeArt)
        ..dispose();
      expect(
        () => background.show(
          ChapterTheme.ch01,
          size: _reference,
          devicePixelRatio: 2,
        ),
        throwsStateError,
      );
      final live = ThemeBackground.fromLoader((_) async => _probeArt);
      addTearDown(live.dispose);
      expect(
        () =>
            live.show(ChapterTheme.ch01, size: _reference, devicePixelRatio: 0),
        throwsArgumentError,
      );
    });
  });
}
