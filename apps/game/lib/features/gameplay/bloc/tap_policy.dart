import 'package:nesty_core/nesty_core.dart';

/// What one board touch asks the gameplay bloc to do (design frame 2.6,
/// PROGRESS D22; docs/plans/m2-lottie-design.md §11).
///
/// The policy only picks *which* core call a touch becomes. Whether a move
/// is legal is decided by `GameSession.move` (`Rules.tryMove`), never here
/// (CLAUDE.md rule 2): a touch on any other slot while a nest is lifted is
/// an attempt, and core applies it (a legal target) or rejects it with its
/// reason (anything else, including a pickable nest of the wrong color or
/// size).
sealed class TouchAction {
  const TouchAction();
}

/// Lift the nest in [slotId].
final class SelectSlot extends TouchAction {
  const SelectSlot(this.slotId);

  final String slotId;

  @override
  bool operator ==(Object other) =>
      other is SelectSlot && other.slotId == slotId;

  @override
  int get hashCode => Object.hash(SelectSlot, slotId);

  @override
  String toString() => 'SelectSlot($slotId)';
}

/// Put the lifted nest in [slotId] back.
final class CancelSelection extends TouchAction {
  const CancelSelection(this.slotId);

  final String slotId;

  @override
  bool operator ==(Object other) =>
      other is CancelSelection && other.slotId == slotId;

  @override
  int get hashCode => Object.hash(CancelSelection, slotId);

  @override
  String toString() => 'CancelSelection($slotId)';
}

/// Try [move] through `GameSession.move`: applied or rejected by core.
final class AttemptMove extends TouchAction {
  const AttemptMove(this.move);

  final Move move;

  @override
  bool operator ==(Object other) => other is AttemptMove && other.move == move;

  @override
  int get hashCode => Object.hash(AttemptMove, move);

  @override
  String toString() => 'AttemptMove($move)';
}

/// Nothing happens.
final class IgnoreTouch extends TouchAction {
  const IgnoreTouch();

  @override
  bool operator ==(Object other) => other is IgnoreTouch;

  @override
  int get hashCode => (IgnoreTouch).hashCode;

  @override
  String toString() => 'IgnoreTouch()';
}

/// The tap and drag policy of design frame 2.6 (D22), which replaces spec
/// §2.2's "tapping a different pickable nest switches the selection".
abstract final class TapPolicy {
  /// A tap on [tapped] while [selected] is lifted (or nothing is):
  /// - nothing lifted and `Rules.canPick` → [SelectSlot];
  /// - nothing lifted and not pickable (empty, locked or iced) →
  ///   [IgnoreTouch];
  /// - the lifted slot → [CancelSelection];
  /// - any other slot → [AttemptMove]: a legal target moves, anything else
  ///   is invalid with core's reason.
  static TouchAction tap(
    GameState board, {
    required String? selected,
    required String tapped,
  }) {
    if (selected == null) {
      // TODO(design): frame 2.6 doesn't cover a tap on an unpickable slot
      // with nothing lifted; ignored until the owner decides (it could
      // shake the slot instead).
      return Rules.canPick(board, tapped)
          ? SelectSlot(tapped)
          : const IgnoreTouch();
    }
    if (tapped == selected) return CancelSelection(selected);
    return AttemptMove(Move(selected, tapped));
  }

  /// A drag that starts on [slotId] lifts it when it can be picked, whatever
  /// was lifted before (the drag is an explicit pick); otherwise the drag
  /// does nothing.
  static TouchAction dragStart(GameState board, String slotId) =>
      Rules.canPick(board, slotId) ? SelectSlot(slotId) : const IgnoreTouch();

  /// The drag of [dragged] was released over [dropped] (null: over no
  /// slot). A drop on nothing, or back on its own slot, cancels; a drop on
  /// any other slot is the same as a tap there (a move or invalid).
  static TouchAction drop({
    required String dragged,
    required String? dropped,
  }) => dropped == null || dropped == dragged
      ? CancelSelection(dragged)
      : AttemptMove(Move(dragged, dropped));
}
