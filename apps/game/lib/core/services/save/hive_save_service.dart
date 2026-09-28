import 'dart:async';
import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:nesty_game/core/dependency_injection/app_env.dart';
import 'package:nesty_game/core/services/database/database_service.dart';
import 'package:nesty_game/core/services/database/hive_boxes.dart';
import 'package:nesty_game/core/services/remote_config/remote_config_service.dart';
import 'package:nesty_game/core/services/save/in_memory_save_service.dart';
import 'package:nesty_game/core/services/save/save_document.dart';
import 'package:nesty_game/core/services/save/save_document_codec.dart';
import 'package:nesty_game/core/services/save/save_service.dart';

/// Persistent [SaveService] over [DatabaseService]'s `save` box (D63;
/// docs/plans/m3-design.md §3.2). [InMemorySaveService] holds every rule on
/// the document in memory; this class only adds storage: a lenient,
/// migrating, backing-up [load] and a serial, coalescing write queue.
///
/// If Hive can't open, [DatabaseModule] already falls back to the in-memory
/// `FakeDatabaseService` (CLAUDE.md rule 3); this class runs on it
/// unchanged; nothing persists this session, but the game stays playable.
@LazySingleton(as: SaveService, env: [AppEnv.real])
class HiveSaveService extends InMemorySaveService {
  HiveSaveService(this._database, RemoteConfigService remoteConfig)
    : super(remoteConfig);

  final DatabaseService _database;

  // The write queue: at most one `writeSaveDocument` in flight; a change
  // that lands during it only sets `_dirty`, so the queue writes the latest
  // document once more when it finishes (m3-design §3.2).
  Future<void>? _writing;
  bool _dirty = false;

  /// [SaveService.load]'s body: read, migrate and decode the stored text
  /// (never throws), back it up first when it needs one, give a fresh
  /// document its player id, then adopt it. Idempotent: `load()` (the base
  /// class) only calls this once.
  @override
  Future<void> loadDocument() async {
    final String? stored;
    try {
      stored = _database.readSaveDocument();
    } on Object catch (error, stack) {
      _log('reading the save document failed; starting fresh', error, stack);
      adopt(document.copyWith(playerId: InMemorySaveService.newPlayerId()));
      return;
    }
    final result = SaveDocumentCodec.read(stored);
    var needsWrite = false;
    final String? maybeRawText = stored;
    if (result.needsBackup && maybeRawText != null) {
      final String rawText = maybeRawText;
      final key = result.kind == SaveReadKind.invalid
          ? SaveBoxKeys.invalidBackup
          : SaveBoxKeys.backup(result.storedSchema);
      // Never overwrite an earlier backup at the same key (m3-design §3.2).
      if (_database.readSaveBackup(key) == null) {
        await _guard(() => _database.writeSaveBackup(key, rawText));
      }
      needsWrite = true;
    }
    var next = result.document;
    if (next.playerId == null) {
      next = next.copyWith(playerId: InMemorySaveService.newPlayerId());
      needsWrite = true;
    }
    adopt(next);
    if (needsWrite) persist(document);
  }

  /// Queues a write of [document] (the latest one, not necessarily the one
  /// passed): marks the queue dirty and starts draining it if nothing is in
  /// flight.
  @override
  void persist(SaveDocument document) {
    _dirty = true;
    _writing ??= _drain();
  }

  Future<void> _drain() async {
    try {
      while (_dirty) {
        _dirty = false;
        await _guard(
          () => _database.writeSaveDocument(SaveDocumentCodec.write(document)),
        );
      }
    } finally {
      _writing = null;
    }
  }

  /// Awaits the write in flight, writes once more if the queue is still
  /// dirty, then flushes the box durable. Never throws.
  @override
  Future<void> flush() async {
    await _writing;
    if (_dirty) {
      _dirty = false;
      await _guard(
        () => _database.writeSaveDocument(SaveDocumentCodec.write(document)),
      );
    }
    await _guard(_database.flushSave);
  }

  @override
  @disposeMethod
  Future<void> dispose() async {
    await flush();
    await super.dispose();
  }

  static Future<void> _guard(Future<void> Function() body) async {
    try {
      await body();
    } on Object catch (error, stack) {
      // Offline-first (CLAUDE.md rule 3): a write failure is logged and
      // retried by the next change or flush; it never reaches a caller.
      _log('a save write failed', error, stack);
    }
  }

  static void _log(String message, Object error, StackTrace? stack) {
    developer.log(message, name: 'nesty.save', error: error, stackTrace: stack);
    // developer.log never reaches the `flutter run` terminal.
    if (kDebugMode) debugPrint('[nesty.save] $message: $error');
  }
}
