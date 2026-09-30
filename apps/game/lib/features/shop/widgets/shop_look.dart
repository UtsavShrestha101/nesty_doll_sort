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

  /// The tag chip's text on the detail panel.
  static Color caption(String skinId) => of(skinId).caption;

  /// The tag chip's face. A dark skin's caption is a light lilac (Space's
  /// `#E6E3FF`), illegible on the frame's white `.85` chip, so the chip
  /// takes the panel's own dark `edge` at `.85` there (menus spec 8.1).
  ///
  /// `TODO(design)`: confirm Space's chip (menus spec §10, BACKLOG "M7
  /// phase 4 design gaps").
  static Color captionFace(String skinId) {
    final look = of(skinId);
    final light = look.caption.computeLuminance() > 0.6;
    return light
        ? look.edge.withValues(alpha: 0.85)
        : ShopTokens.detailPanelTagFill;
  }
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
