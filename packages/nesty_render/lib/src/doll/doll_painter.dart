import 'dart:math' as math;

import 'package:flutter/rendering.dart';
import 'package:nesty_core/nesty_core.dart';
import 'package:nesty_render/src/doll/doll_art.dart';
import 'package:nesty_render/src/doll/doll_paint_params.dart';
import 'package:nesty_render/src/doll/doll_renderer.dart';

/// A `CustomPainter` that draws one doll with a [DollRenderer], for widgets
/// (home idle dolls, win families, museum) and the admin's playtest board,
/// which has no Flame (spec §13.1).
///
/// The 2 : 3 artboard is fitted inside the paint size and aligned to its
/// bottom centre, like the design's `<nesty-doll>` element
/// (`object-fit: contain; object-position: 50% 100%`). A raised lid may draw
/// above the box. Repaint through [repaint] (e.g. when an async `prepare`
/// completes) or by building a new painter.
final class DollPainter extends CustomPainter {
  DollPainter({
    required this.renderer,
    required this.color,
    this.symbols = DollSymbols.subtle,
    this.part = DollPart.full,
    this.silhouette = false,
    this.lidLift = 0,
    this.open = false,
    this.opacity = 1,
    this.shine = -1,
    this.reveal = -1,
    super.repaint,
  });

  final DollRenderer renderer;
  final DollColor color;
  final DollSymbols symbols;
  final DollPart part;
  final bool silhouette;
  final double lidLift;
  final bool open;
  final double opacity;
  final double shine;
  final double reveal;

  final DollPaintParams _params = DollPaintParams();

  /// The doll height that fits [size] (width × 3/2 or the height, whichever
  /// is smaller): what to pass to `DollRenderer.prepare` for this painter.
  static double heightFor(Size size) =>
      math.min(size.height, size.width * DollArt.height / DollArt.width);

  @override
  void paint(Canvas canvas, Size size) {
    final height = heightFor(size);
    if (height <= 0) return;
    _params
      ..color = color
      ..height = height
      ..baseX = size.width / 2
      ..baseY = size.height - height * (1 - DollArt.base.dy / DollArt.height)
      ..symbols = symbols
      ..part = part
      ..silhouette = silhouette
      ..lidLift = lidLift
      ..open = open
      ..opacity = opacity
      ..shine = shine
      ..reveal = reveal;
    renderer.paint(canvas, _params);
  }

  @override
  bool shouldRepaint(DollPainter oldDelegate) =>
      !identical(oldDelegate.renderer, renderer) ||
      oldDelegate.color != color ||
      oldDelegate.symbols != symbols ||
      oldDelegate.part != part ||
      oldDelegate.silhouette != silhouette ||
      oldDelegate.lidLift != lidLift ||
      oldDelegate.open != open ||
      oldDelegate.opacity != opacity ||
      oldDelegate.shine != shine ||
      oldDelegate.reveal != reveal;
}
