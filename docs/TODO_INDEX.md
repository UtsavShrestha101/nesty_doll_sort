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
| M4 | Firebase content | 13 |
| M5 | Admin panel | 17 |
| M6 | Monetization | 15 |
| M7 | Art and polish | 10 |
| M8 | Release prep | 2 |
| v1.1 | After v1 (e.g. the golden doll, spec §3.5) | 3 |
| design | Waiting on a design export or decision from the owner | 42 |
| later | Unscheduled (spec §19 "Later ideas") | 1 |

Total: 103 markers.

## M1 — Core (`nesty_core`)

_None._

## M2 — Playable game

_None._

## M3 — App shell and meta

_None._

## M4 — Firebase content

- `apps/game/lib/bootstrap.dart:32` — Firebase + Crashlytics go here, before DI: await Firebase.initializeApp( options: DefaultFirebaseOptions.currentPlatform, ); importing `firebase_options_<flavor>.dart` chosen by the flavor entry point. Those files are …
- `apps/game/lib/bootstrap.dart:57` — FirebaseCrashlytics.instance.recordError(error, stackTrace).
- `apps/game/lib/core/base/run_guarded.dart:29` — also report as a Crashlytics non-fatal (spec §14.4).
- `apps/game/lib/core/repository/bundled_catalog_repository.dart:12` — overlay Firestore's `chapters`, `skins`, `themes` and `museumItems` (cached, offline-first; spec §13.5, §14.1).
- `apps/game/lib/core/repository/default_level_resolver.dart:101` — this only sees the bundle it was resolved from, so a chapter the player already passed with fewer levels than `ChapterInfo.levels` never retroactively completes when sync adds the rest. Award that figurine and …
- `apps/game/lib/core/repository/level_repository.dart:9` — `levels_cache.json` + background Firestore sync on launch and resume (never blocking, never swapping the level in progress).
- `apps/game/lib/core/services/analytics/analytics_service.dart:4` — add `FirebaseAnalyticsService` (firebase_analytics) for the real env, plus typed helpers for the §14.4 events (`level_start`, `level_win`, ...) so event names never get mistyped at call sites.
- `apps/game/lib/core/services/analytics/fake_analytics_service.dart:13` — drop `AppEnv.real` from `env` once `FirebaseAnalyticsService` exists, then record events in memory (`events` list plus `clear()`) so tests can read them; that is only safe once release builds stop using this class.
- `apps/game/lib/core/services/database/hive_database_service.dart:53` — report as a Crashlytics non-fatal.
- `apps/game/lib/core/services/remote_config/defaults_remote_config_service.dart:9` — replace in the real env with `FirebaseRemoteConfigService`.
- `apps/game/lib/core/services/remote_config/remote_config_service.dart:6` — add `FirebaseRemoteConfigService` (firebase_remote_config) for the real env; it sets `RemoteConfigKeys.defaults` as in-app defaults and falls back to them on any fetch error.
- `apps/game/lib/features/shop/widgets/skin_grid_card.dart:46` — a skin mid-download shows this instead of Equip/Buy; no bundled skin ever sets it (frame 7.5).
- `apps/game/lib/features/splash/cubit/splash_cubit.dart:32` — kick off level sync and Remote Config refresh in the background here — unawaited, so the splash never waits on the network (rule 3).

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
- `apps/game/lib/core/services/music/music_service.dart:71` — AdsService calls this before every show, and resumeAfterAd in a `finally` when the ad closes (BACKLOG M6 "Ads").
- `apps/game/lib/core/services/purchase/fake_purchase_service.dart:9` — drop `AppEnv.real` from `env` once `StorePurchaseService` exists.
- `apps/game/lib/core/services/purchase/purchase_service.dart:19` — add `StorePurchaseService` (in_app_purchase) for the real env: product queries, client-side receipt checks (v1), restore purchases, and crediting coins/adsRemoved through the M3 save.
- `apps/game/lib/features/daily/widgets/daily_chest_modal.dart:62` — "Double it" (a rewarded ad) sits above Collect.
- `apps/game/lib/features/gameplay/overlays/out_of_moves_sheet.dart:17` — the ▶ ad option and its offline variant (frame 3.7).
- `apps/game/lib/features/gameplay/overlays/win_overlay.dart:77` — the ×3 rewarded-video button and its "Reward added" state (frames 2.8, 2.9); hidden until ads exist, as the design does offline.
- `apps/game/lib/features/gameplay/widgets/booster_bar.dart:60` — the ▶ badge at 0 while an ad is ready (frame 2.2).
- `apps/game/lib/features/settings/pages/settings_page.dart:136` — Restore Purchases (spec §9.2).
- `apps/game/lib/features/settings/pages/settings_page.dart:142` — Privacy choices (the consent form's "Manage options", spec §9.3).
- `apps/game/lib/features/shop/widgets/shop_closed_card.dart:8` — replace with the real coin packs (7.1, 7.2) and Remove Ads / No-Ads Bundle (7.8) once purchases ship.
- `apps/game/lib/features/splash/cubit/splash_cubit.dart:34` — first-launch consent (UMP) sits between splash and Home (§10.1).
- `apps/game/test/core/dependency_injection/di_test.dart:191` — flip as AdMob lands.

## M7 — Art and polish

- `apps/game/lib/core/services/haptics/system_haptics_service.dart:48` — tune by feel on devices (BACKLOG M7, moved from M3's "Audio and haptics": it needs the owner's hands on real phones).
- `apps/game/lib/core/ui/theme/app_text_styles.dart:9` — tabular figures for coins and counters (PROGRESS Q29; moved from M2, the approach waits on the owner). Fredoka has no `tnum`, so [number]'s `FontFeature.tabularFigures()` does nothing yet; `NestyNumberText` is the one …
- `apps/game/lib/core/ui/widgets/number/nesty_number_text.dart:7` — tabular figures (PROGRESS Q29; moved from M2, the approach waits on the owner). The design asks for them, but Fredoka's digits are proportional and it has no `tnum`, so a changing number still shifts. This widget is the …
- `apps/game/lib/features/daily/widgets/puzzle_card.dart:209` — the frame draws the chapter background (`backgrounds/ch3-seaside-market.svg`, center 42%/cover) under the plank; `SkinService.background` is the one full-screen raster, so this card keeps the flat fallback for now.
- `apps/game/lib/features/gameplay/game/components/slot_decor.dart:63` — the "+N" tag and the badge's digits through ARB, with the locale's text direction, when translations land (spec §16); every launch language writes "+3" this way (review PERF-RULES-3).
- `apps/game/lib/features/gameplay/game/timeline/win_overlay_schedule.dart:72` — tune by feel (BACKLOG "Animation polish").
- `apps/game/lib/features/gameplay/pages/gameplay_view.dart:239` — a restored board whose intro card was never dismissed shows the card over this sheet, whose rows then wait for "Got it".
- `apps/game/lib/features/gameplay/pages/gameplay_view.dart:905` — if this bonus level can't be generated the card stays up with its button live; Continue's failure has the retry card (`NextLevelFailedCard`), this path doesn't yet.
- `apps/game/lib/features/settings/widgets/language_sheet.dart:89` — .
- `packages/nesty_render/lib/src/theme/chapter_theme.dart:56` — chapters 7–10 have no theme art yet (BACKLOG "Owner inputs needed"); until it arrives they reuse the six themes in order.

## M8 — Release prep

- `apps/game/android/app/build.gradle.kts:66` — Sign release builds with the upload key. Load it from an untracked android/key.properties (storeFile, storePassword, keyAlias, keyPassword) and never commit the keystore or passwords. .gitignore already excludes …
- `apps/game/lib/core/services/links/app_links.dart:6` — the owner's privacy policy URL and support email (Q73).

## v1.1 — After v1 (e.g. the golden doll, spec §3.5)

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
- `apps/game/lib/core/extensions/app_exception_extension.dart:9` — split `storage` and `content` (bundled levels failed to load) into their own keys once a load-failure screen is designed; no frame shows one (moved from M2, BACKLOG "Design gaps").
- `apps/game/lib/core/ui/colors/app_colors.dart:10` — ask the designer to add these to tokens.json `color`, then switch the call sites to `AppColorTokens` and delete them here.
- `apps/game/lib/core/ui/lottie/lottie_label.dart:74` — the 52 max width is a guess (lottie §12).
- `apps/game/lib/core/ui/widgets/booster/booster_button.dart:22` — no frame shows a disabled booster.
- `apps/game/lib/core/ui/widgets/buttons/play_button.dart:22` — no frame shows Home past the last level; M3's Bonus Endless shows the bonus level here (spec §7.1).
- `apps/game/lib/core/ui/widgets/buttons/play_button.dart:187` — Home shows only HARD; SUPER HARD reuses its shape on the purple gradient with the bolt glyph (Design System chip).
- `apps/game/lib/core/ui/widgets/buttons/tactile_button_style.dart:13` — confirm the success/danger/teal drops (and a danger button at all: no frame shows one; its colours come from the Hard pill).
- `apps/game/lib/core/ui/widgets/feedback/nesty_toast.dart:31` — picked a readable default; ask the owner for the real one.
- `apps/game/lib/core/ui/widgets/home/home_tile.dart:25` — no frame shows the locked Daily tile (before Level 2, Q67). [locked] dims the tile, disables the tap and shows a small lock glyph where the streak badge would sit.
- `apps/game/lib/core/ui/widgets/retry_view.dart:11` — no frame shows a load failure; this uses the body style and a secondary button until one does.
- `apps/game/lib/features/daily/pages/daily_page.dart:160` — no frame shows the Daily screen itself before Level 2 (m3-design §8.3, Q67); Home's tile is dimmed instead.
- `apps/game/lib/features/gameplay/bloc/tap_policy.dart:96` — frame 2.6 doesn't cover a tap on an unpickable slot with nothing lifted; ignored until the owner decides (it could shake the slot instead).
- `apps/game/lib/features/gameplay/game/components/hint_layer.dart:53` — frame 3.1 shows one arc (r0c3 → r2c0); the curve for other moves (same shelf, one column, upward, the extra slots) is generalized from it here and needs a design check (BACKLOG "Design gaps").
- `apps/game/lib/features/gameplay/game/timeline/timeline_plans.dart:773` — an empty case or ice has no target doll; the drift uses the mover's height.
- `apps/game/lib/features/gameplay/overlays/intro_mechanic_card.dart:28` — m3-design §10.4 asks for a looping mini animation of each mechanic (`doll_reveal`, `fx_glass_unlock`, `fx_ice` are board-hosted files); no loop is designed for a card, so the pieces stand still (BACKLOG).
- `apps/game/lib/features/gameplay/overlays/next_level_failed_card.dart:18` — no App Flow frame shows a next-level failure; this is the page's RetryView on the all-levels card's placement (NestyOverlay).
- `apps/game/lib/features/gameplay/overlays/out_of_moves_sheet.dart:15` — no frame shows the Undo row once its free undos are used (BACKLOG "Out-of-moves Undo row once the free undos are used"); it reuses +1 Slot's coin-chip trailing.
- `apps/game/lib/features/gameplay/overlays/overlay_text_link.dart:31` — tokens.json has no 16 px Fredoka style for a text link; this is `buttonSmall` (17 px) at the frame's 16 px.
- `apps/game/lib/features/gameplay/overlays/win_overlay.dart:343` — LOTTIE.md puts fx_twinkle on the win overlay but no frame places it; these sit around the plank.
- `apps/game/lib/features/gameplay/widgets/soft_stuck_banner.dart:20` — no frame shows soft stuck without an undo.
- `apps/game/lib/features/home/pages/home_page.dart:126` — frame 2.1 has no short-screen variant; 12 is a guess.
- `apps/game/lib/features/museum/cubit/museum_state.dart:85` — no App Flow frame shows every chapter collected; this reads the m3-design §10.6 fallback copy verbatim (`museumAllHome`).
- `apps/game/lib/features/shop/widgets/purchase_twinkle_burst.dart:12` — no frame times a Shop purchase's celebration; this shows one twinkle cycle (2.2 s) and removes itself, matching the file's own length rather than looping like Home's ambient stars.
- `apps/game/lib/features/shop/widgets/shop_colors.dart:8` — ask the designer to add these to tokens.json `color`, move them into `AppColors`, and delete this file.
- `apps/game/lib/features/shop/widgets/shop_colors.dart:31` — per-skin panel edges for frame 7.4 (only Ocean's exists).
- `apps/game/lib/features/shop/widgets/theme_grid_card.dart:10` — the tile shows the chapter's flat fallback colour, not its scenic background art. `SkinService.background` is one shared full-screen rasterizer (one theme at a time); showing six thumbnails at once needs its own …
- `packages/nesty_render/lib/src/board/board_geometry.dart:374` — an iced tower has no frame. Its stand is 5·q taller, so the composition, anchored on the doll, draws its ice 5·fs above the static `iceRect` fallback, which stays on the stand's bottom.
- `packages/nesty_render/lib/src/board/board_geometry.dart:509` — the design has no top-shelf tower whose buried nests would reach the HUD; compressing D21's 18 dp step is this layout's extension (BACKLOG "Design gaps").
- `packages/nesty_render/lib/src/board/board_layout.dart:188` — rows of 5–6 slots are undesigned (D22, BACKLOG "Design gaps"); pips, tags, glass and ice shrink with the stand.
- `packages/nesty_render/lib/src/board/board_layout.dart:234` — maxSize 6 on 3 shelves, maxSize 3 on 3 shelves or on 4-slot rows (M2 levels 3–9), and rows of 5–6 slots are undesigned (D22); this clamp is how they fit.
- `packages/nesty_render/lib/src/board/shelf_presets.dart:38` — a 1-shelf board is undesigned (D22, BACKLOG "Design gaps"). The plank sits where the 2-shelf pair is centred, with the 3-shelf doll height.
- `packages/nesty_render/lib/src/board/shelf_presets.dart:61` — a 4-shelf board is undesigned (D22, BACKLOG "Design gaps"). Planks are spread evenly from 250 to the 3-shelf bottom plank (684), and dolls and pieces are scaled by 104/150 so the tallest doll (maxSize 6) of the top row …
- `packages/nesty_render/lib/src/doll/placeholder_doll_painter.dart:312` — the handoff has no frame for the spec §12.5 placeholder; its proportions, face and seam (ink at 55 %, 6 units) follow the classic skin and the mask shading until the owner wants a designed fallback.
- `packages/nesty_render/test/board/board_lottie_anchors_test.dart:111` — in SlotGeometry.

## later — Unscheduled (spec §19 "Later ideas")

- `apps/game/integration_test/playthrough_test.dart:434` — 5.6's day-7 chest modal needs a real 7-day streak (`StreakDailyService`, m3-design §8.2) under the system clock this file runs on — unlike `daily_fingerprint_test.dart`, it doesn't set `NESTY_FAKE_DATE`, so this can't …
