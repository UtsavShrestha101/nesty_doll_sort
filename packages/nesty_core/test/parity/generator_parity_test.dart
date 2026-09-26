// VM/web parity for the generator (spec §6.5, §7.5, design §5, D11). Phones
// (VM/AOT) generate Bonus Endless and daily levels, and the web admin
// generates and previews the same params, so a seed must give the same
// level byte for byte on the VM, in dart2js (chrome, node) and in wasm, or
// two players would get different daily puzzles.
//
// The full generations cover every stage: the PRNG draws, cuts, placement,
// locks, ice, the validator, the admin-budget solve and the simulator that
// chooses the attempt. The raw attempts pin the board-building draws alone
// on more boards, cheaply. The values equal those in
// test/generator/golden_test.dart; after an intended change, bump
// `Generator.version` and update both once every platform agrees.
@Tags(['parity'])
library;

import 'dart:convert';

import 'package:nesty_core/nesty_core.dart';
import 'package:test/test.dart';

import 'parity.dart';

String _digest(Level level) =>
    parityDigestString(jsonEncode(LevelCodec.encode(level)));

Map<String, Object> _generated(GeneratorParams params) {
  final success = Generator.generate(params) as GeneratorSuccess;
  return {
    'digest': _digest(success.level),
    'attempt': success.attempt,
    'tier': success.simulation.tier.id,
    'tierMatched': success.tierMatched,
    'casual': success.simulation.casual.wins,
    'smart': success.simulation.smart.wins,
    'solverMoves': success.solve.solution!.length,
    'nodes': success.solve.nodes,
  };
}

void main() {
  parityTest(
    'bonus level 16: the first towers',
    () => _generated(DifficultyCurve.bonusParams(16)),
    expected: const {
      'digest': '71b6ff9c23271f9e',
      'attempt': 4,
      'tier': 'hard',
      'tierMatched': true,
      'casual': 36,
      'smart': 300,
      'solverMoves': 21,
      'nodes': 1768,
    },
  );

  parityTest(
    'bonus level 56: towers, a lock and ice',
    () => _generated(DifficultyCurve.bonusParams(56)),
    expected: const {
      'digest': '88fa0d8e4e514d48',
      'attempt': 4,
      'tier': 'hard',
      'tierMatched': true,
      'casual': 65,
      'smart': 300,
      'solverMoves': 17,
      'nodes': 115,
    },
  );

  parityTest(
    'daily puzzle of 2026-09-26',
    () => _generated(DifficultyCurve.dailyParams(20260926)),
    expected: const {
      'digest': '7716bec2334e7d9a',
      'attempt': 0,
      'tier': 'hard',
      'tierMatched': true,
      'casual': 62,
      'smart': 259,
      'solverMoves': 20,
      'nodes': 1075,
    },
  );

  parityTest(
    'raw attempts 0–4 of later stages and the largest seed',
    () => {
      for (final (name, params) in [
        ('bonus 76', DifficultyCurve.bonusParams(76)),
        ('bonus 130', DifficultyCurve.bonusParams(130)),
        (
          'max seed',
          const GeneratorParams(
            colors: 5,
            setsPerColor: 2,
            maxSize: 6,
            shelves: 4,
            slotsPerShelf: 5,
            towers: 6,
            towerDepth: 4,
            emptySlots: 2,
            locked: 3,
            iceSlots: 3,
            targetTier: Tier.hard,
            seed: Prng.maxSeed,
          ),
        ),
      ])
        name: [
          for (var attempt = 0; attempt < 5; attempt++)
            switch (Generator.buildAttempt(params, attempt)) {
              final level? => _digest(level),
              null => null,
            },
        ],
    },
    expected: _rawAttempts,
  );
}

const _rawAttempts = <String, List<String?>>{
  'bonus 76': [
    '099d463be441074e',
    '06722a0732ea72d9',
    '8b946cd50f3059d8',
    'de1a4d98083d5538',
    'e9be536c618349b2',
  ],
  // Attempt 1 is the level `generate` returns (golden_test.dart).
  'bonus 130': [
    '2c2303915c6276bb',
    '7d6afb0ce3229ffb',
    '1dfd1ec928fc3b93',
    '39b0bebcb2189ada',
    '5f23bcafccbb814b',
  ],
  'max seed': [
    'c9fabaef9f6c4607',
    'dd2aac085a3a32d0',
    '0b70d46f16223bf0',
    'de015d4b5407df37',
    '789ad8a941c3a26e',
  ],
};
