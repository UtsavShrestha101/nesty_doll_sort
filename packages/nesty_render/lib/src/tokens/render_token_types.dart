import 'dart:ui' show Color, Offset, Rect, Size;

import 'package:flutter/foundation.dart' show immutable;

// Value types for the generated render_tokens.gen.dart. Hand-written (and
// editable) so behaviour can grow here while the values stay generated from
// design/tokens.json.

/// How a doll color tints the grayscale mask layers (design/README.md
/// "Doll rendering", step 1).
enum DollTintMode {
  /// Multiply every mask pixel by the base color (`BlendMode.modulate`).
  modulate,

  /// Map the mask's gray level through [DollColorToken.ramp] (gold).
  gradientMap,
}

/// One stop of a gradient-map ramp: [position] in 0–1 of the (shaped)
/// gray input, and the output [color].
@immutable
final class RampStop {
  const RampStop(this.position, this.color);

  final double position;
  final Color color;
}

/// The design values for one `DollColor` (tokens.json `dollColor.<id>`).
@immutable
final class DollColorToken {
  const DollColorToken({
    required this.id,
    required this.name,
    required this.base,
    required this.ink,
    required this.light,
    required this.symbol,
    this.wild = false,
    this.tintMode = DollTintMode.modulate,
    this.ramp = const [],
    this.rampInputExponent = 1,
  });

  /// The `nesty_core` `DollColor.id`.
  final String id;

  /// The design's English name (tooling only; players see ARB strings).
  final String name;

  /// Mask tint, pip fill and placeholder body color.
  final Color base;

  /// Darker shade for the belly symbol and rings.
  final Color ink;

  /// Lighter shade for highlights.
  final Color light;

  /// File base name of the belly symbol in `assets/symbols/`.
  final String symbol;

  /// True for the wild gold doll (spec §3.5, v1.1).
  final bool wild;

  final DollTintMode tintMode;

  /// Gradient-map stops when [tintMode] is [DollTintMode.gradientMap].
  final List<RampStop> ramp;

  /// The ramp input is `gray ^ rampInputExponent` (tokens: `gray^2`).
  final double rampInputExponent;
}

/// One hop of the completion bounce (tokens.json `motion.complete.hops`).
@immutable
final class MotionHop {
  const MotionHop({required this.height, required this.durationMs});

  /// Peak height in logical px.
  final double height;

  final int durationMs;
}

/// An ellipse in skin artboard coordinates: center and radii.
@immutable
final class TokenEllipse {
  const TokenEllipse({
    required this.cx,
    required this.cy,
    required this.rx,
    required this.ry,
  });

  final double cx;
  final double cy;
  final double rx;
  final double ry;

  /// The bounding rectangle, for `Canvas.drawOval`.
  Rect get rect =>
      Rect.fromCenter(center: Offset(cx, cy), width: rx * 2, height: ry * 2);
}

/// The three limits of the board fit (tokens v3 `layout.boardFit.limits`),
/// the largest doll height each allows, in dp at 390×844.
@immutable
final class BoardFitLimits {
  const BoardFitLimits({
    required this.vertical,
    required this.hud,
    required this.horizontal,
  });

  /// The plank above: `(pitchY − plankHeight − surface − headroom) /
  /// drawnHeight`.
  final double vertical;

  /// The HUD: `(planksY[0] − surface − hudClearY) / drawnHeight`.
  final double hud;

  /// The neighbours: `(min(standWidth, pitch) − neighbourGap) / bodyWidth`.
  final double horizontal;
}

/// One NestyBoard shelf preset (tokens v3 `layout.boardPresets.<name>`),
/// with the design's own results of the board fit for it.
@immutable
final class BoardPresetToken {
  const BoardPresetToken({
    required this.plankTops,
    required this.slotMaxDollHeight,
    required this.maxSlotsPerRow,
    required this.limits,
    required this.dollHeights,
    this.optional = false,
    this.iceOverlay,
  });

  /// Plank top y per shelf, top first.
  final List<double> plankTops;

  /// The size-6 doll height before the fit (`Hs`).
  final double slotMaxDollHeight;

  final int maxSlotsPerRow;

  /// The fit's limits for [maxSlotsPerRow] slots per row.
  final BoardFitLimits limits;

  /// Doll heights after the fit, per maxSize (index 0 = size 1).
  final Map<int, List<double>> dollHeights;

  /// Offered for variety; no bundled level needs it.
  final bool optional;

  /// The ice overlay's size when it differs from `BoardTokens.iceOverlaySize`
  /// (`threeShelvesTall`'s tall ice).
  final Size? iceOverlay;
}

/// The row of 5 slots (tokens v3 `layout.boardPresets.rowOfFive`): the
/// optional wide row, and the bottom shelf with a +1 Slot pad once every
/// shelf holds 4 (D172).
@immutable
final class RowOfFiveToken {
  const RowOfFiveToken({
    required this.pitch,
    required this.stand,
    required this.towerStand,
    required this.standScale,
    required this.standSurfaceOffset,
    required this.pipsScaled,
    required this.limits,
    required this.dollHeights,
    this.optional = false,
  });

  final double pitch;
  final Size stand;
  final Size towerStand;

  /// Stand and furniture scale at [pitch]: `min(90, pitch − 2.4) / 90`.
  final double standScale;

  /// The doll base sits this far below the scaled stand's top.
  final double standSurfaceOffset;

  /// False: the pips stay 6 dp at pitch 7.8 on a scaled stand.
  final bool pipsScaled;

  final BoardFitLimits limits;
  final Map<int, List<double>> dollHeights;
  final bool optional;
}

/// One chapter's UI accents (tokens v3 `theme.chapters.N.palette`).
/// [accentTop] → [accent] is the vertical gradient of chapter-coloured
/// surfaces (the chapter ribbon, the Chapters card header and progress
/// fill), [accentEdge] their solid bottom edge and text shadow, [onAccent]
/// the Fredoka text on them, [soft] and [ink] a tinted chip and its text,
/// and [band] the art's flat top band (behind the HUD and status bar, and
/// the fill shown while the art loads).
@immutable
final class ChapterPalette {
  const ChapterPalette({
    required this.band,
    required this.accentTop,
    required this.accent,
    required this.accentEdge,
    required this.onAccent,
    required this.soft,
    required this.ink,
  });

  final Color band;
  final Color accentTop;
  final Color accent;
  final Color accentEdge;
  final Color onAccent;
  final Color soft;
  final Color ink;
}

/// One chapter theme (tokens v3 `theme.chapters.N`): its id (the catalog's
/// and the save's), its palette and the Shop card crop.
@immutable
final class ChapterThemeToken {
  const ChapterThemeToken({
    required this.chapter,
    required this.id,
    required this.palette,
    required this.thumb,
  });

  /// 1-based.
  final int chapter;

  /// `ch01` … `ch10` (`assets/themes/<id>/background.svg`).
  final String id;

  final ChapterPalette palette;

  /// The Shop card crop, in art px, at `ChapterThemeTokens.thumbBox`'s
  /// ratio.
  final Rect thumb;
}
