import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_game/core/ui/nesty_ui.dart';
import 'package:nesty_game/core/ui/widgets/home/text_link.dart';

import '../../features/support/screen_harness.dart';
import 'support/ui_harness.dart';

/// D112 (owner 2026-09-28 simulator review, replaces D86): a tap on a price
/// the balance can't cover opens this instead of jumping straight to the
/// Shop's Coins tab.
void main() {
  setUpAll(loadBundledFonts);

  Future<void> pumpDialog(
    WidgetTester tester, {
    int price = 800,
    int balance = 100,
    VoidCallback? onGoToShop,
    VoidCallback? onNotNow,
    String? itemName,
    Size size = const Size(390, 844),
    double textScale = 1,
  }) => pumpScreen(
    tester,
    Scaffold(
      body: NotEnoughCoinsDialog(
        price: price,
        balance: balance,
        itemName: itemName,
        onGoToShop: onGoToShop ?? () {},
        onNotNow: onNotNow ?? () {},
      ),
    ),
    size: size,
    textScale: textScale,
  );

  testWidgets('shows the price, how many more are needed, and where coins '
      'come from, warm and plain (D112)', (tester) async {
    await pumpDialog(tester, price: 800, balance: 100);
    expect(find.text('A few more coins'), findsOneWidget);
    // The pill shows the number only; "coins" is in the label.
    expect(find.text('800'), findsOneWidget);
    expect(find.text('800 coins'), findsNothing);
    expect(find.text('You need 700 more coins'), findsOneWidget);
    expect(
      find.text('Coins come from winning levels, the daily puzzle and chests.'),
      findsOneWidget,
    );
    expect(find.text('Go to Shop'), findsOneWidget);
    expect(find.text('Not now'), findsOneWidget);
  });

  testWidgets('opened by show, its text has the app\'s defaults, never the '
      'no-Material underline: a general dialog brings no Material of its '
      'own', (tester) async {
    // The device run (2026-09-30) found every line of the card underlined
    // in yellow: the fallback style Text gets with no Material above it.
    await pumpScreen(
      tester,
      Scaffold(
        body: Builder(
          builder: (context) => Center(
            child: TextButton(
              onPressed: () => NotEnoughCoinsDialog.show(
                context,
                price: 800,
                balance: 10,
                itemName: 'Ocean',
                onGoToShop: () {},
              ),
              child: const Text('open'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    for (final text in [
      'A few more coins',
      'You need 790 more coins',
      'Go to Shop',
      'Not now',
    ]) {
      final paragraph = tester.renderObject<RenderParagraph>(find.text(text));
      final decorations = <TextDecoration?>[];
      paragraph.text.visitChildren((InlineSpan span) {
        decorations.add(span.style?.decoration);
        return true;
      });
      expect(
        decorations.where((d) => d != null && d != TextDecoration.none),
        isEmpty,
        reason: text,
      );
    }
  });

  testWidgets('a single coin short reads the singular', (tester) async {
    await pumpDialog(tester, price: 100, balance: 99);
    expect(find.text('You need 1 more coin'), findsOneWidget);
  });

  testWidgets('Go to Shop calls onGoToShop; the price stays a plain, '
      'enabled button (this dialog only informs; the price it names never '
      'disables)', (tester) async {
    var taps = 0;
    await pumpDialog(tester, onGoToShop: () => taps++);
    final button = tester.widget<TactileButton>(
      find.ancestor(
        of: find.text('Go to Shop'),
        matching: find.byType(TactileButton),
      ),
    );
    expect(button.onPressed, isNotNull);
    await tester.tap(find.text('Go to Shop'));
    await tester.pump();
    expect(taps, 1);
  });

  testWidgets('Not now calls onNotNow', (tester) async {
    var taps = 0;
    await pumpDialog(tester, onNotNow: () => taps++);
    await tester.tap(find.text('Not now'));
    await tester.pump();
    expect(taps, 1);
  });

  testWidgets('the close button also calls onNotNow', (tester) async {
    var taps = 0;
    await pumpDialog(tester, onNotNow: () => taps++);
    expect(find.bySemanticsLabel('Close'), findsOneWidget);
    await tester.tap(find.bySemanticsLabel('Close'));
    await tester.pump();
    expect(taps, 1);
  });

  testWidgets(
    'show() opens over a scrim; Go to Shop closes it, then calls back',
    (tester) async {
      var goToShop = 0;
      await pumpScreen(
        tester,
        Scaffold(
          body: Builder(
            builder: (context) => Center(
              child: TextButton(
                onPressed: () => NotEnoughCoinsDialog.show(
                  context,
                  price: 800,
                  balance: 100,
                  onGoToShop: () => goToShop++,
                ),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      expect(find.byType(NotEnoughCoinsDialog), findsOneWidget);

      await tester.tap(find.text('Go to Shop'));
      await tester.pumpAndSettle();
      expect(find.byType(NotEnoughCoinsDialog), findsNothing);
      expect(goToShop, 1);
    },
  );

  testWidgets("show()'s Not now closes it and never calls onGoToShop", (
    tester,
  ) async {
    var goToShop = 0;
    await pumpScreen(
      tester,
      Scaffold(
        body: Builder(
          builder: (context) => Center(
            child: TextButton(
              onPressed: () => NotEnoughCoinsDialog.show(
                context,
                price: 800,
                balance: 100,
                onGoToShop: () => goToShop++,
              ),
              child: const Text('open'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Not now'));
    await tester.pumpAndSettle();
    expect(find.byType(NotEnoughCoinsDialog), findsNothing);
    expect(goToShop, 0);
  });

  testWidgets('the item chip names the item beside its price (frames 7.3b, '
      '7.4c)', (tester) async {
    final handle = tester.ensureSemantics();
    await pumpDialog(
      tester,
      price: 2500,
      balance: 830,
      itemName: 'Forest Bear',
    );
    expect(find.text('Forest Bear'), findsOneWidget);
    expect(find.text('2,500'), findsOneWidget);
    expect(find.text('2,500 coins'), findsNothing);
    expect(find.text('You need 1,670 more coins'), findsOneWidget);
    expect(find.bySemanticsLabel('Forest Bear, 2,500 coins'), findsOneWidget);
    handle.dispose();
  });

  testWidgets('type and chip follow NestyMeta:59-63: 24/1.15, 16/23, a 30 '
      'tall pill with the number at 16 and the coin at 20', (tester) async {
    await pumpDialog(tester, price: 800, balance: 100, itemName: 'Ocean');
    final heading = tester.widget<Text>(find.text('You need 700 more coins'));
    expect(heading.style!.fontSize, 24);
    expect(heading.style!.height, 1.15);
    final body = tester.widget<Text>(
      find.text('Coins come from winning levels, the daily puzzle and chests.'),
    );
    expect(body.style!.fontSize, 16);
    expect(body.style!.height, closeTo(23 / 16, 1e-9));
    expect(tester.widget<Text>(find.text('Ocean')).style!.fontSize, 18);
    final price = find.text('800');
    expect(tester.widget<Text>(price).style!.fontSize, 16);
    final pill = find.ancestor(of: price, matching: find.byType(NestySurface));
    expect(tester.getSize(pill.first).height, 30);
    final chip = tester.widget<NestySurface>(pill.at(1));
    expect(chip.style.color, AppColorTokens.surfaceWhite);
    expect(chip.style.shadows.single.inset, isTrue);
    expect(chip.style.shadows.single.color, AppColorTokens.surfaceTrack);
    expect(
      tester
          .getSize(
            find.descendant(of: pill.first, matching: find.byType(CoinIcon)),
          )
          .width,
      20,
    );
  });

  testWidgets('without an item name the chip is the price alone (the booster '
      'popup passes none until it knows its booster)', (tester) async {
    await pumpDialog(tester, price: 60, balance: 10);
    expect(find.text('60'), findsOneWidget);
    expect(find.text('Forest Bear'), findsNothing);
  });

  testWidgets('"Not now" is a text link with a 48 dp target, and Go to Shop '
      'is the primary button', (tester) async {
    await pumpDialog(tester);
    expect(find.byType(TextLink), findsOneWidget);
    final target = tester.getSize(
      find.ancestor(
        of: find.text('Not now'),
        matching: find.byType(TouchTarget),
      ),
    );
    expect(target.height, greaterThanOrEqualTo(48));
    expect(target.width, greaterThanOrEqualTo(48));
    expect(
      tester
          .widget<TactileButton>(
            find.widgetWithText(TactileButton, 'Go to Shop'),
          )
          .variant,
      TactileButtonVariant.primary,
    );
  });

  testWidgets('show() opens it as a route and reads as a dialog with its '
      'title (Sound and haptic come from the buttons)', (tester) async {
    final handle = tester.ensureSemantics();
    await pumpScreen(
      tester,
      Scaffold(
        body: Builder(
          builder: (context) => TextButton(
            onPressed: () => NotEnoughCoinsDialog.show(
              context,
              price: 800,
              balance: 100,
              itemName: 'Ocean',
              onGoToShop: () {},
            ),
            child: const Text('open'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    expect(find.text('Ocean'), findsOneWidget);
    expect(find.bySemanticsLabel('A few more coins'), findsOneWidget);
    handle.dispose();
  });

  testWidgets('it fades in over 240 ms, and over 120 ms with reduce motion, '
      'with no scale then', (tester) async {
    Future<void> open(WidgetTester tester, {required bool reduce}) async {
      await pumpScreen(
        tester,
        Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () => NotEnoughCoinsDialog.show(
                context,
                price: 800,
                balance: 100,
                onGoToShop: () {},
              ),
              child: const Text('open'),
            ),
          ),
        ),
        reduceMotion: reduce,
      );
      await tester.tap(find.text('open'));
      await tester.pump();
    }

    await open(tester, reduce: false);
    expect(find.byType(ScaleTransition), findsWidgets);
    await tester.pump(const Duration(milliseconds: 120));
    expect(find.byType(NotEnoughCoinsDialog), findsOneWidget);
    await tester.pumpAndSettle();

    await tester.pumpWidget(const SizedBox());
    await open(tester, reduce: true);
    await tester.pump(const Duration(milliseconds: 130));
    // Settled by 120 ms: nothing is left animating.
    expect(tester.hasRunningAnimations, isFalse);
  });

  for (final size in overflowScreenSizes) {
    for (final scale in textScales) {
      testWidgets(
        'fits ${size.width.toInt()}×${size.height.toInt()} at $scale× text, '
        'even with a large price',
        (tester) async {
          await pumpDialog(
            tester,
            price: 123456,
            balance: 1,
            size: size,
            textScale: scale,
          );
          await expectAccessibleLayout(tester);
        },
      );
    }
  }
}
