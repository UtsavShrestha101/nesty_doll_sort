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

  group('Revealed on the source tower (§7, §9.1)', () {
    late TimelineBatch batch;

    setUp(() {
      h.select('r0c0');
      batch = h.move('r0c0', 'r0c2'); // blue3 leaves: green2 shows
    });

    test('the drop 0–120, then doll_reveal 120–520 on the surface', () {
      final start = only<StartTween>(batch);
      final drop = start.tween as RevealDropTween;
      final end = only<EndTween>(batch);
      final reveal = startOf(batch, FxClipPurpose.reveal);
      expect(start.atMs, 0);
      expect(end.tween, same(drop));
      expect(end.atMs, at(120));
      expect(drop.durationMs, 120);
      expect(reveal.atMs, at(120));
      expect(reveal.clip.fx, FxId.dollReveal);
      expect(reveal.segment, const FxSegment(0, 24));
      expect(stopOf(batch, reveal.clip), at(120 + framesMs(24)));
      expect(stopOf(batch, reveal.clip), closeTo(520, 1e-6));

      // The "+N" tag counts down when the top leaves (the sync at 0), and
      // both the drop and the reveal draw the new top.
      expect(only<SyncSlot>(batch, (c) => c.slotId == 'r0c0').atMs, 0);
      expect(drop.hides, ['r0c0']);
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

      expect(batch.reservations['r0c0'], at(520));
      expect(batch.reservations['r0c2'], at(framesMs(16)));
      expect(batch.endMs, at(520));
    });

    test('the drop moves true-size silhouettes one step down (D21)', () {
      final drop = only<StartTween>(batch).tween as RevealDropTween;
      final slot = h.geometry.slot('r0c0');
      expect(drop.revealedSize, 2);
      expect(drop.revealedColor, DollColor.green);
      expect(drop.buried, 2, reason: 'the tower buried 2 at the start');

      // At the start: the rest pose before the reveal.
      expect(drop.progress, 0);
      expect(drop.revealedBaseY, slot.buriedBaseY(1, buried: 2));
      expect(drop.buriedBaseY(1), slot.buriedBaseY(2, buried: 2));

      h.run(60);
      expect(drop.t, closeTo(0.5, 1e-9));
      expect(drop.progress, lessThan(0.5), reason: 'easeIn');
      expect(h.timeline.debugActiveTweens, [drop]);

      h.run(60);
      expect(drop.progress, 1);
      expect(drop.revealedBaseY, slot.surfaceY);
      expect(drop.buriedBaseY(1), slot.buriedBaseY(1, buried: 2));
      expect(h.timeline.debugActiveTweens, isEmpty);
    });

    test('reduced motion halves the drop and the reveal', () {
      h = TimelineHarness(towerLevel, motion: MotionSpec.reduced)..start();
      final reduced = h.move('r0c0', 'r0c2');
      expect(only<EndTween>(reduced).atMs, at(60));
      final reveal = startOf(reduced, FxClipPurpose.reveal);
      expect(reveal.atMs, at(60));
      expect(reveal.segment.speed, 2);
      expect(stopOf(reduced, reveal.clip), at(260));
      expect(reduced.reservations['r0c0'], at(260));
    });
  });

  group('Revealed on the destination after Completed (§7)', () {
    test('the drop at t0 + 700, doll_reveal until t0 + 1220', () {
      h.select('r1c0');
      final batch = h.move('r1c0', 'r0c1'); // red3 swallows [red2, red1]
      final t0 = framesMs(40);
      final fly = t0 + framesMs(42);

      final start = only<StartTween>(batch);
      final drop = start.tween as RevealDropTween;
      expect(start.atMs, at(fly));
      expect(drop.slotId, 'r0c1');
      expect(drop.revealedColor, DollColor.blue);
      expect(drop.revealedSize, 1);
      expect(only<EndTween>(batch).atMs, at(fly + 120));
      final reveal = startOf(batch, FxClipPurpose.reveal);
      expect(reveal.atMs, at(fly + 120));
      expect(stopOf(batch, reveal.clip), at(fly + 520));
      expect(stopOf(batch, reveal.clip), closeTo(t0 + 1220, 1e-6));

      // The set leaves, then the slot shows the tower's new rest look.
      expect(only<SyncSlot>(batch, (c) => c.slotId == 'r0c1').atMs, at(fly));
      expect(batch.reservations['r0c1'], at(t0 + 1220));
    });
  });
}
