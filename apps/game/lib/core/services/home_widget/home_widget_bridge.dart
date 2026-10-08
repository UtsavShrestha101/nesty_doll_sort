import 'dart:async';
import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart'
    show AppLifecycleListener, AppLifecycleState, Locale;
import 'package:injectable/injectable.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:nesty_core/nesty_core.dart';
import 'package:nesty_game/app/localization_cubit/app_locale_resolver.dart';
import 'package:nesty_game/core/flavor/flavor_config.dart';
import 'package:nesty_game/core/models/play_request.dart';
import 'package:nesty_game/core/repository/level_resolver.dart';
import 'package:nesty_game/core/services/clock/app_clock.dart';
import 'package:nesty_game/core/services/clock/local_date.dart';
import 'package:nesty_game/core/services/daily/daily_service.dart';
import 'package:nesty_game/core/services/daily/daily_status.dart';
import 'package:nesty_game/core/services/database/database_service.dart';
import 'package:nesty_game/core/services/home_widget/home_widget_service.dart';
import 'package:nesty_game/core/services/home_widget/home_widget_snapshot.dart';

/// Keeps the home-screen widget's snapshot current (plan-local-habits §4;
/// stage 4 contract §3): it composes [DailyService.projection], the rendered
/// language and [HomeWidgetService], and writes when the widget could look
/// different.
///
/// Writes on [start], on each resume, on every [DailyService.changes] (a
/// solve, a reconcile, a new day, a freeze) and on a language change, and
/// skips a snapshot identical to the last one stored. It is fire-and-forget:
/// no call throws (rule 3) and nothing waits on it. It has no interface of
/// its own, like `DailyReminder` beside which `bootstrap` starts it. Nothing
/// here pops up, counts down or asks for anything: the widget only shows
/// what the app wrote.
@lazySingleton
class HomeWidgetBridge {
  /// [scheme], [locales] and [deviceLocales] default to the flavor's URL
  /// scheme, [AppLocaleResolver.app] and the engine's locale list; tests
  /// pass them.
  HomeWidgetBridge(
    this._widget,
    this._daily,
    this._settings,
    this._resolver,
    this._clock, {
    @ignoreParam String? scheme,
    @ignoreParam AppLocaleResolver? locales,
    @ignoreParam List<Locale> Function()? deviceLocales,
  }) : _scheme = scheme,
       _locales = locales ?? AppLocaleResolver.app,
       _deviceLocales = deviceLocales ?? AppLocaleResolver.platformLocales;

  final HomeWidgetService _widget;
  final DailyService _daily;
  final DatabaseService _settings;
  final LevelResolver _resolver;
  final AppClock _clock;
  final String? _scheme;
  final AppLocaleResolver _locales;
  final List<Locale> Function() _deviceLocales;

  /// How many of the next dates get their doll colours: today's and
  /// tomorrow's (the lead's ruling), so a phone left closed overnight still
  /// shows dolls; later days show none.
  static const int dollDays = 2;

  AppLifecycleListener? _lifecycle;
  StreamSubscription<DailyStatus>? _dailySubscription;
  StreamSubscription<String>? _languageSubscription;

  /// The colours known per date, kept for the days still to come.
  final Map<LocalDate, List<DollColor>> _dolls = {};
  final Set<LocalDate> _dollsAsked = {};

  String? _lastStored;
  Future<void>? _running;
  bool _queued = false;
  bool _closed = false;
  Future<void>? _dateData;

  /// The JSON stored last (for tests and the integration check).
  @visibleForTesting
  String? get lastStored => _lastStored;

  /// Starts following the resume, the daily's changes and the language, then
  /// writes once (unawaited). Idempotent.
  void start() {
    if (_lifecycle != null ||
        _dailySubscription != null ||
        _languageSubscription != null) {
      return;
    }
    try {
      _lifecycle = AppLifecycleListener(onStateChange: didChangeAppLifecycle);
    } on Object catch (error, stack) {
      // No binding (a bare unit test): resume just isn't followed.
      _log('no lifecycle listener', error, stack);
    }
    _dailySubscription = _daily.changes.listen((_) => unawaited(publish()));
    _languageSubscription = _settings.languageStream.listen(
      (_) => unawaited(publish()),
    );
    unawaited(publish());
  }

  /// Re-writes on resume. Public and `@visibleForTesting`, like
  /// `DailyReminder.didChangeAppLifecycle`.
  @visibleForTesting
  void didChangeAppLifecycle(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) unawaited(publish());
  }

  /// Composes the snapshot now and stores it unless it equals the last one
  /// stored. Concurrent callers coalesce: one run in flight, at most one more
  /// after it. Never throws.
  Future<void> publish() {
    final running = _running;
    if (running != null) {
      _queued = true;
      return running;
    }
    final started = _publishOnce();
    _running = started;
    unawaited(
      started.whenComplete(() {
        _running = null;
        if (_queued && !_closed) {
          _queued = false;
          unawaited(publish());
        }
      }),
    );
    return started;
  }

  Future<void> _publishOnce() async {
    try {
      await (_dateData ??= _initDateData());
      final snapshot = _compose();
      final json = snapshot.encode();
      if (json != _lastStored) {
        final stored = await _widget.publish(snapshot);
        // A failed store is retried by the next trigger, not remembered.
        if (stored) _lastStored = json;
      }
      _fetchDolls(snapshot);
    } on Object catch (error, stack) {
      _log('publishing the widget snapshot failed', error, stack);
    }
  }

  HomeWidgetSnapshot _compose() {
    final today = _clock.today();
    _dolls.removeWhere((date, _) => date < today);
    _dollsAsked.removeWhere((date) => date < today);
    return HomeWidgetSnapshot.compose(
      lang: _locales.resolve(_settings.languageCode, _deviceLocales()),
      scheme: _scheme ?? _flavorScheme(),
      unlocked: _daily.isUnlocked,
      unlockLevel: DailyService.unlockAfterLevel,
      days: _daily.projection(today, HomeWidgetSnapshot.dayCount),
      dolls: _dolls,
    );
  }

  /// Asks for the colours of today's and tomorrow's puzzles once each (the
  /// same entry point the Daily plays, off the UI isolate, so the Daily's
  /// board and the widget's dolls always agree), then writes again. Nothing
  /// is asked while the Daily is locked.
  void _fetchDolls(HomeWidgetSnapshot snapshot) {
    if (!snapshot.unlocked) return;
    final today = _clock.today();
    for (var i = 0; i < dollDays; i++) {
      final date = today.addDays(i);
      if (_dolls.containsKey(date) || !_dollsAsked.add(date)) continue;
      unawaited(_loadDolls(date));
    }
  }

  Future<void> _loadDolls(LocalDate date) async {
    try {
      final entry = await _resolver.resolve(PlayRequest.daily(date.yyyymmdd));
      if (_closed) return;
      if (entry == null) {
        // The generator failed this time: ask again at the next trigger.
        _dollsAsked.remove(date);
        return;
      }
      _dolls[date] = entry.level.setsByColor.keys.toList();
      unawaited(publish());
    } on Object catch (error, stack) {
      _dollsAsked.remove(date);
      _log('reading $date\'s dolls failed', error, stack);
    }
  }

  /// Weekday names need the intl date symbols, which the app's localization
  /// delegates only load once the widget tree is up.
  Future<void> _initDateData() async {
    try {
      await initializeDateFormatting();
    } on Object catch (error, stack) {
      _log('date symbols failed to load', error, stack);
    }
  }

  String _flavorScheme() {
    try {
      return FlavorConfig.flavor.urlScheme;
    } on StateError {
      return 'nesty';
    }
  }

  static void _log(String message, Object error, StackTrace? stack) {
    developer.log(
      message,
      name: 'nesty.home_widget',
      error: error,
      stackTrace: stack,
    );
    if (kDebugMode) debugPrint('[nesty.home_widget] $message: $error');
  }

  /// Stops following everything (DI reset).
  @disposeMethod
  Future<void> dispose() async {
    _closed = true;
    _lifecycle?.dispose();
    _lifecycle = null;
    await _dailySubscription?.cancel();
    _dailySubscription = null;
    await _languageSubscription?.cancel();
    _languageSubscription = null;
  }
}
