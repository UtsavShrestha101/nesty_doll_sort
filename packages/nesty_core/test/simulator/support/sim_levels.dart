// Levels for the simulator's unit and parity tests (spec §6.4), as §5.1 JSON
// so the same inputs load on the VM and the web platforms (no file reads).
//
// - The fixtures are copies of test/fixtures/{solvable,unsolvable}/*.json.
// - The `medium…`, `hard…`, `superhard…` and `expertOnly` boards came from a
//   one-off random search for validator-clean boards (rules 1–7) in every
//   tier band. Each is solvable: a bot wins some of its runs.
// The simulator's default seed ignores `id` (Simulator.defaultSeed), so the
// ids here are only labels.
import 'package:nesty_core/nesty_core.dart';

/// Every level by name, in a fixed order.
const Map<String, String> simLevelJson = {
  // test/fixtures/solvable/001_l1_tutorial.json (2 moves).
  'tutorial':
      '{"schemaVersion":1,"id":"001_l1_tutorial","maxSize":3,"shelves":['
      '[{"type":"open","nest":["red3"]},{"type":"open","nest":null},'
      '{"type":"open","nest":["red2"]}],'
      '[{"type":"open","nest":null},{"type":"open","nest":["red1"]},'
      '{"type":"open","nest":null}]]}',
  // test/fixtures/solvable/002_l2_swallow.json.
  'swallow':
      '{"schemaVersion":1,"id":"002_l2_swallow","maxSize":3,"shelves":['
      '[{"type":"open","nest":["red3"]},{"type":"open","nest":["blue2"]},'
      '{"type":"open","nest":null}],'
      '[{"type":"open","nest":["red2","red1"]},{"type":"open","nest":["blue3"]},'
      '{"type":"open","nest":["blue1"]}]]}',
  // test/fixtures/solvable/003_spec_5_1_example.json: tower, lock and ice.
  'spec':
      '{"schemaVersion":1,"id":"L0042","maxSize":4,"shelves":['
      '[{"type":"open","nest":["red4","red3"]},{"type":"open","nest":null},'
      '{"type":"tower","stack":[["blue2"],["green4"],["red2","red1"]]}],'
      '[{"type":"locked","unlockColor":"red",'
      '"nest":["green3","green2","green1"]},'
      '{"type":"open","nest":["blue4","blue3"],"ice":2},'
      '{"type":"open","nest":["blue1"]}]]}',
  // test/fixtures/solvable/004_placement_first.json.
  'placementFirst':
      '{"schemaVersion":1,"id":"004_placement_first","maxSize":3,"shelves":['
      '[{"type":"tower","stack":[["red2"],["blue1"]]},'
      '{"type":"tower","stack":[["blue2"],["red1"]]},'
      '{"type":"open","nest":["red3"]}],'
      '[{"type":"open","nest":["blue3"]},{"type":"open","nest":null}]]}',
  // test/fixtures/solvable/006_ice_thaws.json.
  'iceThaws':
      '{"schemaVersion":1,"id":"006_ice_thaws","maxSize":3,"shelves":['
      '[{"type":"open","nest":["red3","red2"]},{"type":"open","nest":["red1"]},'
      '{"type":"open","nest":["blue3"],"ice":1}],'
      '[{"type":"open","nest":["blue2","blue1"]},{"type":"open","nest":null}]]}',
  // test/fixtures/solvable/007_lock_opens.json.
  'lockOpens':
      '{"schemaVersion":1,"id":"007_lock_opens","maxSize":3,"shelves":['
      '[{"type":"locked","unlockColor":"red","nest":["blue3"]},'
      '{"type":"open","nest":["red3"]},{"type":"open","nest":["red2","red1"]}],'
      '[{"type":"open","nest":["blue2","blue1"]},{"type":"open","nest":null}]]}',
  // test/fixtures/solvable/008_large_open_board.json: 19 slots, the most
  // expensive board here.
  'largeOpen':
      '{"schemaVersion":1,"id":"008_large_open_board","maxSize":5,"shelves":['
      '[{"type":"open","nest":["red5","red4"]},'
      '{"type":"open","nest":["yellow1"]},'
      '{"type":"open","nest":["green3","green2","green1"]},'
      '{"type":"open","nest":["blue5"]},'
      '{"type":"open","nest":["teal3","teal2"]}],'
      '[{"type":"open","nest":["orange2","orange1"]},'
      '{"type":"open","nest":["teal5","teal4"]},'
      '{"type":"open","nest":["red3"]},'
      '{"type":"open","nest":["yellow5","yellow4","yellow3"]},'
      '{"type":"open","nest":["green5"]}],'
      '[{"type":"open","nest":["blue1"]},{"type":"open","nest":["orange5"]},'
      '{"type":"open","nest":["green4"]},'
      '{"type":"open","nest":["red2","red1"]},'
      '{"type":"open","nest":["teal1"]}],'
      '[{"type":"open","nest":["yellow2"]},'
      '{"type":"open","nest":["blue4","blue3","blue2"]},'
      '{"type":"open","nest":null},'
      '{"type":"open","nest":["orange4","orange3"]}]]}',
  // Three shelves with two deep towers.
  'towersEasy':
      '{"schemaVersion":1,"id":"towers_easy","maxSize":4,"shelves":['
      '[{"type":"open","nest":["brown4"]},'
      '{"type":"open","nest":["yellow4","yellow3","yellow2"]},'
      '{"type":"tower","stack":[["teal2","teal1"],["pink4"],["teal4","teal3"],'
      '["green2","green1"]]}],'
      '[{"type":"open","nest":["green4"]},{"type":"open","nest":null},'
      '{"type":"open","nest":["pink1"]}],'
      '[{"type":"open","nest":["green3"]},'
      '{"type":"tower","stack":[["brown3","brown2"],["pink3"],["brown1"],'
      '["yellow1"]]},'
      '{"type":"open","nest":["pink2"]}]]}',
  'medium1':
      '{"schemaVersion":1,"id":"medium_1","maxSize":3,"shelves":['
      '[{"type":"open","nest":["red2","red1"]},'
      '{"type":"tower","stack":[["teal2"],["red3"],["green1"],["pink1"]]},'
      '{"type":"open","nest":["pink3"]}],'
      '[{"type":"tower","stack":[["green2"],["green3"],["pink2"],["teal3"]]},'
      '{"type":"open","nest":null},{"type":"open","nest":["teal1"]}]]}',
  'medium2':
      '{"schemaVersion":1,"id":"medium_2","maxSize":4,"shelves":['
      '[{"type":"open","nest":["red1"]},'
      '{"type":"tower","stack":[["teal3"],["teal2"],["teal1"],["teal4"]]},'
      '{"type":"tower","stack":[["red3"],["navy3"],["red2"],["red4"]]}],'
      '[{"type":"open","nest":["navy4"]},{"type":"open","nest":["navy2","navy1"]},'
      '{"type":"open","nest":null}]]}',
  'hard1':
      '{"schemaVersion":1,"id":"hard_1","maxSize":3,"shelves":['
      '[{"type":"tower","stack":[["navy2"],["yellow3"],["yellow2"],["blue3"]]},'
      '{"type":"tower","stack":[["brown3"],["brown1"],["blue2"],'
      '["pink3","pink2"]]},'
      '{"type":"tower","stack":[["pink1"],["navy1"],["yellow1"],["navy3"]]}],'
      '[{"type":"open","nest":["blue1"]},{"type":"open","nest":["brown2"]},'
      '{"type":"open","nest":null}]]}',
  'hard2':
      '{"schemaVersion":1,"id":"hard_2","maxSize":4,"shelves":['
      '[{"type":"tower","stack":[["red2"],["navy2"],["brown2"],["red4","red3"]]},'
      '{"type":"open","nest":["orange2","orange1"]},'
      '{"type":"tower","stack":[["brown3"],["brown1"],["orange4","orange3"],'
      '["brown4"]]}],'
      '[{"type":"tower","stack":[["red1"],["navy4","navy3"]]},'
      '{"type":"open","nest":null},{"type":"open","nest":["navy1"]}]]}',
  'superhard1':
      '{"schemaVersion":1,"id":"superhard_1","maxSize":5,"shelves":['
      '[{"type":"tower","stack":[["teal2"],["teal3"],["teal4"],'
      '["brown4","brown3","brown2","brown1"]]},'
      '{"type":"open","nest":null},{"type":"open","nest":["green5","green4"]}],'
      '[{"type":"open","nest":["teal5"]},'
      '{"type":"tower","stack":[["green3","green2","green1"],["blue5","blue4"],'
      '["orange1"],["teal1"]]},'
      '{"type":"tower","stack":[["blue1"],["brown5"],'
      '["orange5","orange4","orange3","orange2"],["blue3","blue2"]]}]]}',
  'superhard2':
      '{"schemaVersion":1,"id":"superhard_2","maxSize":5,"shelves":['
      '[{"type":"open","nest":["brown5"]},{"type":"open","nest":["green5"]},'
      '{"type":"tower","stack":[["green4"],["pink5"],["red3","red2"],'
      '["brown2","brown1"]]}],'
      '[{"type":"tower","stack":[["brown4","brown3"],'
      '["pink4","pink3","pink2","pink1"],["red1"],["green1"]]},'
      '{"type":"open","nest":null},'
      '{"type":"tower","stack":[["red5","red4"],["green3","green2"]]}]]}',
  // Superhard, and the smart bot wins fewer than half its runs.
  'expertOnly':
      '{"schemaVersion":1,"id":"expert_only","maxSize":4,"shelves":['
      '[{"type":"tower","stack":[["pink4","pink3"],["orange4"],["yellow3"],'
      '["pink1"]]},'
      '{"type":"tower","stack":[["pink2"],["teal2"],["yellow4"],["orange3"]]},'
      '{"type":"tower","stack":[["yellow2"],["teal3"],["teal1"],["yellow1"]]}],'
      '[{"type":"open","nest":["orange2","orange1"]},'
      '{"type":"open","nest":["teal4"]},{"type":"open","nest":null}]]}',
  // test/fixtures/unsolvable/001_lock_deadlock.json.
  'lockDeadlock':
      '{"schemaVersion":1,"id":"u001_lock_deadlock","maxSize":3,"shelves":['
      '[{"type":"locked","unlockColor":"red","nest":["blue3","blue2"]},'
      '{"type":"locked","unlockColor":"blue","nest":["red3","red2"]},'
      '{"type":"open","nest":["red1"]}],'
      '[{"type":"open","nest":["blue1"]},{"type":"open","nest":null}]]}',
  // test/fixtures/unsolvable/002_never_thawing_ice.json.
  'neverThaws':
      '{"schemaVersion":1,"id":"u002_never_thawing_ice","maxSize":3,"shelves":['
      '[{"type":"open","nest":["red3"],"ice":2},'
      '{"type":"open","nest":["red2","red1"]},{"type":"open","nest":null}],'
      '[{"type":"open","nest":["blue3","blue2"]},'
      '{"type":"open","nest":["blue1"]}]]}',
  // test/fixtures/unsolvable/003_no_space_dead_end.json.
  'noSpace':
      '{"schemaVersion":1,"id":"u003_no_space_dead_end","maxSize":3,"shelves":['
      '[{"type":"tower","stack":[["green2","green1"],["red3"],["blue3"]]},'
      '{"type":"tower","stack":[["blue2","blue1"],["red2","red1"],["green3"]]},'
      '{"type":"open","nest":null}]]}',
};

/// The names of the unsolvable levels in [simLevelJson].
const List<String> unsolvableSimLevels = [
  'lockDeadlock',
  'neverThaws',
  'noSpace',
];

/// The level [name] of [simLevelJson], decoded (a new instance per call).
Level simLevel(String name) {
  final json = simLevelJson[name];
  if (json == null) throw ArgumentError.value(name, 'name', 'No such level');
  final decoded = LevelCodec.decodeString(json);
  final level = decoded.level;
  if (level == null) {
    throw StateError('Level $name does not decode: ${decoded.issues}');
  }
  return level;
}
