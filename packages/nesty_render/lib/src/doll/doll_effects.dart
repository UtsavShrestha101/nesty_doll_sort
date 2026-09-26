import 'dart:math' as math;
import 'dart:ui';

import 'package:nesty_render/src/doll/doll_art.dart';

/// Paint state shared by the doll renderers' fade, shine and reveal, built
/// once so a frame allocates nothing (CLAUDE.md rule 8). Internal to
/// nesty_render. All coordinates are art units: callers have already
/// mapped the canvas to the artboard.
final class DollEffects {
  DollEffects()
    : _band = Paint()
        ..shader = Gradient.linear(
          const Offset(-DollArt.shineHalfWidth, 0),
          const Offset(DollArt.shineHalfWidth, 0),
          const [
            Color(0x00FFFFFF),
            Color.fromRGBO(255, 255, 255, DollArt.shinePeakAlpha),
            Color(0x00FFFFFF),
          ],
          const [0, 0.5, 1],
        ),
      _unitCircle = Path()
        ..addOval(Rect.fromCircle(center: Offset.zero, radius: 1));

  final Paint _band;
  final Path _unitCircle;
  final Paint _fade = Paint();

  /// Keeps what is already in the layer only where the source is opaque.
  final Paint dstIn = Paint()..blendMode = BlendMode.dstIn;

  // Opacity is quantized to the 256 alpha levels a layer can hold anyway,
  // so fading never builds a Color per frame.
  static final List<Color> _alpha = List.unmodifiable([
    for (var a = 0; a < 256; a++) Color.fromARGB(a, 0, 0, 0),
  ]);

  static final _tan = math.tan(DollArt.shineTiltRadians);
  static final _cos = math.cos(DollArt.shineTiltRadians);

  // Past this, the tilted band is clear of the artboard at every y.
  static final double _bandMargin =
      DollArt.height / 2 * _tan + DollArt.shineHalfWidth / _cos;

  static const _bandRect = Rect.fromLTRB(
    -DollArt.shineHalfWidth,
    -DollArt.height,
    DollArt.shineHalfWidth,
    DollArt.height,
  );

  // ── Hot path: runs every frame. No allocation (CLAUDE.md rule 8). ──

  /// Starts a layer drawn at [opacity]; the caller restores it.
  void beginFade(Canvas canvas, double opacity) {
    _fade.color = _alpha[(opacity.clamp(0.0, 1.0) * 255).round()];
    canvas.saveLayer(DollArt.fadeBounds, _fade);
  }

  /// Draws the shine band at sweep [progress] (0: clear of the doll on the
  /// left, 1: clear on the right). The caller masks it with the doll's
  /// shape (draw the shape with [dstIn] inside a layer).
  ///
  /// The prototype's CSS sweep crosses the doll in only the middle ~40 % of
  /// its 300 ms; here the whole duration is the crossing, which is the
  /// design's intent ("Shine sweeps across the doll", 0–300 ms linear).
  void paintBand(Canvas canvas, double progress) {
    final t = progress.clamp(0.0, 1.0);
    final x = -_bandMargin + (DollArt.width + 2 * _bandMargin) * t;
    canvas
      ..save()
      ..translate(x, DollArt.height / 2)
      ..rotate(DollArt.shineTiltRadians)
      ..drawRect(_bandRect, _band)
      ..restore();
  }

  /// Clips to the reveal wipe circle at [progress] (0–1). The circle is one
  /// unit path scaled by the canvas, so no path is built per frame.
  void clipReveal(Canvas canvas, double progress) {
    final r = DollArt.revealMaxRadius * progress.clamp(0.0, 1.0);
    if (r <= 0) {
      canvas.clipRect(Rect.zero);
      return;
    }
    const c = DollArt.revealCenter;
    canvas
      ..translate(c.dx, c.dy)
      ..scale(r)
      ..clipPath(_unitCircle)
      ..scale(1 / r)
      ..translate(-c.dx, -c.dy);
  }

  // ── End of hot path. ──
}
