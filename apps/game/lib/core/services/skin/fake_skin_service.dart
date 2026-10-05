import 'dart:async';

import 'package:injectable/injectable.dart';
import 'package:nesty_core/nesty_core.dart';
import 'package:nesty_game/core/dependency_injection/app_env.dart';
import 'package:nesty_game/core/services/skin/skin_service.dart';
import 'package:nesty_game/features/fx/fx_image_source.dart';
import 'package:nesty_render/nesty_render.dart';

/// [SkinService] with no rasters: rest dolls come from the procedural
/// `PlaceholderDollPainter` (spec §12.5; it draws whatever symbols mode
/// `DollPaintParams.symbols` asks for) and image slots draw nothing. No
/// async rasterization, so widget tests stay synchronous. Fake env only:
/// the real env runs `AssetSkinService`.
@LazySingleton(as: SkinService, env: [AppEnv.fake])
class FakeSkinService implements SkinService {
  /// No theme art: the page fills the chapter's fallback colour.
  @override
  ThemeBackground? get background => null;

  @override
  Future<void> load() async {}

  @override
  void dispose() => unawaited(_selectedSkinChanges.close());

  @override
  Future<LevelSkin> prepareForLevel(
    Level level, {
    required BoardGeometry geometry,
    required double devicePixelRatio,
    required DollSymbols symbols,
    String? themeId,
  }) async => _PlaceholderLevelSkin();

  @override
  String selectedSkinId = 'classic';

  final StreamController<String> _selectedSkinChanges =
      StreamController.broadcast();

  @override
  Future<bool> selectSkin(String skinId) async {
    final changed = skinId != selectedSkinId;
    selectedSkinId = skinId;
    if (changed && !_selectedSkinChanges.isClosed) {
      _selectedSkinChanges.add(skinId);
    }
    return true;
  }

  @override
  Stream<String> get selectedSkinChanges => _selectedSkinChanges.stream;

  @override
  Future<LevelSkin?> prepareShowcase({
    required List<DollColor> colors,
    required double devicePixelRatio,
    required DollSymbols symbols,
    String? skinId,
  }) async => _PlaceholderLevelSkin();
}

final class _PlaceholderLevelSkin implements LevelSkin {
  @override
  final FxImageSource images = const _NoImages();

  @override
  final DollRenderer restRenderer = PlaceholderDollPainter();

  @override
  BoardSprites? get sprites => null;

  bool _disposed = false;

  @override
  void dispose() {
    if (_disposed) return;
    _disposed = true;
    restRenderer.dispose();
  }
}

final class _NoImages implements FxImageSource {
  const _NoImages();

  @override
  FxRaster? rasterFor(FxImageSlot slot, FxImageRequest request) => null;
}
