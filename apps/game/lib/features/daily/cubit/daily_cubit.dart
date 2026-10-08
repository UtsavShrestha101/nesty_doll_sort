import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:nesty_core/nesty_core.dart';
import 'package:nesty_game/core/base/base_async_cubit.dart';
import 'package:nesty_game/core/base/base_async_state.dart';
import 'package:nesty_game/core/models/play_request.dart';
import 'package:nesty_game/core/repository/level_resolver.dart';
import 'package:nesty_game/core/services/clock/local_date.dart';
import 'package:nesty_game/core/services/daily/daily_service.dart';
import 'package:nesty_game/core/services/daily/daily_status.dart';
import 'package:nesty_game/core/services/daily_month/daily_month.dart';
import 'package:nesty_game/core/services/remote_config/remote_config_keys.dart';
import 'package:nesty_game/core/services/remote_config/remote_config_service.dart';
import 'package:nesty_game/core/services/save/save_service.dart';

part 'daily_cubit.freezed.dart';
part 'daily_state.dart';

/// The Daily screen (spec §7.5, frames 5.1–5.6; docs/plans/m3-design.md
/// §10.5, §8): [DailyService.refresh] for the streak, [LevelResolver] to
/// prefetch today's board and read its preview colours, [SaveService] for
/// the header's coin pill, [RemoteConfigService] for the reward and chest
/// amounts. (Share lives on the daily win card, frame 10.1, D188, and goes
/// through `ShareService` there; this cubit has none, D207.)
///
/// The Daily board itself is the gameplay page; this cubit only feeds the
/// menu around it. [collectChest] and [acknowledgeFreezeNotice] are the
/// only writes here.
@injectable
class DailyCubit extends BaseAsyncCubit<DailyState> {
  DailyCubit(
    this._daily,
    this._resolver,
    this._save,
    this._remoteConfig, {
    @ignoreParam
    @visibleForTesting
    Duration countdownInterval = const Duration(minutes: 1),
  }) : _countdownInterval = countdownInterval {
    _dailyChanges = _daily.changes.listen(_onStatusChanged);
    _saveChanges = _save.changes.listen((_) => _onCoinsChanged());
  }

  final DailyService _daily;
  final LevelResolver _resolver;
  final SaveService _save;
  final RemoteConfigService _remoteConfig;
  final Duration _countdownInterval;
  late final StreamSubscription<DailyStatus> _dailyChanges;
  late final StreamSubscription<void> _saveChanges;
  Timer? _countdown;

  Future<void> load() async {
    emit(AsyncValue.loading(data: state.data));
    await runGuarded(() async {
      // The Daily page's load is where the archive is pruned (never
      // mid-game): a past-day board whose date left the window goes now.
      final status = _daily.pruneArchive();
      _startCountdown();
      return _build(status);
    });
    if (isClosed) return;
    // Only after the built state above landed: `_loadPreview` drops its
    // result when `state.data` doesn't yet show today's date (the guard
    // against a stale in-flight preview), which a preview started from
    // inside the `runGuarded` body above could lose to before its own
    // `emit` ran.
    final today = state.data?.status.today;
    if (today != null) unawaited(_loadPreview(today));
  }

  /// Re-reads the streak (Play → the gameplay page → back to Daily, and
  /// the countdown crossing midnight).
  void refresh() {
    if (isClosed) return;
    final current = state.data;
    if (current == null) return;
    _showStatus(current, _daily.refresh());
  }

  /// A day of the month's picker was tapped (frame 14.3b): its card opens
  /// under the month card. Tapping the chosen day again closes the card
  /// (the chosen ring is its only handle). A day outside the window, or
  /// today's, never opens: the grid doesn't offer it, and this refuses it
  /// too.
  void selectPastDate(LocalDate date) {
    if (isClosed) return;
    final current = state.data;
    if (current == null) return;
    if (current.selectedPastDate == date) {
      clearPastSelection();
      return;
    }
    final status = current.status;
    if (!status.window.contains(date) && status.archiveInProgress != date) {
      return;
    }
    emit(
      AsyncValue.data(
        data: current.copyWith(
          selectedPastDate: date,
          pastPreviewColors: null,
          pastPreviewFailed: false,
          pastTier: DifficultyCurve.dailyTier(date.yyyymmdd),
          pastColorCount: DifficultyCurve.dailyParams(date.yyyymmdd).colors,
        ),
      ),
    );
    unawaited(_loadPastPreview(date));
  }

  /// Closes the past day's card.
  void clearPastSelection() {
    if (isClosed) return;
    final current = state.data;
    if (current == null || current.selectedPastDate == null) return;
    emit(
      AsyncValue.data(
        data: current.copyWith(
          selectedPastDate: null,
          pastPreviewColors: null,
          pastPreviewFailed: false,
          pastTier: null,
          pastColorCount: 0,
        ),
      ),
    );
  }

  /// The ‹ / › chip: [offset] 0 is today's month, -1 the one before, and
  /// nothing else (never further, frame 14.2c). Paging back is refused
  /// unless the window reaches into the previous month.
  void showMonth(int offset) {
    if (isClosed) return;
    final current = state.data;
    if (current == null || current.monthOffset == offset) return;
    if (offset != 0 && offset != -1) return;
    final reaches = DailyMonth.reachesPreviousMonth(
      current.status.today,
      current.status.window,
    );
    if (offset == -1 && !reaches) return;
    emit(AsyncValue.data(data: current.copyWith(monthOffset: offset)));
  }

  /// What the past day card's Play starts: the chosen date, or null.
  /// Past midnight the screen rolls over first, which closes the card (the
  /// window moved, and the chosen day may have left it), so Play starts
  /// nothing rather than a board the resolver refuses.
  PlayRequest? pastPlayRequest() {
    if (_rollOverIfNewDay()) return null;
    final date = state.data?.selectedPastDate;
    return date == null ? null : PlayRequest.pastDaily(date.yyyymmdd);
  }

  /// What the puzzle card's Play starts: always the clock's today
  /// (`DailyService.todayRequest`), never the date the screen last
  /// showed, which is yesterday's for up to a countdown interval after
  /// midnight. The screen rolls over first, so it matches on return.
  PlayRequest dailyPlayRequest() {
    _rollOverIfNewDay();
    return _daily.todayRequest;
  }

  /// The "Streak saved!" banner (frame 5.2) was shown.
  void acknowledgeFreezeNotice() => _daily.acknowledgeFreezeNotice();

  /// Collects the pending day-7 chest (frame 5.6): true, and coins added,
  /// when one was pending, so the page plays `JingleCues.reward()` only
  /// then ("Double it" is M6).
  bool collectChest() => _daily.collectChest() > 0;

  DailyState _build(DailyStatus status) => DailyState(
    status: status,
    coins: _save.coins,
    rewardCoins: _remoteConfig.value(RemoteConfigKeys.dailyReward),
    chestCoins: _remoteConfig.value(RemoteConfigKeys.streak7Reward),
    untilNextPuzzle: _daily.untilNextPuzzle(),
    homeRequest: _resolver.homeRequest,
    homeLevelNumber: _save.currentLevel,
  );

  void _onStatusChanged(DailyStatus status) {
    if (isClosed) return;
    final current = state.data;
    if (current == null) return;
    _showStatus(current, status);
  }

  /// Emits [status] over [current]. A status of another day also resets
  /// the countdown and the preview, then resolves that day's board, so
  /// yesterday's dolls never show under today's title (whichever of
  /// [refresh] and [DailyService.changes] brings the new day first).
  void _showStatus(DailyState current, DailyStatus status) {
    final newDay = status.today != current.status.today;
    emit(
      AsyncValue.data(
        data: newDay
            ? current.copyWith(
                status: status,
                untilNextPuzzle: _daily.untilNextPuzzle(),
                previewColors: null,
                previewFailed: false,
                // The window moved with the day: the picker starts clean.
                selectedPastDate: null,
                pastPreviewColors: null,
                pastPreviewFailed: false,
                pastTier: null,
                pastColorCount: 0,
                monthOffset: 0,
              )
            : current.copyWith(status: status),
      ),
    );
    if (newDay) unawaited(_loadPreview(status.today));
  }

  void _onCoinsChanged() {
    if (isClosed) return;
    final current = state.data;
    if (current == null) return;
    emit(AsyncValue.data(data: current.copyWith(coins: _save.coins)));
  }

  Future<void> _loadPastPreview(LocalDate date) async {
    final request = PlayRequest.pastDaily(date.yyyymmdd);
    final entry = await _resolver.resolve(request);
    if (isClosed) return;
    final current = state.data;
    // Another day was chosen (or the card closed) while this was in
    // flight: its own resolve owns the preview now.
    if (current == null || current.selectedPastDate != date) return;
    emit(
      AsyncValue.data(
        data: entry == null
            ? current.copyWith(pastPreviewFailed: true)
            : current.copyWith(
                pastPreviewColors: entry.level.setsByColor.keys.toList(),
              ),
      ),
    );
  }

  Future<void> _loadPreview(LocalDate today) async {
    final request = _daily.todayRequest;
    _resolver.prefetch(request);
    final entry = await _resolver.resolve(request);
    if (isClosed) return;
    final current = state.data;
    // The day rolled over while this was in flight: a fresh load already
    // asked again, so this stale result is dropped (never applied).
    if (current == null || current.status.today != today) return;
    if (entry == null) {
      emit(AsyncValue.data(data: current.copyWith(previewFailed: true)));
      return;
    }
    emit(
      AsyncValue.data(
        data: current.copyWith(
          previewColors: entry.level.setsByColor.keys.toList(),
        ),
      ),
    );
  }

  void _startCountdown() {
    _countdown?.cancel();
    _countdown = Timer.periodic(_countdownInterval, (_) => _tick());
  }

  void _tick() {
    if (isClosed) return;
    final current = state.data;
    if (current == null) return;
    // Past midnight the whole screen moves to the new day (its status,
    // Play, the preview), not just the countdown.
    if (_rollOverIfNewDay()) return;
    emit(
      AsyncValue.data(
        data: current.copyWith(untilNextPuzzle: _daily.untilNextPuzzle()),
      ),
    );
  }

  /// [refresh]es when the clock's today is past the shown status's; true
  /// when it did.
  bool _rollOverIfNewDay() {
    final shown = state.data?.status.today;
    if (shown == null) return false;
    if (_daily.todayRequest == PlayRequest.daily(shown.yyyymmdd)) return false;
    refresh();
    return true;
  }

  @override
  Future<void> close() {
    _countdown?.cancel();
    unawaited(_dailyChanges.cancel());
    unawaited(_saveChanges.cancel());
    return super.close();
  }
}
