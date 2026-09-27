// Effects on the board (docs/plans/m2-lottie-design.md §7–§10): apply()
// schedules each effect in order on the next tick, the board executes the
// timeline's commands (clips, syncs, tweens, compositions, callbacks), and
// a file that failed to load changes nothing but the drawing (rule 3).
import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_core/nesty_core.dart';
import 'package:nesty_game/core/services/audio/audio_service.dart';
import 'package:nesty_game/features/fx/fx_id.dart';
import 'package:nesty_game/features/fx/fx_player.dart';
import 'package:nesty_game/features/fx/fx_spec.gen.dart';
import 'package:nesty_game/features/gameplay/bloc/board_effect.dart';
import 'package:nesty_game/features/gameplay/game/components/slot_component.dart';
import 'package:nesty_game/features/gameplay/game/timeline/timeline.dart';
import 'package:nesty_render/nesty_render.dart';

import 'support/board_fixtures.dart';
import 'timeline/support/timeline_fixtures.dart' as tl;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<GameHarness> loaded(Level level, {bool reduceMotion = false}) async {
    final h = await GameHarness.mount(
      level,
      fx: await libraryWith(boardFiles),
      reduceMotion: reduceMotion,
    );
    await h.start();
    return h;
  }

  test(
    'apply() queues; the next tick schedules every effect in order',
    () async {
      final h = await loaded(tutorial);
      final before = h.executed.length;
      h.game
        ..apply(const SelectionChangedEffect(selected: 'r0c2'), h.state)
        ..apply(const SelectionChangedEffect(previous: 'r0c2'), h.state);
      expect(h.executed, hasLength(before), reason: 'nothing until the tick');
      await h.tick();
      final started = h.commandsOf<StartClip>().map((c) => c.clip.fx).toList();
      expect(started, [FxId.dollPick, FxId.fxSelectGlow]);
      // The deselect was planned after the lift: the pick settles.
      final segments = h.commandsOf<PlayClipSegment>().toList();
      expect(segments, isNotEmpty);
      expect(h.timeline.selectedSlotId, isNull);
    },
  );

  group('a completing move, every file loaded', () {
    late GameHarness h;

    setUp(() async {
      h = await loaded(tutorial);
      await h.move('r1c1', 'r0c2');
      await h.run(700);
      h.executed.clear();
      h.cues.clear();
    });

    test('nest, complete, dust, sparkles, the counter, then won', () async {
      final idles = h.idles;
      final start = h.timeline.nowMs;
      Future<void> at(double ms) => h.run(start + ms - h.timeline.nowMs);
      await h.move('r0c2', 'r0c0');
      // The nest hides the target from the landing; complete from t0.
      await at(300);
      expect(h.board.slots['r0c0']!.nest.isDrawn, isFalse);
      await at(1366.7 + 1);
      final live = h.board.fx.liveClips.map((c) => c.fx).toSet();
      expect(live, containsAll([FxId.dollComplete, FxId.fxDustPuff]));
      expect(live, contains(FxId.fxSparkle));
      // The set took off: the slot is empty now and shows nothing.
      expect(h.board.scene.slot('r0c0')!.view.hasNest, isFalse);
      expect(h.landed, isEmpty);
      await at(1916.7 - 2);
      expect(h.landed, isEmpty);
      await at(1916.7 + 1);
      expect(h.landed, [(1, 1)]);
      expect(h.won, isEmpty);
      await at(2366.7 + 1);
      expect(h.won, [2]);
      expect(h.idles, greaterThan(idles));
      expect(h.board.fx.liveClips, isEmpty);
      final sounds = h.cues.map((c) => c.sound).toList();
      expect(
        sounds,
        containsAllInOrder([
          SoundEffect.whoosh,
          SoundEffect.clack,
          SoundEffect.complete,
        ]),
      );
    });

    test('sparkles sit on the completing set\'s trail', () async {
      final start = h.timeline.nowMs;
      await h.move('r0c2', 'r0c0');
      await h.run(start + 1366.7 + 5 - h.timeline.nowMs);
      final complete = h.commandsOf<StartClip>().singleWhere(
        (c) => c.clip.fx == FxId.dollComplete,
      );
      final sparkle = h.board.fx.poolOf(FxId.fxSparkle)!;
      final active = [
        for (var i = 0; i < sparkle.capacity; i++)
          if (sparkle[i].active) sparkle[i],
      ];
      expect(active, isNotEmpty);
      // No render yet: the trail point falls back to the travel's source,
      // the completed set's base.
      final src = complete.clip.params.travelFrom!;
      final fit = h.game.geometry!.fit;
      expect(active.first.position.x, closeTo(fit.x(src.dx), 1e-3));
      expect(active.first.position.y, closeTo(fit.y(src.dy), 1e-3));
    });
  });

  test('without any file (rule 3): no clip, same syncs, cues and '
      'callbacks, sprites never hidden', () async {
    final h = await GameHarness.mount(
      tutorial,
      fx: await libraryWith(const []),
    );
    await h.start();
    await h.move('r1c1', 'r0c2');
    for (var t = 0; t < 45; t++) {
      await h.tick(frameMs);
      for (final slot in h.board.scene.slots) {
        expect(slot.spriteHidden, isFalse);
      }
    }
    expect(h.commandsOf<StartClip>(), isEmpty);
    expect(h.board.scene.slot('r0c2')!.view.outerSize, 2);
    expect(h.board.scene.slot('r0c2')!.view.innerSize, 1);
    await h.move('r0c2', 'r0c0');
    await h.run(2500);
    expect(h.landed, [(1, 1)]);
    expect(h.won, [2]);
    expect(
      h.cues.map((c) => c.sound),
      containsAll([SoundEffect.clack, SoundEffect.complete]),
    );
  });

  test('out of moves: the board reports it when the batch is done', () async {
    final h = await loaded(tl.outOfMoves);
    await h.move('r0c0', 'r0c3');
    expect(h.outOfMoves, 0);
    await h.run(h.timeline.busyUntilMs - h.timeline.nowMs - 5);
    expect(h.outOfMoves, 0);
    await h.run(10);
    expect(h.outOfMoves, 1);
  });

  group('locked and iced slots (§8)', () {
    test('a completion unlocks the case and cracks the ice', () async {
      final h = await loaded(tl.comboLevel);
      final locked = h.board.slots['r0c2']!;
      final iced = h.board.slots['r0c3']!;
      expect(locked.glass, isNotNull);
      expect(iced.ice!.drawable.player.frame, 0);
      expect(iced.slot.decor.badgeLabel, '3');

      await h.move('r0c0', 'r0c1');
      // Unlock from t0 + 700 (1366.7), ice 80 ms later.
      await h.run(1370);
      expect(
        h.commandsOf<StartClip>().map((c) => c.clip.fx),
        contains(FxId.dollComplete),
      );
      expect(locked.glass!.drawable.player.isPlaying, isTrue);
      expect(locked.slot.view.locked, isFalse, reason: 'synced at the start');
      expect(locked.nest.isDrawn, isFalse, reason: 'the composition draws it');
      await h.run(90);
      expect(iced.ice!.drawable.player.isPlaying, isTrue);
      expect(iced.slot.decor.badgeLabel, '2');
      await h.run(1000);
      // The case is gone: the sprite stands on the stand.
      expect(locked.glass, isNull);
      expect(locked.nest.isDrawn, isTrue);
      expect(locked.slot.restBaseY(null), locked.slot.geometry.surfaceY);
      // The ice rests on stage 1 (frame 16) from a recorded picture.
      final ice = iced.ice!;
      expect(ice.drawable.player.state, FxPlayState.resting);
      expect(ice.drawable.player.frame, 16);
      await h.render();
      await h.render();
      expect(ice.restRecordings, 1);
    });

    test('a hit that cracks nothing new plays crack_hit_n on the paused '
        'ice, then rests on rest_n (LOTTIE.md v3)', () async {
      // comboLevel with ice 4 on r0c3: 4 → 3 stays on stage 0.
      final level = levelFrom('''
{
  "schemaVersion": 1,
  "id": "T1003",
  "maxSize": 3,
  "shelves": [
    [ {"type": "open", "nest": ["red3"]},
      {"type": "open", "nest": ["red2", "red1"]},
      {"type": "open", "nest": null},
      {"type": "open", "nest": ["blue2"], "ice": 4} ],
    [ {"type": "open", "nest": ["blue1"]},
      {"type": "open", "nest": ["blue3"]},
      {"type": "open", "nest": ["green2", "green1"]},
      {"type": "open", "nest": ["green3"]} ]
  ]
}
''');
      final h = await loaded(level);
      final iced = h.board.slots['r0c3']!;
      final ice = iced.ice!;
      expect(ice.drawable.player.frame, 0);
      expect(iced.slot.decor.badgeLabel, '4');

      await h.move('r0c0', 'r0c1');
      // The hit starts at t0 + 700 (1366.7).
      await h.run(1380);
      expect(iced.slot.decor.badgeLabel, '3');
      expect(ice.drawable.player.isPlaying, isTrue);
      final hit = fxSpecOf(FxId.fxIce).marker('crack_hit_0')!;
      expect(ice.drawable.player.frame, inInclusiveRange(hit.start, hit.end));
      await h.run(400);
      expect(ice.drawable.player.state, FxPlayState.resting);
      expect(ice.drawable.player.frame, 0, reason: 'rest_0: still stage 0');
    });

    test('an invalid move on a locked target shakes the whole slot by '
        'hand (§9.3)', () async {
      final h = await loaded(mainLevel);
      final locked = h.board.slots['r1c3']!;
      final rejected = Rules.tryMove(h.state, const Move('r0c2', 'r1c3'));
      expect(rejected, isA<MoveRejected>());
      await h.apply(
        MoveRejectedEffect(
          source: 'r0c2',
          target: 'r1c3',
          reason: (rejected as MoveRejected).reason,
        ),
      );
      final xs = <double>[];
      for (var t = 0; t < 36; t++) {
        await h.tick(frameMs);
        xs.add(locked.position.x);
      }
      expect(xs.reduce((a, b) => a < b ? a : b), lessThan(-3));
      expect(xs.reduce((a, b) => a > b ? a : b), greaterThan(3));
      expect(locked.position.x, 0);
      // The file's own target is hidden: the case draws the doll.
      final invalid = h.commandsOf<StartClip>().singleWhere(
        (c) => c.clip.fx == FxId.dollInvalid,
      );
      expect(invalid.clip.params.hideTarget, isTrue);
    });

    test('reduced motion: no hand-coded shake', () async {
      final h = await loaded(mainLevel, reduceMotion: true);
      final locked = h.board.slots['r1c3']!;
      final rejected =
          Rules.tryMove(h.state, const Move('r0c2', 'r1c3')) as MoveRejected;
      await h.apply(
        MoveRejectedEffect(
          source: 'r0c2',
          target: 'r1c3',
          reason: rejected.reason,
        ),
      );
      for (var t = 0; t < 20; t++) {
        await h.tick(frameMs);
        expect(locked.position.x, 0);
      }
    });

    test(
      'a failed glass file draws the static case and swaps its frames',
      () async {
        final files = [...boardFiles]..remove(FxId.fxGlassUnlock);
        final h = await GameHarness.mount(
          tl.comboLevel,
          fx: await libraryWith(files),
        );
        await h.start();
        final locked = h.board.slots['r0c2']!;
        expect(locked.glass, isNull);
        expect(locked.drawsGlassFallback, isTrue);
        expect(locked.nest.isDrawn, isTrue);
        await h.move('r0c0', 'r0c1');
        await h.run(2600);
        expect(locked.drawsGlassFallback, isFalse);
        expect(locked.nest.isDrawn, isTrue);
      },
    );
  });

  test(
    'a tower reveal drops the new top and counts the tag down (§9.1)',
    () async {
      final h = await loaded(tl.towerLevel);
      final tower = h.board.scene.slot('r0c0')!;
      expect(tower.decor.tagLabel, '+2');
      await h.move('r0c0', 'r0c2');
      // Synced at 0: one buried nest left, the new top dropping.
      expect(tower.decor.tagLabel, '+1');
      expect(tower.reveal, isNotNull);
      expect(tower.spriteHidden, isTrue);
      await h.run(60);
      expect(tower.reveal!.progress, inExclusiveRange(0, 1));
      await h.run(80);
      expect(tower.reveal, isNull);
      // doll_reveal draws the colour wipe until it ends.
      expect(tower.spriteHidden, isTrue);
      await h.run(420);
      expect(tower.spriteHidden, isFalse);
      expect(h.board.slots['r0c0']!.nest.isDrawn, isTrue);
    },
  );

  test('the hint: arrow over the source, the arc, the target glow; '
      'cleared by the next effect', () async {
    final h = await loaded(tutorial);
    await h.apply(const HintShownEffect(Move('r1c1', 'r0c2')));
    expect(h.board.hint.move, const Move('r1c1', 'r0c2'));
    expect(h.board.hint.dashes, isNotNull);
    expect(h.board.hint.builds, 1);
    final fx = h.board.fx.liveClips.map((c) => c.fx).toList();
    expect(fx, containsAll([FxId.uiHintArrow, FxId.fxSelectGlow]));
    await h.apply(const HintClearedEffect());
    expect(h.board.hint.dashes, isNull);
    await h.run(200);
    expect(h.board.fx.liveClips, isEmpty);
  });

  test('+1 Slot: the bottom row re-pitches over 300 ms, the new stand '
      'pulses, the layout is reported', () async {
    final h = await loaded(tl.tutorial);
    final before = h.game.geometry!;
    final right = h.board.scene.slot('r1c2')!;
    final fromX = before.slot('r1c2').centerX;
    final added = h.session.addExtraSlot()!;
    await h.apply(ExtraSlotAddedEffect(added));
    final after = h.layouts.last;
    expect(after.slotOrNull('x0'), isNotNull);
    expect(h.board.scene.slot('x0'), isNotNull);
    await h.run(150);
    final mid = right.centerX(h.board.scene.repitch);
    final toX = after.slot('r1c2').centerX;
    expect(
      mid,
      inExclusiveRange(toX < fromX ? toX : fromX, toX < fromX ? fromX : toX),
    );
    await h.run(200);
    expect(h.board.scene.repitch, isNull);
    expect(h.game.geometry, same(after));
    expect(right.geometry, same(after.slot('r1c2')));
    expect(h.board.scene.slot('x0')!.pulses, 1);
    expect(h.board.fx.liveClips.map((c) => c.fx), contains(FxId.uiExtraSlot));
    expect(h.board.slots.keys.last, 'x0');
  });

  test('+1 Slot twice within the re-pitch: the bottom row never jumps, and '
      'ends on the two-extra layout (review CORRECTNESS-4)', () async {
    final h = await loaded(tl.tutorial);
    final left = h.board.scene.slot('r1c0')!;
    await h.apply(ExtraSlotAddedEffect(h.session.addExtraSlot()!));
    await h.run(120);
    double x() => left.centerX(h.board.scene.repitch);
    final before = x();
    await h.apply(ExtraSlotAddedEffect(h.session.addExtraSlot()!));
    expect(x(), closeTo(before, 1e-9), reason: 'no snap on the second press');
    // Frame by frame through both re-pitches: never more than one frame's
    // worth of the ease (the probe saw a 29 px step here).
    var last = x();
    var largest = 0.0;
    for (var i = 0; i < 40; i++) {
      await h.run(frameMs);
      final now = x();
      final step = (now - last).abs();
      if (step > largest) largest = step;
      last = now;
    }
    expect(largest, lessThan(6));
    final after = h.layouts.last;
    expect(after.slotOrNull('x1'), isNotNull);
    expect(h.board.scene.repitch, isNull);
    expect(h.game.geometry, same(after));
    expect(left.geometry, same(after.slot('r1c0')));
    expect(h.board.scene.slot('x1'), isNotNull);
    expect(h.board.slots.keys.toList().sublist(6), ['x0', 'x1']);
  });

  test('a reset mid-batch returns every clip and clears every hide', () async {
    final h = await loaded(tutorial);
    await h.select('r0c2');
    await h.move('r0c2', 'r0c1');
    await h.run(100);
    expect(h.board.fx.liveClips, isNotEmpty);
    h.session.restart();
    await h.apply(
      BoardResetEffect(snapshot: h.state, reason: BoardResetReason.restart),
    );
    expect(h.board.fx.liveClips, isEmpty);
    for (final slot in h.board.scene.slots) {
      expect(slot.spriteHidden, isFalse, reason: slot.id);
    }
    expect(h.board.scene.slot('r0c2')!.view.color, DollColor.red);
    expect(h.board.scene.slot('r0c1')!.view.hasNest, isFalse);
  });

  test('after every batch the slots match core (reconcile)', () async {
    final h = await loaded(tutorial);
    // A board the timeline never synced: the page applies a state whose
    // move it didn't send (not a real flow, but the board must converge).
    h.session.move('r0c2', 'r0c1');
    await h.apply(const HintClearedEffect());
    await h.run(50);
    expect(h.board.scene.slot('r0c1')!.view.outerSize, 2);
    expect(h.board.scene.slot('r0c2')!.view.hasNest, isFalse);
  });

  test('slot components sit on the layout the scene commits', () async {
    final h = await loaded(mainLevel);
    for (final component in h.board.children.whereType<SlotComponent>()) {
      final g = h.game.geometry!.slot(component.slotId);
      expect(component.slot.geometry, same(g));
      expect(component.priority, 100 + g.index);
    }
    expect(h.game.geometry!.shape, isA<BoardShape>());
  });
}
