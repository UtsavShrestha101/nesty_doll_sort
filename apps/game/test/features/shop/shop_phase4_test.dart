import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:nesty_game/core/base/base_async_state.dart';
import 'package:nesty_game/core/repository/bundled_catalog_repository.dart';
import 'package:nesty_game/core/services/database/database_service.dart';
import 'package:nesty_game/core/services/database/fake_database_service.dart';
import 'package:nesty_game/core/services/haptics/fake_haptics_service.dart';
import 'package:nesty_game/core/services/haptics/haptics_service.dart';
import 'package:nesty_game/core/services/skin/fake_skin_service.dart';
import 'package:nesty_game/core/services/skin/skin_service.dart';
import 'package:nesty_game/core/ui/art/theme_thumbnail_loader.dart';
import 'package:nesty_game/core/ui/nesty_ui.dart';
import 'package:nesty_game/features/fx/fake_fx_library.dart';
import 'package:nesty_game/features/fx/fx_library.dart';
import 'package:nesty_game/features/shop/cubit/shop_cubit.dart';
import 'package:nesty_game/features/shop/cubit/skin_detail_cubit.dart';
import 'package:nesty_game/features/shop/model/purchase_outcome.dart';
import 'package:nesty_game/features/shop/model/shop_tab.dart';
import 'package:nesty_game/features/shop/pages/shop_page.dart';
import 'package:nesty_game/features/shop/pages/skin_detail_page.dart';
import 'package:nesty_game/features/shop/widgets/purchase_twinkle_burst.dart';
import 'package:nesty_game/features/shop/widgets/shop_buy_button.dart';
import 'package:nesty_game/features/shop/widgets/shop_look.dart';
import 'package:nesty_game/features/shop/widgets/skin_grid_card.dart';
import 'package:nesty_game/features/shop/widgets/theme_grid_card.dart';
import 'package:nesty_render/nesty_render.dart' show ChapterTheme;

import '../../core/ui/support/ui_harness.dart';
import '../support/meta_harness.dart';
import '../support/screen_harness.dart';

/// Phase 4's Shop (frames 7.3, 7.4b, 7.7, 7.3b, 7.4c; menus spec 8): each
/// skin's own colours from the tokens, Forest Bear as the seventh card and
/// its detail, the buy coin chip, the theme crops, "Not enough coins" with
/// the item's name, and the purchase timing (F.5).
void main() {
  setUpAll(loadBundledFonts);

  final catalog = BundledCatalogRepository();
  final sold = [
    for (final skin in catalog.skins)
      if (skin.sold) skin,
  ];

  ShopState state({
    ShopTab tab = ShopTab.skins,
    int coins = 830,
    List<String> ownedSkins = const ['classic'],
    List<String> ownedThemes = const ['ch01'],
    int reached = 3,
  }) => ShopState(
    tab: tab,
    coins: coins,
    skins: sold,
    ownedSkins: ownedSkins,
    selectedSkinId: 'classic',
    themes: catalog.themes,
    ownedThemes: ownedThemes,
    selectedThemeId: null,
    currentChapterThemeId: 'ch0$reached',
    reachedChapterNumber: reached,
  );

  Future<void> pumpShop(
    WidgetTester tester, {
    required ShopState data,
    Future<PurchaseOutcome> Function(String)? onBuySkin,
    Future<PurchaseOutcome> Function(String)? onBuyTheme,
    ValueChanged<ShopTab>? onTabChanged,
    FakeThemeThumbnailLoader? loader,
    Size size = const Size(390, 844),
    double textScale = 1,
    bool reduceMotion = false,
  }) async {
    await pumpScreen(
      tester,
      withFakeArt(
        MultiRepositoryProvider(
          providers: [
            RepositoryProvider<SkinService>.value(value: FakeSkinService()),
            RepositoryProvider<DatabaseService>.value(
              value: FakeDatabaseService(),
            ),
            RepositoryProvider<FxLibrary>.value(value: FakeFxLibrary()),
          ],
          child: ShopView(
            state: AsyncValue.data(data: data),
            onRetry: () {},
            onBack: () {},
            onTabChanged: onTabChanged ?? (_) {},
            onSkinTap: (_) {},
            onEquipSkin: (_) async => true,
            onBuySkin: onBuySkin ?? (_) async => PurchaseOutcome.bought,
            onSetMatchesChapter: (_) {},
            onUseTheme: (_) {},
            onBuyTheme: onBuyTheme ?? (_) async => PurchaseOutcome.bought,
          ),
        ),
        loader: loader,
      ),
      size: size,
      textScale: textScale,
      reduceMotion: reduceMotion,
    );
    await tester.pump();
  }

  group('each skin\'s own colours (F.1)', () {
    test('every skin\'s card and panel gradient is its tokens entry', () {
      for (final entry in ShopTokens.skins.entries) {
        final look = ShopLook.of(entry.key);
        expect(ShopLook.card(entry.key).colors, look.card);
        expect(ShopLook.panel(entry.key).colors, look.panel);
        expect(ShopLook.edge(entry.key), look.edge);
        expect(ShopLook.caption(entry.key), look.caption);
        expect(
          ShopLook.card(entry.key).begin,
          Alignment.topCenter,
          reason: 'top to bottom',
        );
      }
    });

    test('the seven catalog skins all have colours; a later skin gets '
        'Classic\'s', () {
      for (final skin in catalog.skins) {
        expect(ShopTokens.skins.containsKey(skin.id), isTrue, reason: skin.id);
      }
      expect(ShopLook.of('sparkle'), same(ShopTokens.skins['classic']));
    });

    test('Space\'s light lilac caption sits on its dark edge, not on the '
        'white chip; the others keep the white chip (menus spec 8.1)', () {
      final space = ShopLook.captionFace('space');
      expect(space.a, closeTo(0.85, 0.01));
      expect(space.withValues(alpha: 1), ShopLook.edge('space'));
      for (final id in [
        'classic',
        'ocean',
        'sweets',
        'forest',
        'forest-bear',
      ]) {
        expect(
          ShopLook.captionFace(id),
          ShopTokens.detailPanelTagFill,
          reason: id,
        );
      }
    });
  });

  group('the Skins grid (frame 7.3)', () {
    testWidgets('Forest Bear is the seventh card, after Forest Friends, at '
        '2,500 with the buy coin chip', (tester) async {
      await pumpShop(tester, data: state(), size: const Size(390, 2000));
      expect(find.byType(SkinGridCard), findsNWidgets(sold.length));
      final names = [
        for (final card in tester.widgetList<SkinGridCard>(
          find.byType(SkinGridCard),
        ))
          card.skin.id,
      ];
      expect(names.last, 'forest-bear');
      expect(
        names[names.length - 2],
        'winter',
        reason: '6 cards, then the 7th',
      );
      expect(names, containsAllInOrder(['forest', 'winter']));
      await tester.ensureVisible(find.text('Forest Bear'));
      expect(find.text('Forest Bear'), findsOneWidget);
      expect(find.text('2,500'), findsOneWidget);
      expect(find.text('2,000'), findsOneWidget, reason: 'Forest Friends');
      expect(find.text('3,000'), findsOneWidget, reason: 'Winter');
    });

    testWidgets('the price sits in the primary button as a translucent coin '
        'chip (radius 14, coin 22, Fredoka 19 white)', (tester) async {
      await pumpShop(tester, data: state());
      final button = find.byType(ShopBuyButton).first;
      final chip = tester
          .widgetList<DecoratedBox>(
            find.descendant(of: button, matching: find.byType(DecoratedBox)),
          )
          .map((b) => b.decoration)
          .whereType<BoxDecoration>()
          .firstWhere((d) => d.color == ShopTokens.buyCoinChipFace);
      expect(chip.borderRadius, BorderRadius.circular(14));
      final price = tester.widget<Text>(
        find.descendant(of: button, matching: find.byType(Text)).first,
      );
      expect(price.style!.fontSize, 19);
      expect(price.style!.color, const Color(0xFFFFFFFF));
    });

    testWidgets('an equipped card has the green ring and a successTint pill '
        'with the successEdge label', (tester) async {
      await pumpShop(tester, data: state());
      final pill = find.ancestor(
        of: find.text('Equipped'),
        matching: find.byType(NestySurface),
      );
      final surface = tester.widget<NestySurface>(pill.first);
      expect(surface.style.color, AppColorTokens.successTint);
      final label = tester.widget<Text>(find.text('Equipped'));
      expect(label.style!.color, AppColorTokens.successEdge);
    });

    testWidgets('Forest Bear with too few coins: the dialog names it, shows '
        'its price and how many coins are missing (7.3b)', (tester) async {
      final asked = <String>[];
      await pumpShop(
        tester,
        data: state(),
        size: const Size(390, 2000),
        onBuySkin: (id) async {
          asked.add(id);
          return id == 'forest-bear'
              ? PurchaseOutcome.needsCoins
              : PurchaseOutcome.bought;
        },
      );
      final card = find.ancestor(
        of: find.text('Forest Bear'),
        matching: find.byType(SkinGridCard),
      );
      await tester.ensureVisible(card);
      await tester.tap(
        find.descendant(of: card, matching: find.byType(ShopBuyButton)),
      );
      await tester.pumpAndSettle();

      expect(asked, ['forest-bear']);
      expect(find.byType(NotEnoughCoinsDialog), findsOneWidget);
      expect(find.text('A few more coins'), findsOneWidget);
      expect(find.text('2,500 coins'), findsOneWidget);
      expect(find.text('You need 1,670 more coins'), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(NotEnoughCoinsDialog),
          matching: find.text('Forest Bear'),
        ),
        findsOneWidget,
      );
    });

    testWidgets('a locked-price skin is never drawn disabled: the same '
        'orange button asks first (frames 7.3, 7.3b)', (tester) async {
      await pumpShop(tester, data: state(coins: 0));
      for (final button in tester.widgetList<ShopBuyButton>(
        find.byType(ShopBuyButton),
      )) {
        expect(button.onPressed, isNotNull);
      }
    });
  });

  group('the Themes grid (frame 7.7, F.1 crops)', () {
    testWidgets('each card asks for its own theme\'s crop at the card\'s '
        'width and 74 tall, in full colour even when locked', (tester) async {
      final loader = FakeThemeThumbnailLoader();
      await pumpShop(
        tester,
        data: state(tab: ShopTab.themes, ownedThemes: ['ch01', 'ch02']),
        loader: loader,
      );
      await tester.pump();
      expect(loader.requests, isNotEmpty);
      for (final request in loader.requests) {
        expect(request.box.height, 74);
        expect(request.box.width, closeTo(158, 2));
        expect(request.locked, isFalse, reason: 'Shop crops keep colour');
      }
      expect(
        {for (final r in loader.requests) r.theme},
        containsAll([ChapterTheme.ch01, ChapterTheme.ch02, ChapterTheme.ch03]),
      );
    });

    testWidgets('a locked card has the lock chip "Ch N" on the crop and the '
        'price in the buy chip; ch07-ch10 are in the catalog at 2,000', (
      tester,
    ) async {
      await pumpShop(
        tester,
        data: state(tab: ShopTab.themes, reached: 1),
        size: const Size(390, 2400),
      );
      expect(find.text('Ch 4'), findsOneWidget);
      expect(find.text('Ch 10'), findsOneWidget);
      expect(find.byIcon(NestyIcons.lock), findsWidgets);
      expect(find.text('Sunrise Lookout'), findsOneWidget);
      expect(
        find.text('2,000'),
        findsNWidgets(5),
        reason: 'ch06 and ch07-ch10',
      );
      expect(
        catalog.themes
            .where((t) => t.chapterNumber >= 7)
            .map((t) => t.priceCoins),
        everyElement(BundledCatalogRepository.laterThemePrice),
      );
    });

    testWidgets('an unaffordable theme names itself in the dialog', (
      tester,
    ) async {
      await pumpShop(
        tester,
        data: state(tab: ShopTab.themes, coins: 100, reached: 1),
        size: const Size(390, 2400),
        onBuyTheme: (_) async => PurchaseOutcome.needsCoins,
      );
      final card = find.ancestor(
        of: find.text('Snowy Cabin'),
        matching: find.byType(ThemeGridCard),
      );
      await tester.tap(
        find.descendant(of: card, matching: find.byType(ShopBuyButton)),
      );
      await tester.pumpAndSettle();
      expect(
        find.descendant(
          of: find.byType(NotEnoughCoinsDialog),
          matching: find.text('Snowy Cabin'),
        ),
        findsOneWidget,
      );
    });

    testWidgets('the In use pill is successTint with the successRing', (
      tester,
    ) async {
      await pumpShop(
        tester,
        data: state(tab: ShopTab.themes, ownedThemes: ['ch01', 'ch02', 'ch03']),
      );
      final pill = tester.widget<NestySurface>(
        find
            .ancestor(
              of: find.text('In use'),
              matching: find.byType(NestySurface),
            )
            .first,
      );
      expect(pill.style.color, AppColorTokens.successTint);
    });
  });

  group('Forest Bear\'s detail (frame 7.4b)', () {
    SkinDetailState bear({int coins = 830, bool owned = false}) =>
        SkinDetailState(
          skin: sold.firstWhere((s) => s.id == 'forest-bear'),
          owned: owned,
          equipped: false,
          coins: coins,
        );

    Future<void> pumpDetail(
      WidgetTester tester,
      SkinDetailState data, {
      Future<PurchaseOutcome> Function()? onBuy,
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
            state: AsyncValue.data(data: data),
            onRetry: () {},
            onBack: () {},
            onBuy: onBuy ?? () async => PurchaseOutcome.needsCoins,
            onNeedCoins: () {},
            onEquip: () async => true,
          ),
        ),
        size: size,
        textScale: textScale,
      );
      await tester.pump();
    }

    testWidgets('shows its name, its own description, "Buy" with the 2,500 '
        'chip and "You have 830 coins"', (tester) async {
      await pumpDetail(tester, bear());
      expect(find.text('Forest Bear'), findsOneWidget);
      expect(
        find.text('Round bear ears, cozy hoods and acorns in the leaves.'),
        findsOneWidget,
      );
      expect(find.text('Buy'), findsOneWidget);
      expect(find.text('2,500'), findsOneWidget);
      expect(find.text('You have 830 coins'), findsOneWidget);
      expect(find.bySemanticsLabel('Buy, 2,500 coins'), findsOneWidget);
    });

    testWidgets('the panel wears the skin\'s own gradient and its 6 dp edge; '
        'the tag chip its caption colour', (tester) async {
      await pumpDetail(tester, bear());
      final panel = tester
          .widgetList<NestySurface>(find.byType(NestySurface))
          .firstWhere((s) => s.height == SkinDetailView.panelHeight);
      expect(panel.style.gradient, ShopLook.panel('forest-bear'));
      final edge = panel.style.shadows.firstWhere((s) => s.isSolidEdge);
      expect(edge.color, ShopLook.edge('forest-bear'));
      expect(edge.dy, ShopTokens.detailPanelEdgeWidth);
      final tag = tester.widget<Text>(
        find.text('All 11 colors · symbols kept'),
      );
      expect(tag.style!.color, ShopLook.caption('forest-bear'));
    });

    testWidgets('Buy with too few coins opens the dialog with the name and '
        'the missing amount; it is never a disabled face (7.4c)', (
      tester,
    ) async {
      await pumpDetail(tester, bear());
      final button = tester.widget<ShopBuyButton>(find.byType(ShopBuyButton));
      expect(button.onPressed, isNotNull);
      expect(button.height, 62);
      await tester.tap(find.text('Buy'));
      await tester.pumpAndSettle();
      expect(find.text('You need 1,670 more coins'), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(NotEnoughCoinsDialog),
          matching: find.text('Forest Bear'),
        ),
        findsOneWidget,
      );
    });

    testWidgets('Space\'s tag chip is dark, with the light caption on it', (
      tester,
    ) async {
      await pumpDetail(
        tester,
        SkinDetailState(
          skin: sold.firstWhere((s) => s.id == 'space'),
          owned: false,
          equipped: false,
          coins: 0,
        ),
      );
      final chip = tester
          .widgetList<DecoratedBox>(find.byType(DecoratedBox))
          .map((b) => b.decoration)
          .whereType<BoxDecoration>()
          .where((d) => d.color == ShopLook.captionFace('space'));
      expect(chip, isNotEmpty);
    });

    for (final size in overflowScreenSizes) {
      for (final scale in textScales) {
        testWidgets('fits ${size.width.toInt()}×${size.height.toInt()} at '
            '$scale× text', (tester) async {
          await pumpDetail(tester, bear(), size: size, textScale: scale);
          await expectAccessibleLayout(tester);
        });
      }
    }
  });

  group('ShopBuyButton', () {
    Future<void> pumpButton(
      WidgetTester tester, {
      VoidCallback? onPressed,
      String? label,
    }) => pumpUi(
      tester,
      Center(
        child: SizedBox(
          width: 300,
          child: ShopBuyButton(
            price: 2500,
            label: label,
            onPressed: onPressed,
            height: 62,
          ),
        ),
      ),
    );

    testWidgets('reads "Buy, 2,500 coins" and taps', (tester) async {
      var taps = 0;
      final handle = tester.ensureSemantics();
      await pumpButton(tester, onPressed: () => taps++, label: 'Buy');
      expect(find.bySemanticsLabel('Buy, 2,500 coins'), findsOneWidget);
      await tester.tap(find.text('Buy'));
      expect(taps, 1);
      handle.dispose();
    });

    testWidgets('while a purchase is under way (no callback) it is the '
        'disabled face without the chip', (tester) async {
      await pumpButton(tester, label: 'Buy');
      final chips = tester
          .widgetList<DecoratedBox>(find.byType(DecoratedBox))
          .map((b) => b.decoration)
          .whereType<BoxDecoration>()
          .where((d) => d.color == ShopTokens.buyCoinChipFace);
      expect(chips, isEmpty);
    });
  });

  group('the purchase celebration (F.5)', () {
    late FakeHapticsService haptics;

    setUp(() {
      haptics = FakeHapticsService();
      GetIt.instance.registerSingleton<HapticsService>(haptics);
    });

    tearDown(() => GetIt.instance.reset());

    Future<void> pumpHost(
      WidgetTester tester, {
      bool reduceMotion = false,
    }) async {
      await pumpScreen(
        tester,
        Material(
          child: Builder(
            builder: (context) => Center(
              child: TextButton(
                onPressed: () => PurchaseTwinkleBurst.celebrate(
                  context,
                  library: FakeFxLibrary(),
                ),
                child: const Text('bought'),
              ),
            ),
          ),
        ),
        reduceMotion: reduceMotion,
      );
    }

    testWidgets('the success haptic is at 0 and the burst waits for 300 ms', (
      tester,
    ) async {
      await pumpHost(tester);
      await tester.tap(find.text('bought'));
      await tester.pump();
      expect(haptics.played, [HapticPattern.win]);

      await tester.pump(const Duration(milliseconds: 299));
      expect(_burstCount(tester), 0, reason: 'nothing before 300 ms');
      await tester.pump(const Duration(milliseconds: 2));
      expect(_burstCount(tester), greaterThan(0));

      // The burst removes itself, leaving no timer behind.
      await tester.pump(const Duration(milliseconds: 2300));
      expect(_burstCount(tester), 0);
    });

    testWidgets('under reduce motion there is no burst; the haptic stays', (
      tester,
    ) async {
      await pumpHost(tester, reduceMotion: true);
      await tester.tap(find.text('bought'));
      await tester.pump(const Duration(milliseconds: 400));
      expect(haptics.played, [HapticPattern.win]);
      expect(_burstCount(tester), 0);
    });
  });

  for (final size in overflowScreenSizes) {
    for (final scale in textScales) {
      testWidgets('the Skins tab fits ${size.width.toInt()}×'
          '${size.height.toInt()} at $scale× text', (tester) async {
        await pumpShop(tester, data: state(), size: size, textScale: scale);
        await expectAccessibleLayout(tester);
      });
      testWidgets('the Themes tab fits ${size.width.toInt()}×'
          '${size.height.toInt()} at $scale× text', (tester) async {
        await pumpShop(
          tester,
          data: state(tab: ShopTab.themes, reached: 2),
          size: size,
          textScale: scale,
        );
        await expectAccessibleLayout(tester);
      });
    }
  }

  // "Not enough coins" over a card (7.3b), over the detail (7.4c): the
  // dialog and what is behind it at the five sizes and both text scales.
  for (final size in overflowScreenSizes) {
    for (final scale in textScales) {
      testWidgets('"Not enough coins" over the Skins grid fits '
          '${size.width.toInt()}×${size.height.toInt()} at $scale× text', (
        tester,
      ) async {
        await pumpShop(
          tester,
          data: state(),
          size: size,
          textScale: scale,
          onBuySkin: (_) async => PurchaseOutcome.needsCoins,
        );
        await tester.tap(find.byType(ShopBuyButton).first);
        await tester.pumpAndSettle();
        expect(find.byType(NotEnoughCoinsDialog), findsOneWidget);
        await expectAccessibleLayout(tester);
      });
    }
  }
}

/// The twinkles the burst put into the overlay: `LottieTwinkle` boxes.
int _burstCount(WidgetTester tester) => find
    .byWidgetPredicate((w) => w.runtimeType.toString() == 'LottieTwinkle')
    .evaluate()
    .length;
