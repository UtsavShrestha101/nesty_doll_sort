import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_game/core/models/booster.dart';
import 'package:nesty_game/features/gameplay/overlays/booster_buy_popup.dart';

import '../core/ui/support/ui_harness.dart';
import '../features/support/screen_harness.dart';

/// M7 overflow suite (m7-design §18 "overflow"): the booster buy popup
/// (frames 3.2, 3.3) at the five acceptance sizes and both text scales, for
/// every booster type. Behaviour is covered by `test/features/gameplay/
/// overlays/booster_buy_popup_test.dart`, which sweeps `screenSizes` for
/// the Undo variant only.
void main() {
  setUpAll(loadBundledFonts);

  Widget popup(BoosterType type) => BoosterBuyPopup(
    type: type,
    price: 150,
    coins: 830,
    freeUndosPerLevel: 2,
    onBuy: () {},
    onDismiss: () {},
  );

  for (final size in overflowScreenSizes) {
    for (final scale in textScales) {
      for (final type in BoosterType.values) {
        testWidgets(
          '${type.name} fits ${size.width.toInt()}×${size.height.toInt()} '
          'at $scale× text',
          (tester) async {
            await pumpScreen(tester, popup(type), size: size, textScale: scale);
            await tester.pump(const Duration(milliseconds: 300));
            await expectAccessibleLayout(tester);
          },
        );
      }
    }
  }
}
