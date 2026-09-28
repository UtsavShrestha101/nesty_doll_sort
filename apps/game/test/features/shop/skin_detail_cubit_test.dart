import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nesty_game/core/base/base_async_state.dart';
import 'package:nesty_game/core/error/app_exception.dart';
import 'package:nesty_game/core/repository/bundled_catalog_repository.dart';
import 'package:nesty_game/core/repository/fake_catalog_repository.dart';
import 'package:nesty_game/core/services/analytics/analytics_service.dart';
import 'package:nesty_game/core/services/audio/fake_audio_service.dart';
import 'package:nesty_game/core/services/audio/jingle_player.dart';
import 'package:nesty_game/core/services/music/fake_music_service.dart';
import 'package:nesty_game/core/services/music/jingle_cues.dart';
import 'package:nesty_game/core/services/save/fake_save_service.dart';
import 'package:nesty_game/core/services/save/save_document.dart';
import 'package:nesty_game/core/services/skin/fake_skin_service.dart';
import 'package:nesty_game/features/shop/cubit/skin_detail_cubit.dart';
import 'package:nesty_game/features/shop/model/purchase_outcome.dart';

class _MockAnalyticsService extends Mock implements AnalyticsService {}

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

  final oceanPrice = BundledCatalogRepository.bundledSkins
      .firstWhere((s) => s.id == 'ocean')
      .priceCoins;

  SkinDetailCubit build({SaveDocument? initial, FakeSkinService? skins}) =>
      SkinDetailCubit(
        FakeCatalogRepository(),
        FakeSaveService(initial: initial),
        skins ?? FakeSkinService(),
        analytics,
        jingleCues,
      );

  blocTest<SkinDetailCubit, AsyncValue<SkinDetailState>>(
    'reads the skin, whether it is owned, equipped, and the balance',
    build: () => build(initial: const SaveDocument(coins: 800)),
    act: (cubit) => cubit.load('ocean'),
    expect: () => [
      const AsyncValue<SkinDetailState>.loading(),
      isA<AsyncValueData<SkinDetailState>>().having(
        (s) => s.data,
        'data',
        isA<SkinDetailState>()
            .having((d) => d.skin.id, 'skin id', 'ocean')
            .having((d) => d.owned, 'owned', isFalse)
            .having((d) => d.equipped, 'equipped', isFalse)
            .having((d) => d.coins, 'coins', 800),
      ),
    ],
  );

  blocTest<SkinDetailCubit, AsyncValue<SkinDetailState>>(
    'the equipped skin (classic, the default)',
    build: build,
    act: (cubit) => cubit.load('classic'),
    skip: 1,
    expect: () => [
      isA<AsyncValueData<SkinDetailState>>().having(
        (s) => s.data,
        'data',
        isA<SkinDetailState>()
            .having((d) => d.owned, 'owned', isTrue)
            .having((d) => d.equipped, 'equipped', isTrue),
      ),
    ],
  );

  test('an unknown skin id is a content error with a retry', () async {
    final cubit = build();
    addTearDown(cubit.close);
    await cubit.load('not-a-real-skin');
    expect(cubit.state.hasError, isTrue);
    expect(cubit.state.exceptionOrNull?.kind, AppExceptionKind.content);
  });

  group('buy', () {
    test('unaffordable: needs coins (the page opens the Coins tab; '
        'FIDELITY-7), nothing spent', () async {
      final cubit = build(initial: SaveDocument(coins: oceanPrice - 1));
      addTearDown(cubit.close);
      await cubit.load('ocean');
      final outcome = await cubit.buy();
      expect(outcome, PurchaseOutcome.needsCoins);
      await Future<void>.delayed(Duration.zero);
      expect(cubit.state.data?.owned, isFalse);
      expect(cubit.state.data?.coins, oceanPrice - 1);
      expect(jingles.jingles, isEmpty);
    });

    test('already owned: unavailable, nothing spent', () async {
      final cubit = build(
        initial: SaveDocument(
          ownedSkins: const ['classic', 'ocean'],
          coins: oceanPrice * 2,
        ),
      );
      addTearDown(cubit.close);
      await cubit.load('ocean');
      expect(await cubit.buy(), PurchaseOutcome.unavailable);
      await Future<void>.delayed(Duration.zero);
      expect(cubit.state.data?.coins, oceanPrice * 2);
    });

    test('affordable: spends the coins, equips it, plays the reward jingle, '
        'logs skin_equip', () async {
      final skins = FakeSkinService();
      final cubit = build(
        initial: SaveDocument(coins: oceanPrice + 10),
        skins: skins,
      );
      addTearDown(cubit.close);
      await cubit.load('ocean');

      final outcome = await cubit.buy();
      expect(outcome, PurchaseOutcome.bought);
      expect(skins.selectedSkinId, 'ocean');
      expect(jingles.jingles, [Jingle.reward]);
      verify(
        () => analytics.logEvent('skin_equip', parameters: {'skin': 'ocean'}),
      ).called(1);

      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);
      final data = cubit.state.data!;
      expect(data.coins, 10);
      expect(data.owned, isTrue);
      expect(data.equipped, isTrue);
    });
  });

  group('equip', () {
    test('an already-owned skin: no coins spent, no jingle', () async {
      final cubit = build(
        initial: const SaveDocument(ownedSkins: ['classic', 'space']),
      );
      addTearDown(cubit.close);
      await cubit.load('space');

      final ok = await cubit.equip();
      expect(ok, isTrue);
      await Future<void>.delayed(Duration.zero);
      expect(cubit.state.data?.equipped, isTrue);
      expect(jingles.jingles, isEmpty);
      verify(
        () => analytics.logEvent('skin_equip', parameters: {'skin': 'space'}),
      ).called(1);
    });

    test('an unowned skin: false', () async {
      final cubit = build();
      addTearDown(cubit.close);
      await cubit.load('winter');
      final ok = await cubit.equip();
      expect(ok, isFalse);
    });
  });

  test(
    'a purchase made elsewhere (the Shop grid) is reflected here too',
    () async {
      final save = FakeSaveService();
      final cubit = SkinDetailCubit(
        FakeCatalogRepository(),
        save,
        FakeSkinService(),
        analytics,
        jingleCues,
      );
      addTearDown(cubit.close);
      await cubit.load('ocean');
      expect(cubit.state.data?.owned, isFalse);

      save.purchaseSkin('ocean', 0);
      await Future<void>.delayed(Duration.zero);
      expect(cubit.state.data?.owned, isTrue);
    },
  );

  test('stops listening once closed', () async {
    final save = FakeSaveService();
    final cubit = SkinDetailCubit(
      FakeCatalogRepository(),
      save,
      FakeSkinService(),
      analytics,
      jingleCues,
    );
    await cubit.load('ocean');
    await cubit.close();
    save.purchaseSkin('ocean', 0);
    await Future<void>.delayed(Duration.zero);
    expect(cubit.state.data?.owned, isFalse);
  });
}
