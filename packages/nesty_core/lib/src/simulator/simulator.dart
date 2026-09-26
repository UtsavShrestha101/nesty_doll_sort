import 'dart:convert';

import 'package:nesty_core/src/codec/level_codec.dart';
import 'package:nesty_core/src/models/level.dart';
import 'package:nesty_core/src/prng/prng.dart';
import 'package:nesty_core/src/rules/engine/board_layout.dart';
import 'package:nesty_core/src/simulator/bots.dart';
import 'package:nesty_core/src/simulator/tier.dart';
import 'package:nesty_core/src/util/hash64.dart';
import 'package:nesty_core/src/util/u32.dart';

/// How the [Simulator] runs (spec §6.4).
final class SimulatorParams {
  const SimulatorParams({
    this.runs = defaultRuns,
    this.moveCap = defaultMoveCap,
    this.seed,
  });

  /// Playthroughs per bot (spec §6.4).
  static const int defaultRuns = 300;

  /// Moves before a playthrough counts as a loss (spec §6.4).
  static const int defaultMoveCap = 250;

  /// Playthroughs per bot, 1 to 2^32 − 1 (each run is a `Prng.derive`
  /// label).
  final int runs;

  /// The most moves a playthrough may make, at least 0. A playthrough that
  /// hasn't won after [moveCap] moves is a loss; one that wins on its
  /// [moveCap]th move is a win.
  final int moveCap;

  /// The simulation seed in [0, `Prng.maxSeed`], or null for
  /// [Simulator.defaultSeed], so the same board always gets the same tier.
  final int? seed;

  @override
  bool operator ==(Object other) =>
      other is SimulatorParams &&
      other.runs == runs &&
      other.moveCap == moveCap &&
      other.seed == seed;

  @override
  int get hashCode => Object.hash(runs, moveCap, seed);

  @override
  String toString() =>
      'SimulatorParams(runs: $runs, moveCap: $moveCap, seed: $seed)';
}

/// One bot's results. Counts are integers so VM and web agree exactly
/// (design §3 "no doubles in determinism-relevant outputs").
final class BotStats {
  const BotStats({required this.runs, required this.wins});

  final int runs;
  final int wins;

  /// `wins / runs`, for display (spec §5.2 `casualWinRate`,
  /// `smartWinRate`).
  double get winRate => runs == 0 ? 0 : wins / runs;

  @override
  bool operator ==(Object other) =>
      other is BotStats && other.runs == runs && other.wins == wins;

  @override
  int get hashCode => Object.hash(runs, wins);

  @override
  String toString() => 'BotStats($wins/$runs)';
}

/// What the [Simulator] measured, and the tier it suggests (spec §6.4).
final class SimulationResult {
  const SimulationResult({
    required this.casual,
    required this.smart,
    required this.tier,
    required this.expertOnly,
    required this.seed,
  });

  /// The result of [casual] and [smart], with [tier] and [expertOnly]
  /// derived from them as spec §6.4 says ([Tier.fromCasualWins],
  /// [isExpertOnly]). [Simulator.run] builds its result this way, so every
  /// result it returns is consistent.
  ///
  /// Throws a [RangeError] when either bot has no runs or more wins than
  /// runs.
  factory SimulationResult.fromStats({
    required BotStats casual,
    required BotStats smart,
    required int seed,
  }) => SimulationResult(
    casual: casual,
    smart: smart,
    tier: Tier.fromCasualWins(casual.wins, casual.runs),
    expertOnly: isExpertOnly(smart),
    seed: seed,
  );

  /// Spec §6.4: a level whose smart win rate is below 0.5 is flagged
  /// "expert only" in the admin. Integer arithmetic (`2·wins < runs`), so a
  /// rate of exactly 0.5 is never flagged on any platform; at 300 runs that
  /// means fewer than 150 wins.
  ///
  /// Throws a [RangeError] when [smart] has no runs or more wins than runs.
  static bool isExpertOnly(BotStats smart) {
    if (smart.runs <= 0) {
      throw RangeError.value(smart.runs, 'smart.runs', 'must be positive');
    }
    RangeError.checkValueInInterval(smart.wins, 0, smart.runs, 'smart.wins');
    return 2 * smart.wins < smart.runs;
  }

  final BotStats casual;
  final BotStats smart;

  /// From the casual win rate: `Tier.fromCasualWins`.
  final Tier tier;

  /// Smart win rate below 0.5: flagged "expert only" in the admin
  /// (spec §6.4).
  final bool expertOnly;

  /// The seed the runs used.
  final int seed;

  @override
  bool operator ==(Object other) =>
      other is SimulationResult &&
      other.casual == casual &&
      other.smart == smart &&
      other.tier == tier &&
      other.expertOnly == expertOnly &&
      other.seed == seed;

  @override
  int get hashCode => Object.hash(casual, smart, tier, expertOnly, seed);

  @override
  String toString() =>
      'SimulationResult(${tier.id}, casual $casual, smart $smart'
      '${expertOnly ? ', expert only' : ''})';
}

/// The difficulty simulator of spec §6.4: a casual and a smart bot each play
/// seeded runs with a move cap, no undo and no extra slots.
///
/// Deterministic on every platform (CLAUDE.md rule 7): run `i` of bot `b`
/// draws from `Prng(Prng.derive(seed, b, i))` with casual = 0 and smart = 1
/// (design §3), every move goes through the rules kernel, and the results
/// are integer counts. The policies are documented on the internal
/// `BotPlayer` (src/simulator/bots.dart). Any change to what a level
/// simulates to changes generated levels, so it needs a `Generator.version`
/// bump (spec §6.5).
abstract final class Simulator {
  /// Simulates [level] from its start and suggests its tier.
  ///
  /// Throws a [RangeError] for [SimulatorParams] out of range, and an
  /// [ArgumentError] for a level the engine can't lay out (see
  /// `GameState.initial`).
  static SimulationResult run(
    Level level, [
    SimulatorParams params = const SimulatorParams(),
  ]) {
    RangeError.checkValueInInterval(params.runs, 1, u32Mask, 'params.runs');
    RangeError.checkNotNegative(params.moveCap, 'params.moveCap');
    final paramSeed = params.seed;
    if (paramSeed != null) {
      RangeError.checkValueInInterval(
        paramSeed,
        0,
        Prng.maxSeed,
        'params.seed',
      );
    }
    final seed = paramSeed ?? defaultSeed(level);
    final player = BotPlayer(BoardLayout.of(level));
    BotStats stats(SimBot bot) => BotStats(
      runs: params.runs,
      wins: player.wins(bot, seed, params.runs, params.moveCap),
    );
    return SimulationResult.fromStats(
      casual: stats(SimBot.casual),
      smart: stats(SimBot.smart),
      seed: seed,
    );
  }

  /// The seed [run] uses when [SimulatorParams.seed] is null: the low 32
  /// bits (`Hash64.lo`) of the hash of the level's board as canonical JSON
  /// (design §3).
  ///
  /// The board is `LevelCodec.encode(level)` restricted to its
  /// `schemaVersion`, `maxSize` and `shelves` entries, in that order, with
  /// no whitespace, hashed as UTF-16 code units. The level's `id`,
  /// `generatorVersion` and `seed` are left out on purpose: they name a
  /// level without changing it, so renaming a level, or the generator
  /// recording its metadata after simulating a candidate, can never move a
  /// board to another tier.
  static int defaultSeed(Level level) {
    final json = LevelCodec.encode(level);
    final board = <String, Object?>{
      for (final key in _boardKeys) key: json[key],
    };
    return Hash64.ofString(jsonEncode(board)).lo;
  }

  // Spec §5.1 keys that describe the board itself, in canonical order.
  static const List<String> _boardKeys = [
    'schemaVersion',
    'maxSize',
    'shelves',
  ];
}
