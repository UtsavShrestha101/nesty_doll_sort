import 'package:nesty_game/core/repository/catalog_models.dart';

export 'package:nesty_game/core/repository/catalog_models.dart';

/// The chapters, figurines, skins and themes the game offers (spec §7.1,
/// §7.2, §7.4; docs/plans/m3-design.md §9.1).
///
/// `BundledCatalogRepository` serves the bundled catalog (every piece of
/// art ships, D20); M4 overlays Firestore's `chapters`, `skins`, `themes`
/// and `museumItems` (spec §14.1) on it, offline-first. `FakeCatalogRepository`
/// serves tests. Everything is in memory after [load], so reads are
/// synchronous and never throw.
abstract interface class CatalogRepository {
  /// Loads the catalog (the bundled one is const; M4 reads its cache).
  /// Called once by the splash. Never throws.
  Future<void> load();

  /// Chapters 1–10, in order.
  List<ChapterInfo> get chapters;

  /// The chapter [chapterId] (`ch03`), or null.
  ChapterInfo? chapter(String chapterId);

  /// The chapter numbered [number] (from 1), or null.
  ChapterInfo? chapterNumbered(int number);

  /// Every skin, in the Shop's order (frame 7.3), sold or not.
  List<SkinInfo> get skins;

  /// The skin [skinId], or null.
  SkinInfo? skin(String skinId);

  /// Every theme, in chapter order (frame 7.7).
  List<ThemeInfo> get themes;

  /// The theme [themeId], or null.
  ThemeInfo? theme(String themeId);
}
