import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_core/nesty_core.dart' show Tier;
import 'package:nesty_game/core/ui/nesty_ui.dart';

import '../../features/support/screen_harness.dart';
import 'support/ui_harness.dart';

/// tokens.json `textFit` (DELIVERY 9.2): per surface, wrap where allowed,
/// else scale down to the surface's `minScale`, else the short form, and
/// nothing is ever cut. Every surface gets a synthetic string far longer
/// than any translation, so the short form must appear.
void main() {
  setUpAll(loadBundledFonts);

  const style = TextStyle(fontFamily: 'Nunito', fontSize: 16);
  const long = 'Extraordinarily long synthetic label';

  group('FitText.pick', () {
    String pick(String full, String? short, double width, double min) =>
        FitText.pick(
          full: full,
          short: short,
          style: style,
          maxWidth: width,
          scaler: TextScaler.noScaling,
          direction: TextDirection.ltr,
          minScale: min,
        );

    test('the full text while it fits', () {
      expect(pick('Undo', 'U', 200, 0.8), 'Undo');
    });

    test('the full text scaled down while it stays at or above minScale', () {
      final natural = (TextPainter(
        text: const TextSpan(text: 'Restart', style: style),
        textDirection: TextDirection.ltr,
      )..layout()).width;
      expect(pick('Restart', 'Re', natural * 0.9, 0.8), 'Restart');
      expect(pick('Restart', 'Re', natural * 0.7, 0.8), 'Re');
    });

    test('no short form (or the same one) keeps the full text', () {
      expect(pick(long, null, 20, 0.8), long);
      expect(pick(long, long, 20, 0.8), long);
    });

    test('an unbounded box keeps the full text', () {
      expect(pick(long, 'L', double.infinity, 0.8), long);
    });
  });

  group('each tight surface shows its short form and cuts nothing', () {
    testWidgets('a booster label (80 dp pad, minScale 0.8)', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpUi(
        tester,
        const Center(
          child: BoosterButton(
            kind: BoosterButtonKind.restart,
            icon: Icons.restart_alt,
            label: long,
            shortLabel: 'Redo',
            onPressed: null,
          ),
        ),
      );
      expect(find.text('Redo'), findsOneWidget);
      expect(find.text(long), findsNothing);
      expectNoLayoutErrors(tester);
      handle.dispose();
    });

    testWidgets('a booster label keeps its full text when it fits', (
      tester,
    ) async {
      await pumpUi(
        tester,
        const Center(
          child: BoosterButton(
            kind: BoosterButtonKind.undo,
            icon: Icons.undo,
            label: 'Undo',
            shortLabel: 'U',
            onPressed: null,
          ),
        ),
      );
      expect(find.text('Undo'), findsOneWidget);
      expect(find.text('U'), findsNothing);
    });

    testWidgets('a tab label (80 dp item, minScale 0.8)', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpUi(
        tester,
        Align(
          alignment: Alignment.bottomCenter,
          child: NestyBottomNav(
            items: const [
              NestyBottomNavItem(
                icon: Icons.store,
                label: long,
                shortLabel: 'Shop',
              ),
              NestyBottomNavItem(icon: Icons.home, label: 'Home'),
            ],
            selectedIndex: 1,
            onChanged: (_) {},
          ),
        ),
      );
      expect(find.text('Shop'), findsOneWidget);
      expect(find.text(long), findsNothing);
      // A screen reader still hears the whole label.
      expect(find.bySemanticsLabel(long), findsOneWidget);
      expectNoLayoutErrors(tester);
      handle.dispose();
    });

    testWidgets('the HUD pill: SUPER HARD drops to SUPER, HARD to its glyph', (
      tester,
    ) async {
      for (final tier in [Tier.superhard, Tier.hard]) {
        await pumpUi(
          tester,
          Center(
            child: SizedBox(
              width: 120,
              child: LevelPill(level: 188, tier: tier),
            ),
          ),
        );
        if (tier == Tier.superhard) {
          expect(find.text('SUPER'), findsOneWidget);
          expect(find.text('SUPER HARD'), findsNothing);
        } else {
          expect(find.text('HARD'), findsNothing);
        }
        expect(find.text('Level 188'), findsOneWidget);
        expectNoLayoutErrors(tester);
      }
    });

    testWidgets('the HUD pill keeps the full tier name when it fits', (
      tester,
    ) async {
      await pumpUi(
        tester,
        const Center(child: LevelPill(level: 188, tier: Tier.superhard)),
      );
      expect(find.text('SUPER HARD'), findsOneWidget);
    });

    testWidgets('a ribbon label: the short form below textFit minScale', (
      tester,
    ) async {
      late BuildContext context;
      await pumpUi(
        tester,
        Builder(
          builder: (c) {
            context = c;
            return const SizedBox();
          },
        ),
      );
      const veryLong = 'A level-complete line far too long for the ribbon';
      String pick(String full) => RibbonLabel.pick(
        context,
        style: LottieLabelStyles.winRibbon,
        full: full,
        short: 'Complete!',
        minScale: TextFitTokens.winRibbonMinScale,
      );
      expect(pick('Level Complete!'), 'Level Complete!');
      expect(pick(veryLong), 'Complete!');
    });
  });
}
