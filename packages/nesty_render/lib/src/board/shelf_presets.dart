import 'package:flutter/foundation.dart' show immutable;
import 'package:nesty_render/src/board/board_shape.dart';
import 'package:nesty_render/src/tokens/render_tokens.gen.dart';

/// Where the shelves sit for one board shape, in reference units (spec
/// §10.3, render §1). The 2- and 3-shelf presets, the tall one for size-6
/// levels and the 4-shelf one are the design's (tokens.json
/// `layout.board.planksY` and `layout.boardPresets`, m7-3); the 1-shelf one
/// extends its system for a board the design never drew (D22).
@immutable
final class ShelfPreset {
  const ShelfPreset({
    required this.plankTops,
    required this.maxDollHeight,
    required this.designed,
    this.iceHeight = 160,
    this.tall = false,
    this.piecesFollowK = false,
  });

  /// Plank top y per shelf, top to bottom, on the 390×844 reference screen.
  final List<double> plankTops;

  /// The slot's maximum doll height ("Hs", spec §10.3): size 6 is this tall
  /// before the board fit, and every size is a fraction of it.
  final double maxDollHeight;

  /// False when the preset extends the design for an undesigned board (D22).
  final bool designed;

  /// The ice overlay's height: 160, or 168 on [ShelfPresets.threeTall],
  /// where `fx_ice` plays stretched by `BoardTokens.iceTallFxScaleY`
  /// (tokens.json `layout.board.iceOverlayTall`).
  final double iceHeight;

  /// The size-6 preset (`threeShelvesTall`): its taller ice is played
  /// stretched.
  final bool tall;

  /// Four shelves: the glass case and the ice scale with the dolls' fit
  /// factor k about the stand surface (tokens.json `layout.boardPresets.
  /// fourShelves.pieces`, m7-4 5.2).
  final bool piecesFollowK;

  int get shelfCount => plankTops.length;
}

/// The presets by shape (tokens.json `layout.boardPresets`, phase 4
/// architecture §2.1).
abstract final class ShelfPresets {
  /// One row, for tiny boards (tokens.json `layout.boardPresets.oneShelf`,
  /// confirmed in m7-6, Choices 18): plank top 540, 150 dp dolls, up to 4
  /// slots, the boardFit rule applies.
  static const one = ShelfPreset(
    plankTops: [540],
    maxDollHeight: 150,
    designed: true,
  );

  /// Level 1–2 tutorial boards (frames 1.3/1.4, NestyBoard:76 `L2`).
  static final two = ShelfPreset(
    plankTops: BoardPresetTokens.twoShelves.plankTops,
    maxDollHeight: BoardPresetTokens.twoShelves.slotMaxDollHeight,
    designed: true,
  );

  /// The main board (frame 2.2, NestyBoard:76 `L3`), for `maxSize` ≤ 5.
  static final three = ShelfPreset(
    plankTops: BoardPresetTokens.threeShelves.plankTops,
    maxDollHeight: BoardPresetTokens.threeShelves.slotMaxDollHeight,
    designed: true,
  );

  /// The main board for a size-6 level: 12 dp higher with a 194 dp pitch, so
  /// the size-6 doll keeps 94.7 % of its height (`threeShelvesTall`).
  static final threeTall = ShelfPreset(
    plankTops: BoardPresetTokens.threeShelvesTall.plankTops,
    maxDollHeight: BoardPresetTokens.threeShelvesTall.slotMaxDollHeight,
    designed: true,
    iceHeight: BoardPresetTokens.threeShelvesTall.iceOverlay!.height,
    tall: true,
  );

  /// Four shelves (optional; no bundled level uses it): the glass case and
  /// the ice scale with k about the stand surface (m7-4 5.2), so they stay
  /// under the shelf above.
  static final four = ShelfPreset(
    plankTops: BoardPresetTokens.fourShelves.plankTops,
    maxDollHeight: BoardPresetTokens.fourShelves.slotMaxDollHeight,
    designed: true,
    piecesFollowK: true,
  );

  /// The preset for [shape]: the shelf count, and `maxSize` 6 on three
  /// shelves for the tall one. Throws [ArgumentError] outside 1–4 shelves
  /// (spec §2.1).
  static ShelfPreset forShape(BoardShape shape) => switch (shape.shelfCount) {
    1 => one,
    2 => two,
    3 => shape.maxSize == 6 ? threeTall : three,
    4 => four,
    _ => throw ArgumentError.value(
      shape.shelfCount,
      'shape',
      'a board has 1–4 shelves (spec §2.1)',
    ),
  };
}
