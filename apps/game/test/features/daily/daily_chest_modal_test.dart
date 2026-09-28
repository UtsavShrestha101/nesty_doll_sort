import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_game/core/ui/nesty_ui.dart';
import 'package:nesty_game/features/daily/widgets/chest_icon.dart';
import 'package:nesty_game/features/daily/widgets/daily_chest_modal.dart';

import '../../core/ui/support/ui_harness.dart';
import '../support/screen_harness.dart';

/// Frame 5.6 (NestyMenus `isChest`): the day-7 chest modal wears the streak
/// ribbon, not the primary one every other modal uses, and shows the chest
/// open (lid tilted back, gold glow, seven spilled coins) under "Your chest
/// is open." (FIDELITY-12).
void main() {
  setUpAll(loadBundledFonts);

  Future<void> pumpModal(
    WidgetTester tester, {
    Size size = const Size(390, 844),
    double textScale = 1,
  }) => pumpScreen(
    tester,
    Scaffold(body: DailyChestModal(coins: 300, onCollect: () {})),
    size: size,
    textScale: textScale,
  );

  testWidgets('the ribbon is the streak ribbon (#FFB27A → #F2702B, edge '
      '#B8501A), carrying the title', (tester) async {
    await pumpModal(tester);
    final ribbon = tester.widget<RibbonTitle>(find.byType(RibbonTitle));
    expect(ribbon.title, '7-day streak!');
    expect(ribbon.gradient, AppGradientTokens.streak);
    expect(ribbon.edgeColor, AppColorTokens.streakEdge);
  });

  testWidgets('the chest is the open variant: the glow and seven coins '
      'spilling out, at the frame’s 200×170', (tester) async {
    await pumpModal(tester);
    final chest = find.byType(ChestIcon);
    expect(chest, findsOneWidget);
    expect(tester.widget<ChestIcon>(chest).open, isTrue);
    expect(tester.getSize(chest), const Size(200, 170));
    expect(
      find.descendant(of: chest, matching: find.byType(CoinIcon)),
      findsNWidgets(7),
    );
    // "+300" through ARB (winCoins), next to its own coin.
    expect(find.text('+300'), findsOneWidget);
  });

  testWidgets('the Daily row keeps the closed chest', (tester) async {
    await pumpScreen(tester, const Center(child: ChestIcon()));
    expect(tester.widget<ChestIcon>(find.byType(ChestIcon)).open, isFalse);
    expect(find.byType(CoinIcon), findsNothing);
  });

  for (final size in screenSizes) {
    for (final scale in textScales) {
      testWidgets('fits a ${size.width.toInt()}×${size.height.toInt()} '
          'phone at ${scale}x text', (tester) async {
        await pumpModal(tester, size: size, textScale: scale);
        expectNoLayoutErrors(tester);
      });
    }
  }
}
