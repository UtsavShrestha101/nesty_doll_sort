// The pause dialog (frame 3.9; docs/plans/m2-lottie-design.md §7 "Global
// lock"): pausing the engine stops the board's time and drops its input;
// effects applied meanwhile wait; resuming picks up where it stopped.
import 'package:flame/game.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_core/nesty_core.dart';
import 'package:nesty_game/features/fx/fx_id.dart';
import 'package:nesty_game/features/gameplay/bloc/board_effect.dart';
import 'package:nesty_game/features/gameplay/game/nesty_game.dart';
import 'package:nesty_game/features/gameplay/game/timeline/timeline.dart';
import 'package:nesty_render/nesty_render.dart';

import 'support/board_fixtures.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'pauseEngine: time stands still, clips hold, input is dropped',
    () async {
      final h = await GameHarness.mount(
        tutorial,
        fx: await libraryWith(boardFiles),
      );
      await h.start();
      await h.move('r0c2', 'r0c1');
      await h.run(100);
      final move = h.board.fx.componentOf(
        h.commandsOf<StartClip>().single.clip.id,
      )!;
      final frame = move.drawable.player.frame;
      final now = h.timeline.nowMs;

      h.game.pauseEngine();
      expect(h.game.paused, isTrue);
      expect(h.board.paused, isTrue);
      expect(h.timeline.paused, isTrue);
      expect(h.timeline.inputLocked, isTrue);
      await h.tick(1000);
      expect(h.timeline.nowMs, now);
      expect(move.drawable.player.frame, frame);
      final r1c1 = h.game.geometry!.slot('r1c1');
      expect(h.board.handleTap(r1c1.centerX, r1c1.surfaceY - 10), isNull);
      expect(h.board.beginDrag(1, r1c1.centerX, r1c1.surfaceY - 10), isFalse);

      // An effect applied while paused waits for the resume.
      h.game.apply(const HintShownEffect(Move('r1c1', 'r0c0')), h.state);
      await h.tick(16);
      expect(h.board.hint.move, isNull);

      h.game.resumeEngine();
      expect(h.board.paused, isFalse);
      await h.tick(16);
      expect(h.timeline.nowMs, closeTo(now + 16, 1e-9));
      expect(move.drawable.player.frame, greaterThan(frame));
      expect(h.board.hint.move, const Move('r1c1', 'r0c0'));
      expect(h.board.handleTap(r1c1.centerX, r1c1.surfaceY - 10), 'r1c1');
    },
  );

  test('the paused setter does the same', () async {
    final h = await GameHarness.mount(tutorial);
    await h.start();
    h.game.paused = true;
    expect(h.board.paused, isTrue);
    expect(h.timeline.paused, isTrue);
    h.game.paused = false;
    expect(h.board.paused, isFalse);
    expect(h.timeline.paused, isFalse);
  });

  test('reduced motion reaches the timeline and new batches', () async {
    final h = await GameHarness.mount(
      tutorial,
      fx: await libraryWith(boardFiles),
    );
    await h.start();
    h.game.reduceMotion = true;
    expect(h.timeline.motion, MotionSpec.reduced);
    await h.select('r0c0');
    // doll_pick holds lift's end instead of wobbling (D48).
    await h.run(200);
    final pick = h.board.fx.componentOf(h.timeline.selectionClip!.id)!;
    expect(pick.id, FxId.dollPick);
    expect(pick.drawable.player.isResting, isTrue);
  });

  testWidgets('in a GameWidget, a paused engine stops the loop', (
    tester,
  ) async {
    tester.view
      ..physicalSize = const Size(390, 844)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final library = await tester.runAsync(() => libraryWith(boardFiles));
    final game = NestyGame(
      fx: library,
      padding: BoardViewport.reference.padding,
    );
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: GameWidget<NestyGame>(game: game),
      ),
    );
    await tester.pump();
    final state = GameState.initial(tutorial);
    game.apply(
      BoardResetEffect(snapshot: state, reason: BoardResetReason.start),
      state,
    );
    await tester.pump(const Duration(milliseconds: 16));
    await tester.pump(const Duration(milliseconds: 16));
    final timeline = game.board.timeline!;
    final before = timeline.nowMs;
    await tester.pump(const Duration(milliseconds: 100));
    expect(timeline.nowMs, greaterThan(before));
    game.pauseEngine();
    final paused = timeline.nowMs;
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(milliseconds: 100));
    expect(timeline.nowMs, paused);
    game.resumeEngine();
    await tester.pump(const Duration(milliseconds: 16));
    await tester.pump(const Duration(milliseconds: 16));
    expect(timeline.nowMs, greaterThan(paused));
  });
}
