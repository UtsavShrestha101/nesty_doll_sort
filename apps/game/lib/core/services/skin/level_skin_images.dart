import 'dart:ui' as ui;

import 'package:nesty_core/nesty_core.dart';
import 'package:nesty_game/features/fx/fx_image_source.dart';
import 'package:nesty_render/nesty_render.dart';

/// One unlock colour's padlock symbol, rasterized for one furniture scale
/// (docs/plans/m2-lottie-design.md §3 "the unlock symbol").
final class UnlockSymbolRaster {
  const UnlockSymbolRaster({
    required this.color,
    required this.furnitureScale,
    required this.raster,
  });

  final DollColor color;
  final double furnitureScale;

  /// A square image in ink, [FxRaster.scale] = its px per declared px (the
  /// slot is 12 × 12).
  final FxRaster raster;
}

/// The [FxImageSource] of one prepared board (m2-lottie-design §3, §4):
/// - doll slots: the lid, body or silhouette raster of the role's colour
///   from the level's [DollPartSet], scale `DollPartSet.artScale`;
/// - board pieces: `BoardSprites.image(piece, request.furnitureScale)`,
///   scale `pixelScale`, origin the crop offset in declared px;
/// - `unlock_symbol`: the request's unlock colour at the nearest prepared
///   furniture scale.
///
/// Null (the FX runtime then draws `FxLibrary.blank`, a 1×1 transparent
/// image) for an unset or hidden role, a colour the set doesn't hold, a
/// sprite that isn't rasterized yet or failed.
///
/// [rasterFor] runs inside lottie's image delegate on every draw: every
/// [FxRaster] is built once, board-piece wrappers on the first lookup of
/// each image (CLAUDE.md rule 8). Does not own [parts], [sprites] or the
/// unlock images; [dispose] only stops listening to [sprites].
final class LevelSkinImages implements FxImageSource {
  LevelSkinImages({
    DollPartSet? parts,
    BoardSprites? sprites,
    Iterable<UnlockSymbolRaster> unlockSymbols = const [],
  }) : _sprites = sprites,
       _silhouette = parts == null
           ? null
           : FxRaster(parts.silhouette, scale: parts.artScale),
       _lids = _perColor(parts, (set, color) => set.lid(color)),
       _bodies = _perColor(parts, (set, color) => set.body(color)),
       _unlocks = List.generate(
         DollColor.values.length,
         (_) => <(int, FxRaster)>[],
         growable: false,
       ) {
    for (final symbol in unlockSymbols) {
      _unlocks[symbol.color.index].add((
        _scaleKey(symbol.furnitureScale),
        symbol.raster,
      ));
    }
    sprites?.addListener(_forgetPieces);
  }

  final BoardSprites? _sprites;
  final FxRaster? _silhouette;

  /// Per `DollColor.index`; null for colours the set doesn't hold.
  final List<FxRaster?> _lids;
  final List<FxRaster?> _bodies;

  /// Per `DollColor.index`: (scale key, raster).
  final List<List<(int, FxRaster)>> _unlocks;

  /// Board-piece wrappers by image identity. Cleared whenever the sprites
  /// change (an image landed, was evicted or released), so a disposed
  /// image is never handed out.
  final Map<BoardSpriteImage, FxRaster> _pieces = Map.identity();

  bool _disposed = false;

  // ── Hot path: lottie's image delegate. No allocation (rule 8). ──

  @override
  FxRaster? rasterFor(FxImageSlot slot, FxImageRequest request) {
    if (_disposed) return null;
    final role = slot.role;
    if (role != null) {
      final color = request.colorOf(role);
      if (color == null) return null;
      return switch (slot.part) {
        FxDollPart.lid => _lids[color.index],
        FxDollPart.body => _bodies[color.index],
        FxDollPart.silhouette || null => _silhouette,
      };
    }
    final piece = slot.piece;
    if (piece != null) return _piece(piece, request.furnitureScale);
    final unlock = request.unlockColor;
    return unlock == null ? null : _unlock(unlock, request.furnitureScale);
  }

  FxRaster? _piece(BoardSprite piece, double furnitureScale) {
    final image = _sprites?.image(piece, furnitureScale);
    if (image == null) return null;
    return _pieces[image] ??= FxRaster(
      image.image,
      scale: image.pixelScale,
      origin: image.cropOrigin,
    );
  }

  FxRaster? _unlock(DollColor color, double furnitureScale) {
    final candidates = _unlocks[color.index];
    final key = _scaleKey(furnitureScale);
    FxRaster? nearest;
    var nearestDistance = 0;
    for (var i = 0; i < candidates.length; i++) {
      final (candidateKey, raster) = candidates[i];
      final distance = (candidateKey - key).abs();
      if (nearest == null || distance < nearestDistance) {
        nearest = raster;
        nearestDistance = distance;
      }
    }
    return nearest;
  }

  // ── End of hot path. ──

  /// Stops listening to the sprites. Idempotent.
  void dispose() {
    if (_disposed) return;
    _disposed = true;
    _sprites?.removeListener(_forgetPieces);
    _pieces.clear();
  }

  void _forgetPieces() => _pieces.clear();

  static int _scaleKey(double furnitureScale) =>
      (furnitureScale * 1024).round();

  static List<FxRaster?> _perColor(
    DollPartSet? parts,
    ui.Image? Function(DollPartSet parts, DollColor color) imageOf,
  ) => List.generate(DollColor.values.length, (i) {
    if (parts == null) return null;
    final image = imageOf(parts, DollColor.values[i]);
    return image == null ? null : FxRaster(image, scale: parts.artScale);
  }, growable: false);
}
