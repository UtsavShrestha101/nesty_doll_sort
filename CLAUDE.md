# CLAUDE.md — Nesty: Doll Sort

Nesty is an offline-first, ad-supported hybrid-casual puzzle game for Android and iOS built with Flutter + Flame, plus a Flutter Web admin panel backed by Firebase for authoring levels and uploading art.

**The source of truth is `docs/GAME_SPEC.md`. Read the sections a feature touches before starting it.** If the spec and code disagree, or the spec is ambiguous, stop and ask. Do not invent game rules. Two places add to the spec, and only by the owner's decision: the decisions log in `docs/PROGRESS.md` (`D<n>`; for example D18–D23 settle spec vs design, D91 makes Large color symbols the default), and for M7's features the approved text of `docs/plans/spec-proposals-m7.md`, which counts as spec until the owner pastes it in (D92, D93, Q85). Never edit `GAME_SPEC.md`.

The design handoff in `design/` is the source of truth for **look, layout, motion, sound and copy**. Match it. Rules still come only from the spec. Inside `design/`, `tokens.json` wins over the App Flow screens (`design/prototypes/Nesty App Flow.dc.html`, with frame ids like `2.6`). Those win over `design/README.md`, which wins over the Design System sheet (stale). Where the owner settled a conflict between spec and design, the decision in `docs/PROGRESS.md` wins (D18–D23). When a design is missing, use the tokens and the style described in spec §12, leave a `// TODO(design):` note, and add the gap to `docs/BACKLOG.md`. `design/` is owner-managed: never create or edit anything in it.

## Current state (keep current: see "Keeping this file current")

As of 2026-09-30. The full table is PROGRESS "Status"; the next steps are PROGRESS "Next step".

- **Done:** M0 (skeleton), M1 (`nesty_core`).
- **Code complete, acceptance waits on the owner's physical-device checks:** M2 (levels 1–30 playable on the design art), M3 (save, economy, chapters, Museum, Bonus Endless, Daily + streak, tutorial, Home, Settings, Shop).
- **In progress: M7**, moved ahead of M4–M6 by the owner (D90). It is 100% offline: levels 31–200, chapter themes 7–10, vs Computer (D93), eight engagement features under the respect rules (D92), star ratings (D125, `docs/plans/star-rating.md`). Plan: `docs/plans/plan-m7.md`; design (authoritative): `docs/plans/m7-design.md`; work list: BACKLOG "M7"; art and copy request: `docs/plans/claude-design-request-m7.md`.
  - Phase 1 is integrated (2026-09-28, D113–D124): levels 31–200, E1, E2, E5–E9, E12–E14 and the owner's simulator review; its device run passed on both platforms (D126–D131).
  - Phase 2 (vs Computer) is integrated (2026-09-28, D132–D142, m7-design "Phase 2"): the race core, the save's race API and `RaceRules`, `RaceCubit` and the bloc's race mode, rival select and the race screens as `TODO(design)` stand-ins, and the playthrough's rival-1 segment; its device run passed on both platforms (D143).
  - Phase 3 (star ratings, the daily share card, the opt-in reminder) is integrated (2026-09-29, D144–D161, m7-design P3.1–P3.15): `StarRating` and the bundle's `par` in core, the save's schema-2 star and solve fields with the load-time backfill, the bloc's stars, `StarRow` on the win card, Chapters and Records, `ShareService` and the solved card's Share, `NotificationService`, `DailyReminder`, the one-time offer and Settings' rows, four new packages and AGP 8.12.1, as `TODO(design)` stand-ins; its device run passed on both platforms (D162).
  - Phase 5's review pass is done in two rounds (2026-09-29, D163–D167, PROGRESS "M7 review pass"). Round 1: five lenses, five findings, four fixed and one deferred to Claude Design's I.2. Round 2: four deeper lenses and the rest of the accessibility audit, 33 findings, 32 fixed and one left to the owner (screen-reader play on the board, Q154); the overflow suite now also checks 48 dp targets, labels and cut text. The pass-and-play proposal awaits the owner: `docs/plans/pass-and-play-proposal.md`. The device run after the review passed on both platforms (D168). Left for the close: the VoiceOver and TalkBack pass, the fidelity audit (starting from D209's list in BACKLOG M7), translations, the `/milestone M7` gate.
  - Phase 4 (Claude Design's m7-3 delivery, in `design/` since D171; D172 keeps the +1 Slot on the bottom shelf) is integrated (2026-09-30, D173–D208, m7-design P4.1–P4.10): its tooling stage (tokens v3, the 35 Lottie files, the UI art, the generated Android notification icon, the 68-glyph font), its contracts stage (the frozen shapes, `core/ui/art/`, the toast queue, `SystemSettingsService`, copy.md in the ARB), then five lanes (the board's presets and tall pieces, section 09's race, Home, Chapters, the Museum, Records and the Shop, the daily and Settings, the overlays) and the integrator (the cross-lane edits, the playthrough on m7-3, five new device files in `nesty-test`). Its device run passed on both platforms (D209: every `nesty-test` device check on the iPhone 16 Pro simulator and the API 35 emulator, plus `--android --only reminder`). The design gaps are in `claude-design-request-m7.md` "Follow-up after m7-3".
- **Then:** M4 (Firebase content), M5 (admin), M6 (ads + IAP), M8 (release).
- The admin is still the M0 skeleton: sign-in and a shell whose nine spec §15 sections are "Coming in M5" placeholders.

## Repository layout (Dart pub workspace)

```
nesty/
  CLAUDE.md
  README.md                  # setup, run, codegen, test and on-device check commands
  docs/
    GAME_SPEC.md             # full game + tech spec (source of truth for rules)
    DESIGN_BRIEF.md          # the brief the design/ exports are made from
    PROGRESS.md              # you maintain this: status, decisions log (D<n>), package reasons, open questions (Q<n>)
    BACKLOG.md               # you maintain this: every remaining item, one section per milestone, plus owner inputs
    TODO_INDEX.md            # generated by `dart run nesty_tools:todo_index` from TODO(<tag>) markers; never hand-edit
    TEST_COVERAGE.md         # what `nesty-test` checks for each feature, on the host and on a device (the D169 rule)
    plans/                   # /plan output and design notes: m1-core-design, m2-lottie-design, m3-design, plan-m7, …
  design/                    # design handoff v1 (owner-managed, read-only for you)
    README.md                #   components, board layout, screens by frame id, motion, sound, owner decisions
    tokens.json              #   every color, gradient, type, radius, spacing, shadow, layout, motion, sound, haptic value
    skins/<id>/              #   7 layered 512×768 doll skins + skin.json; classic/renders/ holds reference renders
    board/  symbols/         #   board pieces (stand, plank, glass, ice, hint, glow…); 11 color symbols
    themes/                  #   ch01–ch10 chapter backgrounds, 1290×2796
    museum/  store/          #   figurines (use museum/png/) and app-icon art; their SVGs don't render in flutter_svg
    audio/                   #   23 SFX (WAV, spec §11.3 names), 2 music loops + 5 jingles (OGG); AUDIO.md is the contract
    lottie/                  #   35 Lottie animations + images/; LOTTIE.md (v3, m7-3) is the contract the tools validate against
    ui/                      #   M7 UI art (badges, chest, rivals, sprites, stars) + notification/ (the Android small icon); icons/ stays empty
    copy.md  DELIVERY.md     #   M7 copy by id, and the m7-3 delivery notes and "Choices"
    generator/               #   nesty-doll.js, nesty-sfx.js, nesty-music.js: reference doll-tint, SFX and music algorithms
    prototypes/              #   *.dc.html design references; open "Nesty App Flow.dc.html" in a browser
  packages/nesty_core/       # PURE DART: models, rules, session, codec, validator, solver, simulator, generator, PRNG
  packages/nesty_render/     # Flutter (no Flame): board layout, doll renderers, skin cache, palette, svg_tools
  apps/game/                 # Flutter + Flame mobile game (dev/stg/prod flavors)
    assets/                  #   synced from design/ + level bundle; generated, never hand-edit
    integration_test/        #   on-device checks via `flutter drive`: playthrough, resume A/B, daily fingerprint, board layouts, race loss, meta screens, daily states, overlays, the optional Android reminder check; `support/seeded_save.dart` seeds a save
  apps/admin/                # Flutter Web admin panel
  firebase/                  # firestore.rules, storage.rules, firestore.indexes.json, firebase.json
  tools/                     # nesty_tools workspace member: design pipelines, level CLI, TODO index (tools/README.md)
    levels/                  #   manifest.json + authored/L<nnnn>.json: the source of the bundled levels (levels/README.md)
    scripts/nesty-test       #   one-shot: CI's host checks, then the on-device checks on a simulator/emulator (docs/TEST_COVERAGE.md)
  .claude/                   # settings.json (permissions + hooks), hooks/, rules/, agents/, skills/
  .github/workflows/ci.yaml  # format, analyze, all tests (+ core web parity), codegen/asset/bundle drift, APK + web builds
  .vscode/                   # shared launch configs (one per app and flavor), extension recommendations
```

## Code map

Read this before exploring; open the files it names instead of scanning folders.

**`nesty_core`** (`lib/nesty_core.dart` exports everything public): `models/` (Level, Slot, SlotId, Doll, DollColor, Nest, Move, MoveEvent, MoveResult), `rules/` (`tryMove`, legal moves, undo, extra slot; `star_rating.dart`, the star rule of spec-prop §7.10; `rules/engine/` is the internals), `session/game_session.dart` (a level being played, emits `MoveEvent`s), `codec/` (level JSON §5.1, level bundle with each entry's `par`, session save), `validator/` (§5.3 rules 1–8, layout limits), `solver/` (§6.3 search, hints), `simulator/` (casual + smart bots, tiers, §6.4; `RivalBot`, the race's step-by-step rival), `generator/` (§6.5 params, Bonus Endless curve, the daily, the race's seed and params), `prng/`. Solver fixtures are in `test/fixtures/`, generator goldens in `test/generator/golden_test.dart`.

**`nesty_render`**: `board/` (`BoardLayout` math shared by the Flame board and the admin's `CustomPainter`), `doll/` (part-raster skin renderer, placeholder painter fallback), `skin/` (loader, manifest, rasterizer, cache), `palette/` (doll tint), `theme/`, `tokens/render_tokens.gen.dart`. `lib/svg_tools.dart` is a Flutter-free library that `tools/` imports.

**`apps/game/lib`**
- `bootstrap.dart` → DI (`core/dependency_injection/di.dart`; Hive opens in `database_module.dart`) → `app/app.dart` → `core/router/app_router.dart`.
- Gameplay flow: `features/gameplay/bloc/gameplay_bloc.dart` (a `BaseAsyncBloc` wrapping `GameSession`: pick, drop, undo, hint, boosters, tutorial; a race's player board, with `RaceCubit` beside it; a campaign win's stars; `tap_policy.dart`'s nudge of an unpickable slot) → `features/gameplay/game/nesty_game.dart` (Flame: `components/` board, slot, nest, FX layer) → `game/timeline/board_timeline.dart` plays each move's `MoveEvent`s in core's order. Overlays (win, out of moves, pause, chapter complete, tutorial, the milestone chest, a race's results in `RaceResultLayer`) are Flutter widgets in `features/gameplay/overlays/`; HUD (with a race's rival strip in its top row), booster bar and the race's action bar in `widgets/`; `pages/gameplay_entrance.dart` is the route's transition (the first launch's fade).
- Other features: `splash`, `shell` (tabs), `home` (`widgets/`: the chapter card, the Records button, `HomeLayout`'s 2.1/2.1b blend), `daily` (the reminder offer dialog, the streak card's looks; the Share button is on the daily win card since D188), `museum`, `shop`, `settings`, `chapters` (the chapter accordion and the level card, M7 E7; `cubit/chapter_star_tally.dart` is the one place Home and Chapters total the stars), `records` (Records and badges, M7 E8), `race` (vs Computer: rival select, `RaceCubit`; the race plays on the gameplay page, M7 phase 2), `fx` (Lottie library, `fx_spec.gen.dart`; `fx/chest/` is the chest opening both chests share), `dev` (level picker).
- Levels: `tools/levels/` → `nesty_levels bundle build` → `assets/levels/bundle.json` → `core/repository/bundled_level_repository.dart` (decodes and checks rules 1–7 on a worker isolate); `LevelResolver` maps a play request to a level (bundled, a replay, Bonus Endless, the daily or a race).
- UI kit: `core/ui/` (theme, `tokens/ui_tokens.gen.dart`, `icons/nesty_icons.gen.dart` with `icons/icon_uses.dart` naming each use's glyph, shared widgets; `widgets/stars/star_row.dart` is every star surface's one swap point; `widgets/feedback/toast_queue.dart` is the toast queue, one host at the app root). `core/ui/art/` is the m7-3 UI art: `UiArt` (the stars, the chest, the sprites, the rivals, the badges), `UiArtLibrary` (rasters once per size, real and fake), `UiArtImage` and `UiArtImageSource` for the Lottie slots, and `theme_thumbnail_loader.dart` (the themes' crops for the Shop and Chapters: an LRU, a scope and a shared asset loader, no DI binding). `widgets/home/` holds `StarsChip`, `TextLink` (48 dp) and `StreakLook`; `widgets/race/` the `ComputerTag` and `RivalPortrait` every rival surface uses.

**Services** (`apps/game/lib/core/services/<name>/`, interface + real + fake; which env gets which is on each class's `@LazySingleton(as: …, env: …)`):

| Interface | Real implementation today | Real one lands |
|---|---|---|
| `LevelRepository`, `CatalogRepository` (`core/repository/`) | bundled JSON assets | M4 adds Firestore sync |
| `SaveService` | `HiveSaveService` (`SaveDocument`, `save_migrations.dart`) | done |
| `DatabaseService` | `HiveDatabaseService` (settings + save boxes; in-memory fallback) | done |
| `DailyService` | `StreakDailyService` (both envs) | done |
| `SolverService`, `LevelGeneratorService` | isolate implementations | done |
| `SkinService` | `AssetSkinService` (bundled skins) | done; M4 adds Storage downloads |
| `FxLibrary` (`features/fx/`) | `AssetFxLibrary` (bundled Lottie) | done |
| `AudioService` (SFX + jingles), `MusicService` | SoLoud | done |
| `HapticsService`, `AppClock`, `AppInfoService`, `LinkLauncher` | system / package_info / url_launcher | done |
| `FrameTicker` (`services/ticker/`, the race clock) | `SchedulerFrameTicker` (a factory, both envs) | done |
| `NotificationService` (`services/notifications/`, the daily reminder; its Android icon `res/drawable/ic_notification.xml` is generated by `sync_design_assets` from `design/ui/notification/`) | `LocalNotificationService` (flutter_local_notifications + timezone + flutter_timezone) | done |
| `ShareService` (`services/share/`, the daily share card) | `SharePlusShareService` (share_plus) | done |
| `SystemSettingsService` (`services/system_settings/`, "Open phone settings") | `ChannelSystemSettingsService` (a platform channel the app's Android and iOS code answers) | done (`MainActivity.kt` and `AppDelegate.swift` answer it, M7 phase 4 lane D) |
| `UiArtLibrary` (`core/ui/art/`, the UI art's rasters) | `AssetUiArtLibrary` (bundled `assets/ui/**`) | done |
| `RemoteConfigService` | `DefaultsRemoteConfigService` (hard-coded defaults, `remote_config_keys.dart`) | M4 |
| `AnalyticsService` | fake in both envs | M4 |
| `AdsService`, `PurchaseService` | fake in both envs | M6 |

`services/chest/` (`MilestoneChest`) and `services/records/` (`RecordRules`, `BadgeRules`) are pure M7 meta rules with no interface; the bloc and `SaveService.recordLevelWin` call them. `services/race/` (`RaceRules`: unlock, stage, pace, reward) is vs Computer's, called by the resolver, `RaceCubit` and rival select. `services/records/star_rules.dart` (`StarRules`: the slack, the stars key, the backfill) is the star rating's app glue. `services/reminder/` (`DailyReminder`) composes `NotificationService`, `DatabaseService` and `DailyService` with no interface of its own, and `bootstrap` starts it.

**`apps/admin/lib`**: `app/session_cubit/`, `core/services/auth/` (`AuthService`: fake, and `UnconfiguredAuthService` in real until M5), `core/router/auth_guard.dart`, `features/<section>/pages/` placeholders.

## Commands

No FVM: use `flutter` and `dart` from PATH (Flutter 3.41.2 stable with Dart 3.11, the version CI pins).

```
flutter pub get                                         # at repo root: resolves every workspace member
cd apps/<game|admin> && flutter gen-l10n                # after any .arb change; run before build_runner
cd apps/<game|admin> && dart run build_runner build     # freezed, injectable, auto_route, hive_ce outputs
cd packages/nesty_core && dart test                     # core rules/solver tests — must always pass
cd packages/nesty_core && dart test -p node test/parity test/generator/golden_test.dart   # web parity (CI also runs chrome + dart2wasm)
cd packages/nesty_render && flutter test
cd apps/<game|admin> && flutter test                    # cubit + widget tests on fake services
flutter analyze                                         # at repo root; zero issues (CI adds --fatal-infos --fatal-warnings)
cd apps/game && flutter run --flavor dev -t lib/main_dev.dart                                    # game: dev|stg|prod
cd apps/admin && flutter run -d chrome -t lib/main_dev.dart --dart-define=NESTY_FAKE_SERVICES=true  # admin
cd firebase && firebase emulators:start                 # local Auth/Firestore/Storage (needs firebase-tools)
cd tools && dart test                                   # nesty_tools: codegen, asset sync, levels, TODO index, CLAUDE.md and test-coverage drift
dart run nesty_tools:gen_design_tokens                  # design/tokens.json → render_tokens.gen.dart + ui_tokens.gen.dart
dart run nesty_tools:sync_design_assets                 # design/ art, UI art, audio, Lottie → apps/game/assets, + the Android notification icon (validated)
dart run nesty_tools:gen_fx_spec                        # design/lottie + the Lottie contract → features/fx/fx_spec.gen.dart
dart run nesty_tools:gen_nesty_icons                    # NestyIcons from the bundled icon-font subset
dart run nesty_tools:todo_index                         # regenerate docs/TODO_INDEX.md from TODO(<tag>) markers
dart run nesty_tools:nesty_levels bundle build|check    # tools/levels → assets/levels/bundle.json; check = CI gate
dart run nesty_tools:nesty_levels validate|solve|simulate|report|generate|fixtures check   # --help for flags
tools/fonts/build_fonts.sh [--verify]                   # rebuild the bundled fonts from pinned upstream (network)
tools/scripts/nesty-test [--android] [--device-only] [--only <check>]   # CI's host checks + on-device checks (--only board,race,meta,daily_states,overlays: phase 4's files; --android --only reminder: the optional reminder check); --help
```

- The `nesty_tools:` scripts run from any directory of the repo. Each takes `--check` (write nothing, exit 1 on drift), which CI runs; details in `tools/README.md`.
- The single on-device checks (`flutter drive` with `integration_test/*_test.dart`, `NESTY_FAKE_DATE`, `--keep-app-running` for resume phase A) are spelled out in README "Tests and analysis".
- The game has no flavorless build: always pass `--flavor <f> -t lib/main_<f>.dart`.
- `--dart-define=NESTY_FAKE_SERVICES=true` switches a **debug** build to all-fake services (the only way to sign in to the admin before M5). Profile and release builds ignore it.
- `docs/PROGRESS.md` lists any command that is currently blocked and why.

The owner runs `flutterfire configure` to create Firebase config files. Never hand-write or invent `firebase_options.dart`, `google-services.json` or `GoogleService-Info.plist`.

## Hard rules

1. **Flutter stable channel only.** Do not use `flutter_scene`, Flutter GPU or any master-channel feature.
2. **All game rules live only in `nesty_core`** (pure Dart, no Flutter imports). The game, admin, solver, generator, simulator and `tools/` all call the same rule functions. Never re-implement a rule elsewhere.
3. **Offline-first.** The game must be fully playable with no network from first launch (bundled levels + bundled default skin). Every network call (Firestore, Storage, ads, IAP, Remote Config) must fail gracefully and silently.
4. **Services behind interfaces.** Every service and repository in the Code map table has an interface, a real implementation and a fake one. Debug builds and tests can switch to fakes.
5. **Ads:** use Google's official test ad unit IDs in debug builds. Real IDs come from build-time `--dart-define` values. Never commit real IDs or any secret.
6. **Remote Config:** every key has a hard-coded default in `RemoteConfigService` (spec §9.4).
7. **Deterministic core.** The generator and simulator take an explicit seed and use their own PRNG (spec §6.5), never `Random()` without a seed and never `DateTime.now()` inside core. The app owns the clock (`AppClock`).
8. **Performance:** 60 fps on low-end Android (2 GB RAM). Rasterize skins once into cached `ui.Image`s. No per-frame allocation in hot paths. The on-device solver runs in an isolate.
9. **No new packages without a reason** written in `docs/PROGRESS.md`. Preferred packages are listed in spec §13.2.
10. **State management:** Cubit-first `flutter_bloc` for app/UI state. Async cubits extend `BaseAsyncCubit<T>` and emit the freezed `AsyncValue<T>` (`lib/core/base/`); use `BaseAsyncBloc` only where events must be handled strictly in order. Dependencies come from `get_it` + `injectable` annotations (`final get = GetIt.instance;`), never hand-registered. Flame components never own game truth; they render state from `nesty_core` and play animations from its `MoveEvent`s.

## Conventions

Detailed, path-scoped rules load automatically from `.claude/rules/` when you touch matching files: `auto-route`, `bloc-cubit`, `di-injectable`, `firebase`, `flame`, `freezed`, `hive`, `l10n`, `nesty-core`, `services`. They hold pinned versions and snippets (for example `auto_route` is pinned to exactly 11.1.0, PROGRESS B1). The summary:

- **Routing:** `auto_route`, one `lib/core/router/app_router.dart` per app. Screens are `@RoutePage()` widgets. Navigate with `context.router`, never `Navigator.push`, and pass arguments through the generated route constructors.
- **DI environments:** `AppEnv.real` and `AppEnv.fake` pick implementations, and each implementation declares its environments. A service whose real implementation lands in a later milestone registers its offline fake for both until then. Tests use `configureTestDependencies()` from `test/helpers/`.
- **Models and states:** freezed 3 (`@freezed abstract class` for data classes, `@freezed sealed class` with public case classes for unions). Not in `nesty_core`, whose models are hand-written with `==`/`hashCode`.
- **Local storage:** Hive via `hive_ce`, in `apps/game` only (the admin keeps its data in Firestore). Boxes (settings and save) are opened once in bootstrap (`DatabaseModule`, `@preResolve`) and reached only through `DatabaseService` and `SaveService`. If Hive can't open, the game falls back to in-memory storage. Box names (`HiveBoxes`), typeIds (`HiveTypeIds`) and field indexes are a contract with players' devices: never rename a box, never reuse an id or index, and never assign 200/201 (reserved by `hive_ce_flutter`). Every new save field is a schema step with a migration in `save_migrations.dart`.
- **Flavors:** dev, stg, prod. `lib/main_<flavor>.dart` sets `FlavorConfig`, then calls `bootstrap()`. Android uses product flavors, iOS uses `Debug-/Profile-/Release-<flavor>` build configurations with one scheme per flavor. Bundle ids are `com.futrix.nesty`, `.dev` and `.stg`.
- **Generated files are committed and never hand-edited** (the `block-generated` hook and the settings deny-list refuse it); CI fails if any is stale. build_runner and gen-l10n make `*.freezed.dart`, `*.g.dart`, `*.gr.dart`, `di.config.dart` and `lib/l10n/app_localizations*.dart`. `nesty_tools` makes `*.gen.dart`, `docs/TODO_INDEX.md`, `apps/game/assets/` (synced art, audio, Lottie, fonts) and `assets/levels/bundle.json`. Change the source and re-run the generator.
- **l10n:** each app's `lib/l10n/app_en.arb` is the source of truth (English only so far). Read strings with `context.localizations.someKey`. Every key has a description.
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
- Generator: same seed + params must give identical output. All generated levels must be solvable. `test/parity/` and the goldens also run on node, chrome and dart2wasm.
- Apps: `bloc_test` for cubits and widget tests for the main flows, using fake services (`AppEnv.fake`).
- Widget-test harness facts: `Bloc.close()` never completes inside `testWidgets`' fake-async zone, so don't await it there (use `tester.runAsync`); real Hive I/O only finishes by alternating `tester.runAsync` with `pump` (`settle` in `apps/game/test/app_flow_test.dart`).
- Hooks: every Dart write is run through `dart format`, and the Stop hook runs `nesty_core`'s tests when core changed (`NESTY_SKIP_STOP_TESTS=1` skips it).
- **`nesty-test` covers every feature (owner, D169).** A new or changed feature ships, in the same change, with:
  - its host tests, in a suite `nesty-test` runs;
  - its flow on a device: a step, with a screenshot, in `apps/game/integration_test/playthrough_test.dart`, or its own `integration_test/*_test.dart` that `tools/scripts/nesty-test` drives;
  - its row in `docs/TEST_COVERAGE.md`.

  When a simulator can't drive something (an OS dialog, a delivered notification, haptics), its row says why and names the host test that covers it. `tools/test/test_coverage_test.dart` fails when a feature folder or an on-device check has no row, or when `nesty-test` doesn't run an on-device check.

## Workflow

- Work milestone by milestone as spec §18 lists them, in the owner's order: M7 runs before M4–M6 (D90). Don't start the next milestone until the current one's acceptance criteria pass. The M2 and M3 physical-device checks stay open with the owner and don't block M7 (D90).
- **Starting a milestone:** read its section in `docs/BACKLOG.md`, its spec §18 entry, and the open questions they cite.
- **Deferring anything** (a design gap, a hook for a later milestone, an owner input): add a `docs/BACKLOG.md` item (`- [ ] <item> — <source>`) under the milestone that will do it, or a `// TODO(<tag>): ...` in code, or both. Code-level work should get both. The tag is `M1`…`M8`, `design`, `v1.1` or `later`, and an untagged TODO fails CI.
- **Ending a milestone** (the `/milestone` skill):
  1. Run `flutter analyze` and all tests.
  2. Tick the finished BACKLOG items, and move leftovers to a later section with the reason.
  3. Regenerate `docs/TODO_INDEX.md` with `dart run nesty_tools:todo_index`.
  4. Update `docs/PROGRESS.md` with what was done, decisions made and open questions.
  5. Bring this file current (next section), "Current state" first.
- New decisions go in the PROGRESS decisions log as the next `D<n>`, new owner questions as the next `Q<n>`.
- Dolls render from the design skins (PROGRESS D23). The procedural placeholder painter (spec §12.5) stays as the fallback when a skin can't load.

## Keeping this file current

Every session starts from this file instead of reading the repo, so a stale line sends work to the wrong place. **Update CLAUDE.md in the same change that makes it stale**, never "later". This applies to every session and subagent, whatever the task.

- **Update it when a change:**
  - adds, removes, renames or moves a workspace member, a top-level folder, a feature, a service or repository interface (or its real implementation), or anything the Code map names;
  - adds or changes a command, a `nesty_tools` script, a generator or generated output, a CI job, a hook, a skill or a `.claude/rules` file (Commands must match README.md's: change both);
  - starts, finishes or reorders a milestone, or changes what is in progress ("Current state", with its date);
  - records an owner decision that changes where rules come from or how the work is done.
- **Facts vs rules.** Any session keeps the facts current: Current state, the layout, the Code map and its table, and Commands. The Hard rules, Conventions, Workflow, Git and the source-of-truth order change only when the owner asks, with the decision in PROGRESS.
- **Keep it short.** One line per item. Point to the doc that holds the detail (PROGRESS, BACKLOG, a README, `.claude/rules/`, a plan) instead of copying it. Delete what is no longer true.
- **Checked by a test.** `tools/test/claude_md_test.dart` (in `cd tools && dart test`, CI and the `/milestone` gate) fails when a workspace member, top-level folder, `nesty_tools` script, `.claude/rules` file, game feature folder or DI-bound interface is missing from this file. It can't check the prose, so before finishing a task, re-read the sections it touched and fix them.

## Git

- Conventional commits: `feat(game): ...`, `fix(core): ...`, `docs: ...`, `chore(ci): ...`.
- No `Co-Authored-By` trailer or any other Claude attribution in commits or PRs.
- Never force-push.
