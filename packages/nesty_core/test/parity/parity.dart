/// Harness for the VM/web parity suite (docs/plans/m1-core-design.md §5,
/// D11, Q9).
///
/// The web admin and the phones must agree bit for bit on everything
/// deterministic: PRNG streams, hashes, canonical keys, solver verdicts and
/// moves, simulator counts and generated levels (spec §6.5, §7.5). A parity
/// case computes a JSON-shaped value and compares it with a const expected
/// value. The same file then runs unchanged on every platform:
///
/// ```
/// dart test test/parity                          # VM
/// dart test -p node test/parity                  # dart2js, JS numbers
/// dart test -p chrome test/parity                # dart2js in a browser
/// dart test -p chrome -c dart2wasm test/parity   # wasm, 64-bit ints
/// ```
///
/// Rules for files in test/parity/ (checked by parity_guard_test.dart):
/// - Start with `@Tags(['parity'])` and a `library;` directive.
/// - No dart:io, dart:isolate, dart:ffi or dart:mirrors, no file reads and no
///   `@TestOn`. Expected values are consts in the file or in `vectors/`.
/// - Register cases with [parityTest]. A later M1 step adds its own file,
///   for example `solver_parity_test.dart`, next to the existing ones.
///
/// A parity value is null, a bool, a String, an int within ±(2^53 − 1), or a
/// List or `Map<String, …>` of parity values. Doubles are refused: `1.0`
/// prints as `1.0` on the VM but `1` on the web, and the design keeps doubles
/// out of every determinism-relevant output (win counts are ints, §3). Sets
/// are refused too, because their order is an implementation detail.
library;

import 'dart:convert';

import 'package:nesty_core/src/util/hash64.dart';
import 'package:test/test.dart';

/// The tag every parity test carries (declared in dart_test.yaml).
const String parityTag = 'parity';

/// Whether this run uses JS numbers (dart2js on chrome or node), where `int`
/// is a double that is exact only up to 2^53. It is false on the VM and in
/// wasm, which have 64-bit ints. `identical(1, 1.0)` is the usual test,
/// because only JS numbers make the two literals the same object.
final bool parityOnJsNumbers = identical(1, 1.0);

/// A label for failure messages.
String get parityPlatform => parityOnJsNumbers
    ? 'dart2js (JS numbers)'
    : 'VM or dart2wasm (64-bit ints)';

/// The largest integer that is exact on every platform.
const int maxParityInt = 0x1FFFFFFFFFFFFF;

/// Registers a parity case: [compute] runs inside the test and must return a
/// parity value equal to [expected] on every platform.
///
/// On a mismatch the failure prints [compute]'s value as canonical JSON (keys
/// sorted). Paste it as the new expectation only when the change is
/// intended, and only once every platform agrees. For generator output that
/// also means a `Generator.version` bump (spec §6.5).
void parityTest(
  String description,
  Object? Function() compute, {
  required Object? expected,
  Timeout? timeout,
  Object? skip,
}) {
  test(
    description,
    () {
      checkParityValue(expected, 'expected');
      final actual = compute();
      checkParityValue(actual, 'actual');
      expect(
        actual,
        equals(expected),
        reason:
            'Parity mismatch on $parityPlatform. The actual value, as '
            'canonical JSON:\n${parityJson(actual)}',
      );
    },
    tags: parityTag,
    timeout: timeout,
    skip: skip,
  );
}

/// Throws a [ParityValueError] unless [value] is a parity value (see the
/// library doc). [path] names the value in the error.
void checkParityValue(Object? value, [String path = r'$']) {
  switch (value) {
    case null || bool() || String():
      return;
    case int():
      if (value < -maxParityInt || value > maxParityInt) {
        throw ParityValueError(path, 'int $value is not exact on the web');
      }
    case num():
      throw ParityValueError(
        path,
        'double $value prints differently per '
        'platform; return an int or a String',
      );
    case List<Object?>():
      for (var i = 0; i < value.length; i++) {
        checkParityValue(value[i], '$path[$i]');
      }
    case Map<Object?, Object?>():
      for (final MapEntry(:key, value: item) in value.entries) {
        if (key is! String) {
          throw ParityValueError(path, 'map key $key is not a String');
        }
        checkParityValue(item, '$path.$key');
      }
    default:
      throw ParityValueError(
        path,
        '${value.runtimeType} is not JSON-shaped; convert it to lists, maps '
        'and ints',
      );
  }
}

/// [value] as canonical JSON: map keys sorted, no whitespace. Two parity
/// values are equal exactly when their canonical JSON is equal.
String parityJson(Object? value) {
  checkParityValue(value);
  return jsonEncode(_sortKeys(value));
}

/// The [Hash64] hex digest of the u32 [words], for parity cases whose raw
/// output is too long to keep as a const (for example a long PRNG stream).
String parityDigestU32s(List<int> words) => Hash64.ofU32s(words).toHex();

/// The [Hash64] hex digest of [string]'s UTF-16 code units, for example of
/// `jsonEncode(LevelCodec.encode(level))` for a generated level.
String parityDigestString(String string) => Hash64.ofString(string).toHex();

/// A value that can't be compared across platforms.
final class ParityValueError extends Error {
  ParityValueError(this.path, this.problem);

  /// Where in the value the problem is, such as `actual[3].moves`.
  final String path;

  /// What is wrong with it.
  final String problem;

  @override
  String toString() => 'Not a parity value at $path: $problem';
}

Object? _sortKeys(Object? value) => switch (value) {
  List<Object?>() => [for (final item in value) _sortKeys(item)],
  Map<Object?, Object?>() => {
    for (final key in value.keys.cast<String>().toList()..sort())
      key: _sortKeys(value[key]),
  },
  _ => value,
};
