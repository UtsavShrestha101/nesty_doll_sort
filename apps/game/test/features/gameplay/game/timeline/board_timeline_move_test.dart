import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_core/nesty_core.dart';
import 'package:nesty_game/core/services/audio/audio_service.dart';
import 'package:nesty_game/core/services/haptics/haptics_service.dart';
import 'package:nesty_game/features/fx/fx_cue.dart';
import 'package:nesty_game/features/fx/fx_id.dart';
import 'package:nesty_game/features/gameplay/game/timeline/timeline.dart';

import 'support/timeline_fixtures.dart';

// Tutorial: red3 at r0c0, red2 at r0c2, red1 at r1c1; r0c1 empty.
const red3 = 'r0c0';
const empty = 'r0c1';
const red2 = 'r0c2';

void main() {
  late TimelineHarness h;

  setUp(() {
    h = TimelineHarness(tutorial)..start();
  });

  double refX(double x) => h.geometry.fit.referenceX(x);
  double refY(double y) => h.geometry.fit.referenceY(y);

  group('Placed (§7)', () {
    test('glow out and a doll_move from the base to the target base', () {
      final lift = h.select(red3);
      final pick = startOf(lift, FxClipPurpose.selection).clip;
      final glow = startOf(lift, FxClipPurpose.selectionGlow).clip;

      final batch = h.move(red3, empty);
      final move = startOf(batch, FxClipPurpose.move).clip;
      expect(batch.commands.map((c) => c.toString()), [
        // Same-frame hand-off: doll_pick stops as doll_move starts, and
        // the source already shows what it holds now (§10.1).
        '@0.0 stop $pick',
        '@0.0 play $glow FxSegment(103.0–113.0 ×1.0)',
        '@0.0 sync $red3',
        '@0.0 start $move FxSegment(0.0–16.0 ×1.0)',
        '@166.7 stop $glow',
        // The nest shows on the target when it lands.
        '@266.7 stop $move',
        '@266.7 sync $empty',
      ]);
      expect(batch.cues, const [FxCue(atMs: 0, sound: SoundEffect.whoosh)]);
      expect(batch.reservations, {
        red3: at(framesMs(16)),
        empty: at(framesMs(16)),
      });
      expect(batch.endMs, at(framesMs(16)));

      final src = h.geometry.slot(red3);
      final dst = h.geometry.slot(empty);
      expect(move.placement, FxPlacement.boardSpace(h.geometry.fit));
      expect(move.params.doll, DollColor.red);
      expect(
        move.params.dollScale,
        closeTo(h.geometry.dollHeight(3) / (150 * h.geometry.scale), 1e-12),
      );
      expect(
        move.params.travelFrom,
        offsetNear(refX(src.centerX), refY(src.surfaceY)),
      );
      expect(
        move.params.travelTo,
        offsetNear(refX(dst.centerX), refY(dst.surfaceY)),
      );
      expect(move.hides, isEmpty, reason: 'the source synced at 0');
      expect(only<SyncSlot>(batch, (c) => c.slotId == empty).state, h.state);
      expect(h.timeline.selectedSlotId, isNull);
    });

    test('a drag drop flies from the finger', () {
      h.select(red3, byDrag: true);
      const finger = Offset(300, 420);
      final batch = h.move(red3, empty, byDrag: true, dragBase: finger);
      final move = startOf(batch, FxClipPurpose.move).clip;
      expect(move.params.travelFrom, offsetNear(refX(300), refY(420)));
    });

    test('a finger outside the board frame is clamped to it (§5, R6)', () {
      h.select(red3, byDrag: true);
      final frame = h.geometry.fit.frame;
      final batch = h.move(
        red3,
        empty,
        byDrag: true,
        dragBase: Offset(frame.right + 40, frame.top - 60),
      );
      final move = startOf(batch, FxClipPurpose.move).clip;
      expect(
        move.params.travelFrom,
        offsetNear(refX(frame.right), refY(frame.top)),
      );
    });
  });

  group('NestedInto (§7)', () {
    test('inside: doll_move to the 0.5 h hover, doll_nest, clack @536.7', () {
      h.select(red2);
      final batch = h.move(red2, red3);
      final move = startOf(batch, FxClipPurpose.move).clip;
      final nest = startOf(batch, FxClipPurpose.nest).clip;
      final dst = h.geometry.slot(red3);
      final h3 = h.geometry.dollHeight(3);
      final h2 = h.geometry.dollHeight(2);

      expect(nest.fx, FxId.dollNest);
      expect(
        move.params.travelTo,
        offsetNear(refX(dst.centerX), refY(dst.surfaceY - 0.5 * h3)),
      );
      expect(
        batch.commands.where((c) => c.atMs > 200).map((c) => c.toString()),
        [
          '@266.7 stop $move',
          '@266.7 start $nest FxSegment(0.0–24.0 ×1.0)',
          '@666.7 stop $nest',
          '@666.7 sync $red3',
        ],
      );
      expect(
        only<StartClip>(batch, (c) => c.clip == nest).atMs,
        at(framesMs(16)),
      );
      expect(stopOf(batch, nest), at(framesMs(16 + 24)));

      expect(batch.cues, [
        const FxCue(atMs: 0, sound: SoundEffect.whoosh),
        // The lid shuts 16.2 f into doll_nest: 266.7 + 270 (§17).
        FxCue(
          atMs: framesMs(16 + 16.2),
          sound: SoundEffect.clack,
          haptic: HapticPattern.nest,
          dollSize: 3,
        ),
      ]);
      expect(batch.cues.last.atMs, closeTo(536.67, 0.01));

      // Both dolls are in the file, so the target's sprite hides; the mover
      // chain sits inside target_size (§5).
      expect(nest.placement.x, dst.centerX);
      expect(nest.placement.y, dst.surfaceY);
      expect(nest.placement.scale, h.geometry.scale);
      expect(nest.hides, [red3]);
      expect(nest.params.mover, DollColor.red);
      expect(nest.params.target, DollColor.red);
      expect(
        nest.params.targetScale,
        closeTo(h3 / (150 * h.geometry.scale), 1e-12),
      );
      expect(nest.params.moverScale, closeTo(h2 / h3, 1e-12));
      expect(nest.params.rim, DollColor.red);

      expect(batch.reservations, {
        red2: at(framesMs(40)),
        red3: at(framesMs(40)),
      });
    });

    test('swallow: the 1.06 h hover, doll_swallow, clack by merged size', () {
      h.select(red3);
      final batch = h.move(red3, red2);
      final move = startOf(batch, FxClipPurpose.move).clip;
      final swallow = startOf(batch, FxClipPurpose.nest).clip;
      final dst = h.geometry.slot(red2);
      final h2 = h.geometry.dollHeight(2);
      final h3 = h.geometry.dollHeight(3);

      expect(swallow.fx, FxId.dollSwallow);
      expect(
        move.params.travelTo,
        offsetNear(refX(dst.centerX), refY(dst.surfaceY - 1.06 * h2)),
      );
      expect(swallow.params.mover, DollColor.red);
      expect(
        swallow.params.targetScale,
        closeTo(h2 / (150 * h.geometry.scale), 1e-12),
      );
      expect(swallow.params.moverScale, closeTo(h3 / h2, 1e-12));
      expect(swallow.hides, [red2]);
      final clack = batch.cues.singleWhere((c) => c.sound == SoundEffect.clack);
      expect(clack.dollSize, 3);
      expect(clack.atMs, at(framesMs(32.2)));
      expect(
        only<SyncSlot>(batch, (c) => c.slotId == red2).atMs,
        at(framesMs(40)),
      );
    });
  });

  group('input gating', () {
    test('the source and target drop input until the landing', () {
      h.select(red3);
      h.move(red3, empty);
      expect(h.timeline.acceptsInput(red3), isFalse);
      expect(h.timeline.acceptsInput(empty), isFalse);
      expect(h.timeline.acceptsInput(red2), isTrue);
      h.run(framesMs(16) - 1);
      expect(h.timeline.isReserved(empty), isTrue);
      h.run(1);
      expect(h.timeline.isReserved(empty), isFalse);
      expect(h.timeline.acceptsInput(red3), isTrue);
    });

    test('pause and an overlay lock every slot', () {
      h.timeline.paused = true;
      expect(h.timeline.inputLocked, isTrue);
      expect(h.timeline.acceptsInput(red2), isFalse);
      h.timeline
        ..paused = false
        ..overlayOpen = true;
      expect(h.timeline.acceptsInput(red2), isFalse);
      h.timeline.overlayOpen = false;
      expect(h.timeline.acceptsInput(red2), isTrue);
    });
  });
}
