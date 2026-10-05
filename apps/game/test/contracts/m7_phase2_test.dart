import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_core/nesty_core.dart';
import 'package:nesty_game/core/base/base_async_state.dart';
import 'package:nesty_game/core/flavor/flavor.dart';
import 'package:nesty_game/core/models/play_entry.dart';
import 'package:nesty_game/core/models/play_request.dart';
import 'package:nesty_game/core/repository/default_level_resolver.dart';
import 'package:nesty_game/core/repository/fake_catalog_repository.dart';
import 'package:nesty_game/core/repository/fake_level_repository.dart';
import 'package:nesty_game/core/repository/fixture_levels.dart';
import 'package:nesty_game/core/services/database/fake_database_service.dart';
import 'package:nesty_game/core/services/generator/fake_level_generator_service.dart';
import 'package:nesty_game/core/services/race/race_rules.dart';
import 'package:nesty_game/core/services/remote_config/fake_remote_config_service.dart';
import 'package:nesty_game/core/services/remote_config/remote_config_keys.dart';
import 'package:nesty_game/core/services/save/fake_save_service.dart';
import 'package:nesty_game/core/services/save/save_document.dart';
import 'package:nesty_game/core/services/save/save_document_codec.dart';
import 'package:nesty_game/core/services/ticker/fake_frame_ticker.dart';
import 'package:nesty_game/core/services/ticker/scheduler_frame_ticker.dart';
import 'package:nesty_game/features/gameplay/bloc/gameplay_bloc.dart';
import 'package:nesty_game/features/race/cubit/race_cubit.dart';
import 'package:nesty_game/features/race/cubit/rival_select_cubit.dart';

import '../features/gameplay/bloc/support/bloc_fixtures.dart';
import '../features/gameplay/bloc/support/scripted_level_resolver.dart';

/// The plumbing the M7 phase-2 contracts froze and implemented for vs
/// Computer (docs/plans/m7-design.md P2.1): each lane owns the full
/// behaviour tests of its part (P2.13); these pin that the frozen surface
/// is wired.
void main() {
  const race = RacePlay(rival: 1, raceNo: 1);

  /// A save past the unlock level (`race_unlock_level` 20 won).
  SaveDocument unlockedDocument({RaceProgress race = const RaceProgress()}) =>
      SaveDocument(currentLevel: 21, highestLevel: 21, race: race);

  PlayEntry raceEntry(RacePlay request, {Level? level}) => PlayEntry(
    request: request,
    level: level ?? defaultLevel,
    tier: Tier.easy,
    levelVersion: Generator.version,
    rewardCoins: 20,
    themeId: 'ch02',
  );

  group('PlayRequest.race (m7-design P2.4)', () {
    test('is a generated request of its own kind, never stored', () {
      expect(race.kind, PlayKind.race);
      expect(race.number, 1);
      expect(race.isRace, isTrue);
      expect(race.isGenerated, isTrue);
      expect(race.isBundled, isFalse);
      expect(race.isReplay, isFalse);
      expect(const PlayRequest.race(rival: 2, raceNo: 5), isA<RacePlay>());
      expect(PlayKind.tryFromId('race'), PlayKind.race);
      expect(PlayRequest.tryCreate(PlayKind.race, 1), isNull);
    });
  });

  group("the save's race API (m7-design P2.7)", () {
    test('beginRace stores the next raceNo in one update, only for an '
        'unlocked rival', () async {
      final save = FakeSaveService(initial: unlockedDocument());
      var changes = 0;
      final sub = save.changes.listen((_) => changes++);
      addTearDown(sub.cancel);

      expect(save.beginRace(1), 1);
      expect(save.beginRace(1), 2);
      expect(save.document.race.rivals[0].raceNo, 2);
      expect(save.beginRace(2), isNull, reason: 'rival 2 is locked');
      expect(save.beginRace(0), isNull);
      expect(save.beginRace(4), isNull);
      await pumpEventQueue();
      expect(changes, 2);
    });

    test('beginRace stays at the cap', () {
      final save = FakeSaveService(
        initial: unlockedDocument(
          race: const RaceProgress(
            rivals: [
              RivalProgress(unlocked: true, raceNo: DifficultyCurve.maxRaceNo),
              RivalProgress(),
              RivalProgress(),
            ],
          ),
        ),
      );
      expect(save.beginRace(1), DifficultyCurve.maxRaceNo);
    });

    test('recordRaceWin pays, counts, unlocks the next rival once and grants '
        'first_race', () {
      final save = FakeSaveService(initial: unlockedDocument());
      final outcome = save.recordRaceWin(
        const RaceWinRecord(
          rival: 1,
          raceNo: 1,
          rewardCoins: 20,
          moves: 9,
          families: 2,
          dolls: 4,
        ),
      );
      expect(outcome.coins, 20);
      expect(outcome.unlockedRival, 2);
      expect(outcome.wins, 1);
      expect(outcome.newBadges, contains(BadgeId.firstRace));
      final doc = save.document;
      expect(doc.coins, 20);
      expect(doc.race.rivals[0].wins, 1);
      expect(doc.race.rivals[1].unlocked, isTrue);
      expect(doc.race.rivals[2].unlocked, isFalse);
      expect(doc.stats.wins, 1);
      expect(doc.stats.moves, 9);
      expect(doc.records.families, 2);
      expect(doc.records.dolls, 4);

      final again = save.recordRaceWin(
        const RaceWinRecord(rival: 1, raceNo: 1, rewardCoins: 20),
      );
      expect(again.unlockedRival, isNull);
      expect(again.wins, 2);
      expect(again.newBadges, isEmpty);
      expect(
        () => save.recordRaceWin(
          const RaceWinRecord(rival: 4, raceNo: 1, rewardCoins: 0),
        ),
        throwsRangeError,
      );
    });

    test('a race never goes through the level win path or the in-progress '
        'slot, and the codec drops a stored one', () {
      final save = FakeSaveService(initial: unlockedDocument());
      final before = save.document;
      expect(
        save.recordLevelWin(
          const LevelWinRecord(request: race, rewardCoins: 20, moves: 5),
        ),
        const LevelWinOutcome(),
      );
      save.saveInProgress(
        const InProgressLevel(
          request: race,
          levelId: 'race-1-1',
          levelVersion: 1,
          session: {},
        ),
      );
      save.clearInProgress(PlayKind.race);
      expect(save.document, before);
      expect(save.inProgressFor(PlayKind.race), isNull);

      final raw = SaveDocumentCodec.encode(before)
        ..['inProgress'] = {
          'kind': 'race',
          'number': 1,
          'levelId': 'race-1-1',
          'levelVersion': 1,
          'session': <String, Object?>{},
          'level': <String, Object?>{},
        };
      expect(SaveDocumentCodec.decode(raw).inProgress, isNull);
    });
  });

  group('RaceRules (m7-design P2.5)', () {
    test('reads and clamps the Remote Config values', () {
      final config = FakeRemoteConfigService();
      expect(RaceRules.paceMs(1, config), 3000);
      expect(RaceRules.paceMs(2, config), 2400);
      expect(RaceRules.paceMs(3, config), 1600);
      expect(RaceRules.jitterPct(config), 20);
      expect(RaceRules.rewardCoins(3, config), 40);
      config
        ..setOverride(RemoteConfigKeys.racePaceMs1, -5)
        ..setOverride(RemoteConfigKeys.racePaceJitterPct, 250)
        ..setOverride(RemoteConfigKeys.raceReward2, -1);
      expect(RaceRules.paceMs(1, config), 0);
      expect(RaceRules.jitterPct(config), 100);
      expect(RaceRules.rewardCoins(2, config), 0);
      expect(() => RaceRules.paceMs(4, config), throwsRangeError);
    });

    test('the mode unlocks past race_unlock_level; the stage is the highest '
        'level won', () {
      final config = FakeRemoteConfigService();
      expect(RaceRules.modeUnlocked(20, config), isFalse);
      expect(RaceRules.modeUnlocked(21, config), isTrue);
      expect(RaceRules.stageLevel(21), 20);
      expect(RaceRules.stageLevel(1), 1);
    });

    test('intervals stay within the jitter and replay from the seed', () {
      List<int> intervals(int seed) {
        final pace = RaceRules.pacePrng(seed);
        return [
          for (var i = 0; i < 200; i++)
            RaceRules.nextIntervalMs(pace, 3000, 20),
        ];
      }

      final seed = DifficultyCurve.raceSeed(1, 1);
      final first = intervals(seed);
      expect(first, intervals(seed));
      expect(first.every((ms) => ms >= 2400 && ms <= 3600), isTrue);
      expect(first.toSet().length, greaterThan(1));
      expect(RaceRules.nextIntervalMs(RaceRules.pacePrng(seed), 1600, 0), 1600);
    });

    test('the pace define counts only in a dev debug build', () {
      expect(
        RaceRules.parsePaceOverride('600000', debug: true, flavor: Flavor.dev),
        600000,
      );
      expect(
        RaceRules.parsePaceOverride('600000', debug: false, flavor: Flavor.dev),
        isNull,
      );
      expect(
        RaceRules.parsePaceOverride('600000', debug: true, flavor: Flavor.prod),
        isNull,
      );
      expect(
        RaceRules.parsePaceOverride('', debug: true, flavor: Flavor.dev),
        isNull,
      );
      expect(
        RaceRules.parsePaceOverride('-1', debug: true, flavor: Flavor.dev),
        isNull,
      );
    });
  });

  group('FrameTicker (m7-design P2.8)', () {
    test('the fake plays frames only while started', () {
      final ticker = FakeFrameTicker();
      final seen = <Duration>[];
      ticker.tick();
      expect(seen, isEmpty);
      ticker.start(seen.add);
      ticker.advance(const Duration(milliseconds: 50));
      expect(seen.first, Duration.zero);
      expect(seen, hasLength(3));
      ticker.stop();
      ticker.tick();
      expect(seen, hasLength(3));
      ticker.dispose();
      expect(ticker.isDisposed, isTrue);
    });

    testWidgets('the real one ticks on frames, from zero', (tester) async {
      final ticker = SchedulerFrameTicker();
      final seen = <Duration>[];
      ticker.start(seen.add);
      expect(ticker.isTicking, isTrue);
      await tester.pump(const Duration(milliseconds: 16));
      await tester.pump(const Duration(milliseconds: 16));
      expect(seen.first, Duration.zero);
      expect(seen.last, greaterThan(Duration.zero));
      ticker.stop();
      expect(ticker.isTicking, isFalse);
      ticker.dispose();
    });
  });

  group("the resolver's race case (m7-design P2.4)", () {
    DefaultLevelResolver resolverFor(FakeSaveService save) =>
        DefaultLevelResolver(
          FakeLevelRepository(entries: FixtureLevels.entries()),
          FakeLevelGeneratorService(),
          FakeRemoteConfigService(),
          save,
          FakeCatalogRepository(),
        );

    test('makes the rival 1 board once the mode and the rival are open; the '
        'cache gives a Rematch the same Level', () async {
      final resolver = resolverFor(
        FakeSaveService(initial: unlockedDocument()),
      );
      final entry = await resolver.resolve(race);
      expect(entry, isNotNull);
      expect(entry!.request, race);
      expect(entry.level.id, 'race-1-1');
      expect(entry.rewardCoins, 20);
      expect(entry.levelVersion, Generator.version);
      expect(entry.chapterId, isNull);
      expect((await resolver.resolve(race))!.level, same(entry.level));
      expect(resolver.next(race), isNull);
    });

    test('gives nothing while the mode or the rival is locked', () async {
      final locked = resolverFor(
        FakeSaveService(
          initial: const SaveDocument(currentLevel: 20, highestLevel: 20),
        ),
      );
      expect(await locked.resolve(race), isNull);
      final open = resolverFor(FakeSaveService(initial: unlockedDocument()));
      expect(
        await open.resolve(const PlayRequest.race(rival: 2, raceNo: 1)),
        isNull,
      );
      expect(
        await open.resolve(const PlayRequest.race(rival: 1, raceNo: 0)),
        isNull,
      );
    });
  });

  group('RaceCubit setup (m7-design P2.5)', () {
    RaceCubit cubitFor(RacePlay request, {FakeSaveService? save}) => RaceCubit(
      request,
      save ?? FakeSaveService(initial: unlockedDocument()),
      FakeRemoteConfigService(),
      FakeFrameTicker(),
    );

    test('the loaded board builds the rival on the same Level from the race '
        'seed, and the race is ready', () async {
      final cubit = cubitFor(race);
      addTearDown(cubit.close);
      expect(cubit.state.data, isNull);

      cubit.playerBoardLoaded(raceEntry(race));
      final state = cubit.state.data!;
      expect(state.phase, RacePhase.ready);
      expect(state.totalSets, defaultLevel.totalSets);
      expect(state.rivalSets, 0);
      expect(state.activity, RivalActivity.idle);
      expect(state.rivalBoard, GameState.initial(defaultLevel));
      final bot = cubit.bot!;
      expect(bot.level, same(defaultLevel));
      expect(bot.policy, SimBot.casual);
      expect(bot.raceSeed, DifficultyCurve.raceSeed(1, 1));
      expect(cubit.paceMs, 3000);
      expect(cubit.jitterPct, 20);
    });

    test("another race's board is ignored", () async {
      final cubit = cubitFor(race);
      addTearDown(cubit.close);
      cubit.playerBoardLoaded(raceEntry(const RacePlay(rival: 1, raceNo: 2)));
      expect(cubit.state.data, isNull);
    });

    test('Rematch and New race wait for a result', () async {
      final cubit = cubitFor(race);
      addTearDown(cubit.close);
      cubit.playerBoardLoaded(raceEntry(race));
      expect(cubit.rematch(), race);
      expect(cubit.newRace(), isNull);
      expect(cubit.state.data!.phase, RacePhase.ready);
    });

    blocTest<RaceCubit, AsyncValue<RaceState>>(
      'Rematch keeps the race; the board then loads it again',
      build: () => cubitFor(race),
      seed: () => const AsyncValue.data(
        data: RaceState(
          request: race,
          phase: RacePhase.finished,
          result: RaceResult.rivalWon,
        ),
      ),
      act: (cubit) => expect(cubit.rematch(), race),
      expect: () => [const AsyncValue.data(data: RaceState(request: race))],
    );

    final newRaceSave = FakeSaveService(
      initial: unlockedDocument(
        race: const RaceProgress(
          rivals: [
            RivalProgress(unlocked: true, raceNo: 1),
            RivalProgress(),
            RivalProgress(),
          ],
        ),
      ),
    );
    const next = RacePlay(rival: 1, raceNo: 2);
    blocTest<RaceCubit, AsyncValue<RaceState>>(
      'New race stores the next raceNo and waits for its board',
      build: () => cubitFor(race, save: newRaceSave),
      seed: () => const AsyncValue.data(
        data: RaceState(
          request: race,
          phase: RacePhase.finished,
          result: RaceResult.playerWon,
        ),
      ),
      act: (cubit) {
        expect(cubit.newRace(), next);
        expect(cubit.request, next);
      },
      expect: () => [const AsyncValue.data(data: RaceState(request: next))],
      verify: (_) => expect(newRaceSave.document.race.rivals[0].raceNo, 2),
    );

    test('closing disposes the clock and writes nothing', () async {
      final ticker = FakeFrameTicker();
      final save = FakeSaveService(initial: unlockedDocument());
      final cubit = RaceCubit(race, save, FakeRemoteConfigService(), ticker)
        ..playerBoardLoaded(raceEntry(race));
      final before = save.document;
      await cubit.close();
      expect(ticker.isDisposed, isTrue);
      expect(save.document, before);
    });
  });

  group('RivalSelectCubit (m7-design P2.8)', () {
    test('lists the three rivals with their rewards, and begin stores the '
        'race', () async {
      final save = FakeSaveService(initial: unlockedDocument());
      final cubit = RivalSelectCubit(
        save,
        FakeRemoteConfigService(),
        FakeDatabaseService(),
      );
      addTearDown(cubit.close);
      await cubit.load();
      expect(cubit.state.data!.rivals, const [
        RivalCard(number: 1, unlocked: true, rewardCoins: 20),
        RivalCard(number: 2, rewardCoins: 30),
        RivalCard(number: 3, rewardCoins: 40),
      ]);
      expect(cubit.begin(2), isNull);
      expect(cubit.begin(1), race);
      expect(save.document.race.rivals[0].raceNo, 1);

      save.recordRaceWin(
        const RaceWinRecord(rival: 1, raceNo: 1, rewardCoins: 20),
      );
      await pumpEventQueue();
      expect(cubit.state.data!.rivals[1].unlocked, isTrue);
      expect(cubit.state.data!.coins, 20);
    });

    test('begins nothing while the mode is locked', () async {
      final save = FakeSaveService();
      final cubit = RivalSelectCubit(
        save,
        FakeRemoteConfigService(),
        FakeDatabaseService(),
      );
      addTearDown(cubit.close);
      expect(cubit.begin(1), isNull);
      expect(save.document.race.rivals[0].raceNo, 0);
    });
  });

  group("the bloc's race gate (m7-design P2.6)", () {
    Future<GameplayState> started(GameplayBloc bloc, PlayRequest request) {
      bloc.add(GameplayStarted(request));
      return bloc.stream
          .where((value) => value.hasData)
          .map((value) => value.data!)
          .first;
    }

    test('a race takes input only while the gate is open', () async {
      final bloc = buildBloc(
        resolver: ScriptedLevelResolver(entries: {race: raceEntry(race)}),
      );
      addTearDown(bloc.close);
      final state = await started(bloc, race);
      expect(state.isRace, isTrue);
      expect(state.raceLive, isFalse);
      expect(state.acceptsInput, isFalse);

      bloc.add(const SlotTapped(red1));
      await pumpEventQueue();
      expect(bloc.state.data!.selectedSlotId, isNull);

      bloc.add(const RaceGateChanged(open: true));
      await pumpEventQueue();
      expect(bloc.state.data!.raceLive, isTrue);
      expect(bloc.state.data!.acceptsInput, isTrue);
      bloc.add(const SlotTapped(red1));
      await pumpEventQueue();
      expect(bloc.state.data!.selectedSlotId, red1);

      bloc.add(const RaceGateChanged(open: false));
      await pumpEventQueue();
      expect(bloc.state.data!.acceptsInput, isFalse);
    });

    test('the gate means nothing outside a race', () async {
      final bloc = buildBloc();
      addTearDown(bloc.close);
      final state = await started(bloc, const PlayRequest.campaign(1));
      expect(state.acceptsInput, isTrue);
      bloc.add(const RaceGateChanged(open: true));
      await pumpEventQueue();
      expect(bloc.state.data!.raceLive, isFalse);
    });
  });
}
