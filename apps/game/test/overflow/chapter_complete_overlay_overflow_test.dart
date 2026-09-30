import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_game/features/gameplay/overlays/chapter_complete_overlay.dart';

import '../core/ui/support/ui_harness.dart';
import '../features/support/screen_harness.dart';

/// M7 overflow suite (m7-design §18 "overflow"): the Chapter complete
/// overlay (frame 4.6) at the five acceptance sizes and both text scales.
/// Behaviour is covered by `test/features/gameplay/overlays/
/// chapter_complete_overlay_test.dart`, which sweeps `screenSizes`.
void main() {
  setUpAll(loadBundledFonts);

  Widget overlay() => ChapterCompleteOverlay(
    chapterNumber: 3,
    chapterName: 'Sweet Bakery',
    figurineId: 'baker',
    coins: 1500,
    nextLine: 'Next: Chapter 4 · A very long chapter name indeed',
    onContinue: () {},
  );

  for (final size in overflowScreenSizes) {
    for (final scale in textScales) {
      testWidgets(
        'fits ${size.width.toInt()}×${size.height.toInt()} at $scale× text',
        (tester) async {
          await pumpScreen(tester, overlay(), size: size, textScale: scale);
          await tester.pump(const Duration(milliseconds: 300));
          await expectAccessibleLayout(tester);
        },
      );
    }
  }
}
