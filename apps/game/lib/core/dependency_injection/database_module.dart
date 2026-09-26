import 'package:injectable/injectable.dart';
import 'package:nesty_game/core/dependency_injection/app_env.dart';
import 'package:nesty_game/core/services/database/database_service.dart';
import 'package:nesty_game/core/services/database/hive_database_service.dart';

/// Opens Hive during `configureDependencies()` (which bootstrap awaits before
/// `runApp`), so every box is opened exactly once and features never open one
/// lazily. A module rather than annotations on `HiveDatabaseService` because
/// the result may be the in-memory fallback, not a Hive instance.
@module
abstract class DatabaseModule {
  @preResolve
  @Singleton(env: [AppEnv.real], dispose: closeDatabase)
  Future<DatabaseService> get database => HiveDatabaseService.openOrFallback();
}

/// get_it dispose hook for [DatabaseModule.database].
Future<void> closeDatabase(DatabaseService database) => database.close();
