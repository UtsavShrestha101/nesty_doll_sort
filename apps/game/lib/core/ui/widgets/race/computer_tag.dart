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

  /// Glyph only when the screen is narrower than the tokens' 360 dp.
  static bool glyphOnlyFor(BuildContext context) =>
      MediaQuery.sizeOf(context).width <
      RivalStripTokens.narrowTagGlyphOnlyBelowWidth;

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
                  const SizedBox(width: 3),
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
