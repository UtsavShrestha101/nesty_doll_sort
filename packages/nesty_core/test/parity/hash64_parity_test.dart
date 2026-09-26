// VM/web parity for Hash64 (spec §6.2, design §5, Q9). The solver's
// canonical keys, the simulator's default seed and the generator's golden
// hashes are all Hash64 values, so they must match the independent Python
// reference on the VM, in dart2js (chrome, node) and in wasm.
@Tags(['parity'])
library;

import 'package:nesty_core/src/util/hash64.dart';
import 'package:nesty_core/src/util/u32.dart';
import 'package:test/test.dart';

import 'parity.dart';
import 'vectors/hash64_vectors.dart';

void main() {
  parityTest(
    'both halves reproduce the published MurmurHash3_x86_32 vectors',
    () => [
      for (final v in murmur3Published)
        {...v, 'hash': _laneHash(v['bytes']! as List<int>, v['seed']! as int)},
    ],
    expected: murmur3Published,
  );

  parityTest(
    'ofU32s, ofU16s and ofBytes goldens',
    () => [
      for (final v in hash64Goldens)
        {...v, 'hex': _hashOf(v['kind']! as String, v['input']! as List<int>)},
    ],
    expected: hash64Goldens,
  );

  parityTest(
    'ofString goldens (UTF-16 code units, surrogates included)',
    () => [
      for (final v in hash64StringGoldens)
        {...v, 'hex': Hash64.ofString(v['input']! as String).toHex()},
    ],
    expected: hash64StringGoldens,
  );

  parityTest(
    'mixed-width stream through one builder',
    () {
      final builder = Hash64Builder();
      for (final [kind as String, value as int]
          in hash64MixedStream['ops']! as List<List<Object>>) {
        switch (kind) {
          case 'u8':
            builder.addU8(value);
          case 'u16':
            builder.addU16(value);
          default:
            builder.addU32(value);
        }
      }
      return {
        ...hash64MixedStream,
        'hex': builder.hash.toHex(),
        // The same bytes in one call must agree, so the carry paths are
        // checked against the plain byte path too.
        'bytesHex': Hash64.ofBytes(
          hash64MixedStream['bytes']! as List<int>,
        ).toHex(),
      };
    },
    expected: {...hash64MixedStream, 'bytesHex': hash64MixedStream['hex']},
  );

  parityTest(
    '1,000 words i * 0x9E3779B9',
    () => Hash64.ofU32s([
      for (var i = 0; i < 1000; i++) mul32(i, 0x9E3779B9),
    ]).toHex(),
    expected: hash64LargeU32,
  );
}

/// One MurmurHash3_x86_32 half with a custom seed. Both halves run with the
/// same seed must give the same value.
int _laneHash(List<int> bytes, int seed) {
  final hash = (Hash64Builder(
    hiSeed: seed,
    loSeed: seed,
  )..addBytes(bytes)).hash;
  expect(hash.hi, hash.lo, reason: 'the two halves differ for seed $seed');
  return hash.lo;
}

String _hashOf(String kind, List<int> input) => switch (kind) {
  'u32' => Hash64.ofU32s(input),
  'u16' => Hash64.ofU16s(input),
  'bytes' => Hash64.ofBytes(input),
  _ => throw ArgumentError.value(kind, 'kind'),
}.toHex();
