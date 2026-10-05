import 'package:flutter/widgets.dart';
import 'package:nesty_game/core/ui/theme/locale_script.dart';

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
    this.overflowLines,
    this.fixedWidth,
    super.key,
  });

  final String data;
  final TextStyle style;
  final int maxLines;
  final TextAlign textAlign;

  /// The smallest share of [style]'s font size it shrinks to; past it the
  /// text is laid out at this size as it comes.
  final double minFontScale;

  /// A longer line count a string may use once it no longer fits [maxLines]
  /// even at [minFontScale] (a translated chapter name on a one-line row):
  /// the text goes to [overflowLines] lines and scales again from full size,
  /// so it is wrapped rather than cut (textFit: wrap where the surface
  /// allows). Null keeps [maxLines].
  final int? overflowLines;

  /// The width to fit to when the parent can't give one: a box inside an
  /// `IntrinsicHeight` can't hold a `LayoutBuilder` (it has no intrinsic
  /// size), so its owner passes the width it knows. Null measures the
  /// parent's own constraint.
  final double? fixedWidth;

  static final RegExp _breaksAnywhere = RegExp(
    r'[\u3040-\u30ff\u3400-\u9fff\uff00-\uffef]',
  );

  static const double _step = 0.05;

  @override
  Widget build(BuildContext context) {
    final width = fixedWidth;
    if (width != null) {
      return _fitted(context, BoxConstraints(maxWidth: width));
    }
    return LayoutBuilder(builder: _fitted);
  }

  Widget _fitted(BuildContext context, BoxConstraints constraints) {
    // Text that may wrap keeps the script's body line height.
    final style = maxLines > 1
        ? context.scriptStyle(this.style, role: ScriptTextRole.body)
        : context.scriptStyle(this.style);
    final base = DefaultTextStyle.of(context).style.merge(style);
    final fontSize = base.fontSize ?? 14;
    final scaler = MediaQuery.textScalerOf(context);
    final direction = Directionality.of(context);
    var lines = maxLines;
    var factor = 1.0;
    if (constraints.hasBoundedWidth) {
      double shrink(int count) {
        var f = 1.0;
        while (f - _step >= minFontScale - 1e-9 &&
            !_fits(
              base.copyWith(fontSize: fontSize * f),
              constraints.maxWidth,
              scaler,
              direction,
              count,
            )) {
          f -= _step;
        }
        return f;
      }

      factor = shrink(lines);
      final more = overflowLines ?? maxLines;
      if (more > maxLines &&
          !_fits(
            base.copyWith(fontSize: fontSize * factor),
            constraints.maxWidth,
            scaler,
            direction,
            lines,
          )) {
        lines = more;
        factor = shrink(lines);
      }
    }
    return Text(
      data,
      style: factor == 1 ? style : style.copyWith(fontSize: fontSize * factor),
      maxLines: lines,
      textAlign: textAlign,
    );
  }

  bool _fits(
    TextStyle style,
    double width,
    TextScaler scaler,
    TextDirection direction,
    int maxLines,
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
      // Japanese has no spaces and breaks between any two characters, so a
      // "word" of kana and kanji may wrap; only a Latin or Devanagari word
      // must stay whole.
      if (word.isEmpty || _breaksAnywhere.hasMatch(word)) continue;
      final painter = painterFor(word)..layout();
      final wide = painter.width > width;
      painter.dispose();
      if (wide) return false;
    }
    return true;
  }
}
