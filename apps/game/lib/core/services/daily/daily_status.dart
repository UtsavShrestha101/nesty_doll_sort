import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:nesty_core/nesty_core.dart';
import 'package:nesty_game/core/services/clock/local_date.dart';
import 'package:nesty_game/core/services/save/save_document.dart';

part 'daily_status.freezed.dart';

/// What the Daily screen (frames 5.1–5.6) and Home's Daily tile show,
/// after `DailyService.refresh` reconciled the streak with today
/// (docs/plans/m3-design.md §8).
@freezed
abstract class DailyStatus with _$DailyStatus {
  const factory DailyStatus({
    /// The player's local date (`AppClock.today`).
    required LocalDate today,

    /// Today's puzzle tier: `DifficultyCurve.dailyTier` (frame 5.1 "Hard").
    required Tier tier,

    /// Today's puzzle colors: `DifficultyCurve.dailyParams(today).colors`
    /// (frame 5.1 "5 colors").
    required int colors,

    /// Level 2 won (m3-design §8.3); a locked tile otherwise.
    @Default(false) bool unlocked,

    /// The gentle streak (spec-prop §7.5, m7-design §8): the days solved,
    /// never lowered (frame 5.1 "4 days").
    @Default(0) int streak,

    /// The flame is lit (`DailyProgress.lit`): false before the first solve
    /// and while [paused].
    @Default(false) bool lit,

    /// The current unbroken run (`DailyProgress.run`); 0 while not [lit].
    @Default(0) int run,

    /// Freezes held, 0 or 1 (frame 5.1 "1 freeze", 5.2 "0 left").
    @Default(0) int freezes,

    /// Today's puzzle is solved (frames 5.4, 5.5).
    @Default(false) bool solvedToday,

    /// Streak days of the current 7-day cycle already done, 0–7: the strip
    /// checks days 1..cycleDone, raises day cycleDone + 1 as "Today" (not
    /// solved yet) or labels it "Tmrw" (solved), and day 7 is the chest
    /// (m3-design §8.4).
    @Default(0) int cycleDone,

    /// A 7th streak day was solved and its chest is still to collect
    /// (frame 5.6).
    @Default(false) bool chestPending,

    /// A day a freeze covered that the player hasn't been told about: the
    /// "Streak saved!" banner (frame 5.2) names its weekday until
    /// `DailyService.acknowledgeFreezeNotice`.
    LocalDate? freezeNotice,

    /// Today's board is saved mid-way: Play continues it.
    @Default(false) bool inProgress,

    /// Today's solve (`DailyProgress.lastSolve` when its date is today):
    /// the Share text's facts (E3) and the reminder offer's default hour
    /// (E4, Q81; m7-design P3.8). Null before today's solve, and for a day
    /// an older build solved (no Share then).
    DailySolve? solve,

    /// Days solved on their own date, oldest first (`DailyProgress.done`,
    /// at most `DailyProgress.maxDates`): the month of played days lights
    /// them (local habits 2, plan-local-habits §2).
    @Default(<LocalDate>[]) List<LocalDate> done,

    /// Days a freeze covered, oldest first (`DailyProgress.frozen`): the
    /// month's frost mark (Q191) and welcome back's "a freeze kept your
    /// flame" line (plan-local-habits §1).
    @Default(<LocalDate>[]) List<LocalDate> frozen,
  }) = _DailyStatus;

  const DailyStatus._();

  /// Days to the chest counting today (frame 5.1 "3 days to go, counting
  /// today") while unsolved, or after today (5.5 "2 days to go").
  int get daysToChest => 7 - cycleDone;

  /// The flame is out with days already counted (spec-prop §7.5 "paused"):
  /// the Daily tile and the streak card show their resting look, and the
  /// next solve relights it (m7-design §8, §15.7).
  bool get paused => !lit && streak > 0;
}
