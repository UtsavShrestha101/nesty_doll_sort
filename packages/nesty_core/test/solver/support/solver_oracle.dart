// Test oracles for the solver, written against the public API only
// (GameState views and Rules), so they share no code with src/solver/.
//
// - canonicalSignature: spec §6.2's canonical form read off the slot views:
//   the free slots (an OpenSlot view without ice: open and extra slots,
//   emptied towers, broken cases) are interchangeable, so only their ids and
//   the sorted multiset of their contents count; every other slot counts by
//   id and full view.
// - reachableCanonicalStates: a breadth-first search over every legal move
//   (no pruning), deduplicated by that signature: how many distinct
//   canonical states the level can reach. A search that proves a level
//   unsolvable must store exactly that many.
// - replay: plays a solution through Rules.tryMove.
library;

import 'package:nesty_core/nesty_core.dart';
import 'package:test/test.dart';

/// The canonical signature of [state] (see the library doc).
String canonicalSignature(GameState state) {
  final freeIds = <String>[];
  final freeContents = <String>[];
  final fixed = <String>[];
  for (final id in state.slotIds) {
    final slot = state.slot(id);
    if (slot is OpenSlot && slot.ice == 0) {
      freeIds.add(id);
      freeContents.add('${slot.nest}');
    } else {
      fixed.add('$id=$slot');
    }
  }
  freeContents.sort();
  return '${state.completedSets} | free ${freeIds.join(',')}: '
      '${freeContents.join(' ')} | ${fixed.join(' ')}';
}

/// Distinct canonical states reachable from [state], and the fewest moves
/// to a win (null when no reachable state is won).
({int states, int? depth}) reachableCanonicalStates(
  GameState state, {
  int cap = 200000,
}) {
  var frontier = [state];
  final seen = {canonicalSignature(state)};
  int? depth;
  for (var d = 0; frontier.isNotEmpty; d++) {
    if (depth == null && frontier.any(Rules.isWon)) depth = d;
    final next = <GameState>[];
    for (final current in frontier) {
      for (final move in Rules.legalMoves(current)) {
        final after = (Rules.tryMove(current, move) as MoveApplied).state;
        if (seen.add(canonicalSignature(after))) next.add(after);
      }
    }
    if (seen.length > cap) throw StateError('More than $cap states');
    frontier = next;
  }
  return (states: seen.length, depth: depth);
}

/// Plays [moves] from [state] through `Rules.tryMove`, failing the test on
/// a rejected move, and returns the final state.
GameState replay(GameState state, List<Move> moves) {
  var current = state;
  for (final move in moves) {
    final result = Rules.tryMove(current, move);
    if (result is! MoveApplied) fail('$move is rejected on $current: $result');
    current = result.state;
  }
  return current;
}

/// Expects [result] to be an optimal win of [expectedMoves] moves from
/// [state] that replays to `Won`.
void expectOptimalWin(GameState state, SolveResult result, int expectedMoves) {
  expect(result.verdict, SolveVerdict.solved);
  expect(result.solution, hasLength(expectedMoves));
  final end = replay(state, result.solution!);
  expect(Rules.isWon(end), isTrue, reason: 'the solution must reach Won');
  expect(result.nodes, greaterThanOrEqualTo(1));
}
