import 'package:nesty_game/core/services/clock/local_date.dart';

/// The app's only source of "now" (CLAUDE.md rule 7 keeps the clock out of
/// nesty_core; docs/plans/m3-design.md §8.1): the daily puzzle's date, the
/// streak, the museum's "Collected · Sep 12", the countdown to the next
/// puzzle. Injected, so tests and the dev flavor can pick the date.
///
/// Implementations: `SystemClock` (real env; the dev flavor's debug builds
/// accept `--dart-define=NESTY_FAKE_DATE=yyyymmdd`) and `FakeClock` (fake
/// env, settable).
abstract interface class AppClock {
  /// The local wall-clock time.
  DateTime now();

  /// The player's local calendar date: the daily puzzle of "today" is
  /// `DifficultyCurve.dailyParams(today().yyyymmdd)` (spec §7.5).
  LocalDate today();
}
