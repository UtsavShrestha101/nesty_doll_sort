import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_game/features/gameplay/widgets/soft_stuck_banner.dart';

import '../core/ui/support/ui_harness.dart';
import '../features/support/screen_harness.dart';

/// M7 overflow suite (m7-design §18 "overflow"): the soft-stuck banner
/// (frame 3.4) at the five acceptance sizes and both text scales. Behaviour
/// is covered by `test/features/gameplay/widgets/
/// soft_stuck_banner_test.dart`, which sweeps `screenSizes`.
void main() {
  setUpAll(loadBundledFonts);

  Widget banner() => Scaffold(
    body: Stack(
      children: [
        Positioned(
          left: SoftStuckBanner.side,
          right: SoftStuckBanner.side,
          top: 59 + SoftStuckBanner.top,
          child: SoftStuckBanner(visible: true, onUndo: () {}),
        ),
      ],
    ),
  );

  for (final size in overflowScreenSizes) {
    for (final scale in textScales) {
      testWidgets(
        'fits ${size.width.toInt()}×${size.height.toInt()} at $scale× text',
        (tester) async {
          await pumpScreen(tester, banner(), size: size, textScale: scale);
          await tester.pump(const Duration(milliseconds: 300));
          await expectAccessibleLayout(tester);
          final rect = tester.getRect(find.byType(SoftStuckBanner));
          expect(rect.left, greaterThanOrEqualTo(0));
          expect(rect.right, lessThanOrEqualTo(size.width));
        },
      );
    }
  }
}
