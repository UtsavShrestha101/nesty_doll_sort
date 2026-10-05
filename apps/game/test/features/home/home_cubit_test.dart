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
import 'package:nesty_game/core/services/clock/local_date.dart';
import 'package:nesty_game/core/services/daily/daily_service.dart';
import 'package:nesty_game/core/services/daily/fake_daily_service.dart';
import 'package:nesty_game/core/services/daily/streak_daily_service.dart';
import 'package:nesty_game/core/services/database/fake_database_service.dart';
import 'package:nesty_game/core/services/remote_config/fake_remote_config_service.dart';
import 'package:nesty_game/core/services/save/fake_save_service.dart';
import 'package:nesty_game/core/services/save/save_document.dart';
import 'package:nesty_game/core/ui/widgets/home/streak_look.dart';
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

class _SettableSave extends FakeSaveService {
  void replaceDocument(SaveDocument next) => adopt(next);
}

HomeCubit _cubit({
  required FakeSaveService save,
  FakeLevelRepository? levels,
  DailyService? daily,
  FakeCatalogRepository? catalog,
  FakeDatabaseService? database,
}) {
  final theLevels = levels ?? _levels();
  return HomeCubit(
    save,
    theLevels,
    FakeLevelResolver(theLevels, save, FakeRemoteConfigService()),
    daily ?? FakeDailyService(FakeClock()),
    catalog ?? FakeCatalogRepository(),
    FakeRemoteConfigService(),
    database ?? FakeDatabaseService(),
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
          // The chapter card names the last chapter, for its palette.
          chapterNumber: 2,
          chapterId: 'ch02',
          isBonus: true,
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
          chapterNumber: 2,
          chapterId: 'ch02',
          isBonus: true,
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

  group('phase 4: the chapter card and the Daily badge (frames 2.1, 12.2)', () {
    /// 45 levels with a par: chapters 1 and 2 full, chapter 3 partly.
    FakeLevelRepository parLevels() {
      final level = levelFrom(tutorialLevelJson);
      return FakeLevelRepository(
        entries: [
          for (var order = 1; order <= 45; order++)
            entryFor(
              level,
              order: order,
              par: 5,
              chapterId: 'ch0${(order - 1) ~/ 20 + 1}',
            ),
        ],
      );
    }

    test('the card is the PLAY level\'s chapter with its stars of 3 per '
        'level', () async {
      final level = levelFrom(tutorialLevelJson);
      final save = FakeSaveService(
        initial: SaveDocument(
          currentLevel: 25,
          highestLevel: 25,
          // The fixture shares one level id, so every won level of the
          // chapter reads the same 2 stars.
          levelStars: {level.id: 2},
        ),
      );
      final cubit = _cubit(save: save, levels: parLevels());
      addTearDown(cubit.close);
      await cubit.load();
      final data = cubit.state.data!;

      expect(data.chapterNumber, 2);
      expect(data.chapterId, 'ch02');
      expect(data.isBonus, isFalse);
      // 20 levels with a par: 60 to earn, and the chapter's cells read the
      // shared 2 stars each.
      expect(data.chapterStarsPossible, 60);
      expect(data.chapterStars, 40);
    });

    test('Bonus Endless shows the whole campaign\'s stars of 3 x the '
        'levels with a par', () async {
      final level = levelFrom(tutorialLevelJson);
      final save = FakeSaveService(
        initial: SaveDocument(
          currentLevel: 46,
          highestLevel: 46,
          levelStars: {level.id: 3},
        ),
      );
      final cubit = _cubit(save: save, levels: parLevels());
      addTearDown(cubit.close);
      await cubit.load();
      final data = cubit.state.data!;

      expect(data.isBonus, isTrue);
      expect(data.chapterStarsPossible, 135, reason: '3 x 45 levels');
      // levelStars is keyed by level id, one id in this fixture.
      expect(data.chapterStars, 3);
    });

    test('a streak of 0 is the unlit flame; a lit streak, lit; a resting '
        'one, paused; never a lost streak', () async {
      final daily = FakeDailyService(FakeClock());
      final cubit = _cubit(save: FakeSaveService(), daily: daily);
      addTearDown(cubit.close);
      await cubit.load();
      expect(cubit.state.data!.streakLook, StreakLook.zero);

      daily.status = daily.status.copyWith(streak: 4, lit: true);
      await pumpEventQueue();
      expect(cubit.state.data!.streakLook, StreakLook.lit);

      daily.status = daily.status.copyWith(lit: false);
      await pumpEventQueue();
      expect(cubit.state.data!.streakLook, StreakLook.paused);
      expect(cubit.state.data!.dailyStreak, 4, reason: 'the number stays');
    });

    SaveDocument relitDoc() => SaveDocument(
      daily: DailyProgress(
        streak: 5,
        lit: true,
        run: 1,
        lastDate: LocalDate(2026, 10, 1),
      ),
    );

    test('a solve that lights a resting flame glows once, then plays the '
        'plain flame (m7-4 4.10)', () async {
      final save = _SettableSave();
      final database = FakeDatabaseService();
      final daily = FakeDailyService(FakeClock());
      daily.status = daily.status.copyWith(streak: 4, lit: false);
      final cubit = _cubit(save: save, daily: daily, database: database);
      addTearDown(cubit.close);
      await cubit.load();
      expect(cubit.state.data!.streakLook, StreakLook.paused);

      save.replaceDocument(relitDoc());
      daily.status = daily.status.copyWith(streak: 5, lit: true);
      await pumpEventQueue();
      expect(cubit.state.data!.streakLook, StreakLook.relit);
      expect(database.relitGlowSeen, '2026-10-01');

      // A refresh while it plays keeps it; finishing ends it for good.
      save.addCoins(5);
      await pumpEventQueue();
      expect(cubit.state.data!.streakLook, StreakLook.relit);
      cubit.relitGlowFinished();
      expect(cubit.state.data!.streakLook, StreakLook.lit);
      save.addCoins(5);
      await pumpEventQueue();
      expect(cubit.state.data!.streakLook, StreakLook.lit);
    });

    test('a later session shows the glow once for a relight Home missed, '
        'and not again once it was seen', () async {
      final database = FakeDatabaseService();
      final daily = FakeDailyService(FakeClock());
      daily.status = daily.status.copyWith(streak: 5, lit: true);
      final first = _cubit(
        save: FakeSaveService(initial: relitDoc()),
        daily: daily,
        database: database,
      );
      addTearDown(first.close);
      await first.load();
      expect(first.state.data!.streakLook, StreakLook.relit);

      final second = _cubit(
        save: FakeSaveService(initial: relitDoc()),
        daily: daily,
        database: database,
      );
      addTearDown(second.close);
      await second.load();
      expect(second.state.data!.streakLook, StreakLook.lit);
    });

    test('a first solve (nothing was resting) is lit, not relit', () async {
      final daily = FakeDailyService(FakeClock());
      final cubit = _cubit(save: FakeSaveService(), daily: daily);
      addTearDown(cubit.close);
      await cubit.load();

      daily.status = daily.status.copyWith(streak: 1, lit: true);
      await pumpEventQueue();
      expect(cubit.state.data!.streakLook, StreakLook.lit);
    });
  });
}
