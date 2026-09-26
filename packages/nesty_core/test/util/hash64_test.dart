// Hash64 (spec §6.2, PROGRESS Q9, docs/plans/m1-core-design.md §1): two
// MurmurHash3_x86_32 halves over one little-endian byte stream. Each half
// must reproduce MurmurHash3's published vectors. The builder must hash a
// stream the same way however it is split and whatever widths feed it. The
// Python goldens for the default seeds are compared in
// test/parity/hash64_parity_test.dart on every platform. No dart:io, so this
// file runs on chrome and node too.
import 'dart:typed_data';

import 'package:nesty_core/nesty_core.dart';
import 'package:nesty_core/src/util/hash64.dart';
import 'package:nesty_core/src/util/u32.dart';
import 'package:test/test.dart';

import '../parity/vectors/hash64_vectors.dart';

/// The little-endian bytes of u32 words.
List<int> _bytesOfU32s(List<int> words) => [
  for (final w in words) ...[
    w & 0xFF,
    (w >>> 8) & 0xFF,
    (w >>> 16) & 0xFF,
    (w >>> 24) & 0xFF,
  ],
];

/// The little-endian bytes of u16 units.
List<int> _bytesOfU16s(List<int> units) => [
  for (final u in units) ...[u & 0xFF, (u >>> 8) & 0xFF],
];

void main() {
  group('each half is MurmurHash3_x86_32', () {
    test('reproduces the 20 published test vectors', () {
      for (final v in murmur3Published) {
        final seed = v['seed']! as int;
        final bytes = v['bytes']! as List<int>;
        final builder = Hash64Builder(hiSeed: seed, loSeed: seed)
          ..addBytes(bytes);
        expect(builder.hi, v['hash'], reason: 'hi, seed $seed, $bytes');
        expect(builder.lo, v['hash'], reason: 'lo, seed $seed, $bytes');
      }
    });

    test('the block scramble equals rotl(k * c1, 15) * c2 via mul32', () {
      // murmur3Scramble uses a constant-operand multiply instead of mul32.
      // mul32 is checked against a BigInt oracle in u32_test.dart.
      int reference(int k) =>
          mul32(rotl32(mul32(k, 0xCC9E2D51), 15), 0x1B873593);
      final prng = Prng(77);
      final inputs = [
        0,
        1,
        0xFFFF,
        0x10000,
        0x7FFFFFFF,
        0x80000000,
        0xFFFFFFFF,
        -1,
        -0x80000000,
        for (var i = 0; i < 2000; i++) prng.nextU32(),
      ];
      for (final k in inputs) {
        expect(murmur3Scramble(k), reference(k), reason: 'k = $k');
      }
    });

    test('the halves use different seeds', () {
      expect(Hash64.hiSeed, isNot(Hash64.loSeed));
      final hash = Hash64.ofString('nesty');
      expect(hash.hi, isNot(hash.lo));
    });

    test('the default halves are the published algorithm with those seeds', () {
      const bytes = [0x6E, 0x65, 0x73, 0x74, 0x79];
      final hi = Hash64Builder(hiSeed: Hash64.hiSeed, loSeed: 0)
        ..addBytes(bytes);
      final lo = Hash64Builder(hiSeed: 0, loSeed: Hash64.loSeed)
        ..addBytes(bytes);
      expect(Hash64.ofBytes(bytes), Hash64(hi.hi, lo.lo));
    });
  });

  group('input widths share one byte stream', () {
    const words = [0x03020100, 0x07060504, 0xFFFEFDFC, 0x80000001, 0];

    test('u32 words hash as their little-endian bytes', () {
      for (var n = 0; n <= words.length; n++) {
        final prefix = words.sublist(0, n);
        expect(
          Hash64.ofU32s(prefix),
          Hash64.ofBytes(_bytesOfU32s(prefix)),
          reason: '$prefix',
        );
      }
    });

    test('u16 units hash as their little-endian bytes', () {
      const units = [0x0100, 0x0302, 0xFFFF, 0x8000, 0x0001, 0];
      for (var n = 0; n <= units.length; n++) {
        final prefix = units.sublist(0, n);
        expect(
          Hash64.ofU16s(prefix),
          Hash64.ofBytes(_bytesOfU16s(prefix)),
          reason: '$prefix',
        );
      }
    });

    test('a String hashes as its UTF-16 code units', () {
      for (final s in ['', 'a', 'ab', 'abc', 'Matryoshka \u{1FA86} déjà vu']) {
        expect(Hash64.ofString(s), Hash64.ofU16s(s.codeUnits), reason: s);
      }
      // A surrogate pair is two units; a lone surrogate is kept as is.
      expect('\u{1FA86}'.codeUnits, [0xD83E, 0xDE86]);
      expect(Hash64.ofString('\uD800'), Hash64.ofU16s([0xD800]));
    });

    test('values are masked to their width', () {
      expect(Hash64.ofU32s([-1]), Hash64.ofU32s([0xFFFFFFFF]));
      expect(Hash64.ofU32s([0x1FFFFFFFF]), Hash64.ofU32s([0xFFFFFFFF]));
      expect(Hash64.ofU16s([0x1ABCD]), Hash64.ofU16s([0xABCD]));
      expect(Hash64.ofBytes([0x1FF, -1]), Hash64.ofBytes([0xFF, 0xFF]));
    });

    test('typed lists work, including signed Int32List values', () {
      final signed = Int32List.fromList([-1, -0x80000000, 7]);
      expect(Hash64.ofU32s(signed), Hash64.ofU32s([0xFFFFFFFF, 0x80000000, 7]));
      expect(
        Hash64.ofU16s(Uint16List.fromList([1, 2, 3])),
        Hash64.ofU16s([1, 2, 3]),
      );
      expect(
        Hash64.ofBytes(Uint8List.fromList([1, 2, 3])),
        Hash64.ofBytes([1, 2, 3]),
      );
    });

    test('start and end select a sub-range', () {
      expect(Hash64.ofU32s(words, 1, 4), Hash64.ofU32s(words.sublist(1, 4)));
      expect(Hash64.ofU16s([9, 8, 7, 6], 1), Hash64.ofU16s([8, 7, 6]));
      expect(Hash64.ofBytes([9, 8, 7], 0, 0), Hash64.ofBytes(const []));
      expect(() => Hash64.ofU32s(words, 2, 1), throwsRangeError);
      expect(() => Hash64.ofU16s([1], 0, 2), throwsRangeError);
    });
  });

  group('Hash64Builder', () {
    test('any split of a stream gives the same hash', () {
      final bytes = [for (var i = 0; i < 23; i++) (i * 37 + 11) & 0xFF];
      final whole = Hash64.ofBytes(bytes);
      for (var a = 0; a <= bytes.length; a++) {
        for (var b = a; b <= bytes.length; b++) {
          final builder = Hash64Builder()
            ..addBytes(bytes, 0, a)
            ..addBytes(bytes, a, b)
            ..addBytes(bytes, b);
          expect(builder.hash, whole, reason: 'split at $a, $b');
        }
      }
    });

    test('random mixes of u8, u16 and u32 match the plain byte stream', () {
      // Covers every carry path: each width arriving with 0..3 bytes
      // pending, and the list fast paths entered unaligned.
      final prng = Prng(2026);
      for (var round = 0; round < 300; round++) {
        final builder = Hash64Builder();
        final bytes = <int>[];
        final ops = prng.nextIntBetween(0, 12);
        for (var i = 0; i < ops; i++) {
          final value = prng.nextU32();
          switch (prng.nextInt(6)) {
            case 0:
              builder.addU8(value);
              bytes.add(value & 0xFF);
            case 1:
              builder.addU16(value);
              bytes.addAll(_bytesOfU16s([value & 0xFFFF]));
            case 2:
              builder.addU32(value);
              bytes.addAll(_bytesOfU32s([value]));
            case 3:
              final chunk = [value & 0xFF, value >>> 24, 0x5A];
              builder.addBytes(chunk);
              bytes.addAll(chunk);
            case 4:
              final chunk = [value & 0xFFFF, value >>> 16, 0x1234];
              builder.addU16s(chunk);
              bytes.addAll(_bytesOfU16s(chunk));
            default:
              final chunk = [value, value ^ 0xFFFFFFFF];
              builder.addU32s(chunk);
              bytes.addAll(_bytesOfU32s(chunk));
          }
        }
        expect(builder.hash, Hash64.ofBytes(bytes), reason: 'round $round');
      }
    });

    test('reading the hash does not change the state', () {
      final builder = Hash64Builder()..addU16(0x4241);
      final first = builder.hash;
      expect(builder.hi, first.hi);
      expect(builder.lo, first.lo);
      builder.addU8(0x43);
      expect(builder.hash, Hash64.ofBytes([0x41, 0x42, 0x43]));
    });

    test('reset starts a new stream with the same seeds', () {
      final builder = Hash64Builder(hiSeed: 1, loSeed: 2)
        ..addU32(123)
        ..addU8(4)
        ..reset()
        ..addString('abc');
      expect(
        builder.hash,
        (Hash64Builder(hiSeed: 1, loSeed: 2)..addString('abc')).hash,
      );
      expect(Hash64Builder().hash, Hash64.ofBytes(const []));
    });

    test('halves are always u32', () {
      final prng = Prng(7);
      for (var i = 0; i < 200; i++) {
        final hash = Hash64.ofU32s(_take(prng, i % 9));
        expect(hash.hi, inInclusiveRange(0, 0xFFFFFFFF));
        expect(hash.lo, inInclusiveRange(0, 0xFFFFFFFF));
      }
    });
  });

  group('Hash64 value', () {
    test('has value equality', () {
      expect(const Hash64(1, 2), const Hash64(1, 2));
      expect(const Hash64(1, 2).hashCode, const Hash64(1, 2).hashCode);
      expect(const Hash64(1, 2), isNot(const Hash64(2, 1)));
    });

    test('toHex is 16 lowercase digits, hi first', () {
      expect(const Hash64(0, 1).toHex(), '0000000000000001');
      expect(const Hash64(0xABCDEF01, 0x0F).toHex(), 'abcdef010000000f');
      expect(
        const Hash64(0xFFFFFFFF, 0xFFFFFFFF).toString(),
        'Hash64(ffffffffffffffff)',
      );
    });

    test('distinct short inputs give distinct hashes', () {
      final hashes = {
        for (var i = 0; i < 5000; i++) Hash64.ofU32s([i]),
        for (var i = 0; i < 5000; i++) Hash64.ofU16s([i]),
      };
      expect(hashes, hasLength(10000));
    });
  });
}

List<int> _take(Prng prng, int count) => [
  for (var i = 0; i < count; i++) prng.nextU32(),
];
