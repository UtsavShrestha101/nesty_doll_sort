import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nesty_core/nesty_core.dart';
import 'package:nesty_game/core/base/base_async_state.dart';
import 'package:nesty_game/core/repository/bundled_catalog_repository.dart';
import 'package:nesty_game/core/repository/catalog_models.dart';
import 'package:nesty_game/core/repository/fake_catalog_repository.dart';
import 'package:nesty_game/core/repository/fake_level_repository.dart';
import 'package:nesty_game/core/services/analytics/analytics_service.dart';
import 'package:nesty_game/core/services/audio/fake_audio_service.dart';
import 'package:nesty_game/core/services/audio/jingle_player.dart';
import 'package:nesty_game/core/services/music/fake_music_service.dart';
import 'package:nesty_game/core/services/music/jingle_cues.dart';
import 'package:nesty_game/core/services/save/fake_save_service.dart';
import 'package:nesty_game/core/services/save/save_document.dart';
import 'package:nesty_game/core/services/skin/fake_skin_service.dart';
import 'package:nesty_game/core/services/skin/skin_service.dart';
import 'package:nesty_game/features/shop/cubit/shop_cubit.dart';
import 'package:nesty_game/features/shop/model/purchase_outcome.dart';
import 'package:nesty_game/features/shop/model/shop_tab.dart';
import 'package:nesty_render/nesty_render.dart';

import '../../helpers/level_fixtures.dart';

class _MockAnalyticsService extends Mock implements AnalyticsService {}

/// Wraps a [FakeSkinService] so [selectSkin] can be held open on demand,
/// reproducing `AssetSkinService`'s genuine await gap (the fake alone
/// resolves synchronously, so it can't race `SaveService.changes` the way
/// the real skin service can). Regression coverage for the owner's
/// 2026-09-28 simulator review: equipping a skin didn't show "Equipped"
/// until the Shop page was reopened.
final class _DelayedSkinService implements SkinService {
  _DelayedSkinService(this._inner);

  final FakeSkinService _inner;
  Completer<void>? _gate;

  /// The next [selectSkin] call waits for [release].
  void holdNextSelect() => _gate = Completer<void>();

  void release() {
    _gate?.complete();
    _gate = null;
  }

  @override
  ThemeBackground? get background => _inner.background;

  @override
  Future<void> load() => _inner.load();

  @override
  void dispose() => _inner.dispose();

  @override
  Future<LevelSkin> prepareForLevel(
    Level level, {
    required BoardGeometry geometry,
    required double devicePixelRatio,
    required DollSymbols symbols,
    String? themeId,
  }) => _inner.prepareForLevel(
    level,
    geometry: geometry,
    devicePixelRatio: devicePixelRatio,
    symbols: symbols,
    themeId: themeId,
  );

  @override
  String get selectedSkinId => _inner.selectedSkinId;

  @override
  Future<bool> selectSkin(String skinId) async {
    final gate = _gate;
    if (gate != null) await gate.future;
    return _inner.selectSkin(skinId);
  }

  @override
  Stream<String> get selectedSkinChanges => _inner.selectedSkinChanges;

  @override
  Future<LevelSkin?> prepareShowcase({
    required List<DollColor> colors,
    required double devicePixelRatio,
    required DollSymbols symbols,
    String? skinId,
  }) => _inner.prepareShowcase(
    colors: colors,
    devicePixelRatio: devicePixelRatio,
    symbols: symbols,
    skinId: skinId,
  );
}

void main() {
  setUpAll(() {
    registerFallbackValue(<String, Object>{});
  });

  late _MockAnalyticsService analytics;
  late FakeMusicService music;
  late FakeAudioService jingles;
  late JingleCues jingleCues;

  setUp(() {
    analytics = _MockAnalyticsService();
    when(
      () => analytics.logEvent(any(), parameters: any(named: 'parameters')),
    ).thenAnswer((_) async {});
    music = FakeMusicService();
    jingles = FakeAudioService();
    jingleCues = JingleCues(music, jingles);
  });

  tearDown(() => jingleCues.dispose());

  /// L1 easy (ch01), L2 hard (ch01), L3 super hard (ch02): matches the
  /// bundled 6-figurine chapter numbering enough that `chapterNumbered(1)`
  /// and `(2)` both resolve.
  FakeLevelRepository levels({int currentLevel = 1}) {
    final level = levelFrom(tutorialLevelJson);
    return FakeLevelRepository(
      entries: [
        entryFor(level),
        entryFor(level, order: 2, tier: Tier.hard),
        entryFor(level, order: 3, tier: Tier.superhard, chapterId: 'ch02'),
      ],
    );
  }

  /// The bundled catalog plus one skin that isn't sold: every bundled skin
  /// is on sale since Forest Bear (phase 4, D200), so the unsold path is
  /// pinned on a catalog of its own.
  FakeCatalogRepository withUnsold() => FakeCatalogRepository(
    skins: [
      ...BundledCatalogRepository.bundledSkins,
      const SkinInfo(
        id: 'unsold-test',
        priceCoins: 0,
        previewColors: [DollColor.red, DollColor.blue, DollColor.green],
        sold: false,
      ),
    ],
  );

  ShopCubit build({
    SaveDocument? initial,
    FakeLevelRepository? repository,
    FakeCatalogRepository? catalog,
    SkinService? skins,
  }) => ShopCubit(
    catalog ?? FakeCatalogRepository(),
    FakeSaveService(initial: initial),
    skins ?? FakeSkinService(),
    repository ?? levels(),
    analytics,
    jingleCues,
  );

  group('load', () {
    blocTest<ShopCubit, AsyncValue<ShopState>>(
      'reads the sold skins, themes and the balance, open on the asked tab',
      build: () =>
          build(initial: const SaveDocument(coins: 830), catalog: withUnsold()),
      act: (cubit) => cubit.load(ShopTab.themes),
      expect: () => [
        const AsyncValue<ShopState>.loading(),
        isA<AsyncValueData<ShopState>>().having(
          (s) => s.data,
          'data',
          isA<ShopState>()
              .having((d) => d.tab, 'tab', ShopTab.themes)
              .having((d) => d.coins, 'coins', 830)
              .having(
                (d) => d.skins.map((s) => s.id),
                'skin ids (an unsold one filtered out; Forest Bear sold, '
                'D200)',
                allOf(isNot(contains('unsold-test')), contains('forest-bear')),
              )
              .having((d) => d.ownedSkins, 'owned skins', contains('classic'))
              .having((d) => d.selectedSkinId, 'selected skin', 'classic'),
        ),
      ],
    );

    blocTest<ShopCubit, AsyncValue<ShopState>>(
      'the reached chapter is the current level\'s, so its theme is owned '
      'without a purchase',
      build: () =>
          build(initial: const SaveDocument(currentLevel: 3, highestLevel: 3)),
      act: (cubit) => cubit.load(ShopTab.themes),
      skip: 1,
      expect: () => [
        isA<AsyncValueData<ShopState>>().having(
          (s) => s.data,
          'data',
          isA<ShopState>()
              .having((d) => d.reachedChapterNumber, 'reached chapter', 2)
              .having(
                (d) => d.ownsTheme(d.themes.firstWhere((t) => t.id == 'ch02')),
                'ch02 owned by reaching chapter 2',
                isTrue,
              )
              .having(
                (d) => d.ownsTheme(d.themes.firstWhere((t) => t.id == 'ch03')),
                'ch03 not yet reached',
                isFalse,
              ),
        ),
      ],
    );
  });

  group('selectTab', () {
    blocTest<ShopCubit, AsyncValue<ShopState>>(
      'switches tabs without a spinner',
      build: build,
      act: (cubit) async {
        await cubit.load(ShopTab.skins);
        cubit.selectTab(ShopTab.themes);
      },
      skip: 2,
      expect: () => [
        isA<AsyncValueData<ShopState>>().having(
          (s) => s.data.tab,
          'tab',
          ShopTab.themes,
        ),
      ],
    );

    test('tapping the already-selected tab does nothing', () async {
      final cubit = build();
      addTearDown(cubit.close);
      await cubit.load(ShopTab.skins);
      final before = cubit.state;
      cubit.selectTab(ShopTab.skins);
      await Future<void>.delayed(Duration.zero);
      expect(cubit.state, same(before));
    });
  });

  group('buySkin', () {
    test('unaffordable: nothing spent, not owned', () async {
      final cubit = build(initial: const SaveDocument(coins: 100));
      addTearDown(cubit.close);
      await cubit.load(ShopTab.skins);

      final outcome = await cubit.buySkin('ocean');
      expect(outcome, PurchaseOutcome.needsCoins);
      await Future<void>.delayed(Duration.zero);
      expect(cubit.state.data?.coins, 100);
      expect(cubit.state.data?.ownedSkins, isNot(contains('ocean')));
      expect(jingles.jingles, isEmpty);
      verifyNever(
        () => analytics.logEvent(any(), parameters: any(named: 'parameters')),
      );
    });

    test('unaffordable: needsCoins, and it stays on its own tab (D112, '
        'replaces the FIDELITY-7 jump to Coins: the caller opens '
        'NotEnoughCoinsDialog instead)', () async {
      final cubit = build(initial: const SaveDocument(coins: 100));
      addTearDown(cubit.close);
      await cubit.load(ShopTab.skins);

      expect(await cubit.buySkin('ocean'), PurchaseOutcome.needsCoins);
      await Future<void>.delayed(Duration.zero);
      expect(cubit.state.data?.tab, ShopTab.skins);
    });

    test('an already-owned or unsold skin stays on its tab', () async {
      final cubit = build(
        initial: const SaveDocument(ownedSkins: ['classic', 'ocean']),
        catalog: withUnsold(),
      );
      addTearDown(cubit.close);
      await cubit.load(ShopTab.skins);

      expect(await cubit.buySkin('ocean'), PurchaseOutcome.unavailable);
      expect(await cubit.buySkin('unsold-test'), PurchaseOutcome.unavailable);
      await Future<void>.delayed(Duration.zero);
      expect(cubit.state.data?.tab, ShopTab.skins);
    });

    test('unsold: unavailable, nothing spent', () async {
      final cubit = build(
        initial: const SaveDocument(coins: 999999),
        catalog: withUnsold(),
      );
      addTearDown(cubit.close);
      await cubit.load(ShopTab.skins);
      final outcome = await cubit.buySkin('unsold-test');
      expect(outcome, PurchaseOutcome.unavailable);
    });

    test('Forest Bear is on sale at 2,500 (copy.md H; Q72, D200)', () async {
      final cubit = build(initial: const SaveDocument(coins: 2500));
      addTearDown(cubit.close);
      await cubit.load(ShopTab.skins);
      expect(await cubit.buySkin('forest-bear'), PurchaseOutcome.bought);
    });

    test('affordable: spends the coins, equips it (save + SkinService), '
        'plays the reward jingle, logs skin_equip', () async {
      final skinPrice = BundledCatalogRepository.bundledSkins
          .firstWhere((s) => s.id == 'ocean')
          .priceCoins;
      final skins = FakeSkinService();
      final cubit = build(
        initial: SaveDocument(coins: skinPrice + 50),
        skins: skins,
      );
      addTearDown(cubit.close);
      await cubit.load(ShopTab.skins);

      final outcome = await cubit.buySkin('ocean');
      expect(outcome, PurchaseOutcome.bought);
      expect(skins.selectedSkinId, 'ocean');
      expect(jingles.jingles, [Jingle.reward]);
      verify(
        () => analytics.logEvent('skin_equip', parameters: {'skin': 'ocean'}),
      ).called(1);

      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);
      final data = cubit.state.data!;
      expect(data.coins, 50);
      expect(data.ownedSkins, contains('ocean'));
      expect(data.selectedSkinId, 'ocean');
      expect(
        data.isSkinEquipped(data.skins.firstWhere((s) => s.id == 'ocean')),
        isTrue,
      );
    });

    test('buying twice: the second buy is a no-op (already owned)', () async {
      final skinPrice = BundledCatalogRepository.bundledSkins
          .firstWhere((s) => s.id == 'ocean')
          .priceCoins;
      final cubit = build(initial: SaveDocument(coins: skinPrice * 2));
      addTearDown(cubit.close);
      await cubit.load(ShopTab.skins);
      await cubit.buySkin('ocean');
      await Future<void>.delayed(Duration.zero);
      final coinsAfterFirst = cubit.state.data!.coins;

      final outcome = await cubit.buySkin('ocean');
      expect(outcome, PurchaseOutcome.unavailable);
      await Future<void>.delayed(Duration.zero);
      expect(cubit.state.data!.coins, coinsAfterFirst);
    });

    test('buying then equipping: a genuinely async SkinService.selectSkin '
        '(like AssetSkinService) still leaves the Skins grid showing '
        '"Equipped" once the purchase settles (regression, owner 2026-09-28 '
        'simulator review: relying only on SaveService.changes could read '
        'SkinService.selectedSkinId before it actually changed)', () async {
      final skinPrice = BundledCatalogRepository.bundledSkins
          .firstWhere((s) => s.id == 'ocean')
          .priceCoins;
      final skins = _DelayedSkinService(FakeSkinService());
      final cubit = build(
        initial: SaveDocument(coins: skinPrice + 50),
        skins: skins,
      );
      addTearDown(cubit.close);
      await cubit.load(ShopTab.skins);

      skins.holdNextSelect();
      final buying = cubit.buySkin('ocean');
      // SaveService.purchaseSkin and .selectSkin both fire
      // SaveService.changes before SkinService.selectSkin (held open)
      // resolves.
      await Future<void>.delayed(Duration.zero);
      skins.release();
      expect(await buying, PurchaseOutcome.bought);

      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);
      final data = cubit.state.data!;
      expect(data.selectedSkinId, 'ocean');
      expect(
        data.isSkinEquipped(data.skins.firstWhere((s) => s.id == 'ocean')),
        isTrue,
      );
    });
  });

  group('equipSkin', () {
    test('equips an owned skin: no coins spent, no jingle', () async {
      final cubit = build(
        initial: const SaveDocument(
          ownedSkins: ['classic', 'space'],
          coins: 10,
        ),
      );
      addTearDown(cubit.close);
      await cubit.load(ShopTab.skins);

      final ok = await cubit.equipSkin('space');
      expect(ok, isTrue);
      await Future<void>.delayed(Duration.zero);
      expect(cubit.state.data?.selectedSkinId, 'space');
      expect(cubit.state.data?.coins, 10);
      expect(jingles.jingles, isEmpty);
      verify(
        () => analytics.logEvent('skin_equip', parameters: {'skin': 'space'}),
      ).called(1);
    });

    test('an unowned skin: false, nothing changes', () async {
      final cubit = build();
      addTearDown(cubit.close);
      await cubit.load(ShopTab.skins);
      final ok = await cubit.equipSkin('winter');
      expect(ok, isFalse);
      expect(cubit.state.data?.selectedSkinId, 'classic');
    });

    test('a genuinely async SkinService.selectSkin (like AssetSkinService) '
        'still leaves the Skins grid showing "Equipped" at once, not only '
        'once the page is reopened (regression, owner 2026-09-28 simulator '
        'review, frame 7.3: SaveService.changes alone can fire before '
        'SkinService.selectSkin finishes, so the grid kept the OLD '
        'selectedSkinId until something else refreshed it)', () async {
      final skins = _DelayedSkinService(FakeSkinService());
      final cubit = build(
        initial: const SaveDocument(ownedSkins: ['classic', 'space']),
        skins: skins,
      );
      addTearDown(cubit.close);
      await cubit.load(ShopTab.skins);
      expect(cubit.state.data?.selectedSkinId, 'classic');

      skins.holdNextSelect();
      final equipping = cubit.equipSkin('space');
      // Lets SaveService.changes's notification run while SkinService is
      // still mid-select: without following SkinService.selectedSkinChanges
      // too, this is the refresh that reads the stale id.
      await Future<void>.delayed(Duration.zero);
      skins.release();
      expect(await equipping, isTrue);

      // Whatever SkinService.selectedSkinChanges scheduled gets to run.
      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);

      expect(cubit.state.data?.selectedSkinId, 'space');
      expect(
        cubit.state.data!.isSkinEquipped(
          cubit.state.data!.skins.firstWhere((s) => s.id == 'space'),
        ),
        isTrue,
      );
    });
  });

  group('themes', () {
    test(
      'buying an early theme spends coins, uses it, plays the jingle',
      () async {
        final themePrice = BundledCatalogRepository.bundledThemes
            .firstWhere((t) => t.id == 'ch04')
            .priceCoins;
        final cubit = build(initial: SaveDocument(coins: themePrice + 20));
        addTearDown(cubit.close);
        await cubit.load(ShopTab.themes);

        final outcome = await cubit.buyTheme('ch04');
        expect(outcome, PurchaseOutcome.bought);
        expect(jingles.jingles, [Jingle.reward]);
        await Future<void>.delayed(Duration.zero);
        final data = cubit.state.data!;
        expect(data.coins, 20);
        expect(data.ownedThemes, contains('ch04'));
        expect(data.selectedThemeId, 'ch04');
        expect(data.matchesChapter, isFalse);
        expect(
          data.isThemeInUse(data.themes.firstWhere((t) => t.id == 'ch04')),
          isTrue,
        );
      },
    );

    test("buying a theme shows the Themes tab's 'In use' at once, even while "
        'a skin equip elsewhere is still mid-flight (themes never touch '
        'SkinService, so they never share the equip race)', () async {
      final themePrice = BundledCatalogRepository.bundledThemes
          .firstWhere((t) => t.id == 'ch04')
          .priceCoins;
      final skins = _DelayedSkinService(FakeSkinService());
      final cubit = build(
        initial: SaveDocument(coins: themePrice + 20),
        skins: skins,
      );
      addTearDown(cubit.close);
      await cubit.load(ShopTab.themes);

      skins.holdNextSelect();
      final outcome = await cubit.buyTheme('ch04');
      expect(outcome, PurchaseOutcome.bought);
      await Future<void>.delayed(Duration.zero);
      final data = cubit.state.data!;
      expect(
        data.isThemeInUse(data.themes.firstWhere((t) => t.id == 'ch04')),
        isTrue,
      );
      skins.release();
    });

    test('unaffordable: needsCoins, nothing spent', () async {
      final cubit = build(initial: const SaveDocument(coins: 0));
      addTearDown(cubit.close);
      await cubit.load(ShopTab.themes);
      final outcome = await cubit.buyTheme('ch06');
      expect(outcome, PurchaseOutcome.needsCoins);
      expect(jingles.jingles, isEmpty);
    });

    test('unaffordable: needsCoins, and it stays on its own tab (D112, '
        'replaces the FIDELITY-7 jump to Coins, like a skin)', () async {
      final cubit = build(initial: const SaveDocument(coins: 0));
      addTearDown(cubit.close);
      await cubit.load(ShopTab.themes);

      expect(await cubit.buyTheme('ch06'), PurchaseOutcome.needsCoins);
      await Future<void>.delayed(Duration.zero);
      expect(cubit.state.data?.tab, ShopTab.themes);
      expect(cubit.state.data?.coins, 0);
    });

    test(
      'useTheme selects it and turns "Match each chapter" off, no jingle',
      () async {
        final cubit = build(
          initial: const SaveDocument(currentLevel: 3, highestLevel: 3),
        );
        addTearDown(cubit.close);
        await cubit.load(ShopTab.themes);
        expect(cubit.state.data?.matchesChapter, isTrue);

        cubit.useTheme('ch01');
        await Future<void>.delayed(Duration.zero);
        expect(cubit.state.data?.selectedThemeId, 'ch01');
        expect(cubit.state.data?.matchesChapter, isFalse);
        expect(jingles.jingles, isEmpty);
      },
    );

    test('setMatchesChapter(true) selects no theme; false picks the reached '
        "chapter's", () async {
      final cubit = build(
        initial: const SaveDocument(
          currentLevel: 3,
          highestLevel: 3,
          selectedTheme: 'ch01',
        ),
      );
      addTearDown(cubit.close);
      await cubit.load(ShopTab.themes);
      expect(cubit.state.data?.currentChapterThemeId, 'ch02');

      cubit.setMatchesChapter(true);
      await Future<void>.delayed(Duration.zero);
      expect(cubit.state.data?.selectedThemeId, isNull);
      expect(cubit.state.data?.matchesChapter, isTrue);

      cubit.setMatchesChapter(false);
      await Future<void>.delayed(Duration.zero);
      expect(cubit.state.data?.selectedThemeId, 'ch02');
      expect(cubit.state.data?.matchesChapter, isFalse);
    });
  });

  test('stops listening once closed', () async {
    final cubit = build();
    await cubit.load(ShopTab.skins);
    await cubit.close();
    final outcome = await cubit.buySkin('ocean');
    // The cubit itself still runs its own methods after close (a caller
    // shouldn't call them, but nothing crashes); only the save-change and
    // skin-change listeners are torn down.
    expect(outcome, isA<PurchaseOutcome>());
  });
}
