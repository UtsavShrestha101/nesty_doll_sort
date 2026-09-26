import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_core/nesty_core.dart';
import 'package:nesty_game/core/services/audio/audio_service.dart';
import 'package:nesty_game/core/services/haptics/haptics_service.dart';
import 'package:nesty_game/features/fx/fx_id.dart';
import 'package:nesty_game/features/gameplay/bloc/board_effect.dart';
import 'package:nesty_game/features/gameplay/game/timeline/timeline.dart';

import 'support/timeline_fixtures.dart';

void main() {
  // t0 = the end of the landing: doll_move 16 f + doll_nest 24 f.
  final t0 = framesMs(40);
  final fly = t0 + framesMs(42);
  final landed = t0 + framesMs(75);

  group('Completed + Won (tutorial, §7)', () {
    late TimelineHarness h;
    late TimelineBatch batch;
    late int executedBefore;
    late int playedBefore;

    setUp(() {
      h = TimelineHarness(tutorial)..start();
      // red2 into red3, then red1 into [red3, red2]: a full set, and the win.
      h
        ..move('r0c2', 'r0c0')
        ..run(1000)
        ..select('r1c1');
      executedBefore = h.commands.executed.length;
      playedBefore = h.feedback.played.length;
      batch = h.move('r1c1', 'r0c0');
    });

    test('doll_complete from t0, flying at t0 + 700', () {
      final complete = startOf(batch, FxClipPurpose.complete).clip;
      expect(complete.fx, FxId.dollComplete);
      expect(only<StartClip>(batch, (c) => c.clip == complete).atMs, at(t0));
      expect(t0, closeTo(666.67, 0.01));
      expect(
        only<ReleaseClipSlots>(batch, (c) => c.clip == complete).atMs,
        at(fly),
      );
      expect(fly, closeTo(1366.67, 0.01));
      expect(stopOf(batch, complete), at(landed));
      expect(landed, closeTo(1916.67, 0.01));

      // It draws the set on its slot until it flies; the slot then shows
      // its new rest look.
      expect(complete.hides, ['r0c0']);
      expect(only<SyncSlot>(batch, (c) => c.slotId == 'r0c0').atMs, at(fly));

      final slot = h.geometry.slot('r0c0');
      final fit = h.geometry.fit;
      final h3 = h.geometry.dollHeight(3);
      final counter = h.geometry.familyCounterTargetReference;
      expect(complete.placement, FxPlacement.boardSpace(fit));
      expect(complete.params.doll, DollColor.red);
      expect(
        complete.params.travelFrom,
        offsetNear(fit.referenceX(slot.centerX), fit.referenceY(slot.surfaceY)),
      );
      // The counter centre + 0.1 × the doll's height, in reference units.
      expect(
        complete.params.travelTo,
        offsetNear(counter.dx, counter.dy + 0.1 * h3 / fit.scale),
      );
    });

    test('dust at the fly, then 10 sparkles on the trail every 60 ms', () {
      final complete = startOf(batch, FxClipPurpose.complete).clip;
      final dust = startOf(batch, FxClipPurpose.dust);
      expect(dust.atMs, at(fly));
      expect(dust.clip.fx, FxId.fxDustPuff);
      final slot = h.geometry.slot('r0c0');
      expect(dust.clip.placement.y, slot.surfaceY);
      expect(dust.clip.placement.scale, slot.furnitureScale);
      expect(stopOf(batch, dust.clip), at(fly + framesMs(24)));

      final sparkles = batch
          .commandsOf<StartClip>()
          .where((c) => c.clip.purpose == FxClipPurpose.sparkle)
          .toList();
      expect(sparkles.map((c) => c.atMs), [
        for (var k = 0; k < 10; k++) at(fly + 60 * k),
      ]);
      expect(sparkles.last.atMs, closeTo(t0 + 1240, 0.01));
      for (final s in sparkles) {
        expect(s.clip.placement.space, FxSpace.trail);
        expect(s.clip.placement.trailOf, complete.id);
        expect(s.clip.placement.scale, h.geometry.scale);
        expect(stopOf(batch, s.clip), at(s.atMs + framesMs(16)));
      }
    });

    test('the counter bumps at t0 + 1250 and Won fires 250 after it', () {
      final landedCommand = only<FamilyLanded>(batch);
      expect(landedCommand.atMs, at(landed));
      expect(landedCommand.setsCompleted, 1);
      expect(landedCommand.totalSets, 1);
      expect(landedCommand.sparkleScale, 1.5);

      // Won: the counter bump (12 f) ends at t0 + 1450, then + 250.
      final won = only<BoardWon>(batch);
      expect(won.atMs, at(landed + framesMs(12) + 250));
      expect(won.atMs, closeTo(2366.67, 0.01));
      expect(won.moveCount, 2);
      expect(batch.endMs, at(won.atMs));
      expect(batch.locksInput, isTrue);
      expect(h.timeline.inputLocked, isTrue);
    });

    test('complete_1 + success @t0; reservations', () {
      expect(batch.cues, [
        isCue(0, sound: SoundEffect.whoosh),
        isCue(
          framesMs(32.2),
          sound: SoundEffect.clack,
          haptic: HapticPattern.nest,
          dollSize: 3,
        ),
        isCue(
          t0,
          sound: SoundEffect.complete,
          haptic: HapticPattern.complete,
          comboStep: 1,
        ),
      ]);
      expect(batch.reservations, {'r1c1': at(t0), 'r0c0': at(fly)});
    });

    test('the executed order matches the plan over real frames', () {
      h.run(3000);
      final executed = h.commands.executed.skip(executedBefore).toList();
      // Every planned command ran, in plan order, each in the first frame
      // at or after its time.
      expect(executed.map((e) => e.command), orderedEquals(batch.commands));
      for (final e in executed) {
        final due = batch.startMs + e.command.atMs;
        expect(e.atMs, greaterThanOrEqualTo(due - 1e-6));
        expect(e.atMs - due, lessThan(1000 / 60 + 1e-6));
        expect(e.lateMs, closeTo(e.atMs - due, 1e-6));
      }
      expect(
        executed.map((e) => e.command).whereType<FamilyLanded>(),
        hasLength(1),
      );
      final played = h.feedback.played
          .skip(playedBefore)
          .map((p) => p.cue.sound)
          .toList();
      expect(played, [
        SoundEffect.whoosh,
        SoundEffect.clack,
        SoundEffect.complete,
      ]);
    });
  });

  group('Completed + Unlocked + IceCracked (§7, §8)', () {
    late TimelineHarness h;
    late TimelineBatch batch;

    setUp(() {
      h = TimelineHarness(comboLevel)..start();
      h.select('r0c0');
      // red3 swallows [red2, red1]: red completes on r0c1, the red glass on
      // r0c2 breaks and r0c3's ice drops 3 → 2.
      batch = h.move('r0c0', 'r0c1');
    });

    test('slot events start at t0 + 700, 80 ms apart, in core order', () {
      final slotFx = batch.commandsOf<PlaySlotFx>().toList();
      expect(slotFx.map((c) => c.toString()), [
        '@1366.7 slotFx r0c2 fx_glass_unlock FxSegment(0.0–54.0 ×1.0)',
        '@1446.7 slotFx r0c3 fx_ice FxSegment(0.0–16.0 ×1.0)',
        '@1713.3 slotFx r0c3 fx_ice FxSegment(hold 16.0)',
      ]);
      expect(slotFx[0].atMs, at(fly));
      expect(slotFx[1].atMs, at(fly + 80));
      expect(slotFx[2].atMs, at(fly + 80 + framesMs(16)));

      final release = only<ReleaseSlotFx>(batch);
      expect(release.slotId, 'r0c2');
      expect(release.fx, FxId.fxGlassUnlock);
      expect(release.atMs, at(fly + framesMs(54)));

      // Each slot syncs at its start: the badge counts down, the freed doll
      // becomes the sprite when its composition is released.
      expect(only<SyncSlot>(batch, (c) => c.slotId == 'r0c2').atMs, at(fly));
      expect(
        only<SyncSlot>(batch, (c) => c.slotId == 'r0c3').atMs,
        at(fly + 80),
      );
    });

    test('unlock_glass + medium, ice_crack + light at their starts', () {
      final slotCues = batch.cues.where((c) => c.atMs >= fly - 1e-6).toList();
      expect(slotCues, [
        isCue(
          fly,
          sound: SoundEffect.unlockGlass,
          haptic: HapticPattern.unlock,
        ),
        isCue(
          fly + 80,
          sound: SoundEffect.iceCrack,
          haptic: HapticPattern.iceCrack,
        ),
      ]);
    });

    test('each slot is reserved to its clip end; the batch ends last', () {
      expect(batch.reservations, {
        'r0c0': at(t0),
        'r0c1': at(fly),
        'r0c2': at(fly + framesMs(54)),
        'r0c3': at(fly + 80 + framesMs(16)),
      });
      expect(batch.endMs, at(fly + framesMs(54)));
      expect(batch.commandsOf<BoardWon>(), isEmpty);
    });

    test('a second completion within 4 s raises the combo; crack_2', () {
      h
        ..run(1500)
        ..move('r1c2', 'r1c1') // green3 off the tower (reveals green1)
        ..move('r1c3', 'r1c1'); // green2 into green3
      final second = h.move('r1c2', 'r1c1'); // green1: green completes
      final complete = second.cues.singleWhere(
        (c) => c.sound == SoundEffect.complete,
      );
      expect(complete.comboStep, 2);
      // Ice 2 → 1 of 3: stage 1 → 2.
      final crack = only<PlaySlotFx>(second, (c) => !c.segment.isHold);
      expect(crack.segment, const FxSegment(16, 32));
      expect(
        only<PlaySlotFx>(second, (c) => c.segment.isHold).segment,
        const FxSegment.hold(32),
      );
    });

    test('a completion after the window starts the combo over', () {
      h
        ..run(5000)
        ..move('r1c2', 'r1c1')
        ..move('r1c3', 'r1c1');
      final second = h.move('r1c2', 'r1c1');
      expect(
        second.cues
            .singleWhere((c) => c.sound == SoundEffect.complete)
            .comboStep,
        1,
      );
    });

    test('a restart resets the combo; the injected clock drives it', () {
      var clock = 0.0;
      final combo = ComboTracker(clock: () => clock);
      h = TimelineHarness(comboLevel, combo: combo)..start();
      h.move('r0c0', 'r0c1');
      expect(combo.step, 1);
      clock = 1000;
      h.schedule(
        BoardResetEffect(snapshot: h.state, reason: BoardResetReason.restart),
      );
      expect(combo.step, 0);
    });
  });

  group('ice stages (D51, BoardLayout.iceFrame)', () {
    // A completion with the given slot events on r0c2's ice.
    TimelineBatch completeWith(TimelineHarness h, List<MoveEvent> events) {
      const red3 = Nest.run;
      final nest = red3(DollColor.red, outer: 3, length: 3);
      return h.schedule(
        MoveAppliedEffect(
          result: MoveApplied(
            move: const Move('r0c0', 'r0c1'),
            state: h.state,
            events: [
              Picked(
                slotId: 'r0c0',
                nest: nest,
                fromTower: false,
                leftEmptyTower: false,
              ),
              Placed(fromId: 'r0c0', slotId: 'r0c1', nest: nest),
              const Completed(
                slotId: 'r0c1',
                color: DollColor.red,
                setsCompleted: 1,
                totalSets: 2,
                leftEmptyTower: false,
              ),
              ...events,
            ],
            completedSet: true,
          ),
        ),
      );
    }

    List<FxSegment> slotSegments(TimelineBatch batch) => [
      for (final c in batch.commandsOf<PlaySlotFx>()) c.segment,
    ];

    test('ice 4: 4 → 3 stays on stage 0, so no clip but the cue', () {
      final h = TimelineHarness(icedTutorial(4))..start();
      final batch = completeWith(h, const [
        IceCracked(slotId: 'r0c2', remaining: 3),
      ]);
      expect(slotSegments(batch), isEmpty);
      expect(
        batch.cues.where((c) => c.sound == SoundEffect.iceCrack),
        hasLength(1),
      );
      expect(
        batch.commandsOf<SyncSlot>().map((c) => c.slotId),
        contains('r0c2'),
      );
    });

    test('ice 4: 3 → 2 cracks to stage 1, 2 → 1 to stage 2', () {
      final h = TimelineHarness(icedTutorial(4))..start();
      expect(
        slotSegments(
          completeWith(h, const [IceCracked(slotId: 'r0c2', remaining: 2)]),
        ),
        const [FxSegment(0, 16), FxSegment.hold(16)],
      );
      expect(
        slotSegments(
          completeWith(h, const [IceCracked(slotId: 'r0c2', remaining: 1)]),
        ),
        const [FxSegment(16, 32), FxSegment.hold(32)],
      );
    });

    test('ice 2: 2 → 1 is crack_1; the shatter always starts at 48', () {
      final h = TimelineHarness(icedTutorial(2))..start();
      expect(
        slotSegments(
          completeWith(h, const [IceCracked(slotId: 'r0c2', remaining: 1)]),
        ),
        const [FxSegment(0, 16), FxSegment.hold(16)],
      );
      final shatter = completeWith(h, const [IceShattered(slotId: 'r0c2')]);
      expect(slotSegments(shatter), const [FxSegment(48, 81)]);
      final release = only<ReleaseSlotFx>(shatter);
      expect(release.fx, FxId.fxIce);
      expect(
        release.atMs - shatter.commandsOf<PlaySlotFx>().single.atMs,
        at(framesMs(33)),
      );
    });

    test('ice_shatter has no haptic (D49)', () {
      final h = TimelineHarness(icedTutorial(1))..start();
      final batch = completeWith(h, const [IceShattered(slotId: 'r0c2')]);
      final cue = batch.cues.singleWhere(
        (c) => c.sound == SoundEffect.iceShatter,
      );
      expect(cue.haptic, isNull);
    });

    test('reduced motion makes the ice null static', () {
      final h = TimelineHarness(icedTutorial(3), motion: MotionSpec.reduced)
        ..start();
      final batch = completeWith(h, const [
        IceCracked(slotId: 'r0c2', remaining: 2),
      ]);
      final crack = batch.commandsOf<PlaySlotFx>().first;
      expect(crack.shake, isFalse);
      expect(crack.segment.speed, 2);
    });
  });
}
