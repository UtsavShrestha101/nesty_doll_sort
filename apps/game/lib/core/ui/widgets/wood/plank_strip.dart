import 'dart:ui' as ui;

import 'package:flutter/widgets.dart';
import 'package:nesty_render/nesty_render.dart' show BoardSprite, BoardSprites;

/// A shelf plank across the screen, outside the board: the splash and Home
/// shelves (NestyMenus: 40 tall at y 566 / 372) and the win overlay's
/// family plank (NestyOverlay: 30 tall at y 350).
///
/// With [sprites] it tiles the skin's rasterized `shelf-plank.svg` (the
/// board's own tile, `BoardSprites.drawPlank`) once it exists. Until then,
/// or without [sprites], it paints the same art in code: the synced
/// `assets/board/shelf-plank.svg` is a few rects and strokes, so this needs
/// no asset or async work and draws in widget tests.
class PlankStrip extends StatelessWidget {
  const PlankStrip({this.height = 40, this.sprites, super.key});

  /// The plank's height; the art is 390×40 and scales with it.
  final double height;
  final BoardSprites? sprites;

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: SizedBox(
      height: height,
      width: double.infinity,
      child: CustomPaint(painter: _PlankPainter(sprites)),
    ),
  );
}

final class _PlankPainter extends CustomPainter {
  _PlankPainter(this.sprites) : super(repaint: sprites);

  final BoardSprites? sprites;

  // shelf-plank.svg, in its own 390×40 units.
  static const _tile = 390.0;
  static const _artHeight = 40.0;

  static final Paint _top = Paint()
    ..shader = ui.Gradient.linear(Offset.zero, const Offset(0, 11), const [
      Color(0xFFFCE6BA),
      Color(0xFFF0C98C),
    ]);
  static final Paint _front = Paint()
    ..shader = ui.Gradient.linear(
      const Offset(0, 11),
      const Offset(0, 34),
      const [Color(0xFFEDBF7D), Color(0xFFDCA15D), Color(0xFFC4844A)],
      const [0, 0.45, 1],
    );
  static final Paint _under = Paint()
    ..shader = ui.Gradient.linear(
      const Offset(0, 34),
      const Offset(0, 40),
      const [Color(0xFF8E5629), Color(0x008E5629)],
    );

  static Paint _stroke(Color color, double width) => Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = width
    ..color = color;

  /// (path, paint) for every stroke of one tile.
  static final List<(Path, Paint)> _strokes = [
    (_line(4.5), _stroke(const Color(0x59E3B06E), 1)),
    (_line(7.5), _stroke(const Color(0x80FFF4DC), 1)),
    (_line(11.5), _stroke(const Color(0xD9FFF1D2), 1.2)),
    (_wave(17, 2.5), _stroke(const Color(0x59B77A40), 1.2)),
    (_wave(22, 1.8), _stroke(const Color(0x73F6D29A), 1)),
    (_wave(27, 2.2), _stroke(const Color(0x4DB77A40), 1.2)),
    (_wave(31, 1.2), _stroke(const Color(0x40A8703A), 1)),
    (
      Path()..addOval(
        Rect.fromCenter(center: const Offset(122, 22), width: 14, height: 6),
      ),
      _stroke(const Color(0x739E6534), 1.2),
    ),
    (
      Path()..addOval(
        Rect.fromCenter(center: const Offset(298, 19), width: 10, height: 4.4),
      ),
      _stroke(const Color(0x669E6534), 1.2),
    ),
  ];

  static final Paint _knot = Paint()..color = const Color(0x739E6534);
  static final Rect _knotRect = Rect.fromCenter(
    center: const Offset(122, 22),
    width: 5,
    height: 2.2,
  );

  static Path _line(double y) => Path()
    ..moveTo(0, y)
    ..lineTo(_tile, y);

  /// The SVG's `M0 y C32.5 y−a 65 y−a 97.5 y S162.5 y+a 195 y …`: four
  /// cubic arcs alternating up and down.
  static Path _wave(double y, double a) {
    final path = Path()..moveTo(0, y);
    for (var i = 0; i < 4; i++) {
      final x0 = i * 97.5;
      final dy = i.isEven ? -a : a;
      path.cubicTo(x0 + 32.5, y + dy, x0 + 65, y + dy, x0 + 97.5, y);
    }
    return path;
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    final scale = size.height / _artHeight;
    final tilePaint = sprites?.image(BoardSprite.shelfPlank, scale)?.tilePaint;
    canvas
      ..save()
      ..clipRect(Offset.zero & size)
      ..scale(scale);
    if (tilePaint != null) {
      canvas.drawPaint(tilePaint);
    } else {
      final tiles = (size.width / scale / _tile).ceil();
      for (var i = 0; i < tiles; i++) {
        _paintTile(canvas);
        canvas.translate(_tile, 0);
      }
    }
    canvas.restore();
  }

  static void _paintTile(Canvas canvas) {
    canvas
      ..drawRect(const Rect.fromLTWH(0, 0, _tile, 11), _top)
      ..drawRect(const Rect.fromLTWH(0, 11, _tile, 23), _front)
      ..drawRect(const Rect.fromLTWH(0, 34, _tile, 6), _under);
    for (final (path, paint) in _strokes) {
      canvas.drawPath(path, paint);
    }
    canvas.drawOval(_knotRect, _knot);
  }

  @override
  bool shouldRepaint(_PlankPainter oldDelegate) =>
      !identical(oldDelegate.sprites, sprites);
}
