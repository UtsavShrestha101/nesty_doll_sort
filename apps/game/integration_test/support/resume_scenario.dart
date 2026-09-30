import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:nesty_core/nesty_core.dart';
import 'package:nesty_game/core/dependency_injection/di.dart';
import 'package:nesty_game/core/services/remote_config/remote_config_keys.dart';
import 'package:nesty_game/core/services/save/save_service.dart';

import 'board_probe.dart';
import 'fingerprint.dart';

/// The scripted resume scenario shared by `resume_phase_a_test.dart` and
/// `resume_phase_b_test.dart` (plan-m3.md "Verification" — device kill),
/// on the real player's path: levels 1 and 2 are won through their
/// scripted tutorial moves, then Home's PLAY opens level 3 (spec §5.1's
/// L0003, medium), the first level past the tutorial and with no mechanic
/// intro card. After the kill, Home's PLAY again is what brings it back.
///
/// The level 3 moves: red1 (r1c2) into red2 (r2c1), yellow1 (r0c1) into
/// yellow2 (r1c0), that second move undone, +1 Slot, then blue1 (r0c2) onto
/// the new stand. None of it completes a set, so the level stays in
/// progress for the resume to matter.
abstract final class ResumeScenario {
  static const int level = 3;

  /// The default `free_undos_per_level` minus the one undo the script
  /// performs: what `GameplayState.freeUndosLeft` must read after it, in
  /// both phases (`GameSession.undosUsed` is part of the persisted save,
  /// m3-design §3.4, so this survives a kill).
  static final int expectedFreeUndosLeft =
      RemoteConfigKeys.freeUndosPerLevel.defaultValue - 1;

  /// +1 Slot was pressed exactly once.
  static const int expectedExtraSlotCount = 1;

  /// From a fresh install: the splash opens level 1 straight away (E9,
  /// m7-design §13); its tutorial moves win it (frames 1.3–1.6, the ones
  /// `playthrough_test.dart` screenshots) and the first win's Continue goes
  /// Home. Home's PLAY opens level 2, won through its scripted swallow;
  /// Continue opens level 3 and Pause goes back Home, so Home's PLAY now
  /// offers level 3 (`SaveService.currentLevel`).
  static Future<void> winTutorialLevels(
    WidgetTester tester,
    Board board,
  ) async {
    await board.waitForLevel(1);
    // L1: red2 into red3, then red1 completes the family.
    await board.move('r0c2', 'r0c0');
    await board.move('r1c1', 'r0c0');
    await board.waitForWinOverlay();
    await board.continueHome(level: 2);
    await tester.tap(find.bySemanticsLabel('Play level 2'));
    await board.waitForLevel(2);
    // L2: the tutorial's swallow drag first (red3 over red2+red1, step 4),
    // then blue1 into blue2 and blue3 swallowing both.
    await tester.pumpUntil(
      () => board.state.tutorial != null,
      reason: 'the L2 swallow tutorial cue (step 4)',
    );
    await board.dragMove('r0c0', 'r1c0');
    await board.move('r1c2', 'r0c1');
    await board.move('r1c1', 'r0c1');
    await board.waitForWinOverlay();
    await board.continueTo(level);
    await board.openPause();
    await board.pauseToHome(level: level);
  }

  /// Plays the scripted moves on a freshly opened level 3 board. Only for
  /// phase A: phase B never re-plays them, it only reads what came back.
  static Future<void> play(WidgetTester tester, Board board) async {
    await board.move('r1c2', 'r2c1');
    await board.move('r0c1', 'r1c0');
    await board.waitIdle();

    // An undo (spec §8): yellow1 back on its own stand.
    await tester.tap(find.text('Undo'));
    await tester.pumpUntil(
      () => board.state.board.slot('r0c1').nests.isNotEmpty,
      reason: 'the undo put yellow1 back',
    );
    await board.waitIdle();

    // +1 Slot: a new stand, `x0`, then blue1 onto it.
    await tester.tap(find.text('+Slot'));
    await tester.pumpUntil(
      () => board.state.board.extraSlotCount == expectedExtraSlotCount,
      reason: 'the extra slot',
    );
    await board.waitIdle();
    await board.move('r0c2', 'x0');
    await board.waitIdle();
  }

  /// The facts that must hold of [board] whether it was just played (phase
  /// A) or just resumed after a kill (phase B).
  static void expectScriptedBoard(GameState board) {
    expect(board.slot('r1c2').nests, isEmpty, reason: 'red1 left r1c2');
    expect(
      board.slot('r2c1'),
      equals(OpenSlot(nest: Nest.run(DollColor.red, outer: 2, length: 2))),
      reason: 'r2c1 holds red2 over red1',
    );
    expect(
      board.slot('r0c1'),
      equals(OpenSlot(nest: Nest.run(DollColor.yellow, outer: 1, length: 1))),
      reason: 'the undone move: yellow1 back on r0c1',
    );
    expect(
      board.slot('r1c0'),
      equals(OpenSlot(nest: Nest.run(DollColor.yellow, outer: 2, length: 1))),
      reason: 'yellow2 alone again',
    );
    expect(board.slot('r0c2').nests, isEmpty, reason: 'blue1 left r0c2');
    expect(
      board.slot('x0'),
      equals(OpenSlot(nest: Nest.run(DollColor.blue, outer: 1, length: 1))),
      reason: 'x0 holds blue1',
    );
    expect(board.extraSlotCount, expectedExtraSlotCount);
  }

  /// Flushes the save queue before phase A ends (`SaveService.flush`,
  /// m3-design §3.2). The queue already writes within milliseconds of each
  /// move; this only makes sure a force-stop (which may skip
  /// `AppLifecycleState.paused`) can't land between a move and its write.
  static Future<void> flushSave() => get<SaveService>().flush();

  /// What each phase reports, as `reportData` (the driver writes it to
  /// `build/integration_response_data.json`) and as one `NESTY_RESUME` log
  /// line, so the two phases can be compared from the `flutter drive`
  /// output alone.
  static void report(
    IntegrationTestWidgetsFlutterBinding binding,
    String phase,
    Board board,
  ) {
    final session = board.session!;
    final data = {
      'level': level,
      'freeUndosLeft': board.state.freeUndosLeft,
      'extraSlotCount': session.state.extraSlotCount,
      'fingerprint': Fingerprint.ofSession(session),
    };
    binding.reportData = {phase: data};
    // ignore: avoid_print
    print('NESTY_RESUME $phase ${jsonEncode(data)}');
  }
}
