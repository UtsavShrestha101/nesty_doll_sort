/// Store products of spec §9.2. [productId] must match the Play Console /
/// App Store Connect ids exactly.
enum IapProduct {
  removeAds('remove_ads'),
  starterPack('starter_pack'),
  coinsSmall('coins_small'),
  coinsMedium('coins_medium'),
  coinsLarge('coins_large'),
  noAdsBundle('no_ads_bundle');

  const IapProduct(this.productId);

  final String productId;
}

/// In-app purchases (spec §9.2). Store unavailability is a normal state, not
/// an error: calls complete with false / do nothing (CLAUDE.md rule 3).
///
/// TODO(M6): add `StorePurchaseService` (in_app_purchase) for the real env:
/// product queries, client-side receipt checks (v1), restore purchases, and
/// crediting coins/adsRemoved through the M3 save.
abstract interface class PurchaseService {
  Future<void> initialize();

  /// Starts a purchase. Completes with true once the purchase is delivered.
  Future<bool> buy(IapProduct product);

  /// Re-delivers non-consumables (required on iOS, spec §9.2).
  Future<void> restorePurchases();
}
