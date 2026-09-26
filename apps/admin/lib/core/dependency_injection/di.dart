import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:nesty_admin/core/dependency_injection/app_env.dart';
import 'package:nesty_admin/core/dependency_injection/di.config.dart';

/// The app's service locator. Resolve with `get<Foo>()`; never register by
/// hand — every registration comes from injectable annotations, and the
/// generated `di.config.dart` is never edited.
final get = GetIt.instance;

/// Registers everything for [environment] ([AppEnv.real] or [AppEnv.fake]).
///
/// How implementations are swapped (CLAUDE.md rule 4):
/// * Callers only ever depend on the interface (`AuthService`, ...),
///   resolved through [get] or constructor injection.
/// * Each implementation declares which environments it serves:
///   `@LazySingleton(as: AuthService, env: [AppEnv.fake])`.
/// * Unlike the game, the admin does NOT run its fakes in the real env:
///   `FakeAuthService` accepts any credentials, so a real build would let
///   anyone in. Until M5, [AppEnv.real] gets `UnconfiguredAuthService`,
///   which lets nobody in. M5 replaces it with `FirebaseAuthService`
///   (`env: [AppEnv.real]`) and reruns build_runner; no caller changes.
///
/// `async` although nothing is `@preResolve`d yet (so the generated `init` is
/// synchronous): the signature stays identical to the game's and stable when
/// M5 adds an async Firebase module.
@InjectableInit()
Future<GetIt> configureDependencies({String environment = AppEnv.real}) async =>
    get.init(environment: environment);
