import 'dart:math' as math;
import 'dart:ui' show Offset, Rect, Size;

import 'package:flutter/foundation.dart' show immutable;
import 'package:flutter/painting.dart' show EdgeInsets;
import 'package:nesty_render/src/board/board_geometry.dart';
import 'package:nesty_render/src/board/board_layout_constants.dart';
import 'package:nesty_render/src/board/board_shape.dart';
import 'package:nesty_render/src/board/shelf_presets.dart';
import 'package:nesty_render/src/tokens/render_token_types.dart';
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
    final preset = ShelfPresets.forShape(shape);
    final result = fitDolls(shape, preset);
    // One shared list: every slot reads the same board-wide heights.
    final dollHeights = List<double>.unmodifiable([
      for (final h in result.heights) fit.length(h),
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
      final pieceScale = standScaleForPitch(pitchRef);
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
            plankAboveRef: r == 0 ? null : preset.plankTops[r - 1],
            iceHeightRef: preset.iceHeight,
            tallIce: preset.tall,
            // Four shelves: the glass and the ice follow the dolls' k.
            overlayK: preset.piecesFollowK ? result.k : 1,
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
      dollHeightScale: result.k,
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

  // TODO(design): a row of 6 (the second +1 Slot on a 4-slot bottom shelf,
  // D172) extends rowOfFive's formulas: pitch 372 / 6 = 62, stands at
  // 59.6 / 90 = 0.662; the design draws no row of 6.

  /// A stand's scale on a row of [pitchRef]: `min(90, pitch − 2.4) / 90`
  /// (tokens.json `layout.boardFit.standWidth`): 1 from a pitch of 92.4 (a
  /// row of 4 is 93), 0.8 on a row of 5 (74.4) and 0.662 on a row of 6 (62).
  static double standScaleForPitch(double pitchRef) =>
      math.min(_K.standWidth, pitchRef - _K.standPitchInset) / _K.standWidth;

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

  /// The board fit (tokens.json `layout.boardFit`, D180): the doll heights
  /// of [shape] on [preset], in reference units, all times one factor
  /// `k = min(1, min(V, HUD, H) / heightOf(maxSize))`.
  ///
  /// - `V = (pitchY − 40 − 12.7 − 2) / 0.9661`, `pitchY` the smallest step
  ///   between plank tops (unbounded on one shelf);
  /// - `HUD = (planks[0] − 12.7 − 150) / 0.9661`;
  /// - `H = (min(standWidth, pitch) − 8) / 0.5353` on the row with the
  ///   smallest pitch, `standWidth = min(90, pitch − 2.4)`;
  /// - `heightOf(size) = Hs × f[size]`, divided by 0.66 when `maxSize` is 3
  ///   (spec §10.3).
  ///
  /// Pure and per layout: [compute] calls it, the tests check every preset
  /// with it.
  static BoardFitResult fitDolls(BoardShape shape, ShelfPreset preset) {
    var minPitch = double.infinity;
    for (final row in shape.rows) {
      minPitch = math.min(minPitch, rowPitch(row.length));
    }
    var pitchY = double.infinity;
    for (var i = 1; i < shape.rows.length; i++) {
      pitchY = math.min(pitchY, preset.plankTops[i] - preset.plankTops[i - 1]);
    }
    const drawn = BoardFitTokens.drawnHeight;
    final standWidth = math.min(_K.standWidth, minPitch - _K.standPitchInset);
    final limits = BoardFitLimits(
      vertical:
          (pitchY - _K.plankHeight - _K.standSurfaceAbovePlank - _headroom) /
          drawn,
      hud:
          (preset.plankTops.first -
              _K.standSurfaceAbovePlank -
              BoardFitTokens.hudClearY) /
          drawn,
      horizontal:
          (math.min(standWidth, minPitch) - BoardFitTokens.neighbourGap) /
          BoardFitTokens.bodyWidth,
    );
    final fractions = BoardTokens.dollHeightFractions;
    // Spec §10.3: at maxSize 3, scale up so size 3 = 1.00.
    final divisor = shape.maxSize == 3 ? BoardTokens.maxSize3Divisor : 1.0;
    final unfitted = [
      for (var size = 1; size <= shape.maxSize; size++)
        preset.maxDollHeight * fractions[size - 1] / divisor,
    ];
    final limit = math.min(
      limits.vertical,
      math.min(limits.hud, limits.horizontal),
    );
    final k = math.min(1.0, limit / unfitted.last);
    return BoardFitResult(
      limits: limits,
      k: k,
      heights: [for (final h in unfitted) h * k],
    );
  }

  static const _headroom = BoardFitTokens.headroom;
}

/// What [BoardLayout.fitDolls] found: the three limits, the factor and the
/// doll heights it gives, in reference units.
@immutable
final class BoardFitResult {
  const BoardFitResult({
    required this.limits,
    required this.k,
    required this.heights,
  });

  /// The largest doll height each limit allows.
  final BoardFitLimits limits;

  /// ≤ 1: how much every doll shrank (1 on a board that fits).
  final double k;

  /// Sizes 1…maxSize.
  final List<double> heights;
}
