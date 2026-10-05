import 'package:flutter/painting.dart';
import 'package:nesty_game/core/ui/tokens/ui_tokens.gen.dart';

/// The colour names the widgets outside the menu screens still read, and the
/// two frame values `design/tokens.json` v4 doesn't name.
///
/// Every frame colour now lives in the generated [AppColorTokens] (m7-4
/// delivery item 1.2: the frame-only colours, the toast kinds, the day
/// strip's faces, the Museum's walnut and shelf colours, the locked and
/// sunk faces, the divider). New code reads `AppColorTokens` directly, and
/// so do the menu screens. The aliases below point at the same token, so
/// the value is the design's; each goes when the last widget that reads it
/// reads the token (the board, HUD, sheets, buttons, banners and the chest:
/// the game lane's files).
///
/// Doll colours are deliberately NOT here: they belong to nesty_render,
/// keyed by nesty_core's colour ids (spec §12.3).
abstract final class AppColors {
  // ── Aliases of AppColorTokens ──

  static const iconBrown = AppColorTokens.iconBrown;
  static const textBrown = AppColorTokens.textBrown;
  static const chevron = AppColorTokens.chevron;
  static const closeFill = AppColorTokens.closeFill;
  static const closeShade = AppColorTokens.closeShade;
  static const disabledFace = AppColorTokens.disabledFace;
  static const disabledText = AppColorTokens.disabledText;
  static const disabledCoin = AppColorTokens.disabledCoin;
  static const coinChipTop = AppColorTokens.coinChipTop;
  static const coinChipBottom = AppColorTokens.coinChipBottom;
  static const coinChipEdge = AppColorTokens.coinChipEdge;
  static const adClaimedFace = AppColorTokens.adClaimedFace;
  static const adClaimedRing = AppColorTokens.adClaimedRing;
  static const superHardChipText = AppColorTokens.superHardChipText;
  static const dailyText = AppColorTokens.dailyText;
  static const dailyChipFace = AppColorTokens.dailyChipFace;
  static const sheetGrabber = AppColorTokens.sheetGrabber;
  static const iconTileGreen = AppColorTokens.iconTileGreen;
  static const warningHighlight = AppColorTokens.warningHighlight;
  static const dangerHighlight = AppColorTokens.dangerHighlight;
  static const successBannerFace = AppColorTokens.successBannerFace;
  static const successToastTitle = AppColorTokens.successToastTitle;
  static const successToastMessage = AppColorTokens.successToastMessage;
  static const infoFace = AppColorTokens.infoFace;
  static const infoEdge = AppColorTokens.infoEdge;
  static const infoTitle = AppColorTokens.infoTitle;
  static const infoText = AppColorTokens.infoText;
  static const cream = AppColorTokens.cream;
  static const playDiscShade = AppColorTokens.playDiscShade;
  static const playCaption = AppColorTokens.playCaption;
  static const woodBarHighlight = AppColorTokens.woodBarHighlight;
  static const woodBarShadow = AppColorTokens.woodBarShadow;
  static const loaderTop = AppColorTokens.loaderTop;

  /// The chest flights' trail dots: `motion.chest.collect.trail` names the
  /// colour (m7-4 1.7), so this is [ChestCollectTokens.trailColor].
  static const trailDot = ChestCollectTokens.trailColor;

  // ── Frame values with no token ──

  /// The figurine detail's art panel, a radial gradient (NestyShop `mBg`,
  /// frame 6.2 earned; 6.3 a duller one for a locked family). Tokens v4's
  /// `spotlight*` colours name the cone's and the shelf's lights, not this.
  // TODO(design): a token for the figurine panel's two gradients.
  static const spotlightEarnedTop = Color(0xFFFFF6DC);
  static const spotlightEarnedMid = Color(0xFFF2D29E);
  static const spotlightEarnedEdge = Color(0xFFE2B478);
  static const spotlightLockedTop = Color(0xFFF7EBD6);
  static const spotlightLockedMid = Color(0xFFE8D3B0);
  static const spotlightLockedEdge = Color(0xFFD9BE93);

  /// The Museum cabinet's drop shadow (NestyHub:116): `0 8 16
  /// rgba(60,25,5,.3)`.
  // TODO(design): a token for the cabinet's drop shadow.
  static const cabinetDrop = Color(0x4D3C1905);

  /// The dashed row divider of an untiled settings card (the Pause toggles,
  /// frame 8.1): `rgba(110,60,25,.2)`. Tokens v4's `divider` is the tiled
  /// Settings' solid line instead.
  // TODO(design): a token for the Pause card's dashed divider (m7-4 gave
  // `divider` to the tiled Settings line only).
  static const rowDash = Color(0x336E3C19);

  /// The segmented control's track, an inset 0 2 4 shadow:
  /// `rgba(90,45,15,.25)` (NestyHub:160).
  // TODO(design): a token for the segmented track's inset shadow.
  static const segmentedTrackShade = Color(0x405A2D0F);
}
