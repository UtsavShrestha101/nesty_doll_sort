import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_core/nesty_core.dart';
import 'package:nesty_game/core/ui/nesty_ui.dart';
import 'package:nesty_game/features/fx/fake_fx_library.dart';
import 'package:nesty_game/features/gameplay/widgets/family_counter.dart';
import 'package:nesty_game/features/gameplay/widgets/gameplay_hud.dart';

import '../../../core/ui/support/ui_harness.dart';
import '../../support/screen_harness.dart';

Widget _hud({
  int level = 56,
  Tier tier = Tier.hard,
  int coins = 830,
  int done = 1,
  int total = 4,
  VoidCallback? onPause,
}) => Scaffold(
  body: Align(
    alignment: Alignment.topCenter,
    child: GameplayHud(
      level: level,
      tier: tier,
      coins: coins,
      setsDone: done,
      setsTotal: total,
      onPause: onPause ?? () {},
      library: FakeFxLibrary(),
    ),
  ),
);

void main() {
  setUpAll(loadBundledFonts);

  for (final size in screenSizes) {
    for (final scale in textScales) {
      testWidgets('fits ${size.width.toInt()} wide at $scale× text', (
        tester,
      ) async {
        await pumpScreen(
          tester,
          _hud(tier: Tier.superhard, coins: 99999),
          size: size,
          textScale: scale,
        );
        expectNoLayoutErrors(tester);
        final top = safeAreaOf(size).top;
        final pause = tester.getRect(find.byType(IconTactileButton));
        final pill = tester.getRect(find.byType(LevelPill));
        final coins = tester.getRect(find.byType(CoinPill));
        // NestyBoard: pause at (16, top + 3), pill centred at top + 3.
        expect(pause.topLeft, Offset(16, top + 3));
        expect(pill.top, top + 3);
        expect(pill.center.dx, closeTo(size.width / 2, 0.01));
        expect(coins.right, lessThanOrEqualTo(size.width - 16 + 0.01));
        // The level pill never runs into the side controls.
        expect(pill.left, greaterThan(pause.right));
        expect(pill.right, lessThan(coins.left));
        // The counter's canvas is centred on top + 70 (129 at 390×844).
        final counter = tester.getRect(find.byType(FamilyCounter));
        expect(counter.center, Offset(size.width / 2, top + 70));
      });
    }
  }

  testWidgets('shows the level, tier, coins and the family count', (
    tester,
  ) async {
    await pumpScreen(tester, _hud());
    expect(find.text('Level 56'), findsOneWidget);
    expect(find.text('HARD'), findsOneWidget);
    expect(find.bySemanticsLabel('Level 56 · Hard'), findsOneWidget);
    expect(find.bySemanticsLabel('830 coins'), findsOneWidget);
    expect(find.bySemanticsLabel('1 of 4 families done'), findsOneWidget);
  });

  testWidgets('Bonus Endless: "Bonus Level N" (frame 4.10)', (tester) async {
    await pumpScreen(
      tester,
      Scaffold(
        body: Align(
          alignment: Alignment.topCenter,
          child: GameplayHud(
            level: 56,
            tier: Tier.hard,
            coins: 830,
            setsDone: 1,
            setsTotal: 4,
            bonusNumber: 3,
            onPause: () {},
            library: FakeFxLibrary(),
          ),
        ),
      ),
    );
    expect(find.text('Bonus Level 3'), findsOneWidget);
    expect(find.text('Level 56'), findsNothing);
  });

  testWidgets('the daily puzzle: the date chip (frame 5.3)', (tester) async {
    await pumpScreen(
      tester,
      Scaffold(
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
      ),
    );
    expect(find.text('Daily'), findsOneWidget);
    expect(find.text('Sep 26'), findsOneWidget);
    expect(find.bySemanticsLabel('Daily puzzle, Sep 26'), findsOneWidget);
  });

  testWidgets('pause sends its tap; disabled while an overlay is up', (
    tester,
  ) async {
    var taps = 0;
    await pumpScreen(tester, _hud(onPause: () => taps++));
    await tester.tap(find.bySemanticsLabel('Pause'));
    await tester.pump(const Duration(milliseconds: 200));
    expect(taps, 1);

    await pumpScreen(
      tester,
      Scaffold(
        body: GameplayHud(
          level: 1,
          tier: Tier.easy,
          coins: 0,
          setsDone: 0,
          setsTotal: 1,
          onPause: null,
          library: FakeFxLibrary(),
        ),
      ),
    );
    await tester.tap(find.bySemanticsLabel('Pause'));
    await tester.pump(const Duration(milliseconds: 200));
    expect(taps, 1);
  });

  group('FamilyCounter', () {
    Future<void> pumpCounter(WidgetTester tester, int done, int total) =>
        pumpUi(
          tester,
          Center(
            child: SizedBox.fromSize(
              size: FamilyCounter.canvas,
              child: FamilyCounter(
                done: done,
                total: total,
                library: FakeFxLibrary(),
              ),
            ),
          ),
        );

    testWidgets('without its file draws the pill and the label (R10)', (
      tester,
    ) async {
      await pumpCounter(tester, 0, 4);
      expect(find.bySemanticsLabel('0 of 4 families done'), findsOneWidget);
      expect(
        find.byWidgetPredicate(
          (w) => w is CustomPaint && w.painter is FamilyCounterPillPainter,
        ),
        findsOneWidget,
      );
    });

    testWidgets('follows the landed count up and resets down', (tester) async {
      await pumpCounter(tester, 0, 4);
      await pumpCounter(tester, 1, 4);
      expect(find.bySemanticsLabel('1 of 4 families done'), findsOneWidget);
      await pumpCounter(tester, 0, 4);
      expect(find.bySemanticsLabel('0 of 4 families done'), findsOneWidget);
      await pumpCounter(tester, 1, 1);
      expect(find.bySemanticsLabel('1 of 1 family done'), findsOneWidget);
    });
  });
}
