import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_game/features/daily/widgets/daily_background_loader.dart';
import 'package:nesty_render/nesty_render.dart' show ChapterTheme;

/// [AssetDailyBackgroundLoader] (m7-design §18 "the Daily puzzle card's
/// preview"): the real bundled SVG, cropped to the card's own box and
/// capped device pixel ratio, rasterized synchronously (`toImageSync`, not
/// `rasterizePictures`' async `toImage`, which needs `runAsync` to ever
/// complete in a test — see `puzzle_card_test.dart`'s regression group).
void main() {
  const loader = AssetDailyBackgroundLoader();

  testWidgets('rasterizes to exactly box × the capped pixel ratio', (
    tester,
  ) async {
    await tester.runAsync(() async {
      final image = await loader.rasterize(
        ChapterTheme.ch03,
        box: const Size(300, 120),
        devicePixelRatio: 2,
      );
      expect(image, isNotNull);
      expect(image!.width, 600);
      expect(image.height, 240);
    });
  });

  testWidgets('caps the pixel ratio like ThemeBackground\'s (2×)', (
    tester,
  ) async {
    await tester.runAsync(() async {
      final image = await loader.rasterize(
        ChapterTheme.ch03,
        box: const Size(100, 50),
        devicePixelRatio: 5,
      );
      expect(image, isNotNull);
      expect(image!.width, 200);
      expect(image.height, 100);
    });
  });

  testWidgets('an empty or non-finite box never asks the bundle, rule 3', (
    tester,
  ) async {
    final bundle = _CountingBundle();
    final withBundle = AssetDailyBackgroundLoader(bundle: bundle);
    for (final box in [
      Size.zero,
      const Size(-1, 120),
      const Size(300, double.infinity),
      const Size(double.nan, 120),
    ]) {
      final image = await withBundle.rasterize(
        ChapterTheme.ch03,
        box: box,
        devicePixelRatio: 2,
      );
      expect(image, isNull, reason: '$box');
    }
    expect(bundle.calls, isEmpty);
  });

  testWidgets('a bundle that fails resolves to null, never throws (rule 3)', (
    tester,
  ) async {
    final loader = AssetDailyBackgroundLoader(bundle: _FailingBundle());
    final image = await loader.rasterize(
      ChapterTheme.ch03,
      box: const Size(300, 120),
      devicePixelRatio: 2,
    );
    expect(image, isNull);
  });
}

class _CountingBundle extends CachingAssetBundle {
  final List<String> calls = [];

  @override
  Future<String> loadString(String key, {bool cache = true}) async {
    calls.add(key);
    throw UnimplementedError();
  }

  @override
  Future<ByteData> load(String key) => throw UnimplementedError();
}

class _FailingBundle extends CachingAssetBundle {
  @override
  Future<String> loadString(String key, {bool cache = true}) async =>
      throw Exception('no such asset');

  @override
  Future<ByteData> load(String key) => throw UnimplementedError();
}
