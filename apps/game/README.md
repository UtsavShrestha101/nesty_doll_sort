# nesty_game

The **Nesty: Doll Sort** mobile game for Android and iOS, built with Flutter +
Flame. Game rules come from [`nesty_core`](../../packages/nesty_core/README.md)
and doll drawing from [`nesty_render`](../../packages/nesty_render/README.md).
This app owns the screens, the services and the Flame board.

**Status: M2 code complete** (2026-09-27; its acceptance, 60 fps on a
mid-range Android, is the owner's device check).
- Splash → Home → Gameplay plays the 30 bundled levels end to end on the
  design's art: the tokens' theme, the Classic skin as part rasters, the
  board sprites, the chapter backgrounds, the 29 Lottie files (the
  designer's v3 export since the post-M2 round), the SFX, the music and
  jingles, and the haptic patterns.
- The Flame board renders `nesty_core`'s state and plays every `MoveEvent`
  through the board timeline; the HUD, booster bar, soft-stuck banner, win
  overlay, out-of-moves sheet, pause dialog and All Levels Done are Flutter
  widgets around it.
- The real environment runs the bundled levels, the isolate solver, the
  asset skin and FX library, SoLoud sound effects, jingles and music,
  system haptics and Hive settings. The save is in memory until M3; ads, purchases, analytics and
  Remote Config are offline stand-ins until M4 and M6.

See [docs/PROGRESS.md](../../docs/PROGRESS.md) (M2, D40–D58; the post-M2
round, D59–D61), [docs/plans/m2-lottie-design.md](../../docs/plans/m2-lottie-design.md)
and [docs/plans/audio-integration.md](../../docs/plans/audio-integration.md).

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
    repository/            # LevelRepository: bundled levels + fake
    router/                # AppRouter + app_router.gr.dart (generated)
    services/<name>/       # one folder per service: interface, real, fake (audio, haptics, save, skin, solver, …)
    ui/                    # theme and tokens, nesty_ui.dart (the tactile component kit), Lottie labels
  features/
    splash/   {cubit, pages}
    home/     {cubit, pages, showcase}   # showcase = the shelf dolls' art
    gameplay/ {bloc, game, overlays, pages, widgets}
      # bloc = GameplayBloc over GameSession; game = NestyGame, the Flame
      # components and the pure-Dart board timeline
    fx/                    # the Lottie runtime: FxId, specs, library, player, delegates, views
    dev/                   # the dev flavor's level picker
  l10n/                    # app_en.arb + generated AppLocalizations
assets/                    # synced from design/ by nesty_tools (never edit): skins, board, symbols, themes, audio, lottie; levels/bundle.json
test/
  app/, core/, features/   # mirror lib/
  app_flow_test.dart       # Splash -> Home -> PLAY -> a board tap -> Pause -> Home on fakes
  helpers/                 # test_dependencies.dart wires the fake env
integration_test/          # playthrough_test.dart: the on-device playthrough (flutter drive)
test_driver/               # integration_test.dart: saves the playthrough's screenshots on the host
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
- **Audio** (`core/services/audio/`, `core/services/music/`; PROGRESS D61).
  - One `SoLoudEngineHost` starts SoLoud for the sound effects and the music
    and stops it last. Low-latency output is on in prod only, so dev and stg
    screen recordings have sound (`Flavor.audioLowLatency`).
  - `SoLoudAudioService` plays the 17 WAV sound effects and, through its
    `JinglePlayer` side, the three OGG jingles on the SFX bus. Both follow
    the Sound setting.
  - `SoLoudMusicService` streams the two OGG loops (`loadMem` with
    `LoadMode.disk`), crossfades between them, ducks under overlays (the
    lowest duck wins), pauses in the background and for ads, and follows
    the Music setting (`DatabaseService.musicEnabledChanges`).
  - `MusicRouteObserver` picks the loop per screen (none on the splash,
    `music_game` in a level, `music_home` elsewhere). `MusicDuck` wraps the
    win overlay, the out-of-moves sheet and Pause. `JingleCues` holds the
    chapter-complete and reward moments for their M3 and M6 callers.
  - Timings, gains and duck factors come from tokens.json `sound`
    (`SoundTokens`). No tone is synthesized at runtime.

## Services

| Interface | Real env today | Fake env | Real implementation arrives |
|---|---|---|---|
| `AdsService` | `FakeAdsService` (never ready, grants nothing) | `FakeAdsService` | M6 (AdMob, test IDs in debug) |
| `PurchaseService` | `FakePurchaseService` (declines) | `FakePurchaseService` | M6 (`in_app_purchase`) |
| `AnalyticsService` | `FakeAnalyticsService` (logs only) | `FakeAnalyticsService` | M4 (Firebase Analytics) |
| `RemoteConfigService` | `DefaultsRemoteConfigService` (the 17 spec §9.4 defaults) | `FakeRemoteConfigService` | M4 (Firebase Remote Config, same defaults) |
| `LevelRepository` | `BundledLevelRepository` (the 30 levels of `assets/levels/bundle.json`) | `FakeLevelRepository` (levels 1–3) | Done; M4 adds the sync |
| `SaveService` | `InMemorySaveService` (level, coins, the booster wallet; PROGRESS D13) | `FakeSaveService` | M3 (the persistent save) |
| `AudioService` (+ `JinglePlayer`) | `SoLoudAudioService` (the 17 SFX and the 3 jingles) | `FakeAudioService` | Done; M7 the final mix |
| `MusicService` | `SoLoudMusicService` (the 2 streamed loops) | `FakeMusicService` (records calls, silent) | Done; M3 the meta screens, M6 the ad pause |
| `HapticsService` | `SystemHapticsService` (token patterns) | `FakeHapticsService` | Done |
| `DatabaseService` | `HiveDatabaseService` (in-memory fallback) | `FakeDatabaseService` | Done |
| `SolverService` | `IsolateSolverService` (hints and soft stuck off the UI isolate) | `FakeSolverService` | Done |
| `SkinService` | `AssetSkinService` (the bundled Classic skin as part rasters, board sprites, backgrounds) | `FakeSkinService` (placeholder dolls) | Done; M3 the shop's skin, M4 downloads |
| `FxLibrary` | `AssetFxLibrary` (the 29 Lottie files, parsed at splash) | `FakeFxLibrary` | Done |

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

- **What is covered** (96 files, 1,045 tests on 2026-09-27):
  - the base cubit and bloc, DI in both environments, the database contract
    suite, Remote Config defaults and the error-message mapper;
  - every service: bundled levels, the skin service, the isolate solver,
    audio pitch and combos, the shared SoLoud engine, the music service on
    a fake-clock backend (crossfades, ducks, pauses, the setting), the
    route observer and ducks, haptic patterns, the in-memory save;
  - the Lottie runtime: the shipped files, their specs, the image-slot
    compensation and the travel remap, the clean seek on a jump, pools,
    reduced motion, hot-path guards, and Level 9's board pieces against
    `BoardLayout`;
  - the gameplay bloc (tap and drag policy, boosters, hints, soft stuck,
    win, out of moves, next level), the board timeline's §7 times and the
    Flame board (input, hand-offs, effects, pause, rendering);
  - the screens and widgets on several phone sizes at 1.0× and 1.3× text;
  - the app flow on fakes (`app_flow_test.dart`).
- **On a device:** `integration_test/playthrough_test.dart` plays levels 1
  and 2 to the win overlay, shows level 9's hint and two extra slots, runs
  level 16 into Out of Moves, pauses with Music off and on, goes home and
  opens level 21's chapter ribbon, with every real service. It checks the
  music's state on each screen, that every Lottie file, sound effect and
  jingle loaded and that no audio or Lottie failure was logged, and saves
  25 screenshots (the root README has the command).
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
  - `AppDelegate.swift` sets the audio session to `.ambient`: the game
    mixes with the player's own music and follows the silent switch
    (PROGRESS Q61). flutter_soloud leaves the category alone.
- **Firebase config:** `android/app/src/<flavor>/README.md` and
  `ios/config/<flavor>/README.md` say where each flavor's
  `google-services.json` and `GoogleService-Info.plist` go. The owner creates
  them with `flutterfire configure` (M4); never write them by hand.
