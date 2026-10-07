import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_game/core/services/clock/local_date.dart';
import 'package:nesty_game/core/services/daily/streak_daily_service.dart';
import 'package:nesty_game/core/services/login_gift/login_gift_reward.dart';
import 'package:nesty_game/core/services/remote_config/fake_remote_config_service.dart';
import 'package:nesty_game/core/services/remote_config/remote_config_keys.dart';
import 'package:nesty_game/core/services/remote_config/remote_config_service.dart';
import 'package:nesty_game/core/services/save/fake_save_service.dart';
import 'package:nesty_game/core/services/save/in_memory_save_service.dart';
import 'package:nesty_game/core/services/save/save_document.dart';
import 'package:nesty_game/core/services/save/save_service.dart';

/// A [RemoteConfigService] whose every read throws, for rule 3.
final class _ThrowingRemoteConfig implements RemoteConfigService {
  @override
  Future<void> refresh() async {}

  @override
  T value<T extends Object>(RemoteConfigKey<T> key) =>
      throw StateError('no config');
}

/// `SaveService.claimLoginGift` and `noteLoginGiftDate`, the daily gift's
/// save contract (plan-login-gift §7.5b, spec until the owner pastes it;
/// D268): the track counts claims, not dates; at most one claim per local
/// date; a date earlier than the latest one seen claims nothing; it
/// unlocks with the Daily (after Level 2). The rules themselves are
/// `login_gift_rules_test.dart`'s; this is the one-update pay and write.
void main() {
  final oct5 = LocalDate(2026, 10, 5);

  /// A save past Level 2, so the Daily (and the gift) are open.
  FakeSaveService unlocked({
    RemoteConfigService? remoteConfig,
    SaveDocument document = const SaveDocument(
      currentLevel: StreakDailyService.unlockAtHighestLevel,
      highestLevel: StreakDailyService.unlockAtHighestLevel,
    ),
  }) {
    final save = FakeSaveService(remoteConfig: remoteConfig, initial: document);
    addTearDown(save.dispose);
    return save;
  }

  /// Counts [save]'s `changes` until the test ends.
  List<void> changesOf(SaveService save) {
    final changes = <void>[];
    final subscription = save.changes.listen(changes.add);
    addTearDown(subscription.cancel);
    return changes;
  }

  test('locked below the Daily\'s unlock (highestLevel 2): no gift and '
      'nothing written', () async {
    expect(StreakDailyService.unlockAtHighestLevel, 3);
    final save = unlocked(
      document: const SaveDocument(currentLevel: 2, highestLevel: 2),
    );
    final before = save.document;
    final changes = changesOf(save);

    expect(save.claimLoginGift(oct5), isNull);
    await pumpEventQueue();
    expect(save.document, same(before));
    expect(changes, isEmpty);
  });

  test('unlocked: Day 1 pays 20 coins in one update, and the progress '
      'counts the claim with its date', () async {
    final save = unlocked();
    final changes = changesOf(save);

    final grant = save.claimLoginGift(oct5);
    await pumpEventQueue();
    expect(
      grant,
      LoginGiftGrant(
        date: oct5,
        day: 1,
        claims: 1,
        reward: const LoginGiftReward(coins: 20),
      ),
    );
    expect(save.coins, 20);
    expect(save.document.inventory, const BoosterInventory());
    expect(
      save.document.loginGift,
      LoginGiftProgress(claims: 1, lastClaim: oct5, latestSeen: oct5),
    );
    expect(changes, hasLength(1));
  });

  test('the same date again claims nothing and writes nothing', () async {
    final save = unlocked()..claimLoginGift(oct5);
    final after = save.document;
    final changes = changesOf(save);

    expect(save.claimLoginGift(oct5), isNull);
    await pumpEventQueue();
    expect(save.document, same(after));
    expect(save.coins, 20);
    expect(changes, isEmpty);
  });

  test('the next day pays Day 2, and a gap of 3 days still pays the next '
      'day: a missed day never moves the track back', () {
    final save = unlocked();
    expect(save.claimLoginGift(oct5)?.day, 1);
    final day2 = save.claimLoginGift(oct5.addDays(1));
    expect(day2?.day, 2);
    expect(day2?.reward, const LoginGiftReward(coins: 30));
    expect(save.coins, 50);

    // Three days away, then back: Day 3, not Day 1 and not Day 6.
    final back = oct5.addDays(5);
    final day3 = save.claimLoginGift(back);
    expect(day3?.day, 3);
    expect(day3?.claims, 3);
    expect(save.document.loginGift.lastClaim, back);
  });

  test('a week of claims pays the whole default track, then Day 1 again '
      'after Day 7 (claims 8)', () {
    final save = unlocked();
    final start = save.document.inventory;
    final days = <int>[];
    for (var i = 0; i < 7; i++) {
      days.add(save.claimLoginGift(oct5.addDays(i))!.day);
    }
    expect(days, [1, 2, 3, 4, 5, 6, 7]);
    // 20 + 30 + 40 + 50 + 100 coins; Days 3 and 6 a hint each; Day 7 an
    // extra slot too.
    expect(save.coins, 240);
    expect(save.document.inventory.hint, start.hint + 2);
    expect(save.document.inventory.slot, start.slot + 1);

    final wrap = save.claimLoginGift(oct5.addDays(7));
    expect(wrap?.day, 1);
    expect(wrap?.claims, 8);
    expect(wrap?.reward, const LoginGiftReward(coins: 20));
    expect(save.coins, 260);
    expect(save.document.loginGift.claims, 8);
  });

  test('Day 3 adds one hint and Day 7 adds 100 coins and one extra slot, '
      'each in a single update', () async {
    final save = unlocked(
      document: const SaveDocument(
        currentLevel: 5,
        highestLevel: 5,
        coins: 7,
        inventory: BoosterInventory(hint: 1, slot: 0),
        loginGift: LoginGiftProgress(claims: 2),
      ),
    );
    final changes = changesOf(save);
    expect(save.claimLoginGift(oct5)?.day, 3);
    expect(save.document.inventory, const BoosterInventory(hint: 2, slot: 0));
    expect(save.coins, 7);

    final dayBefore7 = save.document.copyWith(
      loginGift: LoginGiftProgress(
        claims: 6,
        lastClaim: oct5,
        latestSeen: oct5,
      ),
    );
    final week = unlocked(document: dayBefore7);
    final weekChanges = changesOf(week);
    final day7 = week.claimLoginGift(oct5.addDays(1));
    await pumpEventQueue();
    expect(day7?.day, 7);
    expect(day7?.reward, const LoginGiftReward(coins: 100, slots: 1));
    expect(week.coins, 107);
    expect(week.document.inventory, const BoosterInventory(hint: 2, slot: 1));
    expect(changes, hasLength(1));
    expect(weekChanges, hasLength(1));
  });

  test('a date earlier than the latest one seen claims nothing (the clock '
      'went back)', () async {
    final save = unlocked()..claimLoginGift(oct5);
    final after = save.document;
    final changes = changesOf(save);

    expect(save.claimLoginGift(oct5.addDays(-1)), isNull);
    expect(save.claimLoginGift(oct5.addDays(-30)), isNull);
    await pumpEventQueue();
    expect(save.document, same(after));
    expect(changes, isEmpty);
    // Forward again, the next date claims as usual.
    expect(save.claimLoginGift(oct5.addDays(1))?.day, 2);
  });

  group('noteLoginGiftDate', () {
    test('raises latestSeen in one update, never lowers it, and writes '
        'nothing when the date is not later', () async {
      final save = unlocked();
      final changes = changesOf(save);

      save.noteLoginGiftDate(oct5);
      await pumpEventQueue();
      expect(save.document.loginGift, LoginGiftProgress(latestSeen: oct5));
      expect(changes, hasLength(1));

      final after = save.document;
      save
        ..noteLoginGiftDate(oct5)
        ..noteLoginGiftDate(oct5.addDays(-3));
      await pumpEventQueue();
      expect(save.document, same(after));
      expect(changes, hasLength(1));

      save.noteLoginGiftDate(oct5.addDays(2));
      await pumpEventQueue();
      expect(save.document.loginGift.latestSeen, oct5.addDays(2));
      expect(save.document.loginGift.claims, 0);
      expect(save.coins, 0);
      expect(changes, hasLength(2));
    });

    test('a note is not a claim: the same date still claims Day 1', () {
      final save = unlocked()..noteLoginGiftDate(oct5);
      expect(save.claimLoginGift(oct5)?.day, 1);
      expect(save.coins, 20);
    });

    test('a later-dated note blocks an earlier claim', () {
      final save = unlocked()..noteLoginGiftDate(oct5.addDays(10));
      expect(save.claimLoginGift(oct5), isNull);
      expect(save.coins, 0);
      expect(save.document.loginGift.claims, 0);
      // From that date on, the gift is open again.
      expect(save.claimLoginGift(oct5.addDays(10))?.day, 1);
    });
  });

  test('a Remote Config track pays the override; a malformed one pays the '
      'default track', () {
    final config = FakeRemoteConfigService()
      ..setOverride(
        RemoteConfigKeys.loginGiftTrack,
        '[{"coins":5},{"hints":2},{"slots":3},{"coins":1},{"coins":1},'
        '{"coins":1},{"coins":9,"hints":1,"slots":1}]',
      );
    final save = unlocked(remoteConfig: config);
    final start = save.document.inventory;
    expect(save.claimLoginGift(oct5)?.reward, const LoginGiftReward(coins: 5));
    expect(save.coins, 5);
    expect(
      save.claimLoginGift(oct5.addDays(1))?.reward,
      const LoginGiftReward(hints: 2),
    );
    expect(save.document.inventory.hint, start.hint + 2);
    expect(
      save.claimLoginGift(oct5.addDays(2))?.reward,
      const LoginGiftReward(slots: 3),
    );
    expect(save.document.inventory.slot, start.slot + 3);

    config.setOverride(RemoteConfigKeys.loginGiftTrack, 'not a track');
    // Day 4 of the default track.
    expect(
      save.claimLoginGift(oct5.addDays(3))?.reward,
      const LoginGiftReward(coins: 40),
    );
    expect(save.coins, 45);
  });

  test('gift boosters are added even with the dev flavor\'s unlimited '
      'boosters: they are a stored count', () {
    final dev = InMemorySaveService(
      FakeRemoteConfigService(),
      unlimitedBoosters: true,
      initial: const SaveDocument(
        currentLevel: 4,
        highestLevel: 4,
        loginGift: LoginGiftProgress(claims: 2),
      ),
    );
    addTearDown(dev.dispose);
    expect(dev.unlimitedBoosters, isTrue);
    expect(dev.claimLoginGift(oct5)?.reward, const LoginGiftReward(hints: 1));
    expect(dev.boosterCount(BoosterKind.hint), 4);
  });

  test('never throws (rule 3): a failing Remote Config read claims '
      'nothing and writes nothing', () async {
    final save = unlocked(remoteConfig: _ThrowingRemoteConfig());
    final before = save.document;
    final changes = changesOf(save);
    expect(save.claimLoginGift(oct5), isNull);
    save.noteLoginGiftDate(oct5);
    await pumpEventQueue();
    expect(save.document.coins, before.coins);
    expect(save.document.loginGift, LoginGiftProgress(latestSeen: oct5));
    // Only the note wrote (it reads no config).
    expect(changes, hasLength(1));
  });
}
