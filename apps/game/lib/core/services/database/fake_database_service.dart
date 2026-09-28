import 'dart:async';

import 'package:injectable/injectable.dart';
import 'package:nesty_game/core/dependency_injection/app_env.dart';
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

  bool _sound = SettingsDefaults.sound;
  bool _music = SettingsDefaults.music;
  bool _haptics = SettingsDefaults.haptics;
  SymbolsMode _symbols = SettingsDefaults.symbols;
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
  Future<void> setSymbolsMode(SymbolsMode mode) async => _symbols = mode;

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
  }
}
