import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:injectable/injectable.dart';
import 'package:nesty_core/nesty_core.dart';
import 'package:nesty_game/core/dependency_injection/app_env.dart';
import 'package:nesty_game/core/error/app_exception.dart';
import 'package:nesty_game/core/repository/level_repository.dart';

/// Real [LevelRepository]: the levels bundled in the app (spec §13.4 #1),
/// playable offline from the first launch (CLAUDE.md rule 3).
///
/// [load] reads `assets/levels/bundle.json` (written by
/// `nesty_levels bundle build`), decodes it with nesty_core's
/// `LevelBundleCodec` and checks every level with `Validator` rules 1–7
/// (`ValidationOptions.loader`: CI already proved them solvable, A6). An
/// entry the codec rejects or a level that fails a rule is skipped with a
/// log entry (spec §5.3); the rest still play.
@LazySingleton(as: LevelRepository, env: [AppEnv.real])
class BundledLevelRepository implements LevelRepository {
  BundledLevelRepository({
    @ignoreParam AssetBundle? bundle,
    @ignoreParam String assetKey = bundleAsset,
  }) : _bundle = bundle ?? rootBundle,
       _assetKey = assetKey;

  /// Declared under `assets/levels/` in the pubspec.
  static const bundleAsset = 'assets/levels/bundle.json';

  final AssetBundle _bundle;
  final String _assetKey;

  /// Playable entries, ascending by `order` (the codec sorts and dedupes).
  List<LevelBundleEntry> _entries = const [];
  Future<void>? _loading;

  @override
  Future<void> load() => _loading ??= _loadOnce();

  Future<void> _loadOnce() async {
    try {
      await _load();
    } on Object {
      // Let the splash's retry try again.
      _loading = null;
      rethrow;
    }
  }

  Future<void> _load() async {
    final String text;
    try {
      // cache: false — the text is only needed until it is decoded.
      text = await _bundle.loadString(_assetKey, cache: false);
    } on Object catch (error, stack) {
      throw AppException(
        AppExceptionKind.content,
        message: 'The level bundle $_assetKey could not be read',
        cause: error,
        stackTrace: stack,
      );
    }
    final decoded = LevelBundleCodec.decodeString(text);
    final bundle = decoded.bundle;
    for (final issue in decoded.issues) {
      _log('bundle issue: $issue');
    }
    if (bundle == null) {
      throw AppException(
        AppExceptionKind.content,
        message: 'The level bundle is unusable: ${decoded.issues.join('; ')}',
      );
    }
    final playable = <LevelBundleEntry>[];
    for (final entry in bundle.levels) {
      final report = Validator.validate(
        entry.level,
        options: ValidationOptions.loader,
      );
      if (report.isValid) {
        playable.add(entry);
      } else {
        _log(
          'skipped level ${entry.level.id} (order ${entry.order}): '
          '${report.errors.join('; ')}',
        );
      }
    }
    if (playable.isEmpty) {
      throw const AppException(
        AppExceptionKind.content,
        message: 'The level bundle has no playable level',
      );
    }
    _entries = List.unmodifiable(playable);
  }

  @override
  int get levelCount => _entries.isEmpty ? 0 : _entries.last.order;

  @override
  LevelBundleEntry? entryAt(int order) {
    if (order < 1) return null;
    // The first entry at or after [order]: itself, or the next level when
    // it was skipped. Binary search: no allocation.
    var low = 0;
    var high = _entries.length;
    while (low < high) {
      final mid = (low + high) >> 1;
      if (_entries[mid].order < order) {
        low = mid + 1;
      } else {
        high = mid;
      }
    }
    return low < _entries.length ? _entries[low] : null;
  }

  static void _log(String message) {
    developer.log(message, name: 'nesty.levels');
    // developer.log never reaches the `flutter run` terminal.
    if (kDebugMode) debugPrint('[nesty.levels] $message');
  }
}
