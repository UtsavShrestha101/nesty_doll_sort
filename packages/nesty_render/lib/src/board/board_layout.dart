import 'dart:math' as math;
import 'dart:ui' show Offset, Rect, Size;

import 'package:flutter/foundation.dart' show immutable;
import 'package:flutter/painting.dart' show EdgeInsets;
import 'package:nesty_render/src/board/board_geometry.dart';
import 'package:nesty_render/src/board/board_layout_constants.dart';
import 'package:nesty_render/src/board/board_shape.dart';
import 'package:nesty_render/src/board/shelf_presets.dart';
import 'package:nesty_render/src/tokens/render_tokens.gen.dart';

typedef _K = BoardLayoutConstants;

/// The screen the board is laid out on: its logical size and safe-area
/// padding (`MediaQuery.sizeOf` / `MediaQuery.paddingOf`).
@immutable
final class BoardViewport {
  const BoardViewport({required this.size, this.padding = EdgeInsets.zero});

  /// The design's 390×844 screen with its 59/34 safe areas (tokens.json
  /// `meta.screen`), where the layout reproduces NestyBoard exactly.
  static const reference = BoardViewport(
    size: BoardTokens.referenceScreen,
    padding: EdgeInsets.only(
      top: BoardTokens.referenceSafeTop,
      bottom: BoardTokens.referenceSafeBottom,
    ),
  );

  final Size size;

  final EdgeInsets padding;

  /// Between the HUD (`padding.top + 83`) and the booster bar
  /// (`H − padding.bottom − 76`): y 142…734 on the reference screen
  /// (render §1). Side insets narrow it too, for landscape notches.
  Rect get boardArea => Rect.fromLTRB(
    padding.left,
    padding.top + _K.hudBottomInset,
    size.width - padding.right,
    size.height - padding.bottom - _K.barTopInset,
  );

  @override
  bool operator ==(Object other) =>
      other is BoardViewport && other.size == size && other.padding == padding;

  @override
  int get hashCode => Object.hash(size, padding);

  @override
  String toString() => 'BoardViewport($size, $padding)';
}

/// Board layout as pure math (spec §10.3, render §1), shared by the game's
/// Flame board and the admin's preview. It reproduces
/// `design/prototypes/NestyBoard.dc.html` at 390×844 and scales that frame
/// uniformly to other screens, so every designed proportion holds.
abstract final class BoardLayout {
  /// Lays [shape] out on [viewport]. Call it when the level, the viewport or
  /// the slot count (an extra slot) changes; never per frame.
  static BoardGeometry compute(BoardShape shape, BoardViewport viewport) {
    final area = viewport.boardArea;
    final fit = fitFor(viewport);
    final preset = ShelfPresets.forShelfCount(shape.shelfCount);

    var minPitch = double.infinity;
    for (final row in shape.rows) {
      minPitch = math.min(minPitch, rowPitch(row.length));
    }
    // How much the most crowded row shrinks its pieces beyond the preset
    // (1 on designed boards): the dolls follow it, so a sealed doll keeps
    // fitting its glass case and a frozen one its ice (review RENDER-3).
    final pieceShrink =
        math.min(standScaleForPitch(minPitch), preset.pieceScale) /
        preset.pieceScale;

    final heights = _dollHeights(shape.maxSize, preset, minPitch, pieceShrink);
    // One shared list: every slot reads the same board-wide heights.
    final dollHeights = List<double>.unmodifiable([
      for (final h in heights.heights) fit.length(h),
    ]);

    final hud = HudClearance.of(
      width: viewport.size.width,
      safeTop: viewport.padding.top,
    );

    final shelves = <ShelfGeometry>[];
    var index = 0;
    for (var r = 0; r < shape.rows.length; r++) {
      final row = shape.rows[r];
      final n = row.length;
      final pitchRef = rowPitch(n);
      final pieceScale = math.min(
        standScaleForPitch(pitchRef),
        preset.pieceScale,
      );
      final plankTopRef = preset.plankTops[r];

      // Spec §10.3: the whole column is the hit area. Rows split at plank
      // bottoms, so a tall doll's head still belongs to its own shelf.
      final bandTop = fit.y(
        r == 0 ? _K.frameTop : preset.plankTops[r - 1] + _K.plankHeight,
      );
      final bandBottom = fit.y(plankTopRef + _K.plankHeight);
      final bandPad =
          math.max(0.0, _K.minHitExtent - (bandBottom - bandTop)) / 2;
      final hitTop = bandTop - bandPad;
      final hitBottom = bandBottom + bandPad;

      final slots = <SlotGeometry>[
        for (var i = 0; i < n; i++)
          SlotGeometry(
            shape: row[i],
            row: r,
            column: i,
            index: index + i,
            // NestyBoard:161: cx = 195 + (i − (n − 1)/2) · pitch.
            centerXRef: _K.centerX + (i - (n - 1) / 2) * pitchRef,
            pitchRef: pitchRef,
            plankTopRef: plankTopRef,
            pieceScale: pieceScale,
            hitTop: hitTop,
            hitBottom: hitBottom,
            fit: fit,
            dollHeights: dollHeights,
            hud: hud,
          ),
      ];
      index += n;

      shelves.add(
        ShelfGeometry(
          row: r,
          plankRect: Rect.fromLTWH(
            0,
            fit.y(plankTopRef),
            viewport.size.width,
            fit.length(_K.plankHeight),
          ),
          pitch: fit.length(pitchRef),
          pieceScale: pieceScale,
          hitTop: hitTop,
          hitBottom: hitBottom,
          slots: slots,
        ),
      );
    }

    return BoardGeometry(
      shape: shape,
      preset: preset,
      fit: fit,
      boardArea: area,
      shelves: shelves,
      dollHeights: dollHeights,
      dollHeightScale: heights.clamp,
      familyCounterTarget: Offset(
        viewport.size.width / 2,
        viewport.padding.top + _K.familyCounterCenterInset,
      ),
    );
  }

  /// The reference frame on [viewport]: `s = min(W/390, h/592, 1.5)`,
  /// centred in the board area (render §1). `s` is exactly 1 on the
  /// 390×844 reference screen.
  static BoardFit fitFor(BoardViewport viewport) {
    final area = viewport.boardArea;
    var scale = math.min(
      math.min(area.width / _K.referenceWidth, area.height / _K.frameHeight),
      _K.maxScale,
    );
    if (!(scale >= _K.minScale)) scale = _K.minScale;
    return BoardFit(
      scale: scale,
      originX: area.left + (area.width - _K.referenceWidth * scale) / 2,
      originY: area.top + (area.height - _K.frameHeight * scale) / 2,
    );
  }

  /// Column pitch for a shelf of [slotCount] slots, in reference units:
  /// `min(96, 372 / n)` (spec §10.3, NestyBoard:159).
  static double rowPitch(int slotCount) =>
      math.min(_K.slotPitchMax, _K.slotRowWidth / slotCount);

  // TODO(design): rows of 5–6 slots are undesigned (D22, BACKLOG "Design
  // gaps"); pips, tags, glass and ice shrink with the stand.

  /// Stands keep their designed size while the pitch is ≥ 93 (four slots)
  /// and then shrink to `pitch − 4` wide, height and surface offset scaled
  /// with them (render §1, D22).
  static double standScaleForPitch(double pitchRef) =>
      pitchRef >= _K.standShrinkPitch
      ? 1
      : (pitchRef - _K.slotGap) / _K.standWidth;

  /// The ice sprite for a slot whose counter started at [initial] and is now
  /// [remaining]: `min(3, ⌊3(n0 − n)/n0⌋)` (render §1). Frames 0–2 show while
  /// frozen and frame 3 only at 0, where it flashes before `ice-shatter`.
  /// Throws [ArgumentError] when [initial] < 1 (no ice).
  static int iceFrame({required int remaining, required int initial}) {
    if (initial < 1) {
      throw ArgumentError.value(
        initial,
        'initial',
        'a frozen slot has ice ≥ 1',
      );
    }
    final n = remaining < 0 ? 0 : (remaining > initial ? initial : remaining);
    final frame = (MotionTokens.iceStages * (initial - n)) ~/ initial;
    return frame > MotionTokens.iceStages ? MotionTokens.iceStages : frame;
  }

  /// Reference-unit doll heights for sizes 1…maxSize and the clamp applied.
  static ({List<double> heights, double clamp}) _dollHeights(
    int maxSize,
    ShelfPreset preset,
    double minPitch,
    double pieceShrink,
  ) {
    final fractions = BoardTokens.dollHeightFractions;
    // Spec §10.3: at maxSize 3, scale up so size 3 = 1.00.
    final divisor = maxSize == 3 ? BoardTokens.maxSize3Divisor : 1.0;
    final unclamped = [
      for (var size = 1; size <= maxSize; size++)
        preset.maxDollHeight * fractions[size - 1] / divisor,
    ];
    // One scale for the whole board, so a size reads the same on every
    // shelf; it shrinks only when the tallest doll would come closer to its
    // neighbour on the narrowest shelf than the design ever draws (render
    // §1, with the design's own minimum gap; see dollMinGap).
    // TODO(design): maxSize 6 on 3 shelves, maxSize 3 on 3 shelves or on
    // 4-slot rows (M2 levels 3–9), and rows of 5–6 slots are undesigned
    // (D22); this clamp is how they fit.
    final widest = unclamped.last * _K.dollAspect;
    double clampFor(double pitch) {
      final limit = pitch - _K.dollMinGap;
      return widest > limit ? limit / widest : 1.0;
    }

    var clamp = clampFor(minPitch);
    // A 5–6-slot row shrinks its stands, glass cases and ice by
    // [standScaleForPitch]. The dolls shrink at least as much as they would
    // on the narrowest full-size row (4 slots, pitch 93), times that: a
    // sealed doll keeps its case's proportions and a frozen one its ice's
    // (review RENDER-3).
    if (pieceShrink < 1) {
      final withPieces = pieceShrink * clampFor(_K.standShrinkPitch);
      if (withPieces < clamp) clamp = withPieces;
    }
    return (heights: [for (final h in unclamped) h * clamp], clamp: clamp);
  }
}
