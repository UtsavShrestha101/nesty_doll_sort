import 'package:injectable/injectable.dart';
import 'package:nesty_game/core/dependency_injection/app_env.dart';
import 'package:nesty_game/core/repository/bundled_catalog_repository.dart';
import 'package:nesty_game/core/repository/catalog_repository.dart';

/// An in-memory [CatalogRepository] for tests and the fake env: the bundled
/// catalog unless a test passes its own [chapters], [skins] or [themes].
@LazySingleton(as: CatalogRepository, env: [AppEnv.fake])
class FakeCatalogRepository implements CatalogRepository {
  FakeCatalogRepository({
    @ignoreParam List<ChapterInfo>? chapters,
    @ignoreParam List<SkinInfo>? skins,
    @ignoreParam List<ThemeInfo>? themes,
  }) : chapters = chapters ?? BundledCatalogRepository.bundledChapters,
       skins = skins ?? BundledCatalogRepository.bundledSkins,
       themes = themes ?? BundledCatalogRepository.bundledThemes;

  @override
  final List<ChapterInfo> chapters;

  @override
  final List<SkinInfo> skins;

  @override
  final List<ThemeInfo> themes;

  @override
  Future<void> load() async {}

  @override
  ChapterInfo? chapter(String chapterId) {
    for (final chapter in chapters) {
      if (chapter.id == chapterId) return chapter;
    }
    return null;
  }

  @override
  ChapterInfo? chapterNumbered(int number) {
    for (final chapter in chapters) {
      if (chapter.number == number) return chapter;
    }
    return null;
  }

  @override
  SkinInfo? skin(String skinId) {
    for (final skin in skins) {
      if (skin.id == skinId) return skin;
    }
    return null;
  }

  @override
  ThemeInfo? theme(String themeId) {
    for (final theme in themes) {
      if (theme.id == themeId) return theme;
    }
    return null;
  }
}
