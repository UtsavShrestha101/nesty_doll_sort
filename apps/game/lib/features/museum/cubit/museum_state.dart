part of 'museum_cubit.dart';

/// One of the ten cabinet slots (frames 6.1–6.3; docs/plans/m3-design.md
/// §9.1, §10.6): [chapterNumber] and [figurineId] come from
/// `CatalogRepository.chapters`, [done]/[total] are that chapter's own
/// levels won (0 for a chapter far ahead of [MuseumState.homeLevelNumber]),
/// and [collectedOn] is the save's `museumCollected` date, when known.
@freezed
abstract class MuseumEntry with _$MuseumEntry {
  const factory MuseumEntry({
    /// The bundle's chapter id, `ch03` (`figurineName`/`figurineFlavor`
    /// select keys use [figurineId] instead, `chapterName` uses
    /// [themeId]).
    required String chapterId,

    /// 1-based (frame 6.3 "Finish Chapter 3…").
    required int chapterNumber,

    /// The chapter's board theme: the `chapterName` select key (spec §7.1,
    /// §12.4).
    required String themeId,

    /// `classic` … `explorer`: `FigurineImage`, `figurineName`,
    /// `figurineShortName`, `figurineFlavor`.
    required String figurineId,

    /// The chapter is in the save's `museum` (frame 6.1's colour art).
    required bool earned,

    /// The first not-[earned] chapter, in chapter order (frame 6.1's
    /// "15/20" chip; only one entry is ever true).
    required bool isNext,

    /// This chapter's own levels already won, 0 when
    /// [MuseumState.homeLevelNumber] hasn't reached it yet.
    required int done,

    /// Levels in the chapter (`ChapterInfo.levelsPerChapter`).
    required int total,

    /// The save's `museumCollected` date, or null when [earned] predates
    /// that field (frame 6.2 "Collected" with no date, m3-design §9.5).
    LocalDate? collectedOn,
  }) = _MuseumEntry;
}

/// What the Museum screen shows (frame 6.1's collection card and cabinet,
/// docs/plans/m3-design.md §10.6): [entries] is every chapter, in order,
/// ten of them.
@freezed
abstract class MuseumState with _$MuseumState {
  const factory MuseumState({
    /// The header's coin pill (`SaveService.coins`).
    required int coins,

    /// The collection card's "N / 10" (`museumCount`).
    required int collectedCount,

    /// The catalog's chapter count (`CatalogRepository.chapters.length`).
    required int totalChapters,

    /// The cabinet, one per chapter, chapter order.
    required List<MuseumEntry> entries,

    /// The locked/next modal's "▶ Play Level N" (`LevelResolver.homeRequest`,
    /// the same request Home's PLAY starts).
    required PlayRequest homeRequest,

    /// The number that button shows (`SaveService.currentLevel`).
    required int homeLevelNumber,
  }) = _MuseumState;

  const MuseumState._();

  /// The first [MuseumEntry.isNext] entry, or null once every chapter is
  /// [MuseumEntry.earned] (`museumAllHome`, a design gap).
  MuseumEntry? get next {
    for (final entry in entries) {
      if (entry.isNext) return entry;
    }
    return null;
  }

  /// Every chapter collected (frame 6.1 "Every family is home.").
  // TODO(design): no App Flow frame shows every chapter collected; this
  // reads the m3-design §10.6 fallback copy verbatim (`museumAllHome`).
  bool get allCollected => next == null;
}
