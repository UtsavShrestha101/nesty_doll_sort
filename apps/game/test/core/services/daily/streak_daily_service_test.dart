import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_game/core/models/play_request.dart';
import 'package:nesty_game/core/services/clock/fake_clock.dart';
import 'package:nesty_game/core/services/clock/local_date.dart';
import 'package:nesty_game/core/services/daily/streak_daily_service.dart';
import 'package:nesty_game/core/services/remote_config/fake_remote_config_service.dart';
import 'package:nesty_game/core/services/remote_config/remote_config_keys.dart';
import 'package:nesty_game/core/services/save/fake_save_service.dart';
import 'package:nesty_game/core/services/save/save_document.dart';

void main() {
  group('StreakDailyService.reconcileForTest / solveForTest '
      '(m7-design §8 worked table)', () {
    // Every row of the table, in order: the acting date, the action
    // ('solve' or 'open' = refresh/reconcile only), then streak, lit, run,
    // lastDate, freezes and the latest frozen date the row expects. The
    // gentle streak (`streak`) is never lowered; `run` and `lit` are the
    // ones a miss can reset.
    test('runs the worked table verbatim', () {
      var daily = const DailyProgress();

      DailyProgress solve(String date) => daily =
          StreakDailyService.solveForTest(daily, LocalDate.tryParse(date)!);
      DailyProgress open(String date) => daily =
          StreakDailyService.reconcileForTest(daily, LocalDate.tryParse(date)!);
      void expectRow({
        required int streak,
        required bool lit,
        required int run,
        required String? lastDate,
        required int freezes,
        required String? frozen,
      }) {
        expect(daily.streak, streak, reason: 'streak');
        expect(daily.lit, lit, reason: 'lit');
        expect(daily.run, run, reason: 'run');
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
      expectRow(
        streak: 1,
        lit: true,
        run: 1,
        lastDate: '2026-09-21',
        freezes: 1,
        frozen: null,
      );

      solve('2026-09-22'); // Tue: solve
      expectRow(
        streak: 2,
        lit: true,
        run: 2,
        lastDate: '2026-09-22',
        freezes: 1,
        frozen: null,
      );

      solve('2026-09-23'); // Wed: solve
      expectRow(
        streak: 3,
        lit: true,
        run: 3,
        lastDate: '2026-09-23',
        freezes: 1,
        frozen: null,
      );

      solve('2026-09-24'); // Thu: solve
      expectRow(
        streak: 4,
        lit: true,
        run: 4,
        lastDate: '2026-09-24',
        freezes: 1,
        frozen: null,
      );

      open('2026-09-26'); // Sat: open, Fri missed, a freeze covers it
      expectRow(
        streak: 4,
        lit: true,
        run: 4,
        lastDate: '2026-09-25',
        freezes: 0,
        frozen: '2026-09-25',
      );

      solve('2026-09-26'); // Sat: solve
      expectRow(
        streak: 5,
        lit: true,
        run: 5,
        lastDate: '2026-09-26',
        freezes: 0,
        frozen: '2026-09-25',
      );

      solve('2026-09-27'); // Sun: solve
      expectRow(
        streak: 6,
        lit: true,
        run: 6,
        lastDate: '2026-09-27',
        freezes: 0,
        frozen: '2026-09-25',
      );

      solve('2026-09-28'); // Mon (40): solve (grant W40)
      expectRow(
        streak: 7,
        lit: true,
        run: 7,
        lastDate: '2026-09-28',
        freezes: 1,
        frozen: '2026-09-25',
      );
      expect(daily.chestPending, isTrue);

      // Collect (+300): chestPending clears, nothing else moves.
      daily = daily.copyWith(chestPending: false);
      expectRow(
        streak: 7,
        lit: true,
        run: 7,
        lastDate: '2026-09-28',
        freezes: 1,
        frozen: '2026-09-25',
      );

      solve('2026-09-29'); // Tue: solve (longestRun would reach 8)
      expectRow(
        streak: 8,
        lit: true,
        run: 8,
        lastDate: '2026-09-29',
        freezes: 1,
        frozen: '2026-09-25',
      );

      open('2026-10-02'); // Fri: open, Wed covered, Thu not → paused
      expectRow(
        streak: 8,
        lit: false,
        run: 0,
        lastDate: null,
        freezes: 0,
        frozen: '2026-09-30',
      );

      solve('2026-10-02'); // Fri: solve, relit
      expectRow(
        streak: 9,
        lit: true,
        run: 1,
        lastDate: '2026-10-02',
        freezes: 0,
        frozen: '2026-09-30',
      );
      expect(daily.relitOn(LocalDate(2026, 10, 2)), isTrue);

      solve('2026-10-04'); // Sun: solve, Sat missed, no freeze → paused, relit
      expectRow(
        streak: 10,
        lit: true,
        run: 1,
        lastDate: '2026-10-04',
        freezes: 0,
        frozen: '2026-09-30',
      );

      open(
        '2026-10-06',
      ); // Tue (41): open, Mon missed, its own W41 grant covers it
      expectRow(
        streak: 10,
        lit: true,
        run: 1,
        lastDate: '2026-10-05',
        freezes: 0,
        frozen: '2026-10-05',
      );

      solve('2026-10-06'); // Tue: solve
      expectRow(
        streak: 11,
        lit: true,
        run: 2,
        lastDate: '2026-10-06',
        freezes: 0,
        frozen: '2026-10-05',
      );

      open('2026-10-12'); // Mon (42): open, Wed–Sun missed, W41's freeze
      // already used → paused; then today's W42 grant (covers the next
      // miss, not this one).
      expectRow(
        streak: 11,
        lit: false,
        run: 0,
        lastDate: null,
        freezes: 1,
        frozen: '2026-10-05',
      );

      solve('2026-10-12'); // Mon: solve, relit
      expectRow(
        streak: 12,
        lit: true,
        run: 1,
        lastDate: '2026-10-12',
        freezes: 1,
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

    // The transitions above, isolated: each is a single fixture and a
    // single reconcile/solve, so a regression names exactly what broke.
    group('isolated transitions', () {
      final monday = LocalDate(2026, 1, 5);

      test('a missed day covered by a freeze keeps the flame lit and the '
          'run and streak unchanged', () {
        final daily = StreakDailyService.reconcileForTest(
          DailyProgress(
            streak: 3,
            lit: true,
            run: 3,
            lastDate: monday,
            freezes: 1,
            freezeWeek: monday.isoWeekKey,
          ),
          monday.addDays(2), // Tuesday missed
        );
        expect(daily.streak, 3);
        expect(daily.lit, isTrue);
        expect(daily.run, 3);
        expect(daily.lastDate, monday.addDays(1));
        expect(daily.freezes, 0);
        expect(daily.frozen, [monday.addDays(1)]);
        expect(daily.paused, isFalse);
      });

      test('a missed day with no freeze left pauses the flame without '
          'lowering the streak', () {
        final daily = StreakDailyService.reconcileForTest(
          DailyProgress(
            streak: 5,
            lit: true,
            run: 5,
            lastDate: monday,
            freezeWeek: monday.isoWeekKey, // already spent this week
          ),
          monday.addDays(2), // Tuesday missed, uncovered
        );
        expect(daily.streak, 5);
        expect(daily.lit, isFalse);
        expect(daily.run, 0);
        expect(daily.lastDate, isNull);
        expect(daily.paused, isTrue);
      });

      test('two missed days with one freeze: the first is covered, the '
          'second pauses the flame', () {
        final daily = StreakDailyService.reconcileForTest(
          DailyProgress(
            streak: 5,
            lit: true,
            run: 5,
            lastDate: monday,
            freezes: 1,
            freezeWeek: monday.isoWeekKey,
          ),
          monday.addDays(3), // Tuesday and Wednesday both missed
        );
        expect(daily.streak, 5);
        expect(daily.lit, isFalse);
        expect(daily.run, 0);
        expect(daily.lastDate, isNull);
        expect(daily.freezes, 0);
        // Only Tuesday (the covered one) ever joined `frozen`.
        expect(daily.frozen, [monday.addDays(1)]);
      });

      test('a solve after a pause relights the flame at run 1, keeps the '
          'streak growing, and DailyProgress.relitOn fires once', () {
        const paused = DailyProgress(streak: 9);
        final today = LocalDate(2026, 1, 10);

        final relit = StreakDailyService.solveForTest(paused, today);

        expect(relit.streak, 10);
        expect(relit.lit, isTrue);
        expect(relit.run, 1);
        expect(relit.lastDate, today);
        expect(relit.relitOn(today), isTrue);

        // The very first solve ever starts a streak; it isn't a relight.
        final first = StreakDailyService.solveForTest(
          const DailyProgress(),
          today,
        );
        expect(first.relitOn(today), isFalse);
      });

      // M7 review R2: the clock going back (a date before `lastDate`) must
      // not grant the older date's ISO week, or rolling the clock back and
      // forth mints a freeze per round trip past the once-per-week cap
      // (m3-design §8.2; m7-design §8 "the clock went back").
      test('reconcile on a date before lastDate (the clock went back) '
          'changes nothing, and grants no freeze for the older week', () {
        final spent = DailyProgress(
          streak: 4,
          lit: true,
          run: 4,
          lastDate: monday,
          freezeWeek: monday.isoWeekKey, // this week's freeze already spent
          done: [monday],
        );

        final back = StreakDailyService.reconcileForTest(
          spent,
          monday.addDays(-1), // Sunday of the previous ISO week
        );

        expect(back, spent);
      });

      test('a solve on a date before lastDate pays and records it, but '
          'grants no freeze for the older week', () {
        final spent = DailyProgress(
          streak: 4,
          lit: true,
          run: 4,
          lastDate: monday,
          freezeWeek: monday.isoWeekKey,
          done: [monday],
        );
        final sunday = monday.addDays(-1);

        final solved = StreakDailyService.solveForTest(spent, sunday);

        expect(solved.done, [monday, sunday]);
        expect(solved.freezes, 0);
        expect(solved.freezeWeek, monday.isoWeekKey);
        expect(solved.streak, 4);
        expect(solved.run, 4);
        expect(solved.lastDate, monday);
      });

      test('the chest becomes pending on every 7th streak day, counting '
          'every solve even across a pause in between', () {
        var daily = const DailyProgress();
        var date = LocalDate(2026, 3, 2);
        for (var i = 0; i < 7; i++) {
          daily = StreakDailyService.solveForTest(daily, date);
          date = date.addDays(1);
        }
        expect(daily.streak, 7);
        expect(daily.chestPending, isTrue);

        // The modal collects it; nothing else moves.
        daily = daily.copyWith(chestPending: false);

        // A gap with no freeze left pauses the flame, but the 7-day count
        // toward the next chest is the lifetime streak, never the run
        // (m7-design §8, §9): it isn't reset by the pause either.
        date = date.addDays(5);
        for (var i = 0; i < 7; i++) {
          daily = StreakDailyService.solveForTest(daily, date);
          date = date.addDays(1);
        }
        expect(daily.streak, 14);
        expect(daily.chestPending, isTrue);
      });
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
      expect(save.document.daily.lit, isTrue);
      expect(save.document.daily.run, 1);
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

    group('fake-clock transitions (m7-design §8)', () {
      void solveToday() {
        final win = service.progressAfterSolve(clock.today());
        save.recordLevelWin(
          LevelWinRecord(
            request: service.todayRequest,
            rewardCoins: 50,
            daily: win,
          ),
        );
      }

      void advanceDays(int days) => clock.setDate(clock.today().addDays(days));

      test('a missed day covered by the weekly freeze keeps the tile lit', () {
        solveToday(); // Mon: streak 1, the week's freeze granted.
        advanceDays(2); // Wed: Tuesday missed.

        final status = service.refresh();

        expect(status.lit, isTrue);
        expect(status.paused, isFalse);
        expect(status.streak, 1);
        expect(status.run, 1);
        expect(status.freezeNotice, LocalDate(2026, 9, 22));
      });

      test('a second missed day with the freeze already spent pauses the '
          'tile without lowering the streak', () {
        solveToday(); // Mon
        advanceDays(2); // Wed: Tuesday covered by the freeze.
        service.refresh();
        advanceDays(1); // Thu: Wednesday missed, no freeze left.

        final status = service.refresh();

        expect(status.lit, isFalse);
        expect(status.paused, isTrue);
        expect(status.streak, 1);
        expect(status.run, 0);
      });

      // M7 review R2, end to end: roll the clock back a week after the
      // freeze is spent, open and solve that older daily, then roll it
      // forward again. The older week must not grant a second freeze.
      test('rolling the clock back and forth never mints an extra weekly '
          'freeze', () {
        solveToday(); // Mon 09-21 (W39): streak 1, W39's freeze granted.
        advanceDays(2); // Wed: Tuesday covered by the freeze.
        expect(service.refresh().freezes, 0);
        solveToday(); // Wed: streak 2, lastDate Wed.

        clock.setDate(LocalDate(2026, 9, 20)); // back to Sun (W38)
        expect(service.refresh().freezes, 0);
        solveToday(); // pays and records Sunday; streak and run untouched
        expect(save.document.daily.done, contains(LocalDate(2026, 9, 20)));
        expect(save.document.daily.freezes, 0);

        clock.setDate(LocalDate(2026, 9, 24)); // forward to Thu (W39)
        final status = service.refresh();

        expect(status.freezes, 0);
        expect(
          save.document.daily.freezeWeek,
          LocalDate(2026, 9, 24).isoWeekKey,
        );
        expect(status.streak, 2);
        expect(status.run, 2);
      });

      // M7 review R6: only today's date counts toward the streak (m3-design
      // §8.2, D76, Q70; m7-design §8). Thursday's daily is started at 23:55
      // and won at 00:03 on Friday, with and without the Daily screen's
      // countdown refreshing the streak at 00:01 in between.
      for (final tick in [false, true]) {
        for (final freeze in [true, false]) {
          test('a daily won after midnight pays and records its date only '
              '(countdown refresh: $tick, freeze held: $freeze)', () {
            for (var i = 0; i < 3; i++) {
              solveToday(); // Mon–Wed: streak 3, run 3.
              advanceDays(1);
            }
            if (!freeze) {
              save.writeDaily(save.document.daily.copyWith(freezes: 0));
            }
            clock.set(DateTime(2026, 9, 24, 23, 55)); // Thu
            service.refresh();
            final thursday = clock.today();
            final request = service.todayRequest;
            clock.set(DateTime(2026, 9, 25, 0, 1)); // Fri
            if (tick) service.refresh();
            clock.set(DateTime(2026, 9, 25, 0, 3));

            final win = service.progressAfterSolve(thursday);

            expect(win.streak, 3, reason: 'streak');
            expect(win.relitOn(thursday), isFalse, reason: 'relit');
            expect(win.done, contains(thursday), reason: 'done');
            expect(win.chestPending, isFalse, reason: 'chest');

            save.recordLevelWin(
              LevelWinRecord(request: request, rewardCoins: 50, daily: win),
            );
            // Both orders end the same once Friday is reconciled: Thursday
            // was missed on its own date, so the held freeze covers it (the
            // run of 3 stays lit) or, with none, the flame pauses.
            final status = service.refresh();
            expect(status.streak, 3, reason: 'status streak');
            expect(status.solvedToday, isFalse, reason: 'solvedToday');
            expect(status.lit, freeze, reason: 'lit');
            expect(status.run, freeze ? 3 : 0, reason: 'run');
            expect(status.freezes, 0, reason: 'freezes');
            expect(save.coins, 150 + 50, reason: 'coins');
            expect(save.document.records.dailies, 4, reason: 'dailies');
            expect(save.document.records.longestRun, 3, reason: 'longestRun');

            // Friday's own daily still extends the run.
            final friday = service.progressAfterSolve(clock.today());
            expect(friday.streak, 4);
            expect(friday.run, freeze ? 4 : 1);
          });
        }
      }

      test('a daily of another date already solved changes nothing', () {
        solveToday(); // Mon
        final monday = clock.today();
        advanceDays(1);
        final before = save.document.daily;

        expect(service.progressAfterSolve(monday), before);
      });

      test('a gap with no freeze left pauses the tile, and a later solve '
          'relights it without losing the recorded longest run', () {
        for (var i = 0; i < 4; i++) {
          solveToday(); // Mon–Thu: the run reaches 4.
          advanceDays(1);
        }
        expect(service.refresh().run, 4);
        expect(save.document.records.longestRun, 4);

        advanceDays(5); // Five more days, no freeze left: paused.
        final paused = service.refresh();
        expect(paused.lit, isFalse);
        expect(paused.paused, isTrue);
        expect(paused.streak, 4);

        solveToday(); // Relit at run 1.
        final relit = service.refresh();
        expect(relit.lit, isTrue);
        expect(relit.run, 1);
        expect(relit.streak, 5);
        // The longest run ever recorded survives the pause: only
        // `SaveService.recordLevelWin` raises it, and never lowers it.
        expect(save.document.records.longestRun, 4);
      });
    });

    group('the past days (local habits 3)', () {
      InProgressLevel board(int date) => InProgressLevel(
        request: PlayRequest.pastDaily(date),
        levelId: 'L$date',
        levelVersion: 1,
        session: const {},
      );

      test('the window is empty while the Daily is locked, then opens with '
          'it, not from the install date', () {
        expect(service.refresh().window, isEmpty);
        save.currentLevel = 3;
        final status = service.refresh();
        expect(status.window, hasLength(7));
        expect(status.window.first, LocalDate(2026, 9, 14));
        expect(status.window.last, LocalDate(2026, 9, 20));
      });

      test('daily_archive_days resizes it, and 0 empties it', () {
        save.currentLevel = 3;
        remoteConfig.setOverride(RemoteConfigKeys.dailyArchiveDays, 2);
        expect(service.refresh().window, [
          LocalDate(2026, 9, 19),
          LocalDate(2026, 9, 20),
        ]);
        remoteConfig.setOverride(RemoteConfigKeys.dailyArchiveDays, 0);
        expect(service.refresh().window, isEmpty);
      });

      test('played and archiveInProgress come from the archive, and a '
          'refresh never touches the streak fields', () {
        save.currentLevel = 3;
        save.recordLevelWin(
          const LevelWinRecord(
            request: PlayRequest.pastDaily(20260919),
            rewardCoins: 0,
          ),
        );
        save.saveInProgress(board(20260918));
        service.refresh(); // the weekly freeze grant lands here, once
        final daily = save.document.daily;
        final status = service.refresh();
        expect(status.played, [LocalDate(2026, 9, 19)]);
        expect(status.archiveInProgress, LocalDate(2026, 9, 18));
        expect(save.document.daily, daily);
      });

      test('pruneArchive drops a board that left the window and '
          'republishes', () {
        save.currentLevel = 3;
        save.saveInProgress(board(20260901));
        expect(service.refresh().archiveInProgress, LocalDate(2026, 9, 1));
        final status = service.pruneArchive();
        expect(status.archiveInProgress, isNull);
        expect(save.document.dailyArchive.inProgress, isNull);

        save.saveInProgress(board(20260918));
        expect(
          service.pruneArchive().archiveInProgress,
          LocalDate(2026, 9, 18),
        );
      });
    });
  });
}
