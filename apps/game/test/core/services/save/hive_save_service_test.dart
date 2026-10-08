import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive_ce.dart';
import 'package:nesty_game/core/models/play_request.dart';
import 'package:nesty_game/core/models/reduce_motion_mode.dart';
import 'package:nesty_game/core/models/reminder_settings.dart';
import 'package:nesty_game/core/models/symbols_mode.dart';
import 'package:nesty_game/core/services/clock/local_date.dart';
import 'package:nesty_game/core/services/database/database_service.dart';
import 'package:nesty_game/core/services/database/fake_database_service.dart';
import 'package:nesty_game/core/services/database/hive_boxes.dart';
import 'package:nesty_game/core/services/database/hive_database_service.dart';
import 'package:nesty_game/core/services/remote_config/fake_remote_config_service.dart';
import 'package:nesty_game/core/services/save/hive_save_service.dart';
import 'package:nesty_game/core/services/save/save_document.dart';
import 'package:nesty_game/core/services/save/save_document_codec.dart';

import 'save_migrations_test.dart' show schema1Document, schema2Document;

/// A [DatabaseService] proxy that counts and can pause `writeSaveDocument`
/// calls, for the write-queue coalescing test.
final class _GatedDatabaseService implements DatabaseService {
  _GatedDatabaseService(this._inner);

  final DatabaseService _inner;

  /// Every document text passed to [writeSaveDocument], in order.
  final List<String> writes = [];

  /// While set, [writeSaveDocument] waits for it before delegating.
  Completer<void>? gate;

  @override
  Future<void> writeSaveDocument(String json) async {
    writes.add(json);
    final g = gate;
    if (g != null) await g.future;
    await _inner.writeSaveDocument(json);
  }

  @override
  String? readSaveDocument() => _inner.readSaveDocument();

  @override
  String? readSaveBackup(String key) => _inner.readSaveBackup(key);

  @override
  Future<void> writeSaveBackup(String key, String json) =>
      _inner.writeSaveBackup(key, json);

  @override
  Future<void> flushSave() => _inner.flushSave();

  @override
  Future<void> close() => _inner.close();

  @override
  String? get relitGlowSeen => _inner.relitGlowSeen;
  @override
  Future<void> setRelitGlowSeen(String date) => _inner.setRelitGlowSeen(date);
  @override
  String? get lastOpenDate => _inner.lastOpenDate;
  @override
  Future<void> setLastOpenDate(String date) => _inner.setLastOpenDate(date);
  @override
  String? get welcomeBackDate => _inner.welcomeBackDate;
  @override
  Future<void> setWelcomeBackDate(String? date) =>
      _inner.setWelcomeBackDate(date);
  @override
  int get lastRival => _inner.lastRival;
  @override
  Future<void> setLastRival(int rival) => _inner.setLastRival(rival);
  @override
  bool get soundEnabled => _inner.soundEnabled;
  @override
  Future<void> setSoundEnabled(bool enabled) => _inner.setSoundEnabled(enabled);
  @override
  bool get musicEnabled => _inner.musicEnabled;
  @override
  Future<void> setMusicEnabled(bool enabled) => _inner.setMusicEnabled(enabled);
  @override
  Stream<bool> get musicEnabledChanges => _inner.musicEnabledChanges;
  @override
  bool get hapticsEnabled => _inner.hapticsEnabled;
  @override
  Future<void> setHapticsEnabled(bool enabled) =>
      _inner.setHapticsEnabled(enabled);
  @override
  SymbolsMode get symbolsMode => _inner.symbolsMode;
  @override
  Future<void> setSymbolsMode(SymbolsMode mode) => _inner.setSymbolsMode(mode);
  @override
  Stream<SymbolsMode> get symbolsModeChanges => _inner.symbolsModeChanges;
  @override
  bool get relaxedMode => _inner.relaxedMode;
  @override
  Future<void> setRelaxedMode(bool enabled) => _inner.setRelaxedMode(enabled);
  @override
  Stream<bool> get relaxedModeChanges => _inner.relaxedModeChanges;
  @override
  ReduceMotionMode get reduceMotion => _inner.reduceMotion;
  @override
  Future<void> setReduceMotion(ReduceMotionMode mode) =>
      _inner.setReduceMotion(mode);
  @override
  Stream<ReduceMotionMode> get reduceMotionChanges =>
      _inner.reduceMotionChanges;
  @override
  ReminderSettings get reminder => _inner.reminder;
  @override
  Future<void> setReminder(ReminderSettings reminder) =>
      _inner.setReminder(reminder);
  @override
  Stream<ReminderSettings> get reminderChanges => _inner.reminderChanges;
  @override
  String get languageCode => _inner.languageCode;
  @override
  Future<void> setLanguage(String languageCode) =>
      _inner.setLanguage(languageCode);
  @override
  Stream<String> get languageStream => _inner.languageStream;
}

void main() {
  group('HiveSaveService on a temp-directory Hive box', () {
    late Directory directory;

    setUp(() async {
      directory = await Directory.systemTemp.createTemp('nesty_save_test_');
    });

    tearDown(() async {
      await Hive.close();
      if (directory.existsSync()) await directory.delete(recursive: true);
    });

    test('round trip: what one instance saves, the next reads back', () async {
      final first = await HiveDatabaseService.open(directory: directory.path);
      final save = HiveSaveService(first, FakeRemoteConfigService());
      await save.load();
      save.addCoins(40);
      save.currentLevel = 5;
      await save.flush();
      await first.close();

      final second = await HiveDatabaseService.open(directory: directory.path);
      final reload = HiveSaveService(second, FakeRemoteConfigService());
      await reload.load();
      expect(reload.coins, 40);
      expect(reload.currentLevel, 5);
      expect(reload.playerId, save.playerId);
      await reload.dispose();
    });

    test('round trip: every schema-3 field survives a real Hive write and '
        'reload (m7-design §3.2; plan-login-gift §7.5b)', () async {
      final full = SaveDocument(
        currentLevel: 24,
        highestLevel: 26,
        coins: 830,
        inventory: const BoosterInventory(hint: 1, slot: 0),
        ownedSkins: const ['classic', 'ocean'],
        selectedSkin: 'ocean',
        ownedThemes: const ['ch01', 'ch05'],
        selectedTheme: 'ch05',
        museum: const ['ch01'],
        museumCollected: {'ch01': LocalDate(2026, 9, 12)},
        daily: DailyProgress(
          streak: 9,
          lit: true,
          run: 2,
          lastDate: LocalDate(2026, 9, 27),
          freezes: 1,
          freezeWeek: 202639,
          done: [LocalDate(2026, 9, 26), LocalDate(2026, 9, 27)],
          frozen: [LocalDate(2026, 9, 25)],
          noticeDate: LocalDate(2026, 9, 25),
          chestPending: true,
          // The share text's and the reminder offer's facts (m7-design
          // P3.4).
          lastSolve: DailySolve(
            date: LocalDate(2026, 9, 27),
            moves: 22,
            families: 6,
            minuteOfDay: 1200,
          ),
        ),
        inProgress: const InProgressLevel(
          request: PlayRequest.campaign(24),
          levelId: 'L0024',
          levelVersion: 2,
          session: {'format': 1, 'undosUsed': 1},
          // A hint since the last Restart (Q116; m7-design P3.6).
          hinted: true,
        ),
        adCounters: const AdCounters(winsSinceInterstitial: 1, lastAdAt: 5),
        stats: const SaveStats(wins: 23, moves: 612, boostersUsed: {'hint': 2}),
        seenIntros: const ['towers'],
        tutorialDone: true,
        bonus: const BonusProgress(next: 3),
        playerId: '7F3A-21C9',
        levelBests: const {'L0024@2': 16, 'L0003@1': 9},
        // The star rating's best per level id (m7-design P3.4).
        levelStars: const {'L0024': 3, 'L0003': 1},
        starTipShown: true,
        records: const SaveRecords(
          families: 212,
          dolls: 780,
          // Below the derivable badge thresholds, and `first_family` (the
          // one 23 wins would otherwise grant on load) is already listed,
          // so `SaveService.load`'s silent badge grant is a no-op here:
          // this test is only about storage, not badge rules.
          dailies: 5,
          longestRun: 9,
          badges: ['first_family'],
        ),
        chests: const ChestProgress(opened: [10], bonusOpened: [10, 20]),
        race: const RaceProgress(
          rivals: [
            RivalProgress(unlocked: true, raceNo: 5),
            RivalProgress(unlocked: true, raceNo: 1),
            RivalProgress(),
          ],
        ),
        // Schema 3's daily gift: the next claim pays Day 2 of the second
        // week.
        loginGift: LoginGiftProgress(
          claims: 8,
          lastClaim: LocalDate(2026, 10, 4),
          latestSeen: LocalDate(2026, 10, 5),
        ),
        unknown: const {'zeta': 1, 'alpha': 'kept'},
      );

      final first = await HiveDatabaseService.open(directory: directory.path);
      await first.writeSaveDocument(SaveDocumentCodec.write(full));
      await first.flushSave();
      final save = HiveSaveService(first, FakeRemoteConfigService());
      await save.load();
      // The load-time badge grant found nothing new (see above): the
      // document read back is exactly what was written.
      expect(save.document, full);
      await save.flush();
      await first.close();

      final second = await HiveDatabaseService.open(directory: directory.path);
      final reload = HiveSaveService(second, FakeRemoteConfigService());
      await reload.load();
      expect(reload.document, full);
      await reload.dispose();
    });

    test('migration 0 (no document): a fresh install gets the defaults and '
        'a player id, with nothing to back up', () async {
      final database = await HiveDatabaseService.open(
        directory: directory.path,
      );
      expect(database.readSaveDocument(), isNull);

      final save = HiveSaveService(database, FakeRemoteConfigService());
      await save.load();

      expect(save.currentLevel, 1);
      expect(save.coins, 0);
      expect(SaveDocumentCodec.playerIdPattern.hasMatch(save.playerId), isTrue);
      await save.flush();
      // A fresh install is not "invalid" or "migrated": nothing backed up.
      expect(database.readSaveBackup(SaveBoxKeys.backup(0)), isNull);
      expect(database.readSaveBackup(SaveBoxKeys.invalidBackup), isNull);
      await save.dispose();
    });

    test('a corrupt document (not JSON) reads as the defaults and is backed '
        'up once under doc_backup_invalid', () async {
      final database = await HiveDatabaseService.open(
        directory: directory.path,
      );
      await database.writeSaveDocument('not json at all');
      await database.flushSave();

      final save = HiveSaveService(database, FakeRemoteConfigService());
      await save.load();
      expect(save.coins, 0);
      expect(save.currentLevel, 1);
      await save.flush();

      expect(
        database.readSaveBackup(SaveBoxKeys.invalidBackup),
        'not json at all',
      );
      // A second bad load must never overwrite an existing backup.
      await database.writeSaveDocument('still not json');
      final second = HiveSaveService(database, FakeRemoteConfigService());
      await second.load();
      await second.flush();
      expect(
        database.readSaveBackup(SaveBoxKeys.invalidBackup),
        'not json at all',
      );
      await second.dispose();
    });

    test('a newer schema is read leniently, its unknown keys kept, and '
        'backed up once under doc_backup_v<n>', () async {
      final database = await HiveDatabaseService.open(
        directory: directory.path,
      );
      // Above `SaveDocument.currentSchema` (3), so it still means "newer".
      const future =
          '{"schema":4,"currentLevel":9,"coins":70,"aFutureKey":"x",'
          '"loginGift":{"claims":5,"lastClaim":"2026-10-04"}}';
      await database.writeSaveDocument(future);
      await database.flushSave();

      final save = HiveSaveService(database, FakeRemoteConfigService());
      await save.load();
      expect(save.currentLevel, 9);
      expect(save.coins, 70);
      expect(save.document.unknown['aFutureKey'], 'x');
      // A known key in a newer document is read like any other.
      expect(save.document.loginGift.claims, 5);
      await save.flush();

      expect(SaveDocument.currentSchema, lessThan(4));
      expect(database.readSaveBackup(SaveBoxKeys.backup(4)), future);
      // The document was written back at the current schema.
      final rewritten = database.readSaveDocument();
      expect(rewritten, isNotNull);
      expect(SaveDocumentCodec.read(rewritten).kind, SaveReadKind.current);
      await save.dispose();
    });

    test('a real schema-1 document migrates to the current schema on '
        'load: backed up once under doc_backup_v1, the derived fields '
        'filled, the badges it implies granted, and written back (m7-design '
        '§3.3)', () async {
      final database = await HiveDatabaseService.open(
        directory: directory.path,
      );
      final original = schema1Document();
      await database.writeSaveDocument(original);
      await database.flushSave();

      final save = HiveSaveService(database, FakeRemoteConfigService());
      await save.load();
      expect(save.currentLevel, 24);
      expect(save.coins, 830);
      expect(save.document.daily.lit, isTrue);
      expect(save.document.daily.run, 6);
      expect(save.document.records.longestRun, 6);
      expect(save.document.records.dailies, 6);
      // 23 wins imply a completed family (m7-design §12), granted silently.
      expect(save.document.records.earned, [BadgeId.firstFamily]);
      await save.flush();

      expect(database.readSaveBackup(SaveBoxKeys.backup(1)), original);
      final rewritten = database.readSaveDocument();
      final reread = SaveDocumentCodec.read(rewritten);
      expect(reread.kind, SaveReadKind.current);
      expect(reread.document, save.document);

      // The next launch reads it as current: nothing more to back up.
      final again = HiveSaveService(database, FakeRemoteConfigService());
      await again.load();
      expect(again.document, save.document);
      expect(database.readSaveBackup(SaveBoxKeys.backup(1)), original);
      await again.dispose();
      await save.dispose();
    });

    test('a real schema-2 document migrates to schema 3 on load: backed up '
        'once under doc_backup_v2, every field kept, the daily gift fresh, '
        'and written back (plan-login-gift §7.5b)', () async {
      final database = await HiveDatabaseService.open(
        directory: directory.path,
      );
      final original = schema2Document();
      await database.writeSaveDocument(original);
      await database.flushSave();

      final save = HiveSaveService(database, FakeRemoteConfigService());
      await save.load();
      // The fixture's badges were already granted when the M7 app loaded
      // it, so the document is the migrated one, untouched.
      expect(save.document, SaveDocumentCodec.read(original).document);
      expect(save.currentLevel, 47);
      expect(save.coins, 1240);
      expect(save.document.daily.streak, 12);
      expect(save.document.inProgress?.levelId, 'L0047');
      expect(save.document.race.rivals[0].wins, 2);
      expect(save.playerId, '4C1E-9B07');
      expect(save.document.loginGift, const LoginGiftProgress());
      await save.flush();

      expect(database.readSaveBackup(SaveBoxKeys.backup(2)), original);
      final rewritten = database.readSaveDocument();
      final reread = SaveDocumentCodec.read(rewritten);
      expect(reread.kind, SaveReadKind.current);
      expect(reread.storedSchema, 3);
      expect(reread.document, save.document);

      // The first claim after the update pays Day 1 and survives a reload;
      // the next launch reads it as current, with nothing more backed up.
      final grant = save.claimLoginGift(LocalDate(2026, 10, 5));
      expect(grant?.day, 1);
      expect(save.coins, 1260);
      await save.flush();
      final again = HiveSaveService(database, FakeRemoteConfigService());
      await again.load();
      expect(again.document, save.document);
      expect(again.document.loginGift.claims, 1);
      expect(again.coins, 1260);
      expect(database.readSaveBackup(SaveBoxKeys.backup(2)), original);
      expect(database.readSaveBackup(SaveBoxKeys.backup(3)), isNull);
      await again.dispose();
      await save.dispose();
    });

    test('a race result survives a real Hive write and reload: beginRace '
        'and recordRaceWin keep raceNo, coins, wins and the unlock, and a '
        'kill (no recordRaceWin call) leaves no reward (m7-design P2.7, '
        'P2.13)', () async {
      final first = await HiveDatabaseService.open(directory: directory.path);
      final save = HiveSaveService(first, FakeRemoteConfigService());
      await save.load();
      save.currentLevel = 25; // Past race_unlock_level (20).

      final raceNo = save.beginRace(1);
      expect(raceNo, 1);
      await save.flush();
      await first.close();

      // "A kill leaves no reward": reopening after beginRace alone (no
      // recordRaceWin) keeps the raceNo but pays nothing.
      final reopened = await HiveDatabaseService.open(
        directory: directory.path,
      );
      final afterKill = HiveSaveService(reopened, FakeRemoteConfigService());
      await afterKill.load();
      expect(afterKill.document.race.rivals[0].raceNo, 1);
      expect(afterKill.coins, 0);
      expect(afterKill.document.race.rivals[0].wins, 0);

      final outcome = afterKill.recordRaceWin(
        const RaceWinRecord(
          rival: 1,
          raceNo: 1,
          rewardCoins: 20,
          moves: 12,
          families: 2,
          dolls: 5,
        ),
      );
      expect(outcome.coins, 20);
      expect(outcome.unlockedRival, 2);
      await afterKill.flush();
      await reopened.close();

      final third = await HiveDatabaseService.open(directory: directory.path);
      final reload = HiveSaveService(third, FakeRemoteConfigService());
      await reload.load();
      expect(reload.coins, 20);
      expect(reload.document.race.rivals[0].wins, 1);
      expect(reload.document.race.rivals[0].raceNo, 1);
      expect(reload.document.race.rivals[1].unlocked, isTrue);
      expect(reload.document.records.has(BadgeId.firstRace), isTrue);
      await reload.dispose();
    });

    test('a torn write (the last frame truncated) leaves the previous '
        'document readable', () async {
      final first = await HiveDatabaseService.open(directory: directory.path);
      final save = HiveSaveService(first, FakeRemoteConfigService());
      await save.load();
      save.addCoins(11);
      await save.flush();
      final boxFile = File('${directory.path}/${HiveBoxes.save}.hive');
      final lengthAfterA = boxFile.lengthSync();

      save.addCoins(22);
      await save.flush();
      final lengthAfterB = boxFile.lengthSync();
      await first.close();

      // Simulate a crash mid-write: only part of the second frame reached
      // disk. Hive's crash recovery discards it and keeps the frame before.
      final bytes = boxFile.readAsBytesSync();
      final tornLength = lengthAfterA + (lengthAfterB - lengthAfterA) ~/ 2;
      boxFile.writeAsBytesSync(bytes.sublist(0, tornLength));

      final second = await HiveDatabaseService.open(directory: directory.path);
      final reload = HiveSaveService(second, FakeRemoteConfigService());
      await reload.load();
      expect(reload.coins, 11);
      await reload.dispose();
    });

    test('the write queue coalesces several changes into at most two '
        'writes', () async {
      final database = await HiveDatabaseService.open(
        directory: directory.path,
      );
      final gated = _GatedDatabaseService(database);
      final save = HiveSaveService(gated, FakeRemoteConfigService());
      await save.load();
      // Drain whatever the load itself queued (a fresh install always
      // writes its new player id) before gating writes.
      await save.flush();
      gated.writes.clear();

      gated.gate = Completer<void>();
      save.addCoins(1);
      save.addCoins(1);
      save.addCoins(1);
      // Only the first change's write has started; the rest just marked
      // the queue dirty.
      expect(gated.writes.length, 1);

      gated.gate!.complete();
      gated.gate = null;
      await save.flush();

      expect(gated.writes.length, lessThanOrEqualTo(2));
      expect(save.coins, 3);
      await save.dispose();
    });

    test(
      'flush writes what the queue still holds and makes it durable',
      () async {
        final database = await HiveDatabaseService.open(
          directory: directory.path,
        );
        final save = HiveSaveService(database, FakeRemoteConfigService());
        await save.load();
        save.addCoins(5);

        await save.flush();

        // Read the box directly rather than reopening it: `Hive.close()`
        // (`DatabaseService.close`) closes every open box, so a second
        // `HiveDatabaseService.open` on the same directory without first
        // closing this one would pull the rug from under it.
        expect(
          SaveDocumentCodec.read(database.readSaveDocument()).document.coins,
          5,
        );
        await save.dispose();
      },
    );

    test('dispose flushes before closing', () async {
      final database = await HiveDatabaseService.open(
        directory: directory.path,
      );
      final save = HiveSaveService(database, FakeRemoteConfigService());
      await save.load();
      save.addCoins(9);

      await save.dispose();

      expect(
        SaveDocumentCodec.read(database.readSaveDocument()).document.coins,
        9,
      );
    });
  });

  group('HiveSaveService on the in-memory fallback', () {
    test('runs unchanged when Hive could not open: the game stays playable '
        'but nothing survives the session', () async {
      final fallback = FakeDatabaseService();
      final save = HiveSaveService(fallback, FakeRemoteConfigService());
      await save.load();

      save.addCoins(15);
      save.currentLevel = 3;
      await save.flush();

      expect(save.coins, 15);
      expect(save.currentLevel, 3);
      expect(
        SaveDocumentCodec.read(fallback.readSaveDocument()).document.coins,
        15,
      );
      await save.dispose();
    });
  });
}
