// Spec §2.2: "The player picks up a whole nest from a slot and drops it on
// another slot ... Any other drop is invalid." Spec §4: tryMove returns a
// MoveResult(events, newState). Design §1: sealed MoveResult with
// MoveApplied and MoveRejected(reason).
import 'package:nesty_core/nesty_core.dart';
import 'package:test/test.dart';

import 'spec_example_level.dart';

void main() {
  group('Move', () {
    test('names source and target slot ids', () {
      const move = Move('r0c0', 'r0c1');
      expect(move.from, 'r0c0');
      expect(move.to, 'r0c1');
      expect(move.toString(), 'r0c0 -> r0c1');
    });

    test('equality by value and direction', () {
      expect(const Move('r0c0', 'x0'), Move('r0c0', fresh('x0')));
      expect(
        const Move('r0c0', 'x0').hashCode,
        Move('r0c0', fresh('x0')).hashCode,
      );
      expect(const Move('r0c0', 'r0c1'), isNot(const Move('r0c1', 'r0c0')));
    });
  });

  group('InvalidMoveReason', () {
    test('covers every require of spec §4 (design §1 list)', () {
      expect(InvalidMoveReason.values.map((r) => r.name), [
        'unknownSlot',
        'sameSlot',
        'sourceEmpty',
        'sourceFrozen',
        'sourceLocked',
        'targetFrozen',
        'targetLocked',
        'colorMismatch',
        'sizeMismatch',
        'targetOccupied',
      ]);
    });
  });

  group('MoveApplied', () {
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

    test('holds the move, the new state and the events in order', () {
      final result = MoveApplied(
        move: move,
        state: state,
        events: events,
        completedSet: false,
      );
      expect(result.move, move);
      expect(result.state, state);
      expect(result.events, events);
      expect(result.completedSet, isFalse);
    });

    test('copies the events and exposes them unmodifiable', () {
      final source = [...events];
      final result = MoveApplied(
        move: move,
        state: state,
        events: source,
        completedSet: false,
      );
      source.clear();
      expect(result.events, hasLength(2));
      expect(
        () => result.events.add(const OutOfMoves()),
        throwsUnsupportedError,
      );
    });

    test('equality by value', () {
      MoveApplied make({bool completed = false}) => MoveApplied(
        move: move,
        state: state,
        events: events,
        completedSet: completed,
      );
      expect(make(), make());
      expect(make().hashCode, make().hashCode);
      expect(make(), isNot(make(completed: true)));
    });
  });

  group('MoveRejected', () {
    test('targetId is the slot the drop aimed at (the one that shakes)', () {
      const rejected = MoveRejected(
        move: Move('r0c0', 'r1c1'),
        reason: InvalidMoveReason.targetFrozen,
      );
      expect(rejected.targetId, 'r1c1');
      expect(rejected.reason, InvalidMoveReason.targetFrozen);
      expect(rejected.toString(), 'MoveRejected(r0c0 -> r1c1, targetFrozen)');
    });

    test('equality by move and reason', () {
      const a = MoveRejected(
        move: Move('r0c0', 'r0c2'),
        reason: InvalidMoveReason.sizeMismatch,
      );
      expect(
        a,
        MoveRejected(
          move: Move('r0c0', fresh('r0c2')),
          reason: InvalidMoveReason.sizeMismatch,
        ),
      );
      expect(
        a,
        isNot(
          const MoveRejected(
            move: Move('r0c0', 'r0c2'),
            reason: InvalidMoveReason.colorMismatch,
          ),
        ),
      );
    });
  });

  test('a switch over MoveResult is exhaustive with applied / rejected', () {
    String describe(MoveResult result) => switch (result) {
      MoveApplied(:final events) => 'applied ${events.length}',
      MoveRejected(:final reason) => 'rejected ${reason.name}',
    };
    expect(
      describe(
        const MoveRejected(
          move: Move('r0c0', 'r0c0'),
          reason: InvalidMoveReason.sameSlot,
        ),
      ),
      'rejected sameSlot',
    );
    expect(
      describe(
        MoveApplied(
          move: const Move('r0c0', 'r0c1'),
          state: GameState.initial(specExampleLevel()),
          events: const [],
          completedSet: false,
        ),
      ),
      'applied 0',
    );
  });
}

/// A copy of [s] that is not a compile-time constant, so equality is tested
/// between distinct instances rather than canonicalized ones.
String fresh(String s) => String.fromCharCodes(s.codeUnits);
