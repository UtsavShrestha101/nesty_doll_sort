import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_game/core/services/clock/fake_clock.dart';
import 'package:nesty_game/core/services/clock/local_date.dart';
import 'package:nesty_game/core/services/daily/daily_projection.dart';
import 'package:nesty_game/core/services/daily/streak_daily_service.dart';
import 'package:nesty_game/core/services/remote_config/fake_remote_config_service.dart';
import 'package:nesty_game/core/services/save/fake_save_service.dart';
import 'package:nesty_game/core/services/save/save_document.dart';

/// `DailyService.projection` (plan-local-habits §4): the Daily's status on
/// each of the next dates if the player never solves again, equal to what
/// `refresh` shows when the app is opened on each of those days.
void main() {
  final today = LocalDate(2026, 10, 8);

  StreakDailyService serviceOver(DailyProgress daily, FakeClock clock) =>
      StreakDailyService(
        FakeSaveService(initial: SaveDocument(daily: daily, highestLevel: 5)),
        clock,
        FakeRemoteConfigService(),
      );

  /// A random but plausible save: a run that ended some days ago (or is
  /// today's), with or without a freeze, solved days behind it.
  DailyProgress seeded(Random random) {
    final streak = random.nextInt(4) == 0 ? 0 : 1 + random.nextInt(40);
    final gap = random.nextInt(6); // 0 = the last solve was today
    final last = today.addDays(-gap);
    final lit = streak > 0 && random.nextBool();
    final done = <LocalDate>[
      if (streak > 0)
        for (var i = min(streak, 5) - 1; i >= 0; i--) last.addDays(-i),
    ];
    return DailyProgress(
      streak: streak,
      lit: lit,
      run: lit ? 1 + random.nextInt(streak) : 0,
      lastDate: lit ? last : null,
      freezes: random.nextInt(2),
      freezeWeek: random.nextBool() ? today.isoWeekKey : null,
      done: done,
    );
  }

  group('DailyService.projection', () {
    test('equals refresh() walked day by day, for 40 seeded saves', () {
      for (var seed = 0; seed < 40; seed++) {
        final daily = seeded(Random(seed));
        final clock = FakeClock(now: DateTime(2026, 10, 8, 12));
        final projecting = serviceOver(daily, clock);
        final walking = serviceOver(daily, clock);

        final projected = projecting.projection(today, 8);
        expect(projected, hasLength(8));

        for (var i = 0; i < 8; i++) {
          clock.setDate(today.addDays(i));
          final status = walking.refresh();
          final day = projected[i];
          final reason = 'seed $seed, day $i';
          expect(day.date, today.addDays(i), reason: reason);
          expect(day.streak, status.streak, reason: reason);
          expect(day.lit, status.lit, reason: reason);
          expect(day.solved, status.solvedToday, reason: reason);
          expect(
            day.state,
            DailyDayProjection.stateOf(
              streak: status.streak,
              lit: status.lit,
              solved: status.solvedToday,
            ),
            reason: reason,
          );
        }
        projecting.dispose();
        walking.dispose();
      }
    });

    test('shows every state across the seeds', () {
      final states = <DailyDayState>{};
      for (var seed = 0; seed < 40; seed++) {
        final service = serviceOver(
          seeded(Random(seed)),
          FakeClock(now: DateTime(2026, 10, 8, 12)),
        );
        states.addAll(service.projection(today, 8).map((d) => d.state));
        service.dispose();
      }
      expect(states, containsAll(DailyDayState.values));
    });

    test('a streak with no solve rests after a miss, and keeps its number', () {
      final service = serviceOver(
        DailyProgress(
          streak: 4,
          lit: true,
          run: 4,
          lastDate: today.addDays(-1),
          freezeWeek: today.isoWeekKey,
          done: [today.addDays(-1)],
        ),
        FakeClock(now: DateTime(2026, 10, 8, 12)),
      );
      final days = service.projection(today, 4);
      expect(days.first.state, DailyDayState.ready);
      expect(days.last.state, DailyDayState.paused);
      expect(days.last.streak, 4);
      service.dispose();
    });

    test('is empty for no days and never writes', () {
      final save = FakeSaveService();
      final service = StreakDailyService(
        save,
        FakeClock(now: DateTime(2026, 10, 8, 12)),
        FakeRemoteConfigService(),
      );
      expect(service.projection(today, 0), isEmpty);
      expect(save.document.daily, const DailyProgress());
      service.dispose();
    });
  });
}
