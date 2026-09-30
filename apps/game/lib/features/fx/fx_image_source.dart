import 'dart:ui' as ui;

import 'package:nesty_core/nesty_core.dart';
import 'package:nesty_game/core/ui/art/ui_art.dart';
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

  /// `ui_intro_towers`: the doll revealed under the moving top nest. The
  /// intro loops author their own doll sizes (their `<role>_size` nulls
  /// animate), so the game only colours these roles.
  revealed,

  /// `ui_intro_glass`, `ui_intro_ice`: the family that completes.
  family,

  /// `ui_intro_ice`: the second family (`family_2_*`).
  family2,

  /// `ui_intro_glass`, `ui_intro_ice`: the doll freed from the case or ice.
  freed,
}

/// Which part of a doll a slot shows (docs/plans/m2-lottie-design.md §4:
/// the hard split at art y 400).
enum FxDollPart { lid, body, silhouette }

/// Every image asset id in the 35 files (LOTTIE.md "Image slots"). The game
/// fills each one with its own raster; the placeholder PNGs in
/// `design/lottie/images/` are never shipped or decoded (PROGRESS D50).
///
/// Two sizes describe a slot:
/// - [assetWidth] × [assetHeight] is the asset's `w`/`h` in the JSON. Since
///   LOTTIE.md v3 the board pieces and the unlock symbol are declared at
///   [density] = 3× their box, with their layers at 33.33 % and anchors ×3,
///   so 3× art stays sharp and nothing moves on screen: `glow_ring` is
///   348×156 for a 116×52 box. Doll slots are the 512×768 artboard at 1×.
/// - [declaredWidth] × [declaredHeight] is the box the art is made for, the
///   unit every [FxRaster] counts in: the reference-board box of a board
///   piece (`BoardSprite.designSize`, `× furnitureScale × DPR` is its px size
///   on screen), 12×12 for the unlock symbol, the artboard for a doll part.
///   It was the JSON's own size until v3.
///
/// lottie 3.6.1 ignores the declared size and draws a layer's image at its
/// own pixel size, so every raster the game supplies comes with its
/// [FxRaster.scale] and the FX runtime compensates each image layer's scale
/// and anchor for it, converting the box to asset px by [density]
/// (m2-lottie-design §3). The skin service never sees the export's density.
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

  /// `doll_reveal`'s buried-nest silhouette, shadow included: the wood-grain
  /// blank `board/doll-silhouette.svg` for every skin (owner decision 3e).
  dollSilhouette(
    'doll_silhouette',
    512,
    768,
    role: FxRole.doll,
    part: FxDollPart.silhouette,
  ),
  glowRing('glow_ring', 348, 156, piece: BoardSprite.glowRing),
  hintArrow('hint_arrow', 120, 150, piece: BoardSprite.hintArrow),
  extraSlot('extra_slot', 270, 102, piece: BoardSprite.extraSlot),
  glassCase0('glass_case_0', 258, 429, piece: BoardSprite.glassCase0),
  glassCase1('glass_case_1', 258, 429, piece: BoardSprite.glassCase1),
  glassCase2('glass_case_2', 258, 429, piece: BoardSprite.glassCase2),

  /// The unlock colour's symbol in its ink, on the padlock (not a board
  /// SVG: the skin service rasterizes it from `assets/symbols/`), in a
  /// 12×12 box.
  unlockSymbol('unlock_symbol', 36, 36),
  ice0('ice_0', 288, 480, piece: BoardSprite.ice0),
  ice1('ice_1', 288, 480, piece: BoardSprite.ice1),
  ice2('ice_2', 288, 480, piece: BoardSprite.ice2),
  ice3('ice_3', 288, 480, piece: BoardSprite.ice3),
  iceShatter('ice_shatter', 288, 480, piece: BoardSprite.iceShatter),

  // m7-3 (LOTTIE.md "Image slots"). The tall glass case frames, 93×152 at
  // 3×, in `fx_glass_unlock_tall` (phase 4 architecture §2.3).
  glassCaseTall0(
    'glass_case_tall_0',
    279,
    456,
    piece: BoardSprite.glassCaseTall0,
  ),
  glassCaseTall1(
    'glass_case_tall_1',
    279,
    456,
    piece: BoardSprite.glassCaseTall1,
  ),
  glassCaseTall2(
    'glass_case_tall_2',
    279,
    456,
    piece: BoardSprite.glassCaseTall2,
  ),

  /// `ui_stars`: the stars at 44×44 (the glow 73.3), UI art at 3×, filled by
  /// `UiArtImageSource` (§3.4).
  starFilled('star_filled', 132, 132, art: UiArt.starFilled),
  starEmpty('star_empty', 132, 132, art: UiArt.starEmpty),
  starGlow('star_glow', 220, 220, art: UiArt.starGlow),

  /// `ui_chest`: the chest at 130×108.3, UI art at 3×.
  chestClosed('chest_closed', 390, 325, art: UiArt.chestClosed),
  chestOpen('chest_open', 390, 325, art: UiArt.chestOpen),

  /// The intro loops' dolls (512×768 artboards).
  revealedLid(
    'revealed_lid',
    512,
    768,
    role: FxRole.revealed,
    part: FxDollPart.lid,
  ),
  revealedBody(
    'revealed_body',
    512,
    768,
    role: FxRole.revealed,
    part: FxDollPart.body,
  ),
  familyLid('family_lid', 512, 768, role: FxRole.family, part: FxDollPart.lid),
  familyBody(
    'family_body',
    512,
    768,
    role: FxRole.family,
    part: FxDollPart.body,
  ),
  family2Lid(
    'family_2_lid',
    512,
    768,
    role: FxRole.family2,
    part: FxDollPart.lid,
  ),
  family2Body(
    'family_2_body',
    512,
    768,
    role: FxRole.family2,
    part: FxDollPart.body,
  ),
  freedLid('freed_lid', 512, 768, role: FxRole.freed, part: FxDollPart.lid),
  freedBody('freed_body', 512, 768, role: FxRole.freed, part: FxDollPart.body);

  const FxImageSlot(
    this.assetId,
    this.assetWidth,
    this.assetHeight, {
    this.role,
    this.part,
    this.piece,
    this.art,
  });

  /// Asset px per box unit of the board pieces and the unlock symbol
  /// (LOTTIE.md v3 "Image slots": declared at 3×, layers at 33.33 %).
  static const double pieceDensity = 3;

  /// The `assets[].id` in the JSON (`LottieImageAsset.id`).
  final String assetId;

  /// The asset's `w` and `h` in the JSON, in asset px: [density] × the box.
  final double assetWidth;
  final double assetHeight;

  /// Asset px per box unit: [pieceDensity] for the board pieces, the UI art
  /// and the unlock symbol, 1 for the doll slots.
  double get density => isDoll ? 1 : pieceDensity;

  /// The box the slot's art fills, in the units of [FxRaster.scale] and
  /// [FxRaster.origin]: 116×52 for `glow_ring`, 12×12 for the unlock
  /// symbol, 512×768 for a doll part.
  double get declaredWidth => assetWidth / density;
  double get declaredHeight => assetHeight / density;

  /// Set for doll slots.
  final FxRole? role;

  /// Set for doll slots.
  final FxDollPart? part;

  /// The board sprite that fills it, for board pieces.
  final BoardSprite? piece;

  /// The UI illustration that fills it (`ui_stars`, `ui_chest`: m7-3, phase
  /// 4 architecture §3.4), declared at [pieceDensity] like the board pieces.
  /// The board's `LevelSkinImages` leaves these null; `UiArtImageSource`
  /// fills them.
  final UiArt? art;

  bool get isDoll => role != null;

  static final Map<String, FxImageSlot> _byAssetId = {
    for (final slot in values) slot.assetId: slot,
  };

  /// The slot for a `LottieImageAsset.id`, or null for an id no file uses.
  /// A map lookup: the image delegate calls this on every draw.
  static FxImageSlot? fromAssetId(String id) => _byAssetId[id];
}

/// A raster for an image slot, and how it relates to the slot's box
/// ([FxImageSlot.declaredWidth] × [FxImageSlot.declaredHeight]). Built once
/// when a level's art is prepared and returned as the same object on every
/// draw (CLAUDE.md rule 8: no allocation per frame).
final class FxRaster {
  const FxRaster(
    this.image, {
    required this.scale,
    this.origin = ui.Offset.zero,
  }) : assert(scale > 0);

  final ui.Image image;

  /// Raster px per box unit: `artHeightPx / 768` for doll parts
  /// (`DollPartSet.artScale`), `BoardSpriteImage.pixelScale` (furniture
  /// scale × DPR) for board pieces, the image width ÷ 12 for the unlock
  /// symbol.
  final double scale;

  /// Where the raster's top-left pixel sits inside the box, in box units: a
  /// cropped board sprite's `BoardSpriteImage.cropOrigin`, zero for
  /// full-frame rasters.
  ///
  /// With `d` = [FxImageSlot.density], the compensated layer scale is
  /// `authoredScale × d / scale` and the compensated anchor
  /// `(authoredAnchor − origin × d) × scale / d`: the authored values are
  /// in asset px (m2-lottie-design §3).
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

  /// Colours of the intro loops' roles ([FxRole.revealed], [FxRole.family],
  /// [FxRole.family2], [FxRole.freed]); null draws nothing there.
  DollColor? revealed;
  DollColor? family;
  DollColor? family2;
  DollColor? freed;

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
    FxRole.revealed => revealed,
    FxRole.family => family,
    FxRole.family2 => family2,
    FxRole.freed => freed,
  };

  /// Back to the defaults, for a clip returned to its pool.
  void reset() {
    doll = null;
    mover = null;
    target = null;
    revealed = null;
    family = null;
    family2 = null;
    freed = null;
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
