import 'dart:ui' show Canvas;

import 'package:nesty_render/src/doll/doll_paint_params.dart';

/// Draws single dolls. The game's Flame components and the admin's
/// `CustomPainter` board both paint through this interface, so the look can
/// change (placeholder, SVG skin, later true 3D) without touching either of
/// them (spec §12.6).
///
/// A renderer only draws. It never decides what is on the board: that comes
/// from `nesty_core` state (CLAUDE.md rule 10). Pips, stands, glass and ice
/// belong to the board painters, not here (spec §10.3).
abstract interface class DollRenderer {
  /// Builds whatever this renderer caches (for a skin: every layer
  /// rasterized at each height, spec §12.2) for dolls of the given logical
  /// [heights] on a screen of [devicePixelRatio].
  ///
  /// Called off the hot path: at level load, behind the route transition.
  /// Heights accumulate (older ones are evicted past a limit), so two
  /// screens can share a renderer. [paint] may run before this completes.
  ///
  /// When the board re-lays out (an extra slot re-pitches the bottom row and
  /// changes every doll's height, `BoardLayout`), prepare the new heights
  /// and swap the geometry once this completes, as `BoardSprites.prepare`
  /// does; until then [canPaint] keeps the skin on screen, resampled.
  Future<void> prepare({
    required Iterable<double> heights,
    required double devicePixelRatio,
  });

  /// True when [paint] draws a doll of [height] at full quality right now:
  /// from rasters prepared for exactly that height. For tests and memory
  /// reports; must not allocate.
  bool isReadyFor(double height);

  /// True when [paint] draws a doll of [height] from this renderer's own
  /// art right now, even if only resampled from another prepared height.
  /// `FallbackDollRenderer` asks this every frame to choose the skin over
  /// the placeholder, so a re-layout that changes every height doesn't
  /// flash the placeholder while the new heights are prepared (review
  /// RENDER-2). Must not allocate.
  bool canPaint(double height);

  /// Paints one doll as described by [p].
  ///
  /// Runs every frame for every visible doll: must not allocate
  /// (CLAUDE.md rule 8).
  void paint(Canvas canvas, DollPaintParams p);

  /// Releases cached images. The renderer is unusable afterwards.
  void dispose();
}
