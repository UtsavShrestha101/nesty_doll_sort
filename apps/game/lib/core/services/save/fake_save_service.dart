import 'package:injectable/injectable.dart';
import 'package:nesty_game/core/dependency_injection/app_env.dart';
import 'package:nesty_game/core/services/remote_config/fake_remote_config_service.dart';
import 'package:nesty_game/core/services/remote_config/remote_config_service.dart';
import 'package:nesty_game/core/services/save/in_memory_save_service.dart';
import 'package:nesty_game/core/services/save/save_document.dart';
import 'package:nesty_game/core/services/save/save_service.dart';

/// Deterministic in-memory [SaveService] for tests and the fake env: a
/// fresh install (level 1, 0 coins, 3 hints, 2 slots) whatever the flavor,
/// so tests see real booster counts (the dev flavor's unlimited boosters
/// only apply to the real env).
///
/// Pass [initial] to start from any document (a player mid-streak, a board
/// in progress), or use the mutators; pass [remoteConfig] to tune
/// `free_undos_per_level`.
@LazySingleton(as: SaveService, env: [AppEnv.fake])
class FakeSaveService extends InMemorySaveService {
  FakeSaveService({
    @ignoreParam RemoteConfigService? remoteConfig,
    @ignoreParam bool unlimitedBoosters = false,
    @ignoreParam SaveDocument? initial,
  }) : super(
         remoteConfig ?? FakeRemoteConfigService(),
         unlimitedBoosters: unlimitedBoosters,
         initial: initial,
       );
}
