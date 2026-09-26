// Board-building shorthand for the rules and session tests, in the token
// style of the level JSON (spec §5.1): a nest is written outer to inner as
// 'red4 red3', a tower bottom to top as a list of such nests.
//
// Built straight from the models, so the rules tests don't depend on the
// codec.
import 'package:nesty_core/nesty_core.dart';
import 'package:test/test.dart';

/// The nest of [tokens], outer to inner, e.g. `nest('red4 red3')`.
Nest nest(String tokens) {
  final dolls = [
    for (final token in tokens.split(' ').where((t) => t.isNotEmpty))
      _doll(token),
  ];
  final nest = Nest.tryFromDolls(dolls);
  if (nest == null) throw ArgumentError.value(tokens, 'tokens', 'Not a nest');
  return nest;
}

Doll _doll(String token) {
  final match = RegExp(r'^([a-z]+)([1-6])$').firstMatch(token);
  if (match == null) throw ArgumentError.value(token, 'token');
  return Doll(DollColor.fromId(match[1]!), int.parse(match[2]!));
}

Nest? _maybeNest(String? tokens) =>
    tokens == null || tokens.isEmpty ? null : nest(tokens);

/// An open slot (spec §3.1); empty when [tokens] is null.
OpenSlot open([String? tokens, int ice = 0]) =>
    OpenSlot(nest: _maybeNest(tokens), ice: ice);

/// A tower (spec §3.2), bottom nest first.
TowerSlot tower(List<String> stack, {int ice = 0}) =>
    TowerSlot([for (final tokens in stack) nest(tokens)], ice: ice);

/// A glass case (spec §3.3) that [unlockColor] breaks.
LockedSlot locked(DollColor unlockColor, [String? tokens, int ice = 0]) =>
    LockedSlot(unlockColor: unlockColor, nest: _maybeNest(tokens), ice: ice);

/// A level of [shelves], top shelf first.
Level board(int maxSize, List<List<Slot>> shelves, {String id = 'T'}) =>
    Level(id: id, maxSize: maxSize, shelves: shelves);

/// Parses 'r0c0>r0c1' into a move.
Move mv(String move) {
  final parts = move.split('>');
  return Move(parts[0], parts[1]);
}

/// Applies [move] ('r0c0>r0c1') to [state]; fails the test if it is
/// rejected.
MoveApplied apply(GameState state, String move) {
  final result = Rules.tryMove(state, mv(move));
  if (result is! MoveApplied) {
    fail('Expected $move to be legal, got $result');
  }
  return result;
}

/// Applies every move in order and returns the final state.
GameState play(GameState state, List<String> moves) {
  var current = state;
  for (final move in moves) {
    current = apply(current, move).state;
  }
  return current;
}

/// The reason [move] is rejected on [state]; fails the test if it is legal.
InvalidMoveReason rejection(GameState state, String move) {
  final result = Rules.tryMove(state, mv(move));
  if (result is! MoveRejected) {
    fail('Expected $move to be rejected, got $result');
  }
  expect(result.move, mv(move));
  expect(result.targetId, mv(move).to);
  return result.reason;
}

/// Every slot's view, keyed by id, to show that a state didn't change.
Map<String, Slot> views(GameState state) => {
  for (final id in state.slotIds) id: state.slot(id),
};
