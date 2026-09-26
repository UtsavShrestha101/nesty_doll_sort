import 'package:nesty_game/core/models/symbols_mode.dart';

/// Local key-value storage for device settings (spec §13.3 `"settings"`).
///
/// Implementations: `HiveDatabaseService` (real) and `FakeDatabaseService`
/// (in-memory; tests, fake env and the fallback when Hive can't open).
/// Every read is synchronous — boxes are opened once during bootstrap, never
/// lazily in features.
///
/// TODO(M3): the save document (currentLevel, coins, inventory, inProgress…,
/// spec §13.3) is NOT here yet. M3 decides whether it lives in a Hive box or
/// in the spec's atomic JSON file; see docs/PROGRESS.md open questions.
abstract interface class DatabaseService {
  bool get soundEnabled;
  Future<void> setSoundEnabled(bool enabled);

  bool get musicEnabled;
  Future<void> setMusicEnabled(bool enabled);

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

  /// Flushes and closes the underlying storage. Called on DI reset.
  Future<void> close();
}
