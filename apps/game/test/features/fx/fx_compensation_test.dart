// Image-slot compensation (docs/plans/m2-lottie-design.md §3, §17 "FX
// runtime"): lottie 3.6.1 draws an image layer at the image's own pixel
// size, so every layer's scale and anchor are compensated for the raster
// the game supplies. These tests pin that behaviour, including the swapped
// progress fields of animated scales, against lottie drawing the authored
// declared-size images.
import 'dart:ui' as ui;

import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lottie/lottie.dart';
import 'package:nesty_core/nesty_core.dart';
import 'package:nesty_game/features/fx/fx_id.dart';
import 'package:nesty_game/features/fx/fx_image_source.dart';
import 'package:nesty_game/features/fx/fx_spec.gen.dart';

import 'support/fx_test_art.dart';

void _request(FxImageRequest request) => request
  ..doll = DollColor.red
  ..mover = DollColor.blue
  ..target = DollColor.green
  ..unlockColor = DollColor.yellow;

/// lottie as authored: declared-size rasters, the image delegate only.
LottieDrawable _authored(
  LottieComposition composition,
  FxImageSource? art,
  FxImageRequest request,
) => LottieDrawable(composition, frameRate: FrameRate.max)
  ..filterQuality = FilterQuality.medium
  ..delegates = LottieDelegates(
    image: (_, asset) {
      final slot = FxImageSlot.fromAssetId(asset.id);
      final raster = slot == null ? null : art?.rasterFor(slot, request);
      return raster?.image ?? transparentPixel;
    },
  );

Future<Snapshot> _snapAuthored(
  LottieDrawable drawable,
  double frame,
  double pixelRatio,
) {
  drawable.setProgress(
    (frame / drawable.composition.durationFrames).clamp(0.0, 1.0),
  );
  return snapshot(
    drawable.size.width,
    drawable.size.height,
    (canvas) =>
        drawable.draw(canvas, Offset.zero & drawable.size, fit: BoxFit.fill),
    pixelRatio: pixelRatio,
  );
}

/// The frames at which each file's image layers are on screen, covering
/// every layer of §3's table (glass: padlock + symbol + case 0, case 1,
/// case 2, the hop; ice: every stage and the shatter).
const _frames = <FxId, List<double>>{
  FxId.dollPick: [3, 20, 36],
  FxId.dollMove: [4, 12],
  FxId.dollNest: [2, 10, 20],
  FxId.dollSwallow: [2, 10, 20],
  FxId.dollComplete: [5, 12, 50, 58],
  FxId.dollInvalid: [8, 18, 30],
  // The silhouette is hidden from frame 12 on purpose (§7).
  FxId.dollReveal: [3, 8, 11],
  FxId.dollIdle: [30, 90],
  FxId.dollWinDance: [20, 60],
  FxId.dollWinHop: [20, 50],
  FxId.fxSelectGlow: [3, 50, 108],
  FxId.fxGlassUnlock: [6, 18, 30, 50],
  FxId.fxIce: [0, 10, 25, 40, 55, 60, 66],
  FxId.uiHintArrow: [10, 30],
  FxId.uiExtraSlot: [0, 20, 48, 70],
};

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('every file with image layers is covered', () {
    expect(_frames.keys.toSet(), {
      for (final spec in fxSpecs.values)
        if (spec.imageLayers.isNotEmpty) spec.id,
    });
  });

  group('E1 (analysis "impact" §A): doll_pick frame 0', () {
    final full = insetBox(512, 768, const Color(0xFFFF0000));
    final small = insetBox(300, 450, const Color(0xFFFF0000));
    const r = 300 / 512;

    Future<Rect?> bounds(FxRaster raster, {bool compensate = true}) async {
      final art = FixedArt({
        FxImageSlot.dollLid: raster,
        FxImageSlot.dollBody: raster,
      });
      if (!compensate) {
        final composition = await shippedOnce(FxId.dollPick);
        final request = FxImageRequest()..doll = DollColor.red;
        final snap = await _snapAuthored(
          _authored(composition, art, request),
          0,
          1,
        );
        return snap.alphaBounds();
      }
      final clip = await shippedDrawable(FxId.dollPick, source: art);
      clip.images.request.doll = DollColor.red;
      return (await snapshotDrawable(clip, 0)).alphaBounds();
    }

    test('the 512×768 artboard draws the 150-unit doll on its base', () async {
      // Anchor (256, 742) at the base (80, 230), scale 0.1953: 100×150.
      final box = (await bounds(FxRaster(full, scale: 1)))!;
      expect(box.left, closeTo(80 - 256 * 0.1953, 1));
      expect(box.top, closeTo(230 - 742 * 0.1953, 1));
      expect(box.width, closeTo(512 * 0.1953, 1.5));
      expect(box.height, closeTo(768 * 0.1953, 1.5));
    });

    test('a 300×450 raster draws the same box once compensated', () async {
      final reference = (await bounds(FxRaster(full, scale: 1)))!;
      final compensated = (await bounds(FxRaster(small, scale: r)))!;
      expect(compensated.left, closeTo(reference.left, 1));
      expect(compensated.top, closeTo(reference.top, 1));
      expect(compensated.right, closeTo(reference.right, 1));
      expect(compensated.bottom, closeTo(reference.bottom, 1));
    });

    test('uncompensated, lottie draws it at its pixel size', () async {
      final reference = (await bounds(FxRaster(full, scale: 1)))!;
      final raw = (await bounds(FxRaster(small, scale: r), compensate: false))!;
      expect(raw.height, closeTo(reference.height * r, 1.5));
    });
  });

  // §17: for every image layer, a compensated raster at another
  // resolution draws the same pixels as the declared-size one (≥ 99 %
  // within 8/255 over the pixels the images touch), with the same bounds.
  // Doll parts at 0.586× (the 300×450 of a 150 dp doll at DPR 3) with
  // board pieces at 3× (a piece at DPR 3), then both at 1.5×. The game
  // never supplies a board piece below its declared size (furniture scale
  // × DPR > 1), where upsampling a coarser raster blurs it differently.
  const factors = [(300 / 512, 3.0), (1.5, 1.5)];
  for (final MapEntry(key: id, value: frames) in _frames.entries) {
    for (final (dollFactor, pieceFactor) in factors) {
      test('${id.fileName}: doll parts at ${dollFactor.toStringAsFixed(3)}×, '
          'pieces at $pieceFactor× draw like the declared size', () async {
        final composition = await shippedOnce(id);
        final spec = fxSpecOf(id);
        final pixelRatio = spec.width > 200 ? 1.0 : 2.0;
        final request = FxImageRequest();
        _request(request);
        final reference = _authored(composition, BlobArt(1), request);
        final empty = _authored(composition, null, request);
        final clip = await shippedDrawable(
          id,
          source: BlobArt(dollFactor, pieceFactor: pieceFactor),
        );
        _request(clip.images.request);
        clip.params.unlockSettle = false;

        for (final frame in frames) {
          final ref = await _snapAuthored(reference, frame, pixelRatio);
          final none = await _snapAuthored(empty, frame, pixelRatio);
          final ours = await snapshotDrawable(
            clip,
            frame,
            pixelRatio: pixelRatio,
          );

          var touched = 0;
          var matching = 0;
          for (var i = 0; i < ref.bytes.length; i += 4) {
            if (!ref.pixelDiffers(none, i, 8) &&
                !ours.pixelDiffers(none, i, 8)) {
              continue;
            }
            touched++;
            if (!ours.pixelDiffers(ref, i, 8)) matching++;
          }
          final where = '${id.fileName} f$frame';
          expect(touched, greaterThan(50), reason: '$where: images drawn');
          expect(
            matching / touched,
            greaterThanOrEqualTo(0.99),
            reason: '$where: $matching of $touched match',
          );

          Rect? drawn(Snapshot s) {
            return s.boundsWhere((x, y) {
              final i = (y * s.width + x) * 4;
              return s.pixelDiffers(none, i, 24);
            });
          }

          final a = drawn(ref)!;
          final b = drawn(ours)!;
          expect(b.left, closeTo(a.left, 2), reason: where);
          expect(b.top, closeTo(a.top, 2), reason: where);
          expect(b.right, closeTo(a.right, 2), reason: where);
          expect(b.bottom, closeTo(a.bottom, 2), reason: where);
        }
      });
    }
  }

  test('a board piece cropped out of its declared box is placed by its '
      'origin', () async {
    // glass_case_0 rasterized 3× but cropped: the raster starts 4×8
    // declared px into the box (`BoardSpriteImage.cropOrigin`).
    final full = blobArt(
      86,
      143,
      3,
      primary: const Color(0xFF00BCD4),
      secondary: const Color(0xFF3F51B5),
    );
    final recorder = ui.PictureRecorder();
    ui.Canvas(recorder).drawImage(full, const Offset(-12, -24), Paint());
    final cropped = recorder.endRecording().toImageSync(
      full.width - 12,
      full.height - 24,
    );
    Future<Snapshot> draw(FxRaster raster) async {
      final clip = await shippedDrawable(
        FxId.fxGlassUnlock,
        source: FixedArt({FxImageSlot.glassCase0: raster}),
      );
      return snapshotDrawable(clip, 6, pixelRatio: 2);
    }

    final a = await draw(FxRaster(full, scale: 3));
    final b = await draw(
      FxRaster(cropped, scale: 3, origin: const Offset(4, 8)),
    );
    // Same pixels wherever the crop kept the art.
    expect(b.differingPixels(a), lessThan(a.width * a.height ~/ 100));
  });
}
