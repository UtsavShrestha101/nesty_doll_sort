import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:nesty_game/core/base/base_async_cubit.dart';
import 'package:nesty_game/core/base/base_async_state.dart';
import 'package:nesty_game/core/services/analytics/analytics_service.dart';
import 'package:nesty_game/core/services/clock/app_clock.dart';
import 'package:nesty_game/core/services/clock/local_date.dart';
import 'package:nesty_game/core/services/login_gift/login_gift_reward.dart';
import 'package:nesty_game/core/services/login_gift/login_gift_rules.dart';
import 'package:nesty_game/core/services/remote_config/remote_config_service.dart';
import 'package:nesty_game/core/services/save/save_service.dart';

part 'login_gift_cubit.freezed.dart';
part 'login_gift_state.dart';

/// The daily gift's state for Home's button and the sheet (plan-login-gift
/// §7.5b; D268). The rules are `LoginGiftRules`'s and the payment is
/// `SaveService.claimLoginGift`'s; this only derives what to show and holds
/// the coin pill's cap while claimed coins fly.
///
/// It re-derives on [SaveService.changes] and when the app resumes, so a
/// date that changes while the app sleeps shows without a restart.
@injectable
class LoginGiftCubit extends BaseAsyncCubit<LoginGiftState> {
  LoginGiftCubit(this._save, this._clock, this._remoteConfig, this._analytics);

  final SaveService _save;
  final AppClock _clock;
  final RemoteConfigService _remoteConfig;
  final AnalyticsService _analytics;

  StreamSubscription<void>? _saveChanges;
  AppLifecycleListener? _lifecycle;

  /// Coins the player had just before the last claim, the base of the cap.
  int _coinsBefore = 0;
  int? _coinsCap;

  Future<void> load() async {
    _saveChanges ??= _save.changes.listen((_) => unawaited(refresh()));
    _lifecycle ??= AppLifecycleListener(onResume: () => unawaited(refresh()));
    await refresh();
  }

  /// Reads today's date and derives the state. The date is noted only once
  /// the gift is unlocked: before that it sees nothing (so the clock guard
  /// can't be set by a locked player).
  ///
  /// It reads and emits in one synchronous step (no await), so a refresh
  /// can never land after a later [claim] with a stale reading. A failure
  /// keeps the last data (rule 3: nothing here is the player's to fix).
  Future<void> refresh() async {
    if (isClosed) return;
    try {
      emit(AsyncValue.data(data: _read()));
    } on Object {
      // Keep what is on screen.
    }
  }

  LoginGiftState _read() {
    final today = _clock.today();
    final unlocked = LoginGiftRules.isUnlocked(_save.document.highestLevel);
    if (unlocked) _save.noteLoginGiftDate(today);
    final progress = _save.document.loginGift;
    final phase = !unlocked
        ? LoginGiftPhase.locked
        : today == progress.lastClaim
        ? LoginGiftPhase.claimed
        : LoginGiftRules.canClaim(today, progress)
        ? LoginGiftPhase.ready
        : LoginGiftPhase.waiting;
    return LoginGiftState(
      phase: phase,
      track: LoginGiftRules.trackOf(_remoteConfig),
      claims: progress.claims,
      today: today,
      coinsCap: _coinsCap,
      hints: _save.boosterCount(BoosterKind.hint),
      slots: _save.boosterCount(BoosterKind.extraSlot),
    );
  }

  /// Claims today's gift and returns what was paid, or null when the save
  /// refuses (locked, already claimed, clock back) with nothing changed.
  /// With [holdCoins] the coin pill is capped at the balance before the
  /// claim until [coinsLanded] / [releaseCoins]; pass false when no coins
  /// fly (reduce motion).
  LoginGiftGrant? claim({bool holdCoins = true}) {
    if (isClosed) return null;
    try {
      final coinsBefore = _save.coins;
      final grant = _save.claimLoginGift(_clock.today());
      if (grant == null) return null;
      _coinsBefore = coinsBefore;
      _coinsCap = holdCoins && grant.reward.coins > 0 ? coinsBefore : null;
      unawaited(_logClaim(grant));
      emit(AsyncValue.data(data: _read()));
      return grant;
    } on Object {
      return null;
    }
  }

  /// A failed event is dropped silently (CLAUDE.md rule 3).
  Future<void> _logClaim(LoginGiftGrant grant) async {
    try {
      await _analytics.logEvent(
        'login_gift_claim',
        parameters: {'day': grant.day, 'claims': grant.claims},
      );
    } on Object {
      // Analytics never reaches the player.
    }
  }

  /// [landedSoFar] coins of the claim have reached the pill (cumulative).
  void coinsLanded(int landedSoFar) {
    final current = state.data;
    if (isClosed || current == null || current.coinsCap == null) return;
    _coinsCap = _coinsBefore + landedSoFar;
    emit(AsyncValue.data(data: current.copyWith(coinsCap: _coinsCap)));
  }

  /// All coins have landed (or the player skipped): the pill is uncapped.
  void releaseCoins() {
    _coinsCap = null;
    final current = state.data;
    if (isClosed || current == null || current.coinsCap == null) return;
    emit(AsyncValue.data(data: current.copyWith(coinsCap: null)));
  }

  @override
  Future<void> close() async {
    await _saveChanges?.cancel();
    _lifecycle?.dispose();
    return super.close();
  }
}
