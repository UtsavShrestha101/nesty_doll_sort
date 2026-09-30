import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:nesty_core/nesty_core.dart';

part 'catalog_models.freezed.dart';

/// A chapter's museum figurine (spec §7.2; design/museum; frames 6.1–6.3).
/// Its name and flavor text are ARB selects keyed by [id] (`figurineName`,
/// `figurineFlavor`; Q47).
@freezed
abstract class FigurineInfo with _$FigurineInfo {
  const factory FigurineInfo({
    /// `classic` … `explorer`: the ARB select key.
    required String id,

    /// 1-based, the chapter it belongs to.
    required int number,

    /// The earned art, `assets/museum/NN-<id>.png` (synced from
    /// `design/museum/png/` by `sync_design_assets`, m3-design §9.5).
    required String artAsset,

    /// The locked silhouette, `assets/museum/NN-<id>-locked.png`.
    required String lockedArtAsset,
  }) = _FigurineInfo;
}

/// A chapter of 20 levels (spec §7.1) with its theme and figurine
/// (docs/plans/m3-design.md §9.1).
@freezed
abstract class ChapterInfo with _$ChapterInfo {
  const factory ChapterInfo({
    /// The bundle's `chapterId`, `ch01` … `ch10`; also the `chapterName`
    /// ARB select key (copy.md G.4 names ch07–ch10).
    required String id,

    /// 1-based.
    required int number,

    /// Its board theme: each launch chapter has its own (m7-3's ch07–ch10,
    /// D171; `ChapterTheme.forChapter`).
    required String themeId,

    /// The figurine completing it awards.
    required FigurineInfo figurine,

    /// Levels per chapter (spec §7.1).
    @Default(ChapterInfo.levelsPerChapter) int levels,
  }) = _ChapterInfo;

  /// Spec §7.1: "Chapters are 20 levels each".
  static const int levelsPerChapter = 20;
}

/// A doll skin in the Shop (spec §7.4, frames 7.3–7.4). Its name and
/// description are ARB selects keyed by [id] (`skinName`,
/// `skinDescription`).
@freezed
abstract class SkinInfo with _$SkinInfo {
  const factory SkinInfo({
    /// The skin folder under `assets/skins/` and the save's id.
    required String id,

    /// Coins to buy it; 0 for the bundled Classic every player owns.
    required int priceCoins,

    /// The three dolls on its Shop card, left to right (frame 7.3).
    required List<DollColor> previewColors,

    /// False for a skin that ships but isn't offered (`forest-bear`).
    @Default(true) bool sold,
  }) = _SkinInfo;
}

/// A board theme in the Shop (spec §7.4, frame 7.7).
@freezed
abstract class ThemeInfo with _$ThemeInfo {
  const factory ThemeInfo({
    /// `ch01` … `ch06`: `ChapterTheme.byId`, and the `chapterName` select
    /// key for its name.
    required String id,

    /// The chapter it was drawn for. Reaching that chapter unlocks it
    /// (frame 7.7: "Chapter themes unlock with their chapter and can then
    /// be used anywhere. Later ones can be bought early.").
    required int chapterNumber,

    /// Coins to buy it before its chapter; 0 for ch01.
    required int priceCoins,
  }) = _ThemeInfo;

  const ThemeInfo._();

  /// Owned: listed in the save's `ownedThemes` (bought, or ch01), or its
  /// chapter reached ([reachedChapter], the chapter of the player's
  /// current level; the last published one in Bonus Endless).
  bool isOwned({
    required List<String> ownedThemes,
    required int reachedChapter,
  }) => ownedThemes.contains(id) || chapterNumber <= reachedChapter;
}
