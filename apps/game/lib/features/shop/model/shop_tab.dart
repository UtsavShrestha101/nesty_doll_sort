/// The Shop's segmented tabs, in order (spec §10.2 #12, frame 7.1:
/// "Coins · Skins · Themes · No Ads"; docs/plans/m3-design.md §10.7).
enum ShopTab {
  /// Coin packs (7.1, 7.2): M6. M3 shows its store-unavailable state.
  coins,

  /// Skins (7.3–7.6).
  skins,

  /// Board themes (7.7).
  themes,

  /// Remove Ads (7.8): M6. M3 shows its store-unavailable state.
  noAds,
}
