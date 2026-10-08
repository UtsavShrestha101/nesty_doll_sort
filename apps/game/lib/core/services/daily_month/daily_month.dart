import 'package:flutter/foundation.dart';
import 'package:nesty_game/core/services/clock/local_date.dart';

/// How a day of the month grid looks (docs/plans/plan-local-habits.md,
/// "2. A month of played days"). Never a failure state: a day nobody played
/// is [notPlayed], with no mark of its own.
enum DayState {
  /// A Daily solved on the day itself (`daily.done`).
  solved,

  /// Played later from the archive (stage 3).
  playedLater,

  /// A freeze kept the flame lit that day (`daily.frozen`, Q191).
  frozen,

  /// Nothing recorded.
  notPlayed,

  /// After today.
  future,
}

/// One cell of the grid: out of the month ([isBlank]) or a day.
@immutable
final class MonthCell {
  const MonthCell.blank()
    : date = null,
      state = null,
      isToday = false,
      playable = false;

  const MonthCell.day(
    LocalDate this.date,
    DayState this.state, {
    this.isToday = false,
    this.playable = false,
  });

  final LocalDate? date;
  final DayState? state;
  final bool isToday;

  /// Stage 3: a past day inside the playable window.
  final bool playable;

  bool get isBlank => date == null;

  @override
  bool operator ==(Object other) =>
      other is MonthCell &&
      other.date == date &&
      other.state == state &&
      other.isToday == isToday &&
      other.playable == playable;

  @override
  int get hashCode => Object.hash(date, state, isToday, playable);

  @override
  String toString() => isBlank ? 'blank' : '$date $state';
}

/// The grid of today's month: rows of 7 from the week holding the 1st to the
/// week holding the last day (4-6 rows). Pure: the caller passes the dates.
@immutable
final class DailyMonth {
  const DailyMonth._(this.rows);

  /// [weekStart] is a [DateTime] weekday (`DateTime.monday` ...). [done],
  /// [frozen], [played] (stage 3) and [window] (stage 3's playable days)
  /// may hold dates of other months: only this month's are read.
  /// Precedence: solved, then played later, then frozen, then not played;
  /// any date after [today] is future.
  factory DailyMonth.of({
    required LocalDate today,
    required int weekStart,
    required Iterable<LocalDate> done,
    required Iterable<LocalDate> frozen,
    Iterable<LocalDate> played = const [],
    Iterable<LocalDate> window = const [],
  }) {
    final doneSet = done.toSet();
    final frozenSet = frozen.toSet();
    final playedSet = played.toSet();
    final windowSet = window.toSet();
    final first = LocalDate(today.year, today.month, 1);
    final days = LocalDate.daysInMonth(today.year, today.month);
    final lead = (first.weekday - weekStart + 7) % 7;
    final rowCount = (lead + days + 6) ~/ 7;
    final rows = <List<MonthCell>>[];
    for (var row = 0; row < rowCount; row++) {
      final cells = <MonthCell>[];
      for (var col = 0; col < 7; col++) {
        final day = row * 7 + col - lead + 1;
        if (day < 1 || day > days) {
          cells.add(const MonthCell.blank());
          continue;
        }
        final date = LocalDate(today.year, today.month, day);
        final DayState state;
        if (date.epochDay > today.epochDay) {
          state = DayState.future;
        } else if (doneSet.contains(date)) {
          state = DayState.solved;
        } else if (playedSet.contains(date)) {
          state = DayState.playedLater;
        } else if (frozenSet.contains(date)) {
          state = DayState.frozen;
        } else {
          state = DayState.notPlayed;
        }
        cells.add(
          MonthCell.day(
            date,
            state,
            isToday: date == today,
            playable:
                windowSet.contains(date) &&
                (state == DayState.notPlayed || state == DayState.frozen),
          ),
        );
      }
      rows.add(List.unmodifiable(cells));
    }
    return DailyMonth._(List.unmodifiable(rows));
  }

  final List<List<MonthCell>> rows;
}
