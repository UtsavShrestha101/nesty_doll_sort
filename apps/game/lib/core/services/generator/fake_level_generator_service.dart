import 'dart:developer' as developer;

import 'package:injectable/injectable.dart';
import 'package:nesty_core/nesty_core.dart';
import 'package:nesty_game/core/dependency_injection/app_env.dart';
import 'package:nesty_game/core/services/generator/level_generator_service.dart';

/// [LevelGeneratorService] on the calling isolate: the same
/// `Generator.generateWithRetries` output, synchronously (tests, the fake
/// env). Deterministic like the real one.
@LazySingleton(as: LevelGeneratorService, env: [AppEnv.fake])
class FakeLevelGeneratorService implements LevelGeneratorService {
  /// Requests served, for tests that check a prefetch was reused.
  int calls = 0;

  @override
  Future<GeneratedLevel?> generate(GeneratorParams params) async {
    calls++;
    try {
      return switch (Generator.generateWithRetries(params)) {
        GeneratorSuccess(:final level, :final simulation, :final tierMatched) =>
          GeneratedLevel(
            level: level,
            tier: simulation.tier,
            tierMatched: tierMatched,
            expertOnly: simulation.expertOnly,
          ),
        GeneratorFailure(:final issues) => _failed(params, issues),
      };
    } on Object catch (error) {
      developer.log(
        'generation of ${params.id} threw',
        name: 'nesty.generator',
        error: error,
      );
      return null;
    }
  }

  static GeneratedLevel? _failed(
    GeneratorParams params,
    List<LevelIssue> issues,
  ) {
    developer.log(
      'no level for ${params.id}: $issues',
      name: 'nesty.generator',
    );
    return null;
  }

  @override
  @disposeMethod
  void dispose() {}
}
