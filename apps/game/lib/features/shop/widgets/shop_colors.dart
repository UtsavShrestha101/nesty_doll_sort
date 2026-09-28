import 'package:flutter/painting.dart';

/// Colours `design/prototypes/NestyShop.dc.html` uses that neither
/// `design/tokens.json` nor `core/ui/colors/app_colors.dart` name yet
/// (the shop lane can't edit `app_colors.dart`; see its own doc comment for
/// the same "frame-only" precedent).
///
/// TODO(design): ask the designer to add these to tokens.json `color`, move
/// them into `AppColors`, and delete this file.
abstract final class SkinShopColors {
  /// Frame 7.3's flat "Equipped"/"In use" pill face.
  static const equippedFace = Color(0xFFDDF3E2);

  /// Frame 7.5's skin-card downloading ring (`0 0 0 3px #B79BE8`); built for
  /// M4, unreachable with the bundled catalog (D75).
  static const downloadingCardRing = Color(0xFFB79BE8);

  /// The downloading pill's face.
  static const downloadingFace = Color(0xFFEFE3F9);

  /// The downloading pill's 2 px inset ring and its spinner's track.
  static const downloadingPillRing = Color(0xFFCDB6EE);

  /// The downloading pill's text/icon and its spinner's active arc.
  static const downloadingText = Color(0xFF5530A8);

  /// Frame 7.4's colour panel edge (`0 6px 0 #7FB6C6`). The frame only
  /// draws Ocean's panel, so every skin's panel (its own
  /// [cardBackground]) gets this edge.
  ///
  /// TODO(design): per-skin panel edges for frame 7.4 (only Ocean's exists).
  static const detailPanelEdge = Color(0xFF7FB6C6);

  /// Frame 7.4's panel top highlight (`inset 0 2px 0 rgba(255,255,255,.6)`).
  static const detailPanelHighlight = Color(0x99FFFFFF);

  /// Frame 7.4's "All 11 colors" caption pill (`rgba(255,255,255,.85)`)
  /// and its ink.
  static const detailCaptionFace = Color(0xD9FFFFFF);
  static const detailCaptionText = Color(0xFF1F5E6E);

  /// Frame 7.4's translucent coin chip trailing "Buy"
  /// (`rgba(255,255,255,.22)`; frame 5.1's Play chip is the same).
  static const buyChipFace = Color(0x38FFFFFF);

  /// Frame 7.3's per-skin card backgrounds, top → bottom. Unlisted (or
  /// unsold) ids fall back to the cream card face.
  static const Map<String, List<Color>> _cardBackgrounds = {
    'classic': [Color(0xFFFCEBCB), Color(0xFFF3D4A0)],
    'space': [Color(0xFF3B3470), Color(0xFF232650)],
    'ocean': [Color(0xFFDDF2F6), Color(0xFFA9D8E4)],
    'sweets': [Color(0xFFFFE6EF), Color(0xFFF9C6D8)],
    'forest': [Color(0xFFE3F1D4), Color(0xFFC4DFAA)],
    'winter': [Color(0xFFEEF4FA), Color(0xFFD3E2F0)],
  };

  static const _fallback = [Color(0xFFFCEBCB), Color(0xFFF3D4A0)];

  /// [skinId]'s 180° preview background (frame 7.3), or the classic
  /// card's for an id the frame doesn't cover.
  static LinearGradient cardBackground(String skinId) => LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: _cardBackgrounds[skinId] ?? _fallback,
  );
}
