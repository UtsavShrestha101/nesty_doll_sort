import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_core/nesty_core.dart';
import 'package:nesty_game/features/fx/fake_fx_library.dart';
import 'package:nesty_game/features/gameplay/overlays/all_levels_done.dart';
import 'package:nesty_game/features/gameplay/widgets/lottie_doll.dart';

import '../../../core/ui/support/ui_harness.dart';
import '../../support/screen_harness.dart';

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

  testWidgets('frame 4.9 copy, five hopping dolls, Back to Home', (
    tester,
  ) async {
    var home = 0;
    await pumpScreen(
      tester,
      AllLevelsDone(
        families: families,
        library: FakeFxLibrary(),
        onHome: () => home++,
      ),
    );
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text("You've finished all levels!"), findsOneWidget);
    expect(
      find.text('New chapters are coming — play bonus levels meanwhile.'),
      findsOneWidget,
    );
    expect(find.byType(LottieDoll), findsNWidgets(5));
    // Bonus Endless is M3.
    expect(find.textContaining('Bonus'), findsNothing);
    await tester.tap(find.text('Back to Home'));
    await tester.pump(const Duration(milliseconds: 200));
    expect(home, 1);
  });

  for (final size in screenSizes) {
    for (final scale in textScales) {
      testWidgets('fits ${size.width.toInt()} wide at $scale× text', (
        tester,
      ) async {
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
        expectNoLayoutErrors(tester);
      });
    }
  }
}
