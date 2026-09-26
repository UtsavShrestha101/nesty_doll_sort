import 'dart:ui' as ui;

import 'package:flutter/animation.dart';
import 'package:flutter/rendering.dart';
import 'package:nesty_game/core/ui/tokens/ui_token_types.dart';
import 'package:nesty_game/core/ui/widgets/surface/surface_style.dart';

/// Paints a [SurfaceStyle] into the painter's box: outer shadows beneath the
/// face, then the face, then inset shadows clipped to it, like CSS
/// `box-shadow` (a blur of B px is a Gaussian of sigma B/2).
///
/// The box is the face. Edges and drop shadows paint below and around it,
/// outside the layout box, exactly as a CSS box-shadow takes no layout space,
/// so the design's positions (e.g. a button's `top`) mean the same here.
///
/// With [press], the face moves down by `style.travel × press.value` and
/// every layer lerps towards `style.pressed` (the tactile press). Each paint
/// reuses one [Paint] and the cached face shader; menus are not a hot path,
/// but a press repaints for 80 ms and should stay cheap.
final class SurfacePainter extends CustomPainter {
  SurfacePainter({
    required this.style,
    required this.radius,
    this.press,
    List<NestyShadow>? pressed,
  }) : _pressed = pressed ?? (press == null ? null : style.pressed),
       super(repaint: press);

  final SurfaceStyle style;
  final BorderRadius radius;

  /// 0 = at rest, 1 = fully pressed.
  final Animation<double>? press;

  final List<NestyShadow>? _pressed;

  final Paint _paint = Paint();
  Shader? _shader;
  Size? _shaderSize;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    final t = press?.value ?? 0;
    final face = radius.toRRect(Offset.zero & size).scaleRadii();
    final shadows = style.shadows;
    final pressed = _pressed;

    canvas.save();
    if (t != 0) canvas.translate(0, style.travel * t);

    // Outer layers, bottom-most (last in CSS order) first.
    for (var i = shadows.length - 1; i >= 0; i--) {
      final layer = shadows[i];
      if (layer.inset) continue;
      _paintOuter(canvas, face, layer, pressed?[i], t);
    }

    _paintFace(canvas, face, size);

    var clipped = false;
    for (var i = shadows.length - 1; i >= 0; i--) {
      final layer = shadows[i];
      if (!layer.inset) continue;
      if (!clipped) {
        canvas
          ..save()
          ..clipRRect(face);
        clipped = true;
      }
      _paintInset(canvas, face, layer, pressed?[i], t);
    }
    if (clipped) canvas.restore();
    canvas.restore();
  }

  void _paintFace(Canvas canvas, RRect face, Size size) {
    final gradient = style.gradient;
    _paint
      ..maskFilter = null
      ..shader = null
      ..color = style.color ?? const Color(0xFF000000);
    if (gradient != null) {
      if (_shaderSize != size) {
        _shader = gradient.createShader(Offset.zero & size);
        _shaderSize = size;
      }
      _paint.shader = _shader;
    }
    canvas.drawRRect(face, _paint);
    _paint.shader = null;
  }

  void _paintOuter(
    Canvas canvas,
    RRect face,
    NestyShadow rest,
    NestyShadow? pressed,
    double t,
  ) {
    final dx = _lerp(rest.dx, pressed?.dx, t);
    final dy = _lerp(rest.dy, pressed?.dy, t);
    final blur = _lerp(rest.blur, pressed?.blur, t);
    final spread = _lerp(rest.spread, pressed?.spread, t);
    final color = pressed == null
        ? rest.color
        : Color.lerp(rest.color, pressed.color, t)!;
    _paint
      ..color = color
      ..maskFilter = blur > 0
          ? ui.MaskFilter.blur(ui.BlurStyle.normal, blur / 2)
          : null;
    canvas.drawRRect(
      face.shift(Offset(dx, dy)).inflate(spread).scaleRadii(),
      _paint,
    );
  }

  void _paintInset(
    Canvas canvas,
    RRect face,
    NestyShadow rest,
    NestyShadow? pressed,
    double t,
  ) {
    final dx = _lerp(rest.dx, pressed?.dx, t);
    final dy = _lerp(rest.dy, pressed?.dy, t);
    final blur = _lerp(rest.blur, pressed?.blur, t);
    final spread = _lerp(rest.spread, pressed?.spread, t);
    final color = pressed == null
        ? rest.color
        : Color.lerp(rest.color, pressed.color, t)!;
    _paint
      ..color = color
      ..maskFilter = blur > 0
          ? ui.MaskFilter.blur(ui.BlurStyle.normal, blur / 2)
          : null;
    // The shadow is the face minus its shifted, shrunk copy: a CSS inset
    // `0 2px 0 #fff` is the 2 px crescent under the top edge.
    final hole = face.shift(Offset(dx, dy)).deflate(spread).scaleRadii();
    if (hole.width <= 0 || hole.height <= 0) {
      canvas.drawRRect(face, _paint);
      return;
    }
    final margin = dx.abs() + dy.abs() + spread.abs() + blur * 2 + 1;
    canvas.drawDRRect(face.inflate(margin).scaleRadii(), hole, _paint);
  }

  static double _lerp(double a, double? b, double t) =>
      b == null || t == 0 ? a : a + (b - a) * t;

  @override
  bool shouldRepaint(SurfacePainter oldDelegate) =>
      oldDelegate.style != style ||
      oldDelegate.radius != radius ||
      oldDelegate.press != press;
}
