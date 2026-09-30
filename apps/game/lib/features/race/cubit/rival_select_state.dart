part of 'rival_select_cubit.dart';

/// One rival on the select screen (frame 9.2; spec-prop §7.7;
/// docs/plans/m7-design.md P2.8, P2.10). Every card is labelled a
/// computer (spec-prop §1.1 rule 5).
@freezed
abstract class RivalCard with _$RivalCard {
  const factory RivalCard({
    /// 1–3.
    required int number,

    /// Selectable: rival 1 always, the next after the first win against the
    /// one before.
    @Default(false) bool unlocked,

    /// Races won against this rival (the card's "N wins"; never a loss
    /// count, vs-computer rule 10).
    @Default(0) int wins,

    /// Coins a win pays (`RaceRules.rewardCoins`), shown before the race
    /// (spec-prop §1.1 rule 2).
    @Default(0) int rewardCoins,

    /// The player has beaten this rival at least once (`wins > 0`): the
    /// portrait's check (frame 9.2b). Rematch still pays, and RaceRules is
    /// the source of truth.
    @Default(false) bool beaten,

    /// Unlocked, never raced (`raceNo == 0`) and not rival 1: the "New"
    /// chip (frame 9.2b, C.9). It clears when the rival is first raced.
    @Default(false) bool isNew,
  }) = _RivalCard;
}

/// What rival select shows (frame 9.2; m7-design P2.8).
@freezed
abstract class RivalSelectState with _$RivalSelectState {
  const factory RivalSelectState({
    /// The header's coin pill (`SaveService.coins`).
    @Default(0) int coins,

    /// Rivals 1–3, in order.
    @Default(<RivalCard>[]) List<RivalCard> rivals,

    /// The rival the one Start races (1–3): the newest unlocked one not yet
    /// raced, else the highest unlocked; the player's taps change it for
    /// this visit only (frame 9.2).
    @Default(1) int selected,
  }) = _RivalSelectState;
}
