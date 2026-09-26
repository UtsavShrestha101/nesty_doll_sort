// VM/web parity for the u32 helpers (design §3 and §5, Q9). A JS number is
// exact only to 2^53 and its bitwise operators work on 32 bits, so these are
// the operations most likely to drift between the VM and dart2js. The values
// come from exact Python integers; test/util/u32_test.dart also checks them
// against a BigInt oracle.
@Tags(['parity'])
library;

import 'package:nesty_core/src/util/u32.dart';
import 'package:test/test.dart';

import 'parity.dart';
import 'vectors/u32_vectors.dart';

void main() {
  parityTest(
    'mul32 over the edge grid',
    () => [
      for (final a in u32Edges) [for (final b in u32Edges) mul32(a, b)],
    ],
    expected: u32Mul,
  );

  parityTest(
    'fmix32 over the edges',
    () => [for (final a in u32Edges) fmix32(a)],
    expected: u32Fmix,
  );

  parityTest(
    'rotl32 over the edges',
    () => [
      for (final a in u32Edges) [for (final r in u32RotlBy) rotl32(a, r)],
    ],
    expected: u32Rotl,
  );
}
