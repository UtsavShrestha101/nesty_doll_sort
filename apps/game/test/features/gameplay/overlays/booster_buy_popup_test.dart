import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_game/core/models/booster.dart';
import 'package:nesty_game/core/ui/nesty_ui.dart';
import 'package:nesty_game/features/gameplay/overlays/booster_buy_popup.dart';

import '../../../core/ui/support/ui_harness.dart';
import '../../support/screen_harness.dart';

Widget _popup({
  BoosterType type = BoosterType.undo,
  int price = 60,
  int coins = 830,
  int freeUndosPerLevel = 2,
  VoidCallback? onBuy,
  VoidCallback? onDismiss,
}) => BoosterBuyPopup(
  type: type,
  price: price,
  coins: coins,
  freeUndosPerLevel: freeUndosPerLevel,
  onBuy: onBuy,
  onDismiss: onDismiss ?? () {},
);

void main() {
  setUpAll(loadBundledFonts);

  testWidgets('the Undo popup (frame 3.2): title, benefit, price and '
      'balance', (tester) async {
    await pumpScreen(tester, _popup());
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Undo'), findsOneWidget);
    expect(
      find.text('Your 2 free undos are used. Take back one more move.'),
      findsOneWidget,
    );
    expect(find.text('60 coins'), findsOneWidget);
    expect(find.text('You have 830 coins'), findsOneWidget);
  });

  testWidgets('the Hint popup (frame 3.3)', (tester) async {
    await pumpScreen(tester, _popup(type: BoosterType.hint, price: 40));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Hint'), findsOneWidget);
    expect(find.text('Shows your next best move.'), findsOneWidget);
    expect(find.text('40 coins'), findsOneWidget);
  });

  testWidgets('the +1 Slot popup', (tester) async {
    await pumpScreen(tester, _popup(type: BoosterType.slot, price: 50));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('+Slot'), findsOneWidget);
    expect(find.text('Adds one empty stand for this level.'), findsOneWidget);
  });

  testWidgets('unaffordable: the coin button is disabled (onBuy null)', (
    tester,
  ) async {
    await pumpScreen(tester, _popup(coins: 10, price: 60, onBuy: null));
    await tester.pump(const Duration(milliseconds: 300));
    final button = tester.widget<TactileButton>(find.byType(TactileButton));
    expect(button.onPressed, isNull);
  });

  testWidgets('affordable: the coin button buys; the close button and the '
      'scrim dismiss', (tester) async {
    var bought = 0;
    var dismissed = 0;
    await pumpScreen(
      tester,
      _popup(onBuy: () => bought++, onDismiss: () => dismissed++),
    );
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.text('60 coins'));
    await tester.pump();
    expect(bought, 1);

    await tester.tap(find.byType(NestyCloseButton));
    await tester.pump();
    expect(dismissed, 1);

    await tester.tapAt(const Offset(10, 10));
    await tester.pump();
    expect(dismissed, 2);
  });

  for (final size in screenSizes) {
    for (final scale in textScales) {
      testWidgets('fits ${size.width.toInt()} wide at $scale× text', (
        tester,
      ) async {
        await pumpScreen(tester, _popup(), size: size, textScale: scale);
        await tester.pump(const Duration(milliseconds: 300));
        expectNoLayoutErrors(tester);
        final card = tester.getRect(find.byType(ModalCard));
        expect(card.left, greaterThanOrEqualTo(BoosterBuyPopup.side));
        expect(
          card.right,
          lessThanOrEqualTo(size.width - BoosterBuyPopup.side),
        );
      });
    }
  }

  group(
    'a price the balance can\'t cover (D195, phase 4 architecture §3.7)',
    () {
      Widget unaffordable({VoidCallback? onNeedCoins, VoidCallback? onBuy}) =>
          BoosterBuyPopup(
            type: BoosterType.undo,
            price: 60,
            coins: 10,
            freeUndosPerLevel: 2,
            onBuy: onBuy,
            onNeedCoins: onNeedCoins,
            onDismiss: () {},
          );

      testWidgets('with a way to the Shop the coin button is enabled and '
          'opens Not enough coins with the shortfall', (tester) async {
        var shops = 0;
        await pumpScreen(tester, unaffordable(onNeedCoins: () => shops++));
        await tester.pump(const Duration(milliseconds: 300));
        final button = tester.widget<CoinPriceButton>(
          find.byType(CoinPriceButton),
        );
        expect(button.onPressed, isNotNull);

        await tester.tap(find.byType(CoinPriceButton));
        await tester.pump(const Duration(milliseconds: 400));
        expect(find.text('A few more coins'), findsOneWidget);
        expect(find.text('You need 50 more coins'), findsOneWidget);
        // The item chip names the booster.
        expect(find.text('Undo'), findsWidgets);

        await tester.tap(find.text('Go to Shop'));
        await tester.pump(const Duration(milliseconds: 400));
        expect(shops, 1);
      });

      testWidgets('Not now closes the dialog and changes nothing', (
        tester,
      ) async {
        var shops = 0;
        await pumpScreen(tester, unaffordable(onNeedCoins: () => shops++));
        await tester.pump(const Duration(milliseconds: 300));
        await tester.tap(find.byType(CoinPriceButton));
        await tester.pump(const Duration(milliseconds: 400));
        await tester.tap(find.text('Not now'));
        await tester.pump(const Duration(milliseconds: 400));
        expect(find.text('A few more coins'), findsNothing);
        expect(shops, 0);
        expect(find.byType(BoosterBuyPopup), findsOneWidget);
      });

      testWidgets('an affordable price still buys, never the dialog', (
        tester,
      ) async {
        var buys = 0;
        await pumpScreen(
          tester,
          BoosterBuyPopup(
            type: BoosterType.undo,
            price: 60,
            coins: 100,
            freeUndosPerLevel: 2,
            onBuy: () => buys++,
            onNeedCoins: () {},
            onDismiss: () {},
          ),
        );
        await tester.pump(const Duration(milliseconds: 300));
        await tester.tap(find.byType(CoinPriceButton));
        await tester.pump(const Duration(milliseconds: 400));
        expect(buys, 1);
        expect(find.text('A few more coins'), findsNothing);
      });

      testWidgets('without a way to the Shop it stays disabled, as before', (
        tester,
      ) async {
        await pumpScreen(tester, unaffordable());
        await tester.pump(const Duration(milliseconds: 300));
        final button = tester.widget<CoinPriceButton>(
          find.byType(CoinPriceButton),
        );
        expect(button.onPressed, isNull);
      });
    },
  );
}
