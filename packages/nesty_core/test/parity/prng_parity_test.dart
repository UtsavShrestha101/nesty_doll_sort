// VM/web parity for Prng (spec §6.5, design §5): every stream the generator
// and simulator draw from must match the independent Python reference on the
// VM, in dart2js (chrome, node) and in wasm, or a daily puzzle could differ
// between the web admin and a phone (spec §7.5).
@Tags(['parity'])
library;

import 'package:nesty_core/nesty_core.dart';
import 'package:test/test.dart';

import 'parity.dart';
import 'vectors/prng_vectors.dart';

List<int> _take(Prng prng, int count) => [
  for (var i = 0; i < count; i++) prng.nextU32(),
];

int _int(Map<String, Object> vector, String key) => vector[key]! as int;

List<Object?> _shuffled(Prng prng, List<Object?> input) {
  final copy = List<Object?>.of(input);
  prng.shuffle(copy);
  return copy;
}

void main() {
  parityTest(
    'nextU32 streams by seed',
    () => [
      for (final v in prngSeedStreams)
        {'seed': v['seed'], 'u32': _take(Prng(_int(v, 'seed')), 16)},
    ],
    expected: prngSeedStreams,
  );

  parityTest(
    'derive(seed, a, b)',
    () => [
      for (final v in prngDerive)
        {
          ...v,
          'value': Prng.derive(_int(v, 'seed'), _int(v, 'a'), _int(v, 'b')),
        },
    ],
    expected: prngDerive,
  );

  parityTest(
    'generator attempt sub-streams: Prng(derive(seed, attempt))',
    () => [
      for (final v in prngAttemptStreams)
        {
          ...v,
          'u32': _take(
            Prng(Prng.derive(_int(v, 'seed'), _int(v, 'attempt'))),
            4,
          ),
        },
    ],
    expected: prngAttemptStreams,
  );

  parityTest('nextInt over bounds 1..2^32', () {
    final prng = Prng(_int(prngNextInt, 'seed'));
    final bounds = prngNextInt['bounds']! as List<int>;
    return {
      'seed': prngNextInt['seed'],
      'bounds': bounds,
      'values': [for (final bound in bounds) prng.nextInt(bound)],
      'after': prng.nextU32(),
    };
  }, expected: prngNextInt);

  parityTest(
    'nextInt rejection sampling draws the same raw values',
    () {
      final seed = _int(prngRejection, 'seed');
      final bound = _int(prngRejection, 'bound');
      final prng = Prng(seed);
      final values = [for (var i = 0; i < 24; i++) prng.nextInt(bound)];
      final after = prng.nextU32();
      // How many raw values the 24 calls consumed: the position of `after`
      // in a fresh copy of the raw stream.
      final raw = _take(Prng(seed), 200);
      return {
        'seed': seed,
        'bound': bound,
        'values': values,
        'draws': raw.indexOf(after),
        'after': after,
      };
    },
    expected: prngRejection,
  );

  parityTest(
    'nextIntBetween, including negative and 2^53-wide ends',
    () {
      final prng = Prng(_int(prngNextIntBetween, 'seed'));
      final ranges = prngNextIntBetween['ranges']! as List<List<int>>;
      return {
        'seed': prngNextIntBetween['seed'],
        'ranges': ranges,
        'values': [
          for (final [min, max] in ranges) prng.nextIntBetween(min, max),
        ],
        'after': prng.nextU32(),
      };
    },
    expected: prngNextIntBetween,
  );

  parityTest('nextBool', () {
    final prng = Prng(_int(prngNextBool, 'seed'));
    return {
      'seed': prngNextBool['seed'],
      'values': [for (var i = 0; i < 64; i++) prng.nextBool()],
    };
  }, expected: prngNextBool);

  parityTest('shuffle', () {
    final prng = Prng(_int(prngShuffle, 'seed'));
    final cases = prngShuffle['cases']! as List<Object?>;
    return {
      'seed': prngShuffle['seed'],
      'cases': [
        for (final c in cases.cast<Map<String, Object?>>())
          {
            'input': c['input'],
            'output': _shuffled(prng, c['input']! as List<Object?>),
          },
      ],
      'after': prng.nextU32(),
    };
  }, expected: prngShuffle);

  parityTest('pick', () {
    final prng = Prng(_int(prngPick, 'seed'));
    final from = prngPick['from']! as List<String>;
    return {
      'seed': prngPick['seed'],
      'from': from,
      'values': [for (var i = 0; i < 12; i++) prng.pick(from)],
    };
  }, expected: prngPick);

  parityTest('100,000-value stream: last value and digest', () {
    final prng = Prng(_int(prngLongStream, 'seed'));
    final stream = _take(prng, _int(prngLongStream, 'count'));
    return {
      'seed': prngLongStream['seed'],
      'count': stream.length,
      'last': stream.last,
      'digest': parityDigestU32s(stream),
    };
  }, expected: prngLongStream);
}
