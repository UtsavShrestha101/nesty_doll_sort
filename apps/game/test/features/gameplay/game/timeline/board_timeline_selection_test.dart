import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_core/nesty_core.dart';
import 'package:nesty_game/core/services/audio/audio_service.dart';
import 'package:nesty_game/core/services/haptics/haptics_service.dart';
import 'package:nesty_game/features/fx/fx_cue.dart';
import 'package:nesty_game/features/fx/fx_id.dart';
import 'package:nesty_game/features/gameplay/bloc/board_effect.dart';
import 'package:nesty_game/features/gameplay/game/timeline/timeline.dart';

import 'support/timeline_fixtures.dart';

// Tutorial: red3 at r0c0, red2 at r0c2, red1 at r1c1.
const red3 = 'r0c0';
const red2 = 'r0c2';

void main() {
  late TimelineHarness h;

  setUp(() {
    h = TimelineHarness(tutorial)..start();
  });

  group('tap select (§7 SelectionChangedEffect(selected))', () {
    test('doll_pick lift → wobble loop; glow in → pulse; pick @0', () {
      final batch = h.select(red3);
      final slot = h.geometry.slot(red3);
      final pick = startOf(batch, FxClipPurpose.selection).clip;
      final glow = startOf(batch, FxClipPurpose.selectionGlow).clip;

      expect(batch.commands.map((c) => c.toString()), [
        '@0.0 start $pick FxSegment(0.0–7.0 ×1.0)',
        '@0.0 start $glow FxSegment(0.0–7.0 ×1.0)',
        '@116.7 play $pick FxSegment(7.0–31.0 loop ×1.0)',
        '@116.7 play $glow FxSegment(7.0–103.0 loop ×1.0)',
      ]);
      expect(
        only<PlayClipSegment>(batch, (c) => c.clip == pick).atMs,
        at(framesMs(7)),
      );
      expect(batch.cues, const [
        FxCue(atMs: 0, sound: SoundEffect.pick, haptic: HapticPattern.pick),
      ]);
      expect(batch.reservations, isEmpty);
      expect(batch.endMs, at(framesMs(7)));

      // doll_pick sits on the doll base at s and draws the slot's doll.
      expect(pick.fx, FxId.dollPick);
      expect(pick.placement.space, FxSpace.inPlace);
      expect(pick.placement.x, slot.centerX);
      expect(pick.placement.y, slot.surfaceY);
      expect(pick.placement.scale, h.geometry.scale);
      expect(pick.params.doll, DollColor.red);
      expect(
        pick.params.dollScale,
        closeTo(h.geometry.dollHeight(3) / (150 * h.geometry.scale), 1e-12),
      );
      expect(pick.hides, [red3]);
      expect(pick.anchor, FxAnchor.dollBase);

      // The glow ring's centre is (cx, surface − 2·fs), at fs.
      expect(glow.fx, FxId.fxSelectGlow);
      expect(glow.placement.y, slot.glowCenterY);
      expect(glow.placement.scale, slot.furnitureScale);
      expect(glow.hides, isEmpty);

      expect(h.timeline.selectedSlotId, red3);
      expect(h.timeline.selectionClip, pick);
    });

    test('reduced motion holds lift\'s last frame; the pulse stays 1×', () {
      h = TimelineHarness(tutorial, motion: MotionSpec.reduced)..start();
      final batch = h.select(red3);
      final pick = startOf(batch, FxClipPurpose.selection).clip;
      final glow = startOf(batch, FxClipPurpose.selectionGlow).clip;
      expect(batch.commands.map((c) => c.toString()), [
        '@0.0 start $pick FxSegment(0.0–7.0 ×2.0)',
        '@0.0 start $glow FxSegment(0.0–7.0 ×2.0)',
        '@58.3 play $pick FxSegment(hold 7.0)',
        '@58.3 play $glow FxSegment(7.0–103.0 loop ×1.0)',
      ]);
    });
  });

  group('deselect (§7 SelectionChangedEffect(previous))', () {
    test('doll_pick settle and glow out, then both return; no cue', () {
      final lift = h.select(red3);
      final pick = startOf(lift, FxClipPurpose.selection).clip;
      final glow = startOf(lift, FxClipPurpose.selectionGlow).clip;

      final batch = h.deselect(red3);
      expect(batch.commands.map((c) => c.toString()), [
        '@0.0 play $pick FxSegment(31.0–41.0 ×1.0)',
        '@0.0 play $glow FxSegment(103.0–113.0 ×1.0)',
        '@166.7 stop $pick',
        '@166.7 stop $glow',
      ]);
      expect(stopOf(batch, pick), at(framesMs(10)));
      expect(batch.cues, isEmpty);
      expect(batch.reservations, isEmpty);
      expect(h.timeline.selectedSlotId, isNull);
    });

    test('a re-tap mid-settle stops the settling clips first', () {
      final first = h.select(red3);
      final oldPick = startOf(first, FxClipPurpose.selection).clip;
      final oldGlow = startOf(first, FxClipPurpose.selectionGlow).clip;
      h
        ..deselect(red3)
        ..run(50);
      final batch = h.select(red3);
      final pick = startOf(batch, FxClipPurpose.selection).clip;
      expect(batch.commands.take(3).map((c) => c.toString()), [
        '@0.0 stop $oldPick',
        '@0.0 stop $oldGlow',
        '@0.0 start $pick FxSegment(0.0–7.0 ×1.0)',
      ]);
      // Executed now: the old clips were live and return to their pools.
      final executed = h.commands.executed.map((e) => e.command).toList();
      expect(
        executed.whereType<StopClip>().map((c) => c.clip),
        containsAll([oldPick, oldGlow]),
      );
    });
  });

  group('drag (§7 "Drag start", §9.4)', () {
    test('a drag start lifts and holds, with no wobble', () {
      final batch = h.select(red3, byDrag: true);
      final pick = startOf(batch, FxClipPurpose.selection).clip;
      expect(
        only<PlayClipSegment>(batch, (c) => c.clip == pick).segment,
        const FxSegment.hold(7),
      );
      expect(batch.cues.single.sound, SoundEffect.pick);
    });

    test('dragging the tap-lifted nest only stops its wobble', () {
      final lift = h.select(red3);
      final pick = startOf(lift, FxClipPurpose.selection).clip;
      final batch = h.schedule(
        const SelectionChangedEffect(selected: red3, byDrag: true),
      );
      expect(batch.commands.map((c) => c.toString()), [
        '@0.0 play $pick FxSegment(hold 7.0)',
      ]);
      expect(batch.cues, isEmpty, reason: 'the doll is already up');
      expect(h.timeline.selectionClip, pick);
    });

    test('a drag cancel flies from the finger back to the base', () {
      final lift = h.select(red3, byDrag: true);
      final pick = startOf(lift, FxClipPurpose.selection).clip;
      final glow = startOf(lift, FxClipPurpose.selectionGlow).clip;
      const finger = Offset(210, 380);

      final batch = h.deselect(red3, byDrag: true, at: finger);
      final move = startOf(batch, FxClipPurpose.move).clip;
      expect(batch.commands.map((c) => c.toString()), [
        '@0.0 stop $pick',
        '@0.0 play $glow FxSegment(103.0–113.0 ×1.0)',
        '@0.0 start $move FxSegment(0.0–16.0 ×1.0)',
        '@166.7 stop $glow',
        '@266.7 stop $move',
      ]);
      final slot = h.geometry.slot(red3);
      final fit = h.geometry.fit;
      expect(move.fx, FxId.dollMove);
      expect(move.placement, FxPlacement.boardSpace(fit));
      expect(move.hides, [red3]);
      expect(
        move.params.travelFrom,
        offsetNear(fit.referenceX(210), fit.referenceY(380)),
      );
      expect(
        move.params.travelTo,
        offsetNear(fit.referenceX(slot.centerX), fit.referenceY(slot.surfaceY)),
      );
      expect(batch.reservations, {red3: at(framesMs(16))});
      expect(batch.cues, isEmpty);
    });

    test('a drag start on another nest switches the selection', () {
      final first = h.select(red3);
      final oldPick = startOf(first, FxClipPurpose.selection).clip;
      final batch = h.schedule(
        const SelectionChangedEffect(
          previous: red3,
          selected: red2,
          byDrag: true,
        ),
      );
      expect(
        only<PlayClipSegment>(batch, (c) => c.clip == oldPick).segment,
        const FxSegment(31, 41),
      );
      final newPick = startOf(batch, FxClipPurpose.selection).clip;
      expect(newPick.slotId, red2);
      expect(
        only<PlayClipSegment>(batch, (c) => c.clip == newPick).segment,
        const FxSegment.hold(7),
      );
      expect(h.timeline.selectedSlotId, red2);
    });
  });
}
