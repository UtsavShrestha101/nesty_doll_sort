import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:nesty_game/features/gameplay/pages/gameplay_view.dart';
import 'package:nesty_game/features/home/pages/home_page.dart';
import 'package:nesty_game/main_dev.dart' as app;

import 'support/board_probe.dart';
import 'support/resume_scenario.dart';

/// Phase A of the device-kill resume check (plan-m3.md "Verification";
/// spec §18 M3 "kill mid-level, resume exactly"): on a fresh install, wins
/// level 1 (which the splash opens straight away, E9) and level 2, opens
/// level 3 from Home's PLAY, plays `ResumeScenario` and flushes the save. `--keep-app-running` leaves the app up (a plain
/// `flutter test` or `flutter drive` stops and uninstalls it, wiping its
/// data); it is then killed for real before phase B relaunches it. README
/// "Testing" has the exact commands:
///
/// ```sh
/// cd apps/game
/// xcrun simctl uninstall <udid> com.futrix.nesty.dev   # or adb uninstall
/// flutter drive --flavor dev --keep-app-running \
///   --driver test_driver/integration_test.dart \
///   --target integration_test/resume_phase_a_test.dart -d <device>
/// xcrun simctl terminate <udid> com.futrix.nesty.dev   # or am force-stop
/// flutter drive --flavor dev --driver test_driver/integration_test.dart \
///   --target integration_test/resume_phase_b_test.dart -d <device>
/// ```
///
/// The dev flavor without `--dart-define=NESTY_FAKE_SERVICES=true` is
/// `AppEnv.real` (`bootstrap.dart`): `HiveSaveService` on the device's own
/// Hive directory, so what this phase writes is what phase B's fresh
/// process reads back. Reinstalling phase B's build over this one keeps
/// the app's data (`adb install -r`, `simctl install`).
void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  // The board's own timeline and the solver's isolate need real frames,
  // not only the ones a test pumps (`playthrough_test.dart`).
  binding.framePolicy = LiveTestWidgetsFlutterBindingFramePolicy.fullyLive;

  testWidgets(
    'phase A: wins levels 1-2, plays level 3 from Home and saves it',
    (tester) async {
      app.main();
      final board = Board(tester);

      // A fresh save goes from the splash straight into level 1 (E9,
      // m7-design §13), never Home first.
      await tester.pumpUntil(
        () => find.byType(GameplayView).evaluate().isNotEmpty,
        timeout: const Duration(seconds: 60),
        reason: 'level 1 on a fresh save (uninstall the app before phase A)',
      );
      expect(find.byType(HomePage), findsNothing);

      await ResumeScenario.winTutorialLevels(tester, board);
      await tester.tap(
        find.bySemanticsLabel('Play level ${ResumeScenario.level}'),
      );
      await board.waitForLevel(ResumeScenario.level);
      expect(board.state.restored, isFalse, reason: 'a fresh level 3');

      await ResumeScenario.play(tester, board);
      ResumeScenario.expectScriptedBoard(board.state.board);
      expect(board.state.freeUndosLeft, ResumeScenario.expectedFreeUndosLeft);

      await ResumeScenario.flushSave();
      ResumeScenario.report(binding, 'resumePhaseA', board);
    },
    timeout: const Timeout(Duration(minutes: 5)),
  );
}
