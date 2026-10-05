import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_game/core/models/intro_mechanic.dart';
import 'package:nesty_game/features/gameplay/bloc/gameplay_bloc.dart';

import 'board_probe.dart';

/// Plays the board on screen to its win with the solver's own hints (spec
/// §6.3; the dev flavor keeps Hint free), as `daily_states_test.dart` plays
/// the daily: no move is scripted, so a generated board (the daily, a
/// bonus) is solved whatever the date or seed made of it. Each intro card
/// the board opens on is handed to [onIntro] (a shot, a semantics dump)
/// and dismissed with "Got it". Used by `faults_test.dart` and
/// `semantics_tour_test.dart` (phase 5).
Future<void> solveWithHints(
  WidgetTester tester,
  Board board, {
  Future<void> Function(IntroMechanic shown)? onIntro,
  int maxMoves = 40,
}) async {
  // Settle first: an intro card comes up just after the board, and a Hint
  // tapped before it lands on the card (the device run, 2026-09-30).
  await board.waitIdle();
  await tester.pumpFor(const Duration(milliseconds: 1200));
  final hintButton = find.text('Hint');
  for (var i = 0; i < maxMoves; i++) {
    for (
      var shown = board.state.intro;
      shown != null;
      shown = board.state.intro
    ) {
      await tester.pumpFor(const Duration(milliseconds: 400));
      await onIntro?.call(shown);
      await tester.tap(find.text('Got it'));
      await tester.pumpUntil(
        () => board.state.intro != shown,
        reason: 'the ${shown.name} intro card dismissed',
      );
    }
    // Won by the last hint: a won board stays input-locked under its win
    // card, so it never goes idle.
    if (board.state.status != GameplayStatus.playing) return;
    await board.waitIdle();
    if (board.state.status != GameplayStatus.playing) return;
    // A dismissed card fades out over the booster bar for a moment and
    // takes a tap meant for Hint: wait until Hint itself is the one hit.
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
    await board.move(hint.from, hint.to);
  }
  if (board.state.status != GameplayStatus.playing) return;
  fail('did not solve within $maxMoves moves');
}
