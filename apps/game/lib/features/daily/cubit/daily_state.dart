part of 'daily_cubit.dart';

/// What the Daily screen shows (frames 5.1–5.6; docs/plans/m3-design.md
/// §8.4, §10.5). [status] alone drives which of the §8.4 states the strip,
/// streak card and chest row are in; the rest is what the cubit adds.
@freezed
abstract class DailyState with _$DailyState {
  const factory DailyState({
    /// The reconciled streak, freezes, cycle and today's puzzle
    /// (`DailyService.refresh`).
    required DailyStatus status,

    /// The header's coin pill (`SaveService.coins`).
    @Default(0) int coins,

    /// `daily_reward` (Remote Config): the puzzle card's coin chip and the
    /// win screen's "+50" (m3-design §7.1).
    @Default(50) int rewardCoins,

    /// `streak7_reward`: the chest row's "· 300 coins" and the modal's
    /// "+300".
    @Default(300) int chestCoins,

    /// Until the next local midnight (frame 5.5 "Next puzzle in 14h 12m"),
    /// refreshed once a minute while the screen is open.
    Duration? untilNextPuzzle,

    /// Today's puzzle's colours, once `LevelResolver.resolve` lands (the
    /// puzzle card's preview); null shows `ui_spinner` instead.
    List<DollColor>? previewColors,

    /// The resolve failed (every retry): the preview is hidden, Play still
    /// works (the gameplay page shows its own retry view).
    @Default(false) bool previewFailed,

    /// Frame 5.5's "Play Level N" (`LevelResolver.homeRequest`): the
    /// campaign level (or Bonus Endless) Home's PLAY would start.
    @Default(PlayRequest.campaign(1)) PlayRequest homeRequest,

    /// The number frame 5.5's copy shows (`SaveService.currentLevel`).
    @Default(1) int homeLevelNumber,
  }) = _DailyState;
}
