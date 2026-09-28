import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_core/nesty_core.dart';
import 'package:nesty_game/core/base/base_async_state.dart';
import 'package:nesty_game/core/models/play_request.dart';
import 'package:nesty_game/core/repository/catalog_models.dart';
import 'package:nesty_game/core/repository/fake_catalog_repository.dart';
import 'package:nesty_game/core/repository/fake_level_repository.dart';
import 'package:nesty_game/core/repository/fake_level_resolver.dart';
import 'package:nesty_game/core/services/clock/fake_clock.dart';
import 'package:nesty_game/core/services/daily/daily_service.dart';
import 'package:nesty_game/core/services/daily/fake_daily_service.dart';
import 'package:nesty_game/core/services/daily/streak_daily_service.dart';
import 'package:nesty_game/core/services/remote_config/fake_remote_config_service.dart';
import 'package:nesty_game/core/services/save/fake_save_service.dart';
import 'package:nesty_game/core/services/save/save_document.dart';
import 'package:nesty_game/features/home/cubit/home_cubit.dart';

import '../../helpers/level_fixtures.dart';

/// Three levels: L1 easy (ch01), L2 hard (ch01), L3 super hard (ch02).
FakeLevelRepository _levels() {
  final level = levelFrom(tutorialLevelJson);
  return FakeLevelRepository(
    entries: [
      entryFor(level),
      entryFor(level, order: 2, tier: Tier.hard),
      entryFor(level, order: 3, tier: Tier.superhard, chapterId: 'ch02'),
    ],
  );
}

HomeCubit _cubit({
  required FakeSaveService save,
  FakeLevelRepository? levels,
  DailyService? daily,
  FakeCatalogRepository? catalog,
}) {
  final theLevels = levels ?? _levels();
  return HomeCubit(
    save,
    theLevels,
    FakeLevelResolver(theLevels, save, FakeRemoteConfigService()),
    daily ?? FakeDailyService(FakeClock()),
    catalog ?? FakeCatalogRepository(),
  );
}

void main() {
  blocTest<HomeCubit, AsyncValue<HomeState>>(
    'reads the next level with its tier, the board theme and the coins',
    build: () => _cubit(
      save: FakeSaveService(
        initial: const SaveDocument(currentLevel: 2, coins: 140),
      ),
    ),
    act: (cubit) => cubit.load(),
    expect: () => const [
      AsyncValue<HomeState>.loading(),
      AsyncValue<HomeState>.data(
        data: HomeState(
          playRequest: PlayRequest.campaign(2),
          tier: Tier.hard,
          themeId: 'ch01',
          coins: 140,
          // FakeDailyService defaults to unlocked.
          dailyUnlocked: true,
          museumFigurineId: 'classic',
          museumLockedArtAsset: 'assets/museum/01-classic-locked.png',
          // ch01 starts at order 1: currentLevel 2 means 1 level already won.
          museumDone: 1,
          // The bundled catalog's 10 chapters (BundledCatalogRepository).
          museumCollectedTotal: 10,
        ),
      ),
    ],
  );

  blocTest<HomeCubit, AsyncValue<HomeState>>(
    'past the last level: PLAY starts Bonus Endless (m3-design §7.4, D74)',
    build: () => _cubit(
      save: FakeSaveService(initial: const SaveDocument(currentLevel: 4)),
    ),
    act: (cubit) => cubit.load(),
    skip: 1,
    expect: () => const [
      AsyncValue<HomeState>.data(
        data: HomeState(
          playRequest: PlayRequest.bonus(1),
          // DifficultyCurve.tierForLevel(3 + 1): still an early, easy level.
          themeId: 'ch02',
          dailyUnlocked: true,
          museumFigurineId: 'classic',
          museumLockedArtAsset: 'assets/museum/01-classic-locked.png',
          // ch01 starts at order 1: currentLevel 4 means 3 levels won.
          museumDone: 3,
          museumCollectedTotal: 10,
        ),
      ),
    ],
  );

  blocTest<HomeCubit, AsyncValue<HomeState>>(
    'the Daily tile: locked before Level 2, a streak once unlocked',
    build: () => _cubit(
      save: FakeSaveService(),
      daily: FakeDailyService(FakeClock())..unlocked = false,
    ),
    act: (cubit) => cubit.load(),
    skip: 1,
    expect: () => const [
      AsyncValue<HomeState>.data(
        data: HomeState(
          playRequest: PlayRequest.campaign(1),
          museumFigurineId: 'classic',
          museumLockedArtAsset: 'assets/museum/01-classic-locked.png',
          museumCollectedTotal: 10,
        ),
      ),
    ],
  );

  blocTest<HomeCubit, AsyncValue<HomeState>>(
    'the Museum tile: the current chapter\'s "done/total"',
    build: () => _cubit(
      save: FakeSaveService(initial: const SaveDocument(currentLevel: 5)),
    ),
    act: (cubit) => cubit.load(),
    skip: 1,
    expect: () => const [
      AsyncValue<HomeState>.data(
        data: HomeState(
          playRequest: PlayRequest.bonus(1),
          themeId: 'ch02',
          dailyUnlocked: true,
          museumFigurineId: 'classic',
          museumLockedArtAsset: 'assets/museum/01-classic-locked.png',
          museumDone: 4,
          museumCollectedTotal: 10,
        ),
      ),
    ],
  );

  blocTest<HomeCubit, AsyncValue<HomeState>>(
    'the Museum tile: every catalog chapter collected shows the plain count '
    '(Bonus Endless, TODO(design))',
    build: () => _cubit(
      save: FakeSaveService(initial: const SaveDocument(museum: ['ch01'])),
      catalog: FakeCatalogRepository(
        chapters: const [
          ChapterInfo(
            id: 'ch01',
            number: 1,
            themeId: 'ch01',
            figurine: FigurineInfo(
              id: 'classic',
              number: 1,
              artAsset: 'assets/museum/01-classic.png',
              lockedArtAsset: 'assets/museum/01-classic-locked.png',
            ),
          ),
        ],
      ),
    ),
    act: (cubit) => cubit.load(),
    skip: 1,
    expect: () => const [
      AsyncValue<HomeState>.data(
        data: HomeState(
          playRequest: PlayRequest.campaign(1),
          dailyUnlocked: true,
          museumAllCollected: true,
          museumCollectedCount: 1,
          museumCollectedTotal: 1,
        ),
      ),
    ],
  );

  test(
    'follows the save: a win shows the next level and the balance',
    () async {
      final save = FakeSaveService();
      final cubit = _cubit(save: save);
      addTearDown(cubit.close);
      await cubit.load();
      expect(cubit.state.data?.playRequest, const PlayRequest.campaign(1));

      save.recordWin(levelOrder: 2, rewardCoins: 25);
      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);

      expect(cubit.state.data?.playRequest, const PlayRequest.campaign(3));
      expect(cubit.state.data?.themeId, 'ch02');
      expect(cubit.state.data?.coins, 25);
    },
  );

  test(
    'follows the daily service too (a streak reconciled elsewhere)',
    () async {
      final daily = FakeDailyService(FakeClock());
      final cubit = _cubit(save: FakeSaveService(), daily: daily);
      addTearDown(cubit.close);
      await cubit.load();
      expect(cubit.state.data?.dailyStreak, 0);

      daily.status = daily.status.copyWith(streak: 4);
      await Future<void>.delayed(Duration.zero);

      expect(cubit.state.data?.dailyStreak, 4);
    },
  );

  test('a save change refreshes once through the real daily service, '
      'without looping on its changes', () async {
    final save = FakeSaveService();
    final daily = StreakDailyService(
      save,
      FakeClock(),
      FakeRemoteConfigService(),
    );
    addTearDown(daily.dispose);
    final cubit = _cubit(save: save, daily: daily);
    addTearDown(cubit.close);
    await cubit.load();
    var fired = 0;
    final subscription = daily.changes.listen((_) {
      // A runaway refresh loop fails the test instead of hanging it.
      if (++fired > 20) unawaited(cubit.close());
    });
    addTearDown(subscription.cancel);

    save.addCoins(5);
    await pumpEventQueue();

    expect(cubit.state.data?.coins, 5);
    expect(fired, 0, reason: 'nothing about the daily changed');
  });

  test('stops listening once closed', () async {
    final save = FakeSaveService();
    final cubit = _cubit(save: save);
    await cubit.load();
    await cubit.close();
    save.addCoins(5);
    await Future<void>.delayed(Duration.zero);
    expect(cubit.state.data?.coins, 0);
  });
}
