// Board input (spec §2.2, §10.3; docs/plans/m2-lottie-design.md §7, §9.4,
// §11): taps and drags become the bloc's intents, hit-tested on the whole
// slot column (≥ 48 dp, nearest centre where they overlap); reserved slots,
// the pause and overlays drop input; the dragged doll follows the finger,
// clamped to the board frame, and the next byDrag effect flies from there.
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_core/nesty_core.dart';
import 'package:nesty_game/features/fx/fx_id.dart';
import 'package:nesty_game/features/gameplay/bloc/board_effect.dart';
import 'package:nesty_game/features/gameplay/bloc/gameplay_bloc.dart';
import 'package:nesty_game/features/gameplay/game/nesty_game.dart';
import 'package:nesty_game/features/gameplay/game/timeline/timeline.dart';
import 'package:nesty_render/nesty_render.dart';

import 'support/board_fixtures.dart';

String? _tapped(GameplayEvent e) => e is SlotTapped ? e.slotId : null;

/// Four slots on the bottom shelf, so two extras make a 6-slot row.
final Level _wideLevel = levelFrom('''
{
  "schemaVersion": 1,
  "id": "T7000",
  "maxSize": 3,
  "shelves": [
    [ {"type": "open", "nest": ["red3"]},
      {"type": "open", "nest": ["red2", "red1"]},
      {"type": "open", "nest": null} ],
    [ {"type": "open", "nest": ["blue3"]},
      {"type": "open", "nest": ["blue2"]},
      {"type": "open", "nest": ["blue1"]},
      {"type": "open", "nest": null} ]
  ]
}
''');

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('hit testing: the whole column, at least 48 dp', () {
    test('every slot of the MAIN board takes the taps of its column', () async {
      final h = await GameHarness.mount(mainLevel);
      await h.start();
      final g = h.game.geometry!;
      for (final slot in g.slots) {
        final half = (slot.pitch > 48 ? slot.pitch : 48) / 2;
        final band = g.shelves[slot.row];
        for (final x in [
          slot.centerX,
          slot.centerX - half + 1,
          slot.centerX + half - 1,
        ]) {
          for (final y in [
            band.hitTop + 1,
            band.hitCenterY,
            band.hitBottom - 1,
          ]) {
            expect(
              h.board.slotIdAt(x, y),
              slot.id,
              reason: '${slot.id} @$x,$y',
            );
          }
        }
      }
      // A tall doll's head still belongs to its own shelf (the band starts
      // at the previous plank's bottom).
      final r1c1 = g.slot('r1c1');
      expect(
        h.board.slotIdAt(r1c1.centerX, r1c1.dollTopY(g.shape.maxSize) + 2),
        'r1c1',
      );
    });

    test('outside every column: nothing', () async {
      final h = await GameHarness.mount(mainLevel);
      await h.start();
      final g = h.game.geometry!;
      final bottom = g.shelves.last;
      final r2c0 = g.slot('r2c0');
      // Left of the 3-slot bottom row, below the last plank, above the
      // frame.
      expect(h.board.slotIdAt(r2c0.centerX - 60, bottom.hitCenterY), isNull);
      expect(h.board.slotIdAt(195, bottom.hitBottom + 5), isNull);
      expect(h.board.slotIdAt(195, g.fit.frame.top - 5), isNull);
      expect(h.board.handleTap(195, bottom.hitBottom + 5), isNull);
      expect(h.intents, isEmpty);
    });

    test('a 6-slot row on a small phone: 47.9 dp columns widen to 48 and '
        'the nearest centre wins where they overlap', () async {
      const viewport = BoardViewport(
        size: Size(360, 640),
        padding: EdgeInsets.only(top: 24),
      );
      final h = await GameHarness.mount(_wideLevel, viewport: viewport);
      await h.start();
      for (var i = 0; i < 2; i++) {
        final added = h.session.addExtraSlot()!;
        await h.apply(ExtraSlotAddedEffect(added));
        await h.run(320);
      }
      final g = h.game.geometry!;
      final row = g.shelves.last.slots;
      expect(row, hasLength(6));
      expect(row.first.pitch, lessThan(48));
      final y = g.shelves.last.hitCenterY;
      for (final slot in row) {
        expect(slot.hitRect.width, closeTo(48, 1e-9), reason: slot.id);
        expect(h.board.slotIdAt(slot.centerX, y), slot.id);
      }
      for (var i = 0; i + 1 < row.length; i++) {
        final mid = (row[i].centerX + row[i + 1].centerX) / 2;
        expect(h.board.slotIdAt(mid - 0.01, y), row[i].id);
        expect(h.board.slotIdAt(mid + 0.01, y), row[i + 1].id);
      }
      expect(row.last.id, 'x1');
    });
  });

  group('taps', () {
    test('a tap on a column is SlotTapped', () async {
      final h = await GameHarness.mount(tutorial);
      await h.start();
      final s = h.game.geometry!.slot('r0c2');
      expect(h.board.handleTap(s.centerX, s.surfaceY - 30), 'r0c2');
      expect(h.intents.map(_tapped), ['r0c2']);
    });

    test('dropped on a slot the timeline reserved, until it is free', () async {
      final h = await GameHarness.mount(
        tutorial,
        fx: await libraryWith(boardFiles),
      );
      await h.start();
      await h.move('r0c2', 'r0c1');
      final src = h.game.geometry!.slot('r0c2');
      final other = h.game.geometry!.slot('r1c1');
      expect(h.board.handleTap(src.centerX, src.surfaceY - 10), isNull);
      expect(h.board.handleTap(other.centerX, other.surfaceY - 10), 'r1c1');
      await h.run(280);
      expect(h.board.handleTap(src.centerX, src.surfaceY - 10), 'r0c2');
    });

    test(
      'dropped while paused, while an overlay is open, before a level',
      () async {
        final h = await GameHarness.mount(tutorial);
        final s = h.game.geometry;
        expect(s, isNull);
        expect(h.board.handleTap(99, 400), isNull, reason: 'no level yet');
        await h.start();
        final g = h.game.geometry!.slot('r0c0');
        h.game.pauseEngine();
        expect(h.board.handleTap(g.centerX, g.surfaceY - 10), isNull);
        h.game.resumeEngine();
        h.game.overlayOpen = true;
        expect(h.board.handleTap(g.centerX, g.surfaceY - 10), isNull);
        h.game.overlayOpen = false;
        expect(h.board.handleTap(g.centerX, g.surfaceY - 10), 'r0c0');
        expect(h.intents.map(_tapped), ['r0c0']);
      },
    );
  });

  group('drag', () {
    late GameHarness h;
    late BoardGeometry g;

    setUp(() async {
      h = await GameHarness.mount(tutorial, fx: await libraryWith(boardFiles));
      await h.start();
      g = h.game.geometry!;
    });

    test('start, follow, drop on a slot', () async {
      final src = g.slot('r0c2');
      final dst = g.slot('r0c1');
      expect(h.board.beginDrag(1, src.centerX, src.surfaceY - 40), isTrue);
      expect(h.intents.single, isA<SlotDragStarted>());
      expect((h.intents.single as SlotDragStarted).slotId, 'r0c2');
      // The bloc picks it up (by drag): doll_pick holds lift's end.
      await h.select('r0c2', byDrag: true);
      final pick = h.board.fx.componentOf(h.timeline.selectionClip!.id)!;
      expect(pick.id, FxId.dollPick);

      h.board.moveDrag(1, dst.centerX + 10, src.surfaceY - 60);
      await h.tick(frameMs);
      // The doll's base moved with the finger: +dx, −20.
      expect(
        pick.position.x,
        closeTo(src.centerX + (dst.centerX + 10 - src.centerX), 1e-3),
      );
      expect(pick.position.y, closeTo(src.surfaceY - 20, 1e-3));

      expect(h.board.endDrag(1), 'r0c1');
      expect((h.intents.last as SlotDragDropped).slotId, 'r0c1');

      // The move comes back byDrag: the flight starts at the finger's base.
      final result = h.session.move('r0c2', 'r0c1') as MoveApplied;
      await h.apply(MoveAppliedEffect(result: result, byDrag: true));
      final flight = h.commandsOf<StartClip>().lastWhere(
        (c) => c.clip.fx == FxId.dollMove,
      );
      final from = flight.clip.params.travelFrom!;
      final expected = g.fit.toReference(dst.centerX + 10, src.surfaceY - 20);
      expect(from.dx, closeTo(expected.dx, 1e-6));
      expect(from.dy, closeTo(expected.dy, 1e-6));
    });

    test('the dragged base is clamped to the board frame (§5, R6)', () async {
      final src = g.slot('r0c0');
      h.board
        ..beginDrag(1, src.centerX, src.surfaceY - 40)
        ..moveDrag(1, -500, -900);
      final frame = g.fit.frame;
      expect(h.board.scene.dragBaseX, frame.left);
      expect(h.board.scene.dragBaseY, frame.top);
      h.board.moveDrag(1, 5000, 5000);
      expect(h.board.scene.dragBaseX, frame.right);
      expect(h.board.scene.dragBaseY, frame.bottom);
    });

    test('a drop over nothing, a cancel, or on a reserved slot is a '
        'cancel', () async {
      final src = g.slot('r0c0');
      h.board
        ..beginDrag(1, src.centerX, src.surfaceY - 40)
        ..moveDrag(1, 195, g.shelves.last.hitBottom + 10);
      expect(h.board.endDrag(1), isNull);
      expect((h.intents.last as SlotDragDropped).slotId, isNull);

      h.board.beginDrag(2, src.centerX, src.surfaceY - 40);
      expect(h.board.endDrag(2, cancelled: true), isNull);
      expect((h.intents.last as SlotDragDropped).slotId, isNull);

      await h.move('r0c2', 'r0c1');
      final reserved = g.slot('r0c1');
      h.board
        ..beginDrag(3, src.centerX, src.surfaceY - 40)
        ..moveDrag(3, reserved.centerX, reserved.surfaceY - 30);
      expect(h.board.endDrag(3), isNull);
    });

    test('a board reset ends a drag held by another finger: its release '
        'sends nothing (review CORRECTNESS-2)', () async {
      await h.move('r1c1', 'r0c2');
      await h.run(800);
      final src = g.slot('r0c0');
      expect(h.board.beginDrag(1, src.centerX, src.surfaceY - 20), isTrue);
      await h.select('r0c0', byDrag: true);
      h.board.moveDrag(1, src.centerX + 90, src.surfaceY - 60);
      await h.run(100);
      // Undo from a second finger: the bloc resets the board.
      final undo = h.session.undo()!;
      await h.apply(
        BoardResetEffect(
          snapshot: h.state,
          reason: BoardResetReason.undo,
          undo: undo,
        ),
      );
      expect(h.board.isDragging, isFalse);
      expect(h.board.scene.dragSlotId, isNull);
      final target = g.slot('r0c1');
      final sent = h.intents.length;
      h.board.moveDrag(1, target.centerX, target.surfaceY - 30);
      expect(h.board.endDrag(1), isNull);
      expect(h.intents, hasLength(sent), reason: 'no drop for the bloc');
      // The next drag works as usual.
      expect(h.board.beginDrag(2, src.centerX, src.surfaceY - 20), isTrue);
    });

    test('released while paused: the doll stays where it is drawn, and the '
        'cancel flies it home after Resume (review CORRECTNESS-3)', () async {
      final src = g.slot('r1c1');
      expect(h.board.beginDrag(1, src.centerX, src.surfaceY - 20), isTrue);
      await h.select('r1c1', byDrag: true);
      h.board.moveDrag(1, src.centerX + 120, src.surfaceY - 140);
      await h.run(100);
      final pick = h.board.fx.componentOf(h.timeline.selectionClip!.id)!;
      final heldX = pick.position.x;
      final heldY = pick.position.y;
      expect(heldX, closeTo(src.centerX + 120, 1e-3));

      h.game.pauseEngine();
      // The finger keeps moving under the pause dialog, then lets go.
      h.board.moveDrag(1, src.centerX - 60, src.surfaceY - 20);
      expect(h.board.scene.dragBaseX, closeTo(heldX, 1e-3));
      expect(h.board.endDrag(1), isNull, reason: 'no target while paused');
      // The bloc puts the doll down (a cancel by drag); it waits for the
      // resume like every effect.
      h.game.apply(
        const SelectionChangedEffect(previous: 'r1c1', byDrag: true),
        h.state,
      );
      h.game.resumeEngine();
      await h.tick(frameMs);
      final home = h.commandsOf<StartClip>().lastWhere(
        (c) => c.clip.fx == FxId.dollMove,
      );
      final from = home.clip.params.travelFrom!;
      final expected = g.fit.toReference(heldX, heldY);
      expect(from.dx, closeTo(expected.dx, 1e-3));
      expect(from.dy, closeTo(expected.dy, 1e-3));
      expect(h.timeline.selectedSlotId, isNull);
      await h.run(400);
      expect(h.board.fx.liveClips, isEmpty);
      expect(h.board.scene.slot('r1c1')!.spriteHidden, isFalse);
    });

    test('one drag at a time; none from a reserved slot', () async {
      final a = g.slot('r0c0');
      final b = g.slot('r1c1');
      expect(h.board.beginDrag(1, a.centerX, a.surfaceY - 40), isTrue);
      expect(h.board.beginDrag(2, b.centerX, b.surfaceY - 40), isFalse);
      h.board.moveDrag(2, 0, 0);
      expect(h.board.endDrag(2), isNull);
      h.board.endDrag(1);
      await h.move('r0c2', 'r0c1');
      final src = g.slot('r0c2');
      expect(h.board.beginDrag(4, src.centerX, src.surfaceY - 40), isFalse);
      expect(h.intents.whereType<SlotDragStarted>(), hasLength(1));
    });
  });

  testWidgets('real gestures through a GameWidget', (tester) async {
    tester.view
      ..physicalSize = const Size(390, 844)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final intents = <GameplayEvent>[];
    final game = NestyGame(
      onIntent: intents.add,
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
    final g = game.geometry!;
    final a = g.slot('r0c2');
    final b = g.slot('r0c1');

    await tester.tapAt(Offset(a.centerX, a.surfaceY - 40));
    await tester.pump(const Duration(milliseconds: 16));
    expect(intents.map(_tapped), ['r0c2']);

    final gesture = await tester.startGesture(
      Offset(a.centerX, a.surfaceY - 40),
    );
    await tester.pump(const Duration(milliseconds: 16));
    for (var i = 1; i <= 10; i++) {
      await gesture.moveTo(
        Offset(a.centerX + (b.centerX - a.centerX) * i / 10, a.surfaceY - 40),
      );
      await tester.pump(const Duration(milliseconds: 16));
    }
    await gesture.up();
    await tester.pump(const Duration(milliseconds: 16));
    expect(intents[1], isA<SlotDragStarted>());
    expect((intents[1] as SlotDragStarted).slotId, 'r0c2');
    expect(intents.last, isA<SlotDragDropped>());
    expect((intents.last as SlotDragDropped).slotId, 'r0c1');
    expect(intents.whereType<SlotTapped>(), hasLength(1));
  });
}
