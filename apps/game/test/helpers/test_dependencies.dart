import 'package:nesty_game/core/dependency_injection/app_env.dart';
import 'package:nesty_game/core/dependency_injection/di.dart';
import 'package:nesty_game/core/flavor/flavor.dart';
import 'package:nesty_game/core/flavor/flavor_config.dart';
import 'package:nesty_game/core/flavor/flavor_values.dart';

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

/// Disposes singletons (closes cubits and the fake database) between tests.
Future<void> resetDependencies() => get.reset();
