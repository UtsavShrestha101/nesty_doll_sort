import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_game/core/models/play_request.dart';
import 'package:nesty_game/core/services/database/fake_database_service.dart';
import 'package:nesty_game/core/services/remote_config/fake_remote_config_service.dart';
import 'package:nesty_game/core/services/save/fake_save_service.dart';
import 'package:nesty_game/core/services/save/save_document.dart';
import 'package:nesty_game/features/race/cubit/rival_select_cubit.dart';

/// Rival select's state (frames 9.2, 9.2b; m7-design P4.4): which rival the
/// one Start races, the beaten check, and the "New" mark.
void main() {
  SaveDocument doc(List<RivalProgress> rivals) => SaveDocument(
    currentLevel: 40,
    highestLevel: 40,
    race: RaceProgress(rivals: rivals),
  );

  Future<(RivalSelectCubit, FakeSaveService)> build(
    List<RivalProgress> rivals,
  ) async {
    final save = FakeSaveService(initial: doc(rivals));
    final cubit = RivalSelectCubit(
      save,
      FakeRemoteConfigService(),
      FakeDatabaseService(),
    );
    await cubit.load();
    return (cubit, save);
  }

  RivalSelectState read(RivalSelectCubit cubit) => cubit.state.data!;

  test('a fresh save: Pebble selected, unbeaten, no "New" (rival 1 is never '
      'new), 2 and 3 locked', () async {
    final (cubit, _) = await build(const [
      RivalProgress(unlocked: true),
      RivalProgress(),
      RivalProgress(),
    ]);
    final state = read(cubit);
    expect(state.selected, 1);
    expect(state.rivals.map((r) => r.unlocked), [true, false, false]);
    expect(state.rivals.map((r) => r.beaten), [false, false, false]);
    expect(state.rivals.map((r) => r.isNew), [false, false, false]);
    expect(state.rivals.map((r) => r.rewardCoins), [20, 30, 40]);
    await cubit.close();
  });

  test('beaten follows wins, and a rival that was won against is checked '
      'even after a rematch', () async {
    final (cubit, _) = await build(const [
      RivalProgress(unlocked: true, wins: 2, raceNo: 3),
      RivalProgress(unlocked: true, raceNo: 1),
      RivalProgress(),
    ]);
    expect(read(cubit).rivals.map((r) => r.beaten), [true, false, false]);
    await cubit.close();
  });

  test(
    'the newest unlocked rival not yet raced is New and preselected',
    () async {
      final (cubit, _) = await build(const [
        RivalProgress(unlocked: true, wins: 1, raceNo: 1),
        RivalProgress(unlocked: true),
        RivalProgress(),
      ]);
      final state = read(cubit);
      expect(state.rivals.map((r) => r.isNew), [false, true, false]);
      expect(state.selected, 2);
      await cubit.close();
    },
  );

  test(
    'with nothing new, the highest unlocked (the last raced) is selected',
    () async {
      final (cubit, _) = await build(const [
        RivalProgress(unlocked: true, wins: 1, raceNo: 2),
        RivalProgress(unlocked: true, wins: 1, raceNo: 1),
        RivalProgress(),
      ]);
      expect(read(cubit).selected, 2);
      await cubit.close();
    },
  );

  test('with nothing new, the last rival raced is selected, not the highest '
      '(m7-4 4.5, settings lastRival)', () async {
    final database = FakeDatabaseService();
    final save = FakeSaveService(
      initial: doc(const [
        RivalProgress(unlocked: true, wins: 1, raceNo: 2),
        RivalProgress(unlocked: true, wins: 1, raceNo: 1),
        RivalProgress(),
      ]),
    );
    final cubit = RivalSelectCubit(save, FakeRemoteConfigService(), database);
    await cubit.load();
    expect(read(cubit).selected, 2, reason: 'no memory: the highest');

    // Racing Pebble remembers it for the next visit.
    expect(cubit.begin(1), isNotNull);
    expect(database.lastRival, 1);
    final next = RivalSelectCubit(save, FakeRemoteConfigService(), database);
    await next.load();
    expect(read(next).selected, 1);
    await cubit.close();
    await next.close();
  });

  test('New clears when the rival is first raced (beginRace stores its '
      'raceNo)', () async {
    final (cubit, save) = await build(const [
      RivalProgress(unlocked: true, wins: 1, raceNo: 1),
      RivalProgress(unlocked: true),
      RivalProgress(),
    ]);
    expect(read(cubit).rivals[1].isNew, isTrue);
    final race = cubit.begin(2);
    expect(race, const RacePlay(rival: 2, raceNo: 1));
    await Future<void>.delayed(Duration.zero);
    expect(save.document.race.rivals[1].raceNo, 1);
    expect(read(cubit).rivals[1].isNew, isFalse);
    await cubit.close();
  });

  test('select moves the selection for an unlocked rival only', () async {
    final (cubit, _) = await build(const [
      RivalProgress(unlocked: true, wins: 1, raceNo: 1),
      RivalProgress(unlocked: true, raceNo: 1),
      RivalProgress(),
    ]);
    expect(read(cubit).selected, 2);
    cubit.select(1);
    expect(read(cubit).selected, 1);
    cubit.select(3);
    expect(read(cubit).selected, 1, reason: 'locked: not selectable');
    cubit.select(9);
    expect(read(cubit).selected, 1, reason: 'unknown rival');
    await cubit.close();
  });

  test('the player\'s pick survives a save change for the visit', () async {
    final (cubit, save) = await build(const [
      RivalProgress(unlocked: true, wins: 1, raceNo: 1),
      RivalProgress(unlocked: true),
      RivalProgress(),
    ]);
    cubit.select(1);
    save.recordRaceWin(
      const RaceWinRecord(rival: 1, raceNo: 1, rewardCoins: 20),
    );
    await Future<void>.delayed(Duration.zero);
    await Future<void>.delayed(Duration.zero);
    expect(read(cubit).selected, 1);
    await cubit.close();
  });

  test('begin refuses a locked rival and writes nothing', () async {
    final (cubit, save) = await build(const [
      RivalProgress(unlocked: true),
      RivalProgress(),
      RivalProgress(),
    ]);
    expect(cubit.begin(2), isNull);
    expect(save.document.race.rivals[1].raceNo, 0);
    await cubit.close();
  });
}
