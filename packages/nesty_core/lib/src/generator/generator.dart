import 'package:nesty_core/src/codec/level_issue.dart';
import 'package:nesty_core/src/generator/generator_params.dart';
import 'package:nesty_core/src/generator/placement.dart';
import 'package:nesty_core/src/generator/segments.dart';
import 'package:nesty_core/src/models/equality.dart';
import 'package:nesty_core/src/models/level.dart';
import 'package:nesty_core/src/prng/prng.dart';
import 'package:nesty_core/src/simulator/simulator.dart';
import 'package:nesty_core/src/simulator/tier.dart';
import 'package:nesty_core/src/solver/solver.dart';
import 'package:nesty_core/src/validator/layout_limits.dart';
import 'package:nesty_core/src/validator/validator.dart';

/// What `Generator.generate` returned.
sealed class GeneratorOutcome {
  const GeneratorOutcome();
}

/// A valid, solvable level (spec §6.5 step 4).
final class GeneratorSuccess extends GeneratorOutcome {
  const GeneratorSuccess({
    required this.level,
    required this.solve,
    required this.simulation,
    required this.attempt,
    required this.tierMatched,
  });

  /// The level, with `generatorVersion` and `seed` recorded (spec §6.5).
  final Level level;

  /// Its admin-budget solve (always [SolveVerdict.solved]).
  final SolveResult solve;

  /// Its simulation; `simulation.tier` is the level's tier.
  ///
  /// `simulation.expertOnly` is spec §6.4's "expert only" flag (the smart
  /// bot wins fewer than half its runs). The generator does not reject such
  /// a level: §6.5 step 4 matches on tier only, and §6.4 asks for the flag
  /// "in the admin". A device-generated level (Bonus Endless, the daily)
  /// has no admin, so what the game does with the flag is the app's policy
  /// (an owner question, docs/PROGRESS.md; about 2 of bonus levels 1–100
  /// carry it today, bonus 40 and 99).
  final SimulationResult simulation;

  /// The 0-based attempt (sub-seed) that produced it.
  final int attempt;

  /// False when no attempt hit the target tier and this is the closest
  /// solvable one (design A15).
  final bool tierMatched;

  @override
  bool operator ==(Object other) =>
      other is GeneratorSuccess &&
      other.level == level &&
      other.solve == solve &&
      other.simulation == simulation &&
      other.attempt == attempt &&
      other.tierMatched == tierMatched;

  @override
  int get hashCode =>
      Object.hash(level, solve, simulation, attempt, tierMatched);

  @override
  String toString() =>
      'GeneratorSuccess(${level.id}, attempt $attempt, '
      '${simulation.tier.id}${tierMatched ? '' : ' (closest)'})';
}

/// No level: the params are invalid, or no attempt was solvable
/// (design A14). The app's policy is to retry with the next seed.
final class GeneratorFailure extends GeneratorOutcome {
  GeneratorFailure({required List<LevelIssue> issues, required this.attempts})
    : issues = List.unmodifiable(issues);

  /// Why: `Generator.checkParams` issues, or `gen.noSolvableLevel`.
  final List<LevelIssue> issues;

  /// Attempts made (0 when the params were rejected up front).
  final int attempts;

  @override
  bool operator ==(Object other) =>
      other is GeneratorFailure &&
      other.attempts == attempts &&
      listEquals(other.issues, issues);

  @override
  int get hashCode => Object.hash(attempts, Object.hashAll(issues));

  @override
  String toString() => 'GeneratorFailure(attempts $attempts, $issues)';
}

/// The deterministic level generator of spec §6.5.
///
/// The same params give byte-identical output on every platform
/// (CLAUDE.md rule 7). Any change that alters output bumps [version], because
/// daily puzzles must match across devices (spec §7.5, M3).
///
/// The pipeline, for attempt `i` = 0, 1, … up to [maxAttempts] − 1, each
/// drawing only from its own stream `Prng(Prng.derive(seed, i))`:
/// 1. Colors: `colors` of the 10 non-gold colors (design A11).
/// 2. Sets and segments (spec §6.5 step 1): `colors × setsPerColor` full
///    sets, each cut into 2..maxSize consecutive segments (design A10) so
///    that the segments exactly fill the occupied slots.
/// 3. Slot roles and the deal (step 2): towers, empty and occupied open
///    slots, then the segments shuffled onto them with the tower-top limit
///    (design A13).
/// 4. Locks and ice (step 3) on occupied slots (design A12, rule 6).
/// 5. Rules 1–8 with the admin budget (step 4), then the simulator.
/// The first attempt whose simulated tier is `targetTier` wins. Otherwise
/// the closest solvable attempt is returned (design A15), and when no
/// attempt was solvable, a [GeneratorFailure] (design A14). The draws of
/// each stage are documented in `segments.dart` and `placement.dart`.
///
/// Synchronous and CPU-bound: the game calls it from its solver isolate and
/// the admin between frames (CLAUDE.md rule 8).
abstract final class Generator {
  /// The pipeline version recorded as `generatorVersion` (spec §6.5). It
  /// covers the PRNG, the solver, the simulator and the curve (design §3).
  static const int version = 1;

  /// Sub-seed attempts before settling for the closest tier (spec §6.5).
  static const int maxAttempts = 50;

  /// The most full sets per color [checkParams] accepts: a board holds at
  /// most 20 slots of 4 nests, and every set needs 2 of them (design A10).
  static const int maxSetsPerColor =
      LayoutLimits.maxShelves *
      LayoutLimits.maxSlotsPerShelf *
      LayoutLimits.maxTowerDepth ~/
      2;

  /// The level id used when `GeneratorParams.id` is null: `gen-<seed>`.
  static String defaultId(int seed) => 'gen-$seed';

  /// Seeds [generateWithRetries] tries after the params' own seed fails
  /// (docs/plans/m3-design.md §5).
  static const int maxRetries = 3;

  /// The stream label of the retry seeds: `'RETR'` as a big-endian u32.
  static const int retryStream = 0x52455452;

  /// The seed of retry [retry] (0..[maxRetries]) of [seed]: [seed] itself
  /// for retry 0, then `Prng.derive(seed, retryStream, retry)`, a u32. Pure
  /// integer arithmetic through the core PRNG, so every device derives the
  /// same retry seeds (spec §7.5, CLAUDE.md rule 7). Throws a [RangeError]
  /// for a seed outside [0, `Prng.maxSeed`] or a retry outside
  /// 0..[maxRetries].
  static int retrySeed(int seed, int retry) {
    RangeError.checkValueInInterval(seed, 0, Prng.maxSeed, 'seed');
    RangeError.checkValueInInterval(retry, 0, maxRetries, 'retry');
    return retry == 0 ? seed : Prng.derive(seed, retryStream, retry);
  }

  /// [generate], retried with [retrySeed] 1..[maxRetries] while it returns
  /// a [GeneratorFailure] (design A14: "the app's policy is to retry with
  /// the next seed"; docs/plans/m3-design.md §5). The first
  /// [GeneratorSuccess] wins; its level records the seed that produced it
  /// and keeps `params.id`. When every seed fails, the last failure is
  /// returned; params that fail [checkParams] fail at once, since another
  /// seed can't fix them.
  ///
  /// A seed that succeeds on its first try gives exactly [generate]'s
  /// output, so the bonus and daily goldens are unchanged by the wrapper.
  static GeneratorOutcome generateWithRetries(GeneratorParams params) {
    var outcome = generate(params);
    if (outcome is GeneratorSuccess) return outcome;
    if ((outcome as GeneratorFailure).attempts == 0) return outcome;
    for (var retry = 1; retry <= maxRetries; retry++) {
      outcome = generate(params.withSeed(retrySeed(params.seed, retry)));
      if (outcome is GeneratorSuccess) return outcome;
    }
    return outcome;
  }

  /// Generates a level from [params].
  static GeneratorOutcome generate(GeneratorParams params) {
    final issues = checkParams(params);
    if (issues.isNotEmpty) return GeneratorFailure(issues: issues, attempts: 0);

    _Candidate? closest;
    for (var attempt = 0; attempt < maxAttempts; attempt++) {
      final level = _build(params, attempt);
      if (level == null) continue;
      // Rules 1–8 in one pass: rule 8 runs the admin-budget solve (spec
      // §6.5 step 4 "validate, solve"), and an unproven level is invalid.
      final report = Validator.validate(level);
      final solve = report.solve;
      if (!report.isValid ||
          solve == null ||
          solve.verdict != SolveVerdict.solved) {
        continue;
      }
      final simulation = Simulator.run(level);
      final candidate = _Candidate(
        level: level,
        solve: solve,
        simulation: simulation,
        attempt: attempt,
        target: params.targetTier,
      );
      if (simulation.tier == params.targetTier) {
        return candidate.success(tierMatched: true);
      }
      if (closest == null || candidate.isCloserThan(closest)) {
        closest = candidate;
      }
    }
    if (closest != null) return closest.success(tierMatched: false);
    return GeneratorFailure(
      issues: [
        LevelIssue(
          code: IssueCodes.genNoSolvableLevel,
          message:
              'None of the $maxAttempts attempts gave a valid, solvable '
              'level; try another seed',
          args: {'attempts': maxAttempts},
        ),
      ],
      attempts: maxAttempts,
    );
  }

  /// The board attempt [attempt] of [params] builds (pipeline stages 1–4),
  /// before validation; null when no lock arrangement was found.
  ///
  /// Exposed for tests and the level tools, which inspect every attempt.
  /// Throws an [ArgumentError] when [params] fail [checkParams], and a
  /// [RangeError] unless `0 <= attempt < maxAttempts`.
  static Level? buildAttempt(GeneratorParams params, int attempt) {
    RangeError.checkValueInInterval(attempt, 0, maxAttempts - 1, 'attempt');
    final issues = checkParams(params);
    if (issues.isNotEmpty) {
      throw ArgumentError.value(params, 'params', issues.join('; '));
    }
    return _build(params, attempt);
  }

  // buildAttempt for params that passed checkParams.
  static Level? _build(GeneratorParams params, int attempt) {
    final prng = Prng(Prng.derive(params.seed, attempt));
    final lengths = shelfLengths(params.shelves, params.slotsPerShelf);
    final slotCount = lengths.fold(0, (sum, n) => sum + n);
    final towerDepth = params.towers == 0 ? 0 : params.towerDepth;
    final occupiedOpen = slotCount - params.towers - params.emptySlots;
    final segmentCount = occupiedOpen + params.towers * towerDepth;

    final colors = chooseColors(prng, params.colors);
    final segments = cutSets(
      prng,
      colors,
      params.setsPerColor,
      params.maxSize,
      segmentCount,
    );
    final roles = assignRoles(
      prng,
      slotCount,
      params.towers,
      params.emptySlots,
    );
    final plan = dealSegments(
      prng,
      segments,
      roles,
      lengths,
      towerDepth,
      params.maxSize,
    );
    final locksPlaced = placeLocks(
      prng,
      plan,
      roles.occupiedOpen,
      colors,
      params.setsPerColor,
      params.locked,
    );
    if (!locksPlaced) return null;
    placeIce(prng, plan, params.iceSlots, params.colors * params.setsPerColor);
    return plan.toLevel(
      id: params.id ?? defaultId(params.seed),
      maxSize: params.maxSize,
      generatorVersion: version,
      seed: params.seed,
    );
  }

  /// Problems with [params] that make generation impossible; empty when
  /// they're usable.
  ///
  /// Checked in order, stopping after the first group with a problem,
  /// because later checks are only meaningful once earlier ones pass:
  /// 1. Each param's own range (`gen.paramOutOfRange`; a bad id is
  ///    `level.badId`). The board has `(shelves − 1) · slotsPerShelf +
  ///    min(slotsPerShelf, 4)` slots, since the bottom shelf keeps room for
  ///    both extra slots (owner override D22). `towerDepth` is checked only
  ///    when there are towers.
  /// 2. Towers plus empty slots fit the board (`gen.slotsInfeasible`).
  /// 3. The segments fill the occupied slots: `2·sets ≤ capacity ≤
  ///    maxSize·sets`, with capacity = occupied open slots + towers ×
  ///    towerDepth (`gen.segmentsInfeasible`, design §3).
  /// 4. Locks fit on occupied open slots, and with one set per color need a
  ///    second color to open on (rule 6); ice fits on the other occupied
  ///    slots and needs at least 2 sets (design A12).
  static List<LevelIssue> checkParams(GeneratorParams params) {
    final issues = <LevelIssue>[];
    void range(String param, int value, int min, int max) {
      if (value >= min && value <= max) return;
      issues.add(
        LevelIssue(
          code: IssueCodes.genParamOutOfRange,
          message: '$param $value is outside $min–$max',
          path: LevelIssue.pointer([param]),
          args: {'param': param, 'value': value, 'min': min, 'max': max},
        ),
      );
    }

    // Group 1: ranges.
    range('colors', params.colors, 1, generatorPalette.length);
    range('setsPerColor', params.setsPerColor, 1, maxSetsPerColor);
    range(
      'maxSize',
      params.maxSize,
      LayoutLimits.minMaxSize,
      LayoutLimits.maxMaxSize,
    );
    range(
      'shelves',
      params.shelves,
      LayoutLimits.minShelves,
      LayoutLimits.maxShelves,
    );
    range(
      'slotsPerShelf',
      params.slotsPerShelf,
      LayoutLimits.minSlotsPerShelf,
      LayoutLimits.maxSlotsPerShelf,
    );
    if (params.towers != 0) {
      range('towerDepth', params.towerDepth, 1, LayoutLimits.maxTowerDepth);
    }
    range('seed', params.seed, 0, Prng.maxSeed);
    final id = params.id;
    if (id != null &&
        (id.isEmpty || id.length > LayoutLimits.maxLevelIdLength)) {
      issues.add(
        LevelIssue(
          code: IssueCodes.badId,
          message:
              'The level id must be 1–${LayoutLimits.maxLevelIdLength} '
              'characters (got ${id.length})',
          path: LevelIssue.pointer(const ['id']),
          args: {'id': id, 'maxLength': LayoutLimits.maxLevelIdLength},
        ),
      );
    }
    final shapeValid = issues.isEmpty;
    final slotCount = shapeValid
        ? shelfLengths(
            params.shelves,
            params.slotsPerShelf,
          ).fold(0, (sum, n) => sum + n)
        : LayoutLimits.maxShelves * LayoutLimits.maxSlotsPerShelf;
    range('towers', params.towers, 0, slotCount);
    range('emptySlots', params.emptySlots, 0, slotCount);
    range('locked', params.locked, 0, slotCount);
    range('iceSlots', params.iceSlots, 0, slotCount);
    if (issues.isNotEmpty) return issues;

    // Group 2: the slot roles fit the board.
    final needed = params.towers + params.emptySlots;
    if (needed > slotCount) {
      return [
        LevelIssue(
          code: IssueCodes.genSlotsInfeasible,
          message:
              '${params.towers} towers and ${params.emptySlots} empty slots '
              'need $needed slots, but the board has $slotCount',
          args: {'needed': needed, 'available': slotCount},
        ),
      ];
    }

    // Group 3: the segments fill the occupied slots (design §3, A10).
    final occupiedOpen = slotCount - needed;
    final capacity = occupiedOpen + params.towers * params.towerDepth;
    final sets = params.colors * params.setsPerColor;
    final minCapacity = 2 * sets;
    final maxCapacity = params.maxSize * sets;
    if (capacity < minCapacity || capacity > maxCapacity) {
      return [
        LevelIssue(
          code: IssueCodes.genSegmentsInfeasible,
          message:
              'The occupied slots hold $capacity nests, but $sets sets of '
              'maxSize ${params.maxSize} cut into 2–${params.maxSize} '
              'segments each make $minCapacity–$maxCapacity',
          args: {'capacity': capacity, 'min': minCapacity, 'max': maxCapacity},
        ),
      ];
    }

    // Group 4: locks and ice (spec §6.5 step 3).
    range('locked', params.locked, 0, occupiedOpen);
    if (params.locked > 0 && params.setsPerColor == 1) {
      range('colors', params.colors, 2, generatorPalette.length);
    }
    final lockedSlots = params.locked < occupiedOpen
        ? params.locked
        : occupiedOpen;
    final maxIce = sets < 2 ? 0 : occupiedOpen + params.towers - lockedSlots;
    range('iceSlots', params.iceSlots, 0, maxIce);
    return issues;
  }
}

/// A solvable attempt, with what is needed to rank it against the target
/// tier (design A15).
final class _Candidate {
  _Candidate({
    required this.level,
    required this.solve,
    required this.simulation,
    required this.attempt,
    required Tier target,
  }) : tierDistance = simulation.tier.distanceTo(target),
       centreDistance = _centreDistance(simulation.casual, target);

  final Level level;
  final SolveResult solve;
  final SimulationResult simulation;
  final int attempt;

  /// Tiers between the simulated tier and the target.
  final int tierDistance;

  /// Twice the distance of the casual win count from the middle of the
  /// target tier's band of win counts, so it stays an integer.
  final int centreDistance;

  /// Design A15: fewer tiers away, then nearer the target band's centre;
  /// the earlier attempt wins a tie, so only a strictly closer one replaces
  /// it.
  bool isCloserThan(_Candidate other) {
    if (tierDistance != other.tierDistance) {
      return tierDistance < other.tierDistance;
    }
    return centreDistance < other.centreDistance;
  }

  GeneratorSuccess success({required bool tierMatched}) => GeneratorSuccess(
    level: level,
    solve: solve,
    simulation: simulation,
    attempt: attempt,
    tierMatched: tierMatched,
  );

  /// `|2·wins − (lo + hi)|`, where `lo..hi` are the casual win counts
  /// `Tier.fromCasualWins` maps to [target] at the same number of runs. The
  /// band is read from `Tier` itself, so the edges are stated once.
  static int _centreDistance(BotStats casual, Tier target) {
    var lo = -1;
    var hi = -1;
    for (var wins = 0; wins <= casual.runs; wins++) {
      if (Tier.fromCasualWins(wins, casual.runs) != target) continue;
      if (lo < 0) lo = wins;
      hi = wins;
    }
    // A target no win count reaches (only at very few runs): rank by
    // tier distance and attempt alone.
    if (lo < 0) return 0;
    return (2 * casual.wins - (lo + hi)).abs();
  }
}
