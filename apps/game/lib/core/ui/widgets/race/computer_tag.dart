import 'package:flutter/widgets.dart';
import 'package:nesty_game/core/extensions/context_extension.dart';
import 'package:nesty_game/core/ui/icons/icon_uses.dart';
import 'package:nesty_game/core/ui/tokens/ui_tokens.gen.dart';

/// "A computer opponent is always labelled a computer" (spec-prop §1.1 rule
/// 5): the tag beside every rival name (vs Computer; frame 9.1-9.7b; phase 4
/// ui-spec-game §1 "ComputerTag"). Rival select, the race strip, both
/// results, 9.6, Pause and Records carry it.
///
/// `layout.rivalStrip.tag`: 20 tall, radius 10, a 1.5 dp `#D8B07A` ring on
/// `#FFFDF7`, the `computer` glyph at 14 and "Computer" in Nunito 800 11.
/// With [glyphOnly] (a screen under `narrowTagGlyphOnlyBelowWidth`, 360 dp)
/// only the glyph shows. Use [ComputerTag.responsive] where the screen's
/// width decides.
///
/// Decorative for a screen reader: the caller's row or card label already
/// says "{name}, Computer" (`raceRivalSemantics`), so the tag is excluded.
class ComputerTag extends StatelessWidget {
  const ComputerTag({this.glyphOnly = false, super.key});

  /// The glyph alone (a narrow screen).
  final bool glyphOnly;

  /// Glyph only when the screen is narrower than the tokens' 360 dp (D192).
  static bool glyphOnlyFor(BuildContext context) =>
      MediaQuery.sizeOf(context).width <
      RivalStripTokens.narrowTagGlyphOnlyBelowWidth;

  /// Whether a row of [lead] (in [leadStyle]), a [gap] and this tag should
  /// show the glyph alone: under the screen rule, or when the full tag would
  /// make the row scale below [minScale] (textFit: the short form comes
  /// before shrinking past the floor).
  ///
  /// Only for a row whose own text already says "Computer": the Home tile's
  /// "vs Computer" label and the Pause header "vs Computer · {rival}". The
  /// race strip, a race's only on-screen rival label, keeps the word at
  /// 360 dp and up and makes room instead (`RivalStrip`; 5C ethics, D271).
  static bool glyphOnlyForRow(
    BuildContext context, {
    required String lead,
    required TextStyle leadStyle,
    required double gap,
    required double maxWidth,
    double minScale = 0.75,
  }) {
    if (glyphOnlyFor(context)) return true;
    if (!maxWidth.isFinite) return false;
    final total =
        lineWidth(context, lead, leadStyle) + gap + fullWidth(context);
    return maxWidth / total < minScale;
  }

  /// The tag with its word, laid out at the context's text scale: the
  /// padding, the glyph, the gap and the word (the ring is painted, not laid
  /// out).
  static double fullWidth(BuildContext context) =>
      RivalStripTokens.tagPadding.horizontal +
      RivalStripTokens.tagGlyphSize +
      _wordGap +
      lineWidth(
        context,
        context.localizations.raceComputerTag,
        RivalStripTokens.tagText,
      );

  /// One unwrapped line of [text] in [style] at the context's text scale.
  static double lineWidth(BuildContext context, String text, TextStyle style) {
    final painter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: Directionality.of(context),
      textScaler: MediaQuery.textScalerOf(context),
      maxLines: 1,
    )..layout();
    final width = painter.width;
    painter.dispose();
    return width;
  }

  static const double _wordGap = 3;

  /// A tag whose form follows the screen width.
  static Widget responsive({Key? key}) => Builder(
    key: key,
    builder: (context) => ComputerTag(glyphOnly: glyphOnlyFor(context)),
  );

  @override
  Widget build(BuildContext context) {
    final label = context.localizations.raceComputerTag;
    const ring = RivalStripTokens.tagRing;
    return ExcludeSemantics(
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: RivalStripTokens.tagFill,
          borderRadius: const BorderRadius.all(
            Radius.circular(RivalStripTokens.tagRadius),
          ),
          border: Border.all(color: ring.color, width: ring.width),
        ),
        child: SizedBox(
          height: RivalStripTokens.tagHeight,
          child: Padding(
            padding: glyphOnly
                ? const EdgeInsets.symmetric(horizontal: 3)
                : RivalStripTokens.tagPadding.copyWith(top: 0, bottom: 0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Icon(
                  IconUses.computerTag,
                  size: RivalStripTokens.tagGlyphSize,
                  color: AppColorTokens.computerTagText,
                ),
                if (!glyphOnly) ...[
                  const SizedBox(width: _wordGap),
                  Text(
                    label,
                    style: RivalStripTokens.tagText,
                    maxLines: 1,
                    softWrap: false,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
