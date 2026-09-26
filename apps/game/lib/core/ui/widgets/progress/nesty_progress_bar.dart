import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:nesty_game/core/extensions/context_extension.dart';
import 'package:nesty_game/core/ui/colors/app_colors.dart';
import 'package:nesty_game/core/ui/tokens/ui_tokens.gen.dart';
import 'package:nesty_game/core/ui/widgets/surface/surface_painter.dart';
import 'package:nesty_game/core/ui/widgets/surface/surface_styles.dart';

/// The fill colours: the green progress fill (win chapter card) or the
/// splash loader's orange (NestyMenus 1.1).
enum NestyProgressTone {
  green(AppGradientTokens.progressFill),
  orange(
    LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [AppColors.loaderTop, AppColorTokens.primary],
    ),
  );

  const NestyProgressTone(this.fill);

  final Gradient fill;
}

/// "Progress bar: track `#EAD3B0` with a sunk shadow, radius = height/2,
/// padding 2–3. Fill is the green gradient with a white inner top highlight
/// (the splash loader adds stripes)" (design/README.md "Components").
///
/// [value] is clamped to 0–1. The stripes are tokens.json
/// `gradient.progressFill.stripes` (−45°, 6 px on / 6 px off). In M2 the
/// splash loader is the `ui_splash_loader` Lottie; this bar is its static
/// fallback and the win card's chapter bar.
class NestyProgressBar extends StatelessWidget {
  const NestyProgressBar({
    required this.value,
    this.height = 22,
    this.striped = false,
    this.tone = NestyProgressTone.green,
    this.semanticLabel,
    super.key,
  });

  final double value;
  final double height;
  final bool striped;
  final NestyProgressTone tone;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final value = this.value.clamp(0.0, 1.0);
    return Semantics(
      label: semanticLabel,
      // The locale's percent format (spec §16), not a hard-coded "42%".
      value: context.localizations.progressPercent(value),
      child: SizedBox(
        height: height,
        width: double.infinity,
        child: CustomPaint(
          painter: _ProgressPainter(value: value, tone: tone, striped: striped),
        ),
      ),
    );
  }
}

final class _ProgressPainter extends CustomPainter {
  _ProgressPainter({
    required this.value,
    required this.tone,
    required this.striped,
  });

  final double value;
  final NestyProgressTone tone;
  final bool striped;

  static const _stripes = AppGradientTokens.progressFillStripes;
  static final Paint _stripePaint = Paint()..color = _stripes.color;
  static final Paint _highlight = Paint()..color = const Color(0x73FFFFFF);

  final Paint _fill = Paint();

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    final track = BorderRadius.circular(size.height / 2);
    SurfacePainter(
      style: SurfaceStyles.progressTrack,
      radius: track,
    ).paint(canvas, size);
    if (value <= 0) return;

    // "padding 2–3": 3 for the 22 px loader, 2 for the 16 px win bar.
    final pad = size.height >= 20 ? 3.0 : 2.0;
    final inner = Size(size.width - 2 * pad, size.height - 2 * pad);
    if (inner.isEmpty) return;
    // A sliver still shows as a round cap, like CSS radius on a thin box.
    final width = math.max(
      inner.width * value,
      math.min(inner.height, inner.width),
    );
    final rect = Rect.fromLTWH(pad, pad, width, inner.height);
    final fill = RRect.fromRectAndRadius(
      rect,
      Radius.circular(inner.height / 2),
    );

    _fill.shader = tone.fill.createShader(rect);
    canvas
      ..save()
      ..clipRRect(fill)
      ..drawRect(rect, _fill);
    if (striped) _paintStripes(canvas, rect);
    // `inset 0 2px 0 rgba(255,255,255,.45)`.
    canvas
      ..drawDRRect(fill.inflate(4), fill.shift(const Offset(0, 2)), _highlight)
      ..restore();
  }

  /// Bands along "/" (the −45° CSS gradient's stripes), [_stripes] period
  /// measured across them.
  void _paintStripes(Canvas canvas, Rect rect) {
    final period = (_stripes.onPx + _stripes.offPx) * math.sqrt2;
    final on = _stripes.onPx * math.sqrt2;
    final h = rect.height;
    for (var x = rect.left - h; x < rect.right; x += period) {
      final path = Path()
        ..moveTo(x, rect.bottom)
        ..lineTo(x + on, rect.bottom)
        ..lineTo(x + on + h, rect.top)
        ..lineTo(x + h, rect.top)
        ..close();
      canvas.drawPath(path, _stripePaint);
    }
  }

  @override
  bool shouldRepaint(_ProgressPainter oldDelegate) =>
      oldDelegate.value != value ||
      oldDelegate.tone != tone ||
      oldDelegate.striped != striped;
}
