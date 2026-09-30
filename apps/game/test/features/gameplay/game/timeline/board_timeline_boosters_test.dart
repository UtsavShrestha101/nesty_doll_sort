import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_core/nesty_core.dart';
import 'package:nesty_game/features/fx/fx_cue.dart';
import 'package:nesty_game/features/fx/fx_id.dart';
import 'package:nesty_game/features/gameplay/bloc/board_effect.dart';
import 'package:nesty_game/features/gameplay/game/timeline/timeline.dart';

import 'support/timeline_fixtures.dart';

void main() {
  late TimelineHarness h;

  setUp(() {
    h = TimelineHarness(tutorial)..start();
  });

  group('hint (frame 3.1, §7)', () {
    const move = Move('r0c2', 'r0c0'); // red2 into red3

    test('the arrow loops over the source; the target glows; the arc', () {
      final batch = h.schedule(const HintShownEffect(move));
      final arrow = startOf(batch, FxClipPurpose.hintArrow);
      final glow = startOf(batch, FxClipPurpose.hintGlow);
      final source = h.geometry.slot('r0c2');
      final target = h.geometry.slot('r0c0');

      expect(arrow.clip.fx, FxId.uiHintArrow);
      expect(arrow.segment, const FxSegment(0, 54, loop: true));
      expect(arrow.clip.placement.x, source.centerX);
      expect(arrow.clip.placement.y, source.hintArrowCenterY(2));
      expect(arrow.clip.placement.scale, source.furnitureScale);
      expect(arrow.clip.anchorSize, 2);

      expect(glow.clip.slotId, 'r0c0');
      expect(glow.clip.placement.y, target.glowCenterY);
      expect(
        only<PlayClipSegment>(batch, (c) => c.clip == glow.clip).segment,
        const FxSegment(7, 103, loop: true),
      );
      expect(only<SetHintArc>(batch).move, move);
      expect(batch.cues, isEmpty);
      expect(batch.reservations, isEmpty);
    });

    test('cleared: the arrow goes, the glow goes out, the arc hides', () {
      final shown = h.schedule(const HintShownEffect(move));
      final arrow = startOf(shown, FxClipPurpose.hintArrow).clip;
      final glow = startOf(shown, FxClipPurpose.hintGlow).clip;
      final batch = h.schedule(const HintClearedEffect());
      expect(batch.commands.map((c) => c.toString()), [
        '@0.0 stop $arrow',
        '@0.0 play $glow FxSegment(103.0–113.0 ×1.0)',
        '@0.0 hintArc null',
        '@166.7 stop $glow',
      ]);
      expect(h.schedule(const HintClearedEffect()).commands, isEmpty);
    });

    test('the informational loops stay 1× under reduced motion', () {
      h = TimelineHarness(tutorial, motion: MotionSpec.reduced)..start();
      final batch = h.schedule(const HintShownEffect(move));
      expect(startOf(batch, FxClipPurpose.hintArrow).segment.speed, 1);
      final glow = startOf(batch, FxClipPurpose.hintGlow);
      expect(glow.segment.speed, 2, reason: '`in` is a one-shot');
      expect(
        only<PlayClipSegment>(batch, (c) => c.clip == glow.clip).segment.speed,
        1,
      );
    });
  });

  group('+1 Slot (frame 3.6, §7, §9.5)', () {
    test('re-pitch 0–280 (motion.rowOfFive), the stand pulses from 280, no cue '
        'of its own '
        '(the tapped button already played button + the selection haptic; '
        'BACKLOG "+1 Slot plays button twice")', () {
      final old = h.geometry;
      final batch = h.addExtraSlot();
      final start = only<StartTween>(batch);
      final repitch = start.tween as RepitchTween;
      expect(start.atMs, 0);
      expect(repitch.from, same(old));
      expect(repitch.to, same(h.geometry));
      expect(h.geometry.slotOrNull('x0'), isNotNull);
      expect(only<EndTween>(batch).atMs, at(280));

      final pulse = startOf(batch, FxClipPurpose.extraSlot);
      final stand = h.geometry.slot('x0');
      expect(pulse.atMs, at(280));
      expect(pulse.clip.fx, FxId.uiExtraSlot);
      expect(pulse.segment, const FxSegment(0, 96, loop: true));
      expect(pulse.clip.placement.x, stand.centerX);
      expect(pulse.clip.placement.y, stand.standCenterY);
      expect(pulse.clip.placement.scale, stand.furnitureScale);
      // It opens on the file's `rest` marker, frame 0, which is the static
      // pad's own pose since m7-3 (E.21, D184): no phase offset, no pop.
      expect(FxTiming.extraSlotRestFrame, 0);
      expect(pulse.segment.from, FxTiming.extraSlotRestFrame);
      expect(pulse.phaseMs, 0);

      expect(
        batch.cues,
        isEmpty,
        reason:
            'the button that triggered this already played its own '
            'button sound and selection haptic (TactileSurface); a cue '
            'here would play them twice',
      );
      expect(batch.globalLockMs, at(280));
      expect(h.timeline.inputLocked, isTrue);
      h.run(279);
      expect(repitch.progress, greaterThan(0.99));
      expect(h.timeline.inputLocked, isTrue);
      h.run(1);
      expect(h.timeline.inputLocked, isFalse);
      expect(repitch.progress, 1);
    });

    test('the selection and the hint move onto the new layout at 280', () {
      final lift = h.select('r1c1'); // red1, on the bottom shelf
      final pick = startOf(lift, FxClipPurpose.selection).clip;
      final glow = startOf(lift, FxClipPurpose.selectionGlow).clip;
      final batch = h.addExtraSlot();
      final places = batch.commandsOf<PlaceClip>().toList();
      expect(places.map((c) => c.clip), [pick, glow]);
      expect(places.map((c) => c.atMs), [at(280), at(280)]);
      final slot = h.geometry.slot('r1c1');
      expect(places[0].placement.x, slot.centerX);
      expect(places[0].placement.y, slot.surfaceY);
      expect(
        places[0].params.dollScale,
        closeTo(h.geometry.dollHeight(1) / (150 * h.geometry.scale), 1e-12),
      );
      expect(places[1].placement.y, slot.glowCenterY);
      // Moving a clip doesn't cancel what it plays.
      h.run(400);
      final executed = h.commands.executed.map((e) => e.command).toList();
      expect(
        executed.whereType<PlayClipSegment>().where((c) => c.clip == pick),
        hasLength(1),
        reason: 'the wobble still started',
      );
    });

    test('a second slot re-places the first stand', () {
      h
        ..addExtraSlot()
        ..run(400);
      final batch = h.addExtraSlot();
      final place = only<PlaceClip>(batch);
      expect(place.clip.slotId, 'x0');
      expect(place.placement.x, h.geometry.slot('x0').centerX);
      expect(startOf(batch, FxClipPurpose.extraSlot).clip.slotId, 'x1');
    });

    test('a second slot during the re-pitch waits for it: its re-pitch runs '
        'from the first one\'s end layout (review CORRECTNESS-4)', () {
      final first = h.addExtraSlot();
      final firstRepitch = only<StartTween>(first).tween as RepitchTween;
      h.run(120);
      final second = h.addExtraSlot();
      final start = only<StartTween>(second);
      final repitch = start.tween as RepitchTween;
      // 120 ms in: it starts at the first one's end (280), from its layout.
      expect(start.atMs, at(160));
      expect(repitch.from, same(firstRepitch.to));
      expect(repitch.to, same(h.geometry));
      expect(only<EndTween>(second).atMs, at(440));
      expect(startOf(second, FxClipPurpose.extraSlot).atMs, at(440));
      expect(second.globalLockMs, at(440));

      // The first finishes before the second begins, and the board stays
      // locked through both.
      h.run(159);
      expect(firstRepitch.progress, greaterThan(0.99));
      expect(repitch.progress, 0);
      expect(h.timeline.inputLocked, isTrue);
      h.run(151);
      expect(firstRepitch.progress, 1);
      expect(repitch.progress, inExclusiveRange(0.3, 0.7));
      expect(h.timeline.inputLocked, isTrue);
      h.run(150);
      expect(repitch.progress, 1);
      expect(h.timeline.inputLocked, isFalse);
    });

    test('reduced motion re-pitches in 140 ms', () {
      h = TimelineHarness(tutorial, motion: MotionSpec.reduced)..start();
      final batch = h.addExtraSlot();
      expect(only<EndTween>(batch).atMs, at(140));
      expect(startOf(batch, FxClipPurpose.extraSlot).segment.speed, 1);
      expect(batch.globalLockMs, at(140));
    });
  });

  group('BoardResetEffect (§7)', () {
    test('cancels everything queued and rebuilds from the snapshot', () {
      h.select('r0c2');
      h.move('r0c2', 'r0c0');
      h.run(100);
      final before = h.commands.executed.length;
      final batch = h.schedule(
        BoardResetEffect(snapshot: h.state, reason: BoardResetReason.undo),
      );
      final reset = only<ResetBoard>(batch);
      expect(reset.atMs, 0);
      expect(reset.snapshot, h.state);
      expect(reset.reason, BoardResetReason.undo);
      expect(h.timeline.isReserved('r0c0'), isFalse);
      expect(h.timeline.selectedSlotId, isNull);
      expect(h.timeline.isIdle, isTrue);
      h.run(2000);
      // Only the reset ran: the move's landing never plays.
      expect(h.commands.executed.skip(before).map((e) => e.command), [reset]);
    });

    test('clears the win lock; extra slots pulse again at once', () {
      h
        ..addExtraSlot()
        ..run(400)
        ..move('r0c2', 'r0c0')
        ..run(1000)
        ..move('r1c1', 'r0c0');
      expect(h.timeline.inputLocked, isTrue, reason: 'won');
      final batch = h.schedule(
        BoardResetEffect(snapshot: h.state, reason: BoardResetReason.restart),
      );
      expect(h.timeline.inputLocked, isFalse);
      final pulse = startOf(batch, FxClipPurpose.extraSlot);
      expect(pulse.atMs, 0);
      expect(pulse.clip.slotId, 'x0');
      expect(batch.commands.first, isA<ResetBoard>());
    });

    test('a new level takes its layout', () {
      final next = geometryOf(GameState.initial(towerLevel));
      h.timeline.schedule(
        BoardResetEffect(
          snapshot: GameState.initial(towerLevel),
          reason: BoardResetReason.start,
        ),
        GameState.initial(towerLevel),
        geometry: next,
      );
      expect(h.timeline.geometry, same(next));
    });
  });

  group('OutOfMoves (§7)', () {
    test('onOutOfMoves when the board goes idle', () {
      h = TimelineHarness(outOfMoves)..start();
      h.select('r0c0');
      final batch = h.move('r0c0', 'r0c3'); // blue1 off the tower: stuck
      final oom = only<BoardOutOfMoves>(batch);
      // The source reveal is the last thing playing: doll_reveal, 31
      // frames from the lift-off, its drop included (LOTTIE.md v3).
      expect(oom.atMs, at(framesMs(31)));
      expect(batch.commands.last, same(oom));
      expect(batch.locksInput, isFalse);
      expect(h.timeline.inputLocked, isFalse);
    });
  });
}
