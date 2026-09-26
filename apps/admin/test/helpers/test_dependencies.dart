import 'package:nesty_admin/core/dependency_injection/app_env.dart';
import 'package:nesty_admin/core/dependency_injection/di.dart';
import 'package:nesty_admin/core/flavor/flavor.dart';
import 'package:nesty_admin/core/flavor/flavor_config.dart';
import 'package:nesty_admin/core/flavor/flavor_values.dart';
import 'package:nesty_admin/core/services/auth/auth_service.dart';
import 'package:nesty_admin/core/services/auth/fake_auth_service.dart';

/// Test flavor. `FlavorConfig` keeps the first value it's given, so every
/// test in a run sees this one.
const testFlavorValues = FlavorValues(appTitle: '[TEST] Nesty Admin');

/// Fresh DI graph on the all-fake, in-memory environment: no Firebase, no
/// network. Pair with `tearDown(resetDependencies)`.
Future<void> configureTestDependencies() async {
  FlavorConfig(flavor: Flavor.dev, values: testFlavorValues);
  await get.reset();
  await configureDependencies(environment: AppEnv.fake);
}

/// Disposes singletons (closes cubits and the fake auth stream) between
/// tests.
Future<void> resetDependencies() => get.reset();

/// The registered fake, to flip its knobs (`isAdmin`, `failSignInWith`).
FakeAuthService get fakeAuth => get<AuthService>() as FakeAuthService;
