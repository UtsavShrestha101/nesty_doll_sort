import 'package:flutter/widgets.dart';
import 'package:nesty_game/core/ui/art/ui_art.dart';
import 'package:nesty_game/core/ui/art/ui_art_image.dart';
import 'package:nesty_game/core/ui/tokens/ui_tokens.gen.dart';

/// A rival's round portrait (vs Computer; frames 9.2-9.7b; ui-spec-game §1
/// "RivalPortrait"): the design's `ui/rivals/rival_{1,2,3}.svg` (or
/// `rival_locked.svg`), drawn round through `UiArtImage`, inside a
/// `#FFFDF7` ring and a soft drop (`0 0 0 2 #FFFDF7, 0 2 4 rgba(60,25,5,
/// .25)`).
///
/// Sizes in use: 96 (select), 88 (9.7b), 56 (result cards), 48, 40
/// (Records), 38 (the strip), 30 (Pause's header), 128 (9.6). [emphasis]
/// is 9.6's and 9.7b's wider ring in versus indigo.
///
/// Decorative: the row or card it sits in names the rival ("{name},
/// Computer"), so the portrait is excluded from semantics and never speaks
/// the bare number it once wore.
class RivalPortrait extends StatelessWidget {
  const RivalPortrait({
    required this.number,
    this.size = 96,
    this.locked = false,
    this.emphasis = false,
    this.ring = true,
    super.key,
  });

  /// The rival, 1–3.
  final int number;
  final double size;

  /// A rival not unlocked yet: `rival_locked.svg`.
  final bool locked;

  /// The wide versus ring (9.6, 9.7b).
  final bool emphasis;

  /// Draws the `#FFFDF7` ring and its drop. [RivalReact] draws them itself
  /// under its Lottie and turns this off for its stand-in.
  final bool ring;

  static const _ring = Color(0xFFFFFDF7);

  /// The plain ring and drop, for [RivalReact]'s own.
  static const plainShadows = _plain;

  // CSS paints the first shadow on top, Flutter the last, so the design's
  // lists (`0 0 0 2px ring, drop`; `0 0 0 4px ring, 0 0 0 7px indigo, drop`,
  // NestyMeta.dc.html:281) are written in reverse here.
  static const _plain = [
    BoxShadow(color: Color(0x403C1905), offset: Offset(0, 2), blurRadius: 4),
    BoxShadow(color: _ring, spreadRadius: 2),
  ];

  static const _emphasised = [
    BoxShadow(color: Color(0x403242A8), offset: Offset(0, 8), blurRadius: 16),
    BoxShadow(color: AppColorTokens.versus, spreadRadius: 7),
    BoxShadow(color: _ring, spreadRadius: 4),
  ];

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: DecoratedBox(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: ring ? _ring : null,
        boxShadow: !ring
            ? null
            : emphasis
            ? _emphasised
            : _plain,
      ),
      child: ClipOval(
        child: UiArtImage.square(
          locked ? UiArt.rivalLocked : UiArt.rival(number),
          extent: size,
        ),
      ),
    ),
  );
}
