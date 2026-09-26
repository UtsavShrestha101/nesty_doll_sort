import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:nesty_core/nesty_core.dart';
import 'package:nesty_game/core/dependency_injection/app_env.dart';
import 'package:nesty_game/core/repository/fixture_levels.dart';
import 'package:nesty_game/core/repository/level_repository.dart';

/// In-memory [LevelRepository]. The fake env gets [FakeLevelRepository.fixtures]
/// (levels 1–3); a test can hand it any [entries] (none by default).
@LazySingleton(as: LevelRepository, env: [AppEnv.fake])
class FakeLevelRepository implements LevelRepository {
  FakeLevelRepository({@ignoreParam List<LevelBundleEntry> entries = const []})
    : _entries = {for (final entry in entries) entry.order: entry},
      levelCount = entries.length;

  /// The first three authored levels ([FixtureLevels]): what the fake env
  /// (tests, `NESTY_FAKE_SERVICES` builds) plays.
  @factoryMethod
  FakeLevelRepository.fixtures() : this(entries: FixtureLevels.entries());

  final Map<int, LevelBundleEntry> _entries;

  /// Settable so a test can pretend a bundle of any size loaded.
  @override
  @visibleForTesting
  int levelCount;

  @override
  Future<void> load() async {}

  @override
  LevelBundleEntry? entryAt(int order) => _entries[order];
}
