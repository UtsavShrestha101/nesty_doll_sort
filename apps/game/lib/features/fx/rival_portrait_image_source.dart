import 'dart:ui' show Size;

import 'package:nesty_game/core/ui/art/ui_art.dart';
import 'package:nesty_game/core/ui/art/ui_art_library.dart';
import 'package:nesty_game/features/fx/fx_image_source.dart';

/// Fills `ui_rival_react`'s `rival_portrait` slot with computer rival
/// [rival]'s portrait (`ui/rivals/rival_n.svg`, 96×96 dp at 3× in the
/// export: m7-4 C.6). The slot's art depends on the rival, so it is the
/// caller's, not an [FxImageSlot.art] (`UiArtImageSource`).
///
/// Call [prepare] once before the clip plays; [rasterFor] is then a lookup
/// that returns the same object on every draw (CLAUDE.md rule 8). Every
/// other slot, and a raster not made yet, is null (drawn blank; rule 3).
final class RivalPortraitImageSource implements FxImageSource {
  RivalPortraitImageSource(this.library, this.rival);

  final UiArtLibrary library;

  /// The rival, 1–3.
  final int rival;

  FxRaster? _raster;

  /// The box the raster fills, in dp (`FxImageSlot.rivalPortrait`).
  static Size get box => Size(
    FxImageSlot.rivalPortrait.declaredWidth,
    FxImageSlot.rivalPortrait.declaredHeight,
  );

  /// Rasterizes the portrait at [devicePixelRatio] and caches it. Never
  /// throws.
  Future<void> prepare({required double devicePixelRatio}) async {
    final art = UiArt.rival(rival);
    await library.prepare(
      [art],
      sizes: [box],
      devicePixelRatio: devicePixelRatio,
    );
    final image = library.imageOf(art, box);
    _raster = image == null
        ? null
        : FxRaster(
            image,
            scale: image.width / FxImageSlot.rivalPortrait.declaredWidth,
          );
  }

  @override
  FxRaster? rasterFor(FxImageSlot slot, FxImageRequest request) =>
      slot == FxImageSlot.rivalPortrait ? _raster : null;
}
