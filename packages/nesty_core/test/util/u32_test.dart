// Web-safe 32-bit arithmetic (docs/plans/m1-core-design.md §3, PROGRESS Q9).
// Every helper is checked against a BigInt oracle, which is exact on every
// platform, and against vectors computed independently in Python. The file
// uses no dart:io, so `dart test -p chrome,node test/util` checks the same
// expectations under dart2js.
import 'dart:typed_data';

import 'package:nesty_core/src/util/u32.dart';
import 'package:test/test.dart';

final _mask = BigInt.from(0xFFFFFFFF);

int _oracle(BigInt value) => (value & _mask).toInt();

BigInt _big(int x) => BigInt.from(x) & _mask;

/// Edge values around every 16-bit and 32-bit boundary, plus the murmur3
/// constants.
const _edges = [
  0,
  1,
  2,
  3,
  0x7FFF,
  0x8000,
  0xFFFF,
  0x10000,
  0x10001,
  0x7FFFFFFF,
  0x80000000,
  0x80000001,
  0xFFFEFFFF,
  0xFFFF0000,
  0xFFFFFFFE,
  0xFFFFFFFF,
  0x12345678,
  0x9E3779B9,
  0x85EBCA6B,
  0xC2B2AE35,
  0xDEADBEEF,
];

/// A deterministic spread of 32-bit values from a BigInt LCG, so the test
/// needs no PRNG of its own (core's PRNG is itself built on these helpers).
List<int> _spread(int count) {
  final a = BigInt.parse('6364136223846793005');
  final c = BigInt.parse('1442695040888963407');
  final m64 = (BigInt.one << 64) - BigInt.one;
  var x = BigInt.from(20260926);
  return [
    for (var i = 0; i < count; i++) (((x = (x * a + c) & m64) >> 32).toInt()),
  ];
}

void main() {
  final values = [..._edges, ..._spread(200)];

  test('the spread stays in [0, 2^32)', () {
    for (final v in values) {
      expect(v, inInclusiveRange(0, 0xFFFFFFFF));
    }
  });

  group('matches the BigInt oracle', () {
    test('add32', () {
      for (final a in values) {
        for (final b in _edges) {
          expect(add32(a, b), _oracle(_big(a) + _big(b)), reason: '$a + $b');
        }
      }
    });

    test('sub32', () {
      for (final a in values) {
        for (final b in _edges) {
          expect(sub32(a, b), _oracle(_big(a) - _big(b)), reason: '$a - $b');
        }
      }
    });

    test('mul32', () {
      for (final a in values) {
        for (final b in values) {
          expect(mul32(a, b), _oracle(_big(a) * _big(b)), reason: '$a * $b');
        }
      }
    });

    test('shl32', () {
      for (final x in values) {
        for (var n = 0; n < 32; n++) {
          expect(shl32(x, n), _oracle(_big(x) << n), reason: '$x << $n');
        }
      }
    });

    test('rotl32, including rotations by 0, 32 and more', () {
      for (final x in values) {
        for (var r = 0; r <= 40; r++) {
          final n = r % 32;
          final expected = _oracle((_big(x) << n) | (_big(x) >> (32 - n)));
          expect(rotl32(x, r), expected, reason: 'rotl($x, $r)');
        }
      }
    });

    test('not32', () {
      for (final x in values) {
        expect(not32(x), _oracle(_mask - _big(x)), reason: '~$x');
      }
    });

    test('fmix32', () {
      int oracleFmix(int h) {
        var v = _big(h);
        v ^= v >> 16;
        v = (v * BigInt.from(0x85EBCA6B)) & _mask;
        v ^= v >> 13;
        v = (v * BigInt.from(0xC2B2AE35)) & _mask;
        v ^= v >> 16;
        return v.toInt();
      }

      for (final h in values) {
        expect(fmix32(h), oracleFmix(h), reason: 'fmix32($h)');
      }
    });
  });

  group('matches vectors computed in Python', () {
    test('fmix32 (MurmurHash3 finalizer)', () {
      expect(fmix32(0), 0);
      expect(fmix32(1), 0x514E28B7);
      expect(fmix32(2), 0x30F4C306);
      expect(fmix32(0xDEADBEEF), 0x0DE5C6A9);
      expect(fmix32(0xFFFFFFFF), 0x81F16F39);
      expect(fmix32(0x80000000), 0x6D3C65A0);
      expect(fmix32(0x12345678), 0xE37CD1BC);
    });

    test('mul32', () {
      expect(mul32(0xFFFFFFFF, 0xFFFFFFFF), 1);
      expect(mul32(0x9E3779B9, 0x85EBCA6B), 0xC10EDA53);
      expect(mul32(0x12345678, 0x87654321), 0x70B88D78);
    });

    test('rotl32', () {
      expect(rotl32(0x80000001, 1), 3);
      expect(rotl32(0x12345678, 8), 0x34567812);
      expect(rotl32(0xDEADBEEF, 31), 0xEF56DF77);
    });
  });

  group('results are always in [0, 2^32)', () {
    test('for every helper and input', () {
      for (final a in values) {
        for (final b in _edges) {
          for (final r in [
            add32(a, b),
            sub32(a, b),
            mul32(a, b),
            rotl32(a, b),
            shl32(a, b & 31),
            not32(a),
            fmix32(a),
            toU32(a),
          ]) {
            expect(r, inInclusiveRange(0, 0xFFFFFFFF));
          }
        }
      }
    });
  });

  test('accepts signed values read back from an Int32List', () {
    // The solver snapshot is an Int32List, so values at or above 2^31 come
    // back negative and must mean the same 32 bits.
    final list = Int32List.fromList([for (final v in values) v.toSigned(32)]);
    for (var i = 0; i < values.length; i++) {
      final signed = list[i];
      final unsigned = values[i];
      expect(toU32(signed), unsigned);
      expect(mul32(signed, 0x85EBCA6B), mul32(unsigned, 0x85EBCA6B));
      expect(add32(signed, 7), add32(unsigned, 7));
      expect(sub32(signed, 7), sub32(unsigned, 7));
      expect(rotl32(signed, 13), rotl32(unsigned, 13));
      expect(not32(signed), not32(unsigned));
      expect(fmix32(signed), fmix32(unsigned));
    }
  });
}
