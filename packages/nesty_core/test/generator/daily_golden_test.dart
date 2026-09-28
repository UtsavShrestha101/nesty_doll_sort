// Golden fingerprints of the levels a device generates
// (docs/plans/m3-design.md §5, D70).
//
// Spec §7.5: "One puzzle per day. The level is generated from
//   `seed = yyyymmdd`, pinned `generatorVersion` and tier medium/hard."
// Spec §7.1: "the game generates levels on the device with
//   `seed = 1_000_000 + levelNumber`, following the curve."
// Spec §18 M3: "The daily puzzle is identical across two devices on the
//   same date."
// m3-design §5: goldens of `generateWithRetries` for 28 consecutive dates
//   2026-09-21 … 2026-10-18 (`dailyParams`) and bonus orders 1–20 and 31–50
//   (`bonusParams`), with the attempt, tier and seed used, on the VM and
//   the web.
//
// The table lives in test/parity/vectors/generated_level_vectors.dart, so
// generated_level_parity_test.dart checks the same values on node, chrome
// and wasm. This file adds what the parity run leaves out: every golden
// level is a valid, solvable level with the id, version and seed the app
// expects. Web-safe too (`dart test -p chrome` runs it).
import 'package:nesty_core/nesty_core.dart';
import 'package:test/test.dart';

import '../parity/generated_levels.dart';
import '../parity/vectors/generated_level_vectors.dart';
import 'support/generator_checks.dart';

void main() {
  test('Generator.version is 1: these goldens belong to it', () {
    expect(Generator.version, 1);
  });

  group('the tables', () {
    test('28 consecutive dates, Monday 2026-09-21 to Sunday 2026-10-18', () {
      // September has 30 days.
      expect(dailyGoldenDates, [
        for (var day = 21; day <= 30; day++) 20260900 + day,
        for (var day = 1; day <= 18; day++) 20261000 + day,
      ]);
      expect(dailyGoldens.keys, [
        for (final date in dailyGoldenDates) 'daily-$date',
      ]);
    });

    test('bonus orders 1–20 and 31–50', () {
      expect(bonusGoldenOrders, [
        for (var order = 1; order <= 20; order++) order,
        for (var order = 31; order <= 50; order++) order,
      ]);
      expect(bonusGoldens.keys, [
        for (final order in bonusGoldenOrders) 'bonus-$order',
      ]);
    });

    test('the daily is hard on Saturdays and Sundays, else medium', () {
      // Spec §7.5 "tier medium/hard"; the weekend rule is the owner-confirmed
      // curve (Q34). 2026-09-26 is a Saturday.
      const weekends = {
        20260926, 20260927, 20261003, 20261004, //
        20261010, 20261011, 20261017, 20261018, //
      };
      for (final date in dailyGoldenDates) {
        expect(
          DifficultyCurve.dailyTier(date),
          weekends.contains(date) ? Tier.hard : Tier.medium,
          reason: '$date',
        );
      }
    });
  });

  group('daily puzzles (spec §7.5)', () {
    for (final date in dailyGoldenDates) {
      test('$date', () {
        _expectGolden(
          DifficultyCurve.dailyParams(date),
          dailyGoldens['daily-$date']!,
          seed: date,
        );
      });
    }
  });

  group('bonus levels (spec §7.1)', () {
    for (final order in bonusGoldenOrders) {
      test('$order', () {
        _expectGolden(
          DifficultyCurve.bonusParams(order),
          bonusGoldens['bonus-$order']!,
          seed: 1000000 + order,
        );
      });
    }
  });
}

/// Generates [params] as the app does and expects the [golden] fingerprint
/// and a level the app can play: its id, `generatorVersion` 1, a seed
/// derived from [seed] (itself, or a retry seed), valid and solvable with
/// the admin budget, its solution replaying to a win.
void _expectGolden(
  GeneratorParams params,
  Map<String, Object> golden, {
  required int seed,
}) {
  expect(params.seed, seed);
  final outcome = Generator.generateWithRetries(params);
  expect(outcome, isA<GeneratorSuccess>());
  final success = outcome as GeneratorSuccess;
  expect(fingerprintOf(success), golden);

  final level = success.level;
  expect(level.id, params.id);
  expect(level.generatorVersion, Generator.version);
  expect(
    level.seed,
    anyOf([
      for (var retry = 0; retry <= Generator.maxRetries; retry++)
        Generator.retrySeed(seed, retry),
    ]),
  );
  expect(success.tierMatched, success.simulation.tier == params.targetTier);
  expectPlayable(level);
}
