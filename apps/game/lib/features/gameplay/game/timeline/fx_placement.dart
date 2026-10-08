import 'dart:ui' show Offset;

import 'package:nesty_core/nesty_core.dart' show DollColor;
import 'package:nesty_render/nesty_render.dart';

/// LOTTIE.md's placement facts the timeline computes with: the doll size
/// the files are authored at and the fractions of a doll's height the
/// board-space files travel to (docs/plans/m2-lottie-design.md §5, §6).
/// These are distances baked into the exports, not durations: every time
/// comes from the files' `FxSpec`s.
abstract final class LottieGeometry {
  /// "At 100 % the doll is 150 dp tall" (LOTTIE.md "Doll size").
  static const referenceDollHeight = 150.0;

  /// `doll_nest`: the move ends with the mover's base this many target
  /// heights above the target base (LOTTIE.md "Hover points").
  static const nestHoverFraction = 0.5;

  /// `doll_swallow`: the same for a swallow.
  static const swallowHoverFraction = 1.06;

  /// `doll_invalid`: `dst` is the target base minus this many target
  /// heights (the mover drifts halfway there and back). Onto an empty stand,
  /// case or ice slot the target's height is the mover's own
  /// (`motion.invalid.emptyTarget`, m7-6 Choices 21).
  static const invalidDriftFraction = MotionTokens.invalidEmptyTargetStop;

  /// `doll_complete`: `dst` is the family counter centre plus this many
  /// doll heights (the authored T (195, 144) = (195, 129) + 0.1 × 150).
  static const counterDropFraction = 0.1;

  /// The sparkle over the family counter when a set lands is this much
  /// bigger than a trail sparkle (LOTTIE.md "Completed").
  static const counterSparkleScale = 1.5;

  /// The `<role>_size` null value for a doll [height] logical px tall in a
  /// clip drawn at [compositionScale]: `h / (150 · scale)`, with the scale
  /// `s` for doll files and `fs` for glass and ice (§5).
  static double roleScale(double height, double compositionScale) =>
      height / (referenceDollHeight * compositionScale);

  /// `mover_size` in `doll_nest` / `doll_swallow`, whose mover chain sits
  /// inside `target_size`: `hMover / hTarget`.
  static double nestedMoverScale(double moverHeight, double targetHeight) =>
      targetHeight <= 0 ? 1 : moverHeight / targetHeight;
}

/// Which point of a slot an in-place clip's anchor sits on, so the board
/// can place the clip again on another layout (the +1 Slot re-pitch lerps
/// between two, §9.5). Every point is on the slot's column centre.
enum FxAnchor {
  /// A doll's base on the stand surface, `(cx, surfaceY)`, at the board
  /// scale `s`: `doll_pick`, `doll_nest`, `doll_swallow`, `doll_reveal`.
  dollBase,

  /// `fx_select_glow`'s ring centre, `(cx, surface − 2·fs)`, at `fs`.
  glow,

  /// `ui_hint_arrow`'s rest point, `(cx, dollTop − 33·fs)` for the doll's
  /// size, at `fs`.
  hintArrow,

  /// `ui_extra_slot`'s stand centre, at `fs`.
  stand,

  /// `fx_dust_puff`'s origin on the stand surface, at `fs`.
  surface;

  // ── Hot path: runs every frame. No allocation (CLAUDE.md rule 8). ──

  /// Where the anchor sits horizontally, for a doll of [size] (only
  /// [hintArrow] reads it: the arrow moves off the HUD's counter pill).
  /// Allocation-free.
  double xIn(SlotGeometry slot, {int size = 1}) =>
      this == FxAnchor.hintArrow ? slot.hintArrowCenterX(size) : slot.centerX;

  /// Where the anchor sits vertically, for a doll of [size] (only
  /// [hintArrow] reads it). Allocation-free.
  double yIn(SlotGeometry slot, {int size = 1}) => switch (this) {
    FxAnchor.dollBase || FxAnchor.surface => slot.surfaceY,
    FxAnchor.glow => slot.glowCenterY,
    FxAnchor.hintArrow => slot.hintArrowCenterY(size),
    FxAnchor.stand => slot.standCenterY,
  };

  /// The clip's scale: `s` for doll files, `fs` for board pieces (§5).
  double scaleIn(BoardGeometry board, SlotGeometry slot) =>
      this == FxAnchor.dollBase ? board.scale : slot.furnitureScale;

  // ── End of hot path. ──
}

/// How a clip is placed on the board (docs/plans/m2-lottie-design.md §5).
enum FxSpace {
  /// The file's `FxSpec.anchor` goes on ([FxPlacement.x], [FxPlacement.y]),
  /// scaled by [FxPlacement.scale].
  inPlace,

  /// The 390×844 canvas's top-left goes on ([FxPlacement.x],
  /// [FxPlacement.y]) (`BoardFit.boardSpaceOrigin`), scaled by `s`; the
  /// travel points are in reference units.
  boardSpace,

  /// In place, on the point [FxPlacement.trail]'s `travel` null holds when
  /// the clip starts (the sparkle trail, §6): the FX runtime captures it
  /// in the travel callback, in reference units.
  trail,
}

/// Where a clip is drawn and at what scale.
final class FxPlacement {
  /// The anchor on ([x], [y]) logical px, at [scale].
  const FxPlacement.inPlace({
    required this.x,
    required this.y,
    required this.scale,
  }) : space = FxSpace.inPlace,
       trailOf = null;

  /// The board-space canvas through [fit].
  FxPlacement.boardSpace(BoardFit fit)
    : space = FxSpace.boardSpace,
      x = fit.boardSpaceOrigin.dx,
      y = fit.boardSpaceOrigin.dy,
      scale = fit.scale,
      trailOf = null;

  /// On [clipId]'s current travel point, at [scale].
  const FxPlacement.trail({required int clipId, required this.scale})
    : space = FxSpace.trail,
      x = 0,
      y = 0,
      trailOf = clipId;

  /// An in-place clip on [anchor] of [slot].
  factory FxPlacement.anchored(
    FxAnchor anchor,
    BoardGeometry board,
    SlotGeometry slot, {
    int size = 1,
  }) => FxPlacement.inPlace(
    x: anchor.xIn(slot, size: size),
    y: anchor.yIn(slot, size: size),
    scale: anchor.scaleIn(board, slot),
  );

  final FxSpace space;
  final double x;
  final double y;
  final double scale;

  /// The board-space clip whose trail a [FxSpace.trail] clip follows.
  final int? trailOf;

  @override
  bool operator ==(Object other) =>
      other is FxPlacement &&
      other.space == space &&
      other.x == x &&
      other.y == y &&
      other.scale == scale &&
      other.trailOf == trailOf;

  @override
  int get hashCode => Object.hash(space, x, y, scale, trailOf);

  @override
  String toString() => switch (space) {
    FxSpace.inPlace =>
      'at(${x.toStringAsFixed(1)}, ${y.toStringAsFixed(1)}'
          ' ×${scale.toStringAsFixed(3)})',
    FxSpace.boardSpace =>
      'board(${x.toStringAsFixed(1)}, '
          '${y.toStringAsFixed(1)} ×${scale.toStringAsFixed(3)})',
    FxSpace.trail => 'trail(#$trailOf ×${scale.toStringAsFixed(3)})',
  };
}

/// Per-use parameters of a clip: what its image slots show, its
/// `<role>_size` nulls, travel points, recolours and flags. The FX runtime
/// copies them into the pooled clip's `FxImageRequest` and the mutable
/// fields its delegates read (m2-lottie-design §2 rule 2, §3–§6).
final class FxClipParams {
  const FxClipParams({
    this.doll,
    this.mover,
    this.target,
    this.dollScale = 1,
    this.moverScale = 1,
    this.targetScale = 1,
    this.hideMover = false,
    this.hideTarget = false,
    this.travelFrom,
    this.travelTo,
    this.targetPos,
    this.rim,
    this.tint,
    this.revealDrop,
    this.shake = true,
    this.opacity = 1,
    this.unwindOf,
  });

  /// No doll, no travel: glows, dust, sparkles, the hint arrow, the stand.
  static const none = FxClipParams();

  /// Colour of the `doll` role; null draws nothing there.
  final DollColor? doll;

  /// Colour of the `mover` role (`doll_nest`, `doll_swallow`,
  /// `doll_invalid`).
  final DollColor? mover;

  /// Colour of the `target` role.
  final DollColor? target;

  /// `doll_size`, `mover_size`, `target_size` (LottieGeometry.roleScale;
  /// the nested mover is relative to its target).
  final double dollScale;
  final double moverScale;
  final double targetScale;

  /// `doll_invalid` after a drag: the mover returns by `doll_move`.
  final bool hideMover;

  /// `doll_invalid` on a locked, iced or tower target: the slot's own
  /// drawing shakes by hand instead (§9.3).
  final bool hideTarget;

  /// The `travel` remap's `src` and `dst`, in reference units (§6).
  final Offset? travelFrom;
  final Offset? travelTo;

  /// `doll_invalid`'s `target_pos`, in reference units.
  final Offset? targetPos;

  /// Colour whose `DollSwatch.rimColor` fills `rim_tint` (nest, swallow).
  final DollColor? rim;

  /// Colour whose `DollSwatch.base` fills `tint` (`doll_reveal`'s drops).
  final DollColor? tint;

  /// `doll_reveal`: how far above the stand its `drop` null starts the new
  /// top, in composition units: the tower's step of depth 1, so the file
  /// picks the nest up where its silhouette stood (LOTTIE.md v3 "Reveal
  /// drop"). Null: the authored 18.
  final double? revealDrop;

  /// False under reduced motion: `doll_invalid`'s `target` null and
  /// `fx_ice`'s `ice` null get static values (§13).
  final bool shake;

  /// The whole clip's opacity: 1, or 0.6 for the drag hover's glow
  /// (`motion.dragHover`, E.14).
  final double opacity;

  /// `doll_move` on a drop: the id of the `doll_pick` clip it takes over
  /// from. The board starts the flight tilted as that clip's wobble last
  /// drew and eases the tilt to 0 over its first 80 ms
  /// (`motion.pick.wobbleToMoveMs`, m7-5 item 14).
  final int? unwindOf;

  @override
  bool operator ==(Object other) =>
      other is FxClipParams &&
      other.doll == doll &&
      other.mover == mover &&
      other.target == target &&
      other.dollScale == dollScale &&
      other.moverScale == moverScale &&
      other.targetScale == targetScale &&
      other.hideMover == hideMover &&
      other.hideTarget == hideTarget &&
      other.travelFrom == travelFrom &&
      other.travelTo == travelTo &&
      other.targetPos == targetPos &&
      other.rim == rim &&
      other.tint == tint &&
      other.revealDrop == revealDrop &&
      other.shake == shake &&
      other.opacity == opacity &&
      other.unwindOf == unwindOf;

  @override
  int get hashCode => Object.hash(
    doll,
    mover,
    target,
    dollScale,
    moverScale,
    targetScale,
    hideMover,
    hideTarget,
    travelFrom,
    travelTo,
    targetPos,
    rim,
    tint,
    revealDrop,
    shake,
    opacity,
    unwindOf,
  );

  @override
  String toString() =>
      'FxClipParams(doll: ${doll?.id}, mover: ${mover?.id}, '
      'target: ${target?.id}, travel: $travelFrom → $travelTo)';
}
