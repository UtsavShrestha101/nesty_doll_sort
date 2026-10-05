import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_game/core/base/base_async_state.dart';
import 'package:nesty_game/core/repository/fake_level_repository.dart';
import 'package:nesty_game/core/services/save/fake_save_service.dart';
import 'package:nesty_game/core/services/save/save_document.dart';
import 'package:nesty_game/features/records/cubit/records_cubit.dart';

import '../../../helpers/level_fixtures.dart';

/// `RecordsCubit` (E8; docs/plans/m7-design.md §12): the coins and the
/// unlocked rivals read from the save, and a refresh on every
/// `SaveService.changes` without a loading flash.
void main() {
  final levels = FakeLevelRepository(
    entries: [
      for (var order = 1; order <= 5; order++)
        entryFor(levelFrom(tutorialLevelJson), order: order),
    ],
  );

  test('load reads the coins and which rivals are unlocked', () async {
    final save = FakeSaveService(initial: const SaveDocument(coins: 40));
    final cubit = RecordsCubit(save, levels);
    await cubit.load();

    final data = cubit.state.data!;
    expect(data.coins, 40);
    expect(data.rivalsUnlocked, [
      for (final rival in save.document.race.rivals) rival.unlocked,
    ]);
    await cubit.close();
    await save.dispose();
  });

  test(
    'a save change after load re-emits data, never a loading state',
    () async {
      final save = FakeSaveService(initial: const SaveDocument(coins: 1));
      final cubit = RecordsCubit(save, levels);
      await cubit.load();
      final states = <bool>[];
      final sub = cubit.stream.listen((s) => states.add(s.isLoading));

      save.addCoins(9);
      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);

      expect(cubit.state.data!.coins, 10);
      expect(states, isNotEmpty);
      expect(states, everyElement(isFalse));
      await sub.cancel();
      await cubit.close();
      await save.dispose();
    },
  );

  test(
    'a save change before load is ignored; after close nothing emits',
    () async {
      final save = FakeSaveService(initial: const SaveDocument(coins: 1));
      final cubit = RecordsCubit(save, levels);
      save.addCoins(1);
      await Future<void>.delayed(Duration.zero);
      expect(cubit.state.hasData, isFalse);

      await cubit.load();
      await cubit.close();
      save.addCoins(5);
      await Future<void>.delayed(Duration.zero);
      expect(cubit.state.data!.coins, 2);
      await save.dispose();
    },
  );
}
