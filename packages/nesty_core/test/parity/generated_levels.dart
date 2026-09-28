/// The fingerprint of a device-generated level (docs/plans/m3-design.md §5),
/// shared by test/generator/daily_golden_test.dart (VM) and
/// generated_level_parity_test.dart (VM, node, chrome, wasm).
///
/// The app always generates with `Generator.generateWithRetries` (m3 §5,
/// D70), so that is what is pinned: the Hash64 digest of the level's JSON
/// (as golden_test.dart), the seed that produced it (the params' own seed,
/// or a retry seed), the attempt, and the simulated tier.
library;

import 'dart:convert';

import 'package:nesty_core/nesty_core.dart';

import 'parity.dart';

/// Hash64 hex of `jsonEncode(LevelCodec.encode(level))`.
String levelFingerprintDigest(Level level) =>
    parityDigestString(jsonEncode(LevelCodec.encode(level)));

/// The fingerprint of `generateWithRetries(params)`, as a parity value.
/// Throws a [StateError] when no seed gave a level.
Map<String, Object> generatedFingerprint(GeneratorParams params) {
  final outcome = Generator.generateWithRetries(params);
  if (outcome is! GeneratorSuccess) {
    throw StateError('${params.id}: $outcome');
  }
  return fingerprintOf(outcome);
}

/// The fingerprint of a generated level, as a parity value.
Map<String, Object> fingerprintOf(GeneratorSuccess success) => {
  'digest': levelFingerprintDigest(success.level),
  'seed': success.level.seed!,
  'attempt': success.attempt,
  'tier': success.simulation.tier.id,
  'tierMatched': success.tierMatched,
};
