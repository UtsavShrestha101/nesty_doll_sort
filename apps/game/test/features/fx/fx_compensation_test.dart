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
  ..revealed = DollColor.purple
  ..family = DollColor.orange
  ..family2 = DollColor.teal
  ..freed = DollColor.pink
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
/// case 2, the hop and the landing; ice: every stage, the shatter and every
/// crack_hit; reveal: the drop, the wipe and the colour doll).
const _frames = <FxId, List<double>>{
  FxId.dollPick: [3, 20, 36],
  FxId.dollMove: [4, 12],
  FxId.dollNest: [2, 10, 20],
  FxId.dollSwallow: [2, 10, 20],
  FxId.dollComplete: [5, 12, 50, 58],
  FxId.dollInvalid: [8, 18, 30],
  FxId.dollReveal: [3, 10, 15, 25],
  FxId.dollIdle: [30, 90],
  FxId.dollWinDance: [20, 60],
  FxId.dollWinHop: [20, 50],
  FxId.fxSelectGlow: [3, 50, 108],
  FxId.fxGlassUnlock: [6, 18, 30, 50, 53.5],
  FxId.fxIce: [0, 10, 25, 40, 55, 60, 66, 85, 104, 120, 140],
  FxId.uiHintArrow: [10, 30],
  FxId.uiExtraSlot: [0, 20, 48, 70],
  // m7-3: the tall case (its padlock inside the `padlock_tall` precomp), the
  // UI art at 3× (stars, chest) and the intro loops' doll roles.
  FxId.fxGlassUnlockTall: [6, 18, 30, 50, 53.5],
  // The pops and the flourish (frames 20, 40, 60, 100): at 2.7 px per unit
  // the 44 dp stars miss the 99 % bar by resampling alone (f20 98.9 %, f60
  // 96.9 %), so they have their own bar, [_bars] (architecture §1.2).
  FxId.uiStars: [0, 10, 20, 40, 60, 100, 119],
  FxId.uiChest: [20, 100, 230, 260, 350],
  FxId.uiIntroTowers: [0, 60, 120, 200],
  FxId.uiIntroGlass: [0, 60, 130, 200],
  FxId.uiIntroIce: [0, 80, 170, 260],
};

/// The share of touched pixels that must match, where 99 % is out of reach
/// of resampling alone: small art with soft glows (the 44 dp stars, whose
/// sparkles and glow are a few pixels wide at 2.7 px per unit).
const _bars = <FxId, double>{FxId.uiStars: 0.95};

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
  // The reference is lottie drawing the declared asset sizes, as authored:
  // 512×768 doll parts and, since LOTTIE.md v3, board pieces at 3× their
  // box. Ours: doll parts at 0.586× (the 300×450 of a 150 dp doll at DPR
  // 3) with board pieces at 2.7 px per box unit (furniture scale 0.9 on DPR
  // 3), then dolls at 1.5× with pieces at 2 px per unit (DPR 2). Rasters
  // count in box units, as the skin service serves them.
  const factors = [(300 / 512, 2.7), (1.5, 2.0)];
  for (final MapEntry(key: id, value: frames) in _frames.entries) {
    for (final (dollFactor, pieceFactor) in factors) {
      test('${id.fileName}: doll parts at ${dollFactor.toStringAsFixed(3)}×, '
          'pieces at ${pieceFactor.toStringAsFixed(1)} px per unit draw like '
          'the declared size', () async {
        final composition = await shippedOnce(id);
        final spec = fxSpecOf(id);
        final pixelRatio = spec.width > 200 ? 1.0 : 2.0;
        final request = FxImageRequest();
        _request(request);
        final reference = _authored(
          composition,
          BlobArt(1, pieceFactor: FxImageSlot.pieceDensity),
          request,
        );
        final empty = _authored(composition, null, request);
        final clip = await shippedDrawable(
          id,
          source: BlobArt(dollFactor, pieceFactor: pieceFactor),
        );
        _request(clip.images.request);

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
            greaterThanOrEqualTo(_bars[id] ?? 0.99),
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

  test(
    'a board piece cropped out of its box is placed by its origin',
    () async {
      // glass_case_0 at 3 px per box unit but cropped: the raster starts 4×8
      // box units into its 86×143 box (`BoardSpriteImage.cropOrigin`).
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
      // And a solid case lands where the box says: its top-left at (47, 40)
      // of the canvas (LOTTIE.md "fx_glass_unlock"), 86×143.
      final solid = await draw(
        FxRaster(insetBox(258, 429, const Color(0xFF00BCD4)), scale: 3),
      );
      final box = solid.alphaBounds()!;
      expect(box.left / 2, closeTo(47, 0.5));
      expect(box.top / 2, closeTo(40, 0.5));
      expect(box.width / 2, closeTo(86, 1));
      expect(box.height / 2, closeTo(143, 1));
    },
  );
}
