import 'package:flutter/foundation.dart' show immutable;
import 'package:nesty_render/src/tokens/render_tokens.gen.dart';

/// Where the shelves sit for one shelf count, in reference units (spec
/// §10.3, render §1). The 2- and 3-shelf presets are the design's
/// (tokens.json `layout.board.planksY`, NestyBoard:76); the 1- and 4-shelf
/// ones extend its system for boards the design never drew (D22).
@immutable
final class ShelfPreset {
  const ShelfPreset({
    required this.plankTops,
    required this.maxDollHeight,
    required this.designed,
    this.pieceScale = 1,
  });

  /// Plank top y per shelf, top to bottom, on the 390×844 reference screen.
  final List<double> plankTops;

  /// The slot's maximum doll height ("Hs", spec §10.3): size `maxSize` is
  /// this tall when `maxSize` is 6, and every size is a fraction of it.
  final double maxDollHeight;

  /// Scale for every stand-sized piece (stand, pips, glass, ice, tag, glow,
  /// hint arrow, tower raise) before a crowded row shrinks it further. It is
  /// 1 on the designed presets; the 4-shelf preset scales its pieces with its
  /// dolls so a row's glass case and ice stay below the shelf above.
  final double pieceScale;

  /// False when the preset extends the design for an undesigned board (D22).
  final bool designed;

  int get shelfCount => plankTops.length;
}

/// The presets by shelf count.
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
    plankTops: BoardTokens.plankTopsByShelfCount[2]!,
    maxDollHeight: BoardTokens.slotMaxDollHeightByShelfCount[2]!,
    designed: true,
  );

  /// The main board (frame 2.2, NestyBoard:76 `L3`).
  static final three = ShelfPreset(
    plankTops: BoardTokens.plankTopsByShelfCount[3]!,
    maxDollHeight: BoardTokens.slotMaxDollHeightByShelfCount[3]!,
    designed: true,
  );

  // TODO(design): a 4-shelf board is undesigned (D22, BACKLOG "Design
  // gaps"). Planks are spread evenly from 250 to the 3-shelf bottom plank
  // (684), and dolls and pieces are scaled by 104/150 so the tallest doll
  // (maxSize 6) of the top row still clears the HUD at y 142.
  static const four = ShelfPreset(
    plankTops: [250, 395, 539, 684],
    maxDollHeight: 104,
    pieceScale: 104 / 150,
    designed: false,
  );

  /// Throws [ArgumentError] outside 1–4 shelves (spec §2.1).
  static ShelfPreset forShelfCount(int shelfCount) => switch (shelfCount) {
    1 => one,
    2 => two,
    3 => three,
    4 => four,
    _ => throw ArgumentError.value(
      shelfCount,
      'shelfCount',
      'a board has 1–4 shelves (spec §2.1)',
    ),
  };
}
