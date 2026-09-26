import 'dart:ui' as ui;

import 'package:nesty_core/nesty_core.dart';
import 'package:nesty_render/nesty_render.dart';

/// Which doll of a clip an image slot or `<role>_size` null belongs to
/// (LOTTIE.md "Doll size, rim and tint").
enum FxRole {
  /// The single doll of `doll_pick`, `doll_move`, `doll_complete`,
  /// `doll_reveal`, `doll_idle`, `doll_win_*`, `fx_glass_unlock`, `fx_ice`.
  doll,

  /// The moving doll of `doll_nest`, `doll_swallow`, `doll_invalid`.
  mover,

  /// The doll it lands on (or is rejected by).
  target,
}

/// Which part of a doll a slot shows (docs/plans/m2-lottie-design.md §4:
/// the hard split at art y 400).
enum FxDollPart { lid, body, silhouette }

/// Every image asset id in the 29 files (LOTTIE.md "Image slots"). The game
/// fills each one with its own raster; the placeholder PNGs in
/// `design/lottie/images/` are never shipped or decoded (PROGRESS D50).
///
/// [declaredWidth] × [declaredHeight] is the asset's `w`/`h` in the JSON,
/// the box the export was authored for. lottie 3.6.1 ignores it and draws a
/// layer's image at its own pixel size, so every raster the game supplies
/// comes with its [FxRaster.scale] and the FX runtime compensates each image
/// layer's scale and anchor (m2-lottie-design §3).
enum FxImageSlot {
  dollLid('doll_lid', 512, 768, role: FxRole.doll, part: FxDollPart.lid),
  dollBody('doll_body', 512, 768, role: FxRole.doll, part: FxDollPart.body),
  moverLid('mover_lid', 512, 768, role: FxRole.mover, part: FxDollPart.lid),
  moverBody('mover_body', 512, 768, role: FxRole.mover, part: FxDollPart.body),
  targetLid('target_lid', 512, 768, role: FxRole.target, part: FxDollPart.lid),
  targetBody(
    'target_body',
    512,
    768,
    role: FxRole.target,
    part: FxDollPart.body,
  ),

  /// `doll_reveal`'s buried-nest silhouette, shadow included.
  dollSilhouette(
    'doll_silhouette',
    512,
    768,
    role: FxRole.doll,
    part: FxDollPart.silhouette,
  ),
  glowRing('glow_ring', 116, 52, piece: BoardSprite.glowRing),
  hintArrow('hint_arrow', 40, 50, piece: BoardSprite.hintArrow),
  extraSlot('extra_slot', 90, 34, piece: BoardSprite.extraSlot),
  glassCase0('glass_case_0', 86, 143, piece: BoardSprite.glassCase0),
  glassCase1('glass_case_1', 86, 143, piece: BoardSprite.glassCase1),
  glassCase2('glass_case_2', 86, 143, piece: BoardSprite.glassCase2),

  /// The unlock colour's symbol in its ink, on the padlock (not a board
  /// SVG: the skin service rasterizes it from `assets/symbols/`).
  unlockSymbol('unlock_symbol', 12, 12),
  ice0('ice_0', 96, 160, piece: BoardSprite.ice0),
  ice1('ice_1', 96, 160, piece: BoardSprite.ice1),
  ice2('ice_2', 96, 160, piece: BoardSprite.ice2),
  ice3('ice_3', 96, 160, piece: BoardSprite.ice3),
  iceShatter('ice_shatter', 96, 160, piece: BoardSprite.iceShatter);

  const FxImageSlot(
    this.assetId,
    this.declaredWidth,
    this.declaredHeight, {
    this.role,
    this.part,
    this.piece,
  });

  /// The `assets[].id` in the JSON (`LottieImageAsset.id`).
  final String assetId;

  final double declaredWidth;
  final double declaredHeight;

  /// Set for doll slots.
  final FxRole? role;

  /// Set for doll slots.
  final FxDollPart? part;

  /// The board sprite that fills it, for board pieces.
  final BoardSprite? piece;

  bool get isDoll => role != null;

  static final Map<String, FxImageSlot> _byAssetId = {
    for (final slot in values) slot.assetId: slot,
  };

  /// The slot for a `LottieImageAsset.id`, or null for an id no file uses.
  /// A map lookup: the image delegate calls this on every draw.
  static FxImageSlot? fromAssetId(String id) => _byAssetId[id];
}

/// A raster for an image slot, and how it relates to the slot's declared
/// box. Built once when a level's art is prepared and returned as the same
/// object on every draw (CLAUDE.md rule 8: no allocation per frame).
final class FxRaster {
  const FxRaster(
    this.image, {
    required this.scale,
    this.origin = ui.Offset.zero,
  }) : assert(scale > 0);

  final ui.Image image;

  /// Raster px per declared asset px: `artHeightPx / 768` for doll parts
  /// (`DollPartSet.artScale`), `BoardSpriteImage.pixelScale`
  /// (furniture scale × DPR) for board pieces.
  final double scale;

  /// Where the raster's top-left pixel sits inside the declared box, in
  /// declared px: a cropped board sprite's crop offset
  /// (`BoardSpriteImage.offset / pixelScale`), zero for full-frame rasters.
  ///
  /// The compensated layer anchor is `(authoredAnchor − origin) × scale`
  /// and the compensated layer scale `authoredScale / scale`
  /// (m2-lottie-design §3).
  final ui.Offset origin;
}

/// What one playing clip shows in its image slots. Mutable on purpose: each
/// pooled clip owns one and rewrites it when it is (re)started; the image
/// delegate reads it on every draw without allocating.
final class FxImageRequest {
  /// Colour of the [FxRole.doll] slots; null draws nothing there.
  DollColor? doll;

  /// Colour of the [FxRole.mover] slots; null draws nothing there.
  DollColor? mover;

  /// Colour of the [FxRole.target] slots; null draws nothing there.
  DollColor? target;

  /// Draws the [FxRole.doll] slots empty although [doll] is set: the doll of
  /// an iced composition while its slot is also locked (the glass
  /// composition draws it), or while a sprite draws it.
  bool hideDoll = false;

  /// `doll_invalid` after a drag: the mover returns by `doll_move` instead.
  bool hideMover = false;

  /// `doll_invalid` on a locked, iced or tower target: the target is drawn
  /// by its slot composition or sprite, which shakes by the hand-coded
  /// offset (m2-lottie-design §9).
  bool hideTarget = false;

  /// The colour on the padlock, for [FxImageSlot.unlockSymbol].
  DollColor? unlockColor;

  /// `SlotGeometry.furnitureScale` (s·q) of the slot a board-piece clip is
  /// placed on: picks the board sprite rasterized for that scale.
  double furnitureScale = 1;

  /// The colour [role] shows, or null when that role draws nothing.
  DollColor? colorOf(FxRole role) => switch (role) {
    FxRole.doll => hideDoll ? null : doll,
    FxRole.mover => hideMover ? null : mover,
    FxRole.target => hideTarget ? null : target,
  };

  /// Back to the defaults, for a clip returned to its pool.
  void reset() {
    doll = null;
    mover = null;
    target = null;
    hideDoll = false;
    hideMover = false;
    hideTarget = false;
    unlockColor = null;
    furnitureScale = 1;
  }
}

/// Supplies the rasters for image slots (LOTTIE.md "Image slots"). The skin
/// service builds one per level from the level's `DollPartSet` and
/// `BoardSprites` (m2-lottie-design §4, §16 lane "services").
///
/// [rasterFor] runs inside lottie's image delegate, on every draw and
/// bounds check (up to 6 calls per frame per clip), so it must be a lookup
/// that never allocates or awaits.
abstract interface class FxImageSource {
  /// The raster for [slot] as [request] describes it, or null when the slot
  /// must draw nothing (an unset or hidden role, a sprite that failed to
  /// load). The FX runtime then returns `FxLibrary.blank`, a 1×1
  /// transparent image, so lottie never falls back to an asset image.
  FxRaster? rasterFor(FxImageSlot slot, FxImageRequest request);
}
