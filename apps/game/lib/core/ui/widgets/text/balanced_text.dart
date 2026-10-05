import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:nesty_game/core/ui/theme/locale_script.dart';

/// CSS `text-wrap: balance` and `pretty` for Flutter, which has neither.
///
/// The design's modal heads (NestyMeta.dc.html `text-wrap:balance`, tokens
/// 1460 and 1687) break a two- or three-line title into lines of nearly equal
/// width instead of one long line and an orphan.
class BalancedText extends StatelessWidget {
  const BalancedText(
    this.text, {
    required this.style,
    this.textAlign = TextAlign.center,
    super.key,
  });

  final String text;
  final TextStyle style;
  final TextAlign textAlign;

  /// The narrowest width, to the whole dp, at which [text] still breaks into
  /// as many lines as it does at [maxWidth]. Pure so the tests can use it.
  static double balancedWidth({
    required String text,
    required TextStyle style,
    required double maxWidth,
    required TextDirection direction,
    required TextScaler scaler,
  }) {
    int lines(double width) {
      final painter = TextPainter(
        text: TextSpan(text: text, style: style),
        textDirection: direction,
        textScaler: scaler,
      )..layout(maxWidth: width);
      final count = painter.computeLineMetrics().length;
      painter.dispose();
      return count;
    }

    final target = lines(maxWidth);
    if (target <= 1) {
      return maxWidth;
    }
    var low = 0.0;
    var high = maxWidth;
    // A width under one em can't hold a word; the search settles above it.
    while (high - low > 1) {
      final mid = (low + high) / 2;
      if (lines(mid) <= target) {
        high = mid;
      } else {
        low = mid;
      }
    }
    return math.min(maxWidth, high.ceilToDouble());
  }

  @override
  Widget build(BuildContext context) {
    final direction = Directionality.of(context);
    final scaler = MediaQuery.textScalerOf(context);
    // A heading that wraps keeps the script's title line height (Hindi and
    // Japanese need more room than their tokens' 1.0 to 1.1).
    final style = context.scriptStyle(this.style, role: ScriptTextRole.title);
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth;
        final width = maxWidth.isFinite
            ? balancedWidth(
                text: text,
                style: style,
                maxWidth: maxWidth,
                direction: direction,
                scaler: scaler,
              )
            : maxWidth;
        return Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: width),
            child: Text(text, textAlign: textAlign, style: style),
          ),
        );
      },
    );
  }
}

/// CSS `text-wrap: pretty`: joins the last two words with a no-break space so
/// a paragraph never ends on a one-word line. Text with no space (CJK, Thai)
/// comes back unchanged.
String bindLastWord(String text) {
  final trimmed = text.trimRight();
  final at = trimmed.lastIndexOf(' ');
  if (at <= 0 || at == trimmed.length - 1) {
    return text;
  }
  return '${trimmed.substring(0, at)} ${trimmed.substring(at + 1)}';
}
