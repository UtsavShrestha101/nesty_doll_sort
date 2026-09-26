import 'dart:ui' as ui;

import 'package:lottie/lottie.dart';
import 'package:nesty_game/features/fx/fx_image_source.dart';

/// One clip's bridge from lottie's image slots to the level's art
/// (m2-lottie-design §3, §4): the [source] (the level's
/// `LevelSkin.images`), this clip's [request] (which colours its roles
/// show, which roles are hidden, the furniture scale) and the 1×1 [blank]
/// every empty slot gets.
///
/// Owned by one drawable. [delegate] is the `LottieDelegates.image`
/// callback, built once; the compensation delegates call [rasterFor] for
/// the raster a layer will draw (they run before the image is fetched).
final class FxImages {
  FxImages({this.source, this.blank});

  /// The level's rasters; null draws every slot [blank] (no skin yet, the
  /// fake env). Swapped when the level's `LevelSkin` is replaced.
  FxImageSource? source;

  /// `FxLibrary.blank`: returned for a slot that must draw nothing, so
  /// lottie never falls back to an asset image. Null only in the fake
  /// library, where lottie then draws nothing either (`fromBytes` loads no
  /// asset images).
  ui.Image? blank;

  /// What this clip shows; rewritten when the clip is (re)started.
  final FxImageRequest request = FxImageRequest();

  /// The `LottieDelegates.image` callback (one tear-off, made once).
  late final ui.Image? Function(LottieComposition, LottieImageAsset) delegate =
      _imageFor;

  // What the last draw was served, per `FxImageSlot.index`, so a recorded
  // rest picture can tell when its art changed (a sprite that landed late,
  // a new level skin, a different colour).
  final List<FxRaster?> _served = List.filled(
    FxImageSlot.values.length,
    null,
    growable: false,
  );
  final List<bool> _asked = List.filled(
    FxImageSlot.values.length,
    false,
    growable: false,
  );

  /// Forgets what was served (before recording a rest picture).
  void clearServed() {
    for (var i = 0; i < _asked.length; i++) {
      _asked[i] = false;
      _served[i] = null;
    }
  }

  // ── Hot path: lottie's image and compensation delegates, every draw. ──

  /// The raster [slot] shows now, or null for [blank].
  FxRaster? rasterFor(FxImageSlot slot) {
    final raster = source?.rasterFor(slot, request);
    _served[slot.index] = raster;
    _asked[slot.index] = true;
    return raster;
  }

  /// True when every slot the last draw asked for would still get the same
  /// raster object: a recorded rest picture is still current.
  bool get servedStillCurrent {
    final slots = FxImageSlot.values;
    for (var i = 0; i < _asked.length; i++) {
      if (!_asked[i]) continue;
      final now = source?.rasterFor(slots[i], request);
      if (!identical(now, _served[i])) return false;
    }
    return true;
  }

  ui.Image? _imageFor(LottieComposition composition, LottieImageAsset asset) {
    final slot = FxImageSlot.fromAssetId(asset.id);
    if (slot == null) return blank;
    return rasterFor(slot)?.image ?? blank;
  }

  // ── End of hot path. ──
}
