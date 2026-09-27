import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_game/features/fx/fx_cue.dart';
import 'package:nesty_game/features/fx/fx_id.dart';
import 'package:nesty_game/features/fx/fx_image_source.dart';
import 'package:nesty_game/features/fx/fx_spec.dart';
import 'package:nesty_game/features/fx/fx_spec.gen.dart';
import 'package:nesty_render/nesty_render.dart' show MotionTokens;

import 'support/design_lottie.dart';

/// The out and in tangents (x, y) of keyframe [index] of [layer]'s [key].
(double, double, double, double) _tangents(
  Map<String, Object?> layer,
  String key,
  int index,
) {
  final prop =
      (layer['ks']! as Map<String, Object?>)[key]! as Map<String, Object?>;
  final kf = (prop['k']! as List<Object?>)[index]! as Map<String, Object?>;
  double axis(Object? tangent, String name) =>
      (((tangent! as Map<String, Object?>)[name]! as List<Object?>).first!
              as num)
          .toDouble();
  return (
    axis(kf['o'], 'x'),
    axis(kf['o'], 'y'),
    axis(kf['i'], 'x'),
    axis(kf['i'], 'y'),
  );
}

void main() {
  group('FxTravel (LOTTIE.md "Travel remap")', () {
    const complete = FxTravel(s: Offset(100, 650), t: Offset(195, 144));
    const move = FxTravel(s: Offset(100, 500), t: Offset(300, 500));
    const src = Offset(40, 300);
    const dst = Offset(250, 120);

    test('S maps to src and T to dst', () {
      expect(complete.progressOf(complete.s), 0);
      expect(complete.progressOf(complete.t), closeTo(1, 1e-12));
      expect(complete.remap(complete.s, src, dst), src);
      final end = complete.remap(complete.t, src, dst);
      expect(end.dx, closeTo(dst.dx, 1e-9));
      expect(end.dy, closeTo(dst.dy, 1e-9));
    });

    test('keeps the easeOutBack overshoot of doll_move', () {
      // doll_move frame 8 draws travel at (317.5, 500) in lottie 3.6.1.
      final u = move.progressOf(const Offset(317.5, 500));
      expect(u, closeTo(1.0875, 1e-9));
      expect(
        move.remap(const Offset(317.5, 500), src, dst).dx,
        greaterThan(250),
      );
    });

    test('projects off-line authored points onto S→T', () {
      // The arc lives on its own null, but a stray y must not change u.
      expect(move.progressOf(const Offset(200, 460)), closeTo(0.5, 1e-12));
    });
  });

  group('FxSpec and FxMarker', () {
    const pick = FxSpec(
      id: FxId.dollPick,
      frames: 41,
      width: 160,
      height: 260,
      anchor: Offset(80, 230),
      kind: FxKind.segmented,
      markers: [
        FxMarker('lift', 0, 7),
        FxMarker('wobble', 7, 24),
        FxMarker('settle', 31, 10),
      ],
      roles: [FxRole.doll],
      imageLayers: [
        FxImageLayer(
          keyPath: ['doll_lid'],
          slot: FxImageSlot.dollLid,
          scale: Offset(0.1953, 0.1953),
          anchor: Offset(256, 742),
        ),
      ],
    );

    test('times come from frames at 60 fps', () {
      expect(FxSpec.msOf(16), closeTo(266.67, 0.01));
      expect(pick.durationMs, closeTo(683.33, 0.01));
      final wobble = pick.marker('wobble')!;
      expect(wobble.end, 31);
      expect(wobble.durationMs, closeTo(400, 1e-9));
      expect(pick.marker('settle')!.startMs, closeTo(516.67, 0.01));
      expect(pick.marker('dance'), isNull);
    });

    test('markers are found by name, whatever their order (fx_ice)', () {
      final ice = fxSpecOf(FxId.fxIce);
      expect(ice.marker('rest_2'), const FxMarker('rest_2', 32, 0));
      expect(ice.marker('crack_hit_1'), const FxMarker('crack_hit_1', 99, 16));
      // The file lists the rests after the shatter.
      final names = ice.markers.map((m) => m.name).toList();
      expect(names.indexOf('rest_0'), greaterThan(names.indexOf('shatter')));
    });
  });

  // The frame constants the timeline sequences on, checked against the
  // owner's exports so a re-export that moves them fails here.
  group('FxTiming matches design/lottie (v3)', () {
    test('the nest and swallow lids shut at frame 16.2 (270 ms), on their '
        'lift nulls', () {
      for (final (file, lift, lid) in const [
        ('doll_nest', 'target_lid_lift', 'target_lid'),
        ('doll_swallow', 'mover_lid_lift', 'mover_lid'),
      ]) {
        final json = readDesignLottie(file);
        final keys = keyframes(rootLayer(json, lift), 'p', component: 1);
        expect(keys.last, (FxTiming.nestClackFrame, 0), reason: file);
        // The image layer itself keeps a static transform (v3).
        expect(keyframes(rootLayer(json, lid), 'p'), [(0, 0)], reason: file);
      }
      expect(FxSpec.msOf(FxTiming.nestClackFrame), closeTo(270, 1e-9));
      // The clack of a nest batch: the move (16 f) plus the lid.
      expect(FxSpec.msOf(16 + FxTiming.nestClackFrame), closeTo(536.67, 0.01));
    });

    test(
      'doll_invalid reaches the target at 10.8 and shakes it ±6 to 25.2',
      () {
        final json = readDesignLottie('doll_invalid');
        expect(
          keyframes(rootLayer(json, 'travel'), 'p')[1].$1,
          FxTiming.invalidImpactFrame,
        );
        final shake = keyframes(rootLayer(json, 'target'), 'p');
        final fromImpact = shake.where(
          (kf) => kf.$1 >= FxTiming.invalidShakeStartFrame,
        );
        expect(fromImpact.first.$1, FxTiming.invalidShakeStartFrame);
        expect(fromImpact.last.$1, FxTiming.invalidShakeEndFrame);
        expect(
          fromImpact.map((kf) => kf.$2).toList(),
          FxTiming.invalidShakeKeyframes,
        );
        expect(
          FxTiming.invalidShakeKeyframes
              .map((v) => v.abs())
              .reduce((a, b) => a > b ? a : b),
          FxTiming.invalidShakeAmplitude,
        );
      },
    );

    test('doll_complete flies from frame 42: its travel starts there, with '
        'no hold', () {
      final travel = keyframes(
        rootLayer(readDesignLottie('doll_complete'), 'travel'),
        'p',
        component: 1,
      );
      expect(travel.first.$1, FxTiming.completeFlyFrame);
      for (var i = 0; i + 1 < travel.length; i++) {
        expect(travel[i].$2, isNot(travel[i + 1].$2), reason: 'key $i');
      }
      expect(FxSpec.msOf(FxTiming.completeFlyFrame), closeTo(700, 1e-9));
    });

    test('the family counter swaps its text at the bump peak (frame 6)', () {
      final json = readDesignLottie('ui_family_counter');
      expect(
        keyframes(rootLayer(json, 'count_old'), 'o')[1].$1,
        FxTiming.counterSwapFrame,
      );
      expect(
        keyframes(rootLayer(json, 'counter'), 's')[1].$1,
        FxTiming.counterSwapFrame,
      );
    });

    test('fx_glass_unlock: the freed doll lands on the stand surface '
        '(caseTop + 134) at frame 53, and stays there', () {
      final json = readDesignLottie('fx_glass_unlock');
      final doll = keyframes(rootLayer(json, 'doll'), 'p', component: 1);
      expect(doll.map((kf) => kf.$1), [0, 42, 47, 53]);
      final caseTop = keyframes(
        rootLayer(json, 'glass_case_0'),
        'p',
        component: 1,
      ).single.$2;
      // NestyBoard: the case floor is caseTop + 123, the surface + 134.
      expect(doll.first.$2, caseTop + 123);
      expect(doll.last.$2, caseTop + 134);
      expect(fxSpecOf(FxId.fxGlassUnlock).frames, 54);
      // padlock_ping covers the symbol from frame 1: frame 0 shows it.
      expect(rootLayer(json, 'padlock_ping')['ip'], 1);
    });

    test('fx_ice: a 16-frame segment per crack stage, a rest marker per '
        'stage, and a crack_hit per stage after the shatter', () {
      final ice = fxSpecOf(FxId.fxIce);
      for (var n = 1; n <= 3; n++) {
        expect(
          ice.marker(FxIceSegments.crack(n)),
          FxMarker('crack_$n', FxTiming.iceStageFrames * (n - 1), 16),
        );
      }
      for (var n = 0; n <= 3; n++) {
        expect(
          ice.marker(FxIceSegments.rest(n)),
          FxMarker('rest_$n', FxTiming.iceStageFrames * n, 0),
        );
        expect(FxIceSegments.restFrame(ice, n), FxTiming.iceStageFrames * n);
        final hit = ice.marker(FxIceSegments.crackHit(n))!;
        expect(hit.start, 82 + 17.0 * n);
        expect(hit.duration, 16);
      }
      final shatter = ice.marker(FxIceSegments.shatter)!;
      expect(shatter.start, FxTiming.iceStageFrames * 3);
      expect(shatter.end, 81);
      expect(ice.frames, 150);
      // Rule 3: an export without rest markers rests on 16 n.
      const bare = FxSpec(
        id: FxId.fxIce,
        frames: 81,
        width: 180,
        height: 240,
        anchor: Offset(90, 170.8),
        kind: FxKind.segmented,
      );
      expect(FxIceSegments.restFrame(bare, 2), 32);
    });

    test('doll_reveal: the drop null lowers the doll 18 over frames 0–7 on '
        'the easeOut curve, the wipe ends with the silhouette at 19', () {
      final json = readDesignLottie('doll_reveal');
      final drop = rootLayer(json, 'drop');
      expect(drop['parent'], isNull, reason: 'it moves the whole doll');
      expect(keyframes(drop, 'p', component: 1), [
        (0, -FxTiming.revealDropUnits),
        (FxTiming.revealDropEndFrame, 0),
      ]);
      expect(keyframes(drop, 'p'), [(0, 0), (FxTiming.revealDropEndFrame, 0)]);
      final (ox, oy, ix, iy) = _tangents(drop, 'p', 0);
      const ease = MotionTokens.curveEaseOut;
      expect((ox, oy, ix, iy), (ease.a, ease.b, ease.c, ease.d));
      expect(
        rootLayer(json, 'doll_silhouette')['op'],
        FxTiming.revealWipeEndFrame,
      );
      expect(fxSpecOf(FxId.dollReveal).frames, 31);
    });
  });
}
