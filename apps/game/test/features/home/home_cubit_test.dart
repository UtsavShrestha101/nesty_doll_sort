import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_core/nesty_core.dart';
import 'package:nesty_game/core/base/base_async_state.dart';
import 'package:nesty_game/core/repository/fake_level_repository.dart';
import 'package:nesty_game/core/services/save/fake_save_service.dart';
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

void main() {
  blocTest<HomeCubit, AsyncValue<HomeState>>(
    'reads the next level with its tier and chapter, and the coins',
    build: () => HomeCubit(
      FakeSaveService()
        ..currentLevel = 2
        ..addCoins(140),
      _levels(),
    ),
    act: (cubit) => cubit.load(),
    expect: () => const [
      AsyncValue<HomeState>.loading(),
      AsyncValue<HomeState>.data(
        data: HomeState(
          currentLevel: 2,
          tier: Tier.hard,
          coins: 140,
          levelCount: 3,
        ),
      ),
    ],
  );

  blocTest<HomeCubit, AsyncValue<HomeState>>(
    'past the last level: All Levels Done, in the last chapter (4.9)',
    build: () => HomeCubit(FakeSaveService()..currentLevel = 4, _levels()),
    act: (cubit) => cubit.load(),
    skip: 1,
    expect: () => const [
      AsyncValue<HomeState>.data(
        data: HomeState(
          currentLevel: 4,
          tier: Tier.superhard,
          chapterId: 'ch02',
          levelCount: 3,
          allLevelsDone: true,
        ),
      ),
    ],
  );

  test(
    'follows the save: a win shows the next level and the balance',
    () async {
      final save = FakeSaveService();
      final cubit = HomeCubit(save, _levels());
      addTearDown(cubit.close);
      await cubit.load();
      expect(cubit.state.data?.currentLevel, 1);

      save.recordWin(levelOrder: 2, rewardCoins: 25);
      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);

      expect(cubit.state.data?.currentLevel, 3);
      expect(cubit.state.data?.chapterId, 'ch02');
      expect(cubit.state.data?.coins, 25);
    },
  );

  test('stops listening once closed', () async {
    final save = FakeSaveService();
    final cubit = HomeCubit(save, _levels());
    await cubit.load();
    await cubit.close();
    save.addCoins(5);
    await Future<void>.delayed(Duration.zero);
    expect(cubit.state.data?.coins, 0);
  });
}
