import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_core/nesty_core.dart';
import 'package:nesty_game/core/services/audio/audio_service.dart';
import 'package:nesty_game/core/services/haptics/haptics_service.dart';
import 'package:nesty_game/features/fx/fx_id.dart';
import 'package:nesty_game/features/gameplay/game/timeline/timeline.dart';

import 'support/timeline_fixtures.dart';

void main() {
  final impact = framesMs(10.8); // 180 ms
  final length = framesMs(36); // 600 ms

  group('tap invalid (§7 MoveRejectedEffect)', () {
    late TimelineHarness h;

    setUp(() {
      h = TimelineHarness(tutorial)..start();
    });

    double refX(double x) => h.geometry.fit.referenceX(x);
    double refY(double y) => h.geometry.fit.referenceY(y);

    test('glow out; doll_invalid 0–600; bonk + soft error @180', () {
      final lift = h.select('r1c1'); // red1
      final pick = startOf(lift, FxClipPurpose.selection).clip;
      final glow = startOf(lift, FxClipPurpose.selectionGlow).clip;
      final batch = h.reject('r1c1', 'r0c0'); // onto red3: sizeMismatch
      final invalid = startOf(batch, FxClipPurpose.invalid).clip;

      expect(batch.commands.map((c) => c.toString()), [
        '@0.0 stop $pick',
        '@0.0 play $glow FxSegment(103.0–113.0 ×1.0)',
        '@0.0 start $invalid FxSegment(0.0–36.0 ×1.0)',
        '@166.7 stop $glow',
        '@600.0 stop $invalid',
      ]);
      expect(impact, closeTo(180, 1e-9));
      expect(batch.cues, [
        isCue(impact, sound: SoundEffect.bonk, haptic: HapticPattern.invalid),
      ]);
      expect(batch.reservations, {'r1c1': at(length), 'r0c0': at(length)});
      expect(batch.commandsOf<StartTween>(), isEmpty);
      expect(batch.commandsOf<SyncSlot>(), isEmpty, reason: 'nothing moved');

      final src = h.geometry.slot('r1c1');
      final dst = h.geometry.slot('r0c0');
      final s = h.geometry.scale;
      final p = invalid.params;
      expect(invalid.fx, FxId.dollInvalid);
      expect(invalid.placement, FxPlacement.boardSpace(h.geometry.fit));
      expect(invalid.hides, ['r1c1', 'r0c0']);
      expect(p.mover, DollColor.red);
      expect(p.target, DollColor.red);
      expect(
        p.moverScale,
        closeTo(h.geometry.dollHeight(1) / (150 * s), 1e-12),
      );
      expect(
        p.targetScale,
        closeTo(h.geometry.dollHeight(3) / (150 * s), 1e-12),
      );
      expect(p.hideMover, isFalse);
      expect(p.hideTarget, isFalse);
      expect(p.shake, isTrue);
      expect(p.travelFrom, offsetNear(refX(src.centerX), refY(src.surfaceY)));
      expect(
        p.travelTo,
        offsetNear(
          refX(dst.centerX),
          refY(dst.surfaceY - 0.5 * h.geometry.dollHeight(3)),
        ),
      );
      expect(p.targetPos, offsetNear(refX(dst.centerX), refY(dst.surfaceY)));
      expect(h.timeline.selectedSlotId, isNull);
    });

    test('drag invalid: doll_move back from the finger + a hidden mover', () {
      h.select('r1c1', byDrag: true);
      const finger = Offset(180, 330);
      final batch = h.reject('r1c1', 'r0c0', byDrag: true, dragBase: finger);
      final invalid = startOf(batch, FxClipPurpose.invalid).clip;
      final move = startOf(batch, FxClipPurpose.move).clip;
      final src = h.geometry.slot('r1c1');

      expect(invalid.params.hideMover, isTrue);
      expect(invalid.hides, ['r0c0'], reason: 'doll_move draws the mover');
      expect(move.hides, ['r1c1']);
      expect(move.params.travelFrom, offsetNear(refX(180), refY(330)));
      expect(
        move.params.travelTo,
        offsetNear(refX(src.centerX), refY(src.surfaceY)),
      );
      expect(stopOf(batch, move), at(framesMs(16)));
      expect(stopOf(batch, invalid), at(length));
      expect(batch.cues.single.atMs, at(impact));
      expect(batch.reservations, {'r1c1': at(length), 'r0c0': at(length)});
    });

    test('a drag without a finger position plays the tap variant', () {
      h.select('r1c1', byDrag: true);
      final batch = h.reject('r1c1', 'r0c0', byDrag: true);
      final invalid = startOf(batch, FxClipPurpose.invalid).clip;
      expect(invalid.params.hideMover, isFalse);
      expect(invalid.hides, ['r1c1', 'r0c0']);
      expect(
        batch.clips.where((c) => c.purpose == FxClipPurpose.move),
        isEmpty,
      );
    });

    test('reduced motion: 2×, bonk @90, and the file\'s shake removed', () {
      h = TimelineHarness(tutorial, motion: MotionSpec.reduced)..start();
      final batch = h.reject('r1c1', 'r0c0');
      final invalid = startOf(batch, FxClipPurpose.invalid);
      expect(invalid.segment.speed, 2);
      expect(invalid.clip.params.shake, isFalse);
      expect(stopOf(batch, invalid.clip), at(300));
      expect(batch.cues.single.atMs, at(90));
      expect(batch.reservations['r0c0'], at(300));
    });
  });

  group('case, ice and tower targets shake by hand (§9.3)', () {
    late TimelineHarness h;

    setUp(() {
      h = TimelineHarness(comboLevel)..start();
    });

    void expectHandShake(TimelineBatch batch, String target) {
      final invalid = startOf(batch, FxClipPurpose.invalid).clip;
      expect(invalid.params.hideTarget, isTrue);
      expect(invalid.hides, ['r1c0'], reason: 'the slot draws its own doll');
      final start = only<StartTween>(batch);
      final shake = start.tween as ShakeTween;
      expect(shake.slotId, target);
      expect(start.atMs, at(framesMs(10.8)));
      expect(only<EndTween>(batch).atMs, at(framesMs(25.2)));
      expect(shake.durationMs, at(framesMs(14.4)));
      expect(shake.amplitudeScale, h.geometry.scale);
    }

    test('a locked target: the glass composition shakes', () {
      final batch = h.reject('r1c0', 'r0c2');
      expectHandShake(batch, 'r0c2');
      final invalid = startOf(batch, FxClipPurpose.invalid).clip;
      final dst = h.geometry.slot('r0c2');
      // The sealed doll stands on the case floor.
      expect(
        invalid.params.targetPos,
        offsetNear(
          h.geometry.fit.referenceX(dst.centerX),
          h.geometry.fit.referenceY(dst.lockedDollBaseY),
        ),
      );
    });

    test('an iced target: the ice composition shakes', () {
      expectHandShake(h.reject('r1c0', 'r0c3'), 'r0c3');
    });

    test('a tower target: its doll and silhouettes shake', () {
      expectHandShake(h.reject('r1c0', 'r1c2'), 'r1c2');
    });

    test('no hand shake under reduced motion', () {
      h = TimelineHarness(comboLevel, motion: MotionSpec.reduced)..start();
      final batch = h.reject('r1c0', 'r0c2');
      expect(batch.commandsOf<StartTween>(), isEmpty);
      expect(
        startOf(batch, FxClipPurpose.invalid).clip.params.hideTarget,
        isTrue,
      );
    });

    test('the shake follows doll_invalid\'s target keyframes × s', () {
      h.reject('r1c0', 'r0c2');
      h.run(framesMs(10.8));
      final shake = h.timeline.debugActiveTweens.single as ShakeTween;
      expect(shake.offsetX, closeTo(0, 1e-9));
      // Keyframes 0, −6, 6, −6, 6, −6, 0 every 2.4 f.
      final samples = <double>[];
      for (var k = 1; k <= 6; k++) {
        h.timeline.advance(framesMs(2.4));
        samples.add(shake.offsetX / h.geometry.scale);
      }
      expect(samples.sublist(0, 5), [
        closeTo(-6, 1e-6),
        closeTo(6, 1e-6),
        closeTo(-6, 1e-6),
        closeTo(6, 1e-6),
        closeTo(-6, 1e-6),
      ]);
      expect(samples.last, closeTo(0, 1e-6));
      expect(h.timeline.debugActiveTweens, isEmpty);
    });
  });
}
