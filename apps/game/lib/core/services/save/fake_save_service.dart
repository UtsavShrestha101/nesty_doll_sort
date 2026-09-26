import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:nesty_game/core/dependency_injection/app_env.dart';
import 'package:nesty_game/core/services/save/save_service.dart';

/// In-memory [SaveService] that always starts as a fresh install (level 1).
///
/// TODO(M3): drop `AppEnv.real` from `env` once the persistent save exists.
@LazySingleton(as: SaveService, env: [AppEnv.fake, AppEnv.real])
class FakeSaveService implements SaveService {
  @override
  @visibleForTesting
  int currentLevel = 1;

  @override
  Future<void> load() async {}
}
