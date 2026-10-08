import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_game/core/models/play_request.dart';
import 'package:nesty_game/core/services/clock/local_date.dart';
import 'package:nesty_game/core/services/remote_config/fake_remote_config_service.dart';
import 'package:nesty_game/core/services/save/fake_save_service.dart';
import 'package:nesty_game/core/services/save/in_memory_save_service.dart';
import 'package:nesty_game/core/services/save/save_document.dart';
import 'package:nesty_game/core/services/save/save_service.dart';

/// `recordLevelWin` for a past day (plan-local-habits §3, §7.5c), on both
/// in-memory services (Hive's save extends the same class): pays 0, moves no
/// `daily` field and no daily record, opens no chest, counts no ad, marks
/// the date played once, and counts `stats` and `records` as a replay does.
InProgressLevel _board(PlayRequest request) => InProgressLevel(
  request: request,
  levelId: 'L${request.number}',
  levelVersion: 1,
  session: const {'format': 1},
  level: const {'id': 'gen'},
);

/// A save mid-streak: paused flame, a freeze, done and frozen days, an
/// unpaid day-7 chest, today's board half played, coins and ad counters.
SaveDocument _seed() => SaveDocument(
  coins: 740,
  currentLevel: 40,
  highestLevel: 40,
  adCounters: const AdCounters(winsSinceInterstitial: 2, interstitialsShown: 3),
  records: const SaveRecords(dailies: 5, longestRun: 4),
  daily: DailyProgress(
    streak: 9,
    run: 0,
    freezes: 1,
    freezeWeek: 202641,
    lastDate: null,
    done: [LocalDate(2026, 10, 1), LocalDate(2026, 10, 2)],
    frozen: [LocalDate(2026, 10, 3)],
    noticeDate: LocalDate(2026, 10, 3),
    chestPending: true,
    inProgress: _board(const PlayRequest.daily(20261008)),
  ),
);

void _contract(String name, SaveService Function(SaveDocument seed) make) {
  group('$name: a past day\'s win', () {
    late SaveService save;
    setUp(() => save = make(_seed()));
    tearDown(() => save.dispose());

    LevelWinRecord win(int date, {int coins = 50, int moves = 12}) =>
        LevelWinRecord(
          request: PlayRequest.pastDaily(date),
          rewardCoins: coins,
          moves: moves,
          families: 3,
          dolls: 9,
          date: LocalDate(2026, 10, 8),
          // A hostile record: a streak the save must never take from here.
          daily: const DailyProgress(streak: 99, lit: true, run: 99),
          chest: const ChestGrant(
            source: ChestSource.campaign,
            number: 10,
            coins: 100,
            hints: 1,
          ),
          bestKey: 'L1@1',
          starsKey: 'L1',
          stars: 3,
        );

    test('pays 0 and changes no daily field, record, chest or ad count', () {
      final before = save.document;
      final outcome = save.recordLevelWin(win(20261005));
      final after = save.document;
      expect(after.coins, before.coins);
      expect(
        after.daily,
        before.daily,
        reason:
            'streak, lit, run, freezes, '
            'done, frozen, noticeDate, lastDate and today\'s board',
      );
      expect(after.records.dailies, before.records.dailies);
      expect(after.records.longestRun, before.records.longestRun);
      expect(after.daily.lastSolve, before.daily.lastSolve);
      expect(after.chests, before.chests);
      expect(after.inventory, before.inventory);
      expect(after.adCounters, before.adCounters);
      expect(after.levelBests, before.levelBests);
      expect(after.levelStars, before.levelStars);
      expect(after.currentLevel, before.currentLevel);
      expect(after.highestLevel, before.highestLevel);
      expect(outcome.chestPaid, isNull);
      expect(outcome.stars, isNull);
    });

    test('adds the date to played once; stats and records count as a '
        'replay does', () {
      final before = save.document;
      save.recordLevelWin(win(20261005));
      expect(save.document.dailyArchive.played, [LocalDate(2026, 10, 5)]);
      expect(save.document.stats.wins, before.stats.wins + 1);
      expect(save.document.stats.moves, before.stats.moves + 12);
      expect(save.document.records.families, before.records.families + 3);
      expect(save.document.records.dolls, before.records.dolls + 9);

      // A replay of the same date adds nothing to played, still counts.
      save.recordLevelWin(win(20261005, moves: 8));
      expect(save.document.dailyArchive.played, [LocalDate(2026, 10, 5)]);
      expect(save.document.stats.wins, before.stats.wins + 2);
      expect(save.document.coins, before.coins);

      save.recordLevelWin(win(20261004));
      expect(save.document.dailyArchive.played, [
        LocalDate(2026, 10, 5),
        LocalDate(2026, 10, 4),
      ]);
    });

    test('clears the past day\'s board and nothing else in progress', () {
      save.saveInProgress(_board(const PlayRequest.pastDaily(20261005)));
      save.saveInProgress(_board(const PlayRequest.campaign(40)));
      save.recordLevelWin(win(20261005));
      expect(save.document.dailyArchive.inProgress, isNull);
      expect(
        save.document.daily.inProgress?.request,
        const PlayRequest.daily(20261008),
      );
      expect(save.document.inProgress?.request, const PlayRequest.campaign(40));
    });

    test('today\'s board survives a past-day game, move for move', () {
      final today = save.document.daily.inProgress;
      save.saveInProgress(_board(const PlayRequest.pastDaily(20261005)));
      save.saveInProgress(_board(const PlayRequest.pastDaily(20261004)));
      expect(save.document.daily.inProgress, today);
      save.recordLevelWin(win(20261004));
      expect(save.document.daily.inProgress, today);
    });

    test('a second past day replaces the first board', () {
      save.saveInProgress(_board(const PlayRequest.pastDaily(20261005)));
      save.saveInProgress(_board(const PlayRequest.pastDaily(20261004)));
      expect(
        save.inProgressFor(PlayKind.pastDaily)?.request,
        const PlayRequest.pastDaily(20261004),
      );
      // Finishing the replaced one leaves the open one alone.
      save.recordLevelWin(win(20261005));
      expect(
        save.inProgressFor(PlayKind.pastDaily)?.request,
        const PlayRequest.pastDaily(20261004),
      );
    });

    test('played is trimmed to the newest maxDates', () {
      for (var i = 0; i < DailyProgress.maxDates + 3; i++) {
        final d = LocalDate(2026, 1, 1).addDays(i);
        save.recordLevelWin(win(d.yyyymmdd));
      }
      final played = save.document.dailyArchive.played;
      expect(played, hasLength(DailyProgress.maxDates));
      expect(
        played.last,
        LocalDate(2026, 1, 1).addDays(DailyProgress.maxDates + 2),
      );
    });

    test('the trim keeps the newest dates, not the latest played', () {
      final first = LocalDate(2026, 1, 1);
      // The newest maxDates days first, then an older day played last.
      for (var i = 1; i <= DailyProgress.maxDates; i++) {
        save.recordLevelWin(win(first.addDays(i).yyyymmdd));
      }
      save.recordLevelWin(win(first.yyyymmdd));
      final played = save.document.dailyArchive.played;
      expect(played, hasLength(DailyProgress.maxDates));
      expect(played, isNot(contains(first)));
      expect(played.first, first.addDays(1));
      expect(played.last, first.addDays(DailyProgress.maxDates));
    });

    test('pruneDailyArchive drops a board that left the window, keeps one '
        'inside it, and is quiet otherwise', () {
      var fired = 0;
      save.changes.listen((_) => fired++);
      final today = LocalDate(2026, 10, 8);
      save.pruneDailyArchive(today);
      expect(fired, 0);

      save.saveInProgress(_board(const PlayRequest.pastDaily(20261001)));
      save.pruneDailyArchive(today); // 7 days back: inside
      expect(save.document.dailyArchive.inProgress, isNotNull);

      save.pruneDailyArchive(today.addDays(1)); // 8 days back: out
      expect(save.document.dailyArchive.inProgress, isNull);
    });
  });
}

void main() {
  _contract('FakeSaveService', (seed) => FakeSaveService(initial: seed));
  _contract(
    'InMemorySaveService',
    (seed) => InMemorySaveService(FakeRemoteConfigService(), initial: seed),
  );
}
