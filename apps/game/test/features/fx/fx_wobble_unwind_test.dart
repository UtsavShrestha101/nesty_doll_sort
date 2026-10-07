// m7-5 item 14 (`motion.pick.wobbleToMoveMs` = 80): when a wobbling doll is
// dropped, its tilt eases to 0 over the first 80 ms of `doll_move`
// (easeOut), overlapping the move, which starts at once and never snaps. On
// the shipped files.
import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_core/nesty_core.dart';
import 'package:nesty_game/features/fx/fx_drawable.dart';
import 'package:nesty_game/features/fx/fx_id.dart';
import 'package:nesty_render/nesty_render.dart' show MotionTokens;

import 'support/fx_test_art.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final art = BlobArt(1);

  Future<FxDrawable> clipOf(FxId id) async {
    final clip = await shippedDrawable(id, source: art);
    clip.images.request.doll = DollColor.red;
    return clip;
  }

  test('the token: 80 ms, easeOut', () {
    expect(MotionTokens.pickWobbleToMoveMs, 80);
    expect(MotionTokens.pickWobbleToMoveCurve, MotionTokens.curveEaseOut);
  });

  test("doll_pick captures its wobble's angle as it draws: 0 after the "
      'lift, −3° at 13, 3° at 25, back to 0 at 31', () async {
    final clip = await clipOf(FxId.dollPick);
    for (final (frame, angle) in const [
      (7.0, 0.0),
      (13.0, -3.0),
      (25.0, 3.0),
      (31.0, 0.0),
    ]) {
      await snapshotDrawable(clip, frame);
      expect(clip.params.pickRotation, closeTo(angle, 1e-6), reason: '$frame');
    }
    await snapshotDrawable(clip, 10);
    expect(clip.params.pickRotation, inExclusiveRange(-3, 0));
    await snapshotDrawable(clip, 19);
    expect(clip.params.pickRotation, inExclusiveRange(-3, 3));
  });

  test('capturing changes nothing drawn: the wobble is as authored', () async {
    final clip = await clipOf(FxId.dollPick);
    final a = await snapshotDrawable(clip, 13);
    clip.params.pickRotation = 99;
    final b = await snapshotDrawable(clip, 13);
    expect(a.differingPixels(b), 0);
    expect(clip.params.pickRotation, closeTo(-3, 1e-6));
  });

  group('doll_move from a tilt', () {
    Future<Snapshot> move(double frame, double? tilt) async {
      final clip = await clipOf(FxId.dollMove);
      clip.params.unwindFrom = tilt;
      return snapshotDrawable(clip, frame);
    }

    test('starts tilted, eases out, and is as authored from 80 ms (4.8 '
        'frames) on', () async {
      final d0 = (await move(0, 3)).differingPixels(await move(0, null));
      final d1 = (await move(1.2, 3)).differingPixels(await move(1.2, null));
      final d3 = (await move(3.6, 3)).differingPixels(await move(3.6, null));
      expect(d0, greaterThan(100), reason: 'tilted on its first frame');
      expect(d1, lessThan(d0));
      expect(d3, lessThan(d1));
      for (final frame in const [4.8, 6.0, 10.0, 16.0]) {
        expect(
          (await move(frame, 3)).differingPixels(await move(frame, null)),
          0,
          reason: 'frame $frame',
        );
      }
    });

    test('the tilt eases out (fast first): a third of the way in, most of '
        'it is gone', () async {
      final d0 = (await move(0, -3)).differingPixels(await move(0, null));
      final third = (await move(
        1.6,
        -3,
      )).differingPixels(await move(1.6, null));
      // easeOut(1/3) is about 0.7, so about 30 % of the tilt is left.
      expect(third, lessThan(d0 * 0.6));
    });

    test('the travel starts at once: the tilt only turns the doll about its '
        'base', () async {
      final tilted = await move(0, 3);
      final plain = await move(0, null);
      final a = tilted.alphaBounds()!;
      final b = plain.alphaBounds()!;
      // Same place: the bottom (the base) barely moves, and the doll's
      // centre stays within a few px.
      expect(a.bottom, closeTo(b.bottom, 3));
      expect(a.center.dx, closeTo(b.center.dx, 6));
    });

    test('no tilt, or a zero one, draws the move as authored', () async {
      for (final frame in const [0.0, 2.0]) {
        expect(
          (await move(frame, 0)).differingPixels(await move(frame, null)),
          0,
        );
      }
    });

    test('a pooled clip forgets its tilt on reset', () async {
      final clip = await clipOf(FxId.dollMove);
      clip.params.unwindFrom = 3;
      clip.reset();
      expect(clip.params.unwindFrom, isNull);
      expect(clip.params.pickRotation, 0);
    });
  });
}
