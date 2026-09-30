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

  int get shelfCount => plankTops.length;
}

/// The presets by shape (tokens.json `layout.boardPresets`, phase 4
/// architecture §2.1).
abstract final class ShelfPresets {
  // TODO(design): a 1-shelf board is undesigned (D22, BACKLOG "Design
  // gaps"). The plank sits where the 2-shelf pair is centred, with the
  // 3-shelf doll height.
  static const one = ShelfPreset(
    plankTops: [540],
    maxDollHeight: 150,
    designed: false,
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

  // TODO(design): fourShelves draws no glass or ice; pieces scale with the
  // dolls (a stand's furniture scale follows its pitch only, so a glass case
  // or ice on 4 shelves reaches the shelf above; no bundled level uses it).
  static final four = ShelfPreset(
    plankTops: BoardPresetTokens.fourShelves.plankTops,
    maxDollHeight: BoardPresetTokens.fourShelves.slotMaxDollHeight,
    designed: true,
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
