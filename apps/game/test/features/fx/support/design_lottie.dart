import 'dart:convert';
import 'dart:io';

/// Reads the owner's exports straight from `design/lottie/` (read-only),
/// so the frozen FX contracts are checked against the source files before
/// the asset sync ships them. `flutter test` runs with `apps/game` as the
/// working directory.
final Directory designLottieDir = Directory('../../design/lottie');

/// The file names (without `.json`) in `design/lottie/`.
List<String> designLottieNames() =>
    designLottieDir
        .listSync()
        .whereType<File>()
        .map((f) => f.uri.pathSegments.last)
        .where((n) => n.endsWith('.json'))
        .map((n) => n.substring(0, n.length - '.json'.length))
        .toList()
      ..sort();

Map<String, Object?> readDesignLottie(String name) =>
    jsonDecode(File('${designLottieDir.path}/$name.json').readAsStringSync())
        as Map<String, Object?>;

/// Every layer of [json], root first, then each precomp's layers.
Iterable<Map<String, Object?>> allLayers(Map<String, Object?> json) sync* {
  for (final layer in json['layers']! as List<Object?>) {
    yield layer! as Map<String, Object?>;
  }
  for (final asset in json['assets']! as List<Object?>) {
    final layers = (asset! as Map<String, Object?>)['layers'] as List<Object?>?;
    if (layers == null) continue;
    for (final layer in layers) {
      yield layer! as Map<String, Object?>;
    }
  }
}

/// The root layer called [name] in [json].
Map<String, Object?> rootLayer(Map<String, Object?> json, String name) =>
    (json['layers']! as List<Object?>).cast<Map<String, Object?>>().firstWhere(
      (l) => l['nm'] == name,
    );

/// The keyframes of transform property [key] (`p`, `s`, `o`…) of [layer]
/// as (time, first component) pairs; a static property gives one pair at 0.
List<(double, double)> keyframes(
  Map<String, Object?> layer,
  String key, {
  int component = 0,
}) {
  final prop = (layer['ks']! as Map<String, Object?>)[key]! as Map;
  final k = prop['k']! as List<Object?>;
  if (prop['a'] == 0) {
    return [(0, (k[component]! as num).toDouble())];
  }
  return [
    for (final kf in k.cast<Map<String, Object?>>())
      (
        (kf['t']! as num).toDouble(),
        ((kf['s']! as List<Object?>)[component]! as num).toDouble(),
      ),
  ];
}
