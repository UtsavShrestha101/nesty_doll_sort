import 'package:nesty_core/nesty_core.dart';
import 'package:nesty_render/nesty_render.dart';

/// The one-tower board `SkinService.prepareShowcase` renders (Home shelf,
/// frame 2.1; Shop skin cards, frame 7.3; skin detail, frame 7.5;
/// docs/plans/m3-design.md §9.2): one doll of each requested colour,
/// nested in a single tower, laid out on the reference screen. Moved from
/// `ShowcaseDolls` (M2), whose board this was, so the Shop and skin detail
/// screens can ask for the same art, not only Home.
abstract final class ShowcaseBoard {
  /// One tower holding one doll of each of [colors], outer to inner in list
  /// order. [maxSize] only bounds the doll art's scale (spec §2.1: 3–6); it
  /// need not match `colors.length`.
  static Level levelFor(
    List<DollColor> colors, {
    String id = 'showcase',
    int maxSize = 6,
  }) => Level(
    id: id,
    maxSize: maxSize,
    shelves: [
      [
        TowerSlot([
          for (final color in colors) Nest.run(color, outer: 1, length: 1),
        ]),
      ],
    ],
  );

  /// The board laid out on the reference screen: one tower slot. The same
  /// geometry serves any [levelFor] colour count.
  static final BoardGeometry geometry = BoardLayout.compute(
    BoardShape(
      rows: const [
        [SlotShape('r0c0', SlotShapeKind.tower)],
      ],
      maxSize: 6,
    ),
    BoardViewport.reference,
  );

  /// The height the rasters are made for.
  static double get artHeight => geometry.maxDollHeight;
}
