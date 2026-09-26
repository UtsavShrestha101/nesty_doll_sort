import 'package:injectable/injectable.dart';
import 'package:nesty_game/core/dependency_injection/app_env.dart';
import 'package:nesty_game/core/services/remote_config/remote_config_keys.dart';
import 'package:nesty_game/core/services/remote_config/remote_config_service.dart';

/// Real-env [RemoteConfigService] until Firebase arrives: always the spec §9.4
/// defaults. It is also exactly what the Firebase version must return offline.
///
/// TODO(M4): replace in the real env with `FirebaseRemoteConfigService`.
@LazySingleton(as: RemoteConfigService, env: [AppEnv.real])
class DefaultsRemoteConfigService implements RemoteConfigService {
  @override
  Future<void> refresh() async {}

  @override
  T value<T extends Object>(RemoteConfigKey<T> key) => key.defaultValue;
}
