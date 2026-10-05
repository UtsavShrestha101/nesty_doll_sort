import 'package:flutter/widgets.dart';
import 'package:nesty_game/core/ui/lottie/lottie_label.dart';
import 'package:nesty_game/core/ui/theme/locale_script.dart';

/// One line of text for a tight surface, fitted the way tokens.json
/// `textFit` orders it (DELIVERY 9.2): the full string at its size, else
/// the full string scaled down to the surface's `minScale`, else the short
/// form (copy.md "Short forms"), and as a last resort the short form scaled
/// further so nothing is ever cut. Single line only: surfaces that may wrap
/// use `Text` or `ShrinkToFitText`.
///
/// A screen reader hears [full] either way ([semanticsLabel]): a short form
/// is only a shorter way to draw it.
class FitText extends StatelessWidget {
  const FitText(
    this.full, {
    required this.style,
    this.short,
    this.minScale = 0.75,
    this.textAlign = TextAlign.center,
    this.alignment = Alignment.center,
    super.key,
  });

  final String full;

  /// The ARB's short form, or null for a surface that only scales.
  final String? short;
  final TextStyle style;

  /// The smallest share of [style]'s size the full string may shrink to
  /// before the short form takes over (textFit's `minScale`).
  final double minScale;
  final TextAlign textAlign;

  /// Where the text sits in a box wider than it.
  final AlignmentGeometry alignment;

  /// Which of [full] and [short] a box [maxWidth] wide draws: the full
  /// string while it fits at [minScale] or more, else the short form.
  /// Pure, so a test can run it with any string.
  static String pick({
    required String full,
    required String? short,
    required TextStyle style,
    required double maxWidth,
    required TextScaler scaler,
    required TextDirection direction,
    required double minScale,
  }) {
    if (short == null || short == full || !maxWidth.isFinite) return full;
    final width = _width(full, style, scaler, direction);
    if (width <= maxWidth + 0.01) return full;
    return maxWidth / width >= minScale - 1e-9 ? full : short;
  }

  static double _width(
    String text,
    TextStyle style,
    TextScaler scaler,
    TextDirection direction,
  ) {
    final painter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: direction,
      textScaler: scaler,
      maxLines: 1,
    )..layout();
    final width = painter.width;
    painter.dispose();
    return width;
  }

  @override
  Widget build(BuildContext context) {
    final style = context.scriptStyle(this.style);
    final merged = DefaultTextStyle.of(context).style.merge(style);
    final scaler = MediaQuery.textScalerOf(context);
    final direction = Directionality.of(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final shown = pick(
          full: full,
          short: short,
          style: merged,
          maxWidth: constraints.maxWidth,
          scaler: scaler,
          direction: direction,
          minScale: minScale,
        );
        final text = Text(
          shown,
          style: style,
          maxLines: 1,
          softWrap: false,
          textAlign: textAlign,
          semanticsLabel: shown == full ? null : full,
        );
        if (!constraints.hasBoundedWidth) return text;
        return FittedBox(
          fit: BoxFit.scaleDown,
          alignment: alignment,
          child: text,
        );
      },
    );
  }
}

/// Picks a ribbon's label (the win, race and chapter ribbons draw their
/// text inside the art's box, `LottieLabelStyles`): the full string while
/// the box fits it at [minScale] or more, else the short form.
abstract final class RibbonLabel {
  static String pick(
    BuildContext context, {
    required LottieLabelStyle style,
    required String full,
    required String short,
    double minScale = 0.75,
  }) {
    if (short == full) return full;
    final fit = LottieLabelPainter.fitOf(
      style,
      full,
      Directionality.maybeOf(context) ?? TextDirection.ltr,
    );
    return fit >= minScale - 1e-9 ? full : short;
  }
}
