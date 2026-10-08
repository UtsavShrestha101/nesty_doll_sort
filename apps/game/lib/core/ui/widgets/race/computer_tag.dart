import 'package:flutter/widgets.dart';
import 'package:nesty_game/core/extensions/context_extension.dart';
import 'package:nesty_game/core/ui/icons/icon_uses.dart';
import 'package:nesty_game/core/ui/tokens/ui_tokens.gen.dart';

/// "A computer opponent is always labelled a computer" (spec-prop §1.1 rule
/// 5): the tag beside every rival name (vs Computer; frame 9.1-9.7b; phase 4
/// ui-spec-game §1 "ComputerTag"). Rival select, the race strip, both
/// results, 9.6, Pause and Records carry it.
///
/// `versus.computerTag` (m7-6 item 2): 20 tall, radius 10, a 1.5 dp `#D8B07A`
/// ring on `#FFFDF7`, the `computer` glyph at 14 and "Computer" in Nunito 800
/// 11. Every one of those but the ring scales with the text setting k, up to
/// [ComputerTagTokens.maxTextScale] (20k tall, glyph 14k, text 11k, radius
/// 10k). Where a surface can't grow, the caller drops to the glyph first.
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

  /// The text setting k the tag scales by: the context's, at most
  /// [ComputerTagTokens.maxTextScale].
  static double scaleOf(BuildContext context) => MediaQuery.textScalerOf(
    context,
  ).scale(1).clamp(0.0, ComputerTagTokens.maxTextScale);

  /// The tag with its word, laid out at its scale k: the padding, the glyph,
  /// the gap and the word (the ring is painted, not laid out).
  static double fullWidth(BuildContext context) {
    final k = scaleOf(context);
    return RivalStripTokens.tagPadding.horizontal +
        ComputerTagTokens.glyphSize * k +
        _wordGap +
        lineWidth(
          context,
          context.localizations.raceComputerTag,
          ComputerTagTokens.text.copyWith(
            fontSize: ComputerTagTokens.text.fontSize! * k,
          ),
          scaled: false,
        );
  }

  /// One unwrapped line of [text] in [style], at the context's text scale
  /// unless [scaled] is false (a style that already carries its size).
  static double lineWidth(
    BuildContext context,
    String text,
    TextStyle style, {
    bool scaled = true,
  }) {
    final painter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: Directionality.of(context),
      textScaler: scaled
          ? MediaQuery.textScalerOf(context)
          : TextScaler.noScaling,
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
    const ring = ComputerTagTokens.ring;
    final k = scaleOf(context);
    return ExcludeSemantics(
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: ComputerTagTokens.face,
          borderRadius: BorderRadius.all(
            Radius.circular(ComputerTagTokens.radius * k),
          ),
          border: Border.all(color: ring.color, width: ring.width),
        ),
        child: SizedBox(
          height: ComputerTagTokens.height * k,
          child: Padding(
            padding: glyphOnly
                ? const EdgeInsets.symmetric(horizontal: 3)
                : RivalStripTokens.tagPadding.copyWith(top: 0, bottom: 0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  IconUses.computerTag,
                  size: ComputerTagTokens.glyphSize * k,
                  color: AppColorTokens.computerTagText,
                ),
                if (!glyphOnly) ...[
                  const SizedBox(width: _wordGap),
                  // k is a text scale (the setting, capped), so it goes on
                  // the scaler, not into the size: a fitted surface then
                  // judges the word against its 11 dp like any other text.
                  Text(
                    label,
                    style: ComputerTagTokens.text,
                    textScaler: TextScaler.linear(k),
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
