import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_game/core/services/clock/local_date.dart';
import 'package:nesty_game/core/services/daily_month/daily_month.dart';

void main() {
  DailyMonth month(
    LocalDate today, {
    int weekStart = DateTime.monday,
    List<LocalDate> done = const [],
    List<LocalDate> frozen = const [],
  }) => DailyMonth.of(
    today: today,
    weekStart: weekStart,
    done: done,
    frozen: frozen,
  );

  Iterable<MonthCell> days(DailyMonth m) =>
      m.rows.expand((r) => r).where((c) => !c.isBlank);

  test('every row has 7 cells and the days run 1..N once', () {
    final m = month(LocalDate(2026, 10, 8));
    expect(m.rows.every((r) => r.length == 7), isTrue);
    expect(days(m).map((c) => c.date!.day), [for (var d = 1; d <= 31; d++) d]);
  });

  test('October 2026 (1st is a Thursday) on a Monday start: 5 rows', () {
    final m = month(LocalDate(2026, 10, 31));
    expect(m.rows, hasLength(5));
    expect(m.rows.first.take(3).every((c) => c.isBlank), isTrue);
    expect(m.rows.first[3].date, LocalDate(2026, 10, 1));
    expect(m.rows.last[5].date, LocalDate(2026, 10, 31));
    expect(m.rows.last[6].isBlank, isTrue);
  });

  test('a Sunday start moves the 1st one column', () {
    final m = month(LocalDate(2026, 10, 8), weekStart: DateTime.sunday);
    expect(m.rows.first[4].date, LocalDate(2026, 10, 1));
    expect(m.rows.first.take(4).every((c) => c.isBlank), isTrue);
  });

  test('February 2028 (leap) has 29 days', () {
    final m = month(LocalDate(2028, 2, 29));
    expect(days(m), hasLength(29));
    expect(days(m).last.date, LocalDate(2028, 2, 29));
  });

  test('a month starting on the week start needs no leading blanks', () {
    // 2026-06-01 is a Monday; 30 days -> 5 rows.
    final m = month(LocalDate(2026, 6, 10));
    expect(m.rows.first.first.date, LocalDate(2026, 6, 1));
    expect(m.rows, hasLength(5));
    // February 2027 starts on a Monday with 28 days: exactly 4 rows.
    expect(month(LocalDate(2027, 2, 3)).rows, hasLength(4));
  });

  test('a month that needs 6 rows', () {
    // 2026-08-01 is a Saturday: Sunday start -> 6 + 31 = 37 cells -> 6 rows.
    final m = month(LocalDate(2026, 8, 15), weekStart: DateTime.sunday);
    expect(m.rows, hasLength(6));
  });

  test('states: solved beats frozen, future after today, one today', () {
    final today = LocalDate(2026, 10, 8);
    final m = month(
      today,
      done: [LocalDate(2026, 10, 7), LocalDate(2026, 10, 8)],
      frozen: [LocalDate(2026, 10, 7), LocalDate(2026, 10, 5)],
    );
    DayState at(int d) => days(m).firstWhere((c) => c.date!.day == d).state!;
    expect(at(7), DayState.solved);
    expect(at(5), DayState.frozen);
    expect(at(6), DayState.notPlayed);
    expect(at(8), DayState.solved);
    expect(at(9), DayState.future);
    expect(days(m).where((c) => c.isToday), hasLength(1));
    expect(days(m).firstWhere((c) => c.isToday).date, today);
  });

  test('a solved date after today is still future', () {
    final m = month(LocalDate(2026, 10, 8), done: [LocalDate(2026, 10, 20)]);
    expect(days(m).firstWhere((c) => c.date!.day == 20).state, DayState.future);
  });

  test('dates outside the month are ignored', () {
    final m = month(
      LocalDate(2026, 10, 8),
      done: [LocalDate(2026, 9, 30), LocalDate(2026, 11, 1)],
      frozen: [LocalDate(2026, 9, 29)],
    );
    expect(days(m).where((c) => c.state == DayState.solved), isEmpty);
    expect(days(m).where((c) => c.state == DayState.frozen), isEmpty);
  });

  test('a Daily just unlocked: every past day is not played', () {
    final m = month(LocalDate(2026, 10, 8));
    final past = days(m).where((c) => c.date!.day <= 8);
    expect(past.every((c) => c.state == DayState.notPlayed), isTrue);
    expect(
      days(
        m,
      ).where((c) => c.date!.day > 8).every((c) => c.state == DayState.future),
      isTrue,
    );
  });

  test('the 1st of the month as today', () {
    final m = month(LocalDate(2026, 10, 1));
    expect(days(m).first.isToday, isTrue);
    expect(days(m).skip(1).every((c) => c.state == DayState.future), isTrue);
  });

  test('stage 3 inputs: played later and the playable window', () {
    final m = DailyMonth.of(
      today: LocalDate(2026, 10, 8),
      weekStart: DateTime.monday,
      done: [LocalDate(2026, 10, 7)],
      frozen: const [],
      played: [LocalDate(2026, 10, 6)],
      window: [LocalDate(2026, 10, 6), LocalDate(2026, 10, 5)],
    );
    MonthCell at(int d) => days(m).firstWhere((c) => c.date!.day == d);
    expect(at(6).state, DayState.playedLater);
    expect(at(6).playable, isFalse);
    expect(at(5).playable, isTrue);
    expect(at(7).playable, isFalse);
  });
}
