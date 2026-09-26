import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:nesty_game/core/dependency_injection/app_env.dart';
import 'package:nesty_game/core/dependency_injection/di.config.dart';

/// The app's service locator. Resolve with `get<Foo>()`; never register by
/// hand — every registration comes from injectable annotations, and the
/// generated `di.config.dart` is never edited.
final get = GetIt.instance;

/// Registers everything for [environment] ([AppEnv.real] or [AppEnv.fake]).
///
/// How implementations are swapped (CLAUDE.md rule 4):
/// * Callers only ever depend on the interface (`AdsService`,
///   `SaveService`, ...), resolved through [get] or constructor injection.
/// * Each implementation declares which environments it serves:
///   `@LazySingleton(as: AdsService, env: [AppEnv.fake, AppEnv.real])`.
/// * Today, services without a real implementation register their offline
///   fake for BOTH environments. When a milestone adds the real one (e.g.
///   M6 `AdMobAdsService` with `env: [AppEnv.real]`), it removes
///   `AppEnv.real` from the fake's `env` list and reruns build_runner. No
///   caller changes; exactly one implementation per environment, always.
/// * Haptics, Remote Config (defaults) and the Hive database already have
///   separate real and fake implementations.
///
/// `DatabaseModule` is `@preResolve`d, so awaiting this also opens Hive —
/// exactly once, before `runApp`.
@InjectableInit()
Future<GetIt> configureDependencies({String environment = AppEnv.real}) =>
    get.init(environment: environment);
