// The past dailies (docs/plans/plan-local-habits.md §7.5c, local habits 3):
// a date in the archive window must give the level it gave on its own day.
//
// Spec §7.5: "One puzzle per day. The level is generated from
//   `seed = yyyymmdd`, pinned `generatorVersion` and tier medium/hard."
// Spec §18 M3: "The daily puzzle is identical across two devices on the
//   same date."
// §7.5c: the window is today - daily_archive_days … today - 1, and a past
//   day plays the same puzzle the day itself did.
//
// The app's daily (apps/game DefaultLevelResolver._daily) is
// `DifficultyCurve.dailyParams(yyyymmdd)` then
// `Generator.generateWithRetries` (the isolate and fake generator
// services), and nothing else reads the clock: so "today's" level of a date
// is exactly what a later run builds for it. The fingerprints are the
// pinned table of test/parity/vectors/generated_level_vectors.dart
// (2026-09-21 … 2026-10-18, which holds these dates), so a drift fails here
// and in the parity run on node, chrome and wasm. Web-safe: no dart:io.
@Tags(['parity'])
library;

import 'package:nesty_core/nesty_core.dart';
import 'package:test/test.dart';

import '../generator/support/generator_checks.dart';
import 'generated_levels.dart';
import 'vectors/generated_level_vectors.dart';

/// 2026-10-08 ("today" of the stage) and the 7 dates before it.
const _dates = <int>[
  20261001, 20261002, 20261003, 20261004, //
  20261005, 20261006, 20261007, 20261008, //
];

void main() {
  test('the eight dates are all in the pinned table', () {
    for (final date in _dates) {
      expect(dailyGoldens, contains('daily-$date'));
    }
  });

  for (final date in _dates) {
    group('$date', () {
      test('dailyParams is identical across two calls', () {
        final a = DifficultyCurve.dailyParams(date);
        final b = DifficultyCurve.dailyParams(date);
        expect(a.seed, date);
        expect(a.seed, b.seed);
        expect(a.id, b.id);
        expect(a.targetTier, b.targetTier);
        expect(a.colors, b.colors);
        expect(a.towers, b.towers);
        expect(a.locked, b.locked);
        expect(a.iceSlots, b.iceSlots);
      });

      test('the level equals the pinned one, across two runs', () {
        final golden = dailyGoldens['daily-$date']!;
        final first = generatedFingerprint(DifficultyCurve.dailyParams(date));
        final second = generatedFingerprint(DifficultyCurve.dailyParams(date));
        expect(first, golden, reason: 'the level built on its own day');
        expect(second, first);
      });

      test('it is a valid, solvable level with the date as seed', () {
        final params = DifficultyCurve.dailyParams(date);
        final outcome = Generator.generateWithRetries(params);
        expect(outcome, isA<GeneratorSuccess>());
        final level = (outcome as GeneratorSuccess).level;
        expect(level.id, params.id);
        expect(level.generatorVersion, Generator.version);
        expectPlayable(level);
      });
    });
  }
}
