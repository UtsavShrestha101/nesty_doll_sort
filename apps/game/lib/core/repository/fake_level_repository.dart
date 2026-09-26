import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:nesty_game/core/dependency_injection/app_env.dart';
import 'package:nesty_game/core/repository/level_repository.dart';

/// [LevelRepository] with no levels: the bundle (30 hand-written levels) and
/// the core codec arrive in M2.
///
/// TODO(M2): drop `AppEnv.real` from `env` once the bundled repository exists.
@LazySingleton(as: LevelRepository, env: [AppEnv.fake, AppEnv.real])
class FakeLevelRepository implements LevelRepository {
  @override
  @visibleForTesting
  int levelCount = 0;

  @override
  Future<void> load() async {}
}
