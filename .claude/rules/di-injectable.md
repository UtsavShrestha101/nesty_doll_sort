---
name: di-injectable
description: Dependency injection with get_it 9 + injectable 3 (annotations only, real/fake environments).
paths:
  - "apps/*/lib/core/dependency_injection/**"
  - "apps/*/lib/core/services/**"
  - "apps/*/lib/core/repository/**"
  - "apps/*/lib/bootstrap.dart"
  - "apps/*/lib/main_*.dart"
  - "apps/*/test/helpers/**"
---

# DI rules (get_it 9.3 + injectable 3.0)

- **Annotations only.** The locator is `final get = GetIt.instance;` in
  `lib/core/dependency_injection/di.dart`. Never call `get.registerXxx(...)` by
  hand, and never edit `di.config.dart`: it is generated, and the
  block-generated hook refuses edits to it.
- `@injectable` means a factory: a new instance on every resolve. It is the
  default for page cubits.
- `@lazySingleton` creates one instance on first resolve. It is the default for
  services, repositories, `AppRouter` and app-lifetime cubits.
- `@singleton` builds the instance at startup. Use it sparingly, because it
  slows the splash (spec §10.2 #1).
- Bind an interface with `@LazySingleton(as: AdsService, env: [...])` on the
  implementation. Callers depend only on the interface.
- Third-party objects and anything async to create go in a `@module` in
  `core/dependency_injection/`. `@preResolve` means `configureDependencies()`
  awaits it; that is how Hive is opened exactly once before `runApp`
  (`database_module.dart`).
- After any annotation change, run `cd apps/<app> && dart run build_runner build`,
  then check the binding appears in `di.config.dart`.

## Real vs fake: environments, not `if` statements (CLAUDE.md rule 4)

- `AppEnv.real` and `AppEnv.fake` (`app_env.dart`) are injectable environments.
  They are separate from the dev/stg/prod flavors.
- Every service has an interface, a real implementation and a fake. Each
  implementation declares the environments it serves.
- If a service's real implementation arrives in a later milestone, its fake is
  registered for **both** environments until then (for example `FakeAdsService`
  until M6). When the real one lands, remove `AppEnv.real` from the fake's
  `env` list. Exactly one implementation per environment, always.
- `bootstrap.dart` picks the environment: `AppEnv.fake` only in `kDebugMode`
  with `--dart-define=NESTY_FAKE_SERVICES=true`. Features never branch on
  `kDebugMode` to choose an implementation.
- Tests that need the whole graph call `configureTestDependencies()` from
  `test/helpers/test_dependencies.dart` (all-fake env: no Hive, no platform
  channels, no network) with `tearDown(resetDependencies)`. Unit tests should
  build the class under test directly with explicit fakes.

## Don't

- Don't use `get<T>()` inside a method body. Inject through the constructor.
  At a widget/route boundary, `get<FooCubit>()` inside `BlocProvider.create`
  is fine.
- Don't use injectable 2's `includeMicroPackages` (removed in 3.0). If a package
  ever ships its own module, register it with `externalPackageModulesBefore`/`After`.
- `nesty_core` and `nesty_render` do not use DI. They are plain libraries the
  apps construct or wrap.
