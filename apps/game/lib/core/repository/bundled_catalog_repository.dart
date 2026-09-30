import 'package:injectable/injectable.dart';
import 'package:nesty_core/nesty_core.dart';
import 'package:nesty_game/core/dependency_injection/app_env.dart';
import 'package:nesty_game/core/repository/catalog_repository.dart';

/// The catalog that ships in the app (D20: all art is bundled;
/// docs/plans/m3-design.md §9.1). Prices are frame 7.3's and 7.7's, plus
/// the recorded defaults for what the frames don't price (Space 1,200;
/// ch02 800 and ch03 1,000 before their chapter). M4 overlays Firestore
/// (spec §14.1) on it.
///
/// TODO(M4): overlay Firestore's `chapters`, `skins`, `themes` and
/// `museumItems` (cached, offline-first; spec §13.5, §14.1).
@LazySingleton(as: CatalogRepository, env: [AppEnv.real])
class BundledCatalogRepository implements CatalogRepository {
  /// The ten figurines of design/museum, in chapter order.
  static const figurineIds = [
    'classic',
    'sailor',
    'baker',
    'astronaut',
    'gardener',
    'snow',
    'circus',
    'musician',
    'royal',
    'explorer',
  ];

  /// The bundled chapter themes, one per launch chapter (m7-3 adds
  /// ch07–ch10, D171; phase 4 architecture §3.1).
  static const themeIds = [
    'ch01',
    'ch02',
    'ch03',
    'ch04',
    'ch05',
    'ch06',
    'ch07',
    'ch08',
    'ch09',
    'ch10',
  ];

  /// Chapters 1–10 (spec §7.1: 200 launch levels).
  static final List<ChapterInfo> bundledChapters = List.unmodifiable([
    for (var i = 0; i < figurineIds.length; i++)
      ChapterInfo(
        id: 'ch${(i + 1).toString().padLeft(2, '0')}',
        number: i + 1,
        themeId: themeIds[i],
        figurine: FigurineInfo(
          id: figurineIds[i],
          number: i + 1,
          artAsset: figurineArt(i + 1, figurineIds[i]),
          lockedArtAsset: figurineArt(i + 1, figurineIds[i], locked: true),
        ),
      ),
  ]);

  /// Frame 7.3's cards, in its order, then Forest Bear (m7-3 frames 7.3,
  /// 7.4b).
  static const List<SkinInfo> bundledSkins = [
    SkinInfo(
      id: 'classic',
      priceCoins: 0,
      previewColors: [DollColor.red, DollColor.yellow, DollColor.blue],
    ),
    // Owned in the frame, so unpriced there: a recorded default (Q72).
    SkinInfo(
      id: 'space',
      priceCoins: 1200,
      previewColors: [DollColor.navy, DollColor.purple, DollColor.teal],
    ),
    SkinInfo(
      id: 'ocean',
      priceCoins: 800,
      previewColors: [DollColor.teal, DollColor.blue, DollColor.navy],
    ),
    SkinInfo(
      id: 'sweets',
      priceCoins: 1500,
      previewColors: [DollColor.pink, DollColor.yellow, DollColor.red],
    ),
    SkinInfo(
      id: 'forest',
      priceCoins: 2000,
      previewColors: [DollColor.green, DollColor.brown, DollColor.orange],
    ),
    SkinInfo(
      id: 'winter',
      priceCoins: 3000,
      previewColors: [DollColor.blue, DollColor.red, DollColor.navy],
    ),
    // design/skins/forest-bear (D20), on sale at copy.md H's 2,500 (Q72,
    // inside spec §7.3's 800–3,000; phase 4 architecture §3.3).
    SkinInfo(
      id: 'forest-bear',
      priceCoins: forestBearPrice,
      previewColors: [DollColor.brown, DollColor.green, DollColor.orange],
    ),
  ];

  /// Forest Bear's price (copy.md H `forest_bear_price`; Q72).
  static const int forestBearPrice = 2500;

  /// Chapters 7–10's theme price until the owner sets them (Q156): no
  /// source prices them, so each takes ch06's 2,000, the top of spec §7.3's
  /// 500–2,000 theme range.
  static const int laterThemePrice = 2000;

  /// Frame 7.7's themes: ch04–ch06 priced there, ch02 and ch03 defaults
  /// (Q72), ch07–ch10 at [laterThemePrice] (Q156).
  static const List<ThemeInfo> bundledThemes = [
    ThemeInfo(id: 'ch01', chapterNumber: 1, priceCoins: 0),
    ThemeInfo(id: 'ch02', chapterNumber: 2, priceCoins: 800),
    ThemeInfo(id: 'ch03', chapterNumber: 3, priceCoins: 1000),
    ThemeInfo(id: 'ch04', chapterNumber: 4, priceCoins: 1200),
    ThemeInfo(id: 'ch05', chapterNumber: 5, priceCoins: 1500),
    ThemeInfo(id: 'ch06', chapterNumber: 6, priceCoins: 2000),
    ThemeInfo(id: 'ch07', chapterNumber: 7, priceCoins: laterThemePrice),
    ThemeInfo(id: 'ch08', chapterNumber: 8, priceCoins: laterThemePrice),
    ThemeInfo(id: 'ch09', chapterNumber: 9, priceCoins: laterThemePrice),
    ThemeInfo(id: 'ch10', chapterNumber: 10, priceCoins: laterThemePrice),
  ];

  /// `assets/museum/NN-<id>.png`, or its `-locked` silhouette: the names of
  /// `design/museum/png/`, which `sync_design_assets` ships.
  static String figurineArt(int number, String id, {bool locked = false}) =>
      'assets/museum/${number.toString().padLeft(2, '0')}-$id'
      '${locked ? '-locked' : ''}.png';

  @override
  Future<void> load() async {}

  @override
  List<ChapterInfo> get chapters => bundledChapters;

  @override
  ChapterInfo? chapter(String chapterId) {
    for (final chapter in bundledChapters) {
      if (chapter.id == chapterId) return chapter;
    }
    return null;
  }

  @override
  ChapterInfo? chapterNumbered(int number) =>
      number >= 1 && number <= bundledChapters.length
      ? bundledChapters[number - 1]
      : null;

  @override
  List<SkinInfo> get skins => bundledSkins;

  @override
  SkinInfo? skin(String skinId) {
    for (final skin in bundledSkins) {
      if (skin.id == skinId) return skin;
    }
    return null;
  }

  @override
  List<ThemeInfo> get themes => bundledThemes;

  @override
  ThemeInfo? theme(String themeId) {
    for (final theme in bundledThemes) {
      if (theme.id == themeId) return theme;
    }
    return null;
  }
}
