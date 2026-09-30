import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:hive_ce_flutter/hive_ce_flutter.dart';
import 'package:nesty_game/core/models/reduce_motion_mode.dart';
import 'package:nesty_game/core/models/reminder_settings.dart';
import 'package:nesty_game/core/models/symbols_mode.dart';
import 'package:nesty_game/core/services/database/database_service.dart';
import 'package:nesty_game/core/services/database/fake_database_service.dart';
import 'package:nesty_game/core/services/database/hive_boxes.dart';
import 'package:nesty_game/core/services/database/settings_schema.dart';

/// Hive-backed [DatabaseService].
///
/// Construct it only through [open] / [openOrFallback], which initialise Hive
/// and open every box exactly once. DI calls [openOrFallback] from bootstrap
/// (`DatabaseModule`, `@preResolve`), so features only ever see opened boxes.
class HiveDatabaseService implements DatabaseService {
  HiveDatabaseService._(this._settings, this._save);

  final Box<Object> _settings;
  final Box<Object> _save;

  /// Initialises Hive and opens all boxes. Throws if storage is unavailable.
  ///
  /// [directory] switches to pure-Dart `Hive.init(directory)` (no platform
  /// channels), which is what the round-trip tests use. Without it Hive lives
  /// in `<app documents>/hive` via `Hive.initFlutter`.
  static Future<HiveDatabaseService> open({String? directory}) async {
    if (directory == null) {
      await Hive.initFlutter(HiveBoxes.directory);
    } else {
      Hive.init(directory);
    }
    // Generated adapters get registered here once a type needs one — see
    // hive_type_ids.dart. Settings are primitives, so there are none yet.
    final settings = await Hive.openBox<Object>(HiveBoxes.settings);
    final save = await Hive.openBox<Object>(HiveBoxes.save);
    return HiveDatabaseService._(settings, save);
  }

  /// [open], but never throws.
  ///
  /// Offline-first (CLAUDE.md rule 3): a storage failure must not brick the
  /// app. Hive already recovers truncated/corrupt box files on its own
  /// (`crashRecovery`), so what remains are environment failures such as an
  /// unavailable documents directory or a held file lock. Deleting data would
  /// not fix those, so we log and fall back to the in-memory implementation:
  /// the game stays fully playable with default settings, and changes simply
  /// don't persist this session.
  static Future<DatabaseService> openOrFallback({String? directory}) async {
    try {
      return await open(directory: directory);
    } on Object catch (error, stackTrace) {
      // TODO(M4): report as a Crashlytics non-fatal.
      developer.log(
        'Hive failed to open; using in-memory settings for this session.',
        name: 'nesty.database',
        error: error,
        stackTrace: stackTrace,
      );
      // developer.log never reaches the `flutter run` terminal.
      if (kDebugMode) debugPrint('[nesty.database] Hive failed: $error');
      // A SessionOnlyDatabase, so a reader that acts on the OS (the
      // reminder) can tell its defaults from the player's choices.
      return SessionFallbackDatabaseService();
    }
  }

  // Reads are type-checked: a value of the wrong type (corruption, or a
  // future schema) falls back to its default instead of throwing.
  bool _readBool(String key, bool fallback) {
    final value = _settings.get(key);
    return value is bool ? value : fallback;
  }

  String _readString(String key, String fallback) {
    final value = _settings.get(key);
    return value is String ? value : fallback;
  }

  /// An int in `min..max`, else [fallback].
  int _readInt(String key, int fallback, {required int min, required int max}) {
    final value = _settings.get(key);
    return value is int && value >= min && value <= max ? value : fallback;
  }

  @override
  bool get soundEnabled =>
      _readBool(SettingsKeys.sound, SettingsDefaults.sound);

  @override
  Future<void> setSoundEnabled(bool enabled) =>
      _settings.put(SettingsKeys.sound, enabled);

  @override
  bool get musicEnabled =>
      _readBool(SettingsKeys.music, SettingsDefaults.music);

  @override
  Future<void> setMusicEnabled(bool enabled) =>
      _settings.put(SettingsKeys.music, enabled);

  @override
  Stream<bool> get musicEnabledChanges =>
      _settings.watch(key: SettingsKeys.music).map((event) {
        // As languageStream: a delete (or a rolled-back first write) reads
        // back as the default.
        if (event.deleted) return SettingsDefaults.music;
        final value = event.value;
        return value is bool ? value : SettingsDefaults.music;
      });

  @override
  bool get hapticsEnabled =>
      _readBool(SettingsKeys.haptics, SettingsDefaults.haptics);

  @override
  Future<void> setHapticsEnabled(bool enabled) =>
      _settings.put(SettingsKeys.haptics, enabled);

  @override
  SymbolsMode get symbolsMode => SymbolsMode.fromStorage(
    _settings.get(SettingsKeys.symbols),
    fallback: SettingsDefaults.symbols,
  );

  @override
  Future<void> setSymbolsMode(SymbolsMode mode) =>
      _settings.put(SettingsKeys.symbols, mode.storageValue);

  @override
  Stream<SymbolsMode> get symbolsModeChanges =>
      _settings.watch(key: SettingsKeys.symbols).map((event) {
        // As languageStream: a delete (or a rolled-back first write) reads
        // back as the default.
        if (event.deleted) return SettingsDefaults.symbols;
        return SymbolsMode.fromStorage(
          event.value,
          fallback: SettingsDefaults.symbols,
        );
      });

  @override
  bool get relaxedMode =>
      _readBool(SettingsKeys.relaxed, SettingsDefaults.relaxed);

  @override
  Future<void> setRelaxedMode(bool enabled) =>
      _settings.put(SettingsKeys.relaxed, enabled);

  @override
  Stream<bool> get relaxedModeChanges =>
      _settings.watch(key: SettingsKeys.relaxed).map((event) {
        // As languageStream: a delete (or a rolled-back first write) reads
        // back as the default.
        if (event.deleted) return SettingsDefaults.relaxed;
        final value = event.value;
        return value is bool ? value : SettingsDefaults.relaxed;
      });

  @override
  ReduceMotionMode get reduceMotion => ReduceMotionMode.fromStorage(
    _settings.get(SettingsKeys.reduceMotion),
    fallback: SettingsDefaults.reduceMotion,
  );

  @override
  Future<void> setReduceMotion(ReduceMotionMode mode) =>
      _settings.put(SettingsKeys.reduceMotion, mode.storageValue);

  @override
  Stream<ReduceMotionMode> get reduceMotionChanges =>
      _settings.watch(key: SettingsKeys.reduceMotion).map((event) {
        // As languageStream: a delete (or a rolled-back first write) reads
        // back as the default.
        if (event.deleted) return SettingsDefaults.reduceMotion;
        return ReduceMotionMode.fromStorage(
          event.value,
          fallback: SettingsDefaults.reduceMotion,
        );
      });

  @override
  ReminderSettings get reminder {
    const defaults = SettingsDefaults.reminder;
    return ReminderSettings(
      on: _readBool(SettingsKeys.reminderOn, defaults.on),
      hour: _readInt(SettingsKeys.reminderHour, defaults.hour, min: 0, max: 23),
      minute: _readInt(
        SettingsKeys.reminderMinute,
        defaults.minute,
        min: 0,
        max: 59,
      ),
      offered: _readBool(SettingsKeys.reminderOffered, defaults.offered),
    );
  }

  @override
  Future<void> setReminder(ReminderSettings reminder) => _settings.putAll({
    SettingsKeys.reminderOn: reminder.on,
    SettingsKeys.reminderHour: reminder.hour,
    SettingsKeys.reminderMinute: reminder.minute,
    SettingsKeys.reminderOffered: reminder.offered,
  });

  @override
  Stream<ReminderSettings> get reminderChanges {
    // The four keys of one putAll arrive as four events that all read the
    // same settings back, so only a value that differs from the last one
    // seen (starting from what is stored now) is emitted: one putAll, one
    // emission, and a write of the same settings is quiet. A delete reads
    // back as the default, as languageStream does.
    var last = reminder;
    return _settings
        .watch()
        .where((event) => SettingsKeys.reminder.contains(event.key))
        .map((_) => reminder)
        .where((next) {
          if (next == last) return false;
          last = next;
          return true;
        });
  }

  @override
  String get languageCode =>
      _readString(SettingsKeys.locale, SettingsDefaults.locale);

  @override
  Future<void> setLanguage(String languageCode) =>
      _settings.put(SettingsKeys.locale, languageCode);

  @override
  Stream<String> get languageStream =>
      _settings.watch(key: SettingsKeys.locale).map((event) {
        // hive_ce puts the *removed* value on a delete event, and a failed
        // first write rolls back as a delete carrying the value that never
        // persisted. A deleted key reads back as the default, so emit that.
        if (event.deleted) return SettingsDefaults.locale;
        final value = event.value;
        return value is String ? value : SettingsDefaults.locale;
      });

  @override
  String? readSaveDocument() => readSaveBackup(SaveBoxKeys.document);

  @override
  Future<void> writeSaveDocument(String json) =>
      _save.put(SaveBoxKeys.document, json);

  @override
  String? readSaveBackup(String key) {
    final value = _save.get(key);
    return value is String ? value : null;
  }

  @override
  Future<void> writeSaveBackup(String key, String json) => _save.put(key, json);

  @override
  Future<void> flushSave() => _save.flush();

  @override
  Future<void> close() => Hive.close();
}
