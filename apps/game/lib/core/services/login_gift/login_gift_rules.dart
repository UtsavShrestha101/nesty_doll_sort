import 'dart:convert';

import 'package:nesty_game/core/services/clock/local_date.dart';
import 'package:nesty_game/core/services/daily/streak_daily_service.dart';
import 'package:nesty_game/core/services/login_gift/login_gift_reward.dart';
import 'package:nesty_game/core/services/remote_config/remote_config_keys.dart';
import 'package:nesty_game/core/services/remote_config/remote_config_service.dart';
import 'package:nesty_game/core/services/save/save_document.dart';

/// The daily gift (plan-login-gift §7.5b, spec until the owner pastes it;
/// D268): once a local date, opening the app claims the next day of a
/// 7-day track shown in full in advance.
///
/// The track counts claims, not dates: a missed day never moves it back
/// (spec-prop §1.1 rule 6), and after Day 7 it starts again at Day 1. A
/// date earlier than the latest one the gift has seen claims nothing, so a
/// clock wound forward borrows at most one gift per date and pays it back
/// in time, never in coins (plan "Risks"). It unlocks with the Daily, and
/// no ad, purchase, timer or chance is involved (rules 2, 3).
///
/// Pure, beside `MilestoneChest`: `SaveService.claimLoginGift` asks
/// [grantFor] and pays it in one update; `LoginGiftCubit` reads the same
/// rules for the sheet.
abstract final class LoginGiftRules {
  /// Days on the track.
  static const int trackLength = 7;

  /// The track's default (Q182c): 20 coins · 30 coins · 1 hint · 40 coins ·
  /// 50 coins · 1 hint · 100 coins + 1 extra slot. It is
  /// `RemoteConfigKeys.loginGiftTrack`'s default, parsed (a test holds the
  /// two together), and what a malformed value falls back to.
  static const List<LoginGiftReward> defaultTrack = [
    LoginGiftReward(coins: 20),
    LoginGiftReward(coins: 30),
    LoginGiftReward(hints: 1),
    LoginGiftReward(coins: 40),
    LoginGiftReward(coins: 50),
    LoginGiftReward(hints: 1),
    LoginGiftReward(coins: 100, slots: 1),
  ];

  /// The track [raw] describes, or [defaultTrack] when it is malformed in
  /// any way (CLAUDE.md rule 6). The form (`login_gift_track`) is a JSON
  /// array of [trackLength] objects with only `coins`, `hints` and
  /// `slots`, each a whole number of at least 0 (absent is 0), and at
  /// least one above 0 per day. So not JSON, not [trackLength] days, a
  /// day that pays nothing, a negative or fractional count, or a field
  /// this app doesn't know (a reward it couldn't show or pay) all fall
  /// back.
  static List<LoginGiftReward> parseTrack(String raw) {
    Object? json;
    try {
      json = jsonDecode(raw);
    } on FormatException {
      return defaultTrack;
    }
    if (json is! List || json.length != trackLength) return defaultTrack;
    final track = <LoginGiftReward>[];
    for (final day in json) {
      final reward = _parseDay(day);
      if (reward == null) return defaultTrack;
      track.add(reward);
    }
    return List.unmodifiable(track);
  }

  static LoginGiftReward? _parseDay(Object? day) {
    if (day is! Map) return null;
    if (day.keys.any((key) => !_fields.contains(key))) return null;
    final coins = _count(day['coins']);
    final hints = _count(day['hints']);
    final slots = _count(day['slots']);
    if (coins == null || hints == null || slots == null) return null;
    if (coins + hints + slots == 0) return null;
    return LoginGiftReward(coins: coins, hints: hints, slots: slots);
  }

  static const Set<String> _fields = {'coins', 'hints', 'slots'};

  /// An absent field is 0; otherwise a whole number in `0..2^53 − 1`
  /// (read by value, so `20.0` is 20, like the save codec), else null.
  static int? _count(Object? value) {
    if (value == null) return 0;
    if (value is int) return value >= 0 ? value : null;
    if (value is double &&
        value.isFinite &&
        value >= 0 &&
        value == value.truncateToDouble() &&
        value <= 9007199254740991) {
      return value.toInt();
    }
    return null;
  }

  /// The track Remote Config holds now (`login_gift_track`).
  static List<LoginGiftReward> trackOf(RemoteConfigService config) =>
      parseTrack(config.value(RemoteConfigKeys.loginGiftTrack));

  /// The gift unlocks with the Daily: Level 2 won (§7.5b; m3-design §8.3).
  static bool isUnlocked(int highestLevel) =>
      highestLevel >= StreakDailyService.unlockAtHighestLevel;

  /// The day, 1–[trackLength], the next claim pays after [claims] claims.
  static int dayOf(int claims) => claims % trackLength + 1;

  /// Whether [today]'s date may claim, by the dates alone: not the date of
  /// the last claim, and not earlier than the latest date seen.
  static bool canClaim(LocalDate today, LoginGiftProgress progress) {
    if (today == progress.lastClaim) return false;
    final latest = progress.latestSeen;
    return latest == null || today >= latest;
  }

  /// [progress] having seen [today]: `latestSeen` raised, never lowered
  /// ([progress] itself when nothing changes).
  static LoginGiftProgress noted(LoginGiftProgress progress, LocalDate today) {
    final latest = progress.latestSeen;
    if (latest != null && latest >= today) return progress;
    return progress.copyWith(latestSeen: today);
  }

  /// [progress] after a claim on [today]: one more claim (nothing lowers
  /// it), the claim's date, and [today] seen.
  static LoginGiftProgress claimed(
    LoginGiftProgress progress,
    LocalDate today,
  ) => noted(
    progress,
    today,
  ).copyWith(claims: progress.claims + 1, lastClaim: today);

  /// What claiming on [today] pays [doc]'s player from [track], or null:
  /// still locked, or [canClaim] says no. [track] has [trackLength] days
  /// ([trackOf]).
  static LoginGiftGrant? grantFor(
    SaveDocument doc,
    LocalDate today,
    List<LoginGiftReward> track,
  ) {
    final progress = doc.loginGift;
    if (!isUnlocked(doc.highestLevel) || !canClaim(today, progress)) {
      return null;
    }
    final day = dayOf(progress.claims);
    return LoginGiftGrant(
      date: today,
      day: day,
      claims: progress.claims + 1,
      reward: track[day - 1],
    );
  }
}
