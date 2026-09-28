// Deterministic retries on a GeneratorFailure (design A14: "the app's policy
// is to retry with the next seed"; docs/plans/m3-design.md §5): retry r of
// seed s uses Prng.derive(s, Generator.retryStream, r), so every device
// derives the same seeds for a daily date or a bonus level (spec §7.5).
import 'package:nesty_core/nesty_core.dart';
import 'package:test/test.dart';

import '../parity/vectors/generated_level_vectors.dart';

void main() {
  group('Generator.retrySeed', () {
    // Shared with the web parity suite (generated_level_parity_test.dart,
    // m3-design §5).
    test('the vectors cover a date, a bonus seed, 0 and the largest seed', () {
      expect(retrySeedVectors.keys, [20260926, 1000031, 0, Prng.maxSeed]);
    });

    test('retry 0 is the seed itself, then derived u32 seeds', () {
      for (final MapEntry(key: seed, value: seeds)
          in retrySeedVectors.entries) {
        expect(
          [
            for (var r = 0; r <= Generator.maxRetries; r++)
              Generator.retrySeed(seed, r),
          ],
          seeds,
          reason: '$seed',
        );
      }
    });

    test('rejects a seed or retry out of range', () {
      expect(() => Generator.retrySeed(-1, 1), throwsRangeError);
      expect(() => Generator.retrySeed(1, -1), throwsRangeError);
      expect(
        () => Generator.retrySeed(1, Generator.maxRetries + 1),
        throwsRangeError,
      );
    });
  });

  group('Generator.generateWithRetries', () {
    test('a seed that succeeds gives exactly generate()', () {
      final params = DifficultyCurve.bonusParams(1);
      final direct = Generator.generate(params);
      expect(direct, isA<GeneratorSuccess>());
      expect(Generator.generateWithRetries(params), direct);
    });

    test('params that fail checkParams fail at once, with no retry', () {
      const params = GeneratorParams(
        colors: 0,
        maxSize: 4,
        shelves: 3,
        slotsPerShelf: 3,
        emptySlots: 1,
        targetTier: Tier.easy,
        seed: 1,
      );
      final outcome = Generator.generateWithRetries(params);
      expect(outcome, isA<GeneratorFailure>());
      expect((outcome as GeneratorFailure).attempts, 0);
      expect(outcome, Generator.generate(params));
    });

    test('withSeed changes only the seed', () {
      final params = DifficultyCurve.dailyParams(20260926);
      final other = params.withSeed(7);
      expect(other.seed, 7);
      expect(other.id, params.id);
      expect(other.withSeed(params.seed), params);
    });
  });
}
