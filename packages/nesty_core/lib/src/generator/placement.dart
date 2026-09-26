/// Spec §6.5 steps 2–3: which slots are towers, empty or occupied, how the
/// segments are dealt onto them, and where locks and ice go.
///
/// Every PRNG draw here is part of what `Generator.version` pins; the draw
/// order is documented on each function (spec §6.5, §7.5).
///
/// Internal to nesty_core (not exported by the barrel).
library;

import 'dart:typed_data';

import 'package:nesty_core/src/models/doll_color.dart';
import 'package:nesty_core/src/models/level.dart';
import 'package:nesty_core/src/models/nest.dart';
import 'package:nesty_core/src/models/slot.dart';
import 'package:nesty_core/src/prng/prng.dart';
import 'package:nesty_core/src/rules/engine/board.dart';
import 'package:nesty_core/src/rules/engine/board_layout.dart';
import 'package:nesty_core/src/rules/engine/kernel.dart';
import 'package:nesty_core/src/validator/layout_limits.dart';

/// Slots per shelf, top to bottom: [slotsPerShelf] on every shelf except the
/// bottom one, which holds at most [LayoutLimits.maxBottomShelfSlots] so both
/// extra slots still fit in its row (owner override D22).
List<int> shelfLengths(int shelves, int slotsPerShelf) => [
  for (var row = 0; row < shelves; row++)
    row == shelves - 1 && slotsPerShelf > LayoutLimits.maxBottomShelfSlots
        ? LayoutLimits.maxBottomShelfSlots
        : slotsPerShelf,
];

/// One grid slot of a board being generated.
final class SlotPlan {
  SlotPlan({required this.tower});

  /// A tower (spec §3.2); otherwise an open slot, possibly locked later.
  final bool tower;

  /// The nests, bottom to top: a tower's stack, or an open slot's 0 or 1.
  final List<Nest> nests = [];

  /// The lock's color once [placeLocks] turned this slot into a glass case.
  DollColor? unlockColor;

  /// The ice counter [placeIce] gave it (spec §3.4); 0 means none.
  int ice = 0;

  bool get occupied => nests.isNotEmpty;

  Slot toSlot() {
    final color = unlockColor;
    if (tower) return TowerSlot(nests, ice: ice);
    final nest = nests.isEmpty ? null : nests.single;
    if (color != null) {
      return LockedSlot(unlockColor: color, nest: nest, ice: ice);
    }
    return OpenSlot(nest: nest, ice: ice);
  }
}

/// A board being generated: its slots in row-major order (the `slotIds`
/// order) over shelves of [lengths].
final class BoardPlan {
  BoardPlan(this.lengths, this.slots);

  final List<int> lengths;
  final List<SlotPlan> slots;

  /// The board as a [Level].
  Level toLevel({
    required String id,
    required int maxSize,
    int? generatorVersion,
    int? seed,
  }) {
    final shelves = <List<Slot>>[];
    var index = 0;
    for (final length in lengths) {
      shelves.add([for (var c = 0; c < length; c++) slots[index++].toSlot()]);
    }
    return Level(
      id: id,
      maxSize: maxSize,
      shelves: shelves,
      generatorVersion: generatorVersion,
      seed: seed,
    );
  }
}

/// The slot roles of spec §6.5 step 2, each list in slot-index order.
typedef SlotRoles = ({
  List<int> towers,
  List<int> empty,
  List<int> occupiedOpen,
});

/// Chooses which of [slotCount] grid slots are towers, which open slots stay
/// empty, and which hold a nest.
///
/// Draws: one `Prng.shuffle` of `[0, …, slotCount − 1]`; the first [towers]
/// indexes are towers, the next [emptySlots] are empty open slots and the
/// rest are occupied open slots.
SlotRoles assignRoles(Prng prng, int slotCount, int towers, int emptySlots) {
  final order = [for (var i = 0; i < slotCount; i++) i];
  prng.shuffle(order);
  List<int> sorted(Iterable<int> slots) => slots.toList()..sort();
  return (
    towers: sorted(order.take(towers)),
    empty: sorted(order.skip(towers).take(emptySlots)),
    occupiedOpen: sorted(order.skip(towers + emptySlots)),
  );
}

/// Shuffles attempted per board before the tower-top limit gives up and
/// keeps the best deal (design A13).
const int maxSegmentDeals = 20;

/// Deals [segments] onto the slots of [roles] (spec §6.5 step 2) and
/// returns the board, with no locks or ice yet.
///
/// Each deal is one `Prng.shuffle` of [segments] (in place, so a re-deal
/// shuffles the previous order). Towers take [towerDepth] segments each,
/// bottom to top, in slot order; then each occupied open slot takes one.
///
/// Spec §6.5 says tower tops "should not be immediately mergeable too
/// often". A deal is accepted when at most `⌊towers / 2⌋` towers have a top
/// that the rules allow to merge with some other visible top at the start
/// (design A13). Otherwise the segments are re-dealt, up to
/// [maxSegmentDeals] deals, after which the first deal with the fewest such
/// towers is kept: the limit shapes difficulty but is not a rule, so it
/// never fails an attempt. With no towers, one deal is made and not checked.
BoardPlan dealSegments(
  Prng prng,
  List<Nest> segments,
  SlotRoles roles,
  List<int> lengths,
  int towerDepth,
  int maxSize,
) {
  final slotCount = lengths.fold(0, (sum, n) => sum + n);
  final towerSlots = roles.towers.toSet();
  BoardPlan deal() {
    final slots = [
      for (var i = 0; i < slotCount; i++)
        SlotPlan(tower: towerSlots.contains(i)),
    ];
    var next = 0;
    for (final slot in roles.towers) {
      for (var depth = 0; depth < towerDepth; depth++) {
        slots[slot].nests.add(segments[next++]);
      }
    }
    for (final slot in roles.occupiedOpen) {
      slots[slot].nests.add(segments[next++]);
    }
    return BoardPlan(lengths, slots);
  }

  prng.shuffle(segments);
  var best = deal();
  if (roles.towers.isEmpty) return best;
  final limit = roles.towers.length ~/ 2;
  var bestCount = mergeableTowerTops(best, maxSize);
  for (var tries = 1; bestCount > limit && tries < maxSegmentDeals; tries++) {
    prng.shuffle(segments);
    final plan = deal();
    final count = mergeableTowerTops(plan, maxSize);
    if (count < bestCount) {
      best = plan;
      bestCount = count;
    }
  }
  return best;
}

/// How many towers of [plan] have a top nest that can merge with another
/// slot's top on the starting board, in either direction.
///
/// Asked of the rules engine (a legal merge move from or to the tower), so
/// "mergeable" is exactly §2.2 and never restated here (CLAUDE.md rule 2).
int mergeableTowerTops(BoardPlan plan, int maxSize) {
  final level = plan.toLevel(id: 'plan', maxSize: maxSize);
  final board = Board(BoardLayout.of(level));
  final moves = Int32List(Kernel.legalMoveCapacity(board.layout));
  final count = Kernel.collectLegalMoves(board, moves);
  var towers = 0;
  for (var slot = 0; slot < plan.slots.length; slot++) {
    if (!plan.slots[slot].tower) continue;
    for (var i = 0; i < count; i++) {
      final entry = moves[i];
      if (!MoveOutcome.isMerge(LegalMove.outcome(entry))) continue;
      if (LegalMove.from(entry) == slot || LegalMove.to(entry) == slot) {
        towers++;
        break;
      }
    }
  }
  return towers;
}

/// Turns [locked] occupied open slots into glass cases (spec §3.3, §6.5
/// step 3). Returns false when no arrangement was found, which fails the
/// attempt.
///
/// Draws: one `Prng.shuffle` of the occupied open slots (in slot order);
/// then, walking the shuffled slots until [locked] cases are placed, one
/// `Prng.pick` of the unlock color for each slot that has a candidate
/// color. A slot without one is skipped with no draw.
///
/// Candidate unlock colors are the level's [colors], in order, except:
/// - With one set per color, never the sealed nest's own color (design §3,
///   §5.3 rule 6): its only set needs the sealed dolls, so the case could
///   never break.
/// - For the same reason, with one set per color, never a color that
///   already waits, through earlier cases, on the sealed color. "Color s
///   waits on u" when a case sealing s opens on u; a cycle of waits is a
///   deadlock (unsolvable fixture 001). With more sets per color another
///   set can break the case, so any color qualifies and the solver judges.
/// A segment is never a whole set (design A10), so rule 6's "not every doll
/// of that color is sealed inside the lock" always holds.
bool placeLocks(
  Prng prng,
  BoardPlan plan,
  List<int> occupiedOpen,
  List<DollColor> colors,
  int setsPerColor,
  int locked,
) {
  if (locked == 0) return true;
  final order = List.of(occupiedOpen);
  prng.shuffle(order);
  // waitsOn[s] holds the colors whose completion a case sealing s needs.
  final waitsOn = {for (final color in colors) color: <DollColor>{}};
  bool reaches(DollColor from, DollColor to) {
    final seen = <DollColor>{};
    final stack = [from];
    while (stack.isNotEmpty) {
      final color = stack.removeLast();
      if (color == to) return true;
      if (seen.add(color)) stack.addAll(waitsOn[color]!);
    }
    return false;
  }

  var placed = 0;
  for (final index in order) {
    if (placed == locked) break;
    final slot = plan.slots[index];
    final sealed = slot.nests.single.color;
    final candidates = setsPerColor > 1
        ? colors
        : [
            for (final color in colors)
              if (color != sealed && !reaches(color, sealed)) color,
          ];
    if (candidates.isEmpty) continue;
    final unlock = prng.pick(candidates);
    slot.unlockColor = unlock;
    waitsOn[sealed]!.add(unlock);
    placed++;
  }
  return placed == locked;
}

/// Puts ice on [iceSlots] occupied slots that are not glass cases
/// (spec §3.4, §6.5 step 3).
///
/// Draws: one `Prng.shuffle` of the occupied, unlocked slots (in slot
/// order); the first [iceSlots] are iced. Then, in slot order, each draws
/// its counter with `Prng.nextIntBetween(1, min(3, totalSets − 1))`
/// (design A12): every completion anywhere thaws it by 1 (§3.4), so at most
/// `totalSets − 1` lets it thaw before the last set has to complete, and 3
/// keeps the wait short. The caller guarantees `totalSets ≥ 2` when
/// [iceSlots] > 0.
void placeIce(Prng prng, BoardPlan plan, int iceSlots, int totalSets) {
  if (iceSlots == 0) return;
  final candidates = [
    for (var i = 0; i < plan.slots.length; i++)
      if (plan.slots[i].occupied && plan.slots[i].unlockColor == null) i,
  ];
  prng.shuffle(candidates);
  final chosen = candidates.take(iceSlots).toList()..sort();
  final maxIce = totalSets - 1 < maxIceCounter ? totalSets - 1 : maxIceCounter;
  for (final index in chosen) {
    plan.slots[index].ice = prng.nextIntBetween(1, maxIce);
  }
}

/// The largest ice counter the generator gives a slot (design A12).
const int maxIceCounter = 3;
