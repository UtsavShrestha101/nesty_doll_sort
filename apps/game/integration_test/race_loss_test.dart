import 'dart:convert';
import 'dart:io' show Platform;

import 'package:flutter/widgets.dart' show ValueKey;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:nesty_core/nesty_core.dart';
import 'package:nesty_game/core/dependency_injection/di.dart';
import 'package:nesty_game/core/models/play_request.dart';
import 'package:nesty_game/core/services/race/race_rules.dart';
import 'package:nesty_game/core/services/remote_config/remote_config_service.dart';
import 'package:nesty_game/core/services/save/save_document.dart';
import 'package:nesty_game/core/services/save/save_service.dart';
import 'package:nesty_game/core/ui/nesty_ui.dart';
import 'package:nesty_game/features/gameplay/overlays/out_of_moves_sheet.dart';
import 'package:nesty_game/features/gameplay/overlays/pause_dialog.dart';
import 'package:nesty_game/features/gameplay/overlays/race_result_overlay.dart';
import 'package:nesty_game/features/gameplay/pages/gameplay_view.dart';
import 'package:nesty_game/features/home/pages/home_page.dart';
import 'package:nesty_game/features/race/cubit/race_cubit.dart';
import 'package:nesty_game/features/race/pages/rival_select_page.dart';
import 'package:nesty_game/features/race/widgets/rival_strip.dart';
import 'package:nesty_game/features/settings/pages/settings_page.dart';
import 'package:nesty_game/main_dev.dart' as app;

import 'support/board_probe.dart';
import 'support/seeded_save.dart';

/// vs Computer's losing side on a device (phase 4 lane R; m7-design P4.4;
/// architecture §7.3; frames 9.2, 9.3, 9.5, 9.7, 9.7b): a seeded save past
/// Level 20 (the mode is open, rival 1 beaten never), one scenario per run,
/// chosen by `--dart-define=NESTY_RACE_SCENARIO=<name>`:
///
/// - `loss` (the default; run with `--dart-define=NESTY_RACE_PACE_MS=250`,
///   which only a dev debug build honours): rival select (9.2, one Start,
///   Pebble selected, the Computer tag on all three), Start, the strip while
///   the rival thinks (9.3, "Thinking"), the player never moves and the
///   computer finishes first (9.5, "So close! Rematch?", no coins), Rematch
///   (the same board: the same level, the same raceNo), Pause (9.7: the
///   versus header, "Pebble is paused too.", the rival does not move while
///   held), Settings and back, Leave race asks once (9.7b, Keep racing), then
///   Leave race for real (back to rival select, nothing written), a second
///   race, its loss, and New race (the next raceNo: a different board).
/// - `oom` (run with `--dart-define=NESTY_RACE_PACE_MS=600000`: the rival
///   never finishes): Out of Moves in a race. A dead-end line is searched
///   with core's rules and each move is checked with `Rules.tryMove` first;
///   the sheet shows Undo "Free, as often as you like" and Restart, no +1
///   Slot; Undo closes it; Leave race.
///
/// ```sh
/// cd apps/game
/// flutter drive --flavor dev --driver test_driver/integration_test.dart \
///   --target integration_test/race_loss_test.dart \
///   --dart-define=NESTY_RACE_SCENARIO=loss \
///   --dart-define=NESTY_RACE_PACE_MS=250 -d <device>
/// ```
///
/// `nesty-test` runs each scenario from a fresh install. Written, and run by
/// the device stage, never by the lane. Screenshots are prefixed `r_`. The
/// win segment stays in the playthrough (`_raceRival1`). Not on a device:
/// the strip's live-region announcements (a screen reader), the jingles.
const _scenario = String.fromEnvironment(
  'NESTY_RACE_SCENARIO',
  defaultValue: 'loss',
);

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  binding.framePolicy = LiveTestWidgetsFlutterBindingFramePolicy.fullyLive;

  testWidgets(
    'vs Computer, the losing side: $_scenario',
    (tester) async {
      // Past Level 20: `highestLevel` 21 opens the mode (`race_unlock_level`
      // 20), tutorial long done. Rival 1 open, 2 and 3 locked. `loss` starts
      // with no race yet; `oom` starts at rival 1's race 6 (see [_oomRaceNo]).
      await seedSave(
        _scenario == 'oom'
            ? const SaveDocument(
                currentLevel: 21,
                highestLevel: 21,
                race: RaceProgress(
                  rivals: [
                    RivalProgress(unlocked: true, raceNo: _oomRaceNo - 1),
                    RivalProgress(),
                    RivalProgress(),
                  ],
                ),
              )
            : const SaveDocument(currentLevel: 21, highestLevel: 21),
      );

      app.main();
      final board = Board(tester);
      final shots = _Shots(binding, tester);
      await tester.pumpUntil(
        () => find.byType(HomePage).evaluate().isNotEmpty,
        timeout: const Duration(seconds: 60),
        reason: 'Home for the seeded save (uninstall the app first)',
      );
      await tester.pumpFor(const Duration(milliseconds: 800));

      final config = get<RemoteConfigService>();
      final pace = RaceRules.paceMs(1, config);
      switch (_scenario) {
        case 'oom':
          expect(
            pace,
            greaterThanOrEqualTo(60000),
            reason:
                'run with --dart-define=NESTY_RACE_PACE_MS=600000: the rival '
                'must not finish while the player walks to a dead end',
          );
          await _oom(tester, board, shots);
        default:
          expect(
            pace,
            lessThanOrEqualTo(1500),
            reason:
                'run with --dart-define=NESTY_RACE_PACE_MS=250: the computer '
                'must finish first, so the player never moves',
          );
          await _loss(tester, board, shots);
      }
      // Merged, never replaced: `takeScreenshot` keeps the shots in
      // `reportData['screenshots']`, and the driver only writes what is
      // still there at the end.
      binding.reportData = {
        ...?binding.reportData,
        'race_loss': {
          'scenario': _scenario,
          'platform': Platform.operatingSystem,
        },
      };
      // ignore: avoid_print
      print('NESTY_RACE_LOSS ${jsonEncode({'scenario': _scenario})}');
    },
    timeout: const Timeout(Duration(minutes: 8)),
  );
}

/// Home's vs Computer tile to rival select (9.2).
Future<void> _openSelect(WidgetTester tester) async {
  final tile = find.descendant(
    of: find.byType(HomePage),
    matching: find.text('vs Computer'),
  );
  expect(tile, findsOneWidget);
  await tester.tap(tile);
  await tester.pumpUntil(
    () => find.byType(RivalSelectView).evaluate().isNotEmpty,
    reason: 'rival select',
  );
  await tester.pumpFor(const Duration(milliseconds: 600));
}

/// Rival select's one Start, then the race board (9.3) with its skin.
Future<void> _startFromSelect(WidgetTester tester, Board board) async {
  await tester.tap(find.text('Start'));
  await tester.pumpUntil(
    () =>
        find.byType(GameplayView).evaluate().isNotEmpty &&
        board.bloc.state.data?.isRace == true &&
        board.game.geometry != null &&
        board.game.skin != null,
    timeout: const Duration(seconds: 30),
    reason: 'the race board with its skin',
  );
  await board.waitIdle();
  await tester.pumpFor(const Duration(milliseconds: 800));
}

/// The race's cubit, found through the gameplay page even while Settings
/// covers it (a pushed route leaves the page offstage, which `find` skips
/// by default).
RaceCubit _race(WidgetTester tester) => tester
    .element(find.byType(GameplayView, skipOffstage: false))
    .read<RaceCubit>();

/// The race's Start button (9.3): the race is running once the bloc's input
/// gate has opened.
Future<void> _tapStart(WidgetTester tester, Board board) async {
  await tester.tap(find.text('Start'));
  await tester.pumpUntil(
    () => board.state.raceLive,
    reason: 'the race running',
  );
}

Future<void> _loss(WidgetTester tester, Board board, _Shots shots) async {
  final save = get<SaveService>();
  final coins = save.document.coins;

  // 9.2: one Start, Pebble selected, "Computer" on all three cards.
  await _openSelect(tester);
  expect(find.text('Start'), findsOneWidget, reason: 'one Start, no per card');
  expect(find.byType(ComputerTag), findsNWidgets(3));
  expect(find.text('Computer'), findsNWidgets(3));
  expect(find.text('Win 20 coins'), findsOneWidget);
  expect(find.text('Beat Pebble to unlock'), findsOneWidget);
  expect(find.text('New'), findsNothing, reason: 'rival 1 is never new');
  await shots.take('r_rival_select');

  // 9.3 before Start: the strip in the HUD row, Start over slots 2 and 3.
  await _startFromSelect(tester, board);
  expect(save.document.race.rivals[0].raceNo, 1);
  expect(find.byType(RivalStrip), findsOneWidget);
  expect(find.text('Pebble'), findsWidgets);
  expect(find.text('Ready when you are'), findsOneWidget);
  for (final label in ['Undo', 'Hint', '+Slot', 'Restart']) {
    expect(find.text(label), findsNothing, reason: '$label before Start');
  }
  final firstLevel = board.state.entry.level;
  await shots.take('r_race_ready');

  // Running: the rival thinks; the player never moves.
  await _tapStart(tester, board);
  await tester.pumpFor(const Duration(milliseconds: 200));
  expect(find.text('Undo'), findsOneWidget);
  expect(find.text('Restart'), findsOneWidget);
  expect(find.text('Hint'), findsNothing);
  await shots.take('r_race_running');

  // 9.5: the computer finished first. Nothing is paid or taken.
  await tester.pumpUntil(
    () => find.byType(RaceLossCard).evaluate().isNotEmpty,
    timeout: const Duration(minutes: 3),
    reason: 'the computer to finish first (9.5)',
  );
  await tester.pumpFor(const Duration(milliseconds: 800));
  expect(find.text('So close! Rematch?'), findsOneWidget);
  expect(
    find.text('Pebble finished first this time. A rematch costs nothing.'),
    findsOneWidget,
  );
  expect(find.text('Computer'), findsWidgets);
  expect(find.text('Rematch'), findsOneWidget);
  expect(find.text('New race'), findsOneWidget);
  expect(find.text('Back to races'), findsNothing, reason: 'two buttons');
  expect(save.document.coins, coins);
  expect(save.document.race.rivals[0].wins, 0);
  await shots.take('r_race_loss');

  // Rematch: the same board (the same level, the same raceNo).
  await tester.tap(find.text('Rematch'));
  await tester.pumpUntil(
    () =>
        find.byType(RaceLossCard).evaluate().isEmpty &&
        find.text('Start').evaluate().isNotEmpty &&
        board.game.geometry != null,
    reason: 'the rematch board',
  );
  await board.waitIdle();
  await tester.pumpFor(const Duration(milliseconds: 600));
  expect(board.state.entry.level, firstLevel, reason: 'the same board');
  expect(_race(tester).request, const RacePlay(rival: 1, raceNo: 1));
  expect(save.document.race.rivals[0].raceNo, 1, reason: 'Rematch keeps it');

  // 9.7: Pause holds the rival too.
  await _tapStart(tester, board);
  await tester.pumpFor(const Duration(milliseconds: 100));
  await board.openPause();
  await tester.pumpFor(const Duration(milliseconds: 500));
  expect(find.text('vs Computer · Pebble'), findsOneWidget);
  expect(find.text('Pebble is paused too.'), findsOneWidget);
  expect(find.text('Leave race'), findsOneWidget);
  expect(find.text('Settings'), findsOneWidget, reason: 'Q132: reachable');
  await shots.take('r_pause');
  final movesHeld = _race(tester).state.data!.rivalMoves;
  await tester.pumpFor(const Duration(milliseconds: 1500));
  expect(
    _race(tester).state.data!.rivalMoves,
    movesHeld,
    reason: 'the rival does not move while Pause is up',
  );

  // Settings and back: still paused underneath, the race not yet decided.
  await tester.tap(find.text('Settings'));
  await tester.pumpUntil(
    () => find.byType(SettingsPage).evaluate().isNotEmpty,
    reason: 'Settings over the paused race',
  );
  await tester.pumpFor(const Duration(milliseconds: 600));
  expect(_race(tester).state.data!.held, isTrue);
  await tester.tap(find.bySemanticsLabel(RegExp(r'^(Back|Close)$')).first);
  await tester.pumpUntil(
    () =>
        find.byType(SettingsPage).evaluate().isEmpty &&
        find.byType(PauseDialog).evaluate().isNotEmpty,
    reason: 'back to Pause',
  );
  await tester.pumpFor(const Duration(milliseconds: 400));

  // 9.7b: Leave race asks once; Keep racing goes on.
  await tester.tap(find.text('Leave race'));
  await tester.pumpFor(const Duration(milliseconds: 500));
  expect(find.text('Leave this race?'), findsOneWidget);
  expect(
    find.text('The race ends here. No coins, and nothing lost.'),
    findsOneWidget,
  );
  await shots.take('r_leave_confirm');
  await tester.tap(find.text('Keep racing'));
  await tester.pumpUntil(
    () => find.byType(PauseDialog).evaluate().isEmpty,
    reason: 'Keep racing closes Pause',
  );
  expect(find.byType(GameplayView), findsOneWidget);
  expect(_race(tester).state.data!.held, isFalse);

  // Leave race for real: Pause, Leave race, and the confirmation's Leave.
  await board.openPause();
  await tester.pumpFor(const Duration(milliseconds: 400));
  await tester.tap(find.text('Leave race'));
  await tester.pumpFor(const Duration(milliseconds: 500));
  await tester.tap(
    find.descendant(
      of: find.byKey(const ValueKey('raceLeaveConfirm')),
      matching: find.text('Leave race'),
    ),
  );
  await tester.pumpUntil(
    () =>
        find.byType(GameplayView).evaluate().isEmpty &&
        find.byType(RivalSelectView).evaluate().isNotEmpty,
    reason: 'Leave race back to rival select',
  );
  await tester.pumpFor(const Duration(milliseconds: 600));
  expect(save.document.coins, coins, reason: 'leaving costs nothing');
  expect(save.document.race.rivals[0].wins, 0);

  // A second race (its own raceNo), lost, then New race: the next raceNo.
  await _startFromSelect(tester, board);
  expect(_race(tester).request, const RacePlay(rival: 1, raceNo: 2));
  await _tapStart(tester, board);
  await tester.pumpUntil(
    () => find.byType(RaceLossCard).evaluate().isNotEmpty,
    timeout: const Duration(minutes: 3),
    reason: 'the second loss',
  );
  await tester.pumpFor(const Duration(milliseconds: 800));
  await tester.tap(find.text('New race'));
  await tester.pumpUntil(
    () =>
        find.byType(RaceLossCard).evaluate().isEmpty &&
        find.text('Start').evaluate().isNotEmpty &&
        board.game.geometry != null,
    reason: 'the new race board',
  );
  await board.waitIdle();
  expect(_race(tester).request, const RacePlay(rival: 1, raceNo: 3));
  expect(save.document.race.rivals[0].raceNo, 3);
  await shots.take('r_new_race');
}

/// The race `oom` plays: rival 1's race 6 at stage 20 (`highestLevel` 21).
///
/// Race boards are roomy, and a dead end is rare on them: the first device
/// run (2026-09-30) found none on race 1 with 3,000 random walks, and a
/// breadth-first search of 300,000 states found none on races 1–5 either,
/// while race 6's board reaches one in 4 moves. The generator is seeded
/// (`DifficultyCurve.raceSeed`), so race 6 is the same board on every
/// device; the search below still finds the line itself, so a generator
/// change fails here with a clear reason instead of a wrong tap.
const _oomRaceNo = 6;

/// The shortest legal line from [start] to a dead end (not won, no legal
/// move), found breadth-first with core's own rules; every move is legal by
/// construction (`Rules.tryMove` applied it). Null when none turns up within
/// [budget] expanded states.
List<Move>? _deadEnd(GameState start, {int budget = 100000}) {
  final cameFrom = <GameState, (GameState, Move)>{};
  final seen = <GameState>{start};
  final queue = <GameState>[start];
  for (var head = 0; head < queue.length && head < budget; head++) {
    final state = queue[head];
    final legal = Rules.legalMoves(state);
    if (legal.isEmpty) {
      if (Rules.isWon(state) || identical(state, start)) continue;
      final line = <Move>[];
      for (var at = state; !identical(at, start);) {
        final (before, move) = cameFrom[at]!;
        line.add(move);
        at = before;
      }
      return line.reversed.toList();
    }
    for (final move in legal) {
      final result = Rules.tryMove(state, move);
      if (result is! MoveApplied || !seen.add(result.state)) continue;
      cameFrom[result.state] = (state, move);
      queue.add(result.state);
    }
  }
  return null;
}

Future<void> _oom(WidgetTester tester, Board board, _Shots shots) async {
  final save = get<SaveService>();
  await _openSelect(tester);
  await _startFromSelect(tester, board);
  expect(
    _race(tester).request,
    const RacePlay(rival: 1, raceNo: _oomRaceNo),
    reason: 'the seeded save starts race $_oomRaceNo',
  );
  await _tapStart(tester, board);

  final line = _deadEnd(board.state.board);
  expect(
    line,
    isNotNull,
    reason: 'a dead end on race $_oomRaceNo (a changed generator?)',
  );
  for (final move in line!) {
    // Checked with core first, so a wrong tap can't hide a wrong line.
    final check = Rules.tryMove(board.state.board, move);
    expect(check, isA<MoveApplied>(), reason: '${move.from} → ${move.to}');
    await board.move(move.from, move.to);
    if (board.state.status.name == 'outOfMoves') break;
  }

  await tester.pumpUntil(
    () => find.byType(OutOfMovesSheet).evaluate().isNotEmpty,
    timeout: const Duration(seconds: 20),
    reason: 'Out of Moves in a race',
  );
  await tester.pumpFor(const Duration(milliseconds: 700));
  expect(find.text('Free, as often as you like'), findsOneWidget);
  expect(
    find.descendant(
      of: find.byType(OutOfMovesSheet),
      matching: find.text('+1 Slot'),
    ),
    findsNothing,
  );
  expect(
    find.descendant(
      of: find.byType(OutOfMovesSheet),
      matching: find.text('Restart'),
    ),
    findsOneWidget,
  );
  // The sheet holds the rival's clock.
  expect(_race(tester).state.data!.held, isTrue);
  await shots.take('r_out_of_moves');

  // Undo is free and closes the sheet.
  final coins = save.document.coins;
  await tester.tap(
    find.descendant(
      of: find.byType(OutOfMovesSheet),
      matching: find.text('Undo'),
    ),
  );
  await tester.pumpUntil(
    () => find.byType(OutOfMovesSheet).evaluate().isEmpty,
    reason: 'the sheet to close on Undo',
  );
  expect(save.document.coins, coins, reason: 'a race Undo costs nothing');
  expect(_race(tester).state.data!.held, isFalse);

  // Leave race, asked once.
  await board.openPause();
  await tester.pumpFor(const Duration(milliseconds: 400));
  await tester.tap(find.text('Leave race'));
  await tester.pumpFor(const Duration(milliseconds: 500));
  await tester.tap(
    find.descendant(
      of: find.byKey(const ValueKey('raceLeaveConfirm')),
      matching: find.text('Leave race'),
    ),
  );
  await tester.pumpUntil(
    () =>
        find.byType(GameplayView).evaluate().isEmpty &&
        find.byType(RivalSelectView).evaluate().isNotEmpty,
    reason: 'Leave race back to rival select',
  );
  expect(save.document.race.rivals[0].wins, 0);
}

final class _Shots {
  _Shots(this._binding, this._tester);

  final IntegrationTestWidgetsFlutterBinding _binding;
  final WidgetTester _tester;
  bool _converted = false;

  Future<void> take(String name) async {
    if (Platform.isAndroid && !_converted) {
      await _binding.convertFlutterSurfaceToImage();
      _converted = true;
    }
    await _tester.pump();
    final bytes = await _binding.takeScreenshot(name);
    expect(bytes, isNotEmpty, reason: name);
  }
}
