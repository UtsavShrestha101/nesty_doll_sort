import 'package:injectable/injectable.dart';
import 'package:nesty_core/nesty_core.dart';
import 'package:nesty_game/core/dependency_injection/app_env.dart';
import 'package:nesty_game/core/services/solver/solver_service.dart';

/// [SolverService] that runs the solver synchronously on the calling
/// isolate: deterministic and instant for tests (M2 boards solve in
/// milliseconds). Nothing is ever in flight, so [cancel] has nothing to
/// supersede. Fake env only: the real env runs `IsolateSolverService`.
@LazySingleton(as: SolverService, env: [AppEnv.fake])
class FakeSolverService implements SolverService {
  @override
  Future<HintResult?> hint(GameState state) async => Solver.hint(state);

  @override
  Future<SolveVerdict?> softStuck(GameState state) async =>
      Solver.softStuck(state);

  @override
  void cancel() {}

  @override
  Future<void> dispose() async {}
}
