import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_core/nesty_core.dart';
import 'package:nesty_game/core/ui/nesty_ui.dart';
import 'package:nesty_game/features/fx/fake_fx_library.dart';
import 'package:nesty_game/features/gameplay/widgets/family_counter.dart';
import 'package:nesty_game/features/gameplay/widgets/gameplay_hud.dart';

import '../../../core/ui/support/ui_harness.dart';

/// `GameplayHud.raceStrip` (vs Computer, frame 9.3; phase 4 architecture
/// §6.6): in a race the strip takes the top row in place of the level and
/// coin pills (tokens `layout.rivalStrip`: x 76 to W − 16, top 62, 48 tall),
/// takes no touch, and the family counter stays under it.
void main() {
  setUpAll(loadBundledFonts);

  Widget hud({Widget? strip, bool counterHidden = false}) => Align(
    alignment: Alignment.topCenter,
    child: GameplayHud(
      level: 12,
      tier: Tier.hard,
      coins: 40,
      setsDone: 0,
      setsTotal: 1,
      raceStrip: strip,
      familyCounterHidden: counterHidden,
      onPause: () {},
      library: FakeFxLibrary(),
    ),
  );

  testWidgets('the strip replaces the level and coin pills', (tester) async {
    // The strip sizes itself (lane R's is 48 tall); the row gives it the
    // width.
    const strip = SizedBox(
      key: ValueKey('strip'),
      height: RivalStripTokens.height,
      child: ColoredBox(color: Color(0xFFFF0000)),
    );
    await pumpUi(tester, hud(strip: strip));
    expect(find.byType(LevelPill), findsNothing);
    expect(find.byType(CoinPill), findsNothing);
    final rect = tester.getRect(find.byKey(const ValueKey('strip')));
    final width = tester.view.physicalSize.width / tester.view.devicePixelRatio;
    final top = MediaQuery.paddingOf(
      tester.element(find.byType(GameplayHud)),
    ).top;
    expect(rect.left, RivalStripTokens.left);
    expect(rect.right, width - RivalStripTokens.right);
    expect(rect.top, top + RivalStripTokens.top - 59);
    expect(rect.height, RivalStripTokens.height);
    expect(find.byType(FamilyCounter), findsOneWidget);
    // It only informs: taps pass through to the board.
    expect(
      find.ancestor(
        of: find.byKey(const ValueKey('strip')),
        matching: find.byType(IgnorePointer),
      ),
      findsWidgets,
    );
  });

  testWidgets('a strip taller than 58 scales down instead of overflowing', (
    tester,
  ) async {
    await pumpUi(
      tester,
      hud(strip: const SizedBox(key: ValueKey('tall'), height: 64)),
    );
    expect(tester.takeException(), isNull);
    expect(
      tester.getSize(find.byKey(const ValueKey('tall'))).height,
      64,
      reason: 'laid out at its own height, then scaled',
    );
  });

  testWidgets('a strip grown to 58 (9.3i at large text) keeps its height, '
      'and the family counter moves down with it', (tester) async {
    Future<(Rect, Offset)> layout(double height) async {
      await pumpUi(
        tester,
        hud(
          strip: SizedBox(
            key: const ValueKey('strip'),
            height: height,
            child: const ColoredBox(color: Color(0xFFFF0000)),
          ),
        ),
      );
      return (
        tester.getRect(find.byKey(const ValueKey('strip'))),
        tester.getCenter(find.byType(FamilyCounter)),
      );
    }

    final (normal, counter) = await layout(RivalStripTokens.height);
    final (grown, moved) = await layout(RivalStripTokens.formsHeightAt13);
    expect(RivalStripTokens.formsHeightAt13, 58);
    expect(grown.height, 58);
    expect(grown.top, normal.top);
    // The counter follows the strip down, but its pill stops at the
    // board's HUD line (bottom 142 + 8 = BoardFitTokens.hudClearY).
    expect(58 - RivalStripTokens.height, greaterThan(8));
    expect(moved.dy - counter.dy, 8);
    expect(moved.dx, counter.dx);
  });

  testWidgets('off a race the level and coin pills show', (tester) async {
    await pumpUi(tester, hud());
    expect(find.byType(LevelPill), findsOneWidget);
    expect(find.byType(CoinPill), findsOneWidget);
  });

  testWidgets('familyCounterHidden hides the counter (frame 3.1b)', (
    tester,
  ) async {
    await pumpUi(tester, hud(counterHidden: true));
    final opacity = tester.widget<AnimatedOpacity>(
      find.ancestor(
        of: find.byType(FamilyCounter),
        matching: find.byType(AnimatedOpacity),
      ),
    );
    expect(opacity.opacity, 0);
    expect(opacity.duration, const Duration(milliseconds: 150));
  });
}
