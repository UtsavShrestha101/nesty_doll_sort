import 'dart:typed_data';

import 'package:nesty_core/src/models/move_result.dart';
import 'package:nesty_core/src/rules/engine/board.dart';
import 'package:nesty_core/src/rules/engine/board_layout.dart';
import 'package:nesty_core/src/rules/engine/move_log.dart';
import 'package:nesty_core/src/rules/engine/nest_code.dart';

/// What `Kernel.check` and `Kernel.tryApply` return, as one int so the
/// kernel never allocates (docs/plans/m1-core-design.md §3).
///
/// A legal move is positive: its kind ([placed], [inside] or [swallow]) in
/// the low two bits, plus [completedBit] when it completes a set. A rejected
/// move is negative: `-(reason.index + 1)` for its [InvalidMoveReason], see
/// [reasonOf] and the `reject*` constants.
///
/// Internal to nesty_core (not exported by the barrel).
abstract final class MoveOutcome {
  /// Spec §2.2 rule 1: `M` moved into an empty open slot.
  static const int placed = 1;

  /// Spec §2.2 rule 2: `M` went inside `T`.
  static const int inside = 2;

  /// Spec §2.2 rule 3: `T` went inside `M` (the swallow).
  static const int swallow = 3;

  /// Masks [placed], [inside] or [swallow] out of an outcome.
  static const int kindMask = 3;

  /// Set when the merged nest is a full set and completes (spec §4).
  static const int completedBit = 4;

  // One constant per InvalidMoveReason, in its declaration order, so the hot
  // path compares ints instead of reading enum indexes. A test pins them.
  static const int rejectUnknownSlot = -1;
  static const int rejectSameSlot = -2;
  static const int rejectSourceEmpty = -3;
  static const int rejectSourceFrozen = -4;
  static const int rejectSourceLocked = -5;
  static const int rejectTargetFrozen = -6;
  static const int rejectTargetLocked = -7;
  static const int rejectColorMismatch = -8;
  static const int rejectSizeMismatch = -9;
  static const int rejectTargetOccupied = -10;

  /// True for a legal move.
  static bool isLegal(int outcome) => outcome > 0;

  /// [placed], [inside] or [swallow].
  static int kindOf(int outcome) => outcome & kindMask;

  /// True for [inside] and [swallow]: every merge lowers the nest count by 1
  /// (spec §6.3).
  static bool isMerge(int outcome) => (outcome & kindMask) >= inside;

  /// True when the move completes a set.
  static bool completes(int outcome) => (outcome & completedBit) != 0;

  /// The reason a rejected [outcome] names.
  static InvalidMoveReason reasonOf(int outcome) {
    if (outcome >= 0) {
      throw ArgumentError.value(outcome, 'outcome', 'Not a rejection');
    }
    return InvalidMoveReason.values[-outcome - 1];
  }

  /// The rejection outcome of [reason].
  static int rejectionOf(InvalidMoveReason reason) => -(reason.index + 1);
}

/// A legal move packed into one int by `Kernel.collectLegalMoves`:
/// `from << 8 | to << 3 | outcome`. Slot indexes are below 32 and the
/// outcome of a legal move below 8, so entries sort in (from, to) order.
///
/// Internal to nesty_core (not exported by the barrel).
abstract final class LegalMove {
  static int pack(int from, int to, int outcome) =>
      (from << 8) | (to << 3) | outcome;

  static int from(int entry) => entry >> 8;

  static int to(int entry) => (entry >> 3) & 0x1F;

  static int outcome(int entry) => entry & 0x7;
}

/// The rules of spec §4 over a [Board], written once for everyone: `Rules`,
/// `GameSession`, the solver, the simulator and the generator all call it
/// (CLAUDE.md rule 2, docs/plans/m1-core-design.md §0).
///
/// Slots are layout indexes. An index is "in play" when it is below
/// `board.activeSlotCount` (the reserved extra slots come into play as they
/// are added); anything else is an unknown slot.
///
/// Nothing here allocates: queries return ints and bools, moves mutate the
/// board in place, and the legal-move routines write into caller buffers or
/// call back per move (CLAUDE.md rule 8).
///
/// Internal to nesty_core (not exported by the barrel).
abstract final class Kernel {
  /// True when [slot] is in play on [board].
  static bool isActive(Board board, int slot) =>
      slot >= 0 && slot < board.activeSlotCount;

  /// The current ice counter of [slot] (spec §3.4): its starting ice minus
  /// every set completed since, never below 0.
  static int iceOf(Board board, int slot) {
    final ice = board.layout.initialIce[slot] - board.completedSets;
    return ice > 0 ? ice : 0;
  }

  /// True while [slot] is a glass case that hasn't broken (spec §3.3).
  static bool isLocked(Board board, int slot) =>
      board.layout.kind[slot] == BoardLayout.kindLocked &&
      ((board.openedMask >> slot) & 1) == 0;

  /// True while [slot] is a tower that still holds nests (spec §3.2).
  static bool isTower(Board board, int slot) =>
      board.layout.kind[slot] == BoardLayout.kindTower &&
      ((board.openedMask >> slot) & 1) == 0;

  /// True when [slot] behaves as an open slot: an open or extra slot, an
  /// emptied tower or a broken case (spec §3.1–§3.3).
  static bool isOpenLike(Board board, int slot) =>
      board.layout.kind[slot] == BoardLayout.kindOpen ||
      ((board.openedMask >> slot) & 1) == 1;

  /// Spec §4 `interactable(slot)`: in play, not iced, and not a glass case
  /// that is still locked.
  static bool isInteractable(Board board, int slot) =>
      isActive(board, slot) &&
      iceOf(board, slot) == 0 &&
      !isLocked(board, slot);

  /// The cell index of [slot]'s top nest (spec §4 `top(slot)`), or -1 when
  /// the slot is empty. Towers are bottom to top with no gaps, so the top is
  /// the highest non-empty cell; every other slot has its nest in its first
  /// cell.
  static int topCell(Board board, int slot) {
    final layout = board.layout;
    final cells = board.cells;
    final start = layout.cellOffset[slot];
    for (var cell = start + layout.capacity[slot] - 1; cell >= start; cell--) {
      if (cells[cell] != NestCode.empty) return cell;
    }
    return -1;
  }

  /// The code of [slot]'s top nest, or [NestCode.empty].
  static int top(Board board, int slot) {
    final cell = topCell(board, slot);
    return cell < 0 ? NestCode.empty : board.cells[cell];
  }

  /// Nests in [slot] (a tower's depth; 0 or 1 for any other slot).
  static int height(Board board, int slot) {
    final cell = topCell(board, slot);
    return cell < 0 ? 0 : cell + 1 - board.layout.cellOffset[slot];
  }

  /// Spec §4 `canPick(s) = interactable(s) && top(s) != null`.
  static bool canPick(Board board, int slot) =>
      isInteractable(board, slot) && top(board, slot) != NestCode.empty;

  /// Nests on the board, for the solver's `h = nestsOnBoard − setsRemaining`
  /// (spec §6.3).
  static int nestCount(Board board) {
    final cells = board.cells;
    var count = 0;
    for (var i = 0; i < cells.length; i++) {
      if (cells[i] != NestCode.empty) count++;
    }
    return count;
  }

  /// Spec §2.3: every set is complete.
  static bool isWon(Board board) =>
      board.completedSets == board.layout.totalSets;

  /// Spec §2.3, design A22: not won, and no legal move exists.
  static bool isOutOfMoves(Board board) =>
      !isWon(board) && !hasLegalMove(board);

  /// Spec §4 `tryMove(src, dst)` without applying it: the [MoveOutcome] the
  /// move would have. Rejections follow the §4 order (the precedence
  /// documented on [InvalidMoveReason]).
  static int check(Board board, int from, int to) {
    if (!isActive(board, from) || !isActive(board, to)) {
      return MoveOutcome.rejectUnknownSlot;
    }
    // Spec §4 `require src != dst`.
    if (from == to) return MoveOutcome.rejectSameSlot;
    // Spec §4 `canPick(src)`: `interactable` first, then `top != null`.
    if (iceOf(board, from) > 0) return MoveOutcome.rejectSourceFrozen;
    if (isLocked(board, from)) return MoveOutcome.rejectSourceLocked;
    final moving = top(board, from);
    if (moving == NestCode.empty) return MoveOutcome.rejectSourceEmpty;
    return _dropOutcome(board, moving, to);
  }

  /// Applies the move [from] → [to] (spec §4 `tryMove`) when it is legal and
  /// returns its [MoveOutcome]. A rejected move leaves [board] and [log]
  /// untouched. With a [log], records what happened for `EventBuilder`.
  ///
  /// Steps, as in spec §4: place `M` or replace `top(dst)` with the merged
  /// nest; remove `M` from the source (a tower pops, and an emptied tower
  /// becomes open); if the merged nest is full: remove it and count it, the
  /// destination tower reveals its next nest or becomes open, every case of
  /// that color that is still locked breaks, and all ice drops by 1 (it is
  /// derived from the count); then `moveCount++`. At most one set completes
  /// per move, since only the merged nest can be full.
  static int tryApply(Board board, int from, int to, [MoveLog? log]) {
    final outcome = check(board, from, to);
    if (outcome < 0) return outcome;
    _apply(board, from, to, outcome, log);
    return outcome;
  }

  /// [tryApply] for a move already known to be legal on [board]: [outcome]
  /// must be what [check] returns for it, such as the outcome of a
  /// [collectLegalMoves] entry of this board or of an identical copy. It
  /// skips re-running the §4 checks, which the solver's inner loop would
  /// otherwise repeat for every successor. Everything else uses [tryApply].
  static void applyLegal(Board board, int from, int to, int outcome) =>
      _apply(board, from, to, outcome, null);

  static void _apply(Board board, int from, int to, int outcome, MoveLog? log) {
    final layout = board.layout;
    final cells = board.cells;

    final sourceCell = topCell(board, from);
    final moving = cells[sourceCell];
    final sourceWasTower = isTower(board, from);
    final targetCell = topCell(board, to);
    final kind = outcome & MoveOutcome.kindMask;

    // Spec §4: place M, or replace top(dst) with the merged nest.
    final int landingCell;
    final int target;
    final int merged;
    if (kind == MoveOutcome.placed) {
      landingCell = layout.cellOffset[to];
      target = NestCode.empty;
      merged = moving;
    } else {
      landingCell = targetCell;
      target = cells[targetCell];
      // Spec §2.2: inside puts M in T; the swallow puts T in M.
      merged = kind == MoveOutcome.inside
          ? NestCode.merge(target, moving)
          : NestCode.merge(moving, target);
    }
    cells[landingCell] = merged;

    // Spec §4: remove M from src; a tower pops its top (§3.2).
    cells[sourceCell] = NestCode.empty;
    var sourceEmptied = false;
    var sourceRevealed = NestCode.empty;
    var sourceHiddenBelow = 0;
    if (sourceWasTower) {
      final below = sourceCell - layout.cellOffset[from];
      if (below == 0) {
        // Spec §3.2: an empty tower becomes a normal open slot.
        board.openedMask |= 1 << from;
        sourceEmptied = true;
      } else {
        sourceRevealed = cells[sourceCell - 1];
        sourceHiddenBelow = below - 1;
      }
    }

    var completedColor = -1;
    var destEmptied = false;
    var destRevealed = NestCode.empty;
    var destHiddenBelow = 0;
    var unlocked = 0;
    if ((outcome & MoveOutcome.completedBit) != 0) {
      // Spec §4: the full set leaves the board and counts.
      cells[landingCell] = NestCode.empty;
      board.completedSets++;
      completedColor = NestCode.color(merged);
      if (isTower(board, to)) {
        final below = landingCell - layout.cellOffset[to];
        if (below == 0) {
          board.openedMask |= 1 << to;
          destEmptied = true;
        } else {
          destRevealed = cells[landingCell - 1];
          destHiddenBelow = below - 1;
        }
      }
      // Spec §3.3: the first full set of a color breaks its cases. Later
      // sets find them open already. `x & ~y` written as `x ^ (x & y)`,
      // which is web-safe (design §3).
      final cases = layout.lockedByColor[completedColor];
      unlocked = cases ^ (cases & board.openedMask);
      board.openedMask |= unlocked;
      // Spec §3.4: every ice counter drops by 1. Ice is derived from
      // completedSets, so the increment above already did it.
    }
    board.moveCount++;

    if (log != null) {
      log
        ..from = from
        ..to = to
        ..outcome = outcome
        ..moving = moving
        ..target = target
        ..merged = merged
        ..sourceWasTower = sourceWasTower
        ..sourceEmptied = sourceEmptied
        ..sourceRevealed = sourceRevealed
        ..sourceHiddenBelow = sourceHiddenBelow
        ..completedColor = completedColor
        ..destEmptied = destEmptied
        ..destRevealed = destRevealed
        ..destHiddenBelow = destHiddenBelow
        ..unlockedMask = unlocked;
    }
  }

  /// A buffer size that fits every legal move of any board of [layout].
  static int legalMoveCapacity(BoardLayout layout) =>
      layout.slotCount * (layout.slotCount - 1);

  /// Writes every legal move of [board] into [out] as [LegalMove] entries,
  /// ordered by source and then target index (the `GameState.slotIds`
  /// order), and returns how many. [out] needs [legalMoveCapacity] ints.
  static int collectLegalMoves(Board board, Int32List out) {
    final tops = _loadTargets(board);
    final active = board.activeSlotCount;
    final maxSize = board.layout.maxSize;
    var count = 0;
    for (var from = 0; from < active; from++) {
      final moving = tops[from];
      if (moving <= 0) continue;
      for (var to = 0; to < active; to++) {
        if (to == from) continue;
        final target = tops[to];
        if (target < 0) continue;
        final outcome = target == NestCode.empty
            ? MoveOutcome.placed
            : _mergeOutcome(target, moving, maxSize);
        if (outcome > 0) out[count++] = LegalMove.pack(from, to, outcome);
      }
    }
    return count;
  }

  /// Calls [visit] for every legal move of [board], in the order of
  /// [collectLegalMoves]. [visit] must not change [board]; it may read it
  /// and run the kernel on other boards.
  static void forEachLegalMove(
    Board board,
    void Function(int from, int to, int outcome) visit,
  ) {
    final active = board.activeSlotCount;
    for (var from = 0; from < active; from++) {
      if (!canPick(board, from)) continue;
      final moving = top(board, from);
      for (var to = 0; to < active; to++) {
        if (to == from) continue;
        final outcome = _dropOutcome(board, moving, to);
        if (outcome > 0) visit(from, to, outcome);
      }
    }
  }

  /// True when [board] has at least one legal move (spec §2.3).
  static bool hasLegalMove(Board board) {
    final tops = _loadTargets(board);
    final active = board.activeSlotCount;
    final maxSize = board.layout.maxSize;
    for (var from = 0; from < active; from++) {
      final moving = tops[from];
      if (moving <= 0) continue;
      for (var to = 0; to < active; to++) {
        if (to == from) continue;
        final target = tops[to];
        if (target == NestCode.empty) return true;
        if (target > 0 && _mergeOutcome(target, moving, maxSize) > 0) {
          return true;
        }
      }
    }
    return false;
  }

  /// Fills the layout's scratch with, per slot in play: -1 when it can be
  /// neither picked from nor dropped on, [NestCode.empty] for an empty slot
  /// that accepts a placement, else its top nest.
  static Int32List _loadTargets(Board board) {
    final tops = board.layout.tops;
    final active = board.activeSlotCount;
    for (var slot = 0; slot < active; slot++) {
      if (iceOf(board, slot) > 0 || isLocked(board, slot)) {
        tops[slot] = -1;
      } else {
        final nest = top(board, slot);
        tops[slot] = nest == NestCode.empty && !isOpenLike(board, slot)
            ? -1
            : nest;
      }
    }
    return tops;
  }

  /// The outcome of dropping [moving] on [to], once the source passed.
  static int _dropOutcome(Board board, int moving, int to) {
    // Spec §4 `interactable(dst)`.
    if (iceOf(board, to) > 0) return MoveOutcome.rejectTargetFrozen;
    if (isLocked(board, to)) return MoveOutcome.rejectTargetLocked;
    final target = top(board, to);
    if (target == NestCode.empty) {
      // Spec §4: an empty open slot (or broken case, or emptied tower)
      // takes the nest; §3.2: a tower never takes a placement, and it is
      // never empty while it is a tower, so this `else invalid` branch is
      // unreachable in play.
      return isOpenLike(board, to)
          ? MoveOutcome.placed
          : MoveOutcome.rejectTargetOccupied;
    }
    return _mergeOutcome(target, moving, board.layout.maxSize);
  }

  /// Spec §4's merge test of `M` = [moving] against `T` = [target].
  static int _mergeOutcome(int target, int moving, int maxSize) {
    if (!NestCode.colorsMatch(target, moving)) {
      return MoveOutcome.rejectColorMismatch;
    }
    final movingOuter = NestCode.outer(moving);
    final movingInner = NestCode.inner(moving);
    final targetOuter = NestCode.outer(target);
    final targetInner = NestCode.inner(target);
    // Spec §2.2 rule 2: `M.outer.size == T.inner.size − 1`, M goes inside
    // T; the merged nest runs T.outer..M.inner.
    if (movingOuter == targetInner - 1) {
      return targetOuter == maxSize && movingInner == 1
          ? MoveOutcome.inside | MoveOutcome.completedBit
          : MoveOutcome.inside;
    }
    // Spec §2.2 rule 3: `T.outer.size == M.inner.size − 1`, T goes inside M
    // (the swallow); the merged nest runs M.outer..T.inner.
    if (targetOuter == movingInner - 1) {
      return movingOuter == maxSize && targetInner == 1
          ? MoveOutcome.swallow | MoveOutcome.completedBit
          : MoveOutcome.swallow;
    }
    return MoveOutcome.rejectSizeMismatch;
  }
}
