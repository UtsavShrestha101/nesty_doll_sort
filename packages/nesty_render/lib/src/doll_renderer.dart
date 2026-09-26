import 'dart:ui';

import 'package:nesty_core/nesty_core.dart';

// TODO(M2): PlaceholderDollPainter implements DollRenderer: the procedural
// doll of spec §12.5, and the fallback whenever a skin fails to load.
// TODO(M2): SvgSkinRenderer + SkinCache implement DollRenderer: skin layers
// rasterized once per needed size into cached ui.Images and tinted with
// BlendMode.modulate (spec §12.2, §13.5).

/// Draws a single doll. The game's Flame components and the admin's
/// `CustomPainter` board both paint through this interface, so the look can
/// change (placeholder, SVG skin, later true 3D) without touching either of
/// them (spec §12.6).
///
/// A renderer only draws. It never decides what is on the board: that comes
/// from `nesty_core` state (CLAUDE.md rule 10). Pip bars, stands, glass and
/// ice belong to the slot painters, not here (spec §10.3).
abstract interface class DollRenderer {
  /// Prepares whatever this renderer caches (for a skin: rasterizing every
  /// layer, spec §12.2) for dolls whose tallest size is [maxDollHeight]
  /// logical pixels, i.e. the slot's maximum doll height of spec §10.3.
  ///
  /// Called off the hot path, when a level loads or the board is resized.
  /// [paintDoll] may run before the returned future completes and must still
  /// draw something sensible; the skin renderer falls back to the placeholder
  /// (spec §12.5).
  Future<void> prepare({
    required double maxDollHeight,
    required double devicePixelRatio,
  });

  /// Paints one doll of [color] inside [bounds], bottom-centred, keeping the
  /// doll's aspect ratio. The caller sizes [bounds] per doll size using the
  /// board layout (spec §10.3).
  ///
  /// [lidLift] is how far the lid (upper body) is raised, from 0 (closed) to
  /// 1 (fully open, the skin's `lidLiftPx`), for the nest and swallow
  /// animations (spec §11.1, §12.2). [silhouette] paints the plain wooden
  /// shape used for hidden tower nests (spec §3.2); [color] is then ignored.
  ///
  /// Runs every frame for every visible doll: must not allocate
  /// (CLAUDE.md rule 8).
  void paintDoll(
    Canvas canvas,
    Rect bounds,
    DollColor color, {
    double lidLift = 0,
    bool silhouette = false,
  });

  /// Releases cached images. The renderer is unusable afterwards.
  void dispose();
}
