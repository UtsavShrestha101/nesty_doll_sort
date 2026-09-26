import 'package:nesty_core/src/util/hash64.dart';
import 'package:nesty_core/src/util/u32.dart';

/// Core's own seeded random generator (spec §6.5, CLAUDE.md rule 7).
///
/// xoshiro128** 1.1 (Blackman and Vigna), seeded through splitmix32, in
/// web-safe 32-bit arithmetic (`src/util/u32.dart`), so a seed gives the same
/// stream on the VM, in dart2js and in wasm. `dart:math` `Random` is banned in
/// core because its sequence may change between SDK versions, which would
/// change every generated and daily level. PCG32 was ruled out because it
/// needs 64-bit multiplies (docs/plans/m1-core-design.md §3).
///
/// Every stream is pinned by reference vectors from an independent Python
/// implementation (test/parity/vectors/prng_vectors.dart). Any change to what
/// a seed produces changes generated levels, so it needs a
/// `Generator.version` bump and new golden hashes (spec §6.5).
///
/// Not thread-safe and not cryptographic. One instance per stream: derive
/// independent sub-streams with [derive] rather than sharing a generator.
final class Prng {
  /// A generator whose stream is fixed by [seed], an integer in
  /// [0, [maxSeed]]. Throws a [RangeError] for any other seed.
  ///
  /// The seed is split into `lo = seed % 2^32` and `hi = seed ~/ 2^32` with
  /// `%` and `~/`, never shifts, which truncate to 32 bits on the web.
  /// Dividing by a power of two is exact for every integer below 2^53. The
  /// 128-bit state is then taken from two splitmix32 streams, A started at
  /// `lo` and B at `hi ^ 0x510E527F`, as `(A1, A2 ^ B1, A3 ^ B2, A4 ^ B3)`.
  /// Why that shape:
  /// - xoshiro128**'s first output reads only the second word, which
  ///   therefore mixes in both halves of the seed. Seeds that differ only in
  ///   `hi` start differently.
  /// - Distinct seeds give distinct states: fmix32 is a bijection, so the
  ///   first word determines `lo`, and then the second determines `hi`.
  /// - The state is never all zero, which would make xoshiro output zeros
  ///   forever. The first word is 0 only when `lo = 2^32 − 0x9E3779B9`, and
  ///   then the second word is 0 only if B starts at 0. B can't start at 0,
  ///   because `hi` is below 2^21 and the offset 0x510E527F has higher bits
  ///   set.
  factory Prng(int seed) {
    RangeError.checkValueInInterval(seed, 0, maxSeed, 'seed');
    final a = _SplitMix32(seed % _two32);
    final b = _SplitMix32((seed ~/ _two32) ^ _hiOffset);
    final a1 = a.next();
    final a2 = a.next();
    final a3 = a.next();
    final a4 = a.next();
    final b1 = b.next();
    final b2 = b.next();
    final b3 = b.next();
    return Prng._(a1, a2 ^ b1, a3 ^ b2, a4 ^ b3);
  }

  Prng._(this._s0, this._s1, this._s2, this._s3);

  /// The largest seed, 2^53 − 1: every seed must be an exact integer on the
  /// web (design A20).
  static const int maxSeed = 0x1FFFFFFFFFFFFF;

  /// The largest [nextInt] bound, 2^32.
  static const int maxBound = _two32;

  static const int _two32 = 0x100000000;

  // Offset of the `hi` splitmix32 stream: the fifth SHA-256 initial hash
  // word (fractional part of √11). It must have a bit at or above 2^21 set,
  // so `hi ^ _hiOffset` is never 0 (see the constructor).
  static const int _hiOffset = 0x510E527F;

  // MurmurHash3 seed of [derive]: the fourth SHA-256 initial hash word
  // (fractional part of √7), so derive and Hash64's halves (the first two
  // words) are unrelated functions.
  static const int _deriveSeed = 0xA54FF53A;

  int _s0;
  int _s1;
  int _s2;
  int _s3;

  /// A 32-bit seed derived from [seed] and the stream labels [a] and [b], for
  /// independent sub-streams: generator attempt `i` uses `derive(seed, i)`,
  /// and simulator run `i` of bot `k` uses `derive(simSeed, k, i)`
  /// (design §3). `derive(s, a)` equals `derive(s, a, 0)`.
  ///
  /// It is MurmurHash3_x86_32 over the little-endian u32 words
  /// `[seed % 2^32, seed ~/ 2^32, a, b]` with seed 0xA54FF53A, so every bit of
  /// every input reaches every output bit. [seed] must be in [0, [maxSeed]],
  /// and [a] and [b] in [0, 2^32). Anything else throws a [RangeError].
  static int derive(int seed, int a, [int b = 0]) {
    RangeError.checkValueInInterval(seed, 0, maxSeed, 'seed');
    RangeError.checkValueInInterval(a, 0, u32Mask, 'a');
    RangeError.checkValueInInterval(b, 0, u32Mask, 'b');
    var h = _deriveSeed;
    h = murmur3Round(h, seed % _two32);
    h = murmur3Round(h, seed ~/ _two32);
    h = murmur3Round(h, a);
    h = murmur3Round(h, b);
    return murmur3Finish(h, 16, 0);
  }

  /// The next value in [0, 2^32): one step of xoshiro128** 1.1, following
  /// the reference `next()` line by line.
  int nextU32() {
    final s1 = _s1;
    // `s1 * 5` and `* 9` stay below 2^36, so they are exact on the web and
    // need no mul32.
    final result = (rotl32((s1 * 5) & u32Mask, 7) * 9) & u32Mask;
    final t = shl32(s1, 9);
    _s2 ^= _s0;
    _s3 ^= s1;
    _s1 = s1 ^ _s2;
    _s0 ^= _s3;
    _s2 ^= t;
    _s3 = rotl32(_s3, 11);
    return result;
  }

  /// A uniform value in [0, [bound]), without modulo bias. [bound] must be in
  /// 1..[maxBound] (2^32), or a [RangeError] is thrown.
  ///
  /// The method is rejection sampling as in OpenBSD's `arc4random_uniform`.
  /// With `t = 2^32 mod bound`, draw `r = nextU32()` until `r >= t`, then
  /// return `r % bound`. The accepted range [t, 2^32) holds exactly
  /// `⌊2^32 / bound⌋` copies of every residue, so each result is equally
  /// likely. At most `bound − 1` of the 2^32 raw values are rejected, so the
  /// retry chance is below `bound / 2^32` (about 7·10⁻⁸ for bound 300) and at
  /// worst just under ½ for bounds just above 2^31. Every call draws at
  /// least once, including `nextInt(1)`.
  ///
  /// Lemire's multiply-shift method was rejected: it needs the full 64-bit
  /// product `r * bound`, which a web `int` can't hold.
  int nextInt(int bound) {
    RangeError.checkValueInInterval(bound, 1, maxBound, 'bound');
    // (2^32 − bound) mod bound is 2^32 mod bound, computed without the
    // intermediate 2^32 mod: every value stays exact below 2^53.
    final threshold = (_two32 - bound) % bound;
    while (true) {
      final r = nextU32();
      if (r >= threshold) return r % bound;
    }
  }

  /// A uniform value in [min]..[max], both inclusive: `min + nextInt(span)`
  /// with `span = max − min + 1`. Throws an [ArgumentError] when
  /// `max < min`, and a [RangeError] when the span exceeds 2^32. Both ends
  /// must be exact on the web, within ±(2^53 − 1).
  int nextIntBetween(int min, int max) {
    if (max < min) {
      throw ArgumentError('max ($max) must not be less than min ($min)');
    }
    final span = max - min + 1;
    RangeError.checkValueInInterval(span, 1, maxBound, 'max - min + 1');
    return min + nextInt(span);
  }

  /// A fair coin flip: true when the top bit of [nextU32] is set. Every bit
  /// of xoshiro128** is full quality (unlike xoshiro128+'s low bits), and
  /// the top bit makes the test a plain comparison.
  bool nextBool() => nextU32() >= 0x80000000;

  /// Shuffles [list] in place with Fisher–Yates (spec §6.5 step 2), in
  /// Durstenfeld's order: for `i` from `length − 1` down to 1, swap
  /// `list[i]` with `list[nextInt(i + 1)]`. It draws `length − 1` values, or
  /// none for fewer than two elements.
  void shuffle<T>(List<T> list) {
    for (var i = list.length - 1; i > 0; i--) {
      final j = nextInt(i + 1);
      final swap = list[i];
      list[i] = list[j];
      list[j] = swap;
    }
  }

  /// A uniformly chosen element of the non-empty [list]:
  /// `list[nextInt(list.length)]`. Throws an [ArgumentError] when [list] is
  /// empty.
  T pick<T>(List<T> list) {
    if (list.isEmpty) throw ArgumentError('pick needs a non-empty list');
    return list[nextInt(list.length)];
  }
}

/// splitmix32: a Weyl sequence with step 0x9E3779B9 (2^32 / φ), finalized by
/// MurmurHash3's fmix32. Consecutive outputs are well mixed even for
/// consecutive starting values, which is what seeding needs. It is the
/// common 32-bit analogue of Vigna's splitmix64, which the xoshiro authors
/// recommend for seeding.
final class _SplitMix32 {
  _SplitMix32(int start) : _x = start & u32Mask;

  int _x;

  int next() => fmix32(_x = add32(_x, 0x9E3779B9));
}
