import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:nesty_game/core/services/clock/local_date.dart';

part 'login_gift_reward.freezed.dart';

/// One day of the daily gift's track (plan-login-gift §7.5b; D268): what
/// claiming that day pays, shown in full before any claim (spec-prop §1.1
/// rules 2, 3). Never all zero (`LoginGiftRules.parseTrack`).
@freezed
abstract class LoginGiftReward with _$LoginGiftReward {
  const factory LoginGiftReward({
    @Default(0) int coins,

    /// Hint boosters (`BoosterKind.hint`).
    @Default(0) int hints,

    /// Extra slot boosters (`BoosterKind.extraSlot`).
    @Default(0) int slots,
  }) = _LoginGiftReward;
}

/// One claim of the daily gift, as `SaveService.claimLoginGift` paid it.
@freezed
abstract class LoginGiftGrant with _$LoginGiftGrant {
  const factory LoginGiftGrant({
    /// The local date it was claimed on.
    required LocalDate date,

    /// The track's day it paid, 1–7 (`LoginGiftRules.dayOf`).
    required int day,

    /// `LoginGiftProgress.claims` after this claim.
    required int claims,

    required LoginGiftReward reward,
  }) = _LoginGiftGrant;
}
