import 'package:nesty_tools/src/fx/lottie_contract.dart';

/// Small readers over a decoded Lottie JSON tree, shared by the validator
/// and the spec codegen. They never throw: a missing or mistyped value reads
/// as empty or null, and the validator reports it.

/// Layer `ty`s (Lottie 5.7 schema).
abstract final class LottieLayerType {
  static const precomp = 0;
  static const image = 2;
  static const nullLayer = 3;
  static const text = 5;

  /// The highest type lottie 3.6.1 draws (0 precomp … 5 text).
  static const last = text;
}

/// The elements of [value] that are JSON objects (`[]` for anything else).
List<Map<String, Object?>> lottieMaps(Object? value) => [
  if (value is List<Object?>)
    for (final item in value)
      if (item is Map<String, Object?>) item,
];

/// The transform property [key] (`p`, `s`, `a`, `o`, `r`) of [layer].
Map<String, Object?>? lottieTransform(Map<String, Object?> layer, String key) {
  final ks = layer['ks'];
  if (ks is! Map<String, Object?>) return null;
  final prop = ks[key];
  return prop is Map<String, Object?> ? prop : null;
}

/// Whether a property is keyframed (`a: 1`).
bool lottieIsAnimated(Map<String, Object?>? prop) => prop?['a'] == 1;

/// The first two components of a JSON number list, or null.
LottiePoint? lottiePoint(Object? value) {
  if (value is! List<Object?> || value.length < 2) return null;
  final [x, y, ...] = value;
  if (x is! num || y is! num) return null;
  return LottiePoint(x.toDouble(), y.toDouble());
}
