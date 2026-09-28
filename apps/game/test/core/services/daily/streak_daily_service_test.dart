import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_game/core/services/clock/fake_clock.dart';
import 'package:nesty_game/core/services/clock/local_date.dart';
import 'package:nesty_game/core/services/daily/streak_daily_service.dart';
import 'package:nesty_game/core/services/remote_config/fake_remote_config_service.dart';
import 'package:nesty_game/core/services/remote_config/remote_config_keys.dart';
import 'package:nesty_game/core/services/save/fake_save_service.dart';
import 'package:nesty_game/core/services/save/save_document.dart';

void main() {
  group('StreakDailyService.reconcileForTest / solveForTest '
      '(m3-design §8.2 worked table)', () {
    // Every row of the table, in order: the acting date, the action
    // ('solve' or 'open' = refresh/reconcile only), then the streak,
    // lastDate, freezes and the latest frozen date the row expects.
    test('runs the worked table verbatim', () {
      var daily = const DailyProgress();

      DailyProgress solve(String date) => daily =
          StreakDailyService.solveForTest(daily, LocalDate.tryParse(date)!);
      DailyProgress open(String date) => daily =
          StreakDailyService.reconcileForTest(daily, LocalDate.tryParse(date)!);
      void expectRow({
        required int streak,
        required String? lastDate,
        required int freezes,
        required String? frozen,
      }) {
        expect(daily.streak, streak, reason: 'streak');
        expect(
          daily.lastDate,
          lastDate == null ? isNull : LocalDate.tryParse(lastDate),
          reason: 'lastDate',
        );
        expect(daily.freezes, freezes, reason: 'freezes');
        expect(
          daily.frozen.isEmpty ? null : daily.frozen.last.toIso(),
          frozen,
          reason: 'frozen.last',
        );
      }

      solve('2026-09-21'); // Mon (39): solve (grant W39)
      expectRow(streak: 1, lastDate: '2026-09-21', freezes: 1, frozen: null);

      solve('2026-09-22'); // Tue: solve
      expectRow(streak: 2, lastDate: '2026-09-22', freezes: 1, frozen: null);

      solve('2026-09-23'); // Wed: solve
      expectRow(streak: 3, lastDate: '2026-09-23', freezes: 1, frozen: null);

      solve('2026-09-24'); // Thu: solve
      expectRow(streak: 4, lastDate: '2026-09-24', freezes: 1, frozen: null);

      open('2026-09-26'); // Sat: open, Fri missed, freeze covers it
      expectRow(
        streak: 4,
        lastDate: '2026-09-25',
        freezes: 0,
        frozen: '2026-09-25',
      );

      solve('2026-09-26'); // Sat: solve
      expectRow(
        streak: 5,
        lastDate: '2026-09-26',
        freezes: 0,
        frozen: '2026-09-25',
      );

      solve('2026-09-27'); // Sun: solve
      expectRow(
        streak: 6,
        lastDate: '2026-09-27',
        freezes: 0,
        frozen: '2026-09-25',
      );

      solve('2026-09-28'); // Mon (40): solve (grant W40)
      expectRow(
        streak: 7,
        lastDate: '2026-09-28',
        freezes: 1,
        frozen: '2026-09-25',
      );
      expect(daily.chestPending, isTrue);

      // Collect (+300): chestPending clears, nothing else moves.
      daily = daily.copyWith(chestPending: false);
      expectRow(
        streak: 7,
        lastDate: '2026-09-28',
        freezes: 1,
        frozen: '2026-09-25',
      );

      solve('2026-09-28'); // Mon: solve again — already in `done`, no change
      expectRow(
        streak: 7,
        lastDate: '2026-09-28',
        freezes: 1,
        frozen: '2026-09-25',
      );
      expect(daily.chestPending, isFalse);

      solve('2026-09-29'); // Tue: solve
      expectRow(
        streak: 8,
        lastDate: '2026-09-29',
        freezes: 1,
        frozen: '2026-09-25',
      );

      open('2026-10-02'); // Fri: open, Wed covered, Thu not → reset
      expectRow(streak: 0, lastDate: null, freezes: 0, frozen: '2026-09-30');

      solve('2026-10-02'); // Fri: solve
      expectRow(
        streak: 1,
        lastDate: '2026-10-02',
        freezes: 0,
        frozen: '2026-09-30',
      );

      solve('2026-10-04'); // Sun: solve, Sat missed, no freeze → reset, then 1
      expectRow(
        streak: 1,
        lastDate: '2026-10-04',
        freezes: 0,
        frozen: '2026-09-30',
      );

      open(
        '2026-10-06',
      ); // Tue (41): open, Mon missed, its own W41 grant covers it
      expectRow(
        streak: 1,
        lastDate: '2026-10-05',
        freezes: 0,
        frozen: '2026-10-05',
      );

      solve('2026-10-06'); // Tue: solve
      expectRow(
        streak: 2,
        lastDate: '2026-10-06',
        freezes: 0,
        frozen: '2026-10-05',
      );
    });

    test('reconcile is idempotent within the same day', () {
      final daily = StreakDailyService.solveForTest(
        const DailyProgress(),
        LocalDate.tryParse('2026-09-21')!,
      );
      final once = StreakDailyService.reconcileForTest(
        daily,
        LocalDate.tryParse('2026-09-21')!,
      );
      final twice = StreakDailyService.reconcileForTest(
        once,
        LocalDate.tryParse('2026-09-21')!,
      );
      expect(once, daily);
      expect(twice, once);
    });
  });

  group('StreakDailyService', () {
    late FakeSaveService save;
    late FakeClock clock;
    late FakeRemoteConfigService remoteConfig;
    late StreakDailyService service;

    setUp(() {
      save = FakeSaveService();
      clock = FakeClock(now: DateTime(2026, 9, 21, 12));
      remoteConfig = FakeRemoteConfigService();
      service = StreakDailyService(save, clock, remoteConfig);
    });

    tearDown(() => service.dispose());

    test('is locked until Level 2 is won (highestLevel >= 3)', () {
      expect(service.isUnlocked, isFalse);
      save.currentLevel = 3;
      expect(service.isUnlocked, isTrue);
    });

    test('refresh reconciles today, writes only when it changed, and '
        'reports the strip fields', () {
      final status = service.refresh();
      expect(status.today, LocalDate(2026, 9, 21));
      expect(status.streak, 0);
      expect(status.solvedToday, isFalse);
      expect(status.cycleDone, 0);

      // Idempotent: a same-day refresh doesn't write again.
      final before = save.document.daily;
      service.refresh();
      expect(save.document.daily, before);
    });

    test('a win is recorded through progressAfterSolve, then '
        'recordLevelWin clears the board in the same update', () {
      final win = service.progressAfterSolve(clock.today());
      save.recordLevelWin(
        LevelWinRecord(
          request: service.todayRequest,
          rewardCoins: 50,
          daily: win,
        ),
      );
      expect(save.document.daily.streak, 1);
      expect(save.document.daily.done, [clock.today()]);

      final status = service.refresh();
      expect(status.streak, 1);
      expect(status.solvedToday, isTrue);
      expect(status.cycleDone, 1);
    });

    test('collectChest pays streak7Reward and clears chestPending once', () {
      save.writeDaily(const DailyProgress(streak: 7, chestPending: true));

      final coins = service.collectChest();

      expect(coins, RemoteConfigKeys.streak7Reward.defaultValue);
      expect(save.coins, coins);
      expect(save.document.daily.chestPending, isFalse);
      expect(service.collectChest(), 0);
    });

    test('acknowledgeFreezeNotice clears the notice once shown', () {
      save.writeDaily(DailyProgress(frozen: [LocalDate(2026, 9, 18)]));
      expect(service.refresh().freezeNotice, LocalDate(2026, 9, 18));

      service.acknowledgeFreezeNotice();

      expect(service.refresh().freezeNotice, isNull);
    });

    test('untilNextPuzzle counts down to local midnight', () {
      clock.set(DateTime(2026, 9, 21, 22));
      expect(service.untilNextPuzzle(), const Duration(hours: 2));
    });

    test('changes fires on every published status', () async {
      final statuses = <int>[];
      final subscription = service.changes.listen(
        (status) => statuses.add(status.streak),
      );
      addTearDown(subscription.cancel);

      service.refresh();
      save.writeDaily(const DailyProgress(streak: 7, chestPending: true));
      service.collectChest();
      await pumpEventQueue();

      expect(statuses, [0, 7]);
    });

    test('changes stays quiet when a refresh changes nothing', () async {
      var fired = 0;
      final subscription = service.changes.listen((_) => fired++);
      addTearDown(subscription.cancel);

      service
        ..refresh()
        ..refresh()
        ..refresh();
      await pumpEventQueue();

      // Home re-reads the status (refresh) on every change: an unchanged
      // status firing again would loop forever.
      expect(fired, 1);
    });
  });
}
