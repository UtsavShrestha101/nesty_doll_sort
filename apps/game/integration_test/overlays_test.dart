import 'dart:async' show unawaited;
import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:nesty_core/nesty_core.dart';
import 'package:nesty_game/core/dependency_injection/di.dart';
import 'package:nesty_game/core/models/intro_mechanic.dart';
import 'package:nesty_game/core/models/play_request.dart';
import 'package:nesty_game/core/repository/level_repository.dart';
import 'package:nesty_game/core/router/app_router.dart';
import 'package:nesty_game/core/services/save/in_memory_save_service.dart';
import 'package:nesty_game/core/services/save/save_document.dart';
import 'package:nesty_game/core/services/save/save_service.dart';
import 'package:nesty_game/core/ui/nesty_ui.dart';
import 'package:nesty_game/features/fx/chest/chest_reward_sequence.dart';
import 'package:nesty_game/features/gameplay/bloc/gameplay_bloc.dart';
import 'package:nesty_game/features/gameplay/overlays/intro_mechanic_card.dart';
import 'package:nesty_game/features/gameplay/overlays/milestone_chest_modal.dart';
import 'package:nesty_game/features/gameplay/overlays/out_of_moves_sheet.dart';
import 'package:nesty_game/features/gameplay/overlays/win_overlay.dart';
import 'package:nesty_game/features/gameplay/pages/gameplay_view.dart';
import 'package:nesty_game/features/gameplay/widgets/booster_bar.dart';
import 'package:nesty_game/features/gameplay/widgets/generating_overlay.dart';
import 'package:nesty_game/features/gameplay/widgets/soft_stuck_banner.dart';
import 'package:nesty_game/features/home/pages/home_page.dart';
import 'package:nesty_game/features/splash/pages/splash_page.dart';
import 'package:nesty_game/main_dev.dart' as app;

import 'support/board_probe.dart';
import 'support/seeded_save.dart';

/// Phase 4's overlays on a device (m7-design P4.7, architecture §7.3; lane O;
/// PROGRESS D169): the win card's stars and helper note on a hinted replay of
/// level 1, the milestone chest moment on level 10 (closed, wiggle, open,
/// Collect's flights), the 10th Bonus Endless level (the generating card, the
/// bonus win card, its chest), the Out of Moves sheet with the free undos
/// spent, two +1 Slots and the limit toast, a soft-stuck board (Undo glowing,
/// then Restart glowing with nothing to undo), and the intro loops of levels
/// 16, 31 and 51. Splash errors stay host-only: a device run can't fail
/// storage or the bundle on purpose.
///
/// Written, not run, by the overlays lane (one simulator, a shared
/// `apps/game/build`): the integrator wires it into `tools/scripts/nesty-test`
/// and the device stage runs it on both platforms.
///
/// ```sh
/// cd apps/game
/// NESTY_SCREENSHOT_DIR=/some/dir flutter drive --flavor dev \
///   --driver test_driver/integration_test.dart \
///   --target integration_test/overlays_test.dart -d <device>
/// ```
///
/// It seeds its own save (a returning player past level 60, `bonus.next` 10,
/// no intro seen) before `app.main()`, so start from a fresh install.
/// Screenshots are prefixed `ov_`.
void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  binding.framePolicy = LiveTestWidgetsFlutterBindingFramePolicy.fullyLive;

  testWidgets(
    'the win card, the chest moment, the bonus chest, Out of Moves with the '
    'undos spent, the +1 Slot limit, a stuck board and the intro loops',
    (tester) async {
      await seedSave(
        const SaveDocument(
          currentLevel: 60,
          highestLevel: 60,
          coins: 400,
          tutorialDone: true,
          stats: SaveStats(wins: 59),
          records: SaveRecords(badges: ['first_family']),
          bonus: BonusProgress(next: 10),
        ),
      );
      app.main();
      final shots = _Shots(binding, tester);
      final board = Board(tester);
      await tester.pumpUntil(
        () =>
            find.byType(SplashPage).evaluate().isEmpty &&
            find.byType(HomePage).evaluate().isNotEmpty,
        timeout: const Duration(seconds: 90),
        reason: 'Home after the splash',
      );
      await tester.pumpFor(const Duration(seconds: 1));

      await _hintedReplay(tester, board, shots);
      await _milestoneChest(tester, board, shots);
      await _outOfMovesSpent(tester, board, shots);
      await _slotLimit(tester, board, shots);
      await _home(tester);
      await _introLoops(tester, board, shots);
      // After the intro loops, so their boards (a generated bonus board
      // can bring towers, glass or ice) open no card of their own and never
      // take levels 16, 31 and 51's first showing (the device run,
      // 2026-09-30).
      await _bonusChest(tester, board, shots);
      await _stuck(tester, board, shots);
    },
    timeout: const Timeout(Duration(minutes: 25)),
  );
}

/// The screenshots of this file, taken as `playthrough_test.dart` takes its.
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
    final bytes = await _binding.takeScreenshot('ov_$name');
    expect(bytes, isNotEmpty, reason: name);
  }
}

/// A level's tier as its dev picker tile labels it ("Level 16 · Hard").
String _tierLabel(int level) {
  final entry = get<LevelRepository>().entryAt(level)!;
  return switch (entry.tier) {
    Tier.easy => 'Easy',
    Tier.medium => 'Medium',
    Tier.hard => 'Hard',
    Tier.superhard => 'Super Hard',
  };
}

/// Back to Home from wherever a scenario ended.
Future<void> _home(WidgetTester tester) async {
  unawaited(
    get<AppRouter>().navigate(const MainShellRoute(children: [HomeRoute()])),
  );
  await tester.pumpUntil(
    () =>
        find.byType(GameplayView).evaluate().isEmpty &&
        find.byType(HomePage).evaluate().isNotEmpty &&
        find.text('Jump to a level').evaluate().isNotEmpty,
    timeout: const Duration(seconds: 30),
    reason: 'Home',
  );
  await tester.pumpFor(const Duration(milliseconds: 600));
}

/// Dismisses an intro card that is up, with a screenshot of its loop first.
Future<void> _dismissIntro(
  WidgetTester tester,
  Board board,
  _Shots shots,
  IntroMechanic mechanic, {
  required String shot,
}) async {
  await tester.pumpUntil(
    () => board.state.intro == mechanic,
    reason: 'the ${mechanic.name} intro card',
  );
  expect(find.byType(IntroMechanicCard), findsOneWidget);
  // A frame or two into the loop, not on its first.
  await tester.pumpFor(const Duration(milliseconds: 900));
  await shots.take(shot);
  await tester.tap(find.text('Got it'));
  await tester.pumpUntil(
    () => board.state.intro == null,
    reason: 'the ${mechanic.name} intro card dismissed',
  );
  await board.waitIdle();
  await tester.pumpFor(const Duration(milliseconds: 300));
}

/// Applies the solver's own hint until the level is won (the dev flavor keeps
/// Hint free).
Future<void> _solveWithHints(
  WidgetTester tester,
  Board board, {
  int maxMoves = 40,
}) async {
  final hintButton = find.text('Hint');
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
    await board.move(hint.from, hint.to);
  }
  fail('did not solve within $maxMoves moves');
}

// ── A hinted replay of level 1: 2 stars and the helper note (11.4c) ──────

Future<void> _hintedReplay(
  WidgetTester tester,
  Board board,
  _Shots shots,
) async {
  unawaited(
    get<AppRouter>().push(GameplayRoute(request: const PlayRequest.replay(1))),
  );
  await board.waitForLevel(1);
  await _solveWithHints(tester, board);
  await board.waitForWinOverlay();
  // The stars start at 1,300 ms; the three segments and the flourish end
  // about 3.3 s in.
  await tester.pumpFor(const Duration(milliseconds: 1500));
  await shots.take('01a_replay_stars_starting');
  await tester.pumpFor(const Duration(milliseconds: 2500));
  expect(board.state.starsCapped, isTrue, reason: 'a hint held it to 2 stars');
  expect(find.byKey(WinOverlay.noteKey), findsOneWidget);
  expect(
    find.text('Wins with a hint or an extra slot earn up to 2 stars.'),
    findsOneWidget,
  );
  expect(find.text('Back to Chapters'), findsOneWidget);
  await shots.take('01b_replay_helper_note');
  await tester.tap(find.text('Back to Chapters'));
  await tester.pumpFor(const Duration(seconds: 1));
  await _home(tester);
}

// ── Level 10: the milestone chest moment (10.3, 10.3b–d) ─────────────────

Future<void> _milestoneChest(
  WidgetTester tester,
  Board board,
  _Shots shots,
) async {
  await board.jumpTo(10, _tierLabel(10));
  await _solveWithHints(tester, board);
  await board.waitForWinOverlay();
  await tester.pumpFor(const Duration(milliseconds: 3500));
  // Level 10 is chapter 1's level 10: the chest replaces the countdown.
  expect(board.state.chest, isNotNull, reason: 'level 10 pays the chest');
  await shots.take('02a_win_card');
  await tester.tap(find.text('Continue'));
  await _openAndCollectChest(tester, shots, 'chest10', next: 11, board: board);
  await _home(tester);
}

/// The chest card: it arrives closed with its contents shown, Open wiggles
/// then opens (rays behind), Collect flies the coins to the pill and the hint
/// to the button.
Future<void> _openAndCollectChest(
  WidgetTester tester,
  _Shots shots,
  String prefix, {
  required Board board,
  int? next,
}) async {
  await tester.pumpUntil(
    () => find.byType(MilestoneChestModal).evaluate().isNotEmpty,
    reason: 'the milestone chest',
  );
  await tester.pumpFor(
    const Duration(milliseconds: ChestRewardSequence.arrivalMs + 300),
  );
  // The contents show before it opens.
  expect(find.text('+100 coins'), findsOneWidget);
  expect(find.text('+1 hint'), findsOneWidget);
  await shots.take('${prefix}_closed');
  await tester.tap(find.text('Open'));
  await tester.pumpFor(const Duration(milliseconds: 250));
  await shots.take('${prefix}_wiggle');
  await tester.pumpFor(
    const Duration(milliseconds: ChestRewardSequence.wiggleMs + 150),
  );
  await shots.take('${prefix}_open');
  await tester.pumpUntil(
    () => find.text('Collect').evaluate().isNotEmpty,
    reason: 'the chest open',
  );
  await tester.pumpFor(const Duration(milliseconds: 500));
  await shots.take('${prefix}_open_idle');
  await tester.tap(find.text('Collect'));
  await tester.pumpFor(const Duration(milliseconds: 450));
  await shots.take('${prefix}_flights');
  await tester.pumpUntil(
    () => find.byType(MilestoneChestModal).evaluate().isEmpty,
    timeout: const Duration(seconds: 10),
    reason: 'the chest collected',
  );
  if (next != null) await board.waitForLevel(next);
}

// ── Bonus level 10: the generating card, the bonus win card, its chest ───

Future<void> _bonusChest(WidgetTester tester, Board board, _Shots shots) async {
  unawaited(
    get<AppRouter>().push(GameplayRoute(request: const PlayRequest.bonus(10))),
  );
  // An un-prefetched bonus level is generated on the device behind the
  // card (frame 12.5): watch for it while the route opens.
  var sawGenerating = false;
  await tester.pumpUntil(
    () {
      if (find.byType(GeneratingOverlay).evaluate().isNotEmpty) {
        sawGenerating = true;
      }
      return find.byType(GameplayView).evaluate().isNotEmpty &&
          find.byType(GeneratingOverlay).evaluate().isEmpty &&
          board.state.status == GameplayStatus.playing;
    },
    timeout: const Duration(seconds: 60),
    step: const Duration(milliseconds: 16),
    reason: 'bonus level 10',
  );
  expect(sawGenerating, isTrue, reason: 'the generating card showed');
  await board.waitIdle();
  await tester.pumpFor(const Duration(milliseconds: 600));
  await _solveWithHints(tester, board);
  await board.waitForWinOverlay();
  await tester.pumpFor(const Duration(milliseconds: 3000));
  expect(find.text('Bonus Level 10'), findsWidgets);
  expect(find.text('10 / 10'), findsOneWidget);
  expect(find.byType(StarRow), findsNothing, reason: 'no stars on a bonus');
  await shots.take('03a_bonus_win');
  expect(board.state.chest, isNotNull, reason: 'every 10th bonus pays one');
  await tester.tap(find.text('Continue'));
  await tester.pumpUntil(
    () => find.byType(MilestoneChestModal).evaluate().isNotEmpty,
    reason: 'the bonus chest',
  );
  await tester.pumpFor(const Duration(milliseconds: 900));
  expect(
    find.text('A chest for bonus level 10. Here’s what’s inside.'),
    findsOneWidget,
  );
  await _openAndCollectChest(tester, shots, 'chest_bonus', board: board);
  await _home(tester);
}

// ── Out of Moves with the free undos spent (12.8) ────────────────────────

Future<void> _outOfMovesSpent(
  WidgetTester tester,
  Board board,
  _Shots shots,
) async {
  // The dev flavor's boosters never run out, which hides every price.
  (get<SaveService>() as InMemorySaveService).debugUnlimitedBoosters = false;
  await board.jumpTo(16, _tierLabel(16));
  await _dismissIntro(
    tester,
    board,
    shots,
    IntroMechanic.towers,
    shot: '04a_l16_towers_loop',
  );
  Future<void> deadEnd() async {
    // Level 16's known dead end (playthrough_test.dart): the top of the
    // r1c1 tower onto the only empty stand leaves no legal move.
    await board.move('r1c1', 'r0c3');
    await tester.pumpUntil(
      () => find.byType(OutOfMovesSheet).evaluate().isNotEmpty,
      timeout: const Duration(seconds: 10),
      reason: 'the Out-of-Moves sheet',
    );
    await tester.pumpFor(const Duration(milliseconds: 600));
  }

  Future<void> undoFromSheet() async {
    await tester.tap(
      find.descendant(
        of: find.byType(OutOfMovesSheet),
        matching: find.text('Undo'),
      ),
    );
    await tester.pumpUntil(
      () =>
          find.byType(OutOfMovesSheet).evaluate().isEmpty &&
          board.state.status == GameplayStatus.playing,
      reason: 'the undone board',
    );
    await board.waitIdle();
  }

  await deadEnd();
  expect(find.text('Free · 2 left'), findsOneWidget);
  await undoFromSheet();
  await deadEnd();
  expect(find.text('Free · 1 left'), findsOneWidget);
  await undoFromSheet();
  await deadEnd();
  // Both free undos are spent: the row says so and shows its price.
  expect(find.text('Your 2 free undos are used'), findsOneWidget);
  await shots.take('04b_oom_undos_spent');
  await tester.tap(
    find.descendant(
      of: find.byType(OutOfMovesSheet),
      matching: find.text('Restart'),
    ),
  );
  await tester.pumpUntil(
    () =>
        find.byType(OutOfMovesSheet).evaluate().isEmpty &&
        board.state.status == GameplayStatus.playing,
    reason: 'the restarted board',
  );
  (get<SaveService>() as InMemorySaveService).debugUnlimitedBoosters = null;
  await _home(tester);
}

// ── Two +1 Slots and the limit toast (12.9) ──────────────────────────────

Future<void> _slotLimit(WidgetTester tester, Board board, _Shots shots) async {
  await board.jumpTo(9, _tierLabel(9));
  for (var i = 0; i < 2; i++) {
    await tester.tap(find.text('+Slot'));
    await tester.pumpUntil(
      () => board.state.board.extraSlotCount == i + 1,
      reason: 'extra slot ${i + 1}',
    );
    await board.waitIdle();
  }
  // The sunk face and its badge.
  expect(find.text('2/2'), findsOneWidget);
  await tester.tap(find.text('+Slot'));
  await tester.pumpUntil(
    () => find
        .text('Two extra slots is the most for one level.')
        .evaluate()
        .isNotEmpty,
    reason: 'the slot-limit toast',
  );
  await tester.pumpFor(const Duration(milliseconds: 500));
  expect(board.state.board.extraSlotCount, 2, reason: 'nothing was added');
  await shots.take('05_slot_limit_toast');
}

// ── A stuck board: Undo glowing, then Restart glowing (3.4, 12.7) ────────

/// The shortest line from [start] to a board that still has legal moves but
/// that the solver proves unsolvable (the soft-stuck check's own budget),
/// found breadth-first with core's own rules. With [lastCompletes] its last
/// move completes a family (which clears the undo history, spec §2.4:
/// nothing to undo); otherwise it doesn't. Null when none turns up within
/// [budget] expanded states.
///
/// Breadth-first, not random walks: on levels 9–34 no soft-stuck board
/// turns up at all (a dead end there is Out of Moves), and random walks
/// missed even level 60's one-move line (host probe, device run
/// 2026-09-30).
List<Move>? _stuckLine(
  GameState start, {
  required bool lastCompletes,
  int budget = 4000,
}) {
  final cameFrom = <GameState, (GameState, Move)>{};
  final seen = <GameState>{start};
  final queue = <GameState>[start];
  for (var head = 0; head < queue.length && head < budget; head++) {
    final state = queue[head];
    for (final move in Rules.legalMoves(state)) {
      final result = Rules.tryMove(state, move);
      if (result is! MoveApplied || !seen.add(result.state)) continue;
      final after = result.state;
      cameFrom[after] = (state, move);
      if (Rules.isWon(after)) continue;
      queue.add(after);
      if (result.completedSet != lastCompletes) continue;
      if (Rules.legalMoves(after).isEmpty) continue;
      if (Solver.softStuck(after) != SolveVerdict.unsolvable) continue;
      final line = <Move>[];
      for (var at = after; !identical(at, start);) {
        final (before, step) = cameFrom[at]!;
        line.add(step);
        at = before;
      }
      return line.reversed.toList();
    }
  }
  return null;
}

Future<void> _playLine(Board board, List<Move> line) async {
  for (final move in line) {
    await board.move(move.from, move.to);
  }
}

/// Level 60, the seeded save's next level: one move (r1c2 → r0c0) leaves
/// it soft stuck with the undo kept, and seven more end on a completion
/// with the board still stuck (the host probe's lines; the search finds
/// them itself).
const _stuckLevel = 60;

Future<void> _stuck(WidgetTester tester, Board board, _Shots shots) async {
  // Undo glowing, on a campaign board (frame 3.4).
  await board.jumpTo(_stuckLevel, _tierLabel(_stuckLevel));
  final withUndo = _stuckLine(board.state.board, lastCompletes: false);
  expect(withUndo, isNotNull, reason: 'a stuck board that keeps its undo');
  await _playLine(board, withUndo!);
  await tester.pumpUntil(
    () => find.text('Hmm, this looks stuck').evaluate().isNotEmpty,
    timeout: const Duration(seconds: 20),
    reason: 'the soft-stuck banner',
  );
  await tester.pumpFor(const Duration(milliseconds: 500));
  expect(find.text('Try Undo? You can keep playing too.'), findsOneWidget);
  expect(find.byType(BoosterGlow), findsOneWidget);
  await shots.take('06a_stuck_undo_glows');
  await tester.tap(
    find.descendant(
      of: find.byType(SoftStuckBanner),
      matching: find.text('Undo'),
    ),
  );
  await tester.pumpUntil(
    () => !board.state.softStuck,
    reason: 'the banner cleared by Undo',
  );
  await board.waitIdle();

  // Nothing to undo: Restart glows and the toast has no button (12.7).
  await tester.tap(find.text('Restart'));
  await board.waitIdle();
  final withoutUndo = _stuckLine(board.state.board, lastCompletes: true);
  if (withoutUndo == null) {
    // Not every board has one; the host tests cover the state either way.
    debugPrint('[overlays_test] no stuck board with an empty history here');
    await _home(tester);
    return;
  }
  await _playLine(board, withoutUndo);
  await tester.pumpUntil(
    () => find
        .text('Try Restart? You can keep playing too.')
        .evaluate()
        .isNotEmpty,
    timeout: const Duration(seconds: 20),
    reason: 'the soft-stuck toast suggesting Restart',
  );
  await tester.pumpFor(const Duration(milliseconds: 500));
  expect(
    find.descendant(
      of: find.byType(SoftStuckBanner),
      matching: find.byType(TactileButton),
    ),
    findsNothing,
  );
  expect(find.byType(BoosterGlow), findsOneWidget);
  await shots.take('06b_stuck_restart_glows');
  await tester.tap(find.text('Restart'));
  await board.waitIdle();
  await _home(tester);
}

// ── The intro loops: levels 16 (seen above), 31 and 51 ───────────────────

Future<void> _introLoops(WidgetTester tester, Board board, _Shots shots) async {
  await board.jumpTo(31, _tierLabel(31));
  await _dismissIntro(
    tester,
    board,
    shots,
    IntroMechanic.glass,
    shot: '07a_l31_glass_loop',
  );
  await _home(tester);
  await board.jumpTo(51, _tierLabel(51));
  await _dismissIntro(
    tester,
    board,
    shots,
    IntroMechanic.ice,
    shot: '07b_l51_ice_loop',
  );
  await _home(tester);
}
