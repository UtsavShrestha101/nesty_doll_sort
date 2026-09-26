// Spec §6.4: "Run two bots, each for 300 seeded playthroughs with a 250-move
// cap … Tier from casual win rate: easy ≥ 0.65, medium 0.35–0.65, hard
// 0.12–0.35, superhard < 0.12. Every level must have a smart win rate ≥ 0.5
// or be flagged 'expert only' in the admin."
// Design §3: run seed Prng.derive(simSeed, bot, i); default simSeed = the
// low 32 bits of Hash64(canonical level JSON); loss on OutOfMoves or the cap;
// no undo or extra slots. A18: lower tier edges inclusive (195, 105, 36 at
// 300 runs).
import 'dart:convert';

import 'package:nesty_core/nesty_core.dart';
import 'package:nesty_core/src/rules/engine/board_layout.dart';
import 'package:nesty_core/src/simulator/bots.dart';
import 'package:nesty_core/src/util/hash64.dart';
import 'package:test/test.dart';

import 'support/sim_levels.dart';

/// Wins per run of [bot] on [level] at [seed]: the runs the simulator
/// counts, played one at a time.
List<bool> _runOutcomes(Level level, SimBot bot, int seed, int runs) {
  final player = BotPlayer(BoardLayout.of(level));
  return [
    for (var run = 0; run < runs; run++)
      player.play(
        bot,
        Prng(Prng.derive(seed, bot.index, run)),
        SimulatorParams.defaultMoveCap,
      ),
  ];
}

void main() {
  group('SimulatorParams validation', () {
    final level = simLevel('tutorial');

    for (final (name, params) in [
      ('runs 0', const SimulatorParams(runs: 0)),
      ('runs −1', const SimulatorParams(runs: -1)),
      ('runs 2^32', const SimulatorParams(runs: 0x100000000)),
      ('moveCap −1', const SimulatorParams(moveCap: -1)),
      ('seed −1', const SimulatorParams(seed: -1)),
      ('seed 2^53', const SimulatorParams(seed: Prng.maxSeed + 1)),
    ]) {
      test('rejects $name with a RangeError', () {
        expect(() => Simulator.run(level, params), throwsRangeError);
      });
    }

    test('accepts the edges: 1 run, a 0-move cap, seeds 0 and 2^53 − 1', () {
      expect(
        Simulator.run(level, const SimulatorParams(runs: 1)).casual.runs,
        1,
      );
      final capped = Simulator.run(level, const SimulatorParams(moveCap: 0));
      expect(capped.casual.wins + capped.smart.wins, 0);
      expect(Simulator.run(level, const SimulatorParams(seed: 0)).seed, 0);
      expect(
        Simulator.run(
          level,
          const SimulatorParams(seed: Prng.maxSeed, runs: 3),
        ).seed,
        Prng.maxSeed,
      );
    });
  });

  group('defaultSeed (design §3)', () {
    test('is Hash64.lo of the board as canonical §5.1 JSON', () {
      // Written out by hand in the canonical key order of design A20, so a
      // codec change that alters the bytes fails here.
      const board =
          '{"schemaVersion":1,"maxSize":3,"shelves":['
          '[{"type":"open","nest":["red3"]},{"type":"open","nest":null},'
          '{"type":"open","nest":["red2"]}],'
          '[{"type":"open","nest":null},{"type":"open","nest":["red1"]},'
          '{"type":"open","nest":null}]]}';
      expect(
        Simulator.defaultSeed(simLevel('tutorial')),
        Hash64.ofString(board).lo,
      );
    });

    test('keeps the §5.1 key order for towers, locks and ice', () {
      final level = simLevel('spec');
      final json = LevelCodec.encode(level);
      final board = jsonEncode({
        'schemaVersion': json['schemaVersion'],
        'maxSize': json['maxSize'],
        'shelves': json['shelves'],
      });
      expect(board, contains('{"type":"locked","unlockColor":"red","nest":'));
      expect(board, contains('"nest":["blue4","blue3"],"ice":2}'));
      expect(Simulator.defaultSeed(level), Hash64.ofString(board).lo);
    });

    test('ignores id, generatorVersion and seed: they name a board, '
        'not change it', () {
      final level = simLevel('medium1');
      final renamed = Level(
        id: 'another-id',
        maxSize: level.maxSize,
        shelves: level.shelves,
        generatorVersion: 7,
        seed: 1000042,
      );
      expect(Simulator.defaultSeed(renamed), Simulator.defaultSeed(level));
      expect(Simulator.run(renamed), Simulator.run(level));
    });

    test('changes with the board', () {
      final seeds = {
        for (final name in simLevelJson.keys)
          Simulator.defaultSeed(simLevel(name)),
      };
      expect(seeds, hasLength(simLevelJson.length));
      final level = simLevel('tutorial');
      final iced = Level(
        id: level.id,
        maxSize: level.maxSize,
        shelves: [
          [
            OpenSlot(nest: Nest.run(DollColor.red, outer: 3, length: 1)),
            OpenSlot(ice: 1),
            level.shelves[0][2],
          ],
          level.shelves[1],
        ],
      );
      expect(Simulator.defaultSeed(iced), isNot(Simulator.defaultSeed(level)));
    });

    test('is a u32, and is the seed a default run reports', () {
      for (final name in simLevelJson.keys) {
        final level = simLevel(name);
        final seed = Simulator.defaultSeed(level);
        expect(seed, inInclusiveRange(0, 0xFFFFFFFF));
        expect(Simulator.run(level, const SimulatorParams(runs: 5)).seed, seed);
      }
    });
  });

  group('results', () {
    for (final name in simLevelJson.keys) {
      test('$name: counts, tier and expertOnly agree (spec §6.4)', () {
        final result = Simulator.run(simLevel(name));
        expect(result.casual.runs, 300);
        expect(result.smart.runs, 300);
        expect(result.casual.wins, inInclusiveRange(0, 300));
        expect(result.smart.wins, inInclusiveRange(0, 300));
        expect(result.tier, Tier.fromCasualWins(result.casual.wins, 300));
        expect(result.expertOnly, result.smart.wins < 150);
        expect(
          result,
          SimulationResult.fromStats(
            casual: result.casual,
            smart: result.smart,
            seed: result.seed,
          ),
        );
      });
    }

    test('the test levels span every tier', () {
      final tiers = {
        for (final name in [
          'tutorial',
          'medium1',
          'hard1',
          'superhard1',
          'expertOnly',
        ])
          name: Simulator.run(simLevel(name)).tier,
      };
      expect(tiers, {
        'tutorial': Tier.easy,
        'medium1': Tier.medium,
        'hard1': Tier.hard,
        'superhard1': Tier.superhard,
        'expertOnly': Tier.superhard,
      });
      expect(Simulator.run(simLevel('expertOnly')).expertOnly, isTrue);
      expect(Simulator.run(simLevel('superhard2')).expertOnly, isFalse);
    });

    for (final name in unsolvableSimLevels) {
      test('$name (unsolvable) is never won: superhard, expert only', () {
        final result = Simulator.run(simLevel(name));
        expect(result.casual, const BotStats(runs: 300, wins: 0));
        expect(result.smart, const BotStats(runs: 300, wins: 0));
        expect(result.tier, Tier.superhard);
        expect(result.expertOnly, isTrue);
      });
    }

    test('the smart bot wins at least as often as the casual bot here', () {
      for (final name in simLevelJson.keys) {
        final result = Simulator.run(simLevel(name));
        expect(
          result.smart.wins,
          greaterThanOrEqualTo(result.casual.wins),
          reason: name,
        );
      }
    });

    test('runs sets the playthroughs per bot', () {
      final result = Simulator.run(
        simLevel('medium1'),
        const SimulatorParams(runs: 17),
      );
      expect(result.casual.runs, 17);
      expect(result.smart.runs, 17);
    });
  });

  group('determinism (CLAUDE.md rule 7)', () {
    test('the same level and params give the same result', () {
      for (final name in simLevelJson.keys) {
        expect(
          Simulator.run(simLevel(name)),
          Simulator.run(simLevel(name)),
          reason: name,
        );
      }
    });

    test('an explicit seed equal to the default gives the default result', () {
      final level = simLevel('hard1');
      expect(
        Simulator.run(
          level,
          SimulatorParams(seed: Simulator.defaultSeed(level)),
        ),
        Simulator.run(level),
      );
    });

    test('the seed matters', () {
      final level = simLevel('medium1');
      final casualWins = {
        for (var seed = 0; seed < 8; seed++)
          Simulator.run(level, SimulatorParams(seed: seed)).casual.wins,
      };
      expect(casualWins.length, greaterThan(1));
    });

    test('run i of bot b is seeded with Prng.derive(seed, b, i)', () {
      for (final name in ['medium1', 'superhard2', 'expertOnly']) {
        final level = simLevel(name);
        final seed = Simulator.defaultSeed(level);
        final result = Simulator.run(level);
        expect(
          _runOutcomes(level, SimBot.casual, seed, 300).where((w) => w).length,
          result.casual.wins,
          reason: name,
        );
        expect(
          _runOutcomes(level, SimBot.smart, seed, 300).where((w) => w).length,
          result.smart.wins,
          reason: name,
        );
      }
    });

    test('fewer runs are a prefix of more runs', () {
      final level = simLevel('medium2');
      final seed = Simulator.defaultSeed(level);
      final outcomes = _runOutcomes(level, SimBot.casual, seed, 300);
      for (final runs in [1, 10, 100, 299]) {
        expect(
          Simulator.run(level, SimulatorParams(runs: runs)).casual.wins,
          outcomes.take(runs).where((w) => w).length,
        );
      }
    });

    test('the bots use separate streams: casual 0, smart 1', () {
      expect(SimBot.casual.index, 0);
      expect(SimBot.smart.index, 1);
    });
  });

  group('move cap (spec §6.4)', () {
    test('the tutorial needs 2 moves: cap 1 loses every run', () {
      final level = simLevel('tutorial');
      final one = Simulator.run(level, const SimulatorParams(moveCap: 1));
      expect(one.casual.wins, 0);
      expect(one.smart.wins, 0);
      final two = Simulator.run(level, const SimulatorParams(moveCap: 2));
      expect(two.smart.wins, 300, reason: 'the smart bot plays it optimally');
      expect(two.casual.wins, lessThanOrEqualTo(300));
    });

    test('a run that wins within a cap also wins within a larger one', () {
      final level = simLevel('medium1');
      var previous = -1;
      for (final cap in [0, 3, 6, 10, 20, 40, 250]) {
        final result = Simulator.run(level, SimulatorParams(moveCap: cap));
        expect(result.casual.wins, greaterThanOrEqualTo(previous));
        previous = result.casual.wins;
      }
    });

    test('a win on exactly the cap-th move counts', () {
      final level = simLevel('tutorial');
      final player = BotPlayer(BoardLayout.of(level));
      var moves = 0;
      final won = player.play(SimBot.smart, Prng(1), 2, (_, _) => moves++);
      expect(won, isTrue);
      expect(moves, 2);
    });
  });

  group('SimulationResult.fromStats', () {
    BotStats casual(int wins) => BotStats(runs: 300, wins: wins);
    const smart = BotStats(runs: 300, wins: 300);

    for (final (wins, tier) in [
      (300, Tier.easy),
      (195, Tier.easy),
      (194, Tier.medium),
      (105, Tier.medium),
      (104, Tier.hard),
      (36, Tier.hard),
      (35, Tier.superhard),
      (0, Tier.superhard),
    ]) {
      test('casual $wins/300 → ${tier.id} (A18)', () {
        final result = SimulationResult.fromStats(
          casual: casual(wins),
          smart: smart,
          seed: 9,
        );
        expect(result.tier, tier);
        expect(result.casual, casual(wins));
        expect(result.smart, smart);
        expect(result.seed, 9);
      });
    }

    test('every casual count gets Tier.fromCasualWins', () {
      for (var wins = 0; wins <= 300; wins++) {
        expect(
          SimulationResult.fromStats(
            casual: casual(wins),
            smart: smart,
            seed: 0,
          ).tier,
          Tier.fromCasualWins(wins, 300),
        );
      }
    });

    for (final (wins, expertOnly) in [
      (300, false),
      (150, false),
      (149, true),
      (0, true),
    ]) {
      test('smart $wins/300 → expertOnly $expertOnly (rate < 0.5)', () {
        final result = SimulationResult.fromStats(
          casual: casual(300),
          smart: BotStats(runs: 300, wins: wins),
          seed: 0,
        );
        expect(result.expertOnly, expertOnly);
      });
    }

    test('isExpertOnly compares rates exactly for any run count', () {
      expect(
        SimulationResult.isExpertOnly(const BotStats(runs: 3, wins: 1)),
        isTrue,
      );
      expect(
        SimulationResult.isExpertOnly(const BotStats(runs: 3, wins: 2)),
        isFalse,
      );
      expect(
        SimulationResult.isExpertOnly(const BotStats(runs: 1, wins: 0)),
        isTrue,
      );
      expect(
        SimulationResult.isExpertOnly(const BotStats(runs: 2, wins: 1)),
        isFalse,
      );
    });

    test('rejects impossible stats', () {
      expect(
        () => SimulationResult.fromStats(
          casual: const BotStats(runs: 0, wins: 0),
          smart: smart,
          seed: 0,
        ),
        throwsRangeError,
      );
      expect(
        () => SimulationResult.fromStats(
          casual: casual(10),
          smart: const BotStats(runs: 0, wins: 0),
          seed: 0,
        ),
        throwsRangeError,
      );
      expect(
        () => SimulationResult.fromStats(
          casual: casual(301),
          smart: smart,
          seed: 0,
        ),
        throwsRangeError,
      );
      expect(
        () => SimulationResult.fromStats(
          casual: casual(1),
          smart: const BotStats(runs: 300, wins: -1),
          seed: 0,
        ),
        throwsRangeError,
      );
    });
  });
}
