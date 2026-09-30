import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_game/features/gameplay/overlays/out_of_moves_sheet.dart';

import '../core/ui/support/ui_harness.dart';
import '../features/support/screen_harness.dart';

/// M7 overflow suite (m7-design §18 "overflow"): the Out of Moves sheet
/// (frame 3.5) at the five acceptance sizes and both text scales. Behaviour
/// is covered by `test/features/gameplay/overlays/
/// out_of_moves_sheet_test.dart`, which sweeps `screenSizes`; this file
/// extends the same fully-populated sheet (every row shown) to the wider
/// M7 grid.
void main() {
  setUpAll(loadBundledFonts);

  Widget sheet({int freeUndosLeft = 1, bool relaxed = false}) =>
      OutOfMovesSheet(
        freeUndosLeft: freeUndosLeft,
        relaxed: relaxed,
        showFreeUndos: true,
        onUndo: () {},
        onExtraSlot: () {},
        onRestart: () {},
        onDismiss: () {},
        undoPrice: 20,
        slotPrice: 150,
        extraSlotsLeft: 0,
      );

  for (final size in overflowScreenSizes) {
    for (final scale in textScales) {
      testWidgets(
        'fits ${size.width.toInt()}×${size.height.toInt()} at $scale× text',
        (tester) async {
          await pumpScreen(tester, sheet(), size: size, textScale: scale);
          await tester.pump(const Duration(milliseconds: 300));
          await expectAccessibleLayout(tester);
        },
      );

      testWidgets('the undos spent (12.8) fits ${size.width.toInt()}×'
          '${size.height.toInt()} at $scale× text', (tester) async {
        await pumpScreen(
          tester,
          sheet(freeUndosLeft: 0),
          size: size,
          textScale: scale,
        );
        await tester.pump(const Duration(milliseconds: 300));
        await expectAccessibleLayout(tester);
      });

      testWidgets(
        'relaxed (10.9b) fits ${size.width.toInt()}×${size.height.toInt()} '
        'at $scale× text',
        (tester) async {
          await pumpScreen(
            tester,
            sheet(relaxed: true),
            size: size,
            textScale: scale,
          );
          await tester.pump(const Duration(milliseconds: 300));
          await expectAccessibleLayout(tester);
        },
      );
    }
  }
}
