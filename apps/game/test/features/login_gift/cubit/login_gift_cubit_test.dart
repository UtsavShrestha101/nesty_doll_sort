import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nesty_game/core/services/analytics/analytics_service.dart';
import 'package:nesty_game/core/services/clock/fake_clock.dart';
import 'package:nesty_game/core/services/clock/local_date.dart';
import 'package:nesty_game/core/services/login_gift/login_gift_rules.dart';
import 'package:nesty_game/core/services/remote_config/fake_remote_config_service.dart';
import 'package:nesty_game/core/services/save/fake_save_service.dart';
import 'package:nesty_game/core/services/save/save_document.dart';
import 'package:nesty_game/core/services/save/save_service.dart';
import 'package:nesty_game/features/login_gift/cubit/login_gift_cubit.dart';

class _MockAnalyticsService extends Mock implements AnalyticsService {}

// FakeClock starts on 2026-09-26.
final _today = LocalDate.fromDateTime(FakeClock.defaultNow);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FakeClock clock;
  late FakeSaveService save;
  late _MockAnalyticsService analytics;
  late LoginGiftCubit cubit;

  Future<void> start({
    int highestLevel = 5,
    int coins = 100,
    LoginGiftProgress progress = const LoginGiftProgress(),
  }) async {
    clock = FakeClock();
    analytics = _MockAnalyticsService();
    when(
      () => analytics.logEvent(any(), parameters: any(named: 'parameters')),
    ).thenAnswer((_) async {});
    save = FakeSaveService(
      initial: SaveDocument(
        highestLevel: highestLevel,
        coins: coins,
        loginGift: progress,
      ),
    );
    cubit = LoginGiftCubit(save, clock, FakeRemoteConfigService(), analytics);
    await cubit.load();
  }

  tearDown(() async => cubit.close());

  LoginGiftState data() => cubit.state.data!;

  test('locked below the Daily unlock, and the date is not noted', () async {
    await start(highestLevel: 1);
    expect(data().phase, LoginGiftPhase.locked);
    expect(data().showsDot, isFalse);
    expect(data().doneDays, 0);
    expect(save.document.loginGift.latestSeen, isNull);
  });

  test('ready on a fresh unlock, and refresh notes the date', () async {
    await start();
    expect(data().phase, LoginGiftPhase.ready);
    expect(data().canClaim, isTrue);
    expect(data().showsDot, isTrue);
    expect(data().todayDay, 1);
    expect(data().tileStateOf(1), GiftTileState.today);
    expect(data().tileStateOf(2), GiftTileState.later);
    expect(data().track, LoginGiftRules.defaultTrack);
    expect(save.document.loginGift.latestSeen, _today);
  });

  test('claim pays, turns claimed and logs once', () async {
    await start();
    final grant = cubit.claim();
    expect(grant, isNotNull);
    expect(grant!.day, 1);
    expect(save.coins, 120);
    expect(data().phase, LoginGiftPhase.claimed);
    expect(data().claims, 1);
    expect(data().doneDays, 1);
    expect(data().todayDay, isNull);
    expect(data().showsDot, isFalse);
    expect(data().nextReward, LoginGiftRules.defaultTrack[1]);
    expect(data().tileStateOf(1), GiftTileState.done);
    await Future<void>.delayed(Duration.zero);
    verify(
      () => analytics.logEvent(
        'login_gift_claim',
        parameters: {'day': 1, 'claims': 1},
      ),
    ).called(1);
  });

  test('a failing analytics call is swallowed', () async {
    await start();
    when(
      () => analytics.logEvent(any(), parameters: any(named: 'parameters')),
    ).thenThrow(StateError('offline'));
    expect(cubit.claim(), isNotNull);
    await Future<void>.delayed(Duration.zero);
    expect(data().phase, LoginGiftPhase.claimed);
  });

  test('a refused claim changes nothing and emits nothing', () async {
    await start();
    cubit.claim();
    await Future<void>.delayed(Duration.zero);
    final emitted = <Object>[];
    final sub = cubit.stream.listen(emitted.add);
    expect(cubit.claim(), isNull);
    await Future<void>.delayed(Duration.zero);
    await sub.cancel();
    expect(emitted, isEmpty);
    expect(save.coins, 120);
    verify(
      () => analytics.logEvent(any(), parameters: any(named: 'parameters')),
    ).called(1);
  });

  test('a claim while locked is refused', () async {
    await start(highestLevel: 1);
    expect(cubit.claim(), isNull);
    expect(save.coins, 100);
  });

  test('waiting after the clock goes back: no claim, no dot', () async {
    await start();
    cubit.claim();
    clock.setDate(_today.addDays(-2));
    await cubit.refresh();
    expect(data().phase, LoginGiftPhase.waiting);
    expect(data().canClaim, isFalse);
    expect(data().showsDot, isFalse);
    expect(data().todayDay, isNull);
    expect(cubit.claim(), isNull);
    expect(data().nextReward, LoginGiftRules.defaultTrack[1]);
  });

  test('a gap keeps the day', () async {
    await start();
    cubit.claim();
    clock.setDate(_today.addDays(5));
    await cubit.refresh();
    expect(data().phase, LoginGiftPhase.ready);
    expect(data().todayDay, 2);
    expect(data().doneDays, 1);
  });

  test(
    'the wrap: Day 7 claimed shows all done, the next date starts Day 1',
    () async {
      await start(
        progress: LoginGiftProgress(
          claims: 6,
          lastClaim: _today.addDays(-1),
          latestSeen: _today.addDays(-1),
        ),
      );
      expect(data().todayDay, 7);
      expect(data().doneDays, 6);
      final grant = cubit.claim();
      expect(grant!.day, 7);
      expect(grant.reward.slots, 1);
      expect(data().doneDays, 7);
      expect(data().tileStateOf(7), GiftTileState.done);
      expect(data().nextDay, 1);
      clock.setDate(_today.addDays(1));
      await cubit.refresh();
      expect(data().phase, LoginGiftPhase.ready);
      expect(data().doneDays, 0);
      expect(data().todayDay, 1);
      expect(data().tileStateOf(7), GiftTileState.later);
    },
  );

  test('coinsCap follows claim, coinsLanded and releaseCoins', () async {
    await start();
    cubit.claim();
    expect(data().coinsCap, 100);
    cubit.coinsLanded(5);
    expect(data().coinsCap, 105);
    cubit.coinsLanded(20);
    expect(data().coinsCap, 120);
    cubit.releaseCoins();
    expect(data().coinsCap, isNull);
    cubit.coinsLanded(3);
    expect(data().coinsCap, isNull);
  });

  test('a save change while coins fly keeps the cap', () async {
    await start();
    cubit.claim();
    await Future<void>.delayed(Duration.zero);
    expect(data().coinsCap, 100);
  });

  test('holdCoins false sets no cap', () async {
    await start();
    cubit.claim(holdCoins: false);
    expect(data().coinsCap, isNull);
  });

  test('a hint day pays no coins, so no cap', () async {
    await start(
      progress: LoginGiftProgress(
        claims: 2,
        lastClaim: _today.addDays(-1),
        latestSeen: _today.addDays(-1),
      ),
    );
    expect(cubit.claim()!.reward.hints, 1);
    expect(data().coinsCap, isNull);
  });

  test("the state carries the player's hint and slot totals, the tally's "
      'counts (m7-5 13.5c, 13.6d)', () async {
    await start(
      progress: LoginGiftProgress(
        claims: 2,
        lastClaim: _today.addDays(-1),
        latestSeen: _today.addDays(-1),
      ),
    );
    final hints = save.boosterCount(BoosterKind.hint);
    final slots = save.boosterCount(BoosterKind.extraSlot);
    expect(data().hints, hints);
    expect(data().slots, slots);
    cubit.claim();
    expect(data().hints, hints + 1, reason: 'the new total, right away');
    expect(data().slots, slots);
  });

  test('a date change on refresh is read from the clock', () async {
    await start();
    cubit.claim();
    clock.setDate(_today.addDays(1));
    await cubit.refresh();
    expect(data().today, _today.addDays(1));
    expect(save.document.loginGift.latestSeen, _today.addDays(1));
  });

  test(
    'the app resuming on a later date shows the next gift: the '
    'AppLifecycleListener path (a phone left asleep over midnight)',
    () async {
      await start();
      expect(cubit.claim(), isNotNull);
      expect(data().phase, LoginGiftPhase.claimed);

      clock.setDate(_today.addDays(1));
      // Nothing re-reads while the app is in the background.
      expect(data().phase, LoginGiftPhase.claimed);

      final binding = TestWidgetsFlutterBinding.instance
        ..handleAppLifecycleStateChanged(AppLifecycleState.inactive)
        ..handleAppLifecycleStateChanged(AppLifecycleState.hidden)
        ..handleAppLifecycleStateChanged(AppLifecycleState.paused);
      binding
        ..handleAppLifecycleStateChanged(AppLifecycleState.hidden)
        ..handleAppLifecycleStateChanged(AppLifecycleState.inactive)
        ..handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await pumpEventQueue();

      expect(data().today, _today.addDays(1));
      expect(data().phase, LoginGiftPhase.ready);
      expect(data().todayDay, 2);
      expect(data().showsDot, isTrue);
    },
  );
}
