import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:nesty_game/main_dev.dart' as app;

import 'support/board_probe.dart';
import 'support/resume_scenario.dart';

/// Phase B of the device-kill resume check: a fresh process after phase A
/// was killed (see `resume_phase_a_test.dart` for the exact commands).
/// Home's PLAY, as a player would tap it, must bring level 3 back exactly
/// where phase A left it (m3-design §3.4's request + level id +
/// `levelVersion` match): the same board, undos left and extra slots.
void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  binding.framePolicy = LiveTestWidgetsFlutterBindingFramePolicy.fullyLive;

  testWidgets(
    'phase B: Home PLAY resumes level 3 exactly where phase A left it',
    (tester) async {
      app.main();
      final board = Board(tester);

      final play = find.bySemanticsLabel('Play level ${ResumeScenario.level}');
      await tester.pumpUntil(
        () => play.evaluate().isNotEmpty,
        timeout: const Duration(seconds: 60),
        reason: 'Home offering level 3 (phase A\'s wins, read back from Hive)',
      );
      await tester.pumpFor(const Duration(milliseconds: 500));

      await tester.tap(play);
      await board.waitForLevel(ResumeScenario.level);

      expect(
        board.state.restored,
        isTrue,
        reason: 'the saved in-progress session, not a fresh level 3',
      );
      ResumeScenario.expectScriptedBoard(board.state.board);
      expect(board.state.freeUndosLeft, ResumeScenario.expectedFreeUndosLeft);
      ResumeScenario.report(binding, 'resumePhaseB', board);
    },
    timeout: const Timeout(Duration(minutes: 5)),
  );
}
