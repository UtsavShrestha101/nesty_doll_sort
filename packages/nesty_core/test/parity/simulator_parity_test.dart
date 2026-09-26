// VM/web parity for the simulator (spec §6.4, design §5, D11). The admin
// simulates in the browser and the generator (on phones and in the admin)
// picks levels by simulated tier (spec §6.5), so every count here must be
// identical on the VM, in dart2js (chrome, node) and in wasm, or a daily
// puzzle could differ between devices (spec §7.5).
//
// The expectations were reproduced exactly by an independent Python
// implementation written from the documented definitions
// (test/simulator/reference/simref.py), not only copied from Dart output.
// After an intended change, recompute them with it and bump
// `Generator.version` (spec §6.5).
@Tags(['parity'])
library;

import 'package:nesty_core/nesty_core.dart';
import 'package:nesty_core/src/rules/engine/board_layout.dart';
import 'package:nesty_core/src/simulator/bots.dart';
import 'package:test/test.dart';

import '../simulator/support/sim_levels.dart';
import 'parity.dart';

Map<String, Object> _result(SimulationResult result) => {
  'seed': result.seed,
  'casual': result.casual.wins,
  'smart': result.smart.wins,
  'tier': result.tier.id,
  'expertOnly': result.expertOnly,
};

/// Hash64 of one u32 per run, `moves * 2 + (won ? 1 : 0)`, for runs 0..299
/// of [bot] at the level's default seed: pins every run's length and
/// outcome, not only the win count.
String _runsDigest(Level level, SimBot bot) {
  final player = BotPlayer(BoardLayout.of(level));
  final seed = Simulator.defaultSeed(level);
  final words = <int>[];
  for (var run = 0; run < SimulatorParams.defaultRuns; run++) {
    var moves = 0;
    final won = player.play(
      bot,
      Prng(Prng.derive(seed, bot.index, run)),
      SimulatorParams.defaultMoveCap,
      (_, _) => moves++,
    );
    words.add(moves * 2 + (won ? 1 : 0));
  }
  return parityDigestU32s(words);
}

void main() {
  parityTest(
    'default seeds: Hash64.lo of the board JSON',
    () => {
      for (final name in simLevelJson.keys)
        name: Simulator.defaultSeed(simLevel(name)),
    },
    expected: _defaultSeeds,
  );

  parityTest(
    'results at the default params (300 runs, 250-move cap)',
    () => {
      for (final name in simLevelJson.keys)
        name: _result(Simulator.run(simLevel(name))),
    },
    expected: _results,
  );

  parityTest(
    'every run: moves and outcome per run, per bot',
    () => {
      for (final name in simLevelJson.keys)
        name: {
          for (final bot in SimBot.values)
            bot.name: _runsDigest(simLevel(name), bot),
        },
    },
    expected: _runDigests,
  );

  parityTest(
    'explicit seeds, including both halves of a 53-bit seed',
    () {
      final level = simLevel('hard2');
      return {
        for (final seed in [0, 1, 0xFFFFFFFF, 0x100000000, 20260926])
          '$seed': _result(
            Simulator.run(level, SimulatorParams(seed: seed, runs: 60)),
          ),
        '${Prng.maxSeed}': _result(
          Simulator.run(
            level,
            const SimulatorParams(seed: Prng.maxSeed, runs: 60),
          ),
        ),
      };
    },
    expected: _explicitSeeds,
  );
}

const _defaultSeeds = <String, int>{
  'tutorial': 311031789,
  'swallow': 1146406718,
  'spec': 3052803357,
  'placementFirst': 3036406871,
  'iceThaws': 3446127907,
  'lockOpens': 2602307991,
  'largeOpen': 2614013055,
  'towersEasy': 3366422950,
  'medium1': 2022548235,
  'medium2': 210830719,
  'hard1': 1360607776,
  'hard2': 136178532,
  'superhard1': 2719175317,
  'superhard2': 2038712995,
  'expertOnly': 2776124421,
  'lockDeadlock': 1823194236,
  'neverThaws': 1586530867,
  'noSpace': 4060833882,
};

const _results = <String, Map<String, Object>>{
  'tutorial': {
    'seed': 311031789,
    'casual': 300,
    'smart': 300,
    'tier': 'easy',
    'expertOnly': false,
  },
  'swallow': {
    'seed': 1146406718,
    'casual': 300,
    'smart': 300,
    'tier': 'easy',
    'expertOnly': false,
  },
  'spec': {
    'seed': 3052803357,
    'casual': 300,
    'smart': 300,
    'tier': 'easy',
    'expertOnly': false,
  },
  'placementFirst': {
    'seed': 3036406871,
    'casual': 300,
    'smart': 300,
    'tier': 'easy',
    'expertOnly': false,
  },
  'iceThaws': {
    'seed': 3446127907,
    'casual': 300,
    'smart': 300,
    'tier': 'easy',
    'expertOnly': false,
  },
  'lockOpens': {
    'seed': 2602307991,
    'casual': 300,
    'smart': 300,
    'tier': 'easy',
    'expertOnly': false,
  },
  'largeOpen': {
    'seed': 2614013055,
    'casual': 300,
    'smart': 300,
    'tier': 'easy',
    'expertOnly': false,
  },
  'towersEasy': {
    'seed': 3366422950,
    'casual': 300,
    'smart': 300,
    'tier': 'easy',
    'expertOnly': false,
  },
  'medium1': {
    'seed': 2022548235,
    'casual': 155,
    'smart': 300,
    'tier': 'medium',
    'expertOnly': false,
  },
  'medium2': {
    'seed': 210830719,
    'casual': 119,
    'smart': 300,
    'tier': 'medium',
    'expertOnly': false,
  },
  'hard1': {
    'seed': 1360607776,
    'casual': 101,
    'smart': 300,
    'tier': 'hard',
    'expertOnly': false,
  },
  'hard2': {
    'seed': 136178532,
    'casual': 47,
    'smart': 300,
    'tier': 'hard',
    'expertOnly': false,
  },
  'superhard1': {
    'seed': 2719175317,
    'casual': 32,
    'smart': 300,
    'tier': 'superhard',
    'expertOnly': false,
  },
  'superhard2': {
    'seed': 2038712995,
    'casual': 18,
    'smart': 177,
    'tier': 'superhard',
    'expertOnly': false,
  },
  'expertOnly': {
    'seed': 2776124421,
    'casual': 7,
    'smart': 56,
    'tier': 'superhard',
    'expertOnly': true,
  },
  'lockDeadlock': {
    'seed': 1823194236,
    'casual': 0,
    'smart': 0,
    'tier': 'superhard',
    'expertOnly': true,
  },
  'neverThaws': {
    'seed': 1586530867,
    'casual': 0,
    'smart': 0,
    'tier': 'superhard',
    'expertOnly': true,
  },
  'noSpace': {
    'seed': 4060833882,
    'casual': 0,
    'smart': 0,
    'tier': 'superhard',
    'expertOnly': true,
  },
};

const _runDigests = <String, Map<String, String>>{
  'tutorial': {'casual': '7c8970ab4a00603d', 'smart': 'f9f5ec72807a9d1f'},
  'swallow': {'casual': '1f73878117dafa23', 'smart': 'f1f5dbd6e510db7e'},
  'spec': {'casual': 'c7391171209f82f4', 'smart': 'f8113918456d0945'},
  'placementFirst': {'casual': '26efb0810b04a575', 'smart': '7bca7f61a0a306c0'},
  'iceThaws': {'casual': '273b279381f384cd', 'smart': 'f9f5ec72807a9d1f'},
  'lockOpens': {'casual': 'c03f5434e7f71065', 'smart': 'f9f5ec72807a9d1f'},
  'largeOpen': {'casual': '3083bded3f31738d', 'smart': '5c5bc0d021341759'},
  'towersEasy': {'casual': '4b10be2346d03e5c', 'smart': 'fe4aefc858477121'},
  'medium1': {'casual': 'e54a8ae3d6bb048d', 'smart': 'e5749caf9ae55d8b'},
  'medium2': {'casual': '616afcc76ad3ad90', 'smart': 'fe4aefc858477121'},
  'hard1': {'casual': 'fae2439e5637db53', 'smart': 'fe4aefc858477121'},
  'hard2': {'casual': 'e6893948c1b78791', 'smart': 'b6a3de5124437d29'},
  'superhard1': {'casual': '6abb97817e2114bd', 'smart': '72f4489fabbd4ecc'},
  'superhard2': {'casual': '1cd6675588d22968', 'smart': 'a6cd9595d939b917'},
  'expertOnly': {'casual': 'd6098dd318efc2bd', 'smart': '363ca10ec8bfee9c'},
  'lockDeadlock': {'casual': 'c053e2405a9f557e', 'smart': 'c053e2405a9f557e'},
  'neverThaws': {'casual': '8ad690653ca847dd', 'smart': 'fbf19bda1fb16efb'},
  'noSpace': {'casual': 'fbf19bda1fb16efb', 'smart': 'fbf19bda1fb16efb'},
};

const _explicitSeeds = <String, Map<String, Object>>{
  '0': {
    'seed': 0,
    'casual': 12,
    'smart': 60,
    'tier': 'hard',
    'expertOnly': false,
  },
  '1': {
    'seed': 1,
    'casual': 7,
    'smart': 60,
    'tier': 'superhard',
    'expertOnly': false,
  },
  '4294967295': {
    'seed': 4294967295,
    'casual': 12,
    'smart': 60,
    'tier': 'hard',
    'expertOnly': false,
  },
  '4294967296': {
    'seed': 4294967296,
    'casual': 9,
    'smart': 60,
    'tier': 'hard',
    'expertOnly': false,
  },
  '20260926': {
    'seed': 20260926,
    'casual': 9,
    'smart': 60,
    'tier': 'hard',
    'expertOnly': false,
  },
  '9007199254740991': {
    'seed': 9007199254740991,
    'casual': 8,
    'smart': 60,
    'tier': 'hard',
    'expertOnly': false,
  },
};
