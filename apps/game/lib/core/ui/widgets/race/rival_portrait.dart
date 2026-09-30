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
    super.key,
  });

  /// The rival, 1–3.
  final int number;
  final double size;

  /// A rival not unlocked yet: `rival_locked.svg`.
  final bool locked;

  /// The wide versus ring (9.6, 9.7b).
  final bool emphasis;

  static const _ring = Color(0xFFFFFDF7);

  static const _plain = [
    BoxShadow(color: _ring, spreadRadius: 2),
    BoxShadow(color: Color(0x403C1905), offset: Offset(0, 2), blurRadius: 4),
  ];

  static const _emphasised = [
    BoxShadow(color: _ring, spreadRadius: 4),
    BoxShadow(color: AppColorTokens.versus, spreadRadius: 7),
    BoxShadow(color: Color(0x403242A8), offset: Offset(0, 8), blurRadius: 16),
  ];

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: DecoratedBox(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: _ring,
        boxShadow: emphasis ? _emphasised : _plain,
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
