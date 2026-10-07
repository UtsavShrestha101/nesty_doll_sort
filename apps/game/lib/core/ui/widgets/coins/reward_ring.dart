import 'dart:ui' as ui;

import 'package:flutter/widgets.dart';
import 'package:nesty_game/core/extensions/context_extension.dart';
import 'package:nesty_game/core/ui/tokens/ui_token_types.dart';
import 'package:nesty_game/core/ui/tokens/ui_tokens.gen.dart';

/// The glow ring a chest's flights light around their target while sprites
/// land (tokens.json `motion.chest.collect.pillRing` and `hintRing`, m7-4
/// 1.7; frames 10.3c, 10.3d, and the daily gift's 13.5 and 13.6d, m7-5):
///
/// - [RewardRing.pill] is the HUD's coin pill's: the pill's own rectangle
///   with `0 0 0 4px rgba(255,214,110,.8), 0 0 18px 6px rgba(255,205,80,.6)`
///   round it, in over 80 ms and out over 240 ms;
/// - [RewardRing.hint] is the Hint badge's: a 38 dp circle centred on the
///   badge with `0 0 0 3px #FFE08A, 0 0 14px 4px rgba(255,205,80,.7)`, on
///   the same fade.
///
/// Like a CSS `box-shadow` on an element with no fill, the ring paints only
/// outside its shape ([RingGlowPainter]), so the pill's coin and number and
/// the badge's count stay readable under it (m7-5 Part 2 item 3).
///
/// It never changes the child's layout. Under reduced motion (the flights
/// don't fly) it paints nothing.
class RewardRing extends StatefulWidget {
  /// The coin pill's ring: the child's own box.
  const RewardRing.pill({required this.visible, required this.child, super.key})
    : _hint = false;

  /// The Hint badge's ring: [ChestCollectTokens.hintRingSize], centred on
  /// the child.
  const RewardRing.hint({required this.visible, required this.child, super.key})
    : _hint = true;

  final bool visible;
  final Widget child;
  final bool _hint;

  /// The ring while it is shown or fading, for tests.
  static const Key ringKey = Key('reward-ring');

  /// The ring's fade-in (`pillRing.inMs`).
  static const Duration fadeIn = Duration(
    milliseconds: ChestCollectTokens.pillRingInMs,
  );

  /// The ring's fade-out (`pillRing.outMs`).
  static const Duration fadeOut = Duration(
    milliseconds: ChestCollectTokens.pillRingOutMs,
  );

  @override
  State<RewardRing> createState() => _RewardRingState();
}

class _RewardRingState extends State<RewardRing> {
  /// The ring joins the tree the first time it shows and stays (at opacity
  /// 0) so its fade-out can run; until then a booster's badge carries
  /// nothing extra.
  bool _shown = false;

  @override
  Widget build(BuildContext context) {
    final child = widget.child;
    if (context.reduceMotion) return child;
    if (widget.visible) _shown = true;
    if (!_shown) return child;
    final visible = widget.visible;
    final ring = widget._hint
        ? const OverflowBox(
            minWidth: ChestCollectTokens.hintRingSize,
            maxWidth: ChestCollectTokens.hintRingSize,
            minHeight: ChestCollectTokens.hintRingSize,
            maxHeight: ChestCollectTokens.hintRingSize,
            child: CustomPaint(
              key: RewardRing.ringKey,
              painter: RingGlowPainter.hint(),
              size: Size.square(ChestCollectTokens.hintRingSize),
            ),
          )
        : const CustomPaint(
            key: RewardRing.ringKey,
            painter: RingGlowPainter.pill(),
          );
    return Stack(
      clipBehavior: Clip.none,
      children: [
        child,
        Positioned.fill(
          child: IgnorePointer(
            child: AnimatedOpacity(
              opacity: visible ? 1 : 0,
              duration: visible ? RewardRing.fadeIn : RewardRing.fadeOut,
              child: ring,
            ),
          ),
        ),
      ],
    );
  }
}

/// Paints a ring of CSS outer `box-shadow` layers round a shape, outside
/// the shape only (CSS never paints an element's outer shadow under the
/// element itself): the chests' and the daily gift's pill ring, and the
/// hint ring on a badge or on the gift tally's disc.
///
/// The shape is the paint box, a stadium ([RingGlowPainter.pill]) or a
/// circle ([RingGlowPainter.hint]); [opacity] scales every layer (a ring
/// fading in or out without an `Opacity` layer).
class RingGlowPainter extends CustomPainter {
  /// `motion.chest.collect.pillRing` round a stadium (the coin pill).
  const RingGlowPainter.pill({this.opacity = 1, super.repaint})
    : shadows = ChestCollectTokens.pillRingShadow,
      circle = false;

  /// `motion.chest.collect.hintRing` round a circle (a disc or a badge).
  const RingGlowPainter.hint({this.opacity = 1, super.repaint})
    : shadows = ChestCollectTokens.hintRingShadow,
      circle = true;

  final List<NestyShadow> shadows;
  final bool circle;
  final double opacity;

  /// The shape [size] makes: a stadium, or the circle inscribed in it.
  RRect shapeOf(Size size) {
    final rect = Offset.zero & size;
    if (circle) {
      return RRect.fromRectAndRadius(
        Rect.fromCircle(center: rect.center, radius: size.shortestSide / 2),
        Radius.circular(size.shortestSide / 2),
      );
    }
    return RRect.fromRectAndRadius(rect, Radius.circular(size.height / 2));
  }

  @override
  void paint(Canvas canvas, Size size) =>
      paintRing(canvas, shapeOf(size), shadows, opacity: opacity);

  /// Paints [shadows] round [shape] (CSS order: the first layer on top),
  /// clipped to outside it. Shared with the gift's scrim and chest layers,
  /// which draw the ring at a live rect rather than round a widget.
  static void paintRing(
    Canvas canvas,
    RRect shape,
    List<NestyShadow> shadows, {
    double opacity = 1,
  }) {
    if (opacity <= 0 || shadows.isEmpty) return;
    var reach = 0.0;
    for (final layer in shadows) {
      final r = layer.spread + layer.blur + layer.dx.abs() + layer.dy.abs();
      if (r > reach) reach = r;
    }
    final outside = Path()
      ..fillType = PathFillType.evenOdd
      ..addRect(shape.outerRect.inflate(reach + 2))
      ..addRRect(shape);
    canvas
      ..save()
      ..clipPath(outside);
    final paint = Paint();
    // CSS paints the first layer on top: draw from the last.
    for (final layer in shadows.reversed) {
      if (layer.inset) continue;
      paint
        ..color = layer.color.withValues(alpha: layer.color.a * opacity)
        ..maskFilter = layer.blur > 0
            ? ui.MaskFilter.blur(ui.BlurStyle.normal, layer.blur / 2)
            : null;
      canvas.drawRRect(
        shape.shift(Offset(layer.dx, layer.dy)).inflate(layer.spread),
        paint,
      );
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(RingGlowPainter oldDelegate) =>
      oldDelegate.opacity != opacity ||
      oldDelegate.circle != circle ||
      !identical(oldDelegate.shadows, shadows);
}
