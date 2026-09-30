// `NestyGameBoard` (lib/features/gameplay/pages/gameplay_board.dart): the
// `GameplayBoard` interface's real implementation, as the page drives it.
// The page (gameplay-ui's `gameplay_view.dart`) only ever reaches the Flame
// board through this seam, so a fix that doesn't reach it doesn't reach a
// running game (m7-design §14 "board-fx checks it"; BACKLOG "the Flame
// board's '+N' tower tag and the ice badge's digits through ARB").
import 'dart:ui' show TextDirection;

import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_game/features/fx/fake_fx_library.dart';
import 'package:nesty_game/features/fx/fx_cue.dart';
import 'package:nesty_game/features/gameplay/game/timeline/timeline.dart';
import 'package:nesty_game/features/gameplay/pages/gameplay_board.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  GameplayBoardCallbacks callbacks() => GameplayBoardCallbacks(
    onIntent: (_) {},
    onLayout: (_) {},
    onFamilyLanded: (_, _, _) {},
    onWon: () {},
    onOutOfMoves: () {},
  );

  NestyGameBoard build() =>
      NestyGameBoard(callbacks(), fx: FakeFxLibrary(), feedback: const _Mute());

  test('reduceMotion reaches the board\'s MotionSpec through the interface, '
      'both ways, as a running level would toggle it mid-level (m7 §14)', () {
    final board = build();
    final GameplayBoard asInterface = board;
    expect(board.game.board.motion, MotionSpec.standard);

    asInterface.reduceMotion = true;
    expect(board.game.board.motion, MotionSpec.reduced);

    // Settings → off again mid-level (Pause → Settings → Resume): the
    // same seam must carry the change back, not just the first one.
    asInterface.reduceMotion = false;
    expect(board.game.board.motion, MotionSpec.standard);
  });

  test('dropTargets reaches the board through the interface (E.14): the page '
      'hands the bloc\'s legal targets over, the board only reads them', () {
    final board = build();
    final GameplayBoard asInterface = board;
    expect(board.game.board.dropTargets, isEmpty);
    asInterface.dropTargets = {'r1c0', 'x0'};
    expect(board.game.board.dropTargets, {'r1c0', 'x0'});
    expect(board.game.dropTargets, {'r1c0', 'x0'});
    asInterface.dropTargets = const {};
    expect(board.game.board.dropTargets, isEmpty);
  });

  test('familyCounterYield is the board\'s own, driven by its hint (E.20)', () {
    final board = build();
    expect(board.familyCounterYield, same(board.game.board.familyCounterYield));
    expect(board.familyCounterYield.value, isFalse);
  });

  test('boardLabels reaches SlotDecor\'s formatter and direction through the '
      'interface (ARB boardTowerHidden/boardIceCount, spec §16)', () {
    final board = build();
    final GameplayBoard asInterface = board;
    expect(board.game.board.labels, same(BoardLabels.fallback));

    final labels = BoardLabels(
      towerTag: (count) => 'tag:$count',
      iceBadge: (count) => 'ice:$count',
      textDirection: TextDirection.rtl,
    );
    asInterface.boardLabels = labels;
    expect(board.game.board.labels, same(labels));
  });
}

final class _Mute implements FeedbackSink {
  const _Mute();

  @override
  void play(FxCue cue) {}
}
