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

/// Every Remote Config key of spec §9.4, with exactly its default.
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
  ];

  /// `{name: default}` for every key.
  static Map<String, Object> get defaults => {
    for (final key in all) key.name: key.defaultValue,
  };
}
