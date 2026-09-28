import 'package:injectable/injectable.dart';
import 'package:nesty_game/core/dependency_injection/app_env.dart';
import 'package:nesty_game/core/services/clock/app_clock.dart';
import 'package:nesty_game/core/services/clock/local_date.dart';

/// A settable [AppClock] for tests and the fake env (docs/plans/m3-design.md
/// §8.1). It starts at [defaultNow], Saturday 2026-09-26 at noon: the date
/// of the design's daily frames (5.1 "Saturday's puzzle", 5.3 "Sep 26").
@LazySingleton(as: AppClock, env: [AppEnv.fake])
class FakeClock implements AppClock {
  FakeClock({@ignoreParam DateTime? now}) : _now = now ?? defaultNow;

  /// Where a new fake clock starts.
  static final DateTime defaultNow = DateTime(2026, 9, 26, 12);

  DateTime _now;

  @override
  DateTime now() => _now;

  @override
  LocalDate today() => LocalDate.fromDateTime(_now);

  /// Moves the clock to [now].
  void set(DateTime now) => _now = now;

  /// Moves the clock to noon of [date].
  void setDate(LocalDate date) =>
      _now = DateTime(date.year, date.month, date.day, 12);

  /// Moves the clock on by [by].
  void advance(Duration by) => _now = _now.add(by);
}
