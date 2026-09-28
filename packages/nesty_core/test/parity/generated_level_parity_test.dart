// VM/web parity for the levels a device generates (docs/plans/m3-design.md
// §5, spec §7.1, §7.5, D11). The phones (VM/AOT) generate the daily puzzle
// and Bonus Endless, and the web admin previews the same params, so a date
// must give the same level byte for byte everywhere: M3's acceptance is
// "The daily puzzle is identical across two devices on the same date."
//
// The expected values are the table of vectors/generated_level_vectors.dart,
// which test/generator/daily_golden_test.dart also checks on the VM.
@Tags(['parity'])
library;

import 'package:nesty_core/nesty_core.dart';
import 'package:test/test.dart';

import 'generated_levels.dart';
import 'parity.dart';
import 'vectors/generated_level_vectors.dart';

// dart2js runs the solver and simulator several times slower than the VM.
const _slowOnTheWeb = Timeout.factor(4);

void main() {
  parityTest(
    'retry seeds: Prng.derive(seed, RETR, r) for r = 0..3',
    () => {
      for (final seed in retrySeedVectors.keys)
        '$seed': [
          for (var retry = 0; retry <= Generator.maxRetries; retry++)
            Generator.retrySeed(seed, retry),
        ],
    },
    expected: {
      for (final MapEntry(:key, :value) in retrySeedVectors.entries)
        '$key': value,
    },
  );

  parityTest(
    'daily puzzles 2026-09-21 … 2026-10-18',
    () => {
      for (final date in dailyGoldenDates)
        'daily-$date': generatedFingerprint(DifficultyCurve.dailyParams(date)),
    },
    expected: dailyGoldens,
    timeout: _slowOnTheWeb,
  );

  parityTest(
    'bonus levels 1–20',
    () => {
      for (final order in bonusGoldenOrders.where((o) => o <= 20))
        'bonus-$order': generatedFingerprint(
          DifficultyCurve.bonusParams(order),
        ),
    },
    expected: {
      for (final MapEntry(:key, :value) in bonusGoldens.entries)
        if (int.parse(key.substring('bonus-'.length)) <= 20) key: value,
    },
    timeout: _slowOnTheWeb,
  );

  parityTest(
    'bonus levels 31–50',
    () => {
      for (final order in bonusGoldenOrders.where((o) => o >= 31))
        'bonus-$order': generatedFingerprint(
          DifficultyCurve.bonusParams(order),
        ),
    },
    expected: {
      for (final MapEntry(:key, :value) in bonusGoldens.entries)
        if (int.parse(key.substring('bonus-'.length)) >= 31) key: value,
    },
    timeout: _slowOnTheWeb,
  );
}
