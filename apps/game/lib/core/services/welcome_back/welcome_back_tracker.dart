import 'dart:async';

import 'package:flutter/widgets.dart' show AppLifecycleListener;
import 'package:injectable/injectable.dart';
import 'package:nesty_game/core/services/clock/app_clock.dart';
import 'package:nesty_game/core/services/clock/local_date.dart';
import 'package:nesty_game/core/services/database/database_service.dart';
import 'package:nesty_game/core/services/remote_config/remote_config_service.dart';
import 'package:nesty_game/core/services/welcome_back/welcome_back_rules.dart';

/// Notes every open and resume for welcome back (local habit 1,
/// plan-local-habits §1): reads `lastOpenDate`, applies
/// `WelcomeBackRules.onOpen`, then writes the high-water mark and the
/// card's date.
///
/// It composes interfaces, like `DailyReminder`, so it has no interface of
/// its own. `bootstrap` calls [start] before the first frame, so the gap is
/// read before anything overwrites `lastOpenDate`. Writes stay inside the
/// settings box (this phone, not progress) and are silent on failure.
@lazySingleton
class WelcomeBackTracker {
  WelcomeBackTracker(this._settings, this._clock, this._remoteConfig);

  final DatabaseService _settings;
  final AppClock _clock;
  final RemoteConfigService _remoteConfig;
  final StreamController<LocalDate?> _changes = StreamController.broadcast();

  AppLifecycleListener? _lifecycle;
  bool _started = false;

  // What the settings hold, kept here after the first read: a Hive put only
  // becomes readable once its write finishes, and Home's cubit asks in the
  // first frame.
  bool _read = false;
  String? _lastOpen;
  LocalDate? _card;

  /// The date the welcome-back card belongs to, or null.
  LocalDate? get welcomeBackDate {
    if (!_read) note();
    return _card;
  }

  /// Fires with the card's date after an open, resume or dismissal that
  /// changed it.
  Stream<LocalDate?> get changes => _changes.stream;

  /// Notes the app start, then follows every resume. Once.
  void start() {
    if (_started) return;
    _started = true;
    try {
      _lifecycle = AppLifecycleListener(onResume: note);
    } on Object {
      // No binding (a bare unit test): resumes just aren't followed, as in
      // HomeWidgetBridge.start.
    }
    note();
  }

  /// One open or resume: read first, write after. The date it reads is the
  /// one stored before this call, never one this call wrote.
  void note() {
    try {
      if (!_read) {
        _lastOpen = _settings.lastOpenDate;
        _card = LocalDate.tryParse(_settings.welcomeBackDate);
        _read = true;
      }
      final result = WelcomeBackRules.onOpen(
        today: _clock.today(),
        storedLastOpen: _lastOpen,
        storedWelcomeBack: _card?.toIso(),
        gapDays: WelcomeBackRules.gapOf(_remoteConfig),
      );
      final lastIso = result.lastOpenDate.toIso();
      if (_lastOpen != lastIso) {
        _lastOpen = lastIso;
        unawaited(_settings.setLastOpenDate(lastIso));
      }
      _setCard(result.welcomeBackDate);
    } on Object {
      // Nothing here is the player's to fix (CLAUDE.md rule 3).
    }
  }

  /// The player closed the card: it doesn't come back that day.
  void dismiss() {
    if (!_read) note();
    _setCard(null);
  }

  void _setCard(LocalDate? card) {
    if (card == _card) return;
    _card = card;
    unawaited(_settings.setWelcomeBackDate(card?.toIso()));
    if (!_changes.isClosed) _changes.add(card);
  }

  /// Stops following resumes and closes [changes] (tests, DI reset).
  @disposeMethod
  Future<void> dispose() async {
    _lifecycle?.dispose();
    _lifecycle = null;
    await _changes.close();
  }
}
