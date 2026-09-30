import 'package:nesty_game/core/dependency_injection/app_env.dart';
import 'package:nesty_game/core/dependency_injection/di.dart';
import 'package:nesty_game/core/flavor/flavor.dart';
import 'package:nesty_game/core/flavor/flavor_config.dart';
import 'package:nesty_game/core/flavor/flavor_values.dart';
import 'package:nesty_game/core/services/save/fake_save_service.dart';
import 'package:nesty_game/core/services/save/save_document.dart';
import 'package:nesty_game/core/services/save/save_service.dart';

/// Test flavor. `FlavorConfig` keeps the first value it's given, so every
/// test in a run sees this one.
const testFlavorValues = FlavorValues(appTitle: '[TEST] Nesty');

/// Fresh DI graph on the all-fake, in-memory environment: no Hive, no
/// platform channels, no network. Pair with `tearDown(resetDependencies)`.
Future<void> configureTestDependencies() async {
  FlavorConfig(flavor: Flavor.dev, values: testFlavorValues);
  await get.reset();
  await configureDependencies(environment: AppEnv.fake);
}

/// Swaps the DI's `SaveService` for one with a level already won
/// (`highestLevel: 2`, `currentLevel` left at 1), so the splash opens Home:
/// a fresh save now opens Level 1 instead (E9, m7-design §13). For the
/// whole-app tests whose subject starts at Home; "Play level 1" still
/// shows. Call it after [configureTestDependencies], before the app is
/// pumped.
Future<void> seedSavePastFirstLevel() async {
  await get.unregister<SaveService>();
  get.registerSingleton<SaveService>(
    FakeSaveService(initial: const SaveDocument(highestLevel: 2)),
  );
}

/// Disposes singletons (closes cubits and the fake database) between tests.
Future<void> resetDependencies() => get.reset();
