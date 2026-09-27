// GENERATED — do not edit; run dart run nesty_tools:gen_design_tokens
//
// Source: design/tokens.json (tokens v1).
// Nesty: Doll Sort design tokens v1. Source of truth for colors, type,
// spacing, radii, shadows, layout, motion, sound and haptics. Keys under
// dollColor match nesty_core DollColor ids.

import 'dart:ui' show Color, Offset, Size;

import 'package:flutter/animation.dart' show Cubic;
import 'package:nesty_core/nesty_core.dart' show DollColor;
import 'package:nesty_render/src/tokens/render_token_types.dart';

/// Which design/tokens.json these render tokens were generated from.
abstract final class RenderTokensInfo {
  /// tokens.json `meta.version`.
  static const version = 1;
}

/// Per-`DollColor` design colors (tokens.json `dollColor`). Keyed by the
/// `nesty_core` `DollColor.id`, never by display name.
abstract final class DollColorTokens {
  /// tokens.json `dollColor.red`.
  static const red = DollColorToken(
    id: 'red',
    name: 'Cherry',
    base: Color(0xFFE5484D),
    ink: Color(0xFFA43434),
    light: Color(0xFFF19A9D),
    symbol: 'heart',
  );

  /// tokens.json `dollColor.orange`.
  static const orange = DollColorToken(
    id: 'orange',
    name: 'Tangerine',
    base: Color(0xFFF2893B),
    ink: Color(0xFFAD6028),
    light: Color(0xFFF8BE93),
    symbol: 'flower',
  );

  /// tokens.json `dollColor.yellow`.
  static const yellow = DollColorToken(
    id: 'yellow',
    name: 'Sunflower',
    base: Color(0xFFF5C518),
    ink: Color(0xFF92710D),
    light: Color(0xFFFADF80),
    symbol: 'sun',
  );

  /// tokens.json `dollColor.green`.
  static const green = DollColorToken(
    id: 'green',
    name: 'Leaf',
    base: Color(0xFF46A758),
    ink: Color(0xFF38753C),
    light: Color(0xFF99CFA3),
    symbol: 'leaf',
  );

  /// tokens.json `dollColor.teal`.
  static const teal = DollColorToken(
    id: 'teal',
    name: 'Lagoon',
    base: Color(0xFF12A594),
    ink: Color(0xFF157365),
    light: Color(0xFF7DCEC4),
    symbol: 'wave',
  );

  /// tokens.json `dollColor.blue`.
  static const blue = DollColorToken(
    id: 'blue',
    name: 'Sky',
    base: Color(0xFF3E8EDE),
    ink: Color(0xFF326497),
    light: Color(0xFF95C1ED),
    symbol: 'drop',
  );

  /// tokens.json `dollColor.purple`.
  static const purple = DollColorToken(
    id: 'purple',
    name: 'Grape',
    base: Color(0xFF8E4EC6),
    ink: Color(0xFF693887),
    light: Color(0xFFC19EE0),
    symbol: 'star',
  );

  /// tokens.json `dollColor.pink`.
  static const pink = DollColorToken(
    id: 'pink',
    name: 'Bubblegum',
    base: Color(0xFFE93D82),
    ink: Color(0xFFA72D58),
    light: Color(0xFFF394BA),
    symbol: 'bow',
  );

  /// tokens.json `dollColor.navy`.
  static const navy = DollColorToken(
    id: 'navy',
    name: 'Midnight',
    base: Color(0xFF2F3E8F),
    ink: Color(0xFF282C5D),
    light: Color(0xFF979FC7),
    symbol: 'moon',
  );

  /// tokens.json `dollColor.brown`.
  static const brown = DollColorToken(
    id: 'brown',
    name: 'Cocoa',
    base: Color(0xFFA0673C),
    ink: Color(0xFF754929),
    light: Color(0xFFCBAB94),
    symbol: 'acorn',
  );

  /// tokens.json `dollColor.gold`.
  static const gold = DollColorToken(
    id: 'gold',
    name: 'Gold',
    base: Color(0xFFD4A22C),
    ink: Color(0xFF8C5E12),
    light: Color(0xFFFFF1B0),
    symbol: 'crown',
    wild: true,
    tintMode: DollTintMode.gradientMap,
    ramp: [
      RampStop(0.0, Color(0xFF4A3008)),
      RampStop(0.3, Color(0xFF7A5210)),
      RampStop(0.55, Color(0xFFB07E1C)),
      RampStop(0.75, Color(0xFFD9A634)),
      RampStop(0.9, Color(0xFFF0C452)),
      RampStop(1.0, Color(0xFFFFE89A)),
    ],
    rampInputExponent: 2.0,
  );

  /// Every color, in `DollColor.values` order.
  static const List<DollColorToken> values = [
    red,
    orange,
    yellow,
    green,
    teal,
    blue,
    purple,
    pink,
    navy,
    brown,
    gold,
  ];

  /// The tokens for [color]. Exhaustive: a new `DollColor` without tokens is a
  /// compile error.
  static DollColorToken of(DollColor color) => switch (color) {
    DollColor.red => red,
    DollColor.orange => orange,
    DollColor.yellow => yellow,
    DollColor.green => green,
    DollColor.teal => teal,
    DollColor.blue => blue,
    DollColor.purple => purple,
    DollColor.pink => pink,
    DollColor.navy => navy,
    DollColor.brown => brown,
    DollColor.gold => gold,
  };
}

/// How to derive ink/light shades for a color outside the table (tokens.json
/// `dollColorDerivation`). The table colors are hand-tuned: use their tokens,
/// not this.
abstract final class DollColorDerivationTokens {
  static const space = 'OKLCH';

  /// tokens.json `dollColorDerivation.ink.dL`.
  static const inkDeltaL = -0.17;

  /// tokens.json `dollColorDerivation.ink.chroma`.
  static const inkChromaScale = 0.85;

  /// tokens.json `dollColorDerivation.ink.minL`.
  static const inkMinL = 0.24;

  /// tokens.json `dollColorDerivation.light.dL`.
  static const lightDeltaL = 0.17;

  /// tokens.json `dollColorDerivation.light.chroma`.
  static const lightChromaScale = 0.6;

  /// tokens.json `dollColorDerivation.light.maxL`.
  static const lightMaxL = 0.94;

  /// "reduce chroma by 8% steps until inside sRGB": multiply chroma by (1 −
  /// this) until the color is in sRGB.
  static const gamutChromaStep = 0.08;
}

/// Doll skin geometry in 512×768 artboard units (tokens.json `skin`, spec
/// §12.2). Per-skin values come from each `skin.json`; these are the defaults
/// they must match.
///
/// Tint: multiply grayscale mask RGB by base (BlendMode.modulate).
abstract final class SkinTokens {
  static const artboard = Size(512.0, 768.0);

  /// tokens.json `skin.splitY`.
  static const splitY = 400.0;

  /// tokens.json `skin.lidLiftPx`.
  static const lidLiftPx = 120.0;

  /// Center of the belly symbol box.
  static const symbolAnchor = Offset(256.0, 590.0);

  /// tokens.json `skin.symbolSize`.
  static const symbolSize = 110.0;

  /// tokens.json `skin.symbolSizeLarge`.
  static const symbolSizeLarge = 117.0;

  /// tokens.json `skin.badgeRadius`.
  static const badgeRadius = 92.0;

  /// Large-symbols mode backing disc.
  static const badgeFill = Color(0xFFFFF8EC);

  /// tokens.json `skin.badgeStroke`.
  static const badgeStroke = 8.0;

  /// Mask tint for buried tower nests (spec §3.2).
  static const woodSilhouette = Color(0xFFE6C08C);

  /// tokens.json `skin.interiorRim.ellipseOuter` (cx, cy, rx, ry), drawn while
  /// the lid is open.
  static const interiorRimOuter = TokenEllipse(
    cx: 256.0,
    cy: 398.0,
    rx: 148.0,
    ry: 21.0,
  );

  /// tokens.json `skin.interiorRim.ellipseInner` (cx, cy, rx, ry), drawn while
  /// the lid is open.
  static const interiorRimInner = TokenEllipse(
    cx: 256.0,
    cy: 401.0,
    rx: 134.0,
    ry: 15.0,
  );

  static const interiorRimInnerFill = Color(0xFF2A1608);

  static const interiorRimInnerOpacity = 0.88;
}

/// Board layout on the 390×844 reference screen (tokens.json `meta.screen`
/// and `layout`, spec §10.3). BoardLayout scales these to the device.
///
/// Units: logical px (dp).
abstract final class BoardTokens {
  static const referenceScreen = Size(390.0, 844.0);

  static const referenceSafeTop = 59.0;

  static const referenceSafeBottom = 34.0;

  /// tokens.json `layout.board.sideMargin`.
  static const sideMargin = 16.0;

  /// Max slot pitch.
  static const slotWidthMax = 96.0;

  /// Slot pitch = `min(96, 372 / slotsInRow)`.
  static const slotRowWidth = 372.0;

  /// Plank top y per shelf count (tokens.json `layout.board.planksY`).
  static const Map<int, List<double>> plankTopsByShelfCount = {
    3: [312.0, 498.0, 684.0],
    2: [430.0, 650.0],
  };

  /// tokens.json `layout.board.plankHeight`.
  static const plankHeight = 40.0;

  /// tokens.json `layout.board.stand`.
  static const standSize = Size(90.0, 34.0);

  /// tokens.json `layout.board.towerStand`.
  static const towerStandSize = Size(90.0, 39.0);

  /// The doll base sits this far below the stand top.
  static const standSurfaceOffset = 12.3;

  /// tokens.json `layout.board.glassCase`.
  static const glassCaseSize = Size(86.0, 143.0);

  /// tokens.json `layout.board.iceOverlay`.
  static const iceOverlaySize = Size(96.0, 160.0);

  /// Hit area: "whole slot column, min 48".
  static const minHitExtent = 48.0;

  /// tokens.json `layout.pip.size`.
  static const pipSize = 6.0;

  /// tokens.json `layout.pip.pitch`.
  static const pipPitch = 7.8;

  /// Pip order: "left = biggest size".
  static const pipBiggestFirst = true;

  /// Filled pip: "doll base color + 1px rgba(255,240,215,0.95) ring".
  static const pipFilledRingWidth = 1.0;

  static const pipFilledRingColor = Color(0xF2FFF0D7);

  /// Empty pip: "#2C170A inset".
  static const pipEmptyColor = Color(0xFF2C170A);

  static const pipEmptyInset = true;

  /// Doll height ÷ slotMaxDollHeight, index 0 = size 1.
  static const List<double> dollHeightFractions = [
    0.42,
    0.54,
    0.66,
    0.78,
    0.89,
    1.0,
  ];

  /// When maxSize = 3: "divide by 0.66 so size 3 = 1.00".
  static const maxSize3Divisor = 0.66;

  static const Map<int, double> slotMaxDollHeightByShelfCount = {
    3: 150.0,
    2: 140.0,
  };

  /// Towers: "each buried nest drawn behind the top as the wood-grain blank
  /// board/doll-silhouette.svg (same for every skin), height (topHeight + 18 ×
  /// depth), with a +N walnut tag at the stand's right".
  static const towerDepthRaise = 18.0;

  /// The board sprite (`board/<name>.svg`) every buried tower nest draws, the
  /// same for every skin.
  static const towerSilhouetteSprite = 'doll-silhouette';

  /// tokens.json `layout.hud.top`.
  static const hudTop = 62.0;

  /// tokens.json `layout.hud.side`.
  static const hudSide = 16.0;

  /// tokens.json `layout.hud.pauseButton`.
  static const hudPauseButtonSize = Size(48.0, 48.0);

  /// tokens.json `layout.hud.levelPillHeight`.
  static const hudLevelPillHeight = 46.0;

  /// tokens.json `layout.hud.coinPillHeight`.
  static const hudCoinPillHeight = 40.0;

  /// tokens.json `layout.hud.familyCounter.top`.
  static const familyCounterTop = 116.0;

  /// tokens.json `layout.hud.familyCounter.height`.
  static const familyCounterHeight = 26.0;

  /// tokens.json `layout.boosterBar.top`.
  static const boosterBarTop = 734.0;

  /// tokens.json `layout.boosterBar.buttonSize`.
  static const boosterButtonSize = Size(80.0, 58.0);

  /// tokens.json `layout.boosterBar.gap`.
  static const boosterGap = 8.0;

  /// tokens.json `layout.boosterBar.left`.
  static const boosterBarLeft = 23.0;

  /// tokens.json `layout.boosterBar.topInset`.
  static const boosterBarTopInset = 12.0;
}

/// Game-feel timings (tokens.json `motion`, spec §11.1). Durations are
/// milliseconds (`…Ms`), distances logical px, angles degrees.
abstract final class MotionTokens {
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

  /// tokens.json `motion.pick.duration`.
  static const pickMs = 120;

  /// tokens.json `motion.pick.lift`.
  static const pickLift = 14.0;

  /// tokens.json `motion.pick.scale`.
  static const pickScale = 1.05;

  /// tokens.json `motion.pick.wobbleDeg`.
  static const pickWobbleDeg = 3.0;

  /// tokens.json `motion.pick.wobblePeriod`.
  static const pickWobblePeriodMs = 400;

  /// tokens.json `motion.pick.cancelSettle`.
  static const pickCancelSettleMs = 160;

  /// tokens.json `motion.move.duration`.
  static const moveMs = 260;

  /// tokens.json `motion.move.easing`.
  static const Cubic moveCurve = curveEaseOutBack;

  /// tokens.json `motion.move.arcHeight`.
  static const moveArcHeight = 42.0;

  /// tokens.json `motion.nest.lidLift.duration`.
  static const nestLidLiftMs = 80;

  /// tokens.json `motion.nest.lidLift.fraction`.
  static const nestLidLiftFraction = 0.3;

  /// tokens.json `motion.nest.lidLift.easing`.
  static const Cubic nestLidLiftCurve = curveEaseOut;

  /// tokens.json `motion.nest.dropIn.duration`.
  static const nestDropInMs = 120;

  /// tokens.json `motion.nest.dropIn.scale`.
  static const nestDropInScale = 0.92;

  /// tokens.json `motion.nest.dropIn.easing`.
  static const Cubic nestDropInCurve = curveEaseIn;

  /// tokens.json `motion.nest.lidSnap.duration`.
  static const nestLidSnapMs = 70;

  /// tokens.json `motion.nest.lidSnap.easing`.
  static const Cubic nestLidSnapCurve = curveEaseIn;

  /// tokens.json `motion.nest.squash.duration`.
  static const nestSquashMs = 120;

  /// tokens.json `motion.nest.squash.scaleX`.
  static const nestSquashScaleX = 1.08;

  /// tokens.json `motion.nest.squash.scaleY`.
  static const nestSquashScaleY = 0.92;

  /// tokens.json `motion.complete.shine`.
  static const completeShineMs = 300;

  /// tokens.json `motion.complete.hops`.
  static const List<MotionHop> completeHops = [
    MotionHop(height: 22.0, durationMs: 200),
    MotionHop(height: 14.0, durationMs: 200),
  ];

  /// tokens.json `motion.complete.fly.duration`.
  static const completeFlyMs = 550;

  /// tokens.json `motion.complete.fly.endScale`.
  static const completeFlyEndScale = 0.2;

  /// tokens.json `motion.complete.fly.rotateDeg`.
  static const completeFlyRotateDeg = 24.0;

  /// tokens.json `motion.complete.fly.easing`.
  static const Cubic completeFlyCurve = curveFly;

  /// tokens.json `motion.complete.counterBump.duration`.
  static const completeCounterBumpMs = 200;

  /// tokens.json `motion.complete.counterBump.scale`.
  static const completeCounterBumpScale = 1.22;

  /// tokens.json `motion.complete.dustPuff`.
  static const completeDustPuffMs = 400;

  /// tokens.json `motion.invalid.shakes`.
  static const invalidShakes = 3;

  /// tokens.json `motion.invalid.amplitude`.
  static const invalidAmplitude = 6.0;

  /// tokens.json `motion.invalid.each`.
  static const invalidShakeMs = 80;

  /// tokens.json `motion.invalid.returnDuration`.
  static const invalidReturnMs = 420;

  /// tokens.json `motion.reveal.duration`.
  static const revealMs = 200;

  /// Reveal: "circular paint wipe from the doll's centre (art 256, 476, 62 %
  /// down the artboard) + 5 splash drops".
  static const revealSplashDrops = 5;

  /// The centre the reveal wipe grows from, in 512×768 skin artboard units
  /// (tokens.json `motion.reveal.type`).
  static const revealWipeCenter = Offset(256.0, 476.0);

  /// tokens.json `motion.unlock.padlockPop`.
  static const unlockPadlockPopMs = 200;

  /// tokens.json `motion.unlock.crackedAt`.
  static const unlockCrackedAtMs = 200;

  /// tokens.json `motion.unlock.shatteredAt`.
  static const unlockShatteredAtMs = 400;

  /// tokens.json `motion.unlock.shardsDuration`.
  static const unlockShardsMs = 500;

  /// tokens.json `motion.ice.stages`.
  static const iceStages = 3;

  /// tokens.json `motion.ice.crackShake.duration`.
  static const iceCrackShakeMs = 120;

  /// tokens.json `motion.ice.crackShake.amplitude`.
  static const iceCrackShakeAmplitude = 2.0;

  /// tokens.json `motion.ice.shatter`.
  static const iceShatterMs = 300;

  /// tokens.json `motion.win.ribbonIn`.
  static const winRibbonInMs = 300;

  /// tokens.json `motion.win.confetti`.
  static const winConfettiMs = 1700;

  /// tokens.json `motion.win.danceLoop`.
  static const winDanceLoopMs = 1400;

  /// tokens.json `motion.win.danceStagger`.
  static const winDanceStaggerMs = 120;

  /// tokens.json `motion.combo.windowMs`.
  static const comboWindowMs = 4000;

  /// tokens.json `motion.combo.maxSteps`.
  static const comboMaxSteps = 5;

  /// tokens.json `motion.ui.buttonPress`.
  static const uiButtonPressMs = 80;

  /// tokens.json `motion.ui.toggle`.
  static const uiToggleMs = 180;

  /// tokens.json `motion.ui.sheetIn`.
  static const uiSheetInMs = 280;

  /// tokens.json `motion.ui.modalIn`.
  static const uiModalInMs = 240;

  /// tokens.json `motion.ui.tabLift`.
  static const uiTabLiftMs = 180;

  /// tokens.json `motion.reducedMotion.durationScale`.
  static const reducedMotionDurationScale = 0.5;

  /// tokens.json `motion.reducedMotion.shake`.
  static const reducedMotionShake = false;

  /// tokens.json `motion.reducedMotion.confetti`.
  static const reducedMotionConfetti = false;

  /// tokens.json `motion.reducedMotion.wobble`.
  static const reducedMotionWobble = false;
}
