// GENERATED — do not edit; run dart run nesty_tools:gen_design_tokens
//
// Source: design/tokens.json (tokens v4).
// Nesty: Doll Sort design tokens v4. Source of truth for colors, type,
// spacing, radii, shadows, layout, motion, sound and haptics. Keys under
// dollColor match nesty_core DollColor ids.

import 'package:flutter/animation.dart' show Cubic;
import 'package:flutter/painting.dart';
import 'package:nesty_game/core/ui/tokens/ui_token_types.dart';

/// Which design/tokens.json these UI tokens were generated from.
abstract final class UiTokensInfo {
  /// tokens.json `meta.version`.
  static const version = 4;
}

/// App colors (tokens.json `color`).
abstract final class AppColorTokens {
  /// `#FBE7C4`.
  static const background = Color(0xFFFBE7C4);

  /// `#FBEAD0`.
  static const canvasCream = Color(0xFFFBEAD0);

  /// `#F4D9AE`.
  static const canvasCreamLow = Color(0xFFF4D9AE);

  /// `#FFF9EE`.
  static const surface = Color(0xFFFFF9EE);

  /// `#FCEBD0`.
  static const surfaceSunk = Color(0xFFFCEBD0);

  /// `#D8B07A`.
  static const surfaceEdge = Color(0xFFD8B07A);

  /// `#FFFDF7`.
  static const surfaceWhite = Color(0xFFFFFDF7);

  /// `#EAD3B0`.
  static const surfaceTrack = Color(0xFFEAD3B0);

  /// `#F8D9A3`.
  static const woodLight = Color(0xFFF8D9A3);

  /// `#DCA15D`.
  static const woodMid = Color(0xFFDCA15D);

  /// `#A56A34`.
  static const woodDark = Color(0xFFA56A34);

  /// `#7B4824`.
  static const walnut = Color(0xFF7B4824);

  /// `#4E2C14`.
  static const walnutEdge = Color(0xFF4E2C14);

  /// `#5B3A21`.
  static const textPrimary = Color(0xFF5B3A21);

  /// `#8A5B3A`.
  static const textSecondary = Color(0xFF8A5B3A);

  /// `#9A6A44`.
  static const textMuted = Color(0xFF9A6A44);

  /// `#B07A4E`.
  static const textAccent = Color(0xFFB07A4E);

  /// `#FFF4E0`.
  static const textOnWood = Color(0xFFFFF4E0);

  /// `#FFE9C8`.
  static const textOnWoodMuted = Color(0xFFFFE9C8);

  /// `#F2893B`.
  static const primary = Color(0xFFF2893B);

  /// `#F7A15E`.
  static const primaryTop = Color(0xFFF7A15E);

  /// `#C4631E`.
  static const primaryEdge = Color(0xFFC4631E);

  /// `#46A758`.
  static const success = Color(0xFF46A758);

  /// `#6CC07C`.
  static const successTop = Color(0xFF6CC07C);

  /// `#2F7A3E`.
  static const successEdge = Color(0xFF2F7A3E);

  /// `#DDF3E2`.
  static const successTint = Color(0xFFDDF3E2);

  /// `#A6DDB3`.
  static const successRing = Color(0xFFA6DDB3);

  /// `#F5A524`.
  static const warning = Color(0xFFF5A524);

  /// `#FFE3D0`.
  static const warningTint = Color(0xFFFFE3D0);

  /// `#E3AE8C`.
  static const warningEdge = Color(0xFFE3AE8C);

  /// `#E5484D`.
  static const danger = Color(0xFFE5484D);

  /// `#F07377`.
  static const dangerTop = Color(0xFFF07377);

  /// `#A92C33`.
  static const dangerEdge = Color(0xFFA92C33);

  /// `#FFE1E1`.
  static const dangerTint = Color(0xFFFFE1E1);

  /// `#E8A5A7`.
  static const dangerTintEdge = Color(0xFFE8A5A7);

  /// `#F2C230`.
  static const coin = Color(0xFFF2C230);

  /// `#B8860B`.
  static const coinDark = Color(0xFFB8860B);

  /// `#FFF3B0`.
  static const coinLight = Color(0xFFFFF3B0);

  /// `#8C5E12`.
  static const coinText = Color(0xFF8C5E12);

  /// `#7C4DDB`.
  static const ad = Color(0xFF7C4DDB);

  /// `#9A72EC`.
  static const adTop = Color(0xFF9A72EC);

  /// `#5530A8`.
  static const adEdge = Color(0xFF5530A8);

  /// `#EFE3F9`.
  static const adTint = Color(0xFFEFE3F9);

  /// `#E93D82`.
  static const badge = Color(0xFFE93D82);

  /// `#B32463`.
  static const badgeEdge = Color(0xFFB32463);

  /// `#7A3FB8`.
  static const superHard = Color(0xFF7A3FB8);

  /// `#A06AE0`.
  static const superHardTop = Color(0xFFA06AE0);

  /// `#522783`.
  static const superHardEdge = Color(0xFF522783);

  /// `#F4ECFF`.
  static const superHardTint = Color(0xFFF4ECFF);

  /// `#FFF1EE`.
  static const hardTint = Color(0xFFFFF1EE);

  /// `#C33338`.
  static const hardText = Color(0xFFC33338);

  /// `#F5C518`.
  static const daily = Color(0xFFF5C518);

  /// `#FFE58A`.
  static const dailyTop = Color(0xFFFFE58A);

  /// `#C9960A`.
  static const dailyEdge = Color(0xFFC9960A);

  /// `#12A594`.
  static const bonus = Color(0xFF12A594);

  /// `#3FC6B4`.
  static const bonusTop = Color(0xFF3FC6B4);

  /// `#0B7568`.
  static const bonusEdge = Color(0xFF0B7568);

  /// `#F2702B`.
  static const streak = Color(0xFFF2702B);

  /// `#FFB27A`.
  static const streakTop = Color(0xFFFFB27A);

  /// `#B8501A`.
  static const streakEdge = Color(0xFFB8501A);

  /// `#3E8EDE`.
  static const ice = Color(0xFF3E8EDE);

  /// `#6FB4EA`.
  static const iceTop = Color(0xFF6FB4EA);

  /// `#2B6CB0`.
  static const iceEdge = Color(0xFF2B6CB0);

  /// `#DCEFFF`.
  static const iceTint = Color(0xFFDCEFFF);

  /// `#2C170A`.
  static const pipEmpty = Color(0xFF2C170A);

  /// `#D9C2A0`.
  static const toggleOff = Color(0xFFD9C2A0);

  /// `rgba(60,30,10,0.55)`.
  static const scrim = Color(0x8C3C1E0A);

  /// `rgba(25,12,4,0.86)`.
  static const scrimStrong = Color(0xDB190C04);

  /// `#3A2414`.
  static const statusBar = Color(0xFF3A2414);

  /// `#120B06`.
  static const island = Color(0xFF120B06);

  /// `#4E5FD9`.
  static const versus = Color(0xFF4E5FD9);

  /// `#7B8BEF`.
  static const versusTop = Color(0xFF7B8BEF);

  /// `#3242A8`.
  static const versusEdge = Color(0xFF3242A8);

  /// `#E6E9FC`.
  static const versusTint = Color(0xFFE6E9FC);

  /// `#FFFDF7`.
  static const computerTag = Color(0xFFFFFDF7);

  /// `#D8B07A`.
  static const computerTagEdge = Color(0xFFD8B07A);

  /// `#6E4526`.
  static const computerTagText = Color(0xFF6E4526);

  /// `#4E5FD9`.
  static const rivalDot = Color(0xFF4E5FD9);

  /// `#EAD3B0`.
  static const rivalDotEmpty = Color(0xFFEAD3B0);

  /// `#F2893B`.
  static const notificationAccent = Color(0xFFF2893B);

  /// `#DCC6A4`.
  static const streakPaused = Color(0xFFDCC6A4);

  /// `#F1E3CC`.
  static const streakPausedTop = Color(0xFFF1E3CC);

  /// `#B99A7A`.
  static const streakPausedEdge = Color(0xFFB99A7A);

  /// `#9A6A44`.
  static const streakPausedGlyph = Color(0xFF9A6A44);

  /// `rgba(255,205,80,.55)`.
  static const relitGlow = Color(0x8CFFCD50);

  /// `#E5484D`.
  static const tierEdgeHard = Color(0xFFE5484D);

  /// `#8E4EC6`.
  static const tierEdgeSuperHard = Color(0xFF8E4EC6);

  /// `#FFF7E0`.
  static const badgeToast = Color(0xFFFFF7E0);

  /// `#E6C36A`.
  static const badgeToastEdge = Color(0xFFE6C36A);

  /// `#DDBE8E`.
  static const starEmptyOutline = Color(0xFFDDBE8E);

  /// `#EDD6B2`.
  static const starEmptyTop = Color(0xFFEDD6B2);

  /// `#F6E6CC`.
  static const starEmptyBottom = Color(0xFFF6E6CC);

  /// `#EAF7EC`.
  static const toastSuccessFace = Color(0xFFEAF7EC);

  /// `#A6DDB3`.
  static const toastSuccessRing = Color(0xFFA6DDB3);

  /// `#46A758`.
  static const toastSuccessAccent = Color(0xFF46A758);

  /// `#E8F3FF`.
  static const toastInfoFace = Color(0xFFE8F3FF);

  /// `#9CC4EA`.
  static const toastInfoRing = Color(0xFF9CC4EA);

  /// `#3E8EDE`.
  static const toastInfoAccent = Color(0xFF3E8EDE);

  /// `#FFF7E0`.
  static const toastBadgeFace = Color(0xFFFFF7E0);

  /// `#E6C36A`.
  static const toastBadgeRing = Color(0xFFE6C36A);

  /// `#F5C518`.
  static const toastBadgeAccent = Color(0xFFF5C518);

  /// `#FFE3D0`.
  static const toastWarnFace = Color(0xFFFFE3D0);

  /// `#E3AE8C`.
  static const toastWarnRing = Color(0xFFE3AE8C);

  /// `#F2893B`.
  static const toastWarnAccent = Color(0xFFF2893B);

  /// `#FFF1DE`.
  static const streakCardTop = Color(0xFFFFF1DE);

  /// `#FFE2C2`.
  static const streakCardBottom = Color(0xFFFFE2C2);

  /// `#E3AE8C`.
  static const streakCardEdge = Color(0xFFE3AE8C);

  /// `#F0DFC4`.
  static const divider = Color(0xFFF0DFC4);

  /// `#8A6A4E`.
  static const textLocked = Color(0xFF8A6A4E);

  /// `#B99A7A`.
  static const textLockedLight = Color(0xFFB99A7A);

  /// `#C4AE92`.
  static const lockGlyph = Color(0xFFC4AE92);

  /// `#F1E3CC`.
  static const levelLockedFace = Color(0xFFF1E3CC);

  /// `#F3E6D2`.
  static const sunkFace = Color(0xFFF3E6D2);

  /// `rgba(90,45,15,0.15)`.
  static const sunkShade = Color(0x265A2D0F);

  /// `#E2CBA6`.
  static const sunkRing = Color(0xFFE2CBA6);

  /// `rgba(60,30,10,0.35)`.
  static const scrimLight = Color(0x593C1E0A);

  /// `rgba(60,30,10,0.28)`.
  static const scrimBoard = Color(0x473C1E0A);

  /// `rgba(60,30,10,0.18)`.
  static const scrimFaint = Color(0x2E3C1E0A);

  /// `#E8DCCB`.
  static const disabledFace = Color(0xFFE8DCCB);

  /// `rgba(90,45,15,0.2)`.
  static const disabledShade = Color(0x335A2D0F);

  /// `#A48B72`.
  static const disabledText = Color(0xFFA48B72);

  /// `#CDB89C`.
  static const disabledCoin = Color(0xFFCDB89C);

  /// `#F3E6D2`.
  static const limitBadgeFace = Color(0xFFF3E6D2);

  /// `#FFF4E0`.
  static const limitBadgeRing = Color(0xFFFFF4E0);

  /// `#8A6A4E`.
  static const limitBadgeText = Color(0xFF8A6A4E);

  /// `#F6E2C2`.
  static const tileNeutral = Color(0xFFF6E2C2);

  /// `#FFF1C9`.
  static const tileGold = Color(0xFFFFF1C9);

  /// `#DDF3E2`.
  static const tileGreen = Color(0xFFDDF3E2);

  /// `#E8F3FF`.
  static const tileBlue = Color(0xFFE8F3FF);

  /// `#2B5E93`.
  static const tileBlueGlyph = Color(0xFF2B5E93);

  /// `#FFE9D2`.
  static const tileOrange = Color(0xFFFFE9D2);

  /// `#FFE3D0`.
  static const tilePeach = Color(0xFFFFE3D0);

  /// `#E0632A`.
  static const tilePeachGlyph = Color(0xFFE0632A);

  /// `#FFF6E6`.
  static const tileCream = Color(0xFFFFF6E6);

  /// `#CDEFD6`.
  static const iconTileGreen = Color(0xFFCDEFD6);

  /// `#6E4526`.
  static const iconBrown = Color(0xFF6E4526);

  /// `#7A5234`.
  static const textBrown = Color(0xFF7A5234);

  /// `#B98A60`.
  static const chevron = Color(0xFFB98A60);

  /// `#F6E2C2`.
  static const closeFill = Color(0xFFF6E2C2);

  /// `rgba(150,100,50,0.25)`.
  static const closeShade = Color(0x40966432);

  /// `#FFF1C9`.
  static const coinChipTop = Color(0xFFFFF1C9);

  /// `#F9DC8A`.
  static const coinChipBottom = Color(0xFFF9DC8A);

  /// `#D4A93A`.
  static const coinChipEdge = Color(0xFFD4A93A);

  /// `#E9DDF9`.
  static const adClaimedFace = Color(0xFFE9DDF9);

  /// `#C9B3F0`.
  static const adClaimedRing = Color(0xFFC9B3F0);

  /// `#5530A8`.
  static const adClaimedText = Color(0xFF5530A8);

  /// `#6A31A6`.
  static const superHardChipText = Color(0xFF6A31A6);

  /// `#5A3F06`.
  static const dailyText = Color(0xFF5A3F06);

  /// `#FFF8DC`.
  static const dailyChipFace = Color(0xFFFFF8DC);

  /// `rgba(110,70,40,0.25)`.
  static const sheetGrabber = Color(0x406E4628);

  /// `#E3F4E6`.
  static const dayDoneFace = Color(0xFFE3F4E6);

  /// `#A6DDB3`.
  static const dayDoneRing = Color(0xFFA6DDB3);

  /// `#46A758`.
  static const dayDoneDot = Color(0xFF46A758);

  /// `#F9A964`.
  static const dayTodayTop = Color(0xFFF9A964);

  /// `#F2893B`.
  static const dayTodayBottom = Color(0xFFF2893B);

  /// `#C4631E`.
  static const dayTodayEdge = Color(0xFFC4631E);

  /// `#FFF6E6`.
  static const dayTodayDot = Color(0xFFFFF6E6);

  /// `#FFF1C9`.
  static const dayChestFace = Color(0xFFFFF1C9);

  /// `#E8C35C`.
  static const dayChestRing = Color(0xFFE8C35C);

  /// `#F5C518`.
  static const dayChestDot = Color(0xFFF5C518);

  /// `#FFE58A`.
  static const dayOpenTop = Color(0xFFFFE58A);

  /// `#F5C518`.
  static const dayOpenBottom = Color(0xFFF5C518);

  /// `#C9960A`.
  static const dayOpenEdge = Color(0xFFC9960A);

  /// `#FFF8DC`.
  static const dayOpenDot = Color(0xFFFFF8DC);

  /// `rgba(255,249,236,0.7)`.
  static const dayFutureFace = Color(0xB3FFF9EC);

  /// `#E2C9A3`.
  static const dayFutureRing = Color(0xFFE2C9A3);

  /// `#EAD3B0`.
  static const dayFutureDot = Color(0xFFEAD3B0);

  /// `#B98A60`.
  static const dayFutureGlyph = Color(0xFFB98A60);

  /// `#7A5234`.
  static const dayLabel = Color(0xFF7A5234);

  /// `#C98A4E`.
  static const chestBodyTop = Color(0xFFC98A4E);

  /// `#8A5429`.
  static const chestBodyBottom = Color(0xFF8A5429);

  /// `#D99A5A`.
  static const chestLidTop = Color(0xFFD99A5A);

  /// `#A56A34`.
  static const chestLidBottom = Color(0xFFA56A34);

  /// `#E8B94A`.
  static const chestRing = Color(0xFFE8B94A);

  /// `#F5C518`.
  static const chestLock = Color(0xFFF5C518);

  /// `#8C5E12`.
  static const chestLockRing = Color(0xFF8C5E12);

  /// `rgba(255,220,110,0.9)`.
  static const chestGlow = Color(0xE6FFDC6E);

  /// `#326497`.
  static const freezeChipText = Color(0xFF326497);

  /// `#FFF1E4`.
  static const symbolsCardSelectedFace = Color(0xFFFFF1E4);

  /// `#E2C9A3`.
  static const symbolsCardRing = Color(0xFFE2C9A3);

  /// `#F2893B`.
  static const symbolsCardSelectedRing = Color(0xFFF2893B);

  /// `#8A5530`.
  static const walnutCabinetTop = Color(0xFF8A5530);

  /// `#6B3E1E`.
  static const walnutCabinetBottom = Color(0xFF6B3E1E);

  /// `rgba(255,210,160,0.35)`.
  static const walnutHighlight = Color(0x59FFD2A0);

  /// `rgba(40,18,6,0.4)`.
  static const walnutShade = Color(0x66281206);

  /// `#5A3218`.
  static const shelfFaceTop = Color(0xFF5A3218);

  /// `#6E3F1E`.
  static const shelfFaceBottom = Color(0xFF6E3F1E);

  /// `#4A2A14`.
  static const shelfFaceLockedTop = Color(0xFF4A2A14);

  /// `#5E3519`.
  static const shelfFaceLockedBottom = Color(0xFF5E3519);

  /// `#A56A34`.
  static const shelfLip = Color(0xFFA56A34);

  /// `rgba(0,0,0,0.35)`.
  static const shelfShadow = Color(0x59000000);

  /// `rgba(255,226,160,0.5)`.
  static const shelfLight = Color(0x80FFE2A0);

  /// `#F5D98C`.
  static const namePlateTop = Color(0xFFF5D98C);

  /// `#D9AE52`.
  static const namePlateBottom = Color(0xFFD9AE52);

  /// `#8C6420`.
  static const namePlateEdge = Color(0xFF8C6420);

  /// `#4A3008`.
  static const namePlateText = Color(0xFF4A3008);

  /// `#7FD08D`.
  static const museumNextRing = Color(0xFF7FD08D);

  /// `rgba(255,244,210,0.55)`.
  static const spotlightTop = Color(0x8CFFF4D2);

  /// `rgba(255,236,190,0.1)`.
  static const spotlightBottom = Color(0x1AFFECBE);

  /// `rgba(255,240,200,0.75)`.
  static const spotlightFloor = Color(0xBFFFF0C8);

  /// `rgba(255,255,255,0.55)`.
  static const spotlightPanel = Color(0x8CFFFFFF);

  /// `#FFF4EA`.
  static const warningHighlight = Color(0xFFFFF4EA);

  /// `#FFF2F2`.
  static const dangerHighlight = Color(0xFFFFF2F2);

  /// `#EAF7EC`.
  static const successBannerFace = Color(0xFFEAF7EC);

  /// `#1F5A2B`.
  static const successToastTitle = Color(0xFF1F5A2B);

  /// `#3F7A4B`.
  static const successToastMessage = Color(0xFF3F7A4B);

  /// `#E8F3FF`.
  static const infoFace = Color(0xFFE8F3FF);

  /// `#9CC4EA`.
  static const infoEdge = Color(0xFF9CC4EA);

  /// `#23456E`.
  static const infoTitle = Color(0xFF23456E);

  /// `#46698F`.
  static const infoText = Color(0xFF46698F);

  /// `#FFF6E6`.
  static const cream = Color(0xFFFFF6E6);

  /// `#F2CFA4`.
  static const playDiscShade = Color(0xFFF2CFA4);

  /// `#FFE9D2`.
  static const playCaption = Color(0xFFFFE9D2);

  /// `rgba(255,225,180,0.6)`.
  static const woodBarHighlight = Color(0x99FFE1B4);

  /// `rgba(90,45,15,0.25)`.
  static const woodBarShadow = Color(0x405A2D0F);

  /// `#F9B27A`.
  static const loaderTop = Color(0xFFF9B27A);

  /// `#8A5B3A`.
  static const textLink = Color(0xFF8A5B3A);

  /// `#6E4526`.
  static const textLinkPressed = Color(0xFF6E4526);

  /// `#C4631E`.
  static const textLinkAccent = Color(0xFFC4631E);

  /// `#A94F12`.
  static const textLinkAccentPressed = Color(0xFFA94F12);

  /// `#FFEFD6`.
  static const museumNextName = Color(0xFFFFEFD6);

  /// `rgba(90,45,15,0.25)`.
  static const trackShade = Color(0x405A2D0F);

  /// `#CFA36A`.
  static const segmentEdge = Color(0xFFCFA36A);

  /// `rgba(110,60,25,0.2)`.
  static const rowDash = Color(0x336E3C19);

  /// `rgba(60,25,5,0.3)`.
  static const shadowWarm = Color(0x4D3C1905);

  /// `#F5C518`.
  static const giftDot = Color(0xFFF5C518);

  /// `#FFF3B0`.
  static const giftDotTop = Color(0xFFFFF3B0);

  /// `#C9960A`.
  static const giftDotEdge = Color(0xFFC9960A);

  /// `#F2893B`.
  static const giftToday = Color(0xFFF2893B);

  /// `#C4631E`.
  static const giftTodayEdge = Color(0xFFC4631E);

  /// `#FCEBD0`.
  static const giftDoneFace = Color(0xFFFCEBD0);

  /// `#6CC07C`.
  static const slotDiscTop = Color(0xFF6CC07C);

  /// `#46A758`.
  static const slotDisc = Color(0xFF46A758);

  /// `#2F7A3E`.
  static const slotDiscEdge = Color(0xFF2F7A3E);
}

/// Gradients (tokens.json `gradient`). CSS angles map to Alignment so the
/// gradient line reaches the corners of a square box, like CSS; a radial
/// gradient uses the CSS default farthest-corner radius.
abstract final class AppGradientTokens {
  /// 180deg.
  static const primary = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFF7A15E), Color(0xFFF2893B)],
  );

  /// 180deg.
  static const surface = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFFFF9EE), Color(0xFFFCEBD0)],
  );

  /// 180deg.
  static const secondary = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFFFFDF7), Color(0xFFFCEFD8)],
  );

  /// 180deg.
  static const success = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF6CC07C), Color(0xFF46A758)],
  );

  /// 180deg.
  static const ad = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF9A72EC), Color(0xFF7C4DDB)],
  );

  /// 180deg.
  static const hard = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFF07377), Color(0xFFE5484D)],
  );

  /// 180deg.
  static const superHard = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFA06AE0), Color(0xFF7A3FB8)],
  );

  /// 180deg.
  static const daily = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFFFE58A), Color(0xFFF5C518)],
  );

  /// 180deg.
  static const bonus = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF3FC6B4), Color(0xFF12A594)],
  );

  /// 180deg.
  static const streak = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFFFB27A), Color(0xFFF2702B)],
  );

  /// 180deg.
  static const playButton = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFF9A964), Color(0xFFF2893B), Color(0xFFEA7A2A)],
    stops: [0.0, 0.6, 1.0],
  );

  /// 180deg, stops [#D8995A 0, #BD7B40 14px, #A56A34 100%]. Has a px stop: call
  /// `resolve(extent)`.
  static const woodBar = PxLinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFD8995A), Color(0xFFBD7B40), Color(0xFFA56A34)],
    stops: [
      TokenStop.fraction(0.0),
      TokenStop.px(14.0),
      TokenStop.fraction(1.0),
    ],
  );

  /// "repeating vertical grain rgba(90,45,15,0.06) 2px every 30px".
  static const woodBarGrain = WoodGrainToken(
    color: Color(0x0F5A2D0F),
    lineWidth: 2.0,
    spacing: 30.0,
    vertical: true,
  );

  /// Radial from (0.35, 0.3) of the box, farthest-corner.
  static const coinFace = RadialGradient(
    center: Alignment(-0.3, -0.4),
    radius: 0.9552,
    colors: [Color(0xFFFFF3B0), Color(0xFFF2C230), Color(0xFFB8860B)],
    stops: [0.0, 0.5, 1.0],
  );

  /// 180deg.
  static const progressFill = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF7FD08D), Color(0xFF46A758)],
  );

  /// "-45deg rgba(255,255,255,0.22) 6px on / 6px off".
  static const progressFillStripes = TokenStripes(
    angleDeg: -45.0,
    color: Color(0x38FFFFFF),
    onPx: 6.0,
    offPx: 6.0,
  );

  /// 115deg.
  static const gold = LinearGradient(
    begin: Alignment(-1.2044, -0.5616),
    end: Alignment(1.2044, 0.5616),
    colors: [
      Color(0xFF8C5E12),
      Color(0xFFF2CC5B),
      Color(0xFFFFF6C8),
      Color(0xFFC89220),
      Color(0xFF8C5E12),
    ],
    stops: [0.0, 0.35, 0.5, 0.7, 1.0],
  );

  /// `linear-gradient(180deg, #7B8BEF, #4E5FD9)`.
  static const versus = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF7B8BEF), Color(0xFF4E5FD9)],
  );

  /// 180deg.
  static const canvas = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFFBEAD0), Color(0xFFF4D9AE)],
  );

  /// 180deg.
  static const streakCard = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFFFF1DE), Color(0xFFFFE2C2)],
  );

  /// 180deg.
  static const loader = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFF9B27A), Color(0xFFF2893B)],
  );

  /// "-45deg rgba(255,255,255,0.22) 6px on / 6px off".
  static const loaderStripes = TokenStripes(
    angleDeg: -45.0,
    color: Color(0x38FFFFFF),
    onPx: 6.0,
    offPx: 6.0,
  );

  /// 180deg.
  static const coinChip = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFFFF1C9), Color(0xFFF9DC8A)],
  );

  /// The solid edge under [coinChip]: `0 3px 0 #D4A93A`.
  static const List<NestyShadow> coinChipEdge = [
    NestyShadow(color: Color(0xFFD4A93A), dy: 3.0),
  ];

  /// CSS `radial-gradient(ellipse 60% 70% at 50% 30%, …)`: the circle scaled
  /// into the ellipse by [EllipseGradientTransform], so it fits any box.
  static const figurinePanelEarned = RadialGradient(
    center: Alignment(0.0, -0.4),
    radius: 0.5,
    colors: [Color(0xFFFFF6DC), Color(0xFFF2D29E), Color(0xFFE2B478)],
    stops: [0.0, 0.7, 1.0],
    transform: EllipseGradientTransform(
      center: Alignment(0.0, -0.4),
      radiusX: 0.6,
      radiusY: 0.7,
    ),
  );

  /// CSS `radial-gradient(ellipse 60% 70% at 50% 30%, …)`: the circle scaled
  /// into the ellipse by [EllipseGradientTransform], so it fits any box.
  static const figurinePanelLocked = RadialGradient(
    center: Alignment(0.0, -0.4),
    radius: 0.5,
    colors: [Color(0xFFF7EBD6), Color(0xFFE8D3B0), Color(0xFFD9BE93)],
    stops: [0.0, 0.7, 1.0],
    transform: EllipseGradientTransform(
      center: Alignment(0.0, -0.4),
      radiusX: 0.6,
      radiusY: 0.7,
    ),
  );
}

/// Font families and weights (tokens.json `font`). The TTFs are bundled in
/// assets/fonts (tools/fonts/build_fonts.sh); icons use the bundled
/// `NestySymbols` subset of Material Symbols Rounded.
abstract final class AppFontTokens {
  static const displayFamily = 'Fredoka';

  /// The bundled weights.
  static const List<FontWeight> displayWeights = [
    FontWeight.w500,
    FontWeight.w600,
    FontWeight.w700,
  ];

  static const bodyFamily = 'Nunito';

  /// The bundled weights.
  static const List<FontWeight> bodyWeights = [
    FontWeight.w500,
    FontWeight.w600,
    FontWeight.w700,
    FontWeight.w800,
  ];

  /// The upstream icon font the bundled subset is cut from.
  static const iconDesignFamily = 'Material Symbols Rounded';

  /// Icon axis FILL.
  static const iconFill = 1.0;

  /// Icon axis wght.
  static const iconWeight = 600.0;

  /// Icon axis GRAD.
  static const iconGrade = 0.0;

  /// Icon axis opsz.
  static const iconOpticalSize = 24.0;

  /// The Baloo 2 face for Fredoka (display) text: bundled per role, its files
  /// carry the Fredoka weight they answer.
  static const devaDisplayFamily = 'Baloo2Display';

  /// The Baloo 2 face for Nunito (body) text: bundled per role, its files carry
  /// the Nunito weight they answer.
  static const devaBodyFamily = 'Baloo2Body';

  /// The locales whose text is in this script.
  static const List<String> devaLocales = ['hi'];

  /// Fredoka weight → Baloo 2 weight its display text draws (tools/test/fonts
  /// checks the bundled files resolve to it).
  static const Map<int, int> devaDisplayWeights = {700: 700, 600: 600};

  /// Nunito weight → Baloo 2 weight its body text draws (tools/test/fonts
  /// checks the bundled files resolve to it).
  static const Map<int, int> devaBodyWeights = {800: 700, 700: 600, 600: 500};

  /// The font size factor for text in this script.
  static const devaSizeFactor = 1.0;

  /// The least line height of multi-line body text in this script: "multi-line
  /// ≥ 1.5 (body) / 1.3 (titles); single-line boxes keep their height and never
  /// clip ascenders".
  static const devaBodyLineHeight = 1.5;

  /// The least line height of multi-line title text in this script: "multi-line
  /// ≥ 1.5 (body) / 1.3 (titles); single-line boxes keep their height and never
  /// clip ascenders".
  static const devaTitleLineHeight = 1.3;

  /// The M PLUS Rounded 1c face for Fredoka (display) text: bundled per role,
  /// its files carry the Fredoka weight they answer.
  static const jpanDisplayFamily = 'MPLUSRounded1cDisplay';

  /// The M PLUS Rounded 1c face for Nunito (body) text: bundled per role, its
  /// files carry the Nunito weight they answer.
  static const jpanBodyFamily = 'MPLUSRounded1cBody';

  /// The locales whose text is in this script.
  static const List<String> jpanLocales = ['ja'];

  /// Fredoka weight → M PLUS Rounded 1c weight its display text draws
  /// (tools/test/fonts checks the bundled files resolve to it).
  static const Map<int, int> jpanDisplayWeights = {700: 800, 600: 700};

  /// Nunito weight → M PLUS Rounded 1c weight its body text draws
  /// (tools/test/fonts checks the bundled files resolve to it).
  static const Map<int, int> jpanBodyWeights = {800: 700, 700: 700, 600: 500};

  /// The font size factor for text in this script.
  static const jpanSizeFactor = 0.94;

  /// The least line height of multi-line body text in this script: "multi-line
  /// 1.6 (body) / 1.3 (titles)".
  static const jpanBodyLineHeight = 1.6;

  /// The least line height of multi-line title text in this script: "multi-line
  /// 1.6 (body) / 1.3 (titles)".
  static const jpanTitleLineHeight = 1.3;

  /// Letter spacing for text in this script: "always 0 (drop tracked caps)".
  static const jpanLetterSpacing = 0.0;

  /// The Baloo 2 face that replaces Fredoka for whole strings in
  /// [latnTrLocales] (m7-5 (item 28): Fredoka has no ğ Ğ İ ş Ş, so Turkish
  /// draws every Fredoka role in Baloo 2, whole strings, never per glyph).
  /// Bundled as its own family: its files answer each Fredoka weight with
  /// [latnTrDisplayWeights].
  static const latnTrFamily = 'Baloo2LatnTr';

  /// The locales whose Fredoka (display) text draws in [latnTrFamily].
  static const List<String> latnTrLocales = ['tr'];

  /// Fredoka weight → the Baloo 2 weight a display style draws in
  /// [latnTrLocales].
  static const Map<int, int> latnTrDisplayWeights = {
    700: 700,
    600: 600,
    500: 500,
  };

  /// The font size factor for display text in [latnTrLocales].
  static const latnTrSizeFactor = 1.0;

  /// The line height of multi-line titles in [latnTrLocales], as Fredoka:
  /// "titles 1.15, as Fredoka; single-line boxes keep their height".
  static const latnTrTitleLineHeight = 1.15;

  /// The `fontFamilyFallback` of every Fredoka style: Nunito for a Latin glyph
  /// Fredoka lacks, then the script faces (each maps only its own script).
  static const List<String> displayFallback = [
    'Nunito',
    'Baloo2Display',
    'MPLUSRounded1cDisplay',
  ];

  /// The `fontFamilyFallback` of every Nunito style: Fredoka for a Latin glyph
  /// Nunito lacks, then the script faces (each maps only its own script).
  static const List<String> bodyFallback = [
    'Fredoka',
    'Baloo2Body',
    'MPLUSRounded1cBody',
  ];
}

/// Text styles (tokens.json `fontSize`). `height` is lineHeight ÷ size with
/// even leading, like CSS line-height.
abstract final class AppTextStyleTokens {
  /// Fredoka 56/56/700.
  static TextStyle get display => DisplayFace.of(
    const TextStyle(
      fontFamily: 'Fredoka',
      fontSize: 56.0,
      height: 1.0,
      leadingDistribution: TextLeadingDistribution.even,
      fontWeight: FontWeight.w700,
      fontFamilyFallback: AppFontTokens.displayFallback,
    ),
  );

  /// Fredoka 40/42/700.
  static TextStyle get h1 => DisplayFace.of(
    const TextStyle(
      fontFamily: 'Fredoka',
      fontSize: 40.0,
      height: 1.05,
      leadingDistribution: TextLeadingDistribution.even,
      fontWeight: FontWeight.w700,
      fontFamilyFallback: AppFontTokens.displayFallback,
    ),
  );

  /// Fredoka 30/33/700.
  static TextStyle get sheetTitle => DisplayFace.of(
    const TextStyle(
      fontFamily: 'Fredoka',
      fontSize: 30.0,
      height: 1.1,
      leadingDistribution: TextLeadingDistribution.even,
      fontWeight: FontWeight.w700,
      fontFamilyFallback: AppFontTokens.displayFallback,
    ),
  );

  /// Fredoka 28/31/700.
  static TextStyle get h2 => DisplayFace.of(
    const TextStyle(
      fontFamily: 'Fredoka',
      fontSize: 28.0,
      height: 1.1071428571428572,
      leadingDistribution: TextLeadingDistribution.even,
      fontWeight: FontWeight.w700,
      fontFamilyFallback: AppFontTokens.displayFallback,
    ),
  );

  /// Fredoka 26/26/700.
  static TextStyle get screenTitle => DisplayFace.of(
    const TextStyle(
      fontFamily: 'Fredoka',
      fontSize: 26.0,
      height: 1.0,
      leadingDistribution: TextLeadingDistribution.even,
      fontWeight: FontWeight.w700,
      fontFamilyFallback: AppFontTokens.displayFallback,
    ),
  );

  /// Fredoka 20/22/700.
  static TextStyle get cardTitle => DisplayFace.of(
    const TextStyle(
      fontFamily: 'Fredoka',
      fontSize: 20.0,
      height: 1.1,
      leadingDistribution: TextLeadingDistribution.even,
      fontWeight: FontWeight.w700,
      fontFamilyFallback: AppFontTokens.displayFallback,
    ),
  );

  /// Fredoka 21/21/700.
  static TextStyle get button => DisplayFace.of(
    const TextStyle(
      fontFamily: 'Fredoka',
      fontSize: 21.0,
      height: 1.0,
      leadingDistribution: TextLeadingDistribution.even,
      fontWeight: FontWeight.w700,
      fontFamilyFallback: AppFontTokens.displayFallback,
    ),
  );

  /// Fredoka 17/17/700.
  static TextStyle get buttonSmall => DisplayFace.of(
    const TextStyle(
      fontFamily: 'Fredoka',
      fontSize: 17.0,
      height: 1.0,
      leadingDistribution: TextLeadingDistribution.even,
      fontWeight: FontWeight.w700,
      fontFamilyFallback: AppFontTokens.displayFallback,
    ),
  );

  /// Fredoka 16/20/700. text links on overlays (textLink): Back to Home, Not
  /// now, No thanks; m7-6 (item 15).
  static TextStyle get textLink => DisplayFace.of(
    const TextStyle(
      fontFamily: 'Fredoka',
      fontSize: 16.0,
      height: 1.25,
      leadingDistribution: TextLeadingDistribution.even,
      fontWeight: FontWeight.w700,
      fontFamilyFallback: AppFontTokens.displayFallback,
    ),
  );

  /// Fredoka 18/18/700.
  static TextStyle get hudLevel => DisplayFace.of(
    const TextStyle(
      fontFamily: 'Fredoka',
      fontSize: 18.0,
      height: 1.0,
      leadingDistribution: TextLeadingDistribution.even,
      fontWeight: FontWeight.w700,
      fontFamilyFallback: AppFontTokens.displayFallback,
    ),
  );

  /// Fredoka 17/17/700.
  static TextStyle get number => DisplayFace.of(
    const TextStyle(
      fontFamily: 'Fredoka',
      fontSize: 17.0,
      height: 1.0,
      leadingDistribution: TextLeadingDistribution.even,
      fontWeight: FontWeight.w700,
      fontFamilyFallback: AppFontTokens.displayFallback,
      fontFeatures: [FontFeature.tabularFigures()],
    ),
  );

  /// Fredoka 13/13/600.
  static TextStyle get boosterLabel => DisplayFace.of(
    const TextStyle(
      fontFamily: 'Fredoka',
      fontSize: 13.0,
      height: 1.0,
      leadingDistribution: TextLeadingDistribution.even,
      fontWeight: FontWeight.w600,
      fontFamilyFallback: AppFontTokens.displayFallback,
    ),
  );

  /// Fredoka 11/11/700.
  static TextStyle get tierChip => DisplayFace.of(
    const TextStyle(
      fontFamily: 'Fredoka',
      fontSize: 11.0,
      height: 1.0,
      leadingDistribution: TextLeadingDistribution.even,
      fontWeight: FontWeight.w700,
      fontFamilyFallback: AppFontTokens.displayFallback,
      letterSpacing: 0.66,
    ),
  );

  /// Fredoka 12/12/700.
  static TextStyle get tabLabel => DisplayFace.of(
    const TextStyle(
      fontFamily: 'Fredoka',
      fontSize: 12.0,
      height: 1.0,
      leadingDistribution: TextLeadingDistribution.even,
      fontWeight: FontWeight.w700,
      fontFamilyFallback: AppFontTokens.displayFallback,
    ),
  );

  /// Nunito 16/23/600.
  static const body = TextStyle(
    fontFamily: 'Nunito',
    fontSize: 16.0,
    height: 1.4375,
    leadingDistribution: TextLeadingDistribution.even,
    fontWeight: FontWeight.w600,
    fontFamilyFallback: AppFontTokens.bodyFallback,
  );

  /// Nunito 14/20/600.
  static const bodySmall = TextStyle(
    fontFamily: 'Nunito',
    fontSize: 14.0,
    height: 1.4285714285714286,
    leadingDistribution: TextLeadingDistribution.even,
    fontWeight: FontWeight.w600,
    fontFamilyFallback: AppFontTokens.bodyFallback,
  );

  /// Nunito 17/17/700.
  static const row = TextStyle(
    fontFamily: 'Nunito',
    fontSize: 17.0,
    height: 1.0,
    leadingDistribution: TextLeadingDistribution.even,
    fontWeight: FontWeight.w700,
    fontFamilyFallback: AppFontTokens.bodyFallback,
  );

  /// Nunito 12/16/700.
  static const caption = TextStyle(
    fontFamily: 'Nunito',
    fontSize: 12.0,
    height: 1.3333333333333333,
    leadingDistribution: TextLeadingDistribution.even,
    fontWeight: FontWeight.w700,
    fontFamilyFallback: AppFontTokens.bodyFallback,
  );
}

/// Corner radii (tokens.json `radius`).
abstract final class AppRadii {
  static const xs = 6.0;

  static const sm = 10.0;

  static const md = 14.0;

  static const lg = 18.0;

  static const xl = 22.0;

  /// tokens.json `radius.2xl`.
  static const xxl = 30.0;

  static const card = 32.0;

  static const sheet = 34.0;

  static const phone = 46.0;

  static const pill = 999.0;

  static const booster = 18.0;

  static const iconButton = 17.0;

  static const hudPill = 18.0;

  static const toggle = 15.0;
}

/// The 4-pt spacing scale (tokens.json `spacing`).
abstract final class AppSpacing {
  static const s1 = 4.0;

  static const s2 = 8.0;

  static const s3 = 12.0;

  static const s4 = 16.0;

  static const s5 = 20.0;

  static const s6 = 24.0;

  static const s8 = 32.0;

  static const s10 = 40.0;

  static const s12 = 48.0;

  static const s16 = 64.0;
}

/// Shadow stacks (tokens.json `shadow`), CSS order: the first layer paints on
/// top. Inset layers are the 2 px top highlight of tactile surfaces.
abstract final class AppShadowTokens {
  /// `inset 0 2px 0 #FFFFFF, 0 5px 0 #D8B07A, 0 9px 14px rgba(90,50,20,0.22)`.
  static const List<NestyShadow> raised = [
    NestyShadow(color: Color(0xFFFFFFFF), inset: true, dy: 2.0),
    NestyShadow(color: Color(0xFFD8B07A), dy: 5.0),
    NestyShadow(color: Color(0x385A3214), dy: 9.0, blur: 14.0),
  ];

  /// `inset 0 2px 0 #FFFFFF, 0 2px 0 #D8B07A, 0 3px 6px rgba(90,50,20,0.18)`.
  static const List<NestyShadow> pressed = [
    NestyShadow(color: Color(0xFFFFFFFF), inset: true, dy: 2.0),
    NestyShadow(color: Color(0xFFD8B07A), dy: 2.0),
    NestyShadow(color: Color(0x2E5A3214), dy: 3.0, blur: 6.0),
  ];

  /// `inset 0 2px 0 #FFFFFF, 0 8px 0 #D8B07A, 0 20px 40px rgba(60,25,5,0.35)`.
  static const List<NestyShadow> card = [
    NestyShadow(color: Color(0xFFFFFFFF), inset: true, dy: 2.0),
    NestyShadow(color: Color(0xFFD8B07A), dy: 8.0),
    NestyShadow(color: Color(0x593C1905), dy: 20.0, blur: 40.0),
  ];

  /// `inset 0 2px 0 #FFFFFF, 0 -10px 30px rgba(60,25,5,0.30)`.
  static const List<NestyShadow> sheet = [
    NestyShadow(color: Color(0xFFFFFFFF), inset: true, dy: 2.0),
    NestyShadow(color: Color(0x4D3C1905), dy: -10.0, blur: 30.0),
  ];

  /// `0 12px 24px rgba(90,45,15,0.30)`.
  static const List<NestyShadow> float = [
    NestyShadow(color: Color(0x4D5A2D0F), dy: 12.0, blur: 24.0),
  ];

  /// `inset 0 2px 3px rgba(90,45,15,0.30)`.
  static const List<NestyShadow> sunk = [
    NestyShadow(color: Color(0x4D5A2D0F), inset: true, dy: 2.0, blur: 3.0),
  ];

  /// `inset 0 2px 0 rgba(255,255,255,0.35), 0 6px 0 #C4631E, 0 10px 18px
  /// rgba(150,70,20,0.30)`.
  static const List<NestyShadow> primaryButton = [
    NestyShadow(color: Color(0x59FFFFFF), inset: true, dy: 2.0),
    NestyShadow(color: Color(0xFFC4631E), dy: 6.0),
    NestyShadow(color: Color(0x4D964614), dy: 10.0, blur: 18.0),
  ];

  /// `inset 0 2px 0 rgba(255,255,255,0.30), 0 6px 0 #5530A8, 0 10px 18px
  /// rgba(80,40,160,0.30)`.
  static const List<NestyShadow> adButton = [
    NestyShadow(color: Color(0x4DFFFFFF), inset: true, dy: 2.0),
    NestyShadow(color: Color(0xFF5530A8), dy: 6.0),
    NestyShadow(color: Color(0x4D5028A0), dy: 10.0, blur: 18.0),
  ];

  /// `inset 0 2px 0 #FFFFFF, 0 5px 0 #CFA36A, 0 8px 10px rgba(60,25,5,0.30)`.
  static const List<NestyShadow> booster = [
    NestyShadow(color: Color(0xFFFFFFFF), inset: true, dy: 2.0),
    NestyShadow(color: Color(0xFFCFA36A), dy: 5.0),
    NestyShadow(color: Color(0x4D3C1905), dy: 8.0, blur: 10.0),
  ];

  /// Pressed: "buttons move down by (edge − 2) px and the solid edge shrinks to
  /// 2 px, 80 ms".
  static const pressedEdge = 2.0;

  static const int pressTravelMs = 80;

  /// `inset 0 3px 0 rgba(255,210,160,0.35), inset 0 -4px 0 rgba(40,18,6,0.4), 0
  /// 8px 16px rgba(60,25,5,0.3)`.
  static const List<NestyShadow> cabinet = [
    NestyShadow(color: Color(0x59FFD2A0), inset: true, dy: 3.0),
    NestyShadow(color: Color(0x66281206), inset: true, dy: -4.0),
    NestyShadow(color: Color(0x4D3C1905), dy: 8.0, blur: 16.0),
  ];

  /// `inset 0 2px 4px rgba(90,45,15,0.25)`.
  static const List<NestyShadow> segmentTrack = [
    NestyShadow(color: Color(0x405A2D0F), inset: true, dy: 2.0, blur: 4.0),
  ];

  /// `inset 0 2px 0 #FFFFFF, 0 3px 0 #CFA36A`.
  static const List<NestyShadow> segmentSelected = [
    NestyShadow(color: Color(0xFFFFFFFF), inset: true, dy: 2.0),
    NestyShadow(color: Color(0xFFCFA36A), dy: 3.0),
  ];
}

/// Gameplay HUD placement on the 390×844 reference (tokens.json
/// `layout.hud`).
abstract final class HudTokens {
  static const top = 62.0;

  static const side = 16.0;

  static const pauseButtonSize = Size(48.0, 48.0);

  static const levelPillHeight = 46.0;

  static const coinPillHeight = 40.0;

  static const familyCounterTop = 116.0;

  static const familyCounterHeight = 26.0;

  static const familyCounterLabelMinWidth = 30.0;

  /// Inside the counter pill.
  static const familyCounterPadding = EdgeInsets.symmetric(
    vertical: 7.0,
    horizontal: 10.0,
  );

  static const familyCounterIconSize = Size(12.0, 18.0);

  static const familyCounterGap = 5.0;

  /// `ui_family_counter`'s pill is authored this wide: for another width w,
  /// size `pill_rect` and `glow_rect` to (w, 26) and move `icon` by (−w / 2 +
  /// 14, 0).
  static const familyCounterLottieWidth = 70.0;

  /// The design's counter widths by label, for the layout test.
  static const Map<String, double> familyCounterWidthExamples = {
    '4 / 4': 64.0,
    '12 / 12': 78.0,
  };

  static const familyCounterLabelMaxWidth = 58.0;

  static const familyCounterPillMaxWidth = 92.0;

  /// The pill is its label + this (m7-6 item 16); the label hugs its text up to
  /// [familyCounterLabelMaxWidth], then scales down to
  /// TextFitTokens.hudPillsMinScale and never wraps.
  static const familyCounterPillChrome = 34.0;
}

/// Booster bar (tokens.json `layout.boosterBar`).
abstract final class BoosterBarTokens {
  static const top = 734.0;

  static const buttonSize = Size(80.0, 58.0);

  static const gap = 8.0;

  static const left = 23.0;

  static const topInset = 12.0;
}

/// Home bottom navigation (tokens.json `layout.bottomNav`).
abstract final class BottomNavTokens {
  static const top = 738.0;

  static const activeItemSize = Size(58.0, 52.0);

  static const itemSize = Size(48.0, 48.0);

  /// Active item y offset (negative = up).
  static const lift = -6.0;
}

/// UI (non-board) motion: durations in ms and the design easings (tokens.json
/// `motion.ui`, `motion.easing`, `motion.reducedMotion`).
abstract final class UiMotionTokens {
  static const buttonPressMs = 80;

  static const toggleMs = 180;

  static const sheetInMs = 280;

  static const modalInMs = 240;

  static const tabLiftMs = 180;

  /// `cubic-bezier(0.2,0.8,0.2,1)`.
  static const curveEaseOut = Cubic(0.2, 0.8, 0.2, 1.0);

  /// `cubic-bezier(0.55,0,1,0.45)`.
  static const curveEaseIn = Cubic(0.55, 0.0, 1.0, 0.45);

  /// `cubic-bezier(0.45,0,0.55,1)`.
  static const curveEaseInOut = Cubic(0.45, 0.0, 0.55, 1.0);

  /// `cubic-bezier(0.34,1.56,0.64,1)`.
  static const curveEaseOutBack = Cubic(0.34, 1.56, 0.64, 1.0);

  /// `cubic-bezier(0.5,0,0.3,1)`.
  static const curveFly = Cubic(0.5, 0.0, 0.3, 1.0);

  /// `cubic-bezier(0.2,0.7,0.3,1)`.
  static const curveConfetti = Cubic(0.2, 0.7, 0.3, 1.0);

  /// `cubic-bezier(0.3,1.4,0.5,1)`.
  static const curveToggle = Cubic(0.3, 1.4, 0.5, 1.0);

  static const reducedMotionDurationScale = 0.5;
}

/// Sound events, music and mix (tokens.json `sound`, spec §11.3,
/// design/audio/AUDIO.md). SFX: 44.1 kHz mono 16-bit WAV. Music and jingles:
/// 44.1 kHz stereo OGG Vorbis q4. All in design/audio; rules in
/// design/audio/AUDIO.md.
abstract final class SoundTokens {
  /// `pick`.
  static const pick = SoundCue(['pick']);

  /// `whoosh`.
  static const move = SoundCue(['whoosh']);

  /// `clack_1|clack_2|clack_3 (random)`.
  static const nest = SoundCue([
    'clack_1',
    'clack_2',
    'clack_3',
  ], pick: SoundPick.random);

  /// `clack_1|clack_2|clack_3 (random)`.
  static const swallow = SoundCue([
    'clack_1',
    'clack_2',
    'clack_3',
  ], pick: SoundPick.random);

  /// `bonk`.
  static const invalid = SoundCue(['bonk']);

  /// `complete_{comboStep}`.
  static const complete = SoundCue([
    'complete_1',
    'complete_2',
    'complete_3',
    'complete_4',
    'complete_5',
  ], pick: SoundPick.comboStep);

  /// `win`.
  static const win = SoundCue(['win']);

  /// `coins`.
  static const coinsCountUp = SoundCue(['coins']);

  /// `unlock_glass`.
  static const unlock = SoundCue(['unlock_glass']);

  /// `ice_crack`.
  static const iceCrack = SoundCue(['ice_crack']);

  /// `ice_shatter`.
  static const iceShatter = SoundCue(['ice_shatter']);

  /// `button`.
  static const button = SoundCue(['button']);

  /// `jingle_chapter`: a jingle (OGG, in [jingleFiles]; the bus is
  /// [jingleBus]).
  static const chapterComplete = SoundCue(['jingle_chapter']);

  /// `jingle_reward`: a jingle (OGG, in [jingleFiles]; the bus is [jingleBus]).
  static const reward = SoundCue(['jingle_reward']);

  /// `jingle_oom`: a jingle (OGG, in [jingleFiles]; the bus is [jingleBus]).
  static const outOfMoves = SoundCue(['jingle_oom']);

  /// `star_1`.
  static const star1 = SoundCue(['star_1']);

  /// `star_2`.
  static const star2 = SoundCue(['star_2']);

  /// `star_3`.
  static const star3 = SoundCue(['star_3']);

  /// `chest_wiggle`.
  static const chestWiggle = SoundCue(['chest_wiggle']);

  /// `chest_open`.
  static const chestOpen = SoundCue(['chest_open']);

  /// `rival_complete`.
  static const rivalComplete = SoundCue(['rival_complete']);

  /// `jingle_versus_win`: a jingle (OGG, in [jingleFiles]; the bus is
  /// [jingleBus]).
  static const raceWon = SoundCue(['jingle_versus_win']);

  /// `jingle_versus_lose`: a jingle (OGG, in [jingleFiles]; the bus is
  /// [jingleBus]).
  static const raceLost = SoundCue(['jingle_versus_lose']);

  /// `jingle_reward`: a jingle (OGG, in [jingleFiles]; the bus is [jingleBus]).
  static const rivalUnlocked = SoundCue(['jingle_reward']);

  /// `none (no sound, no haptic)`: no sound (an empty cue plays nothing).
  static const reminderSet = SoundCue([]);

  /// `gift_claim`.
  static const giftClaim = SoundCue(['gift_claim']);

  /// `button (the welcome card, its close, a month day, Play again)`.
  static const habitsTap = SoundCue(['button']);

  /// `win @0, no coins (the past-day win, 14.3d)`.
  static const habitsPastWin = SoundCue(['win']);

  /// Every SFX file base name the events use, sorted (for preloading and the
  /// asset manifest test): `assets/audio/<name>.wav`. The jingles are
  /// [jingleFiles] and the music loops [musicFiles].
  static const List<String> allFiles = [
    'bonk',
    'button',
    'chest_open',
    'chest_wiggle',
    'clack_1',
    'clack_2',
    'clack_3',
    'coins',
    'complete_1',
    'complete_2',
    'complete_3',
    'complete_4',
    'complete_5',
    'gift_claim',
    'ice_crack',
    'ice_shatter',
    'pick',
    'rival_complete',
    'star_1',
    'star_2',
    'star_3',
    'unlock_glass',
    'whoosh',
    'win',
  ];

  /// Every jingle the events use (the `jingle_*` files), sorted: one-shots at
  /// `assets/audio/<name>.ogg`, loaded into memory like the SFX (AUDIO.md
  /// "Jingles").
  static const List<String> jingleFiles = [
    'jingle_chapter',
    'jingle_oom',
    'jingle_reward',
    'jingle_versus_lose',
    'jingle_versus_win',
  ];

  /// Clack pitch per doll size: playbackRate = 2^(-2 × (size − 3.5) / 12).
  static const Map<int, int> clackSemitonesBySize = {
    1: 5,
    2: 3,
    3: 1,
    4: -1,
    5: -3,
    6: -5,
  };

  /// The pitch the clack files are recorded at, in semitones from the size-3.5
  /// clack (tokens.json `sound.clackPitch.bakedSemitones`): the playback rate
  /// is 2^((clackSemitonesBySize[size] − this) / 12).
  static const clackBakedSemitones = 0;

  static const List<String> comboNotes = ['C6', 'D6', 'E6', 'G6', 'A6'];

  /// Sets completed within this window step up the chime.
  static const comboWindowMs = 4000;

  static const comboMaxSteps = 5;

  /// The home loop, `assets/audio/music_home.ogg` (streamed; the whole file
  /// loops). Plays on: Splash, Home, Daily, Museum, Shop, Skin detail,
  /// Settings.
  static const musicHome = 'music_home';

  /// The loop length in seconds, rounded (the frames are exact).
  static const musicHomeSeconds = 66.667;

  /// The loop length in frames at 44100 Hz.
  static const musicHomeFrames = 2940000;

  /// Tempo; with the meter and key, AUDIO.md "Music loops".
  static const musicHomeBpm = 108.0;

  static const musicHomeMeter = '3/4';

  static const musicHomeKey = 'C major';

  /// The game loop, `assets/audio/music_game.ogg` (streamed; the whole file
  /// loops). Plays on: Levels, daily puzzle, bonus levels.
  static const musicGame = 'music_game';

  /// The loop length in seconds, rounded (the frames are exact).
  static const musicGameSeconds = 68.571;

  /// The loop length in frames at 44100 Hz.
  static const musicGameFrames = 3024000;

  /// Tempo; with the meter and key, AUDIO.md "Music loops".
  static const musicGameBpm = 84.0;

  static const musicGameMeter = '4/4';

  static const musicGameKey = 'F major';

  /// Every music loop, sorted: `assets/audio/<name>.ogg`.
  static const List<String> musicFiles = ['music_game', 'music_home'];

  /// tokens.json `sound.musicFadeMs.start`.
  static const musicFadeStartMs = 1200;

  /// tokens.json `sound.musicFadeMs.crossfade`.
  static const musicFadeCrossfadeMs = 800;

  /// tokens.json `sound.musicFadeMs.resume`.
  static const musicFadeResumeMs = 600;

  /// tokens.json `sound.musicFadeMs.toggleOff`.
  static const musicFadeToggleOffMs = 300;

  /// tokens.json `sound.musicFadeMs.toggleOn`.
  static const musicFadeToggleOnMs = 600;

  /// tokens.json `sound.musicFadeMs.duckIn`.
  static const musicFadeDuckInMs = 200;

  /// tokens.json `sound.musicFadeMs.duckOut`.
  static const musicFadeDuckOutMs = 800;

  /// tokens.json `sound.musicFadeMs.chapterOut`.
  static const musicFadeChapterOutMs = 400;

  /// tokens.json `sound.musicFadeMs.chapterIn`.
  static const musicFadeChapterInMs = 2000;

  /// Music volume × this while ducked for win (tokens.json
  /// `sound.musicDuck.win`).
  static const musicDuckWin = 0.3;

  /// Music volume × this while ducked for outOfMoves (tokens.json
  /// `sound.musicDuck.outOfMoves`).
  static const musicDuckOutOfMoves = 0.4;

  /// Music volume × this while ducked for reward (tokens.json
  /// `sound.musicDuck.reward`).
  static const musicDuckReward = 0.4;

  /// Music volume × this while ducked for pause (tokens.json
  /// `sound.musicDuck.pause`).
  static const musicDuckPause = 0.5;

  /// Music volume × this while ducked for raceResult (tokens.json
  /// `sound.musicDuck.raceResult`).
  static const musicDuckRaceResult = 0.3;

  /// Every duck factor by reason (the `sound.musicDuck` keys). Ducks don't
  /// stack: the lowest active factor wins (AUDIO.md).
  static const Map<String, double> musicDuckFactors = {
    'win': 0.3,
    'outOfMoves': 0.4,
    'reward': 0.4,
    'pause': 0.5,
    'raceResult': 0.3,
  };

  static const sfxVolumeDefault = 0.8;

  static const musicVolumeDefault = 0.5;

  static const separateVolumes = true;

  /// The bus the jingles play on (tokens.json `sound.mix.jingleBus`): `sfx`
  /// follows the Sound toggle and the SFX volume, `music` the Music ones. The
  /// codegen accepts only these two.
  static const jingleBus = 'sfx';
}

/// tokens.json `layout.tutorial` (m7-4 (8.1): 1.3, 1.4, 1.6, 10.8b), in dp on
/// the 390×844 reference unless a member says otherwise.
abstract final class TutorialTokens {
  /// The tutorial scrim, over the HUD and the booster bar too, with a hole that
  /// keeps Pause lit (m7-4 8.1).
  static const scrim = Color(0x99341A08);

  /// x, y, width, height (`[10, 56, 60, 60]`).
  static const pauseHoleRect = Rect.fromLTWH(10.0, 56.0, 60.0, 60.0);

  static const pauseHoleRadius = 22.0;

  /// The tip sits in the HUD row (`HudTokens.top`).
  static const tooltipTop = 62.0;

  /// On the 16:9 screen.
  static const tooltipTopShort = 30.0;

  static const tooltipLeft = 76.0;

  static const tooltipRight = 16.0;

  static const tooltipPadding = EdgeInsets.fromLTRB(18.0, 14.0, 18.0, 16.0);

  static const tooltipRadius = 22.0;

  static const handScale = 0.6;
}

/// tokens.json `layout.sizeBlend` (4.7, 4.12), in dp on the 390×844 reference
/// unless a member says otherwise.
abstract final class SizeBlendTokens {}

/// tokens.json `layout.settingsRows`, in dp on the 390×844 reference unless a
/// member says otherwise.
abstract final class SettingsRowsTokens {
  static const segmentedHeight = 48.0;

  static const segmentedSegmentMinHeight = 40.0;

  /// The blocked reminder row's two actions, "Open phone settings" (a secondary
  /// chip) and "Turn off" (a text link), this far apart; they wrap under each
  /// other when narrow (10.2f, Q158).
  static const blockedActionsGap = 18.0;

  static const iconTilesSize = 36.0;

  static const iconTilesRadius = 12.0;

  static const iconTilesGlyph = 22.0;

  /// `#F6E2C2, #6E4526`.
  static const List<Color> iconTilesDefault = [
    Color(0xFFF6E2C2),
    Color(0xFF6E4526),
  ];

  /// `#FFF1C9, #8C5E12`.
  static const List<Color> iconTilesReminder = [
    Color(0xFFFFF1C9),
    Color(0xFF8C5E12),
  ];

  /// `#F6E2C2, #8A5B3A`.
  static const List<Color> iconTilesReminderBlocked = [
    Color(0xFFF6E2C2),
    Color(0xFF8A5B3A),
  ];

  /// `#DDF3E2, #2F7A3E`.
  static const List<Color> iconTilesRelaxed = [
    Color(0xFFDDF3E2),
    Color(0xFF2F7A3E),
  ];

  /// `#E8F3FF, #2B5E93`.
  static const List<Color> iconTilesReduceMotion = [
    Color(0xFFE8F3FF),
    Color(0xFF2B5E93),
  ];

  /// The rows' divider (`AppColorTokens.divider`).
  static const divider = TokenStroke(width: 1.5, color: Color(0xFFF0DFC4));
}

/// tokens.json `layout.noCoins` (7.3b, 7.4c (the modal shared with the other
/// cards)), in dp on the 390×844 reference unless a member says otherwise.
abstract final class NoCoinsTokens {
  /// `Fredoka 700 24/1.15, balanced`.
  static TextStyle get heading => DisplayFace.of(
    const TextStyle(
      fontFamily: 'Fredoka',
      fontSize: 24.0,
      fontWeight: FontWeight.w700,
      fontFamilyFallback: AppFontTokens.displayFallback,
      height: 1.15,
      leadingDistribution: TextLeadingDistribution.even,
    ),
  );

  /// `Nunito 600 16/23`.
  static const body = TextStyle(
    fontFamily: 'Nunito',
    fontSize: 16.0,
    fontWeight: FontWeight.w600,
    fontFamilyFallback: AppFontTokens.bodyFallback,
    height: 1.4375,
    leadingDistribution: TextLeadingDistribution.even,
  );

  /// `#FFFDF7`.
  static const itemChipFace = Color(0xFFFFFDF7);

  /// `inset 0 0 0 2px #EAD3B0`.
  static const List<NestyShadow> itemChipRing = [
    NestyShadow(color: Color(0xFFEAD3B0), inset: true, spread: 2.0),
  ];

  static const itemChipRadius = 18.0;

  static const itemChipPadding = EdgeInsets.fromLTRB(16.0, 8.0, 10.0, 8.0);

  /// `Fredoka 700 18`.
  static TextStyle get itemChipName => DisplayFace.of(
    const TextStyle(
      fontFamily: 'Fredoka',
      fontSize: 18.0,
      fontWeight: FontWeight.w700,
      fontFamilyFallback: AppFontTokens.displayFallback,
    ),
  );

  /// `gradient.coinChip pill, 30 tall, Fredoka 700 16 #8C5E12 with the 20 dp
  /// coin: the number alone (“2,500”); the coin says the rest, and a11y reads
  /// “2,500 coins”`.
  static const itemChipPriceFill = AppGradientTokens.coinChip;

  /// The price pill shows the number alone; the coin says the rest and screen
  /// readers hear "coins" (m7-4 10.1).
  static const itemChipPriceHeight = 30.0;

  /// `gradient.coinChip pill, 30 tall, Fredoka 700 16 #8C5E12 with the 20 dp
  /// coin: the number alone (“2,500”); the coin says the rest, and a11y reads
  /// “2,500 coins”`.
  static TextStyle get itemChipPriceText => DisplayFace.of(
    const TextStyle(
      fontFamily: 'Fredoka',
      fontSize: 16.0,
      fontWeight: FontWeight.w700,
      fontFamilyFallback: AppFontTokens.displayFallback,
      color: Color(0xFF8C5E12),
    ),
  );

  /// `gradient.coinChip pill, 30 tall, Fredoka 700 16 #8C5E12 with the 20 dp
  /// coin: the number alone (“2,500”); the coin says the rest, and a11y reads
  /// “2,500 coins”`.
  static const itemChipPriceCoin = 20.0;
}

/// tokens.json `layout.museumDetail`, in dp on the 390×844 reference unless a
/// member says otherwise.
abstract final class MuseumDetailTokens {
  static const spotlightDrawnInCode = true;

  /// The art panel the cone is clipped to.
  static const spotlightPanelHeight = 300.0;

  /// `the 300-tall art panel, radius 24, overflow hidden`.
  static const spotlightPanelRadius = 24.0;

  static const spotlightConeWidth = 250.0;

  static const spotlightConeHeight = 320.0;

  static const spotlightConeTop = -10.0;

  static const spotlightConeCentred = true;

  /// The cone's top edge runs from this fraction of its width …
  static const spotlightConeTopLeft = 0.38;

  /// … to this one; its bottom edge is the full width.
  static const spotlightConeTopRight = 0.62;

  /// `linear 180°: rgba(255,255,255,0.55) → rgba(255,255,255,0)`.
  static const spotlightConeFill = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0x8CFFFFFF), Color(0x00FFFFFF)],
  );

  static const spotlightHeight = 300.0;

  static const spotlightHeightShort = 200.0;

  static const spotlightShortBelow = 760.0;
}

/// tokens.json `layout.languageSheet` (8.2, 8.2b), in dp on the 390×844
/// reference unless a member says otherwise.
abstract final class LanguageSheetTokens {
  static const rowHeight = 56.0;

  /// `Nunito 600 13 #9A6A44, right, before the radio; not shown on the English
  /// row`.
  static const english = TextStyle(
    fontFamily: 'Nunito',
    fontSize: 13.0,
    fontWeight: FontWeight.w600,
    fontFamilyFallback: AppFontTokens.bodyFallback,
    color: Color(0xFF9A6A44),
  );

  /// `24, ring 2px #D8B07A; current: #F2893B fill with a white check`.
  static const radioSize = 24.0;

  /// `24, ring 2px #D8B07A; current: #F2893B fill with a white check`.
  static const radioRing = TokenStroke(width: 2.0, color: Color(0xFFD8B07A));

  /// The current language's radio, with a white check.
  static const radioCurrentFill = Color(0xFFF2893B);

  /// The sheet is at most the screen − the safe top − this.
  static const maxHeightInset = 72.0;

  /// The fade over the last rows while more are below.
  static const scrollFadeHeight = 16.0;

  /// `the rows scroll under the pinned title row; a 16 dp fade (#FCEBD0) at the
  /// bottom edge while more rows are below`.
  static const scrollFadeColor = Color(0xFFFCEBD0);
}

/// tokens.json `toast` (m7-4 (1.5). Kinds use color.toast*; title #5B3A21,
/// sub #8A5B3A unless noted), in dp on the 390×844 reference unless a member
/// says otherwise.
abstract final class ToastLayoutTokens {
  /// The app toast's top is the safe top + this, just under the status bar
  /// (m7-4 1.5).
  static const appTopBelowSafeTop = 4.0;

  static const appSide = 16.0;

  static const appPadding = EdgeInsets.fromLTRB(12.0, 12.0, 16.0, 12.0);

  static const appRadius = 22.0;

  static const appGap = 12.0;

  static const appIcon = 40.0;

  static const appGlyph = 26.0;

  /// `Fredoka 700 17/1.1`.
  static TextStyle get appTitle => DisplayFace.of(
    const TextStyle(
      fontFamily: 'Fredoka',
      fontSize: 17.0,
      fontWeight: FontWeight.w700,
      fontFamilyFallback: AppFontTokens.displayFallback,
      height: 1.1,
      leadingDistribution: TextLeadingDistribution.even,
    ),
  );

  /// `Nunito 700 13/1.3`.
  static const appMessage = TextStyle(
    fontFamily: 'Nunito',
    fontSize: 13.0,
    fontWeight: FontWeight.w700,
    fontFamilyFallback: AppFontTokens.bodyFallback,
    height: 1.3,
    leadingDistribution: TextLeadingDistribution.even,
  );

  /// `inset 0 2px 0 #FFFFFF`.
  static const List<NestyShadow> appHighlight = [
    NestyShadow(color: Color(0xFFFFFFFF), inset: true, dy: 2.0),
  ];

  /// The solid edge's depth under the toast, in its kind's ring colour
  /// (`AppColorTokens.toast<Kind>Ring`).
  static const appEdgeDepth = 4.0;

  /// `0 12px 24px rgba(30,60,100,0.25)`.
  static const List<NestyShadow> appShadow = [
    NestyShadow(color: Color(0x401E3C64), dy: 12.0, blur: 24.0),
  ];

  /// `linear-gradient(180deg,#6FB4EA,#3E8EDE)`.
  static const appIconDiscInfo = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF6FB4EA), Color(0xFF3E8EDE)],
  );

  /// `#46A758`.
  static const appIconDiscSuccess = Color(0xFF46A758);

  /// `#F2893B`.
  static const appIconDiscWarn = Color(0xFFF2893B);

  /// A badge toast shows the badge art at this size, with no disc.
  static const appBadgeArtSize = 38.0;

  /// `0 12px 24px rgba(30,90,40,0.2)`.
  static const List<NestyShadow> appShadowSuccess = [
    NestyShadow(color: Color(0x331E5A28), dy: 12.0, blur: 24.0),
  ];

  static const inPlaceTopsWinCard = 60.0;

  static const inPlaceTopsScreenHeader = 124.0;

  static const inPlaceTopsBoard = 152.0;

  static const inPlaceSide = 20.0;

  static const inPlacePadding = EdgeInsets.fromLTRB(8.0, 8.0, 14.0, 8.0);

  static const inPlaceRadius = 20.0;

  static const inPlaceGap = 10.0;

  static const inPlaceIcon = 32.0;

  static const inPlaceGlyph = 20.0;

  static const inPlaceArt = 38.0;

  /// `Fredoka 700 15/1.3`.
  static TextStyle get inPlaceTitle => DisplayFace.of(
    const TextStyle(
      fontFamily: 'Fredoka',
      fontSize: 15.0,
      fontWeight: FontWeight.w700,
      fontFamilyFallback: AppFontTokens.displayFallback,
      height: 1.3,
      leadingDistribution: TextLeadingDistribution.even,
    ),
  );

  /// `Nunito 700 12/1.3`.
  static const inPlaceSub = TextStyle(
    fontFamily: 'Nunito',
    fontSize: 12.0,
    fontWeight: FontWeight.w700,
    fontFamilyFallback: AppFontTokens.bodyFallback,
    height: 1.3,
    leadingDistribution: TextLeadingDistribution.even,
  );

  /// `inset 0 2px 0 rgba(255,255,255,0.7)`.
  static const List<NestyShadow> inPlaceHighlight = [
    NestyShadow(color: Color(0xB3FFFFFF), inset: true, dy: 2.0),
  ];

  /// The solid edge's depth under the toast, in its kind's ring colour
  /// (`AppColorTokens.toast<Kind>Ring`).
  static const inPlaceEdgeDepth = 4.0;

  /// `0 8px 14px rgba(90,50,20,0.2)`.
  static const List<NestyShadow> inPlaceShadow = [
    NestyShadow(color: Color(0x335A3214), dy: 8.0, blur: 14.0),
  ];

  static const inPlaceChipHeight = 24.0;

  static const inPlaceChipRadius = 12.0;

  /// `#FFFDF7`.
  static const inPlaceChipFace = Color(0xFFFFFDF7);

  /// `1.5px #9CC4EA`.
  static const inPlaceChipRing = TokenStroke(
    width: 1.5,
    color: Color(0xFF9CC4EA),
  );

  /// `Nunito 800 12 #2B5E93`.
  static const inPlaceChipText = TextStyle(
    fontFamily: 'Nunito',
    fontSize: 12.0,
    fontWeight: FontWeight.w800,
    fontFamilyFallback: AppFontTokens.bodyFallback,
    color: Color(0xFF2B5E93),
  );

  /// `#FFF7E8`.
  static const pillFace = Color(0xFFFFF7E8);

  static const pillPadding = EdgeInsets.fromLTRB(8.0, 8.0, 18.0, 8.0);

  static const pillRadius = 24.0;

  static const pillIcon = 32.0;

  /// `Fredoka 700 15`.
  static TextStyle get pillText => DisplayFace.of(
    const TextStyle(
      fontFamily: 'Fredoka',
      fontSize: 15.0,
      fontWeight: FontWeight.w700,
      fontFamilyFallback: AppFontTokens.displayFallback,
    ),
  );

  /// `0 4px 0 #D8B07A`.
  static const List<NestyShadow> pillEdge = [
    NestyShadow(color: Color(0xFFD8B07A), dy: 4.0),
  ];
}

/// tokens.json `textFit` (m7-4 (9.2): what each tight surface does with long
/// strings (de ≈ +30 %, hi and ja taller). Order: wrap if allowed, else scale
/// down to min, else the short form in copy.md), in dp on the 390×844
/// reference unless a member says otherwise.
abstract final class TextFitTokens {
  static const winRibbonBox = Size(266.0, 40.0);

  /// `Fredoka 700 24`.
  static TextStyle get winRibbonFont => DisplayFace.of(
    const TextStyle(
      fontFamily: 'Fredoka',
      fontSize: 24.0,
      fontWeight: FontWeight.w700,
      fontFamilyFallback: AppFontTokens.displayFallback,
    ),
  );

  static const winRibbonWrap = false;

  static const winRibbonMinScale = 0.75;

  /// The copy.md ids of the short forms (the ARB keys).
  static const List<String> winRibbonShort = [
    'win_title_short',
    'race_win_title_short',
    'race_lose_title_short',
  ];

  static const chapterRibbonBox = Size(312.0, 32.0);

  /// `Fredoka 700 20`.
  static TextStyle get chapterRibbonFont => DisplayFace.of(
    const TextStyle(
      fontFamily: 'Fredoka',
      fontSize: 20.0,
      fontWeight: FontWeight.w700,
      fontFamilyFallback: AppFontTokens.displayFallback,
    ),
  );

  static const chapterRibbonWrap = false;

  static const chapterRibbonMinScale = 0.75;

  /// The copy.md id of the short form (the ARB key).
  static const List<String> chapterRibbonShort = ['chapter_ribbon_short'];

  static const hudPillsWrap = false;

  static const hudPillsMinScale = 0.85;

  static const boosterLabelsBox = Size(72.0, 16.0);

  static const boosterLabelsWrap = false;

  static const boosterLabelsMinScale = 0.8;

  static const tabBarBox = Size(80.0, 14.0);

  static const tabBarWrap = false;

  static const tabBarMinScale = 0.8;

  static const rivalNamesWrap = false;

  static const rivalNamesMinScale = 0.85;

  static const chestChipsWrap = false;

  static const chestChipsMinScale = 0.85;

  static const chapterRowsWrap = false;

  static const chapterRowsMinScale = 0.85;

  static const giftChestTitleMinScale = 0.85;

  /// The copy.md id of the short form (the ARB key).
  static const List<String> giftChestTitleShort = ['gift_chest_title_short'];

  static const freezeChipMaxWidth = 64.0;

  /// `Fredoka 700 11`.
  static TextStyle get freezeChipFont => DisplayFace.of(
    const TextStyle(
      fontFamily: 'Fredoka',
      fontSize: 11.0,
      fontWeight: FontWeight.w700,
      fontFamilyFallback: AppFontTokens.displayFallback,
    ),
  );

  /// The copy.md id of the short form (the ARB key).
  static const List<String> freezeChipShort = ['streak_freeze_chip_short'];

  /// One line, scaling down to this, then it wraps (`one line, scales to 0.85,
  /// then wraps`).
  static const habitsWelcomeTitleMinScale = 0.85;

  /// The body takes this many lines, then the short forms
  /// `habits_welcome_*_short` (copy.md `## Short forms`).
  static const habitsWelcomeBodyMaxLines = 2;

  /// From this text scale, or with a short body, the Play pill moves under the
  /// text (HabitsWelcomeTokens.playUnderGap).
  static const habitsWelcomePlayUnderAtTextScale = 1.3;

  /// One line, scaling down to this (`one line, scales to 0.85`).
  static const habitsMonthTitleMinScale = 0.85;

  /// One line, then this short form (the ARB key) …
  static const List<String> habitsMonthHintShort = ['habits_month_hint_short'];

  /// … then this many lines.
  static const habitsMonthHintMaxLines = 2;

  /// The weekday names are the abbreviated stand-alone ones; when one does not
  /// fit its column at this scale, the narrow form.
  static const habitsMonthWeekdaysMinScale = 0.85;

  /// The widget's line: this many lines, then an ellipsis (native).
  static const widgetLineMaxLines = 2;

  /// The widget's title: one line, then an ellipsis (native).
  static const widgetTitleMaxLines = 1;

  /// The widget's streak number never scales below this; 1000+ uses the
  /// locale's grouping (native).
  static const widgetNumberMinScale = 0.8;
}

/// tokens.json `screenHeader` (m7-4 (10.2): one alignment for every screen.
/// Daily, the Shop, the Museum detail and Skin detail move left, like
/// Chapters, Records, Settings and rival select (frames updated)), in dp on
/// the 390×844 reference unless a member says otherwise.
abstract final class ScreenHeaderTokens {
  static const top = 62.0;

  static const height = 48.0;

  static const side = 16.0;

  static const buttonSize = 46.0;

  static const buttonRadius = 17.0;

  static const buttonGlyph = 26.0;

  static const gap = 12.0;

  /// The header's trailing coin pill (or nothing).
  static const trailingCoinPillHeight = 40.0;

  /// A tab screen (the Museum) has no button; its title starts here.
  static const tabScreenTitleLeft = 20.0;
}

/// tokens.json `motion.chest.collect`, in dp on the 390×844 reference unless
/// a member says otherwise.
abstract final class ChestCollectTokens {
  /// `0 0 0 4px rgba(255,214,110,0.8), 0 0 18px 6px rgba(255,205,80,0.6)`.
  static const List<NestyShadow> pillRingShadow = [
    NestyShadow(color: Color(0xCCFFD66E), spread: 4.0),
    NestyShadow(color: Color(0x99FFCD50), blur: 18.0, spread: 6.0),
  ];

  static const pillRingOutset = 4.0;

  static const pillRingInMs = 80;

  /// The ring shows as the first coin lands.
  static const pillRingFromMs = 700;

  static const pillRingOutMs = 240;

  /// The last coin lands here; the ring fades [pillRingOutMs] after.
  static const pillRingLastCoinMs = 1000;

  static const hintRingSize = 38.0;

  /// `0 0 0 3px #FFE08A, 0 0 14px 4px rgba(255,205,80,0.7)`.
  static const List<NestyShadow> hintRingShadow = [
    NestyShadow(color: Color(0xFFFFE08A), spread: 3.0),
    NestyShadow(color: Color(0xB3FFCD50), blur: 14.0, spread: 4.0),
  ];

  /// `#46A758`.
  static const gainTagFace = Color(0xFF46A758);

  /// `0 2px 0 #2F7A3E`.
  static const List<NestyShadow> gainTagEdge = [
    NestyShadow(color: Color(0xFF2F7A3E), dy: 2.0),
  ];

  /// `Fredoka 700 13 #FFFFFF`.
  static TextStyle get gainTagFont => DisplayFace.of(
    const TextStyle(
      fontFamily: 'Fredoka',
      fontSize: 13.0,
      fontWeight: FontWeight.w700,
      fontFamilyFallback: AppFontTokens.displayFallback,
      color: Color(0xFFFFFFFF),
    ),
  );

  static const gainTagPadding = EdgeInsets.symmetric(
    vertical: 3.0,
    horizontal: 8.0,
  );

  static const gainTagRadius = 10.0;

  static const gainTagOffset = Offset(12.0, -42.0);

  static const gainTagHoldMs = 1200;

  static const trailDot = 6.0;

  /// `#FFF1C9`.
  static const trailColor = Color(0xFFFFF1C9);

  static const trailCoinDots = 5.0;

  static const trailHintDots = 3.0;

  /// Each trail dot sits behind the sprite at path t − this.
  static const List<double> trailSpacing = [0.1, 0.2, 0.3, 0.45, 0.6];

  /// `0.95 near the sprite to 0.35 at the tail`.
  static const trailOpacityHead = 0.95;

  /// `0.95 near the sprite to 0.35 at the tail`.
  static const trailOpacityTail = 0.35;

  static const trailFadeMs = 200;
}

/// tokens.json `motion.rivalReact` (C.6), in dp on the 390×844 reference
/// unless a member says otherwise.
abstract final class RivalReactTokens {
  static const stripCanvasDp = 47.5;

  static const resultCardCanvasDp = 70.0;
}

/// tokens.json `motion.museumIdle` (J.2), in dp on the 390×844 reference
/// unless a member says otherwise.
abstract final class MuseumIdleTokens {
  /// The square canvas, dp.
  static const canvas = 90.0;

  static const figurineDp = 62.0;

  static const randomStartFrame = true;
}

/// tokens.json `motion.firstLaunch`, in dp on the 390×844 reference unless a
/// member says otherwise.
abstract final class FirstLaunchTokens {
  static const fadeMs = 400;

  /// The first launch's fade (`motion.easing.easeOut`).
  static const Cubic curve = UiMotionTokens.curveEaseOut;
}

/// tokens.json `motion.spinner`, in dp on the 390×844 reference unless a
/// member says otherwise.
abstract final class SpinnerMotionTokens {
  /// Under reduce motion `ui_spinner` rests on frame 0 and pulses its opacity 1
  /// → this → 1 …
  static const reducedMotionMinOpacity = 0.45;

  /// … over this, looping, `easeInOut` (12.5, 7.5).
  static const reducedMotionPulseMs = 1600;
}

/// tokens.json `motion.purchaseItem` (a skin or theme bought with coins (7.3,
/// 7.4, 7.7); no card), in dp on the 390×844 reference unless a member says
/// otherwise.
abstract final class PurchaseItemTokens {
  /// This many `fx_sparkle` around the card or the Buy button.
  static const sparkleCount = 3;

  /// The header balance counts down over this.
  static const balanceCountDownMs = 400;
}

/// tokens.json `motion.relitHome` (4.10), in dp on the 390×844 reference
/// unless a member says otherwise.
abstract final class RelitHomeTokens {
  /// The Daily tile badge glows (`AppColorTokens.relitGlow` ring) on the first
  /// Home visit after a relight, in that session or a later one, never twice
  /// (m7-4 4.10) …
  static const glowMs = 2400;

  /// … then fades over this.
  static const fadeMs = 400;
}

/// tokens.json `motion.relitTwinkle` (10.7, 10.7b (4.17)), in dp on the
/// 390×844 reference unless a member says otherwise.
abstract final class RelitTwinkleTokens {
  /// The `auto_awesome` glyph.
  static const glyph = 'auto_awesome';

  /// `auto_awesome, 22 dp, #FFE08A, glow 0 0 6px rgba(255,220,120,0.9)`.
  static const glyphSize = 22.0;

  /// `auto_awesome, 22 dp, #FFE08A, glow 0 0 6px rgba(255,220,120,0.9)`.
  static const glyphColor = Color(0xFFFFE08A);

  /// `auto_awesome, 22 dp, #FFE08A, glow 0 0 6px rgba(255,220,120,0.9)`.
  static const List<NestyShadow> glyphGlow = [
    NestyShadow(color: Color(0xE6FFDC78), blur: 6.0),
  ];

  /// The twinkle's box sits at the flame disc's top-right corner, right and top
  /// this far (negative: outside the disc).
  static const placeInset = -8.0;
}

/// tokens.json `layout.rivalStrip` (vs Computer HUD top row; replaces the
/// level pill and the coin pill. Family counter stays at top 116.), in dp on
/// the 390×844 reference unless a member says otherwise.
abstract final class RivalStripTokens {
  static const left = 76.0;

  static const right = 16.0;

  static const top = 62.0;

  static const height = 48.0;

  static const radius = 18.0;

  static const padding = EdgeInsets.fromLTRB(5.0, 0.0, 12.0, 0.0);

  static const gap = 9.0;

  static const portrait = 38.0;

  /// `2px #FFFDF7`.
  static const portraitRing = TokenStroke(width: 2.0, color: Color(0xFFFFFDF7));

  /// `Fredoka 700 16 #5B3A21`.
  static TextStyle get name => DisplayFace.of(
    const TextStyle(
      fontFamily: 'Fredoka',
      fontSize: 16.0,
      fontWeight: FontWeight.w700,
      fontFamilyFallback: AppFontTokens.displayFallback,
      color: Color(0xFF5B3A21),
    ),
  );

  static const tagHeight = 20.0;

  static const tagRadius = 10.0;

  static const tagPadding = EdgeInsets.fromLTRB(5.0, 0.0, 7.0, 0.0);

  /// `1.5px #D8B07A`.
  static const tagRing = TokenStroke(width: 1.5, color: Color(0xFFD8B07A));

  /// `#FFFDF7`.
  static const tagFill = Color(0xFFFFFDF7);

  /// `Nunito 800 11 #6E4526, sentence case`.
  static const tagText = TextStyle(
    fontFamily: 'Nunito',
    fontSize: 11.0,
    fontWeight: FontWeight.w800,
    fontFamilyFallback: AppFontTokens.bodyFallback,
    color: Color(0xFF6E4526),
  );

  /// The `computer` glyph (`NestyIcons`).
  static const tagGlyph = 'computer';

  static const tagGlyphSize = 14.0;

  /// `Nunito 700 12 #8A5B3A; thinking = three 3 px dots, 1.2 s, 200 ms
  /// stagger`.
  static const state = TextStyle(
    fontFamily: 'Nunito',
    fontSize: 12.0,
    fontWeight: FontWeight.w700,
    fontFamilyFallback: AppFontTokens.bodyFallback,
    color: Color(0xFF8A5B3A),
  );

  /// Thinking… dots.
  static const stateThinkingDots = 3;

  /// Each dot, dp.
  static const stateThinkingDotSize = 3.0;

  /// One cycle of the dots.
  static const stateThinkingPeriodMs = 1200;

  /// Between dots.
  static const stateThinkingStaggerMs = 200;

  /// `Fredoka 700 17 #3242A8 tabular`.
  static TextStyle get count => DisplayFace.of(
    const TextStyle(
      fontFamily: 'Fredoka',
      fontSize: 17.0,
      fontWeight: FontWeight.w700,
      fontFamilyFallback: AppFontTokens.displayFallback,
      color: Color(0xFF3242A8),
      fontFeatures: [FontFeature.tabularFigures()],
    ),
  );

  static const dotsSize = 8.0;

  static const dotsGap = 3.0;

  /// A filled dot.
  static const dotsFilled = Color(0xFF4E5FD9);

  /// Its ring.
  static const dotsFilledRing = TokenStroke(
    width: 1.5,
    color: Color(0xFFFFFDF7),
  );

  /// An empty dot, drawn sunk (`AppShadowTokens.sunk`).
  static const dotsEmpty = Color(0xFFEAD3B0);

  /// From this many families the dots shrink (as built) …
  static const dotsManyFromFamilies = 9;

  /// … to this, dp …
  static const dotsManySize = 6.0;

  /// … this far apart.
  static const dotsManyGap = 2.0;

  static const narrowTagGlyphOnlyBelowWidth = 360.0;

  static const narrowStateHiddenBelowWidth = 340.0;

  /// The full form (9.3) draws the count over at most this many dots; a race
  /// with more families takes the count-only form.
  static const formsFullMaxDots = 8;

  /// The count-only form (9.3h): the dots go and the count stands alone,
  /// centred; also every race with more than [formsFullMaxDots] families.
  static TextStyle get formsCountOnlyText => DisplayFace.of(
    const TextStyle(
      fontFamily: 'Fredoka',
      fontSize: 17.0,
      fontWeight: FontWeight.w700,
      fontFamilyFallback: AppFontTokens.displayFallback,
    ),
  );

  /// The `more_horiz` glyph (`NestyIcons`), 16 dp after the tag (9.3i);
  /// tools/test/tokens checks the bundled icon font has it.
  static const formsStateGlyphThinking = 'more_horiz';

  /// `more_horiz, #8A5B3A, pulsing like the 3 dots`.
  static const formsStateGlyphThinkingColor = Color(0xFF8A5B3A);

  /// The `replay` glyph (`NestyIcons`), 16 dp after the tag (9.3i);
  /// tools/test/tokens checks the bundled icon font has it.
  static const formsStateGlyphStartingOver = 'replay';

  /// `replay, #8A5B3A`.
  static const formsStateGlyphStartingOverColor = Color(0xFF8A5B3A);

  /// The `check_circle` glyph (`NestyIcons`), 16 dp after the tag (9.3i);
  /// tools/test/tokens checks the bundled icon font has it.
  static const formsStateGlyphFinished = 'check_circle';

  /// `check_circle, #46A758`.
  static const formsStateGlyphFinishedColor = Color(0xFF46A758);

  static const formsStateGlyphGap = 5.0;

  static const formsHeightAt13 = 58.0;

  /// In the m7-5 forms the dots never shrink below this, dp.
  static const formsDotsMinSize = 8.0;

  /// Pause stays HudTokens.pauseButtonSize in every strip form; on the
  /// [formsHeightAt13] strip it sits this far down, centred (m7-6 item 3,
  /// 9.3i).
  static const formsPauseTop = 5.0;
}

/// tokens.json `layout.raceBar` (booster bar during a race: Undo (unlimited)
/// in slot 1, Restart in slot 4, Hint and +1 Slot hidden. Before the start, a
/// Start button covers slots 2-3 and the other slots are hidden.), in dp on
/// the 390×844 reference unless a member says otherwise.
abstract final class RaceBarTokens {
  static const startX = 111.0;

  static const startY = 746.0;

  static const startWidth = 168.0;

  static const startHeight = 58.0;

  static const startRadius = 18.0;

  /// `versus`.
  static const startGradient = AppGradientTokens.versus;

  /// `6px #3242A8`.
  static const startEdge = TokenStroke(width: 6.0, color: Color(0xFF3242A8));

  /// `Fredoka 700 21 white`.
  static TextStyle get startLabel => DisplayFace.of(
    const TextStyle(
      fontFamily: 'Fredoka',
      fontSize: 21.0,
      fontWeight: FontWeight.w700,
      fontFamilyFallback: AppFontTokens.displayFallback,
      color: Color(0xFFFFFFFF),
    ),
  );

  static const undoSlot = 1;

  static const restartSlot = 4;

  static const List<int> hiddenSlots = [2, 3];

  /// The `all_inclusive` glyph (`NestyIcons`).
  static const undoBadge = 'all_inclusive';
}

/// tokens.json `layout.short169` (16:9 phones (390x693 logical). Everything
/// else in layout.* keeps its 844 values; the board is scaled once.), in dp
/// on the 390×693 (16:9) reference unless a member says otherwise.
abstract final class Short169Tokens {
  static const screen = Size(390.0, 693.0);

  static const statusBar = 20.0;

  static const hudShiftY = -32.0;

  static const boardScale = 0.796;

  static const boardOrigin = Offset(195.0, 150.0);

  static const boardShiftY = -32.0;

  static const boosterBarTop = 583.0;
}

/// tokens.json `layout.winStars` (2.8 with stars on 390×844 (11.2)), in dp on
/// the 390×844 reference unless a member says otherwise.
abstract final class WinStarsTokens {
  static const ribbonTop = 118.0;

  static const starsCanvasSize = Size(240.0, 110.0);

  static const starsCanvasLeft = 75.0;

  static const starsCanvasTop = 176.0;

  static const plankTop = 366.0;

  static const hopDollHeight = 88.0;

  static const coinRowTop = 420.0;

  static const coinRowGap = 10.0;

  static const movesChipHeight = 58.0;

  static const movesChipRadius = 26.0;

  static const movesChipIconDisc = 38.0;

  /// The `route` glyph (`NestyIcons`).
  static const movesChipIcon = 'route';

  /// `Nunito 800 15 #7A5234`.
  static const movesChipText = TextStyle(
    fontFamily: 'Nunito',
    fontSize: 15.0,
    fontWeight: FontWeight.w800,
    fontFamilyFallback: AppFontTokens.bodyFallback,
    color: Color(0xFF7A5234),
  );

  static const newBestChipHeight = 26.0;

  static const newBestChipRadius = 13.0;

  /// `gradient.success`.
  static const newBestChipFill = AppGradientTokens.success;

  /// `3px #2F7A3E`.
  static const newBestChipEdge = TokenStroke(
    width: 3.0,
    color: Color(0xFF2F7A3E),
  );

  /// `2px #FFF6E6`.
  static const newBestChipRing = TokenStroke(
    width: 2.0,
    color: Color(0xFFFFF6E6),
  );

  /// Centred on the moves chip, its top this far from the chip's.
  static const newBestChipTopOffset = -16.0;

  static const progressTop = 500.0;

  static const notePillTop = 602.0;

  /// `rgba(40,20,8,.66)`.
  static const notePillFill = Color(0xA8281408);

  static const notePillRadius = 14.0;

  static const notePillPadding = EdgeInsets.symmetric(
    vertical: 7.0,
    horizontal: 14.0,
  );

  /// `Nunito 700 13 #FFF1DC`.
  static const notePillText = TextStyle(
    fontFamily: 'Nunito',
    fontSize: 13.0,
    fontWeight: FontWeight.w700,
    fontFamilyFallback: AppFontTokens.bodyFallback,
    color: Color(0xFFFFF1DC),
  );

  static const buttonsTop = 646.0;

  static const buttonsGap = 14.0;
}

/// tokens.json `layout.winStarsShort` (2.8 with stars on 390×693 (11.2d)), in
/// dp on the 390×693 (16:9) reference unless a member says otherwise.
abstract final class WinStarsShortTokens {
  static const ribbonTop = 70.0;

  static const starsCanvasTop = 128.0;

  static const plankTop = 300.0;

  static const hopDollHeight = 72.0;

  static const coinRowTop = 342.0;

  static const progressTop = 414.0;

  static const notePillTop = 486.0;

  static const notePillWithTipPlankTop = 286.0;

  static const notePillWithTipHopDollHeight = 64.0;

  static const notePillWithTipCoinRowTop = 322.0;

  static const notePillWithTipProgressTop = 392.0;

  static const notePillWithTipButtonsTop = 548.0;

  static const buttonsTop = 522.0;

  static const buttonsGap = 10.0;
}

/// tokens.json `layout.chestCard` (m7-4: the frames are right (10.3b 168, 5.6
/// 176); 214 is withdrawn), in dp on the 390×844 reference unless a member
/// says otherwise.
abstract final class ChestCardTokens {
  static const cardLeft = 28.0;

  static const cardRight = 28.0;

  static const cardTop = 168.0;

  static const cardTopDay7 = 176.0;

  static const cardRadius = 32.0;

  static const cardPadding = EdgeInsets.fromLTRB(22.0, 44.0, 22.0, 22.0);

  static const cardGap = 14.0;

  /// The card's height from its content, for the layout tests: closed …
  static const cardHeightClosed = 390.0;

  /// … open …
  static const cardHeightOpen = 390.0;

  /// … and the day-7 chest open with Double it.
  static const cardHeightOpenDoubleIt = 458.0;

  static const artBox = Size(156.0, 130.0);

  static const lottieScale = 1.2;

  static const contentsChipHeight = 44.0;

  static const contentsChipRadius = 22.0;

  static const contentsGap = 10.0;

  static const contentsIcon = 30.0;
}

/// tokens.json `layout.home` (Home 2.1 from m7 (J.1)), in dp on the 390×844
/// reference unless a member says otherwise.
abstract final class HomeTokens {
  static const topRow = 66.0;

  static const chapterCardTop = 124.0;

  static const chapterCardLeft = 16.0;

  static const chapterCardRight = 88.0;

  static const chapterCardHeight = 60.0;

  static const chapterCardRadius = 22.0;

  static const chapterCardIcon = 44.0;

  static const recordsButtonTop = 124.0;

  static const recordsButtonRight = 16.0;

  static const recordsButtonSize = Size(62.0, 60.0);

  static const recordsButtonRadius = 20.0;

  /// The `military_tech` glyph (`NestyIcons`).
  static const recordsButtonGlyph = 'military_tech';

  static const plankTop = 372.0;

  static const playButtonTop = 446.0;

  static const playButtonHeight = 96.0;

  static const tilesTop = 584.0;

  static const tilesHeight = 132.0;

  static const tilesColumns = 3;

  static const tilesColumnsAdsRemoved = 2;

  static const bottomNav = 738.0;

  static const giftButtonRight = 68.0;

  static const giftButtonTop = 64.0;

  static const giftButtonSize = 46.0;
}

/// tokens.json `layout.homeShort` (Home on 390×693 (2.1b, E.1 approved):
/// tiles stay 12 dp above the nav, the hero scales), in dp on the 390×693
/// (16:9) reference unless a member says otherwise.
abstract final class HomeShortTokens {
  static const statusBar = 20.0;

  static const topRow = 28.0;

  static const chapterCard = 84.0;

  static const plankTop = 262.0;

  static const plankHeight = 34.0;

  static const dollScale = 0.82;

  static const playButtonTop = 312.0;

  static const playButtonHeight = 88.0;

  static const tilesTop = 463.0;

  static const tilesHeight = 112.0;

  static const bottomNav = 587.0;

  static const giftButtonRight = 68.0;

  static const giftButtonTop = 26.0;

  static const giftButtonSize = 46.0;
}

/// tokens.json `layout.chapters` (Chapters (10.4)), in dp on the 390×844
/// reference unless a member says otherwise.
abstract final class ChaptersTokens {
  static const progressLineTop = 118.0;

  static const progressLineBar = 12.0;

  static const listTop = 166.0;

  static const gap = 8.0;

  static const foldedRowHeight = 56.0;

  static const foldedRowRadius = 20.0;

  static const foldedRowThumb = Size(84.0, 42.0);

  static const foldedRowFigurine = Size(34.0, 40.0);

  static const foldedRowStarsChip = 28.0;

  /// `Fredoka 700 15, one line; scales down to 0.85 (12.75) before it
  /// ellipsizes`.
  static TextStyle get foldedRowName => DisplayFace.of(
    const TextStyle(
      fontFamily: 'Fredoka',
      fontSize: 15.0,
      fontWeight: FontWeight.w700,
      fontFamilyFallback: AppFontTokens.displayFallback,
    ),
  );

  /// One line: it scales down to this before it ellipsizes.
  static const foldedRowNameMinScale = 0.85;

  /// The open chapter's ring, in its palette's `accentTop`.
  static const currentRingWidth = 3.0;

  static const currentHeaderHeight = 92.0;

  /// The header shows the theme's thumb crop scaled to this width.
  static const currentHeaderCropWidth = 358.0;

  /// `linear-gradient(180deg,rgba(20,40,70,0) 25%,rgba(20,40,70,.62))`.
  static const currentHeaderScrim = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0x00142846), Color(0x9E142846)],
    stops: [0.25, 1.0],
  );

  static const currentGridColumns = 5;

  static const currentGridGap = 7.0;

  static const currentGridTileHeight = 62.0;

  static const currentGridTileRadius = 14.0;

  static const currentGridMiniStar = 11.0;

  /// `Nunito 800 9.5 #9A6A44`.
  static const currentGridBest = TextStyle(
    fontFamily: 'Nunito',
    fontSize: 9.5,
    fontWeight: FontWeight.w800,
    fontFamilyFallback: AppFontTokens.bodyFallback,
    color: Color(0xFF9A6A44),
  );

  /// The current level's tile.
  static const currentTileFill = AppGradientTokens.primary;

  /// `gradient.primary, 4px edge #C4631E, 4px ring rgba(242,137,59,.28)`.
  static const currentTileEdge = TokenStroke(
    width: 4.0,
    color: Color(0xFFC4631E),
  );

  /// `gradient.primary, 4px edge #C4631E, 4px ring rgba(242,137,59,.28)`.
  static const currentTileRing = TokenStroke(
    width: 4.0,
    color: Color(0x47F2893B),
  );

  /// A hard or super hard tile's inset edge, on won or current tiles.
  static const currentTierEdgeWidth = 2.0;

  /// A 3-star chapter chip's inset line.
  static const perfectChipInset = TokenStroke(
    width: 1.5,
    color: Color(0xFFF2C230),
  );

  /// `inset 1.5px #F2C230 + 3px rgba(245,197,24,.35) ring`.
  static const perfectChipRing = TokenStroke(
    width: 3.0,
    color: Color(0x59F5C518),
  );

  /// On open, the list scrolls so at most this many finished rows show above
  /// the current chapter card: offset = max(0, currentCardTop − listTop −
  /// min(this, finished) × [openScrollRowPitch]).
  static const openScrollFinishedRows = 2;

  /// `the current chapter card with at most two finished rows above it: offset
  /// = max(0, currentCardTop − listTop − min(2, finished) × 64)`.
  static const openScrollRowPitch = 64.0;

  /// `#F1E3CC`.
  static const lockedCellFace = Color(0xFFF1E3CC);

  /// `#B99A7A`.
  static const lockedCellNumber = Color(0xFFB99A7A);

  /// `#C4AE92`.
  static const lockedCellLock = Color(0xFFC4AE92);

  /// `inset 0 2px 4px rgba(90,45,15,0.15)`.
  static const List<NestyShadow> lockedCellShadow = [
    NestyShadow(color: Color(0x265A2D0F), inset: true, dy: 2.0, blur: 4.0),
  ];

  static const scrollFoldedAbove = 3;
}

/// tokens.json `layout.museum` (Museum (6.1, J.2)), in dp on the 390×844
/// reference unless a member says otherwise.
abstract final class MuseumTokens {
  static const introTop = 114.0;

  /// `Nunito 600 13`.
  static const introText = TextStyle(
    fontFamily: 'Nunito',
    fontSize: 13.0,
    fontWeight: FontWeight.w600,
    fontFamilyFallback: AppFontTokens.bodyFallback,
  );

  static const nextCardTop = 160.0;

  static const nextCardHeight = 150.0;

  static const nextCardRadius = 26.0;

  static const nextCardArt = Size(118.0, 132.0);

  /// The next card's name (`AppTextStyleTokens.cardTitle`) takes up to two
  /// balanced lines.
  static const nextCardNameMaxLines = 2;

  static const cabinetTop = 324.0;

  static const cabinetHeight = 402.0;

  static const cabinetColumns = 2;

  static const cabinetRows = 5;

  static const cabinetGap = 6.0;

  static const cabinetRadius = 26.0;

  static const cabinetArt = 62.0;

  static const cabinetLockedOpacity = 0.45;

  /// The name plate's text (m7-6 item 8: flat brass, 6.1c).
  static TextStyle get cabinetNamePlate => DisplayFace.of(
    const TextStyle(
      fontFamily: 'Fredoka',
      fontSize: 11.5,
      fontWeight: FontWeight.w700,
      fontFamilyFallback: AppFontTokens.displayFallback,
      color: Color(0xFF4A3008),
    ),
  );

  /// The plate's flat brass: AppColorTokens.namePlateTop → namePlateBottom, no
  /// shine and no extra saturation.
  static const cabinetNamePlateFace = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFF5D98C), Color(0xFFD9AE52)],
  );

  /// A 1 dp white top and a 2 dp AppColorTokens.namePlateEdge edge.
  static const List<NestyShadow> cabinetNamePlateShadow = [
    NestyShadow(color: Color(0x99FFFFFF), inset: true, dy: 1.0),
    NestyShadow(color: Color(0xFF8C6420), dy: 2.0),
  ];

  /// `Fredoka 700 11.5 #4A3008 on flat brass: linear-gradient(180deg,
  /// namePlateTop #F5D98C, namePlateBottom #D9AE52), inset 0 1px 0
  /// rgba(255,255,255,0.6), 0 2px 0 namePlateEdge #8C6420, radius 7, padding
  /// 3/7. No shine, no extra saturation: 6.1c is the spec (m7-6, item 8)`.
  static const cabinetNamePlateRadius = 7.0;

  /// `Fredoka 700 11.5 #4A3008 on flat brass: linear-gradient(180deg,
  /// namePlateTop #F5D98C, namePlateBottom #D9AE52), inset 0 1px 0
  /// rgba(255,255,255,0.6), 0 2px 0 namePlateEdge #8C6420, radius 7, padding
  /// 3/7. No shine, no extra saturation: 6.1c is the spec (m7-6, item 8)`.
  static const cabinetNamePlatePadding = EdgeInsets.symmetric(
    vertical: 3.0,
    horizontal: 7.0,
  );

  /// A locked figurine's two lines ("Chapter 4" / "Levels 61–80").
  static const cabinetLockedLabel = TextStyle(
    fontFamily: 'Nunito',
    fontSize: 11.0,
    fontWeight: FontWeight.w800,
    fontFamilyFallback: AppFontTokens.bodyFallback,
  );

  /// The tab screen title (`AppTextStyleTokens.screenTitle`) …
  static const titleLeft = 20.0;

  /// … at this top.
  static const titleTop = 62.0;
}

/// tokens.json `layout.records` (Records (10.6)), in dp on the 390×844
/// reference unless a member says otherwise.
abstract final class RecordsTokens {
  static const statsGridColumns = 2;

  static const statsGridGap = 10.0;

  static const statsGridCellRadius = 18.0;

  static const statsGridCellPadding = EdgeInsets.symmetric(
    vertical: 10.0,
    horizontal: 12.0,
  );

  static const statsGridCellGap = 10.0;

  static const statsGridCellIconTileSize = 36.0;

  static const statsGridCellIconTileRadius = 12.0;

  static const statsGridCellIconTileGlyph = 22.0;

  /// A stat's value, tabular figures, one line.
  static TextStyle get statsGridCellValue => DisplayFace.of(
    const TextStyle(
      fontFamily: 'Fredoka',
      fontSize: 20.0,
      fontWeight: FontWeight.w700,
      fontFamilyFallback: AppFontTokens.displayFallback,
      fontFeatures: [FontFeature.tabularFigures()],
    ),
  );

  /// `Nunito 700 11.5/1.2 #8A5B3A`.
  static const statsGridCellLabel = TextStyle(
    fontFamily: 'Nunito',
    fontSize: 11.5,
    fontWeight: FontWeight.w700,
    fontFamilyFallback: AppFontTokens.bodyFallback,
    height: 1.2,
    leadingDistribution: TextLeadingDistribution.even,
    color: Color(0xFF8A5B3A),
  );

  /// `#DDF3E2, #2F7A3E`.
  static const List<Color> statsGridCellTintsLevelsWon = [
    Color(0xFFDDF3E2),
    Color(0xFF2F7A3E),
  ];

  /// The tile's face and the doll mark's colour (`[#FFE9D2, #C4631E, doll mark
  /// 16×24]`).
  static const List<Color> statsGridCellTintsFamiliesCompleted = [
    Color(0xFFFFE9D2),
    Color(0xFFC4631E),
  ];

  /// The family counter's doll mark, not a glyph.
  static const statsGridCellTintsFamiliesCompletedMarkSize = Size(16.0, 24.0);

  /// `#F6E2C2, #6E4526`.
  static const List<Color> statsGridCellTintsDollsNested = [
    Color(0xFFF6E2C2),
    Color(0xFF6E4526),
  ];

  /// `#FFF1C9, #8C5E12`.
  static const List<Color> statsGridCellTintsDailies = [
    Color(0xFFFFF1C9),
    Color(0xFF8C5E12),
  ];

  /// `#FFE3D0, #E0632A`.
  static const List<Color> statsGridCellTintsLongestStreak = [
    Color(0xFFFFE3D0),
    Color(0xFFE0632A),
  ];

  /// The tile's face (`[#FFF6E6, star art 26]`); it shows the star art.
  static const List<Color> statsGridCellTintsStars = [Color(0xFFFFF6E6)];

  /// The star art in the tile.
  static const statsGridCellTintsStarsArtSize = 26.0;

  static const racesCardRowHeight = 56.0;

  static const racesCardPortrait = 40.0;

  static const badgeGridColumns = 3;

  static const badgeGridGap = 10.0;

  static const badgeGridArt = 56.0;

  static const badgeGridRadius = 20.0;
}

/// tokens.json `layout.rivalSelect` (9.2), in dp on the 390×844 reference
/// unless a member says otherwise.
abstract final class RivalSelectTokens {
  static const portrait = 96.0;

  static const cardRadius = 24.0;

  /// `3px #4E5FD9`.
  static const selectedRing = TokenStroke(width: 3.0, color: Color(0xFF4E5FD9));

  /// The "New" chip.
  static const newChipFill = AppGradientTokens.success;

  /// `gradient.success, Fredoka 700 12`.
  static TextStyle get newChipText => DisplayFace.of(
    const TextStyle(
      fontFamily: 'Fredoka',
      fontSize: 12.0,
      fontWeight: FontWeight.w700,
      fontFamilyFallback: AppFontTokens.displayFallback,
    ),
  );

  static const startBottom = 44.0;

  static const startHeight = 60.0;

  /// `#F3E6D2`.
  static const lockedCardFace = Color(0xFFF3E6D2);

  /// `inset 0 2px 4px rgba(90,45,15,0.15)`.
  static const List<NestyShadow> lockedCardShadow = [
    NestyShadow(color: Color(0x265A2D0F), inset: true, dy: 2.0, blur: 4.0),
  ];

  /// `inset 0 0 0 1.5px #E2CBA6`.
  static const List<NestyShadow> lockedCardRing = [
    NestyShadow(color: Color(0xFFE2CBA6), inset: true, spread: 1.5),
  ];

  /// `gradient.canvas`.
  static const lockedCardPage = AppGradientTokens.canvas;
}

/// tokens.json `layout.replayCard` (replay win (10.5, 11.4)), in dp on the
/// 390×844 reference unless a member says otherwise.
abstract final class ReplayCardTokens {
  static const movesRowTop = 420.0;

  static const cardTop = 494.0;

  static const cardLeft = 28.0;

  static const cardRight = 28.0;

  static const cardRadius = 22.0;

  /// `rgba(255,249,236,.97)`.
  static const cardFill = Color(0xF7FFF9EC);

  /// `5px #D8B07A`.
  static const cardEdge = TokenStroke(width: 5.0, color: Color(0xFFD8B07A));

  /// `Nunito 700 14 #7A5234 with the replay glyph`.
  static const reason = TextStyle(
    fontFamily: 'Nunito',
    fontSize: 14.0,
    fontWeight: FontWeight.w700,
    fontFamilyFallback: AppFontTokens.bodyFallback,
    color: Color(0xFF7A5234),
  );

  /// Under a dashed divider: an empty star, then the target.
  static const targetRowStarSize = 22.0;

  /// `dashed divider, empty star 22, Fredoka 700 15 #8C5E12`.
  static TextStyle get targetRowText => DisplayFace.of(
    const TextStyle(
      fontFamily: 'Fredoka',
      fontSize: 15.0,
      fontWeight: FontWeight.w700,
      fontFamilyFallback: AppFontTokens.displayFallback,
      color: Color(0xFF8C5E12),
    ),
  );

  static const tipTop = 612.0;

  static const buttonTop = 668.0;

  /// The card ends above the booster bar (`BoosterBarTokens.top`).
  static const bottomLimit = 734.0;
}

/// tokens.json `layout.hintMiddle` (E.20, frame 3.1b), in dp on the 390×844
/// reference unless a member says otherwise.
abstract final class HintMiddleTokens {
  /// The hint arrow over the top shelf's slot at this cx …
  static const slotCenterX = 195.0;

  /// … with its top above this y fades the family counter (3.1b).
  static const arrowTopAboveY = 150.0;

  static const familyCounterFadeOutMs = 150;

  static const familyCounterFadeInMs = 150;

  static const fadeBackAfterHintMs = 0;

  /// The hint arrow's highest bob point stays at or below this y, 4 dp under
  /// the level pill; it moves down over the doll's head if needed (m7-4 5.4).
  static const clampTop = 112.0;
}

/// tokens.json `layout.winTwinkles` (E.17: fx_twinkle above the scrim, behind
/// the ribbon), in dp on the 390×844 reference unless a member says
/// otherwise.
abstract final class WinTwinklesTokens {
  static const List<Offset> points = [
    Offset(52.0, 112.0),
    Offset(338.0, 128.0),
    Offset(292.0, 396.0),
  ];

  static const List<double> periodS = [2.0, 2.4];
}

/// tokens.json `layout.generating` (E.5), in dp on the 390×844 reference
/// unless a member says otherwise.
abstract final class GeneratingTokens {
  static const cardWidth = 236.0;

  static const cardRadius = 26.0;

  static const cardPadding = EdgeInsets.symmetric(
    vertical: 22.0,
    horizontal: 18.0,
  );

  /// `ui_spinner`, dp: its own #F2893B arc (110°) on a #EAD3B0 track, baked
  /// into the file (m7-5).
  static const spinnerSize = 44.0;

  /// `rgba(60,30,10,.28)`.
  static const dim = Color(0x473C1E0A);
}

/// tokens.json `shop` (F.1), in dp on the 390×844 reference unless a member
/// says otherwise.
abstract final class ShopTokens {
  /// `rgba(255,255,255,.22)`.
  static const buyCoinChipFace = Color(0x38FFFFFF);

  /// `gradient.coinFace`.
  static const buyCoinChipCoin = AppGradientTokens.coinFace;

  static const buyCoinChipCoinSize = 22.0;

  static const buyCoinChipRadius = 14.0;

  static const buyCoinChipPadding = EdgeInsets.fromLTRB(6.0, 6.0, 10.0, 6.0);

  /// `Fredoka 700 19 white`.
  static TextStyle get buyCoinChipText => DisplayFace.of(
    const TextStyle(
      fontFamily: 'Fredoka',
      fontSize: 19.0,
      fontWeight: FontWeight.w700,
      fontFamilyFallback: AppFontTokens.displayFallback,
      color: Color(0xFFFFFFFF),
    ),
  );

  /// `inset 0 2px 0 rgba(255,255,255,.6)`.
  static const List<NestyShadow> detailPanelHighlight = [
    NestyShadow(color: Color(0x99FFFFFF), inset: true, dy: 2.0),
  ];

  static const detailPanelEdgeWidth = 6.0;

  static const detailPanelRadius = 26.0;

  /// The detail panel's tag chip.
  static const detailPanelTagFill = Color(0xD9FFFFFF);

  /// `rgba(255,255,255,.85) chip, Fredoka 700 12`.
  static TextStyle get detailPanelTagText => DisplayFace.of(
    const TextStyle(
      fontFamily: 'Fredoka',
      fontSize: 12.0,
      fontWeight: FontWeight.w700,
      fontFamilyFallback: AppFontTokens.displayFallback,
    ),
  );

  /// `Fredoka 700 16/1.1, one line`.
  static TextStyle get cardNameSkin => DisplayFace.of(
    const TextStyle(
      fontFamily: 'Fredoka',
      fontSize: 16.0,
      fontWeight: FontWeight.w700,
      fontFamilyFallback: AppFontTokens.displayFallback,
      height: 1.1,
      leadingDistribution: TextLeadingDistribution.even,
    ),
  );

  /// `Fredoka 700 14/1.15, one line, ellipsis`.
  static TextStyle get cardNameTheme => DisplayFace.of(
    const TextStyle(
      fontFamily: 'Fredoka',
      fontSize: 14.0,
      fontWeight: FontWeight.w700,
      fontFamilyFallback: AppFontTokens.displayFallback,
      height: 1.15,
      leadingDistribution: TextLeadingDistribution.even,
    ),
  );

  /// Each skin's Shop card and detail panel colours, by catalog skin id
  /// (tokens.json `shop.skins`).
  static const Map<String, ShopSkinColors> skins = {
    'classic': ShopSkinColors(
      card: [Color(0xFFFCEBCB), Color(0xFFF3D4A0)],
      panel: [Color(0xFFFCEBCB), Color(0xFFF3D4A0)],
      edge: Color(0xFFD8B07A),
      caption: Color(0xFF7A4A1E),
    ),
    'space': ShopSkinColors(
      card: [Color(0xFF3B3470), Color(0xFF232650)],
      panel: [Color(0xFF3B3470), Color(0xFF232650)],
      edge: Color(0xFF15163A),
      caption: Color(0xFFE6E3FF),
    ),
    'ocean': ShopSkinColors(
      card: [Color(0xFFDDF2F6), Color(0xFFA9D8E4)],
      panel: [Color(0xFFDDF2F6), Color(0xFFA9D8E4)],
      edge: Color(0xFF7FB6C6),
      caption: Color(0xFF1F5E6E),
    ),
    'sweets': ShopSkinColors(
      card: [Color(0xFFFFE6EF), Color(0xFFF9C6D8)],
      panel: [Color(0xFFFFE6EF), Color(0xFFF9C6D8)],
      edge: Color(0xFFE29DB6),
      caption: Color(0xFF8A2E55),
    ),
    'forest': ShopSkinColors(
      card: [Color(0xFFE3F1D4), Color(0xFFC4DFAA)],
      panel: [Color(0xFFE3F1D4), Color(0xFFC4DFAA)],
      edge: Color(0xFF93BF76),
      caption: Color(0xFF2F5A1E),
    ),
    'forest-bear': ShopSkinColors(
      card: [Color(0xFFF3E6D0), Color(0xFFDCC39D)],
      panel: [Color(0xFFF3E6D0), Color(0xFFDCC39D)],
      edge: Color(0xFFB89868),
      caption: Color(0xFF6B4A22),
    ),
    'winter': ShopSkinColors(
      card: [Color(0xFFEEF4FA), Color(0xFFD3E2F0)],
      panel: [Color(0xFFEEF4FA), Color(0xFFD3E2F0)],
      edge: Color(0xFFA6BFD8),
      caption: Color(0xFF2B4E73),
    ),
  };

  /// The caption chip of a skin whose caption would not read on its card (m7-4
  /// 4.11: Space's white chip), by catalog skin id; other skins keep the
  /// caption colour.
  static const Map<String, ({Color face, Color text})> skinTags = {
    'space': (face: Color(0xEBFFFFFF), text: Color(0xFF2A2766)),
  };
}

/// tokens.json `chestModal` (F.2, the day-7 and milestone chest cards), in dp
/// on the 390×844 reference unless a member says otherwise.
abstract final class ChestModalTokens {
  /// A lit ray.
  static const glowRayColor = Color(0x8CFFC85A);

  /// Each ray's width, degrees …
  static const glowRayLitDeg = 9.0;

  /// … of every this many (`repeating-conic-gradient(rgba(255,200,90,.55) 0deg
  /// 9deg, rgba(255,200,90,0) 9deg 24deg)`).
  static const glowRayPeriodDeg = 24.0;

  static const glowSize = 270.0;

  /// The rays' radial mask: solid to this fraction of the radius …
  static const glowMaskSolid = 0.2;

  /// … and clear from this one.
  static const glowMaskClear = 0.68;

  /// `inset 0 2px 0 #FFFFFF, 0 7px 0 #D8B07A, 0 24px 48px rgba(60,25,5,.35)`.
  static const List<NestyShadow> shadow = [
    NestyShadow(color: Color(0xFFFFFFFF), inset: true, dy: 2.0),
    NestyShadow(color: Color(0xFFD8B07A), dy: 7.0),
    NestyShadow(color: Color(0x593C1905), dy: 24.0, blur: 48.0),
  ];

  static const radius = 32.0;
}

/// tokens.json `settings` (F.3), in dp on the 390×844 reference unless a
/// member says otherwise.
abstract final class SettingsTokens {
  static const colorSymbolCardsRadius = 18.0;

  /// `#FFF1E4`.
  static const colorSymbolCardsSelectedFace = Color(0xFFFFF1E4);

  /// `inset 0 0 0 3px #F2893B`.
  static const List<NestyShadow> colorSymbolCardsSelectedRing = [
    NestyShadow(color: Color(0xFFF2893B), inset: true, spread: 3.0),
  ];

  /// `#FFFDF7`.
  static const colorSymbolCardsIdleFace = Color(0xFFFFFDF7);

  /// `inset 0 0 0 2px #E2C9A3`.
  static const List<NestyShadow> colorSymbolCardsIdleRing = [
    NestyShadow(color: Color(0xFFE2C9A3), inset: true, spread: 2.0),
  ];

  static const reduceMotionControlHeight = 48.0;
}

/// tokens.json `textLink` (F.4; m7-4: 48 dp hit box (the game rule), the look
/// is unchanged), in dp on the 390×844 reference unless a member says
/// otherwise.
abstract final class TextLinkTokens {
  /// `Fredoka 700 16`.
  static TextStyle get font => DisplayFace.of(
    const TextStyle(
      fontFamily: 'Fredoka',
      fontSize: 16.0,
      fontWeight: FontWeight.w700,
      fontFamilyFallback: AppFontTokens.displayFallback,
    ),
  );

  /// `#8A5B3A`.
  static const color = Color(0xFF8A5B3A);

  /// `#6E4526`.
  static const pressed = Color(0xFF6E4526);

  static const underline = false;

  static const minTapHeight = 48.0;

  /// `#C4631E`.
  static const accentColor = Color(0xFFC4631E);

  /// `#A94F12`.
  static const accentPressed = Color(0xFFA94F12);
}

/// tokens.json `layout.splash`, in dp on the 390×844 reference unless a
/// member says otherwise.
abstract final class SplashTokens {
  /// The splash's top fade (m7-5 item 11): solid to 120 dp, clear at 240 dp,
  /// over the theme art. Call `resolve(topFadeHeight)`.
  static const topFadeFill = PxLinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFFBEAD0), Color(0xFFFBEAD0), Color(0x00FBEAD0)],
    stops: [TokenStop.px(0.0), TokenStop.px(120.0), TokenStop.px(240.0)],
  );

  /// The fade's box, from the screen top, dp.
  static const topFadeHeight = 240.0;
}

/// tokens.json `chest.slotChip`, in dp on the 390×844 reference unless a
/// member says otherwise.
abstract final class ChestSlotChipTokens {
  /// The chip's disc, `ui/chest/chip_slot.svg` (`UiArt`), dp.
  static const discSize = 30.0;

  /// `linear-gradient(180deg,#6CC07C,#46A758)`.
  static const face = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF6CC07C), Color(0xFF46A758)],
  );

  /// `inset 0 -2px 0 #2F7A3E`.
  static const List<NestyShadow> edge = [
    NestyShadow(color: Color(0xFF2F7A3E), inset: true, dy: -2.0),
  ];

  /// The add box in the disc (drawn in chip_slot.svg): a rounded square …
  static const glyphColor = Color(0xFFFFFFFF);

  /// … dp …
  static const glyphSize = 15.0;

  /// … with this corner radius …
  static const glyphRadius = 4.2;

  /// … and a plus in this colour.
  static const glyphPlusColor = Color(0xFF46A758);
}

/// tokens.json `gift.button`, in dp on the 390×844 reference unless a member
/// says otherwise.
abstract final class GiftButtonTokens {
  static const size = 46.0;

  static const touch = 48.0;

  static const gapToGear = 6.0;

  static const radius = 17.0;

  /// `linear-gradient(180deg,#FFF9EE,#FCEBD0)`.
  static const face = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFFFF9EE), Color(0xFFFCEBD0)],
  );

  /// `inset 0 2px 0 #FFFFFF, 0 5px 0 #D8B07A, 0 9px 14px rgba(90,50,20,0.22)`.
  static const List<NestyShadow> shadow = [
    NestyShadow(color: Color(0xFFFFFFFF), inset: true, dy: 2.0),
    NestyShadow(color: Color(0xFFD8B07A), dy: 5.0),
    NestyShadow(color: Color(0x385A3214), dy: 9.0, blur: 14.0),
  ];

  static const glyphSize = 28.0;

  static const readyDotSize = 12.0;

  /// `radial-gradient(circle at 35% 30%, #FFF3B0, #F5C518 55%, #C9960A)`.
  static const readyDotFace = RadialGradient(
    center: Alignment(-0.3, -0.4),
    radius: 0.9552,
    colors: [Color(0xFFFFF3B0), Color(0xFFF5C518), Color(0xFFC9960A)],
    stops: [0.0, 0.55, 1.0],
  );

  /// `2.5px #FFFDF7`.
  static const readyDotRing = TokenStroke(width: 2.5, color: Color(0xFFFFFDF7));

  /// `0 2px 3px rgba(90,50,20,0.3)`.
  static const List<NestyShadow> readyDotShadow = [
    NestyShadow(color: Color(0x4D5A3214), dy: 2.0, blur: 3.0),
  ];

  static const readyDotOffsetTop = -3.0;

  static const readyDotOffsetRight = -3.0;
}

/// tokens.json `gift.sheet`, in dp on the 390×844 reference unless a member
/// says otherwise.
abstract final class GiftSheetTokens {
  static const radius = 34.0;

  /// `linear-gradient(180deg,#FFF9EE,#FCEBD0)`.
  static const face = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFFFF9EE), Color(0xFFFCEBD0)],
  );

  /// `inset 0 2px 0 #FFFFFF, 0 -10px 30px rgba(60,25,5,0.3)`.
  static const List<NestyShadow> shadow = [
    NestyShadow(color: Color(0xFFFFFFFF), inset: true, dy: 2.0),
    NestyShadow(color: Color(0x4D3C1905), dy: -10.0, blur: 30.0),
  ];

  static const padding = EdgeInsets.fromLTRB(20.0, 14.0, 20.0, 40.0);

  static const grabberSize = Size(44.0, 5.0);

  /// `rgba(110,70,40,0.25)`.
  static const grabberColor = Color(0x406E4628);

  static const titleGap = 18.0;

  static const titleHeight = 33.0;

  static const subGap = 4.0;

  static const subHeight = 20.0;

  static const gridGap = 16.0;

  static const gridColumns = 3;

  static const gridTileGap = 10.0;

  static const gridTileHeight = 100.0;

  static const day7GapAbove = 10.0;

  static const day7Height = 112.0;

  static const day7Radius = 24.0;

  static const day7Padding = EdgeInsets.fromLTRB(8.0, 8.0, 14.0, 8.0);

  static const day7Chest = Size(108.0, 90.0);

  static const day7ChipsHeight = 32.0;

  static const day7ChipsRadius = 16.0;

  /// `#FFFDF7`.
  static const day7ChipsFace = Color(0xFFFFFDF7);

  /// `inset 0 0 0 1.5px #EAD3B0`.
  static const List<NestyShadow> day7ChipsRing = [
    NestyShadow(color: Color(0xFFEAD3B0), inset: true, spread: 1.5),
  ];

  static const day7ChipsIcon = 24.0;

  static const day7ChipsGap = 6.0;

  static const footerGap = 16.0;

  static const footerHeight = 58.0;

  /// Claim and the claimed line cross-fade over this; the footer keeps
  /// [footerHeight], so nothing moves.
  static const footerSwapMs = 200;

  /// The `scrim` colour (`rgba(60,30,10,0.55)`).
  static const Color scrim = AppColorTokens.scrim;

  /// The sheet's height on the 390×844 reference (from its content), for the
  /// layout tests; its top is 288.
  static const height = 556.0;
}

/// tokens.json `gift.tile`, in dp on the 390×844 reference unless a member
/// says otherwise.
abstract final class GiftTileTokens {
  static const radius = 22.0;

  static const padding = EdgeInsets.fromLTRB(12.0, 11.0, 12.0, 10.0);

  static const art = 34.0;

  static const artGap = 5.0;

  /// `#FCEBD0`.
  static const doneFace = Color(0xFFFCEBD0);

  /// `inset 0 2px 4px rgba(90,45,15,0.14)`.
  static const List<NestyShadow> doneShadow = [
    NestyShadow(color: Color(0x245A2D0F), inset: true, dy: 2.0, blur: 4.0),
  ];

  /// `#9A6A44`.
  static const doneLabel = Color(0xFF9A6A44);

  static const doneContentOpacity = 0.5;

  static const doneCheckSize = 22.0;

  /// `#46A758`.
  static const doneCheckFace = Color(0xFF46A758);

  /// `inset 0 -2px 0 #2F7A3E`.
  static const List<NestyShadow> doneCheckEdge = [
    NestyShadow(color: Color(0xFF2F7A3E), inset: true, dy: -2.0),
  ];

  /// The done tile's check: the `check` glyph (`NestyIcons`) …
  static const doneCheckGlyph = 'check';

  /// `check 16 #FFFFFF wght 600 (the bundled static cut; m7-6, item 6)`.
  static const doneCheckGlyphSize = 16.0;

  /// `check 16 #FFFFFF wght 600 (the bundled static cut; m7-6, item 6)`.
  static const doneCheckGlyphColor = Color(0xFFFFFFFF);

  /// The design draws it at this weight; the bundled icon font is cut at
  /// AppFontTokens.iconWeight.
  static const doneCheckGlyphWeight = 600.0;

  static const doneCheckTop = 7.0;

  static const doneCheckRight = 8.0;

  /// `#FFFDF7`.
  static const todayFace = Color(0xFFFFFDF7);

  /// `inset 0 2px 0 #FFFFFF, 0 0 0 3px #F2893B, 0 4px 0 3px #C4631E, 0 0 0 9px
  /// rgba(242,137,59,0.16)`.
  static const List<NestyShadow> todayShadow = [
    NestyShadow(color: Color(0xFFFFFFFF), inset: true, dy: 2.0),
    NestyShadow(color: Color(0xFFF2893B), spread: 3.0),
    NestyShadow(color: Color(0xFFC4631E), dy: 4.0, spread: 3.0),
    NestyShadow(color: Color(0x29F2893B), spread: 9.0),
  ];

  /// `#C4631E`.
  static const todayLabel = Color(0xFFC4631E);

  static const todayLift = -2.0;

  /// `#FFFDF7`.
  static const laterFace = Color(0xFFFFFDF7);

  /// `inset 0 2px 0 #FFFFFF, 0 5px 0 #D8B07A`.
  static const List<NestyShadow> laterShadow = [
    NestyShadow(color: Color(0xFFFFFFFF), inset: true, dy: 2.0),
    NestyShadow(color: Color(0xFFD8B07A), dy: 5.0),
  ];

  /// `#8A5B3A`.
  static const laterLabel = Color(0xFF8A5B3A);

  static const laterContentOpacity = 1.0;
}

/// tokens.json `gift.tally`, in dp on the 390×844 reference unless a member
/// says otherwise.
abstract final class GiftTallyTokens {
  static const left = 16.0;

  /// The tally's top is the coin pill's top + this …
  static const topBelowCoinPill = 54.0;

  /// … on 844 …
  static const top = 120.0;

  /// … and on 16:9.
  static const topShort = 82.0;

  static const height = 36.0;

  static const radius = 18.0;

  static const padding = EdgeInsets.fromLTRB(5.0, 0.0, 13.0, 0.0);

  static const gap = 7.0;

  static const disc = 26.0;

  /// `linear-gradient(180deg,#FFF9EE,#FCEBD0)`.
  static const face = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFFFF9EE), Color(0xFFFCEBD0)],
  );

  /// `inset 0 2px 0 #FFFFFF, 0 4px 0 #D8B07A, 0 8px 14px rgba(60,25,5,0.25)`.
  static const List<NestyShadow> shadow = [
    NestyShadow(color: Color(0xFFFFFFFF), inset: true, dy: 2.0),
    NestyShadow(color: Color(0xFFD8B07A), dy: 4.0),
    NestyShadow(color: Color(0x403C1905), dy: 8.0, blur: 14.0),
  ];

  /// The hint disc, as the chest's hint chip draws it: its face …
  static const discsHintFace = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFFFE7A0), Color(0xFFF5C518)],
  );

  /// … its edge …
  static const List<NestyShadow> discsHintEdge = [
    NestyShadow(color: Color(0xFFC9960A), inset: true, dy: -2.0),
  ];

  /// … and the `lightbulb` glyph (`NestyIcons`) …
  static const discsHintGlyph = 'lightbulb';

  /// `the chest’s hint chip disc: linear-gradient(180deg,#FFE7A0,#F5C518),
  /// inset 0 -2px 0 #C9960A, lightbulb 17 #8C5E12`.
  static const discsHintGlyphSize = 17.0;

  /// `the chest’s hint chip disc: linear-gradient(180deg,#FFE7A0,#F5C518),
  /// inset 0 -2px 0 #C9960A, lightbulb 17 #8C5E12`.
  static const discsHintGlyphColor = Color(0xFF8C5E12);

  /// The tally slides down from behind the coin pill as the sprite takes off …
  static const inMs = 200;

  /// … so.
  static const Cubic inCurve = UiMotionTokens.curveEaseOut;

  static const holdMs = 1200;

  /// After [holdMs] the tally slides back up …
  static const outMs = 200;

  /// … so.
  static const Cubic outCurve = UiMotionTokens.curveEaseIn;
}

/// tokens.json `gift.claim`, in dp on the 390×844 reference unless a member
/// says otherwise.
abstract final class GiftClaimTokens {
  /// Today's tile sinks to done over this, and its check pops with
  /// MotionTokens.tagPop*.
  static const tileSinkMs = 160;

  /// A coin day flies one coin sprite per this many coins, clamped to
  /// [coinsSpritesMin]…[coinsSpritesMax] (a look, not the reward: the amounts
  /// are the track's).
  static const coinsSpriteEvery = 10;

  /// `one per 10 coins, 2 to 6 (20 → 2, 40 → 4, 100 → 6)`.
  static const coinsSpritesMin = 2;

  /// `one per 10 coins, 2 to 6 (20 → 2, 40 → 4, 100 → 6)`.
  static const coinsSpritesMax = 6;

  static const coinsMs = 700;

  static const coinsStaggerMs = 60;

  /// The coins fly a quadratic path; from a row-2 tile on 844 its control point
  /// is here.
  static const coinsPathControl = Offset(175.0, 300.0);

  /// For the flight the scrim opens a hole this big around the coin pill (which
  /// glows with ChestCollectTokens.pillRing* and steps its count up per
  /// landing) …
  static const coinsPillHole = Size(122.0, 54.0);

  /// … with this radius …
  static const coinsPillHoleRadius = 27.0;

  /// … and closes this long after the last coin lands.
  static const coinsPillHoleCloseMs = 240;

  /// `ui/sprites/hint_flight.svg` (`UiArt`) at this size, dp.
  static const hintSpriteSize = 40.0;

  static const hintMs = 650;

  /// As a hint (or a slot) lands the tally's disc bumps to this scale (the
  /// chest's targetBump) with ChestCollectTokens.hintRing*, and the gain tag
  /// sits beside the tally …
  static const hintLandBump = 1.3;

  /// … over this.
  static const hintLandBumpMs = 240;

  /// `ui/sprites/slot_flight.svg` (`UiArt`) at this size, dp.
  static const slotSpriteSize = 40.0;

  static const slotMs = 650;

  /// Day 7: Claim closes the sheet over this and opens the chest card
  /// (ChestCardTokens.cardTopDay7, ui_chest's arrive); Collect works as 10.3d
  /// (ChestCollectTokens) …
  static const day7SheetCloseMs = 280;

  /// … with the scrim dropped to this while 6 coins fly to the pill and the
  /// slot to the tally.
  static const day7CollectScrim = Color(0x2E3C1E0A);
}

/// tokens.json `gift.reducedMotion`, in dp on the 390×844 reference unless a
/// member says otherwise.
abstract final class GiftReducedMotionTokens {
  /// Reduce motion: no flights and no trail; the tile and Claim cross-fade over
  /// this …
  static const claimCrossFadeMs = 200;

  /// … the pill shows the new count at once, ringed for this …
  static const claimPillRingMs = 400;

  /// … and the tally fades in over this, holds GiftTallyTokens.holdMs and fades
  /// out.
  static const claimTallyFadeInMs = 150;
}

/// tokens.json `gift.short` (16:9 (390×693), 13.3b), in dp on the 390×693
/// (16:9) reference unless a member says otherwise.
abstract final class GiftShortTokens {
  static const padding = EdgeInsets.fromLTRB(20.0, 12.0, 20.0, 20.0);

  static const titleGap = 12.0;

  static const titleHeight = 29.0;

  static const titleSize = 26.0;

  static const subGap = 2.0;

  static const subHeight = 19.0;

  static const subSize = 14.0;

  static const gridGap = 12.0;

  static const gridTileGap = 8.0;

  static const gridTileHeight = 86.0;

  static const art = 30.0;

  static const amount = 22.0;

  static const day7Height = 96.0;

  static const day7Chest = Size(92.0, 77.0);

  static const footerGap = 12.0;

  static const footerHeight = 58.0;

  /// The sheet's height on 16:9 (from its content), for the layout tests; its
  /// top is 228.
  static const height = 465.0;
}

/// tokens.json `versus.computerTag`, in dp on the 390×844 reference unless a
/// member says otherwise.
abstract final class ComputerTagTokens {
  static const height = 20.0;

  static const radius = 10.0;

  /// The `computer` glyph's size at 1× text, dp (`14`).
  static const glyphSize = 14.0;

  /// `Nunito 800 11 #6E4526`.
  static const text = TextStyle(
    fontFamily: 'Nunito',
    fontSize: 11.0,
    fontWeight: FontWeight.w800,
    fontFamilyFallback: AppFontTokens.bodyFallback,
    color: Color(0xFF6E4526),
  );

  /// The tag's face …
  static const face = Color(0xFFFFFDF7);

  /// … and its ring.
  static const ring = TokenStroke(width: 1.5, color: Color(0xFFD8B07A));

  /// Every rival surface's tag scales its height, glyph, text and radius with
  /// the text scale k, up to this (m7-6 item 2); where a surface can't grow it
  /// drops to its glyph first (TextFitTokens.rivalNames*).
  static const maxTextScale = 1.3;
}

/// tokens.json `habits.welcomeBack`, in dp on the 390×844 reference unless a
/// member says otherwise.
abstract final class HabitsWelcomeTokens {
  /// The card sits under the chapter card, this far from each side …
  static const placeSide = 16.0;

  /// … its top this far below the chapter card's top
  /// (HomeTokens.chapterCardTop, HomeShortTokens.chapterCard; checked against
  /// [placeH844Top] and [placeH693Top]).
  static const placeBelowChapterCardTop = 74.0;

  /// The five dolls scale about the plank centre so the tallest clears the
  /// card's bottom edge by this at the top of its bob …
  static const placeDollClearance = 8.0;

  /// … and below this scale they fade out; the empty plank stays.
  static const placeDollFadeBelow = 0.6;

  static const placeH844Top = 198.0;

  static const placeH844DollScale = 0.78;

  static const placeH693Top = 158.0;

  static const cardMinHeight = 84.0;

  static const cardRadius = 24.0;

  static const cardPadding = EdgeInsets.fromLTRB(12.0, 12.0, 12.0, 12.0);

  static const cardGap = 12.0;

  /// `linear-gradient(180deg,#FFF9EE,#FCEBD0)`.
  static const cardFace = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFFFF9EE), Color(0xFFFCEBD0)],
  );

  /// `inset 0 2px 0 #FFFFFF, 0 5px 0 #D8B07A, 0 10px 18px rgba(90,50,20,0.22)`.
  static const List<NestyShadow> cardShadow = [
    NestyShadow(color: Color(0xFFFFFFFF), inset: true, dy: 2.0),
    NestyShadow(color: Color(0xFFD8B07A), dy: 5.0),
    NestyShadow(color: Color(0x385A3214), dy: 10.0, blur: 18.0),
  ];

  static const discSize = 48.0;

  /// `linear-gradient(180deg,#FFB27A,#F2702B)`.
  static const discFreezeFace = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFFFB27A), Color(0xFFF2702B)],
  );

  /// `0 3px 0 #B8501A`.
  static const List<NestyShadow> discFreezeEdge = [
    NestyShadow(color: Color(0xFFB8501A), dy: 3.0),
  ];

  /// The `local_fire_department` glyph (`NestyIcons`); tools/test/tokens checks
  /// the bundled icon font has it …
  static const discFreezeGlyph = 'local_fire_department';

  /// … dp …
  static const discFreezeGlyphSize = 30.0;

  /// … in this colour.
  static const discFreezeGlyphColor = Color(0xFFFFF6E6);

  /// The freeze badge on the disc: a disc this big …
  static const discFreezeBadgeSize = 22.0;

  /// … in this colour …
  static const discFreezeBadgeFace = Color(0xFFDCEFFF);

  /// … ringed and edged so …
  static const List<NestyShadow> discFreezeBadgeShadow = [
    NestyShadow(color: Color(0xFFFFF9EE), spread: 2.0),
    NestyShadow(color: Color(0xFF9CC4EA), dy: 2.0, spread: 2.0),
  ];

  /// … with the `ac_unit` glyph (`NestyIcons`) …
  static const discFreezeBadgeGlyph = 'ac_unit';

  /// `22 dp #DCEFFF disc, ring 0 0 0 2px #FFF9EE, edge 0 2px 0 2px #9CC4EA,
  /// ac_unit 15 #3E8EDE, at right −6 / bottom −5`.
  static const discFreezeBadgeGlyphSize = 15.0;

  /// `22 dp #DCEFFF disc, ring 0 0 0 2px #FFF9EE, edge 0 2px 0 2px #9CC4EA,
  /// ac_unit 15 #3E8EDE, at right −6 / bottom −5`.
  static const discFreezeBadgeGlyphColor = Color(0xFF3E8EDE);

  /// The badge's right edge from the disc's (negative: outside) …
  static const discFreezeBadgeRight = -6.0;

  /// … and its bottom edge from the disc's.
  static const discFreezeBadgeBottom = -5.0;

  /// `linear-gradient(180deg,#F1E3CC,#DCC6A4)`.
  static const discPausedFace = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFF1E3CC), Color(0xFFDCC6A4)],
  );

  /// `0 3px 0 #B99A7A`.
  static const List<NestyShadow> discPausedEdge = [
    NestyShadow(color: Color(0xFFB99A7A), dy: 3.0),
  ];

  /// The `local_fire_department` glyph (`NestyIcons`); tools/test/tokens checks
  /// the bundled icon font has it …
  static const discPausedGlyph = 'local_fire_department';

  /// … dp …
  static const discPausedGlyphSize = 30.0;

  /// … in this colour.
  static const discPausedGlyphColor = Color(0xFF9A6A44);

  /// `linear-gradient(180deg,#FFE7A0,#F5C518)`.
  static const discNewFace = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFFFE7A0), Color(0xFFF5C518)],
  );

  static const discNewRadius = 15.0;

  /// `inset 0 2px 0 rgba(255,255,255,0.6), 0 3px 0 #C9960A`.
  static const List<NestyShadow> discNewEdge = [
    NestyShadow(color: Color(0x99FFFFFF), inset: true, dy: 2.0),
    NestyShadow(color: Color(0xFFC9960A), dy: 3.0),
  ];

  /// The `extension` glyph (`NestyIcons`), the Daily Puzzle tile;
  /// tools/test/tokens checks the bundled icon font has it …
  static const discNewGlyph = 'extension';

  /// … dp …
  static const discNewGlyphSize = 28.0;

  /// … in this colour.
  static const discNewGlyphColor = Color(0xFF8C5E12);

  /// `Fredoka 700 17/1.1 #5B3A21`.
  static TextStyle get title => DisplayFace.of(
    const TextStyle(
      fontFamily: 'Fredoka',
      fontSize: 17.0,
      fontWeight: FontWeight.w700,
      fontFamilyFallback: AppFontTokens.displayFallback,
      height: 1.1,
      leadingDistribution: TextLeadingDistribution.even,
      color: Color(0xFF5B3A21),
    ),
  );

  /// The body: two lines, then the short form
  /// (TextFitTokens.habitsWelcomeBodyMaxLines).
  static const body = TextStyle(
    fontFamily: 'Nunito',
    fontSize: 13.0,
    fontWeight: FontWeight.w700,
    fontFamilyFallback: AppFontTokens.bodyFallback,
    height: 1.3,
    leadingDistribution: TextLeadingDistribution.even,
    color: Color(0xFF7A5234),
  );

  static const playHeight = 34.0;

  static const playRadius = 13.0;

  static const playPadding = EdgeInsets.fromLTRB(11.0, 0.0, 14.0, 0.0);

  static const playGap = 7.0;

  /// `gradient.primary`.
  static const playFace = AppGradientTokens.primary;

  /// `inset 0 2px 0 rgba(255,255,255,0.35), 0 4px 0 #C4631E`.
  static const List<NestyShadow> playEdge = [
    NestyShadow(color: Color(0x59FFFFFF), inset: true, dy: 2.0),
    NestyShadow(color: Color(0xFFC4631E), dy: 4.0),
  ];

  /// `Fredoka 700 16 #FFFFFF, text-shadow 0 2px 0 rgba(150,60,10,0.3)`.
  static TextStyle get playLabel => DisplayFace.of(
    const TextStyle(
      fontFamily: 'Fredoka',
      fontSize: 16.0,
      fontWeight: FontWeight.w700,
      fontFamilyFallback: AppFontTokens.displayFallback,
      color: Color(0xFFFFFFFF),
      shadows: [Shadow(color: Color(0x4D963C0A), offset: Offset(0.0, 2.0))],
    ),
  );

  /// The Play pill's triangle …
  static const playTriangle = Size(10.0, 13.0);

  /// … in this colour.
  static const playTriangleColor = Color(0xFFFFFFFF);

  /// The Play pill sits this far from the card's bottom …
  static const playBottom = 12.0;

  /// … and right; the text keeps clear of it.
  static const playRight = 12.0;

  /// From TextFitTokens.habitsWelcomePlayUnderAtTextScale, or with a short
  /// body, the pill moves under the text, right-aligned, this far below.
  static const playUnderGap = 8.0;

  /// The close button's disc, dp (`28`).
  static const dismissFaceSize = 28.0;

  static const dismissTarget = 48.0;

  /// The close disc sits this far from the card's top …
  static const dismissTop = 6.0;

  /// … and right; its [dismissTarget] is centred on the disc.
  static const dismissRight = 6.0;

  /// `#F6E2C2`.
  static const dismissColor = Color(0xFFF6E2C2);

  /// `inset 0 -2px 0 rgba(150,100,50,0.25)`.
  static const List<NestyShadow> dismissShade = [
    NestyShadow(color: Color(0x40966432), inset: true, dy: -2.0),
  ];

  /// The `close` glyph (`NestyIcons`); tools/test/tokens checks the bundled
  /// icon font has it …
  static const dismissGlyph = 'close';

  /// … dp …
  static const dismissGlyphSize = 18.0;

  /// … in this colour.
  static const dismissGlyphColor = Color(0xFF8A5B3A);

  /// The design draws it at this weight; the bundled icon font is a static cut
  /// at AppFontTokens.iconWeight.
  static const dismissGlyphWeight = 700.0;

  /// With Home's first frame (never later, never on its own) the card fades in
  /// and rises from this far down …
  static const motionInRise = 12.0;

  /// … over this …
  static const motionInMs = 280;

  /// … so; the dolls are drawn at their scale from the start.
  static const Cubic motionInCurve = UiMotionTokens.curveEaseOut;

  /// On the close the card fades out and shrinks to this …
  static const motionOutScale = 0.96;

  /// … over this …
  static const motionOutMs = 180;

  /// `on the close: opacity 1 → 0 and scale 1 → 0.96, 180 ms easeIn; then the
  /// dolls grow back to 1 in 280 ms (easeOutBack), or fade in over 200 ms where
  /// they had faded out`.
  static const Cubic motionOutCurve = UiMotionTokens.curveEaseIn;

  /// Then the dolls grow back to 1 over this …
  static const motionDollsGrowMs = 280;

  /// `on the close: opacity 1 → 0 and scale 1 → 0.96, 180 ms easeIn; then the
  /// dolls grow back to 1 in 280 ms (easeOutBack), or fade in over 200 ms where
  /// they had faded out`.
  static const Cubic motionDollsGrowCurve = UiMotionTokens.curveEaseOutBack;

  /// … or fade in over this where they had faded out.
  static const motionDollsFadeInMs = 200;

  /// Reduce motion: a fade in.
  static const reducedMotionInMs = 200;

  /// Reduce motion: a fade out …
  static const reducedMotionOutMs = 150;

  /// … then the dolls cross-fade to full size over this.
  static const reducedMotionDollsMs = 200;
}

/// tokens.json `habits.month`, in dp on the 390×844 reference unless a member
/// says otherwise.
abstract final class HabitsMonthTokens {
  /// The month is the last card of the Daily's scroll; on open its top is here
  /// (its title peeks under Play) …
  static const top = 728.0;

  /// … this far under today's puzzle card …
  static const gapBelowPuzzleCard = 12.0;

  /// … and here on 16:9.
  static const topShort = 690.0;

  /// Once scrolled, the screen header keeps the canvas behind it with a fade
  /// this tall …
  static const headerFade = 16.0;

  /// … ending this far down …
  static const headerFadeTo = 128.0;

  /// … (this on 16:9).
  static const headerFadeToShort = 94.0;

  static const cardLeft = 16.0;

  static const cardRight = 16.0;

  static const cardRadius = 26.0;

  /// `linear-gradient(180deg,#FFF9EE,#FCEBD0)`.
  static const cardFace = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFFFF9EE), Color(0xFFFCEBD0)],
  );

  /// `inset 0 2px 0 #FFFFFF, 0 6px 0 #D8B07A`.
  static const List<NestyShadow> cardShadow = [
    NestyShadow(color: Color(0xFFFFFFFF), inset: true, dy: 2.0),
    NestyShadow(color: Color(0xFFD8B07A), dy: 6.0),
  ];

  static const cardPadding = EdgeInsets.fromLTRB(10.0, 14.0, 10.0, 14.0);

  static const headerHeight = 30.0;

  static const headerInset = 6.0;

  /// The month's name, first letter capitalised …
  static TextStyle get headerTitle => DisplayFace.of(
    const TextStyle(
      fontFamily: 'Fredoka',
      fontSize: 20.0,
      fontWeight: FontWeight.w700,
      fontFamilyFallback: AppFontTokens.displayFallback,
      color: Color(0xFF5B3A21),
    ),
  );

  /// … the stand-alone month name (intl skeleton).
  static const headerTitleDateSkeleton = 'LLLL';

  static const headerChipHeight = 30.0;

  static const headerChipTarget = 48.0;

  static const headerChipRadius = 15.0;

  static const headerChipPadding = EdgeInsets.fromLTRB(4.0, 0.0, 12.0, 0.0);

  /// `#FFFDF7`.
  static const headerChipFace = Color(0xFFFFFDF7);

  /// `inset 0 2px 0 #FFFFFF, 0 3px 0 #D8B07A`.
  static const List<NestyShadow> headerChipShadow = [
    NestyShadow(color: Color(0xFFFFFFFF), inset: true, dy: 2.0),
    NestyShadow(color: Color(0xFFD8B07A), dy: 3.0),
  ];

  /// `Fredoka 700 14 #6E4526`.
  static TextStyle get headerChipLabel => DisplayFace.of(
    const TextStyle(
      fontFamily: 'Fredoka',
      fontSize: 14.0,
      fontWeight: FontWeight.w700,
      fontFamilyFallback: AppFontTokens.displayFallback,
      color: Color(0xFF6E4526),
    ),
  );

  /// The ‹ chip's `chevron_left` glyph (`NestyIcons`) …
  static const headerChipGlyphPrevious = 'chevron_left';

  /// … the › chip's `chevron_right` …
  static const headerChipGlyphNext = 'chevron_right';

  /// … at this size, dp.
  static const headerChipGlyphSize = 22.0;

  static const hintGap = 4.0;

  static const hintHeight = 17.0;

  /// `Nunito 700 13/17 #8A5B3A`.
  static const hintFont = TextStyle(
    fontFamily: 'Nunito',
    fontSize: 13.0,
    fontWeight: FontWeight.w700,
    fontFamilyFallback: AppFontTokens.bodyFallback,
    height: 1.307692,
    leadingDistribution: TextLeadingDistribution.even,
    color: Color(0xFF8A5B3A),
  );

  static const weekdaysGap = 12.0;

  static const weekdaysHeight = 14.0;

  /// `Nunito 800 11/14 #9A6A44`.
  static const weekdaysFont = TextStyle(
    fontFamily: 'Nunito',
    fontSize: 11.0,
    fontWeight: FontWeight.w800,
    fontFamilyFallback: AppFontTokens.bodyFallback,
    height: 1.272727,
    leadingDistribution: TextLeadingDistribution.even,
    color: Color(0xFF9A6A44),
  );

  static const gridGap = 6.0;

  static const gridColumns = 7;

  /// A day column is min([gridPitchMax], floor((screen width −
  /// [gridPitchInset]) / 7)) wide: 48 at 390, 44 at 360.
  static const gridPitchMax = 48.0;

  /// `min(48, floor((screen width − 52) / 7)): 48 at 390, 44 at 360`.
  static const gridPitchInset = 52.0;

  /// A day's face is min([gridFaceMax], pitch − [gridFaceInset]): 42 at 390, 40
  /// at 360.
  static const gridFaceMax = 42.0;

  /// `min(42, pitch − 4): 42 at 390, 40 at 360`.
  static const gridFaceInset = 4.0;

  /// A grid row is the face + this tall.
  static const gridRowOverFace = 4.0;

  /// A day's corner radius …
  static const gridRadius = 14.0;

  /// … and at a [gridSmallFace] face.
  static const gridRadiusSmall = 13.0;

  /// The face size that takes the small radius and number.
  static const gridSmallFace = 40.0;

  /// A day's number, tabular; the colour and weight are its state's
  /// (`HabitsDayCellTokens.<state>Number*`): 700 on a coloured face, 600 on a
  /// plain one …
  static TextStyle get gridNumber => DisplayFace.of(
    const TextStyle(
      fontFamily: 'Fredoka',
      fontSize: 16.0,
      fontWeight: FontWeight.w700,
      fontFamilyFallback: AppFontTokens.displayFallback,
      height: 1.0,
      leadingDistribution: TextLeadingDistribution.even,
      fontFeatures: [FontFeature.tabularFigures()],
    ),
  );

  /// … at this size on a [gridSmallFace] face.
  static const gridNumberSizeSmall = 15.0;

  static const legendGap = 8.0;

  static const legendHeight = 16.0;

  static const legendSwatch = 14.0;

  static const legendSwatchRadius = 5.0;

  static const legendItemGap = 14.0;

  /// `Nunito 800 11.5 #8A5B3A`.
  static const legendLabel = TextStyle(
    fontFamily: 'Nunito',
    fontSize: 11.5,
    fontWeight: FontWeight.w800,
    fontFamilyFallback: AppFontTokens.bodyFallback,
    color: Color(0xFF8A5B3A),
  );

  /// Each day is one element read as `habits_day_a11y_*` with {date} in this
  /// intl skeleton; window days add `habits_day_a11y_open`.
  static const a11yDateSkeleton = 'MMMMd';
}

/// tokens.json `habits.month.short` (16:9 (390 × 693), 14.2b), in dp on the
/// 390×693 (16:9) reference unless a member says otherwise.
abstract final class HabitsMonthShortTokens {
  static const padding = EdgeInsets.fromLTRB(10.0, 12.0, 10.0, 12.0);

  static const headerHeight = 28.0;

  /// The month's name on 16:9, dp (`18`).
  static const titleSize = 18.0;

  /// The hint on 16:9 (the colour is HabitsMonthTokens.hintFont's) …
  static const hint = TextStyle(
    fontFamily: 'Nunito',
    fontSize: 12.0,
    fontWeight: FontWeight.w700,
    fontFamilyFallback: AppFontTokens.bodyFallback,
    height: 1.333333,
    leadingDistribution: TextLeadingDistribution.even,
  );

  /// … this far under the header.
  static const hintGap = 3.0;

  /// `gap 10, height 13`.
  static const weekdaysGap = 10.0;

  /// `gap 10, height 13`.
  static const weekdaysHeight = 13.0;

  static const gridGap = 5.0;

  /// A day's face on 16:9, dp (`40`).
  static const faceSize = 40.0;

  static const rowHeight = 44.0;

  /// A day's number on 16:9, dp (`15`).
  static const numberSize = 15.0;

  static const legendGap = 6.0;
}

/// tokens.json `habits.month.cell`, in dp on the 390×844 reference unless a
/// member says otherwise.
abstract final class HabitsDayCellTokens {
  /// `linear-gradient(180deg,#FFB27A,#F2702B)`.
  static const litFace = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFFFB27A), Color(0xFFF2702B)],
  );

  /// The day number's colour …
  static const litNumberColor = Color(0xFFFFFFFF);

  /// … and weight (`#FFFFFF 700`).
  static const litNumberWeight = FontWeight.w700;

  /// `inset 0 2px 0 rgba(255,255,255,0.3)`.
  static const List<NestyShadow> litInner = [
    NestyShadow(color: Color(0x4DFFFFFF), inset: true, dy: 2.0),
  ];

  /// `#B8501A`.
  static const litEdge = Color(0xFFB8501A);

  /// `#FFE7D0`.
  static const laterFace = Color(0xFFFFE7D0);

  /// The day number's colour …
  static const laterNumberColor = Color(0xFFA94F12);

  /// … and weight (`#A94F12 700`).
  static const laterNumberWeight = FontWeight.w700;

  /// `inset 0 0 0 2px #F3B98C`.
  static const List<NestyShadow> laterInner = [
    NestyShadow(color: Color(0xFFF3B98C), inset: true, spread: 2.0),
  ];

  /// `#E3AE8C`.
  static const laterEdge = Color(0xFFE3AE8C);

  /// `#E3F1FF`.
  static const freezeFace = Color(0xFFE3F1FF);

  /// The day number's colour …
  static const freezeNumberColor = Color(0xFF326497);

  /// … and weight (`#326497 700`).
  static const freezeNumberWeight = FontWeight.w700;

  /// `inset 0 0 0 2px #9CC4EA`.
  static const List<NestyShadow> freezeInner = [
    NestyShadow(color: Color(0xFF9CC4EA), inset: true, spread: 2.0),
  ];

  /// `#7FAEDB`.
  static const freezeEdge = Color(0xFF7FAEDB);

  /// The `ac_unit` glyph (`NestyIcons`); tools/test/tokens checks the bundled
  /// icon font has it …
  static const freezeGlyph = 'ac_unit';

  /// … dp …
  static const freezeGlyphSize = 11.0;

  /// … in this colour.
  static const freezeGlyphColor = Color(0xFF3E8EDE);

  /// The snowflake sits this far from the face's bottom …
  static const freezeGlyphBottom = 3.0;

  /// … and the number lifts this far.
  static const freezeNumberLift = 4.5;

  /// `#FFFDF7`.
  static const openFace = Color(0xFFFFFDF7);

  /// The day number's colour …
  static const openNumberColor = Color(0xFF5B3A21);

  /// … and weight (`#5B3A21 600`).
  static const openNumberWeight = FontWeight.w600;

  /// `inset 0 2px 0 #FFFFFF`.
  static const List<NestyShadow> openInner = [
    NestyShadow(color: Color(0xFFFFFFFF), inset: true, dy: 2.0),
  ];

  /// `#D8B07A`.
  static const openEdge = Color(0xFFD8B07A);

  /// The day number's colour …
  static const blankNumberColor = Color(0xFF8A5B3A);

  /// … and weight (`#8A5B3A 600`).
  static const blankNumberWeight = FontWeight.w600;

  /// The day number's colour …
  static const futureNumberColor = Color(0xFF8A5B3A);

  /// … and weight (`#8A5B3A 600`).
  static const futureNumberWeight = FontWeight.w600;

  /// `#FFFDF7`.
  static const todayFace = Color(0xFFFFFDF7);

  /// The day number's colour …
  static const todayNumberColor = Color(0xFFC4631E);

  /// … and weight (`#C4631E 700`).
  static const todayNumberWeight = FontWeight.w700;

  /// `inset 0 2px 0 #FFFFFF, 0 0 0 2.5px #F2893B, 0 3.5px 0 2.5px #C4631E`.
  static const List<NestyShadow> todayShadow = [
    NestyShadow(color: Color(0xFFFFFFFF), inset: true, dy: 2.0),
    NestyShadow(color: Color(0xFFF2893B), spread: 2.5),
    NestyShadow(color: Color(0xFFC4631E), dy: 3.5, spread: 2.5),
  ];

  /// `linear-gradient(180deg,#FFB27A,#F2702B)`.
  static const todayLitFace = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFFFB27A), Color(0xFFF2702B)],
  );

  /// The day number's colour …
  static const todayLitNumberColor = Color(0xFFFFFFFF);

  /// … and weight (`#FFFFFF 700`).
  static const todayLitNumberWeight = FontWeight.w700;

  /// `inset 0 2px 0 rgba(255,255,255,0.3), 0 0 0 2px #FFF9EE, 0 0 0 4.5px
  /// #F2893B`.
  static const List<NestyShadow> todayLitShadow = [
    NestyShadow(color: Color(0x4DFFFFFF), inset: true, dy: 2.0),
    NestyShadow(color: Color(0xFFFFF9EE), spread: 2.0),
    NestyShadow(color: Color(0xFFF2893B), spread: 4.5),
  ];

  /// Inside the window every past day is a button raised on its state's
  /// `<state>Edge` this deep; outside it is flat and not a button.
  static const raisedEdgeDepth = 3.0;

  /// Pressed, a day sinks this far …
  static const pressedShift = 2.0;

  /// … onto an edge this deep …
  static const pressedEdgeDepth = 1.0;

  /// … over this (the house press).
  static const pressedMs = 80;

  /// The chosen day, while its card is open, sinks this far with no edge …
  static const selectedShift = 2.0;

  /// … and wears these rings.
  static const List<NestyShadow> selectedRings = [
    NestyShadow(color: Color(0xFFFFF9EE), spread: 2.0),
    NestyShadow(color: Color(0xFF6E4526), spread: 5.0),
  ];
}

/// tokens.json `habits.pastDay`, in dp on the 390×844 reference unless a
/// member says otherwise.
abstract final class HabitsPastDayTokens {
  /// A past day's card opens this far under the month card.
  static const cardGapBelowMonth = 12.0;

  /// The puzzle card of 5.1 for a past day: its title, the date
  /// ([cardTitleDateSkeleton]) …
  static TextStyle get cardTitle => DisplayFace.of(
    const TextStyle(
      fontFamily: 'Fredoka',
      fontSize: 20.0,
      fontWeight: FontWeight.w700,
      fontFamilyFallback: AppFontTokens.displayFallback,
    ),
  );

  /// … in this intl skeleton …
  static const cardTitleDateSkeleton = 'MMMEd';

  /// … the colours · tier chip, the preview this big …
  static const cardPreviewSize = 120.0;

  /// … Play this tall with no coin chip …
  static const cardPlayHeight = 60.0;

  /// … then `habits_past_note` (the ARB key), centred, in this style.
  static const cardNote = TextStyle(
    fontFamily: 'Nunito',
    fontSize: 13.0,
    fontWeight: FontWeight.w700,
    fontFamilyFallback: AppFontTokens.bodyFallback,
    height: 1.3,
    leadingDistribution: TextLeadingDistribution.even,
    color: Color(0xFF8A5B3A),
  );

  /// The card slides down this far and fades in …
  static const openSlide = 12.0;

  /// … over this …
  static const openMs = 240;

  /// … so;
  static const Cubic openCurve = UiMotionTokens.curveEaseOut;

  /// the page scrolls just enough to show the note over this.
  static const openScrollMs = 300;

  /// Reduce motion: a fade this long, and the scroll jumps.
  static const openReducedMs = 150;

  /// A solved past day's preview is dimmed with this under 5.5's green pill,
  /// `habits_past_solved_day` or `habits_past_solved_later` (the ARB keys).
  static const solvedPreviewDim = Color(0xB8FFF9EC);

  /// Play again is the secondary button: this tall …
  static const playAgainHeight = 54.0;

  /// `the secondary button: 54 tall, radius 20, #FFFDF7, inset 0 2px 0 #FFFFFF,
  /// 0 5px 0 #D8B07A, replay 22 + Fredoka 700 18 #6E4526`.
  static const playAgainRadius = 20.0;

  /// `the secondary button: 54 tall, radius 20, #FFFDF7, inset 0 2px 0 #FFFFFF,
  /// 0 5px 0 #D8B07A, replay 22 + Fredoka 700 18 #6E4526`.
  static const playAgainFace = Color(0xFFFFFDF7);

  /// `the secondary button: 54 tall, radius 20, #FFFDF7, inset 0 2px 0 #FFFFFF,
  /// 0 5px 0 #D8B07A, replay 22 + Fredoka 700 18 #6E4526`.
  static const List<NestyShadow> playAgainShadow = [
    NestyShadow(color: Color(0xFFFFFFFF), inset: true, dy: 2.0),
    NestyShadow(color: Color(0xFFD8B07A), dy: 5.0),
  ];

  /// The `replay` glyph (`NestyIcons`) …
  static const playAgainGlyph = 'replay';

  /// `the secondary button: 54 tall, radius 20, #FFFDF7, inset 0 2px 0 #FFFFFF,
  /// 0 5px 0 #D8B07A, replay 22 + Fredoka 700 18 #6E4526`.
  static const playAgainGlyphSize = 22.0;

  /// … and the label.
  static TextStyle get playAgainLabel => DisplayFace.of(
    const TextStyle(
      fontFamily: 'Fredoka',
      fontSize: 18.0,
      fontWeight: FontWeight.w700,
      fontFamilyFallback: AppFontTokens.displayFallback,
      color: Color(0xFF6E4526),
    ),
  );

  /// A past day's board shows its date in the Daily pill chip in this intl
  /// skeleton; no coin pill, no ▶ or price, Out of moves lists only what the
  /// player owns plus Restart, no interstitial.
  static const boardDateSkeleton = 'MMMd';

  /// A booster at 0 takes the disabled face …
  static const boardBoosterDisabledFace = Color(0xFFE8DCCB);

  /// `NestyBoard scene daily with the past date in the Daily pill chip ({date}
  /// MMMd); no coin pill; a booster at 0 takes the disabled face (#E8DCCB,
  /// inset 0 2px 4px rgba(90,45,15,0.2), #A48B72) instead of ▶ or a price; Out
  /// of moves lists only what the player owns, plus Restart; no interstitial`.
  static const List<NestyShadow> boardBoosterDisabledShadow = [
    NestyShadow(color: Color(0x335A2D0F), inset: true, dy: 2.0, blur: 4.0),
  ];

  /// … its glyph and count in this.
  static const boardBoosterDisabledGlyphColor = Color(0xFFA48B72);

  /// A past day's win is 5.4's layout with `habits_past_win_title`: where the
  /// coins were, the Moves pill: the `route` glyph (`NestyIcons`) …
  static const winMovesGlyph = 'route';

  /// `the 5.4 layout: ribbon habits_past_win_title, the Moves pill (route 24
  /// #6E4526 in a 38 dp #F6E2C2 disc, Fredoka 700 28 #5B3A21) where the coins
  /// were, the date card where the streak card was (a 52 dp cell.later with the
  /// day, {date} EEEEdMMMM in Fredoka 700 20, habits_past_win_line), then Back
  /// to Daily, which lands on the month with the new mark. No coins, no ×3`.
  static const winMovesGlyphSize = 24.0;

  /// `the 5.4 layout: ribbon habits_past_win_title, the Moves pill (route 24
  /// #6E4526 in a 38 dp #F6E2C2 disc, Fredoka 700 28 #5B3A21) where the coins
  /// were, the date card where the streak card was (a 52 dp cell.later with the
  /// day, {date} EEEEdMMMM in Fredoka 700 20, habits_past_win_line), then Back
  /// to Daily, which lands on the month with the new mark. No coins, no ×3`.
  static const winMovesGlyphColor = Color(0xFF6E4526);

  /// … in a disc this big …
  static const winMovesDisc = 38.0;

  /// `the 5.4 layout: ribbon habits_past_win_title, the Moves pill (route 24
  /// #6E4526 in a 38 dp #F6E2C2 disc, Fredoka 700 28 #5B3A21) where the coins
  /// were, the date card where the streak card was (a 52 dp cell.later with the
  /// day, {date} EEEEdMMMM in Fredoka 700 20, habits_past_win_line), then Back
  /// to Daily, which lands on the month with the new mark. No coins, no ×3`.
  static const winMovesDiscColor = Color(0xFFF6E2C2);

  /// … and the moves.
  static TextStyle get winMovesText => DisplayFace.of(
    const TextStyle(
      fontFamily: 'Fredoka',
      fontSize: 28.0,
      fontWeight: FontWeight.w700,
      fontFamilyFallback: AppFontTokens.displayFallback,
      color: Color(0xFF5B3A21),
    ),
  );

  /// Where the streak card was, the date card: a HabitsDayCellTokens.later* day
  /// this big …
  static const winDateCell = 52.0;

  /// … the date in this intl skeleton …
  static const winDateSkeleton = 'EEEEdMMMM';

  /// … in this style, then `habits_past_win_line`; Back to Daily lands on the
  /// month with the new mark. No coins, no ×3.
  static TextStyle get winDateText => DisplayFace.of(
    const TextStyle(
      fontFamily: 'Fredoka',
      fontSize: 20.0,
      fontWeight: FontWeight.w700,
      fontFamilyFallback: AppFontTokens.displayFallback,
    ),
  );
}

/// tokens.json `habits.widget`, in dp on the 390×844 reference unless a
/// member says otherwise.
abstract final class HabitsWidgetTokens {
  /// `ui/widget/flame_lit.svg` is drawn at this dp size (native,
  /// plan-local-habits §4; the 1×/2×/3× PNGs are this × 1, 2, 3).
  static const artFlameLitSize = Size(44.0, 44.0);

  /// `ui/widget/flame_unlit.svg` is drawn at this dp size (native,
  /// plan-local-habits §4; the 1×/2×/3× PNGs are this × 1, 2, 3).
  static const artFlameUnlitSize = Size(44.0, 44.0);

  /// `ui/widget/flame_unlit_dark.svg` is drawn at this dp size (native,
  /// plan-local-habits §4; the 1×/2×/3× PNGs are this × 1, 2, 3).
  static const artFlameUnlitDarkSize = Size(44.0, 44.0);

  /// `ui/widget/doll.svg` is drawn at this dp size (native, plan-local-habits
  /// §4; the 1×/2×/3× PNGs are this × 1, 2, 3).
  static const artDollSize = Size(18.0, 24.0);

  /// `ui/widget/daily_mark.svg` is drawn at this dp size (native,
  /// plan-local-habits §4; the 1×/2×/3× PNGs are this × 1, 2, 3).
  static const artDailyMarkSize = Size(52.0, 52.0);

  /// systemSmall on a 390×844 iPhone (the system sets it per device).
  static const iosSmall = Size(158.0, 158.0);

  /// systemMedium on a 390×844 iPhone.
  static const iosMedium = Size(338.0, 158.0);

  static const iosContentMargins = 16.0;

  static const androidMinWidth = 110.0;

  static const androidMinHeight = 110.0;

  static const androidMinResizeWidth = 110.0;

  static const androidMinResizeHeight = 110.0;

  /// The Android widget resizes up to this many cells tall.
  static const androidMaxResizeCells = 2;

  /// The Android widget's `android:resizeMode`.
  static const androidResizeMode = 'horizontal|vertical';

  /// Responsive RemoteViews: from this width the 4 × 2 (medium) layout, under
  /// it the 2 × 2 (small).
  static const androidMediumFrom = 250.0;

  /// Android 12+ uses system_app_widget_background_radius (clipToOutline);
  /// before it, this radius.
  static const androidRadiusBefore12 = 16.0;

  static const androidPadding = 16.0;

  static const layoutSmallPadding = 16.0;

  static const layoutSmallFlame = 36.0;

  /// The small widget's streak number …
  static TextStyle get layoutSmallNumber => DisplayFace.of(
    const TextStyle(
      fontFamily: 'Fredoka',
      fontSize: 36.0,
      fontWeight: FontWeight.w700,
      fontFamilyFallback: AppFontTokens.displayFallback,
    ),
  );

  /// … this far after the flame …
  static const layoutSmallNumberGap = 5.0;

  /// … in a row this tall.
  static const layoutSmallNumberRow = 40.0;

  /// `Nunito 800 12, 3 below`.
  static const layoutSmallLabel = TextStyle(
    fontFamily: 'Nunito',
    fontSize: 12.0,
    fontWeight: FontWeight.w800,
    fontFamilyFallback: AppFontTokens.bodyFallback,
  );

  /// The label sits this far under the number row.
  static const layoutSmallLabelGap = 3.0;

  /// The small widget's dolls: each this big …
  static const layoutSmallDollsSize = Size(15.0, 20.0);

  /// `15 × 20, gap 4, 12 below the label, up to 6`.
  static const layoutSmallDollsGap = 4.0;

  /// … this far under the label …
  static const layoutSmallDollsTop = 12.0;

  /// … at most this many.
  static const layoutSmallDollsMax = 6;

  /// The small widget's line, at the bottom (TextFitTokens.widgetLineMaxLines).
  static TextStyle get layoutSmallLine => DisplayFace.of(
    const TextStyle(
      fontFamily: 'Fredoka',
      fontSize: 14.0,
      fontWeight: FontWeight.w700,
      fontFamilyFallback: AppFontTokens.displayFallback,
      height: 1.2,
      leadingDistribution: TextLeadingDistribution.even,
    ),
  );

  /// Locked (before Level 2): `daily_mark` this big at the top …
  static const layoutSmallLockedMark = 42.0;

  /// … the title …
  static TextStyle get layoutSmallLockedTitle => DisplayFace.of(
    const TextStyle(
      fontFamily: 'Fredoka',
      fontSize: 17.0,
      fontWeight: FontWeight.w700,
      fontFamilyFallback: AppFontTokens.displayFallback,
    ),
  );

  /// … and the line.
  static const layoutSmallLockedLine = TextStyle(
    fontFamily: 'Nunito',
    fontSize: 13.0,
    fontWeight: FontWeight.w700,
    fontFamilyFallback: AppFontTokens.bodyFallback,
  );

  static const layoutMediumPadding = 16.0;

  /// The medium widget: a left column this wide …
  static const layoutMediumLeft = 104.0;

  /// … this gap either side of …
  static const layoutMediumGap = 14.0;

  /// … a divider this thick, then the right column.
  static const layoutMediumDivider = 1.5;

  /// The left column: the flame this big at the top …
  static const layoutMediumFlame = 46.0;

  /// … the number at the bottom …
  static TextStyle get layoutMediumNumber => DisplayFace.of(
    const TextStyle(
      fontFamily: 'Fredoka',
      fontSize: 42.0,
      fontWeight: FontWeight.w700,
      fontFamilyFallback: AppFontTokens.displayFallback,
    ),
  );

  /// … and the label.
  static const layoutMediumLabel = TextStyle(
    fontFamily: 'Nunito',
    fontSize: 12.0,
    fontWeight: FontWeight.w800,
    fontFamilyFallback: AppFontTokens.bodyFallback,
  );

  /// The right column: the title (one line) …
  static TextStyle get layoutMediumTitle => DisplayFace.of(
    const TextStyle(
      fontFamily: 'Fredoka',
      fontSize: 17.0,
      fontWeight: FontWeight.w700,
      fontFamilyFallback: AppFontTokens.displayFallback,
    ),
  );

  /// … the sub …
  static const layoutMediumSub = TextStyle(
    fontFamily: 'Nunito',
    fontSize: 12.5,
    fontWeight: FontWeight.w800,
    fontFamilyFallback: AppFontTokens.bodyFallback,
  );

  /// … the dolls, each this big …
  static const layoutMediumDollsSize = Size(19.0, 26.0);

  /// `title Fredoka 700 17 (one line), sub Nunito 800 12.5, dolls 19 × 26 gap 5
  /// (12 below, up to 8), the line Fredoka 700 15 at the bottom`.
  static const layoutMediumDollsGap = 5.0;

  /// … this far under the sub …
  static const layoutMediumDollsTop = 12.0;

  /// … at most this many …
  static const layoutMediumDollsMax = 8;

  /// … and the line at the bottom.
  static TextStyle get layoutMediumLine => DisplayFace.of(
    const TextStyle(
      fontFamily: 'Fredoka',
      fontSize: 15.0,
      fontWeight: FontWeight.w700,
      fontFamilyFallback: AppFontTokens.displayFallback,
    ),
  );

  /// Locked: `daily_mark` this big …
  static const layoutMediumLockedMark = 56.0;

  /// … in a left column this wide.
  static const layoutMediumLockedColumn = 64.0;
}

/// tokens.json `habits.widget.colors`, in dp on the 390×844 reference unless
/// a member says otherwise.
abstract final class HabitsWidgetColorTokens {
  /// `linear-gradient(180deg,#FFF9EE,#FCEBD0)`.
  static const lightBackground = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFFFF9EE), Color(0xFFFCEBD0)],
  );

  /// `#5B3A21`.
  static const lightTitle = Color(0xFF5B3A21);

  /// `#5B3A21`.
  static const lightNumber = Color(0xFF5B3A21);

  /// `#8A5B3A`.
  static const lightLabel = Color(0xFF8A5B3A);

  /// `#6E4526`.
  static const lightLine = Color(0xFF6E4526);

  /// `rgba(138,91,58,0.18)`.
  static const lightDivider = Color(0x2E8A5B3A);

  /// The light widget's shadow on Android; iOS draws its own.
  static const List<NestyShadow> lightShadow = [
    NestyShadow(color: Color(0x2E28140A), dy: 6.0, blur: 16.0),
  ];

  /// `linear-gradient(180deg,#3A2414,#24150B)`.
  static const darkBackground = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF3A2414), Color(0xFF24150B)],
  );

  /// `#FFF4E0`.
  static const darkTitle = Color(0xFFFFF4E0);

  /// `#FFF4E0`.
  static const darkNumber = Color(0xFFFFF4E0);

  /// `#E3C9A4`.
  static const darkLabel = Color(0xFFE3C9A4);

  /// `#F6E2C2`.
  static const darkLine = Color(0xFFF6E2C2);

  /// `rgba(255,236,205,0.18)`.
  static const darkDivider = Color(0x2EFFECCD);

  /// Tinted mode draws the accent in the system tint; the frames show this one.
  static const tintedAccentPreview = Color(0xFFFFD9A0);

  /// Tinted mode: the unlit flame is the tint at this opacity.
  static const tintedUnlitAccentOpacity = 0.45;

  /// Tinted mode: the text in white at 92 % …
  static const tintedText = Color(0xEBFFFFFF);

  /// … and the labels at 70 %.
  static const tintedLabel = Color(0xB3FFFFFF);
}

/// The win card's star reveal, `ui_stars` (tokens.json `motion.stars`). It
/// starts when the coin count-up ends; haptics: light per star, success after
/// the flourish. Reduce motion: show the last frame of star_n at once, no
/// flourish; one star sound (the highest earned) and one light haptic.
abstract final class StarMotionTokens {
  /// tokens.json `motion.stars.startMs`.
  static const startMs = 1300;

  /// tokens.json `motion.stars.segmentFrames`.
  static const segmentFrames = 20;

  /// tokens.json `motion.stars.perStarMs`.
  static const perStarMs = 333;

  /// tokens.json `motion.stars.popScale`.
  static const popScale = 1.18;

  /// `ui_stars`'s `flourish` segment (a test pins it to the marker).
  static const flourishStartFrame = 60;

  static const flourishEndFrame = 120;
}

/// The chest moment, `ui_chest` and its flights (tokens.json `motion.chest`).
/// Its segments are the file's markers (`fxSpecOf(FxId.uiChest)`). Reduce
/// motion: 200 ms crossfade closed → open, no wiggle, no flights; the chips
/// appear together.
abstract final class ChestMotionTokens {
  /// tokens.json `motion.chest.arriveMs`.
  static const arriveMs = 600;

  /// The idle breath …
  static const idleScaleFrom = 1.0;

  /// … between these scales.
  static const idleScaleTo = 1.03;

  /// tokens.json `motion.chest.idle.periodMs`.
  static const idlePeriodMs = 3000;

  /// tokens.json `motion.chest.idle.lockGlintEveryMs`.
  static const idleLockGlintEveryMs = 2400;

  /// tokens.json `motion.chest.wiggleMs`.
  static const wiggleMs = 483;

  /// tokens.json `motion.chest.burstMs`.
  static const burstMs = 750;

  /// tokens.json `motion.chest.chipStaggerMs`.
  static const chipStaggerMs = 150;

  /// tokens.json `motion.chest.rewardJingleAfterOpenMs`.
  static const rewardJingleAfterOpenMs = 250;

  /// tokens.json `motion.chest.collect.coinFlightMs`.
  static const collectCoinFlightMs = 700;

  /// tokens.json `motion.chest.collect.coinStaggerMs`.
  static const collectCoinStaggerMs = 60;

  /// tokens.json `motion.chest.collect.coins`.
  static const collectCoins = 6;

  /// tokens.json `motion.chest.collect.hintFlightMs`.
  static const collectHintFlightMs = 650;

  /// tokens.json `motion.chest.collect.targetBump`.
  static const collectTargetBump = 1.3;

  /// tokens.json `motion.chest.collect.targetBumpMs`.
  static const collectTargetBumpMs = 240;
}

/// The rival strip (tokens.json `motion.rivalDot`, `motion.rivalMove`): a dot
/// fills when the computer completes a family, and its portrait beats once
/// per move (one beat per rival move; no sound, no haptic). Reduce motion:
/// none beat.
abstract final class RivalMotionTokens {
  /// tokens.json `motion.rivalDot.fillMs`.
  static const dotFillMs = 240;

  /// tokens.json `motion.rivalDot.bump`.
  static const dotBump = 1.3;

  /// `cubic-bezier(.34,1.56,.64,1)`.
  static const dotCurve = Cubic(0.34, 1.56, 0.64, 1.0);

  /// tokens.json `motion.rivalMove.portraitScale`.
  static const movePortraitScale = 1.06;

  /// tokens.json `motion.rivalMove.ms`.
  static const moveMs = 160;
}

/// The toast queue (tokens.json `motion.toast`, F.5; Q122, Q136): one at a
/// time.
abstract final class ToastTokens {
  /// tokens.json `motion.toast.autoDismissMs`.
  static const autoDismissMs = 2500;

  /// "one at a time, the next waits 300 ms after the first leaves".
  static const gapMs = 300;

  /// A result card's toasts leave with it.
  static const leavesWithCard = true;

  /// tokens.json `motion.toast.badgeToastTop`.
  static const badgeToastTop = 60.0;

  /// The app toast's motion top: the safe top + this (`safeTop − 1`).
  /// `ToastLayoutTokens.appTopBelowSafeTop` is its resting place.
  static const appTopOffset = -1.0;

  /// tokens.json `motion.toast.relaxedOncePerLaunch`.
  static const relaxedOncePerLaunch = true;

  /// tokens.json `motion.toast.slotLimitOncePerLevel`.
  static const slotLimitOncePerLevel = true;
}

/// Chapters' rows fade in one after another (tokens.json
/// `motion.chaptersFadeIn`). Reduce motion: none.
abstract final class ChaptersMotionTokens {
  /// tokens.json `motion.chaptersFadeIn.staggerMs`.
  static const staggerMs = 40;

  /// tokens.json `motion.chaptersFadeIn.durationMs`.
  static const durationMs = 220;
}

/// A Shop purchase (tokens.json `motion.purchase`, F.5, 7.2): the card comes
/// in, `jingle_reward` plays at 0 and the balance counts up; the header
/// balance updates with the count-up.
abstract final class PurchaseMotionTokens {
  /// tokens.json `motion.purchase.cardInMs`.
  static const cardInMs = 240;

  /// tokens.json `motion.purchase.coinBurstAtMs`.
  static const coinBurstAtMs = 300;

  /// tokens.json `motion.purchase.countUpDelayMs`.
  static const countUpDelayMs = 400;

  /// tokens.json `motion.purchase.countUpMs`.
  static const countUpMs = 900;
}

/// The glyph each M7 icon use draws (tokens.json `icons`: Material Symbols
/// Rounded, FILL 1, weight 600 (I.10, C.8). ui/icons/ is empty: every use has
/// a glyph.). Every glyph is in the bundled font (`NestyIcons.byName`; a test
/// pins them); `IconUses` maps each use to its `IconData`.
abstract final class IconTokens {
  /// The `auto_stories` glyph.
  static const chapters = 'auto_stories';

  /// The `military_tech` glyph.
  static const records = 'military_tech';

  /// The `share` glyph.
  static const share = 'share';

  /// The `ios_share` glyph.
  static const shareIOS = 'ios_share';

  /// The `notifications` glyph.
  static const reminder = 'notifications';

  /// The `notifications_off` glyph.
  static const reminderOff = 'notifications_off';

  /// The `schedule` glyph.
  static const reminderTime = 'schedule';

  /// The `spa` glyph.
  static const relaxedMode = 'spa';

  /// The `motion_photos_off` glyph.
  static const reduceMotion = 'motion_photos_off';

  /// The `route` glyph.
  static const bestMoves = 'route';

  /// The `flag` glyph.
  static const chapterFinale = 'flag';

  /// The `computer` glyph.
  static const computerTag = 'computer';

  /// The `all_inclusive` glyph.
  static const undoUnlimited = 'all_inclusive';

  /// The `redeem` glyph.
  static const chest = 'redeem';

  /// The `replay` glyph.
  static const replay = 'replay';

  /// The `logout` glyph.
  static const leaveRace = 'logout';

  /// The `refresh` glyph.
  static const retry = 'refresh';

  /// The `open_in_new` glyph.
  static const openSettings = 'open_in_new';

  /// The `check_circle` glyph.
  static const levelsWon = 'check_circle';

  /// The `museum` glyph.
  static const familiesHome = 'museum';

  /// The `layers` glyph.
  static const dollsNested = 'layers';

  /// The `extension` glyph.
  static const dailiesSolved = 'extension';

  /// The `local_fire_department` glyph.
  static const longestStreak = 'local_fire_department';

  /// The `sd_card_alert` glyph.
  static const storageError = 'sd_card_alert';

  /// The `inventory_2` glyph.
  static const contentError = 'inventory_2';

  /// Every glyph use, by its tokens.json key.
  static const Map<String, String> glyphs = {
    'chapters': chapters,
    'records': records,
    'share': share,
    'shareIOS': shareIOS,
    'reminder': reminder,
    'reminderOff': reminderOff,
    'reminderTime': reminderTime,
    'relaxedMode': relaxedMode,
    'reduceMotion': reduceMotion,
    'bestMoves': bestMoves,
    'chapterFinale': chapterFinale,
    'computerTag': computerTag,
    'undoUnlimited': undoUnlimited,
    'chest': chest,
    'replay': replay,
    'leaveRace': leaveRace,
    'retry': retry,
    'openSettings': openSettings,
    'levelsWon': levelsWon,
    'familiesHome': familiesHome,
    'dollsNested': dollsNested,
    'dailiesSolved': dailiesSolved,
    'longestStreak': longestStreak,
    'storageError': storageError,
    'contentError': contentError,
  };
}

/// The ribbons' tints (tokens.json `winRibbon`, `versus.ribbon`): fills are
/// named uniquely per group (m7-4); the same names in ui_chapter_ribbon.
/// `ui_win_ribbon` is tinted [defaultColors] (as authored) or, on the race's
/// result cards (9.4, 9.5), [versusColors].
abstract final class WinRibbonTokens {
  /// The win ribbon as authored (tokens.json `winRibbon.default`).
  static const defaultColors = RibbonColors(
    band: Color(0xFFF28A3B),
    edge: Color(0xFFC4631F),
    tail: Color(0xFFE07A2E),
    fold: Color(0xFF9E4A14),
  );

  /// The race's result ribbon (tokens.json `versus.ribbon`).
  static const versusColors = RibbonColors(
    band: Color(0xFF4E5FD9),
    edge: Color(0xFF3242A8),
    tail: Color(0xFF4250C6),
    fold: Color(0xFF1F297F),
  );

  /// The label on the race ribbon (`#FFFFFF (5.3:1 on the band)`).
  static const versusLabel = Color(0xFFFFFFFF);

  /// The colour delegate's key path to the `band_fill` fills.
  static const List<String> bandKeyPath = ['**', 'band_fill'];

  /// The colour delegate's key path to the `edge_fill` fills.
  static const List<String> edgeKeyPath = ['**', 'edge_fill'];

  /// The colour delegate's key path to the `hi_fill` fills.
  static const List<String> hiKeyPath = ['**', 'hi_fill'];

  /// The colour delegate's key path to the `tail_fill` fills.
  static const List<String> tailKeyPath = ['**', 'tail_fill'];

  /// The colour delegate's key path to the `fold_fill` fills.
  static const List<String> foldKeyPath = ['**', 'fold_fill'];

  /// `ui_win_ribbon`'s band as authored (m7-5): `band_rect` and `edge_rect`;
  /// `hi_rect` is 16 dp narrower.
  static const bandSize = Size(290.0, 56.0);

  /// The ribbon's width at rest with its tails: for another band width w, move
  /// `tail_l` / `tail_r` by ∓(w − bandSize.width) / 2.
  static const reach = 334.0;

  /// The game's own label fits this box, centred on the anchor.
  static const textBox = Size(266.0, 40.0);

  /// The size delegate's key path to `band_rect`
  /// (`ValueDelegate.rectangleSize`).
  static const List<String> bandRectKeyPath = ['band', 'band', 'band_rect'];

  /// The size delegate's key path to `edge_rect`
  /// (`ValueDelegate.rectangleSize`).
  static const List<String> edgeRectKeyPath = ['band', 'edge', 'edge_rect'];

  /// The size delegate's key path to `hi_rect` (`ValueDelegate.rectangleSize`).
  static const List<String> hiRectKeyPath = ['band', 'hi', 'hi_rect'];

  /// A ribbon is never wider than the screen − this; `ui_chapter_ribbon` takes
  /// a width through the same rects.
  static const maxWidthInset = 70.0;
}

/// The text styles of the home surfaces (tokens.json `type.home`): m7-5 (item
/// 2): the scenes’ CSS sizes, named per surface. The CSS is the spec; these
/// names are its index. Line height after the slash; colours where the
/// surface fixes them. All scale with the text setting except where noted in
/// textFit. A `…Caps` member says the text is drawn in capitals (CSS
/// `text-transform`), a `…ShortSize` member the size on 16:9.
abstract final class HomeTypeTokens {
  /// `Fredoka 700 11/1, caps, letter-spacing 0.08em, chapter ink`: the colour
  /// is the chapter palette's `ink`.
  static TextStyle get chapterKicker => DisplayFace.of(
    const TextStyle(
      fontFamily: 'Fredoka',
      fontSize: 11.0,
      fontWeight: FontWeight.w700,
      fontFamilyFallback: AppFontTokens.displayFallback,
      height: 1.0,
      leadingDistribution: TextLeadingDistribution.even,
      letterSpacing: 0.88,
    ),
  );

  /// [chapterKicker] is drawn in capitals.
  static const chapterKickerCaps = true;

  /// `Fredoka 700 17/1.1 #5B3A21`.
  static TextStyle get chapterName => DisplayFace.of(
    const TextStyle(
      fontFamily: 'Fredoka',
      fontSize: 17.0,
      fontWeight: FontWeight.w700,
      fontFamilyFallback: AppFontTokens.displayFallback,
      height: 1.1,
      leadingDistribution: TextLeadingDistribution.even,
      color: Color(0xFF5B3A21),
    ),
  );

  /// `Fredoka 700 15/1.1 #5B3A21`.
  static TextStyle get tileTitle => DisplayFace.of(
    const TextStyle(
      fontFamily: 'Fredoka',
      fontSize: 15.0,
      fontWeight: FontWeight.w700,
      fontFamilyFallback: AppFontTokens.displayFallback,
      height: 1.1,
      leadingDistribution: TextLeadingDistribution.even,
      color: Color(0xFF5B3A21),
    ),
  );

  /// `Nunito 800 12/1 #8A5B3A`.
  static const tileSub = TextStyle(
    fontFamily: 'Nunito',
    fontSize: 12.0,
    fontWeight: FontWeight.w800,
    fontFamilyFallback: AppFontTokens.bodyFallback,
    height: 1.0,
    leadingDistribution: TextLeadingDistribution.even,
    color: Color(0xFF8A5B3A),
  );

  /// `Fredoka 700 11/1 #6E4526`.
  static TextStyle get recordsLabel => DisplayFace.of(
    const TextStyle(
      fontFamily: 'Fredoka',
      fontSize: 11.0,
      fontWeight: FontWeight.w700,
      fontFamilyFallback: AppFontTokens.displayFallback,
      height: 1.0,
      leadingDistribution: TextLeadingDistribution.even,
      color: Color(0xFF6E4526),
    ),
  );
}

/// The text styles of the chapters surfaces (tokens.json `type.chapters`):
/// m7-5 (item 2): the scenes’ CSS sizes, named per surface. The CSS is the
/// spec; these names are its index. Line height after the slash; colours
/// where the surface fixes them. All scale with the text setting except where
/// noted in textFit. A `…Caps` member says the text is drawn in capitals (CSS
/// `text-transform`), a `…ShortSize` member the size on 16:9.
abstract final class ChaptersTypeTokens {
  /// `Fredoka 700 10/1 #9A6A44, caps`.
  static TextStyle get rowKicker => DisplayFace.of(
    const TextStyle(
      fontFamily: 'Fredoka',
      fontSize: 10.0,
      fontWeight: FontWeight.w700,
      fontFamilyFallback: AppFontTokens.displayFallback,
      height: 1.0,
      leadingDistribution: TextLeadingDistribution.even,
      color: Color(0xFF9A6A44),
    ),
  );

  /// [rowKicker] is drawn in capitals.
  static const rowKickerCaps = true;

  /// `Fredoka 700 15/1.1 #5B3A21`.
  static TextStyle get rowName => DisplayFace.of(
    const TextStyle(
      fontFamily: 'Fredoka',
      fontSize: 15.0,
      fontWeight: FontWeight.w700,
      fontFamilyFallback: AppFontTokens.displayFallback,
      height: 1.1,
      leadingDistribution: TextLeadingDistribution.even,
      color: Color(0xFF5B3A21),
    ),
  );

  /// `Nunito 800 11/1 #2F7A3E`.
  static const rowSub = TextStyle(
    fontFamily: 'Nunito',
    fontSize: 11.0,
    fontWeight: FontWeight.w800,
    fontFamilyFallback: AppFontTokens.bodyFallback,
    height: 1.0,
    leadingDistribution: TextLeadingDistribution.even,
    color: Color(0xFF2F7A3E),
  );

  /// `Fredoka 700 16/1, tabular`: the surface gives the colour; tabular
  /// figures.
  static TextStyle get cellNumber => DisplayFace.of(
    const TextStyle(
      fontFamily: 'Fredoka',
      fontSize: 16.0,
      fontWeight: FontWeight.w700,
      fontFamilyFallback: AppFontTokens.displayFallback,
      height: 1.0,
      leadingDistribution: TextLeadingDistribution.even,
      fontFeatures: [FontFeature.tabularFigures()],
    ),
  );

  /// `Nunito 800 9.5/1 #9A6A44`.
  static const cellBest = TextStyle(
    fontFamily: 'Nunito',
    fontSize: 9.5,
    fontWeight: FontWeight.w800,
    fontFamilyFallback: AppFontTokens.bodyFallback,
    height: 1.0,
    leadingDistribution: TextLeadingDistribution.even,
    color: Color(0xFF9A6A44),
  );
}

/// The text styles of the museum surfaces (tokens.json `type.museum`): m7-5
/// (item 2): the scenes’ CSS sizes, named per surface. The CSS is the spec;
/// these names are its index. Line height after the slash; colours where the
/// surface fixes them. All scale with the text setting except where noted in
/// textFit. A `…Caps` member says the text is drawn in capitals (CSS
/// `text-transform`), a `…ShortSize` member the size on 16:9.
abstract final class MuseumTypeTokens {
  /// `Fredoka 700 11/1 #9A6A44, caps (NEXT FAMILY)`: e.g. "NEXT FAMILY".
  static TextStyle get kicker => DisplayFace.of(
    const TextStyle(
      fontFamily: 'Fredoka',
      fontSize: 11.0,
      fontWeight: FontWeight.w700,
      fontFamilyFallback: AppFontTokens.displayFallback,
      height: 1.0,
      leadingDistribution: TextLeadingDistribution.even,
      color: Color(0xFF9A6A44),
    ),
  );

  /// [kicker] is drawn in capitals.
  static const kickerCaps = true;

  /// `Fredoka 700 16/1 #5B3A21, tabular (m7-6: the frames’ size)`: tabular
  /// figures; m7-6: the frames’ size.
  static TextStyle get count => DisplayFace.of(
    const TextStyle(
      fontFamily: 'Fredoka',
      fontSize: 16.0,
      fontWeight: FontWeight.w700,
      fontFamilyFallback: AppFontTokens.displayFallback,
      height: 1.0,
      leadingDistribution: TextLeadingDistribution.even,
      color: Color(0xFF5B3A21),
      fontFeatures: [FontFeature.tabularFigures()],
    ),
  );

  /// `Fredoka 700 12/1.15 #FFEFD6 (museumNextName)`: the colour is
  /// `AppColorTokens.museumNextName`.
  static TextStyle get nextName => DisplayFace.of(
    const TextStyle(
      fontFamily: 'Fredoka',
      fontSize: 12.0,
      fontWeight: FontWeight.w700,
      fontFamilyFallback: AppFontTokens.displayFallback,
      height: 1.15,
      leadingDistribution: TextLeadingDistribution.even,
      color: Color(0xFFFFEFD6),
    ),
  );

  /// `Nunito 800 12/1.2 #7A5234`.
  static const nextLine = TextStyle(
    fontFamily: 'Nunito',
    fontSize: 12.0,
    fontWeight: FontWeight.w800,
    fontFamilyFallback: AppFontTokens.bodyFallback,
    height: 1.2,
    leadingDistribution: TextLeadingDistribution.even,
    color: Color(0xFF7A5234),
  );

  /// `Fredoka 700 11.5/1.15 #4A3008 (namePlateText)`: the colour is
  /// `AppColorTokens.namePlateText`.
  static TextStyle get plateName => DisplayFace.of(
    const TextStyle(
      fontFamily: 'Fredoka',
      fontSize: 11.5,
      fontWeight: FontWeight.w700,
      fontFamilyFallback: AppFontTokens.displayFallback,
      height: 1.15,
      leadingDistribution: TextLeadingDistribution.even,
      color: Color(0xFF4A3008),
    ),
  );

  /// `Nunito 800 11/1.25`: the surface gives the colour.
  static const lockedLines = TextStyle(
    fontFamily: 'Nunito',
    fontSize: 11.0,
    fontWeight: FontWeight.w800,
    fontFamilyFallback: AppFontTokens.bodyFallback,
    height: 1.25,
    leadingDistribution: TextLeadingDistribution.even,
  );
}

/// The text styles of the records surfaces (tokens.json `type.records`): m7-5
/// (item 2): the scenes’ CSS sizes, named per surface. The CSS is the spec;
/// these names are its index. Line height after the slash; colours where the
/// surface fixes them. All scale with the text setting except where noted in
/// textFit. A `…Caps` member says the text is drawn in capitals (CSS
/// `text-transform`), a `…ShortSize` member the size on 16:9.
abstract final class RecordsTypeTokens {
  /// `Fredoka 700 20/1 #5B3A21, tabular`: tabular figures.
  static TextStyle get cellValue => DisplayFace.of(
    const TextStyle(
      fontFamily: 'Fredoka',
      fontSize: 20.0,
      fontWeight: FontWeight.w700,
      fontFamilyFallback: AppFontTokens.displayFallback,
      height: 1.0,
      leadingDistribution: TextLeadingDistribution.even,
      color: Color(0xFF5B3A21),
      fontFeatures: [FontFeature.tabularFigures()],
    ),
  );

  /// `Nunito 700 11.5/1.2 #8A5B3A`.
  static const cellLabel = TextStyle(
    fontFamily: 'Nunito',
    fontSize: 11.5,
    fontWeight: FontWeight.w700,
    fontFamilyFallback: AppFontTokens.bodyFallback,
    height: 1.2,
    leadingDistribution: TextLeadingDistribution.even,
    color: Color(0xFF8A5B3A),
  );

  /// `Fredoka 600 16/1 #5B3A21`.
  static TextStyle get rowName => DisplayFace.of(
    const TextStyle(
      fontFamily: 'Fredoka',
      fontSize: 16.0,
      fontWeight: FontWeight.w600,
      fontFamilyFallback: AppFontTokens.displayFallback,
      height: 1.0,
      leadingDistribution: TextLeadingDistribution.even,
      color: Color(0xFF5B3A21),
    ),
  );

  /// `Fredoka 700 18/1, tabular`: the surface gives the colour; tabular
  /// figures.
  static TextStyle get rowValue => DisplayFace.of(
    const TextStyle(
      fontFamily: 'Fredoka',
      fontSize: 18.0,
      fontWeight: FontWeight.w700,
      fontFamilyFallback: AppFontTokens.displayFallback,
      height: 1.0,
      leadingDistribution: TextLeadingDistribution.even,
      fontFeatures: [FontFeature.tabularFigures()],
    ),
  );

  /// `Nunito 700 11/1.3 #8A5B3A`.
  static const badgeLine = TextStyle(
    fontFamily: 'Nunito',
    fontSize: 11.0,
    fontWeight: FontWeight.w700,
    fontFamilyFallback: AppFontTokens.bodyFallback,
    height: 1.3,
    leadingDistribution: TextLeadingDistribution.even,
    color: Color(0xFF8A5B3A),
  );
}

/// The text styles of the shop surfaces (tokens.json `type.shop`): m7-5 (item
/// 2): the scenes’ CSS sizes, named per surface. The CSS is the spec; these
/// names are its index. Line height after the slash; colours where the
/// surface fixes them. All scale with the text setting except where noted in
/// textFit. A `…Caps` member says the text is drawn in capitals (CSS
/// `text-transform`), a `…ShortSize` member the size on 16:9.
abstract final class ShopTypeTokens {
  /// `Nunito 600 16/1.45 #6E4526`.
  static const description = TextStyle(
    fontFamily: 'Nunito',
    fontSize: 16.0,
    fontWeight: FontWeight.w600,
    fontFamilyFallback: AppFontTokens.bodyFallback,
    height: 1.45,
    leadingDistribution: TextLeadingDistribution.even,
    color: Color(0xFF6E4526),
  );

  /// `Fredoka 700 14/1`: the surface gives the colour.
  static TextStyle get tab => DisplayFace.of(
    const TextStyle(
      fontFamily: 'Fredoka',
      fontSize: 14.0,
      fontWeight: FontWeight.w700,
      fontFamilyFallback: AppFontTokens.displayFallback,
      height: 1.0,
      leadingDistribution: TextLeadingDistribution.even,
    ),
  );

  /// `Fredoka 700 15/1.2 #8C5E12`.
  static TextStyle get price => DisplayFace.of(
    const TextStyle(
      fontFamily: 'Fredoka',
      fontSize: 15.0,
      fontWeight: FontWeight.w700,
      fontFamilyFallback: AppFontTokens.displayFallback,
      height: 1.2,
      leadingDistribution: TextLeadingDistribution.even,
      color: Color(0xFF8C5E12),
    ),
  );

  /// `Nunito 700 13/1.3 #8A5B3A`.
  static const sub = TextStyle(
    fontFamily: 'Nunito',
    fontSize: 13.0,
    fontWeight: FontWeight.w700,
    fontFamilyFallback: AppFontTokens.bodyFallback,
    height: 1.3,
    leadingDistribution: TextLeadingDistribution.even,
    color: Color(0xFF8A5B3A),
  );

  /// `Nunito 700 13/1 #9A6A44`.
  static const balance = TextStyle(
    fontFamily: 'Nunito',
    fontSize: 13.0,
    fontWeight: FontWeight.w700,
    fontFamilyFallback: AppFontTokens.bodyFallback,
    height: 1.0,
    leadingDistribution: TextLeadingDistribution.even,
    color: Color(0xFF9A6A44),
  );
}

/// The text styles of the gift surfaces (tokens.json `type.gift`): m7-5 (item
/// 2): the scenes’ CSS sizes, named per surface. The CSS is the spec; these
/// names are its index. Line height after the slash; colours where the
/// surface fixes them. All scale with the text setting except where noted in
/// textFit. A `…Caps` member says the text is drawn in capitals (CSS
/// `text-transform`), a `…ShortSize` member the size on 16:9.
abstract final class GiftTypeTokens {
  /// `Fredoka 700 30/1.1 #5B3A21 (26 on 16:9)`.
  static TextStyle get title => DisplayFace.of(
    const TextStyle(
      fontFamily: 'Fredoka',
      fontSize: 30.0,
      fontWeight: FontWeight.w700,
      fontFamilyFallback: AppFontTokens.displayFallback,
      height: 1.1,
      leadingDistribution: TextLeadingDistribution.even,
      color: Color(0xFF5B3A21),
    ),
  );

  /// [title]'s size on 16:9 (390×693).
  static const titleShortSize = 26.0;

  /// `Nunito 600 15/1.35 #7A5234 (14 on 16:9)`.
  static const sub = TextStyle(
    fontFamily: 'Nunito',
    fontSize: 15.0,
    fontWeight: FontWeight.w600,
    fontFamilyFallback: AppFontTokens.bodyFallback,
    height: 1.35,
    leadingDistribution: TextLeadingDistribution.even,
    color: Color(0xFF7A5234),
  );

  /// [sub]'s size on 16:9 (390×693).
  static const subShortSize = 14.0;

  /// `Nunito 800 13/1`: the surface gives the colour.
  static const dayLabel = TextStyle(
    fontFamily: 'Nunito',
    fontSize: 13.0,
    fontWeight: FontWeight.w800,
    fontFamilyFallback: AppFontTokens.bodyFallback,
    height: 1.0,
    leadingDistribution: TextLeadingDistribution.even,
  );

  /// `Fredoka 700 24/1, tabular (22 on 16:9)`: the surface gives the colour;
  /// tabular figures.
  static TextStyle get amount => DisplayFace.of(
    const TextStyle(
      fontFamily: 'Fredoka',
      fontSize: 24.0,
      fontWeight: FontWeight.w700,
      fontFamilyFallback: AppFontTokens.displayFallback,
      height: 1.0,
      leadingDistribution: TextLeadingDistribution.even,
      fontFeatures: [FontFeature.tabularFigures()],
    ),
  );

  /// [amount]'s size on 16:9 (390×693).
  static const amountShortSize = 22.0;

  /// `Fredoka 700 15/1 #5B3A21`.
  static TextStyle get chip => DisplayFace.of(
    const TextStyle(
      fontFamily: 'Fredoka',
      fontSize: 15.0,
      fontWeight: FontWeight.w700,
      fontFamilyFallback: AppFontTokens.displayFallback,
      height: 1.0,
      leadingDistribution: TextLeadingDistribution.even,
      color: Color(0xFF5B3A21),
    ),
  );

  /// `Fredoka 700 17/1.15 #5B3A21`.
  static TextStyle get line1 => DisplayFace.of(
    const TextStyle(
      fontFamily: 'Fredoka',
      fontSize: 17.0,
      fontWeight: FontWeight.w700,
      fontFamilyFallback: AppFontTokens.displayFallback,
      height: 1.15,
      leadingDistribution: TextLeadingDistribution.even,
      color: Color(0xFF5B3A21),
    ),
  );

  /// `Nunito 700 15/1.3 #8A5B3A`.
  static const line2 = TextStyle(
    fontFamily: 'Nunito',
    fontSize: 15.0,
    fontWeight: FontWeight.w700,
    fontFamilyFallback: AppFontTokens.bodyFallback,
    height: 1.3,
    leadingDistribution: TextLeadingDistribution.even,
    color: Color(0xFF8A5B3A),
  );

  /// `Fredoka 700 17/1, tabular`: the surface gives the colour; tabular
  /// figures.
  static TextStyle get tally => DisplayFace.of(
    const TextStyle(
      fontFamily: 'Fredoka',
      fontSize: 17.0,
      fontWeight: FontWeight.w700,
      fontFamilyFallback: AppFontTokens.displayFallback,
      height: 1.0,
      leadingDistribution: TextLeadingDistribution.even,
      fontFeatures: [FontFeature.tabularFigures()],
    ),
  );
}

/// The shared orange ribbon title of 10.3b (`RibbonTitle`), on a modal card's
/// top edge; the Day 7 chest card wears it too (m7-6 item 5, tokens.json
/// `gift.chest.ribbon`; 13.6b redrawn).
abstract final class RibbonTitleTokens {
  /// The title, one line, with its text shadow.
  static TextStyle get text => DisplayFace.of(
    const TextStyle(
      fontFamily: 'Fredoka',
      fontSize: 18.0,
      fontWeight: FontWeight.w700,
      fontFamilyFallback: AppFontTokens.displayFallback,
      height: 1.0,
      leadingDistribution: TextLeadingDistribution.even,
      color: Color(0xFFFFFFFF),
      shadows: [Shadow(color: Color(0x29000000), offset: Offset(0.0, 2.0))],
    ),
  );

  static const padding = EdgeInsets.symmetric(vertical: 9.0, horizontal: 22.0);

  static const radius = 16.0;

  /// How far the ribbon rises above the card's top edge.
  static const overhang = 18.0;

  /// Its face.
  static const face = AppGradientTokens.primary;

  /// Its solid edge (AppColorTokens.primaryEdge).
  static const List<NestyShadow> edge = [
    NestyShadow(color: Color(0xFFC4631E), dy: 4.0),
  ];
}
