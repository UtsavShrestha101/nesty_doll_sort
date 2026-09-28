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

  // ── Daily 7-day strip (NestyMenus "days", frames 5.1/5.5/5.6) ──

  /// The raised "Today" cell's gradient top (bottom is `AppColorTokens
  /// .primary`).
  static const dayTodayTop = Color(0xFFF9A964);

  /// A done day's face and ring.
  static const dayDoneFace = Color(0xFFE3F4E6);
  static const dayDoneRing = Color(0xFFA6DDB3);

  /// A locked day: `rgba(255,249,236,.7)` face, dashed-tone ring and dot.
  static const dayLockedFace = Color(0xB3FFF9EC);
  static const dayLockedRing = Color(0xFFE2C9A3);
  static const dayLockedDot = Color(0xFFEAD3B0);
  static const dayLockedIcon = Color(0xFFB98A60);

  /// Day 7 before it opens: a chest waiting on the streak.
  static const dayChestPendingFace = Color(0xFFFFF1C9);
  static const dayChestPendingRing = Color(0xFFE8C35C);
  static const dayChestPendingDot = Color(0xFFF5C518);
  static const dayChestPendingIcon = Color(0xFF8C5E12);

  /// Day 7 once its chest opened (`AppGradientTokens.daily` is its face).
  static const dayChestOpenEdge = Color(0xFFC9960A);
  static const dayChestOpenDot = Color(0xFFFFF8DC);

  // ── Daily chest icon (NestyMenus "chest", frames 5.1/5.6) ──

  static const chestBodyTop = Color(0xFFC98A4E);
  static const chestBodyBottom = Color(0xFF8A5429);
  static const chestLidTop = Color(0xFFD99A5A);
  static const chestLidBottom = Color(0xFFA56A34);
  static const chestRing = Color(0xFFE8B94A);
  static const chestLock = Color(0xFFF5C518);
  static const chestLockRing = Color(0xFF8C5E12);

  /// The open chest's (5.6) gold glow behind the lid: `radial-gradient(
  /// closest-side, rgba(255,220,110,.9), rgba(255,220,110,0))`.
  static const chestGlow = Color(0xE6FFDC6E);
  static const chestGlowClear = Color(0x00FFDC6E);

  /// The open chest body's drop shadow, `0 8px 14px rgba(90,45,15,.3)`.
  static const chestShadow = Color(0x4D5A2D0F);

  /// The freeze chip's label (NestyMenus "freeze", frame 5.1).
  static const freezeChipText = Color(0xFF326497);

  // ── Settings "Color symbols" cards (NestyMenus isSettings, frame 8.1) ──

  /// The selected card's face (its ring is `AppColorTokens.primary`).
  static const symbolsCardSelectedFace = Color(0xFFFFF1E4);

  /// The unselected card's 2 px inset ring.
  static const symbolsCardRing = Color(0xFFE2C9A3);

  // ── Museum walnut cabinet (NestyShop "museum", frame 6.1) ──

  static const walnutTop = Color(0xFFB77B44);
  static const walnutBottom = Color(0xFF9A6232);
  static const walnutEdge = Color(0xFF6E4222);
  static const walnutHighlight = Color(0x80FFDCAA);
  static const shelfFaceTop = Color(0xFFF7E4C4);
  static const shelfFaceBottom = Color(0xFFEDD1A6);

  /// The figurine detail modal's warm spotlight (frame 6.2; a duller one
  /// for the locked modal, frame 6.3).
  static const spotlightEarnedTop = Color(0xFFFFF6DC);
  static const spotlightEarnedMid = Color(0xFFF2D29E);
  static const spotlightEarnedEdge = Color(0xFFE2B478);
  static const spotlightLockedTop = Color(0xFFF7EBD6);
  static const spotlightLockedMid = Color(0xFFE8D3B0);
  static const spotlightLockedEdge = Color(0xFFD9BE93);

  // ── Banners (design/README.md "Banners / toasts") ──

  static const warningHighlight = Color(0xFFFFF4EA);
  static const dangerHighlight = Color(0xFFFFF2F2);
  static const successBannerFace = Color(0xFFEAF7EC);

  /// The "Purchases restored" toast's title (frame 8.3).
  static const successToastTitle = Color(0xFF1F5A2B);

  /// The "Purchases restored" toast's body (frame 8.3).
  static const successToastMessage = Color(0xFF3F7A4B);

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
