import 'package:flutter/painting.dart';
import 'package:nesty_game/core/ui/tokens/ui_token_types.dart';
import 'package:nesty_game/core/ui/tokens/ui_tokens.gen.dart';

/// Each skin's own Shop colours (tokens v3 `shop.skins.<id>`, generated as
/// `ShopTokens.skins`; F.1): the card's and the detail panel's top-to-bottom
/// gradients, the panel's 6 dp edge and the tag chip's caption colour. An id
/// the tokens don't cover (a later skin) gets Classic's.
abstract final class ShopLook {
  static ShopSkinColors of(String skinId) =>
      ShopTokens.skins[skinId] ?? ShopTokens.skins['classic']!;

  static LinearGradient _gradient(List<Color> colors) => LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: colors,
  );

  /// The Skins-tab card's preview gradient (frame 7.3).
  static LinearGradient card(String skinId) => _gradient(of(skinId).card);

  /// The detail panel's gradient (frames 7.4, 7.4b).
  static LinearGradient panel(String skinId) => _gradient(of(skinId).panel);

  /// The detail panel's 6 dp bottom edge.
  static Color edge(String skinId) => of(skinId).edge;

  /// The tag chip's text on the detail panel: the skin's `caption`, or the
  /// `skinTags` text where its caption wouldn't read on its chip (Space's
  /// `#2A2766`, m7-4 4.11).
  static Color caption(String skinId) =>
      ShopTokens.skinTags[skinId]?.text ?? of(skinId).caption;

  /// The tag chip's face: white at 85 %, or the skin's `skinTags` face where
  /// its caption wouldn't read on that (Space's white at 92 %, 12:1, m7-4
  /// 4.11).
  static Color captionFace(String skinId) =>
      ShopTokens.skinTags[skinId]?.face ?? ShopTokens.detailPanelTagFill;
}

/// Frame 7.5's downloading look, built for M4 and unreachable with the
/// bundled catalog (D75). tokens.json names none of these colours.
///
/// `TODO(design)`: add them to tokens.json `color` when M4's downloads land.
abstract final class SkinDownloadColors {
  /// The skin card's ring (`0 0 0 3px #B79BE8`).
  static const cardRing = Color(0xFFB79BE8);

  /// The downloading pill's face.
  static const face = Color(0xFFEFE3F9);

  /// The pill's 2 px inset ring and its spinner's track.
  static const pillRing = Color(0xFFCDB6EE);

  /// The pill's text and its spinner's active arc.
  static const text = Color(0xFF5530A8);
}
