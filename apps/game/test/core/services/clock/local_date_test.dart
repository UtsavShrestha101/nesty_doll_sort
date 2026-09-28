import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_game/core/services/clock/local_date.dart';

/// The daily's calendar (spec §7.5; docs/plans/m3-design.md §8): integer
/// day arithmetic, ISO weeks for the weekly freeze, and the save's
/// `yyyy-mm-dd`.
void main() {
  test('round-trips epoch days, yyyymmdd and yyyy-mm-dd', () {
    final date = LocalDate(2026, 9, 26);
    expect(
      date.epochDay,
      DateTime.utc(2026, 9, 26).millisecondsSinceEpoch ~/
          Duration.millisecondsPerDay,
    );
    expect(LocalDate.fromEpochDay(date.epochDay), date);
    expect(date.yyyymmdd, 20260926);
    expect(LocalDate.fromYyyymmdd(20260926), date);
    expect(date.toIso(), '2026-09-26');
    expect(LocalDate.tryParse('2026-09-26'), date);
    for (var day = -719162; day <= 2932896; day += 997) {
      expect(LocalDate.fromEpochDay(day).epochDay, day);
    }
  });

  test('reads leniently: anything that is not a real date is null', () {
    for (final value in <Object?>[
      null,
      20260926,
      '2026-9-26',
      '2026-02-30',
      '2026-13-01',
      'yesterday',
    ]) {
      expect(LocalDate.tryParse(value), isNull, reason: '$value');
    }
    expect(() => LocalDate(2026, 2, 29), throwsArgumentError);
    expect(LocalDate(2028, 2, 29).addDays(1), LocalDate(2028, 3, 1));
  });

  test('weekdays and ISO weeks (Monday first; week 1 holds a Thursday)', () {
    expect(LocalDate(2026, 9, 26).weekday, DateTime.saturday);
    expect(LocalDate(2026, 9, 21).weekday, DateTime.monday);
    expect(LocalDate(2026, 9, 21).isoWeekKey, 202639);
    expect(LocalDate(2026, 9, 27).isoWeekKey, 202639);
    expect(LocalDate(2026, 9, 28).isoWeekKey, 202640);
    // Years whose first days belong to the previous year's last week.
    expect(LocalDate(2027, 1, 1).isoWeekKey, 202653); // 2026 has 53 weeks
    expect(LocalDate(2021, 1, 3).isoWeekKey, 202053);
    expect(LocalDate(2024, 12, 30).isoWeekKey, 202501);
  });

  test('orders and measures days', () {
    final a = LocalDate(2026, 9, 25);
    final b = LocalDate(2026, 9, 27);
    expect(a < b, isTrue);
    expect(a.daysUntil(b), 2);
    expect(a.compareTo(b), lessThan(0));
    expect(b.startOfDay, DateTime(2026, 9, 27));
  });
}
