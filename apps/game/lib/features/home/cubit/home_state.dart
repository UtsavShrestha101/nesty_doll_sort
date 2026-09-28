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
    /// the tile shows [museumCollectedCount] of [museumCollectedTotal]
    /// instead (`TODO(design)`, m3-design §10.6).
    @Default(false) bool museumAllCollected,
    @Default(0) int museumCollectedCount,
    @Default(0) int museumCollectedTotal,
  }) = _HomeState;
}
