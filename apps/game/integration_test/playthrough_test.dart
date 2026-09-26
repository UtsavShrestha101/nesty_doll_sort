import 'dart:io' show Platform;

import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:nesty_core/nesty_core.dart';
import 'package:nesty_game/core/dependency_injection/di.dart';
import 'package:nesty_game/features/gameplay/bloc/gameplay_bloc.dart';
import 'package:nesty_game/features/gameplay/game/board_shape_of.dart';
import 'package:nesty_game/features/gameplay/game/nesty_game.dart';
import 'package:nesty_game/features/gameplay/overlays/out_of_moves_sheet.dart';
import 'package:nesty_game/features/gameplay/overlays/pause_dialog.dart';
import 'package:nesty_game/features/gameplay/overlays/win_overlay.dart';
import 'package:nesty_game/features/gameplay/pages/gameplay_view.dart';
import 'package:nesty_game/features/home/pages/home_page.dart';
import 'package:nesty_game/features/home/showcase/showcase_dolls.dart';
import 'package:nesty_game/features/splash/pages/splash_page.dart';
import 'package:nesty_game/main_dev.dart' as app;
import 'package:nesty_render/nesty_render.dart';

/// The dev flavor on a simulator or emulator, with every real M2 service
/// (bundled levels, the skin, the 29 Lottie files, SoLoud, the isolate
/// solver): Splash → Home → level 1 and level 2 played to the win overlay
/// → level 16 into Out of Moves → Pause → Home (BACKLOG M2 "On-device
/// playthrough", PROGRESS D57; spec §10.1).
///
/// Taps land on slot centres computed with `BoardLayout` for the screen
/// the board is on (checked against the board's own layout), so they
/// travel the real path: Flutter gestures → the Flame board → the bloc.
/// Mid-animation screenshots are taken at a fixed time of the board's
/// timeline (m2-lottie-design §7), with the engine paused while the
/// platform captures the screen. The driver saves them on the host:
///
/// ```sh
/// cd apps/game
/// NESTY_SCREENSHOT_DIR=/some/dir flutter drive --flavor dev \
///   --driver test_driver/integration_test.dart \
///   --target integration_test/playthrough_test.dart -d <device>
/// ```
void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  // The game runs as it does for a player: Flame's loop and every Lottie
  // get the frames they ask for, not only the ones the test pumps.
  binding.framePolicy = LiveTestWidgetsFlutterBindingFramePolicy.fullyLive;

  testWidgets(
    'plays levels 1 and 2 to the win overlay, runs out of moves on level '
    '16, pauses and goes home',
    (tester) async {
      final shots = _Screenshots(binding, tester);
      final board = _Board(tester, shots);

      app.main();

      // Splash (frame 1.1) while the levels, the skin, the Lottie files and
      // the sounds load: first as it opens, then (if it is still up) once
      // the skin's shelf dolls have landed.
      await tester.pumpUntil(
        () => find.byType(SplashPage).evaluate().isNotEmpty,
        reason: 'the splash',
      );
      await shots.take('00_splash');
      await tester.pumpUntil(
        () =>
            find.byType(SplashPage).evaluate().isEmpty ||
            get<ShowcaseDolls>().current.value != null,
        timeout: const Duration(seconds: 60),
        reason: 'the splash art',
      );
      if (find.byType(SplashPage).evaluate().isNotEmpty) {
        await shots.take('00b_splash_loaded');
      }

      // Home (frame 2.1): level 1 (InMemorySaveService starts every launch
      // there, D13).
      await tester.pumpUntil(
        () =>
            find.byType(SplashPage).evaluate().isEmpty &&
            find.bySemanticsLabel('Play level 1').evaluate().isNotEmpty,
        timeout: const Duration(seconds: 60),
        reason: 'Home with level 1',
      );
      // The route transition and the idle dolls' first loop.
      await tester.pumpFor(const Duration(milliseconds: 1500));
      await shots.take('01_home');

      // ── Level 1: red3 · red2 · red1 (maxSize 3, one family) ──
      await tester.tap(find.bySemanticsLabel('Play level 1'));
      await board.waitForLevel(1);
      expect(
        board.state.board.slot('r0c0'),
        _open(DollColor.red, outer: 3, length: 1),
      );
      await shots.take('02_l1_board');

      // Tap-tap (spec §2.2): red2 lifts (doll_pick lift, then the wobble
      // loop and the select glow; frame 2.3)…
      await board.tap('r0c2');
      await tester.pumpUntil(
        () => board.state.selectedSlotId == 'r0c2',
        reason: 'r0c2 selected',
      );
      await tester.pumpFor(const Duration(milliseconds: 450));
      await shots.take('03_selection');

      // …and drops inside red3: doll_move to the hover point 0–267 ms, then
      // doll_nest 267–667 ms with the clack at 537 ms (frame 2.4).
      final nest = await board.drop('r0c0');
      await board.shotAt('04_nesting', nest, 250);
      await board.waitIdle();
      expect(
        board.state.board.slot('r0c0'),
        _open(DollColor.red, outer: 3, length: 2),
      );
      await tester.pumpFor(const Duration(milliseconds: 200));
      await shots.take('04b_after_nesting');

      // red1 completes the family (frame 2.5): doll_complete from t0 =
      // 667 ms (the shine, the hops from t0 + 300, the flight to the counter
      // from t0 + 700 with the dust puff and the sparkle trail), then Won
      // at the batch end + 250 ms.
      final complete = await board.move('r1c1', 'r0c0');
      await board.shotAt('05_family_complete', complete, 667 + 420);
      await board.shotAt('05b_family_flying', complete, 667 + 880);
      expect(board.state.status, GameplayStatus.won);

      // Win (frames 1.5, 2.8): ribbon, confetti, the hopping family, "+10".
      await board.waitForWinOverlay();
      await tester.pumpFor(const Duration(milliseconds: 1500));
      await shots.take('06_win');

      // Continue loads level 2 in the same page (frame 2.11), with its own
      // art from its first frame (level 2 adds blue, which level 1's skin
      // doesn't hold).
      await board.continueTo(2);
      await shots.take('07_l2_board');

      // ── Level 2: red2+red1 into red3, then the swallow (spec §2.2 #3,
      // frame 1.6): blue3 dropped on blue2 closes over it. ──
      await board.move('r1c0', 'r0c0');
      await board.waitIdle();
      expect(board.state.setsCompleted, 1);
      // doll_move to the hover point (1.06 × blue2's height) 0–267 ms,
      // then doll_swallow 267–667 ms: the lid opens mid-air and the body
      // drops over blue2.
      final swallow = await board.move('r1c1', 'r0c1');
      await board.shotAt('08_l2_swallow', swallow, 267 + 170);
      await board.waitIdle();
      expect(
        board.state.board.slot('r0c1'),
        _open(DollColor.blue, outer: 3, length: 2),
      );
      await tester.pumpFor(const Duration(milliseconds: 200));
      await shots.take('08b_l2_swallowed');

      await board.move('r1c2', 'r0c1');
      await board.waitForWinOverlay();
      expect(board.state.levelNumber, 2);
      await tester.pumpFor(const Duration(milliseconds: 1500));
      await shots.take('09_l2_win');

      // Continue to level 3, then Pause → Home.
      await board.continueTo(3);
      await board.openPause();
      await board.pauseToHome(level: 3);

      // ── Level 16 (towers, HARD) from the dev level picker: the top of
      // the r1c1 tower onto the only empty stand leaves no legal move (a
      // breadth-first search over the bundle: the shortest Out-of-Moves
      // line among levels 1–30). ──
      await tester.tap(find.text('Jump to a level'));
      await tester.pumpUntil(
        () => find.bySemanticsLabel('Level 16 · Hard').evaluate().isNotEmpty,
        reason: 'the level picker',
      );
      await tester.pumpFor(const Duration(milliseconds: 500));
      await tester.tap(find.bySemanticsLabel('Level 16 · Hard'));
      await board.waitForLevel(16);
      await shots.take('10_l16_board');
      await board.move('r1c1', 'r0c3');
      await tester.pumpUntil(
        () => find.byType(OutOfMovesSheet).evaluate().isNotEmpty,
        timeout: const Duration(seconds: 10),
        reason: 'the Out-of-Moves sheet',
      );
      expect(board.state.status, GameplayStatus.outOfMoves);
      await tester.pumpFor(const Duration(milliseconds: 700));
      await shots.take('11_out_of_moves');

      // Restart from the sheet, then Pause (frame 3.9) and go Home.
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
      await board.waitIdle();
      await board.openPause();
      await tester.pumpFor(const Duration(milliseconds: 600));
      await shots.take('12_pause');
      await board.pauseToHome(level: 3);
      await tester.pumpFor(const Duration(milliseconds: 700));
      await shots.take('13_home_after');
    },
    timeout: const Timeout(Duration(minutes: 8)),
  );
}

/// An open slot holding the run of [length] [color] dolls from [outer] down.
OpenSlot _open(DollColor color, {required int outer, required int length}) =>
    OpenSlot(
      nest: Nest.run(color, outer: outer, length: length),
    );

/// Takes each screenshot through the platform and hands it to the driver,
/// which saves `<name>.png` on the host.
final class _Screenshots {
  _Screenshots(this._binding, this._tester);

  final IntegrationTestWidgetsFlutterBinding _binding;
  final WidgetTester _tester;
  bool _surfaceConverted = false;

  Future<void> take(String name) async {
    if (Platform.isAndroid && !_surfaceConverted) {
      // Android draws Flutter into a SurfaceView the platform can't read
      // back; the plugin swaps in an image view for the rest of the test.
      await _binding.convertFlutterSurfaceToImage();
      _surfaceConverted = true;
    }
    await _tester.pump();
    final bytes = await _binding.takeScreenshot(name);
    expect(bytes, isNotEmpty, reason: name);
  }
}

/// The gameplay page's board: its Flame game, its bloc, and taps on slot
/// centres laid out with `BoardLayout` (spec §10.3).
final class _Board {
  _Board(this._tester, this._shots);

  final WidgetTester _tester;
  final _Screenshots _shots;

  Finder get _gameWidget => find.byType(GameWidget<NestyGame>);

  NestyGame get game =>
      _tester.widget<GameWidget<NestyGame>>(_gameWidget).game!;

  GameplayBloc get bloc =>
      _tester.element(find.byType(GameplayView)).read<GameplayBloc>();

  GameplayState get state => bloc.state.data!;

  /// The board has scheduled the bloc's latest effect (effects are queued
  /// and scheduled in the game's next tick).
  bool get _caughtUp => game.board.board == state.board;

  /// [slotId]'s column centre on its shelf's hit band, on screen: the
  /// layout `BoardLayout` computes for this board on the game's viewport
  /// (the screen minus its safe areas), which must be the one the board
  /// drew. The board lays out on Flame's float32 size, so the two agree to
  /// a small fraction of a pixel on a fractional screen width.
  Offset centreOf(String slotId) {
    final size = _tester.getSize(_gameWidget);
    final padding = MediaQuery.paddingOf(_tester.element(_gameWidget));
    final layout = BoardLayout.compute(
      boardShapeOf(state.board),
      BoardViewport(size: size, padding: padding),
    );
    final drawn = game.geometry!;
    final slot = layout.slot(slotId);
    expect(drawn.slot(slotId).centerX, closeTo(slot.centerX, 1e-3));
    expect(
      drawn.shelves[slot.row].hitCenterY,
      closeTo(layout.shelves[slot.row].hitCenterY, 1e-3),
    );
    return _tester.getTopLeft(_gameWidget) +
        Offset(slot.centerX, layout.shelves[slot.row].hitCenterY);
  }

  Future<void> tap(String slotId) => _tester.tapAt(centreOf(slotId));

  /// Tap-tap from [from] to [to] once the board is idle; returns the
  /// board's timeline time when it scheduled the move's batch.
  Future<double> move(String from, String to) async {
    await waitIdle();
    await tap(from);
    await _tester.pumpUntil(
      () => state.selectedSlotId == from,
      reason: '$from selected',
    );
    await _tester.pumpFor(const Duration(milliseconds: 250));
    return drop(to);
  }

  /// Taps [to] with a nest lifted; returns the board's timeline time when it
  /// scheduled the move's batch.
  Future<double> drop(String to) async {
    final before = state.moveSeq;
    await tap(to);
    await _tester.pumpUntil(
      () => state.moveSeq > before && _caughtUp,
      reason: 'the move onto $to scheduled',
      step: const Duration(milliseconds: 4),
    );
    return game.board.timeline!.nowMs;
  }

  /// A screenshot [atMs] into the batch scheduled at [batchStart] (timeline
  /// time), with the engine paused while the platform captures it.
  Future<void> shotAt(String name, double batchStart, double atMs) async {
    final timeline = game.board.timeline!;
    await _tester.pumpUntil(
      () => timeline.nowMs >= batchStart + atMs,
      reason: '$name at $atMs ms',
      step: const Duration(milliseconds: 4),
    );
    game.pauseEngine();
    try {
      await _shots.take(name);
    } finally {
      game.resumeEngine();
    }
  }

  /// The board has played everything the bloc gave it and takes input
  /// again.
  Future<void> waitIdle() => _tester.pumpUntil(() {
    final timeline = game.board.timeline;
    return timeline != null &&
        _caughtUp &&
        timeline.isIdle &&
        !timeline.inputLocked;
  }, reason: 'the board to go idle');

  /// Level [number] is on the board with its own art: the bloc has it, the
  /// board laid it out and the skin prepared for that layout arrived.
  Future<void> waitForLevel(int number, {Object? previousSkin}) async {
    await _tester.pumpUntil(
      () =>
          find.byType(GameplayView).evaluate().isNotEmpty &&
          bloc.state.data?.levelNumber == number &&
          game.geometry != null &&
          game.skin != null &&
          !identical(game.skin, previousSkin) &&
          find.byType(WinOverlay).evaluate().isEmpty,
      timeout: const Duration(seconds: 30),
      reason: 'level $number with its skin',
    );
    await waitIdle();
    // The route transition and the art's first frames.
    await _tester.pumpFor(const Duration(milliseconds: 800));
  }

  /// Continue on the win overlay: level [number]'s board has its own art
  /// in the very update that lays it out, never the previous level's skin,
  /// which holds only that level's colours (a colour it lacks draws
  /// nothing; review CORRECTNESS-1).
  Future<void> continueTo(int number) async {
    final previousSkin = game.skin;
    await _tester.tap(find.text('Continue'));
    await _tester.pumpUntil(
      () => bloc.state.data?.levelNumber == number && _caughtUp,
      reason: 'level $number on the board',
      step: const Duration(milliseconds: 4),
    );
    expect(game.skin, isNotNull);
    expect(
      identical(game.skin, previousSkin),
      isFalse,
      reason: 'level $number drew with the previous level\'s skin',
    );
    await waitForLevel(number, previousSkin: previousSkin);
  }

  Future<void> waitForWinOverlay() => _tester.pumpUntil(
    () => find.byType(WinOverlay).evaluate().isNotEmpty,
    timeout: const Duration(seconds: 10),
    reason: 'the win overlay',
  );

  Future<void> openPause() async {
    await _tester.tap(find.bySemanticsLabel('Pause'));
    await _tester.pumpUntil(
      () => find.byType(PauseDialog).evaluate().isNotEmpty,
      reason: 'the pause dialog',
    );
  }

  /// Pause's Home tile: back to Home, which offers [level], once the route
  /// transition is over.
  Future<void> pauseToHome({required int level}) async {
    await _tester.tap(
      find.descendant(
        of: find.byType(PauseDialog),
        matching: find.text('Home'),
      ),
    );
    await _tester.pumpUntil(
      () =>
          find.byType(GameplayView).evaluate().isEmpty &&
          find.byType(HomePage).evaluate().isNotEmpty &&
          find.bySemanticsLabel('Play level $level').evaluate().isNotEmpty,
      reason: 'Home with level $level',
    );
    await _tester.pumpFor(const Duration(milliseconds: 600));
  }
}

extension on WidgetTester {
  /// Real time passes (the live binding draws every frame meanwhile).
  Future<void> pumpFor(Duration duration) async {
    final end = DateTime.now().add(duration);
    while (DateTime.now().isBefore(end)) {
      await pump(const Duration(milliseconds: 16));
    }
  }

  /// Pumps until [condition] holds, failing after [timeout].
  Future<void> pumpUntil(
    bool Function() condition, {
    required String reason,
    Duration timeout = const Duration(seconds: 15),
    Duration step = const Duration(milliseconds: 50),
  }) async {
    final end = DateTime.now().add(timeout);
    while (!condition()) {
      if (DateTime.now().isAfter(end)) {
        fail('Timed out after $timeout waiting for $reason');
      }
      await pump(step);
    }
  }
}
