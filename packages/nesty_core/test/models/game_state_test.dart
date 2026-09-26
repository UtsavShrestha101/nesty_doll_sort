// The public surface of GameState at the start of a level (spec §4 `State`:
// "slots (flattened, stable ids ...), completedSets: int, completedByColor:
// Map<DollColor,int>, moveCount"). States after moves are covered by the
// rules and session tests, which go through the engine.
import 'package:nesty_core/nesty_core.dart';
import 'package:test/test.dart';

import 'spec_example_level.dart';

void main() {
  group('GameState.initial', () {
    final level = specExampleLevel();
    final state = GameState.initial(level);

    test('is for its level', () {
      expect(state.level, level);
    });

    test('lists the level slots in board order, no extra slots yet', () {
      expect(state.slotIds, level.slotIds);
      expect(state.extraSlotCount, 0);
    });

    test('shows every slot exactly as the level defines it', () {
      for (final id in level.slotIds) {
        expect(state.slot(id), level.slot(id), reason: id);
        expect(state.positionOf(id), level.positionOf(id), reason: id);
      }
    });

    test('starts with nothing completed and no moves', () {
      expect(state.completedSets, 0);
      expect(state.moveCount, 0);
      for (final color in DollColor.values) {
        expect(state.completedOf(color), 0, reason: color.id);
      }
    });

    test('counts the sets to win (spec §2.3)', () {
      expect(state.totalSets, 3);
      expect(state.isWon, isFalse);
    });

    test('unknown ids throw, including extra slots not added yet', () {
      for (final id in ['x0', 'x1', 'r2c0', 'nope']) {
        expect(() => state.slot(id), throwsArgumentError, reason: id);
        expect(() => state.positionOf(id), throwsArgumentError, reason: id);
      }
    });

    test('equal levels give equal states', () {
      final again = GameState.initial(specExampleLevel());
      expect(again, state);
      expect(again.hashCode, state.hashCode);
    });

    test('different levels give different states', () {
      final other = Level(
        id: 'other',
        maxSize: level.maxSize,
        shelves: level.shelves,
      );
      expect(GameState.initial(other), isNot(state));
    });
  });
}
