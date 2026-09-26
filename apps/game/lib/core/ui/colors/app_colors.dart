import 'package:flutter/painting.dart';
import 'package:nesty_game/core/ui/tokens/ui_tokens.gen.dart';

/// Colours the App Flow frames use that `design/tokens.json` doesn't name.
///
/// Every token colour lives in the generated `AppColorTokens`; use that
/// first. The values here are copied from the prototypes (the file and the
/// element are noted on each), so widgets never hard-code a hex value.
///
/// TODO(design): ask the designer to add these to tokens.json `color`, then
/// switch the call sites to `AppColorTokens` and delete them here.
///
/// Doll colours are deliberately NOT here: they belong to nesty_render,
/// keyed by nesty_core's colour ids (spec §12.3).
abstract final class AppColors {
  // ── Content ──

  /// Icon glyphs and secondary-button text (every `#6E4526` in NestyBoard,
  /// NestyOverlay and NestyMenus).
  static const iconBrown = Color(0xFF6E4526);

  /// Sheet subtitles and progress-card labels (NestyOverlay OOM subtitle,
  /// win card label).
  static const textBrown = Color(0xFF7A5234);

  /// Sheet-row chevrons (NestyOverlay OOM Restart row).
  static const chevron = Color(0xFFB98A60);

  // ── Close button (NestyOverlay buy/pause cards) ──

  static const closeFill = Color(0xFFF6E2C2);

  /// Its 3 px inner bottom shade.
  static const closeShade = Color(0xFFE3C394);

  // ── Disabled (NestyOverlay 3.8 "can't afford offline") ──

  static const disabledFace = Color(0xFFE8DCCB);
  static const disabledText = Color(0xFFA48B72);
  static const disabledCoin = Color(0xFFCDB89C);

  // ── Coin price chip (NestyOverlay OOM row, NestyBoard coin badge) ──

  static const coinChipTop = Color(0xFFFFF1C9);
  static const coinChipBottom = Color(0xFFF9DC8A);
  static const coinChipEdge = Color(0xFFD4A93A);

  // ── Ad (NestyOverlay 2.9 "Reward added") ──

  static const adClaimedFace = Color(0xFFE9DDF9);
  static const adClaimedRing = Color(0xFFC9B3F0);

  // ── Tiers (NestyBoard super-hard chip, daily pill) ──

  static const superHardChipText = Color(0xFF6A31A6);
  static const dailyText = Color(0xFF5A3F06);
  static const dailyChipFace = Color(0xFFFFF8DC);

  // ── Sheets ──

  /// `rgba(110,70,40,.25)`: the 44×5 grabber.
  static const sheetGrabber = Color(0x406E4628);

  /// `rgba(110,60,25,.2)`: dashed row dividers (Pause toggles).
  static const divider = Color(0x336E3C19);

  /// The green icon tile of the +1 Slot row.
  static const iconTileGreen = Color(0xFFCDEFD6);

  // ── Banners (design/README.md "Banners / toasts") ──

  static const warningHighlight = Color(0xFFFFF4EA);
  static const dangerHighlight = Color(0xFFFFF2F2);
  static const successBannerFace = Color(0xFFEAF7EC);
  static const infoFace = Color(0xFFE8F3FF);
  static const infoEdge = Color(0xFF9CC4EA);
  static const infoTitle = Color(0xFF23456E);
  static const infoText = Color(0xFF46698F);

  // ── Brand (NestyMenus splash and Home) ──

  /// Wordmark fill and the Home play disc.
  static const cream = Color(0xFFFFF6E6);

  /// The play disc's inner bottom shade.
  static const playDiscShade = Color(0xFFF2CFA4);

  /// The "PLAY" caption.
  static const playCaption = Color(0xFFFFE9D2);

  // ── Wood ──

  /// `rgba(255,225,180,.6)`: the booster bar's and bottom nav's 3 px top
  /// highlight.
  static const woodBarHighlight = Color(0x99FFE1B4);

  /// `rgba(90,45,15,.25)`: the shadow the wood bar casts upward.
  static const woodBarShadow = Color(0x405A2D0F);

  // ── Progress (NestyMenus splash loader) ──

  /// The splash loader's orange fill top (the bottom is
  /// `AppColorTokens.primary`).
  static const loaderTop = Color(0xFFF9B27A);

  // ── Legacy names ──
  //
  // The M0 placeholders, kept as aliases of the token values so call sites
  // written before the tokens keep compiling. Prefer `AppColorTokens`.

  static const background = AppColorTokens.canvasCream;
  static const surface = AppColorTokens.surface;
  static const woodLight = AppColorTokens.woodLight;
  static const woodMid = AppColorTokens.woodMid;
  static const woodDark = AppColorTokens.woodDark;
  static const textPrimary = AppColorTokens.textPrimary;
  static const textSecondary = AppColorTokens.textSecondary;
  static const textOnWood = AppColorTokens.textOnWood;
  static const success = AppColorTokens.success;
  static const warning = AppColorTokens.warning;
  static const danger = AppColorTokens.danger;
  static const coinGold = AppColorTokens.coin;
  static const adPurple = AppColorTokens.ad;
  static const badgeHard = AppColorTokens.danger;
  static const badgeSuperHard = AppColorTokens.superHard;
  static const disabled = disabledFace;
}
