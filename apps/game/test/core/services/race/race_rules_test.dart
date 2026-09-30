import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_core/nesty_core.dart' show DifficultyCurve, Prng;
import 'package:nesty_game/core/flavor/flavor.dart';
import 'package:nesty_game/core/services/race/race_rules.dart';
import 'package:nesty_game/core/services/remote_config/fake_remote_config_service.dart';
import 'package:nesty_game/core/services/remote_config/remote_config_keys.dart';

/// Full coverage of [RaceRules] (docs/plans/m7-design.md P2.5, P2.13):
/// every clamp, [RaceRules.stageLevel] at the stage boundaries,
/// [RaceRules.nextIntervalMs]'s range, one-draw-per-call and determinism,
/// and the dev-debug pace override.
void main() {
  late FakeRemoteConfigService config;

  setUp(() => config = FakeRemoteConfigService());

  group('modeUnlocked', () {
    test('the default race_unlock_level is 20: unlocked past it', () {
      expect(RaceRules.modeUnlocked(20, config), isFalse);
      expect(RaceRules.modeUnlocked(21, config), isTrue);
    });

    test('follows a tuned race_unlock_level', () {
      config.setOverride(RemoteConfigKeys.raceUnlockLevel, 5);
      expect(RaceRules.modeUnlocked(5, config), isFalse);
      expect(RaceRules.modeUnlocked(6, config), isTrue);
    });
  });

  group('stageLevel', () {
    test('is highestLevel - 1, at least 1 (m7-design P2.14 Q125)', () {
      expect(RaceRules.stageLevel(1), 1);
      expect(RaceRules.stageLevel(2), 1);
      expect(RaceRules.stageLevel(22), 21);
      expect(RaceRules.stageLevel(32), 31);
      expect(RaceRules.stageLevel(52), 51);
      expect(RaceRules.stageLevel(72), 71);
    });

    test('clamps to DifficultyCurve.maxLevelNumber', () {
      expect(
        RaceRules.stageLevel(DifficultyCurve.maxLevelNumber + 100),
        DifficultyCurve.maxLevelNumber,
      );
    });
  });

  group('paceMs', () {
    test('reads race_pace_ms_<rival> per rival', () {
      expect(
        RaceRules.paceMs(1, config),
        RemoteConfigKeys.racePaceMs1.defaultValue,
      );
      expect(
        RaceRules.paceMs(2, config),
        RemoteConfigKeys.racePaceMs2.defaultValue,
      );
      expect(
        RaceRules.paceMs(3, config),
        RemoteConfigKeys.racePaceMs3.defaultValue,
      );
    });

    test('clamps a tuned value to 0..maxPaceMs', () {
      config.setOverride(RemoteConfigKeys.racePaceMs1, -500);
      expect(RaceRules.paceMs(1, config), 0);
      config.setOverride(RemoteConfigKeys.racePaceMs2, 999999999);
      expect(RaceRules.paceMs(2, config), RaceRules.maxPaceMs);
    });

    test('throws a RangeError for a rival outside 1..3', () {
      expect(() => RaceRules.paceMs(0, config), throwsRangeError);
      expect(() => RaceRules.paceMs(4, config), throwsRangeError);
    });
  });

  group('jitterPct', () {
    test('reads race_pace_jitter_pct, clamped to 0..100', () {
      expect(
        RaceRules.jitterPct(config),
        RemoteConfigKeys.racePaceJitterPct.defaultValue,
      );
      config.setOverride(RemoteConfigKeys.racePaceJitterPct, -10);
      expect(RaceRules.jitterPct(config), 0);
      config.setOverride(RemoteConfigKeys.racePaceJitterPct, 250);
      expect(RaceRules.jitterPct(config), 100);
    });
  });

  group('rewardCoins', () {
    test('reads race_reward_<rival> per rival', () {
      expect(
        RaceRules.rewardCoins(1, config),
        RemoteConfigKeys.raceReward1.defaultValue,
      );
      expect(
        RaceRules.rewardCoins(2, config),
        RemoteConfigKeys.raceReward2.defaultValue,
      );
      expect(
        RaceRules.rewardCoins(3, config),
        RemoteConfigKeys.raceReward3.defaultValue,
      );
    });

    test('never below 0 (spec-prop §7.7 "a win pays")', () {
      config.setOverride(RemoteConfigKeys.raceReward1, -20);
      expect(RaceRules.rewardCoins(1, config), 0);
    });

    test('throws a RangeError for a rival outside 1..3', () {
      expect(() => RaceRules.rewardCoins(0, config), throwsRangeError);
      expect(() => RaceRules.rewardCoins(4, config), throwsRangeError);
    });
  });

  group('pacePrng', () {
    test('is Prng(Prng.derive(raceSeed, paceStream)): deterministic and not '
        'the raw race seed stream', () {
      const raceSeed = 3100001;
      final expected = Prng(Prng.derive(raceSeed, RaceRules.paceStream));
      final actual = RaceRules.pacePrng(raceSeed);
      expect(actual.nextU32(), expected.nextU32());
      expect(actual.nextU32(), expected.nextU32());
      // Different from the seed's own raw stream (the board's attempts use
      // their own derived streams, never the pace's).
      expect(
        RaceRules.pacePrng(raceSeed).nextU32(),
        isNot(Prng(raceSeed).nextU32()),
      );
    });

    test('a Rematch (the same raceSeed) replays the same pace', () {
      const raceSeed = 3200007;
      final first = RaceRules.pacePrng(raceSeed);
      final second = RaceRules.pacePrng(raceSeed);
      for (var i = 0; i < 20; i++) {
        expect(second.nextU32(), first.nextU32());
      }
    });
  });

  group('nextIntervalMs', () {
    test('stays within paceMs +/- span = paceMs * jitterPct ~/ 100', () {
      const paceMs = 2400;
      const jitterPct = 20;
      const span = paceMs * jitterPct ~/ 100;
      final pace = RaceRules.pacePrng(3100050);
      for (var i = 0; i < 500; i++) {
        final interval = RaceRules.nextIntervalMs(pace, paceMs, jitterPct);
        expect(interval, greaterThanOrEqualTo(paceMs - span));
        expect(interval, lessThanOrEqualTo(paceMs + span));
      }
    });

    test('is never negative even at the edges of the clamps', () {
      final pace = RaceRules.pacePrng(3200099);
      // jitterPct 100 makes span == paceMs, so the interval can reach 0 but
      // never below it.
      for (var i = 0; i < 200; i++) {
        expect(
          RaceRules.nextIntervalMs(pace, 1600, 100),
          greaterThanOrEqualTo(0),
        );
      }
    });

    test('with no jitter every draw is exactly paceMs, but still consumes '
        'one draw from the stream', () {
      final pace = RaceRules.pacePrng(3300001);
      for (var i = 0; i < 10; i++) {
        expect(RaceRules.nextIntervalMs(pace, 3000, 0), 3000);
      }
    });

    test('one draw per call: the stream advances by exactly one nextU32 '
        'whatever paceMs and jitterPct are', () {
      const raceSeed = 3300123;
      final viaInterval = RaceRules.pacePrng(raceSeed);
      final raw = RaceRules.pacePrng(raceSeed);

      // Three calls with different (even zero) jitter each consume exactly
      // one raw draw, so the two streams stay in lock-step.
      RaceRules.nextIntervalMs(viaInterval, 3000, 0);
      raw.nextU32();
      RaceRules.nextIntervalMs(viaInterval, 1600, 20);
      raw.nextU32();
      RaceRules.nextIntervalMs(viaInterval, 2400, 100);
      raw.nextU32();

      expect(viaInterval.nextU32(), raw.nextU32());
    });

    test('the same seed replays the same sequence of intervals (a Rematch, '
        'spec-prop §7.7 "the same rival moves")', () {
      const raceSeed = 3100777;
      int draw(Prng pace) => RaceRules.nextIntervalMs(pace, 2400, 20);
      final pace1 = RaceRules.pacePrng(raceSeed);
      final sequence1 = [for (var i = 0; i < 30; i++) draw(pace1)];
      final pace2 = RaceRules.pacePrng(raceSeed);
      final sequence2 = [for (var i = 0; i < 30; i++) draw(pace2)];
      expect(sequence1, sequence2);

      // A different seed gives a different sequence (not a coincidence of
      // always drawing the same interval).
      final other = RaceRules.pacePrng(raceSeed + 1);
      final sequence3 = [for (var i = 0; i < 30; i++) draw(other)];
      expect(sequence3, isNot(sequence1));
    });
  });

  group('parsePaceOverride (README "Testing" NESTY_RACE_PACE_MS)', () {
    test('a whole non-negative number counts in a dev debug build', () {
      expect(
        RaceRules.parsePaceOverride('5000', debug: true, flavor: Flavor.dev),
        5000,
      );
      expect(
        RaceRules.parsePaceOverride('0', debug: true, flavor: Flavor.dev),
        0,
      );
    });

    test('empty, negative or non-numeric text is null', () {
      expect(
        RaceRules.parsePaceOverride('', debug: true, flavor: Flavor.dev),
        isNull,
      );
      expect(
        RaceRules.parsePaceOverride('-5', debug: true, flavor: Flavor.dev),
        isNull,
      );
      expect(
        RaceRules.parsePaceOverride('abc', debug: true, flavor: Flavor.dev),
        isNull,
      );
    });

    test('never counts outside a debug build', () {
      expect(
        RaceRules.parsePaceOverride('5000', debug: false, flavor: Flavor.dev),
        isNull,
      );
    });

    test('never counts outside the dev flavor, including no flavor set', () {
      expect(
        RaceRules.parsePaceOverride('5000', debug: true, flavor: Flavor.stg),
        isNull,
      );
      expect(
        RaceRules.parsePaceOverride('5000', debug: true, flavor: Flavor.prod),
        isNull,
      );
      expect(
        RaceRules.parsePaceOverride('5000', debug: true, flavor: null),
        isNull,
      );
    });
  });
}
