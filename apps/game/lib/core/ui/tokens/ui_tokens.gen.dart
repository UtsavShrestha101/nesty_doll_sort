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
  static const display = TextStyle(
    fontFamily: 'Fredoka',
    fontSize: 56.0,
    height: 1.0,
    leadingDistribution: TextLeadingDistribution.even,
    fontWeight: FontWeight.w700,
    fontFamilyFallback: AppFontTokens.displayFallback,
  );

  /// Fredoka 40/42/700.
  static const h1 = TextStyle(
    fontFamily: 'Fredoka',
    fontSize: 40.0,
    height: 1.05,
    leadingDistribution: TextLeadingDistribution.even,
    fontWeight: FontWeight.w700,
    fontFamilyFallback: AppFontTokens.displayFallback,
  );

  /// Fredoka 30/33/700.
  static const sheetTitle = TextStyle(
    fontFamily: 'Fredoka',
    fontSize: 30.0,
    height: 1.1,
    leadingDistribution: TextLeadingDistribution.even,
    fontWeight: FontWeight.w700,
    fontFamilyFallback: AppFontTokens.displayFallback,
  );

  /// Fredoka 28/31/700.
  static const h2 = TextStyle(
    fontFamily: 'Fredoka',
    fontSize: 28.0,
    height: 1.1071428571428572,
    leadingDistribution: TextLeadingDistribution.even,
    fontWeight: FontWeight.w700,
    fontFamilyFallback: AppFontTokens.displayFallback,
  );

  /// Fredoka 26/26/700.
  static const screenTitle = TextStyle(
    fontFamily: 'Fredoka',
    fontSize: 26.0,
    height: 1.0,
    leadingDistribution: TextLeadingDistribution.even,
    fontWeight: FontWeight.w700,
    fontFamilyFallback: AppFontTokens.displayFallback,
  );

  /// Fredoka 20/22/700.
  static const cardTitle = TextStyle(
    fontFamily: 'Fredoka',
    fontSize: 20.0,
    height: 1.1,
    leadingDistribution: TextLeadingDistribution.even,
    fontWeight: FontWeight.w700,
    fontFamilyFallback: AppFontTokens.displayFallback,
  );

  /// Fredoka 21/21/700.
  static const button = TextStyle(
    fontFamily: 'Fredoka',
    fontSize: 21.0,
    height: 1.0,
    leadingDistribution: TextLeadingDistribution.even,
    fontWeight: FontWeight.w700,
    fontFamilyFallback: AppFontTokens.displayFallback,
  );

  /// Fredoka 17/17/700.
  static const buttonSmall = TextStyle(
    fontFamily: 'Fredoka',
    fontSize: 17.0,
    height: 1.0,
    leadingDistribution: TextLeadingDistribution.even,
    fontWeight: FontWeight.w700,
    fontFamilyFallback: AppFontTokens.displayFallback,
  );

  /// Fredoka 18/18/700.
  static const hudLevel = TextStyle(
    fontFamily: 'Fredoka',
    fontSize: 18.0,
    height: 1.0,
    leadingDistribution: TextLeadingDistribution.even,
    fontWeight: FontWeight.w700,
    fontFamilyFallback: AppFontTokens.displayFallback,
  );

  /// Fredoka 17/17/700.
  static const number = TextStyle(
    fontFamily: 'Fredoka',
    fontSize: 17.0,
    height: 1.0,
    leadingDistribution: TextLeadingDistribution.even,
    fontWeight: FontWeight.w700,
    fontFamilyFallback: AppFontTokens.displayFallback,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  /// Fredoka 13/13/600.
  static const boosterLabel = TextStyle(
    fontFamily: 'Fredoka',
    fontSize: 13.0,
    height: 1.0,
    leadingDistribution: TextLeadingDistribution.even,
    fontWeight: FontWeight.w600,
    fontFamilyFallback: AppFontTokens.displayFallback,
  );

  /// Fredoka 11/11/700.
  static const tierChip = TextStyle(
    fontFamily: 'Fredoka',
    fontSize: 11.0,
    height: 1.0,
    leadingDistribution: TextLeadingDistribution.even,
    fontWeight: FontWeight.w700,
    fontFamilyFallback: AppFontTokens.displayFallback,
    letterSpacing: 0.66,
  );

  /// Fredoka 12/12/700.
  static const tabLabel = TextStyle(
    fontFamily: 'Fredoka',
    fontSize: 12.0,
    height: 1.0,
    leadingDistribution: TextLeadingDistribution.even,
    fontWeight: FontWeight.w700,
    fontFamilyFallback: AppFontTokens.displayFallback,
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
  static const top = 220.0;

  /// `Fredoka 700 24/1.15, balanced`.
  static const heading = TextStyle(
    fontFamily: 'Fredoka',
    fontSize: 24.0,
    fontWeight: FontWeight.w700,
    fontFamilyFallback: AppFontTokens.displayFallback,
    height: 1.15,
    leadingDistribution: TextLeadingDistribution.even,
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
  static const itemChipName = TextStyle(
    fontFamily: 'Fredoka',
    fontSize: 18.0,
    fontWeight: FontWeight.w700,
    fontFamilyFallback: AppFontTokens.displayFallback,
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
  static const itemChipPriceText = TextStyle(
    fontFamily: 'Fredoka',
    fontSize: 16.0,
    fontWeight: FontWeight.w700,
    fontFamilyFallback: AppFontTokens.displayFallback,
    color: Color(0xFF8C5E12),
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
  static const appTitle = TextStyle(
    fontFamily: 'Fredoka',
    fontSize: 17.0,
    fontWeight: FontWeight.w700,
    fontFamilyFallback: AppFontTokens.displayFallback,
    height: 1.1,
    leadingDistribution: TextLeadingDistribution.even,
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
  static const inPlaceTitle = TextStyle(
    fontFamily: 'Fredoka',
    fontSize: 15.0,
    fontWeight: FontWeight.w700,
    fontFamilyFallback: AppFontTokens.displayFallback,
    height: 1.3,
    leadingDistribution: TextLeadingDistribution.even,
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
  static const pillText = TextStyle(
    fontFamily: 'Fredoka',
    fontSize: 15.0,
    fontWeight: FontWeight.w700,
    fontFamilyFallback: AppFontTokens.displayFallback,
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
  static const winRibbonBox = Size(312.0, 40.0);

  /// `Fredoka 700 24`.
  static const winRibbonFont = TextStyle(
    fontFamily: 'Fredoka',
    fontSize: 24.0,
    fontWeight: FontWeight.w700,
    fontFamilyFallback: AppFontTokens.displayFallback,
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
  static const chapterRibbonFont = TextStyle(
    fontFamily: 'Fredoka',
    fontSize: 20.0,
    fontWeight: FontWeight.w700,
    fontFamilyFallback: AppFontTokens.displayFallback,
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
  static const gainTagFont = TextStyle(
    fontFamily: 'Fredoka',
    fontSize: 13.0,
    fontWeight: FontWeight.w700,
    fontFamilyFallback: AppFontTokens.displayFallback,
    color: Color(0xFFFFFFFF),
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
  static const name = TextStyle(
    fontFamily: 'Fredoka',
    fontSize: 16.0,
    fontWeight: FontWeight.w700,
    fontFamilyFallback: AppFontTokens.displayFallback,
    color: Color(0xFF5B3A21),
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
  static const count = TextStyle(
    fontFamily: 'Fredoka',
    fontSize: 17.0,
    fontWeight: FontWeight.w700,
    fontFamilyFallback: AppFontTokens.displayFallback,
    color: Color(0xFF3242A8),
    fontFeatures: [FontFeature.tabularFigures()],
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
  static const startLabel = TextStyle(
    fontFamily: 'Fredoka',
    fontSize: 21.0,
    fontWeight: FontWeight.w700,
    fontFamilyFallback: AppFontTokens.displayFallback,
    color: Color(0xFFFFFFFF),
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
  static const foldedRowName = TextStyle(
    fontFamily: 'Fredoka',
    fontSize: 15.0,
    fontWeight: FontWeight.w700,
    fontFamilyFallback: AppFontTokens.displayFallback,
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

  /// `Fredoka 700 11.5 #4A3008 on a brass gradient`.
  static const cabinetNamePlate = TextStyle(
    fontFamily: 'Fredoka',
    fontSize: 11.5,
    fontWeight: FontWeight.w700,
    fontFamilyFallback: AppFontTokens.displayFallback,
    color: Color(0xFF4A3008),
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
  static const statsGridCellValue = TextStyle(
    fontFamily: 'Fredoka',
    fontSize: 20.0,
    fontWeight: FontWeight.w700,
    fontFamilyFallback: AppFontTokens.displayFallback,
    fontFeatures: [FontFeature.tabularFigures()],
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
  static const newChipText = TextStyle(
    fontFamily: 'Fredoka',
    fontSize: 12.0,
    fontWeight: FontWeight.w700,
    fontFamilyFallback: AppFontTokens.displayFallback,
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
  static const targetRowText = TextStyle(
    fontFamily: 'Fredoka',
    fontSize: 15.0,
    fontWeight: FontWeight.w700,
    fontFamilyFallback: AppFontTokens.displayFallback,
    color: Color(0xFF8C5E12),
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

  static const cardTop = 360.0;

  static const cardRadius = 26.0;

  /// `ui_spinner`, dp.
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
  static const buyCoinChipText = TextStyle(
    fontFamily: 'Fredoka',
    fontSize: 19.0,
    fontWeight: FontWeight.w700,
    fontFamilyFallback: AppFontTokens.displayFallback,
    color: Color(0xFFFFFFFF),
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
  static const detailPanelTagText = TextStyle(
    fontFamily: 'Fredoka',
    fontSize: 12.0,
    fontWeight: FontWeight.w700,
    fontFamilyFallback: AppFontTokens.displayFallback,
  );

  /// `Fredoka 700 16/1.1, one line`.
  static const cardNameSkin = TextStyle(
    fontFamily: 'Fredoka',
    fontSize: 16.0,
    fontWeight: FontWeight.w700,
    fontFamilyFallback: AppFontTokens.displayFallback,
    height: 1.1,
    leadingDistribution: TextLeadingDistribution.even,
  );

  /// `Fredoka 700 14/1.15, one line, ellipsis`.
  static const cardNameTheme = TextStyle(
    fontFamily: 'Fredoka',
    fontSize: 14.0,
    fontWeight: FontWeight.w700,
    fontFamilyFallback: AppFontTokens.displayFallback,
    height: 1.15,
    leadingDistribution: TextLeadingDistribution.even,
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
  static const font = TextStyle(
    fontFamily: 'Fredoka',
    fontSize: 16.0,
    fontWeight: FontWeight.w700,
    fontFamilyFallback: AppFontTokens.displayFallback,
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
}
