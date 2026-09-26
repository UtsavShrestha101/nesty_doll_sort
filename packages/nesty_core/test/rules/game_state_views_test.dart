// GameState after moves (spec §4 `State`): slot views, extra-slot ids and
// positions (spec §3.6, D22), value equality, and immutability. The initial
// board is covered by test/models/game_state_test.dart.
import 'package:nesty_core/nesty_core.dart';
import 'package:test/test.dart';

import '../models/spec_example_level.dart' show specExampleLevel;
import 'support/boards.dart';

void main() {
  final level = board(3, [
    [open('red1'), open('blue1'), open(), open()],
    [open('red3 red2'), open('blue3 blue2')],
  ]);
  final start = GameState.initial(level);

  group('equality', () {
    test('the same board reached in a different order is equal', () {
      final a = play(start, ['r0c0>r0c2', 'r0c1>r0c3']);
      final b = play(start, ['r0c1>r0c3', 'r0c0>r0c2']);
      expect(a, b);
      expect(a.hashCode, b.hashCode);
    });

    test('the move count is part of the state (spec §4)', () {
      final back = play(start, ['r0c0>r0c2', 'r0c2>r0c0']);
      expect(back.slot('r0c0'), start.slot('r0c0'));
      expect(back.slot('r0c2'), start.slot('r0c2'));
      expect(back, isNot(start));
    });

    test('different boards differ', () {
      expect(apply(start, 'r0c0>r0c2').state, isNot(start));
      expect(
        apply(start, 'r0c0>r0c2').state,
        isNot(apply(start, 'r0c0>r0c3').state),
      );
    });
  });

  test('a state never changes after later moves', () {
    final one = apply(start, 'r0c0>r1c0').state; // completes red
    final before = views(one);
    play(one, ['r0c1>r0c0', 'r0c0>r1c1']);
    expect(views(one), before);
    expect(one.completedSets, 1);
    expect(one.moveCount, 1);
  });

  test('completedOf counts per color; gold never forms a set', () {
    final end = play(start, ['r0c0>r1c0', 'r0c1>r1c1']);
    expect(end.completedOf(DollColor.red), 1);
    expect(end.completedOf(DollColor.blue), 1);
    expect(end.completedOf(DollColor.green), 0);
    expect(end.completedOf(DollColor.gold), 0);
    expect(end.isWon, isTrue);
  });

  group('extra slots', () {
    final session = GameSession(specExampleLevel());
    final one = session.addExtraSlot()!.state;
    final two = session.addExtraSlot()!.state;

    test('ids are appended in order', () {
      expect(one.slotIds.last, 'x0');
      expect(two.slotIds.sublist(two.slotIds.length - 2), ['x0', 'x1']);
      expect(two.extraSlotCount, 2);
    });

    test('they sit right of the bottom shelf (spec §3.6, D22)', () {
      // The §5.1 example's bottom shelf r1 has 3 slots.
      expect(two.positionOf('x0'), const BoardPosition(1, 3));
      expect(two.positionOf('x1'), const BoardPosition(1, 4));
    });

    test('they are empty open slots', () {
      expect(two.slot('x0'), open());
      expect(two.slot('x1'), open());
      expect(Rules.isInteractable(two, 'x0'), isTrue);
    });

    test('an extra slot not added yet is unknown', () {
      expect(() => one.slot('x1'), throwsArgumentError);
      expect(() => one.positionOf('x1'), throwsArgumentError);
    });

    test('adding one changes the state', () {
      expect(one, isNot(GameState.initial(specExampleLevel())));
    });
  });

  group('levels the engine cannot lay out', () {
    test('no shelf: extra slots have nowhere to go', () {
      expect(() => GameState.initial(board(3, const [])), throwsArgumentError);
    });

    test('more slots than a 30-bit slot mask holds', () {
      final tooMany = board(3, [
        for (var row = 0; row < 6; row++) [for (var c = 0; c < 5; c++) open()],
      ]);
      expect(() => GameState.initial(tooMany), throwsArgumentError);
    });
  });
}
