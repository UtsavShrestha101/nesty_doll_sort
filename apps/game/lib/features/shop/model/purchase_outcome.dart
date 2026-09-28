/// What a coin purchase on the skin detail screen came to (frame 7.4;
/// docs/plans/m3-design.md §9.4, §10.7).
enum PurchaseOutcome {
  /// Paid and equipped: the page shows the purchase twinkle.
  bought,

  /// The price is more than the balance, so nothing was spent. Frames
  /// 7.3/7.4/7.7 draw every price as the same orange button, so a tap on
  /// one the player can't afford opens the Shop's Coins tab instead
  /// (FIDELITY-7).
  needsCoins,

  /// Not for sale, already owned, or not loaded: nothing happens.
  unavailable,
}
