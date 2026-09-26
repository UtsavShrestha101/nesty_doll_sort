# TODO index

<!-- GENERATED — do not edit; run dart run nesty_tools:todo_index -->

Every tagged `TODO(<tag>)` / `FIXME(<tag>)` marker in first-party code and docs, grouped by milestone (spec §18), so no future-milestone work is lost. When you start a milestone, work through its section; when you finish one, its section must be empty or every entry moved to a later tag on purpose.

- **Tags:** `M1`…`M8`, `v1.1`, `design`, `later`; combinations like `M3/M4` are listed under each milestone they name.
- **Rules:** `dart run nesty_tools:todo_index --check` (CI) fails when this file is stale, when a tag is unknown, or when a code comment has a `TODO`/`FIXME` without a tag. Markers inside `backticks` or fenced code blocks are references, not work items, and are not indexed.
- **Not scanned:** `design/`, `.claude/`, build output and generated files (`*.g.dart`, `*.freezed.dart`, `*.gr.dart`, `*.config.dart`, `*.gen.dart`, gen-l10n output).

| Tag | Scope | Open |
|---|---|---:|
| M1 | Core (`nesty_core`) | 3 |
| M2 | Playable game | 29 |
| M3 | App shell and meta | 10 |
| M4 | Firebase content | 11 |
| M5 | Admin panel | 16 |
| M6 | Monetization | 6 |
| M7 | Art and polish | 0 |
| M8 | Release prep | 1 |
| v1.1 | After v1 (e.g. the golden doll, spec §3.5) | 0 |
| design | Waiting on a design export or decision from the owner | 8 |
| later | Unscheduled (spec §19 "Later ideas") | 0 |

Total: 81 markers.

## M1 — Core (`nesty_core`)

- `packages/nesty_core/lib/nesty_core.dart:10` — export models, codec, validator, rules, game_session, solver, simulator, generator and prng as they land. Spec §13.1, §18.
- `packages/nesty_core/lib/src/models/doll_color.dart:35` — colorsMatch(T, M) in rules uses this flag. Spec §3.5, §4.
- `packages/nesty_core/test/fixtures/README.md:39` — decide how a solvable fixture records its expected optimal move count (spec §5.2 metrics.solverMoves), e.g. a map in the test that loads it, without changing the level JSON.

## M2 — Playable game

- `apps/game/lib/core/extensions/app_exception_extension.dart:9` — split `storage` and `content` (bundled levels failed to load) into their own keys once those screens exist.
- `apps/game/lib/core/extensions/context_extension.dart:12` — map to the design type scale in `AppTextStyleTokens` (display, h1, h2, button, body, caption, number).
- `apps/game/lib/core/repository/fake_level_repository.dart:9` — drop `AppEnv.real` from `env` once the bundled repository exists.
- `apps/game/lib/core/repository/level_repository.dart:4` — real bundled implementation reading `assets/levels/bundle.json`, decoding and validating each level with nesty_core's `LevelCodec`/`Validator` (invalid ones skipped with a log entry, spec §5.3) and a lookup by play order …
- `apps/game/lib/core/services/audio/audio_service.dart:23` — a real flutter_soloud implementation (spec §11.3, PROGRESS D19) with per-size clack pitch and the combo chime steps.
- `apps/game/lib/core/services/audio/fake_audio_service.dart:7` — drop `AppEnv.real` from `env` once the real audio service exists.
- `apps/game/lib/core/ui/colors/app_colors.dart:6` — every value below is a placeholder. Replace them with the generated `AppColorTokens` (design/tokens.json `color.*`).
- `apps/game/lib/core/ui/theme/app_theme.dart:7` — chunky rounded buttons with a pressed bottom edge, radii, shadows and spacing from the generated tokens (`ui_tokens.gen.dart`).
- `apps/game/lib/core/ui/theme/app_theme.dart:9` — fonts — Fredoka (display/headings) and Nunito (body), already bundled in assets/fonts (`AppFontTokens`); never google_fonts, which downloads at runtime and would break the offline first launch (rule 3).
- `apps/game/lib/core/ui/widgets/retry_view.dart:9` — replace with the design's modal card style (design/README.md "Components").
- `apps/game/lib/features/gameplay/game/components/board_component.dart:8` — render from nesty_core's `GameSession` via nesty_render's `BoardLayout` (spec §10.3) with `SlotComponent` / `NestComponent` children, play §11.1 animations from `MoveEvent`s in order (spec §4), and forward tap-tap / drag …
- `apps/game/lib/features/gameplay/game/nesty_game.dart:9` — receive the level's `GameSession` state from the gameplay controller and pass it down to [BoardComponent]; add the `FxLayer`.
- `apps/game/lib/features/gameplay/pages/gameplay_page.dart:11` — a gameplay controller (cubit or `BaseAsyncBloc`) that owns the nesty_core `GameSession` for [levelNumber]; the Flame game only renders it. Win / Out of Moves / soft-stuck overlays (spec §2.3, §10.2).
- `apps/game/lib/features/gameplay/pages/gameplay_page.dart:38` — open the pause menu (spec §10.2 #14, frame 3.9).
- `apps/game/lib/features/gameplay/widgets/booster_bar.dart:6` — wire to the gameplay controller (undo, solver hint, extra slot, restart).
- `apps/game/lib/features/gameplay/widgets/booster_bar.dart:7` — booster buttons and count badges from the design (design/README.md "Components").
- `apps/game/lib/features/gameplay/widgets/gameplay_top_bar.dart:5` — the design HUD (frame 2.2): level pill with its tier, coin pill and family counter.
- `apps/game/lib/features/gameplay/widgets/gameplay_top_bar.dart:36` — replace with the coin pill.
- `apps/game/lib/features/home/cubit/home_cubit.dart:12` — coins, the tier badge of the current level, and refresh when returning from a won level.
- `apps/game/lib/features/home/pages/home_page.dart:11` — the Home hero of frame 2.1: chapter background, coin pill, wordmark, settings gear, idle dolls and PLAY with Level N and its tier.
- `apps/game/lib/features/splash/cubit/splash_cubit.dart:14` — also load and rasterize the bundled Classic skin (spec §13.5).
- `apps/game/lib/features/splash/pages/splash_page.dart:11` — wordmark and striped loading bar (frame 1.1).
- `apps/game/test/app_flow_test.dart:58` — pause menu, frame 3.9.
- `apps/game/test/core/dependency_injection/di_test.dart:76` (also M3, M4, M6) — flip these as real implementations land (M2: the bundled LevelRepository and the in-memory SaveService).
- `packages/nesty_render/lib/nesty_render.dart:11` — export PlaceholderDollPainter (spec §12.5), BoardLayout (spec §10.3), SvgSkinRenderer and SkinCache (spec §12.2; pulled in, D23).
- `packages/nesty_render/lib/src/doll_palette.dart:6` — add `ink` and `light` shades to DollSwatch, and take base/ink/light from the generated `DollColorTokens` (design/tokens.json `dollColor.<id>`).
- `packages/nesty_render/lib/src/doll_palette.dart:64` — the gold gradient map from `DollColorTokens.gold` (ramp, gray^2 input; spec §12.3, §3.5, PROGRESS D22: rendering now, rules in v1.1).
- `packages/nesty_render/lib/src/doll_renderer.dart:5` — PlaceholderDollPainter implements DollRenderer: the procedural doll of spec §12.5, and the fallback whenever a skin fails to load.
- `packages/nesty_render/lib/src/doll_renderer.dart:7` — SvgSkinRenderer + SkinCache implement DollRenderer: skin layers rasterized once per needed size into cached ui.Images and tinted with BlendMode.modulate (spec §12.2, §13.5).

## M3 — App shell and meta

- `apps/game/lib/core/router/app_router.dart:22` — Win, Pause, Settings, Daily, Museum, Shop (spec §10.2).
- `apps/game/lib/core/services/audio/audio_service.dart:25` — separate SFX/music volumes and the two music loops.
- `apps/game/lib/core/services/database/database_service.dart:10` — the save document (currentLevel, coins, inventory, inProgress…, spec §13.3) is NOT here yet. M3 decides whether it lives in a Hive box or in the spec's atomic JSON file; see docs/PROGRESS.md open questions.
- `apps/game/lib/core/services/haptics/system_haptics_service.dart:20` — tune by feel on devices; a true multi-pulse "success pattern" for `complete` may need the `vibration` package (spec §13.2).
- `apps/game/lib/core/services/save/fake_save_service.dart:8` — drop `AppEnv.real` from `env` once the persistent save exists.
- `apps/game/lib/core/services/save/save_service.dart:4` — the full document (coins, inventory, adsRemoved, skins, themes, museum, daily, inProgress + undo, adCounters, stats), schema version + migrations, save-on-every-move and on app pause, and restore-on-resume when …
- `apps/game/lib/features/gameplay/widgets/booster_bar.dart:8` — the booster purchase popup.
- `apps/game/lib/features/home/cubit/home_cubit.dart:13` — Daily/Museum/Remove Ads tiles.
- `apps/game/lib/features/home/pages/home_page.dart:13` — the Daily/Museum/Remove Ads tiles and the bottom nav.
- `apps/game/test/core/dependency_injection/di_test.dart:76` (also M2, M4, M6) — flip these as real implementations land (M2: the bundled LevelRepository and the in-memory SaveService).

## M4 — Firebase content

- `apps/game/lib/bootstrap.dart:31` — Firebase + Crashlytics go here, before DI: await Firebase.initializeApp( options: DefaultFirebaseOptions.currentPlatform, ); importing `firebase_options_<flavor>.dart` chosen by the flavor entry point. Those files are …
- `apps/game/lib/bootstrap.dart:51` — FirebaseCrashlytics.instance.recordError(error, stackTrace).
- `apps/game/lib/core/base/run_guarded.dart:29` — also report as a Crashlytics non-fatal (spec §14.4).
- `apps/game/lib/core/repository/level_repository.dart:8` — `levels_cache.json` + background Firestore sync on launch and resume (never blocking, never swapping the level in progress).
- `apps/game/lib/core/services/analytics/analytics_service.dart:4` — add `FirebaseAnalyticsService` (firebase_analytics) for the real env, plus typed helpers for the §14.4 events (`level_start`, `level_win`, ...) so event names never get mistyped at call sites.
- `apps/game/lib/core/services/analytics/fake_analytics_service.dart:13` — drop `AppEnv.real` from `env` once `FirebaseAnalyticsService` exists, then record events in memory (`events` list plus `clear()`) so tests can read them; that is only safe once release builds stop using this class.
- `apps/game/lib/core/services/database/hive_database_service.dart:51` — report as a Crashlytics non-fatal.
- `apps/game/lib/core/services/remote_config/defaults_remote_config_service.dart:9` — replace in the real env with `FirebaseRemoteConfigService`.
- `apps/game/lib/core/services/remote_config/remote_config_service.dart:6` — add `FirebaseRemoteConfigService` (firebase_remote_config) for the real env; it sets `RemoteConfigKeys.defaults` as in-app defaults and falls back to them on any fetch error.
- `apps/game/lib/features/splash/cubit/splash_cubit.dart:15` — kick off level sync and Remote Config refresh in the background here — unawaited, so the splash never waits on the network (rule 3).
- `apps/game/test/core/dependency_injection/di_test.dart:76` (also M2, M3, M6) — flip these as real implementations land (M2: the bundled LevelRepository and the in-memory SaveService).

## M5 — Admin panel

- `apps/admin/lib/bootstrap.dart:27` — Firebase goes here, before DI: await Firebase.initializeApp( options: DefaultFirebaseOptions.currentPlatform, ); importing `firebase_options_<flavor>.dart` chosen by the flavor entry point. Those files are produced by …
- `apps/admin/lib/core/router/auth_guard.dart:21` — resume the originally requested deep link after sign-in, if the owner wants it; Firebase keeps web sessions, so this only affects the first sign-in on a browser.
- `apps/admin/lib/core/services/auth/auth_service.dart:9` — `FirebaseAuthService` (real env): Firebase Auth sign-in, then a read of `admins/{uid}` to set [AdminUser.isAdmin]. It must restore the persisted web session BEFORE `runApp` (await the first `authStateChanges()` event in …
- `apps/admin/lib/core/services/auth/unconfigured_auth_service.dart:13` — delete this class when `FirebaseAuthService` registers for [AppEnv.real] (spec §15 Auth).
- `apps/admin/lib/features/chapters/pages/chapters_page.dart:6` — CRUD on `chapters/{chapterId}` (spec §14.1), with theme and museum item assignment.
- `apps/admin/lib/features/daily_overrides/pages/daily_overrides_page.dart:6` — calendar view to pick or generate a level for a date; writes `dailyOverrides/{yyyymmdd}` (spec §14.1).
- `apps/admin/lib/features/dashboard/pages/dashboard_page.dart:6` — counts by status, `config/manifest` version, last publish, and the "levels remaining ahead of players" estimate.
- `apps/admin/lib/features/export_bundle/pages/export_bundle_page.dart:6` — download `bundle.json` of the first N published levels, encoded with nesty_core's `LevelCodec`, for `apps/game/assets/levels/` (spec §13.4).
- `apps/admin/lib/features/generator/pages/generator_page.dart:6` — form with the §6.5 params plus count and seed; the batch runs nesty_core's deterministic `Generator` off the UI thread and shows preview cards with metrics; Accept adds them to drafts in the chosen chapter, Reject …
- `apps/admin/lib/features/levels/pages/level_editor_page.dart:7` — shelf/slot builder, doll palette, live validation (§5.3), Solve, Simulate, Playtest, Save Draft (bumps `version`) and Publish. Every rule, validation, solve and simulation comes from nesty_core (CLAUDE.md rule 2), and …
- `apps/admin/lib/features/levels/pages/levels_page.dart:6` — table of order, id, chapter, tier, casual/smart win rates, solver moves and status; filters and search; drag-to-reorder within drafts/published; bulk publish/unpublish/archive as one batched write that bumps …
- `apps/admin/lib/features/museum_items/pages/museum_items_page.dart:6` — upload with preview; writes `museumItems/{itemId}` and `museum/{itemId}.png` (spec §14.1-2).
- `apps/admin/lib/features/skins/pages/skins_page.dart:6` — upload an SVG (or PNG layer set) with its sidecar JSON; check group ids, artboard size and disallowed features (spec §12.2); live preview of all colors × sizes including the lid-lift, drawn through nesty_render; set …
- `apps/admin/lib/features/themes/pages/themes_page.dart:6` — upload a board theme (spec §12.4) with preview; writes `themes/{themeId}` and `themes/{themeId}/v{version}/...` (spec §14.1-2).
- `apps/admin/test/core/dependency_injection/di_test.dart:44` — FirebaseAuthService.
- `firebase/storage.rules:8` — consider constraining admin uploads by size and content type (image/svg+xml, image/png, image/webp) once the admin upload flow (spec §15 screens 6–7) exists — the spec does not define limits yet.

## M6 — Monetization

- `apps/game/lib/core/services/ads/ads_service.dart:20` — add `AdMobAdsService` (google_mobile_ads) for the real env: UMP consent before init (§9.3), Google test unit IDs in debug and `--dart-define` IDs in release (CLAUDE.md rule 5), preload one rewarded + one interstitial, …
- `apps/game/lib/core/services/ads/fake_ads_service.dart:10` — drop `AppEnv.real` from `env` once `AdMobAdsService` exists.
- `apps/game/lib/core/services/purchase/fake_purchase_service.dart:9` — drop `AppEnv.real` from `env` once `StorePurchaseService` exists.
- `apps/game/lib/core/services/purchase/purchase_service.dart:19` — add `StorePurchaseService` (in_app_purchase) for the real env: product queries, client-side receipt checks (v1), restore purchases, and crediting coins/adsRemoved through the M3 save.
- `apps/game/lib/features/splash/cubit/splash_cubit.dart:17` — first-launch consent (UMP) sits between splash and Home (§10.1).
- `apps/game/test/core/dependency_injection/di_test.dart:76` (also M2, M3, M4) — flip these as real implementations land (M2: the bundled LevelRepository and the in-memory SaveService).

## M7 — Art and polish

_None._

## M8 — Release prep

- `apps/game/android/app/build.gradle.kts:66` — Sign release builds with the upload key. Load it from an untracked android/key.properties (storeFile, storePassword, keyAlias, keyPassword) and never commit the keystore or passwords. .gitignore already excludes …

## v1.1 — After v1 (e.g. the golden doll, spec §3.5)

_None._

## design — Waiting on a design export or decision from the owner

- `apps/admin/lib/core/extensions/context_extension.dart:12` — map to the admin type scale from design/admin/*.png + design/tokens.json once they exist.
- `apps/admin/lib/core/ui/colors/app_colors.dart:6` — every value below is a placeholder. Replace them with `design/tokens.json` → `color.*` and `design/admin/*.png` once exported.
- `apps/admin/lib/core/ui/theme/app_theme.dart:6` — radii, spacing, table and form styles from `design/tokens.json` and `design/admin/*.png` (DESIGN_BRIEF Prompt 14).
- `apps/admin/lib/core/ui/theme/app_theme.dart:8` — bundle the brand fonts as assets rather than using google_fonts, which downloads at runtime.
- `apps/admin/lib/core/ui/widgets/placeholder_view.dart:7` — replace each use with the real screen (design/admin/*.png).
- `apps/admin/lib/features/login/pages/login_page.dart:11` — design/admin/*.png has no login screen yet (DESIGN_BRIEF Prompt 14 lists Levels, Level Editor and Skin upload only).
- `apps/admin/lib/features/not_authorized/pages/not_authorized_page.dart:10` — no admin design export covers this screen yet.
- `apps/admin/lib/features/shell/pages/admin_shell_page.dart:17` — narrow-window layout and rail styling (design/admin/*.png).

## later — Unscheduled (spec §19 "Later ideas")

_None._
