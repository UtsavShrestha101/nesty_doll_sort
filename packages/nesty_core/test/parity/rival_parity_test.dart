// VM/web parity for the vs Computer rival (spec-prop §7.7, D11). The phones
// (VM/AOT) play the rival, and the web admin runs the same core, so a race
// seed must give the same rival moves everywhere: "Rematch replays the same
// board and the same rival moves".
//
// Spec-prop §7.7: "Rival: makes one move per interval. When its run can't be
// won (no useful move, or the 250-move cap of §6.4), it restarts from the
// start with its next run seed."
//
// The expectations were computed by the independent Python reference
// (test/simulator/reference/rivalref.py), written from RivalBot's documented
// definition over simref.py's rules and bots, never copied from Dart output.
// The race boards' `board` and `json` are the one exception: regression pins
// of Generator.version 1 (see vectors/race_vectors.dart). After an intended
// change, recompute with the reference.
//
// The step digest's format is documented in rival_race.dart.
@Tags(['parity'])
library;

import 'package:nesty_core/nesty_core.dart';
import 'package:test/test.dart';

import '../simulator/support/sim_levels.dart';
import 'parity.dart';
import 'rival_race.dart';
import 'vectors/race_vectors.dart';

// dart2js runs the solver and simulator several times slower than the VM.
const _slowOnTheWeb = Timeout.factor(4);

// The reference's cases.
const _boards = ['spec', 'hard2', 'expertOnly'];
const _seeds = [3100001, 3200001, 3300001];
const _maxSteps = 600;

void main() {
  parityTest(
    'run seeds: Prng.derive(raceSeed, RVL0 + bot, run)',
    () => {
      for (final seed in [..._seeds, 0, Prng.maxSeed])
        '$seed': {
          for (final bot in SimBot.values)
            bot.name: [
              for (final run in [0, 1, 2, 0xFFFFFFFF])
                RivalBot.runSeed(seed, bot, run),
            ],
        },
    },
    expected: _runSeeds,
  );

  parityTest(
    "the rival's steps on three boards, three race seeds, both bots",
    () => {
      for (final name in _boards)
        name: {
          for (final seed in _seeds)
            '$seed': {
              for (final bot in SimBot.values)
                bot.name: rivalRace(simLevel(name), bot, seed, _maxSteps),
            },
        },
    },
    expected: _steps,
  );

  parityTest(
    'a dead board restarts after every move and never finishes',
    () => {
      for (final bot in SimBot.values)
        bot.name: rivalRace(simLevel('noSpace'), bot, _seeds.first, _maxSteps),
    },
    expected: _dead,
  );

  parityTest(
    'a cap of 5 moves restarts every run that has not won by then',
    () => {
      for (final bot in SimBot.values)
        bot.name: rivalRace(
          simLevel('expertOnly'),
          bot,
          _seeds.last,
          _maxSteps,
          moveCap: 5,
        ),
    },
    expected: _capped,
  );

  parityTest(
    "race boards and the rival's whole race on each",
    () => {
      for (final (rival, raceNo, won) in raceGoldenCases)
        raceGoldenKey(rival, raceNo, won): raceGoldenOf(
          generateRaceBoard(rival, raceNo, won),
          rival,
          raceNo,
        ),
    },
    expected: raceGoldens,
    timeout: _slowOnTheWeb,
  );
}

const _runSeeds = <String, Map<String, List<int>>>{
  '3100001': {
    'casual': [95954607, 3007998949, 2440204243, 1394696717],
    'smart': [2473205724, 2327025644, 3686665868, 1416947865],
  },
  '3200001': {
    'casual': [4033799127, 477674535, 1368537148, 986090067],
    'smart': [1987907332, 2527559827, 102693974, 878197053],
  },
  '3300001': {
    'casual': [3573907836, 920671186, 2304387369, 1977591488],
    'smart': [1463719035, 1143949072, 2046275414, 48135745],
  },
  '0': {
    'casual': [1993545732, 1310084305, 668082803, 593728994],
    'smart': [4252849067, 514245784, 2612950103, 3922005315],
  },
  '9007199254740991': {
    'casual': [1576029149, 2549098992, 2823694804, 285168986],
    'smart': [881491568, 334356332, 2310986295, 2885750580],
  },
};

const _steps = <String, Map<String, Map<String, Map<String, Object>>>>{
  'spec': {
    '3100001': {
      'casual': {
        'digest': '7befabba00f0f497',
        'steps': 8,
        'restarts': 0,
        'finished': true,
        'runMoves': 8,
      },
      'smart': {
        'digest': 'c2ab6fb43fbcae11',
        'steps': 4,
        'restarts': 0,
        'finished': true,
        'runMoves': 4,
      },
    },
    '3200001': {
      'casual': {
        'digest': 'dff30c1019d29947',
        'steps': 8,
        'restarts': 0,
        'finished': true,
        'runMoves': 8,
      },
      'smart': {
        'digest': 'e6e5fdafa4e29dbe',
        'steps': 4,
        'restarts': 0,
        'finished': true,
        'runMoves': 4,
      },
    },
    '3300001': {
      'casual': {
        'digest': '8ca2c08beda5c96f',
        'steps': 5,
        'restarts': 0,
        'finished': true,
        'runMoves': 5,
      },
      'smart': {
        'digest': '619984a7df4d4abc',
        'steps': 4,
        'restarts': 0,
        'finished': true,
        'runMoves': 4,
      },
    },
  },
  'hard2': {
    '3100001': {
      'casual': {
        'digest': '799b666e8a181459',
        'steps': 12,
        'restarts': 0,
        'finished': true,
        'runMoves': 12,
      },
      'smart': {
        'digest': 'b3c571a8d965bf57',
        'steps': 11,
        'restarts': 0,
        'finished': true,
        'runMoves': 11,
      },
    },
    '3200001': {
      'casual': {
        'digest': 'c4fd1a5bc519a60d',
        'steps': 34,
        'restarts': 7,
        'finished': true,
        'runMoves': 11,
      },
      'smart': {
        'digest': '6910ce4fdf15ed27',
        'steps': 11,
        'restarts': 0,
        'finished': true,
        'runMoves': 11,
      },
    },
    '3300001': {
      'casual': {
        'digest': '54a380ebf61b322e',
        'steps': 16,
        'restarts': 0,
        'finished': true,
        'runMoves': 16,
      },
      'smart': {
        'digest': 'edd1dd0f3d6dc61c',
        'steps': 11,
        'restarts': 0,
        'finished': true,
        'runMoves': 11,
      },
    },
  },
  'expertOnly': {
    '3100001': {
      'casual': {
        'digest': 'e879b6060dd1d738',
        'steps': 23,
        'restarts': 2,
        'finished': true,
        'runMoves': 14,
      },
      'smart': {
        'digest': '7286ccd10dc6110f',
        'steps': 49,
        'restarts': 5,
        'finished': true,
        'runMoves': 13,
      },
    },
    '3200001': {
      'casual': {
        'digest': '261124eaf15d442a',
        'steps': 26,
        'restarts': 0,
        'finished': true,
        'runMoves': 26,
      },
      'smart': {
        'digest': 'b40cb8a886cb316a',
        'steps': 21,
        'restarts': 1,
        'finished': true,
        'runMoves': 14,
      },
    },
    '3300001': {
      'casual': {
        'digest': '42e192a666cd0055',
        'steps': 180,
        'restarts': 28,
        'finished': true,
        'runMoves': 17,
      },
      'smart': {
        'digest': 'b2b07892688f1d08',
        'steps': 21,
        'restarts': 1,
        'finished': true,
        'runMoves': 13,
      },
    },
  },
};

const _dead = <String, Map<String, Object>>{
  'casual': {
    'digest': '4f2a540ffaf64a00',
    'steps': 600,
    'restarts': 300,
    'finished': false,
    'runMoves': 0,
  },
  'smart': {
    'digest': '2ef2920ac7599001',
    'steps': 600,
    'restarts': 300,
    'finished': false,
    'runMoves': 0,
  },
};

const _capped = <String, Map<String, Object>>{
  'casual': {
    'digest': 'da6af534953351d7',
    'steps': 600,
    'restarts': 122,
    'finished': false,
    'runMoves': 3,
  },
  'smart': {
    'digest': 'af8ac83661905829',
    'steps': 600,
    'restarts': 100,
    'finished': false,
    'runMoves': 0,
  },
};
