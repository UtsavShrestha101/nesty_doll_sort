import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_core/nesty_core.dart';
import 'package:nesty_game/features/fx/fake_fx_library.dart';
import 'package:nesty_game/features/gameplay/widgets/gameplay_hud.dart';

import '../core/ui/support/ui_harness.dart';
import '../features/support/screen_harness.dart';

/// M7 overflow suite (m7-design §18 "overflow"): the gameplay HUD (frames
/// 3.1, 4.10, 5.3) at the five acceptance sizes and both text scales.
/// Behaviour is covered by `test/features/gameplay/widgets/
/// gameplay_hud_test.dart`, which sweeps `screenSizes`; this file extends
/// that same worst-case HUD (the longest tier badge, the highest coin
/// count) to the wider M7 grid.
void main() {
  setUpAll(loadBundledFonts);

  Widget hud() => Scaffold(
    body: Align(
      alignment: Alignment.topCenter,
      child: GameplayHud(
        level: 188,
        tier: Tier.superhard,
        coins: 99999,
        setsDone: 3,
        setsTotal: 6,
        onPause: () {},
        library: FakeFxLibrary(),
      ),
    ),
  );

  for (final size in overflowScreenSizes) {
    for (final scale in textScales) {
      testWidgets(
        'fits ${size.width.toInt()}×${size.height.toInt()} at $scale× text',
        (tester) async {
          await pumpScreen(tester, hud(), size: size, textScale: scale);
          await expectAccessibleLayout(tester);
        },
      );
    }
  }

  Widget bonusHud() => Scaffold(
    body: Align(
      alignment: Alignment.topCenter,
      child: GameplayHud(
        level: 56,
        tier: Tier.hard,
        coins: 830,
        setsDone: 1,
        setsTotal: 4,
        bonusNumber: 123,
        onPause: () {},
        library: FakeFxLibrary(),
      ),
    ),
  );

  Widget dailyHud() => Scaffold(
    body: Align(
      alignment: Alignment.topCenter,
      child: GameplayHud(
        level: 56,
        tier: Tier.hard,
        coins: 830,
        setsDone: 1,
        setsTotal: 4,
        dailyDateLabel: 'Sep 26',
        onPause: () {},
        library: FakeFxLibrary(),
      ),
    ),
  );

  for (final size in overflowScreenSizes) {
    testWidgets(
      'Bonus Endless fits ${size.width.toInt()}×${size.height.toInt()} at '
      '1.3× text',
      (tester) async {
        await pumpScreen(tester, bonusHud(), size: size, textScale: 1.3);
        await expectAccessibleLayout(tester);
      },
    );

    testWidgets(
      'the daily date chip fits ${size.width.toInt()}×${size.height.toInt()} '
      'at 1.3× text',
      (tester) async {
        await pumpScreen(tester, dailyHud(), size: size, textScale: 1.3);
        await expectAccessibleLayout(tester);
      },
    );
  }
}
