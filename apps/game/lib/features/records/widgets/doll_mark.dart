import 'package:flutter/widgets.dart';
import 'package:nesty_game/core/ui/tokens/ui_tokens.gen.dart';

/// The family counter's doll mark (frame 10.6's "Families completed" tile;
/// tokens `layout.records.statsGrid.cell.tints.familiesCompleted`: 16×24 in
/// the stat's glyph colour): the doll blank `board/doll-silhouette.svg`
/// (viewBox 512×768) as one flat shape, a head over a body.
///
/// The two outlines are the silhouette's own clip paths, written as [Path]
/// commands because the game ships no SVG widget (the art would otherwise
/// need `nesty_render`'s rasterizer for a 16 dp mark). They are built once
/// and scaled per paint (rule 8).
class DollMark extends StatelessWidget {
  const DollMark({required this.color, this.size = _defaultSize, super.key});

  final Color color;
  final Size size;

  static const Size _defaultSize =
      RecordsTokens.statsGridCellTintsFamiliesCompletedMarkSize;

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: CustomPaint(size: size, painter: _DollMarkPainter(color)),
  );
}

class _DollMarkPainter extends CustomPainter {
  const _DollMarkPainter(this.color);

  final Color color;

  static const double _w = 512;
  static const double _h = 768;

  /// The silhouette's lid and body in its 512×768 artboard.
  static final Path _doll = Path()
    ..moveTo(256, 34)
    ..cubicTo(354, 34, 410, 102, 412, 196)
    ..cubicTo(413, 262, 398, 296, 400, 336)
    ..cubicTo(402, 372, 414, 396, 422, 412)
    ..lineTo(90, 412)
    ..cubicTo(98, 396, 110, 372, 112, 336)
    ..cubicTo(114, 296, 99, 262, 100, 196)
    ..cubicTo(102, 102, 158, 34, 256, 34)
    ..close()
    ..moveTo(402, 388)
    ..cubicTo(430, 436, 462, 530, 462, 610)
    ..cubicTo(462, 690, 426, 736, 372, 742)
    ..lineTo(140, 742)
    ..cubicTo(86, 736, 50, 690, 50, 610)
    ..cubicTo(50, 530, 82, 436, 110, 388)
    ..close();

  @override
  void paint(Canvas canvas, Size size) {
    // `contain`, centred, like the CSS mask.
    final scale = size.width / _w < size.height / _h
        ? size.width / _w
        : size.height / _h;
    canvas
      ..translate((size.width - _w * scale) / 2, (size.height - _h * scale) / 2)
      ..scale(scale)
      ..drawPath(_doll, Paint()..color = color);
  }

  @override
  bool shouldRepaint(_DollMarkPainter oldDelegate) =>
      oldDelegate.color != color;
}
