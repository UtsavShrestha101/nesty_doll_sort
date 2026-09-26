import 'dart:async';

import 'package:injectable/injectable.dart';
import 'package:nesty_game/core/dependency_injection/app_env.dart';
import 'package:nesty_game/core/flavor/flavor.dart';
import 'package:nesty_game/core/flavor/flavor_config.dart';
import 'package:nesty_game/core/services/remote_config/remote_config_keys.dart';
import 'package:nesty_game/core/services/remote_config/remote_config_service.dart';
import 'package:nesty_game/core/services/save/save_service.dart';

/// The M2 [SaveService]: progress, coins and the booster wallet, in memory
/// for the session (PROGRESS D13; spec §8, §13.3). Every launch starts as a
/// fresh install: level 1, 0 coins, the starter boosters.
///
/// In the dev flavor boosters are unlimited, so any level can be poked at
/// (BACKLOG M2 "Unlimited boosters in the dev flavor").
///
/// TODO(M3): replaced in the real env by the persistent save (Q3); this
/// then stays as `FakeSaveService`'s base.
@LazySingleton(as: SaveService, env: [AppEnv.real])
class InMemorySaveService implements SaveService {
  InMemorySaveService(
    this._remoteConfig, {
    @ignoreParam bool? unlimitedBoosters,
  }) : _unlimitedOverride = unlimitedBoosters;

  final RemoteConfigService _remoteConfig;
  final bool? _unlimitedOverride;
  late final bool _unlimited = _unlimitedOverride ?? _isDevFlavor();

  final StreamController<void> _changes = StreamController.broadcast();
  final List<int> _boosters = [
    for (final kind in BoosterKind.values) kind.starterGift,
  ];
  int _currentLevel = 1;
  int _coins = 0;

  @override
  Future<void> load() async {}

  @override
  int get currentLevel => _currentLevel;

  @override
  set currentLevel(int level) {
    RangeError.checkValueInInterval(level, 1, 1 << 30, 'level');
    if (level == _currentLevel) return;
    _currentLevel = level;
    _notify();
  }

  @override
  int get coins => _coins;

  @override
  void addCoins(int amount) {
    RangeError.checkNotNegative(amount, 'amount');
    if (amount == 0) return;
    _coins += amount;
    _notify();
  }

  @override
  bool spendCoins(int amount) {
    RangeError.checkNotNegative(amount, 'amount');
    if (amount > _coins) return false;
    if (amount == 0) return true;
    _coins -= amount;
    _notify();
    return true;
  }

  @override
  void recordWin({required int levelOrder, required int rewardCoins}) {
    RangeError.checkValueInInterval(levelOrder, 1, 1 << 30, 'levelOrder');
    RangeError.checkNotNegative(rewardCoins, 'rewardCoins');
    if (levelOrder + 1 > _currentLevel) _currentLevel = levelOrder + 1;
    _coins += rewardCoins;
    _notify();
  }

  @override
  int boosterCount(BoosterKind kind) => _boosters[kind.index];

  @override
  bool useBooster(BoosterKind kind) {
    if (_unlimited) return true;
    if (_boosters[kind.index] == 0) return false;
    _boosters[kind.index]--;
    _notify();
    return true;
  }

  @override
  void addBoosters(BoosterKind kind, int count) {
    RangeError.checkNotNegative(count, 'count');
    if (count == 0) return;
    _boosters[kind.index] += count;
    _notify();
  }

  @override
  int get freeUndosPerLevel {
    final value = _remoteConfig.value(RemoteConfigKeys.freeUndosPerLevel);
    // A negative tuned value would read as "owes undos"; treat it as none.
    return value < 0 ? 0 : value;
  }

  @override
  bool get unlimitedBoosters => _unlimited;

  @override
  Stream<void> get changes => _changes.stream;

  /// Closes [changes] (get_it dispose hook).
  @override
  @disposeMethod
  Future<void> dispose() => _changes.close();

  void _notify() {
    if (!_changes.isClosed) _changes.add(null);
  }

  static bool _isDevFlavor() {
    try {
      return FlavorConfig.flavor == Flavor.dev;
    } on StateError {
      // `lib/main_<flavor>.dart` sets the flavor before DI, so only a test
      // that builds the real graph without one gets here: production rules.
      return false;
    }
  }
}
