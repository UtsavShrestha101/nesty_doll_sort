import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_game/core/models/reduce_motion_mode.dart';
import 'package:nesty_game/core/models/reminder_settings.dart';
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
      // M7 phase 5B (l10n plan §1.4): the language follows the phone until
      // one is picked; spec §13.3's example "en" is a recorded deviation.
      expect(database.languageCode, LocaleSetting.system);
      expect(SettingsDefaults.locale, LocaleSetting.system);
      // M7 (m7-design §4): relaxed mode off, reduce motion follows the OS.
      expect(database.relaxedMode, isFalse);
      expect(database.reduceMotion, ReduceMotionMode.system);
      // M7 phase 3 (m7-design P3.10): the reminder is off, at 19:00, and
      // was never offered (spec-prop §7.9 "off until the player accepts").
      expect(database.reminder, const ReminderSettings());
      expect(database.reminder.on, isFalse);
      expect(database.reminder.hour, 19);
      expect(database.reminder.minute, 0);
      expect(database.reminder.offered, isFalse);
    });

    test('relitGlowSeen and lastRival: defaults, round trips, range', () async {
      expect(database.relitGlowSeen, isNull);
      expect(database.lastRival, 0);
      await database.setRelitGlowSeen('2026-10-05');
      await database.setLastRival(2);
      expect(database.relitGlowSeen, '2026-10-05');
      expect(database.lastRival, 2);
      await database.setLastRival(7);
      expect(database.lastRival, 0, reason: 'only rivals 1-3 exist');
    });

    test(
      'lastOpenDate and welcomeBackDate: defaults, round trips, clear',
      () async {
        expect(database.lastOpenDate, isNull);
        expect(database.welcomeBackDate, isNull);
        await database.setLastOpenDate('2026-10-05');
        await database.setWelcomeBackDate('2026-10-08');
        expect(database.lastOpenDate, '2026-10-05');
        expect(database.welcomeBackDate, '2026-10-08');
        await database.setWelcomeBackDate(null);
        expect(database.welcomeBackDate, isNull);
        expect(database.lastOpenDate, '2026-10-05');
      },
    );

    test('every setting reads back what was written', () async {
      await database.setSoundEnabled(false);
      await database.setMusicEnabled(false);
      await database.setHapticsEnabled(false);
      await database.setSymbolsMode(SymbolsMode.large);
      await database.setLanguage('pt_BR');
      await database.setRelaxedMode(true);
      await database.setReduceMotion(ReduceMotionMode.on);

      expect(database.relaxedMode, isTrue);
      expect(database.reduceMotion, ReduceMotionMode.on);
      expect(database.soundEnabled, isFalse);
      expect(database.musicEnabled, isFalse);
      expect(database.hapticsEnabled, isFalse);
      expect(database.symbolsMode, SymbolsMode.large);
      expect(database.languageCode, 'pt_BR');
    });

    test('the language setting stores "system" and a pinned "en" as given '
        '(the resolver, not the store, picks the rendered language)', () async {
      await database.setLanguage('en');
      expect(database.languageCode, 'en');
      await database.setLanguage(LocaleSetting.system);
      expect(database.languageCode, LocaleSetting.system);
      await database.setLanguage('pt_BR');
      expect(database.languageCode, 'pt_BR');
    });

    test('languageStream emits "system" when the player goes back to the '
        "phone's language", () async {
      await database.setLanguage('de');
      final emitted = expectLater(
        database.languageStream,
        emitsInOrder([LocaleSetting.system, 'en']),
      );
      await database.setLanguage(LocaleSetting.system);
      await database.setLanguage('en');
      await emitted;
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

    test(
      'relaxedModeChanges emits each stored Relaxed mode, as relaxedMode '
      'then reads it (the gameplay bloc follows it, m7-design §10)',
      () async {
        final seen = <(bool, bool)>[];
        final subscription = database.relaxedModeChanges.listen(
          (value) => seen.add((value, database.relaxedMode)),
        );
        addTearDown(subscription.cancel);
        await database.setRelaxedMode(true);
        await database.setRelaxedMode(false);
        await pumpEventQueue();
        expect(seen, [(true, true), (false, false)]);
      },
    );

    test('reduceMotionChanges emits each stored override, as reduceMotion '
        'then reads it (the app root follows it, m7-design §14)', () async {
      final seen = <(ReduceMotionMode, ReduceMotionMode)>[];
      final subscription = database.reduceMotionChanges.listen(
        (mode) => seen.add((mode, database.reduceMotion)),
      );
      addTearDown(subscription.cancel);
      await database.setReduceMotion(ReduceMotionMode.off);
      await database.setReduceMotion(ReduceMotionMode.system);
      await pumpEventQueue();
      expect(seen, [
        (ReduceMotionMode.off, ReduceMotionMode.off),
        (ReduceMotionMode.system, ReduceMotionMode.system),
      ]);
    });

    test('the reminder reads back what was written, and reminderChanges '
        'emits once per change, as reminder then reads it (m7-design '
        'P3.10)', () async {
      final seen = <(ReminderSettings, ReminderSettings)>[];
      final subscription = database.reminderChanges.listen(
        (value) => seen.add((value, database.reminder)),
      );
      addTearDown(subscription.cancel);
      const on = ReminderSettings(on: true, hour: 8, minute: 30, offered: true);
      await database.setReminder(on);
      await pumpEventQueue();
      await database.setReminder(on);
      await pumpEventQueue();
      const off = ReminderSettings(hour: 8, minute: 30, offered: true);
      await database.setReminder(off);
      await pumpEventQueue();
      expect(database.reminder, off);
      expect(seen, [(on, on), (off, off)]);
    });

    test('the other settings leave the M7 streams quiet', () async {
      final relaxed = <bool>[];
      final motion = <ReduceMotionMode>[];
      final reminder = <ReminderSettings>[];
      final a = database.relaxedModeChanges.listen(relaxed.add);
      final b = database.reduceMotionChanges.listen(motion.add);
      final c = database.reminderChanges.listen(reminder.add);
      addTearDown(a.cancel);
      addTearDown(b.cancel);
      addTearDown(c.cancel);
      await database.setSoundEnabled(false);
      await database.setMusicEnabled(false);
      await database.setSymbolsMode(SymbolsMode.subtle);
      await database.setLanguage('fr');
      await pumpEventQueue();
      expect(relaxed, isEmpty);
      expect(motion, isEmpty);
      expect(reminder, isEmpty);
    });
  });
}
