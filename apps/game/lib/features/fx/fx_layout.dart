import 'dart:ui' show Offset;

import 'package:nesty_game/features/fx/fx_drawable_params.dart';
import 'package:nesty_game/features/fx/fx_id.dart';
import 'package:nesty_game/features/fx/fx_image_source.dart';
import 'package:nesty_game/features/fx/fx_spec.dart';

/// Where and how big a file draws on the board (m2-lottie-design §5,
/// PROGRESS D46). Pure arithmetic, per event.
///
/// - Board-space files (`doll_move`, `doll_complete`, `doll_invalid`): the
///   canvas is the 390×844 reference screen, translated to
///   `BoardFit.boardSpaceOrigin` and scaled by the board scale `s`; their
///   travel points are in reference units (`BoardFit.toReference`).
/// - In-place files: the file's anchor on the game point, scaled by `s`
///   (doll files, `fx_sparkle`) or by the slot's furniture scale `fs = s·q`
///   (board pieces).
abstract final class FxLayout {
  /// A doll at 100 % `<role>_size` is 150 composition units tall (LOTTIE.md
  /// "Doll size": size 6 on a 3-shelf board).
  static const dollUnits = 150.0;

  /// LOTTIE.md "Hover points": `doll_nest` ends the move with the mover's
  /// base this many target heights above the target base.
  static const nestHoverFactor = 0.50;

  /// The same for `doll_swallow`.
  static const swallowHoverFactor = 1.06;

  /// `doll_invalid` drifts toward the target base minus this many target
  /// heights (LOTTIE.md "Travel remap").
  static const invalidDriftFactor = 0.5;

  /// `doll_complete` flies to the family counter centre plus this many doll
  /// heights (LOTTIE.md "Travel remap").
  static const completeCounterFactor = 0.1;

  /// Whether [id] is placed by the furniture scale (a board piece) rather
  /// than the board scale.
  static bool usesFurnitureScale(FxId id) => switch (id) {
    FxId.fxSelectGlow ||
    FxId.fxGlassUnlock ||
    FxId.fxIce ||
    FxId.fxDustPuff ||
    FxId.uiHintArrow ||
    FxId.uiExtraSlot => true,
    _ => false,
  };

  /// The composition scale of [id] on a board of scale [boardScale], on a
  /// slot of [furnitureScale] (§5).
  static double scaleOf(
    FxId id, {
    required double boardScale,
    double furnitureScale = 1,
  }) => usesFurnitureScale(id) ? furnitureScale : boardScale;

  /// The anchor as fractions of the canvas (Flame's `Anchor(x, y)`); the
  /// top-left for board-space files.
  static (double, double) anchorFraction(FxSpec spec) =>
      (spec.anchor.dx / spec.width, spec.anchor.dy / spec.height);

  /// The canvas's top-left in logical px when [spec]'s anchor goes on
  /// ([x], [y]) at [scale].
  static Offset topLeft(FxSpec spec, double x, double y, double scale) =>
      Offset(x - spec.anchor.dx * scale, y - spec.anchor.dy * scale);

  /// `<role>_size` for a doll [dollHeight] logical px tall in a composition
  /// drawn at [compositionScale]: `h / (150 · scale)`.
  static double sizeFactor(double dollHeight, double compositionScale) =>
      dollHeight / (dollUnits * compositionScale);

  /// Whether [id]'s `mover_size` null sits inside `target_size` (§5): its
  /// factor is then relative to the target.
  static bool nestsMoverInTarget(FxId id) =>
      id == FxId.dollNest || id == FxId.dollSwallow;

  /// Sets every `<role>_size` of [spec] in [params] from the dolls'
  /// logical heights (§5): `h / (150 · compositionScale)`, except that in
  /// `doll_nest` and `doll_swallow` the mover's is `hMover / hTarget`. A
  /// role whose height is null keeps its authored size.
  static void applyDollHeights(
    FxDrawableParams params,
    FxSpec spec, {
    required double compositionScale,
    double? doll,
    double? mover,
    double? target,
  }) {
    for (final role in spec.roles) {
      switch (role) {
        case FxRole.doll:
          params.setSize(
            role,
            doll == null ? null : sizeFactor(doll, compositionScale),
          );
        case FxRole.target:
          params.setSize(
            role,
            target == null ? null : sizeFactor(target, compositionScale),
          );
        case FxRole.mover:
          final nested = nestsMoverInTarget(spec.id);
          params.setSize(
            role,
            mover == null
                ? null
                : nested
                ? (target == null ? null : mover / target)
                : sizeFactor(mover, compositionScale),
          );
      }
    }
  }

  /// The hover base y `doll_move` ends on before [nestFile] (`doll_nest` or
  /// `doll_swallow`) plays at a target whose base is [targetBaseY] and
  /// height [targetHeight] (LOTTIE.md "Hover points"); logical px.
  static double hoverBaseY(
    FxId nestFile,
    double targetBaseY,
    double targetHeight,
  ) =>
      targetBaseY -
      (nestFile == FxId.dollSwallow ? swallowHoverFactor : nestHoverFactor) *
          targetHeight;
}
