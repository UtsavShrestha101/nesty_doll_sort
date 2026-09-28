import 'package:nesty_game/core/models/play_request.dart';
import 'package:nesty_game/core/services/clock/local_date.dart';
import 'package:nesty_game/core/services/daily/daily_status.dart';
import 'package:nesty_game/core/services/save/save_document.dart';

/// The daily puzzle's streak, freezes and chest (spec §7.5; frames
/// 5.1–5.6; docs/plans/m3-design.md §8), over `SaveService` and the
/// injected `AppClock`. The rules (§8.2's algorithm and worked table) live
/// here, not in the screens or the bloc.
///
/// `StreakDailyService` (the services lane) is the implementation for both
/// environments (it composes the save and the clock, which the fake env
/// fakes); `FakeDailyService` scripts a [DailyStatus] for unit tests.
abstract interface class DailyService {
  /// Level 2 has been won (`SaveService.highestLevel >= 3`, m3-design
  /// §8.3).
  bool get isUnlocked;

  /// Reconciles the streak with today (missed days, freezes, the weekly
  /// grant), writes the result if it changed, and returns what to show.
  /// Idempotent within a day. Home and the Daily screen call it on open.
  DailyStatus refresh();

  /// The status of the last [refresh] (refreshing first when there was
  /// none).
  DailyStatus get status;

  /// Fires after every change of [status].
  Stream<DailyStatus> get changes;

  /// Today's puzzle: `PlayRequest.daily(today.yyyymmdd)`.
  PlayRequest get todayRequest;

  /// The save's `daily` after solving [date]'s puzzle (pure: nothing is
  /// written). The bloc hands it to `SaveService.recordLevelWin`, so the
  /// coins, the streak and the cleared board are one update. Only today's
  /// date counts toward the streak; an older date changes nothing but
  /// `done`.
  DailyProgress progressAfterSolve(LocalDate date);

  /// Collects the pending day-7 chest (frame 5.6): adds `streak7_reward`
  /// and clears it in one update. Returns the coins added, 0 when none was
  /// pending. ("Double it" is M6.)
  int collectChest();

  /// The "Streak saved!" banner was shown (frame 5.2).
  void acknowledgeFreezeNotice();

  /// Until the next local midnight (frame 5.5 "Next puzzle in 14h 12m").
  Duration untilNextPuzzle();

  /// Closes [changes] (DI reset).
  void dispose();
}
