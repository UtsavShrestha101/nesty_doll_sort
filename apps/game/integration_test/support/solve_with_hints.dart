import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_core/nesty_core.dart';
import 'package:nesty_game/core/ui/widgets/booster/booster_button.dart';
import 'package:nesty_game/features/gameplay/bloc/gameplay_bloc.dart';

import 'board_probe.dart';

/// The booster bar's Hint button, found by its kind, not its label, so it
/// works in every language (build/m7-p5/p5/l10n.md §7.2).
final Finder hintButton = find.byWidgetPredicate(
  (widget) => widget is BoosterButton && widget.kind == BoosterButtonKind.hint,
);

/// Applies the solver's own hint until the level is won (the dev flavor
/// keeps Hint free): the same logic as `overlays_test.dart`'s
/// `_solveWithHints`, with a language-free Hint finder, for
/// `locales_test.dart` (the integrator later points overlays_test at it).
/// [beforeWinningMove] runs just before the move that wins.
Future<void> solveWithHints(
  WidgetTester tester,
  Board board, {
  int maxMoves = 40,
  void Function()? beforeWinningMove,
}) async {
  for (var i = 0; i < maxMoves; i++) {
    if (board.state.status != GameplayStatus.playing) return;
    await board.waitIdle();
    if (board.state.status != GameplayStatus.playing) return;
    // Hint only once nothing covers it (a card fading out takes the tap).
    await tester.pumpUntil(
      () => hintButton.hitTestable().evaluate().isNotEmpty,
      reason:
          'Hint uncovered (intro ${board.state.intro}, paused '
          '${board.state.paused}, status ${board.state.status})',
    );
    await tester.tap(hintButton);
    await tester.pumpUntil(
      () => board.state.hint != null,
      timeout: const Duration(seconds: 15),
      reason: 'a hint',
    );
    final hint = board.state.hint!;
    if (beforeWinningMove != null) {
      final after = Rules.tryMove(board.state.board, hint);
      if (after is MoveApplied && Rules.isWon(after.state)) {
        beforeWinningMove();
      }
    }
    await board.move(hint.from, hint.to);
  }
  fail('did not solve within $maxMoves moves');
}
