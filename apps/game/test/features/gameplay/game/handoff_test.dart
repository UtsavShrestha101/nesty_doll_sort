// The sprite ↔ Lottie hand-off (docs/plans/m2-lottie-design.md §10.1–§10.2,
// §17 "Flame board"): the rest sprite and a clip draw the same part rasters
// with the same transform, so the frame a clip takes over (doll_pick frame
// 0) and the frame it hands back (doll_nest's last) equal the sprite, within
// 1/255 mean (doll_move's last renderable frame is the exception: its ease
// ends on op, which lottie never draws). And the swap happens in one update:
// never a frame with both, or neither.
import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_core/nesty_core.dart';
import 'package:nesty_game/features/fx/fx_id.dart';
import 'package:nesty_game/features/fx/fx_player.dart';
import 'package:nesty_game/features/gameplay/bloc/board_effect.dart';
import 'package:nesty_game/features/gameplay/game/timeline/timeline.dart';

import 'support/board_fixtures.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<GameHarness> harness() async {
    final h = await GameHarness.mount(
      tutorial,
      fx: await libraryWith(boardFiles),
      skin: TestSkin(blobParts([DollColor.red])),
    );
    await h.start();
    return h;
  }

  test('doll_pick frame 0 equals the rest sprite it replaces', () async {
    final h = await harness();
    final rest = await h.render(pixelRatio: 2);
    expect(h.board.slots['r0c0']!.nest.isDrawn, isTrue);

    await h.select('r0c0');
    // Same update: the clip started on frame 0 and the sprite hid.
    final pick = h.board.fx.componentOf(h.timeline.selectionClip!.id)!;
    expect(pick.id, FxId.dollPick);
    expect(pick.drawable.player.frame, 0);
    expect(h.board.slots['r0c0']!.nest.isDrawn, isFalse);
    final lifted = await h.render(pixelRatio: 2);

    final g = h.game.geometry!.slot('r0c0');
    final diff = meanDifference(
      rest,
      lifted,
      region: dollBox(g, 3, pixelRatio: 2),
    );
    expect(diff.touched, greaterThan(5000), reason: 'the doll is drawn');
    expect(diff.mean, lessThanOrEqualTo(1.0), reason: 'mean ${diff.mean}');
  });

  test('doll_nest\'s last frame equals the merged nest\'s sprite', () async {
    final h = await harness();
    // red2 into red3 (inside): doll_move 0–267, then doll_nest 267–667.
    await h.move('r0c2', 'r0c0');
    await h.run(300);
    final nest = h.commandsOf<StartClip>().last.clip;
    expect(nest.fx, FxId.dollNest);
    final component = h.board.fx.componentOf(nest.id)!;
    await h.run(666.6 - h.timeline.nowMs);
    expect(h.board.fx.componentOf(nest.id), same(component));
    expect(
      component.drawable.player.frame,
      closeTo(FxPlayer.durationFramesOf(component.drawable.spec), 0.02),
    );
    expect(h.board.slots['r0c0']!.nest.isDrawn, isFalse);
    final nesting = await h.render(pixelRatio: 2);

    await h.tick(1);
    expect(h.board.fx.componentOf(nest.id), isNull);
    expect(h.board.slots['r0c0']!.nest.isDrawn, isTrue);
    final merged = await h.render(pixelRatio: 2);

    final g = h.game.geometry!.slot('r0c0');
    final diff = meanDifference(
      nesting,
      merged,
      region: dollBox(g, 3, pixelRatio: 2),
    );
    expect(diff.touched, greaterThan(5000), reason: 'the doll is drawn');
    expect(diff.mean, lessThanOrEqualTo(1.0), reason: 'mean ${diff.mean}');
  });

  test('doll_move lands on the sprite: same column and size; its last '
      'renderable frame is a hair above rest', () async {
    final h = await harness();
    await h.move('r0c2', 'r0c1');
    final move = h.commandsOf<StartClip>().single.clip;
    expect(move.fx, FxId.dollMove);
    final component = h.board.fx.componentOf(move.id)!;
    // A hair before the StopClip (266.67 ms): lottie's last renderable
    // frame (op − 0.01), the target still shows nothing.
    await h.run(266.6);
    expect(h.board.fx.componentOf(move.id), same(component));
    expect(h.board.slots['r0c1']!.nest.isDrawn, isFalse);
    final flying = await h.render(pixelRatio: 2);

    // The next update stops the clip and syncs the target: the sprite.
    await h.tick(1);
    expect(h.board.fx.componentOf(move.id), isNull);
    expect(h.board.slots['r0c1']!.nest.isDrawn, isTrue);
    final landed = await h.render(pixelRatio: 2);

    final g = h.game.geometry!.slot('r0c1');
    final box = dollBox(g, 2, pixelRatio: 2);
    bool inBox(int x, int y) =>
        x >= box.left && x < box.right && y >= box.top && y < box.bottom;
    bool doll(Snapshot s, int x, int y) =>
        inBox(x, y) && y < g.surfaceY * 2 && s.alphaAt(x, y) > 128;
    final a = flying.boundsWhere((x, y) => doll(flying, x, y))!;
    final b = landed.boundsWhere((x, y) => doll(landed, x, y))!;
    // The remap puts it on the target's column exactly.
    expect(a.center.dx, closeTo(b.center.dx, 1));
    // doll_move's `arc`, lift and ×1.05 end on easeIn keyframes at op
    // (frame 16); lottie 3.6.1 renders op − 0.01 at most, where the eases'
    // vertical end tangents still hold the doll ≈ 2% big and ≈ 2 px (at
    // DPR 2) up. The sprite takes over in the next frame, mid-fall (the
    // re-export request asks for a hold at the end; known issue).
    expect(a.height / b.height, inInclusiveRange(1.0, 1.03));
    expect(b.top - a.top, inInclusiveRange(0, 6));
  });

  test('a wobbling doll dropped mid-wobble: doll_move starts at its tilt '
      'and eases it out over 80 ms (m7-5 item 14)', () async {
    final h = await harness();
    await h.select('r0c2');
    // The lift (7 frames) and 6 frames into the wobble: about −3°.
    await h.run(13 * 1000 / 60);
    // The angle is captured as the pick draws (every frame in the game).
    await h.render();
    final pickClip = h.timeline.selectionClip!;
    final pick = h.board.fx.componentOf(pickClip.id)!;
    final tilt = pick.drawable.params.pickRotation;
    expect(tilt, lessThan(-1), reason: 'mid-wobble');
    final result = h.session.move('r0c2', 'r0c1') as MoveApplied;
    h.game.apply(MoveAppliedEffect(result: result), h.state);
    await h.tick();
    final move = h.commandsOf<StartClip>().last.clip;
    expect(move.fx, FxId.dollMove);
    expect(move.params.unwindOf, pickClip.id);
    final flight = h.board.fx.componentOf(move.id)!;
    expect(flight.drawable.params.unwindFrom, tilt);
    // The pick handed over in the same update.
    expect(h.board.fx.componentOf(pickClip.id), isNull);
  });

  test('a doll dropped before it wobbles (still lifting, or dragged) starts '
      'its move upright', () async {
    final h = await harness();
    await h.select('r0c2');
    await h.run(50);
    final result = h.session.move('r0c2', 'r0c1') as MoveApplied;
    h.game.apply(MoveAppliedEffect(result: result), h.state);
    await h.tick();
    final move = h.commandsOf<StartClip>().last.clip;
    expect(h.board.fx.componentOf(move.id)!.drawable.params.unwindFrom, isNull);
  });

  test('a clip and a sprite never both draw one doll, and the doll never '
      'vanishes, through a whole move', () async {
    final h = await harness();
    await h.select('r0c2');
    await h.run(200);
    final result = h.session.move('r0c2', 'r0c0') as MoveApplied;
    h.game.apply(MoveAppliedEffect(result: result), h.state);
    // Every frame of the flight and the nest: each doll a slot shows is
    // drawn exactly once, by its sprite or by a clip that hides it.
    for (var t = 0; t < 50; t++) {
      await h.tick(frameMs);
      final live = h.board.fx.liveClips;
      for (final id in ['r0c0', 'r0c1', 'r0c2', 'r1c0', 'r1c1', 'r1c2']) {
        final drawn = h.board.slots[id]!.nest.isDrawn;
        final byClip = live.any((c) => c.hides.contains(id));
        if (h.board.scene.slot(id)!.view.hasNest) {
          expect(drawn, !byClip, reason: '$id at frame $t');
        } else {
          expect(drawn, isFalse, reason: '$id at frame $t');
        }
      }
    }
    // Settled: one merged nest at r0c0.
    expect(h.board.slots['r0c0']!.nest.isDrawn, isTrue);
    expect(h.board.scene.slot('r0c0')!.view.innerSize, 2);
    expect(h.board.slots['r0c2']!.nest.isDrawn, isFalse);
  });
}
