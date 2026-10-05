import 'dart:async';
import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart'
    show AppLifecycleListener, AppLifecycleState, Locale;
import 'package:injectable/injectable.dart';
import 'package:nesty_game/app/localization_cubit/app_locale_resolver.dart';
import 'package:nesty_game/core/models/reminder_settings.dart';
import 'package:nesty_game/core/services/clock/app_clock.dart';
import 'package:nesty_game/core/services/clock/local_date.dart';
import 'package:nesty_game/core/services/daily/daily_service.dart';
import 'package:nesty_game/core/services/database/database_service.dart';
import 'package:nesty_game/core/services/notifications/notification_service.dart';
import 'package:nesty_game/core/services/reminder/reminder_status.dart';
import 'package:nesty_game/l10n/app_localizations.dart';

export 'package:nesty_game/core/services/reminder/reminder_status.dart';

/// The opt-in daily reminder (E4; spec-prop §7.9, §1.1 rule 7;
/// docs/plans/m7-design.md P3.10): one local notification a day at the
/// player's chosen time, "Today's puzzle is ready", off until the player
/// accepts, never naming the streak, never a badge, re-timed or turned off
/// in Settings. No network.
///
/// It composes interfaces ([NotificationService], [DatabaseService],
/// [DailyService]), like `SaveLifecycleFlusher`, so it has no interface of
/// its own and one instance in both environments. The settings are the
/// truth; the OS schedule follows them at every [refresh]: on schedules
/// the one plan (replacing the last), off cancels it, except over a
/// [SessionOnlyDatabase] (Hive didn't open), whose off is only a default.
///
/// [start] runs from `bootstrap` after DI, once. The permission is asked
/// only in [enable], after the player's own Yes; a fresh install neither
/// schedules nor asks.
@lazySingleton
class DailyReminder {
  /// [locales] defaults to [AppLocaleResolver.app] (the catalogs present)
  /// and [deviceLocales] to the engine's list, read at each plan; tests
  /// pass both.
  DailyReminder(
    this._notifications,
    this._settings,
    this._daily, {
    AppClock? clock,
    @ignoreParam AppLocaleResolver? locales,
    @ignoreParam List<Locale> Function()? deviceLocales,
  }) : _clock = clock,
       _locales = locales ?? AppLocaleResolver.app,
       _deviceLocales = deviceLocales ?? AppLocaleResolver.platformLocales;

  final NotificationService _notifications;
  final AppClock? _clock;
  final AppLocaleResolver _locales;
  final List<Locale> Function() _deviceLocales;
  final DatabaseService _settings;
  final DailyService _daily;
  final StreamController<ReminderStatus> _changes =
      StreamController.broadcast();
  ReminderStatus _status = const ReminderStatus();

  AppLifecycleListener? _lifecycle;
  StreamSubscription<ReminderSettings>? _settingsSubscription;
  StreamSubscription<String>? _languageSubscription;

  /// The in-flight [_refreshOnce] (coalescing: while one runs, every other
  /// caller gets its result instead of starting a second platform round
  /// trip); [_refreshQueued] means at least one more call arrived meanwhile,
  /// so exactly one more run follows once this one settles ("one in flight,
  /// one more queued", m7-design P3.10).
  Future<ReminderStatus>? _running;
  bool _refreshQueued = false;

  /// The status as the last [refresh] read it.
  ReminderStatus get status => _status;

  /// Fires after every [refresh] that changed [status].
  Stream<ReminderStatus> get changes => _changes.stream;

  /// Starts following the app's resume, `DatabaseService.reminderChanges`
  /// and `languageStream`, then runs one [refresh] (unawaited). Idempotent:
  /// a second call is a no-op (the listeners are already up).
  void start() {
    if (_lifecycle != null ||
        _settingsSubscription != null ||
        _languageSubscription != null) {
      return;
    }
    try {
      _lifecycle = AppLifecycleListener(onStateChange: didChangeAppLifecycle);
    } on Object catch (error, stack) {
      // No binding (a bare unit test): resume just isn't followed.
      _log('no lifecycle listener', error, stack);
    }
    _settingsSubscription = _settings.reminderChanges.listen(
      (_) => unawaited(refresh()),
    );
    _languageSubscription = _settings.languageStream.listen(
      (_) => unawaited(refresh()),
    );
    unawaited(refresh());
  }

  /// Re-syncs on resume (m7-design P3.10: launch, resume, a settings or
  /// language change). Public and `@visibleForTesting`, like
  /// `SaveLifecycleFlusher.didChangeAppLifecycle`, so a test can drive it
  /// without a real app lifecycle event.
  @visibleForTesting
  void didChangeAppLifecycle(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) unawaited(refresh());
  }

  /// Re-reads the settings, the permission (no prompt) and the daily's
  /// lock, then (re)schedules the reminder when it is on or cancels it when
  /// off. Never throws. Concurrent callers (a resume racing a settings
  /// change, say) coalesce into at most one extra run past the one already
  /// in flight.
  Future<ReminderStatus> refresh() {
    final running = _running;
    if (running != null) {
      _refreshQueued = true;
      return running;
    }
    final started = _refreshOnce();
    _running = started;
    unawaited(
      started.whenComplete(() {
        _running = null;
        if (_refreshQueued) {
          _refreshQueued = false;
          unawaited(refresh());
        }
      }),
    );
    return started;
  }

  Future<ReminderStatus> _refreshOnce() async {
    var permission = NotificationPermission.unknown;
    try {
      permission = await _notifications.permission();
    } on Object catch (error, stack) {
      // NotificationService never throws; this keeps refresh's promise
      // even for a double that does (rule 3).
      _log('permission read failed', error, stack);
    }
    final settings = _settings.reminder;
    try {
      if (settings.on) {
        await _notifications.scheduleDaily(planFor(settings));
      } else if (_settings is! SessionOnlyDatabase) {
        await _notifications.cancelDaily();
      }
      // Else Hive didn't open this launch: the in-memory store's off is only
      // its default, not the player's answer, so the schedule an earlier
      // session made stays (M7 review R30; [disable] still cancels).
    } on Object catch (error, stack) {
      _log('schedule sync failed', error, stack);
    }
    _publish(
      ReminderStatus(
        settings: settings,
        permission: permission,
        available: _daily.isUnlocked,
      ),
    );
    return _status;
  }

  /// The player said yes (the offer, or Settings' toggle): asks the OS (the
  /// prompt only when undecided), stores [hour]:[minute] and `offered`
  /// either way (a denial never loses the player's chosen time) and `on`
  /// when the OS allowed it or refused (a refusal stays on and blocked,
  /// D190), refreshes, and answers [ReminderEnableResult.enabled] or
  /// [ReminderEnableResult.denied].
  Future<ReminderEnableResult> enable({
    required int hour,
    required int minute,
  }) async {
    try {
      await _notifications.initialize();
      final permission = await _notifications.requestPermission();
      final granted = permission == NotificationPermission.granted;
      // A denied Yes keeps the reminder on (D190, Q-P4-4): the offer's copy
      // promises "your note will arrive at {time}", so `ReminderStatus.blocked`
      // holds, and Settings offers "Open phone settings", until the OS
      // allows it. An answer the platform can't give (unknown) stores off.
      final denied = permission == NotificationPermission.denied;
      await _settings.setReminder(
        ReminderSettings(
          on: granted || denied,
          hour: hour,
          minute: minute,
          offered: true,
        ),
      );
      await refresh();
      return granted
          ? ReminderEnableResult.enabled
          : ReminderEnableResult.denied;
    } on Object catch (error, stack) {
      _log('enable failed', error, stack);
      return ReminderEnableResult.denied;
    }
  }

  /// Turns the reminder off and cancels the schedule.
  Future<void> disable() async {
    try {
      await _settings.setReminder(_settings.reminder.copyWith(on: false));
      // Over the session fallback a refresh never cancels, so the player's
      // own off does it here.
      if (_settings is SessionOnlyDatabase) await _notifications.cancelDaily();
      await refresh();
    } on Object catch (error, stack) {
      _log('disable failed', error, stack);
    }
  }

  /// Stores the time; reschedules when the reminder is on.
  ///
  /// False when the time could not be stored.
  Future<bool> setTime({required int hour, required int minute}) async {
    try {
      await _settings.setReminder(
        _settings.reminder.copyWith(hour: hour, minute: minute),
      );
      await refresh();
      return true;
    } on Object catch (error, stack) {
      _log('setTime failed', error, stack);
      return false;
    }
  }

  /// The one plan for [settings] in the app's language (the language
  /// setting resolved as the app resolves it, by [AppLocaleResolver]: a
  /// pinned language, else the phone's first supported one, else English):
  /// the same warm title and body every day, whatever the streak
  /// (spec-prop §7.9).
  @visibleForTesting
  ReminderPlan planFor(ReminderSettings settings) {
    final l10n = _localizations(
      _locales.resolve(_settings.languageCode, _deviceLocales()),
    );
    return ReminderPlan(
      hour: settings.hour,
      minute: settings.minute,
      title: l10n.reminderNotificationTitle,
      body: switch (_lineIndex(settings)) {
        1 => l10n.reminderNotificationBody2,
        2 => l10n.reminderNotificationBody3,
        _ => l10n.reminderNotificationBody,
      },
      channelName: l10n.reminderChannelName,
      channelDescription: l10n.reminderChannelDescription,
    );
  }

  /// Which of the three lines (G.7) the plan carries: `epochDay(nextFire) %
  /// 3`, where nextFire is the next local [settings] time after now (m7
  /// phase 4 architecture §3.9, Q-P4-5). Deterministic, and re-picked at
  /// every re-plan; it stays one repeating trigger, so a player who never
  /// opens the app sees one line.
  int _lineIndex(ReminderSettings settings) {
    final clock = _clock;
    final now = clock?.now() ?? DateTime.now();
    var date = LocalDate.fromDateTime(now);
    final minutes = now.hour * 60 + now.minute;
    if (settings.hour * 60 + settings.minute <= minutes) {
      date = date.addDays(1);
    }
    return date.epochDay % 3;
  }

  void _publish(ReminderStatus next) {
    if (next == _status) return;
    _status = next;
    if (!_changes.isClosed) _changes.add(next);
  }

  /// The catalog for a resolved [code]. The resolver only answers
  /// languages that have one; a resolver built over a wider list (a test's)
  /// still never makes a plan throw.
  static AppLocalizations _localizations(String code) {
    final locale = AppLocaleResolver.localeFor(code);
    return lookupAppLocalizations(
      AppLocalizations.delegate.isSupported(locale)
          ? locale
          : AppLocaleResolver.localeFor(AppLocaleResolver.fallbackCode),
    );
  }

  static void _log(String message, Object error, StackTrace? stack) {
    developer.log(
      message,
      name: 'nesty.notifications',
      error: error,
      stackTrace: stack,
    );
    if (kDebugMode) debugPrint('[nesty.notifications] $message: $error');
  }

  /// Stops following everything and closes [changes] (DI reset).
  @disposeMethod
  Future<void> dispose() async {
    _lifecycle?.dispose();
    _lifecycle = null;
    await _settingsSubscription?.cancel();
    _settingsSubscription = null;
    await _languageSubscription?.cancel();
    _languageSubscription = null;
    await _changes.close();
  }
}
