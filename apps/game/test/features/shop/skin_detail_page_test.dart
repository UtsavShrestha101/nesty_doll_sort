import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_core/nesty_core.dart';
import 'package:nesty_game/core/base/base_async_state.dart';
import 'package:nesty_game/core/error/app_exception.dart';
import 'package:nesty_game/core/repository/catalog_models.dart';
import 'package:nesty_game/core/services/database/database_service.dart';
import 'package:nesty_game/core/services/database/fake_database_service.dart';
import 'package:nesty_game/core/services/skin/fake_skin_service.dart';
import 'package:nesty_game/core/services/skin/skin_service.dart';
import 'package:nesty_game/core/ui/nesty_ui.dart';
import 'package:nesty_game/features/fx/fake_fx_library.dart';
import 'package:nesty_game/features/fx/fx_library.dart';
import 'package:nesty_game/features/shop/cubit/skin_detail_cubit.dart';
import 'package:nesty_game/features/shop/model/purchase_outcome.dart';
import 'package:nesty_game/features/shop/pages/skin_detail_page.dart';
import 'package:nesty_game/features/shop/widgets/purchase_twinkle_burst.dart';
import 'package:nesty_game/features/shop/widgets/shop_look.dart';
import 'package:nesty_game/features/shop/widgets/skin_doll_row.dart';

import '../../core/ui/support/ui_harness.dart';
import '../support/screen_harness.dart';

/// Frame 7.4 (docs/plans/m3-design.md §10.7): all 11 colors, the size
/// lineup, the name/description, and Buy / Equip / Equipped with the
/// balance line.
void main() {
  setUpAll(() async {
    await loadBundledFonts();
  });

  const oceanBuyable = SkinDetailState(
    skin: SkinInfo(
      id: 'ocean',
      priceCoins: 800,
      previewColors: [DollColor.teal, DollColor.blue, DollColor.navy],
    ),
    owned: false,
    equipped: false,
    coins: 250,
  );

  // Enough coins to actually afford ocean's 800 (oceanBuyable's 250 is
  // below its price, so it is used only where the button's enabled state
  // doesn't matter).
  const oceanAffordable = SkinDetailState(
    skin: SkinInfo(
      id: 'ocean',
      priceCoins: 800,
      previewColors: [DollColor.teal, DollColor.blue, DollColor.navy],
    ),
    owned: false,
    equipped: false,
    coins: 2500,
  );

  Finder buyButton() => find.ancestor(
    of: find.text('Buy'),
    matching: find.byType(TactileSurface),
  );

  Future<void> pumpDetail(
    WidgetTester tester, {
    required AsyncValue<SkinDetailState> state,
    VoidCallback? onRetry,
    VoidCallback? onBack,
    Future<PurchaseOutcome> Function()? onBuy,
    VoidCallback? onNeedCoins,
    Future<bool> Function()? onEquip,
    Size size = const Size(390, 844),
    double textScale = 1,
  }) async {
    await pumpScreen(
      tester,
      MultiRepositoryProvider(
        providers: [
          RepositoryProvider<SkinService>.value(value: FakeSkinService()),
          RepositoryProvider<DatabaseService>.value(
            value: FakeDatabaseService(),
          ),
          RepositoryProvider<FxLibrary>.value(value: FakeFxLibrary()),
        ],
        child: SkinDetailView(
          state: state,
          onRetry: onRetry ?? () {},
          onBack: onBack ?? () {},
          onBuy: onBuy ?? () async => PurchaseOutcome.bought,
          onNeedCoins: onNeedCoins ?? () {},
          onEquip: onEquip ?? () async => true,
        ),
      ),
      size: size,
      textScale: textScale,
    );
    await tester.pump();
  }

  testWidgets('the title, captions, name and Buy', (tester) async {
    await pumpDetail(tester, state: const AsyncValue.data(data: oceanBuyable));
    expect(find.text('Skin'), findsOneWidget);
    expect(find.text('All 11 colors · symbols kept'), findsOneWidget);
    expect(
      find.text('Every size nests the same way. Only the paint changes.'),
      findsOneWidget,
    );
    expect(find.text('Ocean'), findsOneWidget);
    expect(
      find.text('Sailor collars, tiny anchors and wave trims.'),
      findsOneWidget,
    );
    expect(find.text('Buy'), findsOneWidget);
    expect(find.text('You have 250 coins'), findsOneWidget);
  });

  testWidgets('the header has the back arrow and the coin pill, like every '
      'NestyShop screen (frame 7.4; FIDELITY-10)', (tester) async {
    var backs = 0;
    await pumpDetail(
      tester,
      state: const AsyncValue.data(data: oceanBuyable),
      onBack: () => backs++,
    );
    expect(find.bySemanticsLabel('Close'), findsNothing);
    final header = find.byType(ScreenHeader);
    expect(
      tester
          .widget<CoinPill>(
            find.descendant(of: header, matching: find.byType(CoinPill)),
          )
          .coins,
      250,
    );
    await tester.tap(find.bySemanticsLabel('Back'));
    await tester.pump(const Duration(milliseconds: 200));
    expect(backs, 1);
  });

  testWidgets('Buy is "Buy" plus a trailing coin chip with the price, read '
      'as one label (frame 7.4; FIDELITY-10, RULES-1)', (tester) async {
    await pumpDetail(
      tester,
      state: const AsyncValue.data(data: oceanAffordable),
    );
    final buy = find.bySemanticsLabel('Buy, 800 coins');
    expect(buy, findsOneWidget);
    final label = tester.getRect(find.text('Buy'));
    final price = tester.getRect(find.text('800'));
    final coin = tester.getRect(
      find.descendant(
        of: find.byType(TactileSurface).last,
        matching: find.byType(CoinIcon),
      ),
    );
    // "Buy", then the chip: its coin, then the number.
    expect(coin.left, greaterThan(label.right));
    expect(price.left, greaterThan(coin.right));
    // One word and a number, not a glued "Buy · 800 coins" string.
    expect(
      find.descendant(
        of: find.byType(TactileSurface).last,
        matching: find.byType(Text),
      ),
      findsNWidgets(2),
    );
  });

  testWidgets('the colour panel is the skin\'s own card colour with a 22 px '
      'plank under each shelf of dolls (frame 7.4; FIDELITY-5)', (
    tester,
  ) async {
    await pumpDetail(
      tester,
      state: const AsyncValue.data(
        data: SkinDetailState(
          skin: SkinInfo(
            id: 'space',
            priceCoins: 1200,
            previewColors: [DollColor.navy, DollColor.purple, DollColor.teal],
          ),
          owned: false,
          equipped: false,
          coins: 0,
        ),
      ),
    );
    final panel = find.byWidgetPredicate(
      (w) => w is NestySurface && w.height == 292,
    );
    expect(
      tester.widget<NestySurface>(panel).style.gradient,
      ShopLook.card('space'),
    );
    final top = tester.getRect(panel).top;
    final planks = tester
        .widgetList<PlankStrip>(
          find.descendant(of: panel, matching: find.byType(PlankStrip)),
        )
        .toList();
    expect(planks.map((p) => p.height), [22, 22]);
    final plankFinder = find.descendant(
      of: panel,
      matching: find.byType(PlankStrip),
    );
    expect(
      [for (var i = 0; i < 2; i++) tester.getRect(plankFinder.at(i)).top - top],
      [118, 252],
    );
    // The 6 + 5 dolls stand on them: the rows' bases at 124 and 258.
    final rows = find.descendant(of: panel, matching: find.byType(SkinDollRow));
    expect(rows, findsNWidgets(2));
    expect(
      [for (var i = 0; i < 2; i++) tester.getRect(rows.at(i)).bottom - top],
      [124, 258],
    );
  });

  testWidgets('the size lineup is the skin\'s first preview colour '
      '(frame 7.4: Ocean\'s lagoon; FIDELITY-10)', (tester) async {
    await pumpDetail(tester, state: const AsyncValue.data(data: oceanBuyable));
    final lineup = tester
        .widgetList<SkinDollRow>(find.byType(SkinDollRow))
        .singleWhere((r) => r.heights.length == 4);
    expect(lineup.colors, List.filled(4, DollColor.teal));
    expect(lineup.heights, SkinDetailView.sizeHeights);
  });

  testWidgets('unaffordable: Buy stays orange (frames 7.3/7.7 draw every '
      'price that way) and a tap that needs coins opens '
      'NotEnoughCoinsDialog first (D112, replaces the FIDELITY-7 jump)', (
    tester,
  ) async {
    var buys = 0;
    var needCoins = 0;
    await pumpDetail(
      tester,
      state: const AsyncValue.data(
        data: SkinDetailState(
          skin: SkinInfo(
            id: 'ocean',
            priceCoins: 800,
            previewColors: [DollColor.teal, DollColor.blue, DollColor.navy],
          ),
          owned: false,
          equipped: false,
          coins: 10,
        ),
      ),
      onBuy: () async {
        buys++;
        return PurchaseOutcome.needsCoins;
      },
      onNeedCoins: () => needCoins++,
    );
    expect(tester.widget<TactileSurface>(buyButton()).onPressed, isNotNull);
    await tester.tap(buyButton());
    await tester.pump(const Duration(milliseconds: 200));
    expect(buys, 1);
    expect(needCoins, 0, reason: 'the dialog, not the jump, opens first');
    expect(find.byType(PurchaseTwinkleBurst), findsNothing);

    expect(find.byType(NotEnoughCoinsDialog), findsOneWidget);
    expect(find.text('You need 790 more coins'), findsOneWidget);

    await tester.tap(find.text('Not now'));
    await tester.pumpAndSettle();
    expect(find.byType(NotEnoughCoinsDialog), findsNothing);
    expect(needCoins, 0, reason: 'Not now stays put');
  });

  testWidgets("NotEnoughCoinsDialog's Go to Shop calls onNeedCoins (the "
      'page then opens the Shop on its Coins tab)', (tester) async {
    var needCoins = 0;
    await pumpDetail(
      tester,
      state: const AsyncValue.data(
        data: SkinDetailState(
          skin: SkinInfo(
            id: 'ocean',
            priceCoins: 800,
            previewColors: [DollColor.teal, DollColor.blue, DollColor.navy],
          ),
          owned: false,
          equipped: false,
          coins: 10,
        ),
      ),
      onBuy: () async => PurchaseOutcome.needsCoins,
      onNeedCoins: () => needCoins++,
    );
    await tester.tap(buyButton());
    await tester.pump(const Duration(milliseconds: 200));

    await tester.tap(find.text('Go to Shop'));
    await tester.pumpAndSettle();
    expect(find.byType(NotEnoughCoinsDialog), findsNothing);
    expect(needCoins, 1);
  });

  testWidgets('affordable: tapping Buy calls onBuy', (tester) async {
    var buys = 0;
    await pumpDetail(
      tester,
      state: const AsyncValue.data(data: oceanAffordable),
      onBuy: () async {
        buys++;
        return PurchaseOutcome.bought;
      },
    );
    await tester.tap(buyButton());
    await tester.pump(const Duration(milliseconds: 200));
    expect(buys, 1);
    // Lets the purchase twinkle burst's own timer finish and remove
    // itself, so no timer is left pending when the test tears down.
    await tester.pump(const Duration(milliseconds: 2600));
  });

  testWidgets('owned, unequipped: Equip calls onEquip', (tester) async {
    var equips = 0;
    await pumpDetail(
      tester,
      state: const AsyncValue.data(
        data: SkinDetailState(
          skin: SkinInfo(
            id: 'ocean',
            priceCoins: 800,
            previewColors: [DollColor.teal, DollColor.blue, DollColor.navy],
          ),
          owned: true,
          equipped: false,
          coins: 250,
        ),
      ),
      onEquip: () async {
        equips++;
        return true;
      },
    );
    expect(find.text('Equip'), findsOneWidget);
    await tester.tap(find.text('Equip'));
    await tester.pump(const Duration(milliseconds: 200));
    expect(equips, 1);
  });

  testWidgets('equipped: shows Equipped, disabled', (tester) async {
    await pumpDetail(
      tester,
      state: const AsyncValue.data(
        data: SkinDetailState(
          skin: SkinInfo(
            id: 'classic',
            priceCoins: 0,
            previewColors: [DollColor.red, DollColor.yellow, DollColor.blue],
          ),
          owned: true,
          equipped: true,
          coins: 0,
        ),
      ),
    );
    expect(find.text('Equipped'), findsOneWidget);
    final button = tester.widget<TactileButton>(find.byType(TactileButton));
    expect(button.onPressed, isNull);
  });

  testWidgets('a skin with no description hides the line', (tester) async {
    await pumpDetail(
      tester,
      state: const AsyncValue.data(
        data: SkinDetailState(
          skin: SkinInfo(
            id: 'space',
            priceCoins: 1200,
            previewColors: [DollColor.navy, DollColor.purple, DollColor.teal],
          ),
          owned: false,
          equipped: false,
          coins: 0,
        ),
      ),
    );
    expect(find.text('Space'), findsOneWidget);
    // No frame-provided description for Space (Q73): the line is hidden,
    // not shown empty.
    expect(find.text(''), findsNothing);
  });

  testWidgets('a failed load offers a retry', (tester) async {
    var retries = 0;
    await pumpDetail(
      tester,
      state: const AsyncValue.error(
        exception: AppException(AppExceptionKind.content, message: 'oops'),
      ),
      onRetry: () => retries++,
    );
    expect(find.text('Try again'), findsOneWidget);
    await tester.tap(find.text('Try again'));
    await tester.pump(const Duration(milliseconds: 200));
    expect(retries, 1);
  });

  for (final size in screenSizes) {
    for (final scale in textScales) {
      testWidgets(
        'fits ${size.width.toInt()}×${size.height.toInt()} at $scale× text',
        (tester) async {
          await pumpDetail(
            tester,
            state: const AsyncValue.data(data: oceanBuyable),
            size: size,
            textScale: scale,
          );
          expectNoLayoutErrors(tester);
        },
      );
    }
  }
}
