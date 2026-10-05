import 'package:nesty_render/src/tokens/render_tokens.gen.dart';

/// Every number the board layout uses, in the design's **reference units**:
/// logical px on the 390×844 frame of `design/prototypes/NestyBoard.dc.html`
/// (spec §10.3). `BoardLayout` maps them to the device with one scale.
///
/// Where tokens.json carries a value it comes from the generated
/// [BoardTokens], so a design change flows in through `gen_design_tokens`.
/// The rest are read off the prototype and cited as `NestyBoard:<line>`, or
/// come from docs/plans/design-foundation-m2-design.md §1 ("render §1").
/// Sizes that tokens.json stores as a `Size` are repeated here as plain
/// doubles, because `Size.width` isn't a constant expression; a test pins
/// each one to its token.
abstract final class BoardLayoutConstants {
  // ── Reference frame (render §1) ───────────────────────────────────────

  /// Width of the design frame. NestyBoard:11 (`width:390px`).
  static const referenceWidth = 390.0;

  /// Height of the design screen. NestyBoard:11 (`height:844px`).
  static const referenceHeight = 844.0;

  /// The HUD ends under the family counter: 116 + 26 = 142 on the reference
  /// screen, i.e. 83 below the 59 dp safe top. NestyBoard:25/31.
  static const hudBottomInset =
      BoardTokens.familyCounterTop +
      BoardTokens.familyCounterHeight -
      BoardTokens.referenceSafeTop;

  /// The booster bar starts 76 above the safe bottom: 844 − 34 − 734.
  /// NestyBoard:41 (`top:734px`).
  static const barTopInset = 76.0;

  /// Top of the reference board frame (y 142 on the design screen).
  static const frameTop =
      BoardTokens.familyCounterTop + BoardTokens.familyCounterHeight;

  /// Bottom of the reference board frame: the booster bar top (y 734).
  static const frameBottom = BoardTokens.boosterBarTop;

  /// 592: the board frame is 390 × 592 (render §1).
  static const frameHeight = frameBottom - frameTop;

  /// Tablets stop growing the board here, so dolls don't turn into posters
  /// (render §1: `s = min(W/390, h/592, 1.5)`).
  static const maxScale = 1.5;

  /// A viewport with no area (a widget test before layout, a collapsed
  /// admin panel) still gets a positive scale, so nothing is NaN.
  static const minScale = 0.01;

  /// Family counter centre, below the safe top: 116 + 26/2 − 59 = 70
  /// (render §1: the completed set flies to `(W/2, padding.top + 70)`).
  static const familyCounterCenterInset =
      BoardTokens.familyCounterTop +
      BoardTokens.familyCounterHeight / 2 -
      BoardTokens.referenceSafeTop;

  // ── Rows and columns ──────────────────────────────────────────────────

  /// Row centre line. NestyBoard:161 (`cx = 195 + …`).
  static const centerX = referenceWidth / 2;

  /// Max slot pitch. NestyBoard:159 (`Math.min(96, 372 / n)`).
  static const slotPitchMax = BoardTokens.slotWidthMax;

  /// The row width a crowded row divides. NestyBoard:159.
  static const slotRowWidth = BoardTokens.slotRowWidth;

  /// A row can hold 4 authored slots plus 2 extras (D22, m1 design owner
  /// override on the bottom shelf).
  static const maxSlotsPerRow = 6;

  /// Spec §2.1: a board has 1–4 shelves.
  static const minShelves = 1;
  static const maxShelves = 4;

  /// A stand is `min(90, pitch − 2.4)` wide (tokens.json `layout.boardFit.
  /// standWidth`; the design's row of 5 is 72 = 74.4 − 2.4 wide), so it
  /// keeps its designed size at a pitch of 92.4 or more and shrinks below.
  static const standPitchInset = BoardFitTokens.standPitchInset;

  // ── Plank and stand ───────────────────────────────────────────────────

  /// NestyBoard:12 (`height:40px`).
  static const plankHeight = BoardTokens.plankHeight;

  /// NestyBoard:163 (`cx - 45, top, 90, …`). Pinned to [BoardTokens.standSize].
  static const standWidth = 90.0;

  /// NestyBoard:161/163 (`tw ? 39 : 34`). Pinned to [BoardTokens.standSize].
  static const standHeight = 34.0;

  /// NestyBoard:161/163. Pinned to [BoardTokens.towerStandSize].
  static const towerStandHeight = 39.0;

  /// Stands sink 9 dp into the plank. NestyBoard:161 (`pt + 9 − …`).
  static const standBottomInset = 9.0;

  /// Doll base below the stand top. NestyBoard:161 (`surf = top + 12.3`).
  static const standSurfaceOffset = BoardTokens.standSurfaceOffset;

  /// The stand's surface above its plank's top: 34 − 9 − 12.3 = 12.7 (the
  /// `layout.boardFit` vertical and HUD limits' "standSurfaceOffset").
  static const standSurfaceAbovePlank =
      standHeight - standBottomInset - standSurfaceOffset;

  /// A tower stand's surface above its plank's top: 39 − 9 − 12.3 = 17.7
  /// (`layout.towerStack.rule`, "towerSurface = plankTop − 17.7").
  static const towerSurfaceAbovePlank =
      towerStandHeight - standBottomInset - standSurfaceOffset;

  // ── Pips (spec §10.3) ─────────────────────────────────────────────────

  /// Pip centre below the stand top. NestyBoard:164 (`top + 24 − 3`, where
  /// 3 is the pip radius).
  static const pipCenterOffset = 24.0;

  /// Same on the taller tower stand. NestyBoard:164 (`top + 31.9 − 3`).
  static const towerPipCenterOffset = 31.9;

  /// NestyBoard:14 (`width:6px`).
  static const pipDiameter = BoardTokens.pipSize;

  /// NestyBoard:164 (`k * 7.8`).
  static const pipPitch = BoardTokens.pipPitch;

  // ── Dolls ─────────────────────────────────────────────────────────────

  /// Doll base in the 512×768 skin artboard: the rect top is
  /// `base − h·742/768`. NestyBoard:152, render §1 ("base = art (256,742)").
  static const dollArtBaseY = 742.0;

  /// NestyBoard:152 and `SkinTokens.artboard`.
  static const dollArtHeight = 768.0;

  /// `w = h·2/3`. NestyBoard:152 and `SkinTokens.artboard` (512 / 768).
  static const dollAspect = 2 / 3;

  /// D21 (owner override of NestyBoard:168): each buried tower nest is drawn
  /// at its true size, its base raised this much per depth.
  static const towerDepthRaise = BoardTokens.towerDepthRaise;

  /// Spec §3.2: a tower is at most 4 deep, so at most 3 nests lie under its
  /// top (`LayoutLimits.maxTowerDepth − 1` in nesty_core, which this pure
  /// layout doesn't import).
  static const maxBuriedNests = 3;

  // ── Slot decorations ──────────────────────────────────────────────────

  /// Selection / hint-target glow. NestyBoard:167
  /// (`cx - 58, surf - 28, 116, 52`).
  static const glowRingOffsetX = -58.0;
  static const glowRingOffsetY = -28.0;
  static const glowRingWidth = 116.0;
  static const glowRingHeight = 52.0;

  /// Walnut "+N" tag top-left. NestyBoard:168 (`cx + 21, top + 16`).
  static const towerTagOffsetX = 21.0;
  static const towerTagOffsetY = 16.0;

  /// Glass case. NestyBoard:169 (`ct = surf − 134`, case `cx − 43, ct, 86,
  /// 143`). Width/height pinned to [BoardTokens.glassCaseSize].
  static const glassCaseTopAboveSurface = 134.0;
  static const glassCaseWidth = 86.0;
  static const glassCaseHeight = 143.0;

  /// The sealed doll stands on the case floor. NestyBoard:169
  /// (`doll(…, ct + 123, h)`).
  static const lockedDollBaseBelowCaseTop = 123.0;

  /// Padlock symbol centre: 244/300 of the case art height (116.3 dp).
  /// NestyBoard:169 (`ct + 244 / 300 * 143 − 6`, 6 = half the symbol).
  static const padlockCenterBelowCaseTop = glassCaseHeight * 244 / 300;

  /// NestyBoard:15 (`width:12px;height:12px`).
  static const padlockSymbolSize = 12.0;

  /// Ice overlay. NestyBoard:180 (`it = pt + 16.5 − height`, `cx − 48, it, 96,
  /// height`): its bottom is 16.5 below the plank's top, i.e. 7.5 below the
  /// stand's bottom, on every stand (a tower's too, m7-3 `iceTower`). On an
  /// open stand that is 29.2 below the surface: `fx_ice`'s doll base (90,
  /// 170.8) to its ice bottom (90, 200), LOTTIE.md. Width/height pinned to
  /// [BoardTokens.iceOverlaySize].
  static const iceBottomBelowStandBottom =
      BoardTokens.iceTopFromPlank - standBottomInset;
  static const iceWidth = 96.0;
  static const iceHeight = 160.0;

  /// Blue counter badge top-left. NestyBoard:180 (`cx + 22, it + 2`) and
  /// NestyBoard:17 (`28px`).
  static const iceBadgeOffsetX = 22.0;
  static const iceBadgeOffsetY = 2.0;
  static const iceBadgeSize = 28.0;

  /// Hint arrow above the source doll's top. NestyBoard:208
  /// (`s.cx − 20, s.dt − 58, 40, 50`).
  static const hintArrowOffsetX = -20.0;
  static const hintArrowOffsetY = -58.0;
  static const hintArrowWidth = 40.0;
  static const hintArrowHeight = 50.0;

  /// How far the arrow rises at the top of its bob: `ui_hint_arrow`'s
  /// `arrow_bob` null goes from y 45 to 35 (LOTTIE.md v3), in `fs` units.
  static const hintArrowBob = 10.0;

  // ── Hint arrow vs the HUD (owner, 2026-09-27; BACKLOG "Design gaps") ──
  // The HUD isn't scaled with the board, so these are screen dp below the
  // safe-area top (GameplayHud), not reference units.

  /// The HUD's button row ends under the pause button: 62 − 59 + 48 = 51
  /// (the level pill ends at 49, the coin pill at 47). The pause button's
  /// height is pinned to [BoardTokens.hudPauseButtonSize] by a test.
  static const hudRowBottomInset =
      BoardTokens.hudTop - BoardTokens.referenceSafeTop + hudPauseButtonHeight;
  static const hudPauseButtonHeight = 48.0;

  /// `layout.hintMiddle.clampTop` (m7-4 5.4): the arrow's highest bob point
  /// stays 4 below the level pill, which ends 49 below the safe top (112 on
  /// the 59 dp reference). Over the family counter the arrow keeps its rest
  /// pose, so this is the only clamp it gets.
  static const hintClampTopInset = 49.0 + hintArrowHudGap;

  /// `ui_family_counter`'s own walnut pill, 70 × 26, centred on the
  /// counter (LOTTIE.md v3); it ends at [hudBottomInset].
  static const familyCounterPillWidth = 70.0;

  /// Space the arrow keeps from a HUD piece, in dp.
  static const hintArrowHudGap = 4.0;

  /// The arrow moves sideways off the counter pill by at most this share
  /// of the column pitch, so it stays over its doll's head (a 4-slot row's
  /// inner columns need about 10 dp of their 94).
  static const hintArrowMaxNudge = 0.25;

  /// The arrow moves down, under the HUD, by at most this (× `fs`): at
  /// rest its tip then reaches 8 below the doll's top, not its face.
  static const hintArrowMaxDrop = 16.0;

  // ── Hit testing (spec §10.3) ──────────────────────────────────────────

  /// "Tap targets are at least 48 dp. The whole slot column is the hit area."
  static const minHitExtent = BoardTokens.minHitExtent;

  // ── Motion owned by the layout ────────────────────────────────────────

  /// The bottom row re-pitches over this long when an extra slot is added
  /// (tokens.json `motion.rowOfFive`, 280 ms `easeInOut`; D181).
  static const extraSlotRepitchMs = MotionTokens.rowOfFiveMs;
}
