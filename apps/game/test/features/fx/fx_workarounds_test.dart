// The export workarounds and paused rest frames of
// docs/plans/m2-lottie-design.md §5, §7, §8, §9.2 and §13, on the shipped
// files through the real delegates.
import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_core/nesty_core.dart';
import 'package:nesty_game/features/fx/fx_drawable.dart';
import 'package:nesty_game/features/fx/fx_id.dart';
import 'package:nesty_game/features/fx/fx_image_source.dart';
import 'package:nesty_game/features/fx/fx_layout.dart';
import 'package:nesty_game/features/fx/fx_spec.gen.dart';
import 'package:nesty_render/nesty_render.dart';

import 'support/fx_test_art.dart';

const _red = Color(0xFFFF0000);
const _green = Color(0xFF00FF00);
const _blue = Color(0xFF0000FF);
const _cream = Color(0xFFFFF3D6);

FxRaster _solid(FxImageSlot slot, Color color) => FxRaster(
  insetBox(slot.declaredWidth.round(), slot.declaredHeight.round(), color),
  scale: 1,
);

bool _isRed(int r, int g, int b, int a) => a > 200 && r > 200 && g < 60;
bool _isGreen(int r, int g, int b, int a) => a > 200 && g > 200 && r < 60;
bool _isBlue(int r, int g, int b, int a) => a > 200 && b > 200 && r < 60;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('fx_glass_unlock', () {
    Future<FxDrawable> glass() async {
      final clip = await shippedDrawable(
        FxId.fxGlassUnlock,
        source: FixedArt({
          FxImageSlot.glassCase0: _solid(FxImageSlot.glassCase0, _cream),
          FxImageSlot.unlockSymbol: _solid(FxImageSlot.unlockSymbol, _blue),
          FxImageSlot.dollLid: _solid(FxImageSlot.dollLid, _red),
          FxImageSlot.dollBody: _solid(FxImageSlot.dollBody, _red),
        }),
      );
      clip.images.request
        ..doll = DollColor.red
        ..unlockColor = DollColor.blue;
      return clip;
    }

    Future<Snapshot> at(FxDrawable clip) =>
        snapshot(clip.spec.width, clip.spec.height, clip.draw, pixelRatio: 2);

    test('at rest the unlock symbol shows: padlock_ping is hidden (§8, '
        'audit #3)', () async {
      final clip = await glass();
      clip.player.rest(0);
      final resting = await at(clip);
      // The symbol's centre is (90, 156) in the canvas.
      final (r, g, b, a) = resting.at(180, 312);
      expect(_isBlue(r, g, b, a), isTrue, reason: '($r,$g,$b,$a)');

      // As authored (not resting), the padlock copy covers it.
      clip.player.seek(0);
      final (r2, g2, b2, a2) = (await at(clip)).at(180, 312);
      expect(_isBlue(r2, g2, b2, a2), isFalse, reason: '($r2,$g2,$b2,$a2)');
    });

    test('while playing, padlock_ping follows its authored fade', () async {
      final clip = await glass();
      clip.player.seek(11.9);
      final late = await at(clip);
      final (r, g, b, a) = late.at(180, 312);
      // Almost faded out by frame 12: the symbol shows through again.
      expect(_isBlue(r, g, b, a), isTrue, reason: '($r,$g,$b,$a)');
    });

    test('the freed doll settles 11 units onto the stand (§9.2)', () async {
      Future<double> bottom(double frame, {required bool settle}) async {
        final clip = await glass();
        clip.params.unlockSettle = settle;
        clip.player.seek(frame);
        final snap = await at(clip);
        return snap.boundsWhere((x, y) {
          final (r, g, b, a) = snap.at(x, y);
          return _isRed(r, g, b, a);
        })!.bottom;
      }

      // (Frames 0–12 hide the doll behind the opaque test case; the flash
      // whitens it around frame 30.)
      for (final frame in const [12.0, 24.0, 42.0]) {
        expect(
          await bottom(frame, settle: true),
          await bottom(frame, settle: false),
          reason: 'frame $frame: no settle before the last hop',
        );
      }
      final mid =
          await bottom(48, settle: true) - await bottom(48, settle: false);
      expect(mid / 2, closeTo(5.5, 1));
      final end =
          await bottom(54, settle: true) - await bottom(54, settle: false);
      expect(end / 2, closeTo(11, 1));
    });

    test('the file ends with the doll base on the stand surface (canvas '
        '163 + 11)', () async {
      final clip = await glass();
      FxLayout.applyDollHeights(
        clip.params,
        clip.spec,
        compositionScale: 1,
        doll: 117,
      );
      clip.player.seek(54);
      final snap = await at(clip);
      final box = snap.boundsWhere((x, y) {
        final (r, g, b, a) = snap.at(x, y);
        return _isRed(r, g, b, a);
      })!;
      // The solid art reaches 26 of 768 units below the base.
      const below = 117 * 26 / 768;
      expect(box.bottom / 2, closeTo(174 + below, 1));
    });
  });

  group('fx_ice rest frames: stage n rests on frame 16n (D51)', () {
    for (final (stage, slot) in [
      (0, FxImageSlot.ice0),
      (1, FxImageSlot.ice1),
      (2, FxImageSlot.ice2),
      (3, FxImageSlot.ice3),
    ]) {
      test('stage $stage shows ${slot.assetId}', () async {
        final art = BlobArt(1);
        final clip = await shippedDrawable(FxId.fxIce, source: art);
        clip.images.request.doll = DollColor.red;
        clip.player.rest(16.0 * stage);
        await snapshot(180, 240, clip.draw);
        final shown = art.requested.where((s) => s.piece != null).toSet();
        expect(shown, {slot});
      });
    }
  });

  group('doll_reveal (§7)', () {
    Future<FxDrawable> reveal() async {
      final clip = await shippedDrawable(
        FxId.dollReveal,
        source: FixedArt({
          FxImageSlot.dollSilhouette: _solid(
            FxImageSlot.dollSilhouette,
            _green,
          ),
          FxImageSlot.dollLid: _solid(FxImageSlot.dollLid, _red),
          FxImageSlot.dollBody: _solid(FxImageSlot.dollBody, _red),
        }),
      );
      clip.images.request.doll = DollColor.red;
      return clip;
    }

    test('the silhouette is hidden from the wipe\'s end (frame 12)', () async {
      final clip = await reveal();
      int greens(Snapshot s) {
        var n = 0;
        for (var y = 0; y < s.height; y++) {
          for (var x = 0; x < s.width; x++) {
            final (r, g, b, a) = s.at(x, y);
            if (_isGreen(r, g, b, a)) n++;
          }
        }
        return n;
      }

      expect(greens(await snapshotDrawable(clip, 2)), greaterThan(100));
      expect(greens(await snapshotDrawable(clip, 12)), 0);
      expect(greens(await snapshotDrawable(clip, 20)), 0);
    });

    test('its last frame equals the rest sprite (§10.2)', () async {
      const h = 110.0, s = 0.9, base = Offset(120, 300);
      const artPx = 450;
      const widthPx = 300;
      final set = DollPartSet(
        skinKey: 'test@1',
        symbols: DollSymbols.none,
        artHeightPx: artPx,
        lids: {
          DollColor.red: blobArt(
            512,
            768,
            artPx / 768,
            primary: _red,
            secondary: _blue,
          ),
        },
        bodies: {
          DollColor.red: blobArt(
            512,
            768,
            artPx / 768,
            primary: _green,
            secondary: _red,
          ),
        },
        silhouette: insetBox(widthPx, artPx, _green),
      );
      final sprite = PartRasterDollRenderer(set.clone());
      final params = DollPaintParams()
        ..color = DollColor.red
        ..height = h
        ..baseX = base.dx
        ..baseY = base.dy;
      final expected = await snapshot(
        240,
        360,
        (canvas) => sprite.paint(canvas, params),
        pixelRatio: 2,
      );

      final clip = await shippedDrawable(
        FxId.dollReveal,
        source: _PartSource(set),
      );
      clip.images.request.doll = DollColor.red;
      FxLayout.applyDollHeights(
        clip.params,
        clip.spec,
        compositionScale: s,
        doll: h,
      );
      clip.player.seek(24);
      final topLeft = FxLayout.topLeft(clip.spec, base.dx, base.dy, s);
      final actual = await snapshot(240, 360, (canvas) {
        canvas
          ..save()
          ..translate(topLeft.dx, topLeft.dy)
          ..scale(s);
        clip.draw(canvas);
        canvas.restore();
      }, pixelRatio: 2);

      var touched = 0, matching = 0;
      for (var i = 0; i < expected.bytes.length; i += 4) {
        if (expected.bytes[i + 3] < 8 && actual.bytes[i + 3] < 8) continue;
        touched++;
        if (!actual.pixelDiffers(expected, i, 8)) matching++;
      }
      expect(touched, greaterThan(1000));
      expect(matching / touched, greaterThanOrEqualTo(0.99));
      sprite.dispose();
      set.dispose();
    });
  });

  group('reduced motion removes the shakes (D48)', () {
    test('doll_invalid: the target holds still', () async {
      Future<double> centre(double frame, {required bool reduced}) async {
        final clip = await shippedDrawable(
          FxId.dollInvalid,
          source: FixedArt({
            FxImageSlot.targetLid: _solid(FxImageSlot.targetLid, _red),
            FxImageSlot.targetBody: _solid(FxImageSlot.targetBody, _red),
          }),
        );
        clip.images.request.target = DollColor.red;
        clip.params.reducedMotion = reduced;
        return (await snapshotDrawable(clip, frame)).alphaBounds()!.center.dx;
      }

      // Frame 15.6 is the +6 keyframe of the shake.
      expect(await centre(15.6, reduced: false), closeTo(306, 1));
      expect(await centre(15.6, reduced: true), closeTo(300, 1));
      expect(await centre(0, reduced: true), closeTo(300, 1));
    });

    test('fx_ice: the crack shake holds the ice at (42, 40)', () async {
      Future<double> left(double frame, {required bool reduced}) async {
        final clip = await shippedDrawable(
          FxId.fxIce,
          source: FixedArt({FxImageSlot.ice1: _solid(FxImageSlot.ice1, _blue)}),
        );
        clip.params.reducedMotion = reduced;
        return (await snapshotDrawable(clip, frame)).alphaBounds()!.left;
      }

      // Frame 2.75 is the (40, 40) keyframe of crack_1's shake.
      expect(await left(2.75, reduced: false), closeTo(40, 1));
      expect(await left(2.75, reduced: true), closeTo(42, 1));
    });
  });

  group('doll_size (§5)', () {
    Future<double> height(
      FxId id,
      FxRole role, {
      required double compositionScale,
      required double mover,
      required double target,
    }) async {
      final clip = await shippedDrawable(
        id,
        source: FixedArt({
          for (final slot in FxImageSlot.values)
            if (slot.isDoll) slot: _solid(slot, _red),
        }),
      );
      clip.images.request
        ..mover = role == FxRole.mover ? DollColor.red : null
        ..target = role == FxRole.target ? DollColor.red : null;
      FxLayout.applyDollHeights(
        clip.params,
        clip.spec,
        compositionScale: compositionScale,
        mover: mover,
        target: target,
      );
      return (await snapshotDrawable(clip, 0)).alphaBounds()!.height;
    }

    for (final id in [FxId.dollNest, FxId.dollSwallow, FxId.dollInvalid]) {
      test('${id.fileName}: each doll is its logical height / s', () async {
        const s = 0.8;
        final (mover, target) = id == FxId.dollSwallow
            ? (96.0, 64.0)
            : (64.0, 96.0);
        // doll_invalid's mover starts from the lifted pose (×1.05).
        final lift = id == FxId.dollInvalid ? 1.05 : 1.0;
        expect(
          await height(
            id,
            FxRole.target,
            compositionScale: s,
            mover: mover,
            target: target,
          ),
          closeTo(target / s, 1.5),
        );
        expect(
          await height(
            id,
            FxRole.mover,
            compositionScale: s,
            mover: mover,
            target: target,
          ),
          closeTo(mover / s * lift, 1.5),
        );
      });
    }

    test('the nested mover factor is relative to the target', () {
      final clip = fxSpecOf(FxId.dollNest);
      expect(FxLayout.nestsMoverInTarget(clip.id), isTrue);
      expect(FxLayout.nestsMoverInTarget(FxId.dollInvalid), isFalse);
    });
  });
}

/// The level's part rasters as the services lane serves them, reduced to
/// what doll_reveal needs.
final class _PartSource implements FxImageSource {
  _PartSource(DollPartSet set)
    : _lid = FxRaster(set.lid(DollColor.red)!, scale: set.artScale),
      _body = FxRaster(set.body(DollColor.red)!, scale: set.artScale),
      _silhouette = FxRaster(set.silhouette, scale: set.artScale);

  final FxRaster _lid;
  final FxRaster _body;
  final FxRaster _silhouette;

  @override
  FxRaster? rasterFor(FxImageSlot slot, FxImageRequest request) {
    final role = slot.role;
    if (role == null || request.colorOf(role) == null) return null;
    return switch (slot.part) {
      FxDollPart.lid => _lid,
      FxDollPart.body => _body,
      _ => _silhouette,
    };
  }
}
