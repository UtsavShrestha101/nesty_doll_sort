// Golden outputs of Generator.version 1 (spec §6.5, §7.5, design §5): the
// same params and seed must give byte-identical levels forever, because the
// daily puzzle has to match across devices and app versions (M3), and bonus
// level N must stay the same level for a player.
//
// Each digest is Hash64 of `jsonEncode(LevelCodec.encode(level))`. The
// metrics pin the solver and simulator results the attempt was chosen by.
// When one of these fails:
// - after an unintended change, fix the change;
// - after an intended change to what the pipeline produces (PRNG, cuts,
//   placement, locks, ice, validator, solver, simulator or the curve), bump
//   `Generator.version`, keep a frozen v1 path for dailies (design §3), and
//   only then paste the new values, once the parity suite agrees on every
//   platform (test/parity/generator_parity_test.dart).
import 'package:nesty_core/nesty_core.dart';
import 'package:test/test.dart';

import 'support/generator_checks.dart';

final _params = <String, GeneratorParams>{
  for (final n in [1, 2, 6, 10, 16, 20, 31, 36, 40, 51, 56, 60, 71, 100, 121])
    'bonus $n': DifficultyCurve.bonusParams(n),
  'bonus 130': DifficultyCurve.bonusParams(130),
  for (final date in [20260926, 20260928, 20270101])
    'daily $date': DifficultyCurve.dailyParams(date),
  'two sets per color': const GeneratorParams(
    colors: 3,
    setsPerColor: 2,
    maxSize: 4,
    shelves: 3,
    slotsPerShelf: 4,
    towers: 4,
    towerDepth: 3,
    emptySlots: 1,
    locked: 1,
    iceSlots: 1,
    targetTier: Tier.medium,
    seed: 0,
  ),
  // The largest seed, a 5-wide top shelf over a 4-wide bottom one, and no
  // attempt at the target: the closest is the last attempt.
  'max seed': const GeneratorParams(
    colors: 5,
    maxSize: 5,
    shelves: 2,
    slotsPerShelf: 5,
    towers: 3,
    towerDepth: 4,
    emptySlots: 1,
    targetTier: Tier.hard,
    seed: Prng.maxSeed,
  ),
};

const _golden = <String, Map<String, Object>>{
  'bonus 1': {
    'digest': '9dc65834299d0a5c',
    'attempt': 0,
    'tier': 'easy',
    'tierMatched': true,
    'casual': 300,
    'smart': 300,
    'solverMoves': 2,
    'nodes': 3,
  },
  'bonus 2': {
    'digest': 'bda46e270c71f497',
    'attempt': 0,
    'tier': 'easy',
    'tierMatched': true,
    'casual': 300,
    'smart': 300,
    'solverMoves': 2,
    'nodes': 3,
  },
  'bonus 6': {
    'digest': 'dffb7a0dfbfe1b26',
    'attempt': 0,
    'tier': 'easy',
    'tierMatched': false,
    'casual': 300,
    'smart': 300,
    'solverMoves': 4,
    'nodes': 10,
  },
  'bonus 10': {
    'digest': 'af533bee7555ca05',
    'attempt': 0,
    'tier': 'easy',
    'tierMatched': false,
    'casual': 300,
    'smart': 300,
    'solverMoves': 6,
    'nodes': 21,
  },
  'bonus 16': {
    'digest': '71b6ff9c23271f9e',
    'attempt': 4,
    'tier': 'hard',
    'tierMatched': true,
    'casual': 36,
    'smart': 300,
    'solverMoves': 21,
    'nodes': 1768,
  },
  'bonus 20': {
    'digest': '18709c29ccb00fe1',
    'attempt': 5,
    'tier': 'superhard',
    'tierMatched': true,
    'casual': 22,
    'smart': 300,
    'solverMoves': 23,
    'nodes': 17267,
  },
  'bonus 31': {
    'digest': '11c300906d48b87c',
    'attempt': 0,
    'tier': 'easy',
    'tierMatched': true,
    'casual': 300,
    'smart': 300,
    'solverMoves': 12,
    'nodes': 162,
  },
  'bonus 36': {
    'digest': 'e0fe97357c357a40',
    'attempt': 6,
    'tier': 'hard',
    'tierMatched': true,
    'casual': 37,
    'smart': 230,
    'solverMoves': 19,
    'nodes': 826,
  },
  'bonus 40': {
    'digest': 'd952bd515fba05ff',
    'attempt': 0,
    'tier': 'superhard',
    'tierMatched': true,
    'casual': 10,
    'smart': 0,
    'solverMoves': 19,
    'nodes': 1084,
  },
  'bonus 51': {
    'digest': 'b88752546d18482f',
    'attempt': 0,
    'tier': 'easy',
    'tierMatched': true,
    'casual': 300,
    'smart': 300,
    'solverMoves': 12,
    'nodes': 567,
  },
  'bonus 56': {
    'digest': '88fa0d8e4e514d48',
    'attempt': 4,
    'tier': 'hard',
    'tierMatched': true,
    'casual': 65,
    'smart': 300,
    'solverMoves': 17,
    'nodes': 115,
  },
  'bonus 60': {
    'digest': '037273bccbce3a29',
    'attempt': 1,
    'tier': 'superhard',
    'tierMatched': true,
    'casual': 23,
    'smart': 300,
    'solverMoves': 21,
    'nodes': 1458,
  },
  'bonus 71': {
    'digest': '4e34ba024fac753c',
    'attempt': 0,
    'tier': 'easy',
    'tierMatched': true,
    'casual': 300,
    'smart': 300,
    'solverMoves': 11,
    'nodes': 43,
  },
  'bonus 100': {
    'digest': '52a2fc7f57cadfb0',
    'attempt': 0,
    'tier': 'superhard',
    'tierMatched': true,
    'casual': 9,
    'smart': 300,
    'solverMoves': 26,
    'nodes': 4226,
  },
  'bonus 121': {
    'digest': '84822e8e75dd022c',
    'attempt': 0,
    'tier': 'easy',
    'tierMatched': true,
    'casual': 300,
    'smart': 300,
    'solverMoves': 11,
    'nodes': 52,
  },
  'bonus 130': {
    'digest': '7d6afb0ce3229ffb',
    'attempt': 1,
    'tier': 'superhard',
    'tierMatched': true,
    'casual': 0,
    'smart': 204,
    'solverMoves': 25,
    'nodes': 663,
  },
  'daily 20260926': {
    'digest': '7716bec2334e7d9a',
    'attempt': 0,
    'tier': 'hard',
    'tierMatched': true,
    'casual': 62,
    'smart': 259,
    'solverMoves': 20,
    'nodes': 1075,
  },
  'daily 20260928': {
    'digest': 'ba7076deff1ebeb8',
    'attempt': 3,
    'tier': 'medium',
    'tierMatched': true,
    'casual': 138,
    'smart': 300,
    'solverMoves': 16,
    'nodes': 524,
  },
  'daily 20270101': {
    'digest': '6f2f97ccb663ff56',
    'attempt': 4,
    'tier': 'medium',
    'tierMatched': true,
    'casual': 135,
    'smart': 300,
    'solverMoves': 15,
    'nodes': 114,
  },
  'two sets per color': {
    'digest': '7c558ae292261c8f',
    'attempt': 22,
    'tier': 'medium',
    'tierMatched': true,
    'casual': 159,
    'smart': 300,
    'solverMoves': 14,
    'nodes': 486,
  },
  'max seed': {
    'digest': 'e9b6b70798126b2a',
    'attempt': 49,
    'tier': 'easy',
    'tierMatched': false,
    'casual': 220,
    'smart': 300,
    'solverMoves': 13,
    'nodes': 61,
  },
};

/// Bonus level 16, the first tower level, as JSON: pins the exact bytes of
/// one level, not only its digest.
const _bonus16Json =
    '{"schemaVersion":1,"id":"bonus-16","maxSize":4,"shelves":[[{"type":'
    '"tower","stack":[["teal4"],["brown2"],["pink2"],["purple1"]]},{"type":'
    '"tower","stack":[["brown4"],["teal2"],["brown3"],["teal3"]]},{"type":'
    '"tower","stack":[["yellow4"],["pink3"],["red2"],["orange1"]]}],[{"type":'
    '"tower","stack":[["purple3"],["red4"],["teal1"],["red1"]]},{"type":'
    '"open","nest":["purple2"]},{"type":"tower","stack":[["pink4"],["red3"],'
    '["purple4"],["brown1"]]}],[{"type":"tower","stack":[["yellow2",'
    '"yellow1"],["orange3","orange2"],["orange4"],["pink1"]]},{"type":'
    '"open","nest":null},{"type":"open","nest":["yellow3"]}]],'
    '"generatorVersion":1,"seed":1000016}';

void main() {
  test('Generator.version is 1: these goldens belong to it', () {
    expect(Generator.version, 1);
  });

  test('every golden has params and every params a golden', () {
    expect(_params.keys, orderedEquals(_golden.keys));
  });

  for (final MapEntry(key: name, value: params) in _params.entries) {
    test(name, () {
      final outcome = Generator.generate(params);
      expect(outcome, isA<GeneratorSuccess>());
      final success = outcome as GeneratorSuccess;
      expect({
        'digest': levelDigest(success.level),
        'attempt': success.attempt,
        'tier': success.simulation.tier.id,
        'tierMatched': success.tierMatched,
        'casual': success.simulation.casual.wins,
        'smart': success.simulation.smart.wins,
        'solverMoves': success.solve.solution!.length,
        'nodes': success.solve.nodes,
      }, _golden[name]);
    });
  }

  test('bonus level 16, byte for byte', () {
    final success =
        Generator.generate(DifficultyCurve.bonusParams(16)) as GeneratorSuccess;
    expect(LevelCodec.encodeString(success.level), _bonus16Json);
  });
}
