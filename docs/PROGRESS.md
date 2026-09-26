# Progress — Nesty: Doll Sort

The running record of the project (CLAUDE.md "Workflow"): milestone status,
decisions with their reasons, why each package is here (CLAUDE.md rule 9), and
open questions. The spec is [GAME_SPEC.md](GAME_SPEC.md); milestones and their
acceptance criteria come from spec §18.

Last updated: 2026-09-26.

## Status

| Milestone | Status | Acceptance criteria (spec §18) |
|---|---|---|
| **M0 — Architecture skeleton** | ✅ Done 2026-09-26, no open blocker | Analyze clean, every test passes, every app builds. All met: analyze clean, tests 32/5/53/47, every flavor's APK, the iOS dev/prod builds and the admin web build succeed (see [Verification](#verification-2026-09-26-in-the-repo)) |
| M1 — Core (`nesty_core`) | Not started | All §4 rules unit-tested. Solver fixtures pass. Generator is deterministic. 100 generated levels pass validation and solve |
| M2 — Playable game (placeholder art) | Not started | Levels 1–30 playable start to finish at 60 fps on a mid-range Android device |
| M3 — App shell and meta | Not started | Kill the app mid-level and it resumes exactly where it was. The daily puzzle is identical on two devices on the same date |
| M4 — Firebase content | Not started | Airplane mode on first launch: fully playable. Levels published in the admin appear on the next app resume |
| M5 — Admin panel | Not started | The owner can build, solve, simulate, playtest and publish a level, and upload a skin that then shows up in the game |
| M6 — Monetization | Not started | Every §9.1 pacing rule is unit-tested with a fake clock. Offline ad buttons fall back to coins correctly |
| M7 — Art and polish | Not started | Matches the design screens. No layout overflows on 5 test screen sizes (small Android, standard phone, tall phone, small iPhone, iPad portrait) |
| M8 — Release prep | Not started | Release builds run on real Android and iOS devices with production Firebase |

M0 is not in spec §18. It is the pre-M1 architecture pass the owner asked for:
"internal setups like base cubits, Hive, folder architecture, packages". No
game rule, solver, generator or codec was written, and the UI is unstyled
placeholders until the owner adds the `design/` exports.

### Blocker B1 (resolved 2026-09-26): auto_route 11.2.0 does not compile on the installed Flutter

- **Symptom:** `auto_route-11.2.0/lib/src/router/widgets/eager_page_view.dart:283`
  passes `Viewport(scrollCacheExtent: ...)`. The local SDK (Flutter 3.41.2
  underneath, see D15) only has `cacheExtent`/`cacheExtentStyle`. auto_route
  still declares `flutter: >=3.16.0`, so pub accepted it.
- **Impact while open:** anything that imported the router failed to compile:
  `flutter run`, every app build and 2 test files per app
  (`app_flow_test.dart`, `di_test.dart`). `flutter analyze` did not catch it,
  because it doesn't compile dependencies.
- **Fix (applied 2026-09-26, Q1):** `auto_route: 11.1.0` (exact, no caret) in
  both `apps/game/pubspec.yaml` and `apps/admin/pubspec.yaml`, then
  `flutter pub get` at the root.
  - The lock diff was auto_route 11.2.0 → 11.1.0, plus dropping
    `material_ui` and `cupertino_ui` 0.0.1, which only 11.2.0 pulled in.
  - Codegen output stayed byte-identical. Every app test and build passes
    (see Verification).
- **This is the rule-9 reason for the pin** (see the auto_route row under
  Package reasons). Revisit it when the local Flutter is upgraded (Q23) to
  an SDK that has `Viewport.scrollCacheExtent`. Bump auto_route in the same
  change, then update this entry, that row and `.claude/rules/auto-route.md`.

## M0 — Architecture skeleton — done (2026-09-26)

The skeleton was built on 2026-09-25. On 2026-09-26 B1 was fixed, an
infrastructure pass finished `.claude/`, CI, hooks, launch configs,
`firebase/` and `.gitignore`, and a review and fix pass followed (see
[Review pass](#review-pass-2026-09-26)).

### Done

**Workspace and tooling**
- Dart pub workspace at the root with four members: `packages/nesty_core`,
  `packages/nesty_render`, `apps/game` and `apps/admin`. Members use
  `resolution: workspace`, and the only lockfile is the root `pubspec.lock`.
- Strict `analysis_options.yaml` in every member.
- `.github/workflows/ci.yaml` pins Flutter `3.41.2` on the stable channel
  (D15). Every job starts with `flutter pub get --enforce-lockfile`. It has
  three jobs:
  - Format, analyze and test: format check, `flutter analyze --fatal-infos
    --fatal-warnings`, and the tests of all four members.
  - Codegen drift: gen-l10n and build_runner per app, then
    `git diff --exit-code` plus a check for new untracked files.
  - Build: the game's dev debug APK (JDK 17) and the admin's web build. iOS
    needs a macOS runner, so it is built locally.
- `.claude/`:
  - `settings.json` with permissions, and commit/PR attribution turned off.
    Write/Edit of signing material (`*.pem`, `*.keystore`, `*.jks`,
    `*.p12`, `*.p8`, `key.properties`) is denied.
  - Hooks:
    - `block-secrets` blocks secret-looking content and secret paths (env
      files, keystores, service-account JSON, flutterfire output).
    - `block-generated` blocks edits to generated files, Flutter tool
      outputs, `pubspec.lock` and `design/`.
    - `format-on-write` formats Dart files as they are written.
    - `test-on-stop` runs the core tests when core changed. It needs no git,
      and it is skipped before the first `pub get`.
  - Rules per topic, agents, and 13 skills (`/plan`, `/feature`, `/test`,
    `/milestone`, `/debug`, `/perf-profile`, `/review`, `/pr`, `/commit`
    and others).
- `.vscode/launch.json`:
  - Game: one config per flavor, plus "Game [DEV] (profile mode, physical
    device)".
  - Admin: one config per flavor, plus "Admin [DEV] (Chrome, fake
    services)", which passes `--dart-define=NESTY_FAKE_SERVICES=true`.
- `firebase/` holds the rules (the spec §14.3 sketch, semantics unchanged),
  the `levels(status, order)` index, emulator config and
  `.firebaserc.example`. The rules were checked once on the emulators (see
  Verification). The gaps found are in `firebase/README.md` and Q20.
- `.gitignore` covers build outputs, Flutter tool outputs, secrets,
  `CLAUDE.local.md` and `.claude/settings.local.json`. Generated Dart,
  `Podfile.lock`, the root `pubspec.lock`, the Xcode schemes and
  `gradle-wrapper.properties` are tracked. A scan of everything a scratch
  `git init` copy would commit found no secrets, real ad unit ids or local
  `/Users` paths. The Gradle wrapper scripts are the exception to the
  tracking list (Q27).
- `tools/README.md` lists the planned scripts. None is implemented.
- Docs:
  - Root `README.md`, and a README for each app and package.
  - `CHANGELOG.md` at `0.1.0 — skeleton` in both packages.
  - This file.
  - Spec §13.1 and §13.2 amended for D1/D2, and nothing else in the spec.

**`packages/nesty_core`** (pure Dart)
- `DollColor` covers the 11 colors of spec §12.3, each with a stable codec
  `id`. Gold has `isWild` (§3.5). A strict `fromId` throws
  `FormatException` for anything else.
- An architecture guard test fails if `lib/` does any of these:
  - imports Flutter, Flame, `dart:ui` or a platform-specific `dart:` library;
  - references `dart:math` `Random` or constructs an unseeded `Random`;
  - reads the clock (`DateTime.now()`, `DateTime.timestamp()` or
    `Stopwatch`).

  It also fails if the pubspec gains a Flutter SDK dependency. A self-test
  proves that each guard fires.
- `test/fixtures/README.md` sets the solver fixture convention.
- The README lays out the planned M1 modules.

**`packages/nesty_render`** (Flutter, no Flame)
- `DollPalette.of(DollColor)` returns a const `DollSwatch` with the exact
  §12.3 hex values. Gold uses a placeholder gradient.
- The `DollRenderer` interface (§12.6) has `prepare`, `paintDoll` and
  `dispose`. The painters themselves come in M2 and M7.
- The template `Calculator` is removed.

**`apps/game`** (Flutter + Flame, Android + iOS)
- **Startup:** `lib/main_dev|stg|prod.dart` sets `FlavorConfig`, then calls
  `bootstrap()`. bootstrap runs in `runZonedGuarded`, locks portrait, awaits
  `configureDependencies`, then calls `runApp`. Uncaught errors go through
  `FlutterError.reportError` (D17).
- **Base layer** (`lib/core/base/`):
  - `AsyncValue<T>`, a freezed sealed union.
  - `BaseAsyncCubit<T>` and `BaseAsyncBloc<E, S>`, which share one
    `runGuarded` implementation. `BaseAsyncBloc` handles events one at a
    time, in order (D16).
  - `AppException` with an `AppExceptionKind`. `AppExceptionL10n`
    (`core/extensions/`) maps each kind to an ARB string, as in the admin.
- **DI:** injectable environments `real` and `fake`. Hive is opened once
  through the `@preResolve` `DatabaseModule`.
- **Hive** (`hive_ce`): one `settings` box of primitives, holding the §13.3
  defaults. There is a typeId registry, and the game falls back to in-memory
  settings when Hive can't open.
- **Services:** all eight rule-4 services, plus `DatabaseService`, sit behind
  interfaces with offline fakes. Real implementations exist for Haptics,
  Remote Config (the 17 hard-coded §9.4 defaults) and the database.
- **Screens:**
  - An auto_route router with Splash → Home → Gameplay.
  - `GameplayPage` hosts a Flame `NestyGame` with an empty `BoardComponent`,
    between a placeholder top bar and booster bar. The booster bar fits
    320–393 dp wide phones at 1.3× text.
  - `LanguageCubit` persists the locale.
  - English ARB with 10 keys.
  - Placeholder theme tokens and a text-scale clamp at 1.3× (§16).
- **Native flavors:** dev, stg and prod on Android (product flavors) and iOS
  (9 build configurations and 3 schemes).
  - Bundle ids: `com.futrix.nesty.dev`, `com.futrix.nesty.stg` and
    `com.futrix.nesty`.
  - Minimum OS: Android minSdk 24, iOS 14.0.
  - Portrait only. Android sets `appCategory="game"` so the portrait lock
    also holds on large screens.
  - iOS stops the build when the Dart entry point or flavor doesn't match
    the scheme (D8).
- **Tests:** 13 test files (53 tests). They cover:
  - the base cubit and bloc, including event order and misuse of `on<>`;
  - DI in both environments;
  - a database contract suite shared by the Hive and fake implementations,
    plus the Hive locale stream on delete and on rollback;
  - the Remote Config defaults, haptics and the error-message mapper;
  - the cubits;
  - the booster bar at three phone sizes and two text scales;
  - the full Splash → Home → Gameplay flow with the real `GameWidget`.

**`apps/admin`** (Flutter Web)
- **Shared layer:** the same base layer, flavors, DI and bootstrap as the
  game, but no Hive and no orientation lock.
- **Auth:**
  - `AuthService` has two implementations. `FakeAuthService` serves the fake
    env. `UnconfiguredAuthService` serves the real env until M5, and nobody
    can sign in with it.
  - `AuthGuard` holds the whole access policy: signed out goes to Login,
    non-admin to Not authorized, admin to the shell.
  - `SessionCubit` follows auth changes, and `App` re-enters the router root
    whenever the session changes.
- **Screens:**
  - Login, with a form and `LoginCubit`.
  - Not authorized.
  - A `NavigationRail` shell with nine spec §15 sections. The Levels tab is
    a nested stack that includes `/levels/:levelId`.
  - Every section is a localized "Coming in M5" placeholder.
- **Tests:** 8 test files (47 tests), including 11 guard and flow tests.

### Verification (2026-09-26, in the repo)

These are the final results after the fix pass. "Docs pass" rows were re-run
at the very end, on the files as they are now. The "Fix pass" rows ran after
the last code change. The "Infrastructure pass" rows ran before the fix
pass changed code.

| Command | Outcome | Run in |
|---|---|---|
| `flutter pub get --enforce-lockfile` (root) | exit 0; `pubspec.lock` unchanged | Docs pass |
| `flutter gen-l10n` + `dart run build_runner build` in each app | 0 outputs written; all 15 generated files byte-identical | Docs pass |
| `flutter analyze --fatal-infos --fatal-warnings` (root) | No issues found | Docs pass |
| `dart format --output=none --set-exit-if-changed` (all non-generated Dart) | 141 files, 0 changed | Docs pass |
| `cd packages/nesty_core && dart test` | 32/32 pass | Docs pass |
| `cd packages/nesty_render && flutter test` | 5/5 pass | Docs pass |
| `cd apps/game && flutter test` | 53/53 pass | Docs pass |
| `cd apps/admin && flutter test` | 47/47 pass | Docs pass |
| `flutter build apk --flavor prod -t lib/main_prod.dart` (release) | Builds (45.7 MB). aapt2: `com.futrix.nesty`, label `Nesty` | Docs pass |
| `flutter build apk --debug --flavor dev\|stg\|prod -t lib/main_<f>.dart` | All three build. aapt2: `com.futrix.nesty.dev` `[DEV] Nesty`, `com.futrix.nesty.stg` `[STG] Nesty`, `com.futrix.nesty` `Nesty` | Fix pass |
| `flutter build ios --debug --no-codesign --flavor dev\|prod -t lib/main_<f>.dart` | Both build. dev: `com.futrix.nesty.dev`, `[DEV] Nesty`; prod: `com.futrix.nesty`, `Nesty`. `pod install` left `project.pbxproj` and `Podfile.lock` unchanged | Fix pass |
| `xcodebuild -scheme dev -configuration Debug-dev` with `Generated.xcconfig` on prod | Fails as intended: "FLUTTER_TARGET=lib/main_prod.dart does not match the dev configuration" (D8) | Fix pass |
| `cd apps/admin && flutter build web -t lib/main_prod.dart` | Builds | Fix pass |
| The `ci.yaml` steps on a clean copy with Flutter 3.41.2 (macOS arm64) | With nesty_render's floor at `>=3.41.0` (the fix the fix pass then applied): `--enforce-lockfile` passes, format, analyze and tests are clean (30/5/42/45, before the fix pass added tests), codegen is identical, and the web build and dev debug APK build | Infrastructure pass |
| Firestore and Storage rules on the emulators (firebase-tools 13.35.1 in a scratch copy of `firebase/`) | Both compile; 34/34 allow/deny checks as expected | Infrastructure pass |
| `block-generated` and `block-secrets` fed Claude Code JSON for Write, Edit and MultiEdit | 116/116 block/allow cases as expected. `format-on-write` and `test-on-stop` scenarios also behave as intended | Infrastructure pass |

Not verified yet:
- `flutter run` on a device.
- iOS profile and release builds, `flutter build ipa` (needs the owner's
  signing, Q11) and Xcode Archive.
- The VS Code launch configs.
- `firebase emulators:start` from `firebase/` itself, including the Auth
  emulator. The Firebase CLI is not installed on this machine.
- CI on GitHub: there is no git repository or remote yet. The simulation
  above ran on macOS, not `ubuntu-latest`, so the Linux-only
  `grep -z`/`xargs --no-run-if-empty` format step and `setup-java` were not
  exercised. actionlint 1.7.7 passed, but without shellcheck.

## Review pass (2026-09-26)

**What was reviewed.** After the infrastructure pass, five reviews ran in
parallel over the whole repo:
- parity with the aquabuildr reference app;
- CLAUDE.md rules and spec compliance;
- Dart code in the apps and packages;
- the native Android and iOS projects;
- infrastructure: CI, hooks, settings and docs.

Each finding was then checked by a separate verifier.

| Review | Findings | Confirmed | Refuted | Uncertain |
|---|---|---|---|---|
| aquabuildr parity | 8 | 8 | 0 | 0 |
| Rules and spec | 9 | 6 | 2 | 1 |
| Dart | 6 | 5 | 1 | 0 |
| Native | 2 | 2 | 0 | 0 |
| Infrastructure | 10 | 10 | 0 | 0 |
| **Total** | **35** | **31** | **3** | **1** |

The 31 confirmed findings break down as follows:
- **2 blockers**, both with the same cause: CI pinned Flutter 3.41.2, but
  `nesty_render` required `>=3.43.0-0`.
- **2 majors:** the documented "Flutter 3.43+ stable" does not exist, and
  `BaseAsyncBloc` did not keep event order.
- **25 minors and 2 nits.**

The uncertain finding became Q28.

**Fixed in code** (the fix pass; each new regression test failed on the old
code first):
- **CI blocker:** nesty_render's floor is now `flutter: ">=3.41.0"`. The only
  lock change is `sdks.flutter`, and `--enforce-lockfile` passes (D15).
- **Bloc order:** `BaseAsyncBloc` in both apps now handles events strictly
  in order (D16). Before the fix, a fast event overtook a slow one added
  before it (`[20, 10]` instead of `[10, 20]`).
- **Booster bar:** it no longer overflows on narrow phones or at 1.3× text.
  The old bar overflowed by 170 px at 360×640.
- **Hive locale stream:** `HiveDatabaseService.languageStream` now emits the
  default locale when the key is deleted or a write rolls back. Before, it
  re-emitted the deleted or rolled-back value as if it were stored.
- **Error output:** errors now show in the `flutter run` terminal (D17).
- **iOS flavor guard:** iOS builds stop when the entry point or flavor
  doesn't match the scheme (D8).
- **Core guard:** it now bans `Stopwatch` in `nesty_core`.
- **Error messages:** the game got the admin's `AppExceptionL10n` error
  mapper, and `RetryView` takes the exception.
- **Tooling docs** in `.claude/`:
  - the copyWith idiom and unseeded cubits (D1);
  - the app-lifetime Cubit exception (D14);
  - the canonical example feature (`apps/game/lib/features/home/`);
  - the analytics fake (log-only until M4);
  - `AIza…` keys inside flutterfire output being expected;
  - the test-layout examples.

Result: tests went from 30/5/42/45 to 32/5/53/47. Generated files are
unchanged.

**Fixed in docs** (this pass): B1, Q1, Q2, Q13 and Q22 are now marked
resolved. The SDK version is corrected in CLAUDE.md, README and PROGRESS.
The CI description, the fake-services launch config, the emulator
statements and the iOS archive note are updated. D14–D17 are added.

**Not applied:**
- The `rm -rf` deny globs in `.claude/settings.json`. Changing permission
  settings is the owner's call (Q24).
- Two findings were overtaken by the infrastructure pass: the `/plan` skill
  now exists, and the tooling now describes the flat test layout the tests
  already use.

**Known gaps (not questions):**
- The hooks guard only Write/Edit/MultiEdit. A Bash redirect such as
  `echo … > .env` bypasses them, and the `settings.json` deny list doesn't
  cover it.
- The three `.metadata` files record Flutter revision `5408e0f…`, a local
  commit that doesn't exist upstream (Q23).
- The bootstrap zone handler's `FlutterError.reportError` call has no test,
  because no test calls `bootstrap()`.
- In debug, `runGuarded` prints every non-cancelled failure. Tests that
  exercise expected failures print a few extra lines.

## Decisions log

D1–D13 are dated 2026-09-25, and D14–D17 2026-09-26. D1, D8 and D12 were
amended on 2026-09-26.

- **D1. aquabuildr stack instead of Riverpod / go_router (owner decision).**
  The owner asked for "base cubits" and "Hive" on the pattern of the team's
  existing aquabuildr app. So the app layer uses:
  - Cubit-first `flutter_bloc`, with `BaseAsyncCubit<T>` and the freezed
    `AsyncValue<T>`.
  - `get_it` + `injectable` (annotations only; the generated `di.config.dart`
    is never edited).
  - `auto_route` (one `app_router.dart` per app).
  - freezed models and states.
  - dev/stg/prod flavors with `main_<flavor>.dart`, `FlavorConfig` and
    `bootstrap.dart`.
  - ARB l10n through `context.localizations`.
  - A `common_imports.dart` barrel and feature-first folders.

  This replaces the original "Riverpod" in CLAUDE.md rule 10 and the
  `go_router`/Riverpod in spec §13.1. Spec §13.1 and §13.2 are amended to
  match, and §13.3 is unchanged (see Q3). CLAUDE.md's rule 10, Commands and
  Conventions were updated on 2026-09-26 (Q2). Every other hard rule still
  applies, including the second half of rule 10: Flame components never own
  game truth.

  Deliberate differences from aquabuildr's base layer (amended 2026-09-26):
  - **Method name:** `runguarded` is `runGuarded`. The bloc version is
    `runGuarded(emit, body)`, and both versions share one `resolveGuarded`
    body, so they can't drift apart.
  - **Error case:** `AsyncValue.error` carries a typed
    `AppException exception` (an `AppExceptionKind` plus a log-only
    `message`) instead of `String message` + `int? statusCode`. There is no
    REST backend (D3), and the UI maps the kind to an ARB string instead of
    showing text. As a result, `errorMessage`/`getErrorStatus` are replaced
    by `exceptionOrNull`, and `onError` receives the `AppException`.
  - **Pattern matching:** the union is `sealed` and its case classes are
    public (`AsyncValueData` and the others), so pages can use exhaustive
    `switch`es. The `initial` getter is renamed `isInitial`.
  - **Cancellation:** `AppExceptionKind.cancelled` replaces
    `NetworkExceptionTypes.cancel`. The bloc also swallows it and supports
    `onError`.
  - **No seeding:** cubits start unseeded (`AsyncValue.initial()` with no
    data), where aquabuildr emits `AsyncValue.initial(data: FooState())` in
    an init method. `state.data` is therefore null until the first data
    emit. Never write `state.data!`; the idiom is in
    `.claude/rules/bloc-cubit.md`.
  - **Bloc order:** `BaseAsyncBloc` registers its only handler itself (D16).
- **D2. Hive via `hive_ce`, game only.** The owner asked for Hive.
  `hive`/`hive_generator` 2.x can't resolve against analyzer 10, which the
  current freezed 3, injectable 3 and auto_route_generator 10 need.
  `hive_ce` is the maintained fork with the same API.
  - The admin is Flutter Web and keeps its data in Firestore, so it has no
    local database.
  - The game has one `settings` box of primitives under
    `<documents>/hive`, so there are no adapters yet.
  - `HiveTypeIds` records the typeId/field-index contract and reserves 200
    and 201 for `hive_ce_flutter`.
  - `hive_ce_generator` is declared but produces nothing today.
- **D3. What was deliberately not copied from aquabuildr, and why.**
  - `dio` / `retrofit`: there is no REST backend. Content comes from
    Firestore and Storage (spec §13.4, §14).
  - `flutter_screenutil`: board layout is spec math in logical pixels
    (§10.3, `BoardLayout` in `nesty_render`), and menus must honour system
    text scaling up to 1.3× (§16). Global scale factors would fight both.
  - `flutter_gen`: no assets exist yet. Revisit when levels, audio or skins
    land (M2/M3/M7).
  - Sentry: crashes go to Firebase Crashlytics (spec §13.2, §14.4), and no
    DSN may be committed (rule 5).
  - FVM: one SDK, `flutter`/`dart` from PATH.
  - Firebase, `google_mobile_ads`, `in_app_purchase` and audio packages are
    postponed to M3, M4 and M6. `google_mobile_ads` crashes at launch without
    native App IDs.
- **D4. UI kept minimal until the owner supplies `design/`.** Pages are
  unstyled placeholders that exist so routing and flows are wired and tested.
  `AppColors` are placeholder tokens (`TODO(design)`, to be replaced by
  `design/tokens.json`). Fonts are not bundled yet. Claude never creates
  `design/`.
- **D5. Fakes first, swapped by DI environment.**
  - Each implementation declares its injectable environments.
  - A service without a real implementation registers its offline fake for
    both `real` and `fake`. The milestone that adds the real one removes
    `real` from the fake, and callers don't change.
  - bootstrap picks `fake` only when `kDebugMode &&
    NESTY_FAKE_SERVICES=true`, so a release build can never run on fakes.
  - The fakes used in the real env behave like a device with no network or
    store: no ads are ready, purchases are declined, and there are 0 levels.
    Nothing is handed out for free if a build ships early.
  - The admin is the exception: its real env uses `UnconfiguredAuthService`,
    because `FakeAuthService` accepts any credentials.
- **D6. The base layer is duplicated in both apps.** These are copied
  between `apps/game` and `apps/admin`, and differ only in package name and
  error kinds:
  - `core/base`
  - the `AppException` shape
  - flavor
  - `context_extension`
  - the test helper

  Extracting a shared package is Q8.
- **D7. Bundle id `com.futrix.nesty`.**
  - The Android `namespace` and `applicationId` are `com.futrix.nesty`.
  - dev and stg add the suffixes `.dev` and `.stg` on both platforms.
  - `MainActivity` moved to `com/futrix/nesty`.
  - minSdk is pinned to 24 and the iOS deployment target is 14.0 (spec §0).
  - Store ids are permanent once published, so Q10 asks the owner to confirm.
- **D8. Flavors dev / stg / prod.**
  - **App names:** `[DEV] Nesty`, `[STG] Nesty` and `Nesty: Doll Sort` in
    Dart (`FlavorValues.appTitle`). On the launcher they are `[DEV] Nesty`,
    `[STG] Nesty` and `Nesty`.
  - **iOS:** `Debug-/Profile-/Release-<flavor>` configurations on the base
    Flutter xcconfigs, and every configuration is mapped in the Podfile.
    `FLUTTER_TARGET` is deliberately not pinned per configuration, so `-t`
    keeps working. Always build with
    `--flavor <f> -t lib/main_<f>.dart`; a flavorless build fails fast.
  - **iOS flavor guard (amended 2026-09-26):** each of the 9 Runner
    configurations sets `NESTY_FLAVOR`.
    - The Run Script phase fails the build when `FLUTTER_TARGET` or `FLAVOR`
      in `Flutter/Generated.xcconfig` don't match it, for example after a
      `flutter run` of another flavor. The error message names the right
      command.
    - An Xcode Archive or a fastlane `build_app(scheme:)` lane must
      therefore first run `flutter build ipa --flavor <f> -t
      lib/main_<f>.dart`, or `flutter build ios --config-only` with the same
      flags.
    - A plain flavorless `flutter build ios` now also fails at this step.
    - Only debug device builds were tried. Profile, release and Archive
      were not.
  - **Android:** `appCategory="game"`, because Android 16 ignores portrait
    locks on large screens for other app categories.
- **D9. Generated code is committed.** CI regenerates it and fails on any
  difference, and a hook blocks hand edits. Codegen order: `flutter gen-l10n`
  first, then `dart run build_runner build`. build_runner 2.15 ignores
  `--delete-conflicting-outputs`.
- **D10. Admin access policy lives only in `AuthGuard`.** Navigation after a
  session change is centralised in `App`: it re-enters the router root and
  lets the guard decide. `resolver.redirectUntil` is not used, because
  `replaceAll` would leave held resolvers pending forever. So after the first
  sign-in the admin lands on the Dashboard rather than the deep link (Q6).
  URLs use the default hash strategy (Q7).
- **D11. The `nesty_core` purity rules are enforced by a test, not by
  review.** Core must also compile for the web admin (Solve / Simulate /
  Playtest in the browser). So only platform-neutral `dart:` libraries are
  allowed, and spawning the solver isolate is the game's job (rule 8).
- **D12. B1 fixed by pinning `auto_route: 11.1.0` exactly (amended
  2026-09-26).** Dependency sections were frozen for the skeleton pass on
  2026-09-25. The verified pin was applied in both apps on 2026-09-26 (Q1),
  instead of upgrading Flutter. The pin stays until the local SDK is
  upgraded (Q23).
- **D13. The save document (spec §13.3) is not built.** `SaveService`
  exposes only `load()` and `currentLevel` until M3 decides where the save
  lives (Q3).
- **D14. App-lifetime cubits that mirror a store extend `Cubit<S>`
  directly.** The game's `LanguageCubit` (persisted locale) and the admin's
  `SessionCubit` (auth stream) seed synchronously from their store and then
  follow its stream. So they always hold a value, and there is no initial or
  data-less state for `AsyncValue` to model.
  - `LanguageCubit` does an optimistic update with rollback, and
    `LanguageState` carries its own `isLoading`/`hasError` flags.
  - Every other async cubit, including the M3 Settings toggles, extends
    `BaseAsyncCubit<T>`.
  - The exception is written down in `.claude/rules/bloc-cubit.md`. Whether
    CLAUDE.md rule 10 should mention it is Q25.
- **D15. CI pins Flutter 3.41.2, and every member's `flutter:` bound stays at
  or below it.**
  - The local SDK prints "3.43.0-1.0.pre-35", but it is Flutter 3.41.2
    stable plus one local commit that only edits the SDK's own
    `pubspec.lock` (`git describe`: `3.41.2-1-g5408e0f3048`; same engine and
    Dart 3.11.0).
  - That version string is not a published release, so CI can't install it.
    3.41.2 is the published stable it is built on, and on it every package
    resolves to the committed lock.
  - nesty_render's `>=3.43.0-0` floor was accepted locally but rejected by a
    real 3.41.2, so it was relaxed to `>=3.41.0`, which is flame 1.38.2's
    floor. The only lock change was `sdks.flutter`.
  - Newer stables (3.44+, Dart 3.12+) re-resolve 5 SDK-pinned test packages
    (matcher, meta, test, test_api, test_core), which
    `--enforce-lockfile` rejects.
  - Upgrading means bumping the pin and committing the re-resolved lock in
    one change (Q23). This closes Q13.
- **D16. `BaseAsyncBloc` handles events strictly in order.**
  - bloc 9 runs handlers concurrently. Each `on<...>` registration also has
    its own subscription, so even a sequential transformer per event type
    doesn't order events of different types.
  - So the base class registers one handler over the base event type,
    through `asyncExpand`. This is FIFO without adding `bloc_concurrency`.
  - Subclasses implement `handleEvent` with an exhaustive `switch`, and
    calling `on<>` throws a `StateError`.
- **D17. Error output until Crashlytics (M4).**
  - `runGuarded` logs failures with `developer.log`, and in debug builds
    also with `debugPrint`, so they reach the `flutter run` terminal.
  - It does not use `FlutterError.reportError`: expected failures (a
    rejected sign-in, a failed load) aren't framework errors, and tests
    exercise them.
  - The bootstrap zone handler, which sees only uncaught errors, does call
    `FlutterError.reportError`. That prints in the `flutter run` terminal,
    and in release it logs a one-line summary to logcat or the device
    console.
  - Hive's in-memory fallback and `LanguageCubit`'s persist failure also
    `debugPrint` in debug.

## Package reasons (CLAUDE.md rule 9)

Versions are the resolved versions in the root `pubspec.lock`, checked
against every member's `pubspec.yaml` on 2026-09-26. "§13.2" says whether
spec §13.2 lists the package (it was amended for D1/D2). The root
`pubspec.yaml` only declares the workspace and has no dependencies. In the
apps every constraint is a caret on the locked version, except `auto_route`
(exact pin) and `intl` (`any`). In core, `lints: ^6.0.0` and
`test: ^1.25.6` are lower floors than the locked versions.

### Runtime dependencies

| Package | Locked | Used in | Why | §13.2 |
|---|---|---|---|---|
| `flutter` (SDK) | — | render, game, admin | UI framework. In `nesty_render`: `Color`, `Canvas`, `Rect`, `@immutable` for the palette and renderer interface. `nesty_render` declares `flutter: ">=3.41.0"`, kept at or below the CI pin (D15) | — |
| `flutter_localizations` (SDK) | — | game, admin | ARB localization delegates (spec §16) | yes |
| `intl` | 0.20.2 | game, admin | Required by the `gen-l10n` output. Constraint `any` because `flutter_localizations` pins the version | yes |
| `flame` | 1.38.2 | game | `NestyGame` (`FlameGame`), `BoardComponent`, `GameWidget` on the gameplay page | yes |
| `flutter_bloc` | 9.1.1 | game, admin | Cubit-first state management (D1): `BaseAsyncCubit`/`BaseAsyncBloc`, `BlocProvider`/`BlocBuilder`/`BlocListener` | yes |
| `bloc` | 9.2.1 | game, admin | Core Cubit/Bloc types, imported directly by the app-lifetime `LanguageCubit` and `SessionCubit` | yes |
| `get_it` | 9.3.0 | game, admin | Service locator (`final get = GetIt.instance`) | yes |
| `injectable` | 3.0.0 | game, admin | DI annotations: `real`/`fake` environments, `@preResolve` (Hive), `@disposeMethod` | yes |
| `auto_route` | 11.1.0 (pinned exactly) | game, admin | Routing (D1): `AppRouter`, `@RoutePage` pages, `AutoRouteWrapper`. Admin: guards, `AutoTabsRouter` shell, nested Levels stack. **Why the exact pin:** 11.2.0 calls `Viewport(scrollCacheExtent:)`, which Flutter 3.41.2 doesn't have (B1). Revisit when the SDK is upgraded (Q23) | yes |
| `freezed_annotation` | 3.1.0 | game, admin | `@freezed` on `AsyncValue` and the states (`LanguageState`, `SplashState`, `HomeState`, `SessionState`, `AdminUser`) | yes |
| `json_annotation` | 4.12.0 | game, admin | **Not used yet.** Declared for app-side JSON DTOs from M3–M5 (Firestore document wrappers §5.2/§14.1, cache files). Level JSON itself is never parsed here: it goes through `nesty_core`'s `LevelCodec` (rule 2). Remove it if M5 ends without a use | yes |
| `hive_ce` | 2.20.0 | game | Local database (D2): the `settings` box in `HiveDatabaseService`, and pure-Dart `Hive.init` in round-trip tests | yes |
| `hive_ce_flutter` | 2.3.4 | game | `Hive.initFlutter` in the app documents directory. Brings `path_provider` (§13.2) in transitively | yes |
| `nesty_core` (path) | 0.1.0 | render, game, admin | The single rule implementation (rule 2). `nesty_render` keys its palette and renderer API on `DollColor`. The apps declare it but do not import it yet (M1/M2) | — |
| `nesty_render` (path) | 0.1.0 | game, admin | Shared doll rendering and layout math. Declared, not imported yet (M2) | — |

### Dev dependencies

| Package | Locked | Used in | Why | §13.2 |
|---|---|---|---|---|
| `test` | 1.29.0 | core | Unit tests and the architecture guard | — |
| `lints` | 6.1.0 | core | Base lint set for core's strict `analysis_options.yaml` | — |
| `flutter_test` (SDK) | — | render, game, admin | Widget and unit tests | — |
| `flutter_lints` | 6.0.0 | render, game, admin | Base lint set for the Flutter members | — |
| `build_runner` | 2.15.1 | game, admin | Runs the freezed, injectable, auto_route and hive_ce generators | yes |
| `freezed` | 3.2.5 | game, admin | Generates `*.freezed.dart` | yes |
| `json_serializable` | 6.14.1 | game, admin | **Not used yet**, the pair of `json_annotation` above | yes |
| `injectable_generator` | 3.0.2 | game, admin | Generates `di.config.dart` | yes |
| `auto_route_generator` | 10.5.0 | game, admin | Generates `app_router.gr.dart`. Its output is byte-identical under auto_route 11.1.0 and compiles against it (B1) | yes |
| `hive_ce_generator` | 1.11.1 | game | No adapters yet (settings are primitives). Kept so the first `@GenerateAdapters` type needs no dependency change. It currently does nothing | yes |
| `bloc_test` | 10.0.0 | game, admin | `blocTest` for the base cubit/bloc, `LanguageCubit`, `SplashCubit`, `HomeCubit`, `LoginCubit`, `SessionCubit` | yes |
| `mocktail` | 1.0.5 | game, admin | Mocks for failure paths the fakes don't cover (a failing `SaveService`, `DatabaseService` or `AuthService.signOut`) | yes |

## Open questions

Owner decisions come first. Each one names the spec section or milestone it
blocks. Resolved questions stay here, checked, so their numbers are never
reused.

- [x] **Q1. B1: pin `auto_route: 11.1.0` or upgrade Flutter?** Resolved
  2026-09-26: pinned exactly in both apps (B1, D12). An SDK upgrade is Q23.
- [x] **Q2. Approve the CLAUDE.md update.** Resolved 2026-09-26: CLAUDE.md
  was updated. The owner approved it when choosing the aquabuildr stack,
  whose option text said CLAUDE.md rule 10 and spec §13 would be updated.
  The update covers:
  - rule 10 (Cubit-first `flutter_bloc`, `get_it` + `injectable`);
  - the flavored Commands, with no FVM;
  - a Conventions section;
  - the extended layout;
  - a Git section;
  - the rule that `design/` is owner-only.

  Later that day the docs pass corrected one fact in it, the Flutter version
  in Commands ("3.43+" → 3.41.2, D15).
- [ ] **Q3. Where does the M3 save document live (spec §13.3)?** In a Hive
  box, or in the spec's atomic JSON file (temp file + rename, schema version,
  migrations)? Today Hive holds only device settings. §13.3 is deliberately
  unchanged until this is decided.
- [ ] **Q4. What is the settings `symbols` value for large symbols?** §13.3
  shows only `"subtle"`. The large mode is "assist mode" in §10.2, §12.3 and
  §16, and "Large" in DESIGN_BRIEF Prompt 9. The skeleton persists
  `"assist"`.
- [ ] **Q5. Is `reward_medium` missing from spec §9.4?** §7.3 pays easy and
  medium 10 each, but §9.4 has only `reward_easy`, `reward_hard` and
  `reward_superhard`. Should medium read `reward_easy` (M3), or should a
  `reward_medium` key be added?
- [ ] **Q6. Deep links in the admin after the first sign-in (M5).** Should
  the admin return to the originally requested link (for example a shared
  `/levels/L0024`)? Today it lands on the Dashboard.
- [ ] **Q7. Hash URLs (`/#/levels`) or path URLs (`/levels`) for the admin
  (M5)?** Path URLs need `flutter_web_plugins` (an SDK package, with a reason
  recorded here) and a Firebase Hosting SPA rewrite.
- [ ] **Q8. Extract the duplicated base layer (D6) into a shared package,
  such as `packages/nesty_app_core`?** The error kinds differ per app, so
  the package would need a strategy for them.
- [ ] **Q9. Web-safe solver hashing (M1, spec §6.2).** In the browser a
  Dart `int` is a JS number: exact to 2^53, with 32-bit bitwise operators.
  The 64-bit canonical hash therefore needs a web-safe design, such as two
  32-bit halves or `fixnum`. `fixnum` is already in the lock transitively; a
  direct dependency would need a reason recorded here.
- [ ] **Q10. Confirm the bundle id `com.futrix.nesty` (and `.dev`, `.stg`)
  before any store upload.** It can't change after publishing.
- [ ] **Q11. Is `DEVELOPMENT_TEAM` `Z674BG8G6U` the right Apple team?** It
  came from `flutter create` on this machine.
- [ ] **Q12. How many Firebase projects: one per flavor or fewer?**
  `firebase/.firebaserc.example` assumes three (dev, stg, prod), and
  `flutterfire configure` then produces `firebase_options_<flavor>.dart` plus
  per-flavor `google-services.json` / `GoogleService-Info.plist`. The owner
  runs it (M4).
- [x] **Q13. CI Flutter version vs local.** Resolved 2026-09-26. CI pins
  `FLUTTER_VERSION: "3.41.2"`, the published stable the local SDK is built
  on. nesty_render's floor was relaxed to `>=3.41.0`, and every job runs
  `pub get --enforce-lockfile` (D15). Whether to upgrade is Q23.
- [ ] **Q14. Fonts.** DESIGN_BRIEF names Fredoka (display) and Nunito (body).
  They must be bundled as assets, not fetched at runtime with `google_fonts`
  (offline first launch, rule 3). Will the owner supply the font files with
  `design/`, or may they be added from the OFL releases?
- [ ] **Q15. The `design/` exports are missing.** These are needed:
  - `design/tokens.json`, which replaces the placeholder `AppColors`, the
    gold gradient and the doll ink/light shades;
  - the screens (game and admin);
  - `design/symbols/`;
  - the Classic skin SVG.

  Everything visual is `TODO(design)` until then.
- [ ] **Q16. iPad orientation.** iPad allows Portrait and PortraitUpsideDown,
  iPhone and Android allow portrait only. Should iPad be upright-only?
  Separately, `UIRequiresFullScreen` is deprecated in iPadOS 26 and should be
  rechecked in M7/M8.
- [ ] **Q17. Should dev and stg builds get distinct app icons and a
  `versionNameSuffix` (M8)?** Icons need design assets.
- [ ] **Q18. Can hidden tower nests show their size but not their color
  (spec §3.2)?** `DollRenderer` has a `silhouette` flag that ignores color.
  The paint-splash reveal (§11.1) is assumed to be composed by the caller.
  Confirm in M2.
- [ ] **Q19. Where does a solvable fixture record its expected optimal move
  count (M1)?** The suggestion is to keep fixture files as pure §5.1 level
  JSON and put the expectations in the test.
- [ ] **Q20. Tighten the spec §14.3 rules sketch for M5?** Both rules files
  keep the sketch's semantics. A one-off emulator check on 2026-09-26
  confirmed these gaps (details in `firebase/README.md`):
  - (a) The `firestore.rules` catch-all also matches `admins/{uid}`.
    Firestore ORs overlapping matches, so an existing admin can create or
    edit `admins/*` despite `allow write: if false`.
  - (b) The catch-all read has no `status` check, so draft `chapters`,
    `skins` and `themes` are publicly readable and listable, unlike draft
    levels.
  - (c) `dailyOverrides` for future dates are readable ahead of their date.
  - (d) Storage uploads have no size or content-type limits.

  Separately, the Storage admin check reads Firestore. The first
  `firebase deploy --only storage` must grant that access, or admin uploads
  fail.
- [ ] **Q21. Admin `web/manifest.json` still has the template's
  `portrait-primary` orientation and `#0175C2` colors.** For a desktop tool
  the orientation should probably go, and the colors should come from tokens
  once `design/` exists.
- [x] **Q22. No VS Code admin config passes
  `--dart-define=NESTY_FAKE_SERVICES=true`.** Resolved 2026-09-26: "Admin
  [DEV] (Chrome, fake services)" was added. The dev/stg/prod admin configs
  stay on real services, so they stop at Login until M5.
- [ ] **Q23. Stay on Flutter 3.41.2, or upgrade local and CI?**
  - **Upgrading** to a newer stable (3.44.x or 3.47.x) means bumping
    `FLUTTER_VERSION` in `ci.yaml` and committing the re-resolved lock in
    the same change. On 3.44.9, 5 test packages change (D15). It would also
    let auto_route move past the 11.1.0 pin (B1).
  - **The stray local commit:** should `~/development/flutter` drop its
    local "wip" commit (`5408e0f`, on top of the 3.41.2 tag, touching only
    the SDK's `pubspec.lock`)? Then it reports its real version, and the
    three `.metadata` files and future `flutter create` output stop
    recording a revision that doesn't exist upstream.
- [ ] **Q24. Relax the `rm -rf` deny globs in `.claude/settings.json`?**
  - `Bash(rm -rf /*)`, `Bash(rm -rf ~*)` and `Bash(rm -rf $HOME*)` deny
    every `rm -rf` of an absolute or home path, not only the root or home
    directory. That includes cleaning `apps/game/build` by its absolute
    path.
  - The proposal is to move them to `ask`, keeping exact denies for
    `rm -rf ~`, `~/`, `$HOME` and `$HOME/`.
  - This changes permission settings, so only the owner can decide it.
- [ ] **Q25. Should CLAUDE.md rule 10 name the D14 exception?** For
  example: "Async feature cubits extend `BaseAsyncCubit<T>` … (app-lifetime
  store mirrors excepted, see `.claude/rules/bloc-cubit.md`)". CLAUDE.md is
  the owner's file.
- [ ] **Q26. Use the same error-key names in both apps?** The game's
  generic failure key is `genericLoadFailed`, and the admin's is
  `errorGeneric`. Renaming it is an ARB edit plus gen-l10n. This is
  optional and a matter of style.
- [ ] **Q27. Commit the Gradle wrapper?** The root `.gitignore` no longer
  ignores `gradlew`, `gradlew.bat` and `gradle-wrapper.jar`, but the Flutter
  template's `apps/game/android/.gitignore` still does. Flutter recreates
  them on build, and a clean checkout builds fine.
  `gradle-wrapper.properties` is tracked either way.
- [ ] **Q28. Should the app title players see be localized?**
  `MaterialApp.title` comes from `FlavorValues.appTitle`, a hard-coded
  string in each `main_<flavor>.dart`: `'Nesty: Doll Sort'` in the game's
  prod entry point and `'Nesty Admin'` in the admin's (D8).
  - It shows in Android Recents and in the browser tab. In prod, Recents
    says "Nesty: Doll Sort" while the splash (ARB `appName`) and the
    launcher say "Nesty".
  - The option is `onGenerateTitle` with an ARB key, keeping only the
    `[DEV] `/`[STG] ` prefix in `FlavorValues`.
  - Or it can stay as a deliberately unlocalized brand name.
  - This was the review's one uncertain finding.

### Notes for later milestones (not questions)

- **M6:** before `google_mobile_ads` is added, the AdMob App IDs must be in
  place, or the app crashes at launch: `GADApplicationIdentifier` in
  `ios/Runner/Info.plist` and `com.google.android.gms.ads.APPLICATION_ID` in
  `AndroidManifest.xml` (test IDs in debug, rule 5).
- **M4:** Firebase init goes where the `TODO(M4)` comment is in each app's
  `bootstrap.dart`, and must fail silently offline.
- **M3:** `SystemHapticsService` maps spec §11.2 to single impacts. The
  multi-pulse "success pattern" is still to be tuned on devices.
- **Firebase CLI:** not installed on this machine.
  - What was checked: on 2026-09-26, firebase-tools 13.35.1 in a scratch
    directory ran `emulators:exec --only firestore,storage` against a copy
    of `firebase/`. It confirmed that the rules compile and behave as the
    §14.3 sketch says (34 checks, Q20).
  - What wasn't: `firebase emulators:start` from `firebase/`, the Auth
    emulator and the UI.
  - To install: `npm install -g firebase-tools`, which also needs a JDK.
  - Emulator-backed rules tests are to be added in M5.
- **iOS:** the first `flutter build ios` ran `pod install`. `Podfile.lock`
  and the CocoaPods changes to the Xcode project and workspace are meant to be
  committed.
- **M8:** any Xcode Archive or fastlane lane must run
  `flutter build ipa --flavor <f> -t lib/main_<f>.dart` first, or the D8 guard
  fails the build. Profile and release iOS builds haven't been tried yet.
- **Before the first push:** the owner runs `git init` and adds the remote.
  CI has only been simulated locally, so watch its first run on
  `ubuntu-latest`.

## Next step

1. Start **M1 — Core** in `packages/nesty_core`: models, codec, validator,
   rules, `GameSession`, PRNG, solver, simulator and generator (spec §4–§6),
   with the tests CLAUDE.md "Testing" requires. M0's acceptance criteria
   pass, and nothing blocks M1. Q9 (web-safe hashing) and Q19 (fixture
   expectations) should be answered early in M1.
2. Owner decisions that don't block M1 but are cheapest to take early: Q23
   (SDK upgrade), Q24 (deny globs), Q25 (rule 10 wording) and Q27 (Gradle
   wrapper).
