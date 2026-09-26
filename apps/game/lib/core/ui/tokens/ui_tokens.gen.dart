// GENERATED — do not edit; run dart run nesty_tools:gen_design_tokens
//
// Source: design/tokens.json (tokens v1).
// Nesty: Doll Sort design tokens v1. Source of truth for colors, type,
// spacing, radii, shadows, layout, motion, sound and haptics. Keys under
// dollColor match nesty_core DollColor ids.

import 'package:flutter/animation.dart' show Cubic;
import 'package:flutter/painting.dart';
import 'package:nesty_game/core/ui/tokens/ui_token_types.dart';

/// Which design/tokens.json these UI tokens were generated from.
abstract final class UiTokensInfo {
  /// tokens.json `meta.version`.
  static const version = 1;
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
  );

  /// Fredoka 40/42/700.
  static const h1 = TextStyle(
    fontFamily: 'Fredoka',
    fontSize: 40.0,
    height: 1.05,
    leadingDistribution: TextLeadingDistribution.even,
    fontWeight: FontWeight.w700,
  );

  /// Fredoka 30/33/700.
  static const sheetTitle = TextStyle(
    fontFamily: 'Fredoka',
    fontSize: 30.0,
    height: 1.1,
    leadingDistribution: TextLeadingDistribution.even,
    fontWeight: FontWeight.w700,
  );

  /// Fredoka 28/31/700.
  static const h2 = TextStyle(
    fontFamily: 'Fredoka',
    fontSize: 28.0,
    height: 1.1071428571428572,
    leadingDistribution: TextLeadingDistribution.even,
    fontWeight: FontWeight.w700,
  );

  /// Fredoka 26/26/700.
  static const screenTitle = TextStyle(
    fontFamily: 'Fredoka',
    fontSize: 26.0,
    height: 1.0,
    leadingDistribution: TextLeadingDistribution.even,
    fontWeight: FontWeight.w700,
  );

  /// Fredoka 20/22/700.
  static const cardTitle = TextStyle(
    fontFamily: 'Fredoka',
    fontSize: 20.0,
    height: 1.1,
    leadingDistribution: TextLeadingDistribution.even,
    fontWeight: FontWeight.w700,
  );

  /// Fredoka 21/21/700.
  static const button = TextStyle(
    fontFamily: 'Fredoka',
    fontSize: 21.0,
    height: 1.0,
    leadingDistribution: TextLeadingDistribution.even,
    fontWeight: FontWeight.w700,
  );

  /// Fredoka 17/17/700.
  static const buttonSmall = TextStyle(
    fontFamily: 'Fredoka',
    fontSize: 17.0,
    height: 1.0,
    leadingDistribution: TextLeadingDistribution.even,
    fontWeight: FontWeight.w700,
  );

  /// Fredoka 18/18/700.
  static const hudLevel = TextStyle(
    fontFamily: 'Fredoka',
    fontSize: 18.0,
    height: 1.0,
    leadingDistribution: TextLeadingDistribution.even,
    fontWeight: FontWeight.w700,
  );

  /// Fredoka 17/17/700.
  static const number = TextStyle(
    fontFamily: 'Fredoka',
    fontSize: 17.0,
    height: 1.0,
    leadingDistribution: TextLeadingDistribution.even,
    fontWeight: FontWeight.w700,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  /// Fredoka 13/13/600.
  static const boosterLabel = TextStyle(
    fontFamily: 'Fredoka',
    fontSize: 13.0,
    height: 1.0,
    leadingDistribution: TextLeadingDistribution.even,
    fontWeight: FontWeight.w600,
  );

  /// Fredoka 11/11/700.
  static const tierChip = TextStyle(
    fontFamily: 'Fredoka',
    fontSize: 11.0,
    height: 1.0,
    leadingDistribution: TextLeadingDistribution.even,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.66,
  );

  /// Fredoka 12/12/700.
  static const tabLabel = TextStyle(
    fontFamily: 'Fredoka',
    fontSize: 12.0,
    height: 1.0,
    leadingDistribution: TextLeadingDistribution.even,
    fontWeight: FontWeight.w700,
  );

  /// Nunito 16/23/600.
  static const body = TextStyle(
    fontFamily: 'Nunito',
    fontSize: 16.0,
    height: 1.4375,
    leadingDistribution: TextLeadingDistribution.even,
    fontWeight: FontWeight.w600,
  );

  /// Nunito 14/20/600.
  static const bodySmall = TextStyle(
    fontFamily: 'Nunito',
    fontSize: 14.0,
    height: 1.4285714285714286,
    leadingDistribution: TextLeadingDistribution.even,
    fontWeight: FontWeight.w600,
  );

  /// Nunito 17/17/700.
  static const row = TextStyle(
    fontFamily: 'Nunito',
    fontSize: 17.0,
    height: 1.0,
    leadingDistribution: TextLeadingDistribution.even,
    fontWeight: FontWeight.w700,
  );

  /// Nunito 12/16/700.
  static const caption = TextStyle(
    fontFamily: 'Nunito',
    fontSize: 12.0,
    height: 1.3333333333333333,
    leadingDistribution: TextLeadingDistribution.even,
    fontWeight: FontWeight.w700,
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

/// Sound events and mix (tokens.json `sound`, spec §11.3). Placeholders are
/// 44.1 kHz mono 16-bit WAV in design/audio. Final files may be OGG with the
/// same base names.
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

  /// Every SFX file base name the events use, sorted (for preloading and the
  /// asset manifest test).
  static const List<String> allFiles = [
    'bonk',
    'button',
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
    'unlock_glass',
    'whoosh',
    'win',
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

  static const List<String> comboNotes = ['C6', 'D6', 'E6', 'G6', 'A6'];

  /// Sets completed within this window step up the chime.
  static const comboWindowMs = 4000;

  static const comboMaxSteps = 5;

  /// "music_home (to source, 60–90 s seamless)" — not in the bundle yet.
  static const musicHome = 'music_home';

  /// "music_game (to source, 60–90 s seamless)" — not in the bundle yet.
  static const musicGame = 'music_game';

  static const sfxVolumeDefault = 0.8;

  static const musicVolumeDefault = 0.5;

  static const separateVolumes = true;
}
