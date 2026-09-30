import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_game/core/models/intro_mechanic.dart';
import 'package:nesty_game/features/fx/fake_fx_library.dart';
import 'package:nesty_game/features/gameplay/overlays/intro_mechanic_card.dart';

import '../core/ui/support/ui_harness.dart';
import '../features/support/screen_harness.dart';

/// M7 overflow suite (m7-design §18 "overflow"): the mechanic intro cards
/// (frames 4.1-4.3), every mechanic, at the five acceptance sizes and both
/// text scales. Behaviour is covered by `test/features/gameplay/overlays/
/// intro_mechanic_card_test.dart`, which sweeps `screenSizes`.
void main() {
  setUpAll(loadBundledFonts);

  Widget card(IntroMechanic mechanic) => IntroMechanicCard(
    mechanic: mechanic,
    onGotIt: () {},
    library: FakeFxLibrary(),
  );

  for (final mechanic in IntroMechanic.values) {
    for (final size in overflowScreenSizes) {
      for (final scale in textScales) {
        testWidgets('${mechanic.id} fits ${size.width.toInt()}×'
            '${size.height.toInt()} at $scale× text', (tester) async {
          await pumpScreen(
            tester,
            card(mechanic),
            size: size,
            textScale: scale,
          );
          await tester.pump(const Duration(milliseconds: 300));
          await expectAccessibleLayout(tester);
        });
      }
    }
  }
}
