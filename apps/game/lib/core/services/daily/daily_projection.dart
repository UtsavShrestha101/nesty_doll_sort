import 'package:flutter/foundation.dart';
import 'package:nesty_game/core/services/clock/local_date.dart';

/// How the Daily would look on a date if the player never solves again
/// (plan-local-habits §4; the home-screen widget's four looks).
enum DailyDayState {
  /// A lit or fresh flame with today's puzzle waiting: the flame is unlit.
  ready,

  /// The date's puzzle is solved: the flame is lit.
  solved,

  /// The streak is resting (`!lit && streak > 0`): the number is kept.
  paused,

  /// No streak yet: "Your first flame".
  zero,
}

/// One date of `DailyService.projection`: the streak reconciled to that date
/// (`DailyProgress` after the same reconcile `refresh` runs), never written.
@immutable
final class DailyDayProjection {
  const DailyDayProjection({
    required this.date,
    required this.streak,
    required this.lit,
    required this.solved,
    required this.state,
  });

  final LocalDate date;

  /// The gentle streak (`DailyProgress.streak`), never lowered.
  final int streak;

  final bool lit;

  /// [date]'s puzzle is in `DailyProgress.done`.
  final bool solved;

  final DailyDayState state;

  /// The state the Daily shows for these facts: solved first, then no streak
  /// yet, then a resting flame, else ready.
  static DailyDayState stateOf({
    required int streak,
    required bool lit,
    required bool solved,
  }) {
    if (solved) return DailyDayState.solved;
    if (streak == 0) return DailyDayState.zero;
    if (!lit) return DailyDayState.paused;
    return DailyDayState.ready;
  }

  @override
  bool operator ==(Object other) =>
      other is DailyDayProjection &&
      other.date == date &&
      other.streak == streak &&
      other.lit == lit &&
      other.solved == solved &&
      other.state == state;

  @override
  int get hashCode => Object.hash(date, streak, lit, solved, state);

  @override
  String toString() =>
      'DailyDayProjection($date, streak $streak, lit $lit, solved $solved, '
      '${state.name})';
}
