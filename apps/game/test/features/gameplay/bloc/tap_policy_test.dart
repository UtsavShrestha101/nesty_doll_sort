import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_core/nesty_core.dart';
import 'package:nesty_game/features/gameplay/bloc/tap_policy.dart';

import 'support/bloc_fixtures.dart';

void main() {
  final board = GameState.initial(tutorialLevel);
  final iced = GameState.initial(icedLevel);

  group('tap (frame 2.6, D22)', () {
    test('with nothing lifted, a pickable nest is selected', () {
      expect(
        TapPolicy.tap(board, selected: null, tapped: red1),
        const SelectSlot(red1),
      );
    });

    test('with nothing lifted, an empty, iced or unknown slot is ignored', () {
      expect(
        TapPolicy.tap(board, selected: null, tapped: emptyTop),
        const IgnoreTouch(),
      );
      expect(
        TapPolicy.tap(iced, selected: null, tapped: red2),
        const IgnoreTouch(),
      );
      expect(
        TapPolicy.tap(board, selected: null, tapped: 'r9c9'),
        const IgnoreTouch(),
      );
    });

    test('the lifted slot cancels', () {
      expect(
        TapPolicy.tap(board, selected: red1, tapped: red1),
        const CancelSelection(red1),
      );
    });

    test('any other slot is a move attempt that core decides', () {
      // A legal target, an illegal pickable nest (no switching, D22) and an
      // empty slot all go to core.
      for (final target in [red2, red3, emptyTop]) {
        expect(
          TapPolicy.tap(board, selected: red1, tapped: target),
          AttemptMove(Move(red1, target)),
        );
      }
    });
  });

  group('drag', () {
    test('a drag start lifts a pickable nest and ignores anything else', () {
      expect(TapPolicy.dragStart(board, red3), const SelectSlot(red3));
      expect(TapPolicy.dragStart(board, emptyTop), const IgnoreTouch());
      expect(TapPolicy.dragStart(iced, red2), const IgnoreTouch());
    });

    test('a drop on nothing or on its own slot cancels', () {
      expect(
        TapPolicy.drop(dragged: red1, dropped: null),
        const CancelSelection(red1),
      );
      expect(
        TapPolicy.drop(dragged: red1, dropped: red1),
        const CancelSelection(red1),
      );
    });

    test('a drop on another slot is the same as a tap there', () {
      expect(
        TapPolicy.drop(dragged: red1, dropped: red3),
        const AttemptMove(Move(red1, red3)),
      );
    });
  });

  test('actions compare by value', () {
    expect(const SelectSlot(red1), isNot(const SelectSlot(red2)));
    expect(
      const CancelSelection(red1).hashCode,
      const CancelSelection(red1).hashCode,
    );
    expect(const IgnoreTouch(), const IgnoreTouch());
    expect(
      const AttemptMove(Move(red1, red2)),
      isNot(const AttemptMove(Move(red2, red1))),
    );
  });
}
