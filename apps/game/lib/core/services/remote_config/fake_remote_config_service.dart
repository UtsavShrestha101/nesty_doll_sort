import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:nesty_game/core/dependency_injection/app_env.dart';
import 'package:nesty_game/core/services/remote_config/remote_config_keys.dart';
import 'package:nesty_game/core/services/remote_config/remote_config_service.dart';

/// Defaults plus per-key overrides, so tests can exercise tuned values
/// (e.g. M6 interstitial pacing) without Firebase.
@LazySingleton(as: RemoteConfigService, env: [AppEnv.fake])
class FakeRemoteConfigService implements RemoteConfigService {
  final Map<String, Object> _overrides = {};

  @visibleForTesting
  void setOverride<T extends Object>(RemoteConfigKey<T> key, T value) =>
      _overrides[key.name] = value;

  @visibleForTesting
  void clearOverrides() => _overrides.clear();

  @override
  Future<void> refresh() async {}

  @override
  T value<T extends Object>(RemoteConfigKey<T> key) {
    final override = _overrides[key.name];
    return override is T ? override : key.defaultValue;
  }
}
