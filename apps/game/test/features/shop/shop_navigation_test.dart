import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_game/app/app.dart';
import 'package:nesty_game/core/dependency_injection/di.dart';
import 'package:nesty_game/core/router/app_router.dart';
import 'package:nesty_game/core/ui/nesty_ui.dart';
import 'package:nesty_game/features/home/pages/home_page.dart';
import 'package:nesty_game/features/shop/cubit/shop_cubit.dart';
import 'package:nesty_game/features/shop/model/shop_tab.dart';
import 'package:nesty_game/features/shop/pages/shop_page.dart';
import 'package:nesty_game/features/shop/pages/skin_detail_page.dart';
import 'package:nesty_game/features/shop/widgets/shop_closed_card.dart';

import '../../core/ui/support/ui_harness.dart';
import '../../helpers/test_dependencies.dart';

/// Opening the Shop on a tab from Home, over the whole app and the fake DI
/// graph (m3-design §10.3, §10.7): the coin pill's "+" asks for Coins and
/// the Remove Ads tile for No Ads, every time, even once the Shop tab (kept
/// alive by the shell) has been visited and left on another tab
/// (CORRECTNESS-6).
void main() {
  setUpAll(loadBundledFonts);
  setUp(() async {
    await configureTestDependencies();
    // These start at Home: a fresh save opens Level 1 (E9).
    await seedSavePastFirstLevel();
  });
  tearDown(resetDependencies);

  Finder navLabel(String label) => find.descendant(
    of: find.byType(NestyBottomNav),
    matching: find.text(label),
  );

  Finder inHome(Finder matching) =>
      find.descendant(of: find.byType(HomePage), matching: matching);

  /// Pumps past route transitions without settling (Home's decor loops).
  Future<void> pumpFor(WidgetTester tester, Duration duration) async {
    const step = Duration(milliseconds: 50);
    for (var t = Duration.zero; t < duration; t += step) {
      await tester.pump(step);
    }
  }

  Future<void> boot(WidgetTester tester) async {
    tester.view
      ..physicalSize = const Size(390, 844)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(App(router: get<AppRouter>()));
    await tester.pump();
    await pumpFor(tester, const Duration(seconds: 1));
    expect(find.byType(HomePage), findsOneWidget);
  }

  ShopTab? shopTab(WidgetTester tester) => tester
      .element(find.byType(ShopView, skipOffstage: false))
      .read<ShopCubit>()
      .state
      .data
      ?.tab;

  Future<void> tapCoinPlus(WidgetTester tester) async {
    await tester.tap(inHome(find.byType(CoinPill)));
    await pumpFor(tester, const Duration(seconds: 1));
  }

  Future<void> goHome(WidgetTester tester) async {
    await tester.tap(navLabel('Home'));
    await pumpFor(tester, const Duration(seconds: 1));
    expect(find.byType(HomePage), findsOneWidget);
  }

  testWidgets('the coin pill "+" opens Coins after the Shop tab was visited '
      'on Skins', (tester) async {
    await boot(tester);
    await tester.tap(navLabel('Shop'));
    await pumpFor(tester, const Duration(seconds: 1));
    expect(shopTab(tester), ShopTab.skins);

    await goHome(tester);
    await tapCoinPlus(tester);

    expect(find.byType(ShopPage), findsOneWidget);
    expect(shopTab(tester), ShopTab.coins);
    expect(find.byType(ShopClosedCard), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('the coin pill "+" opens Coins again after the player moved '
      'the Shop to another tab (same tab asked twice)', (tester) async {
    await boot(tester);
    await tapCoinPlus(tester);
    expect(shopTab(tester), ShopTab.coins);

    await tester.tap(find.text('Themes'));
    await pumpFor(tester, const Duration(milliseconds: 500));
    expect(shopTab(tester), ShopTab.themes);

    await goHome(tester);
    await tapCoinPlus(tester);

    expect(shopTab(tester), ShopTab.coins);
    expect(tester.takeException(), isNull);
  });

  testWidgets('the bottom nav returns to the Shop on the tab it was left '
      'on', (tester) async {
    await boot(tester);
    await tester.tap(navLabel('Shop'));
    await pumpFor(tester, const Duration(seconds: 1));
    await tester.tap(find.text('Themes'));
    await pumpFor(tester, const Duration(milliseconds: 500));

    await goHome(tester);
    await tester.tap(navLabel('Shop'));
    await pumpFor(tester, const Duration(seconds: 1));

    expect(shopTab(tester), ShopTab.themes);
  });

  testWidgets('an unaffordable Buy on a skin detail opens '
      'NotEnoughCoinsDialog first; its Go to Shop returns to the Shop on '
      'its Coins tab (D112, replaces the FIDELITY-7 direct jump)', (
    tester,
  ) async {
    await boot(tester); // A fresh save: 0 coins.
    await tester.tap(navLabel('Shop'));
    await pumpFor(tester, const Duration(seconds: 1));
    await tester.tap(find.text('Winter'));
    await pumpFor(tester, const Duration(seconds: 1));
    expect(find.byType(SkinDetailPage), findsOneWidget);

    await tester.tap(find.text('Buy'));
    await pumpFor(tester, const Duration(seconds: 1));

    // The dialog opens first: the skin detail page is still underneath.
    expect(find.byType(NotEnoughCoinsDialog), findsOneWidget);
    expect(find.byType(SkinDetailPage), findsOneWidget);

    await tester.tap(find.text('Go to Shop'));
    await pumpFor(tester, const Duration(seconds: 1));

    expect(find.byType(NotEnoughCoinsDialog), findsNothing);
    expect(find.byType(SkinDetailPage), findsNothing);
    expect(find.byType(ShopPage), findsOneWidget);
    expect(shopTab(tester), ShopTab.coins);
    expect(tester.takeException(), isNull);
  });

  testWidgets('the Remove Ads tile opens the Shop on No Ads (m3-design '
      '§10.3), also after a visit', (tester) async {
    await boot(tester);
    await tester.tap(inHome(find.text('Remove Ads')));
    await pumpFor(tester, const Duration(seconds: 1));

    expect(find.byType(ShopPage), findsOneWidget);
    expect(shopTab(tester), ShopTab.noAds);
    expect(find.byType(ShopClosedCard), findsOneWidget);

    await tester.tap(find.text('Skins'));
    await pumpFor(tester, const Duration(milliseconds: 500));
    await goHome(tester);
    await tester.tap(inHome(find.text('Remove Ads')));
    await pumpFor(tester, const Duration(seconds: 1));

    expect(shopTab(tester), ShopTab.noAds);
    expect(tester.takeException(), isNull);
  });
}
