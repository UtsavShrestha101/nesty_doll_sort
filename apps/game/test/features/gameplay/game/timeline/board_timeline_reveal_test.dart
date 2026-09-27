import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_core/nesty_core.dart';
import 'package:nesty_game/features/fx/fx_id.dart';
import 'package:nesty_game/features/gameplay/game/timeline/timeline.dart';

import 'support/timeline_fixtures.dart';

// towerLevel: r0c0 buries green1, green2 under blue3; r0c1 buries blue1
// under [red2, red1]; r0c2 is empty; red3 at r1c0.
void main() {
  late TimelineHarness h;

  setUp(() {
    h = TimelineHarness(towerLevel)..start();
  });

  // LOTTIE.md v3: doll_reveal is 31 frames. Its `drop` null lowers the new
  // top from its buried step onto the stand over frames 0–7, the wipe runs
  // 7–19 and the splash drops fade out by 31. The board shifts the nests
  // still buried one step down alongside the drop.
  const revealFrames = 31.0;
  const dropFrames = 7.0;

  group('Revealed on the source tower (§7, §9.1)', () {
    late TimelineBatch batch;

    setUp(() {
      h.select('r0c0');
      batch = h.move('r0c0', 'r0c2'); // blue3 leaves: green2 shows
    });

    test('doll_reveal plays from its first frame at 0, drop included, to '
        '516.7 ms on the surface', () {
      final reveal = startOf(batch, FxClipPurpose.reveal);
      expect(reveal.atMs, 0);
      expect(reveal.clip.fx, FxId.dollReveal);
      expect(reveal.segment, const FxSegment(0, revealFrames));
      expect(stopOf(batch, reveal.clip), at(framesMs(revealFrames)));
      expect(stopOf(batch, reveal.clip), closeTo(516.67, 0.01));

      // The "+N" tag counts down when the top leaves (the sync at 0), and
      // the clip draws the new top from its buried step down.
      expect(only<SyncSlot>(batch, (c) => c.slotId == 'r0c0').atMs, 0);
      expect(reveal.clip.hides, ['r0c0']);

      final slot = h.geometry.slot('r0c0');
      expect(reveal.clip.placement.x, slot.centerX);
      expect(reveal.clip.placement.y, slot.surfaceY);
      expect(reveal.clip.params.doll, DollColor.green);
      expect(reveal.clip.params.tint, DollColor.green);
      expect(
        reveal.clip.params.dollScale,
        closeTo(h.geometry.dollHeight(2) / (150 * h.geometry.scale), 1e-12),
      );
      // The drop starts where the new top stood: depth 1 of a tower that
      // buried 2, in composition units (the file authors 18).
      expect(
        reveal.clip.params.revealDrop,
        closeTo(
          (slot.surfaceY - slot.buriedBaseY(1, buried: 2)) / h.geometry.scale,
          1e-9,
        ),
      );

      expect(batch.reservations['r0c0'], at(framesMs(revealFrames)));
      expect(batch.reservations['r0c2'], at(framesMs(16)));
      expect(batch.endMs, at(framesMs(revealFrames)));
    });

    test('the buried silhouettes shift one step down with the drop, frames '
        '0–7 easeOut, keeping their true size (D21)', () {
      final start = only<StartTween>(batch);
      final shift = start.tween as RevealDropTween;
      final end = only<EndTween>(batch);
      final slot = h.geometry.slot('r0c0');
      expect(start.atMs, 0);
      expect(end.tween, same(shift));
      expect(end.atMs, at(framesMs(dropFrames)));
      expect(shift.durationMs, closeTo(framesMs(dropFrames), 1e-9));
      expect(shift.buried, 2, reason: 'the tower buried 2 at the start');
      // The clip draws the new top; the tween hides nothing.
      expect(shift.hides, isEmpty);

      // At the start: the rest pose before the reveal.
      expect(shift.progress, 0);
      expect(shift.buriedBaseY(1), slot.buriedBaseY(2, buried: 2));

      h.run(framesMs(dropFrames) / 2);
      expect(shift.t, closeTo(0.5, 1e-9));
      expect(shift.progress, greaterThan(0.5), reason: 'easeOut, as drop');
      expect(h.timeline.debugActiveTweens, [shift]);

      h.run(framesMs(dropFrames) / 2);
      expect(shift.progress, 1);
      expect(shift.buriedBaseY(1), slot.buriedBaseY(1, buried: 2));
      expect(h.timeline.debugActiveTweens, isEmpty);
    });

    test('reduced motion halves the drop and the reveal', () {
      h = TimelineHarness(towerLevel, motion: MotionSpec.reduced)..start();
      final reduced = h.move('r0c0', 'r0c2');
      expect(only<EndTween>(reduced).atMs, at(framesMs(dropFrames) / 2));
      final reveal = startOf(reduced, FxClipPurpose.reveal);
      expect(reveal.atMs, 0);
      expect(reveal.segment.speed, 2);
      expect(stopOf(reduced, reveal.clip), at(framesMs(revealFrames) / 2));
      expect(reduced.reservations['r0c0'], at(framesMs(revealFrames) / 2));
    });
  });

  group('Revealed on the destination after Completed (§7)', () {
    test('doll_reveal from t0 + 700 to t0 + 1216.7, the shift with its '
        'drop', () {
      h.select('r1c0');
      final batch = h.move('r1c0', 'r0c1'); // red3 swallows [red2, red1]
      final t0 = framesMs(40);
      final fly = t0 + framesMs(42);

      final start = only<StartTween>(batch);
      final shift = start.tween as RevealDropTween;
      expect(start.atMs, at(fly));
      expect(shift.slotId, 'r0c1');
      expect(only<EndTween>(batch).atMs, at(fly + framesMs(dropFrames)));
      final reveal = startOf(batch, FxClipPurpose.reveal);
      expect(reveal.atMs, at(fly));
      expect(reveal.clip.params.doll, DollColor.blue);
      expect(
        reveal.clip.params.dollScale,
        closeTo(h.geometry.dollHeight(1) / (150 * h.geometry.scale), 1e-12),
      );
      expect(stopOf(batch, reveal.clip), at(fly + framesMs(revealFrames)));
      expect(stopOf(batch, reveal.clip), closeTo(t0 + 1216.67, 0.01));

      // The set leaves, then the slot shows the tower's new rest look.
      expect(only<SyncSlot>(batch, (c) => c.slotId == 'r0c1').atMs, at(fly));
      expect(batch.reservations['r0c1'], at(t0 + framesMs(42 + revealFrames)));
    });
  });
}
