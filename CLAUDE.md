# CLAUDE.md — Nesty: Doll Sort

Nesty is an offline-first, ad-supported hybrid-casual puzzle game for Android and iOS built with Flutter + Flame, plus a Flutter Web admin panel backed by Firebase for authoring levels and uploading art.

**The source of truth is `docs/GAME_SPEC.md`. Read it before starting any feature.** If the spec and code disagree, or the spec is ambiguous, stop and ask. Do not invent game rules.

Design exports live in `design/` (screens, `design/tokens.json`, skin SVGs). Match them. When a design is missing, use the tokens and the style described in the spec §12 and leave a `// TODO(design):` note. The owner adds `design/`; never create or edit anything in it.

## Repository layout (Dart pub workspace)

```
nesty/
  CLAUDE.md
  README.md                  # setup, run, codegen and test commands
  docs/
    GAME_SPEC.md             # full game + tech spec (source of truth)
    DESIGN_BRIEF.md          # the brief the design/ exports are made from
    PROGRESS.md              # you maintain this: milestone status, decisions, package reasons, open questions
  design/                    # exports from Claude Design (read-only for you; added by the owner)
  packages/nesty_core/       # PURE DART: models, rules, solver, generator, simulator, level codec
  packages/nesty_render/     # Flutter (no Flame): doll/slot painters, skin loading, layout math
  apps/game/                 # Flutter + Flame mobile game (dev/stg/prod flavors)
  apps/admin/                # Flutter Web admin panel
  firebase/                  # firestore.rules, storage.rules, firestore.indexes.json, firebase.json
  tools/                     # scripts (level bundle export, etc.)
  .claude/                   # settings.json (permissions + hooks), hooks/, rules/, agents/, skills/
  .github/workflows/ci.yaml  # format, analyze, all tests, generated-code drift check
  .vscode/                   # shared launch configs (one per app and flavor), extension recommendations
```

## Commands

No FVM: use `flutter` and `dart` from PATH (Flutter 3.41.2 stable with Dart 3.11, the version CI pins).

```
flutter pub get                                         # at repo root: resolves every workspace member
cd apps/<game|admin> && flutter gen-l10n                # after any .arb change; run before build_runner
cd apps/<game|admin> && dart run build_runner build     # freezed, injectable, auto_route, hive_ce outputs
cd packages/nesty_core && dart test                     # core rules/solver tests — must always pass
cd packages/nesty_render && flutter test
cd apps/<game|admin> && flutter test                    # cubit + widget tests on fake services
flutter analyze                                         # at repo root; zero issues (CI adds --fatal-infos --fatal-warnings)
cd apps/game && flutter run --flavor dev -t lib/main_dev.dart                                    # game: dev|stg|prod
cd apps/admin && flutter run -d chrome -t lib/main_dev.dart --dart-define=NESTY_FAKE_SERVICES=true  # admin
cd firebase && firebase emulators:start                 # local Auth/Firestore/Storage (needs firebase-tools)
```

- The game has no flavorless build: always pass `--flavor <f> -t lib/main_<f>.dart`.
- `--dart-define=NESTY_FAKE_SERVICES=true` switches a **debug** build to all-fake services (the only way to sign in to the admin before M5). Profile and release builds ignore it.
- `docs/PROGRESS.md` lists any command that is currently blocked and why.

The owner runs `flutterfire configure` to create Firebase config files. Never hand-write or invent `firebase_options.dart`, `google-services.json` or `GoogleService-Info.plist`.

## Hard rules

1. **Flutter stable channel only.** Do not use `flutter_scene`, Flutter GPU or any master-channel feature.
2. **All game rules live only in `nesty_core`** (pure Dart, no Flutter imports). The game, admin, solver, generator and simulator all call the same rule functions. Never re-implement a rule elsewhere.
3. **Offline-first.** The game must be fully playable with no network from first launch (bundled levels + bundled default skin). Every network call (Firestore, Storage, ads, IAP, Remote Config) must fail gracefully and silently.
4. **Services behind interfaces.** `AdsService`, `PurchaseService`, `AnalyticsService`, `RemoteConfigService`, `LevelRepository`, `SaveService`, `AudioService`, `HapticsService` each have a real implementation and a fake one. Debug builds and tests can switch to fakes.
5. **Ads:** use Google's official test ad unit IDs in debug builds. Real IDs come from build-time `--dart-define` values. Never commit real IDs or any secret.
6. **Remote Config:** every key has a hard-coded default in `RemoteConfigService` (spec §9.4).
7. **Deterministic core.** The generator and simulator take an explicit seed and use their own PRNG (spec §6.5), never `Random()` without a seed and never `DateTime.now()` inside core.
8. **Performance:** 60 fps on low-end Android (2 GB RAM). Rasterize skins once into cached `ui.Image`s. No per-frame allocation in hot paths. The on-device solver runs in an isolate.
9. **No new packages without a reason** written in `docs/PROGRESS.md`. Preferred packages are listed in spec §13.2.
10. **State management:** Cubit-first `flutter_bloc` for app/UI state. Async cubits extend `BaseAsyncCubit<T>` and emit the freezed `AsyncValue<T>` (`lib/core/base/`); use `BaseAsyncBloc` only where events must be handled strictly in order. Dependencies come from `get_it` + `injectable` annotations (`final get = GetIt.instance;`), never hand-registered. Flame components never own game truth; they render state from `nesty_core` and play animations from its `MoveEvent`s.

## Conventions

- **Routing:** `auto_route`, one `lib/core/router/app_router.dart` per app. Screens are `@RoutePage()` widgets. Navigate with `context.router`, never `Navigator.push`, and pass arguments through the generated route constructors.
- **DI environments:** `AppEnv.real` and `AppEnv.fake` pick implementations, and each implementation declares its environments. A service whose real implementation lands in a later milestone registers its offline fake for both until then. Tests use `configureTestDependencies()` from `test/helpers/`.
- **Models and states:** freezed 3 (`@freezed abstract class` for data classes, `@freezed sealed class` with public case classes for unions). Not in `nesty_core`, whose models are hand-written with `==`/`hashCode`.
- **Local storage:** Hive via `hive_ce`, in `apps/game` only (the admin keeps its data in Firestore). Boxes are opened once in bootstrap (`DatabaseModule`, `@preResolve`) and reached only through `DatabaseService`. If Hive can't open, the game falls back to in-memory settings. Box names (`HiveBoxes`), typeIds (`HiveTypeIds`) and field indexes are a contract with players' devices: never rename a box, never reuse an id or index, and never assign 200/201 (reserved by `hive_ce_flutter`).
- **Flavors:** dev, stg, prod. `lib/main_<flavor>.dart` sets `FlavorConfig`, then calls `bootstrap()`. Android uses product flavors, iOS uses `Debug-/Profile-/Release-<flavor>` build configurations with one scheme per flavor. Bundle ids are `com.futrix.nesty`, `.dev` and `.stg`.
- **Codegen:** build_runner (per app) and gen-l10n. Generated files (`*.freezed.dart`, `*.g.dart`, `*.gr.dart`, `di.config.dart`, `lib/l10n/app_localizations*.dart`) are committed and never hand-edited; CI fails if they are stale.
- **l10n:** each app's `lib/l10n/app_en.arb` is the source of truth. Read strings with `context.localizations.someKey`. Every key has a description.
- **Imports:** `package:` imports only. `lib/core/common_imports.dart` is each app's barrel.

## Code style

- Dart 3, sound null safety, `very_good_analysis`-style lints (or `flutter_lints` + strict analysis options).
- Immutable models in core with `==`/`hashCode`. The solver uses its own compact state encoding for speed.
- Small files, feature-first folders: `apps/<app>/lib/features/<name>/{cubit,pages,widgets,model}`.
- User-facing strings go through ARB localization from day one (English first).
- Comments explain *why*. Link spec sections like `// Spec §4.3`.

## Testing

- Every rule in spec §4 has a unit test in `nesty_core`, including invalid moves.
- Solver: known-solvable and known-unsolvable fixtures in `packages/nesty_core/test/fixtures/`.
- Level codec: round-trip tests, plus schema validation tests (spec §5.3).
- Generator: same seed + params must give identical output. All generated levels must be solvable.
- Apps: `bloc_test` for cubits and widget tests for the main flows, using fake services (`AppEnv.fake`).

## Workflow

- Work milestone by milestone as ordered in spec §18. Don't start the next milestone until the current one's acceptance criteria pass.
- At the end of each milestone: run `flutter analyze` and all tests, then update `docs/PROGRESS.md` with what was done, decisions made and open questions.
- Before any art exists, render dolls with the procedural placeholder painter (spec §12.5) so the game is fully playable early.

## Git

- Conventional commits: `feat(game): ...`, `fix(core): ...`, `docs: ...`, `chore(ci): ...`.
- No `Co-Authored-By` trailer or any other Claude attribution in commits or PRs.
- Never force-push.
