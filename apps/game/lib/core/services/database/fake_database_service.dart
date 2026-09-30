import 'dart:async';

import 'package:injectable/injectable.dart';
import 'package:nesty_game/core/dependency_injection/app_env.dart';
import 'package:nesty_game/core/models/reduce_motion_mode.dart';
import 'package:nesty_game/core/models/reminder_settings.dart';
import 'package:nesty_game/core/models/symbols_mode.dart';
import 'package:nesty_game/core/services/database/database_service.dart';
import 'package:nesty_game/core/services/database/hive_boxes.dart';
import 'package:nesty_game/core/services/database/settings_schema.dart';

/// In-memory [DatabaseService]: nothing survives a restart.
///
/// Registered for the fake env (tests, `NESTY_FAKE_SERVICES`). It is also the
/// real env's fallback when Hive can't open (see
/// `HiveDatabaseService.openOrFallback`), which is why it is a complete
/// implementation rather than a stub.
@Singleton(as: DatabaseService, env: [AppEnv.fake])
class FakeDatabaseService implements DatabaseService {
  final _languageController = StreamController<String>.broadcast();
  final _musicController = StreamController<bool>.broadcast();
  final _symbolsController = StreamController<SymbolsMode>.broadcast();
  final _relaxedController = StreamController<bool>.broadcast();
  final _reduceMotionController =
      StreamController<ReduceMotionMode>.broadcast();
  final _reminderController = StreamController<ReminderSettings>.broadcast();

  bool _sound = SettingsDefaults.sound;
  bool _music = SettingsDefaults.music;
  bool _haptics = SettingsDefaults.haptics;
  SymbolsMode _symbols = SettingsDefaults.symbols;
  bool _relaxed = SettingsDefaults.relaxed;
  ReduceMotionMode _reduceMotion = SettingsDefaults.reduceMotion;
  ReminderSettings _reminder = SettingsDefaults.reminder;
  String _languageCode = SettingsDefaults.locale;
  final Map<String, String> _save = {};

  @override
  bool get soundEnabled => _sound;

  @override
  Future<void> setSoundEnabled(bool enabled) async => _sound = enabled;

  @override
  bool get musicEnabled => _music;

  @override
  Future<void> setMusicEnabled(bool enabled) async {
    _music = enabled;
    if (!_musicController.isClosed) _musicController.add(enabled);
  }

  @override
  Stream<bool> get musicEnabledChanges => _musicController.stream;

  @override
  bool get hapticsEnabled => _haptics;

  @override
  Future<void> setHapticsEnabled(bool enabled) async => _haptics = enabled;

  @override
  SymbolsMode get symbolsMode => _symbols;

  @override
  Future<void> setSymbolsMode(SymbolsMode mode) async {
    _symbols = mode;
    if (!_symbolsController.isClosed) _symbolsController.add(mode);
  }

  @override
  Stream<SymbolsMode> get symbolsModeChanges => _symbolsController.stream;

  @override
  bool get relaxedMode => _relaxed;

  @override
  Future<void> setRelaxedMode(bool enabled) async {
    _relaxed = enabled;
    if (!_relaxedController.isClosed) _relaxedController.add(enabled);
  }

  @override
  Stream<bool> get relaxedModeChanges => _relaxedController.stream;

  @override
  ReduceMotionMode get reduceMotion => _reduceMotion;

  @override
  Future<void> setReduceMotion(ReduceMotionMode mode) async {
    _reduceMotion = mode;
    if (!_reduceMotionController.isClosed) _reduceMotionController.add(mode);
  }

  @override
  Stream<ReduceMotionMode> get reduceMotionChanges =>
      _reduceMotionController.stream;

  @override
  ReminderSettings get reminder => _reminder;

  @override
  Future<void> setReminder(ReminderSettings reminder) async {
    // As Hive's reads: an hour or minute out of range reads back as its
    // default.
    const defaults = SettingsDefaults.reminder;
    final read = reminder.copyWith(
      hour: reminder.hour >= 0 && reminder.hour < 24
          ? reminder.hour
          : defaults.hour,
      minute: reminder.minute >= 0 && reminder.minute < 60
          ? reminder.minute
          : defaults.minute,
    );
    // Like the Hive stream's `.distinct()`: an unchanged value is quiet.
    if (read == _reminder) return;
    _reminder = read;
    if (!_reminderController.isClosed) _reminderController.add(read);
  }

  @override
  Stream<ReminderSettings> get reminderChanges => _reminderController.stream;

  @override
  String get languageCode => _languageCode;

  @override
  Future<void> setLanguage(String languageCode) async {
    _languageCode = languageCode;
    if (!_languageController.isClosed) _languageController.add(languageCode);
  }

  @override
  Stream<String> get languageStream => _languageController.stream;

  @override
  String? readSaveDocument() => _save[SaveBoxKeys.document];

  @override
  Future<void> writeSaveDocument(String json) async =>
      _save[SaveBoxKeys.document] = json;

  @override
  String? readSaveBackup(String key) => _save[key];

  @override
  Future<void> writeSaveBackup(String key, String json) async =>
      _save[key] = json;

  @override
  Future<void> flushSave() async {}

  @override
  @disposeMethod
  Future<void> close() async {
    await _languageController.close();
    await _musicController.close();
    await _symbolsController.close();
    await _relaxedController.close();
    await _reduceMotionController.close();
    await _reminderController.close();
  }
}

/// [FakeDatabaseService] as the real env's session fallback, when Hive can't
/// open (`HiveDatabaseService.openOrFallback`): the same in-memory store,
/// marked [SessionOnlyDatabase] so the reminder doesn't take its default
/// "off" for the player's answer. The fake env and tests keep the plain
/// [FakeDatabaseService], which stands in for a store that persists.
class SessionFallbackDatabaseService extends FakeDatabaseService
    implements SessionOnlyDatabase {}
