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

/// A stretch where a keyframed point property does not move: from a
/// keyframe's time to the next one's.
final class LottieHold {
  const LottieHold(this.start, this.end, this.value);

  final double start;
  final double end;
  final LottiePoint value;

  @override
  bool operator ==(Object other) =>
      other is LottieHold &&
      other.start == start &&
      other.end == end &&
      other.value == value;

  @override
  int get hashCode => Object.hash(start, end, value);

  @override
  String toString() => '$start–$end at $value';
}

/// The holds of a keyframed point property [prop] (a null's `p`): each
/// keyframe whose end value equals its start (two equal consecutive
/// keyframes, or a hold keyframe `h: 1`) holds from its time to the next
/// keyframe's. Adjacent holds at one value merge. Nothing holds after the
/// last keyframe: lottie still calls the position callback there (probe
/// `tail_hold_test`).
///
/// lottie 3.6.1 returns the keyframe value without calling a position
/// callback during a hold (lottie audit #2), so a remapped null (`travel`,
/// `drop`) must have none (LOTTIE.md v3 "Travel remap").
List<LottieHold> lottieHolds(Map<String, Object?>? prop) {
  final keyframes = lottieMaps(prop?['k']);
  final holds = <LottieHold>[];
  for (var i = 0; i + 1 < keyframes.length; i++) {
    final kf = keyframes[i];
    final next = keyframes[i + 1];
    final start = lottiePoint(kf['s']);
    final from = kf['t'];
    final to = next['t'];
    if (start == null || from is! num || to is! num) continue;
    final end = lottiePoint(kf['e']) ?? lottiePoint(next['s']) ?? start;
    if (kf['h'] != 1 && start != end) continue;
    if (holds.isNotEmpty &&
        holds.last.end == from.toDouble() &&
        holds.last.value == start) {
      holds[holds.length - 1] = LottieHold(
        holds.last.start,
        to.toDouble(),
        start,
      );
    } else {
      holds.add(LottieHold(from.toDouble(), to.toDouble(), start));
    }
  }
  return holds;
}
