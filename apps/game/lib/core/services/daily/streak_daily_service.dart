import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:nesty_core/nesty_core.dart';
import 'package:nesty_game/core/dependency_injection/app_env.dart';
import 'package:nesty_game/core/models/play_request.dart';
import 'package:nesty_game/core/services/clock/app_clock.dart';
import 'package:nesty_game/core/services/clock/local_date.dart';
import 'package:nesty_game/core/services/daily/daily_service.dart';
import 'package:nesty_game/core/services/daily/daily_status.dart';
import 'package:nesty_game/core/services/remote_config/remote_config_keys.dart';
import 'package:nesty_game/core/services/remote_config/remote_config_service.dart';
import 'package:nesty_game/core/services/save/save_document.dart';
import 'package:nesty_game/core/services/save/save_service.dart';

/// The daily puzzle's streak (spec §7.5; docs/plans/m3-design.md §8): the
/// worked table's algorithm over `SaveService.document.daily` and the
/// injected [AppClock], for both environments (the fake env fakes the save
/// and the clock, not this class).
///
/// [refresh] reconciles missed days and the weekly freeze grant against
/// today, idempotently within a day; [progressAfterSolve] is the pure
/// function `GameplayBloc` hands to `SaveService.recordLevelWin` for a
/// daily win, so the coins, the streak and the cleared board are one save
/// update.
@LazySingleton(as: DailyService, env: [AppEnv.real, AppEnv.fake])
class StreakDailyService implements DailyService {
  StreakDailyService(this._save, this._clock, this._remoteConfig);

  /// `SaveService.highestLevel` at which the daily unlocks: Level 2 won
  /// (m3-design §8.3).
  static const int unlockAtHighestLevel = 3;

  final SaveService _save;
  final AppClock _clock;
  final RemoteConfigService _remoteConfig;

  final StreamController<DailyStatus> _changes = StreamController.broadcast();
  DailyStatus? _status;

  @override
  bool get isUnlocked => _save.highestLevel >= unlockAtHighestLevel;

  @override
  DailyStatus get status => _status ?? refresh();

  @override
  DailyStatus refresh() {
    final today = _clock.today();
    final before = _save.document.daily;
    final after = _reconcile(before, today);
    if (after != before) _save.writeDaily(after);
    return _publish(after, today);
  }

  @override
  Stream<DailyStatus> get changes => _changes.stream;

  @override
  PlayRequest get todayRequest => PlayRequest.daily(_clock.today().yyyymmdd);

  @override
  DailyProgress progressAfterSolve(LocalDate date) =>
      _solveOn(_save.document.daily, date, _clock.today());

  @override
  int collectChest() {
    final current = _save.document.daily;
    if (!current.chestPending) return 0;
    final coins = _remoteConfig.value(RemoteConfigKeys.streak7Reward);
    final updated = current.copyWith(chestPending: false);
    _save.writeDaily(updated, addCoins: coins);
    _publish(updated, _clock.today());
    return coins;
  }

  @override
  void acknowledgeFreezeNotice() {
    final current = _save.document.daily;
    final shown = _freezeNotice(current);
    if (shown == null) return;
    final updated = current.copyWith(noticeDate: shown);
    _save.writeDaily(updated);
    _publish(updated, _clock.today());
  }

  @override
  Duration untilNextPuzzle() {
    final now = _clock.now();
    return _clock.today().addDays(1).startOfDay.difference(now);
  }

  @override
  @disposeMethod
  void dispose() => unawaited(_changes.close());

  DailyStatus _publish(DailyProgress daily, LocalDate today) {
    final solvedToday = daily.done.contains(today);
    final status = DailyStatus(
      today: today,
      tier: DifficultyCurve.dailyTier(today.yyyymmdd),
      colors: DifficultyCurve.dailyParams(today.yyyymmdd).colors,
      unlocked: isUnlocked,
      streak: daily.streak,
      lit: daily.lit,
      run: daily.run,
      freezes: daily.freezes,
      solvedToday: solvedToday,
      cycleDone: solvedToday
          ? (daily.streak - 1) % _cycleLength + 1
          : daily.streak % _cycleLength,
      chestPending: daily.chestPending,
      freezeNotice: _freezeNotice(daily),
      inProgress: daily.inProgress != null,
      solve: daily.lastSolve?.date == today ? daily.lastSolve : null,
    );
    // Only a real change fires: Home re-reads the status (refresh) on every
    // change, so an unchanged one firing again would loop forever.
    final changed = status != _status;
    _status = status;
    if (changed && !_changes.isClosed) _changes.add(status);
    return status;
  }

  static const int _cycleLength = 7;

  static LocalDate? _freezeNotice(DailyProgress daily) {
    if (daily.frozen.isEmpty) return null;
    final latest = daily.frozen.last;
    final notice = daily.noticeDate;
    return notice == null || latest > notice ? latest : null;
  }

  // --- The §8.2 algorithm: pure functions over the model, unit-tested
  // directly through the @visibleForTesting wrappers below. ---

  /// Grants a weekly freeze for [day]'s ISO week, once (m3-design §8.2
  /// `grant`).
  static DailyProgress _grant(DailyProgress daily, LocalDate day) {
    final week = day.isoWeekKey;
    if (daily.freezeWeek == week) return daily;
    return daily.copyWith(
      freezes: math.min(DailyProgress.maxFreezes, daily.freezes + 1),
      freezeWeek: week,
    );
  }

  /// Covers missed days between `daily.lastDate` and [today] with freezes
  /// while they last, pausing the flame on the first uncovered day, then
  /// grants today's week (m7-design §8 `reconcile`). The gentle streak
  /// (`daily.streak`) is never lowered here, whatever happens to the run:
  /// a pause only clears [DailyProgress.lit], [DailyProgress.run] and
  /// [DailyProgress.lastDate]. Idempotent when there is nothing to
  /// reconcile.
  ///
  /// When the clock went back ([today] before `lastDate`), nothing is
  /// reconciled and nothing is granted: that week is behind the save
  /// already, and granting it would let a clock rolled back and forth mint
  /// a freeze per round trip past the once-per-ISO-week cap (m3-design
  /// §8.2; M7 review R2). A freeze can't cover anything until today passes
  /// `lastDate` again, so skipping the grant costs an honest player
  /// nothing. `refresh` and `_solve` both reach this guard.
  static DailyProgress _reconcile(DailyProgress daily, LocalDate today) {
    var d = daily;
    final last = d.lastDate;
    if (last != null && last > today) return d;
    if (last != null && last < today) {
      var day = last.addDays(1);
      final end = today.addDays(-1);
      while (day <= end) {
        d = _grant(d, day);
        if (d.freezes > 0) {
          d = d.copyWith(
            freezes: d.freezes - 1,
            frozen: _appendDate(d.frozen, day),
            lastDate: day,
          );
        } else {
          // An uncovered miss pauses the flame; the streak count itself
          // is never lowered (spec-prop §7.5, m7-design §8: "gentle").
          d = d.copyWith(lit: false, run: 0, lastDate: null);
          break;
        }
        day = day.addDays(1);
      }
    }
    return _grant(d, today);
  }

  /// [daily] after solving [date]'s puzzle (m7-design §8 `solve`): pure,
  /// nothing is written. `streak` (the days ever solved) always grows by
  /// one; `run` (the unbroken run) restarts at 1 when [date] doesn't
  /// continue the last one (a fresh streak, or a relight after a pause).
  static DailyProgress _solve(DailyProgress daily, LocalDate date) {
    var d = _reconcile(daily, date);
    if (d.done.contains(date)) return d;
    final last = d.lastDate;
    if (last != null && last > date) {
      // The clock went back: pays and records, but doesn't touch the
      // streak, the run or the freeze (m7-design §8; `_reconcile` granted
      // nothing either, M7 review R2).
      return d.copyWith(done: _appendDate(d.done, date));
    }
    final run = last == date.addDays(-1) ? d.run + 1 : 1;
    final streak = d.streak + 1;
    d = d.copyWith(
      streak: streak,
      lit: true,
      run: run,
      lastDate: date,
      done: _appendDate(d.done, date),
    );
    if (streak % _cycleLength == 0) d = d.copyWith(chestPending: true);
    return d;
  }

  /// [daily] after solving [date]'s puzzle on [today] (`progressAfterSolve`).
  /// Only today's date counts toward the streak: a daily of another date,
  /// such as one started before midnight and won after it, pays its coins
  /// and adds to `done` only (m3-design §8.2, D76, Q70; m7-design §8; M7
  /// review R6). Nothing is reconciled against [today] here either, so a
  /// countdown `refresh` between midnight and the win gives the same end
  /// state as none.
  static DailyProgress _solveOn(
    DailyProgress daily,
    LocalDate date,
    LocalDate today,
  ) {
    if (date == today) return _solve(daily, date);
    if (daily.done.contains(date)) return daily;
    return daily.copyWith(done: _appendDate(daily.done, date));
  }

  static List<LocalDate> _appendDate(List<LocalDate> dates, LocalDate date) {
    if (dates.isNotEmpty && dates.last == date) return dates;
    final next = [...dates, date];
    return next.length <= DailyProgress.maxDates
        ? next
        : next.sublist(next.length - DailyProgress.maxDates);
  }

  /// The §8.2 `reconcile` function, exposed for the worked-table test.
  @visibleForTesting
  static DailyProgress reconcileForTest(DailyProgress daily, LocalDate today) =>
      _reconcile(daily, today);

  /// The §8.2 `solve` function, exposed for the worked-table test.
  @visibleForTesting
  static DailyProgress solveForTest(DailyProgress daily, LocalDate date) =>
      _solve(daily, date);
}
