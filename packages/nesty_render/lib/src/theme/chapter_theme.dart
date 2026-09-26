import 'dart:ui' show Color;

/// The bundled chapter themes (spec §7.1 "each chapter has its own board
/// theme", §12.4; D20 bundles ch01–ch06). The enum name is the theme id the
/// save stores (`ownedThemes`, `selectedTheme`, spec §13.3) and the asset
/// folder (`assets/themes/<id>/background.svg`).
enum ChapterTheme {
  /// Sunny Toy Shop.
  ch01(Color(0xFFF4D29C)),

  /// Rainy Cafe Corner.
  ch02(Color(0xFFBFC6CC)),

  /// Seaside Market.
  ch03(Color(0xFFF3E6CF)),

  /// Snowy Cabin.
  ch04(Color(0xFFE7EDF2)),

  /// Night Carnival.
  ch05(Color(0xFF3B3470)),

  /// Spring Garden Shed.
  ch06(Color(0xFFDCEBC8));

  const ChapterTheme(this.fallbackColor);

  /// The colour the design sets each background on (NestyBoard:73, the `BG`
  /// map). It fills the screen behind the art, and alone while the art is
  /// rasterizing or if it fails to load.
  final Color fallbackColor;

  /// The theme id, e.g. `ch01`.
  String get id => name;

  /// The chapter the theme was drawn for, from 1.
  int get chapter => index + 1;

  /// The asset key of the background art under [basePath].
  String assetKey([String basePath = 'assets/themes']) =>
      '$basePath/$id/background.svg';

  /// The theme with [id], or null.
  static ChapterTheme? byId(String id) {
    for (final theme in values) {
      if (theme.id == id) return theme;
    }
    return null;
  }

  /// The theme of [chapter] (from 1). Throws [ArgumentError] below 1.
  static ChapterTheme forChapter(int chapter) {
    if (chapter < 1) {
      throw ArgumentError.value(chapter, 'chapter', 'chapters start at 1');
    }
    // TODO(M7): chapters 7–10 have no theme art yet (BACKLOG "Owner inputs
    // needed"); until it arrives they reuse the six themes in order.
    return values[(chapter - 1) % values.length];
  }
}
