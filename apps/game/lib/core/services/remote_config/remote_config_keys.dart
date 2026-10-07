/// A typed Remote Config key with its hard-coded default (CLAUDE.md rule 6).
final class RemoteConfigKey<T extends Object> {
  const RemoteConfigKey._(this.name, this.defaultValue);

  /// The Firebase Remote Config parameter name.
  final String name;

  /// Used offline, before the first fetch, and whenever a fetched value is
  /// missing or has the wrong type.
  final T defaultValue;

  @override
  String toString() => 'RemoteConfigKey<$T>($name = $defaultValue)';
}

/// Every Remote Config key of spec §9.4 (and spec-prop §9.4's M7 keys),
/// with exactly its default.
///
/// This is the single place defaults live. Add a key here (and to [all]),
/// never inline a default at a call site.
abstract final class RemoteConfigKeys {
  // Interstitial pacing — spec §9.1.
  static const interstitialFirstLevel = RemoteConfigKey<int>._(
    'interstitial_first_level',
    8,
  );
  static const interstitialEveryNLevels = RemoteConfigKey<int>._(
    'interstitial_every_n_levels',
    3,
  );
  static const interstitialMinSeconds = RemoteConfigKey<int>._(
    'interstitial_min_seconds',
    90,
  );
  static const interstitialSessionGraceSec = RemoteConfigKey<int>._(
    'interstitial_session_grace_sec',
    300,
  );

  /// Optional small Home banner — off by default (spec §9.1).
  static const homeBannerEnabled = RemoteConfigKey<bool>._(
    'home_banner_enabled',
    false,
  );

  /// Win screen "×3 coins" rewarded multiplier (spec §7.3).
  static const rewardedCoinMultiplier = RemoteConfigKey<int>._(
    'rewarded_coin_multiplier',
    3,
  );

  /// Free undos before undo costs coins (spec §8).
  static const freeUndosPerLevel = RemoteConfigKey<int>._(
    'free_undos_per_level',
    2,
  );

  // Booster prices in coins — spec §7.3.
  static const priceUndo = RemoteConfigKey<int>._('price_undo', 20);
  static const priceHint = RemoteConfigKey<int>._('price_hint', 60);
  static const priceSlot = RemoteConfigKey<int>._('price_slot', 150);

  // Win rewards in coins — spec §7.3.
  static const rewardEasy = RemoteConfigKey<int>._('reward_easy', 10);

  /// Not in spec §9.4's list: the owner added it (Q5, D64) so a medium win
  /// no longer reads `reward_easy`. §7.3 pays easy and medium 10 each.
  static const rewardMedium = RemoteConfigKey<int>._('reward_medium', 10);
  static const rewardHard = RemoteConfigKey<int>._('reward_hard', 25);
  static const rewardSuperhard = RemoteConfigKey<int>._('reward_superhard', 50);

  /// Chapter complete (spec §7.3 "150", frame 4.6 "+150 coins"). Not in
  /// §9.4's list: added like `reward_medium` (docs/plans/m3-design.md §7.1;
  /// a default the owner may override, see PROGRESS).
  static const rewardChapter = RemoteConfigKey<int>._('reward_chapter', 150);

  // Daily puzzle rewards — spec §7.5.
  static const dailyReward = RemoteConfigKey<int>._('daily_reward', 50);
  static const streak7Reward = RemoteConfigKey<int>._('streak7_reward', 300);

  /// "Remove Ads" offer appears after this many interstitials (spec §9.2).
  static const removeAdsOfferAfterInterstitials = RemoteConfigKey<int>._(
    'remove_ads_offer_after_interstitials',
    3,
  );

  /// Native rate prompt after winning this level (spec §10.2 #16).
  static const ratePromptLevel = RemoteConfigKey<int>._(
    'rate_prompt_level',
    15,
  );

  // The milestone chest — spec-prop §7.3, §9.4 (M7 E5, Q76;
  // docs/plans/m7-design.md §5, §9).
  static const chestCoins = RemoteConfigKey<int>._('chest_coins', 100);
  static const chestHints = RemoteConfigKey<int>._('chest_hints', 1);

  // vs Computer — spec-prop §7.7, §9.4 (M7 phase 2, D93, Q77–Q80;
  // m7-design §5). Declared with the phase-1 contracts so the Home tile
  // can name its unlock level.
  /// The race unlocks once this level is won.
  static const raceUnlockLevel = RemoteConfigKey<int>._(
    'race_unlock_level',
    20,
  );

  /// Rival 1–3's milliseconds per move.
  static const racePaceMs1 = RemoteConfigKey<int>._('race_pace_ms_1', 3000);
  static const racePaceMs2 = RemoteConfigKey<int>._('race_pace_ms_2', 2400);
  static const racePaceMs3 = RemoteConfigKey<int>._('race_pace_ms_3', 1600);

  /// Each interval varies by up to this percentage, from the race's seeded
  /// PRNG.
  static const racePaceJitterPct = RemoteConfigKey<int>._(
    'race_pace_jitter_pct',
    20,
  );

  /// Coins a win against rival 1–3 pays.
  static const raceReward1 = RemoteConfigKey<int>._('race_reward_1', 20);
  static const raceReward2 = RemoteConfigKey<int>._('race_reward_2', 30);
  static const raceReward3 = RemoteConfigKey<int>._('race_reward_3', 40);

  // The star rating — spec-prop §7.10, §9.4 (M7 phase 3, D125;
  // docs/plans/m7-design.md P3.3). Readers clamp both into
  // `0..StarRating.maxSlackPct` (`StarRules.slackOf`).
  /// 3 stars at moves ≤ par + ⌈par × this ÷ 100⌉.
  static const star3SlackPct = RemoteConfigKey<int>._('star3_slack_pct', 20);

  /// 2 stars at moves ≤ par + ⌈par × this ÷ 100⌉.
  static const star2SlackPct = RemoteConfigKey<int>._('star2_slack_pct', 60);

  /// The daily gift's 7-day track (plan-login-gift §7.5b, §9.4; D268,
  /// Q182c): 20 coins · 30 coins · 1 hint · 40 coins · 50 coins · 1 hint ·
  /// 100 coins + 1 extra slot, as a JSON array of one object per day
  /// (`coins`, `hints`, `slots`). The first string key: a value
  /// `LoginGiftRules.parseTrack` can't read falls back to this default,
  /// whole (rule 6).
  static const loginGiftTrack = RemoteConfigKey<String>._(
    'login_gift_track',
    '[{"coins":20},{"coins":30},{"hints":1},{"coins":40},{"coins":50},'
        '{"hints":1},{"coins":100,"slots":1}]',
  );

  /// Every key, e.g. for pushing defaults into Firebase Remote Config (M4).
  static const List<RemoteConfigKey<Object>> all = [
    interstitialFirstLevel,
    interstitialEveryNLevels,
    interstitialMinSeconds,
    interstitialSessionGraceSec,
    homeBannerEnabled,
    rewardedCoinMultiplier,
    freeUndosPerLevel,
    priceUndo,
    priceHint,
    priceSlot,
    rewardEasy,
    rewardMedium,
    rewardHard,
    rewardSuperhard,
    rewardChapter,
    dailyReward,
    streak7Reward,
    removeAdsOfferAfterInterstitials,
    ratePromptLevel,
    chestCoins,
    chestHints,
    raceUnlockLevel,
    racePaceMs1,
    racePaceMs2,
    racePaceMs3,
    racePaceJitterPct,
    raceReward1,
    raceReward2,
    raceReward3,
    star3SlackPct,
    star2SlackPct,
    loginGiftTrack,
  ];

  /// `{name: default}` for every key.
  static Map<String, Object> get defaults => {
    for (final key in all) key.name: key.defaultValue,
  };
}
