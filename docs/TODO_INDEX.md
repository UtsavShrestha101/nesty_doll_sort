# TODO index

<!-- GENERATED — do not edit; run dart run nesty_tools:todo_index -->

Every tagged `TODO(<tag>)` / `FIXME(<tag>)` marker in first-party code and docs, grouped by milestone (spec §18), so no future-milestone work is lost. When you start a milestone, work through its section; when you finish one, its section must be empty or every entry moved to a later tag on purpose.

- **Tags:** `M1`…`M8`, `v1.1`, `design`, `later`; combinations like `M3/M4` are listed under each milestone they name.
- **Rules:** `dart run nesty_tools:todo_index --check` (CI) fails when this file is stale, when a tag is unknown, or when a code comment has a `TODO`/`FIXME` without a tag. Markers inside `backticks` or fenced code blocks are references, not work items, and are not indexed.
- **Not scanned:** `design/`, `.claude/`, build output and generated files (`*.g.dart`, `*.freezed.dart`, `*.gr.dart`, `*.config.dart`, `*.gen.dart`, gen-l10n output).

| Tag | Scope | Open |
|---|---|---:|
| M1 | Core (`nesty_core`) | 0 |
| M2 | Playable game | 0 |
| M3 | App shell and meta | 0 |
| M4 | Firebase content | 14 |
| M5 | Admin panel | 17 |
| M6 | Monetization | 17 |
| M7 | Art and polish | 0 |
| M8 | Release prep | 4 |
| v1.1 | After v1 (e.g. the golden doll, spec §3.5) | 5 |
| design | Waiting on a design export or decision from the owner | 20 |
| later | Unscheduled (spec §19 "Later ideas") | 0 |

Total: 77 markers.

## M1 — Core (`nesty_core`)

_None._

## M2 — Playable game

_None._

## M3 — App shell and meta

_None._

## M4 — Firebase content

- `apps/game/lib/bootstrap.dart:38` — Firebase + Crashlytics go here, before DI: await Firebase.initializeApp( options: DefaultFirebaseOptions.currentPlatform, ); importing `firebase_options_<flavor>.dart` chosen by the flavor entry point. Those files are …
- `apps/game/lib/bootstrap.dart:71` — FirebaseCrashlytics.instance.recordError(error, stackTrace).
- `apps/game/lib/core/base/run_guarded.dart:29` — also report as a Crashlytics non-fatal (spec §14.4).
- `apps/game/lib/core/repository/bundled_catalog_repository.dart:12` — overlay Firestore's `chapters`, `skins`, `themes` and `museumItems` (cached, offline-first; spec §13.5, §14.1).
- `apps/game/lib/core/repository/default_level_resolver.dart:132` — this only sees the bundle it was resolved from, so a chapter the player already passed with fewer levels than `ChapterInfo.levels` never retroactively completes when sync adds the rest. Award that figurine and …
- `apps/game/lib/core/repository/level_repository.dart:9` — `levels_cache.json` + background Firestore sync on launch and resume (never blocking, never swapping the level in progress).
- `apps/game/lib/core/services/analytics/analytics_service.dart:4` — add `FirebaseAnalyticsService` (firebase_analytics) for the real env, plus typed helpers for the §14.4 events (`level_start`, `level_win`, ...) so event names never get mistyped at call sites.
- `apps/game/lib/core/services/analytics/fake_analytics_service.dart:13` — drop `AppEnv.real` from `env` once `FirebaseAnalyticsService` exists, then record events in memory (`events` list plus `clear()`) so tests can read them; that is only safe once release builds stop using this class.
- `apps/game/lib/core/services/database/hive_database_service.dart:55` — report as a Crashlytics non-fatal.
- `apps/game/lib/core/services/remote_config/defaults_remote_config_service.dart:9` — replace in the real env with `FirebaseRemoteConfigService`.
- `apps/game/lib/core/services/remote_config/remote_config_service.dart:6` — add `FirebaseRemoteConfigService` (firebase_remote_config) for the real env; it sets `RemoteConfigKeys.defaults` as in-app defaults and falls back to them on any fetch error. Keys are `int`, `bool` and, since the daily …
- `apps/game/lib/features/shop/widgets/skin_grid_card.dart:62` — a skin mid-download shows this instead of Equip/Buy; no bundled skin ever sets it (frame 7.5).
- `apps/game/lib/features/splash/cubit/splash_cubit.dart:41` — kick off level sync and Remote Config refresh in the background here — unawaited, so the splash never waits on the network (rule 3).
- `docs/BACKLOG.md:914` — names `getString`

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
- `apps/game/lib/core/services/skin/unlock_symbol_rasterizer.dart:19` — switch to nesty_render's ink-tinted `SymbolRaster` (docs/plans/m2-lottie-design.md §16) before the first locked levels (L31+) ship in M5's level bundle; no M2 level has a lock (moved from M2).
- `firebase/storage.rules:8` — consider constraining admin uploads by size and content type (image/svg+xml, image/png, image/webp) once the admin upload flow (spec §15 screens 6–7) exists — the spec does not define limits yet.

## M6 — Monetization

- `apps/game/lib/core/services/ads/ads_service.dart:20` — add `AdMobAdsService` (google_mobile_ads) for the real env: UMP consent before init (§9.3), Google test unit IDs in debug and `--dart-define` IDs in release (CLAUDE.md rule 5), preload one rewarded + one interstitial, …
- `apps/game/lib/core/services/ads/fake_ads_service.dart:10` — drop `AppEnv.real` from `env` once `AdMobAdsService` exists.
- `apps/game/lib/core/services/music/jingle_cues.dart:28` — call when an in-app purchase completes.
- `apps/game/lib/core/services/music/music_service.dart:75` — AdsService calls this before every show, and resumeAfterAd in a `finally` when the ad closes (BACKLOG M6 "Ads").
- `apps/game/lib/core/services/purchase/fake_purchase_service.dart:9` — drop `AppEnv.real` from `env` once `StorePurchaseService` exists.
- `apps/game/lib/core/services/purchase/purchase_service.dart:19` — add `StorePurchaseService` (in_app_purchase) for the real env: product queries, client-side receipt checks (v1), restore purchases, and crediting coins/adsRemoved through the M3 save.
- `apps/game/lib/features/daily/widgets/daily_chest_modal.dart:30` — "Double it" (a rewarded ad) sits above Collect.
- `apps/game/lib/features/gameplay/overlays/booster_buy_popup.dart:26` — with a real `AdsService`, an ad ready keeps this path and an offline one shows frame 3.8's disabled button with "Connect to watch an ad" (`BuyPopupBody.offline`).
- `apps/game/lib/features/gameplay/overlays/out_of_moves_sheet.dart:22` — the ▶ ad option beside the price chips and its offline variant (frames 3.7, 12.8).
- `apps/game/lib/features/gameplay/overlays/win_overlay.dart:179` — the ×3 rewarded-video button and its "Reward added" state (frames 2.8, 2.9); hidden until ads exist, as the design does offline, where Continue takes its slot (C12).
- `apps/game/lib/features/gameplay/widgets/booster_bar.dart:68` — the ▶ badge at 0 while an ad is ready (frame 2.2).
- `apps/game/lib/features/settings/pages/settings_page.dart:259` — Restore Purchases (spec §9.2).
- `apps/game/lib/features/settings/pages/settings_page.dart:266` — Privacy choices (the consent form's "Manage options", spec §9.3).
- `apps/game/lib/features/shop/widgets/shop_closed_card.dart:9` — replace with the real coin packs (7.1, 7.2) and Remove Ads / No-Ads Bundle (7.8) once purchases ship.
- `apps/game/lib/features/splash/cubit/splash_cubit.dart:43` — first-launch consent (UMP) sits between splash and Home (§10.1).
- `apps/game/test/core/dependency_injection/di_test.dart:244` — flip as AdMob lands.
- `apps/game/test/features/daily/daily_chest_modal_test.dart:52` — the ad.

## M7 — Art and polish

_None._

## M8 — Release prep

- `apps/game/android/app/build.gradle.kts:69` — Sign release builds with the upload key. Load it from an untracked android/key.properties (storeFile, storePassword, keyAlias, keyPassword) and never commit the keystore or passwords. .gitignore already excludes …
- `apps/game/lib/core/services/links/app_links.dart:6` — the owner's privacy policy URL and support email (Q73).
- `apps/game/lib/core/ui/theme/app_text_styles.dart:11` — tabular figures for coins and counters (PROGRESS Q29; moved from M2, the approach waits on the owner). Fredoka has no `tnum`, so [number]'s `FontFeature.tabularFigures()` does nothing yet; `NestyNumberText` is the one …
- `apps/game/lib/core/ui/widgets/number/nesty_number_text.dart:7` — tabular figures (PROGRESS Q29; moved from M2, the approach waits on the owner). The design asks for them, but Fredoka's digits are proportional and it has no `tnum`, so a changing number still shifts. This widget is the …

## v1.1 — After v1 (e.g. the golden doll, spec §3.5)

- `apps/game/lib/core/ui/theme/reduce_motion_override.dart:4` — with Android's "Remove animations" on, Off can't bring back full motion: an `AnimationController` with the default behaviour runs at 5 % of its duration whenever `SemanticsBinding.disableAnimations` (the platform's flag, …
- `apps/game/lib/features/gameplay/pages/gameplay_board.dart:147` — the board has no screen-reader nodes (Flame adds none), so a VoiceOver or TalkBack player can't pick a slot. The owner decides whether that is v1 (M7 review R12, its PROGRESS question): a semantics layer from the page's …
- `packages/nesty_core/lib/src/codec/game_session_codec.dart:547` — read gold once the §3.5 rules and the Nest view ship.
- `packages/nesty_core/lib/src/rules/engine/nest_code.dart:119` — Nest view for a mixed gold nest (spec §3.5); needs a Nest model that records the golden doll's position.
- `packages/nesty_core/lib/src/validator/level_checks.dart:199` — accept gold once the §3.5 rules ship (spec §3.5, D22).

## design — Waiting on a design export or decision from the owner

- `apps/admin/lib/core/extensions/context_extension.dart:12` — map to the admin type scale from design/admin/*.png + design/tokens.json once they exist.
- `apps/admin/lib/core/ui/colors/app_colors.dart:6` — every value below is a placeholder. Replace them with `design/tokens.json` → `color.*` and `design/admin/*.png` once exported.
- `apps/admin/lib/core/ui/theme/app_theme.dart:6` — radii, spacing, table and form styles from `design/tokens.json` and `design/admin/*.png` (DESIGN_BRIEF Prompt 14).
- `apps/admin/lib/core/ui/theme/app_theme.dart:8` — bundle the brand fonts as assets rather than using google_fonts, which downloads at runtime.
- `apps/admin/lib/core/ui/widgets/placeholder_view.dart:7` — replace each use with the real screen (design/admin/*.png).
- `apps/admin/lib/features/login/pages/login_page.dart:11` — design/admin/*.png has no login screen yet (DESIGN_BRIEF Prompt 14 lists Levels, Level Editor and Skin upload only).
- `apps/admin/lib/features/not_authorized/pages/not_authorized_page.dart:10` — no admin design export covers this screen yet.
- `apps/admin/lib/features/shell/pages/admin_shell_page.dart:17` — narrow-window layout and rail styling (design/admin/*.png).
- `apps/game/lib/core/ui/colors/app_colors.dart:62` — m7-5 named no token for the figurine panel's two gradients; the frame's `mBg` values stay here (BACKLOG "Design gaps").
- `apps/game/lib/core/ui/icons/icon_uses.dart:107` — ask Claude Design to add `storageError` and `contentError` to tokens.json `icons` (lead note 2; ui-spec-game C9).
- `apps/game/lib/core/ui/lottie/lottie_label.dart:121` — the 52 max width is a guess (lottie §12).
- `apps/game/lib/features/daily/pages/daily_page.dart:260` — no frame shows the Daily screen itself before Level 2 (m3-design §8.3, Q67); Home's tile is dimmed instead.
- `apps/game/lib/features/gameplay/game/timeline/timeline_plans.dart:893` — an empty case or ice has no target doll; the drift uses the mover's height.
- `apps/game/lib/features/gameplay/overlays/overlay_text_link.dart:31` — tokens.json has no 16 px Fredoka style for a text link; this is `buttonSmall` (17 px) at the frame's 16 px.
- `apps/game/lib/features/records/pages/records_page.dart:171` — the "Best moves by level" destination is in no frame (menus spec §11 gap 6): it keeps the stand-in target, Chapters, whose won cells show "Best N". BACKLOG "M7 phase 4 design gaps".
- `apps/game/lib/features/splash/pages/splash_page.dart:128` — add the splash error dim to tokens.json `color`.
- `packages/nesty_render/lib/src/board/board_geometry.dart:169` — , the design draws no tall case there): then it is the case of a doll of `caseHeight`, and the composition's `case_size` follows it (the doll itself stays h.
- `packages/nesty_render/lib/src/board/board_layout.dart:179` — a row of 6 (the second +1 Slot on a 4-slot bottom shelf, D172) extends rowOfFive's formulas: pitch 372 / 6 = 62, stands at 59.6 / 90 = 0.662; the design draws no row of 6.
- `packages/nesty_render/lib/src/board/shelf_presets.dart:51` — a 1-shelf board is undesigned (D22, BACKLOG "Design gaps"). The plank sits where the 2-shelf pair is centred, with the 3-shelf doll height.
- `packages/nesty_render/lib/src/doll/placeholder_doll_painter.dart:292` — `layout.fallbackDoll` doesn't say whether "circle, 0.36 h", "disc, 0.19 h" and "disc 0.2 h" are diameters or radii; ask Claude Design to say so in tokens.json.

## later — Unscheduled (spec §19 "Later ideas")

_None._
