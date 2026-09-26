# Backlog — Nesty: Doll Sort

This is the single curated checklist of all remaining work, with one section per
milestone (spec §18). [PROGRESS.md](PROGRESS.md) records what was done and why.
This file records what is left. In-code markers are indexed separately in
[TODO_INDEX.md](TODO_INDEX.md), which `dart run nesty_tools:todo_index` generates from
`TODO(<tag>)` comments. Never edit it by hand.

Last updated: 2026-09-26 (M1 closed).

## How this file works

- **The rule:** every deferral gets a BACKLOG item, a tagged `TODO(<tag>)` in
  code, or both. Code-level work should get both. The tags are `M1`…`M8`,
  `design`, `v1.1` and `later`. An untagged `TODO` fails CI.
- **Item format:** `- [ ] <item> — <source>`. When an item is done it becomes
  `- [x] … (done YYYY-MM-DD)`. An item moved to a later section carries
  `(moved from Mn: why)`.
- **Sources:**
  - `§n.m` is a section of [GAME_SPEC.md](GAME_SPEC.md).
  - `Dn`, `Qn` and `Bn` are a decision, question or blocker in [PROGRESS.md](PROGRESS.md).
  - `frame n.m` is a frame of `design/prototypes/Nesty App Flow.dc.html`. The
    frames are listed in [design/README.md](../design/README.md) under "Screens".
  - `plan Pn` is phase n of the approved 2026-09-26 round plan. Its owner
    decisions are copied into PROGRESS D18–D23.
  - `audit` is the 2026-09-26 audit of the design handoff (see D18–D20 and the
    items below).
  - A path is a file in this repo.
- **One place per item.** Implementation items go in the milestone that builds
  them. Anything only the owner can supply or decide goes in
  [Owner inputs needed](#owner-inputs-needed), with the milestone it blocks.
- **Milestone start:** read the milestone's section together with its spec §18
  criteria and the questions it cites.
- **Milestone end** (the `/milestone` skill):
  1. Tick the finished items.
  2. Move every leftover to a later section.
  3. Regenerate TODO_INDEX.md.
  4. Make sure no `TODO(Mn)` for the closing milestone is left without a later
     tag and a BACKLOG item.

## Design foundation — done (2026-09-26, plan P0–P1)

- [x] Move the handoff into `design/` (plus `design/prototypes/` and `design/README.md`) and delete `design_handoff_nesty/` — D18 (done 2026-09-26, commit 3a8dfca)
- [x] Update CLAUDE.md with the layout, the design contents and precedence, and point agents and skills at `design/prototypes/*.dc.html` instead of `design/screens/*.png` and `design/motion/` — D18 (done 2026-09-26)
- [x] Create this backlog and the tracking rule — D24 (done 2026-09-26)
- [x] Make `tools/` the workspace member `nesty_tools` (depends on `nesty_core`, `nesty_render`'s Flutter-free `svg_tools.dart`, `xml`, `path`; hand-rolled args) — plan P1 (done 2026-09-26)
- [x] `dart run nesty_tools:todo_index` writes docs/TODO_INDEX.md; `--check` fails CI on a stale index, an unknown tag or an untagged `TODO`/`FIXME` — D24 (done 2026-09-26)
- [x] `gen_design_tokens`: `design/tokens.json` → `render_tokens.gen.dart` (nesty_render) and `ui_tokens.gen.dart` (game). Every one of the 466 leaves is emitted or listed as documented-only, and unknown value shapes fail loudly — plan P1 (done 2026-09-26)
- [x] `sync_design_assets` copies the 7 skins (+ `skin.json`), 11 symbols, 15 board SVGs, ch01–ch06 backgrounds and 17 WAVs into `apps/game/assets/`. It strips the ~7.7 KB C2PA `<metadata>` block, validates the §12.2 SVG rules, is idempotent, and `--check` also checks the pubspec asset folders — plan P1, audit (done 2026-09-26)
- [x] Bundle static Fredoka 500/600/700 and Nunito 500–800 TTFs (google/fonts at a pinned commit, with OFL.txt) and register their licenses — Q14 (done 2026-09-26: `tools/fonts/build_fonts.sh`, byte-reproducible, `--verify`)
- [x] Icon font: a Material Symbols Rounded subset (FILL 1, wght 600, GRAD 0, opsz 24) of the README's 48 glyphs, with the FILL 1 `.fill` glyph swap baked into the cmap, plus `nesty_icons.gen.dart`. The `material_symbols_icons` fallback wasn't needed — design/README.md "Typography & icons" (done 2026-09-26)
- [x] Add `flutter_svg` and `xml` (render) and `flutter_soloud` (game, 4.1.7: see PROGRESS "Package reasons"), each with its rule-9 reason — CLAUDE.md rule 9, plan P1 (done 2026-09-26)
- [x] CI drift job runs token and icon gen, the asset-sync and TODO-index checks, plus `dart test` in tools. `block-generated.sh` protects `*.gen.dart`, `docs/TODO_INDEX.md`, the synced assets and the fonts — plan P1 (done 2026-09-26; the level bundle check moved to M2, see below)

## M1 — Core (`nesty_core`) — done (2026-09-26)

Acceptance (§18): all §4 rules unit-tested, solver fixtures pass, the generator
is deterministic, and 100 generated levels validate and solve. All met (see
PROGRESS "M1"). Leftovers moved to later sections are marked there.

- [x] One allocation-free §4 kernel over a compact board, called by `Rules`, `GameSession`, the solver, the simulator and the generator — §4, CLAUDE.md rule 2, plan P2 (done 2026-09-26, D30)
- [x] Immutable models: `Doll`, `Nest`, sealed `Slot` (open, tower, locked, plus ice), `Level`, `GameState`, `Move`, and sealed `MoveResult` (applied, or rejected with a reason) — §4 (done 2026-09-26, D27)
- [x] `MoveEvent`s in §4 order, carrying what the animations need. The destination's `Revealed` comes after `Completed` — §4, plan P2 (done 2026-09-26)
- [x] `legalMoves`, `isWon` and `isOutOfMoves` — §4 (done 2026-09-26)
- [x] `GameSession`: move, undo (history cleared on completion), restart, counts, and `addExtraSlot()` (`x0`/`x1` on the bottom shelf, at most 2, kept through restart) — §2.4, §3.6, D22 (done 2026-09-26)
- [x] Gold hooks in the codec and the kernel, with the validator rejecting gold until v1.1 — §3.5, D22 (done 2026-09-26)
- [x] `LevelCodec`, with round-trip tests — §5.1 (done 2026-09-26, D29)
- [x] `Validator` rules 1–8 with issue codes and arguments (for admin ARB), plus schema tests — §5.3 (done 2026-09-26, D29; ice bounded by `LayoutLimits.maxIce`, review SPEC-02)
- [x] `LevelBundleCodec` for `apps/game/assets/levels/bundle.json` (`format`, `bundleVersion`, `levelsVersion`, and levels with order, chapter, tier, version, reward and data) — §13.4, plan P2 (done 2026-09-26, D34)
- [x] Web-safe PRNG: xoshiro128** plus splitmix32, with 32-bit masked ops — §6.5, CLAUDE.md rule 7 (done 2026-09-26, D28)
- [x] Canonical key that sorts interchangeable open-slot contents, and `Hash64` as two u32 halves with no `fixnum` — §6.2, Q9 (done 2026-09-26, D28, D31)
- [x] Solver — §6.3 (done 2026-09-26, D31):
  - A* with a bucket queue, `h = nests − setsRemaining` and the §6.3 pruning.
  - Budgets 500k, 30k and 20k. An exhausted budget is `unknown`, never `unsolvable`.
  - Hint plus the fallback.
  - Resumable `SolverRun.advance()`, and `SolverSnapshot` for the isolate.
- [x] Solver fixtures (solvable, unsolvable, unknown) in `packages/nesty_core/test/fixtures/`. Decide where expected move counts live — §18 M1, Q19 (done 2026-09-26: `test/solver/fixture_expectations.dart`)
- [x] Simulator: casual and smart bots, 300 seeded runs, a 250-move cap, integer tier thresholds, and "expert only" when the smart win rate is below 0.5 — §6.4 (done 2026-09-26, D32)
- [x] Generator: the §6.5 params, segments, placement, locks and ice (validation rule 6), 50 sub-seed retries, the closest-tier fallback, `generatorVersion`, and golden hashes — §6.5 (done 2026-09-26, D33)
- [x] `DifficultyCurve` (`E E M E M H M E M S` per 10 levels) for bonus and daily seeds — §6.6, §7.1, §7.5 (done 2026-09-26; the default stage table is owner-confirmable, Q34)
- [x] A unit test for every §4 rule and every rejection reason, plus session tests — §18 M1, CLAUDE.md "Testing" (done 2026-09-26)
- [x] Determinism: the same seed and params give identical output, with VM, Chrome and Node parity (`dart test -p chrome,node test/parity`) — §18 M1, D11 (done 2026-09-26; dart2wasm too, and CI runs the web half, D39)
- [x] Acceptance test: 100 generated levels validate and solve (tagged `slow`) — §18 M1 (done 2026-09-26)
- [x] Record benchmarks (hint ≤ 100 ms on the VM) — plan P2 (done 2026-09-26: PROGRESS "M1 → Benchmarks"; the exhaustive-search targets are missed, Q32)
- [x] `nesty_tools` CLI with `validate`, `solve`, `simulate`, `report`, `bundle build|check`, `generate` and `fixtures check`. It replaces the script list in tools/README.md — plan P2, tools/README.md (done 2026-09-26)
- [x] M1 review fix pass: 18 of 19 findings fixed (RENDER-7 deferred to v1.1) — PROGRESS "M1 review and fix pass" (done 2026-09-26)

## M2 — Playable game — in progress

Acceptance (§18): levels 1–30 can be played start to finish at 60 fps on a
mid-range Android device. The scope grew: the design's art, tokens, SFX and
haptics were pulled in from M3 and M7 (D23).

### nesty_render

- [x] `DollPalette` from the generated `DollColorTokens` and `SkinTokens` (base, ink, light, symbol, rim, and modulate or the gold gradient map), replacing the hard-coded values and the placeholder gold. This resolves the `TODO(design)` and `TODO(M7)` markers in `doll_palette.dart` — design/README.md "Doll rendering", D19, `packages/nesty_render/lib/src/tokens/render_tokens.gen.dart` (done 2026-09-26)
- [x] Skin pipeline — §12.2, CLAUDE.md rule 8 (done 2026-09-26, D37):
  - `SkinManifest`.
  - `SkinSvgSplitter`, which copies every def into each layer.
  - `SvgColorRewriter` for the gold stops.
  - `SkinRasterizer` and `SkinCache`, with `ui.Image` layers per skin, height and DPR.
  - `SymbolAtlas` (subtle 110, large 117).
- [x] `DollRenderer` API: `prepare`, `isReadyFor`, and `paint` with parts, lid lift, open rim, symbols, silhouette, shine sweep and reveal wipe. No per-frame allocation — §12.6, CLAUDE.md rule 8 (done 2026-09-26; plus `canPaint`, `DollPart.interior/bodyFront` and `shadow`, D37)
- [x] `SvgSkinRenderer`, `PlaceholderDollPainter` (the fallback), `FallbackDollRenderer`, and `DollPainter` (a CustomPainter for widgets and the admin) — §12.5 (done 2026-09-26)
- [x] `BoardLayout` as pure math — §10.3, D21, D22 (done 2026-09-26, D36):
  - 3-shelf and 2-shelf presets, and row pitch `min(96, 372/n)`.
  - Geometry for stands, pips, glass, ice, tags, glow and hints.
  - Column hit rects of at least 48 dp.
  - Tower stacking at true size, and re-pitching the row for an extra slot.
- [x] `BoardLayout` for undesigned boards (1 or 4 shelves, 5-slot rows, maxSize 6 on 3 shelves), made by scaling the design's system and marked `TODO(design)` — D22 (done 2026-09-26, D36)
- [x] `BoardSprites` (board SVGs at the layout scale) and `ThemeBackground` (cover-fit, rasterized once at screen size, DPR ≤ 2) — plan P3, audit (done 2026-09-26, D38)
- [x] nesty_render tests — plan "Verification" (done 2026-09-26: 466 tests):
  - `BoardLayout` against NestyBoard at 390×844 (±0.5).
  - Hit rects on 5 screen sizes.
  - Renderer goldens against `design/skins/classic/renders/`.
  - The splitter, the rewriter and the palette.

### apps/game

- [ ] `AppTheme` from the generated tokens (Nunito body, Fredoka display) and the tactile component set from the README "Components" table. It replaces the placeholder `AppColors` — D4
- [ ] All handoff copy goes through ARB — §16, CLAUDE.md "Code style"
- [ ] Icons come from `NestyIcons.*` (the bundled `NestySymbols` subset), never `Icons.*`, in the HUD, booster bar, sheets and menus. To add a glyph, list it in `tools/fonts/nesty_symbols.txt` and run `tools/fonts/build_fonts.sh` — design/README.md "Typography & icons", tools/README.md
- [ ] Tabular figures for coins and counters. Fredoka's digits are proportional and it has no `tnum` feature, so `AppTextStyleTokens.number`'s `FontFeature.tabularFigures()` does nothing (Nunito's digits are already fixed-width). Build the approach the owner picks (Q29) — design/README.md "Typography & icons", tokens.json `fontSize.number.tabular`, tools/fonts audit
- [ ] `SoLoudAudioService`, with the fake kept for tests and `AppEnv.fake` (drop `AppEnv.real` from `FakeAudioService`; moved from M3: the SFX were pulled into M2, D23) — §11.3, D19, `apps/game/lib/core/services/audio/fake_audio_service.dart`:
  - Preloads the 17 SFX and picks a random clack variant.
  - Plays clacks at `2^(−2(size−3)/12)`, which offsets the +1 semitone baked into the files. `SoundTokens.clackSemitonesBySize` holds the design's target, so the rate is `2^((semitones − 1)/12)`.
  - Plays combo `complete_1..5`, obeys the settings, and fails silently.
- [ ] Haptic patterns from tokens: pick, nest, complete, win, invalid, unlock, ice and button — §11.2
- [ ] `IsolateSolverService` (a long-lived worker where the latest request wins), plus a fake — CLAUDE.md rule 8. Use `SolverSnapshot.start(snapshot, task, budget, requestId:)` and `SolverTask.advance(2000)` with an await between chunks, then map `task.result` with `SolverSnapshot.readHint`/`readVerdict` (solver report)
- [ ] `BundledLevelRepository`: `rootBundle` → `LevelBundleCodec` + `Validator`, skipping invalid levels with a log. Drop `AppEnv.real` from the fake — §13.4, §5.3, `apps/game/lib/core/repository/fake_level_repository.dart`
- [ ] Split `AppExceptionKind.storage` from a content failure (bundled levels failed to load) — `apps/game/lib/core/extensions/app_exception_extension.dart`
- [ ] In-memory `SaveService` for M2: current level, coins, a booster wallet (3 hints, 2 slots) and free undos from Remote Config. Unlimited boosters in the dev flavor — §8, §18 M2
- [ ] `SymbolsMode.large`, which also reads the legacy `assist` value — Q4, D19
- [ ] `SkinService` for the selected skin and the bundled skins — §7.4. Wiring (r2/r3 reports): one `SkinCache`, one `SymbolAtlas.load(rootBundle)` and one `BoardSpriteLibrary.load(rootBundle)` per app; `AssetBundleSkinLoader(bundle: rootBundle).load(skin)` → `SkinRasterizer` → `FallbackDollRenderer(primary: SvgSkinRenderer(…), fallback: PlaceholderDollPainter(symbols:), onPrimaryError: log)`; a `BoardSprites(library)` per level, `prepare(geometry, devicePixelRatio:, also: {extraSlot, the ice frames present})` behind the route transition and again after an extra-slot re-pitch (renderer `prepare(newGeometry.dollHeights)` first, then swap the geometry); `ensure(glassCase1/2)` about 700 ms before an unlock clip; `release` the glass frames after the last case shatters; one `ThemeBackground(bundle: rootBundle)` shown from the gameplay page's LayoutBuilder. The fake env uses `PlaceholderDollPainter()` with no atlas
- [ ] Nest animations draw the documented `DollPart` passes (host lid → host `interior` → guest with `shadow: false` → host `bodyFront`; swallow mirrors it) and animate scale on the destination rect, passing the resting `furnitureScale` to `BoardSprites` — D37, D38, review RENDER-1/6
- [ ] Towers: pass the tower's starting buried count to `SlotGeometry.buriedBaseY(depth, buried:)` so the spacing stays put as it empties — D36, review RENDER-4
- [ ] Name the game's `BoardEffect`s so they don't clash with core's exported `MoveApplied`/`MoveRejected`/`Completed`/`Won`/`Placed` (or import core with a prefix) — D27
- [ ] `GameplayBloc` (`BaseAsyncBloc`, FIFO) owning `GameSession` — §2.2, §2.3, D22:
  - The design's tap and drag policy, and `BoardEffect`s.
  - Stale solver results are dropped.
  - The soft-stuck check is debounced after each move.
- [ ] Flame tree: BoardComponent (tap and drag, hit testing through BoardGeometry) → ShelfLayer, SlotComponent (glass, ice, glow), NestComponent (including silhouettes), HintLayer and a pooled FxLayer. It reconciles from the new state after each batch — §13.1, CLAUDE.md rule 10
- [ ] `BoardTimeline` — §11.1, §16:
  - Every §11.1 animation, with the `tokens.motion` timings.
  - Sound and haptic cues at the design's offsets.
  - Input reservations per slot, and a combo tracker (4 s, max 5).
  - Reduced motion: durations ×0.5, no shake, wobble or confetti.
- [ ] Gameplay screen (frame 2.2) — §10.2 #3/#6:
  - Theme background.
  - HUD: pause, level pill with tier, coins, family counter.
  - Booster bar with count badges.
  - Soft-stuck banner (frame 3.4) with a glowing Undo.
- [ ] Win overlay (frame 2.8): scrim, confetti, ribbon, hopping families, coin count-up and a basic chapter card. The ×3 button stays hidden until M6 — §10.2 #4
- [ ] Out-of-moves sheet (3.5), Pause (3.9, with the Settings tile disabled until M3), hint (3.1), extra slot added (3.6) and next level (2.11) — §10.2
- [ ] All-levels-done screen with the frame 4.9 copy. Bonus generation is M3 — §10.2 #15
- [ ] Splash (frame 1.1: wordmark, striped loader, prepares the skin) and Home hero (frame 2.1: coin pill, wordmark, gear, idle dolls, PLAY with Level N and the tier badge) — §10.2 #1/#2
- [ ] Dev-flavor level picker — plan P4
- [x] 30 authored levels in `tools/levels/authored/`, built into `apps/game/assets/levels/bundle.json` by `nesty_tools bundle build`. L1 and L2 are the tutorial boards; ch01 is levels 1–20 and ch02 is 21–30 — §18 M2, §3.7 (done 2026-09-26, D35)
- [x] Declare `assets/levels/` in `apps/game/pubspec.yaml` in the same change that adds `bundle.json` — CLAUDE.md rule 3, `apps/game/pubspec.yaml` (done 2026-09-26)
- [ ] Extend `apps/game/test/core/assets/asset_manifest_test.dart` to assert that `assets/levels/bundle.json` ships and decodes with `LevelBundleCodec` without issues — CLAUDE.md rule 3 (split from the item above)
- [x] Run `nesty_tools bundle check` in the CI drift job (moved from Design foundation: no bundle existed yet) — plan P1, `.github/workflows/ci.yaml` (done 2026-09-26)
- [x] `nesty_tools bundle check` — §3.7, §6.6 (done 2026-09-26; towerless levels keep their tier by `tierOverride`, D26, Q30):
  - All 30 levels are valid and solvable.
  - The simulated tier equals the declared tier.
  - The §3.7 schedule holds (maxSize 4 at L10, towers at L16), and so does the §6.6 pattern.
- [ ] Game tests — CLAUDE.md "Testing":
  - Bloc: select, cancel, invalid, move, drag, undo, restart, hint, stale hint, soft stuck, extra slot ≤ 2, win, out of moves.
  - Timeline cue times.
  - Widgets: HUD, booster bar, sheets, win, pause.
  - Services: audio pitch, combo and settings gate; haptics; bundle repository; asset manifest.
  - The app flow.
- [ ] Builds: APK dev/stg/prod, iOS dev/prod (no codesign), admin web — CLAUDE.md "Commands"
- [ ] Run the dev flavor on the iOS simulator and an Android emulator, play L1–30, and compare with frames 2.2–2.8, 3.1, 3.4–3.6 and 3.9. Check that L16's 4,3 board reads as the tower intro and that the towerless L6 (HARD) and L10 (SUPER HARD) badges feel right (Q37, D26) — plan "Verification"
- [ ] Acceptance: 60 fps on a real mid-range Android in a profile build. The owner runs it on their device with `/perf-profile`, following the steps in PROGRESS — §18 M2, CLAUDE.md rule 8

## M3 — App shell and meta

Acceptance (§18): kill the app mid-level and it resumes exactly where it was.
The daily puzzle is identical on two devices on the same date.

### Save and economy

- [ ] Persistent save document with the §13.3 fields, atomic writes, a schema version and migrations, in the store Q3 picks. It replaces the D13 stub, and `AppEnv.real` is dropped from the fake save — §13.3, D13, Q3
- [ ] Save the in-progress level on every move and on app pause. Restore it when `levelVersion` matches, otherwise restart the level — §13.3
- [ ] Acceptance: save/restore round-trip tests (state, undo, `levelVersion`), plus a kill-and-relaunch check on a device — §18 M3
- [ ] Coins — §7.3:
  - Earn: 10 easy, 10 medium (see Q5), 25 hard, 50 superhard; 150 per chapter; 50 per daily; 300 for the day-7 chest.
  - Spend: undo 20 after the free ones, hint 60, slot 150.
- [ ] Persist the booster inventory, with the starter gift of 3 hints and 2 slots — §8
- [ ] Booster purchase popup, coin path: frames 3.2 (Undo) and 3.3 (Hint), with "You have N coins" — §10.2 #7
- [ ] Settings footer version and build, which needs `package_info_plus` with a rule-9 reason — frame 8.1, CLAUDE.md rule 9

### Progression

- [ ] Chapters of 20 levels, each showing its theme on Home and in play. "Match each chapter" is the default (`selectedTheme: null`) — §7.1, §7.4
- [ ] Chapter complete overlay (frame 4.6): spotlight, figurine, "Added to your Museum!", +150 coins, next chapter — §10.2 #9
- [ ] New-chapter ribbon on a chapter's first level, fading after about 2 s — frame 4.7
- [ ] Museum progress on the win card: chapter, count, bar, "Next up" and the locked figurine (frames 1.5, 2.8) — §7.2
- [ ] Museum detail's "Collected · Sep 12" chip needs a collected date, but the §13.3 save stores `museum` as ids only. Per D22 (the design wins), the M3 save records the date each figurine was collected. Record the §13.3 addition in PROGRESS when the save schema is built — frame 6.2, §13.3, D22, Q3
- [ ] Bonus Endless: generate with `seed = 1_000_000 + levelNumber` on the curve, with the bonus intro (4.9) and the teal "Bonus Level N" pill (4.10) — §7.1. Pass the global play order to `DifficultyCurve.bonusParams` ("Bonus Level N" = order − last published order); define the deterministic retry seed on a `GeneratorFailure` (A14; none occurred for 1–300); generate in the solver isolate (CLAUDE.md rule 8); act on `simulation.expertOnly` per Q31 (review SPEC-03) — generator report
- [ ] Replace the default difficulty stage table (A16) with the owner's (Q34; `TODO(M3)` in `packages/nesty_core/lib/src/generator/curve.dart`). Any change needs a `Generator.version` bump and new goldens and parity values — §6.6, A16
- [ ] `SolverSnapshot` "generate" task (design §6 lists hint | softStuck | generate) with a params encoding, when on-device generation moves into the isolate — design §6, contracts report
- [ ] `codec/game_state_codec.dart` (design §1 stretch goal): the in-progress save of `GameState` + undo history, persisting `GameSession.undosUsed` and restoring with `GameSession.restore(..., undosUsed:)` — §13.3, contracts and kernel reports
- [ ] Museum: collection card and a walnut cabinet of 4 × 3 (6.1), detail modal (6.2), and the locked state with a bar and Play (6.3). The art comes from `design/museum/png/` (20 files: figurines and `_locked` silhouettes), because the museum SVGs use nested `<svg>` and mix-blend-mode. Extend `sync_design_assets` and the pubspec asset list to ship them — §7.2, §10.2 #10, audit
- [ ] Daily puzzle: `seed = yyyymmdd`, a pinned `generatorVersion`, tier medium or hard. The date comes from an injected clock, never inside core — §7.5, CLAUDE.md rule 7. When `Generator.version` is ever bumped, keep a frozen v1 pipeline (PRNG, cuts, placement, validator, solver, simulator, daily table) for dailies so every device makes the same puzzle (Q35); decide the unlock level and the weekday rule (Q34) — generator report
- [ ] Daily screens — §10.2 #11:
  - 5.1: streak card, 7-day strip, chest row and puzzle card.
  - 5.2: streak saved.
  - 5.3: daily board with the date pill.
  - 5.4: solved, +50, no ×3.
  - 5.5: countdown to the next puzzle.
  - 5.6: chest modal with Collect ("Double it" is M6).
- [ ] Streak rules: a missed day resets the streak, and one freeze is earned each week — §7.5
- [ ] Acceptance: a seed test (same date → same level on every run), plus a two-device check — §18 M3

### Onboarding

- [ ] L1 tutorial (frames 1.3, 1.4): scrim with holes, dotted arc, tooltip and a tapping hand. All other input is blocked — §7.6
- [ ] L1 third step: nest the last Cherry 1 to finish the family. No frame exists, so mark it `TODO(design)` — §7.6, frame 1.4
- [ ] L1 complete (frame 1.5) and the L2 swallow drag demo (frame 1.6) — §7.6
- [ ] Mechanic intro cards, shown once each with a looping mini animation: towers at L16 (4.1), glass at L31 (4.2), ice at L51 (4.3) — §3, §7.6, §10.2 #8

### Menus

- [ ] Finish Home (frame 2.1) — §10.2 #2:
  - Tiles: Daily (streak badge), Museum (next-figurine progress), and a Remove Ads slot that hides once purchased.
  - Bottom nav: Shop · Home · Museum.
  - The coin pill's "+" opens the Shop.
- [ ] Routes for Win, Pause, Settings, Daily, Museum, Shop and SkinDetail — `apps/game/lib/core/router/app_router.dart`, design/README.md "Navigation & state"
- [ ] Settings (frame 8.1): Sound, Music and Haptics toggles, Color symbols (Subtle or Large), Language, Privacy Policy link, Support email, and a footer. The Restore and Privacy choices rows are wired in M6 — §10.2 #13
- [ ] Language sheet with the 9 launch languages (frame 8.2) — §16
- [ ] Enable Pause's Settings tile, and stop the flow test's pause from returning to Home — frame 3.9, `apps/game/test/app_flow_test.dart`
- [ ] Shop on the bundled art — §7.4, §10.2 #12:
  - Tab shell: Coins · Skins · Themes · No Ads.
  - Skins grid (7.3), skin detail with Buy for coins (7.4), and the skin in play (7.6).
  - Themes grid with the "Match each chapter" toggle (7.7).
  - Theme ownership (`ownedThemes`), per frame 7.7's note: "Chapter themes unlock with their chapter and can then be used anywhere. Later ones can be bought early." A locked card shows "Ch N" and its coin price (1,200 / 1,500 / 2,000 for ch04–ch06 in the frame; §7.3 range 500–2000, prices from Remote Config or Firestore) — §7.3, §7.4, frame 7.7

### Audio and haptics

- [ ] Music playback (`music_home`, `music_game`) with separate music and SFX volumes. It stays silent until the files exist. When they arrive, extend `sync_design_assets`, the pubspec and `asset_manifest_test.dart` — §11.3, tokens.json `sound.music`
- [ ] Tune the haptic patterns, including the multi-pulse success, on real devices — §11.2, PROGRESS "Notes for later milestones"

## M4 — Firebase content

Acceptance (§18): with airplane mode on first launch, the game is fully
playable. Levels published in the admin appear on the next app resume.

- [ ] Firebase init at the `TODO(M4)` in both bootstraps, failing silently offline. The owner runs `flutterfire configure` first (Q12) — §14, CLAUDE.md rule 3, `apps/game/lib/bootstrap.dart`
- [ ] Crashlytics: uncaught errors, plus non-fatals for `runGuarded` failures, the Hive fallback and level-validation failures — §14.4, D17
- [ ] `FirebaseRemoteConfigService` over the hard-coded defaults, with prices and rewards read from it — §9.4, CLAUDE.md rule 6
- [ ] `FirebaseAnalyticsService`, with every §14.4 event sent from the feature it belongs to — §14.4
- [ ] Level sync — §13.4:
  - `levels_cache.json` with `manifestVersion`.
  - Runs on launch and on resume when online, without blocking.
  - Pages of 200, each level validated, then an atomic swap.
  - Cache entries override bundled ones by `id`.
  - Never swaps the level in progress.
- [ ] Skin and theme download from Storage (`skins/{id}/v{n}/{group}.svg|png`), then rasterize and cache. The card shows a spinner (frame 7.5), and a failure keeps the current skin — §13.5
- [ ] Disk raster cache (PNG) for skin layers — §12.2, plan P3 (deferred from M2)
- [ ] PNG layer sets accepted by the game's skin loader — §12.2
- [ ] A Storage skin loader that builds `SkinLayers` from the admin's pre-split per-group SVGs (the `SkinLayers(Map)` constructor is ready) — §13.5, §14.2, r2 report
- [ ] Daily overrides from `dailyOverrides/{yyyymmdd}` — §7.5, §14.1
- [ ] Chapter, theme, skin and museum metadata (names, flavor text, prices) from Firestore — §14.1
- [ ] `connectivity_plus` to re-sync on reconnect, with its reason in PROGRESS — §13.2, §9.1
- [ ] Airplane-mode tests with failing network services, plus a fresh-install device check — §18 M4
- [ ] Install `firebase-tools` (it needs a JDK) and verify `firebase emulators:start` from `firebase/`, including the Auth emulator — PROGRESS M0 "Not verified yet"

## M5 — Admin panel

Acceptance (§18): the owner can build, solve, simulate, playtest and publish a
level, and upload a skin that then shows up in the game.

- [ ] `FirebaseAuthService` (email and password), with "Not authorized" when there is no `admins/{uid}`. Delete `UnconfiguredAuthService` — §15, `apps/admin/lib/core/services/auth/unconfigured_auth_service.dart`
- [ ] Dashboard — §15 #1
- [ ] Levels list: table, filters, search, drag reorder, and bulk publish, unpublish and archive — §15 #2
- [ ] Level editor — §15 #3:
  - Shelf builder, slot types plus ice, doll palette.
  - Live validation.
  - Solve with animated playback, and Simulate.
  - Playtest, a CustomPainter on nesty_render.
  - Save Draft (bumps `version`) and Publish.
- [ ] Generator page: the §6.5 params plus count and seed, preview cards, and accept into drafts — §15 #4
- [ ] Chapters CRUD with theme and museum assignment — §15 #5
- [ ] Skin upload — §15 #6, §12.2:
  - Split the SVG with `xml` and strip its metadata.
  - Check the group ids, the artboard and disallowed features. Reuse `package:nesty_render/svg_tools.dart` (`stripSvgMetadata`, `validateSkinSvg`, `validateSkinManifest`, the same checks the asset sync runs), and map its stable issue codes to admin ARB strings.
  - Preview all colors × sizes, including the lid lift.
  - Set price and status.
- [ ] Theme and museum-item upload with preview — §15 #7
- [ ] Daily overrides calendar — §15 #8
- [ ] Export bundle, plus a headless `export_level_bundle` in tools — §15 #9, tools/README.md. Write through `LevelBundleCodec.encodeString` and apply `nesty_levels bundle check`'s checks; when bundling moves to a Firestore export, revisit BundlePolicy's M2 layout limits (Q36) and whether `tools/levels/` stays the source of the first levels — bundle report
- [ ] Map every `LevelIssue` code and its args to ARB messages (the `field`/`expected` value sets are documented on `LevelCodec`, each code's args on `IssueCodes`, the generator's on `Generator.checkParams`) — §15, codec and generator reports
- [ ] Step long core work with `await` so the admin page never blocks: `Solver.start(...).advance(n)` for rule 8 (exhaustive proofs take 2.3 s VM / 3.5 s dart2js, Q32), a stepped `Simulator` API (up to ~90 ms per 19-slot board in dart2js) and awaits between generated levels (up to ~350 ms each in dart2js); show every attempt with `Generator.buildAttempt` — §15, solver/simulator/generator reports
- [ ] Decide Q33 and cap the admin generator's params (or scale the admin budget by board size) so a search stays under the design's 64 MB — design §5, review DETERMINISM-005
- [ ] Admin level editor and playtest preview on `DebugBoardPainter`: an adapter from a nesty_core `Level`/`GameState` to `Map<String, DebugSlot>`, and bundle Fredoka (tag and badge text) or accept the fallback font — §15 #3, r3 report
- [ ] A `nesty_levels tune` command (or an admin Generator feature) that hill-climbs a fixed skeleton (rows, tower positions and depths, empties, colors) toward a target tier by swapping nests and re-cutting sets; that is how L16–L30 were found — §6.5, §15, levels report
- [ ] Publishing batch: bump `config/manifest.levelsVersion` and `publishedCount`, and renumber `order` — §15
- [ ] Final security rules, including the Q20 gaps, with emulator-backed rules tests. The first Storage deploy must grant it Firestore access — §14.3, Q20, firebase/README.md
- [ ] Orientation and colors in `apps/admin/web/manifest.json` — Q21
- [ ] Author or generate levels 31–200 (chapters 1–10) and export the 200-level launch bundle. Follow the §3.7 schedule (locks at L31, ice at L51, maxSize 5 at L71, maxSize 6 from L121) and the §6.6 pattern — §7.1, §3.7, §13.4
- [ ] Use `json_annotation` and `json_serializable`, or remove them — PROGRESS "Package reasons"
- [ ] Acceptance walkthrough with the owner, on emulators or stg — §18 M5

## M6 — Monetization

Acceptance (§18): every §9.1 pacing rule is unit-tested with a fake clock.
Offline ad buttons fall back to coins correctly.

- [ ] Put the AdMob App IDs in `Info.plist` and `AndroidManifest.xml` before adding `google_mobile_ads` (test IDs in debug) — PROGRESS "Notes for later milestones", CLAUDE.md rule 5
- [ ] `AdMobAdsService` — §9.1, CLAUDE.md rule 5:
  - Test unit IDs in debug; real ones through `--dart-define`.
  - Preload one rewarded and one interstitial ad, and reload after each is shown and on reconnect.
  - 3 s timeout.
  - Drop `AppEnv.real` from the fake.
- [ ] Interstitial pacing, with fake-clock tests (frame 2.10) — §9.1, §18 M6:
  - None before level 8, then one every 3 wins.
  - At least 90 s since any ad, and a 5-minute session grace.
  - Off when `adsRemoved` is set.
  - Only on Win → Continue.
- [ ] Rewarded placements: booster popups (3.2, 3.3), out of moves +1 slot (3.5), win ×3 (2.8 → 2.9 "Reward added"), and the daily chest's "Double it" (5.6) — §9.1
- [ ] Offline, ad buttons switch to coin prices (frame 3.7). With no coins the button is disabled with "Connect to watch an ad" (frame 3.8). A widget test uses a no-fill fake — §9.1, §18 M6
- [ ] Home banner behind `home_banner_enabled` (default off), and no banner in gameplay — §9.1
- [ ] `StorePurchaseService` (`in_app_purchase`): the 6 products, with receipts checked on the client. Drop `AppEnv.real` from the fake — §9.2
- [ ] Shop Coins tab (7.1: Starter Pack and 3 packs; 7.2: thank-you) and No Ads tab (7.8) — §9.2
- [ ] Remove Ads offer after the 3rd interstitial (frame 7.9, `remove_ads_offer_after_interstitials`), then Home without the tile and a toast (7.10) — §9.2
- [ ] Restore Purchases in Settings, with a toast (frame 8.3) — §9.2, §17
- [ ] UMP consent before ads start, where required (frame 1.2). The Privacy choices row re-opens it (frame 8.1) — §9.3, D19
- [ ] ATT pre-prompt (8.5) and system prompt (8.6) after the first Level 3 win, with the purpose string in `Info.plist` — §9.3
- [ ] Rate prompt (`in_app_review`) after the `rate_prompt_level` win, if the player hasn't failed in the last 3 levels (frame 8.7) — §10.2 #16
- [ ] `adCounters` in the save: winsSinceInterstitial, lastAdAt, interstitialsShown — §13.3

## M7 — Art and polish

Acceptance (§18): matches the design screens, with no layout overflows on 5
screen sizes. Most of the original M7 integration moved into M2 (D23).

- [ ] Fidelity pass, screen by screen, against every App Flow frame (01–08) with `ui-designer`, then owner sign-off — §18 M7
- [ ] Overflow tests on small Android, standard phone, tall phone, small iPhone and iPad portrait, at 1.0× and 1.3× text — §18 M7, §16
- [ ] Animation polish: tune `tokens.motion` by feel, including the intro-card loops — §11.1
- [ ] Final audio: replace the placeholder WAVs, normalize levels, re-check the clack pitch offset, and add the music loops — §11.3, D19
- [ ] Integrate chapter themes 7–10, per-theme shelf and stand art, and `palette` accents once supplied — §12.4
- [ ] Translations: es, pt-BR, id, hi, de, fr, tr, ja — §16
- [ ] Accessibility audit: semantics labels, 48 dp targets, reduced motion, large symbols — §16
- [ ] Re-check `UIRequiresFullScreen` (deprecated in iPadOS 26) together with the iPad orientation decision — Q16

## M8 — Release prep

Acceptance (§18): release builds run on real Android and iOS devices with
production Firebase.

- [ ] App icons: flatten the 1024 App Store icon (App Store Connect rejects alpha), and add an Android adaptive icon and a 512 px Play icon. `sync_design_assets` doesn't copy `design/store/` (its SVG uses unsupported features), so the launcher icons are generated separately — §18 M8, audit, `design/store/icon_1024.png`
- [ ] Native splash (the Android 12 splash API and the iOS LaunchScreen) matching frame 1.1 — §18 M8
- [ ] Store screenshot support: a clean capture mode — §18 M8
- [ ] App size under 60 MB (`--analyze-size`), keeping an eye on the bundled art — §18 M8, D20
- [ ] Performance profiling on a 2 GB Android — CLAUDE.md rule 8, `/perf-profile`. Include the level-load raster time of doll layers (design budget ≤ 250 ms; host flutter_tester measured 35–67 ms for 4 heights at DPR 3), board sprites and the theme background (r2/r3 reports)
- [ ] Release configs with the ad IDs from `--dart-define`, never committed — CLAUDE.md rule 5
- [ ] Android release signing with the upload key (`key.properties` kept out of git) — `apps/game/android/app/build.gradle.kts`
- [ ] iOS profile and release builds, `flutter build ipa` and Xcode Archive. Run `flutter build ipa --flavor <f> -t lib/main_<f>.dart` first, or the D8 guard fails the build — D8, PROGRESS M0 "Not verified yet"
- [ ] Privacy policy URL in both store listings, and a final check of the Settings link — §9.3, §17
- [ ] Acceptance on real devices with production Firebase (owner) — §18 M8

## v1.1

- [ ] Golden doll rules — §3.5, D22:
  - `colorsMatch`: a nest takes the color of its non-gold dolls, and an all-gold nest matches any color.
  - At most one gold doll per level, and it counts toward its set.
  - Validator rule-4 exemption.
  - Lift the v1 rejection.
- [ ] Gold in the solver, the simulator and the generator, the L101 intro, intro card 4.8 with its "v1.1" chip, and the admin palette — §3.5, §3.7, frame 4.8
- [ ] A `Nest` model and view for a nest that holds the golden doll among other dolls; `NestCode.toNest` drops the gold today (`TODO(v1.1)` in `packages/nesty_core/lib/src/rules/engine/nest_code.dart`); accept gold in the validator (`TODO(v1.1)` in `lib/src/validator/level_checks.dart`) and decide how gold counts toward rule 4 — §3.5, D22, kernel and codec reports
- [ ] Gold levels in `test/simulator/support/sim_levels.dart`, gold in `simref.py`, and new parity values (a `Generator.version` bump) — §3.5, simulator report
- [ ] Rasterize the gold mask layers only for levels (or previews) that show gold: a gold flag through `DollRenderer.prepare` and the `SkinCache` key. Today every prepared height rasterizes them (23 % of layer bytes) — review RENDER-7

## Later (spec §19)

- [ ] Weekend events with special skins — §19
- [ ] Cloud save through anonymous Auth — §19, §13.2
- [ ] Server-side receipt verification (Cloud Functions) — §19, §9.2
- [ ] Ad mediation (AppLovin MAX or ironSource) — §19, §9.1
- [ ] Relaxed mode with unlimited undo — §19
- [ ] Seasonal skins — §19
- [ ] True 3D renderer behind `DollRenderer` once Flutter GPU is stable — §19, §12.6
- [ ] Level-sharing code for friends — §19
- [ ] Data-driven playable colors. It is a spec change, so `DollColor` stays a fixed enum — D19, design/README.md "Decisions to confirm" 6
- [ ] About 20 new levels a week from the admin after launch — §7.1
- [ ] Solver and simulator speed, only if needed (Q32, or a generator p95 over 5 s): hash only the changed key words, pack two codes per word, and a count-only kernel routine for the bots (`Kernel.collectLegalMoves` is ~23 % of an exhaustive search and most of the casual bot's cost) — design §5, solver/simulator/prng reports
- [ ] Symbol atlas pages rasterize only the active symbols mode, if memory matters (both sizes cost ≈0.24 MB per height at DPR 3) — r2 report
- [ ] Theme background on tablets: 768×1024 @2 is 12.6 MB; cap the raster at the art's native pixel count or lower the pixel ratio on large screens if the iPad budget matters — r3 report

## Owner inputs needed

Content, assets, accounts and decisions only the owner can supply. Each item
names the milestone it blocks.

### Content and assets

- [ ] Music: `music_home` and `music_game`, seamless loops of 60–90 s. The handoff has none — §11.3 (M3, M7)
- [ ] Optional: final SFX to replace the 17 placeholder WAVs — §11.3, D19 (M7)
- [ ] Flavor text for 9 figurines. Only the Sailor Family has one — §7.2, frame 6.2 (M3)
- [ ] Names and background art for chapters 7–10. Only ch01–ch06 exist — §7.1, §12.4 (M3, M7)
- [ ] Shelf plank, stand art and palette JSON for each theme, or confirmation that every theme shares the board art — §12.4 (M7)
- [ ] Store art — audit, docs/DESIGN_BRIEF.md Prompt 12 (M8):
  - Re-export the store SVGs (`design/store/icon.svg`, `open_doll.svg`). They use nested `<svg>` and mix-blend-mode, which flutter_svg can't render.
  - A 1024 icon without alpha, and adaptive icon layers.
  - Play feature graphic (1024×500).
  - 6 screenshots (1290×2796).
- [ ] Distinct dev and stg icons, if Q17 says yes (M8)
- [ ] Admin panel designs. The handoff has none, and the admin placeholders point at `design/admin/*.png` — docs/DESIGN_BRIEF.md Prompt 14 (M5)
- [ ] Privacy policy URL and support email address — §9.3, §17, frame 8.1 (M3, M8)

### Design gaps

These states have no design yet. Until they do, build them in the design's
system and mark them `TODO(design)`.

- [ ] L1 tutorial third step (Cherry 1 into the nest) — §7.6, frame 1.4 (M3)
- [ ] Out-of-moves Undo row once the free undos are used — frame 3.5 (M3)
- [ ] +Slot at its limit (2 used this level) — §3.6 (M2)
- [ ] Extra slot when the bottom shelf is full — §3.6, D22 (M2)
- [ ] Boards with 1 shelf, 4 shelves or 5 slots per shelf — §2.1, §5.3 (M2). Built by scaling (D36): the 1-shelf preset (plank 540, Hs 150) and the 4-shelf preset (planks 250/395/539/684, Hs 104, every slot piece × 104/150), both `TODO(design)` in `packages/nesty_render/lib/src/board/shelf_presets.dart`; 5–6-slot rows shrink stands, pips, tag, glow, glass, ice, hint arrow, tower raise and (review RENDER-3) the dolls (`TODO(design)` in `board_layout.dart`)
- [ ] The board-wide doll clamp (`h·2/3 ≤ minPitch − 8/3`) for maxSize 6 on 3 shelves, maxSize 3 on 3 shelves or 4-slot rows (M2 levels 3–9) and 5–6-slot rows needs a design sign-off (`TODO(design)` in `board_layout.dart` `_dollHeights`) — D22, D36 (M2)
- [ ] A doll sealed in a glass case is taller than the case at maxSize ≥ 5 (the design's own maxSize-5 doll is 6 dp above it, NestyBoard:169) and wider at maxSize 6; on a 4-shelf board a top-row maxSize-6 doll (sealed, or on a tower) reaches ~2–6 dp above the frame — r1 report, review (M2)
- [ ] Top-shelf towers: the D21 18 dp step per buried nest shrinks so the deepest silhouette stays under the HUD (`TODO(design)` in `board_geometry.dart` `buriedBaseY`); and a buried nest two or more sizes smaller than the top stays hidden at 18 dp per depth (Q38) — D21, review RENDER-4 (M2)
- [ ] A designed look for the procedural fallback doll (spec §12.5; `TODO(design)` in `packages/nesty_render/lib/src/doll/placeholder_doll_painter.dart`) — r2 report (M2)
- [ ] Looping animations for the intro cards — frames 4.1–4.3 (M3)
- [ ] Home with a Super Hard level, in bonus mode, and with a streak of 0 — frame 2.1 (M3)
- [ ] Win card in bonus mode — frame 2.8 (M3)
- [ ] Streak lost — §7.5 (M3)
- [ ] Ad loading, ad failed and ad timed out — §9.1 (M6)
- [ ] Purchase failed and purchase pending — §9.2 (M6)
- [ ] Restore found nothing — §9.2 (M6)
- [ ] Starter Pack already owned, and the No Ads tab once ads are removed — frames 7.1, 7.8 (M6)
- [ ] Skin or theme download failed, and the Shop offline — §13.5, frame 7.5 (M4)

### Copy to confirm

- [ ] ATT pre-prompt: "you can change it later in Settings" should say iPhone Settings — frame 8.5, §9.3 (M6)
- [ ] Remove Ads offer: "Restore it on any device" only holds for devices on the same store account — frame 7.9, §9.2 (M6)
- [ ] BEST VALUE is on the 4,000 pack, but 9,000 for $9.99 is the better value per coin — frame 7.1, §9.2 (M6)
- [ ] Casing: "Restore Purchases" (8.1) vs "Restore purchases" (7.8) — frames 8.1, 7.8 (M6)
- [ ] Settings footer "Player ID": the spec has no player id. Use a local random id, or drop it — frame 8.1, §13.3 (M3)

### Accounts and compliance

- [ ] AdMob account, app IDs and real ad unit IDs, supplied through `--dart-define` at build time — CLAUDE.md rule 5 (M6, M8)
- [ ] Link AdMob to Firebase for ad revenue data — §14.4 (M6)
- [ ] Create the 6 §9.2 products in Play Console and App Store Connect — §9.2 (M6)
- [ ] App Privacy and Data Safety forms, the target-audience declaration, and a legal check — §17 (M8)
- [ ] Production Firebase project and signing material (upload keystore, Apple certificates) — §18 M8 (M8)

### Decisions

- [ ] Q3: the save document in Hive or in the atomic JSON file? (blocks M3 save)
- [ ] Q5: add a `reward_medium` key, or have medium read `reward_easy`? (M3)
- [ ] Q6: return to the originally requested admin deep link after the first sign-in? (M5)
- [ ] Q7: hash or path URLs for the admin? (M5)
- [ ] Q10: confirm the bundle id `com.futrix.nesty` (plus `.dev`, `.stg`) before any store upload (M8)
- [ ] Q11: is `Z674BG8G6U` the right Apple team? (M8)
- [ ] Q12: how many Firebase projects? Then run `flutterfire configure` (M4)
- [ ] Q16: should iPad be upright-only? (M7)
- [ ] Q17: distinct dev and stg icons, and a `versionNameSuffix`? (M8)
- [ ] Q20: tighten the §14.3 rules sketch? (M5)
- [ ] Q23: stay on Flutter 3.41.2 or upgrade, which would lift the auto_route pin (B1)? And drop the stray local SDK commit?
- [ ] Q24: relax the `rm -rf` deny globs in `.claude/settings.json`?
- [ ] Q25: name the D14 exception in CLAUDE.md rule 10?
- [ ] Q27: commit the Gradle wrapper?
- [ ] Q28: localize the app title players see?
- [ ] Q29: tabular numbers in Fredoka: a fixed-width digit widget, Nunito for numbers, or a patched "Fredoka Tabular" build in `build_fonts.sh` (the OFL allows modified builds under a new name)? (M2)
- [ ] Q30–Q38: the M1 and render decisions to confirm (towerless grading, expert-only generated levels, solver targets, admin memory, the curve table, the recorded defaults, bundle policy, authored levels, render defaults). Q31, Q34 and Q35 before M3 (M1/M3)
- [ ] Update GAME_SPEC.md for this round's deviations, or keep them recorded only in PROGRESS? They are §2.2 tap policy (D22), §3.6 extra-slot placement (D22), §13.5 bundled art (D20), and the §12.3/§13.3 symbols value (Q4) — D19–D22

## Tech debt

- [ ] Extract the duplicated base layer into a shared package — D6, Q8
- [ ] Optional: use the same error-key names in both apps — Q26
- [ ] The hooks guard only Write, Edit and MultiEdit, so a Bash redirect bypasses `block-secrets` and `block-generated` — PROGRESS "Review pass"
- [ ] No test covers the bootstrap zone handler's `FlutterError.reportError` — PROGRESS "Review pass"
- [ ] `runGuarded`'s debug prints add noise to test output — PROGRESS "Review pass"
- [ ] Watch CI's first GitHub run on `ubuntu-latest`: the Linux-only `grep -z` and `xargs --no-run-if-empty` format step, `setup-java`, shellcheck, and the APK build of `flutter_soloud`'s native code (it needs the NDK and CMake on the runner; only built locally so far) — PROGRESS M0 "Not verified yet", PROGRESS "Package reasons"
- [ ] The VS Code launch configs are untested — PROGRESS M0 "Not verified yet"
- [ ] Revisit `flutter_gen` now that assets exist, or keep hand-written asset paths (`sync_design_assets` owns the files, not typed accessors) — D3
- [ ] `hive_ce_generator` produces nothing. Keep it or drop it once Q3 settles the save — PROGRESS "Package reasons"
- [x] Refresh the root README.md: it still says `design/` is not in the repo, and it doesn't list `tools/` — README.md (done 2026-09-26: status, layout, tools commands, native build prerequisites)
- [ ] Refresh the `code-explorer` map after M1 and M2. It says only `DollColor` exists; M1 core and the nesty_render API (D27, D36–D38) are now built — `.claude/agents/code-explorer.md`
- [ ] Make the Stop hook (`.claude/hooks/test-on-stop.sh`) run `dart test -x slow` in nesty_core now that the slow M1 acceptance test exists (owner's hook config) — design §5, contracts report
- [ ] `.claude/hooks/block-generated.sh` doesn't yet block hand edits of `apps/game/assets/levels/bundle.json` (a `nesty_levels bundle build` output; CI's `bundle check` catches drift) — tools/README.md, D25, bundle report
- [ ] Commit the kernel/facade and PRNG/Hash64 micro-benchmarks in `packages/nesty_core/benchmark/` (scratch numbers: kernel copy+apply 45 ns, `collectLegalMoves` 97 ns, `Rules.tryMove` 0.4 µs; `nextU32` 9 ns, `derive` 50 ns VM / 70 ns node, a 24-cell key hash 116 ns), with dart2js numbers — design §5, kernel and prng reports
- [ ] Share one doll base constant: `DollArt.base` (256, 742) in nesty_render's doll code and `BoardLayoutConstants.dollArtBaseY`/`dollArtHeight` (742/768) in the layout — r2 report
- [ ] `test/simulator/bots_test.dart` reuses the kernel step's `test/rules/support/boards.dart` helpers; keep them stable or copy them — simulator report
- [ ] Upgrade `flutter_soloud` to 5.x together with the SDK and CI pin (5.x needs `meta` ^1.19; Flutter 3.41.2 pins 1.17.0) — Q23, PROGRESS "Package reasons"
- [ ] `AppGradientTokens.gold` (115°) maps the CSS angle to `Alignment` exactly only for square boxes. If it paints non-square boxes, resolve begin/end from the box's aspect (180° gradients are exact everywhere) — `tools/lib/src/tokens/ui_tokens_codegen.dart`
- [ ] The TODO scanner finds comments heuristically: a string literal containing `//` or `#` followed by a marker is indexed too — `tools/lib/src/todo/todo_scanner.dart`
- [ ] `tools/pubspec.yaml` declares `xml` but uses it only through `svg_tools.dart`. Use it directly (level tools) or drop it after P3 — PROGRESS "Package reasons"
- [ ] The icon font's name table still says "Material Symbols Rounded" (Flutter uses the pubspec family `NestySymbols`, so it's cosmetic). Rename it in `build_fonts.sh` if it ever shows up in a font picker or licence page — `tools/fonts/build_fonts.sh`

## Closed questions

Kept for traceability. Q9 and Q19 are answered by M1 items above.

- [x] Q1: auto_route pinned at 11.1.0 — B1, D12
- [x] Q2: CLAUDE.md updated for the aquabuildr stack — D1
- [x] Q4: the symbols value `large` replaces `assist` — D19 (done 2026-09-26)
- [x] Q13: CI pins Flutter 3.41.2 — D15
- [x] Q14: fonts are bundled as assets and sourced by tooling — D18 (done 2026-09-26)
- [x] Q15: design exports delivered — D18 (done 2026-09-26)
- [x] Q18: tower nests show their true size with the color hidden — D21 (done 2026-09-26)
- [x] Q22: the fake-services admin launch config was added — PROGRESS Q22
