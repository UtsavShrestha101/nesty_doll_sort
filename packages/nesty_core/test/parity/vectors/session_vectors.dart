// Hand-derived JSON of GameSessionCodec format 1 (docs/plans/m3-design.md
// §4) on the spec §5.1 example level (L0042), shared by
// test/codec/game_session_codec_test.dart (the scenario that produces them,
// step by step) and session_codec_parity_test.dart (the same strings read
// on node, chrome and wasm).
//
// Worked out by hand from the rules, not captured from the codec:
//   r0: open [red4, red3] | open empty | tower [[blue2], [green4], [red2, red1]]
//   r1: locked(red) [green3, green2, green1] | open [blue4, blue3] ice 2
//       | open [blue1]
// Key order: format, levelId, undosUsed, state, history; per board moves,
// sets, extra, opened, slots; slots in GameState.slotIds order (grid
// row-major, then x0, x1), nests bottom to top, dolls outer to inner.
library;

const String _startSlots =
    '"r0c0":[["red4","red3"]],"r0c1":[],'
    '"r0c2":[["blue2"],["green4"],["red2","red1"]],'
    '"r1c0":[["green3","green2","green1"]],"r1c1":[["blue4","blue3"]],'
    '"r1c2":[["blue1"]]';

const String startJson =
    '{"format":1,"levelId":"L0042","undosUsed":0,"state":{"moves":0,'
    '"sets":0,"extra":0,"opened":[],"slots":{$_startSlots}},"history":[]}';

// After A8: two undo entries, x1 added between them (before#0 has 1 extra
// slot, before#1 has 2), the red case broken, the ice at 1.
const String afterA8Json =
    '{"format":1,"levelId":"L0042","undosUsed":1,'
    '"state":{"moves":4,"sets":1,"extra":2,"opened":["r1c0"],"slots":{'
    '"r0c0":[["green4"]],"r0c1":[],"r0c2":[["blue2"]],'
    '"r1c0":[["green3","green2","green1"]],"r1c1":[["blue4","blue3"]],'
    '"r1c2":[],"x0":[],"x1":[["blue1"]]}},'
    '"history":['
    '{"before":{"moves":2,"sets":1,"extra":1,"opened":["r1c0"],"slots":{'
    '"r0c0":[],"r0c1":[["blue1"]],"r0c2":[["blue2"],["green4"]],'
    '"r1c0":[["green3","green2","green1"]],"r1c1":[["blue4","blue3"]],'
    '"r1c2":[],"x0":[]}},"move":["r0c2","r0c0"]},'
    '{"before":{"moves":3,"sets":1,"extra":2,"opened":["r1c0"],"slots":{'
    '"r0c0":[["green4"]],"r0c1":[["blue1"]],"r0c2":[["blue2"]],'
    '"r1c0":[["green3","green2","green1"]],"r1c1":[["blue4","blue3"]],'
    '"r1c2":[],"x0":[],"x1":[]}},"move":["r0c1","x1"]}'
    ']}';

// After A9: the start, both extra slots kept, undosUsed kept (D22).
const String afterRestartJson =
    '{"format":1,"levelId":"L0042","undosUsed":1,"state":{"moves":0,'
    '"sets":0,"extra":2,"opened":[],"slots":{$_startSlots,"x0":[],"x1":[]}},'
    '"history":[]}';

// After B3: the tower emptied (opened, ahead of the broken case in slot
// order), one undo entry whose before is B2's board.
const String afterB3Json =
    '{"format":1,"levelId":"L0042","undosUsed":1,'
    '"state":{"moves":3,"sets":2,"extra":2,"opened":["r0c2","r1c0"],"slots":{'
    '"r0c0":[],"r0c1":[],"r0c2":[],"r1c0":[],'
    '"r1c1":[["blue4","blue3","blue2"]],"r1c2":[["blue1"]],"x0":[],"x1":[]}},'
    '"history":[{"before":{"moves":2,"sets":2,"extra":2,"opened":["r1c0"],'
    '"slots":{"r0c0":[],"r0c1":[],"r0c2":[["blue2"]],"r1c0":[],'
    '"r1c1":[["blue4","blue3"]],"r1c2":[["blue1"]],"x0":[],"x1":[]}},'
    '"move":["r0c2","r1c1"]}]}';

// After B4: won; every set left the board, the history cleared.
const String wonJson =
    '{"format":1,"levelId":"L0042","undosUsed":1,"state":{"moves":4,'
    '"sets":3,"extra":2,"opened":["r0c2","r1c0"],"slots":{"r0c0":[],'
    '"r0c1":[],"r0c2":[],"r1c0":[],"r1c1":[],"r1c2":[],"x0":[],"x1":[]}},'
    '"history":[]}';

/// The spec §5.1 example level as canonical level JSON (spec §5.1).
const String specExampleLevelJson =
    '{"schemaVersion":1,"id":"L0042","maxSize":4,"shelves":['
    '[{"type":"open","nest":["red4","red3"]},'
    '{"type":"open","nest":null},'
    '{"type":"tower","stack":[["blue2"],["green4"],["red2","red1"]]}],'
    '[{"type":"locked","unlockColor":"red","nest":["green3","green2","green1"]},'
    '{"type":"open","nest":["blue4","blue3"],"ice":2},'
    '{"type":"open","nest":["blue1"]}]]}';
