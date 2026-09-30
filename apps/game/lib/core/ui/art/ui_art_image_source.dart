import 'dart:ui' show Size;

import 'package:nesty_game/core/ui/art/ui_art_library.dart';
import 'package:nesty_game/features/fx/fx_image_source.dart';

/// Fills the UI-art image slots of `ui_stars` and `ui_chest`
/// (`FxImageSlot.art`: `star_filled`, `star_empty`, `star_glow`,
/// `chest_closed`, `chest_open`) from a [UiArtLibrary] (phase 4 architecture
/// §3.4).
///
/// Each slot's raster is its box ([FxImageSlot.declaredWidth] ×
/// [FxImageSlot.declaredHeight], e.g. 44×44 for a star) at the screen's
/// pixel ratio, so [FxRaster.scale] is that ratio: the FX runtime's
/// compensation converts it to the export's 3× density like a board piece's
/// (m2-lottie-design §3). Every other slot, and a slot whose raster isn't
/// made yet, is null (drawn blank; rule 3).
///
/// Call [prepare] once before the clip plays (the win card, the chest
/// card); [rasterFor] is then a lookup that returns the same objects on
/// every draw (CLAUDE.md rule 8).
final class UiArtImageSource implements FxImageSource {
  UiArtImageSource(this.library);

  final UiArtLibrary library;

  /// The UI-art slots, in [FxImageSlot] order.
  static final List<FxImageSlot> slots = [
    for (final slot in FxImageSlot.values)
      if (slot.art != null) slot,
  ];

  final List<FxRaster?> _rasters = List.filled(
    FxImageSlot.values.length,
    null,
    growable: false,
  );

  /// The box a slot's raster fills, in dp.
  static Size boxOf(FxImageSlot slot) =>
      Size(slot.declaredWidth, slot.declaredHeight);

  /// Rasterizes [only] (default: every UI-art slot) at [devicePixelRatio]
  /// and caches the rasters. Never throws.
  Future<void> prepare({
    required double devicePixelRatio,
    Iterable<FxImageSlot>? only,
  }) async {
    final wanted = [
      for (final slot in only ?? slots)
        if (slot.art != null) slot,
    ];
    for (final slot in wanted) {
      await library.prepare(
        [slot.art!],
        sizes: [boxOf(slot)],
        devicePixelRatio: devicePixelRatio,
      );
      final image = library.imageOf(slot.art!, boxOf(slot));
      _rasters[slot.index] = image == null
          ? null
          : FxRaster(image, scale: image.width / slot.declaredWidth);
    }
  }

  @override
  FxRaster? rasterFor(FxImageSlot slot, FxImageRequest request) =>
      slot.art == null ? null : _rasters[slot.index];
}
