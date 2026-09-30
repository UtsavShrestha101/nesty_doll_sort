import 'dart:async';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:nesty_game/core/base/base_async_cubit.dart';
import 'package:nesty_game/core/base/base_async_state.dart';
import 'package:nesty_game/core/models/reduce_motion_mode.dart';
import 'package:nesty_game/core/models/symbols_mode.dart';
import 'package:nesty_game/core/services/app_info/app_info_service.dart';
import 'package:nesty_game/core/services/database/database_service.dart';
import 'package:nesty_game/core/services/database/settings_schema.dart';
import 'package:nesty_game/core/services/reminder/daily_reminder.dart';
import 'package:nesty_game/core/services/save/save_service.dart';
import 'package:nesty_game/core/services/system_settings/system_settings_service.dart';

part 'settings_cubit.freezed.dart';
part 'settings_state.dart';

/// Settings (frames 8.1, 8.2; spec §10.2 #13; docs/plans/m3-design.md
/// §10.2; spec-prop §10.2 #13, §7.9, docs/plans/m7-design.md §15.5, P3.10):
/// the Sound/Music/Haptics toggles, Color symbols, Relaxed mode, Reduce
/// motion and the Daily reminder write only `DatabaseService`/
/// `DailyReminder` (D14 note), whose change streams carry them to the
/// board, the app root and this cubit; the footer reads [AppInfoService]
/// once and [SaveService.playerId] (already loaded by the splash).
@injectable
class SettingsCubit extends BaseAsyncCubit<SettingsState> {
  SettingsCubit(
    this._database,
    this._appInfo,
    this._save,
    this._reminder, {
    SystemSettingsService? systemSettings,
  }) : _systemSettings = systemSettings;

  final DatabaseService _database;
  final AppInfoService _appInfo;
  final SaveService _save;
  final DailyReminder _reminder;
  final SystemSettingsService? _systemSettings;
  StreamSubscription<ReminderStatus>? _reminderChanges;

  /// A [setReminderOn] `true` is in flight (the OS permission dialog can be
  /// up): another one meanwhile is ignored (M7 review R35).
  bool _enablingReminder = false;

  Future<void> load() async {
    emit(AsyncValue.loading(data: state.data));
    await runGuarded(() async {
      final info = await _appInfo.load();
      final reminder = await _reminder.refresh();
      _reminderChanges ??= _reminder.changes.listen(_onReminderChanged);
      return SettingsState(
        soundEnabled: _database.soundEnabled,
        musicEnabled: _database.musicEnabled,
        hapticsEnabled: _database.hapticsEnabled,
        symbolsMode: _database.symbolsMode,
        relaxedMode: _database.relaxedMode,
        reduceMotion: _database.reduceMotion,
        version: info.version,
        buildNumber: info.buildNumber,
        playerId: _save.playerId,
        reminder: reminder,
      );
    });
  }

  void _onReminderChanged(ReminderStatus reminder) {
    if (isClosed) return;
    final current = state.data;
    if (current == null) return;
    emit(AsyncValue.data(data: current.copyWith(reminder: reminder)));
  }

  /// Opens the phone's notification settings (frames 10.2d and 10.2f, Q140):
  /// the blocked row's pill and toggle. Coming back, `DailyReminder`'s resume
  /// refresh clears the blocked state through [_onReminderChanged].
  Future<bool> openPhoneSettings() async =>
      await _systemSettings?.openNotificationSettings() ?? false;

  /// The reminder toggle (spec-prop §7.9; m7-design P3.10): on asks the OS
  /// for the notification permission (only when it hasn't answered before),
  /// off cancels the schedule. Returns false when turning it on was denied;
  /// the reminder then stays on and blocked (D190), so the row itself shows
  /// `settingReminderBlocked` with Open phone settings instead of a toast.
  ///
  /// Applies `DailyReminder.status` to the state itself once the call
  /// settles, rather than waiting on [_onReminderChanged]'s broadcast
  /// stream event (which lands on a later microtask): a caller awaiting
  /// this method sees the new toggle immediately, with no timing race.
  ///
  /// A second on while one is in flight (a double tap while the OS dialog
  /// is up) is ignored and returns true, so no "blocked" toast shows: a
  /// second request would fail at once as "already in progress" on
  /// Android 13 and read as denied (M7 review R35). The first call alone
  /// reports the answer.
  Future<bool> setReminderOn(bool enabled) async {
    final current = state.data;
    if (current == null) return true;
    if (!enabled) {
      await _reminder.disable();
      _applyReminderStatus();
      return true;
    }
    if (_enablingReminder) return true;
    _enablingReminder = true;
    try {
      final settings = current.reminder.settings;
      final result = await _reminder.enable(
        hour: settings.hour,
        minute: settings.minute,
      );
      _applyReminderStatus();
      return result == ReminderEnableResult.enabled;
    } finally {
      _enablingReminder = false;
    }
  }

  /// The reminder time row: `showTimePicker`'s new hour and minute.
  Future<void> setReminderTime({required int hour, required int minute}) async {
    await _reminder.setTime(hour: hour, minute: minute);
    _applyReminderStatus();
  }

  void _applyReminderStatus() {
    if (isClosed) return;
    final current = state.data;
    if (current == null) return;
    emit(AsyncValue.data(data: current.copyWith(reminder: _reminder.status)));
  }

  Future<void> setSoundEnabled(bool enabled) async {
    final current = state.data;
    if (current == null) return;
    await runGuarded(() async {
      await _database.setSoundEnabled(enabled);
      return current.copyWith(soundEnabled: enabled);
    });
  }

  Future<void> setMusicEnabled(bool enabled) async {
    final current = state.data;
    if (current == null) return;
    await runGuarded(() async {
      await _database.setMusicEnabled(enabled);
      return current.copyWith(musicEnabled: enabled);
    });
  }

  Future<void> setHapticsEnabled(bool enabled) async {
    final current = state.data;
    if (current == null) return;
    await runGuarded(() async {
      await _database.setHapticsEnabled(enabled);
      return current.copyWith(hapticsEnabled: enabled);
    });
  }

  /// "Color symbols": Subtle | Large (boards rebuild their bodies, D45).
  Future<void> setSymbolsMode(SymbolsMode mode) async {
    final current = state.data;
    if (current == null) return;
    await runGuarded(() async {
      await _database.setSymbolsMode(mode);
      return current.copyWith(symbolsMode: mode);
    });
  }

  /// "Relaxed mode" (E6): undo free and unlimited; the level in play
  /// follows at once (`GameplayBloc` listens to the setting).
  Future<void> setRelaxedMode(bool enabled) async {
    final current = state.data;
    if (current == null) return;
    await runGuarded(() async {
      await _database.setRelaxedMode(enabled);
      return current.copyWith(relaxedMode: enabled);
    });
  }

  /// "Reduce motion" (E14): System | On | Off; the app root follows it
  /// (`MediaQuery.disableAnimations`).
  Future<void> setReduceMotion(ReduceMotionMode mode) async {
    final current = state.data;
    if (current == null) return;
    await runGuarded(() async {
      await _database.setReduceMotion(mode);
      return current.copyWith(reduceMotion: mode);
    });
  }

  @override
  Future<void> close() {
    unawaited(_reminderChanges?.cancel());
    return super.close();
  }
}
