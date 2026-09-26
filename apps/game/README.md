# nesty_game

The **Nesty: Doll Sort** mobile game for Android and iOS, built with Flutter +
Flame. Game rules come from [`nesty_core`](../../packages/nesty_core/README.md)
and doll drawing from [`nesty_render`](../../packages/nesty_render/README.md).
This app owns the screens, the services and the Flame board.

**Status: M0 skeleton.**
- Splash → Home → Gameplay is wired end to end, with placeholder, unstyled
  pages.
- The Flame board is empty until M2.
- In the real environment every service except haptics, the Remote Config
  defaults and the settings database is still an offline fake.

See [docs/PROGRESS.md](../../docs/PROGRESS.md).

## Run

There is no flavorless build and no `lib/main.dart`. Always pass the flavor
and its entry point:

| Flavor | Command (from `apps/game`) | Application / bundle id | Launcher name |
|---|---|---|---|
| dev | `flutter run --flavor dev -t lib/main_dev.dart` | `com.futrix.nesty.dev` | `[DEV] Nesty` |
| stg | `flutter run --flavor stg -t lib/main_stg.dart` | `com.futrix.nesty.stg` | `[STG] Nesty` |
| prod | `flutter run --flavor prod -t lib/main_prod.dart` | `com.futrix.nesty` | `Nesty` |

- Add `--dart-define=NESTY_FAKE_SERVICES=true` to a **debug** run to use
  all-fake, offline services. Profile and release builds ignore the define.
- For release builds, use `flutter build apk|appbundle|ipa --flavor prod -t
  lib/main_prod.dart`.
- Don't archive straight from Xcode. `FLUTTER_TARGET` is not pinned per
  configuration, so Xcode would use whatever entry point the last `flutter`
  command wrote to `ios/Flutter/Generated.xcconfig`.
  - A Run Script check stops the build with an error when that entry point
    or flavor doesn't match the scheme's `NESTY_FLAVOR`. The error names the
    command to run.
  - So an Xcode Archive or a fastlane `build_app(scheme:)` lane must first
    run `flutter build ipa --flavor <f> -t lib/main_<f>.dart` (PROGRESS.md
    D8).

## Folder structure

```text
lib/
  main_dev.dart, main_stg.dart, main_prod.dart   # set FlavorConfig, then bootstrap()
  bootstrap.dart           # error zone, portrait lock, DI (opens Hive), runApp
  app/
    app.dart               # MaterialApp.router: theme, l10n, 1.3x text-scale clamp
    localization_cubit/    # LanguageCubit (app lifetime, persisted locale)
  core/
    base/                  # AsyncValue<T>, BaseAsyncCubit<T>, BaseAsyncBloc<E, S>, runGuarded
    common_imports.dart    # barrel for the common imports
    dependency_injection/  # di.dart (`get`), app_env.dart, database_module.dart, di.config.dart (generated)
    error/                 # AppException + AppExceptionKind
    extensions/            # context.localizations, AppException -> localized message
    flavor/                # Flavor, FlavorConfig, FlavorValues
    models/                # small app-level enums (SymbolsMode)
    repository/            # LevelRepository + fake
    router/                # AppRouter + app_router.gr.dart (generated)
    services/<name>/       # one folder per service: interface, real, fake
    ui/                    # placeholder colors, theme, shared widgets (TODO(design))
  features/
    splash/  {cubit, pages}
    home/    {cubit, pages}
    gameplay/{pages, widgets, game/}   # game/ = NestyGame + Flame components
  l10n/                    # app_en.arb + generated AppLocalizations
test/
  app/, core/              # mirror lib/app and lib/core
  features/<name>/         # flat: <name>_cubit_test.dart, widget tests (booster_bar_test.dart)
  app_flow_test.dart       # Splash -> Home -> Gameplay with the real GameWidget
  helpers/                 # test_dependencies.dart wires the fake env
```

New features go in `features/<name>/{cubit,pages,widgets,model}`. The
`/feature` skill scaffolds one.

## How it fits together

- **Startup.**
  - `main_<flavor>.dart` sets `FlavorConfig`.
  - `bootstrap()` runs in `runZonedGuarded`, locks portrait and awaits
    `configureDependencies(environment: ...)`.
  - It then calls `runApp(App(router: get<AppRouter>()))`.
  - Firebase init goes in the marked `TODO(M4)` spot and must fail silently
    offline.
  - Uncaught errors reach the zone handler, which logs them and calls
    `FlutterError.reportError`, so they show in the `flutter run` terminal.
    Crashlytics reporting is added to this handler in M4.
- **State.**
  - Async cubits extend `BaseAsyncCubit<T>` and emit `AsyncValue<T>`, which
    has four cases: initial, loading, data and error.
  - `runGuarded(body)` works like this:
    - it emits data on success;
    - on failure it emits error with the previous data kept;
    - it emits nothing for `AppExceptionKind.cancelled`;
    - it never emits after `close()`;
    - in debug builds it also prints the failure to the `flutter run`
      terminal.
  - Cubits start unseeded, so `state.data` is null until the first data
    emit. Never write `state.data!`.
  - Pages render with an exhaustive `switch`. Errors reach the player
    through `exception.localizedMessage(context.localizations)`
    (`AppExceptionL10n` in `core/extensions/`), never through `message`.
  - Page cubits are `@injectable` factories. Each one is provided by its page
    through `AutoRouteWrapper`.
  - App-lifetime cubits are `@lazySingleton`s provided once in `App`.
    `LanguageCubit` mirrors the stored locale, so it extends `Cubit` directly
    (PROGRESS.md D14).
  - `BaseAsyncBloc` is kept for the M2 gameplay controller, which must handle
    pick, drop, undo and hint strictly in order.
    - It registers the bloc's only handler itself and runs events one at a
      time, in the order they were added.
    - Subclasses implement `handleEvent`. Calling `on<>` throws
      (PROGRESS.md D16).
- **DI.** Annotations only: `final get = GetIt.instance;`, and
  `di.config.dart` is generated.
  - The `real` and `fake` environments are separate from the flavors.
  - A service with no real implementation yet registers its fake for both
    environments.
  - The milestone that adds the real one moves the fake to `fake` only, and
    callers don't change.
- **Routing.** One `AppRouter` (`core/router/app_router.dart`) and
  `@RoutePage()` pages. Navigate with `context.router`. Arguments go through
  the generated constructors, for example `GameplayRoute(levelNumber: 3)`.
- **Hive** (`hive_ce`).
  - `DatabaseModule` is `@preResolve`d, so the boxes are opened exactly once,
    before `runApp`, in `<app documents>/hive`.
  - Features use the `DatabaseService` interface, never a `Box`.
  - If Hive can't open, `openOrFallback` logs the failure and uses the
    in-memory `FakeDatabaseService`. The game stays playable with default
    settings.
  - Box names (`hive_boxes.dart`), settings keys (`settings_schema.dart`) and
    typeIds (`hive_type_ids.dart`) are a storage contract and are never
    reused. 200 and 201 are reserved by `hive_ce_flutter`.
  - Where the M3 save document lives (Hive or the spec §13.3 JSON file) is
    still open.
- **Game truth.** Flame components (`features/gameplay/game/`) render
  `nesty_core` state and play its `MoveEvent`s. They never own or change
  game state (CLAUDE.md rules 2 and 10).
- **l10n.** `lib/l10n/app_en.arb` is the source of truth. Read strings with
  `context.localizations.key`. The `nullable-getter: false` setting means no
  `!` is needed.

## Services

| Interface | Real env today | Fake env | Real implementation arrives |
|---|---|---|---|
| `AdsService` | `FakeAdsService` (never ready, grants nothing) | `FakeAdsService` | M6 (AdMob, test IDs in debug) |
| `PurchaseService` | `FakePurchaseService` (declines) | `FakePurchaseService` | M6 (`in_app_purchase`) |
| `AnalyticsService` | `FakeAnalyticsService` (logs only) | `FakeAnalyticsService` | M4 (Firebase Analytics) |
| `RemoteConfigService` | `DefaultsRemoteConfigService` (the 17 spec §9.4 defaults) | `FakeRemoteConfigService` | M4 (Firebase Remote Config, same defaults) |
| `LevelRepository` | `FakeLevelRepository` (0 levels) | `FakeLevelRepository` | M2 (bundled levels), M4 (sync) |
| `SaveService` | `FakeSaveService` | `FakeSaveService` | M3 |
| `AudioService` | `FakeAudioService` | `FakeAudioService` | M3 |
| `HapticsService` | `SystemHapticsService` | `FakeHapticsService` | Done |
| `DatabaseService` | `HiveDatabaseService` (in-memory fallback) | `FakeDatabaseService` | Done |

Every network-backed implementation must fail silently (CLAUDE.md rule 3).

## Code generation

```bash
flutter gen-l10n            # after editing lib/l10n/app_en.arb
dart run build_runner build # freezed, injectable, auto_route, hive_ce
```

Run gen-l10n first. Commit the generated files and never edit them by hand;
CI fails on drift.

## Tests

```bash
flutter test
```

- **What is covered** (13 files, 53 tests):
  - the base cubit and bloc, including event order;
  - DI in both environments;
  - a database contract suite that the Hive and fake implementations both
    pass, plus the Hive locale stream on delete and rollback;
  - the Remote Config defaults (checked against the spec), haptics and the
    error-message mapper;
  - each cubit;
  - the booster bar at 320×568, 360×640 and 393×852, at 1.0× and 1.3× text;
  - the full Splash → Home → Gameplay flow with the real `GameWidget`.
- **Wiring:** tests use the fake environment through
  `test/helpers/test_dependencies.dart` (`configureTestDependencies()` /
  `resetDependencies()`).
- **Pumping:** the Flame game loop never settles, so widget tests use
  `pump(duration)`, not `pumpAndSettle`.

## Native projects

- **Android** (`android/app/build.gradle.kts`):
  - One `default` flavor dimension with `dev`, `stg` and `prod`.
  - `app_name` is set with `resValue`.
  - minSdk is pinned to 24. targetSdk and compileSdk come from Flutter.
  - The activity is portrait with `appCategory="game"`. Android 16 ignores
    portrait locks on large screens for other app categories.
  - Release signing is still debug signing (`TODO(M8)`).
- **iOS:**
  - Nine build configurations (`Debug-`, `Profile-`, `Release-` ×
    `dev`, `stg`, `prod`) and one shared scheme per flavor.
  - Each configuration sets `NESTY_FLAVOR`, which the Run Script flavor
    check compares with `Generated.xcconfig` (see [Run](#run)).
  - The Podfile maps every configuration.
  - Deployment target iOS 14.0.
  - iPhone is portrait only; iPad allows portrait and upside-down.
- **Firebase config:** `android/app/src/<flavor>/README.md` and
  `ios/config/<flavor>/README.md` say where each flavor's
  `google-services.json` and `GoogleService-Info.plist` go. The owner creates
  them with `flutterfire configure` (M4); never write them by hand.
