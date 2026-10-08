import 'dart:math' as math;
import 'dart:ui' show Offset, Rect;

import 'package:nesty_render/src/board/board_layout_constants.dart';
import 'package:nesty_render/src/board/board_shape.dart';
import 'package:nesty_render/src/board/shelf_presets.dart';
import 'package:nesty_render/src/tokens/render_tokens.gen.dart';

typedef _K = BoardLayoutConstants;

/// Maps reference units (the 390×592 board frame, y 142…734 on the design
/// screen) to logical px on the device: one uniform [scale] and an origin
/// that centres the frame in the board area (render §1).
///
/// Every board Lottie is placed through it (docs/plans/m2-lottie-design.md
/// §5, PROGRESS D46), so each authored distance scales with the board and
/// the placement equals LOTTIE.md's on the 390×844 reference screen.
final class BoardFit {
  BoardFit({required this.scale, required this.originX, required this.originY})
    : frame = Rect.fromLTWH(
        originX,
        originY,
        _K.referenceWidth * scale,
        _K.frameHeight * scale,
      ),
      boardSpaceOrigin = Offset(originX, originY - _K.frameTop * scale);

  /// Logical px per reference px. 1 on the 390×844 reference screen.
  final double scale;

  /// Where reference x = 0 lands.
  final double originX;

  /// Where reference y = [BoardLayoutConstants.frameTop] (142) lands.
  final double originY;

  /// The 390×592 reference frame on the device.
  final Rect frame;

  /// Where the 390×844 reference screen's top-left lands: `(originX,
  /// originY − 142·s)`. A board-space Lottie (`doll_move`, `doll_complete`,
  /// `doll_invalid`, `ui_drag_hand`) is translated here and scaled by
  /// [scale], so its canvas is exactly the reference screen (§5).
  final Offset boardSpaceOrigin;

  double x(double referenceX) => originX + referenceX * scale;

  double y(double referenceY) => originY + (referenceY - _K.frameTop) * scale;

  double length(double reference) => reference * scale;

  /// The inverse of [x]: the reference x of logical [x].
  double referenceX(double x) => (x - originX) / scale;

  /// The inverse of [y]: the reference y of logical [y].
  double referenceY(double y) => (y - originY) / scale + _K.frameTop;

  /// The inverse of [length].
  double referenceLength(double length) => length / scale;

  /// A logical point in reference units: the board-space files' travel
  /// remap takes `src` and `dst` this way (§5, §6). Allocates the
  /// [Offset]: call it per event, not per frame ([referenceX] and
  /// [referenceY] don't allocate).
  Offset toReference(double x, double y) =>
      Offset(referenceX(x), referenceY(y));
}

/// Everything a painter or hit test needs for one slot, in logical px.
///
/// All fields are computed once when the board is laid out; the methods are
/// arithmetic on them. Methods that return a [Rect] allocate it, so per-frame
/// code (NestComponent, the timeline) should use the `…Y`/`…X` accessors,
/// which don't.
/// Where the gameplay HUD sits over the board, in logical px: the button
/// row across the top (pause, level pill, coins) and the family counter's
/// pill centred under it. The HUD isn't scaled with the board, so the hint
/// arrow clears it in screen units ([SlotGeometry.hintArrowCenterY]). One
/// per layout, shared by every slot.
final class HudClearance {
  const HudClearance({
    required this.rowBottom,
    required this.counterLeft,
    required this.counterRight,
    required this.counterBottom,
  });

  /// The HUD laid out from a safe-area top of [safeTop] on a screen
  /// [width] wide (GameplayHud): the row ends 51 below the safe top and the
  /// 70-wide pill, centred, 83 below it.
  factory HudClearance.of({required double width, required double safeTop}) {
    final center = width / 2;
    return HudClearance(
      rowBottom: safeTop + _K.hudRowBottomInset,
      counterLeft: center - _K.familyCounterPillWidth / 2,
      counterRight: center + _K.familyCounterPillWidth / 2,
      counterBottom: safeTop + _K.hudBottomInset,
    );
  }

  /// Bottom of the pause button, the lowest piece of the top row.
  final double rowBottom;

  /// The family counter pill's sides and bottom.
  final double counterLeft;
  final double counterRight;
  final double counterBottom;
}

final class SlotGeometry {
  /// Derives the slot's geometry from its reference-frame position. Called by
  /// `BoardLayout.compute`; every constant is cited in
  /// [BoardLayoutConstants].
  factory SlotGeometry({
    required SlotShape shape,
    required int row,
    required int column,
    required int index,
    required double centerXRef,
    required double pitchRef,
    required double plankTopRef,
    required double pieceScale,
    required double hitTop,
    required double hitBottom,
    required BoardFit fit,
    required List<double> dollHeights,
    required HudClearance hud,
    double? plankAboveRef,
    double iceHeightRef = _K.iceHeight,
    bool tallIce = false,
    double overlayK = 1,
  }) {
    final q = pieceScale;
    // The glass case and the ice scale with the stand (`q`) about their
    // bottom centre, and on four shelves also with the dolls' factor
    // [overlayK] about the stand surface (tokens.json `layout.boardPresets.
    // fourShelves.pieces`, m7-4 5.1, 5.2): 1 on every other preset.
    final qo = q * overlayK;
    final tower = shape.kind == SlotShapeKind.tower;
    final standBottomRef = plankTopRef + _K.standBottomInset;
    final standTopRef =
        standBottomRef - (tower ? _K.towerStandHeight : _K.standHeight) * q;
    final surfaceRef = standTopRef + _K.standSurfaceOffset * q;
    // The ice's bottom is 16.5 below the plank's top on every stand (the
    // design's `it = pt + 16.5 − height`, a tower's too), its top the
    // preset's height above.
    // On four shelves the ice's bottom keeps its distance below the stand
    // surface scaled by [overlayK], so the ice scales about that surface.
    final iceBottom0Ref = standBottomRef + _K.iceBottomBelowStandBottom * q;
    final iceBottomRef = surfaceRef + (iceBottom0Ref - surfaceRef) * overlayK;
    final iceTopRef = iceBottomRef - iceHeightRef * qo;

    // The tall glass case (m7-3 `layout.board.glassCaseTall`): a sealed
    // size-5 or size-6 doll, taller than a normal case was drawn for
    // (117.5 dp at the design's scale), gets a case that follows its own
    // height, and stands on the stand instead of the plinth.
    final sealedSize = shape.lockedSize;
    final sealedHeight =
        shape.kind == SlotShapeKind.locked &&
            sealedSize != null &&
            sealedSize >= 1 &&
            sealedSize <= dollHeights.length
        ? dollHeights[sealedSize - 1]
        : null;
    final tallCase =
        sealedHeight != null &&
        sealedHeight / fit.scale > GlassCaseTallTokens.minDollHeight * q;
    // The case follows the doll's height h, but never grows wider than its
    // column less 2 dp (a safety net: on a row of 6 a tall case is at most
    // 59.8 wide under boardFit's horizontal limit, so it never bites, m7-6
    // Choices 19): then it is the case of a doll of `caseHeight`, and
    // the composition's `case_size` follows it (the doll itself stays h).
    final caseHeight = tallCase
        ? math.min(
            sealedHeight,
            (fit.length(pitchRef) -
                    BoardTokens.tallGlassPitchInset * fit.scale) /
                GlassCaseTallTokens.widthPerHeight,
          )
        : 0.0;
    final caseTopRef = surfaceRef - _K.glassCaseTopAboveSurface * qo;
    final lockedBaseRef = caseTopRef + _K.lockedDollBaseBelowCaseTop * qo;

    final pitch = fit.length(pitchRef);
    final centerX = fit.x(centerXRef);
    // The whole column is the hit area, never narrower than 48 dp (spec
    // §10.3). Below 48 neighbours overlap and [BoardGeometry.slotAt] picks
    // the nearest centre.
    final hitHalfWidth =
        (pitch > _K.minHitExtent ? pitch : _K.minHitExtent) / 2;

    Rect box(
      double leftRef,
      double topRef,
      double widthRef,
      double heightRef,
    ) => Rect.fromLTWH(
      fit.x(leftRef),
      fit.y(topRef),
      fit.length(widthRef),
      fit.length(heightRef),
    );

    return SlotGeometry._(
      shape: shape,
      row: row,
      column: column,
      index: index,
      centerX: centerX,
      pitch: pitch,
      pieceScale: q,
      furnitureScale: fit.scale * q,
      overlayFurnitureScale: fit.scale * qo,
      plankTop: fit.y(plankTopRef),
      standRect: Rect.fromLTRB(
        fit.x(centerXRef - _K.standWidth / 2 * q),
        fit.y(standTopRef),
        fit.x(centerXRef + _K.standWidth / 2 * q),
        fit.y(standBottomRef),
      ),
      surfaceY: fit.y(surfaceRef),
      pipCenterY: fit.y(
        standTopRef +
            (tower ? _K.towerPipCenterOffset : _K.pipCenterOffset) * q,
      ),
      pipDiameter: fit.length(_K.pipDiameter),
      pipPitch: fit.length(_K.pipPitch),
      glowRingRect: box(
        centerXRef + _K.glowRingOffsetX * q,
        surfaceRef + _K.glowRingOffsetY * q,
        _K.glowRingWidth * q,
        _K.glowRingHeight * q,
      ),
      towerTagOrigin: Offset(
        fit.x(centerXRef + _K.towerTagOffsetX * q),
        fit.y(standTopRef + _K.towerTagOffsetY * q),
      ),
      usesTallCase: tallCase,
      tallCaseHeight: tallCase ? caseHeight : null,
      glassCaseRect: tallCase
          ? _tallCaseRect(centerX, fit.y(surfaceRef), caseHeight)
          : box(
              centerXRef - _K.glassCaseWidth / 2 * qo,
              caseTopRef,
              _K.glassCaseWidth * qo,
              _K.glassCaseHeight * qo,
            ),
      lockedDollBaseY: tallCase ? fit.y(surfaceRef) : fit.y(lockedBaseRef),
      padlockSymbolCenter: Offset(
        centerX,
        tallCase
            ? _tallCaseRect(centerX, fit.y(surfaceRef), caseHeight).top +
                  GlassCaseTallTokens.lockCenter *
                      GlassCaseTallTokens.heightPerHeight *
                      caseHeight
            : fit.y(caseTopRef + _K.padlockCenterBelowCaseTop * qo),
      ),
      padlockSymbolSize: fit.length(_K.padlockSymbolSize * qo),
      iceRect: box(
        centerXRef - _K.iceWidth / 2 * qo,
        iceTopRef,
        _K.iceWidth * qo,
        iceHeightRef * qo,
      ),
      iceBadgeRect: box(
        centerXRef + _K.iceBadgeOffsetX * qo,
        iceTopRef + _K.iceBadgeOffsetY * qo,
        _K.iceBadgeSize * qo,
        _K.iceBadgeSize * qo,
      ),
      hitRect: Rect.fromLTRB(
        centerX - hitHalfWidth,
        hitTop,
        centerX + hitHalfWidth,
        hitBottom,
      ),
      glassCompositionOrigin: tallCase
          ? Offset(
              centerX - glassTallCompositionAnchor.dx * fit.scale * qo,
              fit.y(surfaceRef) -
                  glassTallCompositionAnchor.dy * fit.scale * qo,
            )
          : Offset(
              centerX - glassCompositionAnchor.dx * fit.scale * qo,
              fit.y(lockedBaseRef) - glassCompositionAnchor.dy * fit.scale * qo,
            ),
      iceCompositionOrigin: Offset(
        centerX - iceCompositionAnchor.dx * fit.scale * qo,
        fit.y(iceBottomRef) -
            iceCompositionAnchor.dy *
                fit.scale *
                qo *
                (tallIce ? BoardTokens.iceTallFxScaleY : 1),
      ),
      iceFxScaleY: tallIce ? BoardTokens.iceTallFxScaleY : 1,
      iceDollBaseY:
          fit.y(iceBottomRef) -
          _iceDollAboveBottom *
              fit.scale *
              qo *
              (tallIce ? BoardTokens.iceTallFxScaleY : 1),
      pipScale: fit.scale,
      // The tower stack (m7-3 `layout.towerStack`), in reference units: the
      // room between the tower stand's surface and the limit above it, the
      // ice's top (+ 8) lifting the limit of an iced tower.
      towerRoomRef: _roomRef(
        plankTopRef: plankTopRef,
        plankAboveRef: plankAboveRef,
        q: q,
        iceTopRef: iceTopRef,
      ),
      towerRoomIcedRef: _roomRef(
        plankTopRef: plankTopRef,
        plankAboveRef: plankAboveRef,
        q: q,
        iceTopRef: iceTopRef,
        iced: true,
      ),
      dollHeights: dollHeights,
      hud: hud,
    );
  }

  /// The tall case's box for a sealed doll [h] tall standing on [surfaceY]:
  /// `0.62h × 1.0133h`, centred, its bottom at surface + 0.02667h.
  static Rect _tallCaseRect(double centerX, double surfaceY, double h) {
    final width = GlassCaseTallTokens.widthPerHeight * h;
    final height = GlassCaseTallTokens.heightPerHeight * h;
    final bottom = surfaceY + GlassCaseTallTokens.bottomPerHeight * h;
    return Rect.fromLTWH(centerX - width / 2, bottom - height, width, height);
  }

  /// `hRoom = (towerSurface − limit) / drawnHeight` for the tower stack:
  /// `towerSurface = plankTop − 17.7 q`, `limit` = 150 on the top shelf,
  /// else the plank above's top + 40 + 2; an iced tower's limit is at least
  /// the ice's top + 8 (`layout.icedTower`).
  static double _roomRef({
    required double plankTopRef,
    required double? plankAboveRef,
    required double q,
    required double iceTopRef,
    bool iced = false,
  }) {
    var limit = plankAboveRef == null
        ? BoardFitTokens.hudClearY
        : plankAboveRef + _K.plankHeight + BoardFitTokens.headroom;
    if (iced) limit = math.max(limit, iceTopRef + IcedTowerTokens.iceTopGap);
    final surface = plankTopRef - _K.towerSurfaceAbovePlank * q;
    return (surface - limit) / BoardFitTokens.drawnHeight;
  }

  SlotGeometry._({
    required this.shape,
    required this.row,
    required this.column,
    required this.index,
    required this.centerX,
    required this.pitch,
    required this.pieceScale,
    required this.furnitureScale,
    required this.overlayFurnitureScale,
    required this.plankTop,
    required this.standRect,
    required this.surfaceY,
    required this.pipCenterY,
    required this.pipDiameter,
    required this.pipPitch,
    required this.glowRingRect,
    required this.towerTagOrigin,
    required this.usesTallCase,
    required this.tallCaseHeight,
    required this.glassCaseRect,
    required this.lockedDollBaseY,
    required this.padlockSymbolCenter,
    required this.padlockSymbolSize,
    required this.iceRect,
    required this.iceBadgeRect,
    required this.hitRect,
    required this.glassCompositionOrigin,
    required this.iceCompositionOrigin,
    required this.iceFxScaleY,
    required this.iceDollBaseY,
    required this.pipScale,
    required double towerRoomRef,
    required double towerRoomIcedRef,
    required List<double> dollHeights,
    required HudClearance hud,
  }) : _towerRoomRef = towerRoomRef,
       _towerRoomIcedRef = towerRoomIcedRef,
       _dollHeights = dollHeights,
       _hud = hud;

  final SlotShape shape;

  String get id => shape.id;

  SlotShapeKind get kind => shape.kind;

  /// Shelf index, top to bottom.
  final int row;

  /// Position in its shelf, left to right.
  final int column;

  /// Row-major index into [BoardGeometry.slots].
  final int index;

  /// Column centre: the doll base x and the stand centre.
  final double centerX;

  /// Distance between neighbouring column centres on this shelf.
  final double pitch;

  /// How much this slot's pieces are shrunk from the design size: 1 on
  /// designed boards, below 1 on crowded rows and on 4 shelves.
  final double pieceScale;

  /// Logical px per design px for this slot's sprites and text
  /// (`BoardFit.scale × pieceScale`). The stand sprite is
  /// `90 × furnitureScale` wide, the "+N" tag text `12 × furnitureScale`.
  final double furnitureScale;

  /// [furnitureScale] for the glass case and the ice (and their
  /// compositions and sprites): the same on every preset but four shelves,
  /// where those pieces also follow the dolls' fit factor k about the stand
  /// surface (`fourShelves.pieces`, m7-4 5.2), so a case or ice no longer
  /// reaches the shelf above.
  final double overlayFurnitureScale;

  /// Top of this slot's shelf plank.
  final double plankTop;

  /// The stand sprite (`slot-stand-blank`, `tower-base-blank` or
  /// `extra-slot`) box. Its bottom sinks 9 dp into the plank.
  final Rect standRect;

  double get standTop => standRect.top;

  /// Where a doll's base sits on an open, tower or extra slot.
  final double surfaceY;

  /// Pip centres share this y; see [pipCenterX]. The design draws no pips on
  /// an empty extra slot (NestyBoard:164); the geometry exists regardless.
  final double pipCenterY;

  final double pipDiameter;

  /// Distance between pip centres.
  final double pipPitch;

  /// Number of pips: the level's `maxSize` (spec §10.3).
  int get pipCount => _dollHeights.length;

  /// Selection / hint-target glow ring (`glow-ring.svg`).
  final Rect glowRingRect;

  /// Top-left of the walnut "+N" tower tag.
  final Offset towerTagOrigin;

  /// Whether this slot's case is the tall one (m7-3
  /// `layout.board.glassCaseTall`): its sealed doll is taller than a normal
  /// case was drawn for, so the case (`BoardSprite.glassCaseTall0..2`,
  /// `fx_glass_unlock_tall`) follows the doll's height and the doll stands
  /// on the stand ([lockedDollBaseY] = [surfaceY]).
  final bool usesTallCase;

  /// For a tall case: the height h (logical px) of the doll the case is
  /// drawn for, the sealed doll's own height, or less where the column is
  /// too narrow for `0.62 h` (a row of 5 or 6). `fx_glass_unlock_tall`'s
  /// `case_size` follows it. Null for a normal case.
  final double? tallCaseHeight;

  /// The glass case sprite box (spec §3.3).
  final Rect glassCaseRect;

  /// Base of the doll sealed inside a glass case: the case floor, or the
  /// stand surface itself in a tall case.
  final double lockedDollBaseY;

  /// Centre of the unlock colour's symbol on the padlock.
  final Offset padlockSymbolCenter;

  final double padlockSymbolSize;

  /// The ice overlay sprite box (spec §3.4); it covers stand and doll.
  final Rect iceRect;

  /// The blue ice counter badge.
  final Rect iceBadgeRect;

  /// The whole column between the shelf above and this plank's bottom, at
  /// least 48×48 (spec §10.3).
  final Rect hitRect;

  /// `fx_glass_unlock`'s doll base in its 180×240 canvas (LOTTIE.md
  /// "Files"). Its case's top-left is at (47, 40).
  static const glassCompositionAnchor = Offset(90, 163);

  /// `fx_ice`'s ice bottom in its 180×240 canvas (LOTTIE.md "Files"): the
  /// point placed on (the stand's centre, the ice's bottom). Its ice's
  /// top-left is at (42, 40) and its doll base at (90, 170.8), 29.2 above.
  static const iceCompositionAnchor = Offset(90, 200);

  /// `fx_ice`'s doll base above its ice bottom in its canvas: 200 − 170.8.
  static const _iceDollAboveBottom = 29.2;

  /// `fx_glass_unlock_tall`'s stand surface in its 200×280 canvas (the
  /// `case_size` null; LOTTIE.md m7-3): the doll base rests on it, and the
  /// case's top-left is at (53.5, 64) at 100 %.
  static const glassTallCompositionAnchor = Offset(100, 212);

  /// Top-left of this slot's paused glass composition, drawn at
  /// [furnitureScale] (m2-lottie-design §8): `fx_glass_unlock`'s doll base
  /// ([glassCompositionAnchor]) on ([centerX], [lockedDollBaseY]), which
  /// puts its case on [glassCaseRect]; for a tall case
  /// `fx_glass_unlock_tall`'s stand surface ([glassTallCompositionAnchor])
  /// on ([centerX], [surfaceY]), its `case_size` and `doll_size` following
  /// the doll's height (`FxLayout`).
  final Offset glassCompositionOrigin;

  /// Top-left of this slot's paused `fx_ice` composition at
  /// [furnitureScale] (m2-lottie-design §8): its ice bottom
  /// ([iceCompositionAnchor]) on ([centerX], [iceRect]`.bottom`), which puts
  /// its ice on [iceRect] (`iceRect.topLeft − (42, 40)·fs`) and, on an open
  /// stand, its doll base on the surface. On a tower stand (5·fs higher) the
  /// composition's own doll would sink into the stand, so the slot hides it
  /// and draws the doll itself under the ice. On the tall preset the
  /// composition is stretched by [iceFxScaleY] from the ice bottom and this
  /// is where its top-left lands.
  final Offset iceCompositionOrigin;

  /// Where `fx_ice`'s own anchor, its doll base (90, 170.8), goes so that its
  /// ice bottom (90, 200) lands on [iceRect]'s bottom: the game places the
  /// composition on ([centerX], this) at [furnitureScale], stretched by
  /// [iceFxScaleY]. On an open stand that is [surfaceY] (1.5 dp above it on
  /// the tall preset, where the doll inside is compensated).
  final double iceDollBaseY;

  /// 1, or `BoardTokens.iceTallFxScaleY` (1.05) on `threeShelvesTall`, where
  /// `fx_ice` plays at scale (1, 1.05) from the ice bottom to fill the 96×168
  /// overlay; the doll inside is compensated by dividing its height factor.
  final double iceFxScaleY;

  /// Logical px per design px for the pips: they stay 6 dp at a 7.8 pitch on
  /// a crowded row (`rowOfFive.pips`), so this is the board scale alone.
  final double pipScale;

  final double _towerRoomRef;

  final double _towerRoomIcedRef;

  final List<double> _dollHeights;

  final HudClearance _hud;

  /// Where this slot's resting doll stands: on the case floor for a locked
  /// slot, else on the stand surface.
  double get restingBaseY =>
      shape.kind == SlotShapeKind.locked ? lockedDollBaseY : surfaceY;

  /// Where a locked slot's doll rests once its case has shattered: the stand
  /// surface, [unlockSettle] below the case floor. Since the v3 export
  /// `fx_glass_unlock` lands the doll there itself (its last hop ends at
  /// canvas y 174 = 163 + 11, frame 53); v1 needed a hand-coded settle
  /// (m2-lottie-design §9.2). For other slots it is [restingBaseY].
  double get unlockedDollBaseY => surfaceY;

  /// How far the freed doll drops from the case floor to the stand: 11 dp
  /// at furniture scale 1 (the case floor is `surface − 134 + 123`). The
  /// game no longer adds it by hand (v3's file includes the drop); it stays
  /// as the geometry `fx_glass_unlock`'s landing is checked against.
  double get unlockSettle => surfaceY - lockedDollBaseY;

  /// Centre y of [standRect]: where `ui_extra_slot` pulses (anchor (55, 25)
  /// on the stand centre).
  double get standCenterY => standRect.top + standRect.height / 2;

  /// Centre y of [glowRingRect], `surface − 2·fs`: where `fx_select_glow`'s
  /// anchor (70, 40) goes, at [centerX].
  double get glowCenterY => glowRingRect.top + glowRingRect.height / 2;

  /// Centre x of [hintArrowRect] for a resting doll of [size]: [centerX],
  /// moved sideways off the family counter's pill when the arrow would
  /// reach it at the top of its bob (a 4-slot row's inner columns under a
  /// tall doll). A column the pill sits right over (the middle of an odd
  /// row) can't move that far and keeps [centerX]. Allocation-free.
  double hintArrowCenterX(int size) {
    final dx = _counterClearance(size);
    return dx.abs() <= _K.hintArrowMaxNudge * pitch ? centerX + dx : centerX;
  }

  /// Centre y of [hintArrowRect] for a resting doll of [size],
  /// `dollTop − 33·fs`: where `ui_hint_arrow`'s anchor (30, 45) goes. Where
  /// the top of the arrow's bob would reach the HUD's button row (a tall
  /// top-row doll) it moves down to clear it, by at most `16·fs`, so it
  /// never covers the doll's face. Over the family counter it keeps its
  /// rest pose instead and the counter yields ([hintNeedsCounter], frame
  /// 3.1b, E.20). Allocation-free.
  double hintArrowCenterY(int size) {
    final rest =
        dollTopY(size) +
        (_K.hintArrowOffsetY + _K.hintArrowHeight / 2) * furnitureScale;
    if (hintNeedsCounter(size)) {
      // Frame 3.1b keeps the rest pose, but never above `hintMiddle.
      // clampTop` (m7-4 5.4): down over the doll's head if it must.
      final clamp =
          _hud.rowBottom - _K.hudRowBottomInset + _K.hintClampTopInset;
      final lift = clamp - _arrowPeak(size);
      return lift > 0 ? rest + lift : rest;
    }
    final ceiling = _hud.rowBottom + _K.hintArrowHudGap;
    final drop = ceiling - _arrowPeak(size);
    if (drop <= 0) return rest;
    final maxDrop = _K.hintArrowMaxDrop * furnitureScale;
    return rest + (drop < maxDrop ? drop : maxDrop);
  }

  /// Whether a hint arrow over this slot's resting doll of [size] reaches
  /// the family counter and can't slide off it (tokens.json
  /// `layout.hintMiddle`, E.20): a top-shelf column right under the
  /// counter's pill, the arrow's top above `hudClearY` (the counter's bottom
  /// + 8). The arrow doesn't move; the HUD fades the counter out while the
  /// hint shows and back after it ends. Allocation-free.
  bool hintNeedsCounter(int size) {
    if (row != 0) return false;
    final hud = _hud;
    if (_arrowPeak(size) >= hud.counterBottom + BoardFitTokens.neighbourGap) {
      return false;
    }
    const gap = _K.hintArrowHudGap;
    final half = _K.hintArrowWidth / 2 * furnitureScale;
    final left = hud.counterLeft - gap;
    final right = hud.counterRight + gap;
    if (centerX + half <= left || centerX - half >= right) return false;
    final dx = centerX < (left + right) / 2
        ? left - (centerX + half)
        : right - (centerX - half);
    return dx.abs() > _K.hintArrowMaxNudge * pitch;
  }

  /// The top of the arrow at the top of its bob, before it clears the HUD.
  double _arrowPeak(int size) =>
      dollTopY(size) + (_K.hintArrowOffsetY - _K.hintArrowBob) * furnitureScale;

  /// How far the arrow must move sideways to clear the counter's pill at
  /// the top of its bob: toward the side of the pill its column is on, or
  /// 0 when it doesn't reach the pill.
  double _counterClearance(int size) {
    final hud = _hud;
    const gap = _K.hintArrowHudGap;
    if (_arrowPeak(size) >= hud.counterBottom + gap) return 0;
    final half = _K.hintArrowWidth / 2 * furnitureScale;
    final left = hud.counterLeft - gap;
    final right = hud.counterRight + gap;
    if (centerX + half <= left || centerX - half >= right) return 0;
    return centerX < (left + right) / 2
        ? left - (centerX + half)
        : right - (centerX - half);
  }

  /// Centre x of pip [position], 0 = leftmost = the biggest size
  /// (tokens.json `layout.pip.order`, NestyBoard:164).
  double pipCenterX(int position) =>
      centerX + (position - (pipCount - 1) / 2) * pipPitch;

  /// Centre x of the pip for doll [size] (1…maxSize).
  double pipCenterXForSize(int size) => pipCenterX(pipCount - size);

  /// Doll height for [size] (1…maxSize): one scale for the whole board, so
  /// sizes compare across shelves (spec §10.3).
  double dollHeight(int size) => _dollHeights[size - 1];

  double dollWidth(int size) => dollHeight(size) * _K.dollAspect;

  /// Top of the doll rect for [size] standing at [baseY] (default: the
  /// resting base). The art's base is 742/768 of its height.
  double dollTopY(int size, [double? baseY]) =>
      (baseY ?? restingBaseY) -
      dollHeight(size) * _K.dollArtBaseY / _K.dollArtHeight;

  /// The doll rect for [size] at [baseY] (default: the resting base).
  Rect dollRect(int size, [double? baseY]) {
    final height = dollHeight(size);
    final width = height * _K.dollAspect;
    return Rect.fromLTWH(
      centerX - width / 2,
      dollTopY(size, baseY),
      width,
      height,
    );
  }

  /// The tower stack (tokens.json `layout.towerStack`, m7-3): the step in
  /// logical px between buried silhouettes and how many are drawn, for a
  /// tower of [buried] nests under a top of [topSize] (its tallest doll).
  ///
  /// `step = min(18, (hRoom − topHeight) / N)`, `hRoom = (towerSurface −
  /// limit) / 0.9661` in reference units; under a step of 9 fewer
  /// silhouettes are drawn: `drawn = max(1, ⌊(hRoom − topHeight) / 9⌋)`, each
  /// `min(9, room / drawn)` apart. The "+N" tag keeps the real count. Give
  /// the tower's starting depth and tallest size, so the spacing stays put
  /// as it empties. [iced] lifts the limit to the ice's top + 8.
  /// Allocation-free (a record of two numbers).
  ({double step, int drawn}) towerStack(
    int topSize,
    int buried, {
    bool iced = false,
  }) {
    final size = topSize < 1
        ? 1
        : (topSize > _dollHeights.length ? _dollHeights.length : topSize);
    final scale = furnitureScale / pieceScale;
    final topHeightRef = _dollHeights[size - 1] / scale;
    // D21's true sizes (`layout.towerStack.d21`, m7-4 5.3): the deepest
    // silhouette's visible top, surface − N·step − h·drawnHeight, stays at
    // or under the limit, so the room is worked out in drawn units.
    final room =
        ((iced ? _towerRoomIcedRef : _towerRoomRef) - topHeightRef) *
        BoardFitTokens.drawnHeight;
    final n = buried < 1 ? 1 : buried;
    var stepRef = math.min(TowerStackTokens.step, room / n);
    var drawn = buried;
    if (stepRef < TowerStackTokens.minStep) {
      drawn = math.max(1, (room / TowerStackTokens.minStep).floor());
      stepRef = math.max(0.0, math.min(TowerStackTokens.minStep, room / drawn));
    }
    return (step: stepRef * scale, drawn: drawn);
  }

  /// Base y of the buried tower nest [depth] below the top (1 = directly
  /// under it), in a tower that buries [buried] nests, the tallest of them
  /// [topSize] (default: this level's biggest size). D21: each buried nest
  /// keeps its true size and its base is raised one [towerStack] step per
  /// depth so it peeks out behind the top nest.
  ///
  /// Pass the number of nests the tower buried at the start of the level,
  /// and its tallest size, so the spacing stays put as it empties. The
  /// default is the most a tower can bury (spec §3.2).
  ///
  /// Allocation-free.
  double buriedBaseY(
    int depth, {
    int buried = _K.maxBuriedNests,
    int? topSize,
    bool iced = false,
  }) =>
      surfaceY -
      depth *
          towerStack(topSize ?? _dollHeights.length, buried, iced: iced).step;

  /// How many of a tower's [buried] silhouettes are drawn (depths 1 to
  /// this); see [towerStack].
  int buriedDrawn(int buried, {int? topSize, bool iced = false}) => math.min(
    buried,
    towerStack(topSize ?? _dollHeights.length, buried, iced: iced).drawn,
  );

  /// The wood silhouette rect for the buried nest at [depth] whose outer doll
  /// is [size] (D21, `TowerStackStyle.trueSize`), in a tower that buries
  /// [buried] nests (see [buriedBaseY]).
  Rect buriedSilhouetteRect(
    int depth,
    int size, {
    int buried = _K.maxBuriedNests,
    int? topSize,
    bool iced = false,
  }) => dollRect(
    size,
    buriedBaseY(depth, buried: buried, topSize: topSize, iced: iced),
  );

  /// The hint arrow above this slot's resting doll of [size], at rest, on
  /// ([hintArrowCenterX], [hintArrowCenterY]).
  Rect hintArrowRect(int size) {
    final width = _K.hintArrowWidth * furnitureScale;
    final height = _K.hintArrowHeight * furnitureScale;
    return Rect.fromLTWH(
      hintArrowCenterX(size) - width / 2,
      hintArrowCenterY(size) - height / 2,
      width,
      height,
    );
  }

  @override
  String toString() => 'SlotGeometry($id, row $row, col $column)';
}

/// One shelf: its plank, its pitch and its slots.
final class ShelfGeometry {
  ShelfGeometry({
    required this.row,
    required this.plankRect,
    required this.pitch,
    required this.pieceScale,
    required this.hitTop,
    required this.hitBottom,
    required List<SlotGeometry> slots,
  }) : slots = List.unmodifiable(slots),
       hitCenterY = (hitTop + hitBottom) / 2;

  final int row;

  /// The plank strip, spanning the full viewport width (NestyBoard:12,
  /// `left:0;right:0`), for the tiled `shelf-plank.svg`.
  final Rect plankRect;

  double get plankTop => plankRect.top;

  /// Column pitch on this shelf.
  final double pitch;

  /// See [SlotGeometry.pieceScale].
  final double pieceScale;

  /// This shelf's hit band: the previous plank's bottom (the frame top for
  /// the first shelf) to this plank's bottom, at least 48 dp tall.
  final double hitTop;
  final double hitBottom;
  final double hitCenterY;

  /// Left to right. Unmodifiable.
  final List<SlotGeometry> slots;
}

/// The laid-out board: every shelf and slot in logical px, plus hit testing.
/// Built by `BoardLayout.compute`; immutable.
final class BoardGeometry {
  BoardGeometry({
    required this.shape,
    required this.preset,
    required this.fit,
    required this.boardArea,
    required List<ShelfGeometry> shelves,
    required List<double> dollHeights,
    required this.dollHeightScale,
    required this.familyCounterTarget,
  }) : shelves = List.unmodifiable(shelves),
       dollHeights = List.unmodifiable(dollHeights),
       slots = List.unmodifiable([for (final shelf in shelves) ...shelf.slots]),
       familyCounterTargetReference = fit.toReference(
         familyCounterTarget.dx,
         familyCounterTarget.dy,
       ) {
    for (final slot in slots) {
      _byId[slot.id] = slot;
    }
  }

  final BoardShape shape;

  final ShelfPreset preset;

  /// Reference → device mapping; `fit.scale` is the board's scale `s`.
  final BoardFit fit;

  double get scale => fit.scale;

  /// The area between the HUD and the booster bar the frame is centred in.
  final Rect boardArea;

  /// Top to bottom. Unmodifiable.
  final List<ShelfGeometry> shelves;

  /// Row-major, bottom shelf last (so extras come last). Unmodifiable.
  final List<SlotGeometry> slots;

  /// Doll height per size (index 0 = size 1), logical px, for the whole
  /// board; hand these to `DollRenderer.prepare`.
  final List<double> dollHeights;

  /// ≤ 1: how much every doll was shrunk so the tallest fits the narrowest
  /// pitch (render §1: `h·2/3 ≤ minPitch − gap`, gap
  /// [BoardLayoutConstants.dollMinGap]) and, on a 5–6-slot row, shrinks with
  /// that row's stands, glass cases and ice (review RENDER-3).
  final double dollHeightScale;

  /// Where a completed set flies to (render §1: `(W/2, padding.top + 70)`).
  final Offset familyCounterTarget;

  /// [familyCounterTarget] in reference units: (195, 129) on the 390×844
  /// reference screen, and `doll_complete`'s travel `dst` before its
  /// `+ (0, 0.1 × doll height)` (m2-lottie-design §5, §6).
  ///
  /// Vertical centring slack moves it up by `slack / (2s)`; see
  /// [familyCounterInBoardSpace].
  final Offset familyCounterTargetReference;

  /// Whether [familyCounterTargetReference] is inside the board-space
  /// canvas (reference y > 0), which holds while the board area's vertical
  /// slack is below `2·(142·s − 13)`: on every phone the layout supports.
  /// A board-space clip past it would be cut at the canvas top, so the
  /// timeline asserts it in debug (m2-lottie-design §5).
  bool get familyCounterInBoardSpace => familyCounterTargetReference.dy > 0;

  final Map<String, SlotGeometry> _byId = {};

  /// The tallest doll's height (size `maxSize`).
  double get maxDollHeight => dollHeights.last;

  double dollHeight(int size) => dollHeights[size - 1];

  /// Throws [ArgumentError] for an id that isn't on this board.
  SlotGeometry slot(String id) =>
      _byId[id] ?? (throw ArgumentError.value(id, 'id', 'not on this board'));

  SlotGeometry? slotOrNull(String id) => _byId[id];

  /// The slot whose column contains [point], or null (spec §10.3: the whole
  /// column is the hit area).
  SlotGeometry? slotAt(Offset point) {
    final index = slotIndexAt(point.dx, point.dy);
    return index < 0 ? null : slots[index];
  }

  /// Allocation-free [slotAt] for drag updates: the index into [slots], or
  /// −1. Where 48 dp minimums make neighbours overlap, the nearest centre
  /// wins.
  int slotIndexAt(double x, double y) {
    ShelfGeometry? shelf;
    var bestDistance = double.infinity;
    for (var r = 0; r < shelves.length; r++) {
      final candidate = shelves[r];
      if (y < candidate.hitTop || y >= candidate.hitBottom) continue;
      final distance = (y - candidate.hitCenterY).abs();
      if (distance < bestDistance) {
        bestDistance = distance;
        shelf = candidate;
      }
    }
    if (shelf == null) return -1;
    final row = shelf.slots;
    var column = ((x - row.first.centerX) / shelf.pitch).round();
    if (column < 0) column = 0;
    if (column >= row.length) column = row.length - 1;
    final slot = row[column];
    if (x < slot.hitRect.left || x > slot.hitRect.right) return -1;
    return slot.index;
  }
}
