/// 64-bit hashing without 64-bit integers (spec §6.2, PROGRESS Q9,
/// docs/plans/m1-core-design.md §1).
///
/// The solver's canonical state key, the simulator's default seed and the
/// generator's golden hashes all need a 64-bit hash that is identical on the
/// VM and in the web admin. A web `int` can't hold 64 bits, so a [Hash64] is
/// two 32-bit halves. Each half is MurmurHash3_x86_32 (Austin Appleby,
/// smhasher) over the same little-endian byte stream, with its own seed:
/// [Hash64.hiSeed] for [Hash64.hi] and [Hash64.loSeed] for [Hash64.lo]. Using
/// the unmodified algorithm means each half is checked against MurmurHash3's
/// published test vectors (test/util/hash64_test.dart). All arithmetic
/// follows the web-safe rules of u32.dart: no intermediate reaches 2^53.
///
/// Input is a byte stream: a u32 word is 4 bytes and a u16 unit 2 bytes, both
/// little-endian, and a `String` is its UTF-16 code units. Widths may be
/// mixed freely; only the concatenated bytes matter.
///
/// Not cryptographic and not collision resistant. The solver confirms every
/// visited-table hit by comparing the stored key (design §3), so a collision
/// costs time, never correctness. Never persist `hashCode`; persist [toHex].
///
/// Internal to nesty_core (not exported by the barrel).
library;

import 'package:nesty_core/src/util/u32.dart';

/// A 64-bit hash as two unsigned 32-bit halves.
final class Hash64 {
  /// A hash from its halves, each in [0, 2^32).
  const Hash64(this.hi, this.lo)
    : assert(hi >= 0 && hi <= u32Mask, 'hi must be a u32'),
      assert(lo >= 0 && lo <= u32Mask, 'lo must be a u32');

  /// The hash of the u32 [words] in `[start, end)`, 4 bytes each.
  factory Hash64.ofU32s(List<int> words, [int start = 0, int? end]) =>
      (Hash64Builder()..addU32s(words, start, end)).hash;

  /// The hash of the u16 [units] in `[start, end)`, 2 bytes each. The solver's
  /// packed cells are u16 (design §2).
  factory Hash64.ofU16s(List<int> units, [int start = 0, int? end]) =>
      (Hash64Builder()..addU16s(units, start, end)).hash;

  /// The hash of the [bytes] in `[start, end)`.
  factory Hash64.ofBytes(List<int> bytes, [int start = 0, int? end]) =>
      (Hash64Builder()..addBytes(bytes, start, end)).hash;

  /// The hash of [string]'s UTF-16 code units. Dart strings are UTF-16 on
  /// every platform, so this needs no encoder and gives the same bytes
  /// everywhere. For example, the simulator's default seed is the [lo] half
  /// of the hash of the level's canonical JSON (design §3).
  factory Hash64.ofString(String string) =>
      (Hash64Builder()..addString(string)).hash;

  /// MurmurHash3 seed of the [hi] half: the first SHA-256 initial hash word
  /// (fractional part of √2), a constant with no chosen structure.
  static const int hiSeed = 0x6A09E667;

  /// MurmurHash3 seed of the [lo] half: the second SHA-256 initial hash word
  /// (fractional part of √3).
  static const int loSeed = 0xBB67AE85;

  /// The upper 32 bits.
  final int hi;

  /// The lower 32 bits.
  final int lo;

  /// The 16 lowercase hex digits of the hash, [hi] first. Golden hashes are
  /// written in this form.
  String toHex() =>
      '${hi.toRadixString(16).padLeft(8, '0')}'
      '${lo.toRadixString(16).padLeft(8, '0')}';

  @override
  bool operator ==(Object other) =>
      other is Hash64 && other.hi == hi && other.lo == lo;

  @override
  int get hashCode => Object.hash(hi, lo);

  @override
  String toString() => 'Hash64(${toHex()})';
}

/// A reusable, allocation-free [Hash64] accumulator.
///
/// The solver hashes a canonical key per stored state (spec §6.2), so it
/// keeps one builder, calls [reset], adds the key, and reads [hi] and [lo]
/// without creating a [Hash64]. Reading [hi], [lo] or [hash] doesn't change
/// the state: more input may follow.
final class Hash64Builder {
  /// A builder for [Hash64]. [hiSeed] and [loSeed] exist so each half can be
  /// checked against MurmurHash3's published vectors, which use other seeds.
  /// Everything else keeps the defaults.
  Hash64Builder({this.hiSeed = Hash64.hiSeed, this.loSeed = Hash64.loSeed})
    : _hi = hiSeed & u32Mask,
      _lo = loSeed & u32Mask;

  /// MurmurHash3 seed of the [hi] half.
  final int hiSeed;

  /// MurmurHash3 seed of the [lo] half.
  final int loSeed;

  // Running MurmurHash3 state of each half, over the complete 4-byte blocks.
  int _hi;
  int _lo;

  // Bytes of the incomplete block, little-endian, and how many there are
  // (always `_length % 4`).
  int _tail = 0;
  int _tailBytes = 0;

  // Total bytes added. It stays exact on the web up to 2^53 bytes, and
  // MurmurHash3 only uses it mod 2^32.
  int _length = 0;

  /// Forgets all input, ready to hash a new stream.
  void reset() {
    _hi = hiSeed & u32Mask;
    _lo = loSeed & u32Mask;
    _tail = 0;
    _tailBytes = 0;
    _length = 0;
  }

  /// Adds the low 32 bits of [word] as 4 little-endian bytes. Signed values
  /// read back from an `Int32List` mean the same 32 bits.
  void addU32(int word) {
    final w = word & u32Mask;
    _length += 4;
    if (_tailBytes == 0) {
      _block(w);
      return;
    }
    // The pending bytes plus the low bytes of w complete a block; the high
    // `_tailBytes` bytes of w become the new pending tail.
    final bits = _tailBytes * 8;
    _block(_tail | shl32(w, bits));
    _tail = w >>> (32 - bits);
  }

  /// Adds the low 16 bits of [unit] as 2 little-endian bytes.
  void addU16(int unit) {
    final u = unit & 0xFFFF;
    _length += 2;
    switch (_tailBytes) {
      case 0:
        _tail = u;
        _tailBytes = 2;
      case 1:
        _tail |= u << 8;
        _tailBytes = 3;
      case 2:
        // Multiply rather than shift: the product stays below 2^32, so it is
        // exact and unsigned on the web too.
        _block(_tail | u * 0x10000);
        _tail = 0;
        _tailBytes = 0;
      default:
        _block(_tail | (u & 0xFF) * 0x1000000);
        _tail = u >>> 8;
        _tailBytes = 1;
    }
  }

  /// Adds the low 8 bits of [byte].
  void addU8(int byte) {
    final b = byte & 0xFF;
    _length += 1;
    if (_tailBytes == 3) {
      _block(_tail | b * 0x1000000);
      _tail = 0;
      _tailBytes = 0;
    } else {
      _tail |= b << (8 * _tailBytes);
      _tailBytes++;
    }
  }

  /// Adds the u32 [words] in `[start, end)`, as [addU32] would one by one.
  void addU32s(List<int> words, [int start = 0, int? end]) {
    final stop = RangeError.checkValidRange(start, end, words.length);
    if (_tailBytes != 0) {
      for (var i = start; i < stop; i++) {
        addU32(words[i]);
      }
      return;
    }
    // Aligned fast path: one block per word.
    for (var i = start; i < stop; i++) {
      _block(words[i] & u32Mask);
    }
    _length += 4 * (stop - start);
  }

  /// Adds the u16 [units] in `[start, end)`, as [addU16] would one by one.
  void addU16s(List<int> units, [int start = 0, int? end]) {
    final stop = RangeError.checkValidRange(start, end, units.length);
    var i = start;
    if (_tailBytes == 0) {
      // Aligned fast path: two units per block.
      for (; i + 1 < stop; i += 2) {
        _block((units[i] & 0xFFFF) | (units[i + 1] & 0xFFFF) * 0x10000);
      }
      _length += 2 * (i - start);
    }
    for (; i < stop; i++) {
      addU16(units[i]);
    }
  }

  /// Adds the [bytes] in `[start, end)`, as [addU8] would one by one.
  void addBytes(List<int> bytes, [int start = 0, int? end]) {
    final stop = RangeError.checkValidRange(start, end, bytes.length);
    var i = start;
    if (_tailBytes == 0) {
      // Aligned fast path: four bytes per block.
      for (; i + 3 < stop; i += 4) {
        _block(
          (bytes[i] & 0xFF) |
              (bytes[i + 1] & 0xFF) << 8 |
              (bytes[i + 2] & 0xFF) << 16 |
              (bytes[i + 3] & 0xFF) * 0x1000000,
        );
      }
      _length += i - start;
    }
    for (; i < stop; i++) {
      addU8(bytes[i]);
    }
  }

  /// Adds [string]'s UTF-16 code units, as [Hash64.ofString] hashes them.
  void addString(String string) => addU16s(string.codeUnits);

  /// The upper half of the hash of everything added so far.
  int get hi => murmur3Finish(_hi, _length, _tail);

  /// The lower half of the hash of everything added so far.
  int get lo => murmur3Finish(_lo, _length, _tail);

  /// The hash of everything added so far.
  Hash64 get hash => Hash64(hi, lo);

  // The block scramble doesn't depend on the lane, so it runs once per block
  // for both halves.
  void _block(int k) {
    final scrambled = murmur3Scramble(k);
    _hi = murmur3Mix(_hi, scrambled);
    _lo = murmur3Mix(_lo, scrambled);
  }
}

// MurmurHash3_x86_32 building blocks, shared with Prng.derive
// (src/prng/prng.dart). They follow smhasher's MurmurHash3.cpp step by step.

const int _c1 = 0xCC9E2D51;
const int _c2 = 0x1B873593;

/// MurmurHash3_x86_32's per-block scramble of the 32-bit block [k]:
/// `rotl(k * c1, 15) * c2`.
int murmur3Scramble(int k) =>
    _mulConst(rotl32(_mulConst(k, _c1, _c1 & 0xFFFF), 15), _c2, _c2 & 0xFFFF);

/// `(x * c) mod 2^32` for a u32 constant [c] whose low 16 bits are [cLow].
///
/// This is mul32 with only [x] split: `x·c = xl·c + xh·c·2^16`, where
/// `xl·c < 2^48` is exact on the web and only `(xh·cLow) mod 2^16` survives
/// in the high term. Two multiplies instead of mul32's three, which matters
/// because the solver hashes a key for every state it reaches (spec §6.3).
/// The final mask reduces the value mod 2^32 on every platform, because a
/// web bitwise operator takes its operands mod 2^32. The vectors in
/// test/util/hash64_test.dart and test/parity/ cover it.
int _mulConst(int x, int c, int cLow) =>
    ((x & 0xFFFF) * c + ((((x >>> 16) & 0xFFFF) * cLow) & 0xFFFF) * 0x10000) &
    u32Mask;

/// MurmurHash3_x86_32's body step: folds an already [scrambled] block into
/// the running state [h].
int murmur3Mix(int h, int scrambled) {
  final r = rotl32(h ^ scrambled, 13);
  // `r * 5 + n` is below 6 · 2^32, far under 2^53, so it is exact on the web
  // before the mask and needs no mul32.
  return (r * 5 + 0xE6546B64) & u32Mask;
}

/// One full MurmurHash3_x86_32 round: scrambles the block [k] and folds it
/// into [h].
int murmur3Round(int h, int k) => murmur3Mix(h, murmur3Scramble(k));

/// MurmurHash3_x86_32's tail and finalization. [tail] holds the last
/// `length % 4` bytes little-endian (it is ignored when there are none), and
/// [length] is the total input length in bytes.
int murmur3Finish(int h, int length, int tail) {
  var v = h;
  if (length & 3 != 0) v ^= murmur3Scramble(tail);
  return fmix32(v ^ (length & u32Mask));
}
