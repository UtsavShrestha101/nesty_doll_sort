// The level JSON example of spec §5.1, built directly from the models so the
// model tests don't depend on the codec:
//
//   r0: open [red4, red3] | open empty | tower [[blue2], [green4], [red2, red1]]
//   r1: locked(red) [green3, green2, green1] | open [blue4, blue3] ice 2
//       | open [blue1]
import 'package:nesty_core/nesty_core.dart';

Nest nest(DollColor color, int outer, [int length = 1]) =>
    Nest.run(color, outer: outer, length: length);

Level specExampleLevel() => Level(
  id: 'L0042',
  maxSize: 4,
  shelves: [
    [
      OpenSlot(nest: nest(DollColor.red, 4, 2)),
      OpenSlot(),
      TowerSlot([
        nest(DollColor.blue, 2),
        nest(DollColor.green, 4),
        nest(DollColor.red, 2, 2),
      ]),
    ],
    [
      LockedSlot(unlockColor: DollColor.red, nest: nest(DollColor.green, 3, 3)),
      OpenSlot(nest: nest(DollColor.blue, 4, 2), ice: 2),
      OpenSlot(nest: nest(DollColor.blue, 1)),
    ],
  ],
);
