// Internal to nesty_render (not exported): the hard lid/body split of the
// doll part rasters (docs/plans/m2-lottie-design.md §4, PROGRESS D45).
import 'dart:ui' as ui;

/// Clears every pixel row of a [width] × [height] raster outside
/// `[top, bottom)`, on whole pixels and without anti-aliasing. Draw it
/// last, at the root of the recording (not inside a layer).
///
/// Cutting afterwards, not clipping first: under any clip, even a
/// whole-pixel one without anti-aliasing, Skia anti-aliases path edges
/// differently, and the doll's outline would stop matching the design
/// renders and `SvgSkinRenderer` by up to 32/255 on edge pixels.
void eraseRowsOutside(
  ui.Canvas canvas,
  int width,
  int height,
  int top,
  int bottom,
) {
  final erase = ui.Paint()
    ..blendMode = ui.BlendMode.clear
    ..isAntiAlias = false;
  if (top > 0) {
    canvas.drawRect(
      ui.Rect.fromLTRB(0, 0, width.toDouble(), top.toDouble()),
      erase,
    );
  }
  if (bottom < height) {
    canvas.drawRect(
      ui.Rect.fromLTRB(
        0,
        bottom.toDouble(),
        width.toDouble(),
        height.toDouble(),
      ),
      erase,
    );
  }
}
