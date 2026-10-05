import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_core/nesty_core.dart';
import 'package:nesty_game/core/ui/nesty_ui.dart';
import 'package:nesty_game/features/fx/fake_fx_library.dart';
import 'package:nesty_game/features/fx/fx_id.dart';
import 'package:nesty_game/features/fx/lottie_fx_view.dart';
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
        // Centred while it fits between the controls at the wider one's
        // width; otherwise it takes the free width on its side (5B-5).
        final symmetricRoom =
            size.width - 2 * (16 + math.max(pause.width, coins.width) + 8);
        if (pill.width <= symmetricRoom + 0.01) {
          expect(pill.center.dx, closeTo(size.width / 2, 0.01));
        } else {
          expect(pill.center.dx, isNot(closeTo(size.width / 2, 0.01)));
        }
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
    expect(find.bySemanticsLabel('1 of 4 families complete'), findsOneWidget);
  });

  testWidgets('coinPillKey marks the coin pill, for the milestone chest\'s '
      'Collect flight to find (m7-design chest sequence step 4)', (
    tester,
  ) async {
    final coinPillKey = GlobalKey();
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
            onPause: () {},
            library: FakeFxLibrary(),
            coinPillKey: coinPillKey,
          ),
        ),
      ),
    );
    expect(
      find.descendant(
        of: find.byKey(coinPillKey),
        matching: find.byType(CoinPill),
      ),
      findsOneWidget,
    );
    final box = coinPillKey.currentContext!.findRenderObject()! as RenderBox;
    expect(box.attached, isTrue);
    expect(box.size, isNot(Size.zero));
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
      expect(find.bySemanticsLabel('0 of 4 families complete'), findsOneWidget);
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
      expect(find.bySemanticsLabel('1 of 4 families complete'), findsOneWidget);
      await pumpCounter(tester, 0, 4);
      expect(find.bySemanticsLabel('0 of 4 families complete'), findsOneWidget);
      await pumpCounter(tester, 1, 1);
      expect(find.bySemanticsLabel('1 of 1 family complete'), findsOneWidget);
    });
  });

  group('the family counter hugs its text (E.18)', () {
    testWidgets('"4 / 4" is about 64 dp and "12 / 12" about 78 (tokens '
        '`hud.familyCounter`)', (tester) async {
      await pumpUi(tester, const SizedBox());
      for (final (label, width) in [('4 / 4', 64.0), ('12 / 12', 78.0)]) {
        expect(FamilyCounter.hugWidth(label), closeTo(width, 4), reason: label);
      }
      expect(HudTokens.familyCounterWidthExamples, {
        '4 / 4': 64.0,
        '12 / 12': 78.0,
      });
    });

    testWidgets('the pill takes the hugged width itself (m7-4 4.14): no '
        'scale on the counter, the fallback pill is that wide', (tester) async {
      Future<double> pillFor(int done, int total) async {
        await pumpUi(
          tester,
          FamilyCounter(done: done, total: total, library: FakeFxLibrary()),
        );
        expect(
          find.descendant(
            of: find.byType(FamilyCounter),
            matching: find.byType(Transform),
          ),
          findsNothing,
          reason: 'the old 0.9-1.2 scale is gone',
        );
        final paint = tester.widget<CustomPaint>(
          find.byWidgetPredicate(
            (w) => w is CustomPaint && w.painter is FamilyCounterPillPainter,
          ),
        );
        final width = (paint.painter! as FamilyCounterPillPainter).pillWidth;
        final view = tester.widget<LottieFxView>(
          find.byWidgetPredicate(
            (w) => w is LottieFxView && w.id == FxId.uiFamilyCounter,
          ),
        );
        expect(
          view.controller!.params.pillWidth,
          width,
          reason: 'the file gets the same width through pill_rect',
        );
        return width;
      }

      final small = await pillFor(1, 4);
      final large = await pillFor(12, 12);
      expect(small, closeTo(64, 4));
      expect(large, closeTo(78, 4));
      expect(large, greaterThan(small));
      // Not clamped to the old 0.9-1.2 of 70 (63-84): any width.
      expect(FamilyCounter.hugWidth('100 / 100'), greaterThan(84));
    });
  });

  group('the chest\'s Collect bumps the coin pill (frame 10.3d)', () {
    testWidgets('each new coinBump plays a 240 ms 1.3× bump; reduce motion '
        'never moves it', (tester) async {
      Widget hud(int bump) => Scaffold(
        body: GameplayHud(
          level: 1,
          tier: Tier.easy,
          coins: 100,
          setsDone: 0,
          setsTotal: 1,
          onPause: () {},
          coinBump: bump,
          library: FakeFxLibrary(),
        ),
      );
      double scale() {
        final t = tester.widget<Transform>(
          find
              .ancestor(
                of: find.byType(CoinPill),
                matching: find.byType(Transform),
              )
              .first,
        );
        return t.transform.storage[0];
      }

      await pumpScreen(tester, hud(0));
      expect(scale(), 1);
      await pumpScreen(tester, hud(1));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 120));
      expect(scale(), closeTo(1.3, 0.02));
      await tester.pump(const Duration(milliseconds: 200));
      expect(scale(), 1);

      await pumpScreen(tester, hud(1), reduceMotion: true);
      await pumpScreen(tester, hud(2), reduceMotion: true);
      await tester.pump(const Duration(milliseconds: 120));
      expect(scale(), 1);
    });
  });
}
