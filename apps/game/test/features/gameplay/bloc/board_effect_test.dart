import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_core/nesty_core.dart';
import 'package:nesty_game/features/gameplay/bloc/board_effect.dart';

import '../../../helpers/level_fixtures.dart';

void main() {
  final level = levelFrom(tutorialLevelJson);
  final start = GameState.initial(level);

  test('effects compare by value, so bloc tests can expect them', () {
    expect(
      const SelectionChangedEffect(selected: 'r0c2'),
      const SelectionChangedEffect(selected: 'r0c2'),
    );
    expect(
      const SelectionChangedEffect(previous: 'r0c2', byDrag: true),
      isNot(const SelectionChangedEffect(previous: 'r0c2')),
    );
    expect(
      const MoveRejectedEffect(
        source: 'r0c2',
        target: 'r1c1',
        reason: InvalidMoveReason.sizeMismatch,
      ),
      const MoveRejectedEffect(
        source: 'r0c2',
        target: 'r1c1',
        reason: InvalidMoveReason.sizeMismatch,
      ),
    );
    expect(
      BoardResetEffect(snapshot: start, reason: BoardResetReason.start),
      BoardResetEffect(snapshot: start, reason: BoardResetReason.start),
    );
    expect(
      const HintShownEffect(Move('r1c1', 'r0c2')),
      const HintShownEffect(Move('r1c1', 'r0c2')),
    );
    expect(const HintClearedEffect(), const HintClearedEffect());
  });

  test('wrap nesty_core\'s results without clashing with their names', () {
    final session = GameSession(level);
    final applied = session.move('r1c1', 'r0c2');
    expect(applied, isA<MoveApplied>());
    final effect = MoveAppliedEffect(result: applied as MoveApplied);
    expect(effect, MoveAppliedEffect(result: applied));
    expect(effect.result.events.first, isA<Picked>());

    final added = session.addExtraSlot()!;
    expect(ExtraSlotAddedEffect(added).result.slotId, 'x0');
  });

  test('every effect kind is handled by an exhaustive switch', () {
    String kind(BoardEffect effect) => switch (effect) {
      SelectionChangedEffect() => 'selection',
      MoveAppliedEffect() => 'move',
      MoveRejectedEffect() => 'rejected',
      BoardResetEffect() => 'reset',
      HintShownEffect() => 'hint',
      HintClearedEffect() => 'hintCleared',
      ExtraSlotAddedEffect() => 'extraSlot',
    };
    expect(kind(const HintClearedEffect()), 'hintCleared');
  });
}
