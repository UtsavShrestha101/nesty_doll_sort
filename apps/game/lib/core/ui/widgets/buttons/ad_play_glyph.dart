import 'package:flutter/widgets.dart';
import 'package:nesty_game/core/ui/tokens/ui_tokens.gen.dart';

/// The rewarded-ad mark: "a CSS triangle inside a white 30×24 rounded
/// rectangle, so draw it as a shape" (design/README.md "Typography &
/// icons"). [bare] is the white triangle alone (the compact ▶ buttons and
/// the booster ad badge).
class AdPlayGlyph extends StatelessWidget {
  /// The white box with a purple triangle: 30×24 r7 with a 10×13 triangle
  /// (large buttons), 26×20 r6 with 8×10 (medium).
  const AdPlayGlyph({this.boxWidth = 30, super.key}) : bare = false;

  /// Just the white triangle, [boxWidth] wide (its height is 1.3×).
  const AdPlayGlyph.bare({this.boxWidth = 11, super.key}) : bare = true;

  final double boxWidth;
  final bool bare;

  @override
  Widget build(BuildContext context) {
    final size = bare
        ? Size(boxWidth, boxWidth * 14 / 11)
        : Size(boxWidth, boxWidth * 0.8);
    return ExcludeSemantics(
      child: CustomPaint(
        size: size,
        painter: _AdPlayPainter(bare: bare),
      ),
    );
  }
}

final class _AdPlayPainter extends CustomPainter {
  _AdPlayPainter({required this.bare});

  final bool bare;

  static final Paint _white = Paint()..color = const Color(0xFFFFFFFF);
  static final Paint _purple = Paint()..color = AppColorTokens.ad;

  @override
  void paint(Canvas canvas, Size size) {
    if (bare) {
      canvas.drawPath(_triangle(Offset.zero & size), _white);
      return;
    }
    // 30×24 r7 box; a 10×13 triangle nudged 3 px right of centre.
    final k = size.width / 30;
    canvas.drawRRect(
      RRect.fromRectAndRadius(Offset.zero & size, Radius.circular(7 * k)),
      _white,
    );
    final w = 10 * k;
    final h = 13 * k;
    final left = (size.width - w) / 2 + 1.5 * k;
    final top = (size.height - h) / 2;
    canvas.drawPath(_triangle(Rect.fromLTWH(left, top, w, h)), _purple);
  }

  static Path _triangle(Rect r) => Path()
    ..moveTo(r.left, r.top)
    ..lineTo(r.right, r.center.dy)
    ..lineTo(r.left, r.bottom)
    ..close();

  @override
  bool shouldRepaint(_AdPlayPainter oldDelegate) => oldDelegate.bare != bare;
}
