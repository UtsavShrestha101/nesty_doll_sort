import 'dart:ui' as ui;

import 'package:flutter/widgets.dart';
import 'package:nesty_game/core/ui/colors/app_colors.dart';
import 'package:nesty_game/core/ui/tokens/ui_tokens.gen.dart';

/// The wood bar under the board (booster bar, frame 2.2) and the Home
/// bottom nav: "Wood gradient from y = 734 to the bottom, grain overlay, 3px
/// light top edge" (design/README.md "Booster bar").
///
/// Paints `gradient.woodBar` (`#D8995A 0 → #BD7B40 14px → #A56A34`), the
/// vertical grain (`gradient.woodBar.overlay`: 2 px every 30 px), a 3 px
/// `rgba(255,225,180,.6)` inner top highlight and the upward shadow
/// `0 -6px 14px rgba(90,45,15,.25)`. [child] is laid out inside [padding].
class WoodBar extends StatelessWidget {
  const WoodBar({
    this.child,
    this.height,
    this.padding = EdgeInsets.zero,
    super.key,
  });

  final Widget? child;

  /// Null takes the child's height plus [padding].
  final double? height;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: height,
    width: double.infinity,
    child: CustomPaint(
      painter: _WoodBarPainter(),
      child: Padding(padding: padding, child: child),
    ),
  );
}

final class _WoodBarPainter extends CustomPainter {
  static const _grain = AppGradientTokens.woodBarGrain;
  static const _highlightHeight = 3.0;

  final Paint _paint = Paint();
  Shader? _shader;
  double _shaderHeight = -1;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    final rect = Offset.zero & size;

    // The upward shadow, clipped to above the bar so it doesn't darken it.
    canvas
      ..save()
      ..clipRect(Rect.fromLTRB(-20, -40, size.width + 20, 0));
    _paint
      ..color = AppColors.woodBarShadow
      ..maskFilter = const ui.MaskFilter.blur(ui.BlurStyle.normal, 7);
    canvas
      ..drawRect(rect.shift(const Offset(0, -6)), _paint)
      ..restore();
    _paint.maskFilter = null;

    if (_shaderHeight != size.height) {
      _shader = AppGradientTokens.woodBar
          .resolve(size.height)
          .createShader(Rect.fromLTWH(0, 0, 1, size.height));
      _shaderHeight = size.height;
    }
    // Opaque, or the shader would inherit the shadow colour's alpha.
    _paint
      ..color = const Color(0xFF000000)
      ..shader = _shader;
    canvas.drawRect(rect, _paint);
    _paint.shader = null;

    _paint.color = _grain.color;
    for (var x = 0.0; x < size.width; x += _grain.spacing) {
      canvas.drawRect(
        Rect.fromLTWH(x, 0, _grain.lineWidth, size.height),
        _paint,
      );
    }

    _paint.color = AppColors.woodBarHighlight;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, _highlightHeight), _paint);
  }

  @override
  bool shouldRepaint(_WoodBarPainter oldDelegate) => false;
}
