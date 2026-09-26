import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_core/nesty_core.dart';
import 'package:nesty_game/core/base/base_async_state.dart';
import 'package:nesty_game/core/repository/fake_level_repository.dart';
import 'package:nesty_game/core/services/analytics/analytics_service.dart';
import 'package:nesty_game/core/services/analytics/fake_analytics_service.dart';
import 'package:nesty_game/core/services/remote_config/fake_remote_config_service.dart';
import 'package:nesty_game/core/services/save/fake_save_service.dart';
import 'package:nesty_game/core/services/save/save_service.dart';
import 'package:nesty_game/core/services/solver/fake_solver_service.dart';
import 'package:nesty_game/core/services/solver/solver_service.dart';
import 'package:nesty_game/features/gameplay/bloc/gameplay_bloc.dart';

import '../../../../helpers/level_fixtures.dart';
import 'scripted_solver_service.dart';

/// Slot ids of the Level 1 tutorial ([tutorialLevelJson]): red3 at r0c0,
/// red2 at r0c2, red1 at r1c1; r0c1, r1c0 and r1c2 empty.
const red3 = 'r0c0';
const red2 = 'r0c2';
const red1 = 'r1c1';
const emptyTop = 'r0c1';
const emptyBottom = 'r1c0';

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
/// the app's default makes it free). The solver and save it was built with
/// are available through [scriptedSolverOf] and [saveOf].
GameplayBloc buildBloc({
  List<LevelBundleEntry>? entries,
  SolverService? solver,
  FakeRemoteConfigService? config,
  SaveService? save,
  AnalyticsService? analytics,
  bool freeExtraSlots = false,
  Duration softStuckDebounce = const Duration(milliseconds: 5),
}) {
  final usedConfig = config ?? FakeRemoteConfigService();
  final usedSolver = solver ?? FakeSolverService();
  final usedSave = save ?? FakeSaveService(remoteConfig: usedConfig);
  final bloc = GameplayBloc(
    FakeLevelRepository(entries: entries ?? [entryFor(tutorialLevel)]),
    usedSolver,
    usedConfig,
    usedSave,
    analytics ?? FakeAnalyticsService(),
    freeExtraSlots: freeExtraSlots,
    softStuckDebounce: softStuckDebounce,
  );
  _solvers[bloc] = usedSolver;
  _saves[bloc] = usedSave;
  return bloc;
}

final Expando<SolverService> _solvers = Expando();
final Expando<SaveService> _saves = Expando();

/// The [ScriptedSolverService] [bloc] was built with.
ScriptedSolverService scriptedSolverOf(GameplayBloc bloc) =>
    _solvers[bloc]! as ScriptedSolverService;

/// The save [bloc] was built with.
SaveService saveOf(GameplayBloc bloc) => _saves[bloc]!;

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
