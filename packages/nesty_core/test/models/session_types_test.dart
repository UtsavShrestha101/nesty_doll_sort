// Spec §2.4: "Undo reverts the last move. The undo history is cleared
// whenever a set completes." Spec §3.6 / D22: the extra slot is appended to
// the bottom shelf. These are the records GameSession hands out; the session
// behaviour itself is tested with GameSession.
import 'package:nesty_core/nesty_core.dart';
import 'package:test/test.dart';

import 'spec_example_level.dart';

void main() {
  final state = GameState.initial(specExampleLevel());
  const move = Move('r0c0', 'r0c1');
  final red43 = nest(DollColor.red, 4, 2);
  final events = <MoveEvent>[
    Picked(
      slotId: 'r0c0',
      nest: red43,
      fromTower: false,
      leftEmptyTower: false,
    ),
    Placed(fromId: 'r0c0', slotId: 'r0c1', nest: red43),
  ];

  group('UndoEntry', () {
    test('holds the board before, the move and its events', () {
      final entry = UndoEntry(before: state, move: move, events: events);
      expect(entry.before, state);
      expect(entry.move, move);
      expect(entry.events, events);
    });

    test('copies the events and exposes them unmodifiable', () {
      final source = [...events];
      final entry = UndoEntry(before: state, move: move, events: source);
      source.clear();
      expect(entry.events, hasLength(2));
      expect(() => entry.events.clear(), throwsUnsupportedError);
    });

    test('equality by value', () {
      expect(
        UndoEntry(before: state, move: move, events: events),
        UndoEntry(before: state, move: move, events: [...events]),
      );
      expect(
        UndoEntry(before: state, move: move, events: events).hashCode,
        UndoEntry(before: state, move: move, events: [...events]).hashCode,
      );
      expect(
        UndoEntry(before: state, move: move, events: events),
        isNot(UndoEntry(before: state, move: move, events: const [])),
      );
    });
  });

  group('UndoResult', () {
    test('holds the reverted move and the restored board', () {
      final result = UndoResult(revertedMove: move, restoredState: state);
      expect(result.revertedMove, move);
      expect(result.restoredState, state);
      expect(result, UndoResult(revertedMove: move, restoredState: state));
      expect(
        result,
        isNot(
          UndoResult(
            revertedMove: const Move('r0c1', 'r0c0'),
            restoredState: state,
          ),
        ),
      );
    });
  });

  group('ExtraSlotAdded', () {
    test('holds the id, its bottom-shelf position and the board', () {
      final added = ExtraSlotAdded(
        slotId: 'x0',
        position: const BoardPosition(1, 3),
        state: state,
      );
      expect(added.slotId, 'x0');
      expect(added.position, const BoardPosition(1, 3));
      expect(added.state, state);
      expect(
        added,
        ExtraSlotAdded(
          slotId: 'x0',
          position: const BoardPosition(1, 3),
          state: state,
        ),
      );
      expect(
        added,
        isNot(
          ExtraSlotAdded(
            slotId: 'x1',
            position: const BoardPosition(1, 4),
            state: state,
          ),
        ),
      );
    });
  });
}
