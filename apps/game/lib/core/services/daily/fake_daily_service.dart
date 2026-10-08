import 'dart:async';

import 'package:injectable/injectable.dart';
import 'package:nesty_core/nesty_core.dart';
import 'package:nesty_game/core/models/play_request.dart';
import 'package:nesty_game/core/services/clock/app_clock.dart';
import 'package:nesty_game/core/services/clock/local_date.dart';
import 'package:nesty_game/core/services/daily/daily_service.dart';
import 'package:nesty_game/core/services/daily/daily_status.dart';
import 'package:nesty_game/core/services/save/save_document.dart';

/// A scriptable [DailyService] for unit tests: it shows [status] as set,
/// never reconciles, and counts what it was asked to do. The date comes
/// from [AppClock].
///
/// Not bound by DI: `StreakDailyService` (m3-design §8) serves both
/// environments; this class is a hand-scripted double for tests only.
class FakeDailyService implements DailyService {
  FakeDailyService(this._clock, {@ignoreParam DailyStatus? status})
    : _status = status;

  final AppClock _clock;
  DailyStatus? _status;
  final StreamController<DailyStatus> _changes = StreamController.broadcast();

  /// Chest coins [collectChest] pays while [status] has one pending.
  int chestCoins = 300;

  /// Calls of [acknowledgeFreezeNotice].
  int noticesAcknowledged = 0;

  /// Unlocked unless a test says otherwise.
  bool unlocked = true;

  @override
  bool get isUnlocked => unlocked;

  @override
  DailyStatus get status => _status ??= _defaultStatus();

  /// Replaces what [status] and [refresh] return.
  set status(DailyStatus status) {
    _status = status;
    if (!_changes.isClosed) _changes.add(status);
  }

  DailyStatus _defaultStatus() {
    final today = _clock.today();
    return DailyStatus(
      today: today,
      tier: DifficultyCurve.dailyTier(today.yyyymmdd),
      colors: DifficultyCurve.dailyParams(today.yyyymmdd).colors,
      unlocked: unlocked,
    );
  }

  @override
  DailyStatus refresh() => status;

  /// Calls of [pruneArchive].
  int archivePrunes = 0;

  @override
  DailyStatus pruneArchive() {
    archivePrunes++;
    return status;
  }

  @override
  Stream<DailyStatus> get changes => _changes.stream;

  @override
  PlayRequest get todayRequest => PlayRequest.daily(_clock.today().yyyymmdd);

  @override
  DailyProgress progressAfterSolve(LocalDate date) =>
      DailyProgress(streak: status.streak + 1, lastDate: date, done: [date]);

  @override
  int collectChest() {
    if (!status.chestPending) return 0;
    status = status.copyWith(chestPending: false);
    return chestCoins;
  }

  @override
  void acknowledgeFreezeNotice() {
    noticesAcknowledged++;
    status = status.copyWith(freezeNotice: null);
  }

  @override
  Duration untilNextPuzzle() {
    final now = _clock.now();
    return _clock.today().addDays(1).startOfDay.difference(now);
  }

  @override
  @disposeMethod
  void dispose() => unawaited(_changes.close());
}
