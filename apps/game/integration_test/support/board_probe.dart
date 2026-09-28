import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_core/nesty_core.dart';
import 'package:nesty_game/features/gameplay/bloc/gameplay_bloc.dart';
import 'package:nesty_game/features/gameplay/game/board_shape_of.dart';
import 'package:nesty_game/features/gameplay/game/nesty_game.dart';
import 'package:nesty_game/features/gameplay/overlays/pause_dialog.dart';
import 'package:nesty_game/features/gameplay/overlays/win_overlay.dart';
import 'package:nesty_game/features/gameplay/pages/gameplay_view.dart';
import 'package:nesty_game/features/home/pages/home_page.dart';
import 'package:nesty_render/nesty_render.dart';

/// The gameplay page's board, pared down from `playthrough_test.dart`'s own
/// `_Board` (same taps-land-on-real-layout technique) for the kill/resume
/// and daily entry points, which don't need its screenshot timing helpers.
final class Board {
  Board(this._tester);

  final WidgetTester _tester;

  Finder get _gameWidget => find.byType(GameWidget<NestyGame>);

  NestyGame get game =>
      _tester.widget<GameWidget<NestyGame>>(_gameWidget).game!;

  GameplayBloc get bloc =>
      _tester.element(find.byType(GameplayView)).read<GameplayBloc>();

  GameplayState get state => bloc.state.data!;

  /// The live `nesty_core` session, for `GameSessionCodec.encode` (m3-design
  /// §4): null only before the bloc has loaded a level.
  GameSession? get session => bloc.session;

  bool get _caughtUp => game.board.board == state.board;

  Offset centreOf(String slotId) {
    final size = _tester.getSize(_gameWidget);
    final padding = MediaQuery.paddingOf(_tester.element(_gameWidget));
    final layout = BoardLayout.compute(
      boardShapeOf(state.board),
      BoardViewport(size: size, padding: padding),
    );
    final slot = layout.slot(slotId);
    return _tester.getTopLeft(_gameWidget) +
        Offset(slot.centerX, layout.shelves[slot.row].hitCenterY);
  }

  Future<void> tap(String slotId) => _tester.tapAt(centreOf(slotId));

  /// Tap-tap from [from] to [to] once the board is idle.
  Future<void> move(String from, String to) async {
    await waitIdle();
    await tap(from);
    await _tester.pumpUntil(
      () => state.selectedSlotId == from,
      reason: '$from selected',
    );
    await _tester.pumpFor(const Duration(milliseconds: 250));
    await drop(to);
  }

  /// A real drag from [from] onto [to] (the L2 tutorial's step 4 accepts
  /// only a drag, m3-design §10.4): press, travel in small steps past the
  /// touch slop, release over [to].
  Future<void> dragMove(String from, String to) async {
    await waitIdle();
    final before = state.moveSeq;
    final start = centreOf(from);
    final end = centreOf(to);
    final gesture = await _tester.startGesture(start);
    await _tester.pump(const Duration(milliseconds: 100));
    const steps = 12;
    for (var i = 1; i <= steps; i++) {
      await gesture.moveTo(Offset.lerp(start, end, i / steps)!);
      await _tester.pump(const Duration(milliseconds: 16));
    }
    await _tester.pump(const Duration(milliseconds: 100));
    await gesture.up();
    await _tester.pumpUntil(
      () => state.moveSeq > before && _caughtUp,
      reason: 'the drag onto $to applied',
      step: const Duration(milliseconds: 4),
    );
  }

  Future<void> drop(String to) async {
    final before = state.moveSeq;
    await tap(to);
    await _tester.pumpUntil(
      () => state.moveSeq > before && _caughtUp,
      reason: 'the move onto $to scheduled',
      step: const Duration(milliseconds: 4),
    );
  }

  Future<void> waitIdle() => _tester.pumpUntil(() {
    final timeline = game.board.timeline;
    return timeline != null &&
        _caughtUp &&
        timeline.isIdle &&
        !timeline.inputLocked;
  }, reason: 'the board to go idle');

  Future<void> waitForLevel(
    int number, {
    Duration settle = const Duration(milliseconds: 800),
  }) async {
    await _tester.pumpUntil(
      () =>
          find.byType(GameplayView).evaluate().isNotEmpty &&
          bloc.state.data?.levelNumber == number &&
          game.geometry != null &&
          game.skin != null,
      timeout: const Duration(seconds: 30),
      reason: 'level $number with its skin',
    );
    await waitIdle();
    await _tester.pumpFor(settle);
  }

  /// Home's dev "Jump to a level" picker (dev flavor).
  Future<void> jumpTo(
    int number,
    String tier, {
    Duration settle = const Duration(milliseconds: 800),
  }) async {
    final tile = find.bySemanticsLabel('Level $number · $tier');
    await _tester.tap(find.text('Jump to a level'));
    await _tester.pumpUntil(
      () => tile.evaluate().isNotEmpty,
      reason: 'the level picker',
    );
    await _tester.pumpFor(const Duration(milliseconds: 500));
    await _tester.tap(tile);
    await waitForLevel(number, settle: settle);
  }

  Future<void> waitForWinOverlay() => _tester.pumpUntil(
    () => find.byType(WinOverlay).evaluate().isNotEmpty,
    timeout: const Duration(seconds: 10),
    reason: 'the win overlay',
  );

  /// The win overlay's Continue: level [number] on the same page.
  Future<void> continueTo(int number) async {
    await _tester.pumpUntil(
      () => find.text('Continue').evaluate().isNotEmpty,
      reason: 'the win overlay\'s Continue',
    );
    await _tester.pumpFor(const Duration(milliseconds: 800));
    await _tester.tap(find.text('Continue'));
    await waitForLevel(number);
  }

  Future<void> openPause() async {
    await _tester.tap(find.bySemanticsLabel('Pause'));
    await _tester.pumpUntil(
      () => find.byType(PauseDialog).evaluate().isNotEmpty,
      reason: 'the pause dialog',
    );
  }

  /// Pause's Home tile: back to Home, which offers [level].
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

/// Pumps until [condition] holds, failing after [timeout] (copied from
/// `playthrough_test.dart` so the two files don't depend on each other).
extension PumpUntil on WidgetTester {
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

  /// Real time passes (the live binding draws every frame meanwhile).
  Future<void> pumpFor(Duration duration) async {
    final end = DateTime.now().add(duration);
    while (DateTime.now().isBefore(end)) {
      await pump(const Duration(milliseconds: 16));
    }
  }
}
