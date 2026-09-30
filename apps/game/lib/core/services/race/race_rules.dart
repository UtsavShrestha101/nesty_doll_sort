import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:nesty_core/nesty_core.dart' show DifficultyCurve, Prng;
import 'package:nesty_game/core/flavor/flavor.dart';
import 'package:nesty_game/core/flavor/flavor_config.dart';
import 'package:nesty_game/core/services/remote_config/remote_config_keys.dart';
import 'package:nesty_game/core/services/remote_config/remote_config_service.dart';

/// The app's part of vs Computer (spec-prop §7.7; docs/plans/m7-design.md
/// P2.5, P2.7): when the mode opens, the stage of a race's board, the pace
/// and its jitter, and the reward. Pure rules with no interface, like
/// `MilestoneChest`.
///
/// Core owns the rival's policy, its restart rule, the race seed and the
/// board's params (`RivalBot`, `DifficultyCurve.raceSeed`/`raceParams`,
/// CLAUDE.md rule 2). The pace is time, which core never reads (rule 7):
/// its Remote Config values (rule 6) and the jitter drawn from the race's
/// own seeded stream live here.
abstract final class RaceRules {
  /// The stream label of a race's pace jitter, `'PACE'` as a big-endian
  /// u32: the pace draws from `Prng(Prng.derive(raceSeed, paceStream))`
  /// ([pacePrng]), apart from the board's attempts (0–49), the generator's
  /// `'RETR'` and the rival's `'RVL0'`/`'RVL1'` runs.
  static const int paceStream = 0x50414345;

  /// The most running time one frame adds to a race (m7-design P2.5): a
  /// stalled frame, a debugger pause or a frame after the app comes back
  /// never counts as more than this, so the rival never gets a burst of
  /// moves the player didn't see coming.
  static const Duration maxFrameDelta = Duration(milliseconds: maxFrameDeltaMs);

  /// [maxFrameDelta] in milliseconds, for the race clock's integer
  /// arithmetic (`RaceCubit`'s frame tick allocates nothing, rule 8).
  static const int maxFrameDeltaMs = 250;

  /// The longest pace this clamps a tuned value to (an hour): past it,
  /// the jitter's range would not fit the PRNG's bound.
  static const int maxPaceMs = 3600000;

  /// The raw `NESTY_RACE_PACE_MS` define (README "Testing"): a dev debug
  /// build's pace for every rival, so the device playthrough can win a race
  /// by playing the solver's moves. `''` when it isn't set.
  static const String paceDefine = String.fromEnvironment('NESTY_RACE_PACE_MS');

  static final int? _paceOverride = parsePaceOverride(
    paceDefine,
    debug: kDebugMode,
    flavor: _flavor(),
  );

  /// Spec-prop §7.7 "Unlock: after winning level `race_unlock_level`":
  /// [highestLevel] (the next level to play) is past it. `HomeState.
  /// raceUnlocked` reads the same.
  static bool modeUnlocked(int highestLevel, RemoteConfigService config) =>
      highestLevel > config.value(RemoteConfigKeys.raceUnlockLevel);

  /// The campaign level whose stage a race's board takes (spec-prop §7.7
  /// "at the stage of the player's highest level"): the highest level
  /// won, `highestLevel − 1` (at least 1), since `highestLevel` is the next
  /// one to play and its stage's mechanic may not have been met yet (the
  /// default of an owner question, m7-design P2.14).
  static int stageLevel(int highestLevel) =>
      math.max(1, math.min(highestLevel - 1, DifficultyCurve.maxLevelNumber));

  /// Milliseconds per rival move, `race_pace_ms_<rival>` (3000 / 2400 /
  /// 1600), clamped to 0..[maxPaceMs]. A dev debug build's
  /// `NESTY_RACE_PACE_MS` replaces it for every rival. Throws a
  /// [RangeError] for a rival outside 1–3.
  static int paceMs(int rival, RemoteConfigService config) {
    final key = switch (rival) {
      1 => RemoteConfigKeys.racePaceMs1,
      2 => RemoteConfigKeys.racePaceMs2,
      3 => RemoteConfigKeys.racePaceMs3,
      _ => throw RangeError.range(rival, 1, 3, 'rival'),
    };
    return (_paceOverride ?? config.value(key)).clamp(0, maxPaceMs);
  }

  /// `race_pace_jitter_pct` (20), clamped to 0..100.
  static int jitterPct(RemoteConfigService config) =>
      config.value(RemoteConfigKeys.racePaceJitterPct).clamp(0, 100);

  /// Coins a win against [rival] pays, `race_reward_<rival>` (20 / 30 /
  /// 40), never below 0 (spec-prop §7.7 "A win pays the rival's
  /// `race_reward_n`"). Throws a [RangeError] for a rival outside 1–3.
  static int rewardCoins(int rival, RemoteConfigService config) {
    final key = switch (rival) {
      1 => RemoteConfigKeys.raceReward1,
      2 => RemoteConfigKeys.raceReward2,
      3 => RemoteConfigKeys.raceReward3,
      _ => throw RangeError.range(rival, 1, 3, 'rival'),
    };
    return math.max(0, config.value(key));
  }

  /// The pace stream of the race seeded [raceSeed]
  /// (`DifficultyCurve.raceSeed`): a Rematch, which keeps the seed, draws
  /// the same intervals (spec-prop §7.7 "the same rival moves").
  static Prng pacePrng(int raceSeed) => Prng(Prng.derive(raceSeed, paceStream));

  /// The next interval between two rival moves (spec-prop §7.7 "Each
  /// interval varies by up to `race_pace_jitter_pct` from the race's seeded
  /// PRNG"): `paceMs + d`, with `d` drawn uniformly from `−span..span` and
  /// `span = paceMs × jitterPct ~/ 100`, in integers only. One draw per
  /// call, even with no jitter, so the stream's position never depends on
  /// a tuned value. [paceMs] is clamped to 0..[maxPaceMs] and [jitterPct]
  /// to 0..100, so the result is never negative.
  static int nextIntervalMs(Prng pace, int paceMs, int jitterPct) {
    final base = paceMs.clamp(0, maxPaceMs);
    final span = base * jitterPct.clamp(0, 100) ~/ 100;
    return base + pace.nextIntBetween(-span, span);
  }

  /// The pace override [define] gives in a build that is [debug] and of
  /// [flavor]: only a dev debug build honours it, and only for a whole
  /// number of milliseconds ≥ 0 (as `SystemClock.parseFakeDate` does for
  /// `NESTY_FAKE_DATE`).
  @visibleForTesting
  static int? parsePaceOverride(
    String define, {
    required bool debug,
    required Flavor? flavor,
  }) {
    if (!debug || flavor != Flavor.dev) return null;
    final value = int.tryParse(define);
    return value == null || value < 0 ? null : value;
  }

  static Flavor? _flavor() {
    try {
      return FlavorConfig.flavor;
    } on StateError {
      // `lib/main_<flavor>.dart` sets the flavor before DI; only a test that
      // runs without one gets here.
      return null;
    }
  }
}
