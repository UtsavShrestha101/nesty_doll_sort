// A pooled or reused drawable starts every segment from a clean lottie
// seek (docs/plans/claude-design-v3-check.md issue 1): in lottie 3.6.1 a
// layer keeps its cached in/out keyframe while it still "contains" the new
// progress, and `fx_ice`'s `ice_0_hit` ends on frame 99 where `ice_1_hit`
// starts, rounded one ulp apart. A drawable that last drew 98.x and then
// jumps to 99 would draw both ice frames for one frame.
import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_core/nesty_core.dart';
import 'package:nesty_game/features/fx/fx_cue.dart';
import 'package:nesty_game/features/fx/fx_drawable.dart';
import 'package:nesty_game/features/fx/fx_id.dart';
import 'package:nesty_game/features/fx/fx_image_source.dart';
import 'package:nesty_game/features/fx/fx_player.dart';
import 'package:nesty_game/features/fx/fx_spec.gen.dart';

import 'support/fx_test_art.dart';

/// The board-piece slots [clip] asked for while drawing its current frame.
Future<Set<FxImageSlot>> _drawnPieces(FxDrawable clip, BlobArt art) async {
  art.requested.clear();
  await snapshot(clip.spec.width, clip.spec.height, clip.draw);
  return art.requested.where((s) => s.piece != null).toSet();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final spec = fxSpecOf(FxId.fxIce);
  final hit0 = spec.marker(FxIceSegments.crackHit(0))!;
  final hit1 = spec.marker(FxIceSegments.crackHit(1))!;

  test('the boundary: crack_hit_0 ends where crack_hit_1 starts, +1', () {
    expect(hit0.end, 98);
    expect(hit1.start, 99);
  });

  test('lottie alone, 98.5 then 99 without a clean seek, keeps ice_0 drawn '
      'with ice_1: the defect the reset guards against', () async {
    final art = BlobArt(1);
    final clip = await shippedDrawable(FxId.fxIce, source: art);
    clip.images.request.doll = DollColor.red;
    final lottie = clip.lottie;
    final frames = clip.composition.durationFrames;
    Future<Set<FxImageSlot>> rawAt(double frame) async {
      art.requested.clear();
      lottie.setProgress(frame / frames);
      await snapshot(180, 240, (canvas) {
        lottie.draw(canvas, const Rect.fromLTWH(0, 0, 180, 240));
      });
      return art.requested.where((s) => s.piece != null).toSet();
    }

    expect(await rawAt(98.5), {FxImageSlot.ice0});
    final jumped = await rawAt(99);
    // lottie 3.6.1: both layers claim frame 99. If a lottie upgrade fixes
    // this, the reset below is still harmless.
    expect(jumped, contains(FxImageSlot.ice1));
    expect(jumped, {FxImageSlot.ice0, FxImageSlot.ice1});
  });

  test('FxDrawable: a new segment on a drawable that drew 98.5 draws only '
      'ice_1 on its first frame', () async {
    final art = BlobArt(1);
    final clip = await shippedDrawable(FxId.fxIce, source: art);
    clip.images.request.doll = DollColor.red;

    clip.player.seek(98.5);
    expect(await _drawnPieces(clip, art), {FxImageSlot.ice0});

    // The timeline starts crack_hit_1 on the same, reused composition.
    clip.player.start(FxPlan(FxRange(hit1.start, hit1.end)));
    expect(clip.player.frame, 99);
    expect(await _drawnPieces(clip, art), {FxImageSlot.ice1});
    // And the next frames of the segment stay clean.
    clip.advance(1000 / 60);
    expect(await _drawnPieces(clip, art), {FxImageSlot.ice1});
  });

  test('a rest, a seek and a pooled reset re-seek too; continuous playback '
      'does not', () async {
    final art = BlobArt(1);
    final clip = await shippedDrawable(FxId.fxIce, source: art);
    clip.images.request.doll = DollColor.red;

    clip.player.seek(98.5);
    await _drawnPieces(clip, art);
    clip.player.rest(99);
    expect(await _drawnPieces(clip, art), {FxImageSlot.ice1});

    clip.player.seek(98.5);
    await _drawnPieces(clip, art);
    clip.player.seek(99);
    expect(await _drawnPieces(clip, art), {FxImageSlot.ice1});

    // Returned to its pool and taken again for another slot.
    clip.player.seek(98.5);
    await _drawnPieces(clip, art);
    clip.reset();
    clip.images.request.doll = DollColor.red;
    clip.player.start(FxPlan(FxRange(hit1.start, hit1.end)));
    expect(await _drawnPieces(clip, art), {FxImageSlot.ice1});

    // Playing on inside one segment bumps nothing.
    final epoch = clip.player.epoch;
    clip.advance(100);
    clip.advance(100);
    expect(clip.player.epoch, epoch);
  });
}
