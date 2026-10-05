import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_core/nesty_core.dart';
import 'package:nesty_game/core/services/audio/audio_service.dart';
import 'package:nesty_game/core/services/haptics/haptics_service.dart';
import 'package:nesty_game/features/fx/fx_cue.dart';
import 'package:nesty_game/features/fx/fx_id.dart';
import 'package:nesty_game/features/fx/fx_spec.gen.dart';
import 'package:nesty_game/features/gameplay/game/timeline/timeline.dart';
import 'package:nesty_render/nesty_render.dart';

import 'support/timeline_fixtures.dart';

void main() {
  group('MotionSpec', () {
    test('standard plays everything as authored', () {
      const m = MotionSpec.standard;
      expect(m.durationScale, 1);
      expect(m.oneShotSpeed, 1);
      expect(m.informationalLoopSpeed, 1);
      expect(m.ambientLoopSpeed, 1);
      expect([
        m.shake,
        m.wobble,
        m.confetti,
        m.ambientLoops,
      ], everyElement(true));
      expect(m.ms(537), 537);
      expect(m.isReduced, isFalse);
    });

    test('reduced motion is tokens.json motion.reducedMotion (D48)', () {
      const m = MotionSpec.reduced;
      expect(m.durationScale, MotionTokens.reducedMotionDurationScale);
      expect(m.durationScale, 0.5);
      expect(m.oneShotSpeed, 2);
      // Loops that carry information stay at 1×; ambient loops pause.
      expect(m.informationalLoopSpeed, 1);
      expect(m.ambientLoopSpeed, 0);
      expect([
        m.shake,
        m.wobble,
        m.confetti,
        m.ambientLoops,
      ], everyElement(false));
      expect(m.ms(536.67), closeTo(268.33, 0.01));
      expect(m.isReduced, isTrue);
    });

    test('of picks by the platform flag', () {
      expect(MotionSpec.of(reduceMotion: true), MotionSpec.reduced);
      expect(MotionSpec.of(reduceMotion: false), MotionSpec.standard);
    });
  });

  group('ComboTracker', () {
    test('steps up within 4 s, up to 5, and restarts after a gap', () {
      var now = 0.0;
      final combo = ComboTracker(clock: () => now);
      expect(combo.windowMs, MotionTokens.comboWindowMs);
      expect(combo.maxStep, MotionTokens.comboMaxSteps);
      expect(combo.step, 0);

      final steps = <int>[];
      for (var i = 0; i < 7; i++) {
        steps.add(combo.register());
        now += 3000;
      }
      expect(steps, [1, 2, 3, 4, 5, 5, 5]);

      now += 1001; // 4001 ms after the last one
      expect(combo.register(), 1);
    });

    test('the window is inclusive and measured between t0s', () {
      var now = 1000.0;
      final combo = ComboTracker(clock: () => now);
      // Scheduled at 1000, lands 667 ms later.
      expect(combo.register(delayMs: 666.67), 1);
      now = 1000 + 4000;
      expect(combo.register(delayMs: 666.67), 2);
      expect(combo.registerAt(now + 666.67 + 4000.001), 1);
    });

    test('reset starts over', () {
      final combo = ComboTracker(clock: () => 0)
        ..register()
        ..register();
      expect(combo.step, 2);
      combo.reset();
      expect(combo.step, 0);
      expect(combo.register(), 1);
    });
  });

  group('SlotReservations', () {
    test('reserve extends, never shortens, and expires', () {
      final r = SlotReservations()
        ..reserve('a', 500)
        ..reserve('a', 300)
        ..reserve('b', 100);
      expect(r.until('a'), 500);
      expect(r.isReserved('a', 499), isTrue);
      expect(r.isReserved('a', 500), isFalse);
      expect(r.isReserved('c', 0), isFalse);
      expect(r.reservedAt(200), ['a']);
      r.clear();
      expect(r.isReserved('a', 0), isFalse);
    });
  });

  group('FxSegment', () {
    test('markers and whole files come from the spec, never typed in', () {
      final pick = fxSpecOf(FxId.dollPick);
      final lift = FxSegment.marker(pick, 'lift');
      expect(lift, const FxSegment(0, 7));
      expect(lift.durationMs, at(framesMs(7)));
      expect(FxSegment.marker(pick, 'wobble', loop: true).loop, isTrue);
      expect(FxSegment.holdEndOf(pick, 'lift'), const FxSegment.hold(7));
      expect(FxSegment.holdEndOf(pick, 'lift').isHold, isTrue);
      expect(FxSegment.holdEndOf(pick, 'lift').durationMs, 0);

      final move = FxSegment.whole(fxSpecOf(FxId.dollMove), speed: 2);
      expect(move, const FxSegment(0, 16, speed: 2));
      expect(move.durationMs, at(framesMs(16) / 2));

      expect(
        () => FxSegment.marker(pick, 'nope'),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('a paused loop never ends', () {
      const paused = FxSegment(0, 78, loop: true, speed: 0);
      expect(paused.durationMs, 0);
    });
  });

  group('LottieGeometry', () {
    test('role sizes follow LOTTIE.md "Doll size" at any board scale', () {
      expect(LottieGeometry.roleScale(150, 1), 1);
      expect(LottieGeometry.roleScale(63, 1), 0.42);
      // A board scaled 1.2 draws a 180 dp doll at k = 1 (§5).
      expect(LottieGeometry.roleScale(180, 1.2), closeTo(1, 1e-12));
      expect(LottieGeometry.nestedMoverScale(81, 99), closeTo(81 / 99, 1e-12));
      expect(LottieGeometry.nestedMoverScale(81, 0), 1);
    });
  });

  group('FxAnchor', () {
    test('resolves the §2 table\'s game points on a slot', () {
      final state = GameState.initial(tutorial);
      final board = geometryOf(state);
      final slot = board.slot('r0c0');
      expect(FxAnchor.dollBase.yIn(slot), slot.surfaceY);
      expect(FxAnchor.surface.yIn(slot), slot.surfaceY);
      expect(FxAnchor.glow.yIn(slot), slot.glowCenterY);
      expect(FxAnchor.glow.yIn(slot), closeTo(slot.surfaceY - 2, 1e-9));
      expect(FxAnchor.stand.yIn(slot), slot.standCenterY);
      expect(FxAnchor.hintArrow.yIn(slot, size: 2), slot.hintArrowCenterY(2));
      expect(FxAnchor.dollBase.xIn(slot), slot.centerX);
      expect(FxAnchor.dollBase.scaleIn(board, slot), board.scale);
      expect(FxAnchor.glow.scaleIn(board, slot), slot.furnitureScale);
    });
  });

  group('BoardTimeline rest frames', () {
    test('ice rests on 16 × iceFrame, glass on 0 (§8, D51)', () {
      expect(BoardTimeline.glassRestFrame, 0);
      expect(BoardTimeline.iceRestFrame(remaining: 3, initial: 3), 0);
      expect(BoardTimeline.iceRestFrame(remaining: 2, initial: 3), 16);
      expect(BoardTimeline.iceRestFrame(remaining: 1, initial: 3), 32);
      expect(BoardTimeline.iceRestFrame(remaining: 0, initial: 3), 48);
      expect(BoardTimeline.iceRestFrame(remaining: 3, initial: 4), 0);
      expect(BoardTimeline.iceRestFrame(remaining: 1, initial: 2), 16);
    });
  });

  group('ServiceFeedbackSink', () {
    test('plays the sound with its pitch and step, then the haptic', () {
      final audio = _Audio();
      final haptics = _Haptics();
      ServiceFeedbackSink(audio: audio, haptics: haptics)
        ..play(
          const FxCue(
            atMs: 536.67,
            sound: SoundEffect.clack,
            haptic: HapticPattern.nest,
            dollSize: 4,
          ),
        )
        ..play(const FxCue(atMs: 0, sound: SoundEffect.complete, comboStep: 3))
        ..play(const FxCue(atMs: 0, sound: SoundEffect.iceShatter))
        ..play(const FxCue(atMs: 0, haptic: HapticPattern.button));
      expect(audio.played, [
        (SoundEffect.clack, 4, null),
        (SoundEffect.complete, null, 3),
        (SoundEffect.iceShatter, null, null),
      ]);
      expect(haptics.played, [HapticPattern.nest, HapticPattern.button]);
    });

    test('swallows failures (rule 3)', () async {
      final sink = ServiceFeedbackSink(
        audio: _Audio(fail: true),
        haptics: _Haptics(fail: true),
      );
      expect(
        () => sink.play(
          const FxCue(
            atMs: 0,
            sound: SoundEffect.bonk,
            haptic: HapticPattern.invalid,
          ),
        ),
        returnsNormally,
      );
      await Future<void>.delayed(Duration.zero);
    });
  });

  group('WinOverlaySchedule', () {
    test('the coin count-up runs coins@700 to the stars at 1300 (A-CNT)', () {
      expect(WinOverlaySchedule.winCountUpMs, 600);
      final s = WinOverlaySchedule.of(MotionSpec.standard, families: 3);
      expect(
        s.countUpStartMs + WinOverlaySchedule.winCountUpMs,
        s.starsStartMs,
      );
      expect(s.starsStartMs, 1300);
      final r = WinOverlaySchedule.of(MotionSpec.reduced, families: 3);
      expect(r.starsStartMs, 650);
    });

    test('frame 2.8 from the files: win @0, coins and burst @700', () {
      final s = WinOverlaySchedule.of(MotionSpec.standard, families: 3);
      expect(s.cues, const [
        FxCue(atMs: 0, sound: SoundEffect.win, haptic: HapticPattern.win),
        FxCue(atMs: 700, sound: SoundEffect.coins),
      ]);
      expect(s.ribbon, const FxSegment(0, 18));
      expect(s.ribbonHoldFrame, 18);
      expect(s.confetti, const FxSegment(0, 102));
      expect(s.hop, const FxSegment(0, 78, loop: true));
      expect(s.hopStartsMs, [0, 150, 300]);
      expect(s.coinBurstAtMs, 700);
      expect(s.coinBurst, const FxSegment(0, 40));
      expect(s.countUpStartMs, 700);
      expect(s.countUpEndMs, 1300);
      expect(s.twinkle, const FxSegment(0, 120, loop: true));
    });

    test('reduced motion halves it, drops confetti, pauses the hops', () {
      final s = WinOverlaySchedule.of(MotionSpec.reduced, families: 2);
      expect(s.cues.map((c) => c.atMs), [0, 350]);
      expect(s.confetti, isNull);
      expect(s.ribbon.speed, 2);
      expect(s.hop.speed, 0);
      expect(s.twinkle.speed, 0);
      expect(s.hopStartsMs, [0, 75]);
      expect(s.coinBurstAtMs, 350);
      expect(s.countUpEndMs, 650);
    });

    group('stars (m7-design P3.7, D149)', () {
      test('no stars: starsStartMs still set, no cues, no flourish', () {
        final s = WinOverlaySchedule.of(MotionSpec.standard, families: 0);
        expect(s.starsStartMs, 1300);
        expect(s.starCues, isEmpty);
        expect(s.starFlourishCue, isNull);
      });

      test('3 stars: star_1…star_3 cues 333 ms apart from 1,300 ms with a '
          'light haptic each, then the success haptic after the flourish', () {
        final s = WinOverlaySchedule.of(
          MotionSpec.standard,
          families: 0,
          stars: 3,
        );
        expect(s.starCues.map((c) => c.sound), [
          SoundEffect.star1,
          SoundEffect.star2,
          SoundEffect.star3,
        ]);
        expect(s.starCues.map((c) => c.atMs), [
          closeTo(1300, 0.01),
          closeTo(1633.3, 0.1),
          closeTo(1966.7, 0.1),
        ]);
        expect(
          s.starCues.map((c) => c.haptic),
          everyElement(HapticPattern.pick),
        );
        // Three segments (20 f each), then the 60 f flourish.
        expect(s.starFlourishCue!.atMs, closeTo(1300 + 1000 + 1000, 0.1));
        expect(s.starFlourishCue!.haptic, HapticPattern.complete);
        expect(s.starFlourishCue!.sound, isNull);
      });

      test('1 or 2 stars: their own cues, no flourish', () {
        for (final stars in [1, 2]) {
          final s = WinOverlaySchedule.of(
            MotionSpec.standard,
            families: 0,
            stars: stars,
          );
          expect(s.starCues, hasLength(stars));
          expect(s.starFlourishCue, isNull, reason: '$stars stars');
        }
      });

      test('reduced motion (Q146, D191): starsStartMs halves, and one cue '
          'plays for the highest star, with no flourish', () {
        final s = WinOverlaySchedule.of(
          MotionSpec.reduced,
          families: 0,
          stars: 3,
        );
        expect(s.starsStartMs, 650);
        expect(s.starCues, [
          const FxCue(
            atMs: 650,
            sound: SoundEffect.star3,
            haptic: HapticPattern.pick,
          ),
        ]);
        expect(s.starFlourishCue, isNull);
        final two = WinOverlaySchedule.of(
          MotionSpec.reduced,
          families: 0,
          stars: 2,
        );
        expect(two.starCues.single.sound, SoundEffect.star2);
      });
    });
  });
}

final class _Audio implements AudioService {
  _Audio({this.fail = false});

  final bool fail;
  final List<(SoundEffect, int?, int?)> played = [];

  @override
  void play(SoundEffect effect, {int? dollSize, int? comboStep}) {
    if (fail) throw StateError('no audio');
    played.add((effect, dollSize, comboStep));
  }

  @override
  Future<void> preload() async {}

  @override
  Future<void> dispose() async {}
}

final class _Haptics implements HapticsService {
  _Haptics({this.fail = false});

  final bool fail;
  final List<HapticPattern> played = [];

  @override
  Future<void> play(HapticPattern pattern) async {
    if (fail) throw StateError('no haptics');
    played.add(pattern);
  }
}
