import 'package:nesty_game/core/models/symbols_mode.dart';

/// Local storage: device settings (spec §13.3 `"settings"`) and the raw
/// save document (§13.3, D63).
///
/// Implementations: `HiveDatabaseService` (real) and `FakeDatabaseService`
/// (in-memory; tests, fake env and the fallback when Hive can't open).
/// Every read is synchronous — boxes are opened once during bootstrap, never
/// lazily in features.
///
/// Only `SaveService` reads and writes the save document; it holds the
/// schema, the migrations and the lenient decoding (docs/plans/m3-design.md
/// §3). This layer stores its text as it is given.
abstract interface class DatabaseService {
  bool get soundEnabled;
  Future<void> setSoundEnabled(bool enabled);

  bool get musicEnabled;
  Future<void> setMusicEnabled(bool enabled);

  /// Emits the Music setting every time the stored value changes, including
  /// a rollback or deletion back to the default. Each emission equals what
  /// [musicEnabled] reads at that point. The music service follows it, so
  /// the Pause and Settings toggles only write the setting.
  Stream<bool> get musicEnabledChanges;

  bool get hapticsEnabled;
  Future<void> setHapticsEnabled(bool enabled);

  SymbolsMode get symbolsMode;
  Future<void> setSymbolsMode(SymbolsMode mode);

  /// Persisted locale code, e.g. `en` or `pt_BR`.
  String get languageCode;
  Future<void> setLanguage(String languageCode);

  /// Emits the locale every time the stored value changes, including a
  /// rollback or deletion back to the default. Each emission equals what
  /// [languageCode] reads at that point.
  Stream<String> get languageStream;

  /// The stored save document text (`SaveBoxKeys.document`), or null when
  /// there is none or the stored value is not a string.
  String? readSaveDocument();

  /// Stores [json] as the save document: one write of one key.
  Future<void> writeSaveDocument(String json);

  /// The text kept under [key] of the save box (`SaveBoxKeys.backup`,
  /// `SaveBoxKeys.invalidBackup`), or null.
  String? readSaveBackup(String key);

  /// Keeps [json] under the save box's [key].
  Future<void> writeSaveBackup(String key, String json);

  /// Makes the save box's writes durable (Hive's `flush`). Called on
  /// `AppLifecycleState.paused`/`detached`.
  Future<void> flushSave();

  /// Flushes and closes the underlying storage. Called on DI reset.
  Future<void> close();
}
