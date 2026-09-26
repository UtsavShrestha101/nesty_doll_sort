import 'package:nesty_core/src/rules/engine/nest_code.dart';

/// What one `Kernel.tryApply` did, recorded as plain ints so the kernel
/// stays allocation-free (docs/plans/m1-core-design.md §3). `EventBuilder`
/// turns it into the `MoveEvent`s the game animates; the solver and the
/// simulator pass no log at all.
///
/// Slot fields are slot indexes of the board's layout; nest fields are
/// [NestCode]s. A log is reusable: `tryApply` clears it first.
///
/// Internal to nesty_core (not exported by the barrel).
final class MoveLog {
  /// The source slot.
  int from = -1;

  /// The target slot.
  int to = -1;

  /// The `MoveOutcome` the kernel returned.
  int outcome = 0;

  /// The moving nest `M` (spec §4).
  int moving = NestCode.empty;

  /// The target's top nest `T` before the move, or empty for a placement.
  int target = NestCode.empty;

  /// What landed in the target: `M` for a placement, else the merged nest.
  int merged = NestCode.empty;

  /// True when the source was a tower holding nests (spec §3.2).
  bool sourceWasTower = false;

  /// True when the pick emptied that tower, which is now an open slot.
  bool sourceEmptied = false;

  /// The source tower's new top, or empty when none appeared.
  int sourceRevealed = NestCode.empty;

  /// Nests still hidden under [sourceRevealed].
  int sourceHiddenBelow = 0;

  /// The completed set's `DollColor.index`, or -1 when nothing completed.
  int completedColor = -1;

  /// True when the completion emptied the destination tower (spec §3.2).
  bool destEmptied = false;

  /// The destination tower's new top after the completion, or empty.
  int destRevealed = NestCode.empty;

  /// Nests still hidden under [destRevealed].
  int destHiddenBelow = 0;

  /// Glass cases the completion broke, as a slot mask (spec §3.3).
  int unlockedMask = 0;

  /// True when the move completed a set (spec §4).
  bool get completed => completedColor >= 0;

  /// Forgets the previous move.
  void clear() {
    from = -1;
    to = -1;
    outcome = 0;
    moving = NestCode.empty;
    target = NestCode.empty;
    merged = NestCode.empty;
    sourceWasTower = false;
    sourceEmptied = false;
    sourceRevealed = NestCode.empty;
    sourceHiddenBelow = 0;
    completedColor = -1;
    destEmptied = false;
    destRevealed = NestCode.empty;
    destHiddenBelow = 0;
    unlockedMask = 0;
  }
}
