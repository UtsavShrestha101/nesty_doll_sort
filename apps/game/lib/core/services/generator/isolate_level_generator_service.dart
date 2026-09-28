import 'dart:developer' as developer;
import 'dart:isolate';

import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:nesty_core/nesty_core.dart';
import 'package:nesty_game/core/dependency_injection/app_env.dart';
import 'package:nesty_game/core/services/generator/level_generator_service.dart';

/// [LevelGeneratorService] off the UI isolate (CLAUDE.md rule 8;
/// docs/plans/m3-design.md §6.3): each request runs
/// `Generator.generateWithRetries` in a fresh `Isolate.run`, so a slow
/// generation (a run of failed retries) never drops a frame. The level
/// comes back as `LevelCodec.encode` JSON plus the tier and its flags —
/// plain, isolate-transferable data — and is decoded on the calling isolate.
@LazySingleton(as: LevelGeneratorService, env: [AppEnv.real])
class IsolateLevelGeneratorService implements LevelGeneratorService {
  bool _disposed = false;

  @override
  Future<GeneratedLevel?> generate(GeneratorParams params) async {
    if (_disposed) return null;
    _IsolateResult? result;
    try {
      result = await Isolate.run(() => _generateInIsolate(params));
    } on Object catch (error, stack) {
      _log('generation of ${params.id} threw', error, stack);
      return null;
    }
    if (result == null || _disposed) return null;
    final decoded = LevelCodec.decode(result.levelJson);
    final level = decoded.level;
    if (level == null) {
      // The isolate only ever encodes a level `Generator` itself produced,
      // so a decode failure here would mean the codec and the generator
      // disagree — treat it like any other generation failure (rule 3).
      _log('the generated level failed to decode', decoded.issues, null);
      return null;
    }
    return GeneratedLevel(
      level: level,
      tier: result.tier,
      tierMatched: result.tierMatched,
      expertOnly: result.expertOnly,
    );
  }

  /// Runs on the spawned isolate: the same `Generator.generateWithRetries`
  /// the fake calls synchronously, so the two implementations agree.
  static _IsolateResult? _generateInIsolate(GeneratorParams params) =>
      switch (Generator.generateWithRetries(params)) {
        GeneratorSuccess(:final level, :final simulation, :final tierMatched) =>
          _IsolateResult(
            levelJson: LevelCodec.encode(level),
            tier: simulation.tier,
            tierMatched: tierMatched,
            expertOnly: simulation.expertOnly,
          ),
        GeneratorFailure() => null,
      };

  /// Drops work in flight (DI reset): a call already spawned finishes on
  /// its own isolate regardless (each is a single short-lived computation),
  /// but its result is discarded here rather than decoded.
  @override
  @disposeMethod
  void dispose() => _disposed = true;

  static void _log(String message, Object error, StackTrace? stack) {
    developer.log(
      message,
      name: 'nesty.generator',
      error: error,
      stackTrace: stack,
    );
    // developer.log never reaches the `flutter run` terminal.
    if (kDebugMode) debugPrint('[nesty.generator] $message: $error');
  }
}

/// What crosses back from the isolate: JSON and other plain data only, per
/// the class doc above.
final class _IsolateResult {
  const _IsolateResult({
    required this.levelJson,
    required this.tier,
    required this.tierMatched,
    required this.expertOnly,
  });

  final Map<String, Object?> levelJson;
  final Tier tier;
  final bool tierMatched;
  final bool expertOnly;
}
