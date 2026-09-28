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
import 'package:nesty_game/features/fx/fx_spinner.dart';
import 'package:nesty_game/features/shop/cubit/shop_cubit.dart';
import 'package:nesty_game/features/shop/model/shop_tab.dart';
import 'package:nesty_game/features/shop/pages/shop_page.dart';
import 'package:nesty_game/features/shop/widgets/shop_closed_card.dart';
import 'package:nesty_game/features/shop/widgets/skin_doll_row.dart';
import 'package:nesty_game/features/shop/widgets/skin_grid_card.dart';
import 'package:nesty_game/features/shop/widgets/theme_grid_card.dart';

import '../../core/ui/support/ui_harness.dart';
import '../support/controlled_skin_service.dart';
import '../support/screen_harness.dart';

/// Frames 7.1–7.7 (docs/plans/m3-design.md §10.7): the Shop's tabs, the
/// Coins/No Ads store-closed card, the Skins grid and the Themes grid.
void main() {
  setUpAll(() async {
    await loadBundledFonts();
  });

  const skins = [
    SkinInfo(
      id: 'classic',
      priceCoins: 0,
      previewColors: [DollColor.red, DollColor.yellow, DollColor.blue],
    ),
    SkinInfo(
      id: 'space',
      priceCoins: 1200,
      previewColors: [DollColor.navy, DollColor.purple, DollColor.teal],
    ),
    SkinInfo(
      id: 'ocean',
      priceCoins: 800,
      previewColors: [DollColor.teal, DollColor.blue, DollColor.navy],
    ),
  ];

  const themes = [
    ThemeInfo(id: 'ch01', chapterNumber: 1, priceCoins: 0),
    ThemeInfo(id: 'ch02', chapterNumber: 2, priceCoins: 800),
    ThemeInfo(id: 'ch04', chapterNumber: 4, priceCoins: 1200),
  ];

  ShopState skinsState({int coins = 100, String selectedSkinId = 'classic'}) =>
      ShopState(
        tab: ShopTab.skins,
        coins: coins,
        skins: skins,
        ownedSkins: const ['classic', 'space'],
        selectedSkinId: selectedSkinId,
        themes: themes,
        ownedThemes: const ['ch01'],
        selectedThemeId: null,
        currentChapterThemeId: 'ch01',
        reachedChapterNumber: 1,
      );

  ShopState themesState({String? selectedThemeId}) => ShopState(
    tab: ShopTab.themes,
    coins: 100,
    skins: skins,
    ownedSkins: const ['classic'],
    selectedSkinId: 'classic',
    themes: themes,
    ownedThemes: const ['ch01', 'ch02'],
    selectedThemeId: selectedThemeId,
    currentChapterThemeId: 'ch02',
    reachedChapterNumber: 2,
  );

  Future<void> pumpShop(
    WidgetTester tester, {
    required AsyncValue<ShopState> state,
    VoidCallback? onRetry,
    VoidCallback? onBack,
    ValueChanged<ShopTab>? onTabChanged,
    ValueChanged<String>? onSkinTap,
    Future<bool> Function(String)? onEquipSkin,
    Future<bool> Function(String)? onBuySkin,
    ValueChanged<bool>? onSetMatchesChapter,
    ValueChanged<String>? onUseTheme,
    Future<bool> Function(String)? onBuyTheme,
    Size size = const Size(390, 844),
    double textScale = 1,
    SkinService? skinService,
  }) async {
    await pumpScreen(
      tester,
      MultiRepositoryProvider(
        providers: [
          RepositoryProvider<SkinService>.value(
            value: skinService ?? FakeSkinService(),
          ),
          RepositoryProvider<DatabaseService>.value(
            value: FakeDatabaseService(),
          ),
          RepositoryProvider<FxLibrary>.value(value: FakeFxLibrary()),
        ],
        child: ShopView(
          state: state,
          onRetry: onRetry ?? () {},
          onBack: onBack ?? () {},
          onTabChanged: onTabChanged ?? (_) {},
          onSkinTap: onSkinTap ?? (_) {},
          onEquipSkin: onEquipSkin ?? (_) async => true,
          onBuySkin: onBuySkin ?? (_) async => true,
          onSetMatchesChapter: onSetMatchesChapter ?? (_) {},
          onUseTheme: onUseTheme ?? (_) {},
          onBuyTheme: onBuyTheme ?? (_) async => true,
        ),
      ),
      size: size,
      textScale: textScale,
    );
    await tester.pump();
  }

  testWidgets('the header, coin pill and every tab label', (tester) async {
    await pumpShop(tester, state: AsyncValue.data(data: skinsState()));
    expect(find.text('Shop'), findsOneWidget);
    expect(find.text('100'), findsOneWidget);
    expect(find.text('Coins'), findsOneWidget);
    expect(find.text('Skins'), findsOneWidget);
    expect(find.text('Themes'), findsOneWidget);
    expect(find.text('No Ads'), findsOneWidget);
  });

  testWidgets('the back arrow returns to Home', (tester) async {
    var backs = 0;
    await pumpShop(
      tester,
      state: AsyncValue.data(data: skinsState()),
      onBack: () => backs++,
    );
    expect(find.bySemanticsLabel('Back'), findsOneWidget);
    await tester.tap(find.bySemanticsLabel('Back'));
    await tester.pump(const Duration(milliseconds: 200));
    expect(backs, 1);
  });

  testWidgets('a failed load offers a retry', (tester) async {
    var retries = 0;
    await pumpShop(
      tester,
      state: const AsyncValue.error(
        exception: AppException(AppExceptionKind.content, message: 'bundle'),
      ),
      onRetry: () => retries++,
    );
    expect(find.text('Try again'), findsOneWidget);
    await tester.tap(find.text('Try again'));
    await tester.pump(const Duration(milliseconds: 200));
    expect(retries, 1);
  });

  group('tab selection', () {
    testWidgets('tapping a tab asks for it', (tester) async {
      final tabs = <ShopTab>[];
      await pumpShop(
        tester,
        state: AsyncValue.data(data: skinsState()),
        onTabChanged: tabs.add,
      );
      await tester.tap(find.text('Themes'));
      await tester.pump(const Duration(milliseconds: 200));
      expect(tabs, [ShopTab.themes]);
    });

    testWidgets('Coins shows the store-closed card', (tester) async {
      await pumpShop(
        tester,
        state: AsyncValue.data(data: skinsState().copyWith(tab: ShopTab.coins)),
      );
      expect(find.byType(ShopClosedCard), findsOneWidget);
      expect(find.text('The store is closed for now'), findsOneWidget);
      expect(
        find.text('Coin packs and Remove Ads come in a later update.'),
        findsOneWidget,
      );
      expect(find.byType(SkinGridCard), findsNothing);
    });

    testWidgets('No Ads shows the same store-closed card', (tester) async {
      await pumpShop(
        tester,
        state: AsyncValue.data(data: skinsState().copyWith(tab: ShopTab.noAds)),
      );
      expect(find.byType(ShopClosedCard), findsOneWidget);
    });
  });

  group('Skins tab', () {
    testWidgets('a card shows the spinner until its skin art arrives, never '
        'the placeholder dolls first; the placeholder only when the art '
        "can't be prepared", (tester) async {
      final skinService = ControlledSkinService();
      await pumpShop(
        tester,
        state: AsyncValue.data(data: skinsState()),
        skinService: skinService,
      );
      Finder inCard(int i, Type type) => find.descendant(
        of: find.byType(SkinGridCard).at(i),
        matching: find.byType(type),
      );
      expect(skinService.showcaseRequests, hasLength(skins.length));
      for (var i = 0; i < skins.length; i++) {
        expect(inCard(i, FxSpinner), findsOneWidget, reason: 'card $i');
        expect(inCard(i, SkinDollRow), findsNothing, reason: 'card $i');
      }

      skinService.completeShowcase(0);
      skinService.failShowcase(1);
      await tester.pump();
      expect(inCard(0, SkinDollRow), findsOneWidget);
      expect(inCard(0, FxSpinner), findsNothing);
      // Failed: the placeholder dolls (a row without art), no spinner.
      expect(inCard(1, SkinDollRow), findsOneWidget);
      expect(tester.widget<SkinDollRow>(inCard(1, SkinDollRow)).skin, isNull);
      expect(inCard(2, FxSpinner), findsOneWidget);
    });

    testWidgets('one card per sold skin, in catalog order', (tester) async {
      await pumpShop(tester, state: AsyncValue.data(data: skinsState()));
      expect(find.byType(SkinGridCard), findsNWidgets(3));
      expect(find.text('Classic'), findsOneWidget);
      expect(find.text('Space'), findsOneWidget);
      expect(find.text('Ocean'), findsOneWidget);
    });

    testWidgets('the equipped skin shows Equipped, not Equip or a price', (
      tester,
    ) async {
      await pumpShop(tester, state: AsyncValue.data(data: skinsState()));
      expect(find.text('Equipped'), findsOneWidget);
      expect(find.text('Equip'), findsOneWidget); // space: owned, not equipped
      expect(find.text('800 coins'), findsOneWidget); // ocean's price
    });

    testWidgets('tapping the card (not its button) opens its detail', (
      tester,
    ) async {
      final tapped = <String>[];
      await pumpShop(
        tester,
        state: AsyncValue.data(data: skinsState()),
        onSkinTap: tapped.add,
      );
      // The classic card's name label sits over its background, not its
      // footer button.
      await tester.tap(find.text('Classic'));
      await tester.pump(const Duration(milliseconds: 200));
      expect(tapped, ['classic']);
    });

    testWidgets('Equip equips without opening the detail', (tester) async {
      final tapped = <String>[];
      final equipped = <String>[];
      await pumpShop(
        tester,
        state: AsyncValue.data(data: skinsState()),
        onSkinTap: tapped.add,
        onEquipSkin: (id) async {
          equipped.add(id);
          return true;
        },
      );
      await tester.tap(find.text('Equip'));
      await tester.pump(const Duration(milliseconds: 200));
      expect(equipped, ['space']);
      expect(tapped, isEmpty, reason: 'the footer button, not the card, wins');
    });

    testWidgets('an unaffordable price stays orange and still asks, so the '
        'cubit can open the Coins tab (frame 7.3, like 7.7; FIDELITY-7)', (
      tester,
    ) async {
      final bought = <String>[];
      await pumpShop(
        tester,
        state: AsyncValue.data(data: skinsState(coins: 0)),
        onBuySkin: (id) async {
          bought.add(id);
          return false;
        },
      );
      final button = tester.widget<CoinPriceButton>(
        find.byType(CoinPriceButton),
      );
      expect(button.onPressed, isNotNull);
      await tester.tap(find.byType(CoinPriceButton));
      await tester.pump(const Duration(milliseconds: 200));
      expect(bought, ['ocean']);
    });

    testWidgets('an affordable price buys', (tester) async {
      final bought = <String>[];
      await pumpShop(
        tester,
        state: AsyncValue.data(data: skinsState(coins: 5000)),
        onBuySkin: (id) async {
          bought.add(id);
          return true;
        },
      );
      final button = tester.widget<CoinPriceButton>(
        find.byType(CoinPriceButton),
      );
      expect(button.onPressed, isNotNull);
      await tester.tap(find.byType(CoinPriceButton));
      await tester.pump(const Duration(milliseconds: 200));
      expect(bought, ['ocean']);
      // Lets the purchase twinkle burst's own timer finish and remove
      // itself, so no timer is left pending when the test tears down.
      await tester.pump(const Duration(milliseconds: 2300));
    });
  });

  group('Themes tab', () {
    testWidgets('the toggle reflects "Match each chapter"', (tester) async {
      await pumpShop(
        tester,
        state: AsyncValue.data(data: themesState(selectedThemeId: null)),
      );
      final toggle = tester.widget<NestyToggle>(find.byType(NestyToggle));
      expect(toggle.value, isTrue);
      expect(find.text('Match each chapter'), findsOneWidget);
    });

    testWidgets('toggling it off asks for false', (tester) async {
      final values = <bool>[];
      await pumpShop(
        tester,
        state: AsyncValue.data(data: themesState()),
        onSetMatchesChapter: values.add,
      );
      await tester.tap(find.byType(NestyToggle));
      await tester.pump(const Duration(milliseconds: 200));
      expect(values, [false]);
    });

    testWidgets('In use / Use / a locked price, per theme', (tester) async {
      await pumpShop(
        tester,
        state: AsyncValue.data(data: themesState(selectedThemeId: 'ch02')),
      );
      expect(find.text('In use'), findsOneWidget); // ch02
      expect(find.text('Use'), findsOneWidget); // ch01, owned
      expect(find.text('1,200 coins'), findsOneWidget); // ch04's locked price
      expect(find.byType(ThemeGridCard), findsNWidgets(3));
    });

    testWidgets('with "Match each chapter" on, the current chapter\'s theme '
        'is the one in use (frame 7.7; FIDELITY-3)', (tester) async {
      await pumpShop(
        tester,
        // currentChapterThemeId: ch02.
        state: AsyncValue.data(data: themesState(selectedThemeId: null)),
      );
      final cards = tester
          .widgetList<ThemeGridCard>(find.byType(ThemeGridCard))
          .toList();
      expect(
        {for (final c in cards) c.theme.id: c.inUse},
        {'ch01': false, 'ch02': true, 'ch04': false},
      );
      expect(find.text('In use'), findsOneWidget); // ch02
      expect(find.text('Use'), findsOneWidget); // ch01
    });

    testWidgets('Use selects the theme', (tester) async {
      final used = <String>[];
      await pumpShop(
        tester,
        state: AsyncValue.data(data: themesState(selectedThemeId: 'ch02')),
        onUseTheme: used.add,
      );
      await tester.tap(find.text('Use'));
      await tester.pump(const Duration(milliseconds: 200));
      expect(used, ['ch01']);
    });

    testWidgets('the locked price buys it', (tester) async {
      final bought = <String>[];
      await pumpShop(
        tester,
        state: AsyncValue.data(data: themesState(selectedThemeId: 'ch02')),
        onBuyTheme: (id) async {
          bought.add(id);
          return true;
        },
      );
      await tester.tap(find.text('1,200 coins'));
      await tester.pump(const Duration(milliseconds: 200));
      expect(bought, ['ch04']);
      // Lets the purchase twinkle burst's own timer finish and remove
      // itself, so no timer is left pending when the test tears down.
      await tester.pump(const Duration(milliseconds: 2300));
    });
  });

  for (final size in screenSizes) {
    for (final scale in textScales) {
      testWidgets(
        'fits ${size.width.toInt()}×${size.height.toInt()} at $scale× text '
        '(Skins)',
        (tester) async {
          await pumpShop(
            tester,
            state: AsyncValue.data(data: skinsState(coins: 1234567)),
            size: size,
            textScale: scale,
          );
          expectNoLayoutErrors(tester);
        },
      );

      testWidgets(
        'fits ${size.width.toInt()}×${size.height.toInt()} at $scale× text '
        '(Themes)',
        (tester) async {
          await pumpShop(
            tester,
            state: AsyncValue.data(data: themesState(selectedThemeId: 'ch02')),
            size: size,
            textScale: scale,
          );
          expectNoLayoutErrors(tester);
        },
      );

      testWidgets(
        'fits ${size.width.toInt()}×${size.height.toInt()} at $scale× text '
        '(Coins closed card)',
        (tester) async {
          await pumpShop(
            tester,
            state: AsyncValue.data(
              data: skinsState().copyWith(tab: ShopTab.coins),
            ),
            size: size,
            textScale: scale,
          );
          expectNoLayoutErrors(tester);
        },
      );
    }
  }
}
