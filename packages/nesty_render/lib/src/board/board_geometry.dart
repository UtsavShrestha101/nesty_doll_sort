import 'dart:ui' show Offset, Rect;

import 'package:nesty_render/src/board/board_layout_constants.dart';
import 'package:nesty_render/src/board/board_shape.dart';
import 'package:nesty_render/src/board/shelf_presets.dart';

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
  }) {
    final q = pieceScale;
    final tower = shape.kind == SlotShapeKind.tower;
    final standBottomRef = plankTopRef + _K.standBottomInset;
    final standTopRef =
        standBottomRef - (tower ? _K.towerStandHeight : _K.standHeight) * q;
    final surfaceRef = standTopRef + _K.standSurfaceOffset * q;
    final caseTopRef = surfaceRef - _K.glassCaseTopAboveSurface * q;
    final iceTopRef = standBottomRef - _K.iceTopAboveStandBottom * q;
    final lockedBaseRef = caseTopRef + _K.lockedDollBaseBelowCaseTop * q;

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
      pipDiameter: fit.length(_K.pipDiameter * q),
      pipPitch: fit.length(_K.pipPitch * q),
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
      glassCaseRect: box(
        centerXRef - _K.glassCaseWidth / 2 * q,
        caseTopRef,
        _K.glassCaseWidth * q,
        _K.glassCaseHeight * q,
      ),
      lockedDollBaseY: fit.y(lockedBaseRef),
      padlockSymbolCenter: Offset(
        centerX,
        fit.y(caseTopRef + _K.padlockCenterBelowCaseTop * q),
      ),
      padlockSymbolSize: fit.length(_K.padlockSymbolSize * q),
      iceRect: box(
        centerXRef - _K.iceWidth / 2 * q,
        iceTopRef,
        _K.iceWidth * q,
        _K.iceHeight * q,
      ),
      iceBadgeRect: box(
        centerXRef + _K.iceBadgeOffsetX * q,
        iceTopRef + _K.iceBadgeOffsetY * q,
        _K.iceBadgeSize * q,
        _K.iceBadgeSize * q,
      ),
      hitRect: Rect.fromLTRB(
        centerX - hitHalfWidth,
        hitTop,
        centerX + hitHalfWidth,
        hitBottom,
      ),
      glassCompositionOrigin: Offset(
        centerX - glassCompositionAnchor.dx * fit.scale * q,
        fit.y(lockedBaseRef) - glassCompositionAnchor.dy * fit.scale * q,
      ),
      iceCompositionOrigin: Offset(
        centerX - iceCompositionAnchor.dx * fit.scale * q,
        fit.y(surfaceRef) - iceCompositionAnchor.dy * fit.scale * q,
      ),
      towerRaise: fit.length(_K.towerDepthRaise * q),
      // Room above the tallest doll for its tower's silhouettes before they
      // reach the HUD over the board frame (review RENDER-4).
      buriedHeadroom:
          fit.y(surfaceRef) -
          dollHeights.last * _K.dollArtBaseY / _K.dollArtHeight -
          fit.y(_K.frameTop),
      dollHeights: dollHeights,
    );
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
    required this.plankTop,
    required this.standRect,
    required this.surfaceY,
    required this.pipCenterY,
    required this.pipDiameter,
    required this.pipPitch,
    required this.glowRingRect,
    required this.towerTagOrigin,
    required this.glassCaseRect,
    required this.lockedDollBaseY,
    required this.padlockSymbolCenter,
    required this.padlockSymbolSize,
    required this.iceRect,
    required this.iceBadgeRect,
    required this.hitRect,
    required this.glassCompositionOrigin,
    required this.iceCompositionOrigin,
    required double towerRaise,
    required double buriedHeadroom,
    required List<double> dollHeights,
  }) : _towerRaise = towerRaise,
       _buriedHeadroom = buriedHeadroom,
       _dollHeights = dollHeights;

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

  /// The glass case sprite box (spec §3.3).
  final Rect glassCaseRect;

  /// Base of the doll sealed inside a glass case.
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

  /// `fx_ice`'s doll base in its 180×240 canvas (LOTTIE.md "Files"). Its
  /// ice's top-left is at (42, 40).
  static const iceCompositionAnchor = Offset(90, 170.8);

  /// Top-left of this slot's paused `fx_glass_unlock` composition, drawn at
  /// [furnitureScale] (m2-lottie-design §8): its doll base
  /// ([glassCompositionAnchor]) on ([centerX], [lockedDollBaseY]), which
  /// puts its case on [glassCaseRect] (`glassCaseRect.topLeft − (47, 40)·fs`).
  final Offset glassCompositionOrigin;

  /// Top-left of this slot's paused `fx_ice` composition, drawn at
  /// [furnitureScale] (m2-lottie-design §8): its doll base
  /// ([iceCompositionAnchor]) on ([centerX], [surfaceY]), which puts its
  /// ice on [iceRect] (`iceRect.topLeft − (42, 40)·fs`) on an open stand.
  // TODO(design): an iced tower has no frame. Its stand is 5·q taller, so
  // the composition, anchored on the doll, draws its ice 5·fs above the
  // static `iceRect` fallback, which stays on the stand's bottom.
  final Offset iceCompositionOrigin;

  final double _towerRaise;

  final double _buriedHeadroom;

  final List<double> _dollHeights;

  /// Where this slot's resting doll stands: on the case floor for a locked
  /// slot, else on the stand surface.
  double get restingBaseY =>
      shape.kind == SlotShapeKind.locked ? lockedDollBaseY : surfaceY;

  /// Where a locked slot's doll rests once its case has shattered: the stand
  /// surface, [unlockSettle] below the case floor. `fx_glass_unlock` ends on
  /// it through the hand-coded settle (m2-lottie-design §9.2). For other
  /// slots it is [restingBaseY].
  double get unlockedDollBaseY => surfaceY;

  /// How far the freed doll drops from the case floor to the stand: 11 dp
  /// at furniture scale 1 (the case floor is `surface − 134 + 123`).
  double get unlockSettle => surfaceY - lockedDollBaseY;

  /// Centre y of [standRect]: where `ui_extra_slot` pulses (anchor (55, 25)
  /// on the stand centre).
  double get standCenterY => standRect.top + standRect.height / 2;

  /// Centre y of [glowRingRect], `surface − 2·fs`: where `fx_select_glow`'s
  /// anchor (70, 40) goes, at [centerX].
  double get glowCenterY => glowRingRect.top + glowRingRect.height / 2;

  /// Centre y of [hintArrowRect] for a resting doll of [size],
  /// `dollTop − 33·fs`: where `ui_hint_arrow`'s anchor (30, 45) goes, at
  /// [centerX]. Allocation-free.
  double hintArrowCenterY(int size) =>
      dollTopY(size) +
      (_K.hintArrowOffsetY + _K.hintArrowHeight / 2) * furnitureScale;

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

  /// Base y of the buried tower nest [depth] below the top (1 = directly
  /// under it), in a tower that buries [buried] nests. D21: each buried nest
  /// keeps its true size and is raised 18 dp per depth so it peeks out
  /// behind the top nest.
  ///
  /// The step shrinks when the deepest of [buried] silhouettes of the
  /// level's tallest doll would otherwise rise above the board frame into
  /// the HUD (the level pill and family counter), which only happens on the
  /// top shelf (review RENDER-4). Pass the number of nests the tower buried
  /// at the start of the level, so the spacing stays put as it empties; the
  /// default is the most a tower can bury (spec §3.2).
  ///
  /// Allocation-free.
  // TODO(design): the design has no top-shelf tower whose buried nests
  // would reach the HUD; compressing D21's 18 dp step is this layout's
  // extension (BACKLOG "Design gaps").
  double buriedBaseY(int depth, {int buried = _K.maxBuriedNests}) {
    var step = _towerRaise;
    if (buried > 0) {
      final room = _buriedHeadroom / buried;
      if (room < step) step = room > 0 ? room : 0;
    }
    return surfaceY - depth * step;
  }

  /// The wood silhouette rect for the buried nest at [depth] whose outer doll
  /// is [size] (D21, `TowerStackStyle.trueSize`), in a tower that buries
  /// [buried] nests (see [buriedBaseY]).
  Rect buriedSilhouetteRect(
    int depth,
    int size, {
    int buried = _K.maxBuriedNests,
  }) => dollRect(size, buriedBaseY(depth, buried: buried));

  /// The hint arrow above this slot's resting doll of [size].
  Rect hintArrowRect(int size) => Rect.fromLTWH(
    centerX + _K.hintArrowOffsetX * furnitureScale,
    dollTopY(size) + _K.hintArrowOffsetY * furnitureScale,
    _K.hintArrowWidth * furnitureScale,
    _K.hintArrowHeight * furnitureScale,
  );

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
