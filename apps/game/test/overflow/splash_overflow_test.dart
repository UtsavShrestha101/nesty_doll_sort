import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_game/features/fx/fake_fx_library.dart';
import 'package:nesty_game/features/splash/pages/splash_page.dart';

import '../core/ui/support/ui_harness.dart';
import '../features/support/screen_harness.dart';

/// M7 overflow suite (m7-design §18 "overflow"; spec-prop §18): the splash
/// (frame 1.1) at the five acceptance sizes and both text scales. The
/// screen's own behaviour is covered by `test/features/splash/
/// splash_page_test.dart`; this file only sweeps the wider size/scale grid.
void main() {
  setUpAll(loadBundledFonts);

  Future<void> pumpSplash(
    WidgetTester tester, {
    Size size = const Size(390, 844),
    double textScale = 1,
  }) async {
    await pumpScreen(
      tester,
      SplashView(progress: 0.6, onRetry: () {}, library: FakeFxLibrary()),
      size: size,
      textScale: textScale,
    );
    await tester.pump();
  }

  for (final size in overflowScreenSizes) {
    for (final scale in textScales) {
      testWidgets(
        'fits ${size.width.toInt()}×${size.height.toInt()} at $scale× text',
        (tester) async {
          await pumpSplash(tester, size: size, textScale: scale);
          await expectAccessibleLayout(tester);
        },
      );
    }
  }
}
