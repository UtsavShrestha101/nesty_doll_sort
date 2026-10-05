part of 'home_cubit.dart';

/// What Home shows (frame 2.1; spec §10.2 #2; docs/plans/m3-design.md
/// §10.3).
@freezed
abstract class HomeState with _$HomeState {
  const factory HomeState({
    /// What PLAY starts (`LevelResolver.homeRequest`): a campaign level
    /// while one is left, else Bonus Endless (m3-design §7.4, D74). A saved
    /// board of this request continues.
    required PlayRequest playRequest,

    /// [playRequest]'s tier, for the play button's badge (§6.6): the
    /// bundle entry's for a campaign level, `DifficultyCurve.tierForLevel`
    /// for a bonus one.
    @Default(Tier.easy) Tier tier,

    /// The board theme behind the hero: `selectedTheme ?? current chapter's
    /// theme` (m3-design §10.3, §9.4).
    @Default('ch01') String themeId,

    /// The coin pill.
    @Default(0) int coins,

    /// Hides the Remove Ads tile (spec §9.2; M6).
    @Default(false) bool adsRemoved,

    /// The Daily tile: locked before Level 2 is won (m3-design §8.3).
    @Default(false) bool dailyUnlocked,

    /// The Daily tile's flame badge, 0 hides it.
    @Default(0) int dailyStreak,

    /// The Daily tile's flame is lit (`DailyStatus.lit`); with
    /// [dailyStreak] above 0 and this false, the badge shows its resting,
    /// paused look (E2; docs/plans/m7-design.md §8, §15.7).
    @Default(false) bool dailyLit,

    /// vs Computer's unlock level (`race_unlock_level`, default 20): the
    /// locked tile's "After Level {n}" (m7-design §15.8).
    @Default(20) int raceUnlockLevel,

    /// That level is won (`highestLevel > raceUnlockLevel`). The race
    /// itself lands in M7 phase 2; until then the tile stays locked and
    /// says it is coming (m7-design §15.8).
    @Default(false) bool raceUnlocked,

    /// The next uncollected figurine's id (`FigurineInfo.id`), null once
    /// every catalog chapter is collected (`museumAllCollected`).
    String? museumFigurineId,

    /// Its locked art (`FigurineInfo.lockedArtAsset`).
    String? museumLockedArtAsset,

    /// The current chapter's levels already won, of [museumTotal]
    /// (m3-design §10.3's "15/20"); meaningless once [museumAllCollected].
    @Default(0) int museumDone,
    @Default(ChapterInfo.levelsPerChapter) int museumTotal,

    /// Every catalog chapter's figurine is in the museum (Bonus Endless):
    /// [museumCollectedCount] of [museumCollectedTotal]. Home has no Museum
    /// tile any more (D111); the Museum's own 6.1c says every family is home.
    @Default(false) bool museumAllCollected,
    @Default(0) int museumCollectedCount,
    @Default(0) int museumCollectedTotal,

    /// The chapter card (frame 2.1; menus spec 1.1): the chapter the PLAY
    /// level is in, 1-based, and its id (`ch03`, the `chapterName` select
    /// key and the palette's theme). In Bonus Endless ([isBonus]) it stays
    /// the last chapter's, only for the palette (frame 12.2).
    @Default(1) int chapterNumber,
    @Default('ch01') String chapterId,

    /// PLAY is a Bonus Endless board: the card reads "BONUS ENDLESS / Bonus
    /// levels" with the whole campaign's stars (frame 12.2).
    @Default(false) bool isBonus,

    /// The card's stars chip: the chapter's best stars, of
    /// [chapterStarsPossible] (`StarRating.maxStars` × its levels with a par,
    /// 60 for a full chapter). In Bonus Endless the same two fields hold the
    /// campaign's total, of 600.
    @Default(0) int chapterStars,
    @Default(0) int chapterStarsPossible,

    /// The flame was paused and a solve lit it again, and Home hasn't
    /// glowed for that yet (this session or an earlier one): the tile's badge
    /// shows its `relitGlow` ring once, 2,400 ms and a 400 ms fade, until
    /// `HomeCubit.relitGlowFinished` (m7-4 4.10, `motion.relitHome`; frame
    /// 10.7).
    @Default(false) bool streakRelit,
  }) = _HomeState;

  const HomeState._();

  /// The Daily tile's badge (menus spec 1.1): a lit flame with its count, a
  /// paused (resting) one, a just-relit one, or an unlit flame with no
  /// number at a streak of 0 (frame 12.2). Never a lost or red streak.
  StreakLook get streakLook {
    if (dailyStreak <= 0) return StreakLook.zero;
    if (!dailyLit) return StreakLook.paused;
    return streakRelit ? StreakLook.relit : StreakLook.lit;
  }
}
