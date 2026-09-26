import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive_ce.dart';
import 'package:nesty_game/core/models/symbols_mode.dart';
import 'package:nesty_game/core/services/database/fake_database_service.dart';
import 'package:nesty_game/core/services/database/hive_boxes.dart';
import 'package:nesty_game/core/services/database/hive_database_service.dart';
import 'package:nesty_game/core/services/database/settings_schema.dart';

import 'database_service_contract.dart';

/// Real Hive on a temp directory via pure-Dart `Hive.init` — no platform
/// channels, so this runs under plain `flutter test`.
void main() {
  late Directory directory;

  setUp(() async {
    directory = await Directory.systemTemp.createTemp('nesty_hive_test_');
  });

  tearDown(() async {
    await Hive.close();
    if (directory.existsSync()) await directory.delete(recursive: true);
  });

  runDatabaseServiceContract(
    'HiveDatabaseService',
    () => HiveDatabaseService.open(directory: directory.path),
  );

  test('settings survive closing and reopening the box', () async {
    final first = await HiveDatabaseService.open(directory: directory.path);
    await first.setHapticsEnabled(false);
    await first.setSymbolsMode(SymbolsMode.assist);
    await first.setLanguage('ja');
    await first.close();
    expect(Hive.isBoxOpen(HiveBoxes.settings), isFalse);

    final second = await HiveDatabaseService.open(directory: directory.path);
    expect(second.hapticsEnabled, isFalse);
    expect(second.symbolsMode, SymbolsMode.assist);
    expect(second.languageCode, 'ja');
    expect(second.soundEnabled, SettingsDefaults.sound);
    await second.close();
  });

  test('values of the wrong type fall back to defaults', () async {
    Hive.init(directory.path);
    final raw = await Hive.openBox<Object>(HiveBoxes.settings);
    await raw.put(SettingsKeys.sound, 'not a bool');
    await raw.put(SettingsKeys.locale, 42);
    await raw.put(SettingsKeys.symbols, 'from-the-future');
    await raw.close();

    final database = await HiveDatabaseService.open(directory: directory.path);
    expect(database.soundEnabled, SettingsDefaults.sound);
    expect(database.languageCode, SettingsDefaults.locale);
    expect(database.symbolsMode, SettingsDefaults.symbols);
    await database.close();
  });

  test('deleting the stored locale emits the default', () async {
    final database = await HiveDatabaseService.open(directory: directory.path);
    await database.setLanguage('fr');

    final next = database.languageStream.first;
    await Hive.box<Object>(HiveBoxes.settings).delete(SettingsKeys.locale);

    expect(await next, SettingsDefaults.locale);
    expect(database.languageCode, SettingsDefaults.locale);
    await database.close();
  });

  test(
    'a first write that fails and rolls back ends on the stored value',
    () async {
      final database = await HiveDatabaseService.open(
        directory: directory.path,
      );
      final emitted = <String>[];
      final subscription = database.languageStream.listen(emitted.add);
      addTearDown(subscription.cancel);

      // No adapter for _Unserializable, so the batch write throws and Hive
      // rolls back the locale it had already announced.
      await expectLater(
        Hive.box<Object>(
          HiveBoxes.settings,
        ).putAll({SettingsKeys.locale: 'fr', 'probe': _Unserializable()}),
        throwsA(anything),
      );
      await pumpEventQueue();

      expect(database.languageCode, SettingsDefaults.locale);
      expect(emitted, isNotEmpty);
      expect(emitted.last, database.languageCode);
      await database.close();
    },
  );

  test(
    'openOrFallback returns the in-memory store when Hive cannot open',
    () async {
      // A regular file where Hive expects a directory: opening the box fails.
      final notADirectory = File('${directory.path}/blocker')..createSync();

      final database = await HiveDatabaseService.openOrFallback(
        directory: notADirectory.path,
      );

      expect(database, isA<FakeDatabaseService>());
      expect(database.languageCode, SettingsDefaults.locale);
      await database.close();
    },
  );
}

/// A type with no registered Hive adapter, to make a write fail.
class _Unserializable {}
