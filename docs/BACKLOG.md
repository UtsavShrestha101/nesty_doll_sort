# Backlog — Nesty: Doll Sort

This is the single curated checklist of all remaining work, with one section per
milestone (spec §18). [PROGRESS.md](PROGRESS.md) records what was done and why.
This file records what is left. In-code markers are indexed separately in
[TODO_INDEX.md](TODO_INDEX.md), which `dart run nesty_tools:todo_index` generates from
`TODO(<tag>)` comments. Never edit it by hand.

Last updated: 2026-09-30 (D209, Q159: phase 4's device run passed on both platforms; its item, the race-loss segment, the day-7 chest on a device and `nesty-test`'s device gaps ticked; the fidelity audit's list, two design gaps, Q159 and the reminder phone check added. Before that: D202–D208, Q158: phase 4 integrated: the lanes' and the integrator's phase-4 items ticked with their evidence, the delivered design items ticked, the device-pending ones annotated, the lanes' deferrals and Q158 added. Before that: D179–D201, Q156–Q157: phase 4's contracts stage: a phase-4 subsection with the five lanes' items, the design-delivered items, gaps and owner inputs ticked or annotated with their m7 P4.n section, and the design-answered questions ticked. Before that: D171–D172: the M7 delivery is in `design/`; the import item ticked, and phase 4 wires it in. Before that: D170: the HUD's "Replay" tag removed. Before that: D169: `nesty-test` covers every feature; its device gaps are an M7 item. Before that: M7 phase 5, the device run after the review: both platforms pass, dated notes on the audit, the VoiceOver and TalkBack pass, the race-loss segment and the reminder phone check, D168. Before that: M7 review pass, round 2: the accessibility audit ticked, and new items for the device VoiceOver and TalkBack pass, screen-reader board play (R12, Q154), R7's Android note and `shopOwned`'s copy; the pass-and-play proposal linked; Q154–Q155. Before that: M7 review pass, round 1: R2's paused-streak follow-up and R4's accent swap added under M7, the accessibility audit annotated with what is left, Q153. Before that: M7 phase 3 integrated: star ratings, the share card and the reminder, D156–D161, Q149–Q151; the phase-2 rival strip item done; the device run is next. Before that: M7 phase 3's contracts frozen, D144–D155, Q137–Q148. Before that: M7 phase 2 done: vs Computer integrated, D132–D142, and passed on both devices, D143, Q124–Q136. Before that: M7 phase 1 device stage: device-pass confirmed on both platforms, two app bugs fixed, Decisions D126–D131 and Questions Q121–Q123 added, eight deferrals proposed. Before that, star ratings added by the owner: D125, Q116–Q120. Earlier today: M7 phase 1 integrated, D113–D124, Q99–Q115; D92–D93; D90. M3 code complete; acceptance pending the owner's two physical-device checks).

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
  - `m3 §n` is section n of [plans/m3-design.md](plans/m3-design.md), the
    authoritative M3 design (D66–D80); `plan-m3` is its approved
    [plans/plan-m3.md](plans/plan-m3.md).
  - `m7 §n` is section n of [plans/m7-design.md](plans/m7-design.md), the
    authoritative M7 design (D95–D110, and each phase's sections as its
    contracts stage adds them); `m7 P2.n` is its phase-2 (vs Computer)
    section P2.n (D132–D142); `m7 P3.n` is its phase-3 (star ratings,
    the share card, the reminder) section P3.n (D144–D155); `plan-m7` is
    its approved
    [plans/plan-m7.md](plans/plan-m7.md).
  - `brainstorm §n` is section n of
    [plans/offline-game-brainstorm.md](plans/offline-game-brainstorm.md) (D92),
    and `En` is one of its adopted features. `vs-computer` is
    [plans/mode-vs-computer.md](plans/mode-vs-computer.md) (D93).
    `spec-prop` is [plans/spec-proposals-m7.md](plans/spec-proposals-m7.md),
    the spec text for the owner to paste.
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

## M3 — App shell and meta — code complete; acceptance pending (2026-09-28, plan [plans/plan-m3.md](plans/plan-m3.md))

Acceptance (§18): kill the app mid-level and it resumes exactly where it was.
The daily puzzle is identical on two devices on the same date.

Lanes and ownership: m3 §2 and §14. Each item below names the m3 section it
follows.

Status on 2026-09-28 (PROGRESS "M3 acceptance"): every automated gate passes,
and both criteria pass on the iPhone 16 Pro simulator and the API 35
emulator. What is left is the owner's two physical-device checks below. The
design gaps the M3 stand-ins cover moved to M7 (see "Design gaps").

- [ ] Owner: on a physical phone, swipe the app away mid-level (after a few moves, an undo and a +1 Slot), relaunch, tap PLAY: the same board, undos and extra slots — §18 M3; README "Testing" has the automated two-phase version
- [ ] Owner: on two physical phones set to the same date, open the Daily and compare the board (the automated check matched the simulator, the emulator and the core golden) — §18 M3

### Contracts stage

- [x] The authoritative design `docs/plans/m3-design.md`, and the frozen Dart contracts: `GameSessionCodec`'s API and `Generator.generateWithRetries` (core); `PlayRequest`, `PlayEntry`, `BoosterType`, `IntroMechanic`; `AppClock` + `LocalDate`; `SaveService`, `SaveDocument`, its lenient codec and migrations, `HiveBoxes.save` and the raw save accessors; `CatalogRepository` with the bundled data; `LevelGeneratorService`, `LevelResolver`, `DailyService` with fakes; `reward_medium`, `reward_chapter`; the route tree with stub pages; `GameplayRoute(request:)` and the M3 bloc fields and events — m3 §1, D66–D80 (done 2026-09-27)
- [x] Add `package_info_plus` and `url_launcher`, remove `hive_ce_generator`, with the rule-9 reasons — m3 §10.2, D80 (done 2026-09-27)
- [x] After the first iOS build of this round, commit the `pod install` changes for `url_launcher_ios` and `package_info_plus` (Podfile.lock, the Xcode project) — D80, integrator (done 2026-09-28: the first iOS build updated `apps/game/ios/Podfile.lock` for the two pods; the Xcode project didn't change)

### Save and economy

- [x] Persistent save document with the §13.3 fields, atomic writes, a schema version and migrations, in the store Q3 picks. It replaces the D13 stub (`InMemorySaveService` in the real env, which then only backs `FakeSaveService`), and `AppEnv.real` is dropped from the fake save. `AssetSkinService` then loads the save's selected skin — §13.3, D13, Q3, services report. Build: `HiveSaveService` (load, backups, the coalescing write queue, `SaveLifecycleFlusher` on paused/detached, the in-memory fallback) over the frozen `SaveDocumentCodec` and `SaveMigrations` — m3 §3.2, D63, D67, D68 (services lane) (done 2026-09-28: `HiveSaveService` in the real env, `FakeSaveService` in the fake env only; `AssetSkinService` loads the selected skin)
- [x] Save the in-progress level on every move and on app pause. Restore it when `levelVersion` matches, otherwise restart the level. The bloc restores with `GameSession.restore(level, state, history, undosUsed:)` — §13.3, bloc report; m3 §3.4, §6.4, D71 (gameplay-bloc lane) (done 2026-09-28: a restored board also takes its status from core, so an out-of-moves or won save reopens its sheet or win (review CORRECTNESS-1))
- [x] Acceptance: save/restore round-trip tests (state, undo, `levelVersion`), plus a kill-and-relaunch check on a device — §18 M3; m3 §14 (the Hive, bloc and app-flow tests; the two-phase `flutter drive` on the iPhone 16 simulator and the API 35 emulator), m3 §16 (done 2026-09-28: the codec, Hive, bloc and `app_flow_test` (a) round trips, and the two-phase `flutter drive` kill on the iPhone 16 Pro simulator and the API 35 emulator (PROGRESS "M3 acceptance"); the physical-phone check is the owner item below)
- [x] Coins — §7.3: (done 2026-09-28)
  - Earn: 10 easy, 10 medium (see Q5), 25 hard, 50 superhard; 150 per chapter; 50 per daily; 300 for the day-7 chest.
  - Spend: undo 20 after the free ones, hint 60, slot 150.
  - Every number from Remote Config (`reward_medium` D64, `reward_chapter` D72/Q68) — m3 §7.1 (the keys are done; the callers are the bloc, daily and shop lanes)
- [x] Persist the booster inventory, with the starter gift of 3 hints and 2 slots — §8; m3 §3.1 (in the save document, services lane) (done 2026-09-28)
- [x] Booster purchase popup, coin path: frames 3.2 (Undo) and 3.3 (Hint), with "You have N coins". Wire the coin path of Undo, Hint and +1 Slot once the free undos or the inventory run out in `GameplayBloc` (`_withBoosters` and its handlers, `TODO(M3)`; `booster_use{source: coins}`), the coin rows of the out-of-moves sheet and the coin badges of the booster bar (frames 3.2, 3.3, 3.5) — §10.2 #7, bloc and screens reports; m3 §7.3 (the bloc's `BoosterOffer` flow, gameplay-bloc lane) and §10.8 (the popup, rows and badges, gameplay-screens lane), D73 (done 2026-09-28: a confirm buys only the offer that is up and spends only when the booster applies (review CORRECTNESS-7); the Out-of-Moves sheet reads its prices from the state)
- [x] Settings footer version and build, which needs `package_info_plus` with a rule-9 reason — frame 8.1, CLAUDE.md rule 9; m3 §10.2 (`AppInfoService`, services lane; the footer, shell-home-settings lane; the package is added, D80) (done 2026-09-28)
- [x] `AppInfoService` (`PackageAppInfoService` + fake), `LinkLauncher` (`UrlLinkLauncher` + fake) and `AppLinks` (empty until supplied, `TODO(M8)`) — m3 §10.2, §11, D79 (services lane) (done 2026-09-28: `AppLinks` stays empty until the owner supplies the URLs, so the Privacy Policy and Support rows stay hidden (`TODO(M8)`))

### Progression

- [x] Chapters of 20 levels, each showing its theme on Home and in play. "Match each chapter" is the default (`selectedTheme: null`) — §7.1, §7.4; m3 §9.1, §9.4 (the catalog is done; Home and the board read `selectedTheme ?? the chapter's theme`) (done 2026-09-28)
- [x] Chapter complete overlay (frame 4.6): spotlight, figurine, "Added to your Museum!", +150 coins, next chapter, `fx_twinkle` — §10.2 #9, lottie §15; m3 §9.3, D72 (bloc: the completion rule and the one-update win; gameplay-screens: the overlay) (done 2026-09-28: titled with the figurine's name (review FIDELITY-1))
- [x] Museum progress on the win card: chapter, count, bar, "Next up" and the locked figurine (frames 1.5, 2.8). M2 built the card with a placeholder tile for the figurine art, and `figurineName` names 3 of the 10 figurines (see Owner inputs) — §7.2, screens report; m3 §9.3 (the locked PNG from the catalog), §13 (names 4–10, Q73) (done 2026-09-28: figurines 4–10 keep placeholder names until the owner's Q73 answer (Owner inputs))
- [x] Museum detail's "Collected · Sep 12" chip needs a collected date, but the §13.3 save stores `museum` as ids only. Per D22 (the design wins), the M3 save records the date each figurine was collected. Record the §13.3 addition in PROGRESS when the save schema is built — frame 6.2, §13.3, D22, Q3; m3 §3.1 (`museumCollected`, recorded in D67; written by `recordLevelWin`) (done 2026-09-28)
- [x] Bonus Endless: generate with `seed = 1_000_000 + levelNumber` on the curve, with the bonus intro (4.9) and the teal "Bonus Level N" pill (4.10) — §7.1. Pass the global play order to `DifficultyCurve.bonusParams` ("Bonus Level N" = order − last published order); define the deterministic retry seed on a `GeneratorFailure` (A14; none occurred for 1–300); generate in the solver isolate (CLAUDE.md rule 8); decide what the app shows for `simulation.expertOnly` (Q31 kept the generator's behaviour: flagged, not rejected; review SPEC-03). `NextLevelPressed` past the last level then starts it instead of `GameplayStatus.allLevelsDone`, and All Levels Done (4.9) gains "Play Bonus Level 1" and "Back to Home". The win overlay then prefetches the bonus level's art as it does the next level's (`TODO(M3)` in `gameplay_view.dart`), and Home's PLAY names the bonus level instead of "All done!" (D58) — generator, bloc and screens reports, review fix pass; m3 §5 (the retry seeds, done), §6.2 (`DefaultLevelResolver`), §6.3 (`IsolateLevelGeneratorService`), §7.4 (the policy, D74/Q71; expert only plays as its tier) (done 2026-09-28)
- [x] `DefaultLevelResolver` (both environments; cache, prefetch join, the embedded-level restore, `completesChapter`, `next`, `homeRequest`) and `IsolateLevelGeneratorService` (`Isolate.run`, level JSON back), replacing the fakes' `AppEnv.real` registrations — m3 §6.2, §6.3, §11, D70 (services lane) (done 2026-09-28: a board embedded by an older generator is regenerated (review CORRECTNESS-5))
- [x] A `SkinService` method for the showcase dolls of Splash and Home, replacing `ShowcaseDolls`' one-tower board (`TODO(M3)` in `apps/game/lib/features/home/showcase/showcase_dolls.dart`) — screens report; m3 §9.2 (`prepareShowcase`, `selectSkin`, `selectedSkinId`: services lane; Home's use: shell-home-settings lane) (done 2026-09-28: `prepareShowcase` pins the rasterizers it uses, so concurrent previews never fall back to the placeholder (review CORRECTNESS-2))
- [x] The owner confirmed the default difficulty stage table (A16) on 2026-09-26 (Q34). Resolve the `TODO(M3)` in `packages/nesty_core/lib/src/generator/curve.dart` (doc only). Any later change still needs a `Generator.version` bump and new goldens and parity values — §6.6, A16; m3 §5 (core-codec lane, with `Tier.medium`'s doc for D64) (done 2026-09-28)
- [x] ~~`SolverSnapshot` "generate" task (design §6 lists hint | softStuck | generate) with a params encoding, when on-device generation moves into the isolate — design §6, contracts report~~ (dropped 2026-09-27: `Isolate.run` copies `GeneratorParams`, m3 §6.3, D70)
- [x] `codec/game_state_codec.dart` (design §1 stretch goal): the in-progress save of `GameState` + undo history, persisting `GameSession.undosUsed` and restoring with `GameSession.restore(..., undosUsed:)` — §13.3, contracts and kernel reports; m3 §4: now `codec/game_session_codec.dart`, its API frozen by the contracts stage, format 1 and the `session.*` issue codes to implement (core-codec lane), D69 (done 2026-09-28: `GameSessionCodec` format 1)
- [x] Museum: collection card and a walnut cabinet of 4 × 3 (6.1), detail modal (6.2), and the locked state with a bar and Play (6.3). The art comes from `design/museum/png/` (20 files: figurines and `_locked` silhouettes), because the museum SVGs use nested `<svg>` and mix-blend-mode. Extend `sync_design_assets` and the pubspec asset list to ship them — §7.2, §10.2 #10, audit; m3 §9.5 (the sync), §10.6 (the screen) (daily-museum-tools lane) (done 2026-09-28)
- [x] Daily puzzle: `seed = yyyymmdd`, a pinned `generatorVersion`, tier medium or hard. The date comes from an injected clock, never inside core — §7.5, CLAUDE.md rule 7. When `Generator.version` is ever bumped, keep a frozen v1 pipeline (PRNG, cuts, placement, validator, solver, simulator, daily table) for dailies so every device makes the same puzzle (Q35); decide the unlock level and the weekday rule (Q34) — generator report; m3 §5 (the retries, done; the 28-date goldens, core-codec lane), §8.1 (`AppClock`, done), §8.3 (unlock after Level 2, D76/Q67) (done 2026-09-28: 28-date goldens on the VM, node, chrome and wasm; the unlock after Level 2)
- [x] Daily screens — §10.2 #11: (done 2026-09-28: 5.2 and 5.6 are widget-tested with a fake clock; the screen rolls over at midnight (review CORRECTNESS-8))
  - 5.1: streak card, 7-day strip, chest row and puzzle card.
  - 5.2: streak saved.
  - 5.3: daily board with the date pill.
  - 5.4: solved, +50, no ×3.
  - 5.5: countdown to the next puzzle.
  - 5.6: chest modal with Collect ("Double it" is M6).
  - m3 §8.4, §10.5 (daily-museum-tools lane); the 5.3 pill and the 5.4 win card: m3 §10.8 (gameplay-screens lane); the win path: m3 §8.5 (gameplay-bloc lane)
- [x] Streak rules: a missed day resets the streak, and one freeze is earned each week — §7.5; m3 §8.2 (the algorithm and its worked table, D76/Q70): `StreakDailyService` for both environments (services lane) (done 2026-09-28)
- [x] Acceptance: a seed test (same date → same level on every run), plus a two-device check — §18 M3; m3 §5 (VM + Chrome goldens), §16 (`NESTY_FAKE_DATE` on the simulator and the emulator, then the owner's two phones) (done 2026-09-28: the goldens, plus `daily_fingerprint_test` at `NESTY_FAKE_DATE=20260926` on the simulator and the emulator, both equal to the core's golden `7716bec2334e7d9a`; the two-phone check is the owner item below)

### Onboarding

- [x] L1 tutorial (frames 1.3, 1.4): scrim with holes, dotted arc, tooltip and the tapping hand `ui_tap_hand` (fingertip (48, 32) on the target; it works in a `LottieFxView` as it is). All other input is blocked — §7.6, lottie §15, FX runtime report; m3 §10.4, D78 (the script and gating: gameplay-bloc lane; the overlay: gameplay-screens lane) (done 2026-09-28: the tap steps draw the dotted arc too (review FIDELITY-4))
- [x] L1 third step: nest the last Cherry 1 to finish the family. No frame exists, so mark it `TODO(design)` — §7.6, frame 1.4; m3 §10.4 (step 3, provisional copy) (done 2026-09-28: built with provisional copy; the frame stays a design gap)
- [x] L1 complete (frame 1.5) and the L2 swallow drag demo (frame 1.6) with `ui_drag_hand`. It is board space through BoardFit, above the scrim: wrap its `LottieFxView` in a BoardFit `Transform`. Its `travel` holds need the lottie §6 hold fix until the re-export — §7.6, lottie §6, §15, FX runtime report; m3 §10.4 (step 4; `tutorialDone` set on the swallow). The hold fix is gone since v3 (D60) (done 2026-09-28)
- [x] Mechanic intro cards, shown once each with a looping mini animation: towers at L16 (4.1), glass at L31 (4.2), ice at L51 (4.3) — §3, §7.6, §10.2 #8; m3 §10.4 (first board with the mechanic, any kind; `seenIntros`), D78 (done 2026-09-28: static illustrations from the frames' board sprites and the level's skin at top 170 (review FIDELITY-6); the loops stay a design gap)

### Menus

- [x] Finish Home (frame 2.1) — §10.2 #2: (done 2026-09-28: the tiles stay above the nav on a 16:9 Android body, and Remove Ads opens the Shop's No Ads tab (m3 §10.3))
  - Tiles: Daily (streak badge), Museum (next-figurine progress), and a Remove Ads slot that hides once purchased.
  - Bottom nav: Shop · Home · Museum.
  - The coin pill's "+" opens the Shop.
  - m3 §10.3 (shell-home-settings lane)
- [x] Routes for Win, Pause, Settings, Daily, Museum, Shop and SkinDetail — `apps/game/lib/core/router/app_router.dart`, design/README.md "Navigation & state" (done 2026-09-27 as stubs: the shell's Shop · Home · Museum tabs, and Settings, Daily, SkinDetail and `GameplayRoute(request)` over it; Win and Pause stay gameplay overlays; m3 §10.1)
- [x] Settings (frame 8.1): Sound, Music and Haptics toggles (the `ui_toggle` component from Pause), Color symbols (Subtle or Large; the part-raster bodies are rebuilt on change, D45), Language, Privacy Policy link, Support email, and a footer. The Restore and Privacy choices rows are wired in M6. The rows use `NestyToggle` (on `ui_toggle`) and the language sheet `NestySheet` — §10.2 #13, UI lane report; m3 §10.2, D79 (shell-home-settings lane) (done 2026-09-28: Color symbols as the frame's two preview cards (review FIDELITY-8); the Privacy Policy and Support rows wait for `AppLinks`)
- [x] The components M2 didn't need: segmented tabs, the bottom nav (on `WoodBar`), Home tiles with the streak badge, the buy popup's body (112 px icon disc with its 8 px halo), intro cards with the NEW chip, and the toast — design/README.md "Components", UI lane report; m3 §10.9 (ui-kit-arb lane) (done 2026-09-28)
- [x] Every M3 string in `app_en.arb` with a description (the catalog of m3 §13), then gen-l10n — §16, CLAUDE.md "Code style" (ui-kit-arb lane) (done 2026-09-28)
- [x] Language sheet with the 9 launch languages (frame 8.2) — §16; m3 §10.2 (only English selectable until M7, D79) (done 2026-09-28)
- [x] Enable Pause's Settings tile, and stop the flow test's pause from returning to Home — frame 3.9, `apps/game/test/app_flow_test.dart`; m3 §10.1 (Settings pushed over the paused level) (done 2026-09-28: the Pause toggles and the board's symbols re-read on return (review CORRECTNESS-4))
- [x] Color symbols: Large on a fresh install, and every doll preview follows a change made in Settings. Home's shelf (`ShowcaseDolls`), the Shop's skin cards and the Daily card kept the mode they were prepared in until a restart; only the board re-read it — owner 2026-09-28, D91 (done 2026-09-28: `DatabaseService.symbolsModeChanges`, `FollowsSymbolsMode`, app flow test (h))
- [x] Shop on the bundled art — §7.4, §10.2 #12: (done 2026-09-28)
  - Tab shell: Coins · Skins · Themes · No Ads.
  - Skins grid (7.3), skin detail with Buy for coins (7.4), and the skin in play (7.6).
  - Themes grid with the "Match each chapter" toggle (7.7).
  - The downloading state's `ui_spinner` on the skin card (7.5; the download itself is M4) and `fx_twinkle` on the Shop — lottie §15
  - Theme ownership (`ownedThemes`), per frame 7.7's note: "Chapter themes unlock with their chapter and can then be used anywhere. Later ones can be bought early." A locked card shows "Ch N" and its coin price (1,200 / 1,500 / 2,000 for ch04–ch06 in the frame; §7.3 range 500–2000, prices from Remote Config or Firestore) — §7.3, §7.4, frame 7.7
  - m3 §9.4, §10.7 (shop lane); the Coins and No Ads tabs show a store-closed card until M6 (D75, Q75)

### Audio and haptics

- [x] Music playback (`music_home`, `music_game`) with separate music and SFX volumes, and the files synced and shipped (moved into the post-M2 round: the music arrived) — §11.3, tokens.json `sound.music`, D61 (done 2026-09-27)
- [x] Chapter complete (4.6) calls `JingleCues.chapterComplete()`: the music fades out over 400 ms, then `jingle_chapter` only (Q62). Its Continue calls `MusicService.playGame()`, which fades `music_game` in over 2000 ms — `TODO(M3)` in `gameplay_view.dart` and `jingle_cues.dart`, audio plan §4; m3 §9.3 (done 2026-09-28)
- [x] `JingleCues.reward()` (`jingle_reward` over music ducked to 0.4) at a skin unlock (7.4), a theme unlock or purchase (7.7) and the daily chest (5.6) — `TODO(M3)` in `jingle_cues.dart`, Q62; m3 §9.4, §10.1 (a theme unlocked by reaching its chapter plays none) (done 2026-09-28)
- [x] Music by screen: the daily puzzle's and the bonus levels' boards play `music_game`; Daily, Museum, Shop, Skin detail and Settings play `music_home` (`MusicRouteObserver.trackFor`) — `TODO(M3)` in `music_route_observer.dart`, AUDIO.md "Music rules"; m3 §10.1 (the route tree already gives it, pinned by `music_route_observer_test`; the `TODO(M3)` comment is the shell-home-settings lane's) (done 2026-09-28)
- [x] Settings' Music and Sound toggles only write `DatabaseService` (the music follows `musicEnabledChanges`, as Pause's do); a music volume control, if one is designed, calls `MusicService.setVolume`, which applies at once (Q66 asks whether it should fade) — frame 8.1, AUDIO.md "Music rules"; m3 §10.2 (no volume slider is designed, so none is built) (done 2026-09-28)

## M4 — Firebase content — after M7 (D90)

Acceptance (§18): with airplane mode on first launch, the game is fully
playable. Levels published in the admin appear on the next app resume.

- [ ] Firebase init at the `TODO(M4)` in both bootstraps, failing silently offline. The owner runs `flutterfire configure` first (Q12) — §14, CLAUDE.md rule 3, `apps/game/lib/bootstrap.dart`
- [ ] Crashlytics: uncaught errors, plus non-fatals for `runGuarded` failures, the Hive fallback and level-validation failures — §14.4, D17
- [ ] `FirebaseRemoteConfigService` over the hard-coded defaults, with prices and rewards read from it — §9.4, CLAUDE.md rule 6
- [ ] `FirebaseAnalyticsService`, with every §14.4 event sent from the feature it belongs to — §14.4
- [ ] When sync adds levels to a chapter the player has already passed, award its figurine and `reward_chapter` once — m3 §6.2, D72
- [ ] Synced levels carry their `par` for the star rating. A level without one shows no stars, and a new version keeps the level's best stars (Q117) — spec-prop §7.10, D125
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
- [ ] Chapter, theme, skin and museum metadata (names, flavor text, prices) from Firestore — §14.1; overlaid on `CatalogRepository` (`TODO(M4)` in `bundled_catalog_repository.dart`), m3 §9.1
- [ ] When level sync adds levels to a chapter the player has already passed, award its figurine and `reward_chapter` then (`PlayEntry.completesChapter` sees only the bundle it was resolved from) — m3 §6.2, D72
- [ ] `connectivity_plus` to re-sync on reconnect, with its reason in PROGRESS — §13.2, §9.1
- [ ] Airplane-mode tests with failing network services, plus a fresh-install device check — §18 M4
- [ ] Install `firebase-tools` (it needs a JDK) and verify `firebase emulators:start` from `firebase/`, including the Auth emulator — PROGRESS M0 "Not verified yet"

## M5 — Admin panel — after M7 (D90)

Acceptance (§18): the owner can build, solve, simulate, playtest and publish a
level, and upload a skin that then shows up in the game.

- [ ] `FirebaseAuthService` (email and password), with "Not authorized" when there is no `admins/{uid}`. Delete `UnconfiguredAuthService` — §15, `apps/admin/lib/core/services/auth/unconfigured_auth_service.dart`
- [ ] Dashboard — §15 #1
- [ ] Publishing a level computes its par with the admin's solver (the optimal length) and stores it with the level, for the star rating — spec-prop §7.10, D125
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

## M6 — Monetization — after M7 (D90)

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
- [ ] The respect rules hold for every ad and purchase surface (spec-prop §1.1):
  - no offer shown because the player failed or got stuck, and no countdown or limited-time offer;
  - the real-money price shown before the purchase flow, and no forcing an oversized coin pack (EU CPC key principles, March 2025);
  - a test per placement.
  - D92, brainstorm §5
- [ ] Ads for players of unknown age: non-personalized by default, and whether to read Apple's Declared Age Range API (Q86). The game may be "likely to be accessed by children" whatever its rating — D92, brainstorm §1

## M7 — Art and polish, plus the offline game: content, modes and engagement — in progress (started 2026-09-28, D90–D93, plan [plans/plan-m7.md](plans/plan-m7.md))

Acceptance (§18): matches the design screens, with no layout overflows on 5
screen sizes. Most of the original M7 integration moved into M2 (D23).

The owner moved M7 ahead of M4–M6 on 2026-09-28 (D90): everything the game
can do offline comes before any backend (Firebase, ads, purchases). D90
widens it with the offline content and the modes below. D92 adds the
respect rules and the engagement features, and D93 approves vs Computer in
principle as a race against three computer rivals. Their acceptance is added
to §18's (spec-prop §18):
- **Levels 1–200** are bundled, valid, solvable and on the §3.7 and §6.6
  schedule.
- **vs Computer**, the gentle streak, the share card, the reminder, the
  milestone chest, relaxed mode, replay with best moves, Records and badges,
  and the first-launch L1 all work fully offline, with tests at every layer.
- **Every feature** passes the ethics checklist (brainstorm §5).

The rules for these features are spec-prop's text as approved in D92 and D93,
until the owner pastes it into GAME_SPEC.md (Q85). The art and copy come from
Claude Design (see "Owner inputs needed → Design gaps" and the D90 and D92
notes there).

### Phase 4: Claude Design's m7-3 delivery (2026-09-30, m7 P4, D179–D201)

C4a (the tooling) and C4b (the frozen shapes and the copy) are done. Five
lanes build on them, each with its host tests, overflow sweeps and device
file (m7 P4.3–P4.7), then the integrator and the device stage.

- [x] Lane B, the board: the fit rule and presets, rows of 5 and 6, the tall case and tall ice, the tower stack and the iced tower, `ui_extra_slot`'s rest and stop, the nudge, the hover, the hint arcs and `familyCounterYield`, the fallback doll; `board_fit_test`, `bundle_layout_fit_test`, `integration_test/board_layouts_test.dart` — m7 P4.3, D180–D185 (`TODO(M7)` in `gameplay_board.dart` and `board_timeline.dart`) (done 2026-09-30: lane B, D204; `board_fit_test`, `board_tall_pieces_test`, `bundle_layout_fit_test` (200 levels × 6 viewports × 0–2 +1 Slots), `board_m7_test`; the view hands `dropTargets` to the board, D202; the device file is wired into `nesty-test` as `board`)
- [x] Lane B: `ui_stars`' compensation at the pops and the flourish, with a tolerance for the small art (C4a's note in `fx_compensation_test`) — m7 P4.3, D174 (done 2026-09-30: lane B: `fx_compensation_test` covers `ui_stars`' pops and flourish at their own 95 % bar)
- [x] Lane R, vs Computer: rival select (tap to select, one Start, New, the beaten check, portraits), the strip in the HUD row, the results in `RaceResultLayer` with their jingles, 9.6's card, Pause with Leave race's confirm, the Computer tag; `integration_test/race_loss_test.dart` — m7 P4.4, D192 (`TODO(M7)` in `rival_select_page.dart`) (done 2026-09-30: lane R, D205; the race suites, `race_overflow_test` 160, `gameplay_view_race_test`; `race_loss_test.dart` wired as `race` (`loss`, `oom`))
- [x] The integrator: Settings in a race's Pause with the race's hold kept (Q132's answer), wired in `gameplay_view.dart` once lane R's confirm lands — m7 P4.4, D192 (`TODO(M7)` in `gameplay_view.dart`) (done 2026-09-30: D202: the Pause's hold stays set under Settings; `gameplay_view_race_test` "Settings in a race's Pause", `app_flow_test` (i))
- [x] Lane M, the meta screens: Home, Chapters and the level card, the Museum, Records, the Shop with Forest Bear and the theme crops (`ThemeThumbnailLoader`), "Not enough coins"; `integration_test/meta_screens_test.dart` — m7 P4.5, D193, D199, D200 (done 2026-09-30: lane M, D206; the home, chapters, museum, records and shop suites and their overflow sweeps; `meta_screens_test.dart` wired as `meta`)
- [x] Lane D, the daily and Settings: the reminder's steps and Settings' rows, the segmented Reduce motion, the rotation, "Open phone settings" (the native side), the streak's looks, the day-7 chest, the share text's owner; drop `PuzzleCard.onShare`; `integration_test/daily_states_test.dart` and `reminder_test.dart` — m7 P4.6, D188–D190 (`TODO(M7)` in `daily_page.dart`) (done 2026-09-30: lane D, D207; the daily, settings, reminder and system-settings suites and three overflow sweeps; `daily_states_test.dart` wired as `daily_states` (`chest`, `paused`, `settings`); `reminder_test.dart` updated)
- [x] Lane O, the overlays: the win card and `ui_stars`, the helper note and the tip's deferral, the daily win card's Share, the chest moment, the splash's fade and error views, 12.5–12.9, relaxed mode, the tutorial, the intro loops, the ribbon, the toasts' scoped hosts; `integration_test/overlays_test.dart` — m7 P4.7, D187, D191, D194, D195 (done 2026-09-30: lane O, D208; the overlay, win card, chest, splash and HUD suites and their overflow sweeps; `overlays_test.dart` wired as `overlays`)
- [x] The integrator: the new device files in `tools/scripts/nesty-test` and TEST_COVERAGE's rows, the playthrough's finder updates (copy.md m7-3 changed "Start race", "You win!", "Back to rivals", "Quit race", "Reminder time" and the Share button's place; `integration_test/playthrough_test.dart`, `reminder_test.dart`), "Follow-up after m7-3" in `claude-design-request-m7.md` (lead note 13: C7, C8, the splash glyphs, the toast colours, `textLink.pressed`, `shopOwned`) — m7 P4.2, lead notes 12, 13 (done 2026-09-30: D202; `nesty-test` step 6 and its `--only` names, docs/TEST_COVERAGE.md, the playthrough on m7-3 (analyze clean), "Follow-up after m7-3" written; `test_coverage_test` passes)
- [x] The device stage: every new file and the playthrough on the iPhone 16 Pro simulator and the API 35 emulator, and `--android --only reminder` — m7 P4.10 (done 2026-09-30: D209: every check passes on both platforms, iOS run 9 and Android runs 1 and 2, plus the reminder check; `scratchpad/m7/reports/device-p4.md`)
  - 2026-09-30 (phase 4 integrated, D202): `nesty-test --device-only` runs them all from fresh installs (`--only playthrough,resume,daily,board,race,meta,daily_states,overlays`); what each must show is in the integrator's report (`scratchpad/m7/reports/integrator-p4.md`)

Left from phase 4 (the lanes' deferrals, 2026-09-30):

- [ ] Fidelity audit: the tutorial scrim leaves the HUD and booster bar bright (frames 1.3, 10.8b), and the step chip touches the family counter — device run p4, D209
- [ ] Fidelity audit: rival select's locked cards are invisible on the flat page (9.2), and the list's clipped edge under the pinned hint on 731 dp phones — device run p4, D209
- [ ] Fidelity audit: the chest card's art box is about 80 dp taller than 10.3b, 10.3c and 5.6, so the closed chest floats low — device run p4, D209
- [ ] Fidelity audit: Chapters opens with the current chapter at the top (10.4 shows the finished rows above it); locked cells' numbers aren't faded; "60 won" isn't right-aligned — device run p4, D209
- [ ] Fidelity audit: the rest of D209's list (the paused strip's static "Thinking…", the iOS Share glyph, the coin pill's missing glow during the chest's flights, the splash dolls hidden until the skin loads) — `scratchpad/m7/reports/device-p4.md` §5, D209
- [ ] design: Records' "Families completed" cell, its copy and glyph (`TODO(design)` in `records_page.dart`; Q159) — device run p4, D209
- [ ] design: where a capped win says why on a short phone, since the helper note has no room there (11.2d, C11) — device run p4, D209
- [ ] Claude Design's answers to "Follow-up after m7-3" (`docs/plans/claude-design-request-m7.md`): the tokens, copy ids, screen-reader strings and looks to confirm; take `nesty-design-m7-4` through the import checks — integrator, lead note 13, D202
- [ ] Rows of 5 and 6 with tall pieces: a tall case, its ice and a row of 6 are undesigned (the case is capped at the pitch − 2 dp, a 96-wide ice can overlap a neighbour by up to 2.4 dp), and `fourShelves` has no glass or ice sizes — lane B, `TODO(design)` in `board_geometry.dart`, `board_layout.dart`, `shelf_presets.dart`; follow-up §5
- [ ] Device check of the board's short motions: the empty stand's dip, the padlock ping, the tag pop and the hover glow (16–240 ms). `board_layouts_test` polls their tweens and shoots before and after — lane B, the device stage
- [ ] The relit twinkles (10.7b) on the daily win card: `StreakCard(relit:)` is built, the two `fx_twinkle` sparkles aren't placed — lanes D and O, follow-up §4.17
- [ ] 12.6's failed card over the theme art only; the board stays dimmed behind it today — lane O, follow-up §4.13
- [ ] The chest flights' gold ring on the coin pill and their 6 dp trail dots, once Claude Design gives the values — lane O, follow-up §1.7
- [ ] The family counter's hug with a width-free pill (the file's 70 dp pill scales 0.9–1.2 today) — lane O, follow-up §4.14
- [ ] The chapter ribbon: frame 4.7's two-line plate, or named fills on `ui_chapter_ribbon` to recolour it exactly (a colour matrix tints it today) — lane O, `TODO(design)` in `ribbon_tint.dart`; follow-up §4.15
- [ ] 12.5's reduce-motion spinner: a still frame 0 today; the proposal's slow pulse isn't specced — lane O, follow-up §4.17
- [ ] Drop `DailyCubit.share` and its `ShareService` constructor argument (the solved card has no Share since D188) once the contract tests stop building it with five arguments — lane D, D207
- [ ] A way to turn a blocked reminder off in the app, if the owner wants one (Q158) — lane D, D207 (owner)

### Offline content (D90)

- [x] Levels 31–200 (chapters 2–10, 20 per chapter) in the bundle, made with the generator and `nesty_levels`:
  - on the chapter plan (brainstorm §4): glass cases from L31, ice from L51, `maxSize` 5 from L71, and `maxSize` 6 in the S slots L130, L140 … L200;
  - on the `E E M E M H M E M S` pattern, so each chapter's 20th level is its S finale;
  - hand-tuned at L31, L51, L71, L130 and the ten finales;
  - each validated, solved and tier-checked by `bundle check`.
  - §3.7, §6.6, §7.1 (launch target 200), D90, D92 E11
  - (done 2026-09-28: the levels lane and the H/S review's fix pass, D113, D115; `bundle check` OK on 200 levels, 0 errors, 0 warnings; finales 22 → 35 moves; `repo_levels_test` pins the chapter plan, the near duplicates and the casual-0 levels)
- [x] L101 introduces the golden doll only if it ships (§3.7); it stays v1.1, so L101 is an ordinary level — §3.5, §3.7, D90 (done 2026-09-28: L0101 is an easy `maxSize` 5 level with glass and ice, its note says the golden doll is v1.1)
- [x] `bundle check` and `BundlePolicy`: (done 2026-09-30: the design part landed with lane B: the presets and tall pieces fit every bundled level, `bundle_layout_fit_test`; D180–D183, D204)
  - The confirmed curve (Q34, `curve.dart`) never needs more than 3 shelves or 4 slots per row, so levels 31–200 fit today's layouts.
  - What they still need designed is `maxSize` 5–6 on 3 shelves (design request B.3–B.6; D36 scaling is the stand-in).
  - The 4-shelf and 5-slot presets are for variety only, if the owner wants them (Q87).
  - `tools/lib/src/levels/bundle_policy.dart`, D22, D36, D90
  - 2026-09-28: the tools part holds (levels 31–200 fit 2–3 shelves and ≤ 4 slots per shelf); left: the design part (B.3–B.6)
  - 2026-09-30 (phase 4, m7 P4.3): the design part is delivered: tokens v3 `layout.boardFit`, `boardPresets`, `glassCaseTall`, `towerStack`, `icedTower` (D180–D183). Lane B builds it; tick when B lands
- [x] The glass (L31) and ice (L51) intro cards, the museum figurines 3–10, chapter complete and the chapter ribbons play through chapters 2–10 offline (a playthrough segment per new mechanic) — §3.7, §7.2, D90
  - 2026-09-28: the device run passed on the iPhone 16 Pro simulator and the API 35 emulator (device stage): L16's towers card (4.1), L31's glass card (4.2) and case, L51's ice card (4.3) and shatter, L71's size 5, L130's size 6 and its chest, L200 into chapter 10 complete and All Levels Done; the Daily runs after L31, so each schedule level shows its own card
- [ ] The owner plays the ten flagged levels (L31, L51, L71, L130, L40, L60, L81, L160, L170, L200), then L131 and L132, and the H/S table, and names any to re-tune (casual 0/300 on L200; smart 75 % on L60) — levels lane report and its review fixes, brainstorm §4 "Human review", Q107 (owner)
- [ ] Chapter themes 7–10: the art once Claude Design delivers it (chapters 7–10 reuse ch01–ch04 today, `themeIds[(N - 1) % 6]`, Q38), their Shop theme cards and prices, and real thumbnails on every theme card — §7.4, §12.4, frame 7.7, D90
  - 2026-09-30 (phase 4, m7 P4.1, P4.5): the art is synced (D176), `ChapterTheme` has ch07–ch10 with their palettes, and each chapter takes its own theme (D199); ch07–ch10 sell at 2,000 each until the owner prices them (Q156). Left: lane M's thumbnails (A.4) and the owner's prices
  - 2026-09-30 (phase 4 integrated): lane M's theme crops are on every theme card (`ThemeThumbnailLoader`, D206). Left: the owner's prices (Q156)
- [x] The catalog copy the design doesn't supply: figurine names 4–10 and 9 flavor texts, 5 skin descriptions, chapter names 7–10 (Q73), from Claude Design, approved by the owner — §7.2, §7.4, D90 (done 2026-09-30: copy.md G.1–G.4 in the ARB, C4b, D196; final, D198)
- [x] `forest-bear`: sell it in the Shop (price, card, description) or drop it; it ships unsold today — design/README.md, D20, D90 (owner) (done 2026-09-30: lane M: the 7th skin card and its detail at 2,500 (`shop_phase4_test`, `skin_detail_page_test`); D200, D206)
  - 2026-09-30 (phase 4, m7 P4.5): sold at 2,500 (copy.md H, D200). Left: lane M's card and detail per frames 7.3 and 7.4b

### Game modes (D90, D93)

The spec has no competitive mode, so none is built before the owner approves
its rules (CLAUDE.md: never invent game rules). The spec text a mode needs is
proposed for the owner to add to GAME_SPEC.md; Claude never edits it.

- [x] vs Computer, design first: a written proposal (`docs/plans/mode-vs-computer.md`) with the rules, the computer rivals (their skill from the §6.4 simulator's player models, their pace, their names), rewards, entry points, what saves, and the screens Claude Design must draw; the owner approves it and records it as a decision — D90 (done 2026-09-28: the race, approved in principle, D93; its numbers are Q77–Q80)
- [x] vs Computer core (done 2026-09-28: race-core's `RivalBot`/`RivalStep` and the race curve, frozen by the contracts, D133, D134; `dart test` 1,606 and the node, chrome and dart2wasm parity green at the phase-2 integration):
  - a public, seeded, step-by-step rival API reusing `BotPlayer` (internal today);
  - the run-end and restart rule;
  - the race board params (a `DifficultyCurve` entry for a stage and a tier);
  - the seed formula `3_000_000 + rival × 100_000 + raceNo`;
  - no new bot policy and no `Generator.version` change;
  - tests for determinism, legality, restarts and seed collisions.
  - rule 2, rule 7, vs-computer "What core does", spec-prop §7.7, D93
  - 2026-09-28: built by the race-core lane (`RivalBot`, `RivalStep`, `BotPlayer.stepRun`, `DifficultyCurve.raceSeed`/`racePolicy`/`raceTier`/`raceParams`; the tests, the race goldens and the web parity) and frozen as is by the phase-2 contracts (D133, D134; m7 P2.3). Ticked by the phase-2 integrator
- [x] vs Computer app (done 2026-09-28: phase 2, D132–D143; the look waits for the stand-ins item below):
  - a race bloc that owns the pace clock (seeded jitter, pause on sheets and backgrounding) and the result;
  - the Home tile, locked until `race_unlock_level`;
  - rival select, the race board with the rival strip, pause, win, loss and rival unlocked;
  - hint and +1 Slot off, undo and restart free;
  - Rematch and New race;
  - the per-rival save fields (schema step and migration);
  - the Remote Config keys with defaults;
  - "Computer" on every rival surface;
  - bloc, widget and playthrough tests.
  - Build it in the design system with `TODO(design)` until frames 09.x land. The rival's move choice runs where the build plan decides, and it allocates nothing per move (rule 8).
  - vs-computer, spec-prop §7.7, §9.4, §13.3, D93
  - 2026-09-28: the phase-2 contracts froze the request, the resolver's race case, the save's race API, `RaceRules`, `FrameTicker`, the `RaceCubit` signatures and its setup, the bloc's gate, rival select's route and cubit, and the copy (D132–D139, m7 P2.1). The per-rival save fields are schema 2's (phase 1's one migration, D96), so no new step. The phase-2 lanes' items follow
  - 2026-09-28: integrated (D140–D142): every sub-item is built and tested on the host (bloc, widget, page, app-flow and overflow tests); the playthrough's rival-1 segment is written and wired into `nesty-test`. Left: that segment's device run on both platforms (the item below), then this item is ticked
  - 2026-09-28: the device run passed on both platforms (D143)
- [x] The race's clock in `RaceCubit` (done 2026-09-28: race-bloc, `race_cubit_test.dart` 19 tests): Start with no countdown, the frame ticks (one rival step at most per frame, 250 ms clamp), the pace and its seeded jitter, the holds (Pause, a sheet or overlay, the app in the background), the player's win recorded once, the tie by frame order; the vs-computer "Bloc" tests on `FakeFrameTicker` — race-bloc lane, m7 P2.5, D136
- [x] The gameplay bloc's race mode (done 2026-09-28: race-bloc, `race_mode_test.dart` 13 tests): undo free and unlimited, Hint and +1 Slot give no offer and spend nothing, no tutorial, intro card or in-progress save, a win recorded only by the race, no spec §14.4 level events — race-bloc lane, m7 P2.6, D137
- [x] The save's race API and the resolver's race case, fully tested (done 2026-09-28: race-services, `race_rules_test`, `race_win_path_test` and the codec, Hive and resolver extensions, 135 tests): `beginRace` and `recordRaceWin` (every step, one update, a Hive round trip, a reload keeping the raceNo and paying nothing), the codec's race case, `RaceRules`, `_race`'s locks, cache and failure — race-services lane, m7 P2.4, P2.7, D135, D138
- [x] The race screens (done 2026-09-28: race-ui's stand-ins, then the integrator's fixes, D140, D141: 9.4 on the board's win report and never 2.8's Continue, Back to rivals and Quit race pop past the page's `PopScope`, the failure card with Back to rivals, 2.8's celebration on 9.4, the live balance on the HUD, the strip's taps pass through, rival select readable by a screen reader; `gameplay_view_race_test` 14, `app_flow_test` (i), `race_overflow_test` 120): Home's tile opening rival select, rival select (frame 9.2), the race board's rival strip, Start and bar (9.3), You win, the computer finished first and Rival unlocked (9.4–9.6), Pause and out of moves in a race, the level pill's chip, the failure card, and "Computer" on every rival surface; overflow at the five sizes — race-ui lane, m7 P2.8–P2.10, D139
- [x] The vs Computer stand-ins are built in the design's system with `TODO(design)` (`ComputerTag`, `RivalPortrait`, the strip, the Start state, the result cards, the race Pause) until Claude Design's section C (frames 9.1–9.6, C.2 portraits, C.8 glyph) lands; the gaps are already in the design request's section C — m7 P2.10, design request C (done 2026-09-30: lane R replaced every stand-in with section 09: `ComputerTag`, `RivalPortrait` on `UiArt.rival`, the strip, Start, the result cards, 9.6 and the race Pause; D205)
  - 2026-09-30 (phase 4, m7 P4.4): section C is delivered (frames 9.1–9.7b, `ui/rivals/*`, the tag); lane R replaces the stand-ins (D192)
- [x] The playthrough segment that beats rival 1 (done 2026-09-28: both devices, D143): past L20, Home's tile, rival 1, Start, the solver's moves on `race-1-1@20` with `--dart-define=NESTY_RACE_PACE_MS=600000`; "You win!", +20 coins, Rival 2 unlocked and "Computer" on screen, on both devices; README documents the define — integrator, m7 P2.13, vs-computer "Integration"
  - 2026-09-28: written (`_raceRival1` in `integration_test/playthrough_test.dart`, after level 20's chapter complete; screenshots 25–25f), `nesty-test` passes the define and README "Tests and analysis" documents it (D142). Left: the device stage runs it on the iPhone 16 Pro simulator and the API 35 emulator
  - 2026-09-28: run on both devices from fresh installs, all PASS (device stage): the iPhone 16 Pro simulator (iOS 18.3) and the API 35 emulator, screenshots 25–25f; two stand-in fixes from the run (D143)
- [x] Retire `homeVsComputerSoon` once the Home tile opens rival select (the key and its phase-1 pin) — integrator, m7 P2.10, P2.11, Q98 (done 2026-09-28: the key and its pin are gone, `arb_keys_m7_test` checks it stays gone)
- [x] The race's audio once Claude Design delivers it: `jingle_versus_win`, `jingle_versus_lose` and `rival_complete` — design request C.7, D93 (done 2026-09-30: lane R plays `Jingle.versusWin`/`versusLose` under the `raceResult` duck and `rival_complete` for each rival family (`gameplay_view_race_test`, `rival_strip_test`); D205)
  - 2026-09-28: until then 9.4 plays 2.8's `win` and `coins` cues and both results duck the music as 2.8 does (`TODO(design)` in `race_result_overlay.dart` and `gameplay_view.dart`, D141)
  - 2026-09-30 (phase 4, m7 P4.1, P4.4): delivered and frozen: `SoundEffect.rivalComplete`, `Jingle.versusWin`/`versusLose`, the `raceResult` duck in `RaceResultLayer` (D192). Left: lane R plays them
- [x] The rival strip against frame 9.3: its height (~64 dp), its place against the board's top shelf (it sits in that shelf's band, and taps pass through; a tall doll on the top shelf passes under it, at rest on the iPhone 16 Pro (19.5:9) and more on a 16:9 screen, and a doll's flight arc passes under it and the HUD (device stage); a fix is to reserve the strip's band, 64 + 12 dp, in a race board's top inset), which part gives way on a narrow screen (the state line below 340 dp, Q135) and its per-move "moved" beat (a portrait nudge, no sound or haptic) — race-ui, integrator, m7 P2.9, P2.10, design request C.3, C.9 (done 2026-09-30: lane R: 48 tall in the HUD row, the dots, the states, the 360/340 dp rules by screen width, the per-move portrait beat (`rival_strip_test`, seven widths at 1.0 and 1.3); D205)
  - 2026-09-30 (phase 4, m7 P4.4): frame 9.3 is delivered. C4b moved the strip into the HUD's top row (x 76 to W − 16, top 62, 48 tall) and the banner back to 152; Q134 and Q135 are answered (D192). Left: lane R's look, the dots and the narrow-screen rule
- [x] Rival portraits: one shared `smartDisplay` glyph with a number badge until Claude Design's C.2 portraits land (`rival_portrait.dart`) — race-ui, design request C.2 (done 2026-09-30: lane R: `RivalPortrait` draws `UiArt.rival(n)`; D205)
  - 2026-09-30 (phase 4, m7 P4.4): `ui/rivals/*` is delivered and in `UiArt.rival(n)`. Left: lane R draws them
- [x] The rival strip stops saying "Thinking…" once the player has won: today it keeps it under 9.4's scrim, because the rival's activity never leaves `thinking`. Until C.9 says what it shows, the state line goes blank once the race is over and the rival didn't finish; regression test in `rival_strip_test` — phase-2 device stage, m7 P2.9, design request C.9 (done 2026-09-29: `RivalStripData.over` from `RacePhase.finished`, the line blank unless the rival finished, `TODO(design)` C.9; `rival_strip_test`'s three new tests fail without it; D161)
- [x] A race-loss segment on a device (9.5, Pause in a race, Quit race) with a fast `NESTY_RACE_PACE_MS`; host tests cover it today (`race_result_overlay_test`, `gameplay_view_race_test`, `app_flow_test` (i)) — phase-2 device stage (phase 5's device run) (done 2026-09-30: D209: `race_loss_test` loss and oom pass on both platforms)
  - 2026-09-29 (D168): still open. The device run after the review ran `nesty-test`, which has no race-loss segment. R8's check fits in the same segment: after a loss, Rematch, back while the board loads; Pause must stay up and the rival must not move until Resume
  - 2026-09-30 (phase 4, m7 P4.4): lane R's new `integration_test/race_loss_test.dart` (a fast pace), wired by the integrator
  - 2026-09-30 (phase 4 integrated): `race_loss_test.dart` is wired into `nesty-test` (`--only race`: `loss` with `NESTY_RACE_PACE_MS=250`, then `oom`). Left: its device run (the device stage)
- [x] Close `nesty-test`'s device gaps (docs/TEST_COVERAGE.md, D169). Each gets a device step with a screenshot, in the playthrough or in its own `integration_test/*_test.dart` driven by `tools/scripts/nesty-test`, with a seeded save or a `NESTY_FAKE_DATE` where it needs one. Update the feature's row as each one lands: (done 2026-09-30: D209: every part's device step passes on both platforms; what a simulator can't show (haptics felt, the OS share sheet, a delivered notification) stays in TEST_COVERAGE's "Not on a device" with its host test)
  - gameplay: undo on a campaign board, the soft-stuck banner, relaxed mode's free undo, and the 10th bonus level's chest;
  - Settings: the Color symbols, Sound and Haptics toggles, with their effect;
  - Shop: using or buying a theme;
  - Daily: the day-7 chest, and a paused then relit streak;
  - race: a loss (9.5), Pause and Quit, Rematch, New race, and Out of Moves (the item above);
  - owner D169
  - 2026-09-30 (phase 4, m7 P4.3–P4.7): each lane's new device file closes its part: `board_layouts_test`, `race_loss_test`, `meta_screens_test`, `daily_states_test` (with `seedSave`) and `overlays_test`. What a lane can't make reliable stays here with its reason
  - 2026-09-30 (phase 4 integrated): every part has its device step in `nesty-test` (D202): gameplay (undo past the free ones and soft-stuck in `overlays_test`, relaxed undo in `daily_states_test settings`, the 10th bonus chest in `overlays_test`); Settings (`daily_states_test settings`); Shop (`meta_screens_test`: buying Forest Bear, using ch07); Daily (`daily_states_test chest` and `paused`); race (`race_loss_test`). Left: their device runs; what a run can't make reliable stays here with its reason
- [ ] Local player vs player (pass-and-play on one device), if the owner wants it offline: a proposal after vs Computer (the basis: alternating turns on one board, a family scoring for whoever completes it; brainstorm §6) — D90
  - 2026-09-29: the proposal is written, with no code: [plans/pass-and-play-proposal.md](plans/pass-and-play-proposal.md). It sets out three rule options for the owner to pick from (a shared board with alternating moves, the same board one player after the other, or co-op), how each fits the respect rules, what each reuses, a rough effort, and eight open questions. Next: the owner's answer

### Engagement (D92)

The owner approved these in principle on 2026-09-28. The rules are
spec-prop's text (Q85), and the numbers are defaults behind Remote Config
keys (Q76–Q87). Each feature passes the ethics checklist (brainstorm §5)
before it's merged, and its lane report records the answers.

- [x] E1, the respect rules (done 2026-09-29: every phase's tests are in: the copy and randomness tests, the race session test and phase 3's `stars_gate_nothing_test` and `reminder_opt_in_test`; `/review`'s ethics lens; D161):
  - tests that pin them: no race path offers hint or +1 Slot; every reminder, chest and streak ARB string is free of loss or guilt framing (a copy list checked in a test); the reminder is off on a fresh install; no reward reads a random source outside the seeded PRNG;
  - and a check in `/review`'s ethics lens.
  - spec-prop §1.1, brainstorm §5, D92
  - 2026-09-28: phase 1's parts are in: `test/ethics/respect_copy_test.dart`, `test/ethics/reward_randomness_test.dart` (now also the chest opening, D124) and `/review` step 5, the ethics lens. Left: the race's test (phase 2) and the reminder's (phase 3)
  - 2026-09-28: phase 2's contracts added the race's parts: the copy test checks `race*` and `hudRace*`, the randomness test scans `core/services/{race,ticker}` and `features/race`, and `arb_keys_m7_test` pins "Computer" on every rival surface (m7 P2.12)
  - 2026-09-28: phase 2's race session test is in (below). Left: the reminder's (phase 3)
  - 2026-09-29: phase 3's contracts added its parts: the copy test checks `reminder*`, `settingReminder*`, `dailyShare*` and the star keys, with a star-shaming list and a check that no reminder string names the streak; the randomness test scans `core/ui/widgets/stars`; `arb_keys_m7_test` pins the 26 keys (m7 P3.12). Left: `stars_gate_nothing_test` and `reminder_opt_in_test` (below)
- [x] E1's phase-3 tests (done 2026-09-29: `stars_gate_nothing_test` 3 tests, also checking that twenty 1★ and twenty 3★ wins leave the same save apart from the stars; `reminder_opt_in_test` 11 tests, with source checks that the one `requestPermission` call is `DailyReminder.enable` and that the real service schedules only `reminderId`; D161): `test/ethics/stars_gate_nothing_test.dart` (no reward, unlock or gate path names `levelStars`, `StarRating`, `StarRules` or `starsFor`, and every scanned path exists) and `test/ethics/reminder_opt_in_test.dart` (off on a fresh install, nothing scheduled or requested; the permission only after Yes; one pending id; no badge; the same text whatever the streak) — integrator, m7 P3.12, spec-prop §1.1, §7.9
- [x] E1's race session test (`test/ethics/race_respect_test.dart`) (done 2026-09-28: 4 tests; `respect_copy_test` also checks every string a race shows, its reused keys included, against the deny-list and a taunt list): a race on the real bloc and cubit never offers Hint or +1 Slot, coins only rise by the reward, a loss and a quit write nothing, nothing counts down — integrator, m7 P2.12, spec-prop §1.1
- [x] E2, the gentle streak (done 2026-09-28: `lit`/`run` in save schema 2 and `records.longestRun`, D96; `StreakDailyService` pauses and relights, the m7 §8 worked table in its test, D98; the copy rewritten, D110; the paused and relit stand-ins; Claude Design's I.7 replaces them in the fidelity pass):
  - `DailyProgress` gains `lit` and `longestRun` (a save schema step and migration);
  - `_reconcile` in `streak_daily_service.dart` stops zeroing the count and puts the flame out instead;
  - the chest stays on every 7th streak day;
  - rewrite the streak ARB copy without loss framing ("Play today to keep your streak" and its neighbours);
  - Daily tile and streak-card states lit, out and relit (design request I.7).
  - spec-prop §7.5, §13.3, D92
  - 2026-09-29 (M7 review R2, D163): a clock rolled back behind `lastDate` no longer grants a freeze for the older ISO week (`_reconcile` returns the progress unchanged); m7-design §8's pseudocode says so
- [ ] Paused daily streak (lastDate null) + clock rolled back to an earlier ISO week still grants that week's freeze and lets the past date relight the run; needs a high-water date in DailyProgress (owner decision, default: leave as is) — M7 review R2, Q153
- [x] E3, the daily share card (done 2026-09-29: built by the share lane and integrated; `di_test` binds `SharePlusShareService`/`FakeShareService`; `app_flow_test` (g) and the playthrough see Share on the solved card, never tapped; left, tracked elsewhere: G.6's copy and I.10's glyph in "Phase 3's stand-ins" below, the store link in M8; the device run is next):
  - a Share button on the Daily's done card;
  - a spoiler-free text (date, families, moves, streak day) through the OS share sheet with `share_plus` (a rule-9 reason in PROGRESS when added);
  - the text template comes from Claude Design (G.6);
  - add the store link in M8.
  - spec-prop §10.2 #11, design request I.1, D92
  - 2026-09-29: the contracts froze it (m7 P3.8, P3.9; D151): `share_plus` 13.3.0 with its rule-9 reason (D154), the `ShareService` interface, `DailyStatus.solve` from the save's `daily.lastSolve`, and the keys `dailyShare`, `dailyShareSemantics`, `dailyShareText`, `dailyShareFamilyGlyph`. The text is one 🪆 per family (at most 12), the families, the moves and the streak count (Q144). Left, for the share lane: `SharePlusShareService` and `FakeShareService`, `features/daily/share/daily_share_text.dart`, `DailyCubit.share`, `PuzzleCard.onShare` and their tests (P3.13)
  - 2026-09-29: the share lane built it (m7 P3.13): `SharePlusShareService` (maps `ShareResultStatus`, swallows every failure under `nesty.share`) and `FakeShareService`, both bound in `di.config.dart`; `shareDataOf`/`DailyShareText` in `features/daily/share/daily_share_text.dart` (null unless `solvedToday` and `DailyStatus.solve` is known — a day an older build solved shows no Share); `DailyCubit.share` (a pure delegate, no save or analytics touch); the Share button in `PuzzleCard`'s `_SolvedFooter`, shown only when `onShare` is non-null, its own `GlobalKey` giving `ShareService.shareText`'s `origin` for the iPad popover; `DailyView`'s `reminderOffer` slot (placed by the contracts, unchanged) stays gated on `solvedToday`. Tests: `share_plus_share_service_test.dart`, `fake_share_service_test.dart`, `daily_share_text_test.dart`, the `daily_page_test.dart`/`daily_overflow_test.dart` additions. Left open: the store link (M8) and the Share icon glyph (`TODO(design)` I.10 — stands in with `NestyIcons.download`)
- [x] E4, the opt-in daily reminder (done 2026-09-29: built by the reminder lane and integrated; `di_test` binds `LocalNotificationService`/`FakeNotificationService`, `DailyReminder` and `ReminderOfferCubit` in both envs; `reminder_opt_in_test`; `app_flow_test` (g) and the playthrough answer the offer "No thanks" and check Settings' row off; the optional Android check `nesty-test --android --only reminder`; the merged manifest has no exact-alarm permission; left, tracked below: the owner's phone check, and I.2's copy, icon and accent colour and I.10's glyphs in "Phase 3's stand-ins"):
  - a `NotificationService` interface with a real (`flutter_local_notifications` plus the time-zone scheduling it needs, each with a rule-9 reason) and a fake implementation, wired through DI for both environments;
  - the one-time offer on the Daily's done card after the first solve;
  - Settings rows for on/off and the time, default off; the default time is the hour of that first solve (Q81);
  - one notification a day, value copy only, no badge count;
  - Android 13 `POST_NOTIFICATIONS` and iOS permission asked only after the player says yes;
  - offline only, and it fails silently (rule 3).
  - spec-prop §7.9, design request I.2, D92
  - 2026-09-29: the contracts froze it (m7 P3.10; D152, D153): `flutter_local_notifications` 22.3.1, `timezone` 0.11.1 and `flutter_timezone` 5.1.0 with their rule-9 reasons, AGP 8.12.1 and desugaring (D154); the settings keys `reminderOn`, `reminderHour`, `reminderMinute`, `reminderOffered` and `DatabaseService.reminder` in Hive and the fake; `NotificationService` with its fake and a safe real stub; `DailyReminder` started from `bootstrap`; the offer's cubit and card, hidden; `DailyView`'s offer slot; the 14 reminder keys. Left, for the reminder lane: the real `LocalNotificationService` and its detail builders, `DailyReminder`'s refresh queue, enable, disable and setTime, the offer's steps, the Settings rows, the manifest, the notification icon and `AppDelegate.swift`, and their tests (P3.13). Questions Q137–Q143
  - 2026-09-29: the reminder lane built it (m7 P3.13): `LocalNotificationService` (init never prompts, permission reads/requests split by platform, `scheduleDaily` skips a call identical to the last (plan, zone), `hasPendingDaily` reads the plugin's own pending list — every method catches everything under `nesty.notifications`) and the pure `reminder_notification_details.dart` (the Android/iOS details, the init settings, `nextDailyOccurrence` built from calendar components so DST in `America/New_York` lands on the right wall-clock time and offset, and `fixedOffsetLocation` for an unrecognised zone id); `DailyReminder`'s refresh queue (coalescing: one in flight, one more queued), `enable`/`disable`/`setTime`, the resume listener (renamed `didChangeAppLifecycle`, `@visibleForTesting`, matching `SaveLifecycleFlusher`); the offer's four steps and its card (`NestySurface`, `OverlayTextLink` for "Change time", `NestyCloseButton`); the Settings toggle and time row (hidden until `available`, the blocked subtitle, a `NestyToast` on a denied toggle); the Android manifest (`POST_NOTIFICATIONS`, `RECEIVE_BOOT_COMPLETED`, both FLN receivers, an exact-alarm `tools:node="remove"`), the stand-in `ic_notification.xml` (a traced doll silhouette) plus `keep.xml`, and the iOS `AppDelegate.swift` delegate. Tests: `reminder_notification_details_test.dart` (the DST and zone-fallback cases), `local_notification_service_test.dart` (a throwing Android/iOS plugin double proving every method's "never throws" promise, plus a recording double for the schedule/skip/cancel behaviour), `daily_reminder_test.dart`, `reminder_offer_cubit_test.dart`, `reminder_offer_card_test.dart`, the `settings_cubit_test.dart`/`settings_page_test.dart` additions, `test/overflow/{settings,reminder_offer}_overflow_test.dart`. One reading not settled by the frozen text: `DailyReminder.enable`'s denied branch still persists the chosen hour/minute and `offered` (only `on` differs from the granted branch), so a denied Yes never loses the player's time choice — recorded as a question, default shipped. Left open: Claude Design's I.2 copy, icon and accent colour; I.10's glyphs (no share/bell/clock icon exists yet, so the offer and Settings reuse `NestyIcons.calendarToday`); the integrator's `di_test`, `stars_gate_nothing_test`/`reminder_opt_in_test`, the playthrough's reminder steps and the optional Android device check (P3.13)
  - 2026-09-29: integrated (D161): `di_test`, the two E1 tests, `app_flow_test` (g), the playthrough's offer and Settings steps, and `integration_test/reminder_test.dart` (Android only: on in Settings → one pending, off → none, `POST_NOTIFICATIONS` granted with `pm grant` first) run by `nesty-test --android --only reminder`
- [x] The phase-3 device run (done 2026-09-29: both devices, D162): the playthrough's star, share and offer steps (screenshots `06a_win_stars`, `01h_chapters`, `01j_replay_win`, `01k2_records_stars`, `09a5_daily_share_and_offer`, `09a6_settings_reminder_off`), the resume and daily checks unchanged, on the iPhone 16 Pro simulator and the API 35 emulator from fresh installs; then `nesty-test --android --only reminder` on the emulator — the device stage, m7 P3.13
  - 2026-09-29: run on both devices from fresh installs, all PASS (device stage): the iPhone 16 Pro simulator (iOS 18.3) and the API 35 emulator, 90 screenshots each; resume A = B and daily = core on both; `nesty-test --android --only reminder` PASS (on gives one pending reminder, off none); iOS made no notification authorization request (simulator log); two UI fixes from the run (D162)
- [ ] The owner's phone check of the reminder: one delivered at the chosen time, then Doze batching, a time-zone change while the app is closed, a DST change and Android's force-stop, on a real Android phone and an iPhone; a simulator proves little here — owner, plan-m7 "Verification", m7 P3.10, architecture risk 3
  - 2026-09-29 (D168): on the API 35 emulator, `nesty-test --android --only reminder` passes in Asia/Kathmandu and again in Europe/Amsterdam, a zone `latest_10y` lacks. The log shows the fallback, and on still gives one pending reminder (R9). The phone check itself is still the owner's
  - 2026-09-30 (D209): the Android small icon is now generated from Claude Design's `ui/notification/ic_notification.svg`. It renders as the doll silhouette on the host; the phone check also confirms it on a delivered reminder, with the accent #F2893B
- [x] E5, the milestone chest (done 2026-09-28: `MilestoneChest`, paid in the win's update, D103; `MilestoneChestModal` in the overlay chain and the win card's countdown; the animated opening, D120; its art from I.3 in the fidelity pass):
  - at level 10 of each chapter (L10, L30 … L190) and every 10th bonus level;
  - `chest_coins` 100 and `chest_hints` 1 by default (Q76);
  - contents shown before opening; the day-7 chest modal's system;
  - the win card's progress alternates with the figurine bar, whichever goal is nearer;
  - `chests.opened` in the save; never on a replay.
  - spec-prop §7.3, §13.3, design request I.3, D92
- [x] E6, relaxed mode (done 2026-09-28: the `relaxed` setting read live by the bloc, D99, D104; the Settings row; `BoosterBadge.infinite()` and the Out-of-Moves "Always free" row):
  - a Settings toggle, off by default;
  - undo becomes free and unlimited, and its price and ad rows are hidden (Q84); coins are still earned;
  - the HUD's undo shows "∞".
  - spec-prop §8, design request I.2, D92
- [x] E7, replay and best moves (done 2026-09-28: `PlayRequest.replay`, D100; `levelBests` in save schema 2, D102; Chapters, D118; the win card's "Moves · Best", the replay card and chip):
  - a Chapters list (20 levels a chapter, won marks, best moves); replaying a won level pays nothing and never moves `currentLevel`, the chest or the Museum;
  - `levelBests` keyed by level id and version (a schema step);
  - the win card shows "Moves 18 · Best 16", and moves are never shown during play.
  - spec-prop §7.1, §13.3, design request I.4–I.5, D92
  - 2026-09-29: the owner had the HUD's "Replay" tag removed: it looked like a button that did nothing, and the win card already says a replay pays no coins (D170; `gameplay_view_test` checks a replay shows no tag, and the playthrough checks it on a device)
- [x] E8, Records and badges (done 2026-09-28: `RecordRules`, `BadgeRules` and the twelve badges, D105, D106; the Records screen with its badge grid and the win card's toasts; the races per rival read 0 until phase 2, and the names and glyphs are Claude Design's I.6):
  - a Records screen (levels, families, dolls nested, dailies, the longest unbroken streak, races per rival, best moves);
  - about 12 cosmetic badges with deterministic triggers: Claude Code proposes the list in the brainstorm doc (Q83) and Claude Design names and draws them;
  - a "badge earned" toast;
  - `records` in the save.
  - spec-prop §7.8, §13.3, design request I.6, D92
- [x] E9, first launch opens L1 (done 2026-09-28: `SplashState.opensFirstLevel` and the splash page's route, D107, D123; the first win's Continue goes Home; the router, music and app-flow tests; the playthrough and resume phase A rewritten, their device run in the next stage; M6's consent step comes later):
  - a fresh save goes from the splash straight into L1's tutorial, after consent once M6 adds it;
  - Home appears after the first win, and returning players are unchanged;
  - update the playthrough and resume scenarios that tap Home's PLAY first.
  - spec-prop §10.1, D92
- [x] E12, `bundle check` gates (done 2026-09-28: `layout_signature.dart`, `BundlePolicy.checkVariety`, expert-only an error from L31, `maxSize` 6 only on super hard slots, D114; tools/README.md's `bundle check` row):
  - a layout signature per level (shelves × slots, towers and depth, glass, ice, colours, maxSize), with no two consecutive levels alike outside the tutorial;
  - an expert-only level (smart win rate under 0.5) is an error for L31–200, instead of today's warning.
  - `tools/lib/src/levels/bundle_policy.dart`, brainstorm §3–§4, D92
- [ ] E13, time to first win:
  - the fresh-install playthrough records the time from launch to L1's first playable frame, and that no screen stands in between;
  - the owner's device check notes the seconds.
  - 2026-09-28 device run: the iOS simulator 2,349 ms to playable and 2,609 ms to level 1 alone on screen (from `main()`); the API 35 emulator 3,582–17,336 ms, too variable to use; both times in `e13.json` beside the screenshots and in `nesty-test`'s E13 row; left: the owner's seconds (Q114).
  - brainstorm §3, D92
  - 2026-09-28: the playthrough reports it (`NESTY_E13`, `playthrough.json`; `nesty-test` prints it), from `main()` to L1's first playable frame, with no screen in between (D123, Q114); left: a device run and the owner's seconds
- [x] E14, reduce motion in Settings: on, off or system, with sounds and haptics at full strength. It feeds `FxDrawableParams.reducedMotion`, which follows the OS today — spec-prop §16, §16, D92 (done 2026-09-28: the `reduceMotion` setting, D99; the app root's `MediaQuery` override, D108; the Settings row and its three-way sheet; the board swaps its `MotionSpec` mid-level)

### Star rating (owner 2026-09-28, D125)

The owner asked for 1 to 3 stars per level, and chose the rules:
- stars come from moves against par (3★ within par + 20 %, 2★ within
  par + 60 %, 1★ for any win);
- a hint or an extra slot caps a win at 2★;
- stars apply to levels 1–200 and their replays;
- they are cosmetic only.

The rule is spec-prop §7.10, and the plan is
[plans/star-rating.md](plans/star-rating.md). It is built in phase 3. The
stand-ins ship until Claude Design's section K lands.

- [x] The rule in core (done 2026-09-29: stars-core: the full threshold table, the bands, the cap and `starsForWin`; parity digests from `test/rules/reference/starref.py` on the VM, node, Chrome and dart2wasm; par equal to the BFS oracle on every solvable fixture, `test/solver/par_oracle_test.dart`; D157): `StarRating` in `rules/star_rating.dart`, with the thresholds (`par + ⌈par × slack ÷ 100⌉`) and the 2★ cap, exported from the barrel. Tests: the threshold table and node parity — spec-prop §7.10, star-rating.md
  - 2026-09-29: the contracts built and froze it with `starsForWin` and minimal tests (m7 P3.3, D145). Left, for stars-core: the full table, the parity digest on node, chrome and dart2wasm, the BFS-oracle check (P3.13)
- [x] Par in the bundle (done 2026-09-29: stars-core: `bundle build` writes the rule-8 optimum and fails with `build.parUnproven`; `bundle check` fails with `bundle.parMismatch`; `bundle.json` rebuilt with only the 200 `par` lines added (par 2–35); L1–L30's digest `6eb213699ab72200` pinned in `repo_levels_test`; the READMEs; `report --stars`; D157):
  - `LevelBundleEntry.par`, read leniently;
  - `nesty_levels bundle build` writes the solver's optimal length (admin budget), and `bundle check` fails on a mismatch;
  - rebuild `bundle.json`: entries only, and no level's data or version changes;
  - `tools/levels/README.md`.

  — star-rating.md "Rules" 1
  - 2026-09-29: the contracts built `LevelBundleEntry.par` and its lenient codec (m7 P3.3, D146). Left, for stars-core: `bundle build`/`check` with par (`build.parUnproven`, `bundle.parMismatch`), the bundle rebuild, the READMEs and their tests (P3.13)
- [x] Remote Config keys `star3_slack_pct` (20) and `star2_slack_pct` (60), with hard-coded defaults (rule 6) — spec-prop §9.4 (done 2026-09-29: in `RemoteConfigKeys.all`, 31 keys, clamped by `StarRules.slackOf`; m7 P3.3, D145)
- [x] Save (done 2026-09-29: the contracts' implementation with stars-app's tests: the four fields in the codec and Hive round trips, the schema-1 fixture migrating with them empty, best stars per id across a new version (Q117), the backfill; D147, D158):
  - `levelStars` (per level id, keeping the highest). It joins schema 2's one migration, since schema 2 hasn't shipped;
  - `LevelWinRecord.stars`, `LevelWinOutcome.stars` and `previousStars`;
  - `RecordsSummary.stars` and `threeStarLevels`;
  - the silent load-time backfill (Q120).

  — spec-prop §13.3, star-rating.md
  - 2026-09-29: the contracts built and froze them in schema 2 with `starTipShown`, `daily.lastSolve` and `inProgress.hinted`, `backfillLevelStars`, `StarRules`, `RecordsSummary.stars`/`starsPossible`/`threeStarLevels` and `PlayEntry.par` (m7 P3.4, P3.5, D147). Left, for stars-app: the full save, codec, migration and backfill tests, the fixture pars (P3.13)
- [x] Gameplay bloc (done 2026-09-29: stars-app: `_hintSinceRestart` saved as `inProgress.hinted` when the hint arrives, cleared by Restart; the win's stars, target and tip; the splash's backfill; 12 `blocTest`s at the boundaries, the caps, a kill and restore, relaxed undo, a replay's best, the daily, bonus and race computing none; D158):
  - the attempt's `assisted` flag (Q116);
  - `StarRating.starsFor` at the win, with the Remote Config slack;
  - `GameplayState.stars`, `previousStars` and `starTarget`;
  - replays can raise stars; the daily, bonus and race compute none.

  — star-rating.md
  - 2026-09-29: the contracts froze the state (`stars`, `previousStars`, `starTarget`, `starTip`, `starsNewBest`; m7 P3.6, D148). Left, for stars-app: the bloc's `_hintSinceRestart` and `_win`, the splash's backfill call and their `blocTest`s (P3.6, P3.13)
- [x] The UI stand-ins, each with `TODO(design)` (done 2026-09-29: stars-ui: the reveal from 1,300 ms, the clack cues and the 3★ flourish, reduce motion; the win card's row, target line, "New best!" and tip; Chapters' cell stars and `StarsTotal`; Records' two rows; the overflow sweeps at the 5 sizes × 1.0/1.3; Chapters' scroll-to-current fix; D159. The art and motion stay open in "Phase 3's stand-ins" and "When Claude Design's K lands" below):
  - `StarRow` in `core/ui/widgets/stars/`, the one swap point for the art and motion;
  - the win card's stars: they pop in one by one, each with a pitched sound and a haptic, then the 3★ flourish; under reduce motion they appear at once;
  - the replay card's target line (Q118) and "New best!";
  - the one-time tip (Q119);
  - Chapters' stars per won level and each chapter's total;
  - Records' "Stars" and "Levels with 3 stars";
  - overflow at the 5 sizes × 1.0/1.3.

  — star-rating.md, design request K
  - 2026-09-29: the contracts froze `StarRow` as a static stand-in (a painted star; sizes 44/20/11) and filled the Chapters data (`ChapterLevel.stars`, `ChapterSection.stars`/`starsPossible`; m7 P3.7, D149, D150). Left, for stars-ui: the reveal from 1,300 ms with its cues and the 3★ flourish, reduce motion (Q146), the win card, Chapters, Records and the overflow tests (P3.7, P3.13)
- [x] E1 for stars (done 2026-09-29: `stars_gate_nothing_test`, D161):
  - the star ARB keys in `respect_copy_test`'s deny-list;
  - a test that no unlock, reward or gate reads `levelStars`;
  - `reward_randomness_test` over the new paths.

  — spec-prop §1.1, star-rating.md "Ethics checklist"
  - 2026-09-29: the copy and randomness parts are in (m7 P3.12, D155); left: `stars_gate_nothing_test` (the E1 item above)
- [x] The playthrough (done 2026-09-29: both devices, D162): L1's win shows its stars, and a replay that wins with more moves keeps the best. Screenshots of the win card and of Chapters — star-rating.md "Tests"
  - 2026-09-29: the integrator's steps are in m7 P3.13 (L1 at 3★, the L1 replay in 4 moves at 2★ with the target line and no "New best!", Chapters keeping 3★, Records' "Stars"), with the share and offer screenshots of E3 and E4
  - 2026-09-29: written (D161): `06a_win_stars` (L1's 3 stars), Chapters' "Level 1, won, best 2 moves, 3 of 3 stars" (`01h_chapters`), the replay `r0c2>r0c1 r0c1>r1c2 r1c2>r0c0 r1c1>r0c0` checked with `Rules.tryMove` ("Moves 4 · Best 2", 2 stars, "3 stars at 3 moves or fewer", no "New best!", `levelStars` still 3; `01j_replay_win`), Chapters keeping 3★, Records' "3/600" (`01k2_records_stars`). Left: the device run (the phase-3 device run item above)
  - 2026-09-29: run on both devices, all PASS (D162)
- [ ] Before release, a levels-tool report of the smart and casual bots' star shares per chapter at the default slack, so the owner can tune the two keys — star-rating.md
  - 2026-09-29: `nesty_levels report --stars` is stars-core's (m7 P3.3); left after it: the owner reads it
  - 2026-09-29: built (D157); at 20/60 over all levels, the casual bot's wins are 24.0 / 47.9 / 27.9 % at 3★/2★/1★ and the smart bot's 98.6 / 1.3 / 0.0 %; the per-chapter table is in `tools/levels/README.md` "Par and the star shares". Left: the owner reads it and tunes the keys
- [x] The replay card's line about the hint or +1 Slot cap, if design request K.4 asks for one (nothing is built for it today) — stars-ui, Q145, design request K.4 (done 2026-09-30: lane O: the helper note on `starsCapped`, which wins over the tip (`win_overlay_test`); D191, D208)
  - 2026-09-30 (phase 4, m7 P4.7): copy.md G.11's `starsHelperNote`, shown on `GameplayState.starsCapped` (Q145 answered, D191). Left: lane O draws it
- [x] Phase 3's stand-ins, each with `TODO(design)`, against Claude Design's delivery: the painted star (K.1, K.6), the reveal and its clack cues (K.3), the offer card and the Settings reminder rows (I.2), the time picker (I.2 leaves it open), the Share and reminder glyphs (none in the subset, I.10), the Android notification icon traced from the doll art (I.2 "Delivery") — m7 P3.7, P3.9, P3.10, design request K, I.1, I.2, I.10 (done 2026-09-30: lane O's star art and `ui_stars` reveal, lane D's reminder dialog, Settings rows and `notificationAccent`, `IconUses` for the Share and reminder glyphs, the generated notification icon (C4a); the platform time picker stays, as I.2 leaves it open; D188, D190, D191, D207, D208)
  - 2026-09-29: the lanes' stand-ins, all noted in the design request (G.6, I.2, I.10, K.3, K.5): the 3★ flourish's hand-painted glow for `fx_twinkle` (K.3), `StarsTotal`'s one star beside a chapter's numbers (K.5), `NestyIcons.download` for Share and `calendarToday` for the offer and both reminder rows (I.10), Flutter's `showTimePicker` (I.2), and G.6's text
  - 2026-09-30 (phase 4, m7 P4.6, P4.7): K, I.1, I.2 and I.10 are delivered; lanes O and D replace them (D188, D190, D191)
- [x] When Claude Design's K lands, take it through the swap points in star-rating.md "When Claude Design delivers section K": the star art, the `ui_stars` Lottie, the `star_1`–`star_3` SFX, the tokens, frames 11.1–11.5 and copy G.11 — design request K (done 2026-09-30: lane O: `StarRow` on `UiArt`'s stars, `StarRow.reveal` on `ui_stars` with `star_1`–`star_3`, the reduce-motion cue (D191); lane M: the totals and chips of 11.5 (D206))
  - 2026-09-30 (phase 4, m7 P4.7): K is delivered: `ui/stars/*` in `UiArt`, `ui_stars` through `UiArtImageSource`, `SoundEffect.star1..3` (C4b). Left: lane O

### The owner's simulator review (2026-09-28)

- [x] Home: drop the Museum tile (the bottom nav's Museum tab covers it); the tiles are Daily, Remove Ads and vs Computer — owner 2026-09-28, D111, frame 2.1, design request J.1 (done 2026-09-28: `_TilesRow` has three tiles; `home_page_test` and `app_flow_test` pin it; the device stage screenshots it)
- [x] Chapters (E7): cool, clean, elegant and engaging, not a plain number grid. Improve the stand-in now (the chapter's theme and figurine, its progress, the current level standing out, won and locked levels readable at a glance, no stars or nags), then take Claude Design's 10.4 — owner 2026-09-28, design request I.4 (done 2026-09-30: lane M built frames 10.4 and 10.4b: theme crops, palette headers, the accordion, the level card with its replay (`chapters_page_test`, `level_card_test`, the overflow sweep); D206)
  - 2026-09-28: the stand-in v2 is in (menus, owner-home, D118: the emblem, progress, the current cell's glow, a finished chapter folded, the scroll to the current chapter, the chest and finale marks, the tier edges, "Level N of 200", the fade-in); left: Claude Design's 10.4 (and Q113)
  - 2026-09-28: the owner then asked for star ratings (D125). Won levels will show their best stars, and each chapter its total ("Star rating" above). "No nags" still holds
  - 2026-09-30 (phase 4, m7 P4.5): frames 10.4 and 10.4b are delivered (Q113 answered, D193). Left: lane M
- [x] Shop (bug): equipping a skin doesn't show "Equipped" on the Skins grid until the page is reopened — owner 2026-09-28, frame 7.3 (done 2026-09-28: the Shop's cubits follow `selectedSkinChanges`, D119; regression tests with a genuinely async skin service)
- [x] Museum: the owner finds 6.1 hard to understand and flat. Now: say what the Museum is and how a family is earned, make the next family the focus, name each locked shelf by its chapter and levels, and never show "soon" on a chapter whose 20 levels are all won (seen as "Classic · soon" with a 20/20 badge after Jump to a level); then Claude Design's redesign — owner 2026-09-28, frames 6.1–6.3, design request J.2 (done 2026-09-30: lane M built frames 6.1–6.1c: the intro, the next-family card, the lit cabinet with brass plates and two-line locked labels, the all-home card (`museum_page_test`, the overflow sweep); D206)
  - 2026-09-28: the "Now" part is in (menus, D118: the intro line, the next family's row with Play, the locked shelves' "Chapter N · Levels X–Y", "earned" derived from the won levels); left: Claude Design's redesign (and Q115)
  - 2026-09-28 (device stage): the locked-shelf labels were cut by an ellipsis on every phone width; they scale down to fit now, 3 dp apart (`museum_cabinet.dart`, `museum_page_test` 'every cabinet label shows whole'); their size waits for J.2 (`TODO(design)`)
  - 2026-09-30 (phase 4, m7 P4.5): frames 6.1–6.1c are delivered (Q115 and Q123 answered, D193); C4b removed the Chapters link. Left: lane M
- [x] Not enough coins: a tap on a price the balance can't cover opens a dialog first (the price, how many more coins, where coins come from) with "Go to Shop" and "Not now", on the Shop's skin cards, theme cards and skin detail; the booster popup keeps its disabled coin button (3.2, 3.8) until Claude Design says otherwise — owner 2026-09-28, D112 (replaces D86), design request J.3 (done 2026-09-28: `NotEnoughCoinsDialog`, D119; its copy and look wait on J.3 and G.10)
- [x] Jump to a level (dev flavor, bug): with 200 levels the grid draws outside its sheet, over Home, and hides the title; keep it inside a scrolling sheet, grouped by chapter (done 2026-09-28). Cause: `NestySheet`'s scroll area didn't clip (`Clip.none`), so every sheet that scrolls painted its rows over its title. Fixed there (pixel test `test/core/ui/nesty_sheet_clip_test.dart`). The picker is now grouped by chapter, with a close button. Confirmed on the iPhone 16 Pro simulator and the API 35 emulator (2026-09-28, `23a_level_picker_scrolled`) — owner 2026-09-28, `features/dev/level_picker_sheet.dart`, `core/ui/widgets/sheet/nesty_sheet.dart`
- [x] Chests (the milestone chest and the day-7 chest, 5.6): opening one should be a small reward moment, not a static card. Build it now from the existing art and Lottie (the chest drops in and breathes, wiggles, bursts open with coins and sparkles, the chips pop, then Collect flies the coins to the HUD's coin pill and the hint to the Hint button; a crossfade under reduce motion). Then swap in Claude Design's chest Lottie, art and SFX — owner 2026-09-28, m7 §9, design request I.3 (done 2026-09-30: lane O rebuilt the moment on `ui_chest` (arrive, idle, wiggle, open, open_idle), the chips at their promised amounts, Collect's flights and bumps, reduce motion's crossfade (`chest_reward_sequence_test`); lane D's day-7 modal shares it; D207, D208)
  - 2026-09-28: built (owner-chest's `ChestRewardSequence`, D120; the day-7 chest's coins fly to the Daily header's pill, D124); left: Claude Design's I.3 assets (`TODO(design)` in `chest_reward_sequence.dart`)
  - 2026-09-28 (device stage): the four states on both platforms (`19a`–`19d`); the coin chip counts up from 0 on Open (new item)
  - 2026-09-30 (phase 4, m7 P4.6, P4.7): I.3 is delivered (`ui_chest`, the chest art, the sprites); `ChestIcon` draws the art (C4b). Left: lanes O and D
- [x] A way to reach the day-7 chest on a device for the owner's check (it needs a 7-day streak: a dev-flavor streak seed, or `NESTY_FAKE_DATE` runs over a week with `--keep-app-running`); today only the widget tests open it — lead notes, integrator (done 2026-09-30: D209: `daily_states_test chest` opens it from a seeded 6-day streak on both platforms)
  - 2026-09-30 (phase 4, m7 P4.6): lane D's `integration_test/daily_states_test.dart`, a 6-day streak through `seedSave` and `NESTY_FAKE_DATE`
  - 2026-09-30 (phase 4 integrated): wired into `nesty-test` (`--only daily_states`, scenario `chest`, `NESTY_FAKE_DATE`). Left: its device run

- [ ] Fidelity pass, screen by screen, against every App Flow frame (01–08) with `ui-designer`, then owner sign-off — §18 M7
- [x] Home's shelf after a skin equip: `ShowcaseDolls` keys its art on the pixel ratio and the symbols mode, not the skin, and nothing tells it about `SkinService.selectSkin`, so after an equip in the Shop the Home shelf keeps the old skin until the app restarts (found by reading the code while fixing D91; not yet seen on a device) — §7.4, D58, D91 (done 2026-09-28: `ShowcaseDolls` follows `SkinService.selectedSkinChanges`, D109; `showcase_dolls_test.dart`)
- [ ] Tune the haptic patterns, including the multi-pulse success, on real devices (moved from M3: it needs the owner's hands on real phones; `TODO(M7)` in `system_haptics_service.dart`) — §11.2, PROGRESS "Notes for later milestones"
- [x] The Daily puzzle card's preview: draw the chapter background under its plank (NestyMenus isDaily, `backgrounds/ch3-seaside-market.svg` at center 42%/cover). `SkinService.background` is the one full-screen raster, so it needs a small per-card theme raster (`TODO(M7)` in `features/daily/widgets/puzzle_card.dart`) — frame 5.1, M3 review FIDELITY-2 (done 2026-09-28: `DailyBackgroundLoader` and `DailyThemeBackground`, the menus lane; `daily_background_loader_test.dart`)
- [x] "Play Bonus Level N" on All Levels Done when that level can't be generated: the card stays up with its button live. Continue's failure already has `NextLevelFailedCard`; give this path the same (`TODO(M7)` in `gameplay_view.dart`) — M3 review CORRECTNESS-3 follow-up (done 2026-09-28: `_pendingBonusRetry` and the retry card, the gameplay-ui lane; `gameplay_view_test`)
- [x] A restored out-of-moves board whose intro card was never dismissed shows the card over the reopened sheet, whose rows wait for "Got it" (`TODO(M7)` in `gameplay_view.dart`) — M3 review CORRECTNESS-1 follow-up (done 2026-09-28: the sheet waits for the card, the gameplay-ui lane; `gameplay_view_test`)
- [x] Overflow tests on small Android, standard phone, tall phone, small iPhone and iPad portrait, at 1.0× and 1.3× text — §18 M7, §16 (done 2026-09-28: `test/overflow/`, 21 files over `overflowScreenSizes` × `textScales`, D121; every screen and overlay, the real Chapters and Records grids, the chest modals open and closed, the win card variants, the new Settings rows and the Daily states, paused included)
- [ ] Sweep the fully navigated bottom-nav shell (Home under the real router) for overflow at the five sizes, beside today's chrome-and-`HomeView` sweep, if Q112 says so — overflow lane report
- [ ] Animation polish: tune by feel each clip's playback speed (never the JSON), the hand-coded tweens of lottie §9 (`TODO(M7)`), the wobble snap into `doll_move` (settle it before the move), an animated undo (`BoardResetEffect(undo)` cuts today), re-placing the clips in flight during a +1 Slot re-pitch, the coin count-up (700–1300 ms) guess, and the intro-card loops. The tower reveal's drop now comes from `doll_reveal` (D60) — §11.1, lottie §7, §9, timeline report
- [x] Swap in the designer's Lottie re-export when it arrives (done 2026-09-27: Claude Design v3, imported in the post-M2 round, D59, D60) — re-export, lottie §18, D43:
  - re-sync (`sync_design_assets`) and regenerate `fx_spec.gen.dart` (`gen_fx_spec`). Any change to a length, a marker, the canvas or a hook fails validation until `tools/lib/src/fx/lottie_contract.dart` is updated, and its test also reads LOTTIE.md, so LOTTIE.md must agree;
  - before any lottie upgrade, rerun `fx_compensation_test`, `fx_travel_test` and `fx_workarounds_test`: they pin lottie 3.6.1's internals;
  - remove each workaround whose cause is fixed (hold fix, padlock hide, settle ramp, reveal silhouette hide, animated-scale callbacks);
  - keep the equivalence tests green.
- [ ] Tabular figures for coins and counters. Fredoka's digits are proportional and it has no `tnum` feature, so `AppTextStyleTokens.number`'s `FontFeature.tabularFigures()` does nothing (Nunito's digits are already fixed-width). Build the approach the owner picks (Q29) in `NestyNumberText` (`TODO(M7)` there and in `app_text_styles.dart`) (moved from M2: the approach waits on the owner) — design/README.md "Typography & icons", tokens.json `fontSize.number.tabular`, tools/fonts audit
- [x] +1 Slot plays `button` twice: the booster's tactile feedback and the timeline's `ExtraSlotAddedEffect` cue (m2-lottie-design §7 lists the cue). Keep one — review fix pass (done 2026-09-28: the timeline's cue is gone, D116, Q110; `board_timeline_boosters_test`)
- [x] Final audio: replace the placeholder WAVs, normalize levels, re-check the clack pitch offset, and add the music loops (done 2026-09-27: the SFX v2 WAVs baked at 0 semitones, the two OGG loops and three jingles, D61) — §11.3, D19, services report
- [ ] Final mix by ear on a mid-range Android and an iPhone: `SfxMix.gains`, the music's 0.5 and the ducks, the jingles over ducked music. The worst realistic stack has about 0.14 dB of headroom: keep the cues staggered, and turn on SoLoud's limiter only if clipping is heard — audio plan §2 "Clipping", audio audit §5
- [ ] Optional: keep Nesty's music off while another app plays audio (iOS `secondaryAudioShouldBeSilencedHint`) — Q61, audio plan
- [x] The `ui_extra_slot` loop starts at its rest pose (96 %, 75 % opacity) when the 300 ms re-pitch ends, after the static pad drew the stand at 100 %: a small pop. Start it at frame 24 (100 %) or fade it in — lottie lane report, `board_pieces_l9_test.dart` (done 2026-09-28: it starts at frame 24, `FxTiming.extraSlotRestFrame`, D116)
- [x] The `ui_extra_slot` loop's opacity is still about 88 % at frame 24 (its opacity ramps on a slower curve than its scale and reaches 100 % near frame 44): a smaller pop than before. Take Claude Design's E.21 or crossfade it in, with the animation polish pass — board-fx report, Q111, `board_pieces_l9_test.dart` (done 2026-09-30: lane B: the loop starts on the `rest` marker (frame 0, the static pad's pose), settles and stops under a doll and restarts when empty (`board_pieces_l9_test`); D184, D204)
  - 2026-09-30 (phase 4, m7 P4.3): m7-3's file rests on frame 0 (the `rest` marker; D178, D184). Left: lane B
- [ ] Device check: the gameplay skin lands within the route transition (`prepareForLevel` starts on the board's first layout; placeholder dolls show until it lands) — screens report
- [x] Integrate chapter themes 7–10, per-theme shelf and stand art, and `palette` accents once supplied — §12.4 (done 2026-09-30: ch07–ch10 and every palette in `ChapterTheme`, D199; per-theme shelf and stand art is not needed, every theme shares the wood (DELIVERY A.5))
- [x] Importing a Claude Design delivery (phase 4) (done 2026-09-30: `nesty-design-m7-3`, the whole round, passed every check below and is in `design/`, copied at the owner's request, D171). The request's "Delivery: the download folder" fixes the format:
  - check the folder against it: the layout, the names, `DELIVERY.md`, the SVG subset, every sound named in `tokens.json`, and every Lottie with its LOTTIE.md row;
  - diff it against `design/` (new, changed, missing) and show the owner. Copy it in only with the owner's OK, because `design/` is theirs, and never delete a file unless `DELIVERY.md` says so.

  — design request "Delivery", CLAUDE.md
- [x] `sync_design_assets` maps the new `design/ui/**` folders (badges, chest, icons, notification, rivals, sprites, stars) and the optional `board/chNN/**`, and turns `ui/notification/ic_notification.svg` into each flavor's Android drawable — design request "Delivery" 3 (done 2026-09-30: C4a, D176)
- [x] In the same change that syncs I.2's `ui/notification/ic_notification.svg`, swap the reminder's stand-in Android accent (`reminder_notification_details.dart`'s `color: AppColorTokens.primary`, `TODO(design) I.2`) for I.2's accent colour: a new colour token that nothing reads fails no check, so a missed swap would ship silently — M7 review R4 (done 2026-09-30: lane D: `reminder_notification_details.dart` reads `AppColorTokens.notificationAccent` (`#F2893B`; `reminder_notification_details_test`); D207)
  - 2026-09-30 (phase 4, m7 P4.6): the drawable is generated (C4a, D176). Left: lane D's accent swap to `AppColorTokens.notificationAccent`
- [x] The new Lottie rows (`ui_chest`, `ui_stars`, `ui_intro_towers`, `ui_intro_glass`, `ui_intro_ice`, optionally `ui_rival_react`) go into `tools/lib/src/fx/lottie_contract.dart`, matching LOTTIE.md; then `gen_fx_spec` — design request C.6, D, I.3, K.3 (done 2026-09-30: C4a, D174, D175; `ui_rival_react` was not delivered and is dropped)
- [x] The new icon glyphs (I.10, C.8, from `tokens.json`'s `icons` map) go into `tools/fonts/nesty_symbols.txt`; then `tools/fonts/build_fonts.sh` and `gen_nesty_icons` — design request I.10 (done 2026-09-30: C4a, D177; `IconUses` maps every use, C4b)
- [x] `copy.md` into the ARB file by id (G.1–G.11). Each key keeps its name and drops "Placeholder" from its description — design request G, "Delivery" 6 (done 2026-09-30: C4b, D196, D197; m7 P4.8)
- [ ] `shopOwned` ("Owned", read to a screen reader after an owned skin card's name) is a stand-in that the design request's copy list doesn't name: ask Claude Design for it with the next copy request, or confirm "Owned" — M7 review R14
  - 2026-09-30 (phase 4): `shopOwned` ("Owned") is not in copy.md m7-3 either; ask in the next Claude Design copy request
  - 2026-09-30 (phase 4 integrated): asked in `claude-design-request-m7.md` "Follow-up after m7-3" §2.1
- [ ] Translations: es, pt-BR, id, hi, de, fr, tr, ja — §16
- [x] The Flame board's "+N" tower tag and the ice badge's digits through ARB, with the locale's text direction, handed to `SlotDecor` when the board is built (`TODO(M7)` in `slot_decor.dart`). Every launch language writes "+3" the same way today — §16, review PERF-RULES-3 (done 2026-09-28: `BoardLabels` from `boardTowerHidden`/`boardIceCount`, D116; `slot_decor_test`, `board_tree_test`, and `gameplay_view_test`'s non-English label)
- [ ] A silent load-time catch-up that writes `museum`/`museumCollected` for a chapter whose levels are all won (like the badges' grant on load), so the stored Museum agrees with the one the screens derive (D118) — menus lane report
- [x] Accessibility audit: semantics labels, 48 dp targets, reduced motion, large symbols — §16 (done 2026-09-29: rounds 1 and 2 of the M7 review pass together cover every screen and overlay, and every fix is in except screen-reader play on the board, which is the owner's call (R12, Q154, the item below); D165)
  - 2026-09-29 (M7 review pass, D164): the ui lens audited the M7 surfaces (Chapters, Records, rival select, the race board and rival strip, the race action bar, the race win and loss cards, the milestone and day-7 chests, `StarRow`, the reminder offer and its Settings rows, the board decor; the table is in PROGRESS "M7 review pass"). One failure, fixed: the race win and loss cards now read "Rival N, Computer" (R1). Left: the pre-M7 screens (splash, Home, Daily, the Museum, the Shop, Settings' other rows, the gameplay HUD and booster bar, the win, out-of-moves, pause, tutorial and intro overlays, the dev level picker); a text-scale check of Records, the race action bar, the race cards and `StarRow`, which the audit didn't run on its own; and a VoiceOver and TalkBack pass on a device, since a host test proves the semantics tree, not what a reader says
  - 2026-09-29 (M7 review pass round 2, D165): the a11y lens audited every pre-M7 screen and overlay and ran the four text-scale checks (the per-screen table is in PROGRESS "Round 2"). 23 findings (R7, R11–R29, R36–R38), all fixed but R12:
    - iOS's Reduce Motion now reaches System (R7, D167);
    - in-page overlays are modal routes to a screen reader (R11);
    - duplicate and missing labels and states (R13–R16, R37);
    - eleven targets under 48 dp (R17–R24, R38);
    - six texts cut at 1.3× (R25–R29).

    The overflow suite now fails a target under 48 dp, an unlabelled target and cut text (R36). Records failed its text-scale check (R25, fixed); the race action bar, the race cards and `StarRow` pass
  - 2026-09-29 (device run after the review, D168): the fixes hold on the iPhone 16 Pro simulator and the API 35 emulator. The integration tests' semantics finders all pass under R11's modal overlays and R13's single labels. The screenshots show the 48 dp targets and the scaled-down texts without overlaps or unreadable text. One side effect was fixed: R23's win button stood wider than the scaled card, and it now takes the card's width
- [ ] The VoiceOver and TalkBack pass on a device (the race cards' "Rival N, Computer" first) — the close's device stage, M7 review
  - 2026-09-29 (D168): not in the device run after the review, which ran `nesty-test` only. The iOS simulator has no VoiceOver. TalkBack is installed on the API 35 emulator (`com.google.android.marvin.talkback`), so the Android half can run there; VoiceOver needs a physical iPhone
- [ ] Screen-reader play on the board: a semantics layer over the Flame board (one node per slot from BoardGeometry, labelled from core's GameState, its tap through the board's input policy), the tutorial card as a live region, and Claude Design copy for the colour names and slot states. `TODO(v1.1)` at `gameplay_board.dart`, the question's default — M7 review R12 (owner decision, Q154)
- [ ] With Android's "Remove animations" on, the in-app Reduce motion "Off" can't restore full motion: AnimationControllers run at 5 % under SemanticsBinding.disableAnimations; use AnimationBehavior.preserve on the app's own controllers. `TODO(v1.1)` in `reduce_motion_override.dart` — M7 review R7 note (D167)
- [ ] Re-check `UIRequiresFullScreen` (deprecated in iPadOS 26) together with the iPad orientation decision — Q16
- [x] The badge toast on the win card: clear of the ribbon title, and gone with the card (today it covers "Level Complete!" and stays over Home's Chapters/Records row, chapter complete and All Levels Done). The same on 9.4: the 9.6 "New rival unlocked!" toast covers "You win!" and stays over rival select. Toasts stack at one spot, so a second toast 350 ms later hides the first (the `first_race` badge toast under 9.6's, and 2.8's with two badges): queue them (Q136). Its text's yellow double underline (MaterialApp's fallback style) is fixed (D162) — device stage, m7 §12, design request I.6, C.9, Q131 (done 2026-09-30: the toast queue (D187), lane O's scoped `ToastHost` at top 60 on the win card and lane R's on 9.4 and 9.5: one at a time, leaving with the card; 9.6 is a card, not a toast (`win_overlay_test`, `race_result_overlay_test`); D205, D208)
  - 2026-09-29 (D168): unchanged in the device run after the review. "Badge earned!" still covers the ribbon on 2.8 (`06a`, `20c`, `24`), and 9.6's toast covers "You win!" (`25d`), on both platforms
  - 2026-09-30 (phase 4, m7 P4.1, P4.7): the toast queue is in (D187; Q122 and Q136 answered). Left: lane O's scoped host at top 60 on the win card, lane R's on the race cards
- [x] The replay win card's reason line on a surface, readable over the board and the confetti (done 2026-09-29: it sits on the coin pill's cream surface, D162) — device stage, m7 §11, §15.3
- [x] The milestone chest's coin chip keeps its promised amount through the burst (it counts up from 0 on Open) — device stage, design request I.3 (done 2026-09-30: lane O: the chips show their promised amounts from the first frame, no count-up (`chest_reward_sequence_test`); D208)
  - 2026-09-30 (phase 4, m7 P4.7): I.3 shows the chips with their promised amount from the start, with no count-up. Left: lane O
- [x] A bonus level's win card shows the bonus number and the chest countdown, not "Chapter N · 1 / 1" (N from the last chapter's placeholder theme) — device stage, frame 4.10 (done 2026-09-30: lane O: frame 12.4's "Bonus Level N", its 10-level chest count and moves only (`win_overlay_test`, `win_chapter_card_test`); D208)
  - 2026-09-30 (phase 4, m7 P4.7): frame 12.4 is delivered (E.2). Left: lane O
- [x] An iced tower's "+N" tag: above the ice or hidden — device stage, design request B (done 2026-09-30: lane B: hidden while iced, popping in at the shatter (`board_m7_test`); D183, D204)
  - 2026-09-30 (phase 4, m7 P4.3): hidden while iced, popping in with the shatter (`layout.icedTower`, D183). Left: lane B
- [x] The Museum shelf labels' size and wrap (they scale down to fit now) — with J.2, `TODO(design)` in museum_cabinet.dart (done 2026-09-30: lane M: two lines at 11 px ("Chapter N" / "Levels a–b"; `museum_page_test`, the overflow sweep); D206)
  - 2026-09-30 (phase 4, m7 P4.5): two lines at 11 px (Q123 answered, D193). Left: lane M
- [ ] Optional E9 device check: kill the app during L1 and relaunch; it must reopen L1 — integrator-p1, m7 §13

## M8 — Release prep

Acceptance (§18): release builds run on real Android and iOS devices with
production Firebase.

- [ ] App icons: flatten the 1024 App Store icon (App Store Connect rejects alpha), and add an Android adaptive icon and a 512 px Play icon. `sync_design_assets` doesn't copy `design/store/` (its SVG uses unsupported features), so the launcher icons are generated separately — §18 M8, audit, `design/store/icon_1024.png`
- [ ] Native splash (the Android 12 splash API and the iOS LaunchScreen) matching frame 1.1 — §18 M8
- [ ] Store screenshot support: a clean capture mode — §18 M8
- [ ] App size under 60 MB (`--analyze-size`), keeping an eye on the bundled art — §18 M8, D20. On 2026-09-28 the prod fat APK (every ABI) was 73.3 MB: measure the per-ABI app bundle
- [ ] Performance profiling on a 2 GB Android — CLAUDE.md rule 8, `/perf-profile`. Include the level-load raster time of doll layers (design budget ≤ 250 ms; host flutter_tester measured 35–67 ms for 4 heights at DPR 3), board sprites and the theme background (r2/r3 reports)
- [ ] Release configs with the ad IDs from `--dart-define`, never committed — CLAUDE.md rule 5
- [ ] Android release signing with the upload key (`key.properties` kept out of git) — `apps/game/android/app/build.gradle.kts`
- [ ] iOS profile and release builds, `flutter build ipa` and Xcode Archive. Run `flutter build ipa --flavor <f> -t lib/main_<f>.dart` first, or the D8 guard fails the build — D8, PROGRESS M0 "Not verified yet"
- [ ] Privacy policy URL in both store listings, and a final check of the Settings link — §9.3, §17
- [ ] Store listing copy and screenshots in an adult and family tone, with no kid-coded language. The target audience (13+) is declared accurately in Play Console. The IARC, Data Safety and App Privacy answers match D92: local notifications only, opt-in; no tracking before M6 — §1, §17, D92
- [ ] The share card gains the store link once the listings exist — D92 E3
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
- [x] Relaxed mode with unlimited undo — §19 (moved to M7 "Engagement" as E6: the owner approved it for v1, D92)
- [ ] Home-screen widget for the daily and the streak (WidgetKit and AppWidget in all three flavors, plus a package) — brainstorm §6, D92
- [ ] A weekly puzzle, par and stars, no-undo challenges and time attack: revisit after M7 with the best-moves data (stars make a win feel like a failure, and speed pressure is off-brand) — brainstorm §6, D92
- [ ] A Museum diorama or a sticker album (large art cost), a Daily Duel against the computer, a ghost race against your own best, and a welcome-back recap — brainstorm §6, D92, D93
- [ ] Doll micro-expressions (new face layers in all 7 skins), a dyslexia-friendly font option, and a favourite family on Home (ask Claude Design where it sits) — brainstorm §6, D92
- [ ] Online player vs player (matchmaking, a shared board or a race over the network): after the Firebase milestones — D90
- [ ] Seasonal skins — §19
- [ ] True 3D renderer behind `DollRenderer` once Flutter GPU is stable — §19, §12.6
- [ ] Level-sharing code for friends — §19
- [ ] Data-driven playable colors. It is a spec change, so `DollColor` stays a fixed enum — D19, design/README.md "Decisions to confirm" 6
- [ ] About 20 new levels a week from the admin after launch — §7.1
- [ ] Optional: make "solved from its start within the soft-stuck budget (20,000 nodes)" a `bundle check` gate; today it is a selection rule pinned by `repo_levels_test` — levels lane report, spec §6.3, Q104
- [ ] Separate the four side-by-side easy pairs L81/L82, L91/L92, L141/L142 and L151/L152 if the owner allows another knob in those slots — levels-fix report, Q108
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
- [x] Flavor text for 9 figurines. Only the Sailor Family has one — §7.2, frame 6.2 (M8; moved from M3: the Museum shows no flavor line until supplied) (done 2026-09-30: copy.md G.2 in the ARB, C4b, D198)
- [x] Names for figurines 4–10 (astronaut, gardener, snow, circus, musician, royal, explorer): the design names only the Classic, Sailor and Baker Families, so `figurineName` returns '' and the win card hides "Next up" for chapters 4–10 (Q47) — UI lane report (M8; moved from M3: placeholder names ship until the owner's, Q73) (done 2026-09-30: copy.md G.1, final, D198)
- [ ] The colours the App Flow frames use that tokens.json lacks (e.g. `#6E4526` icon brown), listed in `apps/game/lib/core/ui/colors/app_colors.dart` with `TODO(design)`: add them to tokens.json `color`, then move the call sites to `AppColorTokens` — UI lane report (M7)
  - 2026-09-30 (phase 4): tokens v3 adds the Shop, chest modal, symbols-card, versus, streak and notification colours. What `app_colors.dart` still lists is the remainder; ask Claude Design for those names in the "Follow-up after m7-3" request
  - 2026-09-30 (phase 4 integrated): asked, with every remaining name, in "Follow-up after m7-3" §1.2
- [x] Names and background art for chapters 7–10. Only ch01–ch06 exist — §7.1, §12.4 (M3, M7) (done 2026-09-30: copy.md G.4 and `themes/ch07…ch10` (D176, D196, D199))
- [x] Shelf plank, stand art and palette JSON for each theme, or confirmation that every theme shares the board art — §12.4 (M7) (done 2026-09-30: every theme shares the board art (DELIVERY A.5); the palettes are tokens v3 `theme.chapters.N.palette` (D199))
- [ ] Store art — audit, docs/DESIGN_BRIEF.md Prompt 12 (M8):
  - Re-export the store SVGs (`design/store/icon.svg`, `open_doll.svg`). They use nested `<svg>` and mix-blend-mode, which flutter_svg can't render.
  - A 1024 icon without alpha, and adaptive icon layers.
  - Play feature graphic (1024×500).
  - 6 screenshots (1290×2796).
- [ ] Distinct dev and stg icons, if Q17 says yes (M8)
- [ ] Admin panel designs. The handoff has none, and the admin placeholders point at `design/admin/*.png` — docs/DESIGN_BRIEF.md Prompt 14 (M5)
- [ ] Privacy policy URL and support email address — §9.3, §17, frame 8.1 (M3, M8). Until then their Settings rows are hidden (`AppLinks`, m3 §10.2, Q73)
- [x] Descriptions for the Classic, Space, Sweets, Forest Friends and Winter skins (frame 7.4 has only Ocean's "Sailor collars, tiny anchors and wave trims."); hidden until supplied — m3 §9.1, Q73 (M8; moved from M3: hidden until supplied) (done 2026-09-30: copy.md G.3, D198)

### Design gaps

**D90 (2026-09-28):** the offline game milestone (M7) sends its design needs
to Claude Design in one request: chapter themes 7–10 and theme thumbnails,
the board layouts for levels 31–200, the vs-Computer screens once the mode's
proposal is approved, the catalog copy (Q73), and the gaps below tagged
(M7). The prompt is kept in `docs/plans/claude-design-request-m7.md`.

**D92–D93 (2026-09-28):** the same request now also asks for:
- the approved race, section C (rules, the "Computer" label, Start, "Starting over", Rematch and New race);
- a new App Flow section 10, "Engagement", in section I: the share card, the reminder offer and the Settings rows, the milestone chest, Chapters and the replay win card, Records and badges, the gentle streak's states and the first-launch transition;
- their copy in G.6–G.9.

**D125 (2026-09-28):** the same request also asks for the star rating in
section K: the art, the reveal, sounds, tokens, frames 11.1–11.5 and copy
G.11.

Section B's 4-shelf and 5-slot presets are optional now (Q87). Until each delivery lands, build in the design's system with `TODO(design)`.

These states have no design yet. Until they do, build them in the design's
system and mark them `TODO(design)`. The gaps that said (M7) moved to M7 on
2026-09-27: M2 ships the design-system stand-ins, and the M7 fidelity pass
takes the designs when they arrive.

- [x] L1 tutorial third step (Cherry 1 into the nest) — §7.6, frame 1.4 (M7; moved from M3: the M3 stand-in ships) (done 2026-09-30: delivered in m7-3: E.10, "STEP n OF 3" on all three steps; C4b switched the chips; lane O, m7 P4.7)
- [x] Out-of-moves Undo row once the free undos are used — frame 3.5 (M7; moved from M3: the M3 stand-in ships) (done 2026-09-30: delivered in m7-3: frame 12.8, `oomUndoSpent`; lane O, m7 P4.7)
- [x] +Slot at its limit (2 used this level) — §3.6 (M7) (done 2026-09-30: delivered in m7-3: frame 12.9, `extraSlotLimitToast`; lane O, m7 P4.7)
- [x] Extra slot when the bottom shelf is full — §3.6, D22 (M7) (done 2026-09-30: delivered in m7-3: `boardPresets.rowOfFive`, D172 as built (D181); lane B, m7 P4.3)
- [ ] Boards with 1 shelf, 4 shelves or 5 slots per shelf — §2.1, §5.3 (M7). Built by scaling (D36): the 1-shelf preset (plank 540, Hs 150) and the 4-shelf preset (planks 250/395/539/684, Hs 104, every slot piece × 104/150), both `TODO(design)` in `packages/nesty_render/lib/src/board/shelf_presets.dart`; 5–6-slot rows shrink stands, pips, tag, glow, glass, ice, hint arrow, tower raise and (review RENDER-3) the dolls (`TODO(design)` in `board_layout.dart`)
  - 2026-09-30 (phase 4, m7 P4.3): m7-3 designs 4 shelves (`fourShelves`) and rows of 5 (`rowOfFive`); lane B builds them. Left: the 1-shelf preset (still a stand-in)
- [x] The board-wide doll clamp (`h·2/3 ≤ minPitch − 8/3`) for maxSize 6 on 3 shelves, maxSize 3 on 3 shelves or 4-slot rows (M2 levels 3–9) and 5–6-slot rows needs a design sign-off (`TODO(design)` in `board_layout.dart` `_dollHeights`). On these boards a top-row doll of the largest size is taller than any in the frames, so the designed hint arrow reaches the HUD at the top of its bob (Level 9's hint, playthrough screenshot `09c_l9_hint`). D62 moves it off the counter pill and under the pause row — D22, D36, post-M2 playthrough (M7) (done 2026-09-30: delivered in m7-3: `layout.boardFit` and the presets (D180); lane B, m7 P4.3)
- [x] The hint arrow over the middle column of an odd top row (L3, L5, L8, L21–L23) sits right under the family counter pill: D62 drops it the most it may (16·fs) and it still tucks under the pill by 10–33 dp on a 393 × 852 screen. Ask Claude Design where the arrow (or the counter) goes when a tall doll sits under the HUD's centre (asked as frame 3.1b in `docs/plans/claude-design-request-m7.md` E.20) — D62, owner 2026-09-27 (M7) (done 2026-09-30: delivered in m7-3: frame 3.1b, `layout.hintMiddle` and `familyCounterYield` (D185); lanes B and O, m7 P4.3, P4.7)
- [x] A doll sealed in a glass case is taller than the case at maxSize ≥ 5 (the design's own maxSize-5 doll is 6 dp above it, NestyBoard:169) and wider at maxSize 6; on a 4-shelf board a top-row maxSize-6 doll (sealed, or on a tower) reaches ~2–6 dp above the frame — r1 report, review (M7) (done 2026-09-30: delivered in m7-3: the tall case, `layout.board.glassCaseTall` (D182); lane B, m7 P4.3)
- [x] Top-shelf towers: the D21 18 dp step per buried nest shrinks so the deepest silhouette stays under the HUD (`TODO(design)` in `board_geometry.dart` `buriedBaseY`); and a buried nest two or more sizes smaller than the top stays hidden at 18 dp per depth (Q38) — D21, review RENDER-4 (M7) (done 2026-09-30: delivered in m7-3: `layout.towerStack` (D183); lane B, m7 P4.3)
- [x] A designed look for the procedural fallback doll (spec §12.5; `TODO(design)` in `packages/nesty_render/lib/src/doll/placeholder_doll_painter.dart`) — r2 report (M7) (done 2026-09-30: delivered in m7-3: `layout.fallbackDoll`, frame 12.12; lane B, m7 P4.3)
- [x] Looping animations for the intro cards — frames 4.1–4.3 (M7; moved from M3: the M3 stand-in ships) (done 2026-09-30: delivered in m7-3: `ui_intro_towers`, `ui_intro_glass`, `ui_intro_ice`; lane O, m7 P4.7)
- [x] Home with a Super Hard level, in bonus mode, and with a streak of 0 — frame 2.1 (M7; moved from M3: the M3 stand-in ships) (done 2026-09-30: delivered in m7-3: frames 12.1–12.3; lane M, m7 P4.5)
- [x] Win card in bonus mode — frame 2.8 (M7; moved from M3: the M3 stand-in ships) (done 2026-09-30: delivered in m7-3: frame 12.4; lane O, m7 P4.7)
- [x] Streak lost — §7.5 (M7; moved from M3: the M3 stand-in ships) (done 2026-09-30: delivered in m7-3: frames 10.7 and 10.7b, a streak pauses and relights; lanes D and M, m7 P4.5, P4.6)
- [ ] Ad loading, ad failed and ad timed out — §9.1 (M6)
- [ ] Purchase failed and purchase pending — §9.2 (M6)
- [ ] Restore found nothing — §9.2 (M6)
- [ ] Starter Pack already owned, and the No Ads tab once ads are removed — frames 7.1, 7.8 (M6)
- [ ] Skin or theme download failed, and the Shop offline — §13.5, frame 7.5 (M4)
- [x] A tap on an unpickable slot (empty, locked or iced) with nothing selected: ignored today (`TODO(design)` in `tap_policy.dart`, Q39). Should it shake? — frame 2.6 (M7) (done 2026-09-30: delivered in m7-3: frame 12.13, a dip, a ping or a bump (Q39, D185); C4b froze `NudgeSlot`; lane B plays it, m7 P4.3)
- [x] Highlighting the hovered column while dragging: no design (a second `fx_select_glow` is the suggestion) — contracts report (M7) (done 2026-09-30: delivered in m7-3: `motion.dragHover`, from `GameplayState.dropTargets` (D185); lane B, m7 P4.3)
- [x] Text max width: the family counter's label (52) is a guess (`TODO(design)`). The win and chapter ribbons use LOTTIE.md v3's text boxes (312×40, 312×32) since 2026-09-27 — lottie §12, v3 3a (M7) (done 2026-09-30: delivered in m7-3: `layout.hud.familyCounter`'s hug width; lane O, m7 P4.7)
- [x] Iced towers: `fx_ice` anchored on the doll at the tower surface draws the ice 5·fs above the static `iceRect` fallback (`TODO(design)` in `board_geometry.dart`, Q55). Ice comes at L51 — render report (M5) (done 2026-09-30: delivered in m7-3: `layout.icedTower` and the `iceTower` scene (D183); lane B, m7 P4.3)
- [x] The hint's dashed arc for moves other than frame 3.1's is a generalization (a quadratic 0.4 × the chord off its middle, arriving on the source's side of the target, D60; `TODO(design)` in `hint_layer.dart`), and where it starts on a tall source doll was Q64 (resolved: the design's 66) — board report, owner Level 9 report (M7) (done 2026-09-30: delivered in m7-3: `layout.hintArc`'s cubics (D185); lane B, m7 P4.3)
- [x] Whether `ui_extra_slot` keeps pulsing under a doll placed on the extra slot (today it loops until a reset); frame 3.6 shows only the empty slot (Q65) — lottie lane report (M7) (done 2026-09-30: delivered in m7-3: it stops under a doll (Q65, D184); lane B, m7 P4.3)
- [x] `fx_twinkle` on the win overlay: LOTTIE.md puts it there but no frame places it; four sit around the plank (`TODO(design)` in `win_overlay.dart`) — screens report (M7) (done 2026-09-30: delivered in m7-3: `layout.winTwinkles`; lane O, m7 P4.7)
- [ ] The drift height of an invalid move onto an empty glass case or ice slot uses the mover's height (`TODO(design)` in `timeline_plans.dart`) — timeline report (M5)
- [x] Looks no frame shows, built in the design's system (`TODO(design)`): a disabled booster (45 % glyph and label), the danger button, the success banner, and the Home SUPER HARD badge — UI lane report (M7) (done 2026-09-30: delivered in m7-3: frame 12.12; C4b re-tokened the danger button; lane O, m7 P4.7)
- [x] A load failure (the splash's retry): the player reads `genericLoadFailed` whether storage or content failed (`TODO(M7)` in `app_exception_extension.dart`, `TODO(design)` in `retry_view.dart`) — UI lane report (M7) (done 2026-09-30: delivered in m7-3: frames 12.10 and 12.11, `splashStorage*`, `splashContent*`; lane O, m7 P4.7)
- [ ] The splash's first frames draw the procedural placeholder dolls, which swap to the skin once it loads (about a second on the simulator, Q58) — integration playthrough (M7)
  - 2026-09-30 (phase 4): `layout.fallbackDoll` gives the placeholder a designed look (lane B, m7 P4.3). The swap itself stays Q58's
- [x] Anchors of `ui_toggle` and `ui_splash_loader`: LOTTIE.md says only "toggle box" and "bar box", taken as their top-left (Q56) — tools report (M7) (done 2026-09-30: delivered in m7-3: LOTTIE.md v3 answers them)
- [x] Home's PLAY once every bundled level is won (it used to read "PLAY · All done!" and promise "Level 31") (`TODO(design)` in `play_button.dart`, review FIDELITY-5) — frame 2.1, 4.9 (M7; moved from M3: M3's PLAY names "Bonus Level N" past the last level, m3 §7.4, §10.3, which no frame shows yet) (done 2026-09-30: delivered in m7-3: frame 12.2 (the BONUS badge, "Bonus Level N"); lane M, m7 P4.5)
- [x] Home's Daily tile before Level 2 is won: no locked design; built dimmed with a lock and "After Level 2" (`TODO(design)`) — m3 §8.3, Q67 (M7; moved from M3: the M3 stand-in ships) (done 2026-09-30: delivered in m7-3: frame 12.3; lane M, m7 P4.5)
- [x] The Museum with all ten figurines collected ("Every family is home.") and the Museum tile in Bonus Endless — m3 §10.3, §10.6 (M7; moved from M3: the M3 stand-in ships) (done 2026-09-30: delivered in m7-3: frame 6.1c; lane M, m7 P4.5)
- [x] A board being generated (a bonus level or the daily not prefetched): `ui_spinner` over the previous board, "Setting up the shelves…" — m3 §10.8 (M7; moved from M3: the M3 stand-in ships) (done 2026-09-30: delivered in m7-3: frame 12.5; lane O, m7 P4.7)
- [ ] The Shop's Coins and No Ads tabs before M6: a store-closed card ("The store is closed for now") — m3 §10.7, Q75 (M6)
- [x] Soft stuck with nothing to undo (a completion cleared the history, or the free undos are spent): the banner suggests Restart, "Try Restart? You can keep playing too.", and Undo doesn't glow (`TODO(design)` in `soft_stuck_banner.dart`, review FIDELITY-6) — frame 3.4 (M7) (done 2026-09-30: delivered in m7-3: frame 12.7 (Restart glows); lane O, m7 P4.7)
- [x] The Shop's colours that tokens.json lacks (the skin cards' backgrounds, Buy's coin-chip face, the 7.4 panel's highlight, edge and caption), in `SkinShopColors` with `TODO(design)` in `features/shop/widgets/shop_colors.dart`; and each skin's own 7.4 panel edge and caption ink (the frame draws only Ocean's) — frames 7.3, 7.4, M3 review RULES-3, FIDELITY-5 (M7) (done 2026-09-30: delivered in m7-3: tokens v3 `shop.*`, `ShopTokens`; lane M, m7 P4.5)
- [x] Theme cards show the chapter's flat fallback colour, not a thumbnail of its art (`TODO(design)` in `features/shop/widgets/theme_grid_card.dart`) — frame 7.7, M3 review RULES-3 (M7) (done 2026-09-30: delivered in m7-3: `theme.chapters.N.thumb`, `ThemeThumbnailLoader`; lane M, m7 P4.5)
- [x] No frame times the Shop purchase celebration (`TODO(design)` in `features/shop/widgets/purchase_twinkle_burst.dart`) — M3 review RULES-3 (M7) (done 2026-09-30: delivered in m7-3: `motion.purchase`, `PurchaseMotionTokens`; lane M, m7 P4.5)
- [x] Home on a short screen (a 16:9 Android body is about 630 tall): the tiles sit 12 above the nav and the hero scales down; frame 2.1 has no such variant (`TODO(design)` in `features/home/pages/home_page.dart`) — M3 device run, RULES-3 (M7) (done 2026-09-30: delivered in m7-3: `layout.homeShort`; lane M, m7 P4.5)
- [x] `NestyToast`'s 3 s auto-dismiss has no frame timing (`TODO(design)` in `core/ui/widgets/feedback/nesty_toast.dart`) — M3 review RULES-3 (M7) (done 2026-09-30: delivered in m7-3: `motion.toast`, 2.5 s, in the toast queue (C4b, D187))
- [x] A designed failure state for a Continue whose next level can't be generated (built: the retry view and a "Back to Home" link, `TODO(design)` in `features/gameplay/overlays/next_level_failed_card.dart`) — M3 review CORRECTNESS-3 (M7) (done 2026-09-30: delivered in m7-3: frame 12.6; C4b froze `NextLevelFailedCard`'s words; lane O, m7 P4.7)
- [x] A text-link style in tokens.json ("Back to Home" on 4.9 uses `buttonSmall` at 16, `TODO(design)` in `features/gameplay/overlays/overlay_text_link.dart`) — frame 4.9, M3 review FIDELITY-11 (M7) (done 2026-09-30: delivered in m7-3: tokens v3 `textLink`, with a 48 dp hit box (D201); lane O, m7 P4.7)
- [x] Tokens for the 5.6 and 8.1 colours now in `AppColors` (`chestGlow`, `chestShadow`, `symbolsCardSelectedFace`, `symbolsCardRing`), with the item above on `app_colors.dart` — M3 review FIDELITY-8, FIDELITY-12 (M7) (done 2026-09-30: delivered in m7-3: `chestModal.*` and `settings.colorSymbolCards`; lanes O and D, m7 P4.6, P4.7)
- [x] The M7 phase-1 stand-ins, built in the design's system with `TODO(design)` until Claude Design's section I and J frames land: Chapters (10.4, `chapter_section_card.dart`, `chapter_level_cell.dart`), Records and its badge glyphs (10.6, I.6, `badge_toast.dart`, the best-moves link icon in `records_page.dart`), the win card's moves line, the replay card (10.5; the HUD's "Replay" tag was removed, D170; its reason line sits on the coin pill's cream surface since D162), the milestone and day-7 chest opening (10.3, `chest_reward_sequence.dart`), the relaxed "∞" badge and the always-free Undo row (10.9), the paused streak (10.7), the Settings rows and the reduce-motion sheet (10.2), the vs Computer tile's glyph and colour (9.1, C.8, `home_page.dart`), the Museum's clarity pass (J.2) and the "Not enough coins" dialog (J.3, G.10) — m7 §15, §15.10, design request C, I, J (M7) (done 2026-09-30: delivered in m7-3: sections I and J; lanes M, O and D, m7 P4.5–P4.7)

### Copy to confirm

- [ ] ATT pre-prompt: "you can change it later in Settings" should say iPhone Settings — frame 8.5, §9.3 (M6)
- [ ] Remove Ads offer: "Restore it on any device" only holds for devices on the same store account — frame 7.9, §9.2 (M6)
- [ ] BEST VALUE is on the 4,000 pack, but 9,000 for $9.99 is the better value per coin — frame 7.1, §9.2 (M6)
- [ ] Casing: "Restore Purchases" (8.1) vs "Restore purchases" (7.8) — frames 8.1, 7.8 (M6)
- [ ] Settings footer "Player ID": the spec has no player id. Use a local random id, or drop it — frame 8.1, §13.3 (M8; the default ships in M3: a local random id in the save, D79, Q74)

### Accounts and compliance

- [ ] AdMob account, app IDs and real ad unit IDs, supplied through `--dart-define` at build time — CLAUDE.md rule 5 (M6, M8)
- [ ] Link AdMob to Firebase for ad revenue data — §14.4 (M6)
- [ ] Create the 6 §9.2 products in Play Console and App Store Connect — §9.2 (M6)
- [ ] App Privacy and Data Safety forms, the target-audience declaration, and a legal check — §17 (M8)
- [ ] Production Firebase project and signing material (upload keystore, Apple certificates) — §18 M8 (M8)

### Decisions

- [x] Q3: the save document in Hive or in the atomic JSON file? (blocks M3 save) (done 2026-09-27: a Hive box via `DatabaseService`, D63)
- [x] Q5: add a `reward_medium` key, or have medium read `reward_easy`? (M3) (done 2026-09-27: `reward_medium`, default 10, D64)
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
  - 2026-09-30 (phase 4): Q39 is answered by frame 12.13, a nudge, never a shake (D185)
- [x] Q59: the subtle belly symbol, bare ink (tokens.json, README §3, the generator and the classic renders; what ships) or on the App Flow previews' cream r 55 disc with a light-shade ring? (done 2026-09-27: the owner chose bare ink, PROGRESS Q59)
- [ ] Q60: a second +1 Slot press during the 300 ms re-pitch: queue it (today: a second slot and booster) or ignore it like the board's global lock? (M2, D58)
- [x] Q61–Q63: the audio plan's session, chapter-jingle and low-latency questions (done 2026-09-26: iOS `.ambient`; `jingle_chapter` only at chapter complete; low latency in prod only; D61)
- [x] Q64: should the hint arc start at the source doll's head rather than 66 below its top (the prototype's value, which lands on a tall doll's upper body)? (M7) (done 2026-09-27: the owner kept the design's value, PROGRESS Q64)
- [x] Q65: should the extra slot's pulse stop while a doll stands on it? (M7) (done 2026-09-30: answered by Claude Design's m7-3: the pulse stops under a doll, D184)
- [ ] Q66: should a music volume slider fade (SoLoud's `setVolume` applies at once and cancels a running fade)? No M2 caller (M7; moved from M3: no slider is designed, so none was built)
- [ ] Q67: the daily unlocks after Level 2 (the tutorial) is won, with intro cards covering any mechanic a daily shows first? (M3, D76)
- [ ] Q68: the chapter reward as a Remote Config key `reward_chapter`, default 150, like Q5? (M3, D72)
- [ ] Q69: after a kill, relaunch to Home with PLAY continuing the saved board, or open straight into the board? (M3, D71)
- [ ] Q70: the streak readings: at most 1 freeze, granted each ISO week; a frozen day keeps but doesn't add; the chest on every 7th streak day; only today's date counts? (M3, D76)
- [ ] Q71: bonus levels outside the chapters, never skipping levels published later? (M3, D74)
- [ ] Q72: prices the frames don't show: Space 1,200; ch02 800 and ch03 1,000 bought early; `forest-bear` not sold? (M3, D75)
  - 2026-09-30 (phase 4): Forest Bear answered by copy.md H, 2,500 (D200); the rest stays open
- [ ] Q73: catalog content: figurine names 4–10 ("The <Name> Family"), 9 flavor texts, 5 skin descriptions, the names of chapters 7–10, the privacy URL and support email (hidden until supplied)? (M3, D75)
  - 2026-09-30 (phase 4): the catalog copy answered by copy.md G.1–G.4 and H (D198); the privacy policy URL and support email stay open
- [ ] Q74: the Settings footer's Player ID: a local random id in the save, or drop it? (M3, D79)
- [ ] Q75: the Shop's Coins and No Ads tabs before M6: a store-closed card, or hide the tabs? (M3, D75)
- [ ] Q76: the milestone chest: 100 coins + 1 hint, at level 10 of each chapter and every 10th bonus level? (M7, D92 E5)
- [ ] Q77: race rewards 20 / 30 / 40 coins by rival, with no daily cap? (M7, D93)
- [ ] Q78: vs Computer unlocks after Level 20? (M7, D93)
- [ ] Q79: rival paces 3.0 / 2.4 / 1.6 s per move with ±20 % jitter, tuned by playtest? (M7, D93)
- [ ] Q80: rival boards easy / medium / medium? (M7, D93)
- [ ] Q81: the reminder's default time is the hour the first daily was solved? (M7, D92 E4)
- [ ] Q82: replays pay nothing, and best moves are kept per level id and version? (M7, D92 E7)
- [ ] Q83: the badge list and triggers (Claude Code proposes about 12 in the brainstorm doc; Claude Design names them) (M7, D92 E8)
- [ ] Q84: relaxed mode also hides the undo price and the ad row? (M7, D92 E6)
- [ ] Q85: paste `docs/plans/spec-proposals-m7.md` into GAME_SPEC.md, or keep it as the approved text? (M7, D92, D93)
- [ ] Q86: for players of unknown age, non-personalized ads by default, and Apple's Declared Age Range API? (M6, D92)
- [ ] Q87: 4-shelf boards and 5-slot rows in chapters 8–10 for variety (Claude Design B.1–B.2 plus a curve change and a `Generator.version` bump), or keep the confirmed curve's layouts? (M7, D92)
- [ ] Q88: no best moves on daily, bonus and race boards (their win card shows "Moves N" only)? (M7, m7 §11, D102)
- [ ] Q89: the milestone chest pays in the win's own save update and its modal only shows it, or pay on the modal's button? (M7, m7 §9, D103)
- [ ] Q90: replays are never saved in progress (a kill ends the replay), or save and resume them? (M7, m7 §6, D100)
- [ ] Q91: records count every mode's won boards, with "dolls nested" = the dolls that end inside another in each won board? (M7, m7 §12, D105)
- [x] Q92: Chapters and Records open from a two-button row under Home's header, and Chapters also from the Museum, until Claude Design draws them? (M7, m7 §15.8, D109) (done 2026-09-30: answered by Claude Design's m7-3: Home's chapter card and Records button, no Museum link, D193)
- [ ] Q93: bonus milestone chests every 10th bonus level, kept in their own `chests.bonusOpened` list? (M7, m7 §9, D97)
- [ ] Q94: the twelve badge triggers of m7 §12 (`tall_order` at `maxSize` 5 or more, `museum_full` the ten launch figurines), with Q83? (M7, D106)
- [ ] Q95: the freeze chip's "0 left" (frame 5.2) rewritten "No freeze", or keep the frame's copy? (M7, D110)
- [ ] Q96: the paused streak turns the whole Daily badge and streak card neutral (never red), or only the flame? (M7, m7 §15.7, D98)
- [ ] Q97: "Streak relit!" on the daily win card rather than a toast on the Daily screen? (M7, m7 §8, D98)
- [ ] Q98: the vs Computer tile before the race ships: locked "After Level 20", then "Coming soon", or hide it until phase 2? (M7, m7 §15.8, D109)
- [ ] Q99: E12's layout signature: the slots per shelf, the sorted tower depths, the glass cases, the iced slots, the colour count and `maxSize` (colours, positions and set cuts ignored)? (M7, D114)
- [ ] Q100: expert-only levels an error from L31 on, levels published past L200 included? (M7, D114)
- [ ] Q101: `maxSize` 6 only on super hard slots, as a `bundle check` error? (M7, D114)
- [ ] Q102: the intro levels L31, L51 and L71 leave their curve rows (no towers, 3–4 colours) so each mechanic arrives alone? (M7, D113)
- [ ] Q103: chapter 5's "fewer empty slots" as no empty slot at the start on all 20 levels? (M7, D113)
- [ ] Q104: the 20,000-node start solve as a selection rule pinned by a repo test, not a `bundle check` gate? (M7, D113)
- [ ] Q105: the twist knobs beyond ±1 (towers 4 deep in chapters 5, 8 and 10; 0 or 2 empty slots; glass and ice counts 0–2)? (M7, D113)
- [ ] Q106: `levelsVersion` stays 0 until M4's manifest reads it? (M7, D113)
- [ ] Q107: keep L200 as the only level the casual bot never wins (0/300, smart 300/300), or re-tune it? (M7, D115)
- [ ] Q108: keep the four easy pairs that read alike (L81/L82, L91/L92, L141/L142, L151/L152), or allow another knob in those slots? (M7, D115)
- [ ] Q109: the near-duplicate measure as a repo test, or a `bundle check` gate? (M7, D115)
- [ ] Q110: +1 Slot's one sound from the booster's tap feedback, or every board sound from the timeline? (M7, D116)
- [x] Q111: the extra slot's loop from frame 24 (scale exact, opacity about 88 %): wait for Claude Design's E.21, or crossfade it now? (M7, D116) (done 2026-09-30: answered by Claude Design's m7-3: the loop rests on frame 0, D184)
- [ ] Q112: also sweep the fully navigated shell for overflow, beside the chrome-and-`HomeView` sweep? (M7, D121)
- [x] Q113: the Chapters header band with the chapter's theme art cropped behind a scrim now, or wait for Claude Design's 10.4 (today a theme-colour emblem)? (M7, D118) (done 2026-09-30: answered by Claude Design's m7-3: the header crops the theme art, D193)
- [ ] Q114: E13 times from Dart's `main()` to L1's first playable frame; the owner's device check adds the native launch? (M7, D123)
- [x] Q115: the Museum's next family line "7 levels to go", or "Chapter 4 · 7 levels to go"? (M7, D118, design request J.2) (done 2026-09-30: answered by Claude Design's m7-3: "Chapter 4 · 14 levels to go", D193)
- [ ] Q116: a hint since the last Restart, or an extra slot on the board at the win, caps it at 2★? (M7, D125)
- [ ] Q117: best stars kept per level id, so a new level version keeps them? (M7, D125)
- [ ] Q118: the 3★ target line only on a replay's win card below 3★, never on a first win? (M7, D125)
- [ ] Q119: a one-time tip on the first win below 3★? (M7, D125)
- [ ] Q120: levels won before stars existed get the stars their best moves earn, or 1★? (M7, D125)
- [ ] Q121: E13's headline: "playable" (the board takes input) or "alone on screen" (the splash's exit over)? (M7, D127, device stage)
- [x] Q122: Where the badge toast sits over the win card, and whether it closes with the card (M7, device stage) (done 2026-09-30: answered by Claude Design's m7-3: above the ribbon at y 60, leaving with the card, D187)
- [x] Q123: The Museum's shelf label: scaled to fit (shipped), two lines with a taller shelf, or a shorter form? (M7, D130, device stage, design request J.2) (done 2026-09-30: answered by Claude Design's m7-3: two lines at 11 px, D193)
- [ ] Q124: a Rematch after a win pays `race_reward_n` again? (M7, D136, D138)
- [ ] Q125: a race board's stage is the highest campaign level won (`highestLevel − 1`), not the next level's? (M7, D134)
- [ ] Q126: keep the race seed formula (it formally meets unreachable bonus and daily seeds) and cap raceNo at 99,999, where New race replays the last board? (M7, D134, D138)
- [ ] Q127: a rival's restart takes one pace interval, shown as "Starting over"? (M7, D133, D136)
- [ ] Q128: Quit race goes back to rival select and uses up that raceNo; races log no spec §14.4 level events until M4 defines race events? (M7, D137)
- [ ] Q129: a race board on the player's current chapter's theme until frame 9.3 lands? (M7, D135)
- [ ] Q130: if `race_unlock_level` is tuned below 16, accept easy boards for rivals 2 and 3, or clamp the race stage to 16 or later? (M7, D134)
- [x] Q131: "Rival unlocked" (frame 9.6) as a toast over the win card, or a fuller card? (M7, D139) (done 2026-09-30: answered by Claude Design's m7-3: a card, once per rival, D192)
- [x] Q132: a race's Pause without the Settings tile (Restart and Quit race only)? (M7, D139) (done 2026-09-30: answered by Claude Design's m7-3: Settings is reachable, D192)
- [x] Q133: Quit race in one tap, with no confirmation? (M7, D139) (done 2026-09-30: answered by Claude Design's m7-3: Leave race asks once, D192)
- [x] Q134: the rival strip as a counter pill, no second board, until frame 9.3? (M7, D139) (done 2026-09-30: answered by Claude Design's m7-3: a counter and one dot per family, D192)
- [x] Q135: the rival strip drops its state line first below 340 dp until frame 9.3 says what gives way? It is measured on the strip's inner width (the screen − 64 dp), so it drops on every screen under 404 dp, the iPhone 16 Pro and the design's 390 reference included (M7, D141, race-ui, device stage) (done 2026-09-30: answered by Claude Design's m7-3: glyph-only tag below 360 dp, no state line below 340 dp, D192)
- [x] Q136: toasts over a result card (2.8, 9.4) stack 350 ms apart at one spot, so the second hides the first. Queue them, each after the previous one closes? Default: they stack (M7, D143, device stage, design request I.6) (done 2026-09-30: answered by Claude Design's m7-3: queued, 2.5 s each, 300 ms apart, D187)
- [ ] Q137: the daily reminder still fires on a day already solved (plan decision 15's "daily repeating"), or skip solved days with one-shot notifications re-planned at each launch? Default: it fires (M7, D153)
- [ ] Q138: the reminder offer counts as made at its first appearance, answered or not? Default: yes; Settings keeps the switch (M7, D153)
- [ ] Q139: Settings hides the reminder row until the daily unlocks (Level 2 won)? Default: yes (M7, D153)
- [x] Q140: a button that opens the phone's notification settings (a platform channel or `app_settings`)? Default: none in phase 3; the copy says where (M7, D153) (done 2026-09-30: answered by Claude Design's m7-3: yes, "Open phone settings", D189)
- [ ] Q141: a tap on the reminder opens the app normally (splash → Home), not the Daily screen? Default: yes; a deep link later (M7, D153)
- [ ] Q142: the reminder while the app is open: nothing on iOS, default importance on Android (no heads-up)? Default: yes (M7, D153)
- [x] Q143: one notification line every day, or rotate G.7's 2–3 lines (one schedule per weekday)? Default: one line (M7, D153, design request G.7) (done 2026-09-30: answered by Claude Design's m7-3: three lines, rotating at each re-plan, D190)
- [x] Q144: the share text is the date, one 🪆 per family (at most 12), the families, the moves and the streak count, even while paused? Default: yes, until G.6 (M7, D151) (done 2026-09-30: answered by Claude Design's m7-3: G.6's text on the daily win card, D188)
- [x] Q145: the replay's 3-star target line only when the moves were over it, and no line about the hint or +1 Slot cap until K.4? Default: yes (M7, D148, Q118) (done 2026-09-30: answered by Claude Design's m7-3: the helper note, D191)
- [x] Q146: under reduce motion the win card's stars show at once, and their three clacks and haptics still play at half the stagger (D48), or silently? Default: they play (M7, D149, design request K.3) (done 2026-09-30: answered by Claude Design's m7-3: the last frame, one sound and one haptic, D191)
- [ ] Q147: the star totals count only bundled levels with a par: 60 a chapter, 600 in Records? Default: yes (M7, D150)
- [ ] Q148: if a tutorial's scripted moves leave every optimal line, accept that its first play can't reach 3★ (a replay can)? Default: yes, and report it (M7, D146). Checked 2026-09-29 by stars-core: both tutorials' scripted moves lie on an optimal line, so it's moot (D157)
- [ ] Q149: a denied reminder Yes still stores the chosen time and `offered` (only `on` stays false)? Default: yes (M7, D160)
- [ ] Q150: add `share_plus_platform_interface` and `plugin_platform_interface` as dev dependencies for a true `SharePlatform` test double? Default: no (M7, D156)
- [x] Q151: `NestyIcons.download` as the Share button's glyph until I.10? Default: yes (M7, D156) (done 2026-09-30: answered by Claude Design's m7-3: `share` / `ios_share`, D188)
- [ ] Q152: the reminder offer's time after a night solve. A daily solved at 01:59 offers "Every day at 1:00 AM". Keep the solve's hour, or propose a daytime hour (such as 19:00) when it falls at night? Default: keep the solve's hour (M7, D153, Q81, Q138, device stage)
- [ ] Q153: while the daily streak is paused (no `lastDate`), a clock rolled back to an earlier ISO week still grants that week's freeze, and solving that past daily relights the run. Keep a high-water date in `DailyProgress` (or keep `lastDate` on a pause) so this also counts as "the clock went back"? Default: leave as is (M7, D163, review R2)
- [ ] Q154: should blind players be able to play levels with VoiceOver or TalkBack in v1? The Flame board has no screen-reader nodes, so they can't play any level, the daily or a race; every menu works. It needs one node per slot, a tap through the board's input rules and about 20 Claude Design strings in 9 languages. Default: build it in v1.1, and say in the store listing that board play needs sight until then (M7, D165, review R12)
- [ ] Q155: should the reminder load `timezone`'s `latest_all` (about 380 KB and 3 ms more) instead of P3.10's `latest_10y`, so the 132 backward-link zone ids resolve in Dart too? Default: keep `latest_10y`; the platform already gets the device's own id since R9 (M7, D166, review R9)
- [ ] Q156: the ch07–ch10 theme prices, which no source sets? Default: 2,000 each, the top of spec §7.3's theme range (M7, D199)
- [ ] Q157: the splash's "Nesty needs about 60 MB" (copy.md E `splash_storage_body`)? Default: copy.md's line with 60 in `SplashCopy.storageMegabytes` (M7, D196)
- [ ] Q158: a reminder the OS blocked has no off switch in the app (Settings draws the toggle off and opens the phone's settings, frame 10.2f), so it starts as asked if notifications are allowed later. Add a "Turn off" link on the blocked row? Default: no extra control (M7, D190, D207)
- [ ] Q159: Records' families cell shows the rule's plain count, "Families completed" (every family a won board completed), not frame 10.6's "N of 10 Families home", which is the Museum's count. Keep it, or show the Museum's count? Default: the plain count (M7, D209)
- [x] Q30–Q38: the M1 and render decisions to confirm (towerless grading, expert-only generated levels, solver targets, admin memory, the curve table, the recorded defaults, bundle policy, authored levels, render defaults) (done 2026-09-26: the owner confirmed the recorded defaults, D52)
- [ ] Update GAME_SPEC.md for this round's deviations, or keep them recorded only in PROGRESS? They are §2.2 tap policy (D22), §3.6 extra-slot placement (D22), §13.5 bundled art (D20), the §12.3/§13.3 symbols value (Q4), and the §12.3/§13.3 default symbols mode, now `large` (D91) — D19–D22, D91

## Tech debt

- [ ] Extract the duplicated base layer into a shared package — D6, Q8
- [ ] `SkinDollRow` lives in `features/shop/widgets/` but the Daily card and Settings' Color symbols use it too: move it next to `LottieDoll` in `features/fx/` — M3 fix pass
- [ ] A public digest helper in nesty_core (e.g. `LevelCodec.fingerprint`), so the app's integration tests can report the core goldens' short `Hash64` instead of the whole canonical JSON — M3 shop lane
- [ ] CI: add `test/codec/game_session_codec_test.dart` and `test/generator/daily_golden_test.dart` to the `dart test -p node` parity line — M3 core-codec lane
- [ ] Optional: use the same error-key names in both apps — Q26
- [ ] The hooks guard only Write, Edit and MultiEdit, so a Bash redirect bypasses `block-secrets` and `block-generated` — PROGRESS "Review pass"
- [ ] No test covers the bootstrap zone handler's `FlutterError.reportError` — PROGRESS "Review pass"
- [ ] `runGuarded`'s debug prints add noise to test output — PROGRESS "Review pass"
- [ ] Watch CI's first GitHub run on `ubuntu-latest`: the Linux-only `grep -z` and `xargs --no-run-if-empty` format step, `setup-java`, shellcheck, and the APK build of `flutter_soloud`'s native code (it needs the NDK and CMake on the runner; only built locally so far) — PROGRESS M0 "Not verified yet", PROGRESS "Package reasons"
- [ ] The VS Code launch configs are untested — PROGRESS M0 "Not verified yet"
- [ ] Revisit `flutter_gen` now that assets exist, or keep hand-written asset paths (`sync_design_assets` owns the files, not typed accessors) — D3
- [x] `hive_ce_generator` produces nothing. Keep it or drop it once Q3 settles the save — PROGRESS "Package reasons" (done 2026-09-27: removed, the save is one JSON document, D80)
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
- [x] The bundled levels are validated on the UI isolate at splash (milliseconds for 30). Re-measure at 200 levels and move it to `compute` if it takes longer than a frame — services report (done 2026-09-28: 57–75 ms AOT and 232–354 ms JIT on the dev Mac for 200 levels, against 6–12 ms for 30, so the decode and rules 1–7 now run on a worker isolate, `BundledLevelRepository.checkInBackground`, D122; `bundled_level_repository_test` proves the work leaves the caller's isolate)
- [ ] The timeline tests' `geometryOf` fixture repeats the game's `boardShapeOf`; use it, so the page, the board and the tests build geometry one way — timeline report
- [ ] The tools contract table repeats the `FxId` file names and the `FxImageSlot` ids and sizes (tools can't import the game). `lottie_contract_test` reads the game's frozen `fx_id`/`fx_image_source`/`fx_spec` files with regexes, so a big reformat of them may need the regexes updated — tools report
- [ ] `integration_test.framework` is embedded in every iOS configuration: CocoaPods links the dev-dependency plugin's pod everywhere, and only its registration is debug-only. Check the M8 release size and whether to keep it out of release builds — integration (M8)
- [ ] `flutter drive` on Android ends with "Failed to uninstall app": it tries the base id `com.futrix.nesty`, not the flavor's `.dev`. The test result is unaffected — integration
- [ ] `winRewardFor` lives in the bloc's `features/gameplay/bloc/win_reward.dart`, and `core/repository/fake_level_resolver.dart` (and the M3 `DefaultLevelResolver`) import it from there. Move it next to `RemoteConfigKeys` if more of core needs it — m3 §6.2
- [ ] Deleting `apps/game/build/` alone leaves `apps/game/.dart_tool/flutter_build/` stamps that say the iOS native assets (objective_c's framework) are built, so the next iOS build fails with "NativeAssetsManifest.json references objective_c, which was not found". Clean both (`flutter clean`, or remove `.dart_tool/flutter_build` too); README "Troubleshooting" says so — fix-and-close verification
- [ ] GameplayPage keeps the bloc of its first request when the router reuses its page for another GameplayRoute (a replaceAll from one level page to another); no app path does it today — M7 device stage, daily_fingerprint_test

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
