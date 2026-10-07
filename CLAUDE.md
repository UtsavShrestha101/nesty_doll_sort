# CLAUDE.md — Nesty: Doll Sort

Nesty is an offline-first, ad-supported hybrid-casual puzzle game for Android and iOS built with Flutter + Flame, plus a Flutter Web admin panel backed by Firebase for authoring levels and uploading art.

**The source of truth is `docs/GAME_SPEC.md`. Read the sections a feature touches before starting it.** If the spec and code disagree, or the spec is ambiguous, stop and ask. Do not invent game rules. Two places add to the spec, and only by the owner's decision: the decisions log in `docs/PROGRESS.md` (`D<n>`; for example D18–D23 settle spec vs design, D91 makes Large color symbols the default), and for M7's features the approved text of `docs/plans/spec-proposals-m7.md`, which counts as spec until the owner pastes it in (D92, D93, Q85). Never edit `GAME_SPEC.md`.

The design handoff in `design/` is the source of truth for **look, layout, motion, sound and copy**. Match it. Rules still come only from the spec. Inside `design/`, `tokens.json` wins over the App Flow screens (`design/prototypes/Nesty App Flow.dc.html`, with frame ids like `2.6`). Those win over `design/README.md`, which wins over the Design System sheet (stale). Where the owner settled a conflict between spec and design, the decision in `docs/PROGRESS.md` wins (D18–D23). When a design is missing, use the tokens and the style described in spec §12, leave a `// TODO(design):` note, and add the gap to `docs/BACKLOG.md`. `design/` is owner-managed: never create or edit anything in it.

## Current state (keep current: see "Keeping this file current")

As of 2026-10-08. The full table is PROGRESS "Status"; the next steps are PROGRESS "Next step". Detail for each line below is in PROGRESS and BACKLOG.

- **Done:** M0 (skeleton), M1 (`nesty_core`).
- **Code complete, acceptance waits on the owner's physical-device checks:** M2 (levels 1–30 on the design art), M3 (save, economy, chapters, Museum, Bonus Endless, Daily + streak, tutorial, Home, Settings, Shop).
- **Code complete 2026-10-05, acceptance waits on the owner: M7**, ahead of M4–M6 by the owner (D90). 100% offline: levels 31–200, chapter themes 7–10, vs Computer (D93), eight engagement features under the respect rules (D92), star ratings (D125). Plan `docs/plans/plan-m7.md`, design `docs/plans/m7-design.md`, work list BACKLOG "M7".
  - Phases 1–3 (levels 31–200 and the engagement features, vs Computer, star ratings, the share card and the reminder) are integrated, each with its device run passed on both platforms (D113–D162).
  - Phase 4 (Claude Design's m7-3, in `design/` since D171; D172 keeps the +1 Slot on the bottom shelf) is integrated, its device run passed (D173–D209).
  - Phase 5, the close (2026-10-01 to 2026-10-05): the review pass (D163–D168), 5A (D210–D234), m7-4 wired, device-run, audited and fixed (D241–D258) and 5B, the translations, are done as of 2026-10-05: nine locales (en + es, pt-BR, id, hi, de, fr, tr, ja), the Baloo 2 and M PLUS Rounded 1c script fonts, the text fit, the language sheet and the locale tests (D261–D267, Q175–Q181; PROGRESS "Phase 5, 5B"). The results of the 5B and 5f device reruns are still being added.
  - 5C: the review and its fixes (D271) and the `/milestone M7` gate, passed on both devices with its reruns (PROGRESS "Phase 5, 5C").
  - Left with the owner: the design sign-off (Q161), the VoiceOver pass (`docs/plans/voiceover-checklist.md`) and Claude Design's follow-up (§1–§14).
- **Code complete 2026-10-05, with M7's sign-offs open (D268, D272, D276–D280):** the daily gift, a 7-day login reward that counts claims, so a missed day never moves it back. Plan `docs/plans/plan-login-gift.md`, work list BACKLOG "Daily gift". It passed `nesty-test --only gift` on both devices. Claude Design's section 13 (m7-5, D281–D296) is in: the final look, glyph and copy are wired, and every on-device check passes on both platforms (PROGRESS "m7-5, Device run and fidelity"). The owner's paste of §7.5b is still open; Q187–Q188 hold defaults (Q186 is answered).
- **Then, still local (D237):** the habit proposals in `docs/plans/local-habits-brainstorm.md` (all four, in order, the widget last: D274), then the engagement proposals in `docs/plans/engagement-research.md` (D259; Q173 asks which) and the kid path's local part (D260), which must land before M4, and the themes, characters and story proposals in `docs/plans/themes-characters-story.md` (D270; wave 1 first: D275; original characters only, no licensed IP). None starts until M7 is closed.
- **Audience (D260):** under-13s are a target too (a mixed audience). Every player under 13 or of unknown age gets the kid path: an age question, a parent area, and child-safe analytics, ads and purchases. Its items are in BACKLOG, Q174 holds the defaults, and spec §1 and §17 wait for the owner's paste (engagement-research §6.4).
- **At the end:** M4 (Firebase content), M5 (admin), M6 (ads + IAP), M8 (release on production Firebase). D90 put M7 ahead of M4–M6; D237 keeps that backend work after the local habits as well.
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
    board/  symbols/         #   board pieces (stand, plank, glass, ice, hint, glow…) + ch07–ch10/ (those chapters' own wood); 11 color symbols
    themes/                  #   ch01–ch10 chapter backgrounds, 1290×2796
    museum/  store/          #   figurines (use museum/png/) and app-icon art; their SVGs don't render in flutter_svg
    audio/                   #   23 SFX (WAV, spec §11.3 names), 2 music loops + 5 jingles (OGG); AUDIO.md is the contract
    lottie/                  #   37 Lottie animations + images/; LOTTIE.md (m7-4) is the contract the tools validate against
    ui/                      #   M7 UI art (badges, chest, rivals, sprites, stars, gift/ the daily gift's glyph) + notification/ (the Android small icon); icons/ stays empty
    copy.md  DELIVERY.md     #   M7 copy by id, and the m7-4 delivery notes and "Choices"
    generator/               #   nesty-doll.js, nesty-sfx.js, nesty-music.js: reference doll-tint, SFX and music algorithms
    prototypes/              #   *.dc.html design references; open "Nesty App Flow.dc.html" in a browser
  packages/nesty_core/       # PURE DART: models, rules, session, codec, validator, solver, simulator, generator, PRNG
  packages/nesty_render/     # Flutter (no Flame): board layout, doll renderers, skin cache, palette, svg_tools
  apps/game/                 # Flutter + Flame mobile game (dev/stg/prod flavors)
    assets/                  #   synced from design/ + level bundle; generated, never hand-edit
    integration_test/        #   on-device checks via `flutter drive`: playthrough, resume A/B, daily fingerprint, board layouts, race loss, meta screens, daily states, overlays, faults, the semantics tour, the optional Android reminder check; `support/seeded_save.dart` seeds a save, `support/fault_services.dart` installs a fault through `bootstrap(beforeRunApp:)`
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
- Other features: `splash`, `shell` (tabs), `home` (`widgets/`: the chapter card, the Records button, `HomeLayout`'s 2.1/2.1b blend), `login_gift` (the daily gift: `LoginGiftCubit`, Home's `GiftButton`, `GiftSheet` on its own `GiftSheetRoute` (the scrim with the coin pill's hole) with its `GiftDayTile`s, Home's `GiftTally`, Day 7's `GiftChestModal`; the sizes blend 844 dp to 16:9 in `gift_metrics.dart`), `daily` (the reminder offer dialog, the streak card's looks; the Share button is on the daily win card since D188), `museum`, `shop`, `settings`, `chapters` (the chapter accordion and the level card, M7 E7; `cubit/chapter_star_tally.dart` is the one place Home and Chapters total the stars), `records` (Records and badges, M7 E8), `race` (vs Computer: rival select, `RaceCubit`; the race plays on the gameplay page, M7 phase 2), `fx` (Lottie library, `fx_spec.gen.dart`; `fx_ribbon.dart` is the win and chapter ribbons' width (`FxRibbon`, named rects); `fx/chest/` is the chest opening both chests share), `dev` (level picker).
- Levels: `tools/levels/` → `nesty_levels bundle build` → `assets/levels/bundle.json` → `core/repository/bundled_level_repository.dart` (decodes and checks rules 1–7 on a worker isolate); `LevelResolver` maps a play request to a level (bundled, a replay, Bonus Endless, the daily or a race).
- UI kit: `core/ui/` (theme, `tokens/ui_tokens.gen.dart`, `icons/nesty_icons.gen.dart` with `icons/icon_uses.dart` naming each use's glyph, shared widgets; `widgets/stars/star_row.dart` is every star surface's one swap point; `widgets/feedback/toast_queue.dart` is the toast queue, one host at the app root). `core/ui/art/` is the m7-3 UI art: `UiArt` (the stars, the chest, the sprites, the rivals, the badges), `UiArtLibrary` (rasters once per size, real and fake), `UiArtImage` and `UiArtImageSource` for the Lottie slots, and `theme_thumbnail_loader.dart` (the themes' crops for the Shop and Chapters: an LRU, a scope and a shared asset loader, no DI binding). `widgets/home/` holds `StarsChip`, `TextLink` (48 dp) and `StreakLook`; `widgets/race/` the `ComputerTag`, `RivalPortrait` and `RivalReact` (`ui_rival_react`) every rival surface uses; `widgets/sheet/sheet_row.dart` the sheets' rows and `SheetRowChip` (moves under the line, never shrinks); `widgets/layout/cream_page.dart` the `CreamPage` gradient every menu page paints; `widgets/text/balanced_text.dart` the `BalancedText` (`text-wrap: balance`) and `bindLastWord` that modal heads and `ErrorCard` bodies use; `widgets/text/fit_text.dart` the `FitText` (textFit's order: wrap, scale, short form) and `shrink_to_fit_text.dart` the wrapping scaler; `theme/locale_script.dart` the `LocaleScriptScope`, the script's size factor and line heights (Devanagari, Japanese) and Turkish's display face (`Baloo2LatnTr`, `LocaleScript.display`); `tokens/ui_token_types.dart` the `DisplayFace` hook the generated Fredoka styles read (getters, so a locale swaps the face); `widgets/coins/reward_ring.dart` the chest flights' `RewardRing`.

**Services** (`apps/game/lib/core/services/<name>/`, interface + real + fake; which env gets which is on each class's `@LazySingleton(as: …, env: …)`):

| Interface | Real implementation today | Real one lands |
|---|---|---|
| `LevelRepository`, `CatalogRepository` (`core/repository/`) | bundled JSON assets | M4 adds Firestore sync |
| `SaveService` | `HiveSaveService` (`SaveDocument` at schema 3, `save_migrations.dart`) | done |
| `DatabaseService` | `HiveDatabaseService` (settings + save boxes; in-memory fallback) | done |
| `DailyService` | `StreakDailyService` (both envs) | done |
| `SolverService`, `LevelGeneratorService` | isolate implementations | done |
| `SkinService` | `AssetSkinService` (bundled skins; chapters 7–10's own board wood by `themeId`) | done; M4 adds Storage downloads |
| `FxLibrary` (`features/fx/`) | `AssetFxLibrary` (bundled Lottie) | done |
| `AudioService` (SFX + jingles), `MusicService` | SoLoud | done |
| `HapticsService`, `AppClock`, `AppInfoService`, `LinkLauncher` | system / package_info / url_launcher | done |
| `FrameTicker` (`services/ticker/`, the race clock) | `SchedulerFrameTicker` (a factory, both envs) | done |
| `NotificationService` (`services/notifications/`, the daily reminder; its Android icon `res/drawable/ic_notification.xml` is generated by `sync_design_assets` from `design/ui/notification/`) | `LocalNotificationService` (flutter_local_notifications + timezone + flutter_timezone) | done |
| `ShareService` (`services/share/`, the daily share card) | `SharePlusShareService` (share_plus) | done |
| `SystemSettingsService` (`services/system_settings/`, "Open phone settings") | `ChannelSystemSettingsService` (a platform channel the app's Android and iOS code answers) | done (`MainActivity.kt` and `AppDelegate.swift` answer it, M7 phase 4 lane D) |
| `UiArtLibrary` (`core/ui/art/`, the UI art's rasters) | `AssetUiArtLibrary` (bundled `assets/ui/**`) | done |
| `RemoteConfigService` | `DefaultsRemoteConfigService` (hard-coded defaults, `remote_config_keys.dart`: int, bool and string keys) | M4 |
| `AnalyticsService` | fake in both envs | M4 |
| `AdsService`, `PurchaseService` | fake in both envs | M6 |

`services/chest/` (`MilestoneChest`) and `services/records/` (`RecordRules`, `BadgeRules`) are pure M7 meta rules with no interface; the bloc and `SaveService.recordLevelWin` call them. `services/login_gift/` (`LoginGiftRules`: the daily gift's track from `login_gift_track`, the claim and the clock guard) is the same kind, paid by `SaveService.claimLoginGift`. `services/race/` (`RaceRules`: unlock, stage, pace, reward) is vs Computer's, called by the resolver, `RaceCubit` and rival select. `services/records/star_rules.dart` (`StarRules`: the slack, the stars key, the backfill) is the star rating's app glue. `services/reminder/` (`DailyReminder`) composes `NotificationService`, `DatabaseService` and `DailyService` with no interface of its own, and `bootstrap` starts it.

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
cd apps/game && flutter test test/overflow --dart-define=NESTY_TEST_LOCALE=<code>   # the overflow suite in one locale (de es fr hi id ja pt pt_BR tr; nesty-test and CI loop all nine)
flutter analyze                                         # at repo root; zero issues (CI adds --fatal-infos --fatal-warnings)
cd apps/game && flutter run --flavor dev -t lib/main_dev.dart                                    # game: dev|stg|prod
cd apps/admin && flutter run -d chrome -t lib/main_dev.dart --dart-define=NESTY_FAKE_SERVICES=true  # admin
cd firebase && firebase emulators:start                 # local Auth/Firestore/Storage (needs firebase-tools)
cd tools && dart test                                   # nesty_tools: codegen, asset sync, levels, TODO index, CLAUDE.md and test-coverage drift
dart run nesty_tools:gen_design_tokens                  # design/tokens.json → render_tokens.gen.dart + ui_tokens.gen.dart
dart run nesty_tools:sync_design_assets                 # design/ art, UI art, audio, Lottie → apps/game/assets, + the Android notification icon (validated)
dart run nesty_tools:gen_fx_spec                        # design/lottie + the Lottie contract → features/fx/fx_spec.gen.dart
dart run nesty_tools:gen_nesty_icons                    # NestyIcons from the bundled icon-font subset
dart run nesty_tools:gen_font_subsets                   # tools/fonts/subset/{hi,ja}.txt (the script fonts' characters) from the ARBs, intl and Flutter's material ARBs; then build_fonts.sh
dart run nesty_tools:todo_index                         # regenerate docs/TODO_INDEX.md from TODO(<tag>) markers
dart run nesty_tools:nesty_levels bundle build|check    # tools/levels → assets/levels/bundle.json; check = CI gate
dart run nesty_tools:nesty_levels validate|solve|simulate|report|generate|fixtures check   # --help for flags
tools/fonts/build_fonts.sh [--verify]                   # rebuild the bundled fonts from pinned upstream (network)
tools/scripts/nesty-test [--android] [--device <name|udid>] [--android-size WxH@dpi] [--device-only] [--only <check>]   # CI's host checks + on-device checks (--only board,race,meta,daily_states,overlays: phase 4's files; gift: the daily gift's; faults,semantics,locales: phase 5's; --android --only reminder: the optional reminder check; NESTY_TEST_IOS_DEVICE / NESTY_TEST_ANDROID_DEVICE default --device); --help
tools/scripts/watch-run --log <file> [--pid <pid>|--match <pattern>] [--done <regex>] [--stall <s>]   # watch a long run: one line per event, ends on done, died, stalled or overtime (D295); --help
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
- **l10n:** each app's `lib/l10n/app_en.arb` is the source of truth. The game has nine catalogs (en, es, pt, pt_BR as a regional overlay of pt, id, hi, de, fr, tr, ja; every key translated, `test/l10n/` checks them); the admin is English only. The `locale` setting is `system` (follow the phone) or a pinned code, resolved by `app/localization_cubit/app_locale_resolver.dart` (`AppLocaleResolver`, also used by the reminder); the language sheet is `features/settings/widgets/language_sheet.dart`. Read strings with `context.localizations.someKey`. Every key has a description.
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
- **Working within Claude's usage limits** (owner, D238). Quality comes first: a cheaper model or a smaller chunk never skips a test, a gate, a review or a design check.
  - Pick the model per task: Sonnet for well-specified lanes, screenshot judging, test runs and docs; Haiku for mechanical sweeps; the session's model (Opus) for planning, cross-cutting design, hard debugging, judging conflicts between lanes, and reviewing translations and player-facing copy (on 2026-10-04 Sonnet reviewers missed about 100 translation errors that an Opus pass caught, D240).
  - Split large work into chunks (one feature area, or about 30 screenshots), and run independent chunks as parallel agents that own disjoint files; a last serial stage integrates and runs the gate.
  - Save as you go: every stage keeps its checkpoint file and appends its findings to its report after each batch, so a session or weekly limit loses nothing. Never leave results only in an agent's context or final message.
  - Keep contexts small: read files by range, view each screenshot once, run long device and build steps as background scripts instead of agents that poll, and start a fresh agent from the saved files instead of resuming a huge one.
  - Keep big output out of context: tests run with `-r failures-only` (or `| tail -n 40`), and verbose searches and logs go to a subagent (`code-explorer`, `test-runner`) that returns a summary. Don't delegate a small edit: each agent pays for its own fresh context (D240).
  - Set effort per task: low for mechanical stages (format, copy, merge, reruns), the default for most work, high only for the hardest judging or debugging. Use the agent call's effort or the agent's `effort:` frontmatter (D240).
  - Keep the prompt cache warm (D240):
    - pick the model and effort at the start of a session or stage;
    - mid-task, don't switch models, toggle fast mode or add or remove MCP servers, because each one invalidates the cache;
    - compact only at a task break, using "Compact instructions" below;
    - between unrelated tasks, `/clear`;
    - after two failed corrections, rewind or clear and restate the task with what was learned.
- **Be proactive** (owner, D239). Don't wait to be told what the work already implies; do it within the owner's standing instructions and these rules.
  - Start whatever can run now: work that doesn't depend on what is in progress, in parallel where files don't conflict (a separate folder when a device run is using the tree), and prepare the next stage's prompts and scripts while the current one runs.
  - Fix what you find on the way (a bug, a stale doc, a missing test or TEST_COVERAGE row, a broken shot), each with its test, and record it; don't leave it for the owner to notice.
  - Ship the default and record a question (`Q<n>`, BACKLOG "Owner inputs needed") instead of blocking on an owner decision that has a sensible default.
  - Still stop and ask for: an ambiguous game rule, anything outward-facing or hard to reverse (commits, pushes, deleting outside the repo and the scratchpad), and whatever these rules leave to the owner (`GAME_SPEC.md`, `design/`, the rules in this file).
- **Watch every long run** (owner, D295). Silence is not success.
  - Anything that runs longer than about two minutes (a test suite, `nesty-test`, a device run, a build, a font build) runs detached (`nohup … &`, its exit code written to a summary file) with its log under `build/`. Never rely on a background shell: its default timeout kills the foreground child after two minutes and leaves orphans.
  - From the moment it starts, `tools/scripts/watch-run` watches it under the Monitor tool, re-armed at each expiry, never a bare wait loop. Set `--stall` to the run's longest quiet step (300 s for host suites, 900 s for device runs).
  - On WATCH STALLED, DIED, OVERTIME or a FAIL line, act at once: spawn the `run-watcher` agent (or fix it directly when it is small) to find the cause, fix it with its test, and rerun only that piece under a fresh watch. Stop only this repo's orphans.
  - The run's checkpoint records each alert and its fix.
- **Local first, backend last** (owner, D269; D237's order). The game works 100% locally before any backend: nothing that needs a server, an account, Firebase, ads, analytics delivery or a store purchase starts before M4, and such items live in BACKLOG's M4–M8 sections. Anything the admin will control later (levels, chapters, skins and prices, rewards and tracks, race parameters, changeable copy) is read today through a repository or a `RemoteConfigService` key with a bundled default, never hard-coded in a widget or cubit, so M4 and M5 swap the source without touching features.
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

## Compact instructions

When compacting (`/compact` or auto-compact), keep (D240):
- the current milestone, phase and stage, the working folder (`build/m7-p5/` for M7 phase 5) and every checkpoint and report path in use;
- the background agents and scripts still running, what each writes, and what runs next;
- the owner's standing constraints and latest instructions, verbatim: no commits until asked, the protected simulator UDID, the 20 GB disk floor, and anything they said this session;
- the next free `D<n>` and `Q<n>`, the open owner questions, and any decision made but not yet logged.

Drop file dumps, test logs and screenshot descriptions; those live in the reports.

## Git

- Conventional commits: `feat(game): ...`, `fix(core): ...`, `docs: ...`, `chore(ci): ...`.
- No `Co-Authored-By` trailer or any other Claude attribution in commits or PRs.
- Never force-push.
