import 'package:flutter/foundation.dart';

/// A calendar date with no time or zone: the player's local day (spec
/// §7.5 "one puzzle per day"; docs/plans/m3-design.md §8). The save stores
/// it as `yyyy-mm-dd` (§13.3 `daily.lastDate`), the daily seed as
/// `yyyymmdd`.
///
/// Day arithmetic is integer-only (days from the civil calendar, Hinnant's
/// algorithm), so it never depends on a platform's time zone rules or
/// daylight-saving jumps.
@immutable
final class LocalDate implements Comparable<LocalDate> {
  /// Throws an [ArgumentError] for a date that doesn't exist (years
  /// 1–9999).
  LocalDate(this.year, this.month, this.day) {
    if (!isValid(year, month, day)) {
      throw ArgumentError('$year-$month-$day is not a date');
    }
  }

  /// The local calendar date of [time].
  factory LocalDate.fromDateTime(DateTime time) =>
      LocalDate(time.year, time.month, time.day);

  /// The date of a `yyyymmdd` integer such as 20260926 (the daily seed,
  /// `DifficultyCurve.dailySeed`). Throws an [ArgumentError] for a value
  /// that is not a date.
  factory LocalDate.fromYyyymmdd(int yyyymmdd) =>
      LocalDate(yyyymmdd ~/ 10000, yyyymmdd ~/ 100 % 100, yyyymmdd % 100);

  /// The date [epochDay] days after 1970-01-01 (negative before).
  factory LocalDate.fromEpochDay(int epochDay) {
    final z = epochDay + 719468;
    final era = (z >= 0 ? z : z - 146096) ~/ 146097;
    final doe = z - era * 146097;
    final yoe = (doe - doe ~/ 1460 + doe ~/ 36524 - doe ~/ 146096) ~/ 365;
    final doy = doe - (365 * yoe + yoe ~/ 4 - yoe ~/ 100);
    final mp = (5 * doy + 2) ~/ 153;
    final day = doy - (153 * mp + 2) ~/ 5 + 1;
    final month = mp < 10 ? mp + 3 : mp - 9;
    final year = yoe + era * 400 + (month <= 2 ? 1 : 0);
    return LocalDate(year, month, day);
  }

  /// `yyyy-mm-dd` (the save's format), or null for anything else: another
  /// shape, a date that doesn't exist, a value that is not a string. The
  /// save reads leniently (m3-design §3.3).
  static LocalDate? tryParse(Object? value) {
    if (value is! String || value.length != 10) return null;
    final match = _iso.firstMatch(value);
    if (match == null) return null;
    final year = int.parse(match.group(1)!);
    final month = int.parse(match.group(2)!);
    final day = int.parse(match.group(3)!);
    return isValid(year, month, day) ? LocalDate(year, month, day) : null;
  }

  static final RegExp _iso = RegExp(r'^(\d{4})-(\d{2})-(\d{2})$');

  /// True when [year]-[month]-[day] is a real date of years 1–9999.
  static bool isValid(int year, int month, int day) {
    if (year < 1 || year > 9999 || month < 1 || month > 12 || day < 1) {
      return false;
    }
    return day <= daysInMonth(year, month);
  }

  /// Days in [month] of [year] (proleptic Gregorian).
  static int daysInMonth(int year, int month) {
    if (month == 2) {
      final leap = year % 4 == 0 && (year % 100 != 0 || year % 400 == 0);
      return leap ? 29 : 28;
    }
    return const [31, 0, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31][month - 1];
  }

  final int year;
  final int month;
  final int day;

  /// Days since 1970-01-01.
  int get epochDay {
    final y = month <= 2 ? year - 1 : year;
    final era = (y >= 0 ? y : y - 399) ~/ 400;
    final yoe = y - era * 400;
    final doy = (153 * (month + (month > 2 ? -3 : 9)) + 2) ~/ 5 + day - 1;
    final doe = yoe * 365 + yoe ~/ 4 - yoe ~/ 100 + doy;
    return era * 146097 + doe - 719468;
  }

  /// The daily seed form, e.g. 20260926 (spec §7.5).
  int get yyyymmdd => year * 10000 + month * 100 + day;

  /// The save's form, `yyyy-mm-dd` (spec §13.3).
  String toIso() =>
      '${year.toString().padLeft(4, '0')}-'
      '${month.toString().padLeft(2, '0')}-'
      '${day.toString().padLeft(2, '0')}';

  /// [days] later (earlier when negative).
  LocalDate addDays(int days) => LocalDate.fromEpochDay(epochDay + days);

  /// Days from this date to [other]: 1 when [other] is the next day.
  int daysUntil(LocalDate other) => other.epochDay - epochDay;

  /// ISO weekday: 1 = Monday … 7 = Sunday.
  int get weekday => (epochDay + 3) % 7 + 1;

  /// The ISO 8601 week this date is in, as `isoYear × 100 + week` (e.g.
  /// 202639 for 2026-09-26). Weeks start on Monday; week 1 holds the
  /// year's first Thursday. The daily's weekly streak freeze is granted
  /// once per value (m3-design §8.2).
  int get isoWeekKey {
    final thursday = addDays(4 - weekday);
    final jan1 = LocalDate(thursday.year, 1, 1);
    final week = jan1.daysUntil(thursday) ~/ 7 + 1;
    return thursday.year * 100 + week;
  }

  /// Local midnight at the start of this date.
  DateTime get startOfDay => DateTime(year, month, day);

  bool operator <(LocalDate other) => epochDay < other.epochDay;
  bool operator <=(LocalDate other) => epochDay <= other.epochDay;
  bool operator >(LocalDate other) => epochDay > other.epochDay;
  bool operator >=(LocalDate other) => epochDay >= other.epochDay;

  @override
  int compareTo(LocalDate other) => epochDay.compareTo(other.epochDay);

  @override
  bool operator ==(Object other) =>
      other is LocalDate &&
      other.year == year &&
      other.month == month &&
      other.day == day;

  @override
  int get hashCode => Object.hash(year, month, day);

  @override
  String toString() => toIso();
}
