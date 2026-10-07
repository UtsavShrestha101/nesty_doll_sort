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

  /// The figurine detail's art panel, a radial gradient (NestyShop `mBg`,
  /// frame 6.2 earned; 6.3 a duller one for a locked family). tokens.json's
  /// `spotlightPanel` (white 55 %) is the cone's fill, not this.
  // TODO(design): m7-5 named no token for the figurine panel's two gradients;
  // the frame's `mBg` values stay here (BACKLOG "Design gaps").
  static const spotlightEarnedTop = Color(0xFFFFF6DC);
  static const spotlightEarnedMid = Color(0xFFF2D29E);
  static const spotlightEarnedEdge = Color(0xFFE2B478);
  static const spotlightLockedTop = Color(0xFFF7EBD6);
  static const spotlightLockedMid = Color(0xFFE8D3B0);
  static const spotlightLockedEdge = Color(0xFFD9BE93);
}
