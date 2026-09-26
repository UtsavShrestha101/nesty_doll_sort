// The Flame tree the board builds for the design's MAIN board (NestyBoard
// `MAIN()`, frame 2.2; docs/plans/m2-lottie-design.md §8, §16 "Flame
// board"): the layers, one SlotComponent per slot with its rest sprite, the
// paused glass and ice compositions, and their rule-3 stand-ins.
import 'package:flame/components.dart' hide Snapshot;
import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_core/nesty_core.dart';
import 'package:nesty_game/features/fx/fake_fx_library.dart';
import 'package:nesty_game/features/fx/fx_cue.dart';
import 'package:nesty_game/features/fx/fx_id.dart';
import 'package:nesty_game/features/fx/fx_player.dart';
import 'package:nesty_game/features/gameplay/bloc/board_effect.dart';
import 'package:nesty_game/features/gameplay/game/board_shape_of.dart';
import 'package:nesty_game/features/gameplay/game/components/board_component.dart';
import 'package:nesty_game/features/gameplay/game/components/fx_layer.dart';
import 'package:nesty_game/features/gameplay/game/components/hint_layer.dart';
import 'package:nesty_game/features/gameplay/game/components/nest_component.dart';
import 'package:nesty_game/features/gameplay/game/components/shelf_layer.dart';
import 'package:nesty_game/features/gameplay/game/components/slot_component.dart';
import 'package:nesty_game/features/gameplay/game/timeline/feedback_sink.dart';
import 'package:nesty_render/nesty_render.dart';

import 'support/board_fixtures.dart';

const _ids = [
  'r0c0', 'r0c1', 'r0c2', 'r0c3', //
  'r1c0', 'r1c1', 'r1c2', 'r1c3', //
  'r2c0', 'r2c1', 'r2c2',
];

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('MAIN board, every file loaded', () {
    late GameHarness h;

    setUp(() async {
      h = await GameHarness.mount(mainLevel, fx: await libraryWith(boardFiles));
      await h.start();
    });

    test('the layers, back to front', () {
      final board = h.board;
      expect(h.game.world.children.whereType<BoardComponent>(), [board]);
      final layers = board.children.toList();
      expect(layers.first, isA<ShelfLayer>());
      expect(layers[1], same(board.fx.underlay));
      expect(layers.whereType<SlotComponent>(), hasLength(11));
      expect(layers[layers.length - 2], isA<HintLayer>());
      expect(layers.last, isA<FxLayer>());
      // Priorities: shelf < glow underlay < slots (row-major) < arc < clips.
      final priorities = [for (final c in layers) c.priority];
      expect(priorities, orderedEquals([...priorities]..sort()));
    });

    test('one SlotComponent per slot, row-major, each with its sprite', () {
      final slots = h.board.children.whereType<SlotComponent>().toList();
      expect([for (final s in slots) s.slotId], _ids);
      for (final slot in slots) {
        expect(slot.isMounted, isTrue);
        expect(slot.children.whereType<NestComponent>(), [slot.nest]);
      }
    });

    test('the layout is BoardLayout on the reference screen', () {
      final expected = BoardLayout.compute(
        boardShapeOf(h.state),
        BoardViewport.reference,
      );
      final g = h.game.geometry!;
      expect(g.scale, expected.scale);
      for (final id in _ids) {
        expect(g.slot(id).centerX, expected.slot(id).centerX, reason: id);
        expect(g.slot(id).surfaceY, expected.slot(id).surfaceY, reason: id);
      }
      expect(g.slot('r1c0').kind, SlotShapeKind.tower);
      expect(g.slot('r1c3').kind, SlotShapeKind.locked);
      expect(h.layouts, [same(g)], reason: 'onLayout once, for the level');
    });

    test('the locked slot rests on a paused glass composition, frame 0', () {
      final slot = h.board.slots['r1c3']!;
      final glass = slot.glass!;
      expect(glass.isMounted, isTrue);
      expect(glass.cacheRest, isTrue);
      expect(glass.drawable.player.state, FxPlayState.resting);
      expect(glass.drawable.player.frame, 0);
      final request = glass.drawable.images.request;
      expect(request.doll, DollColor.green);
      expect(request.unlockColor, DollColor.purple);
      final g = h.game.geometry!.slot('r1c3');
      expect(request.furnitureScale, g.furnitureScale);
      // Its doll base (90, 163) on the case floor (§8); Vector2 is 32-bit.
      expect(glass.position.x, closeTo(g.centerX, 1e-3));
      expect(glass.position.y, closeTo(g.lockedDollBaseY, 1e-3));
      expect(glass.scale.x, closeTo(g.furnitureScale, 1e-6));
      // The composition is the rest look: no sprite.
      expect(slot.nest.isDrawn, isFalse);
      expect(slot.ice, isNull);
    });

    test('the iced slot rests on a paused ice composition with its '
        'badge', () {
      final slot = h.board.slots['r2c1']!;
      final ice = slot.ice!;
      expect(ice.drawable.player.state, FxPlayState.resting);
      // Ice 2 of 2: stage 0.
      expect(ice.drawable.player.frame, 0);
      final g = h.game.geometry!.slot('r2c1');
      expect(ice.position.y, closeTo(g.surfaceY, 1e-3));
      expect(ice.drawable.images.request.doll, DollColor.blue);
      expect(slot.nest.isDrawn, isFalse);
      expect(slot.slot.decor.badgeLabel, '2');
    });

    test('the tower shows its buried nest and its tag', () {
      final tower = h.board.scene.slot('r1c0')!;
      expect(tower.view.buried, [1]);
      expect(tower.view.buriedAtStart, 1);
      expect(tower.decor.tagLabel, '+1');
      expect(h.board.slots['r1c0']!.nest.isDrawn, isTrue);
    });

    test('rest sprites everywhere else; none on the empty slot', () {
      for (final id in _ids) {
        final drawn = h.board.slots[id]!.nest.isDrawn;
        expect(drawn, !{'r1c2', 'r1c3', 'r2c1'}.contains(id), reason: id);
      }
    });

    test('every board file has a mounted pool; idle clips draw nothing', () {
      for (final id in FxLayer.pooled) {
        final pool = h.board.fx.poolOf(id)!;
        expect(pool.inUse, 0, reason: id.fileName);
        for (var i = 0; i < pool.capacity; i++) {
          final component = pool[i];
          expect(component.isMounted, isTrue);
          expect(component.active, isFalse);
          final parent = FxLayer.isUnder(id) ? h.board.fx.underlay : h.board.fx;
          expect(component.parent, same(parent), reason: id.fileName);
        }
      }
    });

    test('a paused composition replays its recorded picture', () async {
      final glass = h.board.slots['r1c3']!.glass!;
      await h.render();
      await h.render();
      await h.render();
      expect(glass.hasRestPicture, isTrue);
      expect(glass.restRecordings, 1);
    });
  });

  group('MAIN board, no Lottie files (rule 3)', () {
    late GameHarness h;

    setUp(() async {
      h = await GameHarness.mount(mainLevel, fx: await libraryWith(const []));
      await h.start();
    });

    test('no pools, and the glass and ice draw their static stand-ins', () {
      for (final id in FxLayer.pooled) {
        expect(h.board.fx.poolOf(id), isNull);
      }
      final locked = h.board.slots['r1c3']!;
      expect(locked.glass, isNull);
      expect(locked.drawsGlassFallback, isTrue);
      // The sprite draws the sealed doll under the static case.
      expect(locked.nest.isDrawn, isTrue);
      final iced = h.board.slots['r2c1']!;
      expect(iced.ice, isNull);
      expect(iced.drawsIceFallback, isTrue);
      expect(iced.nest.isDrawn, isTrue);
    });

    test('it still draws the whole board', () async {
      final snap = await h.render();
      final g = h.game.geometry!;
      // Something at every nest and under the stand-ins.
      for (final id in ['r0c0', 'r1c3', 'r2c1']) {
        final s = g.slot(id);
        expect(
          snap.alphaAt(s.centerX.round(), (s.surfaceY - 20).round()),
          greaterThan(0),
          reason: id,
        );
      }
    });
  });

  test('without a skin, dolls draw with the placeholder painter', () async {
    final h = await GameHarness.mount(tutorial);
    await h.start();
    expect(h.game.skin, isNull);
    expect(h.board.scene.renderer, isA<PlaceholderDollPainter>());
    final snap = await h.render();
    final s = h.game.geometry!.slot('r0c0');
    expect(snap.alphaAt(s.centerX.round(), (s.surfaceY - 30).round()), 255);
  });

  test('a skin handed over is used, and disposed when replaced', () async {
    final h = await GameHarness.mount(tutorial);
    await h.start();
    final first = TestSkin(blobParts([DollColor.red]));
    final second = TestSkin(blobParts([DollColor.red]));
    h.game.skin = first;
    expect(h.board.scene.renderer, same(first.restRenderer));
    final pick = h.board.fx.poolOf(FxId.dollPick);
    expect(pick, isNull, reason: 'the default library has no files');
    h.game.skin = second;
    expect(first.disposed, isTrue);
    expect(second.disposed, isFalse);
    h.game.onDispose();
    expect(second.disposed, isTrue);
  });

  test('a new level rebuilds the slots; an undo reuses them', () async {
    final h = await GameHarness.mount(
      tutorial,
      fx: await libraryWith(boardFiles),
    );
    await h.start();
    final before = h.board.slots['r0c0'];
    await h.move('r0c2', 'r0c1');
    await h.run(700);
    final undo = h.session.undo()!;
    await h.apply(
      BoardResetEffect(
        snapshot: h.state,
        reason: BoardResetReason.undo,
        undo: undo,
      ),
    );
    expect(h.board.slots['r0c0'], same(before));
    expect(h.board.scene.slot('r0c2')!.view.color, DollColor.red);
    expect(h.board.scene.slot('r0c1')!.view.hasNest, isFalse);

    final main = GameState.initial(mainLevel);
    h.game.apply(
      BoardResetEffect(snapshot: main, reason: BoardResetReason.start),
      main,
    );
    await h.tick();
    expect(h.board.slots.keys, _ids);
    expect(before!.isMounted, isFalse);
    expect(h.layouts, hasLength(2));
  });

  test('components render within the board size', () {
    final board = BoardComponent(
      library: FakeFxLibrary(),
      feedback: const _NoFeedback(),
    )..layOut(390, 844);
    expect(board.size, Vector2(390, 844));
    expect(board.containsLocalPoint(Vector2(-5, -5)), isTrue);
  });
}

final class _NoFeedback implements FeedbackSink {
  const _NoFeedback();

  @override
  void play(FxCue cue) {}
}
