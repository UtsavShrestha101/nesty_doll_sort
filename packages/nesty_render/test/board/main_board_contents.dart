import 'package:nesty_core/nesty_core.dart' show DollColor;
import 'package:nesty_render/nesty_render.dart';

/// What each slot of the design's MAIN board holds: NestyBoard:80–84
/// `MAIN()`, the default `play` scene (frame 2.2, Level 56), for the
/// `mainBoard` shape in board_fixtures.dart.
///
/// The design's colour names are spec §12.3's: cherry = red, sky = blue,
/// leaf = green, grape = purple.
const mainBoardContents = <String, DebugSlot>{
  'r0c0': DebugSlot(color: DollColor.red, sizes: [4, 3]),
  'r0c1': DebugSlot(color: DollColor.blue, sizes: [4, 3]),
  'r0c2': DebugSlot(color: DollColor.green, sizes: [4]),
  'r0c3': DebugSlot(color: DollColor.purple, sizes: [3, 2, 1]),
  // `tower: 1`: one buried nest under sky 2. The frame doesn't say which;
  // leaf 1 is the only doll the level otherwise lacks, so it is a size-1
  // nest (drawn as a silhouette, so only its size matters).
  'r1c0': DebugSlot(color: DollColor.blue, sizes: [2], buried: [1]),
  'r1c1': DebugSlot(color: DollColor.red, sizes: [2, 1]),
  // r1c2 is empty.
  'r1c3': DebugSlot(
    color: DollColor.green,
    sizes: [2],
    unlockColor: DollColor.purple,
  ),
  'r2c0': DebugSlot(color: DollColor.purple, sizes: [4]),
  'r2c1': DebugSlot(color: DollColor.blue, sizes: [1], ice: 2),
  'r2c2': DebugSlot(color: DollColor.green, sizes: [3]),
};
