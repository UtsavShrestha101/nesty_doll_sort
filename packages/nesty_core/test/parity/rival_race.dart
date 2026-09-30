/// The rival's race as a parity value, shared by rival_parity_test.dart
/// (VM, node, chrome, wasm) and test/generator/race_golden_test.dart (VM).
///
/// It is what the independent Python reference
/// (test/simulator/reference/rivalref.py) reports for the same race: one u32
/// word per step, `code << 16 | from << 8 | to`, with code 1 moved, 2
/// finished and 3 restarted (from = to = 0 for a restart) and from and to as
/// `Level.slotIds` indexes, hashed with [parityDigestU32s]; plus the steps
/// taken, the restarts, whether the rival finished and the moves of its last
/// run.
library;

import 'package:nesty_core/nesty_core.dart';

import 'generated_levels.dart';
import 'parity.dart';

/// The reference's code for [step].
int rivalStepCode(RivalStep step) => switch (step) {
  RivalStep.moved => 1,
  RivalStep.finished => 2,
  RivalStep.restarted => 3,
};

/// The rival's steps on [level] until it finishes or has taken [maxSteps].
Map<String, Object> rivalRace(
  Level level,
  SimBot policy,
  int raceSeed,
  int maxSteps, {
  int moveCap = SimulatorParams.defaultMoveCap,
}) {
  final rival = RivalBot(
    level,
    policy: policy,
    raceSeed: raceSeed,
    moveCap: moveCap,
  );
  final ids = level.slotIds;
  final words = <int>[];
  var restarts = 0;
  while (words.length < maxSteps && !rival.isFinished) {
    final step = rival.step();
    if (step == RivalStep.restarted) {
      restarts++;
      words.add(rivalStepCode(step) << 16);
    } else {
      words.add(
        rivalStepCode(step) << 16 |
            ids.indexOf(rival.lastFrom) << 8 |
            ids.indexOf(rival.lastTo),
      );
    }
  }
  return {
    'digest': parityDigestU32s(words),
    'steps': words.length,
    'restarts': restarts,
    'finished': rival.isFinished,
    'runMoves': rival.moveCount,
  };
}

/// The most steps a golden race may take before it counts as a failure to
/// finish (the reference uses the same bound).
const int raceGoldenMaxSteps = 100000;

/// The board of race [raceNo] against [rival] when the highest level won is
/// [highestWonLevel], generated as the app does:
/// `Generator.generateWithRetries(DifficultyCurve.raceParams(...))`. Throws
/// a [StateError] when no seed gave a level.
GeneratorSuccess generateRaceBoard(int rival, int raceNo, int highestWonLevel) {
  final outcome = Generator.generateWithRetries(
    DifficultyCurve.raceParams(
      rival: rival,
      raceNo: raceNo,
      highestWonLevel: highestWonLevel,
    ),
  );
  if (outcome is! GeneratorSuccess) {
    throw StateError('race $rival-$raceNo@$highestWonLevel: $outcome');
  }
  return outcome;
}

/// The golden of [board], the board of race [raceNo] against [rival]: its
/// fingerprint (`fingerprintOf`), its JSON, and the rival's whole race on it
/// with the race's own policy and seed.
Map<String, Object> raceGoldenOf(
  GeneratorSuccess board,
  int rival,
  int raceNo,
) => {
  'board': fingerprintOf(board),
  'json': LevelCodec.encodeString(board.level),
  'race': rivalRace(
    board.level,
    DifficultyCurve.racePolicy(rival),
    DifficultyCurve.raceSeed(rival, raceNo),
    raceGoldenMaxSteps,
  ),
};
