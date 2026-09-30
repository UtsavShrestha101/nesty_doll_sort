import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_core/nesty_core.dart';
import 'package:nesty_game/features/fx/fake_fx_library.dart';
import 'package:nesty_game/features/gameplay/overlays/all_levels_done.dart';

import '../core/ui/support/ui_harness.dart';
import '../features/support/screen_harness.dart';

/// M7 overflow suite (m7-design §18 "overflow"): All Levels Done (frame
/// 4.9), with and without Bonus Endless, at the five acceptance sizes and
/// both text scales. Behaviour is covered by `test/features/gameplay/
/// overlays/all_levels_done_test.dart`, which sweeps `screenSizes`.
void main() {
  setUpAll(loadBundledFonts);

  const families = [
    DollColor.red,
    DollColor.yellow,
    DollColor.green,
    DollColor.blue,
    DollColor.purple,
    DollColor.pink,
  ];

  for (final size in overflowScreenSizes) {
    for (final scale in textScales) {
      testWidgets(
        'without bonus fits ${size.width.toInt()}×${size.height.toInt()} '
        'at $scale× text',
        (tester) async {
          await pumpScreen(
            tester,
            AllLevelsDone(
              families: families,
              library: FakeFxLibrary(),
              onHome: () {},
            ),
            size: size,
            textScale: scale,
          );
          await tester.pump(const Duration(milliseconds: 300));
          await expectAccessibleLayout(tester);
        },
      );

      testWidgets('with a bonus level fits ${size.width.toInt()}×'
          '${size.height.toInt()} at $scale× text', (tester) async {
        await pumpScreen(
          tester,
          AllLevelsDone(
            families: families,
            library: FakeFxLibrary(),
            onHome: () {},
            bonusNumber: 123,
            onPlayBonus: () {},
          ),
          size: size,
          textScale: scale,
        );
        await tester.pump(const Duration(milliseconds: 300));
        await expectAccessibleLayout(tester);
      });
    }
  }
}
