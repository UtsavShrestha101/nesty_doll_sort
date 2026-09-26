// The board's life across levels, restarts and loads
// (docs/plans/m2-lottie-design.md §4, §8, §10.1, §10.7): every new level
// reports its layout (the page prepares its art from it), a restart re-rests
// the slot compositions in the same frame, a library that loads after the
// board is built upgrades the static stand-ins once the board is idle, and a
// new batch's clips run on the timeline's own clock.
import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/painting.dart' show EdgeInsets;
import 'package:flutter_test/flutter_test.dart';
import 'package:lottie/lottie.dart' show LottieComposition;
import 'package:nesty_core/nesty_core.dart';
import 'package:nesty_game/features/fx/fake_fx_library.dart';
import 'package:nesty_game/features/fx/fx_id.dart';
import 'package:nesty_game/features/fx/fx_library.dart';
import 'package:nesty_game/features/fx/fx_player.dart';
import 'package:nesty_game/features/gameplay/bloc/board_effect.dart';
import 'package:nesty_game/features/gameplay/game/timeline/timeline.dart';

import 'support/board_fixtures.dart';
import 'timeline/support/timeline_fixtures.dart' as tl;

/// The tutorial's shape (3 + 3 open slots, max size 3) in blue.
final Level _blueTutorial = levelFrom('''
{
  "schemaVersion": 1,
  "id": "T0002",
  "maxSize": 3,
  "shelves": [
    [ {"type": "open", "nest": null},
      {"type": "open", "nest": ["blue3"]},
      {"type": "open", "nest": null} ],
    [ {"type": "open", "nest": ["blue1"]},
      {"type": "open", "nest": null},
      {"type": "open", "nest": ["blue2"]} ]
  ]
}
''');

/// A library whose files arrive only when [finish] is called (a board built
/// before the splash finished loading).
final class _LateLibrary implements FxLibrary {
  _LateLibrary(this._files);

  final FakeFxLibrary _files;
  final Completer<void> _done = Completer<void>();
  bool _loaded = false;
  int loads = 0;

  void finish() {
    _loaded = true;
    _done.complete();
  }

  @override
  Future<void> load({void Function(double progress)? onProgress}) {
    loads++;
    return _done.future;
  }

  @override
  bool get isLoaded => _loaded;

  @override
  LottieComposition? operator [](FxId id) => _loaded ? _files[id] : null;

  @override
  Set<FxId> get failed => const {};

  @override
  ui.Image? get blank => _loaded ? _files.blank : null;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('a new level shaped like the last still gets, and reports, its own '
      'layout and slots', () async {
    final h = await GameHarness.mount(
      tutorial,
      fx: await libraryWith(boardFiles),
    );
    await h.start();
    final first = h.game.geometry!;
    final before = h.board.slots['r0c1']!;
    final next = GameState.initial(_blueTutorial);
    h.game.apply(
      BoardResetEffect(snapshot: next, reason: BoardResetReason.start),
      next,
    );
    await h.tick();
    // The page prepares each level's art (its colours) from onLayout.
    expect(h.layouts, hasLength(2));
    expect(h.layouts.last, same(h.game.geometry));
    expect(h.game.geometry, isNot(same(first)));
    expect(h.board.slots['r0c1'], isNot(same(before)));
    expect(h.board.scene.slot('r0c1')!.view.color, DollColor.blue);
    expect(h.board.scene.slot('r0c0')!.view.hasNest, isFalse);
  });

  test(
    'a restart or an undo on the same level reports no new layout',
    () async {
      final h = await GameHarness.mount(tutorial);
      await h.start();
      await h.move('r0c2', 'r0c1');
      await h.run(300);
      h.session.restart();
      await h.apply(
        BoardResetEffect(snapshot: h.state, reason: BoardResetReason.restart),
      );
      expect(h.layouts, hasLength(1));
    },
  );

  test('a restart re-rests the released case in the same frame, from the '
      'same mounted component', () async {
    final h = await GameHarness.mount(
      tl.comboLevel,
      fx: await libraryWith(boardFiles),
    );
    await h.start();
    final locked = h.board.slots['r0c2']!;
    final glass = locked.glass!;
    await h.move('r0c0', 'r0c1');
    await h.run(2600);
    expect(locked.glass, isNull);
    expect(glass.active, isFalse, reason: 'released: draws nothing');

    h.session.restart();
    h.game.apply(
      BoardResetEffect(snapshot: h.state, reason: BoardResetReason.restart),
      h.state,
    );
    // One update, no lifecycle pass: it must draw in this very frame.
    h.game.update(0);
    expect(locked.glass, same(glass));
    expect(glass.isMounted, isTrue);
    expect(glass.active, isTrue);
    expect(glass.drawable.player.state, FxPlayState.resting);
    expect(glass.drawable.player.frame, 0);
    expect(glass.drawable.images.request.unlockColor, DollColor.red);
    expect(locked.nest.isDrawn, isFalse);
  });

  test('a library that loads after the board is built: pools at once, '
      'compositions when the board is idle (§10.7)', () async {
    final files = await libraryWith(boardFiles);
    final library = _LateLibrary(files);
    final h = await GameHarness.mount(tl.comboLevel, fx: library);
    await h.start();
    expect(library.loads, 1, reason: 'the board starts the load');
    final locked = h.board.slots['r0c2']!;
    expect(locked.drawsGlassFallback, isTrue);
    expect(h.board.fx.poolOf(FxId.dollMove), isNull);

    // A move is playing when the files arrive.
    await h.move('r1c0', 'r1c1');
    library.finish();
    await pumpEventQueue();
    await h.tick(frameMs);
    expect(h.board.fx.poolOf(FxId.dollMove), isNotNull);
    expect(locked.drawsGlassFallback, isTrue, reason: 'not while it plays');

    await h.run(400);
    expect(locked.drawsGlassFallback, isFalse);
    expect(locked.glass, isNotNull);
    expect(locked.glass!.drawable.player.frame, 0);
    expect(locked.nest.isDrawn, isFalse);
  });

  // Flame mounts a component added during `update` only at the start of the
  // next tick, and removes one only then. The frames below are rendered
  // straight after the update that changed the tree, with no lifecycle pass
  // between, as the engine does.

  test('the frame a new level arrives draws that level, whole, and nothing '
      'of the last one', () async {
    final h = await GameHarness.mount(
      tutorial,
      fx: await libraryWith(boardFiles),
    );
    await h.start();
    final old = h.board.slots.values.toList();
    final main = GameState.initial(mainLevel);
    h.game.apply(
      BoardResetEffect(snapshot: main, reason: BoardResetReason.start),
      main,
    );
    h.game.update(0);
    // Not mounted yet, and the last level's still are.
    expect(h.board.slots['r1c3']!.isMounted, isFalse);
    expect(old.first.isMounted, isTrue);
    final swap = await h.render();
    await h.game.ready();
    expect(old.any((slot) => slot.isMounted), isFalse);
    final settled = await h.render();
    final diff = meanDifference(swap, settled);
    expect(diff.touched, greaterThan(1000), reason: 'the board is drawn');
    expect(diff.mean, lessThan(0.01), reason: 'mean ${diff.mean}');
  });

  test('a composition built on a mounted slot takes over only once Flame '
      'mounts it: the stand-in and the sprite draw until then', () async {
    final library = _LateLibrary(await libraryWith(boardFiles));
    final h = await GameHarness.mount(tl.comboLevel, fx: library);
    await h.start();
    final locked = h.board.slots['r0c2']!;
    final g = h.game.geometry!.slot('r0c2');
    final region = g.glassCaseRect.inflate(4);
    final before = await h.render();

    library.finish();
    await pumpEventQueue();
    // The board is idle: this update builds the composition.
    h.game.update(frameMs / 1000);
    final glass = locked.glass;
    expect(glass, isNotNull);
    expect(glass!.isMounted, isFalse);
    expect(locked.drawsGlassFallback, isTrue);
    expect(locked.nest.isDrawn, isTrue);
    final upgrade = await h.render();
    final diff = meanDifference(before, upgrade, region: region);
    expect(diff.touched, greaterThan(200), reason: 'the case is drawn');
    expect(diff.mean, lessThan(0.01), reason: 'mean ${diff.mean}');

    await h.game.ready();
    expect(glass.isMounted, isTrue);
    expect(locked.drawsGlassFallback, isFalse);
    expect(locked.nest.isDrawn, isFalse);
  });

  test('a resize during the +1 Slot re-pitch ends on the resized layout, '
      'not the one the re-pitch was heading for', () async {
    final h = await GameHarness.mount(
      tutorial,
      fx: await libraryWith(boardFiles),
    );
    await h.start();
    final added = h.session.addExtraSlot()!;
    await h.apply(ExtraSlotAddedEffect(added));
    await h.run(100);
    expect(h.board.scene.repitch, isNotNull);
    h.game.padding = const EdgeInsets.only(top: 90, bottom: 140);
    final resized = h.game.geometry!;
    expect(resized.slotOrNull('x0'), isNotNull);
    expect(h.board.scene.repitch, isNull, reason: 'the resize settled it');
    await h.run(300);
    expect(h.game.geometry, same(resized));
    expect(h.board.scene.slot('r1c2')!.geometry, same(resized.slot('r1c2')));
    expect(h.board.scene.slot('x0')!.from, isNull);
  });

  test('an effect applied between frames plays on the timeline\'s clock: '
      'doll_move reaches its last frame when its StopClip runs', () async {
    final h = await GameHarness.mount(
      tutorial,
      fx: await libraryWith(boardFiles),
    );
    await h.start();
    double? frameAtStop;
    double? startedAt;
    final record = h.board.debugOnCommand!;
    h.board.debugOnCommand = (command, lateMs) {
      record(command, lateMs);
      if (command is StartClip && command.clip.fx == FxId.dollMove) {
        startedAt = h.timeline.nowMs;
      }
      if (command is StopClip && command.clip.fx == FxId.dollMove) {
        frameAtStop = h.board.fx
            .componentOf(command.clip.id)
            ?.drawable
            .player
            .frame;
      }
    };
    await h.tick(frameMs);
    final before = h.timeline.nowMs;
    // As the page does: from a bloc listener, between two frames.
    final result = h.session.move('r0c2', 'r0c1') as MoveApplied;
    h.game.apply(MoveAppliedEffect(result: result), h.state);
    await h.tick(frameMs);
    // The batch starts at this frame's time, and draws its frame 0 now.
    expect(startedAt, closeTo(before + frameMs, 1e-9));
    final move = h.board.fx.liveClips.single;
    final component = h.board.fx.componentOf(move.id)!;
    expect(component.drawable.player.frame, 0);
    await h.run(frameMs * 5);
    expect(
      component.drawable.player.frame * frameMs,
      closeTo(h.timeline.nowMs - startedAt!, 1e-6),
    );
    await h.run(400);
    // It never skips its last frames: the stop finds it at the end.
    expect(frameAtStop, greaterThan(15.9));
  });
}
