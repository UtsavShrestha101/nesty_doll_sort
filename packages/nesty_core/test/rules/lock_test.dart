// Spec §3.3 glass cases: the nest inside is visible but can't be used, the
// case takes no drop, and "the case breaks and the slot becomes an open slot
// the moment the first full set of its unlockColor completes" (§4: "for
// each Locked with unlockColor == c and !unlocked: unlock → emit Unlocked").
import 'package:nesty_core/nesty_core.dart';
import 'package:test/test.dart';

import 'support/boards.dart';

void main() {
  group('while locked', () {
    final state = GameState.initial(
      board(3, [
        [open('red3 red2'), open('red1'), locked(DollColor.red, 'blue3 blue2')],
        [locked(DollColor.red), open('blue1'), open()],
      ]),
    );

    test('the nest shows behind the glass', () {
      expect(state.slot('r0c2'), locked(DollColor.red, 'blue3 blue2'));
    });

    test('the case is neither interactable nor pickable', () {
      expect(Rules.isInteractable(state, 'r0c2'), isFalse);
      expect(Rules.canPick(state, 'r0c2'), isFalse);
      expect(Rules.isInteractable(state, 'r1c0'), isFalse);
      expect(Rules.legalTargets(state, 'r0c2'), isEmpty);
    });

    test('no move uses it, as source or as target', () {
      for (final move in Rules.legalMoves(state)) {
        expect(move.from, isNot(anyOf('r0c2', 'r1c0')), reason: '$move');
        expect(move.to, isNot(anyOf('r0c2', 'r1c0')), reason: '$move');
      }
      // [blue1] would go inside [blue3, blue2] (1 == 2 − 1) if the case
      // were open.
      expect(rejection(state, 'r1c1>r0c2'), InvalidMoveReason.targetLocked);
      expect(rejection(state, 'r0c2>r1c2'), InvalidMoveReason.sourceLocked);
    });
  });

  group('the first full set of the unlock color', () {
    final state = GameState.initial(
      board(3, [
        [open('red3 red2'), open('red1'), locked(DollColor.red, 'blue3 blue2')],
        [locked(DollColor.green, 'blue1'), locked(DollColor.red), open()],
      ]),
    );
    final result = apply(state, 'r0c1>r0c0');

    test('breaks every case of that color, in slot order', () {
      expect(result.events, [
        Picked(
          slotId: 'r0c1',
          nest: nest('red1'),
          fromTower: false,
          leftEmptyTower: false,
        ),
        NestedInto(
          fromId: 'r0c1',
          slotId: 'r0c0',
          direction: NestDirection.inside,
          moving: nest('red1'),
          target: nest('red3 red2'),
          merged: nest('red3 red2 red1'),
        ),
        const Completed(
          slotId: 'r0c0',
          color: DollColor.red,
          setsCompleted: 1,
          totalSets: 2,
          leftEmptyTower: false,
        ),
        const Unlocked(slotId: 'r0c2', unlockColor: DollColor.red),
        const Unlocked(slotId: 'r1c1', unlockColor: DollColor.red),
      ]);
    });

    test('the broken cases are open slots, nest and all', () {
      expect(result.state.slot('r0c2'), open('blue3 blue2'));
      expect(result.state.slot('r1c1'), open());
      expect(Rules.canPick(result.state, 'r0c2'), isTrue);
      expect(Rules.legalTargets(result.state, 'r0c2'), contains('r1c1'));
    });

    test('a case of another color stays locked', () {
      expect(result.state.slot('r1c0'), locked(DollColor.green, 'blue1'));
      expect(Rules.isInteractable(result.state, 'r1c0'), isFalse);
    });
  });

  test('a set of another color breaks nothing', () {
    final state = GameState.initial(
      board(3, [
        [open('blue3 blue2'), open('blue1'), locked(DollColor.red, 'red1')],
        [open('red3 red2'), open()],
      ]),
    );
    final result = apply(state, 'r0c1>r0c0');
    expect(result.completedSet, isTrue);
    expect(result.events.whereType<Unlocked>(), isEmpty);
    expect(result.events, hasLength(3));
    expect(result.state.slot('r0c2'), locked(DollColor.red, 'red1'));
  });

  test('only the first set of the color unlocks; later ones find it open', () {
    final state = GameState.initial(
      board(3, [
        [open('red3 red2'), open('red1'), open('red3'), open('red2 red1')],
        [locked(DollColor.red, 'blue3 blue2'), open('blue1')],
      ]),
    );
    final first = apply(state, 'r0c1>r0c0');
    expect(first.events.whereType<Unlocked>(), [
      const Unlocked(slotId: 'r1c0', unlockColor: DollColor.red),
    ]);
    final second = apply(first.state, 'r0c3>r0c2');
    expect(second.completedSet, isTrue);
    expect(second.events.whereType<Unlocked>(), isEmpty);
    expect(second.state.completedOf(DollColor.red), 2);
    expect(second.state.slot('r1c0'), open('blue3 blue2'));
  });

  test('a broken case keeps its ice until the ice is gone (§3.4)', () {
    final state = GameState.initial(
      board(3, [
        [
          open('red3 red2'),
          open('red1'),
          locked(DollColor.red, 'blue3 blue2', 2),
        ],
        [open('blue1'), open()],
      ]),
    );
    final result = apply(state, 'r0c1>r0c0');
    expect(result.events.sublist(3), [
      const Unlocked(slotId: 'r0c2', unlockColor: DollColor.red),
      const IceCracked(slotId: 'r0c2', remaining: 1),
    ]);
    expect(result.state.slot('r0c2'), open('blue3 blue2', 1));
    expect(Rules.canPick(result.state, 'r0c2'), isFalse);
    expect(
      rejection(result.state, 'r0c2>r1c1'),
      InvalidMoveReason.sourceFrozen,
    );
  });
}
