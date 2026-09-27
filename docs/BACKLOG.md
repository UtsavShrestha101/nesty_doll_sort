# Backlog — Nesty: Doll Sort

This is the single curated checklist of all remaining work, with one section per
milestone (spec §18). [PROGRESS.md](PROGRESS.md) records what was done and why.
This file records what is left. In-code markers are indexed separately in
[TODO_INDEX.md](TODO_INDEX.md), which `dart run nesty_tools:todo_index` generates from
`TODO(<tag>)` comments. Never edit it by hand.

Last updated: 2026-09-27 (M1 closed; M2 code complete after the review fix pass, its acceptance waiting on the owner's 60 fps device check and the manual L1–30 pass; the post-M2 round landed Claude Design v3 and the music and jingles).

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
  - `lottie §n` is section n of [plans/m2-lottie-design.md](plans/m2-lottie-design.md),
    the authoritative M2 phase-4 design (D40–D52). `re-export` is
    [plans/lottie-reexport-request.md](plans/lottie-reexport-request.md).
  - `audio An` is step An of [plans/audio-integration.md](plans/audio-integration.md),
    and `audio plan` is [plans/audio-analysis/plan.md](plans/audio-analysis/plan.md).
  - `v3` is [plans/claude-design-v3-check.md](plans/claude-design-v3-check.md),
    the check of Claude Design's v3 Lottie export (its points 3a–3f are in
    [plans/claude-design-v3-changes.md](plans/claude-design-v3-changes.md)).
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

## M2 — Playable game — code complete; acceptance pending (2026-09-27)

Acceptance (§18): levels 1–30 can be played start to finish at 60 fps on a
mid-range Android device. The scope grew: the design's art, tokens, SFX and
haptics were pulled in from M3 and M7 (D23).

Status on 2026-09-27 (PROGRESS "M2 acceptance"): every automated gate passes.
What is left is the owner's: the 60 fps profile on a real device (the perf
profile item under "Lottie lanes" and the acceptance item) and the manual
L1–30 pass. The other leftovers moved to M5, M7 and the design gaps, each
marked there.

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

### Phase 4 contracts (Lottie)

- [x] Phase-4 contracts stage — lottie §1–§17 (done 2026-09-26, D40–D52):
  - The authoritative design `docs/plans/m2-lottie-design.md` and the designer's re-export request.
  - `lottie: 3.6.1` pinned exactly (D41).
  - The frozen contracts: `features/fx/{fx_id,fx_spec,fx_cue,fx_image_source,fx_library,fake_fx_library}.dart`, the `DollPartRasters`/`DollPartSet` API in nesty_render, and `features/gameplay/bloc/{board_effect,gameplay_event,gameplay_state,gameplay_bloc}.dart`.
  - The service interfaces: `AudioService.play(…, dollSize:, comboStep:)`, `HapticPattern` + win/unlock/iceCrack/button, `SolverService`, `SkinService`/`LevelSkin`, `LevelRepository.entryAt`, with fakes.
  - Contract tests.
- [x] Name the game's `BoardEffect`s so they don't clash with core's exported `MoveApplied`/`MoveRejected`/`Completed`/`Won`/`Placed` (or import core with a prefix) — D27 (done 2026-09-26: the `…Effect` suffix, D52)

### Lottie lanes (lottie §16; stage B, then C, then the integrator)

- [x] **Tools:** `sync_design_assets` copies `design/lottie/*.json` (never `images/`, never LOTTIE.md) to `apps/game/assets/lottie/`, and declares the folder in the pubspec — lottie §16, D50 (done 2026-09-26: 29 files byte for byte, validated on sync and `--check`; `gen_fx_spec` + `fx_spec.gen.dart`, drift-checked in tools, the game and CI; the asset manifest test). Plus:
  - Validation on sync and `--check`: parses; v5.7; `fr` 60; w/h/op and markers match the contract table; asset ids ⊆ `FxImageSlot`; named nulls and fills present. Forbidden features blocked (expressions, effects, merge paths, luma or inverted mattes, `tp`, 3D, time remap, embedded images); trim paths and polystars stay allowed.
  - `fx_spec.gen.dart` (`fxSpecs`, `fxSpecOf`) generated with holds and image layers, plus the drift test and a CI step.
  - The asset manifest test: all 29 files ship and parse with `LottieComposition.fromBytes`, and no PNG ships.
- [x] **Render:** `DollPartRasters.prepare`/`preparePlaceholder` — lottie §4, D45 (done 2026-09-26: the split on a whole pixel row (`splitRowPx`), parity 100 % within 8/255 outside 388–412; `SymbolRaster` for the unlock symbol):
  - full-artboard lid (y < 400), body (y ≥ 400) and silhouette (shadow included); gold from the rewritten masks; symbols modes;
  - `PartRasterDollRenderer` for rest sprites;
  - `BoardFit.toReference` and the board-space origin; a crop-offset accessor on `BoardSpriteImage`; an ink-tinted unlock-symbol raster;
  - tests: split alpha, parity outside 388–412, gold, symbol modes, budgets.
- [x] **FX runtime** — lottie §2, §3, §6, §12, §14 (done 2026-09-26: runtime types `FxDrawable`/`FxRange`/`FxLayout`/`FxDrawableParams`, D53; 283 fx tests):
  - `AssetFxLibrary` (`fromBytes`, spread over frames at splash, failures logged); drop `AppEnv.real` from `FakeFxLibrary`.
  - `fx_player.dart`: pure segment, loop, speed and clamp maths.
  - `fx_delegates.dart`:
    - image-slot compensation, including the animated-scale callback;
    - `<role>_size`, `rim_tint`, `tint`;
    - the travel remap with the hold anchor fix;
    - the padlock hide at rest, the glass settle ramp, the reveal silhouette hide;
    - reduced-motion shake removal;
    - text hiding and null capture.
  - `LottieFxComponent` (Flame, `FrameRate.max`, medium filter), `LottieFxView` (widget), `fx_text_overlay.dart`, `fx_pool.dart`.
  - Compensation equivalence tests for every image layer.
- [x] **Services:** `AssetSkinService` + `LevelSkin` + the `FxImageSource` implementation over `DollPartSet`, `BoardSprites` and the unlock symbols. The placeholder fallback; re-prepare after a re-pitch — lottie §4, §16. This replaces the `SvgSkinRenderer`/`SkinCache` wiring of the item below. (done 2026-09-26: `AssetSkinService`, `LevelSkinImages` (the `FxImageSource`), placeholder fallback chain)
- [x] **Hand-coded gap motions** — lottie §9, D40 (done 2026-09-26: the timeline's tweens and `WinOverlaySchedule`; the settle is the FX runtime's position delegate):
  - the D21 reveal drop and the deeper silhouettes' shift (120 ms);
  - the 11 dp glass settle;
  - the case, ice and silhouette shake;
  - drag cancel and drag invalid;
  - the 300 ms re-pitch;
  - tag and badge counts;
  - the win coin count-up.
- [x] **Locked and iced slots as paused `fx_glass_unlock`/`fx_ice` compositions,** with a cached rest `Picture` — lottie §8, D51 (done 2026-09-26: `SlotComponent`, tested on fixture boards):
  - rest frames (glass 0 with `padlock_ping` hidden; ice `16 × iceFrame`);
  - locked and iced together;
  - static `BoardSprites` fallback.

  Last in the Flame lane: locks start at L31 and ice at L51.
- [x] **Reduced motion** (`MediaQuery.disableAnimationsOf`) through `MotionSpec` and the FX delegates — lottie §13, D48 (done 2026-09-26: `MotionSpec`, the FX delegates and the widgets):
  - one-shots at half duration;
  - no shake, confetti or wobble;
  - ambient loops paused on frame 0;
  - informational loops at 1×.
- [ ] **Perf profile on a 2 GB Android** in profile mode: Complete + sparkles + dust, Win, and the splash parse (R11); also a board with several paused glass/ice compositions (cached pictures), flutter_soloud's per-play allocation (see Tech debt), and the page layers now that every widget Lottie has its own repaint boundary (review PERF-RULES-1). Owner's device; the steps are in PROGRESS "M2 acceptance" — lottie §14, CLAUDE.md rule 8, board and services reports

### apps/game

- [x] `AppTheme` from the generated tokens (Nunito body, Fredoka display) and the tactile component set from the README "Components" table. It replaces the placeholder `AppColors` — D4 (done 2026-09-26: `AppTheme`, `core/ui/nesty_ui.dart`; the prototype-only colours are listed under Owner inputs)
- [x] All handoff copy goes through ARB — §16, CLAUDE.md "Code style" (done 2026-09-26 for M2: 62 new keys, each with a description; later milestones add theirs)
- [x] Icons come from `NestyIcons.*` (the bundled `NestySymbols` subset), never `Icons.*`, in the HUD, booster bar, sheets and menus. To add a glyph, list it in `tools/fonts/nesty_symbols.txt` and run `tools/fonts/build_fonts.sh` — design/README.md "Typography & icons", tools/README.md (done 2026-09-26: no `Icons.*` in `apps/game/lib`)
- [x] `SoLoudAudioService` behind the frozen `play(effect, {dollSize, comboStep})`, with the fake kept for tests and `AppEnv.fake` (drop `AppEnv.real` from `FakeAudioService`; moved from M3: the SFX were pulled into M2, D23) — §11.3, D19, `apps/game/lib/core/services/audio/fake_audio_service.dart` (done 2026-09-26: `SfxEngine`/`SfxMix`; the clack rate is precomputed per size):
  - Preloads the 17 SFX and picks a random clack variant.
  - Plays clacks at `2^(−2(size−3)/12)`, which offsets the +1 semitone baked into the files. `SoundTokens.clackSemitonesBySize` holds the design's target, so the rate is `2^((semitones − 1)/12)`.
  - Plays combo `complete_1..5`, obeys the settings, and fails silently.
- [x] Haptic patterns from tokens (`HapticPattern` has all eight since the contracts stage; `SystemHapticsService` still plays single impacts, `TODO(M2)`): success = medium, then light @80 ms; soft error = light twice, 60 ms apart. `IceShattered` has none (D49) — §11.2 (done 2026-09-26: `HapticPatterns` with an injectable delay; a setting turned off mid-pattern stops it)
- [x] `IsolateSolverService` behind the frozen `SolverService` (a long-lived worker where the latest request wins; superseded or failed requests complete with null; the fake runs synchronously and serves both environments until then) — CLAUDE.md rule 8, lottie §11. Use `SolverSnapshot.start(snapshot, task, budget, requestId:)` and `SolverTask.advance(2000)` with an await between chunks, then map `task.result` with `SolverSnapshot.readHint`/`readVerdict` (solver report) (done 2026-09-26: one worker, 2000-node chunks, latest wins, gives up after 3 failed spawns or crashes)
- [x] `BundledLevelRepository`: `rootBundle` → `LevelBundleCodec` + `Validator`, skipping invalid levels with a log, with `entryAt(order)` and `levelCount` (frozen interface). Drop `AppEnv.real` from the fake and give the fake env 3 fixture levels — §13.4, §5.3, `apps/game/lib/core/repository/fake_level_repository.dart` (done 2026-09-26: an invalid level makes `entryAt` return the next playable one (Q43))
- [x] In-memory `SaveService` for M2: current level, coins, a booster wallet (3 hints, 2 slots) and free undos from Remote Config. Unlimited boosters in the dev flavor — §8, §18 M2 (done 2026-09-26: `InMemorySaveService` with the wallet API; `FakeSaveService` extends it)
- [x] `SymbolsMode.large`, which also reads the legacy `assist` value — Q4, D19 (done 2026-09-26)
- [x] `SkinService` for the selected skin and the bundled skins, behind the frozen `SkinService`/`LevelSkin` — §7.4, lottie §4. Wiring (done 2026-09-26: `AssetSkinService`; the Flame board ensures the glass frames about 1.3 s ahead and releases them after the last case):
  - one `SkinRasterizer` for the selected skin, one `SymbolAtlas.load(rootBundle)`, one `BoardSpriteLibrary.load(rootBundle)` and one `DollPartRasters` cache per app;
  - `prepareForLevel` builds the level's `DollPartSet` (the colours present, at `artHeightPxFor(maxDollHeight, dpr)`), a `BoardSprites(library)` `prepare(geometry, devicePixelRatio:, also: {extraSlot while +Slot is usable, the ice frames present})` and the unlock symbols, behind the route transition. Run it again after an extra-slot re-pitch;
  - the `FxImageSource` implementation, and `PartRasterDollRenderer` as the rest renderer;
  - `ensure(glassCase1/2)` about 700 ms before an unlock clip; `release` the glass frames after the last case shatters;
  - one `ThemeBackground(bundle: rootBundle)` shown from the gameplay page's LayoutBuilder;
  - the fake env uses `PlaceholderDollPainter()` and no images (`FakeSkinService`, both environments until then).

  (The earlier `SvgSkinRenderer`/`FallbackDollRenderer`/`SkinCache` wiring is superseded by D45.)
- [x] ~~Nest animations draw the documented `DollPart` passes~~ — D37, D38, review RENDER-1/6 (dropped 2026-09-26: `doll_nest`/`doll_swallow` draw the nest, and rest sprites use the part rasters, D40, D45)
- [x] Towers: pass the tower's starting buried count to `SlotGeometry.buriedBaseY(depth, buried:)` so the spacing stays put as it empties — D36, review RENDER-4 (done 2026-09-26: `SlotView.buriedAtStart` in the Flame board)
- [x] `GameplayBloc` handlers on the frozen skeleton (`BaseAsyncBloc`, FIFO, owning `GameSession`; `GameplayStarted` is done) — §2.2, §2.3, D22, lottie §11 (done 2026-09-26: plus `tap_policy.dart`, `win_reward.dart`, `NextLevelPressed` and `GameplayStatus.allLevelsDone`):
  - The design's tap and drag policy, and `BoardEffect`s.
  - Stale solver results are dropped.
  - The soft-stuck check is debounced after each move.
- [x] Flame tree — §13.1, CLAUDE.md rule 10, lottie §5, §8, §10, §14. It reconciles from the new state after each batch (done 2026-09-26: `NestyGame`, `BoardComponent`, `ShelfLayer`, `SlotComponent`, `NestComponent`, `FxLayer`, `HintLayer`):
  - `BoardComponent`: tap and drag, hit testing through BoardGeometry, the drag position clamped to the board frame.
  - `ShelfLayer`.
  - `SlotComponent`: paused glass/ice compositions and the ice badge.
  - `NestComponent`: rest sprites from `LevelSkin.restRenderer`, silhouettes and tags.
  - `HintLayer`: `ui_hint_arrow`, the dashed arc, the target glow.
  - A pooled `FxLayer` placing clips through BoardFit.
  - Same-frame sprite ↔ clip hand-offs.
- [x] `BoardTimeline`, the Lottie wiring. Pure Dart: it imports only `FxSpec`/`FxCue`/`FxTiming`, core and the render geometry — §11.1, §16, lottie §7, D40 (done 2026-09-26: pure Dart, 86 tests pin the §7 times):
  - Every effect and `MoveEvent` starts its files per the lottie §7 table: pick/glow segments, `doll_move` to the target or hover point, `doll_nest`/`doll_swallow`, `doll_reveal`, `doll_complete` with dust, a 60 ms sparkle trail and the counter bump at t0 + 1250, `fx_glass_unlock`/`fx_ice` from t0 + 700 with an 80 ms stagger, `doll_invalid`, the hint, +Slot, and Won at the batch end + 250.
  - Cues come from the files' frames: clack + nest haptic @537, bonk @180, `complete_{step}` @t0.
  - Input reservations per slot and a global lock.
  - A combo tracker (4 s, max 5, injected clock).
  - A clip whose file failed to load still fires its cues.
- [x] Gameplay screen (frame 2.2) — §10.2 #3/#6 (done 2026-09-26):
  - Theme background.
  - HUD: pause, level pill with tier, coins, family counter.
  - Booster bar with count badges.
  - Soft-stuck banner (frame 3.4) with a glowing Undo.
- [x] Win overlay (frame 2.8) — §10.2 #4, lottie §7, §12, D47 (done 2026-09-26):
  - scrim;
  - `fx_confetti`;
  - `ui_win_ribbon` with Flutter text;
  - families hopping with `doll_win_hop` (150 ms stagger);
  - `fx_coin_burst` and the coin count-up at 700 ms;
  - `fx_twinkle`;
  - a basic chapter card.

  The ×3 button stays hidden until M6.
- [x] Out-of-moves sheet (3.5), Pause (3.9: the Sound/Music/Haptics toggles on `ui_toggle` `on`/`off`, the Settings tile disabled until M3), hint (3.1), extra slot added (3.6, `ui_extra_slot`) and next level (2.11) — §10.2, lottie §15 (done 2026-09-26: Continue loads the next level in the same page, Q49)
- [x] Family counter on `ui_family_counter`, with its text hidden and a Flutter `TextPainter` following the `counter` null (swaps at frame 6). The soft-stuck Undo glow on `ui_booster_glow`. Static fallbacks when a file fails — lottie §12, D44, R10 (done 2026-09-26)
- [x] New-chapter ribbon `ui_chapter_ribbon` on a chapter's first level, fading after about 2 s; L21 opens ch02 (moved from M3: L21 is in M2's 1–30, D40) — frame 4.7, lottie §12 (done 2026-09-26: the Lottie's one-line ribbon, Q50)
- [x] All-levels-done screen with the frame 4.9 copy. Bonus generation is M3 — §10.2 #15 (done 2026-09-26)
- [x] Splash (frame 1.1: wordmark, `ui_splash_loader` driven by the `FxLibrary.load` + `SkinService.load` progress, 3 `doll_idle` dolls, `fx_twinkle`) and Home hero (frame 2.1: coin pill, wordmark, gear, 5 `doll_idle` dolls with a seeded speed of 0.8–1.2 and a random phase, PLAY with Level N and the tier badge) — §10.2 #1/#2, lottie §15 (done 2026-09-26)
- [x] Dev-flavor level picker — plan P4 (done 2026-09-26: "Jump to a level" on Home, dev flavor only)
- [x] 30 authored levels in `tools/levels/authored/`, built into `apps/game/assets/levels/bundle.json` by `nesty_tools bundle build`. L1 and L2 are the tutorial boards; ch01 is levels 1–20 and ch02 is 21–30 — §18 M2, §3.7 (done 2026-09-26, D35)
- [x] Declare `assets/levels/` in `apps/game/pubspec.yaml` in the same change that adds `bundle.json` — CLAUDE.md rule 3, `apps/game/pubspec.yaml` (done 2026-09-26)
- [x] Extend `apps/game/test/core/assets/asset_manifest_test.dart` to assert that `assets/levels/bundle.json` ships and decodes with `LevelBundleCodec` without issues — CLAUDE.md rule 3 (split from the item above) (done 2026-09-26)
- [x] Run `nesty_tools bundle check` in the CI drift job (moved from Design foundation: no bundle existed yet) — plan P1, `.github/workflows/ci.yaml` (done 2026-09-26)
- [x] `nesty_tools bundle check` — §3.7, §6.6 (done 2026-09-26; towerless levels keep their tier by `tierOverride`, D26, Q30):
  - All 30 levels are valid and solvable.
  - The simulated tier equals the declared tier.
  - The §3.7 schedule holds (maxSize 4 at L10, towers at L16), and so does the §6.6 pattern.
- [x] Game tests — CLAUDE.md "Testing" (done 2026-09-26: 903 game tests; `test/app_flow_test.dart` runs Splash → Home → PLAY → the board taking a tap → Pause → Home):
  - Bloc: select, cancel, invalid, move, drag, undo, restart, hint, stale hint, soft stuck, extra slot ≤ 2, win, out of moves.
  - Timeline cue times.
  - Widgets: HUD, booster bar, sheets, win, pause.
  - Services: audio pitch, combo and settings gate; haptics; bundle repository; asset manifest.
  - The app flow.
- [x] Builds: APK dev/stg/prod, iOS dev/prod (no codesign), admin web — CLAUDE.md "Commands" (done 2026-09-26: see PROGRESS "Verification (2026-09-26, integration)")
- [x] On-device playthrough `apps/game/integration_test/playthrough_test.dart` with its `flutter drive` driver `test_driver/integration_test.dart`: the dev flavor with every real service plays L1 and L2 to the win overlay and L16 into Out of Moves, then Pause → Home, tapping slot centres laid out by `BoardLayout`, and saves 18 screenshots. Passes on the iPhone 16 simulator (iOS 18.3) and an API 35 emulator. The iOS flavor guard now accepts an `integration_test/` target in `Debug-<flavor>` only (D8 amended) — plan "Verification" (done 2026-09-26, D57)
- [x] Review fix pass: 12 of 13 findings fixed, each with a regression test (next-level art prefetched during the win overlay; a reset ends a drag; a drop while paused puts the doll down; a queued second re-pitch; the counter's landing sparkle; the won chrome locked, not greyed; Home keeps its showcase art; Home past L30; soft stuck without undo suggests Restart; repaint boundaries per widget Lottie; a cached label origin; the percent semantics). FIDELITY-3 went to the owner (Q59) — PROGRESS "M2 review and fix pass", D58 (done 2026-09-27)
- [x] Retag the four `TODO(M2)` markers: the unlock-symbol raster to M5, the tabular figures to M7 (Q29), the load-failure copy to `TODO(design)` — CLAUDE.md "Workflow" (done 2026-09-27; `TODO_INDEX.md` has no M2 marker)
- [ ] Play L1–30 by hand on the dev flavor (iOS simulator and an Android emulator) and compare with frames 2.2–2.8, 3.1, 3.4–3.6 and 3.9. Check that L16's 4,3 board reads as the tower intro and that the towerless L6 (HARD) and L10 (SUPER HARD) badges feel right (Q37, D26). The automated playthrough covers L1, L2, L9 (hint and two extra slots), L16 (a tower reveal) and L21 (the chapter ribbon) only — plan "Verification"
- [ ] Acceptance: 60 fps on a real mid-range Android in a profile build. The owner runs it on their device with `/perf-profile`, following the steps in PROGRESS "M2 acceptance", and records the numbers there — §18 M2, CLAUDE.md rule 8

### Post-M2 round: Claude Design v3 and audio (2026-09-27)

Claude Design's audio export and v3 Lottie overlay, imported together after
M2 was committed (PROGRESS "Post-M2 round", D59–D61).

- [x] Import `design/` in overlay order (repo ← audio export ← v3), hash-identical to the checked staging; `export/` removed; the designer's notes and our analyses under `docs/plans/` (audio-integration.md, claude-design-v3-changes.md, claude-design-lottie-audio-prompt.md, claude-design-v3-check.md, audio-analysis/) — v3 import plan 1 (done 2026-09-27)
- [x] Tools for LOTTIE.md v3: the contract table (3× board pieces, `doll_reveal` 31 f with the `drop` null, `fx_ice` 150 f with `rest_n` and `crack_hit_n`, 410-wide ribbons, the six parent nulls); the validator's `hold` and `imageTransform` checks; `fx_spec.gen.dart` regenerated — v3 import plan 2, D59 (done 2026-09-27)
- [x] Audio A1: map the new `sound` token leaves (`jingleFiles`, `musicFiles`, `clackBakedSemitones`, `music.*` with the frames check, fades, ducks, `jingleBus`; `music.*.screens` documented) — audio A1 (done 2026-09-27)
- [x] Audio A2: sync the 5 OGG files, skip AUDIO.md, validate the WAV and Ogg Vorbis formats and the loop lengths; the manifest test and tools/README — audio A2 (done 2026-09-27)
- [x] Audio A3: SFX v2, the clack rate from `SoundTokens.clackBakedSemitones` (0); the placeholder `TODO(M7)` markers removed — audio A3, D61 (done 2026-09-27)
- [x] Audio A4: one `SoLoudEngineHost` (low latency in prod only), `JinglePlayer` on the SFX bus, `MusicService` + `SoLoudMusicService` + `FakeMusicService` (lazy `loadMem` disk, protected voices, crossfade, lowest duck wins, pause reasons, `musicEnabledChanges`, lifecycle) — audio A4, audio plan §3 (done 2026-09-27)
- [x] Audio A5: `MusicRouteObserver`, `MusicDuck` around Win (0.3), Out of moves (0.4 + `jingle_oom`) and Pause (0.5); Pause's toggles write the settings only; iOS `.ambient` (Q61) — audio A5 (done 2026-09-27)
- [x] Audio A6: fake-clock music tests, engine-host and SFX-engine tests, observer, `MusicDuck` and `JingleCues` tests, and the music in `app_flow_test` — audio A6 (done 2026-09-27)
- [x] `FxImageSlot` follows LOTTIE.md v3's 3× declarations (`assetWidth`/`assetHeight`, `density`) with rasters in box units; this fixes the owner's Level 9 hint arrow, glow and +1 pads (device screenshots 2026-09-27), pinned by `board_pieces_l9_test.dart` — v3 import plan 2, D60 (done 2026-09-27)
- [x] Delete the v1 export workarounds (travel-hold fix, `padlock_ping` rest hide, 11 dp glass settle, reveal silhouette hide, hand-coded reveal drop, animated-scale callbacks) and `FxHold`, `FxTravel.holds`, `FxImageLayer.scaleAnimated` — v3 import plan 3, D60 (done 2026-09-27)
- [x] `doll_reveal` plays 0–31 f with its `drop` null starting at the tower's step; the deeper silhouettes shift over the drop's 7 frames — LOTTIE.md v3 "Reveal drop", D60 (done 2026-09-27)
- [x] `fx_ice`: an `IceCracked` without a stage change plays `crack_hit_n` and rests on `rest_n`; a reused drawable re-seeks cleanly on every jump (the frame-99 double draw) — v3 3b, v3 issue 1, D60 (done 2026-09-27)
- [x] Ribbons on the 410 canvas: text boxes 312×40 / 312×32, the label scaled down to fit, screen scale `min(1, W/390)` — v3 3a, D60 (done 2026-09-27)
- [x] Hint arc arrives on the source's side of the target, its arrowhead into the target's head (frame 3.1) — owner Level 9 report, D60 (done 2026-09-27)
- [x] Buried tower nests and `doll_reveal`'s silhouette show the wood blank `board/doll-silhouette.svg` for every skin: `DollPartRasters.prepare(board:)`, and `AssetSkinService` passes its board library — v3 3e, D59 (done 2026-09-27)
- [x] The reveal wipe centre from the tokens (`MotionTokens.revealWipeCenter`, art (256, 476)) — v3 3d, D59 (done 2026-09-27)
- [x] The on-device playthrough adds Level 9's hint, two extra slots and a doll on one (frames 3.1, 3.6), Level 16's tower reveal, Pause's Music toggle and Level 21's chapter ribbon; it checks the music (home, game, the win, out-of-moves and pause ducks, off and on), that every Lottie file, SFX and jingle loaded, and that no SoLoud, music or Lottie failure was logged. Passes on the iPhone 16 simulator and the API 35 emulator with 25 screenshots each — D57, PROGRESS "Post-M2 round" (done 2026-09-27)
- [ ] Owner device check of this round on the dev flavor: the Level 9 hint (arrow over brown3, glow on brown2's stand, arrowhead into brown2's head), +1 Slot twice (two full-size green pads, a doll standing on one), a tower reveal (L16+: the new top drops from its buried step, then the wipe), the win ribbon and the L21 chapter ribbon on a 390 dp phone — lottie lane report
- [ ] Owner audio acceptance on a mid-range Android and an iPhone: both loops wrap with no gap or click over 3 full cycles; crossfades, ducks and fades per the tokens and audible; Music off silent within 300 ms and staying silent across routes, ads and the lifecycle; chimes, the win SFX and the jingles over ducked music without clipping (turn on SoLoud's limiter only if clipping is heard, M7); streaming adds under 3 MB resident; the app grows by about 2 MB; iOS mixes with the Music app and follows the silent switch; Android dev/stg screen recordings have sound — audio "Acceptance", Q61–Q63

## M3 — App shell and meta

Acceptance (§18): kill the app mid-level and it resumes exactly where it was.
The daily puzzle is identical on two devices on the same date.

### Save and economy

- [ ] Persistent save document with the §13.3 fields, atomic writes, a schema version and migrations, in the store Q3 picks. It replaces the D13 stub (`InMemorySaveService` in the real env, which then only backs `FakeSaveService`), and `AppEnv.real` is dropped from the fake save. `AssetSkinService` then loads the save's selected skin — §13.3, D13, Q3, services report
- [ ] Save the in-progress level on every move and on app pause. Restore it when `levelVersion` matches, otherwise restart the level. The bloc restores with `GameSession.restore(level, state, history, undosUsed:)` — §13.3, bloc report
- [ ] Acceptance: save/restore round-trip tests (state, undo, `levelVersion`), plus a kill-and-relaunch check on a device — §18 M3
- [ ] Coins — §7.3:
  - Earn: 10 easy, 10 medium (see Q5), 25 hard, 50 superhard; 150 per chapter; 50 per daily; 300 for the day-7 chest.
  - Spend: undo 20 after the free ones, hint 60, slot 150.
- [ ] Persist the booster inventory, with the starter gift of 3 hints and 2 slots — §8
- [ ] Booster purchase popup, coin path: frames 3.2 (Undo) and 3.3 (Hint), with "You have N coins". Wire the coin path of Undo, Hint and +1 Slot once the free undos or the inventory run out in `GameplayBloc` (`_withBoosters` and its handlers, `TODO(M3)`; `booster_use{source: coins}`), the coin rows of the out-of-moves sheet and the coin badges of the booster bar (frames 3.2, 3.3, 3.5) — §10.2 #7, bloc and screens reports
- [ ] Settings footer version and build, which needs `package_info_plus` with a rule-9 reason — frame 8.1, CLAUDE.md rule 9

### Progression

- [ ] Chapters of 20 levels, each showing its theme on Home and in play. "Match each chapter" is the default (`selectedTheme: null`) — §7.1, §7.4
- [ ] Chapter complete overlay (frame 4.6): spotlight, figurine, "Added to your Museum!", +150 coins, next chapter, `fx_twinkle` — §10.2 #9, lottie §15
- [ ] Museum progress on the win card: chapter, count, bar, "Next up" and the locked figurine (frames 1.5, 2.8). M2 built the card with a placeholder tile for the figurine art, and `figurineName` names 3 of the 10 figurines (see Owner inputs) — §7.2, screens report
- [ ] Museum detail's "Collected · Sep 12" chip needs a collected date, but the §13.3 save stores `museum` as ids only. Per D22 (the design wins), the M3 save records the date each figurine was collected. Record the §13.3 addition in PROGRESS when the save schema is built — frame 6.2, §13.3, D22, Q3
- [ ] Bonus Endless: generate with `seed = 1_000_000 + levelNumber` on the curve, with the bonus intro (4.9) and the teal "Bonus Level N" pill (4.10) — §7.1. Pass the global play order to `DifficultyCurve.bonusParams` ("Bonus Level N" = order − last published order); define the deterministic retry seed on a `GeneratorFailure` (A14; none occurred for 1–300); generate in the solver isolate (CLAUDE.md rule 8); decide what the app shows for `simulation.expertOnly` (Q31 kept the generator's behaviour: flagged, not rejected; review SPEC-03). `NextLevelPressed` past the last level then starts it instead of `GameplayStatus.allLevelsDone`, and All Levels Done (4.9) gains "Play Bonus Level 1" and "Back to Home". The win overlay then prefetches the bonus level's art as it does the next level's (`TODO(M3)` in `gameplay_view.dart`), and Home's PLAY names the bonus level instead of "All done!" (D58) — generator, bloc and screens reports, review fix pass
- [ ] A `SkinService` method for the showcase dolls of Splash and Home, replacing `ShowcaseDolls`' one-tower board (`TODO(M3)` in `apps/game/lib/features/home/showcase/showcase_dolls.dart`) — screens report
- [ ] The owner confirmed the default difficulty stage table (A16) on 2026-09-26 (Q34). Resolve the `TODO(M3)` in `packages/nesty_core/lib/src/generator/curve.dart` (doc only). Any later change still needs a `Generator.version` bump and new goldens and parity values — §6.6, A16
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

- [ ] L1 tutorial (frames 1.3, 1.4): scrim with holes, dotted arc, tooltip and the tapping hand `ui_tap_hand` (fingertip (48, 32) on the target; it works in a `LottieFxView` as it is). All other input is blocked — §7.6, lottie §15, FX runtime report
- [ ] L1 third step: nest the last Cherry 1 to finish the family. No frame exists, so mark it `TODO(design)` — §7.6, frame 1.4
- [ ] L1 complete (frame 1.5) and the L2 swallow drag demo (frame 1.6) with `ui_drag_hand`. It is board space through BoardFit, above the scrim: wrap its `LottieFxView` in a BoardFit `Transform`. Its `travel` holds need the lottie §6 hold fix until the re-export — §7.6, lottie §6, §15, FX runtime report
- [ ] Mechanic intro cards, shown once each with a looping mini animation: towers at L16 (4.1), glass at L31 (4.2), ice at L51 (4.3) — §3, §7.6, §10.2 #8

### Menus

- [ ] Finish Home (frame 2.1) — §10.2 #2:
  - Tiles: Daily (streak badge), Museum (next-figurine progress), and a Remove Ads slot that hides once purchased.
  - Bottom nav: Shop · Home · Museum.
  - The coin pill's "+" opens the Shop.
- [ ] Routes for Win, Pause, Settings, Daily, Museum, Shop and SkinDetail — `apps/game/lib/core/router/app_router.dart`, design/README.md "Navigation & state"
- [ ] Settings (frame 8.1): Sound, Music and Haptics toggles (the `ui_toggle` component from Pause), Color symbols (Subtle or Large; the part-raster bodies are rebuilt on change, D45), Language, Privacy Policy link, Support email, and a footer. The Restore and Privacy choices rows are wired in M6. The rows use `NestyToggle` (on `ui_toggle`) and the language sheet `NestySheet` — §10.2 #13, UI lane report
- [ ] The components M2 didn't need: segmented tabs, the bottom nav (on `WoodBar`), Home tiles with the streak badge, the buy popup's body (112 px icon disc with its 8 px halo), intro cards with the NEW chip, and the toast — design/README.md "Components", UI lane report
- [ ] Language sheet with the 9 launch languages (frame 8.2) — §16
- [ ] Enable Pause's Settings tile, and stop the flow test's pause from returning to Home — frame 3.9, `apps/game/test/app_flow_test.dart`
- [ ] Shop on the bundled art — §7.4, §10.2 #12:
  - Tab shell: Coins · Skins · Themes · No Ads.
  - Skins grid (7.3), skin detail with Buy for coins (7.4), and the skin in play (7.6).
  - Themes grid with the "Match each chapter" toggle (7.7).
  - The downloading state's `ui_spinner` on the skin card (7.5; the download itself is M4) and `fx_twinkle` on the Shop — lottie §15
  - Theme ownership (`ownedThemes`), per frame 7.7's note: "Chapter themes unlock with their chapter and can then be used anywhere. Later ones can be bought early." A locked card shows "Ch N" and its coin price (1,200 / 1,500 / 2,000 for ch04–ch06 in the frame; §7.3 range 500–2000, prices from Remote Config or Firestore) — §7.3, §7.4, frame 7.7

### Audio and haptics

- [x] Music playback (`music_home`, `music_game`) with separate music and SFX volumes, and the files synced and shipped (moved into the post-M2 round: the music arrived) — §11.3, tokens.json `sound.music`, D61 (done 2026-09-27)
- [ ] Chapter complete (4.6) calls `JingleCues.chapterComplete()`: the music fades out over 400 ms, then `jingle_chapter` only (Q62). Its Continue calls `MusicService.playGame()`, which fades `music_game` in over 2000 ms — `TODO(M3)` in `gameplay_view.dart` and `jingle_cues.dart`, audio plan §4
- [ ] `JingleCues.reward()` (`jingle_reward` over music ducked to 0.4) at a skin unlock (7.4), a theme unlock or purchase (7.7) and the daily chest (5.6) — `TODO(M3)` in `jingle_cues.dart`, Q62
- [ ] Music by screen: the daily puzzle's and the bonus levels' boards play `music_game`; Daily, Museum, Shop, Skin detail and Settings play `music_home` (`MusicRouteObserver.trackFor`) — `TODO(M3)` in `music_route_observer.dart`, AUDIO.md "Music rules"
- [ ] Settings' Music and Sound toggles only write `DatabaseService` (the music follows `musicEnabledChanges`, as Pause's do); a music volume control, if one is designed, calls `MusicService.setVolume`, which applies at once (Q66 asks whether it should fade) — frame 8.1, AUDIO.md "Music rules"
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
  - Runs on launch and on resume when online, without blocking: the splash kicks it off unawaited, with the Remote Config refresh (`TODO(M4)` in `splash_cubit.dart`).
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
- [ ] Re-check the admin generator's params against the design's 64 MB. Q33 was confirmed on 2026-09-26 as no cap for now; cap them or scale the budget if the admin hits it — design §5, review DETERMINISM-005
- [ ] Admin level editor and playtest preview on `DebugBoardPainter`: an adapter from a nesty_core `Level`/`GameState` to `Map<String, DebugSlot>`, and bundle Fredoka (tag and badge text) or accept the fallback font — §15 #3, r3 report
- [ ] A `nesty_levels tune` command (or an admin Generator feature) that hill-climbs a fixed skeleton (rows, tower positions and depths, empties, colors) toward a target tier by swapping nests and re-cutting sets; that is how L16–L30 were found — §6.5, §15, levels report
- [ ] Publishing batch: bump `config/manifest.levelsVersion` and `publishedCount`, and renumber `order` — §15
- [ ] Final security rules, including the Q20 gaps, with emulator-backed rules tests. The first Storage deploy must grant it Firestore access — §14.3, Q20, firebase/README.md
- [ ] Orientation and colors in `apps/admin/web/manifest.json` — Q21
- [ ] Swap `BundledUnlockSymbolRasterizer` for nesty_render's `SymbolRaster.rasterize(atlas, color, pixelsPerUnit: fs × dpr)` (the atlas cell 1:1, with its `FxRaster` scale and origin), removing the `TODO(M5)` in `apps/game/lib/core/services/skin/unlock_symbol_rasterizer.dart`, before the first locked levels (L31+) ship (moved from M2: no M2 level has a lock) — render and services reports
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
- [ ] Rewarded placements: booster popups (3.2, 3.3), out of moves +1 slot (3.5), win ×3 (2.8 → 2.9 "Reward added"), and the daily chest's "Double it" (5.6). M2 built `RewardedAdButton` (with its "Reward added" state) and `BoosterBadge.ad()`, both unused until then — §9.1, UI lane report
- [ ] `GameplayBloc` listens to `SaveService.changes`, so a wallet change during a level (a rewarded booster, the Shop) refreshes the coins and the booster counts; today they refresh only on the bloc's own transitions — bloc report
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
- [ ] `AdsService` calls `MusicService.pauseForAd()` before every interstitial or rewarded show and `resumeAfterAd()` in a `finally` when it closes; with the app's own trip to the background during an Android ad, the pause reasons don't double up — `TODO(M6)` in `music_service.dart`, audio A5
- [ ] A completed purchase calls `JingleCues.reward()` — `TODO(M6)` in `jingle_cues.dart`, Q62

## M7 — Art and polish

Acceptance (§18): matches the design screens, with no layout overflows on 5
screen sizes. Most of the original M7 integration moved into M2 (D23).

- [ ] Fidelity pass, screen by screen, against every App Flow frame (01–08) with `ui-designer`, then owner sign-off — §18 M7
- [ ] Overflow tests on small Android, standard phone, tall phone, small iPhone and iPad portrait, at 1.0× and 1.3× text — §18 M7, §16
- [ ] Animation polish: tune by feel each clip's playback speed (never the JSON), the hand-coded tweens of lottie §9 (`TODO(M7)`), the wobble snap into `doll_move` (settle it before the move), an animated undo (`BoardResetEffect(undo)` cuts today), re-placing the clips in flight during a +1 Slot re-pitch, the coin count-up (700–1300 ms) guess, and the intro-card loops. The tower reveal's drop now comes from `doll_reveal` (D60) — §11.1, lottie §7, §9, timeline report
- [x] Swap in the designer's Lottie re-export when it arrives (done 2026-09-27: Claude Design v3, imported in the post-M2 round, D59, D60) — re-export, lottie §18, D43:
  - re-sync (`sync_design_assets`) and regenerate `fx_spec.gen.dart` (`gen_fx_spec`). Any change to a length, a marker, the canvas or a hook fails validation until `tools/lib/src/fx/lottie_contract.dart` is updated, and its test also reads LOTTIE.md, so LOTTIE.md must agree;
  - before any lottie upgrade, rerun `fx_compensation_test`, `fx_travel_test` and `fx_workarounds_test`: they pin lottie 3.6.1's internals;
  - remove each workaround whose cause is fixed (hold fix, padlock hide, settle ramp, reveal silhouette hide, animated-scale callbacks);
  - keep the equivalence tests green.
- [ ] Tabular figures for coins and counters. Fredoka's digits are proportional and it has no `tnum` feature, so `AppTextStyleTokens.number`'s `FontFeature.tabularFigures()` does nothing (Nunito's digits are already fixed-width). Build the approach the owner picks (Q29) in `NestyNumberText` (`TODO(M7)` there and in `app_text_styles.dart`) (moved from M2: the approach waits on the owner) — design/README.md "Typography & icons", tokens.json `fontSize.number.tabular`, tools/fonts audit
- [ ] +1 Slot plays `button` twice: the booster's tactile feedback and the timeline's `ExtraSlotAddedEffect` cue (m2-lottie-design §7 lists the cue). Keep one — review fix pass
- [x] Final audio: replace the placeholder WAVs, normalize levels, re-check the clack pitch offset, and add the music loops (done 2026-09-27: the SFX v2 WAVs baked at 0 semitones, the two OGG loops and three jingles, D61) — §11.3, D19, services report
- [ ] Final mix by ear on a mid-range Android and an iPhone: `SfxMix.gains`, the music's 0.5 and the ducks, the jingles over ducked music. The worst realistic stack has about 0.14 dB of headroom: keep the cues staggered, and turn on SoLoud's limiter only if clipping is heard — audio plan §2 "Clipping", audio audit §5
- [ ] Optional: keep Nesty's music off while another app plays audio (iOS `secondaryAudioShouldBeSilencedHint`) — Q61, audio plan
- [ ] The `ui_extra_slot` loop starts at its rest pose (96 %, 75 % opacity) when the 300 ms re-pitch ends, after the static pad drew the stand at 100 %: a small pop. Start it at frame 24 (100 %) or fade it in — lottie lane report, `board_pieces_l9_test.dart`
- [ ] Device check: the gameplay skin lands within the route transition (`prepareForLevel` starts on the board's first layout; placeholder dolls show until it lands) — screens report
- [ ] Integrate chapter themes 7–10, per-theme shelf and stand art, and `palette` accents once supplied — §12.4
- [ ] Translations: es, pt-BR, id, hi, de, fr, tr, ja — §16
- [ ] The Flame board's "+N" tower tag and the ice badge's digits through ARB, with the locale's text direction, handed to `SlotDecor` when the board is built (`TODO(M7)` in `slot_decor.dart`). Every launch language writes "+3" the same way today — §16, review PERF-RULES-3
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
- [ ] Crop the doll part rasters to their alpha bounds, if memory matters: `FxRaster.origin` already compensates a crop, and it would roughly halve the ≈0.54 MB per part at 150 dp × DPR 3 — lottie §3, §4
- [ ] Theme background on tablets: 768×1024 @2 is 12.6 MB; cap the raster at the art's native pixel count or lower the pixel ratio on large screens if the iPad budget matters — r3 report

## Owner inputs needed

Content, assets, accounts and decisions only the owner can supply. Each item
names the milestone it blocks.

### Content and assets

- [x] Music: `music_home` and `music_game`, seamless loops of 60–90 s — §11.3 (done 2026-09-26: Claude Design's audio export, 66.7 s and 68.6 s OGG loops, plus three jingles; D61)
- [x] Optional: final SFX to replace the 17 placeholder WAVs — §11.3, D19 (done 2026-09-26: the SFX v2 WAVs, D61)
- [ ] Listening check: `jingle_reward` reaches −17 RMS through up to 8.1 dB of limiting (`jingle_chapter` 4.5 dB, `jingle_oom` 2.5 dB). Compare the three in `design/prototypes/Nesty Soundtrack.dc.html` (serve `design/` over http); if `jingle_reward` sounds squashed, ask Claude Design for a gentler master — v3 issue 3 (M7)
- [x] Lottie re-export from the designer. Nothing blocks on it; the workarounds ship. Each point (done 2026-09-27: Claude Design v3 covers every point below, D59) — re-export (M7):
  - [x] Declare image assets at the pixel size supplied: dolls 512×768 with 512×768 placeholders; board pieces at 3× (glass 258×429, ice 288×480, glow 348×156, hint 120×150, extra slot 270×102, unlock symbol 36×36) with 33.33 % layer scales.
  - [x] Placeholder PNGs at exactly the declared sizes.
  - [x] Animated scales moved off image layers onto parent nulls: `glow_ring`, `extra_slot`, `ice_shatter`.
  - [x] No equal consecutive `travel` keyframes: `doll_complete` 0–42; `ui_drag_hand` 0–21.6 and 86.4–108.
  - [x] `fx_glass_unlock`: `padlock_ping` hidden at rest; the freed doll ends on the stand surface (y 174); shards kept inside the canvas.
  - [x] `doll_reveal`: a `drop` null for the true-size 18 dp tower drop; the silhouette ends at the wipe's end; confirm the wipe centre.
  - [x] `fx_ice`: `rest_0…3` markers, a `crack_hit` segment for counters over 3, unique `crack_flash_1/2/3` names, chunks kept inside the canvas.
  - [x] Ribbon bands that fit about 26 characters, or no baked text; the counter's text layers optional.
  - [x] The nest rim above the body, consistent with `nesty-doll.js`, or confirm the current order.
  - [x] LOTTIE.md: "28" → 29; viewer anchors; trim paths and polystars allowed; the `textStyle` advice and the `remapTravel` sample fixed.
- [ ] Optional, for a later export: `doll_move` with a hold frame at the end. lottie never draws `op`, so its last drawn frame is about 1 dp high and 2 % large and the sprite takes over mid-fall; then tighten `handoff_test`'s last-frame check. It wasn't in the v2 request, and v3 keeps the 16 f file — board report (M7)
- [ ] Flavor text for 9 figurines. Only the Sailor Family has one — §7.2, frame 6.2 (M3)
- [ ] Names for figurines 4–10 (astronaut, gardener, snow, circus, musician, royal, explorer): the design names only the Classic, Sailor and Baker Families, so `figurineName` returns '' and the win card hides "Next up" for chapters 4–10 (Q47) — UI lane report (M3)
- [ ] The colours the App Flow frames use that tokens.json lacks (e.g. `#6E4526` icon brown), listed in `apps/game/lib/core/ui/colors/app_colors.dart` with `TODO(design)`: add them to tokens.json `color`, then move the call sites to `AppColorTokens` — UI lane report (M7)
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
system and mark them `TODO(design)`. The gaps that said (M7) moved to M7 on
2026-09-27: M2 ships the design-system stand-ins, and the M7 fidelity pass
takes the designs when they arrive.

- [ ] L1 tutorial third step (Cherry 1 into the nest) — §7.6, frame 1.4 (M3)
- [ ] Out-of-moves Undo row once the free undos are used — frame 3.5 (M3)
- [ ] +Slot at its limit (2 used this level) — §3.6 (M7)
- [ ] Extra slot when the bottom shelf is full — §3.6, D22 (M7)
- [ ] Boards with 1 shelf, 4 shelves or 5 slots per shelf — §2.1, §5.3 (M7). Built by scaling (D36): the 1-shelf preset (plank 540, Hs 150) and the 4-shelf preset (planks 250/395/539/684, Hs 104, every slot piece × 104/150), both `TODO(design)` in `packages/nesty_render/lib/src/board/shelf_presets.dart`; 5–6-slot rows shrink stands, pips, tag, glow, glass, ice, hint arrow, tower raise and (review RENDER-3) the dolls (`TODO(design)` in `board_layout.dart`)
- [ ] The board-wide doll clamp (`h·2/3 ≤ minPitch − 8/3`) for maxSize 6 on 3 shelves, maxSize 3 on 3 shelves or 4-slot rows (M2 levels 3–9) and 5–6-slot rows needs a design sign-off (`TODO(design)` in `board_layout.dart` `_dollHeights`). On these boards a top-row doll of the largest size is taller than any in the frames, so the hint arrow over one in the second column reaches the family counter pill at the top of its bob and slips under it by a few dp (Level 9's hint, playthrough screenshot `09c_l9_hint`) — D22, D36, post-M2 playthrough (M7)
- [ ] A doll sealed in a glass case is taller than the case at maxSize ≥ 5 (the design's own maxSize-5 doll is 6 dp above it, NestyBoard:169) and wider at maxSize 6; on a 4-shelf board a top-row maxSize-6 doll (sealed, or on a tower) reaches ~2–6 dp above the frame — r1 report, review (M7)
- [ ] Top-shelf towers: the D21 18 dp step per buried nest shrinks so the deepest silhouette stays under the HUD (`TODO(design)` in `board_geometry.dart` `buriedBaseY`); and a buried nest two or more sizes smaller than the top stays hidden at 18 dp per depth (Q38) — D21, review RENDER-4 (M7)
- [ ] A designed look for the procedural fallback doll (spec §12.5; `TODO(design)` in `packages/nesty_render/lib/src/doll/placeholder_doll_painter.dart`) — r2 report (M7)
- [ ] Looping animations for the intro cards — frames 4.1–4.3 (M3)
- [ ] Home with a Super Hard level, in bonus mode, and with a streak of 0 — frame 2.1 (M3)
- [ ] Win card in bonus mode — frame 2.8 (M3)
- [ ] Streak lost — §7.5 (M3)
- [ ] Ad loading, ad failed and ad timed out — §9.1 (M6)
- [ ] Purchase failed and purchase pending — §9.2 (M6)
- [ ] Restore found nothing — §9.2 (M6)
- [ ] Starter Pack already owned, and the No Ads tab once ads are removed — frames 7.1, 7.8 (M6)
- [ ] Skin or theme download failed, and the Shop offline — §13.5, frame 7.5 (M4)
- [ ] A tap on an unpickable slot (empty, locked or iced) with nothing selected: ignored today (`TODO(design)` in `tap_policy.dart`, Q39). Should it shake? — frame 2.6 (M7)
- [ ] Highlighting the hovered column while dragging: no design (a second `fx_select_glow` is the suggestion) — contracts report (M7)
- [ ] Text max width: the family counter's label (52) is a guess (`TODO(design)`). The win and chapter ribbons use LOTTIE.md v3's text boxes (312×40, 312×32) since 2026-09-27 — lottie §12, v3 3a (M7)
- [ ] Iced towers: `fx_ice` anchored on the doll at the tower surface draws the ice 5·fs above the static `iceRect` fallback (`TODO(design)` in `board_geometry.dart`, Q55). Ice comes at L51 — render report (M5)
- [ ] The hint's dashed arc for moves other than frame 3.1's is a generalization (a quadratic 0.4 × the chord off its middle, arriving on the source's side of the target, D60; `TODO(design)` in `hint_layer.dart`), and where it starts on a tall source doll was Q64 (resolved: the design's 66) — board report, owner Level 9 report (M7)
- [ ] Whether `ui_extra_slot` keeps pulsing under a doll placed on the extra slot (today it loops until a reset); frame 3.6 shows only the empty slot (Q65) — lottie lane report (M7)
- [ ] `fx_twinkle` on the win overlay: LOTTIE.md puts it there but no frame places it; four sit around the plank (`TODO(design)` in `win_overlay.dart`) — screens report (M7)
- [ ] The drift height of an invalid move onto an empty glass case or ice slot uses the mover's height (`TODO(design)` in `timeline_plans.dart`) — timeline report (M5)
- [ ] Looks no frame shows, built in the design's system (`TODO(design)`): a disabled booster (45 % glyph and label), the danger button, the success banner, and the Home SUPER HARD badge — UI lane report (M7)
- [ ] A load failure (the splash's retry): the player reads `genericLoadFailed` whether storage or content failed (`TODO(M7)` in `app_exception_extension.dart`, `TODO(design)` in `retry_view.dart`) — UI lane report (M7)
- [ ] The splash's first frames draw the procedural placeholder dolls, which swap to the skin once it loads (about a second on the simulator, Q58) — integration playthrough (M7)
- [ ] Anchors of `ui_toggle` and `ui_splash_loader`: LOTTIE.md says only "toggle box" and "bar box", taken as their top-left (Q56) — tools report (M7)
- [ ] Home's PLAY once every bundled level is won: it reads "PLAY · All done!" and opens All Levels Done, where it used to promise "Level 31" (`TODO(design)` in `play_button.dart`, review FIDELITY-5) — frame 2.1, 4.9 (M3)
- [ ] Soft stuck with nothing to undo (a completion cleared the history, or the free undos are spent): the banner suggests Restart, "Try Restart? You can keep playing too.", and Undo doesn't glow (`TODO(design)` in `soft_stuck_banner.dart`, review FIDELITY-6) — frame 3.4 (M7)

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
- [ ] Q29: tabular numbers in Fredoka: a fixed-width digit widget, Nunito for numbers, or a patched "Fredoka Tabular" build in `build_fonts.sh` (the OFL allows modified builds under a new name)? (M7)
- [ ] Q39–Q58: the M2 phase-4 lanes' questions (tap and drag policy details, the soft-stuck re-check, `booster_use` sources, skipped bundled levels, dev-flavor undos, background audio, starting coins, figurine names, button feedback timing, Continue in the same page, the chapter ribbon's look, disabled M3 entries, invalid-move shakes on towers, win timing and combo clock, pool sizes, iced towers, Lottie box anchors, HUD coins at Won, splash placeholder dolls). Q56 (answered by LOTTIE.md v3: the canvas is the component box), Q57 and Q58 are resolved. See PROGRESS "Open questions" (M2, M3)
- [x] Q59: the subtle belly symbol, bare ink (tokens.json, README §3, the generator and the classic renders; what ships) or on the App Flow previews' cream r 55 disc with a light-shade ring? (done 2026-09-27: the owner chose bare ink, PROGRESS Q59)
- [ ] Q60: a second +1 Slot press during the 300 ms re-pitch: queue it (today: a second slot and booster) or ignore it like the board's global lock? (M2, D58)
- [x] Q61–Q63: the audio plan's session, chapter-jingle and low-latency questions (done 2026-09-26: iOS `.ambient`; `jingle_chapter` only at chapter complete; low latency in prod only; D61)
- [x] Q64: should the hint arc start at the source doll's head rather than 66 below its top (the prototype's value, which lands on a tall doll's upper body)? (M7) (done 2026-09-27: the owner kept the design's value, PROGRESS Q64)
- [ ] Q65: should the extra slot's pulse stop while a doll stands on it? (M7)
- [ ] Q66: should a music volume slider fade (SoLoud's `setVolume` applies at once and cancels a running fade)? No M2 caller (M3)
- [x] Q30–Q38: the M1 and render decisions to confirm (towerless grading, expert-only generated levels, solver targets, admin memory, the curve table, the recorded defaults, bundle policy, authored levels, render defaults) (done 2026-09-26: the owner confirmed the recorded defaults, D52)
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
- [ ] Refresh the `code-explorer` map after M1 and M2. It says only `DollColor` exists; M1 core, the nesty_render API (D27, D36–D38) and the M2 Lottie contracts (D40–D52) are now built — `.claude/agents/code-explorer.md`
- [ ] Make the Stop hook (`.claude/hooks/test-on-stop.sh`) run `dart test -x slow` in nesty_core now that the slow M1 acceptance test exists (owner's hook config) — design §5, contracts report
- [ ] `.claude/hooks/block-generated.sh` doesn't yet block hand edits of `apps/game/assets/levels/bundle.json` (a `nesty_levels bundle build` output; CI's `bundle check` catches drift) or of `apps/game/assets/lottie/**` (a `sync_design_assets` output once the tools lane ships it). It is the owner's hook config — tools/README.md, D25, bundle report, lottie §16
- [ ] Commit the kernel/facade and PRNG/Hash64 micro-benchmarks in `packages/nesty_core/benchmark/` (scratch numbers: kernel copy+apply 45 ns, `collectLegalMoves` 97 ns, `Rules.tryMove` 0.4 µs; `nextU32` 9 ns, `derive` 50 ns VM / 70 ns node, a 24-cell key hash 116 ns), with dart2js numbers — design §5, kernel and prng reports
- [ ] Share one doll base constant: `DollArt.base` (256, 742) in nesty_render's doll code and `BoardLayoutConstants.dollArtBaseY`/`dollArtHeight` (742/768) in the layout — r2 report
- [ ] `test/simulator/bots_test.dart` reuses the kernel step's `test/rules/support/boards.dart` helpers; keep them stable or copy them — simulator report
- [ ] Upgrade `flutter_soloud` to 5.x together with the SDK and CI pin (5.x needs `meta` ^1.19; Flutter 3.41.2 pins 1.17.0) — Q23, PROGRESS "Package reasons"
- [ ] `AppGradientTokens.gold` (115°) maps the CSS angle to `Alignment` exactly only for square boxes. If it paints non-square boxes, resolve begin/end from the box's aspect (180° gradients are exact everywhere) — `tools/lib/src/tokens/ui_tokens_codegen.dart`
- [ ] The TODO scanner finds comments heuristically: a string literal containing `//` or `#` followed by a marker is indexed too — `tools/lib/src/todo/todo_scanner.dart`
- [ ] `tools/pubspec.yaml` declares `xml` but uses it only through `svg_tools.dart`. Use it directly (level tools) or drop it after P3 — PROGRESS "Package reasons"
- [ ] The icon font's name table still says "Material Symbols Rounded" (Flutter uses the pubspec family `NestySymbols`, so it's cosmetic). Rename it in `build_fonts.sh` if it ever shows up in a font picker or licence page — `tools/fonts/build_fonts.sh`
- [ ] flutter_soloud's `play()` allocates a Set per call inside the plugin: per sound, not per frame, so it passes rule 8. Re-check it in the perf profile — services report
- [ ] Never set `NO_XIPH_LIBS` in the Android or iOS build: flutter_soloud decodes the OGG music and jingles with its bundled Ogg/Vorbis libraries — D61, PROGRESS "Package reasons"
- [ ] `SoundTokens.jingleBus` is a String checked to be 'sfx' or 'music'; a typed `SoundBus` enum needs `ui_token_types.dart` and a codegen change — import-tools report
- [ ] Optional: strip the 5,758-byte C2PA chunk from each shipped WAV on sync (about 98 KB in all) — audio audit problem 9
- [ ] Optional: carry `doll_reveal`'s authored `drop` start in `FxSpec` (the tools contract has `dropFrom` (0, −18); the game reads `FxTiming.revealDropUnits`) — import-tools report
- [ ] The real `SoLoudBackend` is a thin pass-through no unit test covers (the native library isn't loaded in tests); the playthrough and the owner's device acceptance cover it — audio lane report
- [ ] The bundled levels are validated on the UI isolate at splash (milliseconds for 30). Re-measure at 200 levels and move it to `compute` if it takes longer than a frame — services report
- [ ] The timeline tests' `geometryOf` fixture repeats the game's `boardShapeOf`; use it, so the page, the board and the tests build geometry one way — timeline report
- [ ] The tools contract table repeats the `FxId` file names and the `FxImageSlot` ids and sizes (tools can't import the game). `lottie_contract_test` reads the game's frozen `fx_id`/`fx_image_source`/`fx_spec` files with regexes, so a big reformat of them may need the regexes updated — tools report
- [ ] `integration_test.framework` is embedded in every iOS configuration: CocoaPods links the dev-dependency plugin's pod everywhere, and only its registration is debug-only. Check the M8 release size and whether to keep it out of release builds — integration (M8)
- [ ] `flutter drive` on Android ends with "Failed to uninstall app": it tries the base id `com.futrix.nesty`, not the flavor's `.dev`. The test result is unaffected — integration
- [ ] Deleting `apps/game/build/` alone leaves `apps/game/.dart_tool/flutter_build/` stamps that say the iOS native assets (objective_c's framework) are built, so the next iOS build fails with "NativeAssetsManifest.json references objective_c, which was not found". Clean both (`flutter clean`, or remove `.dart_tool/flutter_build` too); README "Troubleshooting" says so — fix-and-close verification

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
- [x] Q61–Q63: iOS `.ambient`, `jingle_chapter` only at chapter complete, low-latency audio in prod only — D61 (done 2026-09-26)
