import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_game/features/fx/fx_cue.dart';
import 'package:nesty_game/features/fx/fx_id.dart';
import 'package:nesty_game/features/fx/fx_image_source.dart';
import 'package:nesty_game/features/fx/fx_spec.dart';

import 'support/design_lottie.dart';

void main() {
  group('FxTravel (LOTTIE.md "Travel remap")', () {
    const complete = FxTravel(
      s: Offset(100, 650),
      t: Offset(195, 144),
      holds: [FxHold(0, 42, Offset(100, 650))],
    );
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

    test('finds the hold a frame is in, and the nearest one at a boundary', () {
      expect(complete.holdAt(0), complete.holds.single);
      expect(complete.holdAt(41.99), complete.holds.single);
      expect(complete.holdAt(42), isNull);
      expect(complete.nearestHold(42.0), complete.holds.single);
      expect(move.nearestHold(3), isNull);

      const drag = FxTravel(
        s: Offset(100, 500),
        t: Offset(300, 500),
        holds: [
          FxHold(0, 21.6, Offset(100, 500)),
          FxHold(86.4, 108, Offset(300, 500)),
        ],
      );
      expect(drag.nearestHold(50)!.value, const Offset(100, 500));
      expect(drag.nearestHold(60)!.value, const Offset(300, 500));
      expect(drag.nearestHold(95)!.value, const Offset(300, 500));
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
  });

  // The frame constants the timeline sequences on, checked against the
  // owner's exports so a re-export that moves them fails here.
  group('FxTiming matches design/lottie', () {
    test('the nest and swallow lids shut at frame 16.2 (270 ms)', () {
      final nest = rootLayer(readDesignLottie('doll_nest'), 'target_lid');
      final swallow = rootLayer(readDesignLottie('doll_swallow'), 'mover_lid');
      expect(
        keyframes(nest, 'p', component: 1).last.$1,
        FxTiming.nestClackFrame,
      );
      expect(
        keyframes(swallow, 'p', component: 1).last.$1,
        FxTiming.nestClackFrame,
      );
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

    test('doll_complete holds travel at S until the fly at frame 42', () {
      final travel = keyframes(
        rootLayer(readDesignLottie('doll_complete'), 'travel'),
        'p',
        component: 1,
      );
      expect(travel[0].$2, travel[1].$2, reason: 'a hold');
      expect(travel[1].$1, FxTiming.completeHoldEndFrame);
      expect(FxTiming.completeFlyFrame, FxTiming.completeHoldEndFrame);
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

    test('fx_glass_unlock frees the doll 11 units above the stand surface', () {
      final json = readDesignLottie('fx_glass_unlock');
      final doll = keyframes(rootLayer(json, 'doll'), 'p', component: 1);
      expect(doll.map((kf) => kf.$1), [
        0,
        FxTiming.unlockHopStartFrame,
        48,
        FxTiming.unlockHopEndFrame,
      ]);
      final caseTop = keyframes(
        rootLayer(json, 'glass_case_0'),
        'p',
        component: 1,
      ).single.$2;
      // NestyBoard: the surface is caseTop + 134, the case floor + 123.
      expect(caseTop + 134 - doll.last.$2, FxTiming.unlockSettleUnits);
    });

    test('fx_ice has one 16-frame segment per crack stage', () {
      final markers = [
        for (final m in readDesignLottie('fx_ice')['markers']! as List<Object?>)
          m! as Map<String, Object?>,
      ];
      for (var n = 1; n <= 3; n++) {
        final crack = markers.firstWhere((m) => m['cm'] == 'crack_$n');
        expect(crack['tm'], FxTiming.iceStageFrames * (n - 1));
        expect(crack['dr'], FxTiming.iceStageFrames);
      }
      final shatter = markers.firstWhere((m) => m['cm'] == 'shatter');
      expect(shatter['tm'], FxTiming.iceStageFrames * 3);
    });
  });
}
