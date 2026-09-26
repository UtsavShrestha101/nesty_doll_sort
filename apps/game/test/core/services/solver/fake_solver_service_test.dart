import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_core/nesty_core.dart';
import 'package:nesty_game/core/services/solver/fake_solver_service.dart';

import '../../../helpers/level_fixtures.dart';

void main() {
  final state = GameState.initial(levelFrom(tutorialLevelJson));

  test('hints the solver\'s first move, like Solver.hint', () async {
    final hint = await FakeSolverService().hint(state);
    expect(hint, Solver.hint(state));
    expect(hint!.source, HintSource.solver);
    expect(hint.move, isNotNull);
  });

  test('a solvable board is not soft stuck', () async {
    expect(await FakeSolverService().softStuck(state), SolveVerdict.solved);
  });

  test('cancel and dispose are harmless', () async {
    final solver = FakeSolverService()..cancel();
    await solver.dispose();
  });
}
