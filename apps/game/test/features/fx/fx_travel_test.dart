// The board-space `travel` remap and the hold workaround
// (docs/plans/m2-lottie-design.md §6, LOTTIE.md "Travel remap"), through
// the real delegates on the shipped files.
import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lottie/lottie.dart';
import 'package:nesty_core/nesty_core.dart';
import 'package:nesty_game/features/fx/fx_drawable.dart';
import 'package:nesty_game/features/fx/fx_id.dart';
import 'package:nesty_game/features/fx/fx_image_source.dart';
import 'package:nesty_game/features/fx/fx_spec.gen.dart';

import 'support/fx_test_art.dart';

final _solid = insetBox(512, 768, const Color(0xFFFF0000));

FixedArt _dollArt() => FixedArt({
  FxImageSlot.dollLid: FxRaster(_solid, scale: 1),
  FxImageSlot.dollBody: FxRaster(_solid, scale: 1),
  FxImageSlot.moverLid: FxRaster(_solid, scale: 1),
  FxImageSlot.moverBody: FxRaster(_solid, scale: 1),
});

Future<FxDrawable> _clip(FxId id, {Offset? src, Offset? dst}) async {
  final clip = await shippedDrawable(id, source: _dollArt());
  clip.images.request
    ..doll = DollColor.red
    ..mover = DollColor.red;
  clip.params.setTravel(src, dst);
  return clip;
}

/// The horizontal centre of what [clip] draws at [frame].
Future<double> _centreX(FxDrawable clip, double frame) async {
  final box = (await snapshotDrawable(clip, frame)).alphaBounds()!;
  return box.center.dx;
}

/// u of the clip's captured travel point along src→dst.
double _u(FxDrawable clip, Offset src, Offset dst) {
  final p = clip.params.trailPoint!;
  final d = dst - src;
  return ((p - src).dx * d.dx + (p - src).dy * d.dy) / d.distanceSquared;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('doll_move remap', () {
    const src = Offset(60, 420);
    // Far enough from the 390-unit edge that the overshoot isn't clipped.
    const dst = Offset(260, 600);

    test('u = 0 at S: the doll starts on src', () async {
      final clip = await _clip(FxId.dollMove, src: src, dst: dst);
      expect(await _centreX(clip, 0), closeTo(src.dx, 1.5));
      expect(_u(clip, src, dst), closeTo(0, 1e-9));
    });

    test('u = 1 at T: the doll ends on dst', () async {
      final clip = await _clip(FxId.dollMove, src: src, dst: dst);
      expect(await _centreX(clip, 16), closeTo(dst.dx, 1.5));
      expect(_u(clip, src, dst), closeTo(1, 1e-3));
      expect(clip.params.trailPoint!.dy, closeTo(dst.dy, 0.2));
    });

    test('the easeOutBack overshoot is kept: u > 1 mid-move', () async {
      final clip = await _clip(FxId.dollMove, src: src, dst: dst);
      await snapshotDrawable(clip, 8);
      // The analysis measured u = 1.0875 at frame 8 (§6).
      expect(_u(clip, src, dst), closeTo(1.0875, 0.01));
      expect(
        await _centreX(clip, 8),
        closeTo(src.dx + (dst.dx - src.dx) * _u(clip, src, dst), 1.5),
      );
    });

    test('the captured point equals FxTravel.remap of the authored point', () {
      final travel = fxSpecOf(FxId.dollMove).travel!;
      const v = Offset(180, 500);
      expect(
        travel.remap(v, src, dst),
        Offset(
          src.dx + (dst.dx - src.dx) * 0.4,
          src.dy + (dst.dy - src.dy) * 0.4,
        ),
      );
    });

    test('unset travel points draw as authored (S → T)', () async {
      final clip = await _clip(FxId.dollMove);
      final travel = fxSpecOf(FxId.dollMove).travel!;
      expect(await _centreX(clip, 0), closeTo(travel.s.dx, 1.5));
      expect(await _centreX(clip, 16), closeTo(travel.t.dx, 1.5));
    });
  });

  group('holds are remapped too (probe T10)', () {
    const src = Offset(250, 700);
    const dst = Offset(250, 300);

    test('doll_complete draws at src through its 0–42 hold', () async {
      final clip = await _clip(FxId.dollComplete, src: src, dst: dst);
      for (final frame in const [0.0, 5.0, 30.0, 41.0, 41.99]) {
        expect(
          await _centreX(clip, frame),
          closeTo(src.dx, 1.5),
          reason: 'frame $frame',
        );
        expect(clip.params.trailPoint, src, reason: 'frame $frame');
      }
    });

    test('and leaves the hold on the remapped path', () async {
      final clip = await _clip(FxId.dollComplete, src: src, dst: dst);
      for (final frame in const [42.0, 43.0, 60.0]) {
        await snapshotDrawable(clip, frame);
        expect(clip.params.trailPoint!.dx, closeTo(src.dx, 1e-6));
        expect(_u(clip, src, dst), inInclusiveRange(-0.01, 1.2));
      }
      await snapshotDrawable(clip, 75);
      expect(_u(clip, src, dst), closeTo(1, 1e-3));
    });

    test('without the anchor fix lottie would draw the authored S', () async {
      // The bare remap callback: lottie never calls it inside a hold.
      final composition = await shippedOnce(FxId.dollComplete);
      final travel = fxSpecOf(FxId.dollComplete).travel!;
      var calls = 0;
      final drawable = LottieDrawable(composition, frameRate: FrameRate.max)
        ..delegates = LottieDelegates(
          image: (_, _) => _solid,
          values: [
            ValueDelegate.transformPosition(
              const ['travel'],
              callback: (f) {
                calls++;
                final v = Offset.lerp(
                  f.startValue,
                  f.endValue,
                  f.interpolatedKeyframeProgress,
                )!;
                return travel.remap(v, src, dst);
              },
            ),
          ],
        );
      drawable.setProgress(30 / composition.durationFrames);
      final snap = await snapshot(
        390,
        844,
        (canvas) => drawable.draw(
          canvas,
          const Rect.fromLTWH(0, 0, 390, 844),
          fit: BoxFit.fill,
        ),
      );
      expect(calls, 0);
      expect(snap.alphaBounds()!.center.dx, closeTo(travel.s.dx, 1.5));
    });

    test('ui_drag_hand: its S and T holds follow src and dst', () async {
      const handSrc = Offset(140, 460);
      const handDst = Offset(320, 380);
      final spec = fxSpecOf(FxId.uiDragHand);
      final authored = await _clip(FxId.uiDragHand);
      final moved = await _clip(FxId.uiDragHand, src: handSrc, dst: handDst);
      for (final (frame, shift) in [
        (10.0, handSrc - spec.travel!.s),
        (95.0, handDst - spec.travel!.t),
      ]) {
        final a = (await snapshotDrawable(authored, frame)).alphaBounds()!;
        final b = (await snapshotDrawable(moved, frame)).alphaBounds()!;
        expect(b.left - a.left, closeTo(shift.dx, 1.5), reason: 'f$frame');
        expect(b.top - a.top, closeTo(shift.dy, 1.5), reason: 'f$frame');
      }
    });

    test('nearestHold survives lottie rounding at the boundary', () {
      final travel = fxSpecOf(FxId.dollComplete).travel!;
      for (final frame in const [-0.01, 0.0, 20.0, 41.999, 42.0, 42.01]) {
        expect(travel.nearestHold(frame), travel.holds.single);
      }
    });
  });

  test('doll_invalid: target_pos takes the target base', () async {
    final clip = await shippedDrawable(FxId.dollInvalid, source: _dollArt());
    clip.images.request.target = DollColor.red;
    final art = FixedArt({
      FxImageSlot.targetLid: FxRaster(_solid, scale: 1),
      FxImageSlot.targetBody: FxRaster(_solid, scale: 1),
    });
    clip.images.source = art;
    final authored = await _centreX(clip, 0);
    clip.params.targetPos = const Offset(120, 500);
    expect(authored, closeTo(300, 1.5));
    expect(await _centreX(clip, 0), closeTo(120, 1.5));
  });
}
