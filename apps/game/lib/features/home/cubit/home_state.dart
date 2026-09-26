part of 'home_cubit.dart';

/// What Home shows (frame 2.1; spec §10.2 #2).
@freezed
abstract class HomeState with _$HomeState {
  const factory HomeState({
    /// The level the play button starts (spec §10.2 #2): the save's
    /// current level, moved past any skipped bundled level.
    @Default(1) int currentLevel,

    /// Its tier, for the play button's HARD / SUPER HARD badge (§6.6).
    @Default(Tier.easy) Tier tier,

    /// Its chapter (`ch01`): Home's background follows the player's
    /// chapter.
    @Default('ch01') String chapterId,

    /// The coin pill.
    @Default(0) int coins,

    /// Levels available offline.
    @Default(0) int levelCount,

    /// Every bundled level is won: Play shows All Levels Done (frame 4.9)
    /// until Bonus Endless (M3).
    @Default(false) bool allLevelsDone,
  }) = _HomeState;
}
