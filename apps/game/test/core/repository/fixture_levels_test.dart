import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_core/nesty_core.dart';
import 'package:nesty_game/core/repository/fixture_levels.dart';

/// [FixtureLevels.entries]'s pars are the solver's optimal solution length
/// from the level's own start (spec-prop §7.10, D125; m7-design P3.6), so a
/// widget or bloc test that plays a fixture level and wins earns the same
/// stars the real bundle would give it.
void main() {
  test('each fixture level\'s par is the solver\'s optimal length', () {
    for (final entry in FixtureLevels.entries()) {
      final solve = Solver.solve(GameSession(entry.level).state);
      expect(
        solve.verdict,
        SolveVerdict.solved,
        reason: '${entry.level.id} did not solve',
      );
      expect(
        entry.par,
        solve.solution!.length,
        reason:
            '${entry.level.id}: par ${entry.par} vs the solver\'s '
            '${solve.solution!.length}',
      );
    }
  });
}
