import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_core/nesty_core.dart';
import 'package:nesty_game/core/base/base_async_state.dart';
import 'package:nesty_game/core/repository/catalog_models.dart';
import 'package:nesty_game/core/services/database/database_service.dart';
import 'package:nesty_game/core/services/database/fake_database_service.dart';
import 'package:nesty_game/core/services/skin/fake_skin_service.dart';
import 'package:nesty_game/core/services/skin/skin_service.dart';
import 'package:nesty_game/features/fx/fake_fx_library.dart';
import 'package:nesty_game/features/fx/fx_library.dart';
import 'package:nesty_game/features/shop/cubit/shop_cubit.dart';
import 'package:nesty_game/features/shop/cubit/skin_detail_cubit.dart';
import 'package:nesty_game/features/shop/model/purchase_outcome.dart';
import 'package:nesty_game/features/shop/model/shop_tab.dart';
import 'package:nesty_game/features/shop/pages/shop_page.dart';
import 'package:nesty_game/features/shop/pages/skin_detail_page.dart';

import '../core/ui/support/ui_harness.dart';
import '../features/support/screen_harness.dart';

/// M7 overflow suite (m7-design §18 "overflow"): the Shop's tabs (frames
/// 7.1-7.7) and skin detail (frame 7.4) at the five acceptance sizes and
/// both text scales. Behaviour is covered by `test/features/shop/
/// shop_page_test.dart` and `skin_detail_page_test.dart`; this file only
/// sweeps the wider size/scale grid, over the same worst-case data (the
/// longest tier badge, the highest coin count).
void main() {
  setUpAll(loadBundledFonts);

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
  ];

  const themes = [
    ThemeInfo(id: 'ch01', chapterNumber: 1, priceCoins: 0),
    ThemeInfo(id: 'ch02', chapterNumber: 2, priceCoins: 800),
  ];

  final skinsState = const ShopState(
    tab: ShopTab.skins,
    coins: 1234567,
    skins: skins,
    ownedSkins: ['classic'],
    selectedSkinId: 'classic',
    themes: themes,
    ownedThemes: ['ch01'],
    selectedThemeId: null,
    currentChapterThemeId: 'ch01',
    reachedChapterNumber: 1,
  );

  final themesState = skinsState.copyWith(
    tab: ShopTab.themes,
    selectedThemeId: 'ch02',
    ownedThemes: const ['ch01', 'ch02'],
  );

  final coinsState = skinsState.copyWith(tab: ShopTab.coins);

  Future<void> pumpShop(
    WidgetTester tester,
    ShopState state, {
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
        child: ShopView(
          state: AsyncValue.data(data: state),
          onRetry: () {},
          onBack: () {},
          onTabChanged: (_) {},
          onSkinTap: (_) {},
          onEquipSkin: (_) async => true,
          onBuySkin: (_) async => PurchaseOutcome.bought,
          onSetMatchesChapter: (_) {},
          onUseTheme: (_) {},
          onBuyTheme: (_) async => PurchaseOutcome.bought,
        ),
      ),
      size: size,
      textScale: textScale,
    );
    await tester.pump();
  }

  group('the Shop (frames 7.1-7.7)', () {
    for (final size in overflowScreenSizes) {
      for (final scale in textScales) {
        for (final MapEntry(key: name, value: state) in {
          'Skins': skinsState,
          'Themes': themesState,
          'Coins closed card': coinsState,
        }.entries) {
          testWidgets(
            'fits ${size.width.toInt()}×${size.height.toInt()} at $scale× '
            'text ($name)',
            (tester) async {
              await pumpShop(tester, state, size: size, textScale: scale);
              await expectAccessibleLayout(tester);
            },
          );
        }
      }
    }
  });

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

  Future<void> pumpDetail(
    WidgetTester tester, {
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
          state: const AsyncValue.data(data: oceanAffordable),
          onRetry: () {},
          onBack: () {},
          onBuy: () async => PurchaseOutcome.bought,
          onNeedCoins: () {},
          onEquip: () async => true,
        ),
      ),
      size: size,
      textScale: textScale,
    );
    await tester.pump();
  }

  group('skin detail (frame 7.4)', () {
    for (final size in overflowScreenSizes) {
      for (final scale in textScales) {
        testWidgets(
          'fits ${size.width.toInt()}×${size.height.toInt()} at $scale× text',
          (tester) async {
            await pumpDetail(tester, size: size, textScale: scale);
            await expectAccessibleLayout(tester);
          },
        );
      }
    }
  });
}
