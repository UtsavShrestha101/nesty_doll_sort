import 'package:injectable/injectable.dart';
import 'package:nesty_game/core/dependency_injection/app_env.dart';
import 'package:nesty_game/core/services/purchase/purchase_service.dart';

/// [PurchaseService] with the store unavailable: every purchase is declined,
/// restore finds nothing. Safe in the real env until M6 (it can't grant
/// anything for free).
///
/// TODO(M6): drop `AppEnv.real` from `env` once `StorePurchaseService` exists.
@LazySingleton(as: PurchaseService, env: [AppEnv.fake, AppEnv.real])
class FakePurchaseService implements PurchaseService {
  @override
  Future<void> initialize() async {}

  @override
  Future<bool> buy(IapProduct product) async => false;

  @override
  Future<void> restorePurchases() async {}
}
