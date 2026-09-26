import 'package:nesty_core/src/models/doll_color.dart';
import 'package:nesty_core/src/models/move_event.dart';
import 'package:nesty_core/src/rules/engine/board.dart';
import 'package:nesty_core/src/rules/engine/kernel.dart';
import 'package:nesty_core/src/rules/engine/move_log.dart';
import 'package:nesty_core/src/rules/engine/nest_code.dart';

/// Turns a kernel [MoveLog] into the `MoveEvent`s the game animates, in the
/// order of docs/plans/m1-core-design.md §3 (owner override A2):
///
/// 1. `Picked`; 2. `Placed` or `NestedInto`; 3. the source tower's
/// `Revealed`; 4. `Completed`; 5. the destination tower's `Revealed`;
/// 6. `Unlocked` per broken case, slot order; 7. `IceCracked` or
/// `IceShattered` per iced slot, slot order; 8. `Won` or `OutOfMoves`.
///
/// Only the facade builds events: the solver and the simulator apply moves
/// without a log, so the search never allocates them.
///
/// Internal to nesty_core (not exported by the barrel).
abstract final class EventBuilder {
  /// The events of the move [log] recorded; [after] is the board it left.
  static List<MoveEvent> build(Board after, MoveLog log) {
    final layout = after.layout;
    final ids = layout.ids;
    final from = ids[log.from];
    final to = ids[log.to];
    final moving = NestCode.toNest(log.moving);
    final kind = MoveOutcome.kindOf(log.outcome);
    final events = <MoveEvent>[
      Picked(
        slotId: from,
        nest: moving,
        fromTower: log.sourceWasTower,
        leftEmptyTower: log.sourceEmptied,
      ),
      if (kind == MoveOutcome.placed)
        Placed(fromId: from, slotId: to, nest: moving)
      else
        NestedInto(
          fromId: from,
          slotId: to,
          direction: kind == MoveOutcome.inside
              ? NestDirection.inside
              : NestDirection.swallow,
          moving: moving,
          target: NestCode.toNest(log.target),
          merged: NestCode.toNest(log.merged),
        ),
      if (log.sourceRevealed != NestCode.empty)
        Revealed(
          slotId: from,
          nest: NestCode.toNest(log.sourceRevealed),
          hiddenBelow: log.sourceHiddenBelow,
        ),
    ];
    if (log.completed) {
      events.add(
        Completed(
          slotId: to,
          color: DollColor.values[log.completedColor],
          setsCompleted: after.completedSets,
          totalSets: layout.totalSets,
          leftEmptyTower: log.destEmptied,
        ),
      );
      // Design A2: the set leaves before the nest under it shows.
      if (log.destRevealed != NestCode.empty) {
        events.add(
          Revealed(
            slotId: to,
            nest: NestCode.toNest(log.destRevealed),
            hiddenBelow: log.destHiddenBelow,
          ),
        );
      }
      final active = after.activeSlotCount;
      // Spec §3.3: every case of the completed color broke, in slot order.
      for (var slot = 0; slot < active; slot++) {
        if (((log.unlockedMask >> slot) & 1) == 1) {
          events.add(
            Unlocked(
              slotId: ids[slot],
              unlockColor: DollColor.values[layout.unlockColor[slot]],
            ),
          );
        }
      }
      // Spec §3.4: every iced slot dropped by 1, in slot order; a drop to 0
      // shatters without cracking first (design A9).
      for (var slot = 0; slot < active; slot++) {
        final remaining = layout.initialIce[slot] - after.completedSets;
        if (remaining > 0) {
          events.add(IceCracked(slotId: ids[slot], remaining: remaining));
        } else if (remaining == 0) {
          events.add(IceShattered(slotId: ids[slot]));
        }
      }
    }
    // Spec §2.3, design A22.
    if (Kernel.isWon(after)) {
      events.add(Won(moveCount: after.moveCount));
    } else if (!Kernel.hasLegalMove(after)) {
      events.add(const OutOfMoves());
    }
    return events;
  }
}
