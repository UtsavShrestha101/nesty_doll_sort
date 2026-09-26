// The board as the timeline's FxCommandSink, driven by hand-built commands
// (a fake timeline; docs/plans/m2-lottie-design.md §7, §8, §10): clips come
// from their file's pool and go back to it, placed as their placement says;
// sprite hides are counted per clip; slots change only at SyncSlot; tweens,
// compositions, the hint arc and the callbacks follow their commands.
import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_core/nesty_core.dart';
import 'package:nesty_game/features/fx/fx_id.dart';
import 'package:nesty_game/features/fx/fx_player.dart';
import 'package:nesty_game/features/fx/fx_spec.gen.dart';
import 'package:nesty_game/features/gameplay/bloc/board_effect.dart';
import 'package:nesty_game/features/gameplay/game/timeline/timeline.dart';
import 'package:nesty_render/nesty_render.dart';

import 'support/board_fixtures.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late GameHarness h;
  late BoardGeometry g;
  var nextId = 100000;

  setUp(() async {
    h = await GameHarness.mount(mainLevel, fx: await libraryWith(boardFiles));
    await h.start();
    g = h.game.geometry!;
  });

  FxClip clip(
    FxId fx, {
    String? slotId = 'r0c0',
    List<String> hides = const [],
    FxPlacement? placement,
    FxClipParams params = FxClipParams.none,
    FxClipPurpose purpose = FxClipPurpose.selection,
  }) {
    final slot = g.slot(slotId ?? 'r0c0');
    return FxClip(
      id: nextId++,
      fx: fx,
      purpose: purpose,
      placement: placement ?? FxPlacement.anchored(FxAnchor.dollBase, g, slot),
      params: params,
      slotId: slotId,
      anchor: FxAnchor.dollBase,
      hides: hides,
    );
  }

  FxSegment whole(FxId fx) => FxSegment.whole(fxSpecOf(fx));

  void run(FxCommand command, [double lateMs = 0]) =>
      h.board.execute(command, lateMs);

  test('StartClip takes a pooled component, places it and plays the '
      'segment late; StopClip returns it', () {
    final pool = h.board.fx.poolOf(FxId.dollPick)!;
    final pick = clip(FxId.dollPick, hides: const ['r0c0']);
    final slot = g.slot('r0c0');
    run(StartClip(0, pick, whole(FxId.dollPick)), 50);
    final component = h.board.fx.componentOf(pick.id)!;
    expect(pool.inUse, 1);
    expect(component.active, isTrue);
    expect(component.position.x, closeTo(slot.centerX, 1e-3));
    expect(component.position.y, closeTo(slot.surfaceY, 1e-3));
    expect(component.scale.x, closeTo(g.scale, 1e-6));
    // 50 ms late: three frames in.
    expect(component.drawable.player.frame, closeTo(3, 1e-9));
    expect(h.board.slots['r0c0']!.nest.isDrawn, isFalse);

    run(StopClip(0, pick));
    expect(h.board.fx.componentOf(pick.id), isNull);
    expect(pool.inUse, 0);
    expect(component.active, isFalse);
    expect(h.board.slots['r0c0']!.nest.isDrawn, isTrue);
  });

  test('hides are counted: a sprite shows only when every clip drawing it '
      'let go', () {
    final a = clip(FxId.dollPick, hides: const ['r0c0']);
    final b = clip(FxId.dollReveal, hides: const ['r0c0']);
    run(StartClip(0, a, whole(FxId.dollPick)));
    run(StartClip(0, b, whole(FxId.dollReveal)));
    final state = h.board.scene.slot('r0c0')!;
    expect(state.hideCount, 2);
    run(ReleaseClipSlots(0, a));
    expect(state.spriteHidden, isTrue);
    expect(h.board.fx.componentOf(a.id), isNotNull, reason: 'still plays');
    // A stop after a release doesn't show twice.
    run(StopClip(0, a));
    expect(state.hideCount, 1);
    run(StopClip(0, b));
    expect(state.hideCount, 0);
    expect(h.board.slots['r0c0']!.nest.isDrawn, isTrue);
  });

  test('PlayClipSegment switches the live clip; a hold rests on its frame; '
      'PlaceClip moves it', () {
    final pick = clip(FxId.dollPick);
    run(StartClip(0, pick, whole(FxId.dollPick)));
    final component = h.board.fx.componentOf(pick.id)!;
    run(PlayClipSegment(0, pick, const FxSegment.hold(7)));
    expect(component.drawable.player.state, FxPlayState.resting);
    expect(component.drawable.player.frame, 7);
    run(PlayClipSegment(0, pick, const FxSegment(7, 31, loop: true)));
    expect(component.drawable.player.isPlaying, isTrue);
    final other = g.slot('r2c2');
    run(
      PlaceClip(
        0,
        pick,
        FxPlacement.anchored(FxAnchor.dollBase, g, other),
        FxClipParams.none,
      ),
    );
    expect(component.position.x, closeTo(other.centerX, 1e-3));
    expect(component.position.y, closeTo(other.surfaceY, 1e-3));
  });

  test('board-space clips lay the reference screen over the board (§5)', () {
    final move = clip(
      FxId.dollMove,
      placement: FxPlacement.boardSpace(g.fit),
      params: FxClipParams(
        doll: DollColor.red,
        travelFrom: g.fit.toReference(100, 500),
        travelTo: g.fit.toReference(300, 500),
      ),
      purpose: FxClipPurpose.move,
    );
    run(StartClip(0, move, whole(FxId.dollMove)));
    final component = h.board.fx.componentOf(move.id)!;
    expect(component.position.x, closeTo(g.fit.boardSpaceOrigin.dx, 1e-3));
    expect(component.position.y, closeTo(g.fit.boardSpaceOrigin.dy, 1e-3));
    expect(component.scale.x, closeTo(g.fit.scale, 1e-6));
    expect(component.anchor.x, 0);
    expect(component.anchor.y, 0);
    final params = component.drawable.params;
    expect(params.travelSrc, g.fit.toReference(100, 500));
    expect(params.travelDst, g.fit.toReference(300, 500));
    expect(component.drawable.images.request.doll, DollColor.red);
  });

  test('an exhausted pool, or a clip already live, is skipped (§14)', () {
    final pool = h.board.fx.poolOf(FxId.uiHintArrow)!;
    expect(pool.capacity, 1);
    final first = clip(FxId.uiHintArrow, hides: const ['r0c1']);
    final second = clip(FxId.uiHintArrow, hides: const ['r0c2']);
    run(StartClip(0, first, whole(FxId.uiHintArrow)));
    run(StartClip(0, second, whole(FxId.uiHintArrow)));
    run(StartClip(0, first, whole(FxId.uiHintArrow)));
    expect(h.board.fx.componentOf(second.id), isNull);
    expect(h.board.scene.slot('r0c2')!.spriteHidden, isFalse);
    expect(h.board.scene.slot('r0c1')!.hideCount, 1);
  });

  test('a slot changes only at SyncSlot', () {
    final state = h.board.scene.slot('r1c2')!;
    expect(state.view.hasNest, isFalse);
    final after = h.session.move('r0c3', 'r1c2');
    expect(after, isA<MoveApplied>());
    expect(state.view.hasNest, isFalse, reason: 'no sync yet');
    run(SyncSlot(0, 'r1c2', h.state));
    expect(state.view.color, DollColor.purple);
    expect(state.view.outerSize, 3);
    expect(h.board.slots['r1c2']!.nest.isDrawn, isTrue);
  });

  test('tweens: a shake moves the whole slot, a reveal hides its top, '
      'EndTween undoes both', () {
    final shake = ShakeTween(
      slotId: 'r1c3',
      amplitudeScale: g.scale,
      durationMs: 240,
    )..begin(0);
    run(StartTween(0, shake));
    shake.update(20);
    h.board.slots['r1c3']!.update(0);
    expect(h.board.slots['r1c3']!.position.x, isNot(0));
    run(EndTween(0, shake));
    h.board.slots['r1c3']!.update(0);
    expect(h.board.slots['r1c3']!.position.x, 0);

    final reveal = RevealDropTween(
      slot: g.slot('r1c0'),
      revealedSize: 1,
      revealedColor: DollColor.green,
      buried: 1,
      durationMs: 120,
    );
    run(StartTween(0, reveal));
    final tower = h.board.scene.slot('r1c0')!;
    expect(tower.reveal, same(reveal));
    expect(tower.spriteHidden, isTrue);
    run(EndTween(0, reveal));
    expect(tower.reveal, isNull);
    expect(tower.spriteHidden, isFalse);
  });

  test('the slot compositions play, rest and release by command (§8)', () {
    final locked = h.board.slots['r1c3']!;
    final glass = locked.glass!;
    run(PlaySlotFx(0, 'r1c3', FxId.fxGlassUnlock, whole(FxId.fxGlassUnlock)));
    expect(glass.drawable.player.isPlaying, isTrue);
    expect(locked.nest.isDrawn, isFalse, reason: 'the composition draws it');
    run(const ReleaseSlotFx(0, 'r1c3', FxId.fxGlassUnlock));
    expect(locked.glass, isNull);
    expect(glass.active, isFalse);
    expect(locked.nest.isDrawn, isTrue);

    final iced = h.board.slots['r2c1']!;
    final ice = iced.ice!;
    run(
      PlaySlotFx(
        0,
        'r2c1',
        FxId.fxIce,
        FxSegment.marker(fxSpecOf(FxId.fxIce), 'crack_1'),
        shake: false,
      ),
    );
    expect(ice.drawable.player.isPlaying, isTrue);
    expect(ice.drawable.params.reducedMotion, isTrue);
    run(const PlaySlotFx(0, 'r2c1', FxId.fxIce, FxSegment.hold(16)));
    expect(ice.drawable.player.state, FxPlayState.resting);
    expect(ice.drawable.player.frame, 16);
  });

  test('the hint arc and the callbacks', () {
    run(const SetHintArc(0, Move('r0c3', 'r2c0')));
    expect(h.board.hint.move, const Move('r0c3', 'r2c0'));
    expect(h.board.scene.hint, const Move('r0c3', 'r2c0'));
    run(const SetHintArc(0, null));
    expect(h.board.hint.dashes, isNull);

    run(const FamilyLanded(0, setsCompleted: 2, totalSets: 5));
    run(const BoardWon(0, moveCount: 7));
    run(const BoardOutOfMoves(0));
    expect(h.landed, [(2, 5)]);
    expect(h.won, [7]);
    expect(h.outOfMoves, 1);
  });

  test('ResetBoard returns every clip and clears every hide and tween', () {
    final pick = clip(FxId.dollPick, hides: const ['r0c0']);
    run(StartClip(0, pick, whole(FxId.dollPick)));
    run(
      StartTween(
        0,
        ShakeTween(slotId: 'r1c3', amplitudeScale: 1, durationMs: 240),
      ),
    );
    run(ResetBoard(0, h.state, BoardResetReason.restart));
    expect(h.board.fx.liveClips, isEmpty);
    expect(h.board.fx.poolOf(FxId.dollPick)!.inUse, 0);
    expect(h.board.scene.slot('r0c0')!.spriteHidden, isFalse);
    expect(h.board.scene.slot('r1c3')!.shake, isNull);
    expect(h.board.slots['r1c3']!.glass, isNotNull);
  });
}
