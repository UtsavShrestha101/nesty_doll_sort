# Plan: M3 — App shell and meta

Status: written 2026-09-27; the owner asked for plan-then-workflow ("like M2").
Later decisions go in PROGRESS as D63+.

## Context

Spec §18 M3 covers Home, win, pause, settings, save and resume, coins, the
booster inventory, chapters, the museum, the daily puzzle, Bonus Endless, the
tutorial and intro cards, and audio/haptics hooks. ✅ **Kill the app mid-level
and it resumes exactly where it was. The daily puzzle is identical on two
devices on the same date.** The scope is BACKLOG "M3" (about 40 items) plus 26
`TODO(M3)` markers. All 26 markers already have items there.

Owner input, 2026-09-27:

- **Q3:** the save is a Hive box behind `DatabaseService`, with a schema
  version and migrations.
- **Q5:** add `reward_medium`, default 10.
- M3 starts before M2's device checks are done (60 fps, the manual L1–30
  pass, audio). M2 stays "acceptance pending".

Spec sections: §7.1–§7.6, §8, §9.4, §10.1–10.2, §11.3, §13.3, §13.4 #4,
§14.4 and §16. Frames: 1.3–1.6, 2.1, 2.8, 3.2, 3.3, 3.5, 4.1–4.3, 4.6,
4.9, 4.10, 5.1–5.6, 6.1–6.3, 7.3–7.7 and 8.1–8.2. The coin/ad Shop tabs
(7.1, 7.2, 7.8–7.10) are M6.

## Approach

The save is **one JSON document under the key `doc` in a new Hive box
`save`**:

- It uses the §13.3 shape with `"schema": 1`.
- Forward migrations run on open, before any read. Reads are lenient: a
  corrupt, missing or newer document falls back to defaults, the raw document
  is kept, and nothing crashes.
- A single-key `put` is one CRC-checked Hive frame. A torn write is dropped on
  reopen and the previous document survives. That is the spec's atomic write.
- Writes go through one serial queue. The in-progress level is saved after
  every applied move, undo, restart and +Slot, and the box is flushed on
  `AppLifecycleState.paused`/`detached`.

Game rules stay in `nesty_core`. Core gains a pure-Dart `GameSessionCodec`
covering the state, the undo history and `undosUsed`. Undo events are
re-derived on decode through `Rules.tryMove`, which also proves the history is
consistent. Core also gets deterministic generator retries and golden
fingerprints for dailies and bonus levels.

Everything meta (economy, streak, catalog, tutorial, intro cards) is pure
Dart in `apps/game`, with an injected `AppClock`, behind interfaces that each
have a fake. The build runs as a staged workflow like M2's:

1. A contracts stage freezes the interfaces.
2. Four lanes build in parallel: core, services, bloc, UI kit and ARB.
3. Three screen lanes follow.
4. Then an integrator, one three-lens reviewer, and a fix-and-close agent.

Rejected, one line each:

- **Typed Hive adapters per field:** a deep field-index contract with players'
  devices, and the game state needs JSON anyway.
- **The spec's temp-file-and-rename JSON:** the owner chose Hive (Q3).
- **A `SolverSnapshot` "generate" task:** `Isolate.run` copies
  `GeneratorParams` with no encoding, so the BACKLOG item is dropped with a
  reason.
- **Settings moved into the save document:** they already persist in the
  `settings` box and stream to the music. This is recorded as a §13.3
  deviation.

## Decisions the contracts stage records (defaults; each flagged in Open questions)

1. **Save document additions to §13.3** (D22 style, design wins):
   - `museumCollected: {chapterId: "yyyy-mm-dd"}` (frame 6.2);
   - `seenIntros: ["towers", …]`;
   - `tutorialDone`;
   - `bonus: {next}`;
   - `daily.inProgress`;
   - `playerId`.

   Generated boards (bonus and daily) store their level JSON inside
   `inProgress`, so a resume never regenerates them. A campaign board restores
   only when `levelId` and `levelVersion` match (§13.3). Otherwise the level
   restarts.
2. **Resume after a kill:** the app relaunches to Splash, then Home. PLAY
   (Level N, a bonus level or the daily) reopens the saved board exactly: the
   board, the undo history, the free undos left and the extra slots. The
   selection and the hint are cleared.
3. **Bonus Endless** sits outside the chapters: no chapter progress, no
   figurine, and the last chapter's theme.
   - `currentLevel` stays at `levelCount + 1`.
   - Bonus Level N is `bonusParams(levelCount + N)`, generated in an isolate
     with the next one prefetched during the win overlay. An expert-only
     level plays as its tier (Q31).
   - So levels published later (M4) come before the next bonus level and are
     never skipped.
4. **Daily:**
   - The date is the device's local calendar date from `AppClock`, and the
     puzzle is `dailyParams(yyyymmdd)` under `Generator.version` 1. A
     `GeneratorFailure` retries with seeds derived deterministically in core.
   - It unlocks once Level 2 (the tutorial) is won.
   - Streak: a missed day resets it, unless a held freeze covers it
     automatically. At most 1 freeze is held, and a new one is granted each
     ISO week (Monday).
   - A frozen day keeps the streak without adding to it. Every 7th streak day
     opens the 300-coin chest, and a solve pays 50 (no ×3).
5. **Intro cards** show once, on the first board with that mechanic (towers,
   glass, ice). With the §3.7 schedule that is L16, L31 and L51, and the same
   rule covers a daily or bonus board that meets a mechanic first. Their
   looping mini animations reuse `doll_reveal`, `fx_glass_unlock` and `fx_ice`
   on a small plank (`TODO(design)`).
6. **Economy:**
   - Win rewards: `reward_easy`, `reward_medium`, `reward_hard`,
     `reward_superhard`, from Remote Config.
   - Chapter complete pays a new key `reward_chapter` (default 150), like Q5.
   - Undo after the free ones costs `price_undo`, and a Hint or Slot at 0
     costs `price_hint`/`price_slot`. `booster_use{source: coins}`.
   - Starting coins are 0 (Q46). The starter gift is 3 hints and 2 slots.
     The dev flavor keeps unlimited boosters.
7. **Catalog:** a `CatalogRepository`, bundled now with a Firestore overlay in
   M4. It holds the chapters (theme, figurine), the skins and the themes.
   - Skin prices come from frame 7.3: Ocean 800, Sweets 1,500, Forest Friends
     (fox) 2,000, Winter 3,000. Space defaults to 1,200.
   - `forest-bear` is not sold.
   - Theme prices: ch04 1,200, ch05 1,500, ch06 2,000. ch02 and ch03 cost
     800 and 1,000 when bought before their chapter.
   - Figurines 4–10 are named "The Astronaut Family" … "The Explorer Family",
     with the flavor text hidden until the owner supplies it (Q47).
8. **Settings:**
   - Version and build come from `package_info_plus`.
   - Privacy Policy and Support open through `url_launcher`. `AppLinks` stays
     empty until the owner supplies the values, and an empty link hides its
     row.
   - Player ID is a local random id stored in the save (see Copy to confirm).
   - The language sheet lists the 9 launch languages. Languages without an
     ARB file are disabled until M7 (`TODO(M7)`).

## Files (by member; the contracts stage assigns exact ownership per lane)

| Member | Create / modify |
|---|---|
| `packages/nesty_core` | new `codec/game_session_codec.dart` (+ barrel), generator retry seeds (`generator.dart`/`curve.dart`, doc-only `TODO(M3)` fix), `test/codec/game_session_codec_test.dart`, `test/generator/daily_golden_test.dart` (VM + `-p chrome`) |
| `apps/game` core | `services/save/{save_document,save_migrations,hive_save_service}.dart`, save API grown in `save_service.dart`/`in_memory_save_service.dart`/`fake_save_service.dart`, `HiveBoxes.save`, `services/clock/`, `services/generator/` (`Isolate.run` + fake), `repository/catalog_repository.dart` (+ bundled, fake), `remote_config_keys.dart` (`reward_medium`, `reward_chapter`), `asset_skin_service.dart` (selected skin, showcase dolls, theme per chapter), `router/app_router.dart` (shell + routes, `PlayRequest`), `music_route_observer.dart`, `jingle_cues.dart` callers, `bootstrap`/app lifecycle flush |
| `apps/game` features | `gameplay/bloc` (restore, save per move, `PlayRequest`, coin paths, purchase offer, chapter complete, daily/bonus, tutorial gate, intro gate), `gameplay/{overlays,widgets,pages}` (buy popup 3.2/3.3, OOM coin rows, badges, tutorial 1.3–1.6, intro cards 4.1–4.3, bonus intro 4.9, pill 4.10, daily pill 5.3, win progress 2.8, chapter complete 4.6), new `home` tiles + `shell` (bottom nav), `settings/`, `daily/` (+ `model/streak_rules.dart`), `museum/`, `shop/`, and `core/ui` (segmented tabs, bottom nav, Home tile, buy popup body, intro card, toast) |
| `apps/game` other | `l10n/app_en.arb` (+ generated), `pubspec.yaml` (2 packages, `assets/museum/`), tests for every cubit, page and service, `app_flow_test.dart`, `integration_test/` (resume and daily phases) |
| `tools` | `sync_design_assets`: ship `design/museum/png/*.png` (20 files, 2.3 MB) with validation and `--check`; tests; README |
| docs | this plan, `plans/m3-design.md` (the contracts stage's authoritative design), PROGRESS (D63+, Q3/Q5 closed, status), BACKLOG, `.claude/rules/hive.md` (the Q3 section) |

## Reused code

- `BaseAsyncCubit`/`BaseAsyncBloc` + `AsyncValue` (`lib/core/base/`).
- `HiveDatabaseService.openOrFallback` and `_readBool`-style lenient reads.
- The `database_service_contract.dart` pattern, applied to a new save
  contract.
- `IsolateSolverService`'s silent-failure worker.
- `DifficultyCurve.bonusParams`/`dailyParams`/`dailyTier`, and
  `GameSession.restore`.
- `LevelCodec.encode`.
- The UI kit (`nesty_ui.dart`: `ModalCard`, `NestySheet`, `NestyToggle`,
  `CoinPriceButton`, `RewardedAdButton`, `NestyBanner`, `NestyProgressBar`,
  `LevelPill` daily/bonus, `WoodBar`).
- `LottieFxView` (`ui_tap_hand`, `ui_drag_hand`, `ui_spinner`,
  `fx_twinkle`), `JingleCues`, `MusicDuck`, and `LocalizationCubit`.

## Codegen

The order is `flutter gen-l10n`, then `dart run build_runner build`, in
`apps/game`, each run by that stage's named codegen owner only (M2's lock).
The core and tools lanes need none. `hive_ce_generator` still generates
nothing, so its Tech debt item is closed by removing it, with the reason
recorded.

## Packages

- `package_info_plus`: the Settings footer shows the version and build
  (frame 8.1; BACKLOG names it).
- `url_launcher`: Privacy Policy and Support email (frame 8.1, §10.2 #13).

Neither is in §13.2, so both rule-9 reasons go in PROGRESS. The
`hive_ce_generator` dev dependency is removed.

## Verification

- **Baseline gate** (`/milestone`): pub get, codegen drift, format,
  `flutter analyze --fatal-infos --fatal-warnings`, the core/render/game/admin/
  tools tests, the token/icon/asset/TODO-index checks, `bundle check`, and
  the APK dev/prod, iOS dev and admin web builds.
- **Resume, automated:**
  - the core codec round trip (state, history, `undosUsed`, extra slots,
    towers, locks, ice) and its rejections;
  - the Hive save round trip with `HiveDatabaseService.open(directory:)`
    temp dirs, migrations, a corrupt or newer document, and a torn write;
  - bloc restore on a `levelVersion` match and a restart on a mismatch;
  - an app-level test that makes moves, tears the DI and app down, and
    rebuilds on the same Hive directory with an identical board.
  - **Device kill:** a two-phase `flutter drive` on the iPhone 16 simulator
    and the API 35 emulator. Phase A plays moves and records the board
    fingerprint. The app is terminated (`xcrun simctl terminate` / `adb shell
    am force-stop`). Phase B relaunches and compares.
- **Daily, automated:** golden fingerprints for 28 consecutive dates and bonus
  1–20, on the VM and on `dart test -p chrome`. The dev flavor's
  `NESTY_FAKE_DATE` puzzle gives the same fingerprint on the iOS simulator
  and the Android emulator.
- **Owner:** swipe the app away mid-level on a phone, relaunch, press PLAY;
  the daily on two phones on the same date; the haptics tuning.

## Risks

- **Scope:** about 40 items across 8 lanes, plus heavy parallel edits to the
  gameplay page. The stages give each lane exclusive paths, and the
  integrator owns every cross-lane edit.
- **Save correctness:** a bad migration or save loses progress. Every read is
  lenient and never throws. The raw document is backed up before its first
  migration.
- **Cross-platform generator determinism:** `dart2js` integer behaviour.
  M1's `Hash64`/PRNG parity already holds on the VM, node, Chrome and wasm,
  and the goldens make any drift a CI failure.

## Open questions for the owner (the defaults above ship unless answered)

- **Daily unlock:** after the tutorial (Level 2 won), with intro cards
  covering any mechanic a daily shows first? The design has no locked tile,
  so it is `TODO(design)`.
- **`reward_chapter`:** a Remote Config key for the 150 coins, default 150,
  like Q5?
- **Resume:** relaunch to Home with PLAY continuing the board, or open
  straight into the board?
- **Streak readings:** freezes capped at 1 and granted each ISO week; a frozen
  day doesn't add to the count; the chest on every 7th streak day.
- **Bonus levels:** outside the chapters, and never skipping later-published
  levels?
- **Prices and content not in the frames:** the Space skin (1,200) and early
  ch02/ch03 themes (800/1,000). Figurine names 4–10 and 9 flavor texts
  (Q47). The privacy URL and support email. Player ID (local random id, or
  drop it).
