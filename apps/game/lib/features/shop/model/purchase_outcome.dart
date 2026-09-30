/// What a coin purchase came to: a skin or theme card in the Shop's grids
/// (`ShopCubit.buySkin`/`buyTheme`) or the skin detail screen
/// (`SkinDetailCubit.buy`) — frames 7.3, 7.4, 7.7; docs/plans/m3-design.md
/// §9.4, §10.7.
enum PurchaseOutcome {
  /// Paid and equipped: the caller shows the purchase twinkle.
  bought,

  /// The price is more than the balance, so nothing was spent. Frames
  /// 7.3/7.4/7.7 draw every price as the same orange button, so a tap on
  /// one the player can't afford opens `NotEnoughCoinsDialog` instead of
  /// doing nothing (D112, replaces D86's direct jump to the Shop's Coins
  /// tab).
  needsCoins,

  /// Not for sale, already owned, or not loaded: nothing happens.
  unavailable,
}
