import 'package:flutter/painting.dart' show EdgeInsets, Size;
import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_game/core/services/audio/audio_service.dart';
import 'package:nesty_game/features/fx/fx_id.dart';
import 'package:nesty_game/features/gameplay/game/timeline/timeline.dart';
import 'package:nesty_render/nesty_render.dart';

import 'support/timeline_fixtures.dart';

void main() {
  group('dispatch', () {
    test('time-0 commands run inside schedule; later ones on advance', () {
      final h = TimelineHarness(tutorial)..start();
      final before = h.commands.executed.length;
      final batch = h.select('r0c0');
      final now = h.commands.executed.skip(before).toList();
      expect(now.map((e) => e.command), batch.commands.take(2));
      expect(now.map((e) => e.lateMs), [0, 0]);
      expect(h.feedback.played.last.cue.sound, SoundEffect.pick);

      // Due at 116.7, run in the frame that reaches 133.3: 16.7 late.
      h.timeline.advance(100);
      expect(h.commands.executed.length, before + 2);
      h.timeline.advance(1000 / 30);
      final late = h.commands.executed.skip(before + 2).toList();
      expect(late.map((e) => e.command), batch.commands.skip(2));
      for (final e in late) {
        expect(e.lateMs, closeTo(100 + 1000 / 30 - framesMs(7), 1e-6));
      }
    });

    test('a later plan for a clip drops the earlier plan\'s rest', () {
      final h = TimelineHarness(tutorial)..start();
      final lift = h.select('r0c0');
      final glow = startOf(lift, FxClipPurpose.selectionGlow).clip;
      h.run(50);
      h.move('r0c0', 'r0c1'); // before the pulse was due
      h.run(500);
      final forGlow = [
        for (final e in h.commands.executed)
          if (_clipIdOf(e.command) == glow.id)
            e.command.toString().split(' ').skip(1).join(' '),
      ];
      expect(forGlow, [
        'start $glow FxSegment(0.0–7.0 ×1.0)',
        'play $glow FxSegment(103.0–113.0 ×1.0)',
        'stop $glow',
      ]);
    });

    test('sprites hide exactly while a clip or tween draws them', () {
      final h = TimelineHarness(towerLevel)..start();
      final sprites = SpriteModel();
      var seen = 0;
      void sync() {
        for (; seen < h.commands.executed.length; seen++) {
          sprites.apply(h.commands.executed[seen].command);
        }
      }

      h.select('r1c0'); // red3
      sync();
      expect(sprites.isHidden('r1c0'), isTrue, reason: 'doll_pick draws it');
      h.move('r1c0', 'r0c1'); // swallows [red2, red1]: completes, reveals
      sync();
      expect(sprites.isHidden('r1c0'), isFalse, reason: 'synced empty at 0');
      expect(sprites.isHidden('r0c1'), isFalse, reason: 'target until 267');
      h.run(framesMs(16) + 1);
      sync();
      expect(sprites.isHidden('r0c1'), isTrue, reason: 'doll_swallow');
      h.run(framesMs(24) + framesMs(42));
      sync();
      expect(sprites.isHidden('r0c1'), isTrue, reason: 'the reveal drop');
      h.run(520);
      sync();
      expect(sprites.hidden.values, everyElement(0));
      expect(h.timeline.isIdle, isFalse, reason: 'the flight still plays');
      h.run(1000);
      sync();
      expect(h.timeline.isIdle, isTrue);
      expect(sprites.hidden.values, everyElement(0));
    });
  });

  group('rule 3: a file that failed to load', () {
    test('skips its clip (and its trail) but keeps cues and gating', () {
      TimelineHarness play({bool Function(FxId)? isAvailable}) {
        final h = TimelineHarness(tutorial, isAvailable: isAvailable)
          ..start()
          ..move('r0c2', 'r0c0')
          ..run(1000)
          ..move('r1c1', 'r0c0')
          ..run(3000);
        return h;
      }

      final ok = play();
      final failed = play(isAvailable: (id) => id != FxId.dollComplete);

      List<String> cues(TimelineHarness h) => [
        for (final p in h.feedback.played)
          '${p.atMs.toStringAsFixed(3)} ${p.cue}',
      ];
      expect(cues(failed), cues(ok));

      final executed = [for (final e in failed.commands.executed) e.command];
      final clips = executed.whereType<StartClip>().map((c) => c.clip);
      expect(clips.where((c) => c.fx == FxId.dollComplete), isEmpty);
      expect(clips.where((c) => c.fx == FxId.fxSparkle), isEmpty);
      expect(clips.where((c) => c.fx == FxId.fxDustPuff), hasLength(1));
      expect(
        executed.whereType<ReleaseClipSlots>(),
        isEmpty,
        reason: 'commands for a clip that never started are dropped',
      );
      // The landing, the sync, the counter and the win still happen.
      expect(executed.whereType<FamilyLanded>(), hasLength(1));
      expect(executed.whereType<BoardWon>(), hasLength(1));
      expect(
        executed.whereType<SyncSlot>().map((c) => c.slotId),
        contains('r0c0'),
      );
    });

    test('an exhausted pool skips the extra clip', () {
      final h = TimelineHarness(
        tutorial,
        poolSizes: {...TimelinePools.defaults, FxId.fxSparkle: 3},
      )..start();
      h
        ..move('r0c2', 'r0c0')
        ..run(1000)
        ..move('r1c1', 'r0c0')
        ..run(3000);
      var live = 0;
      var most = 0;
      var started = 0;
      for (final e in h.commands.executed) {
        final command = e.command;
        if (command is StartClip && command.clip.fx == FxId.fxSparkle) {
          live++;
          started++;
        } else if (command is StopClip && command.clip.fx == FxId.fxSparkle) {
          live--;
        }
        if (live > most) most = live;
      }
      expect(most, 3);
      expect(started, inInclusiveRange(4, 9));
      expect(live, 0);
    });
  });

  group('reduced motion (D48)', () {
    test('halves every time of a complete + unlock + ice batch', () {
      TimelineBatch batchAt(MotionSpec motion) => (TimelineHarness(
        comboLevel,
        motion: motion,
      )..start()).move('r0c0', 'r0c1');

      final full = batchAt(MotionSpec.standard);
      final half = batchAt(MotionSpec.reduced);
      expect(half.commands.length, full.commands.length);
      for (var i = 0; i < full.commands.length; i++) {
        final a = full.commands[i];
        final b = half.commands[i];
        expect(b.runtimeType, a.runtimeType, reason: '$a');
        expect(b.atMs, closeTo(a.atMs / 2, 1e-6), reason: '$a');
      }
      expect(half.cues.length, full.cues.length);
      for (var i = 0; i < full.cues.length; i++) {
        expect(half.cues[i].atMs, closeTo(full.cues[i].atMs / 2, 1e-6));
        expect(half.cues[i].sound, full.cues[i].sound);
      }
      expect(half.endMs, closeTo(full.endMs / 2, 1e-6));
      for (final entry in full.reservations.entries) {
        expect(half.reservations[entry.key], closeTo(entry.value / 2, 1e-6));
      }
      // The table's reduced numbers: clack @268, complete @333, unlocks
      // from t0 + 350 (§13).
      expect(
        half.cues.singleWhere((c) => c.sound == SoundEffect.clack).atMs,
        closeTo(268.33, 0.01),
      );
      expect(
        half.cues.singleWhere((c) => c.sound == SoundEffect.complete).atMs,
        closeTo(333.33, 0.01),
      );
      expect(
        half.cues.singleWhere((c) => c.sound == SoundEffect.unlockGlass).atMs,
        closeTo(333.33 + 350, 0.01),
      );
    });
  });

  group('overlapping batches', () {
    test('Won waits for everything playing, then + 250', () {
      final h = TimelineHarness(twoSetLevel)..start();
      // Red completes and breaks two cases: its batch ends at the second
      // unlock's end.
      final red = h.move('r0c0', 'r0c1');
      final redEnd = framesMs(40 + 42) + 80 + framesMs(54);
      expect(red.endMs, at(redEnd));
      h.run(100);
      // Green completes on other slots while red plays: the win.
      final green = h.move('r0c3', 'r1c0');
      final won = only<BoardWon>(green);
      final greenOwnEnd = framesMs(40 + 75 + 12);
      expect(green.startMs + greenOwnEnd, lessThan(redEnd));
      expect(won.atMs, at(redEnd - 100 + 250));
      // Completions 100 ms apart: combo step 2.
      expect(
        green.cues
            .singleWhere((c) => c.sound == SoundEffect.complete)
            .comboStep,
        2,
      );
    });

    test('a selection starts at once while a completion flies', () {
      final h = TimelineHarness(comboLevel)..start();
      h
        ..move('r0c0', 'r0c1')
        ..run(900);
      final before = h.commands.executed.length;
      h.select('r1c3'); // green2
      final started = h.commands.executed
          .skip(before)
          .map((e) => e.command)
          .whereType<StartClip>()
          .map((c) => c.clip.purpose);
      expect(started, [FxClipPurpose.selection, FxClipPurpose.selectionGlow]);
      expect(h.timeline.acceptsInput('r1c3'), isTrue);
      expect(h.timeline.acceptsInput('r0c1'), isFalse, reason: 'until 1367');
    });

    test('relayout moves the lasting clips at once', () {
      final h = TimelineHarness(tutorial)..start();
      final lift = h.select('r0c0');
      final pick = startOf(lift, FxClipPurpose.selection).clip;
      final wide = geometryOf(
        h.state,
        viewport: const BoardViewport(
          size: Size(430, 932),
          padding: EdgeInsets.only(top: 59, bottom: 34),
        ),
      );
      final before = h.commands.executed.length;
      h.timeline.relayout(wide);
      final places = h.commands.executed
          .skip(before)
          .map((e) => e.command)
          .whereType<PlaceClip>()
          .toList();
      expect(places.map((c) => c.clip.purpose), [
        FxClipPurpose.selection,
        FxClipPurpose.selectionGlow,
      ]);
      expect(places.first.clip, pick);
      expect(places.first.placement.x, wide.slot('r0c0').centerX);
      expect(places.first.placement.scale, wide.scale);
    });
  });
}

int? _clipIdOf(FxCommand command) => switch (command) {
  StartClip(:final clip) ||
  PlayClipSegment(:final clip) ||
  PlaceClip(:final clip) ||
  ReleaseClipSlots(:final clip) ||
  StopClip(:final clip) => clip.id,
  _ => null,
};
