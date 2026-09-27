# Progress — Nesty: Doll Sort

The running record of the project (CLAUDE.md "Workflow"): milestone status,
decisions with their reasons, why each package is here (CLAUDE.md rule 9), and
open questions. The spec is [GAME_SPEC.md](GAME_SPEC.md); milestones and their
acceptance criteria come from spec §18. The work still to do is tracked in
[BACKLOG.md](BACKLOG.md), item by item and milestone by milestone. This file
doesn't copy it.

Last updated: 2026-09-27.

## Status

| Milestone | Status | Acceptance criteria (spec §18) |
|---|---|---|
| **M0 — Architecture skeleton** | ✅ Done 2026-09-26, no open blocker | Analyze clean, every test passes, every app builds. All met: analyze clean, tests 32/5/53/47, every flavor's APK, the iOS dev/prod builds and the admin web build succeed (see [Verification](#verification-2026-09-26-in-the-repo)) |
| **M1 — Core (`nesty_core`)** | ✅ Done 2026-09-26 (see [M1](#m1--core-nesty_core--done-2026-09-26)); owner questions Q30–Q38 confirmed 2026-09-26 | All §4 rules unit-tested. Solver fixtures pass. Generator is deterministic. 100 generated levels pass validation and solve. All met |
| M2 — Playable game (placeholder art; the design art was pulled in, D23) | **Code complete 2026-09-27; acceptance waits on the owner's device check.** Built: the nesty_render foundation, the 30 authored levels and `bundle check` in CI, the phase-4 Lottie contracts (D40–D52), every Lottie lane, the services, the bloc, the UI kit, the Flame board and the screens (D53–D57), then a review fix pass (12 of 13 findings fixed, D58). Every automated gate passes, including the on-device playthrough of L1, L2 and L16. Left: the 60 fps profile on a real mid-range Android (the owner's, steps in [M2 acceptance](#m2-acceptance-spec-18)) and the manual L1–30 pass (see [M2](#m2--playable-game--code-complete-acceptance-pending)). **Post-M2 round 2026-09-27:** Claude Design's v3 Lottie export and the audio delivery (music, jingles, SFX v2) imported and wired in, the owner's Level 9 hint and +1 Slot report fixed, every gate green again (see [Post-M2 round](#post-m2-round-claude-design-v3-and-audio-2026-09-27), D59–D61) | Levels 1–30 playable start to finish at 60 fps on a mid-range Android device |
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

## M1 — Core (`nesty_core`) — done (2026-09-26)

Built in parallel steps from [plans/m1-core-design.md](plans/m1-core-design.md)
(contracts, PRNG + Hash64 + parity harness, codec + validator + fixtures,
rules kernel + session, solver, simulator, generator + curve, bundle codec +
`nesty_levels`), then reviewed, fixed and integrated. The design-foundation
render work (plan phase 3: `BoardLayout`, the skin pipeline and renderers,
`BoardSprites` and `ThemeBackground`) and the 30 authored M2 levels were built
in the same round. Decisions are D26–D39; the owner confirmed their open
questions Q30–Q38 on 2026-09-26.

### Acceptance (spec §18)

| Criterion | Evidence | Result |
|---|---|---|
| All §4 rules are unit-tested | `test/rules/` and `test/session/`: every rule, every `InvalidMoveReason` with its precedence, towers, locks (first completion only), ice (cracked vs shattered), the exact event order and payloads, `legalMoves` order and completeness, won and out of moves, the §5.1 example as a 4-move scenario, undo, restart and extra slots | Pass |
| Solver fixtures pass | 8 solvable (optimal 2/3/4/5/3/2/2/12 moves), 3 unsolvable (lock deadlock, never-thawing ice, no space), and solvable 008 gives `unknown` at a 50-node budget. Every value was worked out by hand and confirmed by an independent Python implementation of §4; every solution replays through `Rules.tryMove` to `Won` | Pass |
| The generator is deterministic | 21 golden cases (level digest, attempt, tier, bot wins, solution length, nodes) and a parity suite, identical on the VM, node (dart2js), Chrome and dart2wasm; same seed + params give the same bytes | Pass |
| 100 generated levels pass validation and solve | `dart test -t slow`: bonus levels 1–100 (seed 1 000 000 + n) pass rules 1–8 on a fresh admin-budget solve and replay to `Won` (the bundle step also checked it with `nesty_levels generate --bonus 1 --count 100 --verify`) | Pass |

M1 is **done**. The benchmark targets of design §5 are not §18 criteria; two
of them are missed on exhaustive searches (below, Q32).

### M1 review and fix pass

A review of the finished M1 core and render work raised 19 findings. Each
was confirmed against the code before it was fixed (1 blocker, 3 major, 10
minor, 5 nits).

| Finding | Confirmed | Change |
|---|---|---|
| SPEC-01 (blocker) towerless L3–L15 can't meet the §6.6 pattern and A32 | Yes (proof in D26) | `BundlePolicy.checkTier` accepts a `tierOverride` on open-slot-only boards (D26, Q30); tests for both cases; `bundle check` passes |
| SPEC-02 / DETERMINISM-003 ice ≥ 2^31 wraps in `Int32List` | Yes (2^31 and 2^32 validated as solvable) | `LayoutLimits.maxIce` = 2^31 − 1: the validator reports `schema.valueOutOfRange`, `BoardLayout` refuses larger counters |
| SPEC-03 device-generated levels can be expert only | Yes (bonus 40 and 99 of 1–100) | Documented on `GeneratorSuccess.simulation`; test pins bonus 40's flag; the policy is an owner question (Q31). No behaviour change |
| DETERMINISM-001 CI never runs the web parity | Yes | CI step: `dart test -p node test/parity test/generator/golden_test.dart`, `-p chrome test/parity`, `-p chrome -c dart2wasm test/parity` |
| DETERMINISM-002 issue order and args differ on dart2js | Yes | Unknown keys reported sorted by code unit; `schema.invalidJson` has no args (the parser text stays in the message); new `test/parity/codec_parity_test.dart` |
| DETERMINISM-004 decoding quadratic in the issue count | Yes | Both decoders count errors as they are added |
| DETERMINISM-005 admin search above 64 MB; growth holds both arrays | Yes (72.3 MiB at 500k on a 72-cell board; the reviewer measured ~86 MiB for the store alone during its last doubling) | `NodeStore` grows in 1,024-row chunks (never copied, no transient); `AStarSearch.peakBytes` bounds the peak (43.6 MB for the 435k proof); the worst-case board is in the solver benchmark. 72.3 MiB held (80.3 MB peak) on that board remains: Q33 |
| DETERMINISM-006 exhaustive throughput and admin time targets | Yes (187–191k nodes/s, 2.3 s for 435,588 nodes) | `Kernel.applyLegal` skips re-checking kernel-listed moves (~3 %); the remaining gap is Q32 |
| DETERMINISM-007 guards miss the web-safe arithmetic rules | Yes (no violations in lib today) | Guards for `~`, 64-bit typed lists and `HashMap`/`HashSet`, with self-tests |
| DETERMINISM-008 snapshot decode accepts contradicting `completedSets` | Yes (RangeError from the queue) | `decode` checks that the cells lost only whole sets and that they add up to `completedSets`; FormatException tests |
| RENDER-1 the host's rim is painted over the guest | Yes | `DollPart.interior` and `DollPart.bodyFront`, `DollPaintParams.shadow`; the z-order of the design's nest frame (D37); pixel tests |
| RENDER-2 +Slot flashes the placeholder | Yes | `DollRenderer.canPaint`; `FallbackDollRenderer` uses it; re-layout test |
| RENDER-3 sealed/frozen dolls overflow on 5–6-slot rows | Yes | Dolls shrink with the crowded row's pieces (D36); the crowded test now checks sealed and frozen dolls |
| RENDER-4 top-shelf silhouettes reach the HUD | Yes | `buriedBaseY(depth, buried:)` compresses the step only when needed (D36, `TODO(design)`); top-row towers in the crowded test |
| RENDER-5 golden gate can't see the subtle symbol | Yes (all goldens passed with it removed) | Gate ≥ 99.9 % / mean < 0.5, a symbol-box gate, and negative controls (missing symbol, 100 % ink); a mutation that drops the symbol now fails 22 tests |
| RENDER-6 `BoardSprites.image` keeps every scale asked for | Yes | A miss rasterizes only when nothing held is within 10 % |
| RENDER-7 gold layers rasterized for every height | Yes (23 % of layer bytes) | Not fixed: needs a gold flag through `DollRenderer.prepare` and the cache key; deferred (BACKLOG v1.1) |
| RENDER-8 hot-path guard misses allocating constructs | Yes (no violations today) | Patterns for typed lists, `Offset & Size`, Rect/Offset makers, image/mask filters and closures, with self-tests |
| RENDER-9 dolls on fractional device pixels | Yes | Upright, unscaled dolls snap their base to the device grid |

### Benchmarks (2026-09-26, this Mac, VM JIT unless noted)

| Target (design §5) | Measured | Met? |
|---|---|---|
| Hint 30k ≤ 100 ms VM, ≤ 400 ms dart2js | 35–38 ms VM; 52–57 ms dart2js on node | Yes |
| Soft-stuck 20k ≤ 70 ms | 20–22 ms VM; 30–32 ms node | Yes |
| Solver ≥ 300k nodes/s VM | 1.28M nodes/s on a budget-limited search (the widest generator board); 191–289k nodes/s when every node is expanded | Budget-limited only (Q32) |
| Admin 500k ≤ 2 s VM, ≤ 8 s Chrome | 435,588-node exhaustive proof 2.28 s VM, 3.48 s dart2js on node | Web yes, VM no (Q32) |
| Heap ≤ 64 MB | 43.6 MB peak (37.1 MB held) for the 435k proof; 80.3 MB peak on the widest generator board (Q33) | Typical boards only |
| Simulator ≤ 250 ms/level | worst 82.7 ms (19 slots, 5 towers), mean 7.7 ms | Yes |
| Generator median ≤ 1.5 s, p95 ≤ 5 s | bonus 1–300: median 14 ms, p95 101 ms, max 252 ms; dailies 2027: median 23 ms, p95 72 ms | Yes |
| Kernel apply ≤ 1 µs, `tryMove` facade ≤ 20 µs | 45 ns, 0.4 µs (kernel step, scratch benchmark; BACKLOG M1 leftovers) | Yes |

`dart run benchmark/{solver,simulator,generator}_benchmark.dart` reproduce
them; timings vary ±15 % between runs. Memory is typed-list bytes, not RSS.

### Verification (2026-09-26, final)

| Command | Outcome |
|---|---|
| `flutter pub get --enforce-lockfile` (root) | exit 0, `pubspec.lock` unchanged |
| `dart run nesty_tools:gen_design_tokens --check` / `sync_design_assets --check` / `gen_nesty_icons --check` | all unchanged |
| `dart run nesty_tools:todo_index` then `--check` | regenerated; unchanged (83 tagged markers) |
| `dart run nesty_tools:nesty_levels bundle check` | 30 levels: OK (0 errors, 0 warnings) |
| `dart run nesty_tools:nesty_levels fixtures check` | 11 fixtures OK |
| `flutter analyze --fatal-infos --fatal-warnings` (root); `dart analyze --fatal-infos` (core, tools) | No issues found |
| `dart format --output=none --set-exit-if-changed` (all non-generated Dart) | 0 changed |
| `cd packages/nesty_core && dart test -x slow` / `-t slow` / `dart test` | 1,200 / 128 / 1,328 pass |
| `dart test -p node test/parity test/generator/golden_test.dart` / `-p chrome test/parity` / `-p chrome -c dart2wasm test/parity` | 66 / 42 / 42 pass |
| `cd packages/nesty_core && dart test -p node` (the whole suite in dart2js; VM-only files skipped) | 1,219 pass |
| `cd tools && dart test` | 183 pass |
| `flutter test` in nesty_render / apps/game / apps/admin | 466 / 63 / 47 pass |

Not run in this pass: app builds (no app code changed), the Stop hook, CI on
GitHub.

## M2 — Playable game — code complete, acceptance pending

Started 2026-09-26 (D23). The nesty_render foundation and the 30 authored
levels were built with M1 (above); phase 4 built and integrated the game
(below), and a review fix pass followed on 2026-09-27. The acceptance status
is in [M2 acceptance](#m2-acceptance-spec-18); what is left is in
[BACKLOG.md](BACKLOG.md) under "M2".

### Phase 4 C0: Lottie contracts (2026-09-26)

The owner decided that every animation ships as Lottie (D40). The contracts
stage turned that decision, `design/lottie/LOTTIE.md` and the verified
lottie 3.6.1 behaviour in `docs/plans/lottie-analysis/` into one design and a
set of frozen Dart contracts, so the phase-4 lanes can build in parallel.

- **Design:** [plans/m2-lottie-design.md](plans/m2-lottie-design.md), which is
  authoritative for everything animated and supersedes those parts of
  [plans/design-foundation-m2-design.md](plans/design-foundation-m2-design.md).
  It covers:
  - the mapping from each event to its file, with start times, cues and
    reservations (clack 537 ms, complete t0 667, unlocks and ice at t0 + 700,
    the counter at t0 + 1250, the win at the batch end + 250);
  - image-slot compensation, including the callback for animated scales;
  - the `DollPartRasters` spec, BoardFit placement and the travel-hold fix;
  - paused glass and ice compositions, text overlays, pools and reduced
    motion;
  - the hand-coded gap motions and the hand-off rules;
  - which files are M2 and which M3, lane ownership and the test plan.
- **Designer request:**
  [plans/lottie-reexport-request.md](plans/lottie-reexport-request.md).
- **Package:** `lottie: 3.6.1`, pinned exactly in `apps/game`. It adds
  `archive` 4.3.0 and `posix` 6.5.2 transitively; no locked version changed.
  See D41 and "Package reasons".
- **Frozen contracts:**
  - `apps/game/lib/features/fx/`: `FxId` (29 files), `FxSpec`
    (frames, markers, canvas, anchor, kind, travel with its holds, roles,
    image layers), `FxCue` and `FxTiming`, `FxImageSource` (`FxImageSlot`,
    `FxRaster`, `FxImageRequest`), `FxLibrary`, and `FakeFxLibrary`
    (registered for both environments).
  - `nesty_render`: the `DollPartRasters` / `DollPartSet` API. `DollPartSet`
    is complete; `prepare` is stubbed for the render lane.
  - `features/gameplay/bloc/`: the `…Effect` hierarchy, `GameplayEvent`,
    `GameplayState` (freezed), and a `GameplayBloc` skeleton with
    `GameplayStarted` implemented.
  - Service interfaces:
    - `AudioService.play(effect, {dollSize, comboStep})`;
    - `HapticPattern` with `win`, `unlock`, `iceCrack` and `button`;
    - new `SolverService` (latest wins) and `SkinService` / `LevelSkin`,
      each with a fake registered for both environments;
    - `LevelRepository.entryAt(order)`.
- **C0 probes** (scratchpad `lt/test/{anim_scale_comp,tail_hold,precomp_comp}_test.dart`):
  - a scale callback compensates the animated-scale image layers
    (`glow_ring`, `extra_slot`, `ice_shatter`) within 1 px at 3×;
  - precomp children compensate through the key path `[precomp, child]`;
  - lottie skips the travel callback only on interior holds, never after the
    last keyframe (so `doll_invalid` is fine).

#### Verification (2026-09-26)

| Command | Outcome |
|---|---|
| `flutter pub add --directory=apps/game lottie:3.6.1`, then `flutter pub get` (root) | exact pin added; path dependencies unchanged; the lock gains `lottie` 3.6.1, `archive` 4.3.0 and `posix` 6.5.2 only |
| `cd apps/game && dart run build_runner build` | 30 outputs (`gameplay_bloc.freezed.dart`, `di.config.dart`) |
| `flutter analyze --fatal-infos --fatal-warnings` (root) | No issues found |
| `cd apps/game && flutter test` | all pass (new: fx, bloc, solver, skin, repository, DI) |
| `cd packages/nesty_render && flutter test` | all pass (new: `doll_part_rasters_test.dart`) |

### Phase 4: lanes and integration (2026-09-26)

The stage B and C lanes of [plans/m2-lottie-design.md](plans/m2-lottie-design.md)
§16 built everything against the frozen contracts; the integrator then wired
and verified the whole app. BACKLOG "M2" has the ticked items and what is
left.

- **Tools:** `sync_design_assets` ships the 29 `design/lottie/*.json` byte for
  byte to `apps/game/assets/lottie/` (never `images/` or LOTTIE.md; a stray
  PNG is removed) and validates them on sync and `--check`: the contract
  table, the hooks the game drives, and the features lottie 3.6.1 can't draw.
  `gen_fx_spec` writes `fx_spec.gen.dart` (`fxSpecs`, `fxSpecOf`), drift-checked
  in tools, in the game and in CI. The asset manifest test covers the 29 files
  (parsed with `fromBytes`, no PNG) and `bundle.json`.
- **Render:** `DollPartRasters.prepare`/`preparePlaceholder` split lid and body
  on a whole pixel row (`splitRowPx`, within half a pixel of art y 400) by
  erasing rows after drawing, because any clip changed Skia's edge
  anti-aliasing by up to 32/255. Parity with `SvgSkinRenderer` is 100 % within
  8/255 outside 388–412. `PartRasterDollRenderer` draws the rest sprites with
  the Lottie's own transform (60 dolls: 64 µs per frame). Also
  `BoardFit.toReference`/`boardSpaceOrigin`, `BoardSpriteImage.cropOrigin`,
  the glass and ice composition origins, and `SymbolRaster` for the padlock
  symbol. Classic at 150 dp × DPR 3: five colours and the silhouette are
  5.94 MB, prepared in 35 ms.
- **FX runtime:** `AssetFxLibrary` (one file per event-loop turn, the loader
  first; a file that doesn't match its spec is left out), `FxImages`,
  `FxDelegates` (every workaround of D43), the pure `FxPlayer`/`FxPlan`,
  `LottieFxComponent` (driven by the board's tick, with a cached rest picture
  for glass and ice), `LottieFxView` with the Flutter text overlay (D44), and
  fixed pools. The equivalence sweep fails 32 cases when the compensation is
  broken on purpose.
- **Timeline:** `BoardTimeline` is pure Dart and plans each effect from the
  files' frames: the §7 times are pinned by 86 tests (clack 536.7 ms, bonk 180,
  complete 666.7, dust and sparkles from 1366.7, counter 1916.7, Won at the
  batch end + 250). Sprite hand-offs are counted hides plus `SyncSlot`
  commands; a later plan for a clip cancels the earlier one's pending commands;
  sparkle tails don't delay Won (Q53). `WinOverlaySchedule` times the win
  overlay.
- **Services:** `SoLoudAudioService` (the clack rate precomputed per size,
  silent failure), token haptic patterns, `IsolateSolverService` (one worker,
  latest wins), `BundledLevelRepository` (validator rules 1–7 at splash; an
  invalid level is skipped, Q43), `InMemorySaveService` with the booster
  wallet, `SymbolsMode.large`, and `AssetSkinService` + `LevelSkinImages` (the
  `FxImageSource`) with a placeholder fallback chain that never throws (D54).
- **Bloc:** every §11 handler on `GameSession`, `tap_policy.dart`,
  `win_reward.dart`, `NextLevelPressed` and `GameplayStatus.allLevelsDone`
  (D55). A hint is charged only when it arrives; results for an older
  `moveSeq` are dropped.
- **UI:** `AppTheme` from the tokens, the tactile component kit
  (`core/ui/nesty_ui.dart`: surfaces painted as the prototypes' box shadows,
  buttons, pills, booster buttons, sheets, banners, toggles), the Lottie label
  painter, and all 62 M2 ARB keys.
- **Flame board:** `NestyGame` and `BoardComponent` (input forwarded only, 48 dp
  column hit tests, the drag clamped to the board frame), `ShelfLayer`,
  `SlotComponent` (paused glass and ice with cached rest pictures, static
  fallbacks), `NestComponent`, `FxLayer`, `HintLayer`, and reconciliation with
  core's state at every idle. It handles Flame's one-tick delay for adding and
  removing components (a new level, a late library, a resize during the
  re-pitch).
- **Screens:** the gameplay page (frame 2.2) with the HUD, booster bar,
  soft-stuck banner and chapter ribbon; the win overlay (2.8), out-of-moves
  sheet (3.5), Pause (3.9) and All Levels Done (4.9); Splash (1.1) with real
  load progress; the Home hero (2.1); the dev level picker; and a guard that
  keeps Home and Gameplay behind the loaded levels (D56).

#### Integration (stage D)

- **DI:** the real environment resolves `SoLoudAudioService`,
  `SystemHapticsService`, `IsolateSolverService`, `BundledLevelRepository`,
  `AssetSkinService`, `AssetFxLibrary` and `InMemorySaveService`; the fake
  environment the fakes, with `FakeLevelRepository.fixtures()` (levels 1–3).
  `di_test` checks both.
- **`test/app_flow_test.dart`** runs Splash → Home → PLAY → the laid-out board
  (2 shelves × 3 slots, one component per slot) → a tap on red2's column that
  goes Flutter gestures → Flame → the bloc and selects it → Pause → Home. It
  replaces the screens lane's `home_flow_test.dart`, which covered the same
  path without the board checks.
- **On-device playthrough** (D57): `integration_test/playthrough_test.dart`
  runs the dev flavor with every real service. It plays L1 and L2 to the win
  overlay and L16 into Out of Moves (one move: the r1c1 tower's top onto the
  only empty stand, the shortest Out-of-Moves line a breadth-first search found
  in levels 1–30), then Restart, Pause and Home. Taps land on slot centres
  from `BoardLayout`, checked against the board's own layout;
  mid-animation screenshots are taken at a fixed time of the board's timeline
  with the engine paused. `test_driver/integration_test.dart` saves the 18
  screenshots on the host.
- **iOS flavor guard (D8 amended):** the Run Script accepted only
  `main_<flavor>.dart`, so `flutter drive` failed. It now also accepts an
  `integration_test/*.dart` target, in `Debug-<flavor>` only. `pod install`
  added the `integration_test` pod and a "[CP] Embed Pods Frameworks" phase
  (`Podfile.lock`, `project.pbxproj`).
- **Package:** `integration_test` and `flutter_driver` (SDK) as game dev
  dependencies (rule-9 rows below).
- No compile or analyzer error needed fixing: the lanes left the tree green
  except the two expected failures (`di_test`'s real-environment flips and the
  old `app_flow_test`).

#### On-device playthrough results (2026-09-26)

Both runs pass with no Flutter error, no overflow and no board
reconciliation: every slot's view matched core's state at every idle.

- **iPhone 16 simulator, iOS 18.3** (393×852): 28 s for the whole flow.
- **Android emulator, API 35, 1080×1920 at 420 dpi** (411×731 dp, 1.5 GB
  RAM): 32 s. Google Play services crash-loop on this image ("NetworkCapability
  37 out of range"); the game is unaffected.

Compared with the App Flow frames at 390×844 (the renders of 1.1–4.9):
- Splash (1.1) and Home (2.1) match, minus the M3 pieces (tiles, bottom nav,
  the coin pill's "+", an enabled gear) and plus the dev picker. The splash's
  first frames drew the placeholder dolls until the skin loaded (Q58, since
  fixed: they fade in with the art).
- The board (2.2), a selection (2.3), the nest (2.4, the lid up and the mover
  dropping in), the completion (2.5, the hop, then the flight with the dust
  puff) and the swallow (1.6's move, the lid open mid-air) match. The booster
  badges are absent because the dev flavor's boosters never run out.
- The win overlay (1.5, 2.8) matches, minus the ×3 button (M6) and the locked
  figurine art (M3). The HUD's coin pill already shows the new balance while
  the overlay counts "+10" up (Q57, since fixed: the HUD holds the old
  balance until the next level).
- Out of Moves (3.5) and Pause (3.9) match; the Undo row has no "Free · N
  left" chip in the dev flavor, the +1 Slot row no price (M3/M6), and Settings
  is disabled until M3.

#### Verification (2026-09-26, integration)

| Command | Outcome |
|---|---|
| `flutter pub get` (root), then `flutter pub get --enforce-lockfile` | The lock gains `flutter_driver`, `fuchsia_remote_debug_protocol`, `integration_test` (SDK), `process` 5.0.6, `sync_http` 0.3.1 and `webdriver` 3.2.0; no locked version changed |
| `gen_design_tokens`, `sync_design_assets`, `gen_fx_spec`, `gen_nesty_icons` with `--check` | all unchanged (29 Lottie files, 29 specs, 48 glyphs) |
| `dart run nesty_tools:todo_index`, then `--check` | regenerated after the lanes (100 markers) and again after the integration's test changes: 98 tagged markers; unchanged |
| `dart run nesty_tools:nesty_levels bundle check` | 30 levels OK, 0 errors, 0 warnings |
| `cd apps/game && flutter gen-l10n && dart run build_runner build` | no generated file changed (hashes compared) |
| `flutter analyze --fatal-infos --fatal-warnings` (root) | No issues found |
| `dart format --set-exit-if-changed` over every non-generated Dart file | 0 changed |
| `cd packages/nesty_core && dart test -x slow` | 1,200 pass |
| `cd packages/nesty_render && flutter test` | 520 pass |
| `cd apps/game && flutter test` | 903 pass |
| `cd apps/admin && flutter test` | 47 pass |
| `cd tools && dart test` | 269 pass |
| `flutter drive --flavor dev --driver test_driver/integration_test.dart --target integration_test/playthrough_test.dart` on the iPhone 16 simulator and on the API 35 emulator | both pass, 18 screenshots each |
| `flutter build apk --debug --flavor dev\|stg\|prod -t lib/main_<f>.dart` | all three build: `com.futrix.nesty.dev` `[DEV] Nesty`, `.stg` `[STG] Nesty`, `com.futrix.nesty` `Nesty`; 29 Lottie files, no PNG |
| `flutter build ios --debug --no-codesign --flavor dev\|prod -t lib/main_<f>.dart` | both build; prod: `com.futrix.nesty`, `Nesty` |
| `cd apps/admin && flutter build web -t lib/main_prod.dart` | builds |

### M2 review and fix pass (2026-09-27)

A review of the integrated game raised 13 findings: 2 major, 9 minor and 2
nits. Each was confirmed with a probe on a snapshot of the tree before it was
fixed, and each fix comes with a regression test. Twelve are fixed and one
is the owner's call (Q59). The behaviour decisions are D58.

| Finding | Severity | Outcome |
|---|---|---|
| PERF-RULES-1: a looping widget Lottie repaints its whole page layer at 60 fps | major | **Fixed.** `LottieFxView` paints in its own `RepaintBoundary`, so a playing clip repaints only itself and a resting one replays its layer. The probe's sibling surface went from 31 paints in 30 frames to 1 (`lottie_fx_view_test`) |
| CORRECTNESS-1: Continue shows the next level with the previous level's skin, whose missing colours draw nothing | major | **Fixed.** The win overlay prefetches the next level's art for the layout the board will give it (`LevelSkinLoader.prefetch`, `GameplayBoard.layoutFor`). Continue waits for it (at most 2 s), and the layout the board reports adopts it in the same update, so the level's first frame draws its own dolls (`level_skin_loader_test`, `gameplay_view_test`; the playthrough now checks it on the device) |
| CORRECTNESS-2: Undo or Restart pressed mid-drag leaves the drag live, and its release applies a phantom move | minor | **Fixed.** The bloc ends the drag with the reset; the board's reset ends the live drag, and its release sends nothing (bloc and board tests) |
| CORRECTNESS-3: a drag released while paused keeps the nest selected and parks the doll where the finger was | minor | **Fixed.** A drop while paused puts the doll down (`SelectionChangedEffect(previous, byDrag)`), which flies it home on Resume. The dragged doll stays where it is drawn while paused (bloc and board tests) |
| CORRECTNESS-4: +1 Slot twice within the 300 ms re-pitch makes the bottom row jump | minor | **Fixed.** A second re-pitch waits for the running one and starts from its end layout, where the row really is; a queued re-pitch that a resize overtook is skipped (timeline and board tests; the step went from 29 px to at most 4.4 px per frame) |
| FIDELITY-1: the 1.5× `fx_sparkle` over the counter when a family lands is never drawn | minor | **Fixed.** `onFamilyLanded` carries the scale to the HUD, and `FamilyCounter` bursts a 96 × 96 `fx_sparkle` on the counter's centre with the bump, drawn only while it plays |
| FIDELITY-2: the winning batch greys the pause button and the boosters for about 2.4 s | minor | **Fixed.** At Won the HUD and the booster bar keep their look and only swallow touches (`locked`), as frame 2.5 draws them |
| FIDELITY-3: the subtle belly symbol lacks the cream disc the App Flow boards draw | minor | **Not changed: owner decision Q59 (2026-09-27), bare ink.** The prototype preview art has the disc; tokens.json, README §3, the generator and `skins/classic/renders` don't |
| FIDELITY-4: every return to Home flashes placeholder dolls | minor | **Fixed.** Home keeps the showcase rasters while a level covers it (D58: the part-raster cache holds them anyway) |
| FIDELITY-5: after L30, Home's PLAY reads "Level 31" | minor | **Fixed.** It reads "PLAY · All done!" (screen reader: "You've finished all levels!") and opens All Levels Done. `TODO(design)` until M3's Bonus Endless |
| FIDELITY-6: soft stuck suggests Undo when Undo is impossible | minor | **Fixed.** With nothing to undo the banner suggests Restart ("Try Restart? You can keep playing too.") and Undo doesn't glow. What it suggests holds while it slides out. `TODO(design)` |
| PERF-RULES-2: `LottieLabelPainter.paint` allocates an `Offset` per frame | nit | **Fixed.** The text origin is computed per layout; the file is under the FX hot-path guard |
| PERF-RULES-3: percent semantics and the "+N" tag built outside ARB | nit | **Fixed for the percent** (`progressPercent`, the locale's percent format). The "+N" tag and ice badge digits are `TODO(M7)` for the translations, since every launch language writes "+3" the same way |

Also in this pass:
- The four `TODO(M2)` markers moved to their milestones. The unlock-symbol
  raster swap went to M5, because the first locked levels (L31+) ship with its
  bundle. The tabular figures went to M7 (Q29), and the load-failure copy to
  `TODO(design)`.
- Three ARB keys were added: `progressPercent`, `homeAllLevelsDone` and
  `softStuckBodyRestart`, each with a description. The game now has 65 M2
  keys.
- `GameplayBoard` gained `layoutFor`, and
  `GameplayBoardCallbacks.onFamilyLanded` gained the sparkle scale. Both are
  page-internal seams.

### M2 acceptance (spec §18)

Spec §18 M2: "Levels 1–30 can be played start to finish at 60 fps on a
mid-range Android device."

| Part | Status | Evidence |
|---|---|---|
| Levels 1–30 are valid, solvable and on the §3.7/§6.6 schedule | **Pass** | `nesty_levels bundle check`: 30 levels, 0 errors, 0 warnings (CI runs it) |
| They play start to finish in the app | **Pass on the automated path; the manual pass is open** | The playthrough plays L1 and L2 to the win overlay (with Continue and each next level's own art) and L16 into Out of Moves on the iPhone 16 simulator; `app_flow_test` plays Splash → Home → a board tap → Pause → Home; the bloc and board suites cover every §2–§4 flow. The manual L1–30 pass on the dev flavor (BACKLOG M2) is still to do |
| At 60 fps on a mid-range Android | **Needs the owner's device** | A simulator, an emulator and a debug build don't count (`.claude/rules/flame.md`), so this can't be measured here. The code side is ready: the hot paths are guarded against allocation, widget Lotties no longer repaint their pages, and the solver runs in an isolate |

**How to run the 60 fps check (the owner, with `/perf-profile`):**
1. Use a physical Android phone, mid-range or better yet the 2 GB phone rule 8
   targets. Note its model, RAM and Android version.
2. From `apps/game`, run
   `flutter run --profile --flavor dev -t lib/main_dev.dart -d <device>`, or
   the VS Code config "Game [DEV] (profile mode, physical device)". Keep
   Impeller (the default).
3. Open DevTools from the URL `flutter run` prints (Performance, then
   Memory), or press `P` for the performance overlay.
4. Play these flows three times each:
   - Splash → Home, with the idle dolls and twinkles for 10 s;
   - L1 → L2 by Continue, with the completion (hops, flight, dust, sparkle
     trail, the counter bump and its sparkle) and the win overlay (ribbon,
     confetti, hopping families, coin burst);
   - L16, with the tower reveals and an invalid move onto a tower;
   - a drag, +1 Slot twice, and Pause → Resume;
   - Home ↔ a level, twice.
   The dev flavor's "Jump to a level" reaches L16 and any other level.
5. It passes when the UI and raster threads both stay under 16.7 ms per frame
   during moves, completions and the win overlay (no red bars, no GC spike
   during a move), and a level's GPU images stay near the §4 budget (about
   12 MB typical, 25 MB at most).
6. Record the device, the build and the frame numbers here, then tick the two
   M2 items in BACKLOG. If a flow misses, `/perf-profile <flow>` walks
   through the usual suspects.

#### Verification (2026-09-27, fix and close)

| Command | Outcome |
|---|---|
| probes of the review (`scratchpad/rv/nesty/apps/game/test/zz_review/`) on a snapshot of the tree | every finding reproduced before the fixes |
| `flutter pub get --enforce-lockfile` (root) | passes: no dependency or lock change |
| `cd apps/game && flutter gen-l10n && dart run build_runner build` | the 3 new ARB keys generated; build_runner changed no file (hashes compared) |
| `gen_design_tokens`, `sync_design_assets`, `gen_fx_spec`, `gen_nesty_icons` with `--check` | all exit 0 and unchanged (29 Lottie files, 29 specs, 48 glyphs) |
| `dart run nesty_tools:todo_index`, then `--check` | 102 tagged markers (4 new; the 4 `TODO(M2)` retagged), unchanged on the check |
| `dart run nesty_tools:nesty_levels bundle check` | 30 levels OK, 0 errors, 0 warnings |
| `dart format --output=none --set-exit-if-changed` over every non-generated Dart file | 593 files, 0 changed |
| `flutter analyze --fatal-infos --fatal-warnings` (root) | No issues found |
| `cd packages/nesty_core && dart test -x slow` | 1,200 pass |
| `cd packages/nesty_render && flutter test` | 520 pass |
| `cd apps/game && flutter test` | 929 pass (903 before the pass; 26 new regression tests) |
| `cd apps/admin && flutter test` | 47 pass |
| `cd tools && dart test` | 269 pass |
| `NESTY_SCREENSHOT_DIR=… flutter drive --flavor dev --driver test_driver/integration_test.dart --target integration_test/playthrough_test.dart` on the iPhone 16 simulator (iOS 18.3) | passes in 118 s with 18 fresh screenshots (scratchpad `m2_screens_final/ios/`); Continue to L2 and L3 now also asserts each level's own skin in its first laid-out frame. The first attempt failed to build: the integration's cleanup had deleted `apps/game/build/` but not `apps/game/.dart_tool/flutter_build/`, whose stamps still said the iOS native assets were built (README "Troubleshooting", BACKLOG "Tech debt") |
| `flutter build ios --debug --no-codesign --flavor dev -t lib/main_dev.dart` | builds (after the same stamp cleanup) |
| `flutter build apk --debug --flavor dev -t lib/main_dev.dart` | builds `app-dev-debug.apk` |
| `cd apps/admin && flutter build web -t lib/main_prod.dart` | builds |

The screenshots match the integration's, with the fixes visible: the HUD and
the booster bar at full strength while the set flies (05b), level 2's blue
dolls drawn from its first frame (07), and Home's shelf with its skin art on
the way back (13). Afterwards the simulator was shut down, and the build
folders were removed together with `apps/game/.dart_tool/flutter_build/`.
Nothing was committed.

## Post-M2 round: Claude Design v3 and audio (2026-09-27)

After M2 was committed (2351b1e, 2f17181), Claude Design delivered two
exports: the audio export (two music loops, three jingles, the SFX v2 WAVs,
`AUDIO.md` and new `sound` tokens; the owner's zip (3)) and the v3 overlay
(the Lottie files and PNGs re-exported against our v2 request, LOTTIE.md v3,
re-rendered jingles, two token wording changes; zip (5)). The check workflow
verified both ([plans/claude-design-v3-check.md](plans/claude-design-v3-check.md)),
the owner answered the open points, and four lanes imported and wired them
in. The decisions are D59 (v3), D60 (the v3 Lottie runtime) and D61 (music
and jingles); the owner's audio answers are Q61–Q63. BACKLOG "Post-M2 round"
has the ticked items and what is left.

- **Import and tools** (D59): `design/` rebuilt in overlay order (repo ←
  audio export ← v3), hash-identical to the checked staging (381 files);
  `export/` removed; the designer's notes and our analyses copied under
  `docs/plans/`. The Lottie contract follows LOTTIE.md v3 (3× board pieces,
  `doll_reveal` 31 f with its `drop` null, `fx_ice` 150 f with `rest_n` and
  `crack_hit_n`, 410-wide ribbons, six new parent nulls), and the validator
  now rejects what v3 promises away (`hold`, `imageTransform`).
  `sync_design_assets` ships the 5 OGGs next to the 17 WAVs and checks both
  formats byte by byte (WAV: 44.1 kHz mono 16-bit PCM; OGG: one Vorbis
  stream, 44.1 kHz stereo, every page's CRC) and each loop's length against
  its `frames` token. `gen_design_tokens` maps the new `sound` leaves
  (`jingleFiles`, `musicFiles`, `clackBakedSemitones`, the loops, fades and
  ducks) and the reworded `motion.reveal.type` and `layout.towerSilhouettes`.
- **Lottie runtime** (D60): every v1 workaround is gone (the travel-hold
  fix, the `padlock_ping` rest hide, the 11 dp glass settle, the reveal
  silhouette hide, the hand-coded reveal drop and the animated-scale
  callbacks). `doll_reveal` drops the new top from its own buried step;
  an ice hit with no stage change plays `crack_hit_n`; every jump re-seeks
  lottie cleanly (the frame-99 double draw); the ribbons use the 410-wide
  canvases, their text boxes and `min(1, W/390)` on screen. Buried nests
  draw the wood-grain blank for every skin (3e), and the reveal wipe grows
  from art (256, 476) (3d).
- **Audio** (D61): one `SoLoudEngineHost`; the SFX v2 at 0 baked
  semitones; `JinglePlayer` on the SFX bus; `MusicService` with a real
  SoLoud implementation (streamed loops, crossfade, ducks, pause reasons,
  the Music setting) and a fake; `MusicRouteObserver`, `MusicDuck` and
  `JingleCues`; the iOS `.ambient` session (Q61); low latency in prod only
  (Q63).
- **The owner's Level 9 report** (device screenshots, 2026-09-27): the hint
  arrow sat up and left of its doll, the glow ring at the shelf's left end,
  the +1 pads were slivers, and the arc's head pointed at an empty stand.
  The first three were one bug, the raster units after the move to v3's 3×
  image sizes (D60 "Root cause"); the arc now arrives on the source's side
  of the target (D60 "Hint arc"). `board_pieces_l9_test` pins all of it to
  `BoardLayout`.

#### Integration

- **Handoffs applied:** the skin service passes its board library to
  `DollPartRasters` (`DollPartSource.prepare(board:)`), so decision 3e shows
  in the running game; `app_flow_test` follows the music (home after the
  splash, game in the level, ducked under Pause, home again);
  `SlotGeometry.unlockedDollBaseY`'s comment says the v3 file lands the doll
  itself; `docs/TODO_INDEX.md` regenerated (102 markers: the audio lane's
  `TODO(M3)`/`TODO(M6)` hooks in, the SFX placeholders' `TODO(M7)`s and
  `FxTiming.revealDropMs`'s out); the READMEs' audio, playthrough and
  status notes.
- **Self-review against the hard rules:** `_Drop.position` (a per-frame
  Lottie callback) built two `Offset`s per call; it now builds the one the
  callback must return (D42). The new hot paths (`FxPlayer.epoch`,
  `FxDrawable.draw`'s re-seek, the hint arc, `RevealDropTween`) allocate
  nothing per frame, and the re-seek only runs on a jump (the splash
  loader's seeks follow load progress, not frames). Every service added
  has a fake registered for `AppEnv.fake` (`FakeMusicService`,
  `FakeAudioService` as the `JinglePlayer`); no user-facing string was
  added outside ARB; every new `TODO` is tagged. No package was added
  (Package reasons).
- **The playthrough** now also plays Level 9 (Hint, +1 Slot twice, a doll
  onto an extra slot: frames 3.1 and 3.6), shows Level 16's tower reveal,
  toggles Music off and on in Pause and opens Level 21's chapter ribbon. It
  checks the real `SoLoudMusicService`'s state on each screen (`music_home`
  on Home, `music_game` in a level, ducked to 0.3 under the win overlay, 0.4
  under Out of Moves, 0.5 under Pause, silent with Music off), that every
  Lottie file, the 17 SFX and the 3 jingles loaded, that neither loop failed,
  and that nothing was logged under `[nesty.audio]`, `[nesty.music]` or
  `[nesty.fx]`.

#### On-device playthrough results (2026-09-27)

Both runs pass with every real service, and nothing was logged under
`[nesty.audio]`, `[nesty.music]` or `[nesty.fx]`.

- **iPhone 16 simulator, iOS 18.3** (393×852): 166 s with the build, 46 s
  for the flow, 25 screenshots.
- **Android emulator, API 35, 1080×1920 at 420 dpi** (411×731 dp): 177 s
  with the Gradle build, 70 s for the flow, 25 screenshots. At the end
  `flutter drive` fails to uninstall `com.futrix.nesty` (the dev flavor
  installs `com.futrix.nesty.dev`); the test had already passed.

Compared with the App Flow frames and the `Lottie FX` prototype (served
over http and rendered headless):
- **Level 9's hint (3.1):** the arrow at full size over brown3 (r0c1), the
  glow ring on brown2's stand (r1c0), and the dashed arc from brown3's upper
  body to beside brown2's head, its arrowhead heading into it, as 3.1 draws
  its arc. The owner's device screenshots had the arrow up and left, the
  ring at the shelf's end and the arrowhead at the empty r1c1. One
  difference remains: Level 9's top-row doll is taller than any in the
  frames (the board-wide clamp, BACKLOG "Design gaps"), so at the top of its
  bob the arrow grazed the family counter pill's left edge. Fixed after the
  round by D62: it now steps off the pill and under the pause row.
- **+1 Slot twice (3.6):** two green "+1" pads at stand size on the bottom
  shelf, as 3.6 and the `ui_extra_slot` preview draw them; with five slots
  on that row the dolls shrink board-wide (D36). A doll moved onto the
  first pad stands on it with the pad drawn under it.
- **Ribbons:** "Level Complete!" and "CHAPTER 2 · Rainy Café Corner" fit
  their bands, which match the v3 previews; at rest the tails end 6.7 dp
  inside each edge of the 393 dp screen. The chapter ribbon sits where
  frame 4.7 puts its card, over the top row's heads, for its 2 s (Q50 is
  still the look).
- **Level 16's tower reveal:** the Android shot caught the new top as the
  wood blank on the stand after its drop (3e), the iOS shot the colour wipe
  with its splash drops; the deeper silhouettes are the wood blank too.
- **Glass and ice** first appear at L31 and L51, so the playthrough can't
  show them. `fx_workarounds_test` checks the freed doll landing at canvas
  y 174 in the shipped file; `fx_spec_drift_test`, `board_effects_test` and
  `board_timeline_complete_test` check the ice's `rest_n` and `crack_hit_n`
  segments.

#### Verification (2026-09-27, post-M2 round)

| Command | Outcome |
|---|---|
| design/ hashed against the checked v3 staging | 381 files, identical, no `.DS_Store`; `export/` gone |
| `flutter pub get --enforce-lockfile` (root) | passes: no dependency or lock change |
| `cd apps/game && flutter gen-l10n && dart run build_runner build` | no generated file changed (hashes compared) |
| `gen_design_tokens`, `sync_design_assets`, `gen_fx_spec`, `gen_nesty_icons` with `--check` | all exit 0 and unchanged (496 token leaves, 473 emitted; audio 22 files, Lottie 29; 29 specs; 48 glyphs) |
| `dart run nesty_tools:todo_index`, then `--check` | 102 tagged markers, unchanged |
| `dart run nesty_tools:nesty_levels bundle check` | 30 levels OK, 0 errors, 0 warnings |
| `dart format --output=none --set-exit-if-changed` over every non-generated Dart file | 620 files, 0 changed |
| `flutter analyze --fatal-infos --fatal-warnings` (root) | No issues found |
| `cd packages/nesty_core && dart test -x slow` | 1,200 pass |
| `cd packages/nesty_render && flutter test` | 526 pass (520 before the round) |
| `cd apps/game && flutter test` | 1,045 pass (932 before the round) |
| `cd apps/admin && flutter test` | 47 pass |
| `cd tools && dart test` | 299 pass (269 at the M2 close) |
| `NESTY_SCREENSHOT_DIR=… flutter drive --flavor dev --driver test_driver/integration_test.dart --target integration_test/playthrough_test.dart` on the iPhone 16 simulator (iOS 18.3) | passes in 166 s, 25 screenshots; the dev build compiles `AppDelegate.swift`'s `.ambient` session |
| the same on the API 35 emulator | passes in 177 s, 25 screenshots |

Afterwards the iPhone 16 simulator and the emulator were shut down. Nothing
was committed.

## Decisions log

D1–D13 are dated 2026-09-25, D14–D57 2026-09-26 and D58–D61 2026-09-27
(D26–D39 are the M1 and render build and review decisions; D40–D52 are the
M2 Lottie decisions, the owner's of 2026-09-26 and the contracts stage's;
D53–D57 are the M2 phase-4 lanes' and the integration's; D58 is the M2
review fix pass's; D59–D61 are the post-M2 round's, recording the owner's
calls and deliveries of 2026-09-26). D1, D8 and D12 were
amended on 2026-09-26. D18–D23 are the owner's decisions for the round that
covers the design foundation, M1 and M2, copied from its approved plan.

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
    - **Amended again (2026-09-26, D57):** an `integration_test/*.dart`
      target is accepted too, in the `Debug-<flavor>` configurations only,
      so `flutter drive` runs the on-device playthrough while an Archive can
      never ship a test entry point.
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
- **D18. The design handoff is in `design/` (2026-09-26, commit 3a8dfca).**
  - **The move:**
    - The owner's `design_handoff_nesty/` went into `design/`: its `design/*`
      folders, `prototypes/` as `design/prototypes/`, and `README.md` as
      `design/README.md`.
    - The `.DS_Store` files and `design_handoff_nesty/` were deleted.
    - `design/` stays owner-managed and read-only (D4).
  - **What it contains:**
    - `tokens.json`, 7 layered skins, board pieces, 11 symbols and the
      ch01–ch06 backgrounds.
    - Museum figurines as SVG and PNG, and store icons.
    - 17 placeholder WAVs, and the reference generators `nesty-doll.js` and
      `nesty-sfx.js`.
    - 62 HTML frames in 8 flows (`design/prototypes/Nesty App Flow.dc.html`).
    - No fonts and no music.
  - **The screens are HTML prototypes,** not the PNGs `docs/DESIGN_BRIEF.md`
    asked for. The `.claude` agents and skills now point at
    `design/prototypes/`.
  - **Sources of truth:** rules come from GAME_SPEC.md. Look, layout, motion,
    sound and copy come from `design/`. Precedence inside the handoff is in
    D22.
  - **Closed questions:** this ends D4's wait and resolves Q15. For Q14, the
    handoff says to bundle the Fredoka and Nunito TTFs but ships none, so
    tooling fetches the OFL files.
  - **Audit findings that shaped the plan:**
    - Every SVG embeds a ~7.7 KB C2PA `<metadata>` block. It is stripped when
      the file is copied into app assets.
    - The museum and store SVGs use nested `<svg>` and mix-blend-mode, which
      flutter_svg can't render. The museum uses `design/museum/png/`, and the
      store art will be re-exported for M8.
    - `design/store/icon_1024.png` has an alpha channel.
    - There is no Android adaptive icon and no 512 px Play icon.
  - The remaining gaps are in [BACKLOG.md](BACKLOG.md) under "Owner inputs
    needed".
- **D19. The handoff's "Decisions to confirm" are accepted (owner,
  2026-09-26).**
  - A family counter under the level pill is the fly-in target for a
    completed set.
  - A "Privacy choices" row in Settings lets players change UMP consent later.
  - Gold uses a gradient-map tint, per stop and pre-rasterized, not modulate.
  - `DollColor` stays a fixed enum. Open-ended playable colors would be a
    spec change (BACKLOG "Later"). New skins, symbols and cosmetic variants
    need no code change.
  - There is no "watch a video for coins" shop row, because §9.1 lists no
    such placement.
  - **Placeholder SFX:** the 17 WAVs are the SFX until final audio (M7).
    - Their clacks have +1 semitone baked in.
    - So the game plays them at `2^(−2(size−3)/12)` instead of the README's
      `2^(−2(size−3.5)/12)`.
    - **Superseded 2026-09-27 by D61:** the SFX v2 WAVs replaced the
      placeholders, with their clacks baked at 0 semitones
      (`SoundTokens.clackBakedSemitones`), so the rate is the README's.
  - The settings `symbols` value for large symbols is `large`, replacing
    `assist` (Q4). A stored `assist` is read as `large`.
  - Also accepted from the README's list: Level 56 (Hard) is the flow's
    example level, and frames 1.2, 8.6 and 8.7 show system UI for placement
    only.
- **D20. All art is bundled, a deviation from spec §13.5.**
  - **What:** all 7 skins and the 6 chapter themes ship in the app. §13.5
    bundles only Classic and ch01.
  - **Why:**
    - The handoff delivers all of them.
    - They then work offline from the first launch (rule 3).
    - Storage delivery isn't built until M4.
  - **Cost:** app size, checked against the < 60 MB budget in M8.
  - Storage download (M4) remains for skins and themes added after release.
- **D21. Towers follow spec §3.2, not the design (owner).**
  - Buried nests are wood silhouettes at their true size: their size shows,
    their color doesn't.
  - Each is raised 18 dp per depth behind the top nest so it stays visible.
  - The design's walnut "+N" tag is kept.
  - The design itself draws every buried nest at `topHeight + 18 × depth`.
  - This resolves Q18.
- **D22. Gaps between the spec and the design resolve "according to the
  design" (owner).**
  - **Tap policy (frame 2.6).** This replaces §2.2's "tapping a different
    pickable nest switches the selection".
    - Tapping the selected nest cancels, and tapping a legal target moves.
    - Any other tap is invalid, including a pickable nest of the wrong color
      or size: the target shakes, the nest drifts back and the selection
      clears.
    - Drag: a drop on a legal target moves, a drop on any other slot is
      invalid, and a drop on nothing cancels.
  - **Extra slot.**
    - It is always appended to the bottom shelf, which re-pitches, instead of
      going below the shelf when it is full (§3.6). The layout shrinks stands
      and dolls if the row gets tight.
    - At most 2 per level ("Two per level at most").
    - It stays for the rest of the level, including after Restart ("Add a
      stand for this level").
  - **Gold.** The design marks it v1.1, "only if it ships". The gold rendering
    is built now. The gold rules are hooked into core, but the validator
    rejects gold until v1.1.
  - **Soft stuck.** The response is frame 3.4's banner ("Hmm, this looks
    stuck / Try Undo?…") plus a glowing Undo. When the solver says the level
    is stuck, Hint gives no move and charges nothing.
  - **Precedence inside the handoff:** `tokens.json`, then the App Flow
    frames, then the README, then the Design System sheet.
    - The sheet is stale. Where it differs, tokens win: counter bump 1.22,
      wobble period 400 ms, win dance 1400 ms with a 120 ms stagger.
  - **Undesigned boards** (1 or 4 shelves, 5-slot rows, maxSize 6 on 3
    shelves) extend the design's system through `BoardLayout` scaling, marked
    `TODO(design)`.
- **D23. This round's scope is the design foundation, M1 and M2 (owner).**
  - M3 (museum, daily, shop, settings, tutorial, save and resume) is the next
    round.
  - **Pulled into M2:**
    - M7's design integration: tokens, the Classic and other skin SVG
      pipeline, chapter themes, fonts and icons.
    - The SFX and haptics parts of the M3 audio and haptics service.
  - M2 is therefore no longer "placeholder art". `PlaceholderDollPainter`
    (§12.5) stays as the fallback when a skin can't load.
  - The M2 acceptance criterion is unchanged.
  - Item-level status is in BACKLOG under "Design foundation", "M1" and "M2".
- **D24. Remaining work is tracked in [BACKLOG.md](BACKLOG.md) (owner
  request, 2026-09-26).** The owner asked for every future-milestone to-do to
  be tracked, so none is lost.
  - **BACKLOG.md is the curated checklist:**
    - one section per milestone, then v1.1, Later, Owner inputs needed and
      Tech debt;
    - every item names its source.
  - **In code,** deferrals carry `TODO(<tag>)`, where the tag is `M1`…`M8`,
    `design`, `v1.1` or `later`.
    - `dart run nesty_tools:todo_index` generates `docs/TODO_INDEX.md` from
      them.
    - CI fails on an untagged TODO.
  - Every deferral gets a BACKLOG item, a tagged TODO, or both.
  - PROGRESS.md keeps the history (what was done, decisions, questions) and
    points at BACKLOG rather than copying it.
  - The `/milestone` skill and CLAUDE.md's Workflow read BACKLOG at each
    milestone's start and update it at the end.
- **D25. Design foundation pipelines (plan P1, done 2026-09-26).** Everything
  the game takes from `design/` is generated and committed, and CI checks it
  for drift. The commands are in `tools/README.md` and CLAUDE.md "Commands".
  - **Tokens:** `gen_design_tokens` emits only `static const` values. Their
    types are hand-written next to the output (`render_token_types.dart`,
    `ui_token_types.dart`), so helpers can be added without touching generated
    files. Each of the 466 tokens.json leaves is emitted, or it is on a tested
    list of 21 documented-only leaves (prose, font sources, and `haptics.*`,
    which the haptics service hand-writes). An unmapped leaf or an unknown
    value shape fails the codegen.
  - **Assets:** `sync_design_assets` owns `apps/game/assets/{skins,symbols,
    board,themes,audio}`. It strips the C2PA `<metadata>` block at the text
    level, so each SVG is otherwise byte-identical to the export. The spec
    §12.2 allowlist validator is Flutter-free
    (`package:nesty_render/svg_tools.dart`), so the admin upload can reuse it
    in M5.
  - **Fonts:** `tools/fonts/build_fonts.sh` builds them from pinned upstream
    commits. It checks each input's SHA-256, runs fontTools 4.60.1 in a
    throwaway venv, and its output is byte-reproducible (`--verify`). The icon
    font is exactly the README's 48 glyphs. At FILL 1, Material Symbols swaps
    most icons for `<name>.fill` glyphs through GSUB, which subsetting drops.
    So `bake_feature_variations.py` points the cmap at those glyphs first.
    This was a review fix: before it, the outline glyphs only looked filled
    because their holes collapsed into cancelling contours.
  - **TODO index:** only comments and Markdown prose are scanned. `design/`,
    `.claude/` (its docs describe the marker convention), build output and
    generated files are skipped. A combined tag such as `M3/M4` is listed under
    each milestone.
  - **Audio plugin:** `flutter_soloud` is pinned to 4.1.7, because 5.x can't
    resolve on Flutter 3.41.2 ("Package reasons"). It builds native code, so
    iOS builds need CMake on the Mac.

- **D26. Towerless levels keep their §6.6 tier by `tierOverride` (M1 review
  SPEC-01; owner-confirmable, Q30).** Spec §3.7 allows no towers before L16,
  no locks before L31 and no ice before L51, and §6.6 plus design A24 give
  L3, 5, 6, 7, 9, 10, 13 and 15 a medium, hard or superhard tier. On a board
  of open slots without ice every color that isn't complete holds the same
  number k of dolls of each size, so for every size s > 1 the nests whose
  inner doll is s are as many as those whose outer doll is s − 1: there is
  always a legal merge, every merge lowers the nest count by 1, and the
  casual bot (a merge 70 % of the time) wins 300 of 300. No towerless board
  can satisfy A32, so `BundlePolicy.checkTier` lets an open-slot-only board
  (every slot an `OpenSlot` with ice 0) keep its declared tier with a
  `tierOverride` reason, like the tutorials; anywhere else an override is
  still an error. The levels keep their §6.6 badges and coins (§7.3). The
  alternatives (declare them easy and relax the pattern for towerless
  boards; move towers before L16, against §3.7) are the owner's call.
- **D27. The core public API as built (M1).** Design §1 holds, with these
  additions and deviations (every one is exported and tested):
  - `MoveResult` has `move`; `MoveApplied({move, state, events,
    completedSet})`, `MoveRejected({move, reason})` with `targetId` =
    `move.to`. `NestDirection { inside, swallow }`. `BoardPosition` lives in
    `slot_id.dart`; `UndoEntry`, `UndoResult` and `ExtraSlotAdded` in
    `session_types.dart`. Event payloads carry what the animations need
    (`Picked.fromTower/leftEmptyTower`, `NestedInto.moving/target/merged`,
    `Revealed.hiddenBelow`, `Completed.setsCompleted/totalSets`, …).
  - Rejection precedence (tested, owner-confirmable in Q35): unknown slot,
    same slot, source frozen, source locked, source empty, target frozen,
    target locked, color, size. `targetOccupied` is §4's `else invalid`
    branch, unreachable in play.
  - `Rules.legalMoves` lists by source, then target, in `slotIds` order: the
    simulator's and the fallback hint's determinism depend on it.
  - `GameSession.restore(level, state, history, {undosUsed})`; `restart()`
    keeps `undosUsed` and the extra slots (per level, D22; Q35).
  - `Solver.hintFrom`, `SolverTask`, `SolverSnapshot.start/decode`,
    `SolverRun.maxBudget`, `SimulationResult.fromStats/isExpertOnly`,
    `Generator.buildAttempt/defaultId/maxSetsPerColor`,
    `DifficultyCurve.dailyTier/maxLevelNumber`, `LevelSolver`,
    `ValidationOptions.solver` (default `Solver.solve`),
    `LayoutLimits.maxIce`.
  - Name clash for M2: core exports `MoveApplied`, `MoveRejected`,
    `Completed`, `Won`, `Placed`; the game's `BoardEffect` names must differ
    or import core with a prefix.
- **D28. PRNG and Hash64 definitions (resolves Q9; frozen under
  `Generator.version` 1).** `Prng` is xoshiro128** 1.1. Seeding: lo = seed
  mod 2^32, hi = seed ÷ 2^32; splitmix32 streams A from lo and B from
  hi ^ 0x510E527F; state (A1, A2^B1, A3^B2, A4^B3), so distinct seeds give
  distinct states and the all-zero state is impossible.
  `derive(seed, a, [b])` = MurmurHash3_x86_32 over the little-endian words
  [lo, hi, a, b] with seed 0xA54FF53A. `nextInt` rejection-samples (no
  modulo bias, no 64-bit product); `shuffle` is Durstenfeld. `Hash64` is two
  MurmurHash3_x86_32 halves (seeds 0x6A09E667 / 0xBB67AE85) in web-safe u32
  arithmetic, no `fixnum`. Reference vectors come from an independent Python
  implementation checked against the upstream C.
- **D29. Codec and validator semantics (M1, review DETERMINISM-002,
  SPEC-02).** Integers are read by value (`3.0` is `3`; fractions and
  |x| > 2^53 − 1 are `schema.wrongType`), so the browser and the VM agree.
  The codec reports only what a `Level` can't hold; the validator reports
  everything a `Level` can hold, so code-built and JSON levels get the same
  checks. Issue order is document order with the known fields in canonical
  order, then unknown keys **sorted by code unit** (JSON key order isn't
  portable), and `schema.invalidJson` has no args (the parser's text differs
  by platform). Ice above `LayoutLimits.maxIce` (2^31 − 1, a representation
  limit, not a game rule) is `schema.valueOutOfRange`, and `BoardLayout`
  refuses it, so a counter never wraps and plays as thawed. Rule 8 without a
  solver is `solver.unproven` as an error; `generatorVersion` must be ≥ 1;
  rule 6 applies per lock, literally (mutual deadlocks are rule 8's).
  Decoders count errors as they go (linear, DETERMINISM-004).
- **D30. The rules engine (M1).** Nest code `gold << 10 | color << 6 |
  outer << 3 | length` in a `Uint16List`; `BoardLayout` compiled once per
  `Level` (Expando cache), up to 28 authored slots + 2 reserved extras
  (looser than the validator's 22, so rule 7 never throws on a rule-2
  failure; Q35); current ice and per-color completions are derived. Gold is
  merged per §3.5 in the kernel, but the `Nest` view drops it (v1.1).
  `Kernel.applyLegal` applies a move the kernel itself listed without
  re-checking (the solver's inner loop).
- **D31. The solver (M1, review DETERMINISM-005/008).** Deviation from design
  §3: stored nodes are packed canonical keys (three 10-bit codes per word
  without gold), a visited-table hit is confirmed by comparing them, and the
  solution is rebuilt by replaying on the real start board (first legal move
  reaching the next stored state). This halved search time. Pruning adds a
  free-pair merge symmetry (A30). Fallback step 3 (A3) takes the first
  non-pointless placement, then the first placement. A won root is `solved`
  with no moves; the root is always stored. Snapshot format v1 is
  self-contained, and `decode` rejects cells that contradict
  `completedSets`. The node arena grows in 1,024-row chunks, never copied,
  and `peakBytes` bounds the search's memory.
- **D32. The simulator (M1; owner-confirmable, Q35).** Default seed =
  `Hash64.ofString(board JSON).lo` over `schemaVersion`, `maxSize` and
  `shelves` only, so renaming a level or the generator's metadata can't move
  its tier. Run i of bot b (casual 0, smart 1) uses `Prng(derive(simSeed, b,
  i))`. Casual: one `nextInt(100)` only when merges exist. Smart (A17
  reading): candidates minus pointless moves, score (alive, rank,
  mergesAfter) with "alive" extended to boards that have a non-pointless
  move, ties by PRNG. A board with only pointless moves is a loss at once.
  Expert only = smart wins < 150/300.
- **D33. The generator and curve (M1; owner-confirmable, Q31, Q34).** Draw
  order per attempt stream `Prng(derive(seed, i))`: colors (one palette
  shuffle), segment cuts, roles, segments (≤ ⌊towers/2⌋ mergeable tower tops,
  20 deals, best kept), locks (a lock never opens on a color that waits on
  the sealed color when one set per color), ice (never on a lock). Bottom
  shelf = `min(slotsPerShelf, 4)`. Attempts are validated with
  `Validator.validate` (rules 1–8, admin budget) and simulated; closest tier
  by tier distance, then band centre, then earliest. `bonusParams(n)` takes
  the global level number. `dailyParams` uses the 31–50 boards with medium on
  weekdays and hard on weekends, and `dailySeed` rejects dates that don't
  exist. The stage table is the A16 default in `DifficultyCurve`'s doc (Q34).
  An expert-only result is returned with `simulation.expertOnly` set; the
  generator doesn't reject it (§6.5 step 4 matches tier only; Q31).
- **D34. Level bundle and `nesty_levels` (M1/M2).** `LevelBundleCodec` decode
  semantics (format and version first; entries with errors skipped;
  duplicate orders and ids skipped; one `bundle.orderGap` per gap; unknown
  top-level keys are errors but the bundle loads). Manifest schema in
  `tools/levels/README.md` (order = position, id = file name, every
  authored file listed). `bundle build` refuses an edited board whose
  `version` wasn't raised. `BundlePolicy` formalizes §3.7 ("introduces at
  Ln": absent before, present at Ln; maxSize 6 is only a cap; L3–9 ≤ 4
  colors), applies the M2 layout (2–3 shelves, ≤ 4 slots) to every bundled
  level, and treats expert only as a warning (Q36). CI runs `bundle check`.
- **D35. The 30 authored M2 levels.** One set per color everywhere, maxSize 3
  for L1–9 and 4 from L10, no locks, ice or gold, chapters 1–20 / 21–30.
  L1/L2 are the design tutorials and carry no override (both simulate easy).
  The towerless medium/hard/superhard levels (D26) are "harder" by more
  nests, split families and one empty slot. L16 is a 4,3 board with two
  depth-4 towers (the design's 4,3,3 TOWER16 board can only simulate easy, so
  it is L18); L16–L20 use depth-4 towers (Q37). Tiers were tuned with the
  same Validator, Solver and Simulator `bundle check` runs.
- **D36. Board layout extensions (render R1, review RENDER-3/4).** The doll
  clamp gap is 8/3 dp (the design's own TUT1 gap), not design §1's 4, which
  would shrink the designed tutorial. Undesigned rows and presets scale every
  slot piece by `q = min(standScaleForPitch, preset.pieceScale)`. On 5–6-slot
  rows the dolls shrink at least by that row's piece shrink × the 4-slot
  clamp, so a sealed doll keeps its case's proportions and a frozen one its
  ice's. On the top shelf the D21 18 dp step per buried nest shrinks only
  when the deepest of the tower's buried nests would reach the HUD
  (`buriedBaseY(depth, buried:)`, `TODO(design)`). The kind enum is
  `SlotShapeKind`; the whole column is the ≥ 48 dp hit area.
- **D37. Doll rendering (render R2, review RENDER-1/2/5/9).** `DollRenderer`
  adds `canPaint(h)` (any prepared raster, resampled) next to the exact
  `isReadyFor(h)`; `FallbackDollRenderer` uses `canPaint`, so a re-layout
  keeps the skin on screen. Nest z-order follows the design's nest frame
  with `DollPart.interior` and `DollPart.bodyFront` and a `shadow` flag:
  inside = host lid → host interior → guest (no shadow) → host bodyFront.
  `prepare` is additive (LRU past 8 heights); rasters are keyed by artboard
  pixel height; 9 layers; the symbol atlas holds both sizes per exact
  height; the shine sweep crosses the whole doll over its duration (Q38).
  Upright, unscaled dolls snap to device pixels. Goldens compare every
  classic reference render (≥ 99.9 % within 8/255, mean < 0.5, plus the
  symbol box).
- **D38. Board sprites and themes (render R3, review RENDER-6).**
  `BoardSpriteLibrary` (parsed once per app) is split from `BoardSprites` (one
  board's images). `prepare` rasterizes the plank, stands, glow ring, hint
  arrow and the intact glass case at every scale on the board; glass and ice
  frames are lazy (`also:`, `ensure`, or a miss). A miss rasterizes only when
  nothing held is within 10 %. Sprites are cropped once to their alpha. Theme
  backgrounds swap when the new image is ready; `ChapterTheme.forChapter`
  cycles ch01–ch06 until chapters 7–10 have art (Q38).
- **D39. VM/web parity in CI and web-safe arithmetic guards (review
  DETERMINISM-001/007).** CI runs the parity suites on node, Chrome and
  dart2wasm (and the generator goldens on node), because each parity case
  compares with a VM-computed constant and the VM run can't see a web-only
  divergence. The architecture guard also bans `~`, 64-bit typed lists and
  `HashMap`/`HashSet` in core's `lib/`.
- **D40. Every animation ships as Lottie (owner, 2026-09-26).**
  - All 29 files in `design/lottie/` ship. LOTTIE.md says 28; the folder and
    its own table hold 29.
  - Widget transitions that wrap live content stay Flutter animations on
    `tokens.motion.ui`: tactile press, sheet, modal, tab lift and banners.
  - The board timeline still owns the event order, the sound and haptic cues
    and input gating, and a Lottie never changes game state.
  - **Timing comes from each file's frame count, at 60 fps.** Examples: the
    clack lands at 537 ms (the move's 16 frames plus the lid's 16.2), a
    completion starts at 667 ms, and its unlocks and ice at t0 + 700.
  - **Motions with no file are hand-coded** (m2-lottie-design §9):
    - the tower reveal's 18 dp drop, with deeper silhouettes shifting down
      (towers show their true size);
    - the 11 dp settle after an unlock;
    - the case, ice and silhouette shake on an invalid move;
    - drag cancel and drag invalid;
    - the 300 ms re-pitch;
    - the tag and badge counts;
    - the coin count-up.
  - **Split between milestones:**
    - M2: the splash loader, idle dolls, twinkles, the toggles in Pause and
      the chapter ribbon (L21 opens ch02).
    - M3: the tutorial hands, the Settings toggles and the spinner.
- **D41. `lottie: 3.6.1`, pinned exactly; no `flame_lottie` (rule 9).**
  - **Why lottie:** the owner decided every animation is Lottie. It is a
    pure-Dart player.
  - **Why 3.6.1:** it is the newest release that resolves on Flutter
    3.41.2 / Dart 3.11. 3.4.0–3.5.1 need Flutter 3.44 and 3.6.0 is
    retracted. It adds only `archive` 4.3.0 and `posix` 6.5.2 to the lock,
    and no locked version changes.
  - **Why pinned exactly:** it is 8 days old, and the workarounds (D43) depend
    on its internals. The equivalence tests pin them.
  - **No `flame_lottie`:** it can't play segments, pause on a frame, change
    speed or swap delegates on a pooled component.
  - **Where it draws:** board clips use our `LottieFxComponent` over
    `LottieDrawable`, inside Flame for z-order, pooling and same-frame
    hand-off. The HUD, overlays and screens use our `LottieFxView`.
- **D42. Rule-8 exception, scoped.** lottie allocates inside its own draw:
  - a `Paint` per fill;
  - a `LottieFrameInfo` per callback evaluation;
  - two `Rect`s per image;
  - trim-path metrics.

  Our position and scale callbacks must return a new `Offset`, which is the
  API's type. Everything else in our code is allocation-free per frame:
  - delegates built once per pooled drawable;
  - mutable per-clip state;
  - prebuilt rasters;
  - cached rest pictures and text painters.

  Text layers are hidden (D44) because they were the hot spot.
- **D43. Export defects are worked around in code.** The owner decided this,
  and a re-export request went to the designer
  (`docs/plans/lottie-reexport-request.md`). The workarounds:
  - **Image-slot compensation.** lottie 3.6.1 draws images at their pixel
    size, so each image layer's scale becomes `k / rasterScale` and its anchor
    `(a − origin) × rasterScale`. Animated-scale layers get a callback over the
    authored value.
  - **The travel-hold fix.** An anchor delegate stands in whenever the
    position callback was skipped.
  - **`padlock_ping` hidden at rest.**
  - **The 11 dp settle** is blended into the unlock's last hop.
  - **`doll_reveal`'s silhouette** is hidden after the wipe, so its shadow
    isn't drawn twice.
  - **BoardFit placement** (D46).
  - **Loading.** Compositions load with `LottieComposition.fromBytes`, and
    unused roles get a 1×1 blank image.
  - **lottie 3.6.1 quirks** also handled: construct a drawable before setting
    its delegates; never share a `ValueDelegate`; clamp marker ends; use
    inferred-type closures, since `LottieFrameInfo` isn't exported.
  - **Amended 2026-09-27 (D59, D60):** the designer's v3 export fixed the
    defects behind the travel-hold fix, the `padlock_ping` hide, the 11 dp
    settle, the silhouette hide and the animated-scale callbacks, and they
    were deleted. The image-slot compensation (now by `FxImageSlot.density`),
    BoardFit placement, loading and the quirks stay; the validator rejects a
    later export that brings a fixed defect back.
- **D44. Localized text is drawn by Flutter, not by the Lottie text layers.**
  - Text layers cost 0.4–2.3 ms per frame, can't be resized with a
    `textStyle` delegate, and are LTR-only. So the counter and ribbon files
    are drawn with their text hidden (a text delegate that returns '').
  - A cached `TextPainter` with the ARB string follows the `counter` or
    `ribbon` null's transform, captured in the same paint.
  - Too-long strings scale to fit the band instead of wrapping.
- **D45. The lid and body split hard at art y 400 everywhere (owner; impact
  I.1).**
  - `DollPartRasters` builds, per colour, a full-artboard lid (y < 400) and
    body (y ≥ 400), plus the silhouette (shadow included), at
    `artHeightPx = tallest doll × DPR`. The height is rounded up to a multiple
    of 3 so the width is whole.
  - Gold uses the ramp-rewritten masks, and the bodies bake the symbols mode.
  - Rest sprites draw the same rasters through `PartRasterDollRenderer`, so
    hand-offs are pixel-identical.
  - The goldens exclude the 388–412 band.
  - D37's `interior` / `bodyFront` nest passes and the SVG layer rasters are
    no longer used by the game; they stay for the admin and the goldens.
- **D46. Everything on the board is placed through BoardFit (owner; impact
  I.2).**
  - **Board-space files:** translated to `(originX, originY − 142·s)` and
    scaled by `s`, with the travel remap in reference units.
  - **In-place files:** doll files scale by `s`, board pieces by the slot's
    `s·q`.
  - **Doll size:** `doll_size = h / (150·scale)`.
  - Every authored motion distance scales with the board. At 390×844 this is
    exactly LOTTIE.md, and nothing clips on other screens. The dragged doll's
    drawn position is clamped to the board frame.
- **D47. Win families hop (owner; impact I.5).** The overlay plays
  `doll_win_hop` per completed family with a 150 ms stagger (App Flow 2.8).
  `doll_win_dance` ships but is unused in M2: the board is empty at Won.
- **D48. Reduced motion (owner; impact I.6).**
  - One-shot clips, tweens, cue offsets and staggers run at half duration.
  - The shakes are removed: static position delegates on `doll_invalid`'s
    `target` and `fx_ice`'s `ice`, and the hand-coded shake is off.
  - No confetti. `doll_pick` holds the end of `lift` instead of wobbling.
  - Ambient loops (idle, twinkle, the win hop) pause on frame 0.
  - Loops that carry information (select glow, hint arrow, booster glow,
    extra slot, spinner, tutorial hands) stay at 1×.
- **D49. `IceShattered` has no haptic.** This follows LOTTIE.md and
  `tokens.haptics`. The earlier M2 design said medium.
- **D50. The placeholder PNGs are not shipped (owner; impact I.7).**
  - They are the wrong sizes for lottie-flutter, take 1.79 MB on disk and
    8.2 MiB decoded.
  - `design/lottie/images/` stays in `design/` only.
  - `LottieComposition.fromBytes` never decodes them.
- **D51. Ice stages follow `BoardLayout.iceFrame` (owner; impact I.4).**
  - A crack segment plays only when the stage advances. Stage `n` rests on
    frame `16n`; the shatter always starts at frame 48.
  - An `IceCracked` that doesn't advance the stage still fires its cue and
    counts the badge down.
  - The M5 editor caps authored ice at 3.
- **D52. The M2 bloc contract.**
  - **Effect names.** The game's effects are `SelectionChangedEffect`,
    `MoveAppliedEffect(MoveApplied)`, `MoveRejectedEffect`,
    `BoardResetEffect`, `HintShownEffect`, `HintClearedEffect` and
    `ExtraSlotAddedEffect(ExtraSlotAdded)`. The `…Effect` suffix resolves
    D27's name clash with core's exports.
  - Each new effect bumps `GameplayState.effectSeq`.
  - `LevelRepository.entryAt(order)` returns core's `LevelBundleEntry`, so
    the state carries the level's order, chapter, tier, version and reward.
  - `SolverService` has one request in flight at a time (latest wins).
    Superseded or failed requests complete with null, and results come back
    as events tagged with their move sequence.
  - Owner-confirmed on 2026-09-26: the recorded M1 and render defaults
    Q30–Q38. Early towerless levels keep their §6.6 tier labels.
- **D53. The FX runtime and the timeline keep separate types.** The runtime's
  pooled, mutable types are `FxDrawable`, `FxDrawableParams`, `FxRange` and
  `FxLayout`; the timeline's immutable descriptors are `FxClip`,
  `FxClipParams`, `FxSegment` and `FxPlacement`.
  - `features/fx` never imports the gameplay folder, so the Flame board maps
    one onto the other: a hold or speed 0 becomes `FxPlan.rest(from)`, a loop
    `FxPlan(FxRange(from, to), loop: true)`; the params go to `setSize`,
    `setTravel`, `targetPos`, the rim and tint colours and
    `reducedMotion = !shake`. Q54 asks whether to keep one segment type.
  - Clips are driven, never self-running (`autoAdvance` false): each tick the
    board advances the live clips, then `timeline.advance(dt)`, then schedules
    the queued effects, so a clip starts in the frame its sprite hides (§10.1).
- **D54. The M2 services.**
  - The frozen interfaces grew, additively: `dispose()` on `AudioService`,
    `SaveService` and `SkinService` (injectable types the dispose hook on the
    interface), `SkinService.background`, and the save's wallet:
    `currentLevel`, `coins`/`addCoins`/`spendCoins`, `recordWin`,
    `boosterCount`/`useBooster`/`addBoosters` (a starter gift of 3 hints and
    2 slots, §8), `freeUndosPerLevel`, `unlimitedBoosters` (the dev flavor)
    and `changes`.
  - `InMemorySaveService` is the real save until M3 (D13). A fresh launch
    starts at level 1 with 0 coins (Q46).
  - `entryAt(order)` returns the first playable entry at or after `order`, so
    an invalid bundled level never blocks progress (Q43).
  - Sounds load from memory; `SoLoud.instance` is touched only in `init`, so
    DI and tests never load the native library. In the background voices
    pause and resume on return (Q45).
  - The skin service's fallback chain is part rasters, then placeholder
    rasters, then the placeholder painter; it never throws (rule 3).
- **D55. The gameplay bloc beyond the frozen contract.**
  - Constructor: (`LevelRepository`, `SolverService`, `RemoteConfigService`,
    `SaveService`, `AnalyticsService`); +1 Slot is free in debug builds.
  - A drag that starts on another pickable nest switches the selection
    (Q40). A drop on nothing, or back on the nest's own slot, cancels. Any tap
    or drag start clears a visible hint first.
  - The soft-stuck check runs 300 ms after a move, an undo or +1 Slot (Q41)
    and is skipped while a hint for the same board is pending.
  - A hint is charged only when it arrives; a null result uses
    `Solver.fallbackHint`; no move with an unsolvable verdict sets soft stuck
    and charges nothing.
  - A win pays `winRewardFor(tier)`: medium reads `reward_easy` until Q5 is
    decided, clamped at 0 or above, and calls `SaveService.recordWin`.
  - `NextLevelPressed` (only when won) loads the next entry;
    `GameplayStatus.allLevelsDone` follows the last level (Bonus Endless is
    M3). Analytics log the §14.4 events, with `booster_use{source: free}`
    for every M2 use (Q42).
- **D56. The gameplay page.**
  - The page builds `NestyGame` once, behind the `GameplayBoard` seam
    (`NestyGameBoard`; page tests use a recording fake).
  - The board's reports time the overlays: `onFamilyLanded` bumps the
    counter, `onWon` opens the win overlay, `onOutOfMoves` the sheet (a
    dismissed sheet stays closed until the board runs out again).
  - Every layout the board reports prepares the level's art
    (`LevelSkinLoader`: the latest request wins, a failure keeps the current
    art).
  - Continue sends `NextLevelPressed` and stays on the page (Q49). Pause
    pauses the bloc and the engine; the back button and the app going to the
    background open it.
  - Chapter numbers come from the bundle's `chapterId`s. The splash weights
    its progress (Lottie 45 %, skin 35 %, save and levels 15 %, audio 5 %);
    only a save or level failure offers a retry.
- **D57. The on-device playthrough.**
  - `apps/game/integration_test/playthrough_test.dart` runs the real
    `main_dev.dart` under the integration binding with the `fullyLive` frame
    policy, and `test_driver/integration_test.dart` saves its screenshots
    through `flutter drive` (`NESTY_SCREENSHOT_DIR`, by default
    `build/integration_test/screenshots/`).
  - Effects are scheduled in Flame's next tick, so the test waits until the
    board's latest scheduled state equals the bloc's and its timeline is idle.
    Mid-animation screenshots pause the engine at a timeline time.
  - `integration_test` and `flutter_driver` (SDK) are game dev dependencies,
    and the D8 guard accepts an `integration_test/` target in `Debug-<flavor>`
    only. CI doesn't run it (it needs a device).
  - `test/app_flow_test.dart` is the widget-level flow on fakes; it absorbed
    the screens lane's `home_flow_test.dart`.
- **D58. The M2 review fix pass (2026-09-27).** The behaviour the fixes chose
  (see [M2 review and fix pass](#m2-review-and-fix-pass-2026-09-27)):
  - **The next level's art is prepared during the win overlay.** The page
    prefetches it for `GameplayBoard.layoutFor(GameState.initial(next))`,
    the same layout the board computes on the same viewport. Continue waits
    for it, at most `GameplayView.nextArtWait` (2 s, rule 3), and the
    board's `onLayout` for that level adopts it synchronously, in the same
    Flame update as the reset. A skin holds only its own level's colours,
    so this is what keeps a new colour from drawing nothing.
  - **A reset ends a drag,** in the bloc and on the board: undo, restart
    and a new level. The finger's release then sends nothing. A drag
    released while paused puts the doll down: the bloc emits the drag
    cancel, and the doll flies home from where it is drawn on Resume.
  - **A second +1 Slot during the re-pitch is queued, not dropped.** Its
    re-pitch starts when the first ends, from that layout, and input stays
    locked through both. Each press of an enabled booster is honoured (it
    spends one in stg/prod); Q60 asks whether to ignore the second press
    instead.
  - **Won locks the chrome without greying it.** The pause button and the
    booster bar keep the look they had and take no touch (`IgnorePointer`),
    through the winning batch and under the win overlay. Undo still shows
    disabled after the winning completion, as after any completion (§2.4).
  - **Soft stuck with nothing to undo suggests Restart** (always free), and
    Undo doesn't glow. The banner fixes its suggestion when it shows and
    keeps it while it slides out. No frame shows it (`TODO(design)`).
  - **Home keeps the showcase rasters while a level covers it.** The
    part-raster cache (24 MB) keeps its own handles of them anyway, so
    releasing them freed little and cost a placeholder flash on every
    return. The worst case adds about 5 MB to a level (17.6 + 5.2 MB, under
    §4's 25 MB).
  - **Home past the last level** reads "PLAY · All done!" and opens All
    Levels Done; M3's Bonus Endless replaces it.
  - **Every `LottieFxView` is its own repaint boundary** (rule 8): a clip
    never repaints its neighbours, and a resting one costs nothing when they
    repaint.
- **D59. Claude Design v3 replaces our v2 re-export (owner, 2026-09-26).**
  The designer answered our v2 request with a v3 overlay, and the check
  workflow recommended importing it as delivered
  ([plans/claude-design-v3-check.md](plans/claude-design-v3-check.md)).
  - **Import.** `design/` = the repo's `design/`, then the audio export
    (`export/nesty-audio/design`, the owner's zip (3)), then the v3 overlay
    (`export/nesty-v3/design`, zip (5)): 381 files, hash-identical to the
    checked staging. This round was the only one allowed to write into
    `design/`; `export/` was removed afterwards.
  - **The designer's answers:**
    - 3c: the host rim under the host body in `doll_nest`/`doll_swallow` is
      intended. No change.
    - 3d: the reveal wipe grows from the doll's centre at art (256, 476):
      `MotionTokens.revealWipeCenter`, which `DollArt.revealCenter` now
      reads.
    - 3e: buried tower nests show the wood-grain blank
      `board/doll-silhouette.svg` for every skin
      (`BoardTokens.towerSilhouetteSprite`). `DollPartRasters` draws it on
      the 512×768 artboard when the skin service passes its board library
      (`prepare(board:)`); without it a set keeps the skin's own silhouette
      (rule 3).
  - **Accepted as delivered:** the ribbon tails may pass a 390 dp screen
    edge by up to 6 dp for about 100 ms during the 106 % pop; the
    re-rendered jingles (−17 RMS; `jingle_reward`'s limiting is an owner
    listening check).
  - **The tools now enforce what v3 promises,** so a later export can't
    bring a workaround back silently: issue `hold` (equal consecutive keys
    or `h: 1` on `travel` or `drop`), issue `imageTransform` (an animated
    anchor, position, scale or rotation on any image layer; opacity may
    animate), the `drop` null checked like `travel`, and the six new parent
    nulls required. `gen_fx_spec` no longer emits holds or animated scales.
  - **What this supersedes:** D43's list keeps only the image-slot
    compensation (raster and doll size), BoardFit placement, loading and
    the lottie 3.6.1 quirks. D40's hand-coded motions lose the tower
    reveal's drop and the 11 dp settle; the deeper silhouettes' shift stays.
- **D60. The v3 Lottie runtime (2026-09-27).**
  - **Raster units.** `FxRaster.scale` and `origin` stay in the slot's box
    units, which is what `LevelSkinImages` and `AssetSkinService` produce.
    `FxImageSlot` keeps the JSON's asset sizes (`assetWidth`/`assetHeight`,
    3× for the board pieces and the unlock symbol) and a `density` (3 for
    those, 1 for dolls), and `declaredWidth`/`declaredHeight` return the box.
    The compensation uses `r = raster.scale / density`: scale `k / r`, anchor
    `(a − origin × density) × r`.
  - **Root cause of the owner's Level 9 report (2026-09-27, device
    screenshots).** An earlier attempt of the lane had moved `FxImageSlot`
    to the 3× sizes but still read the raster scale as per 3× pixel, so
    every board piece drew at a third of its size with its anchor pushed
    three times too far: the hint arrow up and left of its doll, the glow
    ring at the shelf's left end, the +1 pads as slivers.
    `board_pieces_l9_test` renders Level 9 with the real skin images and
    Lotties and pins the arrow, the glow, both pads and a doll on a pad to
    `BoardLayout`; 4 of its tests fail with the old compensation.
  - **Hint arc.** It arrives on the source's side of the target (the board's
    middle when both are in one column), ending 48·s beside the target's
    head, 6·s below the top of its top doll (for an empty target, the
    moving nest's head). It starts 16·s toward the target and min(66·s,
    ⅔ of the doll) below the source doll's top. The control point is 0.4 ×
    the chord off its middle toward the arrival side, upward for a flat
    chord. This reproduces frame 3.1 (the MAIN-board test still gives about
    (352, 480)); on Level 9 the arrowhead now heads into brown2's head
    instead of the empty stand beside it. Other moves stay a
    `TODO(design)` generalization (Q64 asks about the start).
  - **The reveal.** `doll_reveal` plays its whole 31 frames from the move,
    and its `drop` null starts at the tower's own buried step (the
    authored (0, −18) scaled by that step). `RevealDropTween` only shifts
    the nests still buried, over the drop's 7 frames with easeOut. A
    source reveal now ends at 517 ms (the drop was a separate 120 ms
    before the 400 ms reveal). Without the file the new top shows at once
    (rule 3).
  - **Ice.** An `IceCracked` that advances the stage plays `crack_n`; one
    that doesn't plays `crack_hit_n` for the stage shown. Either then rests
    on `rest_n` (frame 16n in an export without markers).
  - **A clean seek on every jump.** `FxPlayer.epoch` changes on start,
    rest, seek and reset, and the next draw then seeks lottie to 0 before
    the target frame. lottie 3.6.1 otherwise draws `ice_0` and `ice_1`
    together when a reused drawable goes from 98.5 to 99 (verdict issue 1).
    Continuous playback never re-seeks.
  - **Ribbons.** 410-wide canvases with the anchors (205, 55) and (205, 50);
    text boxes 312×40 (win, Fredoka Bold 24) and 312×32 (chapter, 20),
    the label scaled down to fit the box's width and height. On screen the
    canvas is centred at `min(1, W/390)` (`LottieRibbonFit`,
    `ChapterRibbon.rectIn`), so it is 1:1 on the design's 390 dp phone and
    only ever scales down.
  - **Deleted:** the travel-hold fix, the `padlock_ping` rest hide, the
    11 dp glass settle, the reveal silhouette hide (the silhouette now ends
    at frame 19), the hand-coded reveal drop and the animated-scale
    callbacks (the `glow_pulse`, `slot_pulse` and `shatter_burst` nulls
    carry the pulses), together with `FxHold`, `FxTravel.holds`,
    `FxImageLayer.scaleAnimated` and `FxTiming.revealDropMs`.
- **D61. Music and jingles ship as OGG Vorbis in `design/audio` (owner
  delivery 2026-09-26; [plans/audio-integration.md](plans/audio-integration.md)).**
  - **Files.** `music_home` (Toy Shop Waltz, 66.667 s, 3/4 at 108 bpm),
    `music_game` (Quiet Shelves, 68.571 s, 4/4 at 84 bpm), `jingle_chapter`,
    `jingle_reward` and `jingle_oom`. The 17 SFX were replaced in place by
    the v2 WAVs, whose clacks are baked at 0 semitones
    (`SoundTokens.clackBakedSemitones`). That supersedes D19's +1 offset:
    the clack rate is now `2^(semitonesBySize/12)`. `SoundTokens.allFiles`
    stays the 17 WAVs; `jingleFiles` and `musicFiles` list the OGGs.
  - **Loading.** The loops stream: `loadMem(..., LoadMode.disk)`, never
    `loadAsset`, which leaves a 1.9 MB temp copy per launch. Each loads on
    first use, and the other one loads once the first has, so a crossfade
    never waits. The SFX and the jingles decode into memory; the jingles
    load after the SFX and the splash doesn't wait for them.
  - **One engine.** `SoLoudEngineHost` starts SoLoud once for whichever
    caller comes first and stops it only in its own dispose, after both
    services have freed their sounds. `SfxEngine.setPaused` and `dispose`
    now touch only the SFX's own sounds, and the music voices are
    protected, so a burst of SFX can't take their slots. An `AudioBackend`
    interface wraps the flutter_soloud calls both engines make; the tests
    run a fake with SoLoud's timing rules (fades and scheduled pauses only
    advance while a voice plays).
  - **Jingles** are a `JinglePlayer` interface implemented by the SFX
    service: the SFX bus (`jingleBus` 'sfx'), gated by the Sound setting.
    `AudioModule` registers the one instance under both interfaces.
  - **`MusicService`** (`SoLoudMusicService`, `FakeMusicService`) reconciles
    from state rather than a log of commands:
    - an 800 ms crossfade that parks the outgoing loop; a parked loop
      resumes where it stopped;
    - ducks counted per reason, the lowest factor wins (win 0.3, out of
      moves 0.4, reward 0.4, pause 0.5);
    - pause reasons as a set {background, ad}, faded back in over 600 ms;
    - the Music setting followed through
      `DatabaseService.musicEnabledChanges`: off is silent within 300 ms,
      and with Music off at launch it loads nothing;
    - silent failure (a loop that can't load stays silent until the next
      launch), and nothing per frame.
  - **Wiring.** `MusicRouteObserver` picks the track (Splash none, a level
    `music_game`, everything else `music_home`). `MusicDuck` ducks while
    the win overlay, the out-of-moves sheet (plus `jingle_oom` after the
    200 ms duck-in) and Pause are up. Pause's toggles only write the
    settings. `JingleCues.reward()` and `chapterComplete()` wait for their
    M3 and M6 callers.
  - **The owner's answers** (Q61–Q63): the iOS session is `.ambient`;
    chapter complete plays only `jingle_chapter`; SoLoud's low-latency
    output only in prod.
- **D62. The hint arrow keeps clear of the HUD (owner, 2026-09-27).** On
  boards whose top-row dolls are taller than any in the frames (the
  board-wide clamp: maxSize 3 on 3 shelves, L3 and L5–L9), the designed arrow
  (`cx, dollTop − 33·fs`) reached the HUD at the top of its 10·fs bob: the
  pause row (it ends 51 below the safe top) and, over a 4-slot row's inner
  columns, the family counter's 70 × 26 pill (it ends at 83). The owner
  chose "nudge + small push" over a full clamp, which would cover the
  doll's face on 6 levels. `SlotGeometry.hintArrowCenterX/Y` (from a
  `HudClearance` per layout, in screen dp because the HUD isn't scaled):
  - over the pill, the arrow steps sideways off it by at most a quarter of
    the pitch (Level 9's inner columns: about 10 dp);
  - then it moves down to stay 4 dp under whatever HUD piece is still above
    it, by at most 16·fs, so its tip reaches 8·fs into the doll's top at
    most (Level 9: about 13 dp on 390 × 844);
  - an arrow that clears the HUD keeps the design's place, frame 3.1's
    included.
  The middle column of an odd row can't step off the pill, so on L3, L5,
  L8 and L21–L23 its arrow drops the 16·fs and still tucks under the pill
  by 10–33 dp on a 393 × 852 screen (BACKLOG "Design gaps", a question for
  Claude Design). The
  Lottie arrow and the static fallback sprite share the rule.

## Package reasons (CLAUDE.md rule 9)

Versions are the resolved versions in the root `pubspec.lock`, checked
against every member's `pubspec.yaml` on 2026-09-26. "§13.2" says whether
spec §13.2 lists the package (it was amended for D1/D2). The root
`pubspec.yaml` only declares the workspace and has no dependencies. In the
apps every constraint is a caret on the locked version, except `auto_route`
and `lottie` (exact pins) and `intl` (`any`). In core and tools, `lints: ^6.0.0` and
`test: ^1.25.6` are lower floors than the locked versions.

The design foundation round (2026-09-26) added `flutter_svg`, `xml`,
`flutter_soloud` and the `tools` member (`nesty_tools`). Their new transitive
lock entries are `http` 1.6.0, `path_parsing` 1.1.0, `petitparser` 7.0.2,
`vector_graphics` 1.2.3, `vector_graphics_codec` 1.1.13 and
`vector_graphics_compiler` 1.3.0. The fonts are not packages: they are built
by `tools/fonts/build_fonts.sh` from pinned upstream commits with fontTools
4.60.1 in a throwaway venv (never a project dependency).

The M2 Lottie contracts (2026-09-26, D41) added `lottie` to the game. Its
new transitive lock entries are `archive` 4.3.0 and `posix` 6.5.2; no locked
version changed. `flame_lottie` was evaluated and not added.

The M2 integration (2026-09-26, D57) added `integration_test` and
`flutter_driver` (SDK) as game dev dependencies. Their new lock entries are
`process` 5.0.6, `sync_http` 0.3.1 and `webdriver` 3.2.0, plus the SDK's
`flutter_driver`, `fuchsia_remote_debug_protocol` and `integration_test`; no
locked version changed.

The post-M2 round (2026-09-27, D59–D61) added no package and changed no
locked version (`flutter pub get --enforce-lockfile` passes). The music and
jingles use `flutter_soloud`'s OGG Vorbis decoder, and the iOS audio session
is set in `AppDelegate.swift` with AVFoundation, so no `audio_session`
package was needed (Q61).

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
| `nesty_core` (path) | 0.1.0 | render, game, admin, tools | The single rule implementation (rule 2). `nesty_render` keys its palette, renderer API and generated `DollColorTokens` on `DollColor`. `tools` uses it to cross-check the tokens' doll colors (and for the M1–M2 level CLIs). The game imports it since M2 (the bloc's `GameSession`, the board, the bundled repository, the solver isolate); the admin declares it but doesn't import it yet | — |
| `nesty_render` (path) | 0.1.0 | game, admin, tools | Shared doll rendering and layout math. The game imports it from `lib/` since M2 (layout, part rasters, the rest renderer, sprites, backgrounds); the admin doesn't yet. `tools` imports only the Flutter-free `package:nesty_render/svg_tools.dart` (the asset sync's validator; `svg_tools_purity_test.dart` keeps it free of `dart:ui`) | — |
| `flutter_svg` | 2.3.0 | render | Spec §12.2: turns the layered skin, board and theme SVGs into `ui.Image` rasters once per size (Phase 3 skin rasterizer, board sprites, theme background; rule 8). For now only `bundled_svg_render_test.dart` uses it: flutter_svg compiles all 39 shipped SVGs with no warnings. Added in the design foundation round (2026-09-26) | yes |
| `xml` | 7.0.1 | render, tools | Flutter-free SVG parsing in `package:nesty_render/svg_tools.dart`: the spec §12.2 validator and metadata strip now, the skin layer splitter in Phase 3, and the admin upload check in M5. 7.0.1 is the newest that `vector_graphics_compiler` (via flutter_svg) accepts (`<=7.0.1`). `tools` declares it too (the plan listed it) but uses it only through `svg_tools.dart` so far | yes |
| `flutter_soloud` | 4.1.7 | game | Spec §11.3: low-latency SFX with per-play playback speed, needed for the per-size clack pitch (D19) and the combo chimes. Imported by `SoLoudBackend` (`core/services/audio/soloud_backend.dart`), the one seam both `SfxEngine` (the SFX and jingles, since M2 phase 4) and `SoLoudMusicService` (since the post-M2 round) go through; `SoLoudEngineHost` starts and stops the engine. Since D61 it also decodes the OGG Vorbis music (streamed with `loadMem(..., LoadMode.disk)`) and jingles with its bundled Ogg/Vorbis libraries, so **`NO_XIPH_LIBS` must never be set** in the Android or iOS build. **Why 4.x, not 5.x:** 5.x needs `native_toolchain_c` ^0.19.4, which needs `meta` ^1.19, but Flutter 3.41.2 pins `meta` 1.17.0. 4.1.7 is a classic FFI plugin (CMake on Android; podspec plus CMake on iOS), and the dev APK and iOS builds both link it. Upgrade with the SDK (Q23, BACKLOG "Later") | yes |
| `lottie` | 3.6.1 (pinned exactly) | game | **Owner decision (D40): every animation in the design ships as Lottie** (29 files). A pure-Dart Lottie player: board clips through our `LottieFxComponent` over `LottieDrawable`, the HUD, overlays and screens through `LottieFxView` (m2-lottie-design §2). **Why 3.6.1:** the newest release that resolves on Flutter 3.41.2 / Dart 3.11 (3.4.0–3.5.1 need Flutter 3.44; 3.6.0 is retracted). **Why the exact pin:** the export workarounds depend on its internals (image layers drawn at bitmap size, the travel-hold callback skip, the swapped progress fields for point values), and the equivalence tests pin them (D43). It brings `archive` 4.3.0 and `posix` 6.5.2 transitively. No `flame_lottie` (D41) | — |
| `path` | 1.9.1 | tools | Repo-relative path handling in the `nesty_tools` CLIs. Already in the lock transitively | — |

### Dev dependencies

| Package | Locked | Used in | Why | §13.2 |
|---|---|---|---|---|
| `test` | 1.29.0 | core, tools | Unit tests and the architecture guard; the `nesty_tools` codegen, sync and TODO-index tests | — |
| `lints` | 6.1.0 | core, tools | Base lint set for the pure-Dart members' strict `analysis_options.yaml` | — |
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
| `integration_test` (SDK) | — | game | The on-device playthrough `integration_test/playthrough_test.dart` (D57): the integration binding and `takeScreenshot`. Its iOS pod is linked in every configuration, and only registered in debug (BACKLOG "Tech debt") | — |
| `flutter_driver` (SDK) | — | game | The host side of `flutter drive`: `test_driver/integration_test.dart` runs `integrationDriver` and saves the screenshots (D57). It brings `process`, `sync_http`, `webdriver` and the SDK's `fuchsia_remote_debug_protocol` into the lock | — |

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
- [x] **Q4. What is the settings `symbols` value for large symbols?** §13.3
  shows only `"subtle"`. The large mode is "assist mode" in §10.2, §12.3 and
  §16, and "Large" in DESIGN_BRIEF Prompt 9. The skeleton persists
  `"assist"`. Resolved 2026-09-26: `large`, the handoff's decision the owner
  accepted (D19). A stored `assist` is read as `large`. The rename is built in
  M2 (BACKLOG).
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
- [x] **Q9. Web-safe solver hashing (M1, spec §6.2).** In the browser a
  Dart `int` is a JS number: exact to 2^53, with 32-bit bitwise operators.
  The 64-bit canonical hash therefore needs a web-safe design, such as two
  32-bit halves or `fixnum`. `fixnum` is already in the lock transitively; a
  direct dependency would need a reason recorded here. Resolved 2026-09-26:
  `Hash64` is two MurmurHash3_x86_32 halves in web-safe u32 arithmetic, no
  `fixnum` (D28); parity holds on the VM, node, Chrome and dart2wasm, and CI
  runs the web half (D39).
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
- [x] **Q14. Fonts.** DESIGN_BRIEF names Fredoka (display) and Nunito (body).
  They must be bundled as assets, not fetched at runtime with `google_fonts`
  (offline first launch, rule 3). Will the owner supply the font files with
  `design/`, or may they be added from the OFL releases? Resolved 2026-09-26:
  they are bundled as assets and sourced by tooling. The handoff ships no font
  files (D18), so the tooling adds the static Fredoka 500/600/700 and Nunito
  500–800 TTFs from google/fonts at a pinned commit, with OFL.txt, and the
  licenses are registered at startup (BACKLOG "Design foundation").
- [x] **Q15. The `design/` exports are missing.** Resolved 2026-09-26: the
  design handoff was delivered and is in `design/` (D18, commit 3a8dfca). Its
  screens are HTML prototypes in `design/prototypes/`, not PNGs. The admin
  designs are still missing (BACKLOG "Owner inputs needed"). The original
  question said these were needed:
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
- [x] **Q18. Can hidden tower nests show their size but not their color
  (spec §3.2)?** `DollRenderer` has a `silhouette` flag that ignores color.
  The paint-splash reveal (§11.1) is assumed to be composed by the caller.
  Confirm in M2. Resolved 2026-09-26: yes. Buried nests are wood silhouettes
  at their true size with the color hidden, following spec §3.2 rather than
  the design (D21). In the plan, the reveal wipe is a `DollRenderer` paint
  option driven by the board timeline.
- [x] **Q19. Where does a solvable fixture record its expected optimal move
  count (M1)?** The suggestion is to keep fixture files as pure §5.1 level
  JSON and put the expectations in the test. Resolved 2026-09-26: the
  fixtures stay pure §5.1 JSON, and the expectations are consts in
  `packages/nesty_core/test/solver/fixture_expectations.dart`
  (`test/fixtures/README.md`).
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
- [ ] **Q29. How should coins and counters get tabular figures (M2)?** The
  design says "Use tabular figures for coins and counters" (tokens.json
  `fontSize.number.tabular`), and numbers use Fredoka. But Fredoka's digits
  are proportional (advances 379–566 units) and it has no `tnum` feature, so
  `FontFeature.tabularFigures()` has no effect. Nunito's digits are already
  fixed-width. The options:
  - a fixed-width digit layout widget (simplest, no font change);
  - Nunito for numbers (changes the look);
  - a patched "Fredoka Tabular" built by `build_fonts.sh` (the OFL allows it
    under a new name).

- [x] **Q30. How should the towerless levels L3–L15 be graded (D26)?**
  Applied default (a): an open-slot-only board keeps its §6.6 tier (badge and
  coins) with a `tierOverride` reason. The alternatives: (b) declare them
  easy and relax the §6.6 pattern check for towerless boards (L6 and L10
  then pay easy coins and lose their badges); (c) introduce towers before
  L16, against §3.7.
  Resolved 2026-09-26: owner-confirmed default (a). Open-slot-only boards
  keep their §6.6 tier (badge and coins) with a `tierOverride` (D26, D52).
- [x] **Q31. What does the game do with an expert-only generated level
  (spec §6.4, D33)?** Bonus 40 (superhard, smart 0/300) and bonus 99 (medium,
  smart 142/300) of bonus levels 1–100 are expert only, and no admin reviews
  device-generated levels. Options: (a) the generator treats expert only as
  a tier miss and keeps looking (a `Generator.version` bump and new goldens);
  (b) the app shows the flag, which `GeneratorSuccess.simulation.expertOnly`
  already carries; (c) the §6.4 flag applies only to admin-authored levels.
  Decide before M3's Bonus Endless and daily.
  Resolved 2026-09-26: the owner confirmed the recorded default. The
  generator keeps returning an expert-only level with
  `simulation.expertOnly` set (D33). What the app shows for one is settled
  when Bonus Endless is built (M3, BACKLOG).
- [x] **Q32. Relax the exhaustive-search targets (design §5)?** An
  exhaustive 435,588-node proof takes 2.28 s on the VM (target 2 s) at
  191–289k nodes/s (target 300k); budget-limited searches, hints (35–38 ms)
  and soft-stuck checks (20–22 ms) are well inside. The admin steps the
  search, so the page never blocks. Proposed: "admin 500k ≤ 3 s VM worst
  case". The next levers are hashing only the changed key words and a
  count-only kernel routine.
  Resolved 2026-09-26: owner-confirmed. The relaxed target "admin 500k ≤ 3 s
  VM worst case" stands; the speed levers stay in BACKLOG "Later".
- [x] **Q33. Cap the admin generator's params, or scale the admin budget by
  board size (design §5 heap ≤ 64 MB)?** The widest board
  `Generator.checkParams` accepts (4×5, 17 depth-4 towers, 72 cells) holds
  72.3 MiB of typed lists at 500k nodes (80.3 MB peak), about 152 B/node.
  Typical boards stay at 86–125 B/node, 37–44 MB. No curve row comes near.
  Resolved 2026-09-26: owner-confirmed as built. No cap and no budget
  scaling for now; no curve row comes near the limit. The M5 admin generator
  re-checks it (BACKLOG M5).
- [x] **Q34. Confirm the default difficulty curve (design A16, D33) before
  M3.** Every row has one set per color and 1 empty slot unless noted; S =
  shelves × slots, T = towers × depth:

  | Levels | Easy | Medium | Hard | Superhard |
  |---|---|---|---|---|
  | 1 (all tiers) | 1 color, size 3, 2×3, empty 3 | same | same | same |
  | 2 (all tiers) | 2 colors, size 3, 2×3, empty 2 | same | same | same |
  | 3–9 | 3 colors, size 3, 2×4, empty 2 | 3 colors, size 3, 3×3, empty 2 | 4 colors, size 3, 3×3 | 4 colors, size 3, 3×4, empty 2 |
  | 10–15 | 3 colors, size 4, 3×3, empty 2 | 4 colors, size 4, 3×3 | 4 colors, size 4, 3×4, empty 2 | 5 colors, size 4, 3×4 |
  | 16–30 | 5 colors, 3×3, T 4×3 | 6 colors, 3×3, T 5×4 | 7 colors, 3×3, T 6×4 | 8 colors, 3×3, T 7×4 |
  | 31–50 | 6 colors, 3×3, T 4×3, 1 lock | 5 colors, 2×4, T 4×4, 1 lock | 6 colors, 3×3, T 5×4, 1 lock | 6 colors, 2×4, T 5×4, 1 lock |
  | 51–70 | 6 colors, T 4×3, 1 ice | 6 colors, T 5×3, 1 lock, 1 ice | 7 colors, T 5×4, 1 lock, 1 ice | 7 colors, T 6×4, 1 ice |
  | 71–120 | 6 colors, size 5, T 4×3, 1 lock, 1 ice | 6 colors, size 5, T 4×4, 1 lock | 6 colors, size 5, T 5×4, 1 ice | 6 colors, size 5, T 7×4 |
  | 121+ | as 71–120 | as 71–120 | as 71–120 | 6 colors, size 6, T 7×4 |

  Also: `bonusParams` takes the global play order (not the "Bonus Level N"
  count); the daily is medium on weekdays and hard on weekends on the 31–50
  boards; levels 1–15 can only reach easy (D26), so the generator returns the
  closest tier there. Any change alters generated levels and needs a
  `Generator.version` bump.
  Resolved 2026-09-26: owner-confirmed. The default curve table (A16) is the
  curve. BACKLOG M3 drops its `TODO(M3)`; any later change still needs a
  `Generator.version` bump.
- [x] **Q35. Confirm the recorded M1 defaults (design A-list and the build
  steps' readings).** Each is implemented, tested and changeable:
  - A3 fallback step 3: the first non-pointless placement, then the first
    placement; a hint on a won state returns no move (`none`, `solved`).
  - A17 smart bot: the lookahead drops moves to boards with no non-pointless
    move; "doesn't fill the last empty slot" counts empty, open-like,
    interactable slots (iced ones don't); "most merges after" counts ordered
    moves; when every candidate is dead the best-ranked is still played.
  - The default simulation seed hashes the board only (D32).
  - Rejection precedence (D27); `targetOccupied` unreachable.
  - `restart()` keeps `undosUsed` and the extra slots.
  - `solver.unproven` without a solver is an error; `generatorVersion` ≥ 1;
    rule 6 applied per lock, literally.
  - The engine lays out up to 28 authored slots (the validator's limit is 22).
  - Generator readings: the lock wait-cycle rule, no ice on a lock, the best
    deal kept after 20, invalid daily dates rejected.
  - Freeze the PRNG (D28), simulator (D32) and generator (D33) definitions
    under `Generator.version` 1 before M3 ships dailies.
  Resolved 2026-09-26: owner-confirmed. Every listed default stands. The
  PRNG, simulator and generator definitions are frozen under
  `Generator.version` 1 before M3 ships dailies (BACKLOG M3).
- [x] **Q36. Bundle policy (D34).** Should an expert-only bundled level fail
  CI rather than warn? Are the tutorials (L1–L2) plus open-slot boards the
  right set for `tierOverride`, or should intro levels (L16, L31, L51) be
  allowed? Keep the M2 layout limits (2–3 shelves, ≤ 4 slots) for every
  bundled level, or only for 1–30? May bundle entries start at `version` 0?
  Should unknown top-level bundle keys be ignored for forward compatibility?
  Resolved 2026-09-26: owner-confirmed as built. An expert-only bundled
  level warns. `tierOverride` covers the tutorials and open-slot boards. The
  M2 layout limits apply to every bundled level, bundle entries start at
  `version` 1, and unknown top-level keys stay errors. Revisit when bundling
  moves to a Firestore export (BACKLOG M5).
- [x] **Q37. Authored levels (D35).** Is L16's 4,3 board with two depth-4
  towers right for the tower intro (the design's 4,3,3 TOWER16 board is L18,
  easy)? The easy tower levels all simulate 100 % casual; should easy aim
  for 70–95 %? Check L6 (HARD) and L10 (SUPER HARD) in the M2 playtest.
  Resolved 2026-09-26: owner-confirmed. The authored levels stand as built
  (D35). L6 and L10 are still checked in the M2 playtest (BACKLOG M2).
- [x] **Q38. Render defaults (D36–D38).** The doll clamp gap 8/3 dp; a buried
  nest two or more sizes smaller than the top stays hidden behind it at 18 dp
  per depth; pips on an occupied extra slot; the 4-shelf preset scaling every
  piece by 104/150 (and a top-row tower's maxSize-6 doll standing 2 dp into
  the HUD there); the shine sweep crossing the doll over the full 300 ms
  (the prototype's CSS crosses in the middle ~40 %); the placeholder's look;
  both symbol sizes per atlas page; chapters 7+ cycling ch01–ch06; the
  theme's swap-on-ready; lazy glass frames 1–2; sprite fit as
  `preserveAspectRatio` meet.
  Resolved 2026-09-26: owner-confirmed. Every listed render default stands
  (D36–D38).
- [ ] **Q39. A tap on an unpickable slot with nothing selected (M2).** An
  empty, locked or iced slot tapped with no nest lifted is ignored today
  (`TODO(design)` in `tap_policy.dart`; frame 2.6 doesn't cover it). Should it
  shake the slot like an invalid move?
- [ ] **Q40. Dragging another nest while one is tap-lifted (M2, D55).** The
  drag start switches the selection (the drag reads as an explicit pick),
  while a tap there is an invalid move (D22). Keep that, or make the drag
  start invalid too?
- [ ] **Q41. The soft-stuck re-check (M2, D55).** It runs after an undo and
  after +1 Slot as well as after moves, so the banner stays right when an undo
  lands on another stuck board. The contract said "after each applied move".
  OK?
- [ ] **Q42. `booster_use` sources (M2, §14.4).** The spec allows `free`,
  `coins` and `ad`; M2 logs every inventory use as `free`. Should an inventory
  use have its own source?
- [ ] **Q43. Skipped bundled levels (M2, §5.3, D54).** An invalid bundled
  level makes `entryAt(itsOrder)` return the next playable one, and
  `levelCount` is the last available order. Is that the intended reading of
  "skipped with a log entry"?
- [ ] **Q44. Undos in the dev flavor (M2).** Boosters never run out there
  (`unlimitedBoosters`), and the bloc makes undos unlimited too (`canUndo`
  ignores the free-undo count), so the out-of-moves sheet shows no "Free · N
  left" chip. Is unlimited undo intended in dev?
- [ ] **Q45. Sound effects when the app goes to the background (M2, D54).**
  Voices pause and resume on return. Cut short one-shots instead?
- [ ] **Q46. Starting coins (M3, §7.3).** A fresh install starts with 0 coins;
  the spec gives no starting balance.
- [ ] **Q47. Figurine names and empty fallbacks (M3).** The design names only
  the Classic, Sailor and Baker Families. Should 4–10 be "The <Name> Family"?
  `figurineName`, `tierName` and `chapterName` return '' for an unknown id,
  and the win card then hides "Next up".
- [ ] **Q48. When a button's sound and haptic fire (M2).** On activation (a
  tap, or the screen reader's action), so a drag off the button stays
  silent; not on touch-down. OK?
- [ ] **Q49. Continue on the win overlay (M2, frame 2.11, D56).** It loads the
  next level inside the same page (`NextLevelPressed`), keeping the Flame game
  alive with no route transition, where the earlier M2 design replaced the
  route. Is that the intended flow?
- [ ] **Q50. The chapter ribbon's look (M2, frame 4.7).** The game follows the
  Lottie file's one-line ribbon ("CHAPTER 2 · Rainy Café Corner",
  m2-lottie-design §12), not NestyBoard's two-line blue card. Confirm the
  Lottie look wins.
- [ ] **Q51. M3 entries shown disabled (M2).** Home's settings gear and
  Pause's Settings tile are greyed out until M3, while the design draws them
  enabled. Keep them disabled, or enabled with no action?
- [ ] **Q52. An invalid move onto a tower (M2).** The whole tower (top doll,
  silhouettes) shakes by hand in sync, following §7 and
  `FxImageRequest.hideTarget`, rather than §9.3's "the top doll shakes in the
  file"; the "+N" tag stays still. OK?
- [ ] **Q53. Win timing and the combo clock (M2).** Won opens at 2117 + 250 ms
  as §7 says, while the last trail sparkles still fade under the scrim. The
  combo runs on board time (it stops while paused) and resets on start and
  restart, not on undo. OK?
- [ ] **Q54. Pools and segment types (M2, D53).** Pools follow
  m2-lottie-design §14 (2 per doll file, glass and ice one per slot), not
  LOTTIE.md's "dolls one per slot". And the timeline's `FxSegment` duplicates
  the runtime's `FxRange`/`FxPlan`: keep both or merge them?
- [ ] **Q55. Ice on an iced tower (M5, L51+).** `fx_ice` is anchored on the
  doll at the tower's surface (design §8), which puts the ice 5·fs above the
  static `iceRect` anchored on the stand. Should the ice follow the stand
  instead?
- [x] **Q56. Anchors of `ui_toggle` and `ui_splash_loader` (M2).** LOTTIE.md
  says only "toggle box" and "bar box"; the game takes their top-left, with
  the canvas as the widget's box. Or their centre?
  **Resolved 2026-09-27 (the designer, LOTTIE.md v3 "Inside the canvas"):**
  `ui_toggle`, `ui_spinner` and `ui_splash_loader` fill their canvas
  exactly, "because the canvas is the component box". That is what the game
  does; nothing changed.
- [x] **Q57. The HUD coins at Won (M2, frames 2.8, 1.5).** The bloc pays the
  reward at Won, so the HUD's coin pill shows the new balance while the win
  overlay counts "+10" up at 700 ms; the frames show the HUD still at the old
  balance. Hold the HUD until the count-up ends?
  **Resolved 2026-09-27 (owner: match the design):** the HUD shows the balance
  before the reward from Won (the flying set and the overlay, whose settled
  frame 2.8 still shows the old balance) until the next level starts
  (`GameplayView`, `gameplay_view_test` "keeps the old balance").
- [x] **Q58. The splash before the skin loads (M2, frame 1.1).** For about a
  second the three shelf dolls and the wordmark's doll draw with the
  procedural placeholder, then swap to the skin. Hide them until the art
  lands, or keep the placeholder?
  **Resolved 2026-09-27 (owner: match the design):** they stay hidden until the
  showcase's art lands, then fade in over `motion.ui.modalIn` (240 ms, none with
  reduced motion). With no showcase the placeholder draws them at once
  (rule 3); a showcase that fails leaves them hidden on the splash, and Home
  draws its placeholder dolls (`SplashView`, `Wordmark.dollShown`,
  `splash_page_test`).
- [x] **Q59. The subtle belly symbol: bare ink, or on a cream disc (M7,
  review FIDELITY-3)?** Every App Flow board frame (2.1–2.6, 1.3, 1.6) draws
  its dolls from `design/prototypes/skins/classic/preview/doll-*.svg`, which
  put the symbol on an r 55 `#FFF8EC` disc with a 5-unit ring in the colour's
  light shade. tokens.json (`skin.symbolSize` 110, no subtle disc), design
  README §3 ("filled with ink at 94 %"), `generator/nesty-doll.js` and
  `skins/classic/renders/*.svg` draw the bare symbol, and the game follows
  them. The precedence puts App Flow above the README, but tokens.json above
  both, and the tokens define only the large mode's disc. Which is canonical
  for `subtle`? If it is the disc, the subtle body raster (skin and
  placeholder) gains it, and the goldens change.
  **Resolved 2026-09-27 (owner): bare ink.** The subtle symbol stays as
  tokens.json, README §3, the generator and the renders draw it; the App Flow
  preview art's disc is not adopted. No code change.
- [ ] **Q60. +1 Slot pressed again during the re-pitch (M2, D58).** The
  second press is queued: a second slot re-pitches in after the first, and a
  second booster is spent in stg/prod. Or ignore presses during the 300 ms
  re-pitch, as the board's global lock does for taps?
- [x] **Q61. The iOS audio session (audio plan Q39).** Mix with the
  player's own music (`.ambient`), or stop it (the default)?
  **Resolved 2026-09-26 (owner): `.ambient`,** set in `AppDelegate.swift`
  (no package). It follows the silent switch, as Android already mixes.
  Keeping Nesty's music off while another app plays is an optional M7 item.
- [x] **Q62. Chapter complete's two jingles (audio plan Q40).** At 4.6 the
  figurine joins the Museum (AUDIO.md: `jingle_reward`) and the overlay
  opens (`jingle_chapter`). **Resolved 2026-09-26 (owner): only
  `jingle_chapter`;** `jingle_reward` is for skins, bought themes, the daily
  chest and purchases (`JingleCues`, M3 and M6 callers).
- [x] **Q63. Android screen recording (audio plan Q41).** SoLoud's
  low-latency output can't be captured by Android screen recorders.
  **Resolved 2026-09-26 (owner): low latency off in dev and stg, on in
  prod** (`Flavor.audioLowLatency`), so videos recorded on dev or stg builds
  have sound.
- [x] **Q64. Where the hint arc starts (M7, D60).** Frame 3.1 starts it 66
  below the source doll's top, two thirds down its 99 dp doll. The game
  keeps the 66 (capped at two thirds for smaller dolls), which on Level 9's
  tall brown3 lands on its upper body. Should it start at the head instead?
  **Resolved 2026-09-27 (owner): keep the design's value**, 66 below the
  top (capped at two thirds), as frame 3.1 draws it.
- [ ] **Q65. The extra slot's pulse under a doll (M7).** `ui_extra_slot`
  loops until the level resets, also while a doll stands on the slot.
  Frame 3.6 shows only an empty extra slot. Stop the pulse while it is
  occupied?
- [ ] **Q66. A music volume slider (M3).** `MusicService.setVolume` applies
  at once and cancels a running fade (a crossfade too). Fine for a slider;
  should it fade instead? Nothing calls it in M2.

### Notes for later milestones (not questions)

Since 2026-09-26 each note below is also an item in [BACKLOG.md](BACKLOG.md),
the tracker. They stay here as history. New notes go into BACKLOG.md instead.

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
  `ubuntu-latest`. (By 2026-09-26 the repo existed with a GitHub `origin`.
  Watching CI's first run is a BACKLOG "Tech debt" item.)

## Next step

[BACKLOG.md](BACKLOG.md) is the tracker for everything still to do. This
section only says where to look.

1. **This round (D23):** the design foundation and M1 are done, and M2 is
   code complete (D53–D58): the app plays on an iOS simulator and an Android
   emulator with every real service, and the review fix pass is in. Left for
   M2's acceptance (BACKLOG "M2"):
   - the owner's 60 fps check on a real mid-range Android device in a
     profile build, following [M2 acceptance](#m2-acceptance-spec-18)
     (`/perf-profile`);
   - the manual L1–30 pass on the dev flavor;
   - the owner's answers to Q39–Q60 (none blocks the acceptance).

   The unlock-symbol raster swap moved to M5, the tabular figures (Q29) to
   M7 and the load-failure copy to the design gaps. The on-device
   playthrough runs with `NESTY_SCREENSHOT_DIR=<dir> flutter drive --flavor
   dev --driver test_driver/integration_test.dart --target
   integration_test/playthrough_test.dart -d <device>` from `apps/game`.
2. **The post-M2 round** ([Post-M2 round](#post-m2-round-claude-design-v3-and-audio-2026-09-27))
   imported Claude Design v3 (D59, D60) and the music and jingles (D61), so
   the Lottie re-export and the music are no longer waited on. Left for the
   owner (BACKLOG "Post-M2 round" and "Owner inputs needed"): the device check of the Level 9 hint,
   +1 Slot, a tower reveal and the ribbons; the audio acceptance on a
   mid-range Android and an iPhone (gapless loops over 3 cycles, audible
   ducks, no clipping, streaming under 3 MB resident); the `jingle_reward`
   listening check; Q64–Q66.
3. **Owner inputs:** BACKLOG's "Owner inputs needed" lists what only the owner
   can supply or decide, with the milestone each one blocks. The first ones
   due are Q3 and Q5 (before M3) and the 9 missing figurine flavor texts.
4. Owner decisions that block nothing but are cheapest to take early: Q23
   (SDK upgrade), Q24 (deny globs), Q25 (rule 10 wording) and Q27 (Gradle
   wrapper).
