import 'package:nesty_core/nesty_core.dart';
import 'package:nesty_game/features/fx/fx_image_source.dart';
import 'package:nesty_render/nesty_render.dart';

/// The art one laid-out board needs, prepared by [SkinService.prepareForLevel]
/// (m2-lottie-design §4). The board owns it and disposes it when the level
/// ends or a newer one replaces it.
abstract interface class LevelSkin {
  /// Fills every Lottie image slot: the level's `DollPartSet` (lid and body
  /// per colour on the board, the silhouette), the board sprites at each
  /// furniture scale, and the unlock symbols.
  FxImageSource get images;

  /// Draws the rest sprites from the same part rasters as [images], so
  /// sprite ↔ clip hand-offs are pixel-identical (`PartRasterDollRenderer`;
  /// the placeholder painter in the fake env and when the skin fails).
  DollRenderer get restRenderer;

  /// Planks, stands, pips' stands, the static glass/ice/glow fallbacks.
  /// Null when the board art is unavailable (the fake env): the board then
  /// draws flat fallback shapes (CLAUDE.md rule 3).
  BoardSprites? get sprites;

  /// Releases this board's handles. Idempotent.
  void dispose();
}

/// The selected skin, rasterized for boards (spec §7.4, §12.2, §13.5).
///
/// The real implementation, `AssetSkinService`, holds one `SkinRasterizer`
/// for the selected skin (bundled Classic until M3's shop), one
/// `SymbolAtlas`, one `BoardSpriteLibrary`, a `DollPartRasters` cache and
/// the gameplay [background]. It never throws into callers: a skin that
/// fails to load falls back to placeholder part rasters (rule 3). The fake
/// env uses `FakeSkinService` (placeholder painter, no images).
abstract interface class SkinService {
  /// The chapter theme behind the gameplay screen (spec §12.4): the
  /// gameplay page calls `show(ChapterTheme.forChapter(n), size:,
  /// devicePixelRatio:)` from its LayoutBuilder and paints it with a
  /// `ThemeBackgroundPainter`. One per app, owned by the service. Null in
  /// the fake env: the page then fills the theme's `fallbackColor`.
  ThemeBackground? get background;

  /// Loads what every board shares (the skin's layers, the board SVGs, the
  /// symbol SVGs), once, at splash. Later calls return the same future.
  /// Never throws.
  Future<void> load();

  /// Rasterizes what a board of [level] laid out as [geometry] needs on a
  /// [devicePixelRatio] screen, with [symbols] bellies:
  /// - part rasters for every colour on the board at
  ///   `DollPartRasters.artHeightPxFor(geometry.maxDollHeight, dpr)`;
  /// - board sprites at every furniture scale on the board (plus the
  ///   extra-slot stand while +Slot is usable, and the level's ice frames);
  /// - the unlock colours' symbols at 12 × furniture scale × DPR.
  ///
  /// Call it behind the route transition, and again after a re-layout (an
  /// extra slot re-pitches the bottom row): the new [LevelSkin] reuses the
  /// cached rasters, then the caller swaps and disposes the old one. Never
  /// throws.
  Future<LevelSkin> prepareForLevel(
    Level level, {
    required BoardGeometry geometry,
    required double devicePixelRatio,
    required DollSymbols symbols,
  });

  /// Releases what [load] holds and the [background] (DI reset). Boards
  /// already prepared keep their own handles. Idempotent.
  void dispose();
}
