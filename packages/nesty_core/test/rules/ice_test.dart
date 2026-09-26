// Spec §3.4 ice: an iced slot can't be picked from or dropped onto; "each
// full set completed anywhere lowers every ice counter by 1"; "at 0 the ice
// shatters and the slot works normally". §4: IceCracked(slotId, remaining)
// while the counter stays above 0, IceShattered(slotId) when it reaches 0
// (a drop from 1 to 0 emits only IceShattered, design A9); events come in
// slot order, after the Unlocked events.
import 'package:nesty_core/nesty_core.dart';
import 'package:test/test.dart';

import 'support/boards.dart';

void main() {
  // maxSize 3; red, green and blue sets.
  //   r0: [red3 red2] | [red1] | [blue3] ice 1 | [green3]
  //   r1: [blue2 blue1] ice 2 | locked(green) empty, ice 3 | [green2 green1]
  //       | empty
  final start = GameState.initial(
    board(3, [
      [open('red3 red2'), open('red1'), open('blue3', 1), open('green3')],
      [
        open('blue2 blue1', 2),
        locked(DollColor.green, null, 3),
        open('green2 green1'),
        open(),
      ],
    ]),
  );

  test('the counters show on the slot views', () {
    expect(start.slot('r0c2'), open('blue3', 1));
    expect(start.slot('r1c0'), open('blue2 blue1', 2));
    expect(start.slot('r1c1'), locked(DollColor.green, null, 3));
  });

  test('an iced slot is neither a source nor a target', () {
    expect(Rules.isInteractable(start, 'r0c2'), isFalse);
    expect(Rules.canPick(start, 'r0c2'), isFalse);
    expect(rejection(start, 'r0c2>r1c3'), InvalidMoveReason.sourceFrozen);
    expect(rejection(start, 'r0c0>r1c0'), InvalidMoveReason.targetFrozen);
    expect(rejection(start, 'r0c1>r0c2'), InvalidMoveReason.targetFrozen);
  });

  test('a move that completes nothing leaves the ice alone', () {
    final result = apply(start, 'r0c1>r1c3');
    expect(result.events, hasLength(2));
    expect(result.state.slot('r0c2'), open('blue3', 1));
    expect(result.state.slot('r1c0'), open('blue2 blue1', 2));
  });

  group('every completion lowers every counter by 1', () {
    final first = apply(start, 'r0c1>r0c0');

    test('1 → 0 shatters; 2 → 1 and 3 → 2 crack; slot order', () {
      expect(first.events.sublist(3), [
        const IceShattered(slotId: 'r0c2'),
        const IceCracked(slotId: 'r1c0', remaining: 1),
        const IceCracked(slotId: 'r1c1', remaining: 2),
      ]);
    });

    test('a shattered slot works normally', () {
      expect(first.state.slot('r0c2'), open('blue3'));
      expect(Rules.canPick(first.state, 'r0c2'), isTrue);
      // Still frozen: [blue3] can't reach [blue2, blue1] yet.
      expect(
        rejection(first.state, 'r0c2>r1c0'),
        InvalidMoveReason.targetFrozen,
      );
    });

    final second = apply(first.state, 'r1c2>r0c3');

    test('unlocks come before ice, and a case keeps its own counter', () {
      expect(second.events.sublist(2), [
        const Completed(
          slotId: 'r0c3',
          color: DollColor.green,
          setsCompleted: 2,
          totalSets: 3,
          leftEmptyTower: false,
        ),
        const Unlocked(slotId: 'r1c1', unlockColor: DollColor.green),
        const IceShattered(slotId: 'r1c0'),
        const IceCracked(slotId: 'r1c1', remaining: 1),
      ]);
      expect(second.state.slot('r1c1'), open(null, 1));
    });

    test('the last set shatters the last ice, then Won', () {
      final third = apply(second.state, 'r0c2>r1c0');
      expect(third.events.sublist(1), [
        NestedInto(
          fromId: 'r0c2',
          slotId: 'r1c0',
          direction: NestDirection.swallow,
          moving: nest('blue3'),
          target: nest('blue2 blue1'),
          merged: nest('blue3 blue2 blue1'),
        ),
        const Completed(
          slotId: 'r1c0',
          color: DollColor.blue,
          setsCompleted: 3,
          totalSets: 3,
          leftEmptyTower: false,
        ),
        const IceShattered(slotId: 'r1c1'),
        const Won(moveCount: 3),
      ]);
      for (final id in third.state.slotIds) {
        expect(third.state.slot(id).ice, 0, reason: id);
      }
    });
  });

  test('ice on a tower thaws the same way', () {
    final state = GameState.initial(
      board(3, [
        [
          open('red3 red2'),
          open('red1'),
          tower(['blue3', 'blue2'], ice: 1),
        ],
        [open('blue1'), open()],
      ]),
    );
    expect(rejection(state, 'r1c0>r0c2'), InvalidMoveReason.targetFrozen);
    final result = apply(state, 'r0c1>r0c0');
    expect(result.events.last, const IceShattered(slotId: 'r0c2'));
    expect(result.state.slot('r0c2'), tower(['blue3', 'blue2']));
    expect(apply(result.state, 'r1c0>r0c2').events[1], isA<NestedInto>());
  });

  group('counters the engine can store (LayoutLimits.maxIce)', () {
    Level withIce(int ice) => board(3, [
      [open('red3 red2'), open('red1', ice), open('blue3')],
      [open('blue2 blue1'), open()],
    ]);

    test('2^31 − 1 is stored exactly and stays frozen', () {
      final state = GameState.initial(withIce(LayoutLimits.maxIce));
      expect(state.slot('r0c1').ice, LayoutLimits.maxIce);
      expect(Rules.isInteractable(state, 'r0c1'), isFalse);
    });

    // A larger counter would wrap in the engine's 32-bit lists (2^31 to a
    // negative number, 2^32 to 0) and play as thawed: it is refused.
    for (final ice in [LayoutLimits.maxIce + 1, 4294967296, 4294967297]) {
      test('$ice is refused, never wrapped', () {
        expect(() => GameState.initial(withIce(ice)), throwsArgumentError);
      });
    }
  });
}
