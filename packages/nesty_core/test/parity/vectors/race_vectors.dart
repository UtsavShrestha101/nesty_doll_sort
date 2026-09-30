// Race goldens (spec-prop §7.7): three race boards, and the rival's whole
// race on each.
//
// Spec-prop §7.7: "Board: made by the generator from the curve's params for
// the rival's tier, at the stage of the player's highest level, with seed
// `3_000_000 + rival × 100_000 + raceNo`." "Rematch replays the same board
// and the same rival moves."
//
// Each entry is keyed `race-<rival>-<raceNo>@<highestWonLevel>`:
// - `board` is `generatedFingerprint` (../generated_levels.dart) of
//   `Generator.generateWithRetries(DifficultyCurve.raceParams(...))`, the
//   app's call, and `json` is that level's JSON. Like the daily and bonus
//   vectors, they are regression pins of Generator.version 1's own output
//   (captured on the VM on 2026-09-28, then required on every platform), not
//   values from an independent implementation. What makes them trustworthy
//   is elsewhere: each level passes the admin validation and replays its
//   solution to a win, and its params use only the mechanics met by
//   `highestWonLevel` (test/generator/race_golden_test.dart).
// - `race` is the rival's race on that JSON, from its first step until it
//   finishes: the step digest (`code << 16 | from << 8 | to` per step, with
//   code 1 moved, 2 finished and 3 restarted, from = to = 0 for a restart),
//   the steps, the restarts and the moves of the winning run. These come
//   from the independent Python reference
//   (test/simulator/reference/rivalref.py), which reads `json` from this
//   file.
//
// Race boards are never saved, so a later `Generator.version` bump may
// change them harmlessly: regenerate `board` and `json`, then rerun the
// reference for `race`.
library;

/// The goldens' (rival, raceNo, highestWonLevel), in [raceGoldens] order:
/// rival 1 at the first race stage (towers, easy), rival 2 at the ice stage
/// (towers, a lock and ice, medium) and rival 3 at the size-5 stage
/// (towers and a lock, medium).
const raceGoldenCases = <(int, int, int)>[(1, 1, 20), (2, 1, 70), (3, 1, 120)];

/// The key of a golden in [raceGoldens].
String raceGoldenKey(int rival, int raceNo, int highestWonLevel) =>
    'race-$rival-$raceNo@$highestWonLevel';

/// Every golden, keyed by [raceGoldenKey].
const raceGoldens = <String, Map<String, Object>>{
  'race-1-1@20': {
    'board': {
      'digest': '4845bd1c4c81a20a',
      'seed': 3100001,
      'attempt': 0,
      'tier': 'easy',
      'tierMatched': true,
    },
    'json':
        '{"schemaVersion":1,"id":"race-1-1","maxSize":4,"shelves":[[{"type":'
        '"tower","stack":[["teal2"],["brown4"],["teal4","teal3"]]},{"type":'
        '"open","nest":["blue2","blue1"]},{"type":"open","nest":null}],[{'
        '"type":"tower","stack":[["brown1"],["blue3"],["navy2"]]},{"type":'
        '"open","nest":["teal1"]},{"type":"tower","stack":[["brown3"],['
        '"purple2","purple1"],["navy1"]]}],[{"type":"tower","stack":[['
        '"navy4"],["navy3"],["brown2"]]},{"type":"open","nest":["purple4",'
        '"purple3"]},{"type":"open","nest":["blue4"]}]],"generatorVersion":1,'
        '"seed":3100001}',
    'race': {
      'digest': 'c0725f36c465ed4a',
      'steps': 19,
      'restarts': 0,
      'finished': true,
      'runMoves': 19,
    },
  },
  'race-2-1@70': {
    'board': {
      'digest': 'c15cd8b948996c08',
      'seed': 3200001,
      'attempt': 7,
      'tier': 'medium',
      'tierMatched': true,
    },
    'json':
        '{"schemaVersion":1,"id":"race-2-1","maxSize":4,"shelves":[[{"type":'
        '"open","nest":["blue1"]},{"type":"tower","stack":[["teal3"],['
        '"brown1"],["red4"]]},{"type":"tower","stack":[["navy2","navy1"],['
        '"pink2"],["brown2"]]}],[{"type":"open","nest":["navy4","navy3"],'
        '"ice":3},{"type":"locked","unlockColor":"blue","nest":["pink4",'
        '"pink3"]},{"type":"open","nest":null}],[{"type":"tower","stack":[['
        '"blue4"],["teal4"],["red2","red1"]]},{"type":"tower","stack":[['
        '"brown4","brown3"],["teal1"],["pink1"]]},{"type":"tower","stack":[['
        '"blue3","blue2"],["red3"],["teal2"]]}]],"generatorVersion":1,'
        '"seed":3200001}',
    'race': {
      'digest': '27570db38b6d993c',
      'steps': 14,
      'restarts': 0,
      'finished': true,
      'runMoves': 14,
    },
  },
  'race-3-1@120': {
    'board': {
      'digest': '79c2d13d609454d0',
      'seed': 3300001,
      'attempt': 0,
      'tier': 'medium',
      'tierMatched': true,
    },
    'json':
        '{"schemaVersion":1,"id":"race-3-1","maxSize":5,"shelves":[[{"type":'
        '"open","nest":null},{"type":"open","nest":["blue5","blue4","blue3"]}'
        ',{"type":"tower","stack":[["red5","red4","red3","red2"],["green4"],'
        '["brown5","brown4"],["red1"]]}],[{"type":"tower","stack":[["navy3"]'
        ',["yellow5"],["navy5"],["navy4"]]},{"type":"open","nest":["brown3",'
        '"brown2"]},{"type":"locked","unlockColor":"navy","nest":["blue2"]}]'
        ',[{"type":"open","nest":["green5"]},{"type":"tower","stack":[['
        '"green3"],["yellow4","yellow3","yellow2","yellow1"],["green2"],['
        '"navy1"]]},{"type":"tower","stack":[["navy2"],["blue1"],["green1"],'
        '["brown1"]]}]],"generatorVersion":1,"seed":3300001}',
    'race': {
      'digest': 'b76965012c98c104',
      'steps': 20,
      'restarts': 0,
      'finished': true,
      'runMoves': 20,
    },
  },
};
