import 'package:injectable/injectable.dart';
import 'package:nesty_game/core/dependency_injection/app_env.dart';
import 'package:nesty_game/core/services/ads/ads_service.dart';

/// [AdsService] that behaves like a device with no ad fill: nothing is ever
/// ready, nothing is shown, no reward is granted. That is the safe offline
/// behavior (spec §9.1), so it is fine in the real env until M6 too — it can
/// never hand out free rewards in a release build.
///
/// TODO(M6): drop `AppEnv.real` from `env` once `AdMobAdsService` exists.
@LazySingleton(as: AdsService, env: [AppEnv.fake, AppEnv.real])
class FakeAdsService implements AdsService {
  @override
  Future<void> initialize() async {}

  @override
  bool get isRewardedReady => false;

  @override
  Future<bool> showRewarded(RewardedPlacement placement) async => false;

  @override
  Future<bool> showInterstitial() async => false;
}
