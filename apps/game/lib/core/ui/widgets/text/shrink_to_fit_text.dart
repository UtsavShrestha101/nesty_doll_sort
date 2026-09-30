import 'package:flutter/widgets.dart';

/// Text that wraps to at most [maxLines] and, when it still doesn't fit its
/// width, shrinks its font step by step (down to [minFontScale]) instead of
/// cutting a word or a line off (docs/plans/m7-design.md §15's shared rule:
/// text scales down, it is never cut; §15.2's badge names "2 lines, no
/// ellipsis at 1.3×"). A plain `FittedBox` can't do this for wrapping text:
/// it would lay the text out on one line and shrink that.
///
/// A word is never broken across lines: a word wider than the box shrinks
/// the font too. Measuring runs in build, so this is for short menu labels
/// (a badge name, a countdown), not for anything on the board's hot path.
class ShrinkToFitText extends StatelessWidget {
  const ShrinkToFitText(
    this.data, {
    required this.style,
    this.maxLines = 2,
    this.textAlign = TextAlign.center,
    this.minFontScale = 0.6,
    super.key,
  });

  final String data;
  final TextStyle style;
  final int maxLines;
  final TextAlign textAlign;

  /// The smallest share of [style]'s font size it shrinks to; past it the
  /// text is laid out at this size as it comes.
  final double minFontScale;

  static const double _step = 0.05;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final base = DefaultTextStyle.of(context).style.merge(style);
      final fontSize = base.fontSize ?? 14;
      final scaler = MediaQuery.textScalerOf(context);
      final direction = Directionality.of(context);
      var factor = 1.0;
      if (constraints.hasBoundedWidth) {
        while (factor - _step >= minFontScale - 1e-9 &&
            !_fits(
              base.copyWith(fontSize: fontSize * factor),
              constraints.maxWidth,
              scaler,
              direction,
            )) {
          factor -= _step;
        }
      }
      return Text(
        data,
        style: factor == 1
            ? style
            : style.copyWith(fontSize: fontSize * factor),
        maxLines: maxLines,
        textAlign: textAlign,
      );
    },
  );

  bool _fits(
    TextStyle style,
    double width,
    TextScaler scaler,
    TextDirection direction,
  ) {
    TextPainter painterFor(String text, {int? maxLines}) => TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: direction,
      textScaler: scaler,
      maxLines: maxLines,
    );
    final whole = painterFor(data, maxLines: maxLines)..layout(maxWidth: width);
    final exceeds = whole.didExceedMaxLines;
    whole.dispose();
    if (exceeds) return false;
    for (final word in data.split(RegExp(r'\s+'))) {
      if (word.isEmpty) continue;
      final painter = painterFor(word)..layout();
      final wide = painter.width > width;
      painter.dispose();
      if (wide) return false;
    }
    return true;
  }
}
