import 'package:flutter/widgets.dart';
import 'package:nesty_game/core/ui/widgets/surface/surface_painter.dart';
import 'package:nesty_game/core/ui/widgets/surface/surface_style.dart';

/// A non-pressable design surface: pills, cards, sheets, banners, badges.
///
/// The widget's box is the face; the style's edge and shadows paint outside
/// it without taking layout space (see [SurfacePainter]).
class NestySurface extends StatelessWidget {
  const NestySurface({
    required this.style,
    required this.radius,
    this.child,
    this.padding = EdgeInsets.zero,
    this.width,
    this.height,
    this.alignment,
    super.key,
  });

  final SurfaceStyle style;
  final BorderRadius radius;
  final Widget? child;
  final EdgeInsetsGeometry padding;
  final double? width;
  final double? height;

  /// Aligns [child] inside a face of [width] × [height]. Null lays the child
  /// out at the top left.
  final AlignmentGeometry? alignment;

  @override
  Widget build(BuildContext context) {
    Widget content = Padding(padding: padding, child: child);
    if (alignment != null) {
      // Hug the child on an axis with no explicit size.
      content = Align(
        alignment: alignment!,
        widthFactor: width == null ? 1 : null,
        heightFactor: height == null ? 1 : null,
        child: content,
      );
    }
    return SizedBox(
      width: width,
      height: height,
      child: CustomPaint(
        painter: SurfacePainter(style: style, radius: radius),
        child: content,
      ),
    );
  }
}
