import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_game/core/base/base_async_state.dart';
import 'package:nesty_game/core/models/play_request.dart';
import 'package:nesty_game/core/models/reduce_motion_mode.dart';
import 'package:nesty_game/core/repository/fake_catalog_repository.dart';
import 'package:nesty_game/core/repository/fake_level_repository.dart';
import 'package:nesty_game/core/repository/fake_level_resolver.dart';
import 'package:nesty_game/core/repository/fixture_levels.dart';
import 'package:nesty_game/core/services/app_info/fake_app_info_service.dart';
import 'package:nesty_game/core/services/clock/fake_clock.dart';
import 'package:nesty_game/core/services/daily/fake_daily_service.dart';
import 'package:nesty_game/core/services/database/fake_database_service.dart';
import 'package:nesty_game/core/services/notifications/fake_notification_service.dart';
import 'package:nesty_game/core/services/reminder/daily_reminder.dart';
import 'package:nesty_game/core/services/remote_config/fake_remote_config_service.dart';
import 'package:nesty_game/core/services/remote_config/remote_config_keys.dart';
import 'package:nesty_game/core/services/save/fake_save_service.dart';
import 'package:nesty_game/core/services/save/save_document.dart';
import 'package:nesty_game/features/chapters/cubit/chapters_cubit.dart';
import 'package:nesty_game/features/gameplay/bloc/gameplay_bloc.dart';
import 'package:nesty_game/features/home/cubit/home_cubit.dart';
import 'package:nesty_game/features/records/cubit/records_cubit.dart';
import 'package:nesty_game/features/settings/cubit/settings_cubit.dart';

import '../features/gameplay/bloc/support/bloc_fixtures.dart';

/// The plumbing the M7 phase-1 contracts froze and implemented
/// (docs/plans/m7-design.md §1): each lane owns the full behaviour tests
/// of its part; these pin that the frozen surface is wired.
void main() {
  group('ChaptersCubit (m7-design §11)', () {
    test('won levels replay with their best, the current one plays, the '
        'rest are locked', () async {
      final entries = FixtureLevels.entries();
      final save = FakeSaveService(
        initial: SaveDocument(
          currentLevel: 3,
          highestLevel: 3,
          levelBests: {'${entries.first.level.id}@${entries.first.version}': 9},
        ),
      );
      final cubit = ChaptersCubit(
        save,
        FakeLevelRepository(entries: entries),
        FakeCatalogRepository(),
      );
      addTearDown(cubit.close);
      await cubit.load();
      final chapter = cubit.state.data!.chapters.first;
      expect(chapter.levels, hasLength(20));
      // `target` (the level card's 3-star threshold, phase 4) rides on a
      // won level with a par; this pins the phase 1 fields.
      expect(
        chapter.levels[0].copyWith(target: null),
        const ChapterLevel(
          order: 1,
          status: ChapterLevelStatus.won,
          bestMoves: 9,
        ),
      );
      expect(chapter.levels[1].status, ChapterLevelStatus.won);
      expect(chapter.levels[1].bestMoves, isNull);
      expect(chapter.levels[2].status, ChapterLevelStatus.current);
      // Past the three fixture levels the bundle has none: locked.
      expect(chapter.levels[3].status, ChapterLevelStatus.locked);
      expect(chapter.won, 2);
      expect(chapter.levels[0].request, const PlayRequest.replay(1));
      expect(chapter.levels[2].request, const PlayRequest.campaign(3));
      expect(chapter.levels[3].request, isNull);
      expect(cubit.state.data!.chapters, hasLength(10));
    });
  });

  group('RecordsCubit (m7-design §12)', () {
    test('reads the summary from the save', () async {
      final save = FakeSaveService(
        initial: const SaveDocument(
          currentLevel: 3,
          highestLevel: 3,
          records: SaveRecords(families: 4, dolls: 8, badges: ['first_family']),
        ),
      );
      final cubit = RecordsCubit(
        save,
        FakeLevelRepository(entries: FixtureLevels.entries()),
      );
      addTearDown(cubit.close);
      await cubit.load();
      final summary = cubit.state.data!.summary;
      expect(summary.levelsWon, 2);
      expect(summary.families, 4);
      expect(summary.dolls, 8);
      expect(summary.badges, [BadgeId.firstFamily]);
      expect(summary.raceWins, [0, 0, 0]);
    });
  });

  group('SettingsCubit (m7-design §4, §15.5)', () {
    test('relaxed mode and reduce motion write the settings store', () async {
      final database = FakeDatabaseService();
      addTearDown(database.close);
      final cubit = SettingsCubit(
        database,
        FakeAppInfoService(),
        FakeSaveService(),
        DailyReminder(
          FakeNotificationService(),
          database,
          FakeDailyService(FakeClock()),
        ),
      );
      addTearDown(cubit.close);
      await cubit.load();
      expect(cubit.state.data!.relaxedMode, isFalse);
      expect(cubit.state.data!.reduceMotion, ReduceMotionMode.system);

      await cubit.setRelaxedMode(true);
      await cubit.setReduceMotion(ReduceMotionMode.off);
      expect(database.relaxedMode, isTrue);
      expect(database.reduceMotion, ReduceMotionMode.off);
      expect(cubit.state.data!.relaxedMode, isTrue);
      expect(cubit.state.data!.reduceMotion, ReduceMotionMode.off);
    });
  });

  group('HomeCubit (m7-design §15.8)', () {
    test('the flame and the vs Computer lock', () async {
      final config = FakeRemoteConfigService()
        ..setOverride(RemoteConfigKeys.raceUnlockLevel, 2);
      final levels = FakeLevelRepository(entries: FixtureLevels.entries());
      final save = FakeSaveService(
        initial: const SaveDocument(currentLevel: 3, highestLevel: 3),
      );
      final cubit = HomeCubit(
        save,
        levels,
        FakeLevelResolver(levels, save, config),
        FakeDailyService(FakeClock()),
        FakeCatalogRepository(),
        config,
        FakeDatabaseService(),
      );
      addTearDown(cubit.close);
      await cubit.load();
      final state = cubit.state.data!;
      expect(state.raceUnlockLevel, 2);
      expect(state.raceUnlocked, isTrue);
      expect(state.dailyLit, isFalse);
    });
  });

  group('GameplayBloc relaxed mode (m7-design §10)', () {
    test('is read at the start and followed live', () async {
      final settings = FakeDatabaseService();
      addTearDown(settings.close);
      await settings.setRelaxedMode(true);
      final bloc = buildBloc(settings: settings);
      addTearDown(bloc.close);

      bloc.add(const GameplayStarted(PlayRequest.campaign(1)));
      await expectLater(
        bloc.stream,
        emitsThrough(
          isA<AsyncValueData<GameplayState>>().having(
            (value) => value.data.relaxed,
            'relaxed',
            isTrue,
          ),
        ),
      );

      await settings.setRelaxedMode(false);
      await expectLater(
        bloc.stream,
        emitsThrough(
          isA<AsyncValueData<GameplayState>>().having(
            (value) => value.data.relaxed,
            'relaxed',
            isFalse,
          ),
        ),
      );
    });

    test('a replay is flagged on the state', () async {
      final bloc = buildBloc(
        save: FakeSaveService(
          initial: const SaveDocument(currentLevel: 2, highestLevel: 2),
        ),
      );
      addTearDown(bloc.close);
      bloc.add(const GameplayStarted(PlayRequest.replay(1)));
      final state = await bloc.stream
          .where((value) => value.hasData)
          .map((value) => value.data!)
          .first;
      expect(state.isReplay, isTrue);
      expect(state.play.rewardCoins, 0);
    });
  });
}
