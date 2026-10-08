import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive_ce.dart';
import 'package:nesty_game/core/models/symbols_mode.dart';
import 'package:nesty_game/core/services/database/database_service.dart';
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
    await first.setSymbolsMode(SymbolsMode.large);
    await first.setLanguage('ja');
    await first.close();
    expect(Hive.isBoxOpen(HiveBoxes.settings), isFalse);

    final second = await HiveDatabaseService.open(directory: directory.path);
    expect(second.hapticsEnabled, isFalse);
    expect(second.symbolsMode, SymbolsMode.large);
    expect(second.languageCode, 'ja');
    expect(second.soundEnabled, SettingsDefaults.sound);
    await second.close();
  });

  group('the language setting across installs (M7 phase 5B, l10n plan '
      '§1.4: the same key, no schema step)', () {
    test('a settings box from before "system" existed, with no locale key, '
        'reads "system" (follow the phone)', () async {
      Hive.init(directory.path);
      final raw = await Hive.openBox<Object>(HiveBoxes.settings);
      await raw.put(SettingsKeys.sound, false);
      await raw.put(SettingsKeys.symbols, 'large');
      await raw.close();

      final database = await HiveDatabaseService.open(
        directory: directory.path,
      );
      expect(database.soundEnabled, isFalse, reason: 'the old box is read');
      expect(database.languageCode, LocaleSetting.system);
      await database.close();
    });

    test('a stored "en" from an older build stays pinned to English', () async {
      Hive.init(directory.path);
      final raw = await Hive.openBox<Object>(HiveBoxes.settings);
      await raw.put(SettingsKeys.locale, 'en');
      await raw.close();

      final database = await HiveDatabaseService.open(
        directory: directory.path,
      );
      expect(database.languageCode, 'en');
      await database.close();
    });

    test('"system" and a pinned code survive closing and reopening, under '
        'the same key', () async {
      final first = await HiveDatabaseService.open(directory: directory.path);
      await first.setLanguage(LocaleSetting.system);
      await first.close();
      final second = await HiveDatabaseService.open(directory: directory.path);
      expect(second.languageCode, LocaleSetting.system);
      expect(
        Hive.box<Object>(HiveBoxes.settings).get(SettingsKeys.locale),
        LocaleSetting.system,
      );
      await second.setLanguage('pt_BR');
      await second.close();
      final third = await HiveDatabaseService.open(directory: directory.path);
      expect(third.languageCode, 'pt_BR');
      await third.close();
    });
  });

  test('a legacy stored "assist" reads as large symbols and is rewritten as '
      '"large" on the next write (PROGRESS D19)', () async {
    Hive.init(directory.path);
    final raw = await Hive.openBox<Object>(HiveBoxes.settings);
    await raw.put(SettingsKeys.symbols, 'assist');
    await raw.close();

    final database = await HiveDatabaseService.open(directory: directory.path);
    expect(database.symbolsMode, SymbolsMode.large);

    await database.setSymbolsMode(database.symbolsMode);
    expect(
      Hive.box<Object>(HiveBoxes.settings).get(SettingsKeys.symbols),
      'large',
    );
    await database.close();
  });

  test('reminder values of the wrong type or out of range read as their '
      'defaults (m7-design P3.10)', () async {
    Hive.init(directory.path);
    final raw = await Hive.openBox<Object>(HiveBoxes.settings);
    await raw.put(SettingsKeys.reminderOn, 'yes');
    await raw.put(SettingsKeys.reminderHour, 24);
    await raw.put(SettingsKeys.reminderMinute, 7);
    await raw.put(SettingsKeys.reminderOffered, true);
    await raw.close();

    final database = await HiveDatabaseService.open(directory: directory.path);
    expect(database.reminder.on, isFalse);
    expect(database.reminder.hour, SettingsDefaults.reminder.hour);
    expect(database.reminder.minute, 7);
    expect(database.reminder.offered, isTrue);
    await database.close();
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

  test('relitGlowSeen and lastRival of the wrong type or range read as '
      'unset', () async {
    Hive.init(directory.path);
    final raw = await Hive.openBox<Object>(HiveBoxes.settings);
    await raw.put(SettingsKeys.lastRival, 'x');
    await raw.put(SettingsKeys.relitGlowSeen, 3);
    await raw.close();

    final database = await HiveDatabaseService.open(directory: directory.path);
    expect(database.lastRival, 0);
    expect(database.relitGlowSeen, isNull);
    await database.close();
  });

  test(
    'lastOpenDate and welcomeBackDate of the wrong type read as unset',
    () async {
      Hive.init(directory.path);
      final raw = await Hive.openBox<Object>(HiveBoxes.settings);
      await raw.put(SettingsKeys.lastOpenDate, 3);
      await raw.put(SettingsKeys.welcomeBackDate, true);
      await raw.close();

      final database = await HiveDatabaseService.open(
        directory: directory.path,
      );
      expect(database.lastOpenDate, isNull);
      expect(database.welcomeBackDate, isNull);
      await database.close();
    },
  );

  test('deleting the stored locale emits the default', () async {
    final database = await HiveDatabaseService.open(directory: directory.path);
    await database.setLanguage('fr');

    final next = database.languageStream.first;
    await Hive.box<Object>(HiveBoxes.settings).delete(SettingsKeys.locale);

    expect(await next, SettingsDefaults.locale);
    expect(database.languageCode, SettingsDefaults.locale);
    await database.close();
  });

  test('deleting the stored Music setting emits the default', () async {
    final database = await HiveDatabaseService.open(directory: directory.path);
    await database.setMusicEnabled(false);

    final next = database.musicEnabledChanges.first;
    await Hive.box<Object>(HiveBoxes.settings).delete(SettingsKeys.music);

    expect(await next, SettingsDefaults.music);
    expect(database.musicEnabled, SettingsDefaults.music);
    await database.close();
  });

  test('a Music setting of the wrong type emits the default', () async {
    final database = await HiveDatabaseService.open(directory: directory.path);

    final next = database.musicEnabledChanges.first;
    await Hive.box<Object>(HiveBoxes.settings).put(SettingsKeys.music, 'on');

    expect(await next, SettingsDefaults.music);
    expect(database.musicEnabled, SettingsDefaults.music);
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
      // Marked, so the reminder never takes its default "off" for the
      // player's answer (M7 review R30).
      expect(database, isA<SessionOnlyDatabase>());
      expect(database.languageCode, SettingsDefaults.locale);
      await database.close();
    },
  );
}

/// A type with no registered Hive adapter, to make a write fail.
class _Unserializable {}
