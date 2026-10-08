// GENERATED — do not edit; run dart run nesty_tools:gen_design_tokens
//
// Source: design/tokens.json (tokens v4).
// Nesty: Doll Sort design tokens v4. Source of truth for colors, type,
// spacing, radii, shadows, layout, motion, sound and haptics. Keys under
// dollColor match nesty_core DollColor ids.

import 'dart:ui' show Color, Offset, Rect, Size;

import 'package:flutter/animation.dart' show Cubic;
import 'package:nesty_core/nesty_core.dart' show DollColor;
import 'package:nesty_render/src/tokens/render_token_types.dart';

/// Which design/tokens.json these render tokens were generated from.
abstract final class RenderTokensInfo {
  /// tokens.json `meta.version`.
  static const version = 4;
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
    4: [253.0, 398.0, 543.0, 688.0],
  };

  /// The size-6 boards' three shelves (tokens.json
  /// `layout.board.planksY.3shelvesTall`,
  /// `layout.boardPresets.threeShelvesTall`): 12 dp higher, 6 dp longer pitch.
  static const List<double> plankTopsThreeShelvesTall = [300.0, 494.0, 688.0];

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

  /// The tall ice of `threeShelvesTall` (tokens.json
  /// `layout.board.iceOverlayTall`).
  static const iceOverlayTallSize = Size(96.0, 168.0);

  /// An ice overlay's top = plankTop + this − its height (tokens.json
  /// `layout.board.iceOverlayTop`).
  static const iceTopFromPlank = 16.5;

  /// On the tall ice, `fx_ice` plays at scale (1, this) from the ice's bottom
  /// (LOTTIE.md m7-1).
  static const iceTallFxScaleY = 1.05;

  /// Glass, tall glass and ice scale with the stand about their bottom centre;
  /// the tall glass is at most the pitch − this wide (tokens.json
  /// `layout.board.overlays`).
  static const tallGlassPitchInset = 2.0;

  /// Neighbouring ice may overlap by up to this, dp.
  static const iceMaxOverlap = 3.0;

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

/// The tall glass case of a sealed size-5 or size-6 doll (tokens v3
/// `layout.board.glassCaseTall`, m7-1): its geometry as fractions of the doll
/// height h, so it grows with the doll. `fx_glass_unlock_tall` unlocks it.
abstract final class GlassCaseTallTokens {
  /// The art's viewBox (`board/glass-case-tall-{0,1,2}.svg`).
  static const viewBox = Size(186.0, 304.0);

  /// Case width ÷ h (`0.62h × 1.0133h (93×152 for h 150)`).
  static const widthPerHeight = 0.62;

  /// Case height ÷ h.
  static const heightPerHeight = 1.0133;

  /// The case bottom sits this × h below the stand surface.
  static const bottomPerHeight = 0.02667;

  /// The sealed doll stands on the stand surface (no plinth lift), so the
  /// unlock needs no settle.
  static const dollBaseOnSurface = true;

  /// The padlock's symbol, in the unlock colour's ink, dp at q = 1.
  static const lockSymbolSize = 12.0;

  /// The symbol's centre: caseTop + this × caseHeight.
  static const lockCenter = 0.898;

  /// A case whose doll is taller than this (dp at 390×844, sizes 5 and 6) is
  /// the tall one; smaller dolls keep `BoardTokens.glassCaseSize`.
  static const minDollHeight = 117.5;
}

/// The board fit (tokens v3 `layout.boardFit`), which replaces the h·2/3
/// clamp: one factor k per level, `min(1, min(vertical, hud, horizontal) /
/// heightOf(maxSize))`, applied to every doll (the formulas are hand-written
/// in BoardLayout and pinned to `BoardPresetTokens` by board_fit_test).
///
/// Replaces the stand-in clamp (h·2/3 ≤ minPitch − 8/3). One factor k per
/// level, computed in 390×844 dp before the board scales to the screen,
/// applied to every doll so the sizes keep their ratios. Checked against
/// every skin: the art box above the base (742/768 of the art) covers each
/// skin's topper, and the widest painted part is 411 of 512 art px.
abstract final class BoardFitTokens {
  /// The drawn doll above its base ÷ its height (742/768 of the art box).
  static const drawnHeight = 0.9661;

  /// The widest painted part ÷ the doll height (411 of 512).
  static const bodyWidth = 0.5353;

  /// The top shelf's dolls stay below this y (dp at 390×844).
  static const hudClearY = 150.0;

  /// Gap under the plank above, dp.
  static const headroom = 2.0;

  /// Gap between neighbouring dolls, dp.
  static const neighbourGap = 8.0;

  /// Stand width = `min(this, pitch − standPitchInset)`.
  static const standMaxWidth = 90.0;

  static const standPitchInset = 2.4;
}

/// The NestyBoard presets (tokens v3 `layout.boardPresets`), with the
/// design's own board fit results for 4 slots per row. The preset follows the
/// shelf count and maxSize (phase 4 architecture §2.1).
///
/// NestyBoard presets (prototypes/NestyBoard.dc.html scenes in brackets).
/// Measurements in dp at 390×844. dollHeights are per maxSize after
/// layout.boardFit; limits are its three limits for 4 slots per row.
abstract final class BoardPresetTokens {
  /// `layout.boardPresets.twoShelves`.
  static const twoShelves = BoardPresetToken(
    plankTops: [430.0, 650.0],
    slotMaxDollHeight: 140.0,
    maxSlotsPerRow: 4,
    limits: BoardFitLimits(vertical: 171.1, hud: 276.7, horizontal: 153.2),
    dollHeights: {
      3: [89.1, 114.5, 140.0],
      4: [58.8, 75.6, 92.4, 109.2],
      5: [58.8, 75.6, 92.4, 109.2, 124.6],
      6: [58.8, 75.6, 92.4, 109.2, 124.6, 140.0],
    },
  );

  /// `layout.boardPresets.threeShelves`.
  static const threeShelves = BoardPresetToken(
    plankTops: [312.0, 498.0, 684.0],
    slotMaxDollHeight: 150.0,
    maxSlotsPerRow: 4,
    limits: BoardFitLimits(vertical: 135.9, hud: 154.5, horizontal: 153.2),
    dollHeights: {
      3: [86.5, 111.2, 135.9],
      4: [63.0, 81.0, 99.0, 117.0],
      5: [63.0, 81.0, 99.0, 117.0, 133.5],
      6: [57.1, 73.4, 89.7, 106.0, 121.0, 135.9],
    },
  );

  /// `layout.boardPresets.threeShelvesTall`.
  static const threeShelvesTall = BoardPresetToken(
    plankTops: [300.0, 494.0, 688.0],
    slotMaxDollHeight: 150.0,
    maxSlotsPerRow: 4,
    limits: BoardFitLimits(vertical: 144.2, hud: 142.1, horizontal: 153.2),
    dollHeights: {
      6: [59.7, 76.7, 93.8, 110.8, 126.5, 142.1],
    },
    iceOverlay: Size(96.0, 168.0),
  );

  /// `layout.boardPresets.fourShelves`.
  static const fourShelves = BoardPresetToken(
    plankTops: [253.0, 398.0, 543.0, 688.0],
    slotMaxDollHeight: 150.0,
    maxSlotsPerRow: 4,
    limits: BoardFitLimits(vertical: 93.5, hud: 93.5, horizontal: 153.2),
    dollHeights: {
      3: [59.5, 76.5, 93.5],
      4: [50.3, 64.7, 79.1, 93.5],
    },
    optional: true,
  );

  /// `layout.boardPresets.rowOfFive`.
  static const rowOfFive = RowOfFiveToken(
    pitch: 74.4,
    stand: Size(72.0, 27.2),
    towerStand: Size(72.0, 31.2),
    standScale: 0.8,
    standSurfaceOffset: 9.84,
    pipsScaled: false,
    limits: BoardFitLimits(vertical: 135.9, hud: 154.5, horizontal: 119.6),
    dollHeights: {
      4: [63.0, 81.0, 99.0, 117.0],
      5: [56.4, 72.6, 88.7, 104.8, 119.6],
    },
    optional: true,
  );
}

/// Buried-nest silhouettes that stay clear of the HUD and the plank above
/// (tokens v3 `layout.towerStack`). `SlotGeometry.towerStack` hand-codes the
/// rule below; its test re-derives the design's three examples.
///
/// Rule: step = min(18, (hRoom − topHeight) / N), hRoom = (towerSurface −
/// limit) / drawnHeight, towerSurface = plankTop − 17.7, limit = hudClearY on
/// the top shelf, else the plank above's top + 40 + headroom; if step < 9,
/// draw max(1, floor((hRoom − topHeight) / 9)) silhouettes at step 9
abstract final class TowerStackTokens {
  /// The full step, dp (as before).
  static const step = 18.0;

  /// Below this step fewer silhouettes are drawn, at this step.
  static const minStep = 9.0;
}

/// A tower under ice (tokens v3 `layout.icedTower`). Its +N tag is hidden
/// while the ice is on; pops in (motion.tagPop) when fx_ice plays shatter.
abstract final class IcedTowerTokens {
  /// The silhouettes stay inside the ice: limit = max(limit, iceTop + this).
  static const iceTopGap = 8.0;
}

/// The dashed hint arc from the hinted doll to its target (tokens v3
/// `layout.hintArc`, E.15).
abstract final class HintArcTokens {
  /// The arc ends this far above the target doll.
  static const endOffsetAboveDoll = 8.0;

  /// The control points' lift on the same shelf.
  static const handleLift = 42.0;

  /// The control points' lift across shelves.
  static const handleLiftCrossRow = 56.0;

  static const dashOn = 6.0;

  static const dashOff = 6.0;

  /// Stroke width.
  static const width = 3.0;

  static const color = Color(0xFFF2893B);

  /// The arc ends with no arrowhead (m7-4 5.4: the dashed cubic arch is right;
  /// frame 3.1’s dotted quadratic is superseded).
  static const arrowhead = false;
}

/// The procedural doll drawn when a skin can't load (tokens v3
/// `layout.fallbackDoll`, E.19, drawn in code; all sizes are diameters, h =
/// doll height; spec §12.5). Sizes are fractions of the doll height h (w: its
/// width); the head, face and belly are diameters (m7-4 8; every size is one,
/// m7-6 item 20). The splash shows no fallback dolls while its skin decodes
/// (m7-6 item 20, [splashFadeInMs]): they draw only when a skin can't load,
/// never as a placeholder that swaps.
abstract final class FallbackDollTokens {
  /// The splash plank shows no dolls until the skin is decoded, then its three
  /// cherry dolls fade in over this (m7-6 item 20, frame 1.1); fallback dolls
  /// only when a skin can't load, never as a placeholder that swaps.
  static const splashFadeInMs = 200;

  /// The head circle's diameter (`circle, diameter 0.36 h, base color, 3 dp
  /// darker bottom`).
  static const headSize = 0.36;

  /// Its darker bottom band, dp.
  static const headShade = 3.0;

  /// The face disc's diameter.
  static const faceSize = 0.19;

  static const faceColor = Color(0xFFFFF3E0);

  /// The rounded body (`rounded 0.48 h × 0.52 w, base color, darker bottom`).
  static const bodyHeight = 0.48;

  /// Its width ÷ the doll width.
  static const bodyWidth = 0.52;

  /// The body's corner radius ÷ the doll height h (m7-6 item 20: `every size
  /// here is a diameter; body is a rounded rect 0.48 h tall × 0.52 w wide (w =
  /// doll width), corner radius 0.16 h`).
  static const bodyRadius = 0.16;

  /// The belly disc's diameter, the face colour, with the symbol in ink.
  static const bellySize = 0.2;

  /// No painted details or shine.
  static const noDetails = true;
}

/// Chapter themes (tokens v3 `theme`, spec §12.4): the art's size and safe
/// area, the Shop card crop box, and per chapter its palette and crop. Names
/// and ribbons are copy (the ARB's `chapterName`).
///
/// Chapter themes (spec §12.4). art: portrait SVG, 1290×2796, important
/// content inside the centred 1080×1920 safeArea; the app draws it at the
/// screen width, top-aligned. palette: this chapter's UI accents. accentTop →
/// accent is the vertical gradient of chapter-coloured surfaces (the chapter
/// ribbon 4.7, the Chapters card header and progress fill), accentEdge is
/// their solid bottom edge and text shadow (0 2px 0), onAccent is the Fredoka
/// text on them, soft + ink are a tinted chip and its text (7:1 or better),
/// band is the art's flat top band (behind the HUD and status bar, and the
/// fill shown while the art loads). thumb: the Shop theme card crop (7.7) in
/// art px, at the card's 158:74 ratio; cut it from the art and draw it at
/// 158×74 dp. figurine: the family the chapter awards (museum/).
abstract final class ChapterThemeTokens {
  /// The art's px size.
  static const artSize = Size(1290.0, 2796.0);

  /// Important content stays inside this, in art px.
  static const safeArea = Rect.fromLTWH(105.0, 438.0, 1080.0, 1920.0);

  /// The Shop theme card, dp; every `thumb` crop has its ratio.
  static const thumbBox = Size(158.0, 74.0);

  /// Chapter 1, "Sunny Toy Shop" (`theme.chapters.1`).
  static const ch01 = ChapterThemeToken(
    chapter: 1,
    id: 'ch01',
    palette: ChapterPalette(
      band: Color(0xFFFBEAD0),
      accentTop: Color(0xFFDA942C),
      accent: Color(0xFFBC7D1B),
      accentEdge: Color(0xFF8A5B0F),
      onAccent: Color(0xFFFFFFFF),
      soft: Color(0xFFFCECD9),
      ink: Color(0xFF6A4405),
      ribbonTail: Color(0xFFA46B0B),
      ribbonFold: Color(0xFF65420A),
    ),
    thumb: Rect.fromLTWH(105.0, 700.0, 1080.0, 506.0),
  );

  /// Chapter 2, "Rainy Café Corner" (`theme.chapters.2`).
  static const ch02 = ChapterThemeToken(
    chapter: 2,
    id: 'ch02',
    palette: ChapterPalette(
      band: Color(0xFFE9E6E8),
      accentTop: Color(0xFF7B95B0),
      accent: Color(0xFF647D97),
      accentEdge: Color(0xFF41586F),
      onAccent: Color(0xFFFFFFFF),
      soft: Color(0xFFE7F0F8),
      ink: Color(0xFF3C4F62),
      ribbonTail: Color(0xFF526A83),
      ribbonFold: Color(0xFF2B3C4D),
    ),
    thumb: Rect.fromLTWH(105.0, 640.0, 1080.0, 506.0),
  );

  /// Chapter 3, "Seaside Market" (`theme.chapters.3`).
  static const ch03 = ChapterThemeToken(
    chapter: 3,
    id: 'ch03',
    palette: ChapterPalette(
      band: Color(0xFFE6F5F7),
      accentTop: Color(0xFF21A3BC),
      accent: Color(0xFF0789A0),
      accentEdge: Color(0xFF0F5F6F),
      onAccent: Color(0xFFFFFFFF),
      soft: Color(0xFFD9F4FB),
      ink: Color(0xFF105664),
      ribbonTail: Color(0xFF067488),
      ribbonFold: Color(0xFF05414D),
    ),
    thumb: Rect.fromLTWH(105.0, 560.0, 1080.0, 506.0),
  );

  /// Chapter 4, "Snowy Cabin" (`theme.chapters.4`).
  static const ch04 = ChapterThemeToken(
    chapter: 4,
    id: 'ch04',
    palette: ChapterPalette(
      band: Color(0xFFEEF1F5),
      accentTop: Color(0xFF6FA8DC),
      accent: Color(0xFF3E7FC0),
      accentEdge: Color(0xFF2B5E93),
      onAccent: Color(0xFFFFFFFF),
      soft: Color(0xFFDCEBFA),
      ink: Color(0xFF194F81),
      ribbonTail: Color(0xFF2B6BA9),
      ribbonFold: Color(0xFF1C426A),
    ),
    thumb: Rect.fromLTWH(105.0, 700.0, 1080.0, 506.0),
  );

  /// Chapter 5, "Night Carnival" (`theme.chapters.5`).
  static const ch05 = ChapterThemeToken(
    chapter: 5,
    id: 'ch05',
    palette: ChapterPalette(
      band: Color(0xFF2C305F),
      accentTop: Color(0xFF8E7CD4),
      accent: Color(0xFF7764BA),
      accentEdge: Color(0xFF533F8D),
      onAccent: Color(0xFFFFFFFF),
      soft: Color(0xFFEEECFF),
      ink: Color(0xFF4F4080),
      ribbonTail: Color(0xFF6451A3),
      ribbonFold: Color(0xFF382862),
    ),
    thumb: Rect.fromLTWH(105.0, 560.0, 1080.0, 506.0),
  );

  /// Chapter 6, "Spring Garden Shed" (`theme.chapters.6`).
  static const ch06 = ChapterThemeToken(
    chapter: 6,
    id: 'ch06',
    palette: ChapterPalette(
      band: Color(0xFFEEF6E6),
      accentTop: Color(0xFF67AC5F),
      accent: Color(0xFF4E9347),
      accentEdge: Color(0xFF2A6B25),
      onAccent: Color(0xFFFFFFFF),
      soft: Color(0xFFE4F4E1),
      ink: Color(0xFF275B22),
      ribbonTail: Color(0xFF3C7F35),
      ribbonFold: Color(0xFF1B4B17),
    ),
    thumb: Rect.fromLTWH(105.0, 700.0, 1080.0, 506.0),
  );

  /// Chapter 7, "Puppet Theater" (`theme.chapters.7`).
  static const ch07 = ChapterThemeToken(
    chapter: 7,
    id: 'ch07',
    palette: ChapterPalette(
      band: Color(0xFFF7E6D8),
      accentTop: Color(0xFFDE6676),
      accent: Color(0xFFC24D5F),
      accentEdge: Color(0xFF93283D),
      onAccent: Color(0xFFFFFFFF),
      soft: Color(0xFFFFE8E9),
      ink: Color(0xFF812A39),
      ribbonTail: Color(0xFFAA3A4D),
      ribbonFold: Color(0xFF681828),
    ),
    thumb: Rect.fromLTWH(105.0, 600.0, 1080.0, 506.0),
    boardArtDir: 'board/ch07/',
  );

  /// Chapter 8, "Autumn Bandstand" (`theme.chapters.8`).
  static const ch08 = ChapterThemeToken(
    chapter: 8,
    id: 'ch08',
    palette: ChapterPalette(
      band: Color(0xFFFBEBD5),
      accentTop: Color(0xFFDC7A44),
      accent: Color(0xFFC16229),
      accentEdge: Color(0xFF90410A),
      onAccent: Color(0xFFFFFFFF),
      soft: Color(0xFFFFEADF),
      ink: Color(0xFF7C3503),
      ribbonTail: Color(0xFFAA4F12),
      ribbonFold: Color(0xFF672C04),
    ),
    thumb: Rect.fromLTWH(105.0, 680.0, 1080.0, 506.0),
    boardArtDir: 'board/ch08/',
  );

  /// Chapter 9, "Castle Library" (`theme.chapters.9`).
  static const ch09 = ChapterThemeToken(
    chapter: 9,
    id: 'ch09',
    palette: ChapterPalette(
      band: Color(0xFFEFE9F4),
      accentTop: Color(0xFFAD6EB1),
      accent: Color(0xFF945798),
      accentEdge: Color(0xFF6B346F),
      onAccent: Color(0xFFFFFFFF),
      soft: Color(0xFFF9E8FA),
      ink: Color(0xFF67396A),
      ribbonTail: Color(0xFF7F4583),
      ribbonFold: Color(0xFF49204C),
    ),
    thumb: Rect.fromLTWH(105.0, 620.0, 1080.0, 506.0),
    boardArtDir: 'board/ch09/',
  );

  /// Chapter 10, "Sunrise Lookout" (`theme.chapters.10`).
  static const ch10 = ChapterThemeToken(
    chapter: 10,
    id: 'ch10',
    palette: ChapterPalette(
      band: Color(0xFFF8E6DA),
      accentTop: Color(0xFF3AA697),
      accent: Color(0xFF148D7F),
      accentEdge: Color(0xFF016359),
      onAccent: Color(0xFFFFFFFF),
      soft: Color(0xFFDAF6F0),
      ink: Color(0xFF055A50),
      ribbonTail: Color(0xFF10776B),
      ribbonFold: Color(0xFF04443D),
    ),
    thumb: Rect.fromLTWH(105.0, 720.0, 1080.0, 506.0),
    boardArtDir: 'board/ch10/',
  );

  /// Every chapter theme, in chapter order.
  static const List<ChapterThemeToken> chapters = [
    ch01,
    ch02,
    ch03,
    ch04,
    ch05,
    ch06,
    ch07,
    ch08,
    ch09,
    ch10,
  ];
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

  /// tokens.json `motion.pick.wobbleToMoveMs`.
  static const pickWobbleToMoveMs = 80;

  /// When a wobbling doll is dropped its rotation eases to 0 over
  /// [pickWobbleToMoveMs] of doll_move with this curve, overlapped, so the move
  /// starts at once and never snaps (m7-5).
  static const Cubic pickWobbleToMoveCurve = curveEaseOut;

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

  /// An invalid drift onto an empty stand, glass case or ice slot ends at the
  /// target base − this × the mover's own height, the mover drawn in front of
  /// the case or the ice (m7-6, Choices 21).
  static const invalidEmptyTargetStop = 0.5;

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

  /// tokens.json `motion.tagPop.duration`.
  static const tagPopMs = 240;

  /// tokens.json `motion.tagPop.from`.
  static const tagPopFrom = 0.6;

  /// tokens.json `motion.tagPop.easing`.
  static const Cubic tagPopCurve = curveEaseOutBack;

  /// tokens.json `motion.rowOfFive.duration`.
  static const rowOfFiveMs = 280;

  /// tokens.json `motion.rowOfFive.easing`.
  static const Cubic rowOfFiveCurve = curveEaseInOut;

  /// tokens.json `motion.tapFeedback.emptyStand.dip`.
  static const tapDip = 2.0;

  /// tokens.json `motion.tapFeedback.emptyStand.ms`.
  static const tapDipMs = 80;

  /// tokens.json `motion.tapFeedback.lockedCase.padlockScale`.
  static const padlockPingScale = 1.15;

  /// tokens.json `motion.tapFeedback.lockedCase.ms`.
  static const padlockPingMs = 160;

  /// tokens.json `motion.tapFeedback.iced.counterScale`.
  static const iceBumpScale = 1.2;

  /// tokens.json `motion.tapFeedback.iced.ms`.
  static const iceBumpMs = 160;

  /// A valid drop target under a drag: "fx_select_glow at 60 %".
  static const dragHoverGlowOpacity = 0.6;

  /// tokens.json `motion.extraSlot.stopUnderDollMs`.
  static const extraSlotStopUnderDollMs = 150;

  /// tokens.json `motion.extraSlot.restFrame`.
  static const extraSlotRestFrame = 0;
}
