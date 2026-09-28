import 'dart:typed_data';

import 'package:nesty_core/src/models/doll_color.dart';
import 'package:nesty_core/src/rules/engine/board.dart';
import 'package:nesty_core/src/rules/engine/board_layout.dart';
import 'package:nesty_core/src/rules/engine/kernel.dart';
import 'package:nesty_core/src/rules/engine/nest_code.dart';

/// Why a board failed a [BoardCheck]: an English [message] for logs, and
/// the [slot] index it is about, or -1 for the whole board.
///
/// Internal to nesty_core (not exported by the barrel).
final class BoardProblem {
  const BoardProblem(this.message, [this.slot = -1]);

  final String message;

  /// The layout index of the slot, or -1.
  final int slot;

  @override
  String toString() => message;
}

/// Checks for a [Board] that was read from outside the engine, before the
/// rules run on it: a solver snapshot (`SolverSnapshot.decode`) or a saved
/// session (`GameSessionCodec.decode`). One implementation, so the two
/// readers can't drift apart (docs/plans/m3-design.md §4).
///
/// Internal to nesty_core (not exported by the barrel).
abstract final class BoardCheck {
  /// The first broken kernel invariant of [board], or null when the kernel
  /// can run on it (docs/plans/m1-core-design.md §2): the slots' cells and
  /// the opened mask ([_slots]), then the dolls that left ([_sets]).
  static BoardProblem? kernel(Board board) => _slots(board) ?? _sets(board);

  /// The first reason play of the level could never have left [board], or
  /// null. For a board that passed [kernel] and holds no golden doll (gold
  /// is v1.1, spec §3.5).
  ///
  /// These follow from the rules alone:
  /// - Spec §3.3: a glass case breaks the moment the first full set of its
  ///   `unlockColor` completes, and never otherwise, so a case is opened
  ///   exactly when a set of its color is gone.
  /// - Spec §3.3, §3.4: nothing is picked from or dropped onto a case that
  ///   is still locked or a slot that is still iced. Ice only ever drops
  ///   (it is the starting ice minus the completed sets), so such a slot
  ///   still holds its starting nests, and an iced tower was never emptied.
  /// - Spec §3.2: a tower loses nests from the top only and only its top is
  ///   merged into, so while it stands, the nests under its top are the
  ///   starting ones and its top holds at least the starting nest at that
  ///   height.
  static BoardProblem? reachable(Board board) {
    final layout = board.layout;
    final cells = board.cells;
    final initial = layout.initialCells;
    final remaining = Int32List(DollColor.values.length);
    for (final code in cells) {
      if (code != NestCode.empty) {
        remaining[NestCode.color(code)] += NestCode.ownColorDolls(code);
      }
    }
    for (var slot = 0; slot < layout.gridSlotCount; slot++) {
      final id = layout.ids[slot];
      final kind = layout.kind[slot];
      final opened = ((board.openedMask >> slot) & 1) == 1;
      final start = layout.cellOffset[slot];
      final end = start + layout.capacity[slot];
      if (kind == BoardLayout.kindLocked) {
        final color = layout.unlockColor[slot];
        final colorId = DollColor.values[color].id;
        final completed = remaining[color] < layout.initialDolls[color];
        if (opened && !completed) {
          return BoardProblem(
            'The case $id is broken, but no $colorId set is complete',
            slot,
          );
        }
        if (!opened && completed) {
          return BoardProblem(
            'A $colorId set is complete, but the case $id is still locked',
            slot,
          );
        }
      }
      if (Kernel.iceOf(board, slot) > 0 || Kernel.isLocked(board, slot)) {
        if (kind == BoardLayout.kindTower && opened) {
          return BoardProblem('The iced tower $id was emptied', slot);
        }
        for (var cell = start; cell < end; cell++) {
          if (cells[cell] != initial[cell]) {
            return BoardProblem(
              '$id is iced or locked, but its nests changed',
              slot,
            );
          }
        }
      } else if (kind == BoardLayout.kindTower && !opened) {
        // kernel() guarantees a standing tower holds at least one nest.
        final top = Kernel.topCell(board, slot);
        for (var cell = start; cell < top; cell++) {
          if (cells[cell] != initial[cell]) {
            return BoardProblem(
              'The nests under the top of the tower $id changed',
              slot,
            );
          }
        }
        if (!_holds(cells[top], initial[top])) {
          return BoardProblem(
            'The top of the tower $id lost dolls of its starting nest',
            slot,
          );
        }
      }
    }
    return null;
  }

  /// True when the nest [code] holds every doll of the nest [part].
  static bool _holds(int code, int part) =>
      NestCode.color(code) == NestCode.color(part) &&
      NestCode.outer(code) >= NestCode.outer(part) &&
      NestCode.inner(code) <= NestCode.inner(part);

  /// The kernel's slot invariants (design §2): only towers and cases open;
  /// a tower still in play holds a gapless stack; everything else uses its
  /// first cell only; extra slots not added yet are empty.
  static BoardProblem? _slots(Board board) {
    final layout = board.layout;
    final opened = board.openedMask;
    for (var slot = 0; slot < layout.slotCount; slot++) {
      final id = layout.ids[slot];
      final isOpened = ((opened >> slot) & 1) == 1;
      final kind = layout.kind[slot];
      final start = layout.cellOffset[slot];
      final end = start + layout.capacity[slot];
      if (isOpened && kind == BoardLayout.kindOpen) {
        return BoardProblem('The opened mask marks the open slot $id', slot);
      }
      var used = start + 1;
      if (kind == BoardLayout.kindTower && !isOpened) {
        used = start;
        while (used < end && board.cells[used] != NestCode.empty) {
          used++;
        }
        if (used == start) {
          return BoardProblem('The tower $id is empty but not opened', slot);
        }
      }
      for (var cell = used; cell < end; cell++) {
        if (board.cells[cell] != NestCode.empty) {
          return BoardProblem('$id has a nest in an unused cell', slot);
        }
      }
      if (slot >= board.activeSlotCount &&
          board.cells[start] != NestCode.empty) {
        return BoardProblem(
          'The extra slot $id is not in play but holds a nest',
          slot,
        );
      }
    }
    if (opened >= (1 << layout.slotCount)) {
      return const BoardProblem('The opened mask has bits past the last slot');
    }
    return null;
  }

  /// Only full sets ever leave the board (spec §4), so compared with the
  /// level's start every color has lost the same number `d` of dolls of
  /// each size 1..maxSize and none larger, and the `d`s add up to
  /// `completedSets`. A board whose cells contradict its `completedSets`
  /// would give the search a negative heuristic (`h = nests − setsRemaining`).
  /// A golden doll counts toward whatever set it joins (spec §3.5, v1.1),
  /// so a board with gold is only held to `h ≥ 0`.
  static BoardProblem? _sets(Board board) {
    final layout = board.layout;
    final remaining = layout.totalSets - board.completedSets;
    var nests = 0;
    for (final code in board.cells) {
      if (code != NestCode.empty) nests++;
    }
    if (nests < remaining) {
      return BoardProblem('$nests nests cannot hold the $remaining sets left');
    }
    final lost = Int32List(DollColor.values.length * _sizes);
    final gold =
        _countDolls(layout.initialCells, lost, 1) ||
        _countDolls(board.cells, lost, -1);
    if (gold) return null;
    final maxSize = layout.maxSize;
    var sets = 0;
    for (var color = 0; color < DollColor.values.length; color++) {
      final row = color * _sizes;
      final sets0 = lost[row + 1];
      for (var size = 1; size < _sizes; size++) {
        final expected = size <= maxSize ? sets0 : 0;
        if (lost[row + size] != expected || sets0 < 0) {
          return BoardProblem(
            'The ${DollColor.values[color].id} dolls that left the board are '
            'not whole sets',
          );
        }
      }
      sets += sets0;
    }
    if (sets != board.completedSets) {
      return BoardProblem(
        'The cells lost $sets sets, but completedSets is '
        '${board.completedSets}',
      );
    }
    return null;
  }

  // Doll sizes 1..6, indexed directly.
  static const int _sizes = 7;

  /// Adds [sign] per doll of [cells] to [counts] (color × size). Returns
  /// true when a cell holds a golden doll or the wild color.
  static bool _countDolls(List<int> cells, Int32List counts, int sign) {
    var gold = false;
    for (final code in cells) {
      if (code == NestCode.empty) continue;
      final color = NestCode.color(code);
      if (NestCode.gold(code) != 0 || NestCode.isWildColor(color)) {
        gold = true;
        continue;
      }
      final row = color * _sizes;
      for (
        var size = NestCode.inner(code);
        size <= NestCode.outer(code);
        size++
      ) {
        counts[row + size] += sign;
      }
    }
    return gold;
  }
}
