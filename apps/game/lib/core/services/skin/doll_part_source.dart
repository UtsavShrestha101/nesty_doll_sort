import 'package:nesty_core/nesty_core.dart';
import 'package:nesty_render/nesty_render.dart';

/// What `AssetSkinService` asks of nesty_render's [DollPartRasters]
/// (m2-lottie-design §4). A seam, because [DollPartRasters] is `final`:
/// tests hand the service small rasters of their own, or failures.
abstract interface class DollPartSource {
  /// [DollPartRasters.prepare]: the skin's part rasters. Throws when the
  /// skin can't be rasterized.
  ///
  /// [board] draws the silhouette: every skin's buried nests show the
  /// board's wood-grain blank (tokens `layout.towerSilhouettes`, owner
  /// decision 3e). Without it the silhouette is the skin's own (rule 3).
  Future<DollPartSet> prepare({
    required SkinRasterizer skin,
    required Iterable<DollColor> colors,
    required DollSymbols symbols,
    required int artHeightPx,
    SymbolAtlas? symbolAtlas,
    BoardSpriteLibrary? board,
  });

  /// [DollPartRasters.preparePlaceholder]: the rule-3 fallback, drawn by the
  /// procedural painter with the same split. [board] draws the silhouette
  /// as in [prepare].
  Future<DollPartSet> preparePlaceholder({
    required Iterable<DollColor> colors,
    required DollSymbols symbols,
    required int artHeightPx,
    SymbolAtlas? symbolAtlas,
    BoardSpriteLibrary? board,
  });

  void dispose();
}

/// The real [DollPartSource]: one [DollPartRasters] cache for the app, so
/// re-preparing a board (an extra slot's re-pitch, a symbols change) reuses
/// the rasters it already has.
final class DollPartRastersSource implements DollPartSource {
  DollPartRastersSource([DollPartRasters? rasters])
    : rasters = rasters ?? DollPartRasters();

  final DollPartRasters rasters;

  @override
  Future<DollPartSet> prepare({
    required SkinRasterizer skin,
    required Iterable<DollColor> colors,
    required DollSymbols symbols,
    required int artHeightPx,
    SymbolAtlas? symbolAtlas,
    BoardSpriteLibrary? board,
  }) => rasters.prepare(
    skin: skin,
    colors: colors,
    symbols: symbols,
    artHeightPx: artHeightPx,
    symbolAtlas: symbolAtlas,
    board: board,
  );

  @override
  Future<DollPartSet> preparePlaceholder({
    required Iterable<DollColor> colors,
    required DollSymbols symbols,
    required int artHeightPx,
    SymbolAtlas? symbolAtlas,
    BoardSpriteLibrary? board,
  }) => rasters.preparePlaceholder(
    colors: colors,
    symbols: symbols,
    artHeightPx: artHeightPx,
    symbolAtlas: symbolAtlas,
    board: board,
  );

  @override
  void dispose() => rasters.dispose();
}
