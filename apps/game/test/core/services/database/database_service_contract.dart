import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_game/core/models/symbols_mode.dart';
import 'package:nesty_game/core/services/database/database_service.dart';
import 'package:nesty_game/core/services/database/settings_schema.dart';

/// Behavior every [DatabaseService] must share, run against both the Hive
/// and the fake implementation so the fake can't drift from the real thing.
void runDatabaseServiceContract(
  String name,
  Future<DatabaseService> Function() create,
) {
  group('$name (DatabaseService contract)', () {
    late DatabaseService database;

    setUp(() async => database = await create());
    tearDown(() => database.close());

    test('a fresh store returns the spec §13.3 defaults', () {
      expect(database.soundEnabled, SettingsDefaults.sound);
      expect(database.musicEnabled, SettingsDefaults.music);
      expect(database.hapticsEnabled, SettingsDefaults.haptics);
      expect(database.symbolsMode, SymbolsMode.subtle);
      expect(database.languageCode, 'en');
    });

    test('every setting reads back what was written', () async {
      await database.setSoundEnabled(false);
      await database.setMusicEnabled(false);
      await database.setHapticsEnabled(false);
      await database.setSymbolsMode(SymbolsMode.large);
      await database.setLanguage('pt_BR');

      expect(database.soundEnabled, isFalse);
      expect(database.musicEnabled, isFalse);
      expect(database.hapticsEnabled, isFalse);
      expect(database.symbolsMode, SymbolsMode.large);
      expect(database.languageCode, 'pt_BR');
    });

    test('languageStream emits each stored locale', () async {
      final emitted = expectLater(
        database.languageStream,
        emitsInOrder(['de', 'fr']),
      );
      await database.setLanguage('de');
      await database.setLanguage('fr');
      await emitted;
    });
  });
}
