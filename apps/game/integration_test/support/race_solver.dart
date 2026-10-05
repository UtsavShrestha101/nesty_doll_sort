import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_core/nesty_core.dart';

/// Wins a vs Computer race on a device with core's own solver (spec §6.3),
/// tap by tap: the playthrough's rival-1 segment and the semantics tour's
/// race both play it (extracted from `playthrough_test.dart`, phase 5
/// architecture §2.1). The rival must be slowed with
/// `--dart-define=NESTY_RACE_PACE_MS=600000` (a dev debug build only), so
/// the player's solution always lands first.
abstract final class RaceSolver {
  /// Core's optimal line for the race board [board] (the board right after
  /// Start, before any move). Fails the test when the solver finds none.
  static List<Move> line(GameState board) {
    final result = Solver.solve(board);
    expect(
      result.verdict,
      SolveVerdict.solved,
      reason: 'the race board has a solution',
    );
    return result.solution!;
  }

  /// Plays [line] with [move] (a board probe's tap-tap move), calling
  /// [afterMove] with each move's index once it is made (the playthrough
  /// shoots 9.3b after the second).
  static Future<void> play(
    List<Move> line, {
    required Future<void> Function(String from, String to) move,
    Future<void> Function(int index)? afterMove,
  }) async {
    for (var i = 0; i < line.length; i++) {
      await move(line[i].from, line[i].to);
      await afterMove?.call(i);
    }
  }
}
