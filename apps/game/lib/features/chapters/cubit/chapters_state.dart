part of 'chapters_cubit.dart';

/// What the Chapters screen shows (E7; docs/plans/m7-design.md §11,
/// §15.1).
@freezed
abstract class ChaptersState with _$ChaptersState {
  const factory ChaptersState({
    /// The header's coin pill (`SaveService.coins`).
    @Default(0) int coins,

    /// Every catalog chapter, in order: all ten render up front, future
    /// ones locked.
    @Default(<ChapterSection>[]) List<ChapterSection> chapters,

    /// Home's PLAY level (`SaveService.document.currentLevel`): the header's
    /// overall "Level {level} of {total}" line (owner's simulator review,
    /// 2026-09-28, design request I.4, "cool, clean, elegant, addictive").
    @Default(1) int currentLevel,

    /// Every catalog chapter's level count added up (200 at launch); the
    /// overall line's denominator.
    @Default(0) int totalLevels,
  }) = _ChaptersState;

  const ChaptersState._();

  /// Levels won over every chapter ("66 won", frame 10.4).
  int get wonCount => chapters.fold(0, (sum, section) => sum + section.won);
}

/// One chapter card: its levels in play order.
@freezed
abstract class ChapterSection with _$ChapterSection {
  const factory ChapterSection({
    /// `ch01` … `ch10`: the `chapterName` select key and the theme.
    required String chapterId,

    /// 1-based.
    required int number,

    /// The chapter's levels, first to last (20 per chapter, spec §7.1).
    @Default(<ChapterLevel>[]) List<ChapterLevel> levels,

    /// The chapter's board theme (`ChapterTheme.byId`), so its card can
    /// carry the theme's colour (owner's simulator review, 2026-09-28,
    /// D111: "give each chapter its character"). '' when the catalog entry
    /// somehow has none (falls back to a neutral tint).
    @Default('') String themeId,

    /// The figurine this chapter awards (`FigurineImage`, `museumFamilyLabel`
    /// / `museumSoonLabel`; same ids as the Museum). '' when the catalog
    /// entry somehow has none.
    @Default('') String figurineId,

    /// Mirrors `MuseumEntry.earned` (D111's "show it as ready" fix): the
    /// save's `museum` list, or every level in [levels] already won even
    /// before `museum` catches up. Never a stale "not earned" once [won]
    /// reaches [total].
    @Default(false) bool figurineEarned,

    /// Best stars over the chapter's won levels (`levelStars`; spec-prop
    /// §7.10, §10.2 #18; m7-design P3.7): the card's and the folded row's
    /// "38/60".
    @Default(0) int stars,

    /// `StarRating.maxStars` × the chapter's levels the bundle has with a
    /// par (60 for a full chapter at launch): the total beside [stars].
    @Default(0) int starsPossible,
  }) = _ChapterSection;

  const ChapterSection._();

  /// Levels won ("Chapter 3 · 16 / 20", `winChapterProgress`).
  int get won =>
      levels.where((level) => level.status == ChapterLevelStatus.won).length;

  int get total => levels.length;

  /// The chapter's first and last level numbers ("LEVELS 61–80").
  int get firstLevel => levels.isEmpty ? 0 : levels.first.order;
  int get lastLevel => levels.isEmpty ? 0 : levels.last.order;

  /// Every level at 3 stars (`starsPossible` reached): the folded row's gold
  /// ring and "Every level at 3 stars" (frame 10.4).
  bool get perfect => starsPossible > 0 && stars >= starsPossible;

  /// This chapter holds Home's PLAY level.
  bool get isCurrent =>
      levels.any((level) => level.status == ChapterLevelStatus.current);

  /// Some level is won or current: not a locked row.
  bool get reached =>
      levels.any((level) => level.status != ChapterLevelStatus.locked);

  /// Every level won: the card can fold into a compact row (D111, "a
  /// finished chapter can fold").
  bool get allWon => total > 0 && won >= total;
}

/// How a level cell looks and what a tap does (m7-design §11, §15.1).
enum ChapterLevelStatus {
  /// Won: a check mark, its best moves when it has one; a tap replays it.
  won,

  /// Home's PLAY level (`currentLevel`): a tap plays it as the campaign.
  current,

  /// Not reached, or not in the bundle yet: dimmed with a lock, no tap.
  locked,
}

/// One level cell.
@freezed
abstract class ChapterLevel with _$ChapterLevel {
  const factory ChapterLevel({
    /// The 1-based global play order (the number on the cell).
    required int order,
    @Default(ChapterLevelStatus.locked) ChapterLevelStatus status,

    /// The fewest moves of the bundle's current version of it
    /// (`SaveService.bestMovesFor`); null when won before best moves were
    /// kept (a migrated save shows the check mark without "Best").
    int? bestMoves,

    /// The bundle's own tier (spec §6.6); locked when the level isn't in the
    /// bundle. Draws the cell's thin HARD/SUPER HARD edge (owner's simulator
    /// review, 2026-09-28, design request I.4); easy/medium draw no edge,
    /// the same `TierChip.shows` cut.
    @Default(Tier.easy) Tier tier,

    /// A won cell's best stars, 1–3 (`levelStars[levelId]`; m7-design
    /// P3.7); null for a current or locked cell, and for a level won
    /// before stars that the load-time backfill gave none (no par).
    int? stars,

    /// The 3-star threshold in moves (`StarRating.threshold(par, star3)`),
    /// for the level card's "3 stars at N moves or fewer" (frame 10.4b);
    /// null without a par. Only meaningful for a won level.
    int? target,

    /// The bundle's level is here, in the chapter's 10th place: the milestone
    /// chest's cell (frame 10.4; spec-prop §1.1).
    @Default(false) bool isChest,

    /// The chapter's last level: the finale's flag (frame 10.4).
    @Default(false) bool isFinale,
  }) = _ChapterLevel;

  const ChapterLevel._();

  /// What a tap plays: a replay of a won level, the campaign's current
  /// one, nothing for a locked one.
  PlayRequest? get request => switch (status) {
    ChapterLevelStatus.won => PlayRequest.replay(order),
    ChapterLevelStatus.current => PlayRequest.campaign(order),
    ChapterLevelStatus.locked => null,
  };
}
