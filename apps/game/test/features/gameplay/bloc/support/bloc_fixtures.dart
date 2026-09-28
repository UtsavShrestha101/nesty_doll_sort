import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_core/nesty_core.dart';
import 'package:nesty_game/core/base/base_async_state.dart';
import 'package:nesty_game/core/models/intro_mechanic.dart';
import 'package:nesty_game/core/models/play_entry.dart';
import 'package:nesty_game/core/models/play_request.dart';
import 'package:nesty_game/core/repository/fake_level_repository.dart';
import 'package:nesty_game/core/repository/fake_level_resolver.dart';
import 'package:nesty_game/core/repository/level_resolver.dart';
import 'package:nesty_game/core/services/analytics/analytics_service.dart';
import 'package:nesty_game/core/services/analytics/fake_analytics_service.dart';
import 'package:nesty_game/core/services/clock/fake_clock.dart';
import 'package:nesty_game/core/services/daily/daily_service.dart';
import 'package:nesty_game/core/services/daily/fake_daily_service.dart';
import 'package:nesty_game/core/services/remote_config/fake_remote_config_service.dart';
import 'package:nesty_game/core/services/save/fake_save_service.dart';
import 'package:nesty_game/core/services/save/save_document.dart';
import 'package:nesty_game/core/services/save/save_service.dart';
import 'package:nesty_game/core/services/solver/fake_solver_service.dart';
import 'package:nesty_game/core/services/solver/solver_service.dart';
import 'package:nesty_game/features/gameplay/bloc/gameplay_bloc.dart';

import '../../../../helpers/level_fixtures.dart';
import 'scripted_solver_service.dart';

/// Slot ids of the default test board ([defaultLevelJson]): red3 at r0c0,
/// red2 at r0c2, red1 at r1c1; r0c1, r1c0 and r1c2 empty.
const red3 = 'r0c0';
const red2 = 'r0c2';
const red1 = 'r1c1';
const emptyTop = 'r0c1';
const emptyBottom = 'r1c0';

/// The M2 board shape (one color, maxSize 3, 2 shelves), but id `T0001`
/// rather than the real `L0001`: ordinary gameplay tests use this so they
/// never trip the M3 scripted tutorial (m3-design §10.4), which gates on
/// `L0001`/`L0002` specifically. The dedicated tutorial tests use the
/// shared `tutorialLevel` (real id `L0001`) instead.
const defaultLevelJson = '''
{
  "schemaVersion": 1,
  "id": "T0001",
  "maxSize": 3,
  "shelves": [
    [ {"type": "open", "nest": ["red3"]},
      {"type": "open", "nest": null},
      {"type": "open", "nest": ["red2"]} ],
    [ {"type": "open", "nest": null},
      {"type": "open", "nest": ["red1"]},
      {"type": "open", "nest": null} ]
  ]
}
''';

final Level defaultLevel = levelFrom(defaultLevelJson);

/// One shelf where moving the left tower's top (blue1) into the empty
/// r0c3 leaves every slot full and nothing mergeable (spec §2.3): red1,
/// red3, blue3, blue1 on top; red2 and blue2 buried in the towers.
const outOfMovesLevelJson = '''
{
  "schemaVersion": 1,
  "id": "T0002",
  "maxSize": 3,
  "shelves": [
    [ {"type": "tower", "stack": [["red2"], ["red1"], ["blue1"]]},
      {"type": "tower", "stack": [["blue2"], ["red3"]]},
      {"type": "open", "nest": ["blue3"]},
      {"type": "open", "nest": null} ]
  ]
}
''';

/// The tutorial board with red2 frozen under one layer of ice (spec §3.4):
/// r0c2 can be neither picked nor targeted until a set completes.
const icedLevelJson = '''
{
  "schemaVersion": 1,
  "id": "T0003",
  "maxSize": 3,
  "shelves": [
    [ {"type": "open", "nest": ["red3"]},
      {"type": "open", "nest": null},
      {"type": "open", "nest": ["red2"], "ice": 1} ],
    [ {"type": "open", "nest": null},
      {"type": "open", "nest": ["red1"]},
      {"type": "open", "nest": null} ]
  ]
}
''';

final Level tutorialLevel = levelFrom(tutorialLevelJson);
final Level outOfMovesLevel = levelFrom(outOfMovesLevelJson);
final Level icedLevel = levelFrom(icedLevelJson);

/// A bloc on explicit fakes (the DI graph is not involved). The save
/// defaults to a fresh [FakeSaveService] reading [config], and +1 Slot uses
/// the inventory unless [freeExtraSlots] (tests run in debug mode, where
/// the app's default makes it free). [resolver] defaults to a
/// [FakeLevelResolver] over [entries] (or [defaultLevel] at order 1);
/// supply one directly for a bonus/daily/chapter-complete entry the shared
/// fake can't build. The session codec is left at the bloc's own default
/// (the real `GameSessionCodec.encode`/`.decode`, m3-design §4, now that the
/// core-codec lane has landed it), so a restore test exercises the real
/// round trip rather than a stand-in. The solver, save, resolver and daily
/// service it was built with are available through [scriptedSolverOf],
/// [saveOf], [resolverOf] and [dailyOf].
GameplayBloc buildBloc({
  List<LevelBundleEntry>? entries,
  SolverService? solver,
  FakeRemoteConfigService? config,
  SaveService? save,
  AnalyticsService? analytics,
  LevelResolver? resolver,
  FakeDailyService? daily,
  FakeClock? clock,
  bool freeExtraSlots = false,
  Duration softStuckDebounce = const Duration(milliseconds: 5),
}) {
  final usedConfig = config ?? FakeRemoteConfigService();
  final usedSolver = solver ?? FakeSolverService();
  final usedSave = save ?? FakeSaveService(remoteConfig: usedConfig);
  final levels = FakeLevelRepository(
    entries: entries ?? [entryFor(defaultLevel)],
  );
  final usedClock = clock ?? FakeClock();
  final usedDaily = daily ?? FakeDailyService(usedClock);
  final usedResolver =
      resolver ?? FakeLevelResolver(levels, usedSave, usedConfig);
  final bloc = GameplayBloc(
    levels,
    usedSolver,
    usedConfig,
    usedSave,
    analytics ?? FakeAnalyticsService(),
    usedResolver,
    usedDaily,
    usedClock,
    freeExtraSlots: freeExtraSlots,
    softStuckDebounce: softStuckDebounce,
  );
  _solvers[bloc] = usedSolver;
  _saves[bloc] = usedSave;
  _resolvers[bloc] = usedResolver;
  _dailies[bloc] = usedDaily;
  return bloc;
}

final Expando<SolverService> _solvers = Expando();
final Expando<SaveService> _saves = Expando();
final Expando<LevelResolver> _resolvers = Expando();
final Expando<DailyService> _dailies = Expando();

/// The [ScriptedSolverService] [bloc] was built with.
ScriptedSolverService scriptedSolverOf(GameplayBloc bloc) =>
    _solvers[bloc]! as ScriptedSolverService;

/// The save [bloc] was built with.
SaveService saveOf(GameplayBloc bloc) => _saves[bloc]!;

/// The [LevelResolver] [bloc] was built with.
LevelResolver resolverOf(GameplayBloc bloc) => _resolvers[bloc]!;

/// The [FakeDailyService] [bloc] was built with.
FakeDailyService dailyOf(GameplayBloc bloc) =>
    _dailies[bloc]! as FakeDailyService;

/// A [FakeSaveService] that counts [saveInProgress] calls, so a test can
/// assert a save happened after every applied move, undo, restart and +1
/// Slot, and never for a rejected move (m3-design §3.4).
class CountingSaveService extends FakeSaveService {
  int saveInProgressCalls = 0;

  @override
  void saveInProgress(InProgressLevel level) {
    saveInProgressCalls++;
    super.saveInProgress(level);
  }
}

/// A fresh [FakeSaveService] with every [IntroMechanic] already marked
/// seen (m3-design §10.4), for a test whose fixture level happens to carry
/// towers, a lock or ice ([outOfMovesLevel], [icedLevel]) but is exercising
/// something else entirely (tap policy, boosters, out of moves): otherwise
/// the intro card's `acceptsInput == false` would silently swallow every
/// tap the test sends, and the test would pass for the wrong reason. The
/// dedicated "intro cards" group builds its own fresh or partly seeded save
/// instead, to test the gating itself.
FakeSaveService saveWithIntrosSeen() {
  final save = FakeSaveService();
  for (final mechanic in IntroMechanic.values) {
    save.markIntroSeen(mechanic);
  }
  return save;
}

/// A fresh [FakeSaveService] holding exactly [hints] and [extraSlots]
/// boosters (the starter gifts where null).
FakeSaveService saveWith({int? hints, int? extraSlots}) {
  final save = FakeSaveService();
  void hold(BoosterKind kind, int? count) {
    if (count == null) return;
    while (save.boosterCount(kind) > count) {
      save.useBooster(kind);
    }
    save.addBoosters(kind, count - save.boosterCount(kind));
  }

  hold(BoosterKind.hint, hints);
  hold(BoosterKind.extraSlot, extraSlots);
  return save;
}

/// An `AsyncValueData` whose state matches [matcher].
Matcher dataWhere(Matcher matcher) =>
    isA<AsyncValueData<GameplayState>>().having((s) => s.data, 'data', matcher);

/// An `AsyncValueData` whose state carries [effect].
Matcher effectIs(Object? effect) =>
    dataWhere(isA<GameplayState>().having((d) => d.effect, 'effect', effect));

/// The state of the bloc's last emission.
GameplayState dataOf(GameplayBloc bloc) => bloc.state.data!;

/// Lets queued events, solver futures and timers run.
Future<void> settle([Duration duration = const Duration(milliseconds: 20)]) =>
    Future<void>.delayed(duration);

/// A [PlayEntry] for [request] playing [level], for the win-path and
/// generated-start tests the shared [FakeLevelResolver] can't build
/// directly (a completing chapter, a bonus/daily entry with a chosen
/// reward).
PlayEntry playEntryFor(
  PlayRequest request,
  Level level, {
  Tier tier = Tier.easy,
  int levelVersion = 1,
  int rewardCoins = 10,
  String themeId = 'ch01',
  String? chapterId,
  bool completesChapter = false,
  LevelBundleEntry? bundleEntry,
}) => PlayEntry(
  request: request,
  level: level,
  tier: tier,
  levelVersion: levelVersion,
  rewardCoins: rewardCoins,
  themeId: themeId,
  chapterId: chapterId,
  completesChapter: completesChapter,
  bundleEntry: bundleEntry,
);
