import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive_ce.dart';
import 'package:nesty_game/core/models/symbols_mode.dart';
import 'package:nesty_game/core/services/database/database_service.dart';
import 'package:nesty_game/core/services/database/fake_database_service.dart';
import 'package:nesty_game/core/services/database/hive_boxes.dart';
import 'package:nesty_game/core/services/database/hive_database_service.dart';
import 'package:nesty_game/core/services/remote_config/fake_remote_config_service.dart';
import 'package:nesty_game/core/services/save/hive_save_service.dart';
import 'package:nesty_game/core/services/save/save_document_codec.dart';

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
      const future =
          '{"schema":2,"currentLevel":9,"coins":70,"aFutureKey":"x"}';
      await database.writeSaveDocument(future);
      await database.flushSave();

      final save = HiveSaveService(database, FakeRemoteConfigService());
      await save.load();
      expect(save.currentLevel, 9);
      expect(save.coins, 70);
      expect(save.document.unknown['aFutureKey'], 'x');
      await save.flush();

      expect(database.readSaveBackup(SaveBoxKeys.backup(2)), future);
      // The document was written back at the current schema.
      final rewritten = database.readSaveDocument();
      expect(rewritten, isNotNull);
      expect(SaveDocumentCodec.read(rewritten).kind, SaveReadKind.current);
      await save.dispose();
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
