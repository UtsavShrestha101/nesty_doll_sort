import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:nesty_game/core/base/base_async_cubit.dart';
import 'package:nesty_game/core/base/base_async_state.dart';
import 'package:nesty_game/core/models/play_request.dart';
import 'package:nesty_game/core/services/analytics/analytics_service.dart';
import 'package:nesty_game/core/services/daily/daily_service.dart';
import 'package:nesty_game/core/services/welcome_back/welcome_back_rules.dart';
import 'package:nesty_game/core/services/welcome_back/welcome_back_tracker.dart';

export 'package:nesty_game/core/services/welcome_back/welcome_back_rules.dart'
    show WelcomeBackVariant;

part 'welcome_back_cubit.freezed.dart';
part 'welcome_back_state.dart';

/// Home's welcome-back card (local habit 1, plan-local-habits §1). The
/// rules are `WelcomeBackRules`'; `WelcomeBackTracker` notes the opens and
/// owns the card's date. This only derives what to show.
///
/// It re-derives on the tracker's changes, `DailyService.changes` and when
/// the app resumes, so a date that changes while the app sleeps, or a
/// solved daily, shows without a restart. A dismissal is the tracker's
/// cleared date: it stays through a resume and is gone on a new date.
@injectable
class WelcomeBackCubit extends BaseAsyncCubit<WelcomeBackState> {
  WelcomeBackCubit(this._tracker, this._daily, this._analytics);

  final WelcomeBackTracker _tracker;
  final DailyService _daily;
  final AnalyticsService _analytics;

  StreamSubscription<void>? _trackerChanges;
  StreamSubscription<void>? _dailyChanges;
  AppLifecycleListener? _lifecycle;

  Future<void> load() async {
    _trackerChanges ??= _tracker.changes.listen((_) => refresh());
    _dailyChanges ??= _daily.changes.listen((_) => refresh());
    _lifecycle ??= AppLifecycleListener(onResume: refresh);
    refresh();
  }

  /// Derives the state in one synchronous step. A failure keeps what is on
  /// screen (rule 3: nothing here is the player's to fix).
  void refresh() {
    if (isClosed) return;
    try {
      final status = _daily.refresh();
      final show = WelcomeBackRules.shows(
        today: status.today,
        welcomeBackDate: _tracker.welcomeBackDate,
        unlocked: status.unlocked,
        solvedToday: status.solvedToday,
      );
      final next = show
          ? WelcomeBackState.shown(
              variant: WelcomeBackRules.variantOf(status),
              streak: status.streak,
            )
          : const WelcomeBackState.hidden();
      if (state.data == next) return;
      emit(AsyncValue.data(data: next));
    } on Object {
      // Keep what is on screen.
    }
  }

  /// The player closed the card: it doesn't come back today.
  void dismiss() {
    if (isClosed) return;
    _tracker.dismiss();
    refresh();
  }

  /// Today's daily, as the Daily page's Play starts it. The card's Play
  /// asks for this request and pushes it.
  PlayRequest play() {
    unawaited(_logPlay());
    return _daily.todayRequest;
  }

  /// A failed event is dropped silently (CLAUDE.md rule 3).
  Future<void> _logPlay() async {
    try {
      // TODO(M4): the kid path keeps this off for under-13s (BACKLOG M4 kid-path analytics).
      await _analytics.logEvent('welcome_back_play');
    } on Object {
      // Analytics never reaches the player.
    }
  }

  @override
  Future<void> close() async {
    await _trackerChanges?.cancel();
    await _dailyChanges?.cancel();
    _lifecycle?.dispose();
    return super.close();
  }
}
