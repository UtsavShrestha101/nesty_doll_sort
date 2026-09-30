import 'dart:ui' show Color, Rect;

import 'package:nesty_render/src/tokens/render_token_types.dart';
import 'package:nesty_render/src/tokens/render_tokens.gen.dart';

/// The bundled chapter themes (spec §7.1 "each chapter has its own board
/// theme", §12.4; D20 bundled ch01–ch06, m7-3 adds ch07–ch10, D171). The enum
/// name is the theme id the save stores (`ownedThemes`, `selectedTheme`, spec
/// §13.3) and the asset folder (`assets/themes/<id>/background.svg`); adding
/// themes is additive for the save (no schema step).
///
/// Each theme carries its tokens v3 palette (`theme.chapters.N.palette`;
/// phase 4 architecture §3.1): the chapter ribbon, Home's chapter card, the
/// Chapters header and bar, and the Shop card read it.
enum ChapterTheme {
  /// Sunny Toy Shop.
  ch01(ChapterThemeTokens.ch01),

  /// Rainy Café Corner.
  ch02(ChapterThemeTokens.ch02),

  /// Seaside Market.
  ch03(ChapterThemeTokens.ch03),

  /// Snowy Cabin.
  ch04(ChapterThemeTokens.ch04),

  /// Night Carnival.
  ch05(ChapterThemeTokens.ch05),

  /// Spring Garden Shed.
  ch06(ChapterThemeTokens.ch06),

  /// Puppet Theater.
  ch07(ChapterThemeTokens.ch07),

  /// Autumn Bandstand.
  ch08(ChapterThemeTokens.ch08),

  /// Castle Library.
  ch09(ChapterThemeTokens.ch09),

  /// Sunrise Lookout.
  ch10(ChapterThemeTokens.ch10);

  const ChapterTheme(this.token);

  /// The theme's tokens v3 entry (`theme.chapters.N`).
  final ChapterThemeToken token;

  /// The chapter's colours (tokens v3 `theme.chapters.N.palette`).
  ChapterPalette get palette => token.palette;

  /// The Shop card's crop of the art, in art px (tokens v3
  /// `theme.chapters.N.thumb`, at `ChapterThemeTokens.thumbBox`'s ratio).
  Rect get thumb => token.thumb;

  /// The colour behind the art, and alone while it is rasterizing or if it
  /// fails to load: the palette's `band` (tokens win over the prototype's
  /// `BG` map, which ch01–ch06 used until m7-3; phase 4 architecture §3.1).
  Color get fallbackColor => token.palette.band;

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

  /// The theme of [chapter] (from 1): chapters 1–10 have their own, and a
  /// later chapter (M4's content) cycles the ten in order. Throws
  /// [ArgumentError] below 1.
  static ChapterTheme forChapter(int chapter) {
    if (chapter < 1) {
      throw ArgumentError.value(chapter, 'chapter', 'chapters start at 1');
    }
    return values[(chapter - 1) % values.length];
  }
}
