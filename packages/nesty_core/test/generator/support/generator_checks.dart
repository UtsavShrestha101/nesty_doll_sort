// Shared checks for generated levels (spec §6.5, §5.3, §18 M1).
import 'dart:convert';

import 'package:nesty_core/nesty_core.dart';
import 'package:nesty_core/src/util/hash64.dart';
import 'package:test/test.dart';

/// Hash64 hex of `jsonEncode(LevelCodec.encode(level))`: the golden value
/// that pins a generated level byte for byte (design §5).
String levelDigest(Level level) =>
    Hash64.ofString(jsonEncode(LevelCodec.encode(level))).toHex();

/// Expects [level] to pass validation rules 1–8 with a fresh admin-budget
/// solve, and the solver's solution to replay through `Rules` to a win
/// (spec §18 M1 "100 generated levels pass validation and solve").
///
/// Returns the fresh solve.
SolveResult expectPlayable(Level level) {
  final report = Validator.validate(level);
  expect(report.issues, isEmpty, reason: '${level.id}: ${report.issues}');
  expect(report.isValid, isTrue);
  final solve = report.solve!;
  expect(solve.verdict, SolveVerdict.solved, reason: level.id);
  var state = GameState.initial(level);
  for (final move in solve.solution!) {
    final result = Rules.tryMove(state, move);
    if (result is! MoveApplied) {
      fail('${level.id}: solution move $move rejected: $result');
    }
    state = result.state;
  }
  expect(Rules.isWon(state), isTrue, reason: '${level.id} replays to Won');
  expect(state.completedSets, level.totalSets);
  // The JSON the level is stored as reads back to the same level.
  expect(LevelCodec.decodeString(LevelCodec.encodeString(level)).level, level);
  return solve;
}

/// Expects [outcome] to be a [GeneratorSuccess] for [params] whose parts
/// agree with each other and with a fresh validation and simulation.
GeneratorSuccess expectConsistentSuccess(
  GeneratorParams params,
  GeneratorOutcome outcome,
) {
  expect(outcome, isA<GeneratorSuccess>(), reason: '$params → $outcome');
  final success = outcome as GeneratorSuccess;
  final level = success.level;
  expect(level.generatorVersion, Generator.version);
  expect(level.seed, params.seed);
  expect(level.id, params.id ?? Generator.defaultId(params.seed));
  expect(success.attempt, inInclusiveRange(0, Generator.maxAttempts - 1));
  expect(level, Generator.buildAttempt(params, success.attempt));
  final solve = expectPlayable(level);
  expect(success.solve, solve, reason: 'the stored solve is reproducible');
  expect(success.simulation, Simulator.run(level));
  expect(
    success.tierMatched,
    success.simulation.tier == params.targetTier,
    reason: 'tierMatched means the simulated tier is the target',
  );
  return success;
}
