import 'dart:async';
import 'dart:developer' as developer;
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:injectable/injectable.dart';
import 'package:nesty_core/nesty_core.dart';
import 'package:nesty_game/core/dependency_injection/app_env.dart';
import 'package:nesty_game/core/services/skin/doll_part_source.dart';
import 'package:nesty_game/core/services/skin/level_skin_images.dart';
import 'package:nesty_game/core/services/skin/skin_service.dart';
import 'package:nesty_game/core/services/skin/unlock_symbol_rasterizer.dart';
import 'package:nesty_game/features/fx/fx_image_source.dart';
import 'package:nesty_render/nesty_render.dart';

/// Real [SkinService] over the bundled art (spec §7.4, §12.2, §13.5;
/// docs/plans/m2-lottie-design.md §4; PROGRESS D20: all art is bundled).
///
/// [load] (once, at splash) reads what every board shares: the selected
/// skin's layers (`SkinRasterizer`), the belly symbols (`SymbolAtlas`) and
/// the 15 board SVGs (`BoardSpriteLibrary`). [prepareForLevel] then builds
/// one board's [LevelSkin]:
/// - the level's `DollPartSet` (every colour on the board, at
///   `DollPartRasters.artHeightPxFor(geometry.maxDollHeight, dpr)`, in the
///   player's symbols mode), from the skin or, if that fails, from the
///   placeholder painter with the same split;
/// - `BoardSprites` at every furniture scale on the board, plus the
///   family counter's icon, the extra-slot stand while +Slot can still add
///   one, and every ice frame at each iced slot's scale;
/// - each locked slot's unlock symbol at `12 × furnitureScale × DPR` px;
/// - `PartRasterDollRenderer` over the same parts for the rest sprites.
///
/// Rule 3: every step that fails is logged and falls back (placeholder
/// parts, then the placeholder painter; no sprites; no symbol), so neither
/// method ever throws and the board always draws.
// TODO(M3): the shop's selected skin from the save instead of Classic.
@LazySingleton(as: SkinService, env: [AppEnv.real])
class AssetSkinService implements SkinService {
  AssetSkinService({
    @ignoreParam AssetBundle? bundle,
    @ignoreParam SkinLoader? skinLoader,
    @ignoreParam DollPartSource? parts,
    @ignoreParam UnlockSymbolRasterizer? unlockSymbols,
    @ignoreParam String skinId = defaultSkinId,
  }) : _bundle = bundle ?? rootBundle,
       _skinLoader = skinLoader,
       _parts = parts ?? DollPartRastersSource(),
       _unlockSymbols = unlockSymbols,
       _skinId = skinId;

  /// The bundled skin every player starts with (spec §13.5).
  static const defaultSkinId = 'classic';

  final AssetBundle _bundle;
  final SkinLoader? _skinLoader;
  final DollPartSource _parts;
  final UnlockSymbolRasterizer? _unlockSymbols;
  final String _skinId;

  Future<void>? _loading;
  SkinRasterizer? _skin;
  SymbolAtlas? _atlas;
  BoardSpriteLibrary? _board;
  ThemeBackground? _background;
  bool _disposed = false;

  late final UnlockSymbolRasterizer _symbolRasterizer =
      _unlockSymbols ?? BundledUnlockSymbolRasterizer(_bundle);

  /// True once [load] got the skin's layers (false: placeholder dolls).
  @visibleForTesting
  bool get hasSkin => _skin != null;

  /// True once [load] got the board SVGs (false: no sprites).
  @visibleForTesting
  bool get hasBoardArt => _board != null;

  @override
  ThemeBackground? get background {
    if (_disposed) return null;
    return _background ??= ThemeBackground(
      bundle: _bundle,
      onError: (error, stack) => _log('theme background', error, stack),
    );
  }

  @override
  Future<void> load() => _loading ??= _loadOnce();

  Future<void> _loadOnce() async {
    await Future.wait([_loadSkin(), _loadAtlas(), _loadBoard()]);
  }

  Future<void> _loadSkin() async {
    try {
      final loader = _skinLoader ?? AssetBundleSkinLoader(bundle: _bundle);
      final skin = SkinRasterizer(await loader.load(_skinId));
      await skin.ensureReady();
      if (_disposed) {
        skin.dispose();
        return;
      }
      _skin = skin;
    } on Object catch (error, stack) {
      _log(
        'skin $_skinId did not load; dolls use the placeholder',
        error,
        stack,
      );
    }
  }

  Future<void> _loadAtlas() async {
    try {
      final atlas = await SymbolAtlas.load(_bundle);
      if (_disposed) {
        atlas.dispose();
        return;
      }
      _atlas = atlas;
    } on Object catch (error, stack) {
      _log('the belly symbols did not load; bodies have none', error, stack);
    }
  }

  Future<void> _loadBoard() async {
    try {
      final board = await BoardSpriteLibrary.load(
        _bundle,
        onError: (error, stack) => _log('a board sprite', error, stack),
      );
      if (_disposed) {
        board.dispose();
        return;
      }
      _board = board;
    } on Object catch (error, stack) {
      _log('the board art did not load; boards draw flat', error, stack);
    }
  }

  @override
  Future<LevelSkin> prepareForLevel(
    Level level, {
    required BoardGeometry geometry,
    required double devicePixelRatio,
    required DollSymbols symbols,
  }) async {
    await load();
    final dpr = devicePixelRatio.isFinite && devicePixelRatio > 0
        ? devicePixelRatio
        : 1.0;
    final parts = await _prepareParts(level, geometry, dpr, symbols);
    final sprites = await _prepareSprites(level, geometry, dpr);
    final unlocks = await _prepareUnlockSymbols(level, geometry, dpr);
    // The renderer owns what it is given, the skin keeps its own handles.
    final DollRenderer renderer = parts != null
        ? PartRasterDollRenderer(parts.clone())
        : PlaceholderDollPainter(symbols: _atlas);
    try {
      await renderer.prepare(
        heights: geometry.dollHeights,
        devicePixelRatio: dpr,
      );
    } on Object catch (error, stack) {
      _log('preparing the rest dolls failed', error, stack);
    }
    return _AssetLevelSkin(
      images: LevelSkinImages(
        parts: parts,
        sprites: sprites,
        unlockSymbols: unlocks,
      ),
      restRenderer: renderer,
      sprites: sprites,
      parts: parts,
      unlockImages: [for (final u in unlocks) u.raster.image],
    );
  }

  Future<DollPartSet?> _prepareParts(
    Level level,
    BoardGeometry geometry,
    double dpr,
    DollSymbols symbols,
  ) async {
    if (_disposed) return null;
    final int artHeightPx;
    try {
      artHeightPx = DollPartRasters.artHeightPxFor(
        tallestDollHeight: geometry.maxDollHeight,
        devicePixelRatio: dpr,
      );
    } on ArgumentError catch (error, stack) {
      _log('a board with no doll height', error, stack);
      return null;
    }
    final colors = colorsOf(level);
    final skin = _skin;
    if (skin != null) {
      try {
        return await _parts.prepare(
          skin: skin,
          colors: colors,
          symbols: symbols,
          artHeightPx: artHeightPx,
          symbolAtlas: _atlas,
        );
      } on Object catch (error, stack) {
        _log('the skin parts failed; using the placeholder', error, stack);
      }
    }
    try {
      return await _parts.preparePlaceholder(
        colors: colors,
        symbols: symbols,
        artHeightPx: artHeightPx,
        symbolAtlas: _atlas,
      );
    } on Object catch (error, stack) {
      _log(
        'the placeholder parts failed; image slots stay empty',
        error,
        stack,
      );
      return null;
    }
  }

  Future<BoardSprites?> _prepareSprites(
    Level level,
    BoardGeometry geometry,
    double dpr,
  ) async {
    final library = _board;
    if (library == null || _disposed) return null;
    final sprites = BoardSprites(
      library,
      onError: (error, stack) => _log('a board sprite raster', error, stack),
    );
    try {
      await sprites.prepare(
        geometry,
        devicePixelRatio: dpr,
        also: [
          // The HUD's family counter icon (not board-scaled).
          BoardSprite.dollSilhouette,
          if (canStillAddExtraSlot(geometry)) BoardSprite.extraSlot,
        ],
      );
      // Every stage of the ice, at the iced slots' scales only: they are
      // the fx_ice composition's image slots (m2-lottie-design §8).
      final iced = <double>{};
      forEachSlot(level, (id, slot) {
        if (slot.isFrozen) {
          final scale = geometry.slotOrNull(id)?.furnitureScale;
          if (scale != null) iced.add(scale);
        }
      });
      await Future.wait([
        for (final scale in iced)
          for (final sprite in _iceSprites) sprites.ensure(sprite, scale),
      ]);
      return sprites;
    } on Object catch (error, stack) {
      _log('the board sprites failed; boards draw flat', error, stack);
      sprites.dispose();
      return null;
    }
  }

  Future<List<UnlockSymbolRaster>> _prepareUnlockSymbols(
    Level level,
    BoardGeometry geometry,
    double dpr,
  ) async {
    final wanted = <(DollColor, double)>{};
    forEachSlot(level, (id, slot) {
      if (slot is! LockedSlot) return;
      final scale = geometry.slotOrNull(id)?.furnitureScale;
      if (scale != null) wanted.add((slot.unlockColor, scale));
    });
    final rasters = <UnlockSymbolRaster>[];
    for (final (color, scale) in wanted) {
      if (_disposed) break;
      try {
        final sizePx = (FxImageSlot.unlockSymbol.declaredWidth * scale * dpr)
            .round()
            .clamp(1, 4096);
        final image = await _symbolRasterizer.rasterize(color, sizePx);
        rasters.add(
          UnlockSymbolRaster(
            color: color,
            furnitureScale: scale,
            raster: FxRaster(
              image,
              scale: image.width / FxImageSlot.unlockSymbol.declaredWidth,
            ),
          ),
        );
      } on Object catch (error, stack) {
        _log('the ${color.id} unlock symbol failed', error, stack);
      }
    }
    return rasters;
  }

  /// Releases everything the service holds (get_it dispose hook). Boards
  /// already prepared keep their own handles. Idempotent.
  @override
  @disposeMethod
  void dispose() {
    if (_disposed) return;
    _disposed = true;
    _parts.dispose();
    _skin?.dispose();
    _atlas?.dispose();
    _board?.dispose();
    _background?.dispose();
    _skin = null;
    _atlas = null;
    _board = null;
    _background = null;
  }

  static const _iceSprites = [
    BoardSprite.ice0,
    BoardSprite.ice1,
    BoardSprite.ice2,
    BoardSprite.ice3,
    BoardSprite.iceShatter,
  ];

  /// The colours on [level]'s board, in `DollColor` order: the ones the
  /// part rasters are needed for.
  @visibleForTesting
  static List<DollColor> colorsOf(Level level) {
    final present = List.filled(DollColor.values.length, false);
    forEachSlot(level, (_, slot) {
      for (final nest in slot.nests) {
        present[nest.color.index] = true;
      }
      if (slot is LockedSlot) present[slot.unlockColor.index] = true;
    });
    return [
      for (final color in DollColor.values)
        if (present[color.index]) color,
    ];
  }

  /// True while the +Slot booster can still append a stand to [geometry]'s
  /// bottom shelf (at most `LayoutLimits.maxExtraSlots`, D22), so its
  /// sprite is ready before the re-pitch.
  @visibleForTesting
  static bool canStillAddExtraSlot(BoardGeometry geometry) {
    var extras = 0;
    for (final slot in geometry.slots) {
      if (slot.kind == SlotShapeKind.extra) extras++;
    }
    return extras < LayoutLimits.maxExtraSlots &&
        geometry.shelves.last.slots.length <
            BoardLayoutConstants.maxSlotsPerRow;
  }

  /// Calls [visit] with every slot of [level] and its nesty_core id.
  @visibleForTesting
  static void forEachSlot(
    Level level,
    void Function(String id, Slot slot) visit,
  ) {
    final ids = level.slotIds;
    var i = 0;
    for (final shelf in level.shelves) {
      for (final slot in shelf) {
        visit(ids[i++], slot);
      }
    }
  }

  static void _log(String message, Object error, StackTrace? stack) {
    developer.log(message, name: 'nesty.skin', error: error, stackTrace: stack);
    // developer.log never reaches the `flutter run` terminal.
    if (kDebugMode) debugPrint('[nesty.skin] $message: $error');
  }
}

/// One prepared board. Owns its part set, sprites, rest renderer and
/// unlock-symbol images.
final class _AssetLevelSkin implements LevelSkin {
  _AssetLevelSkin({
    required LevelSkinImages images,
    required this.restRenderer,
    required this.sprites,
    required DollPartSet? parts,
    required List<ui.Image> unlockImages,
  }) : _images = images,
       _parts = parts,
       _unlockImages = unlockImages;

  final LevelSkinImages _images;
  final DollPartSet? _parts;
  final List<ui.Image> _unlockImages;
  bool _disposed = false;

  @override
  FxImageSource get images => _images;

  @override
  final DollRenderer restRenderer;

  @override
  final BoardSprites? sprites;

  @override
  void dispose() {
    if (_disposed) return;
    _disposed = true;
    _images.dispose();
    restRenderer.dispose();
    sprites?.dispose();
    _parts?.dispose();
    for (final image in _unlockImages) {
      image.dispose();
    }
  }
}
