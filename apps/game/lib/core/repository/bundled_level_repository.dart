import 'dart:developer' as developer;
import 'dart:isolate';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:injectable/injectable.dart';
import 'package:nesty_core/nesty_core.dart';
import 'package:nesty_game/core/dependency_injection/app_env.dart';
import 'package:nesty_game/core/error/app_exception.dart';
import 'package:nesty_game/core/repository/level_repository.dart';

/// Decodes a bundle's text and checks its levels, returning what plays
/// ([BundledLevelRepository.checkInBackground] by default).
typedef LevelBundleChecker = Future<CheckedLevelBundle> Function(String text);

/// What [BundledLevelRepository.checkBundle] hands back from its isolate:
/// plain data, so it crosses the isolate boundary.
@immutable
final class CheckedLevelBundle {
  const CheckedLevelBundle({
    required this.usable,
    required this.playable,
    this.issues = const [],
    this.skipped = const [],
    this.checkedOn,
    this.elapsed = Duration.zero,
  });

  /// False when the codec couldn't read a bundle at all ([issues] say why).
  final bool usable;

  /// The entries that pass rules 1–7, ascending by `order`.
  final List<LevelBundleEntry> playable;

  /// The codec's issues, as log lines.
  final List<String> issues;

  /// One log line per level that failed a rule and was skipped.
  final List<String> skipped;

  /// The debug name of the isolate that did the work (for the log).
  final String? checkedOn;

  /// How long the decode and the rules took there (for the log).
  final Duration elapsed;
}

/// Real [LevelRepository]: the levels bundled in the app (spec §13.4 #1),
/// playable offline from the first launch (CLAUDE.md rule 3).
///
/// [load] reads `assets/levels/bundle.json` (written by
/// `nesty_levels bundle build`), decodes it with nesty_core's
/// `LevelBundleCodec` and checks every level with `Validator` rules 1–7
/// (`ValidationOptions.loader`: CI already proved them solvable, A6). An
/// entry the codec rejects or a level that fails a rule is skipped with a
/// log entry (spec §5.3); the rest still play.
///
/// The decode and the rules run on a worker isolate ([checkInBackground]),
/// not the UI isolate the splash animates on: for the 200 M7 levels they
/// took 57–75 ms AOT and 232–354 ms JIT on the dev Mac, several frames,
/// against 6–12 ms for 30 (CLAUDE.md rule 8; levels lane report).
@LazySingleton(as: LevelRepository, env: [AppEnv.real])
class BundledLevelRepository implements LevelRepository {
  BundledLevelRepository({
    @ignoreParam AssetBundle? bundle,
    @ignoreParam String assetKey = bundleAsset,
    @ignoreParam LevelBundleChecker checker = checkInBackground,
  }) : _bundle = bundle ?? rootBundle,
       _assetKey = assetKey,
       _checker = checker;

  /// Declared under `assets/levels/` in the pubspec.
  static const bundleAsset = 'assets/levels/bundle.json';

  /// The worker isolate's debug name.
  static const workerName = 'nesty.levels.check';

  final AssetBundle _bundle;
  final String _assetKey;
  final LevelBundleChecker _checker;

  /// Playable entries, ascending by `order` (the codec sorts and dedupes).
  List<LevelBundleEntry> _entries = const [];
  Future<void>? _loading;
  String? _checkedOn;

  /// The debug name of the isolate that decoded and checked the last load
  /// ([workerName] by default), or null before a load.
  @visibleForTesting
  String? get checkedOn => _checkedOn;

  /// Runs [checkBundle] on a worker isolate ([workerName]).
  static Future<CheckedLevelBundle> checkInBackground(String text) =>
      compute(checkBundle, text, debugLabel: workerName);

  /// Decodes [text] with `LevelBundleCodec` and checks each level with
  /// `Validator` rules 1–7 (`ValidationOptions.loader`). Pure: the rules
  /// are nesty_core's (CLAUDE.md rule 2), and nothing here touches Flutter.
  static CheckedLevelBundle checkBundle(String text) {
    final clock = Stopwatch()..start();
    final decoded = LevelBundleCodec.decodeString(text);
    final issues = [for (final issue in decoded.issues) '$issue'];
    final bundle = decoded.bundle;
    if (bundle == null) {
      return CheckedLevelBundle(
        usable: false,
        playable: const [],
        issues: issues,
        checkedOn: Isolate.current.debugName,
        elapsed: clock.elapsed,
      );
    }
    final playable = <LevelBundleEntry>[];
    final skipped = <String>[];
    for (final entry in bundle.levels) {
      final report = Validator.validate(
        entry.level,
        options: ValidationOptions.loader,
      );
      if (report.isValid) {
        playable.add(entry);
      } else {
        skipped.add(
          'skipped level ${entry.level.id} (order ${entry.order}): '
          '${report.errors.join('; ')}',
        );
      }
    }
    return CheckedLevelBundle(
      usable: true,
      playable: playable,
      issues: issues,
      skipped: skipped,
      checkedOn: Isolate.current.debugName,
      elapsed: clock.elapsed,
    );
  }

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
    final CheckedLevelBundle checked;
    try {
      checked = await _checker(text);
    } on Object catch (error, stack) {
      throw AppException(
        AppExceptionKind.content,
        message: 'The level bundle $_assetKey could not be checked',
        cause: error,
        stackTrace: stack,
      );
    }
    _checkedOn = checked.checkedOn;
    for (final issue in checked.issues) {
      _log('bundle issue: $issue');
    }
    checked.skipped.forEach(_log);
    if (!checked.usable) {
      throw AppException(
        AppExceptionKind.content,
        message: 'The level bundle is unusable: ${checked.issues.join('; ')}',
      );
    }
    if (checked.playable.isEmpty) {
      throw const AppException(
        AppExceptionKind.content,
        message: 'The level bundle has no playable level',
      );
    }
    _log(
      'checked ${checked.playable.length} levels in '
      '${checked.elapsed.inMilliseconds} ms on ${checked.checkedOn}',
    );
    _entries = List.unmodifiable(checked.playable);
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
