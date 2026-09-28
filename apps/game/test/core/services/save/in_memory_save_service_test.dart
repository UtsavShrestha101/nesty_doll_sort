import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_game/core/flavor/flavor.dart';
import 'package:nesty_game/core/flavor/flavor_config.dart';
import 'package:nesty_game/core/models/intro_mechanic.dart';
import 'package:nesty_game/core/models/play_request.dart';
import 'package:nesty_game/core/services/clock/local_date.dart';
import 'package:nesty_game/core/services/remote_config/fake_remote_config_service.dart';
import 'package:nesty_game/core/services/remote_config/remote_config_keys.dart';
import 'package:nesty_game/core/services/save/fake_save_service.dart';
import 'package:nesty_game/core/services/save/in_memory_save_service.dart';
import 'package:nesty_game/core/services/save/save_document.dart';
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

  test('debugUnlimitedBoosters overrides the flavor in a debug build, and '
      'null goes back to it', () {
    final dev = InMemorySaveService(remoteConfig, unlimitedBoosters: true);
    addTearDown(dev.dispose);

    dev.debugUnlimitedBoosters = false;
    expect(dev.unlimitedBoosters, isFalse);
    for (var i = 0; i < BoosterKind.extraSlot.starterGift; i++) {
      expect(dev.useBooster(BoosterKind.extraSlot), isTrue);
    }
    expect(dev.boosterCount(BoosterKind.extraSlot), 0);
    expect(dev.useBooster(BoosterKind.extraSlot), isFalse);

    dev.debugUnlimitedBoosters = null;
    expect(dev.unlimitedBoosters, isTrue);
    expect(dev.useBooster(BoosterKind.extraSlot), isTrue);
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

  group('the M3 document (docs/plans/m3-design.md §3)', () {
    InProgressLevel board(PlayRequest request) => InProgressLevel(
      request: request,
      levelId: 'L${request.number}',
      levelVersion: 1,
      session: const {'format': 1},
      level: request.isGenerated ? const {'id': 'gen'} : null,
    );

    test('load gives a fresh install a Player ID, once', () async {
      await save.load();
      final id = save.playerId;
      expect(id, matches(RegExp(r'^[0-9A-F]{4}-[0-9A-F]{4}$')));
      await save.load();
      expect(save.playerId, id);
    });

    test('a campaign win moves progress, clears its board, and collects a '
        'completed chapter once', () {
      save.saveInProgress(board(const PlayRequest.campaign(20)));
      final date = LocalDate(2026, 9, 12);
      final win = LevelWinRecord(
        request: const PlayRequest.campaign(20),
        rewardCoins: 25,
        moves: 14,
        completedChapterId: 'ch01',
        chapterReward: 150,
        date: date,
      );
      save.recordLevelWin(win);
      expect(save.currentLevel, 21);
      expect(save.highestLevel, 21);
      expect(save.coins, 175);
      expect(save.inProgressFor(PlayKind.campaign), isNull);
      expect(save.document.museum, ['ch01']);
      expect(save.document.museumCollected, {'ch01': date});
      expect(save.document.stats.wins, 1);
      expect(save.document.stats.moves, 14);

      // Winning it again pays the level, not the chapter.
      save.recordLevelWin(win);
      expect(save.coins, 200);
      expect(save.document.museum, ['ch01']);
    });

    test('a bonus win moves bonus.next on and leaves currentLevel', () {
      save
        ..currentLevel = 31
        ..saveInProgress(board(const PlayRequest.bonus(2)))
        ..recordLevelWin(
          const LevelWinRecord(request: PlayRequest.bonus(2), rewardCoins: 10),
        );
      expect(save.nextBonus, 3);
      expect(save.currentLevel, 31);
      expect(save.inProgressFor(PlayKind.bonus), isNull);
    });

    test('a daily win takes the given streak and clears the daily board', () {
      save.saveInProgress(board(const PlayRequest.daily(20260926)));
      save.recordLevelWin(
        LevelWinRecord(
          request: const PlayRequest.daily(20260926),
          rewardCoins: 50,
          daily: DailyProgress(
            streak: 5,
            lastDate: LocalDate(2026, 9, 26),
            inProgress: board(const PlayRequest.daily(20260926)),
          ),
        ),
      );
      expect(save.coins, 50);
      expect(save.document.daily.streak, 5);
      expect(save.inProgressFor(PlayKind.daily), isNull);
    });

    test('campaign and bonus share one slot; the daily has its own', () {
      save.saveInProgress(board(const PlayRequest.campaign(4)));
      save.saveInProgress(board(const PlayRequest.daily(20260926)));
      expect(save.inProgressFor(PlayKind.campaign)?.levelId, 'L4');
      expect(save.inProgressFor(PlayKind.bonus), isNull);
      expect(save.inProgressFor(PlayKind.daily)?.levelId, 'L20260926');

      save.clearInProgress(PlayKind.bonus); // not the campaign's
      expect(save.inProgressFor(PlayKind.campaign), isNotNull);
      save.saveInProgress(board(const PlayRequest.bonus(1)));
      expect(save.inProgressFor(PlayKind.campaign), isNull);
      save.clearInProgress(PlayKind.daily);
      expect(save.inProgressFor(PlayKind.daily), isNull);
      expect(save.inProgressFor(PlayKind.bonus), isNotNull);
    });

    test('skins and themes are bought once, with enough coins', () {
      save.addCoins(1000);
      expect(save.purchaseSkin('ocean', 1200), isFalse);
      expect(save.purchaseSkin('ocean', 800), isTrue);
      expect(save.purchaseSkin('ocean', 800), isFalse);
      expect(save.coins, 200);
      expect(save.selectSkin('winter'), isFalse);
      expect(save.selectSkin('ocean'), isTrue);
      expect(save.document.selectedSkin, 'ocean');

      expect(save.purchaseTheme('ch01', 0), isFalse);
      expect(save.purchaseTheme('ch02', 200), isTrue);
      expect(save.document.ownedThemes, ['ch01', 'ch02']);
      save.selectTheme('ch02');
      expect(save.document.selectedTheme, 'ch02');
      save.selectTheme(null);
      expect(save.document.selectedTheme, isNull);
    });

    test('intros, the tutorial and booster stats', () {
      save
        ..markIntroSeen(IntroMechanic.towers)
        ..markIntroSeen(IntroMechanic.towers)
        ..markTutorialDone()
        ..recordBoosterUse(BoosterType.undo)
        ..recordBoosterUse(BoosterType.undo);
      expect(save.document.seenIntros, ['towers']);
      expect(save.document.tutorialDone, isTrue);
      expect(save.document.stats.boostersUsed, {'undo': 2});
    });

    test('writeDaily replaces the daily and pays in one change', () async {
      var changes = 0;
      final subscription = save.changes.listen((_) => changes++);
      addTearDown(subscription.cancel);
      save.writeDaily(const DailyProgress(streak: 7), addCoins: 300);
      await pumpEventQueue();
      expect(save.document.daily.streak, 7);
      expect(save.coins, 300);
      expect(changes, 1);
    });

    test('the dev picker never lowers highestLevel', () {
      save
        ..currentLevel = 10
        ..currentLevel = 3;
      expect((save.currentLevel, save.highestLevel), (3, 10));
    });

    test('an initial document starts the fake anywhere', () {
      final fake = FakeSaveService(
        initial: const SaveDocument(coins: 99, tutorialDone: true),
      );
      addTearDown(fake.dispose);
      expect(fake.coins, 99);
      expect(fake.document.tutorialDone, isTrue);
    });
  });
}
