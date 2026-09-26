/// Where a rewarded ad is offered (spec §9.1). Also the `placement` value of
/// the `rewarded_offer` / `rewarded_complete` analytics events (spec §14.4).
enum RewardedPlacement {
  /// A booster purchase button (spec §8).
  booster,

  /// Out of Moves sheet "+1 Slot" (spec §10.2 #5).
  outOfMovesSlot,

  /// Win screen "×3 coins" (spec §10.2 #4).
  winMultiplier,

  /// Daily chest double (spec §9.1).
  dailyChest,
}

/// Ads (spec §9.1). Every call fails fast and silently when offline — the
/// game never waits on an ad (3 s timeout) and ad buttons fall back to coins.
///
/// TODO(M6): add `AdMobAdsService` (google_mobile_ads) for the real env:
/// UMP consent before init (§9.3), Google test unit IDs in debug and
/// `--dart-define` IDs in release (CLAUDE.md rule 5), preload one rewarded +
/// one interstitial, and the interstitial pacing rules of §9.1.
abstract interface class AdsService {
  Future<void> initialize();

  /// Whether a rewarded ad can be shown right now. When false the UI shows
  /// the coin price instead (spec §9.1 "Offline").
  bool get isRewardedReady;

  /// Shows a rewarded ad. Completes with true only if the reward was earned.
  Future<bool> showRewarded(RewardedPlacement placement);

  /// Shows an interstitial if one is loaded. Only ever called on the
  /// post-win transition (spec §9.1). Completes with true if one was shown.
  Future<bool> showInterstitial();
}
