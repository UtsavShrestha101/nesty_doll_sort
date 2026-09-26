import 'dart:typed_data';

import 'package:nesty_core/src/rules/engine/board.dart';
import 'package:nesty_core/src/rules/engine/board_layout.dart';
import 'package:nesty_core/src/rules/engine/nest_code.dart';
import 'package:nesty_core/src/util/hash64.dart';

/// The canonical form of a board (spec §6.2): boards that differ only by how
/// their interchangeable open slots are ordered get the same form, so the
/// solver stores such boards once.
///
/// Spec §3.1: every open slot follows the same rules. A *free* slot is one
/// that behaves exactly like a plain open slot from now on: in play, open
/// like (an open or extra slot, an emptied tower, a broken case) and not
/// iced. Free slots only ever become more numerous (towers never refill,
/// cases never re-lock, ice never grows), so permuting their contents gives
/// boards with the same futures. Every other slot keeps its identity (spec
/// §6.2: towers, still-locked cases and iced slots).
///
/// [canonicalize] rewrites a board in place into its class's one
/// representative: the free slots' nest codes sorted ascending along slot
/// index order (empty slots first), everything else untouched. A free slot
/// holds at most one nest, in its first cell (an emptied tower reuses only
/// that cell, design §2), so this moves codes between first cells only and
/// the result is a board the kernel plays exactly like the original.
///
/// The canonical key of a canonical board is then its header and cells, as
/// u32 words ([writeKey]):
/// 1. `completedSets` (every slot's ice follows from it, spec §3.4);
/// 2. `openedMask` (with word 1 it fixes which slots are free);
/// 3. every cell in layout order, packed low field first: three 10-bit
///    codes per word when the level has no golden doll (every code is then
///    below 2^10), else two 16-bit codes (a nest holding gold uses bits
///    10–12, spec §3.5).
///
/// This is design §3's key (the free slots' codes sorted, then the fixed
/// slots in index order), laid out by slot instead of free slots first, so
/// that two canonical boards have equal keys exactly when their cells and
/// headers are equal. The key is also a complete, compact copy of the
/// board ([unpack] restores it), so the solver stores keys as its nodes and
/// confirms a visited-table hit by comparing words. [hash] is
/// `Hash64.ofU32s` of the key words (spec §6.2: a 64-bit hash of the
/// canonical form).
///
/// Internal to nesty_core. One instance per search: it keeps scratch space.
final class CanonicalBoard {
  /// A canonicalizer for boards of [layout] with [extraCount] extra slots in
  /// play; both stay fixed for a whole search, since the solver never adds
  /// an extra slot.
  CanonicalBoard(this.layout, int extraCount)
    : activeSlots = layout.gridSlotCount + extraCount,
      triples = !_hasGold(layout),
      _freeOffsets = Int32List(layout.slotCount),
      _thawedBy = _thawTable(layout, layout.gridSlotCount + extraCount),
      _openKinds = _openKindMask(layout, layout.gridSlotCount + extraCount);

  /// Header words before the packed cells.
  static const int headerWords = 2;

  final BoardLayout layout;

  /// Slots in play during the search.
  final int activeSlots;

  /// True when cells pack three per key word: the level has no golden doll,
  /// so no nest code reaches 2^10 (spec §3.5).
  final bool triples;

  /// The high half of the last [hash].
  int hashHi = 0;

  /// The low half of the last [hash].
  int hashLo = 0;

  // The first cell of each free slot, in slot order, for the last free mask
  // seen: it changes only when a tower empties, a case breaks or ice thaws.
  final Int32List _freeOffsets;
  int _freeCount = 0;
  int _freeMaskCached = -1;

  // _thawedBy[c]: the slots in play whose ice is 0 once c sets completed.
  // The last entry covers every larger c.
  final Int32List _thawedBy;

  // Slots in play whose kind is open (extra slots included).
  final int _openKinds;

  /// Key words of every board of this layout ([writeKey] always writes
  /// this many).
  int get keyWords =>
      headerWords +
      (triples ? (layout.cellCount + 2) ~/ 3 : (layout.cellCount + 1) ~/ 2);

  /// The slots of a board that are free (see the class doc), from its
  /// [completedSets] and [openedMask].
  int freeMask(int completedSets, int openedMask) {
    final thawed = completedSets < _thawedBy.length
        ? _thawedBy[completedSets]
        : _thawedBy[_thawedBy.length - 1];
    return thawed & (_openKinds | openedMask);
  }

  /// Rewrites [board] into its canonical form (see the class doc).
  /// Allocation-free, and nearly linear after a move, which changes at most
  /// two free cells of an already canonical board.
  void canonicalize(Board board) {
    final free = freeMask(board.completedSets, board.openedMask);
    if (free != _freeMaskCached) _cacheFreeOffsets(free);
    final offsets = _freeOffsets;
    final count = _freeCount;
    final cells = board.cells;
    // Insertion sort through the offsets.
    for (var i = 1; i < count; i++) {
      final code = cells[offsets[i]];
      var j = i;
      while (j > 0) {
        final before = cells[offsets[j - 1]];
        if (before <= code) break;
        cells[offsets[j]] = before;
        j--;
      }
      cells[offsets[j]] = code;
    }
  }

  /// True when [board] is in canonical form.
  bool isCanonical(Board board) {
    final free = freeMask(board.completedSets, board.openedMask);
    if (free != _freeMaskCached) _cacheFreeOffsets(free);
    for (var i = 1; i < _freeCount; i++) {
      if (board.cells[_freeOffsets[i - 1]] > board.cells[_freeOffsets[i]]) {
        return false;
      }
    }
    return true;
  }

  /// Writes the key words of the canonical [board] into [out] (at least
  /// [keyWords] long) and returns how many: always [keyWords]. The solver
  /// hashes them, stores them as the node and compares them to confirm a
  /// visited-table hit.
  int writeKey(Board board, Int32List out) {
    out[0] = board.completedSets;
    out[1] = board.openedMask;
    final cells = board.cells;
    final n = cells.length;
    var w = headerWords;
    var k = 0;
    if (triples) {
      for (; k + 2 < n; k += 3) {
        out[w++] = cells[k] | (cells[k + 1] << 10) | (cells[k + 2] << 20);
      }
      if (k + 1 < n) {
        out[w++] = cells[k] | (cells[k + 1] << 10);
      } else if (k < n) {
        out[w++] = cells[k];
      }
    } else {
      for (; k + 1 < n; k += 2) {
        out[w++] = cells[k] | (cells[k + 1] << 16);
      }
      if (k < n) out[w++] = cells[k];
    }
    return w;
  }

  /// Restores the board whose key words start at [start] in [words] into
  /// [board], a board of this layout: the inverse of [writeKey].
  /// Allocation-free; `moveCount` and `extraCount` are left as they are.
  void unpack(Int32List words, int start, Board board) {
    board
      ..completedSets = words[start]
      ..openedMask = words[start + 1];
    final cells = board.cells;
    final n = cells.length;
    var w = start + headerWords;
    var k = 0;
    if (triples) {
      for (; k + 2 < n; k += 3) {
        final word = words[w++];
        cells[k] = word & 0x3FF;
        cells[k + 1] = (word >> 10) & 0x3FF;
        cells[k + 2] = word >> 20;
      }
      if (k < n) {
        final word = words[w];
        cells[k] = word & 0x3FF;
        if (k + 1 < n) cells[k + 1] = word >> 10;
      }
    } else {
      for (; k + 1 < n; k += 2) {
        final word = words[w++];
        cells[k] = word & 0xFFFF;
        cells[k + 1] = word >> 16;
      }
      if (k < n) cells[k] = words[w];
    }
  }

  /// Hashes the key `words[0, length)` into [hashHi] and [hashLo]: exactly
  /// `Hash64.ofU32s(words, 0, length)`, without a builder or an object.
  /// Key words are non-negative and below 2^30 (codes are below 2^13, masks
  /// below 2^30), so each is already a u32.
  void hash(Int32List words, int length) {
    var hi = Hash64.hiSeed;
    var lo = Hash64.loSeed;
    for (var i = 0; i < length; i++) {
      final scrambled = murmur3Scramble(words[i]);
      hi = murmur3Mix(hi, scrambled);
      lo = murmur3Mix(lo, scrambled);
    }
    hashHi = murmur3Finish(hi, length * 4, 0);
    hashLo = murmur3Finish(lo, length * 4, 0);
  }

  void _cacheFreeOffsets(int free) {
    var count = 0;
    for (var slot = 0; slot < activeSlots; slot++) {
      if (((free >> slot) & 1) == 1) {
        _freeOffsets[count++] = layout.cellOffset[slot];
      }
    }
    _freeCount = count;
    _freeMaskCached = free;
  }

  static Int32List _thawTable(BoardLayout layout, int active) {
    var maxIce = 0;
    for (var slot = 0; slot < active; slot++) {
      final ice = layout.initialIce[slot];
      if (ice > maxIce) maxIce = ice;
    }
    // Ice beyond the level's sets never thaws, so the table needs no more
    // rows than completions can reach (spec §3.4).
    if (maxIce > layout.totalSets + 1) maxIce = layout.totalSets + 1;
    final table = Int32List(maxIce + 1);
    for (var c = 0; c <= maxIce; c++) {
      var mask = 0;
      for (var slot = 0; slot < active; slot++) {
        if (layout.initialIce[slot] <= c) mask |= 1 << slot;
      }
      table[c] = mask;
    }
    return table;
  }

  static bool _hasGold(BoardLayout layout) {
    for (final code in layout.initialCells) {
      if (code != NestCode.empty &&
          (NestCode.gold(code) != 0 ||
              NestCode.isWildColor(NestCode.color(code)))) {
        return true;
      }
    }
    return false;
  }

  static int _openKindMask(BoardLayout layout, int active) {
    var mask = 0;
    for (var slot = 0; slot < active; slot++) {
      if (layout.kind[slot] == BoardLayout.kindOpen) mask |= 1 << slot;
    }
    return mask;
  }
}
