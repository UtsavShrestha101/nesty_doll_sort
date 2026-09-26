import 'package:flutter/foundation.dart' show immutable;
import 'package:flutter/services.dart' show AssetBundle;
import 'package:nesty_render/src/skin/skin_manifest.dart';
import 'package:nesty_render/src/skin/svg/skin_svg_splitter.dart';

/// Everything needed to rasterize one skin: its validated manifest and its
/// per-group layer SVGs (spec §12.2).
@immutable
final class SkinSource {
  const SkinSource({required this.manifest, required this.layers});

  final SkinManifest manifest;
  final SkinLayers layers;
}

/// A skin that could not be loaded. Callers keep their current skin or the
/// placeholder (spec §12.5, §13.5 "If a download fails, keep the current
/// skin").
final class SkinLoadException implements Exception {
  const SkinLoadException(this.skinId, this.cause);

  final String skinId;

  /// The underlying error: a missing asset, a [SkinManifestException] or a
  /// [SkinSvgException].
  final Object cause;

  @override
  String toString() => 'SkinLoadException($skinId): $cause';
}

/// Loads a skin by id.
///
/// The bundled loader is [AssetBundleSkinLoader]. M4 adds a Storage loader
/// that fetches the admin's pre-split layers (`skins/{id}/v{n}/{group}.svg`,
/// spec §14.2) and wraps them in `SkinLayers` directly.
abstract interface class SkinLoader {
  /// Throws [SkinLoadException] when the skin is missing or invalid.
  Future<SkinSource> load(String skinId);
}

// Same rule as the manifest validator's skinId: ids become asset paths, so
// nothing but kebab-case may reach the bundle.
final _skinId = RegExp(r'^[a-z0-9]+(?:-[a-z0-9]+)*$');

/// Loads `<basePath>/<skinId>/skin.svg` + `skin.json` from an
/// [AssetBundle] and splits the SVG into layers.
///
/// The game passes `rootBundle` and the default base path (the assets
/// `sync_design_assets` writes to `apps/game/assets/skins/`). The admin can
/// reuse it with its own bundle and path.
final class AssetBundleSkinLoader implements SkinLoader {
  const AssetBundleSkinLoader({
    required this.bundle,
    this.basePath = 'assets/skins',
  });

  final AssetBundle bundle;
  final String basePath;

  /// The asset key of [skinId]'s canonical SVG.
  String svgKey(String skinId) => '$basePath/$skinId/skin.svg';

  /// The asset key of [skinId]'s manifest.
  String manifestKey(String skinId) => '$basePath/$skinId/skin.json';

  @override
  Future<SkinSource> load(String skinId) async {
    if (!_skinId.hasMatch(skinId)) {
      throw SkinLoadException(
        skinId,
        ArgumentError.value(skinId, 'skinId', 'not a kebab-case skin id'),
      );
    }
    try {
      // cache: false — the text is only needed until it is split; keeping
      // it in the bundle's cache would hold ~15–30 KB per skin for nothing.
      final texts = await Future.wait([
        bundle.loadString(manifestKey(skinId), cache: false),
        bundle.loadString(svgKey(skinId), cache: false),
      ]);
      final manifest = SkinManifest.parse(texts[0], expectedSkinId: skinId);
      return SkinSource(
        manifest: manifest,
        layers: SkinSvgSplitter.split(texts[1]),
      );
    } on SkinLoadException {
      rethrow;
    } on Object catch (e) {
      throw SkinLoadException(skinId, e);
    }
  }
}
