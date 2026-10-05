import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_game/features/fx/fx_id.dart';
import 'package:nesty_game/features/fx/fx_player.dart';
import 'package:nesty_game/features/fx/fx_spec.dart';
import 'package:nesty_game/features/fx/fx_spec.gen.dart';

const _frameMs = 1000 / 60;

void main() {
  final pick = fxSpecOf(FxId.dollPick);
  final glow = fxSpecOf(FxId.fxSelectGlow);

  group('FxRange', () {
    test('from markers, in frames', () {
      expect(FxRange.marker(pick, 'lift'), const FxRange(0, 7));
      expect(FxRange.marker(pick, 'wobble'), const FxRange(7, 31));
      expect(FxRange.marker(pick, 'settle'), const FxRange(31, 41));
      expect(FxRange.marker(pick, 'nope'), isNull);
      expect(FxRange.whole(pick), const FxRange(0, 41));
      expect(
        FxRange.marker(pick, 'lift')!.durationMs,
        closeTo(7 * _frameMs, 1e-9),
      );
    });
  });

  group('progress', () {
    final player = FxPlayer.forSpec(pick);

    test("uses lottie's durationFrames (op − 0.01)", () {
      expect(player.durationFrames, closeTo(40.99, 1e-12));
      expect(player.progressOf(20), closeTo(20 / 40.99, 1e-12));
    });

    test('clamps a marker end past the last frame to 1.0', () {
      // settle ends at 41 > 40.99: lottie asserts progress ≤ 1.
      expect(player.progressOf(41), 1);
      expect(player.progressOf(-3), 0);
    });
  });

  group('playback', () {
    test('a one-shot plays its segment once and holds its end', () {
      final player = FxPlayer.forSpec(pick)
        ..start(FxPlan(FxRange.marker(pick, 'settle')!));
      expect(player.state, FxPlayState.playing);
      expect(player.frame, 31);
      expect(player.advance(5 * _frameMs), isFalse);
      expect(player.frame, closeTo(36, 1e-9));
      expect(player.advance(5 * _frameMs), isTrue);
      expect(player.isFinished, isTrue);
      expect(player.frame, 41);
      expect(player.progress, 1);
      // Only the tick that ends it reports it.
      expect(player.advance(_frameMs), isFalse);
      expect(player.frame, 41);
    });

    test('a segment then a loop: lift, then wobble forever', () {
      final player = FxPlayer.forSpec(pick)
        ..start(
          FxPlan(
            FxRange.marker(pick, 'lift')!,
            then: FxRange.marker(pick, 'wobble'),
          ),
        );
      expect(player.frameAt(3 * _frameMs), closeTo(3, 1e-9));
      expect(player.frameAt(7 * _frameMs), closeTo(7, 1e-9));
      expect(player.frameAt((7 + 12) * _frameMs), closeTo(19, 1e-9));
      expect(player.frameAt((7 + 24) * _frameMs), closeTo(7, 1e-9));
      expect(player.frameAt((7 + 24 * 3 + 5) * _frameMs), closeTo(12, 1e-6));
      expect(player.advance(10000), isFalse);
      expect(player.isPlaying, isTrue);
    });

    test('a looping segment wraps inside itself', () {
      final pulse = FxRange.marker(glow, 'pulse')!;
      final player = FxPlayer.forSpec(glow)..start(FxPlan(pulse, loop: true));
      expect(player.frameAt(0), 7);
      expect(player.frameAt(95 * _frameMs), closeTo(102, 1e-9));
      expect(player.frameAt(96 * _frameMs), closeTo(7, 1e-9));
      expect(player.frameAt(100 * _frameMs), closeTo(11, 1e-6));
    });

    test('speed scales each part separately', () {
      final player = FxPlayer.forSpec(glow)
        ..start(
          FxPlan(
            FxRange.marker(glow, 'in')!,
            speed: 2,
            then: FxRange.marker(glow, 'pulse'),
          ),
        );
      // `in` (7 f) takes 3.5 frames of time at 2×; the pulse runs at 1×.
      expect(player.frameAt(3.5 * _frameMs), closeTo(7, 1e-9));
      expect(player.frameAt(13.5 * _frameMs), closeTo(17, 1e-9));
    });

    test('startMs starts mid-plan (idle dolls\' random phase)', () {
      final idle = fxSpecOf(FxId.dollIdle);
      final player = FxPlayer.forSpec(idle)
        ..start(FxPlan.whole(idle), startMs: 1000);
      expect(player.frame, closeTo(60, 1e-9));
      expect(player.elapsedMs, 1000);
    });

    test('rest and seek pause on a frame; reset goes idle', () {
      final player = FxPlayer.forSpec(glow)..rest(16);
      expect(player.isResting, isTrue);
      expect(player.isStill, isTrue);
      expect(player.advance(100), isFalse);
      expect(player.frame, 16);
      player.seek(3);
      expect(player.state, FxPlayState.seeking);
      expect(player.isResting, isFalse);
      expect(player.frame, 3);
      player.reset();
      expect(player.state, FxPlayState.idle);
      expect(player.frame, 0);
    });

    test('a rest plan rests', () {
      final player = FxPlayer.forSpec(pick)..start(const FxPlan.rest(7));
      expect(player.isResting, isTrue);
      expect(player.frame, 7);
    });
  });

  group('FxPlan and reduced motion (D48)', () {
    test('one-shots run at 2×, halving their reservation', () {
      final move = fxSpecOf(FxId.dollMove);
      expect(FxPlan.whole(move).durationMs, closeTo(16 * _frameMs, 1e-9));
      expect(
        FxPlan.whole(move, reduced: true).durationMs,
        closeTo(8 * _frameMs, 1e-9),
      );
    });

    test('doll_pick holds the end of lift instead of wobbling', () {
      final plan = FxPlan.marker(
        pick,
        'lift',
        thenMarker: 'wobble',
        reduced: true,
      )!;
      expect(plan.speed, 2);
      expect(plan.then, isNull);
      final player = FxPlayer.forSpec(pick)..start(plan);
      player.advance(1000);
      expect(player.isFinished, isTrue);
      expect(player.frame, 7);

      final normal = FxPlan.marker(pick, 'lift', thenMarker: 'wobble')!;
      expect(normal.then, const FxRange(7, 31));
      expect(normal.isEndless, isTrue);
    });

    test('the glow comes in at 2× but pulses at 1× (informational)', () {
      final plan = FxPlan.marker(
        glow,
        'in',
        thenMarker: 'pulse',
        reduced: true,
      )!;
      expect(plan.speed, 2);
      expect(plan.then, const FxRange(7, 103));
      expect(plan.thenSpeed, 1);
    });

    test('ambient loops rest on frame 0', () {
      for (final id in [
        FxId.dollIdle,
        FxId.fxTwinkle,
        FxId.dollWinHop,
        FxId.dollWinDance,
        FxId.uiIntroTowers,
        FxId.uiIntroGlass,
        FxId.uiIntroIce,
      ]) {
        final plan = FxPlan.whole(fxSpecOf(id), reduced: true);
        expect(plan.restFrame, 0, reason: id.fileName);
        expect(FxPlan.whole(fxSpecOf(id)).loop, isTrue, reason: id.fileName);
      }
    });

    test('informational loops stay at 1×', () {
      for (final id in [
        FxId.uiHintArrow,
        FxId.uiBoosterGlow,
        FxId.uiExtraSlot,
        FxId.uiTapHand,
        FxId.uiDragHand,
      ]) {
        final plan = FxPlan.whole(fxSpecOf(id), reduced: true);
        expect(plan.restFrame, isNull, reason: id.fileName);
        expect(plan.speed, 1, reason: id.fileName);
        expect(plan.loop, isTrue, reason: id.fileName);
      }
    });

    test('confetti is skipped', () {
      expect(FxMotionPolicy.isSkipped(FxId.fxConfetti, reduced: true), isTrue);
      expect(
        FxMotionPolicy.isSkipped(FxId.fxConfetti, reduced: false),
        isFalse,
      );
      expect(FxMotionPolicy.isSkipped(FxId.dollMove, reduced: true), isFalse);
    });

    test('every file has a class', () {
      final classes = {
        for (final id in FxId.values) id: FxMotionPolicy.classOf(id),
      };
      expect(
        classes.entries
            .where((e) => e.value == FxMotionClass.ambient)
            .map((e) => e.key),
        unorderedEquals([
          FxId.dollIdle,
          FxId.dollWinDance,
          FxId.dollWinHop,
          FxId.fxTwinkle,
          // m7-3's intro card loops: frame 0, still (phase 4).
          FxId.uiIntroTowers,
          FxId.uiIntroGlass,
          FxId.uiIntroIce,
          // m7-4: frame 0, still (`motion.rivalReact.reducedMotion`).
          FxId.uiRivalReact,
          FxId.uiMuseumIdle,
          // m7-4 4.17: frame 0, pulsing (`SpinnerPulse`).
          FxId.uiSpinner,
        ]),
      );
      expect(
        FxMotionPolicy.classOf(FxId.dollPick, 'wobble'),
        FxMotionClass.ambient,
      );
      expect(
        FxMotionPolicy.classOf(FxId.fxSelectGlow, 'pulse'),
        FxMotionClass.informational,
      );
      expect(
        FxMotionPolicy.classOf(FxId.fxSelectGlow, 'out'),
        FxMotionClass.oneShot,
      );
    });

    test('a missing marker gives no plan (rule 3)', () {
      expect(FxPlan.marker(pick, 'dance'), isNull);
    });

    test('caller speed multiplies the policy speed', () {
      final ice = fxSpecOf(FxId.fxIce);
      final plan = FxPlan.marker(ice, 'shatter', reduced: true, speed: 1.5)!;
      expect(plan.speed, 3);
      expect(plan.durationMs, closeTo(FxSpec.msOf(33) / 3, 1e-9));
    });
  });
}
