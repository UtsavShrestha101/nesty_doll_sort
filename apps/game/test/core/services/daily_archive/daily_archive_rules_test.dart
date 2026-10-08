import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_game/core/models/play_request.dart';
import 'package:nesty_game/core/services/clock/local_date.dart';
import 'package:nesty_game/core/services/daily_archive/daily_archive_rules.dart';
import 'package:nesty_game/core/services/remote_config/fake_remote_config_service.dart';
import 'package:nesty_game/core/services/remote_config/remote_config_keys.dart';
import 'package:nesty_game/core/services/save/save_document.dart';

InProgressLevel _board(int date) => InProgressLevel(
  request: PlayRequest.pastDaily(date),
  levelId: 'L$date',
  levelVersion: 1,
  session: const {},
);

void main() {
  group('window', () {
    test('is today - days ... today - 1, oldest first', () {
      expect(DailyArchiveRules.window(LocalDate(2026, 10, 8), 3), [
        LocalDate(2026, 10, 5),
        LocalDate(2026, 10, 6),
        LocalDate(2026, 10, 7),
      ]);
    });

    test('crosses a month start and a year start', () {
      final month = DailyArchiveRules.window(LocalDate(2026, 10, 3), 7);
      expect(month.first, LocalDate(2026, 9, 26));
      expect(month.last, LocalDate(2026, 10, 2));
      final year = DailyArchiveRules.window(LocalDate(2027, 1, 2), 7);
      expect(year.first, LocalDate(2026, 12, 26));
      expect(year.last, LocalDate(2027, 1, 1));
    });

    test('0 is empty, 7 and 28 are full, more is clamped to 28', () {
      final today = LocalDate(2026, 10, 8);
      expect(DailyArchiveRules.window(today, 0), isEmpty);
      expect(DailyArchiveRules.window(today, 7), hasLength(7));
      expect(DailyArchiveRules.window(today, 28), hasLength(28));
      expect(DailyArchiveRules.window(today, 400), hasLength(28));
      expect(DailyArchiveRules.window(today, -3), isEmpty);
    });
  });

  group('days from Remote Config', () {
    test('default 7, clamped 0-28, a wrong type reads as 7', () {
      final config = FakeRemoteConfigService();
      expect(DailyArchiveRules.daysOf(config), 7);
      config.setOverride(RemoteConfigKeys.dailyArchiveDays, 100);
      expect(DailyArchiveRules.daysOf(config), 28);
      config.setOverride(RemoteConfigKeys.dailyArchiveDays, -4);
      expect(DailyArchiveRules.daysOf(config), 0);
      config.setOverride(RemoteConfigKeys.dailyArchiveDays, 0);
      expect(DailyArchiveRules.daysOf(config), 0);
      config.setOverride(RemoteConfigKeys.dailyArchiveDays, 28);
      expect(DailyArchiveRules.daysOf(config), 28);
      // A wrong-typed override is ignored: the default reads.
      config.clearOverrides();
      expect(DailyArchiveRules.daysOf(config), 7);
    });
  });

  group('isPlayable', () {
    final today = LocalDate(2026, 10, 8);
    bool playable(LocalDate d, {bool unlocked = true, int days = 7}) =>
        DailyArchiveRules.isPlayable(d, today, unlocked: unlocked, days: days);

    test('inside the window only', () {
      expect(playable(today.addDays(-1)), isTrue);
      expect(playable(today.addDays(-7)), isTrue);
      expect(playable(today.addDays(-8)), isFalse);
      expect(playable(today), isFalse);
      expect(playable(today.addDays(1)), isFalse);
    });

    test('never while locked or switched off', () {
      expect(playable(today.addDays(-1), unlocked: false), isFalse);
      expect(playable(today.addDays(-1), days: 0), isFalse);
    });
  });

  group('prune', () {
    final today = LocalDate(2026, 10, 8);

    test('drops a board whose date left the window, keeps one inside', () {
      final inside = DailyArchive(inProgress: _board(20261001));
      expect(DailyArchiveRules.prune(inside, today, 7), inside);
      final out = DailyArchive(
        played: [LocalDate(2026, 9, 1)],
        inProgress: _board(20260930),
      );
      final pruned = DailyArchiveRules.prune(out, today, 7);
      expect(pruned.inProgress, isNull);
      expect(pruned.played, out.played, reason: 'played is a record');
    });

    test('drops a board of today, the future or a bad date; 0 drops all', () {
      for (final date in [20261008, 20261009, 20260230]) {
        expect(
          DailyArchiveRules.prune(
            DailyArchive(inProgress: _board(date)),
            today,
            7,
          ).inProgress,
          isNull,
          reason: '$date',
        );
      }
      expect(
        DailyArchiveRules.prune(
          DailyArchive(inProgress: _board(20261007)),
          today,
          0,
        ).inProgress,
        isNull,
      );
    });

    test('is a no-op without a board', () {
      const empty = DailyArchive();
      expect(DailyArchiveRules.prune(empty, today, 7), same(empty));
    });
  });
}
