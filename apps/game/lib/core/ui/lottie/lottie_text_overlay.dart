import 'package:flutter/widgets.dart';
import 'package:nesty_game/core/ui/lottie/lottie_label.dart';

export 'package:nesty_game/core/ui/lottie/lottie_label.dart';

/// A Lottie that carries a localized label: the family counter and the win
/// and chapter ribbons (lottie design §12).
///
/// * [lottie] is the FX lane's view of the file. It hides the file's text
///   layers and paints [label] itself with a [LottieLabelPainter] following
///   the null (so the text moves and bumps with the art).
/// * With no [lottie] (the file failed to load, or before the FX lane
///   wires it: lottie §10 R10), [fallback] is shown, or else the label
///   alone at the null's rest position, so the text is never lost.
///
/// Either way the box has the composition's aspect ratio and screen
/// readers read [label] once.
class LottieTextOverlay extends StatelessWidget {
  const LottieTextOverlay({
    required this.label,
    required this.style,
    this.lottie,
    this.fallback,
    this.semanticLabel,
    super.key,
  });

  final String label;
  final LottieLabelStyle style;
  final Widget? lottie;

  /// A static stand-in drawn under the label (e.g. a flat ribbon).
  final Widget? fallback;

  /// Defaults to [label].
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final lottie = this.lottie;
    final fallback = this.fallback;
    return Semantics(
      label: semanticLabel ?? label,
      excludeSemantics: true,
      child: AspectRatio(
        aspectRatio: style.canvas.width / style.canvas.height,
        child:
            lottie ??
            Stack(
              fit: StackFit.expand,
              children: [
                ?fallback,
                CustomPaint(
                  painter: _RestLabelPainter(
                    label: label,
                    style: style,
                    direction:
                        Directionality.maybeOf(context) ?? TextDirection.ltr,
                  ),
                ),
              ],
            ),
      ),
    );
  }
}

/// The label at the null's rest position and scale 1, in a box that maps
/// the composition's canvas onto the widget's size.
final class _RestLabelPainter extends CustomPainter {
  _RestLabelPainter({
    required this.label,
    required this.style,
    required this.direction,
  });

  final String label;
  final LottieLabelStyle style;
  final TextDirection direction;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    final painter = LottieLabelPainter(style, textDirection: direction)
      ..text = label;
    canvas
      ..save()
      ..scale(
        size.width / style.canvas.width,
        size.height / style.canvas.height,
      );
    painter.paint(canvas, style.restNull);
    canvas.restore();
    painter.dispose();
  }

  @override
  bool shouldRepaint(_RestLabelPainter oldDelegate) =>
      oldDelegate.label != label ||
      oldDelegate.style != style ||
      oldDelegate.direction != direction;
}
