import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_game/core/models/symbols_mode.dart';
import 'package:nesty_game/core/services/database/database_service.dart';
import 'package:nesty_game/core/services/database/hive_boxes.dart';
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

    test('the save document text reads back as written (D63, '
        'm3-design §3.2)', () async {
      expect(database.readSaveDocument(), isNull);
      await database.writeSaveDocument('{"schema":1}');
      await database.writeSaveDocument('{"schema":1,"coins":5}');
      expect(database.readSaveDocument(), '{"schema":1,"coins":5}');
      expect(database.readSaveBackup(SaveBoxKeys.backup(0)), isNull);
      await database.writeSaveBackup(SaveBoxKeys.backup(0), 'old');
      await database.writeSaveBackup(SaveBoxKeys.invalidBackup, 'bad');
      await database.flushSave();
      expect(database.readSaveBackup(SaveBoxKeys.backup(0)), 'old');
      expect(database.readSaveBackup(SaveBoxKeys.invalidBackup), 'bad');
      expect(database.readSaveDocument(), '{"schema":1,"coins":5}');
    });

    test('a fresh store returns the spec §13.3 defaults', () {
      expect(database.soundEnabled, SettingsDefaults.sound);
      expect(database.musicEnabled, SettingsDefaults.music);
      expect(database.hapticsEnabled, SettingsDefaults.haptics);
      expect(database.symbolsMode, SettingsDefaults.symbols);
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

    test('musicEnabledChanges emits each stored Music setting, as '
        'musicEnabled then reads it (the music service follows it)', () async {
      final seen = <(bool, bool)>[];
      final subscription = database.musicEnabledChanges.listen(
        (value) => seen.add((value, database.musicEnabled)),
      );
      addTearDown(subscription.cancel);
      await database.setMusicEnabled(false);
      await database.setMusicEnabled(true);
      await pumpEventQueue();
      expect(seen, [(false, false), (true, true)]);
    });

    test('symbolsModeChanges emits each stored Color symbols mode, as '
        'symbolsMode then reads it (the doll art follows it, D91)', () async {
      final seen = <(SymbolsMode, SymbolsMode)>[];
      final subscription = database.symbolsModeChanges.listen(
        (mode) => seen.add((mode, database.symbolsMode)),
      );
      addTearDown(subscription.cancel);
      await database.setSymbolsMode(SymbolsMode.subtle);
      await database.setSymbolsMode(SymbolsMode.large);
      await pumpEventQueue();
      expect(seen, [
        (SymbolsMode.subtle, SymbolsMode.subtle),
        (SymbolsMode.large, SymbolsMode.large),
      ]);
    });

    test('the other settings leave symbolsModeChanges quiet', () async {
      final seen = <SymbolsMode>[];
      final subscription = database.symbolsModeChanges.listen(seen.add);
      addTearDown(subscription.cancel);
      await database.setSoundEnabled(false);
      await database.setMusicEnabled(false);
      await database.setHapticsEnabled(false);
      await database.setLanguage('fr');
      await pumpEventQueue();
      expect(seen, isEmpty);
    });

    test('the other settings leave musicEnabledChanges quiet', () async {
      final seen = <bool>[];
      final subscription = database.musicEnabledChanges.listen(seen.add);
      addTearDown(subscription.cancel);
      await database.setSoundEnabled(false);
      await database.setHapticsEnabled(false);
      await database.setLanguage('fr');
      await pumpEventQueue();
      expect(seen, isEmpty);
    });
  });
}
