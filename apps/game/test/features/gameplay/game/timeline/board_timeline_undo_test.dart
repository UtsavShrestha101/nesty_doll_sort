import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_game/core/services/audio/audio_service.dart';
import 'package:nesty_game/features/fx/fx_id.dart';
import 'package:nesty_game/features/gameplay/bloc/board_effect.dart';
import 'package:nesty_game/features/gameplay/game/timeline/timeline.dart';

import 'support/timeline_fixtures.dart';

/// The animated undo (Q160's default, architecture 3): the reverted nest
/// flies back by `doll_move` after the snapshot is applied.
void main() {
  late TimelineHarness h;

  setUp(() {
    h = TimelineHarness(tutorial)..start();
  });

  TimelineBatch undo() {
    final result = h.session.undo()!;
    return h.schedule(
      BoardResetEffect(
        snapshot: h.state,
        reason: BoardResetReason.undo,
        undo: result,
      ),
    );
  }

  test('the reset applies at 0, then the nest flies target -> source', () {
    h.move('r0c2', 'r0c0'); // red2 into red3
    h.run(1500);
    final batch = undo();
    expect(batch.commands.first, isA<ResetBoard>());
    final flight = startOf(batch, FxClipPurpose.move, FxId.dollMove);
    expect(flight.atMs, 0);
    expect(flight.clip.hides, ['r0c2']);
    final from = h.geometry.slot('r0c0');
    final to = h.geometry.slot('r0c2');
    expect(flight.clip.params.travelFrom, isNotNull);
    expect(flight.clip.params.travelTo, isNotNull);
    expect(
      flight.clip.params.travelFrom,
      isNot(equals(flight.clip.params.travelTo)),
    );
    expect(from.centerX, isNot(to.centerX));
    expect(batch.cues.map((c) => c.sound), [SoundEffect.whoosh]);
    expect(h.timeline.isReserved('r0c0'), isTrue);
    expect(h.timeline.isReserved('r0c2'), isTrue);

    final sprites = SpriteModel();
    for (final e in h.commands.executed) {
      sprites.apply(e.command);
    }
    expect(sprites.isHidden('r0c2'), isTrue, reason: 'in flight');
    h.run(batch.endMs + 50);
    expect(h.timeline.isReserved('r0c2'), isFalse);
    expect(h.timeline.isIdle, isTrue);
  });

  test('the flight ends and releases the sprite', () {
    h.move('r0c2', 'r0c0');
    h.run(1500);
    final batch = undo();
    final flight = startOf(batch, FxClipPurpose.move, FxId.dollMove).clip;
    final stop = stopOf(batch, flight);
    expect(stop, greaterThan(0));
    final sprites = SpriteModel();
    final before = h.commands.executed.length;
    h.run(stop + 20);
    for (final e in h.commands.executed.skip(before)) {
      sprites.apply(e.command);
    }
    expect(sprites.isHidden('r0c2'), isFalse);
  });

  test('a rapid second undo cancels the first flight and plays its own', () {
    h.move('r0c2', 'r0c0');
    h.run(1500);
    final first = undo();
    final firstFlight = startOf(first, FxClipPurpose.move, FxId.dollMove);
    h.run(60); // mid-flight
    h.move('r0c2', 'r0c1'); // red2 to the empty r0c1
    h.run(30);
    final second = undo();
    final secondFlight = startOf(second, FxClipPurpose.move, FxId.dollMove);
    expect(secondFlight.clip.id, isNot(firstFlight.clip.id));
    expect(second.commands.first, isA<ResetBoard>());
    expect(secondFlight.clip.hides, ['r0c2']);
    final before = h.commands.executed.length;
    h.run(2000);
    final stops = h.commands.executed
        .skip(before)
        .map((e) => e.command)
        .whereType<StopClip>()
        .where((c) => c.clip.fx == FxId.dollMove)
        .toList();
    expect(stops.map((s) => s.clip.id), [secondFlight.clip.id]);
    expect(h.timeline.isIdle, isTrue);
    expect(h.timeline.inputLocked, isFalse);
    expect(h.timeline.isReserved('r0c2'), isFalse);
  });

  test('a restart never flies: only an undo carries the move', () {
    h.move('r0c2', 'r0c0');
    h.run(1500);
    final batch = h.schedule(
      BoardResetEffect(snapshot: h.state, reason: BoardResetReason.restart),
    );
    expect(
      batch.commandsOf<StartClip>().where((c) => c.clip.fx == FxId.dollMove),
      isEmpty,
    );
    expect(batch.cues, isEmpty);
  });

  test('reduced motion plays the flight at 2x', () {
    final full = () {
      h.move('r0c2', 'r0c0');
      h.run(1500);
      final b = undo();
      final f = startOf(b, FxClipPurpose.move, FxId.dollMove);
      return stopOf(b, f.clip);
    }();
    final r = TimelineHarness(tutorial, motion: MotionSpec.reduced)..start();
    r.move('r0c2', 'r0c0');
    r.run(1500);
    final result = r.session.undo()!;
    final b = r.schedule(
      BoardResetEffect(
        snapshot: r.state,
        reason: BoardResetReason.undo,
        undo: result,
      ),
    );
    final f = startOf(b, FxClipPurpose.move, FxId.dollMove);
    expect(full, closeTo(260, 20), reason: 'motion.move at 1x');
    expect(f.segment.speed, 2);
    expect(stopOf(b, f.clip), at(full / 2));
  });

  test('undo, move, undo chains leave the board idle and unlocked', () {
    h.move('r0c2', 'r0c0');
    h.run(1500);
    undo();
    h.run(1500);
    h.move('r0c2', 'r0c1');
    h.run(1500);
    undo();
    h.run(1500);
    expect(h.timeline.isIdle, isTrue);
    expect(h.timeline.isReserved('r0c0'), isFalse);
    expect(h.timeline.inputLocked, isFalse);
  });
}
