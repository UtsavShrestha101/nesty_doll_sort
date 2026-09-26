// Behaviour of core's seeded PRNG (spec §6.5, CLAUDE.md rule 7,
// docs/plans/m1-core-design.md §3). The full reference streams from the
// independent Python implementation are compared in
// test/parity/prng_parity_test.dart on every platform. This file covers the
// contract: argument checks, ranges, how many values each call draws,
// uniformity without modulo bias, and seeding edge cases. No dart:io, so it
// runs on chrome and node too.
import 'package:nesty_core/nesty_core.dart';
import 'package:test/test.dart';

import '../parity/vectors/prng_vectors.dart';

List<int> _take(Prng prng, int count) => [
  for (var i = 0; i < count; i++) prng.nextU32(),
];

void main() {
  group('Prng(seed)', () {
    test('matches the Python reference for the first seeds', () {
      // Spot checks for quick diagnosis. The parity suite compares all.
      expect(_take(Prng(0), 4), [
        0xD8F25F58,
        0x775266B1,
        0x899BAC35,
        0x10CA3429,
      ]);
      expect(
        _take(Prng(20260926), 16),
        prngSeedStreams.firstWhere((v) => v['seed'] == 20260926)['u32'],
      );
    });

    test('the same seed gives the same stream', () {
      expect(_take(Prng(1000001), 64), _take(Prng(1000001), 64));
    });

    test('accepts 0 and maxSeed, and rejects anything outside', () {
      expect(Prng.maxSeed, 0x1FFFFFFFFFFFFF);
      expect(() => Prng(0), returnsNormally);
      expect(() => Prng(Prng.maxSeed), returnsNormally);
      expect(() => Prng(-1), throwsRangeError);
      expect(() => Prng(Prng.maxSeed + 1), throwsRangeError);
    });

    test('neighbouring seeds start differently', () {
      final firsts = {for (var s = 0; s < 1000; s++) Prng(s).nextU32()};
      expect(firsts, hasLength(1000));
    });

    test('the high seed word reaches the first output', () {
      // xoshiro128**'s first output reads only the second state word, so
      // seeding mixes both seed halves into it. Seeds 5, 2^32 + 5, 2 · 2^32 +
      // 5, … share their low word, yet each starts differently.
      final firsts = {
        for (var hi = 0; hi < 500; hi++) Prng(hi * 0x100000000 + 5).nextU32(),
      };
      expect(firsts, hasLength(500));
    });

    test('the only seeds that zero the first state word still work', () {
      // The first state word is 0 when lo = 2^32 − 0x9E3779B9. The seeding
      // guarantees the whole state is still non-zero, so the stream is live.
      const lo = 0x100000000 - 0x9E3779B9;
      for (final hi in [0, 1, 0x1FFFFF]) {
        final stream = _take(Prng(hi * 0x100000000 + lo), 8);
        expect(stream.any((v) => v != 0), isTrue, reason: 'hi = $hi');
        expect(stream.toSet().length, greaterThan(4), reason: 'hi = $hi');
      }
    });

    test('nextU32 stays in [0, 2^32)', () {
      final prng = Prng(99);
      for (var i = 0; i < 10000; i++) {
        expect(prng.nextU32(), inInclusiveRange(0, 0xFFFFFFFF));
      }
    });
  });

  group('Prng.derive', () {
    test('matches the Python reference', () {
      final v = prngDerive.firstWhere(
        (v) => v['seed'] == 1000001 && v['a'] == 1 && v['b'] == 0,
      );
      expect(Prng.derive(1000001, 1), v['value']);
    });

    test('derive(s, a) is derive(s, a, 0)', () {
      for (final seed in [0, 1, 20260926, Prng.maxSeed]) {
        for (var a = 0; a < 50; a++) {
          expect(Prng.derive(seed, a), Prng.derive(seed, a, 0));
        }
      }
    });

    test('returns a u32 that is also a valid Prng seed', () {
      for (var a = 0; a < 50; a++) {
        final sub = Prng.derive(Prng.maxSeed, a, 7);
        expect(sub, inInclusiveRange(0, 0xFFFFFFFF));
        expect(() => Prng(sub), returnsNormally);
      }
    });

    test('labels give distinct sub-seeds', () {
      // Generator attempts 0..49 and simulator runs (bot 0..1, run 0..299).
      final attempts = {for (var i = 0; i < 50; i++) Prng.derive(1000007, i)};
      expect(attempts, hasLength(50));
      final runs = {
        for (var bot = 0; bot < 2; bot++)
          for (var run = 0; run < 300; run++) Prng.derive(0xC0FFEE, bot, run),
      };
      expect(runs, hasLength(600));
    });

    test('swapping a and b changes the result', () {
      expect(Prng.derive(42, 1, 2), isNot(Prng.derive(42, 2, 1)));
    });

    test('checks every argument', () {
      expect(() => Prng.derive(-1, 0), throwsRangeError);
      expect(() => Prng.derive(Prng.maxSeed + 1, 0), throwsRangeError);
      expect(() => Prng.derive(0, -1), throwsRangeError);
      expect(() => Prng.derive(0, 0x100000000), throwsRangeError);
      expect(() => Prng.derive(0, 0, -1), throwsRangeError);
      expect(() => Prng.derive(0, 0, 0x100000000), throwsRangeError);
      expect(Prng.derive(0, 0xFFFFFFFF, 0xFFFFFFFF), isA<int>());
    });
  });

  group('nextInt', () {
    test('stays in [0, bound) for small and huge bounds', () {
      final prng = Prng(3);
      for (final bound in [1, 2, 3, 7, 300, 0x80000001, 0x100000000]) {
        for (var i = 0; i < 500; i++) {
          expect(prng.nextInt(bound), inInclusiveRange(0, bound - 1));
        }
      }
    });

    test('rejects bounds outside 1..2^32', () {
      final prng = Prng(3);
      expect(Prng.maxBound, 0x100000000);
      expect(() => prng.nextInt(0), throwsRangeError);
      expect(() => prng.nextInt(-5), throwsRangeError);
      expect(() => prng.nextInt(0x100000001), throwsRangeError);
    });

    test('nextInt(1) is 0 and still draws one value', () {
      final a = Prng(12);
      final b = Prng(12);
      expect(a.nextInt(1), 0);
      b.nextU32();
      expect(a.nextU32(), b.nextU32());
    });

    test('nextInt(2^32) is the raw value, since nothing is rejected', () {
      final a = Prng(13);
      final b = Prng(13);
      for (var i = 0; i < 100; i++) {
        expect(a.nextInt(0x100000000), b.nextU32());
      }
    });

    test('small bounds are the raw value mod bound, drawing once each', () {
      // 2^32 mod 6 = 4, so only raw values 0..3 would be rejected, and the
      // chance of one appearing in 1,000 draws is about 10^-6. The stream
      // is fixed, so this is deterministic.
      final a = Prng(14);
      final b = Prng(14);
      for (var i = 0; i < 1000; i++) {
        expect(a.nextInt(6), b.nextU32() % 6);
      }
    });

    test('rejected values are redrawn (Python reference)', () {
      final seed = prngRejection['seed']! as int;
      final bound = prngRejection['bound']! as int;
      final draws = prngRejection['draws']! as int;
      final prng = Prng(seed);
      final values = [for (var i = 0; i < 24; i++) prng.nextInt(bound)];
      expect(values, prngRejection['values']);
      // 24 calls consumed `draws` raw values, more than one each.
      expect(draws, greaterThan(24));
      expect(prng.nextU32(), _take(Prng(seed), draws + 1).last);
    });

    test('has no modulo bias for a bound of 3 · 2^30', () {
      // Plain `r % 0xC0000000` maps raw values [0, 2^30) and
      // [3 · 2^30, 2^32) to the same results, so a third of the range would
      // come up half the time. Rejection sampling keeps it at a third.
      const bound = 0xC0000000;
      final prng = Prng(15);
      var low = 0;
      const n = 30000;
      for (var i = 0; i < n; i++) {
        if (prng.nextInt(bound) < 0x40000000) low++;
      }
      expect(low / n, inInclusiveRange(0.32, 0.347));
    });

    test('is uniform for a die roll', () {
      // Chi-square over 60,000 rolls, 5 degrees of freedom. The stream is
      // fixed, so this is deterministic; 20.5 is the p = 0.001 cut-off.
      final prng = Prng(16);
      final counts = List.filled(6, 0);
      const n = 60000;
      for (var i = 0; i < n; i++) {
        counts[prng.nextInt(6)]++;
      }
      const expected = n / 6;
      final chi2 = counts.fold<double>(
        0,
        (sum, c) => sum + (c - expected) * (c - expected) / expected,
      );
      expect(chi2, lessThan(20.5), reason: 'counts $counts');
    });
  });

  group('nextIntBetween', () {
    test('is min + nextInt(max − min + 1)', () {
      final a = Prng(21);
      final b = Prng(21);
      for (var i = 0; i < 200; i++) {
        expect(a.nextIntBetween(-7, 7), -7 + b.nextInt(15));
      }
    });

    test('reaches both ends', () {
      final prng = Prng(22);
      final seen = {for (var i = 0; i < 600; i++) prng.nextIntBetween(1, 6)};
      expect(seen, {1, 2, 3, 4, 5, 6});
    });

    test('min == max returns it and still draws once', () {
      final a = Prng(23);
      final b = Prng(23);
      expect(a.nextIntBetween(9, 9), 9);
      b.nextU32();
      expect(a.nextU32(), b.nextU32());
    });

    test('accepts a span of exactly 2^32 and rejects wider or reversed', () {
      final prng = Prng(24);
      expect(
        prng.nextIntBetween(-0x80000000, 0x7FFFFFFF),
        inInclusiveRange(-0x80000000, 0x7FFFFFFF),
      );
      expect(() => prng.nextIntBetween(0, 0x100000000), throwsRangeError);
      expect(() => prng.nextIntBetween(5, 4), throwsArgumentError);
    });
  });

  group('nextBool', () {
    test('is the top bit of the raw value', () {
      final a = Prng(31);
      final b = Prng(31);
      for (var i = 0; i < 200; i++) {
        expect(a.nextBool(), b.nextU32() >= 0x80000000);
      }
    });

    test('is balanced', () {
      final prng = Prng(32);
      var heads = 0;
      for (var i = 0; i < 10000; i++) {
        if (prng.nextBool()) heads++;
      }
      expect(heads, inInclusiveRange(4800, 5200));
    });
  });

  group('shuffle', () {
    test('permutes the list in place', () {
      final list = [for (var i = 0; i < 52; i++) i];
      Prng(41).shuffle(list);
      expect(list.toSet(), hasLength(52));
      expect(list..sort(), [for (var i = 0; i < 52; i++) i]);
    });

    test('is Durstenfeld, from the end down, one draw per step', () {
      final list = ['a', 'b', 'c', 'd', 'e', 'f'];
      final expected = List.of(list);
      final twin = Prng(42);
      for (var i = expected.length - 1; i > 0; i--) {
        final j = twin.nextInt(i + 1);
        final swap = expected[i];
        expected[i] = expected[j];
        expected[j] = swap;
      }
      final prng = Prng(42)..shuffle(list);
      expect(list, expected);
      expect(prng.nextU32(), twin.nextU32());
    });

    test('draws nothing for empty and one-element lists', () {
      final prng = Prng(43)
        ..shuffle(<int>[])
        ..shuffle([1]);
      expect(prng.nextU32(), Prng(43).nextU32());
    });

    test('gives every order of three about equally often', () {
      final prng = Prng(44);
      final counts = <String, int>{};
      for (var i = 0; i < 6000; i++) {
        final list = [1, 2, 3];
        prng.shuffle(list);
        counts.update(list.join(), (c) => c + 1, ifAbsent: () => 1);
      }
      expect(counts, hasLength(6));
      for (final count in counts.values) {
        expect(count, inInclusiveRange(880, 1120), reason: '$counts');
      }
    });
  });

  group('pick', () {
    test('is list[nextInt(length)]', () {
      final a = Prng(51);
      final b = Prng(51);
      const colors = ['red', 'blue', 'green', 'yellow'];
      for (var i = 0; i < 100; i++) {
        expect(a.pick(colors), colors[b.nextInt(colors.length)]);
      }
    });

    test('throws on an empty list without drawing', () {
      final prng = Prng(52);
      expect(() => prng.pick(<int>[]), throwsArgumentError);
      expect(prng.nextU32(), Prng(52).nextU32());
    });
  });
}
