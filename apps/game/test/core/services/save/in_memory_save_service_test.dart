import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_game/core/flavor/flavor.dart';
import 'package:nesty_game/core/flavor/flavor_config.dart';
import 'package:nesty_game/core/services/remote_config/fake_remote_config_service.dart';
import 'package:nesty_game/core/services/remote_config/remote_config_keys.dart';
import 'package:nesty_game/core/services/save/fake_save_service.dart';
import 'package:nesty_game/core/services/save/in_memory_save_service.dart';
import 'package:nesty_game/core/services/save/save_service.dart';

import '../../../helpers/test_dependencies.dart';

void main() {
  late FakeRemoteConfigService remoteConfig;
  late InMemorySaveService save;

  setUp(() {
    remoteConfig = FakeRemoteConfigService();
    save = InMemorySaveService(remoteConfig, unlimitedBoosters: false);
  });

  tearDown(() => save.dispose());

  test('starts as a fresh install: level 1, no coins, the spec §8 starter '
      'boosters', () async {
    await save.load();

    expect(save.currentLevel, 1);
    expect(save.coins, 0);
    expect(save.boosterCount(BoosterKind.hint), 3);
    expect(save.boosterCount(BoosterKind.extraSlot), 2);
    expect(BoosterKind.hint.storageKey, 'hint');
    expect(BoosterKind.extraSlot.storageKey, 'slot');
  });

  test('free undos per level come from Remote Config', () {
    expect(
      save.freeUndosPerLevel,
      RemoteConfigKeys.freeUndosPerLevel.defaultValue,
    );
    remoteConfig.setOverride(RemoteConfigKeys.freeUndosPerLevel, 5);
    expect(save.freeUndosPerLevel, 5);
    remoteConfig.setOverride(RemoteConfigKeys.freeUndosPerLevel, -1);
    expect(save.freeUndosPerLevel, 0);
  });

  test('a win adds the reward and moves progress on, never back', () {
    save.recordWin(levelOrder: 1, rewardCoins: 10);
    expect((save.currentLevel, save.coins), (2, 10));

    save.recordWin(levelOrder: 6, rewardCoins: 25);
    expect((save.currentLevel, save.coins), (7, 35));

    // Replaying an earlier level pays but keeps the progress.
    save.recordWin(levelOrder: 3, rewardCoins: 10);
    expect((save.currentLevel, save.coins), (7, 45));
  });

  test('coins are spent only when there are enough', () {
    save.addCoins(50);
    expect(save.spendCoins(60), isFalse);
    expect(save.coins, 50);
    expect(save.spendCoins(20), isTrue);
    expect(save.coins, 30);
    expect(save.spendCoins(0), isTrue);
    expect(() => save.addCoins(-1), throwsRangeError);
    expect(() => save.spendCoins(-1), throwsRangeError);
  });

  test('boosters run out', () {
    expect(save.useBooster(BoosterKind.extraSlot), isTrue);
    expect(save.useBooster(BoosterKind.extraSlot), isTrue);
    expect(save.useBooster(BoosterKind.extraSlot), isFalse);
    expect(save.boosterCount(BoosterKind.extraSlot), 0);
    expect(save.boosterCount(BoosterKind.hint), 3);

    save.addBoosters(BoosterKind.extraSlot, 1);
    expect(save.useBooster(BoosterKind.extraSlot), isTrue);
  });

  test('unlimited boosters are never used up', () async {
    final dev = InMemorySaveService(remoteConfig, unlimitedBoosters: true);
    addTearDown(dev.dispose);

    for (var i = 0; i < 10; i++) {
      expect(dev.useBooster(BoosterKind.hint), isTrue);
    }
    expect(dev.boosterCount(BoosterKind.hint), 3);
    expect(dev.unlimitedBoosters, isTrue);
  });

  test('unlimited boosters follow the dev flavor by default', () {
    // The test flavor is dev (test_dependencies.dart).
    FlavorConfig(flavor: Flavor.dev, values: testFlavorValues);
    final flavored = InMemorySaveService(remoteConfig);
    addTearDown(flavored.dispose);

    expect(flavored.unlimitedBoosters, isTrue);
  });

  test('currentLevel is 1-based', () {
    save.currentLevel = 24;
    expect(save.currentLevel, 24);
    expect(() => save.currentLevel = 0, throwsRangeError);
  });

  test('every change is announced', () async {
    final changes = <void>[];
    final subscription = save.changes.listen(changes.add);
    addTearDown(subscription.cancel);

    save
      ..addCoins(30)
      ..spendCoins(10)
      ..spendCoins(999) // refused: no change
      ..useBooster(BoosterKind.hint)
      ..addBoosters(BoosterKind.hint, 2)
      ..recordWin(levelOrder: 1, rewardCoins: 10)
      ..currentLevel = 5
      ..currentLevel = 5; // unchanged
    await pumpEventQueue();

    expect(changes, hasLength(6));
  });

  test('the fake is a fresh install with real counts, whatever the flavor', () {
    FlavorConfig(flavor: Flavor.dev, values: testFlavorValues);
    final fake = FakeSaveService()..currentLevel = 12;
    addTearDown(fake.dispose);

    expect(fake.currentLevel, 12);
    expect(fake.unlimitedBoosters, isFalse);
    expect(fake.useBooster(BoosterKind.hint), isTrue);
    expect(fake.boosterCount(BoosterKind.hint), 2);
    expect(
      fake.freeUndosPerLevel,
      RemoteConfigKeys.freeUndosPerLevel.defaultValue,
    );
    expect(
      FakeSaveService(
        remoteConfig: FakeRemoteConfigService()
          ..setOverride(RemoteConfigKeys.freeUndosPerLevel, 4),
      ).freeUndosPerLevel,
      4,
    );
  });
}
