part of 'login_gift_cubit.dart';

/// Where the daily gift stands today (plan-login-gift §7.5b; D268).
enum LoginGiftPhase {
  /// Below the Daily's unlock: the button is hidden.
  locked,

  /// Today's gift can be claimed: the button shows its dot.
  ready,

  /// Claimed on today's date.
  claimed,

  /// Unlocked and not claimed today, but today is earlier than the latest
  /// date seen (a clock wound back): no claim and no dot.
  waiting,
}

/// How one day's tile looks (frames 13.x).
enum GiftTileState { done, today, later }

/// The daily gift's state: the full track (shown before any claim, spec-prop
/// §1.1 rules 2, 3) and how far the player is on it. Pure data.
@freezed
abstract class LoginGiftState with _$LoginGiftState {
  const factory LoginGiftState({
    required LoginGiftPhase phase,
    required List<LoginGiftReward> track,
    required int claims,
    required LocalDate today,

    /// While claimed coins are in the air, the most Home's coin pill may
    /// show (coins before the claim plus those landed so far); null
    /// otherwise. Home shows `min(home.coins, coinsCap)`.
    int? coinsCap,

    /// The player's hint boosters, the count Home's tally shows once a
    /// gift's hint lands (frame 13.5c, `gift.tally.count`).
    @Default(0) int hints,

    /// The player's extra slot boosters, the tally's count for a gift's
    /// slot (frame 13.6d).
    @Default(0) int slots,
  }) = _LoginGiftState;

  const LoginGiftState._();

  /// The track's day, 1–7, the next claim pays.
  int get nextDay => LoginGiftRules.dayOf(claims);

  /// How many tiles show done, 0–7. After Day 7 is claimed all seven stay
  /// done until the next date starts the track again.
  int get doneDays => phase == LoginGiftPhase.claimed
      ? (claims - 1) % LoginGiftRules.trackLength + 1
      : claims % LoginGiftRules.trackLength;

  /// The day that is today's gift, or null when there is nothing to claim.
  int? get todayDay => phase == LoginGiftPhase.ready ? nextDay : null;

  /// What the next claim pays ("Tomorrow" once claimed, "Next gift" when
  /// waiting).
  LoginGiftReward get nextReward => track[nextDay - 1];

  bool get canClaim => phase == LoginGiftPhase.ready;

  /// The button's dot: only when there is a gift to claim.
  bool get showsDot => canClaim;

  GiftTileState tileStateOf(int day) {
    if (day <= doneDays) return GiftTileState.done;
    if (day == todayDay) return GiftTileState.today;
    return GiftTileState.later;
  }
}
