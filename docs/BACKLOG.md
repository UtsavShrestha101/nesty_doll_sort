# Backlog — Nesty: Doll Sort

This is the single curated checklist of all remaining work, with one section per
milestone (spec §18). [PROGRESS.md](PROGRESS.md) records what was done and why.
This file records what is left. In-code markers are indexed separately in
[TODO_INDEX.md](TODO_INDEX.md), which `dart run nesty_tools:todo_index` generates from
`TODO(<tag>)` comments. Never edit it by hand.

Last updated: 2026-10-08 (D300, Q192–Q193: the retention research's proposals RR1–RR7, a new section before M4. Before that: 2026-10-05, D274, D275: Q162 and Q184 answered. Before that: D272, D273: Q185 and Q183 answered; the Wednesday Claude Design send-off item; Gradle reports ignored. Before that: M7 code complete: the `/milestone M7` gate's results ticked or moved in M7 (5C), 13 classified items ticked or moved, Q185, a v1.1 item for Japanese one-character lines. Before that: D270's second pass: the themes, characters and story section checked against the code. TC4 is split into TC4a and TC4b; TC11–TC14, TC-FX and TC-DATA are added; the TC-L line is added under Later; ER8, ER9 and the diorama item are annotated; Q184 is widened. Before that: D271: M7 5C, the review: its fixes ticked, the race strip keeps the word "Computer", the strip's design ask, the device look and the gate pending. Before that: D270, Q183–Q184: the themes, characters and story proposals and the loss-card question. Before that: D269: local first, backend last; ER11b Game Center and Play Games moved to M8. Before that: D268, Q182: the daily gift, a login reward the owner asked for and approved: its section split into the plan's work items, Q182 answered with the defaults, the spec-paste and design-prompt owner inputs, and the M4 analytics and M8 PEGI items extended. Before that: 2026-10-05 (D261–D267, Q175–Q181: M7 phase 5B, the translations: the English-freeze and translations items ticked with their evidence, 5B's deferrals and the fidelity re-shoots added (the device run's results are pending), the 5B questions Q175–Q181. Before that: 2026-10-04 (D259–D260, Q173–Q174: the engagement research and the kid path: a new section after the local habits with the kid path's local items and proposals ER1–ER11; the kid path's analytics (M4), ads, purchases and age signals (M6); the store-listing item changed by D260, and the age-assurance and PEGI items (M8); Q86's item annotated; a legal-check owner input; Q173 and Q174. Before that: 2026-10-04 (D235–D258, Q168–Q172: M7 phase 5's m7-4 stage: the wiring, the device run, the TalkBack pass and the fidelity fixes ticked with their evidence; Q158 and Q159 answered; Q154 under v1.1; the 5f reruns' results, 5f-fj-2 and E13's re-measure are marked for the lead. Before that: 2026-10-01 (D210–D234, Q160–Q161: M7 phase 5A built: the fidelity items, B-SHARE, relit twinkles, chapter themes 7–10 and the animation polish ticked with their evidence; the device-run items (the fidelity audit, TalkBack, the skin landing, E9's `l1`) annotated as built and unrun, because the device stage stopped on disk; tabular figures moved to M8; the VoiceOver checklist, Q160, Q161 and phase 5's design questions added; the citation of the wiped scratchpad report fixed. Before that: 2026-09-30, D209 and Q159: phase 4's device run passed on both platforms; its item, the race-loss segment, the day-7 chest on a device and `nesty-test`'s device gaps ticked; the fidelity audit's list, two design gaps, Q159 and the reminder phone check added. Before that: D202–D208, Q158: phase 4 integrated: the lanes' and the integrator's phase-4 items ticked with their evidence, the delivered design items ticked, the device-pending ones annotated, the lanes' deferrals and Q158 added. Before that: D179–D201, Q156–Q157: phase 4's contracts stage: a phase-4 subsection with the five lanes' items, the design-delivered items, gaps and owner inputs ticked or annotated with their m7 P4.n section, and the design-answered questions ticked. Before that: D171–D172: the M7 delivery is in `design/`; the import item ticked, and phase 4 wires it in. Before that: D170: the HUD's "Replay" tag removed. Before that: D169: `nesty-test` covers every feature; its device gaps are an M7 item. Before that: M7 phase 5, the device run after the review: both platforms pass, dated notes on the audit, the VoiceOver and TalkBack pass, the race-loss segment and the reminder phone check, D168. Before that: M7 review pass, round 2: the accessibility audit ticked, and new items for the device VoiceOver and TalkBack pass, screen-reader board play (R12, Q154), R7's Android note and `shopOwned`'s copy; the pass-and-play proposal linked; Q154–Q155. Before that: M7 review pass, round 1: R2's paused-streak follow-up and R4's accent swap added under M7, the accessibility audit annotated with what is left, Q153. Before that: M7 phase 3 integrated: star ratings, the share card and the reminder, D156–D161, Q149–Q151; the phase-2 rival strip item done; the device run is next. Before that: M7 phase 3's contracts frozen, D144–D155, Q137–Q148. Before that: M7 phase 2 done: vs Computer integrated, D132–D142, and passed on both devices, D143, Q124–Q136. Before that: M7 phase 1 device stage: device-pass confirmed on both platforms, two app bugs fixed, Decisions D126–D131 and Questions Q121–Q123 added, eight deferrals proposed. Before that, star ratings added by the owner: D125, Q116–Q120. Earlier today: M7 phase 1 integrated, D113–D124, Q99–Q115; D92–D93; D90. M3 code complete; acceptance pending the owner's two physical-device checks).

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
  - `local-habits` is
    [plans/local-habits-brainstorm.md](plans/local-habits-brainstorm.md) (D237).
  - `engagement-research` is
    [plans/engagement-research.md](plans/engagement-research.md) (D259, D260),
    and `ERn` is one of its proposals. The kid path is its §6.
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

## M7 — Art and polish, plus the offline game: content, modes and engagement — code complete 2026-10-05, acceptance waits on the owner (started 2026-09-28, D90–D93, plan [plans/plan-m7.md](plans/plan-m7.md))

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
- [x] The device stage: every new file and the playthrough on the iPhone 16 Pro simulator and the API 35 emulator, and `--android --only reminder` — m7 P4.10 (done 2026-09-30: D209: every check passes on both platforms, iOS run 9 and Android runs 1 and 2, plus the reminder check; PROGRESS D209)
  - 2026-09-30 (phase 4 integrated, D202): `nesty-test --device-only` runs them all from fresh installs (`--only playthrough,resume,daily,board,race,meta,daily_states,overlays`); what each must show is in the integrator's report (`scratchpad/m7/reports/integrator-p4.md`)

Left from phase 4 (the lanes' deferrals, 2026-09-30):

- [x] Fidelity audit: the tutorial scrim leaves the HUD and booster bar bright (frames 1.3, 10.8b), and the step chip touches the family counter — device run p4, D209 (done 2026-10-01: F-TUT, D214: the tutorial overlay sits above the HUD and the booster bar, and Pause stays live through `IgnorePointer` (`gameplay_view_test`: the stack order, Pause under the scrim; `tutorial_overlay_overflow_test`). The frames' device comparison waits for the device run (5a-dev, blocked on disk: 16 GB free of the 20 GB floor).)
- [x] Fidelity audit: rival select's locked cards are invisible on the flat page (9.2), and the list's clipped edge under the pinned hint on 731 dp phones — device run p4, D209 (done 2026-10-01: F-RS1 and F-RS2, D218: the locked card is `sunkFace` with the inset `sunkShadow`, on `CreamPage`; the list ends in a 16 dp `ShaderMask` fade only while it scrolls, with a 12 dp gap above the hint (`rival_select_page_test` at 411x731 with 1.3x text and at 390x844). The frames' device comparison waits for the device run (5a-dev, blocked on disk: 16 GB free of the 20 GB floor).)
- [x] Fidelity audit: the chest card's art box is about 80 dp taller than 10.3b, 10.3c and 5.6, so the closed chest floats low — device run p4, D209 (done 2026-10-01: F-CH1, D215: a 200x130 art slot with the 200x200 canvas overflowing upward, the card top still 214 (`chest_reward_sequence_test`). The frames' device comparison waits for the device run (5a-dev, blocked on disk: 16 GB free of the 20 GB floor).)
- [x] Fidelity audit: Chapters opens with the current chapter at the top (10.4 shows the finished rows above it); locked cells' numbers aren't faded; "60 won" isn't right-aligned — device run p4, D209 (done 2026-10-01: F-CHAP, D230: three folded rows stay above the open card (fewer on a short phone), locked cells take `lockedCellFace` and `lockedCellText`, and "N won" ends at the card edge (`chapters_page_test`, group "phase 5 fidelity"). The frames' device comparison waits for the device run (5a-dev, blocked on disk: 16 GB free of the 20 GB floor).)
- [x] Fidelity audit: the rest of D209's list (the paused strip's static "Thinking…", the iOS Share glyph, the coin pill's missing glow during the chest's flights, the splash dolls hidden until the skin loads) — `scratchpad/m7/reports/device-p4.md` §5, D209 (done 2026-10-01: F-SPL, D210: the splash draws the fallback doll from the first frame and cross-fades (`splash_page_test`); F-CH2, D217: the coin pill and Hint badge rings and the trail dots (`reward_ring_test`, `chest_reward_sequence_test`, `gameplay_view_test`). The paused strip and the share glyph stay as built until Claude Design answers follow-up 8.6 and 8.7. The citation of the wiped scratchpad report is replaced by PROGRESS D209. The frames' device comparison waits for the device run (5a-dev, blocked on disk: 16 GB free of the 20 GB floor).)
- [x] design: Records' "Families completed" cell, its copy and glyph (`TODO(design)` in `records_page.dart`; Q159) — device run p4, D209 (done 2026-10-04: m7-4's DELIVERY 8.5 answered it: "Families completed" with the family counter's doll mark; `meta-06-records` asserts the label and a `DollMark`, 5d-i)
- [x] design: where a capped win says why on a short phone, since the helper note has no room there (11.2d, C11) — device run p4, D209 (done 2026-10-07: m7-5 Part 2 item 22, new frame 11.2g: the reason takes the tip's row and the families drop to 64 dp; D287 verified the game already does this)
- [x] (done 2026-10-07: delivered and imported, D281; Part 2's answers are wired in D287–D289) Claude Design's answers to "Follow-up after m7-3" (`docs/plans/claude-design-request-m7.md`): the tokens, copy ids, screen-reader strings and looks to confirm; take `nesty-design-m7-4` through the import checks — integrator, lead note 13, D202
- [ ] Rows of 5 and 6 with tall pieces: a tall case, its ice and a row of 6 are undesigned (the case is capped at the pitch − 2 dp, a 96-wide ice can overlap a neighbour by up to 2.4 dp), and `fourShelves` has no glass or ice sizes — lane B, `TODO(design)` in `board_geometry.dart`, `board_layout.dart`, `shelf_presets.dart`; follow-up §5
- [x] Device check of the board's short motions: the empty stand's dip, the padlock ping, the tag pop and the hover glow (16–240 ms). `board_layouts_test` polls their tweens and shoots before and after — lane B, the device stage (done 2026-10-05: `board_layouts_test` passes on the iPhone 16e and the Android emulator in the `/milestone M7` gate, its polls and before/after shots included)
  - 2026-10-01 (phase 5A): `board_layouts_test` polls and shoots them; the run has not happened (disk).
- [x] The relit twinkles (10.7b) on the daily win card: `StreakCard(relit:)` is built, the two `fx_twinkle` sparkles aren't placed — lanes D and O, follow-up §4.17 (done 2026-10-01: F-REL, D228: `DailyStreakCard` places two `fx_twinkle`s at (+44, -6) and (+52, +4), 22 and 14 dp, with the `relitGlow` spread (`win_chapter_card_test`). The sizes are the build's choice (follow-up 11.3).)
- [x] 12.6's failed card over the theme art only; the board stays dimmed behind it today — lane O, follow-up §4.13 (done 2026-10-05: recorded by design, DELIVERY Choices 4.13 (5f-fj-2: f9-3f, f12-6 "by design"))
- [x] The chest flights' gold ring on the coin pill and their 6 dp trail dots, once Claude Design gives the values — lane O, follow-up §1.7 (done 2026-10-07: m7-5 Part 2 item 3, `motion.chest.collect.pillRing` and `trail`, wired as `ChestCollectTokens.pillRing*` and `trail*`, D286)
  - 2026-10-01 (phase 5A): the ring and the trail dots are built from the frame 10.3d estimate (D217, `TODO(design)` FU 1.7 in `reward_ring.dart` and `reward_flight.dart`); left: Claude Design's values.
- [x] The family counter's hug with a width-free pill (the file's 70 dp pill scales 0.9–1.2 today) — lane O, follow-up §4.14 (done in m7-4: tokens `layout.hud.familyCounter.lottieWidth`; `family_counter.dart` resizes `pill_rect` and `glow_rect` with no scale; box ticked 2026-10-08)
- [x] The chapter ribbon: frame 4.7's two-line plate, or named fills on `ui_chapter_ribbon` to recolour it exactly (a colour matrix tints it today) — lane O, `TODO(design)` in `ribbon_tint.dart`; follow-up §4.15 (done 2026-10-07: m7-5 Part 2 item 7: 4.7 stays one line, recoloured through the named fills; `ribbon_tint.dart` is gone and `chapter_ribbon.dart` sets the fills, D287)
- [x] 12.5's reduce-motion spinner: a still frame 0 today; the proposal's slow pulse isn't specced — lane O, follow-up §4.17 (done in m7-4: `motion.spinner.reducedMotion`, 1 → 0.45 → 1 over 1,600 ms, built as `SpinnerPulse`; box ticked 2026-10-08)
- [x] Drop `DailyCubit.share` and its `ShareService` constructor argument (the solved card has no Share since D188) once the contract tests stop building it with five arguments — lane D, D207 (done 2026-10-01: B-SHARE: `DailyCubit.share` and its `ShareService` argument are gone; the contract, cubit, page and overflow tests and `di.config.dart` are updated.)
- [x] A way to turn a blocked reminder off in the app, if the owner wants one (Q158) — lane D, D207 (owner) (done 2026-10-04: the owner said "Build it" on 2026-10-01; the blocked row has a Turn off link (10.2f) and 10.2h's Off row, D244; `faults reminder_denied` asserts the link's 48 dp and `f_settings_turned_off`, passed on both platforms in 5d-dev)

### Phase 5, m7-4: the device run and its fixes (2026-10-04, D235–D258)

Evidence: PROGRESS "Phase 5, m7-4" and its Verification; the audit is
`build/m7-p5/reports/5d-aud.md`, the re-judge `5f-fj-1.md`.
- [x] Wire Claude Design's m7-4: tokens v4, `ui_rival_react` and `ui_museum_idle`, chapters 7–10's board wood, copy.md m7-4 in the English ARB, the game's and the menus' answers — m7-4, D235, D241–D245 (done 2026-10-04: four lanes and 5d-i; the device steps re-shot or added; 5d-dev's run passed after its fixes; the 5f run's reruns are pending, see PROGRESS Verification)
- [x] The TalkBack pass on the API 35 emulator — D224 (done 2026-10-04: `talkback.sh`'s 4th run, scenarios race, race_loss, game, meta: 26 of 36 screens match node for node, the other 10 expected; T1 fixed, D249; T2 recorded, Q171; the verdicts are at the top of `reports/talkback.md`)
- [x] T1: a toast stays up 10 s while a screen reader is on — TalkBack pass (done 2026-10-04: D249, `toast_geometry_test` "T1")
- [x] Fidelity: the wordmark's doll over the "e", frames 1.1, 10.8, 12.10 — 5d-aud (done 2026-10-04: 5f-fj-1 judged f1-1 and f12-12 fixed; D251, `splash_page_test`)
- [x] Fidelity: the tutorial tip's tail, frames 1.3 and 10.8b — 5d-aud (done 2026-10-04: 5f-fj-1 judged f1-3 and f10-8b fixed; D255)
- [x] Fidelity: the Daily page's lit streak card face, frame 5.5 — 5d-aud (done 2026-10-04: 5f-fj-1 judged f5-5 fixed; D247, `streak_card_test`)
- [x] Fidelity: the Museum's cabinet and next chip, the skin detail's gaps, frames 6.1b and 7.4 — 5d-aud (done 2026-10-04: 5f-fj-1 judged f6-1b and f7-4 fixed; D248)
- [x] Fidelity: rival select's locked ring, the portrait's inner ring, the versus pause rows and the leave card, frames 9.2, 9.6, 9.7, 9.7b (iOS) — 5d-aud (done 2026-10-04: 5f-fj-1 judged f9-2, f9-6, f9-7 and f9-7b (iOS) fixed; D250, D253)
- [x] Fidelity: the chest card's art size, frames 10.3b and 10.3c — 5d-aud (done 2026-10-04: 5f-fj-1 judged f10-3b fixed and f10-3c fixed with a small residual; D255, `chest_reward_sequence_test`)
- [x] Fidelity: Out of Moves' Undo row, frames 10.9b and 12.8 — 5d-aud (done 2026-10-04: 5f-fj-1 judged f10-9b and f12-8 fixed; D252)
- [x] Fidelity: the win card's stars frames 11.2b, 11.2c, 11.3, 11.4, 11.4b — 5d-aud (done 2026-10-04: 5f-fj-1 judged them fixed or matched; the shots are at the empty-stars instant)
- [x] The 16 unread ARB keys m7-4 added: wired, or retired with their reason — 5d-i (done 2026-10-04: D257, `arb_keys_m7_test`; only the 11 short forms stay unread, 5B's)
- [x] The frames the reruns re-shot (f2-3, f2-4, f2-5, f2-6, f6-1c, f8-4, f10-8 on Android, f9-7b on Android, the daily and settings shots) judged — 5f-fj-2; M7 (the reruns are pending, the lead appends the verdicts) (done 2026-10-05: the verdicts are in `build/m7-p5/reports/5f-fj-2.md` (30 frames; reruns green); the gate re-judges the residuals in 5C)
- [ ] Versus ribbon: the `ui_win_ribbon` band is 336 dp where frames 9.4 and 9.5 draw a ~290 dp body (f9-4, f9-5 still differ); only a new Lottie fixes it — Claude Design request 12.1; M7
  - 2026-10-07: m7-5 Part 2 item 5 delivered the new 290 × 56 `ui_win_ribbon` with named rects, and `FxRibbon` draws it unscaled (D287). Left: compare re-shot f9-4 and f9-5 with the frames, then tick.
- [x] E13 on a warm Android emulator: 10,025 ms in the 5f run (5d-dev: 3,906; iPhone 2,483 then 3,169), probably a freshly booted emulator; the playthrough rerun re-measures it — M7 (the lead appends the number) (done 2026-10-05: 6,569 ms on a warm emulator with the host quiet (`noisy` false: levels check 590 ms against 550), alone after every other run; the gate's 12,150 ms was a busy host (2,496); iPhone 3,700 ms; `runs/gate-android-quiet`)
  - 2026-10-05 (5f-startup, 5f-e13): no app regression. The rise followed the host-speed control (`levelsCheckMs`, r = 0.90 over 14 launches) on a busy host, and the new fonts cost nothing measurable; E13 is now timed by a 4 ms in-app poller and its record carries `levelsCheckMs`, `quietLevelsCheckMs` and `noisy`. The warm-emulator number is still the lead's to append
- [ ] The frame-only colours still in `AppColors` with `TODO(design)` (the lit streak card's peach, the spotlight panel, `cabinetDrop`, `rowDash`, `segmentedTrackShade`): add them to tokens.json, then move the call sites; asked in "Follow-up after m7-3" §11 — D244, lane M
  - 2026-10-07: m7-5 Part 2 item 1 tokenised the streak peach, `rowDash`, the cabinet shadow and the segment track (D289). Left: the figurine panel's two radial gradients (`app_colors.dart`), asked again in the m7-6 request.
- [x] design: m7-4's device-run asks to Claude Design, "Follow-up after m7-3" §12 (the ribbon band, the chest's rays, the badge toast's second line, 9.7b's Computer tag, the splash's arch, the Restart glow, the Museum all-home badge, the modals' anchor) — 5d-aud C, 5f-fb, 5f-fj-1; each ships its default (done 2026-10-07: m7-5 Part 2 items 5, 6, 11 and 18 and Choices 4, 12, 17 and 24, wired or verified in D287 and D289; the rays' softness is asked again as an m7-5 follow-up below)
- [ ] The toast over the win ribbon on screens under about 800 dp, and "Selected" on a picked rival card (Q171, Q172), and the owner's sign-off on the by-design pairs (5d-aud D lists) — D250; M7 (owner)
- [x] The English freeze for 5B and the translations' integration (5B-5 and after) — D240, `prompts/5b-integrate-additions.txt`; M7 (done 2026-10-05: the English freeze is 5b-copy's sha256 `1162e29f…`; the nine ARBs integrated by 5b-int, phases A, B1 and B2; D261–D267; the device run's results are pending, the lead appends them)
- [x] 5B's device run (`nesty-test --device-only --only locales,board,meta,faults,playthrough`, iPhone 16e and Android at 390x844, `build/m7-p5/runs/5b.status`): **pending (the lead appends the results)**, with the fidelity re-shoots 5f-fix2 lists: `b_05_family_complete`, `meta-02-chapters`, `meta-05b-museum-modal`, `01b3_museum_locked_modal`, `f_splash_storage`, `f_splash_content`, `00b_splash_loaded` (now in `faults`) and the skin detail shot (Forest Bear, f7-4b) — 5f-fix2, 5f-e13; M7 (done 2026-10-05: the 5B run stopped on iOS (`objective_c.framework`, stale native assets after an iOS release build); after a `flutter clean`, the `/milestone M7` gate's device stage covered it: locales, board, meta, faults and the playthrough pass on both platforms, with the reruns in PROGRESS "Phase 5, 5C")
- [x] The visual review of the locales' screenshots (`l10n-<code>-NN_<screen>`) and the E13 re-measure on a warm Android emulator, after the device run — 5B; M7 (the lead appends) (done 2026-10-05: 94 shots (de, hi, ja on both platforms) all ok, ja's "DAY" and "NEW" being the translation review's choices (`reports/5c-loc-*.md`); E13 re-measured as the item above)
- [x] design: Fredoka at the pin lacks the Turkish ğ Ğ İ ş Ş (and ₹), so Turkish display text falls back to Nunito mid-word; the coverage test passes because the fallback chain covers them. Ask Claude Design for a Fredoka build with Latin Extended-A, or the owner picks another face (`TODO(design)`; "Follow-up after m7-3" §13) — 5b-fonts, D262; M7 (done 2026-10-07: Turkish display text draws whole strings in Baloo 2, D291, D292)
- [x] Per-locale tuning of the Shop's tall-script slack (a flat +2 dp today) and the Hindi and Japanese line heights, if the device run shows a clip — 5b-om, D263; M7 (done 2026-10-05: not needed; the gate's 94 locale shots (de, hi, ja on both platforms) show no clip (`build/m7-p5/reports/5c-loc-*.md`))
- [x] After a new kanji lands in `app_ja.arb` (or any Japanese copy), rerun `gen_font_subsets`, `tools/fonts/build_fonts.sh` (needs the network) and `--verify`; the font coverage test fails until then — 5b-fonts, D262; M7 (done 2026-10-05: a standing procedure, written in `.claude/rules/l10n.md` ("A new Japanese kanji needs `gen_font_subsets`, then `tools/fonts/build_fonts.sh`") and enforced by the font coverage test)
- [ ] A VoiceOver and TalkBack pass in German, Hindi and Japanese on a phone whose own language differs (a German game on an English phone is read with an English voice; Flutter sets no per-node locale here) — 5B risk 9; the owner (join the checklist [plans/voiceover-checklist.md](plans/voiceover-checklist.md))

### Phase 5, 5C: the review and the gate (2026-10-05, D271)

- [x] `/review` with the security scanner and the ethics lens, and its verified findings fixed — `build/m7-p5/reports/5c-*.md`, PROGRESS "Phase 5, 5C"; M7 (done 2026-10-05: security clean, no P0, 10 code findings fixed, the es/pt/ja "computer rival" wording)
- [x] The race strip keeps the word "Computer" at 360 dp and up: the dots, then the state line give way (`_StripRoom`), and `computer_word_test` checks 9 locales at 360 and 390 dp, 1.0× and 1.3× — 5c-eth P1, D271; M7 (done 2026-10-05)
- [x] design: the race strip's two new forms, the count without dots (a long name, or above 8 families) and the tag on the second line in place of the state line (a long name at 360 dp or 1.3× text). Ask Claude Design to draw them with frame 9.3 (`TODO(design)` in `rival_strip.dart`; "Follow-up after m7-3" §14) — D271; M7 (done 2026-10-07: answered by 9.3, 9.3h, 9.3i, D288)
- [x] design (m7-5 follow-up): copy.md's streak freeze chip says "{count} streak freeze(s)", but that overflows the streak card's row (12 overflow cases) and echoes our question's wording. Ask Claude Design for a wording that fits (the game ships "1 freeze" / "{n} freezes") — D284
- [x] design (m7-5 follow-up): 9.3i draws the `NestyStrip` tag scaling with the text (20k tall, glyph 14k); the game's `ComputerTag` keeps 20 dp because every rival surface shares it. Ask whether every `ComputerTag` should scale — D288
- [x] design (m7-5 follow-up): 9.3i draws Pause as tall as the 58 dp strip; the game keeps Pause at 48 dp (`HudTokens.pauseButtonSize`) and nothing in tokens or the README says it grows. Ask, or add a token — D288
- [x] design (m7-5 follow-up): the 16:9 gift sheet's Claim is 54 tall in frame 13.3b, and the game's large button is 58 (the sheet is 465, not 461). Ask for a 54 button size or a 58 Claim — D285
- [x] design (m7-5 follow-up): 13.6b's Day 7 ribbon is 46 tall at Fredoka 21 with padding 24; the shared `RibbonTitle` draws 18/700 with padding 9/22 (the same as 10.3b). Ask whether one ribbon spec serves both — D285
- [x] design (m7-5 follow-up): the done tile's check is drawn at weight 700; the bundled icon font is a static 600 cut. Ask whether 600 is acceptable, else cut a second weight — D282, D285
- [x] design (m7-5 follow-up): `textFit.winRibbon.box` still says 312 x 40 while `winRibbon.size.textBox` says 266 x 40; `type.museum.count` says 20 while the frames draw 16; the figurine panel's two radial gradients have no token. Ask Claude Design to fix the tokens — D287, D289
- [x] design (m7-5 follow-up): the Museum's won nameplates draw a glossy, saturated gold with a diagonal shine; frame 6.1c draws them pale, flat gold. The styling predates m7-5. Match the frame, or ask Claude Design which is meant — stage E iOS, D296
- [x] design (m7-5 follow-up): on a short phone (731 dp) the gift tally ends about 2 dp from the chapter card's "CHAPTER n" label, so a two-digit count covers its start for the tally's 1.2 s visit (under the scrim). Ask whether the tally may cover the card, as 13.5b and 13.6d draw it, or should step aside — stage E Android, D285
- [x] design (m7-5 follow-up): the opened chest's rays (`ui_chest`, m7-5 item 6) read as hard wedges on the device, where 10.3c and 13.6c draw a soft glow. Ask for a softer ray matte in the Lottie — stage E, D287
  - 2026-10-08: the ten "m7-5 follow-up" items above were asked in m7-6's Part 2 and are answered and built (the chip's short form, the tag's scale, Pause's 5 dp, Claim 58, the Day 7 ribbon, the check's 600 cut, the tokens, the name plate, the tally, the rays' matte; D304, D307). Ticked 2026-10-08 after stage E (D309): the device shots match for the chip, the tag, the Day 7 ribbon, the plates and the rays; 9.3i's Pause and 13.3b's Claim have no device shot and rest on their host tests
- [ ] test (m7-5): `locales_test`'s chapter-ribbon check (`_level`, 300 ms after level 61 is ready) misses the 2.6 s ribbon when a starved emulator skips seconds of frames at the level's start (the Android `hi` run). Wait for the ribbon with a bound, or record that it showed, instead of a fixed delay — stage D, D296
- [ ] test: `gameplay_bloc_test` "soft stuck: a verdict for an older board is dropped" waits on real-time settles of a few ms before it expects the held request. Under host load (the m7-5 final run, load ~20) the debounce hadn't fired yet and it failed once; the file passes alone (145/145). Drive it with fake time, or pump until the request is held — stage C, D296
- [x] Look at the strip's count-only and two-line forms, the Home vs Computer tile and the race Pause header in es and ja at 1.3× on a device — 5c-fix; M7 (the locale screenshots of the gate's device run) (done 2026-10-05: ja on both devices at 1.0× shows the word on every rival surface (`5c-loc-*`); es and 1.3× are checked on the host, readable, uncut and with the word (`computer_word_test`, the overflow suite in gate mode); how the two new strip forms should look is Claude Design's §14)
- [x] The `/milestone M7` gate (`build/m7-p5/bin/m7_gate.sh all`: host, the four builds, `nesty-test --device-only` on iOS and Android from fresh installs, which also runs the 11 English-pinned checks for the first time): **pending (the lead appends the result)** — M7 (done 2026-10-05: host, the four builds and both devices pass, with the reruns of the test fixes; PROGRESS "Phase 5, 5C")
- [x] The loss card's `ui_rival_react` `win` hop with confetti (9.5): keep as designed (default), play `idle` or the `lose` nod, or ask Claude Design for a gentler segment — 5c-eth P1, Q183; M7 (owner) (done 2026-10-05: the owner keeps it as designed, D273)

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
- [x] Chapter themes 7–10: the art once Claude Design delivers it (chapters 7–10 reuse ch01–ch04 today, `themeIds[(N - 1) % 6]`, Q38), their Shop theme cards and prices, and real thumbnails on every theme card — §7.4, §12.4, frame 7.7, D90 (done 2026-10-01: the art (D176), `ChapterTheme` ch07–ch10 with their palettes (D199), the crops on every theme card (D206), and the prices at Q156's default 2,000; the owner's own prices stay Q156)
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
  - 2026-10-05 (the `/milestone M7` gate): iPhone 16e 3,700 ms; the warm emulator 6,569 ms (not noisy); main() to level 1 playable, no screen between (E9 passes on both). Left: the owner's seconds on a physical phone
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
  - 2026-10-04 (m7-4 device run): the audit of 123 pairs (5d-aud) and its fixes are done (D247–D258); 5f-fj-1 re-judged 31 frames (20 fixed, 8 by design, 2 still differing, 0 regressions). The owner's sign-off on the by-design pairs (5d-aud's D lists) is still open. See "Phase 5, m7-4" below.
  - 2026-10-05: 5f-fj-2 judged the reruns' frames; the `/milestone M7` gate re-shot the 16 frames still open and 5c-rj judged them: 15 fixed, f2-6 by design, none still differing (`build/m7-p5/reports/5c-rj.md`). E13's warm-emulator number is 6,569 ms. Left: the owner's sign-off (Q161)
  - 2026-10-01 (phase 5A): 5A built the fixes of the scene-CSS audit (D211–D219, D229–D231): the cream page, the headers, the locked looks, the type pass and the Museum, Records, Shop and Settings, each with a host test; the device comparison against all 116 in-scope frames (`pairs.txt`, `pair.mjs`) has not run, because 5a-dev stopped on disk. Left: that run, the audit and its fixes, then the owner's sign-off (Q161).
- [x] Home's shelf after a skin equip: `ShowcaseDolls` keys its art on the pixel ratio and the symbols mode, not the skin, and nothing tells it about `SkinService.selectSkin`, so after an equip in the Shop the Home shelf keeps the old skin until the app restarts (found by reading the code while fixing D91; not yet seen on a device) — §7.4, D58, D91 (done 2026-09-28: `ShowcaseDolls` follows `SkinService.selectedSkinChanges`, D109; `showcase_dolls_test.dart`)
- [ ] Tune the haptic patterns, including the multi-pulse success, on real devices (moved from M3: it needs the owner's hands on real phones; `TODO(M7)` in `system_haptics_service.dart`) — §11.2, PROGRESS "Notes for later milestones"
- [x] The Daily puzzle card's preview: draw the chapter background under its plank (NestyMenus isDaily, `backgrounds/ch3-seaside-market.svg` at center 42%/cover). `SkinService.background` is the one full-screen raster, so it needs a small per-card theme raster (`TODO(M7)` in `features/daily/widgets/puzzle_card.dart`) — frame 5.1, M3 review FIDELITY-2 (done 2026-09-28: `DailyBackgroundLoader` and `DailyThemeBackground`, the menus lane; `daily_background_loader_test.dart`)
- [x] "Play Bonus Level N" on All Levels Done when that level can't be generated: the card stays up with its button live. Continue's failure already has `NextLevelFailedCard`; give this path the same (`TODO(M7)` in `gameplay_view.dart`) — M3 review CORRECTNESS-3 follow-up (done 2026-09-28: `_pendingBonusRetry` and the retry card, the gameplay-ui lane; `gameplay_view_test`)
- [x] A restored out-of-moves board whose intro card was never dismissed shows the card over the reopened sheet, whose rows wait for "Got it" (`TODO(M7)` in `gameplay_view.dart`) — M3 review CORRECTNESS-1 follow-up (done 2026-09-28: the sheet waits for the card, the gameplay-ui lane; `gameplay_view_test`)
- [x] Overflow tests on small Android, standard phone, tall phone, small iPhone and iPad portrait, at 1.0× and 1.3× text — §18 M7, §16 (done 2026-09-28: `test/overflow/`, 21 files over `overflowScreenSizes` × `textScales`, D121; every screen and overlay, the real Chapters and Records grids, the chest modals open and closed, the win card variants, the new Settings rows and the Daily states, paused included)
- [ ] Sweep the fully navigated bottom-nav shell (Home under the real router) for overflow at the five sizes, beside today's chrome-and-`HomeView` sweep, if Q112 says so — overflow lane report
- [x] Animation polish: tune by feel each clip's playback speed (never the JSON), the hand-coded tweens of lottie §9 (`TODO(M7)`), the wobble snap into `doll_move` (settle it before the move), an animated undo (`BoardResetEffect(undo)` cuts today), re-placing the clips in flight during a +1 Slot re-pitch, the coin count-up (700–1300 ms) guess, and the intro-card loops. The tower reveal's drop now comes from `doll_reveal` (D60) — §11.1, lottie §7, §9, timeline report (done 2026-10-01: dispositions: each clip's playback speed is pinned by `fx_playback_speed_test` and the files stay untouched; the §9 tweens match `tokens.json` (the invalid shake, the re-pitch) and the clips in flight follow a re-pitch (`board_hot_path_test`); the coin count-up is `stars.startMs` minus the coins' start, 600 ms (D220); the intro loops are in (D208); the animated undo flies back (D221, D227, `board_timeline_undo_test`); the wobble snap into `doll_move` stays as built, since the design has no settle before a move (follow-up 11.2); the haptic patterns equal `tokens.haptics` and their feel is the owner's)
- [x] Swap in the designer's Lottie re-export when it arrives (done 2026-09-27: Claude Design v3, imported in the post-M2 round, D59, D60) — re-export, lottie §18, D43:
  - re-sync (`sync_design_assets`) and regenerate `fx_spec.gen.dart` (`gen_fx_spec`). Any change to a length, a marker, the canvas or a hook fails validation until `tools/lib/src/fx/lottie_contract.dart` is updated, and its test also reads LOTTIE.md, so LOTTIE.md must agree;
  - before any lottie upgrade, rerun `fx_compensation_test`, `fx_travel_test` and `fx_workarounds_test`: they pin lottie 3.6.1's internals;
  - remove each workaround whose cause is fixed (hold fix, padlock hide, settle ramp, reveal silhouette hide, animated-scale callbacks);
  - keep the equivalence tests green.
- [x] +1 Slot plays `button` twice: the booster's tactile feedback and the timeline's `ExtraSlotAddedEffect` cue (m2-lottie-design §7 lists the cue). Keep one — review fix pass (done 2026-09-28: the timeline's cue is gone, D116, Q110; `board_timeline_boosters_test`)
- [x] Final audio: replace the placeholder WAVs, normalize levels, re-check the clack pitch offset, and add the music loops (done 2026-09-27: the SFX v2 WAVs baked at 0 semitones, the two OGG loops and three jingles, D61) — §11.3, D19, services report
- [ ] Final mix by ear on a mid-range Android and an iPhone: `SfxMix.gains`, the music's 0.5 and the ducks, the jingles over ducked music. The worst realistic stack has about 0.14 dB of headroom: keep the cues staggered, and turn on SoLoud's limiter only if clipping is heard — audio plan §2 "Clipping", audio audit §5
- [x] The `ui_extra_slot` loop starts at its rest pose (96 %, 75 % opacity) when the 300 ms re-pitch ends, after the static pad drew the stand at 100 %: a small pop. Start it at frame 24 (100 %) or fade it in — lottie lane report, `board_pieces_l9_test.dart` (done 2026-09-28: it starts at frame 24, `FxTiming.extraSlotRestFrame`, D116)
- [x] The `ui_extra_slot` loop's opacity is still about 88 % at frame 24 (its opacity ramps on a slower curve than its scale and reaches 100 % near frame 44): a smaller pop than before. Take Claude Design's E.21 or crossfade it in, with the animation polish pass — board-fx report, Q111, `board_pieces_l9_test.dart` (done 2026-09-30: lane B: the loop starts on the `rest` marker (frame 0, the static pad's pose), settles and stops under a doll and restarts when empty (`board_pieces_l9_test`); D184, D204)
  - 2026-09-30 (phase 4, m7 P4.3): m7-3's file rests on frame 0 (the `rest` marker; D178, D184). Left: lane B
- [x] Device check: the gameplay skin lands within the route transition (`prepareForLevel` starts on the board's first layout; placeholder dolls show until it lands) — screens report (done 2026-10-05: iPhone 130 ms with the route done at 422 ms; the warm emulator 659 ms with the route done at 660 ms, so it lands inside the transition, which the emulator runs slower than its 400 ms)
  - 2026-10-01 (phase 5A): the playthrough records `skinLand` (`skinLandMs` from the tap on "Play level 2" to the skin on the board); 5a-dev judges it against 400 ms once the run happens.
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
- [x] Translations: es, pt-BR, id, hi, de, fr, tr, ja — §16 (done 2026-10-05: nine catalogs, the script fonts, the fit, the language sheet and the locale tests, D261–D267; the device run's results are pending)
- [x] The Flame board's "+N" tower tag and the ice badge's digits through ARB, with the locale's text direction, handed to `SlotDecor` when the board is built (`TODO(M7)` in `slot_decor.dart`). Every launch language writes "+3" the same way today — §16, review PERF-RULES-3 (done 2026-09-28: `BoardLabels` from `boardTowerHidden`/`boardIceCount`, D116; `slot_decor_test`, `board_tree_test`, and `gameplay_view_test`'s non-English label)
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
  - 2026-10-01 (phase 5A): 5A built `semantics_tour_test` (four scenarios, holds, a traversal dump) and `talkback.sh` (D224); neither has run. The VoiceOver half is the owner's: `docs/plans/voiceover-checklist.md`.
  - 2026-10-04: the TalkBack half is done, see "Phase 5, m7-4" below (its tick). What stays open here is the VoiceOver half and the owner's listening checks.
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
- [x] Optional E9 device check: kill the app during L1 and relaunch; it must reopen L1 — integrator-p1, m7 §13 (done 2026-10-05: `phase A (l1)`, the kill and `phase B (l1)` pass on both platforms in the gate (level 1, 2 free undos, 0 extra slots))
  - 2026-10-01 (phase 5A): `NESTY_RESUME_SCENARIO=l1` is built in `resume_phase_a/b_test` (one tutorial move, kill, relaunch into level 1 with the same board); its run is pending. If it isn't reliable, it moves to v1.1 with the reason.

## Local habits — picked, after the daily gift and before any backend (D237, D274)

Not a milestone. The reasoning is
[plans/local-habits-brainstorm.md](plans/local-habits-brainstorm.md). The
owner picked all four, in order, with the widget last (Q162, D274). The prompt
that starts the build is
[plans/local-habits-claude-code-prompt.md](plans/local-habits-claude-code-prompt.md),
and the design request is
[plans/claude-design-request-m7-6.md](plans/claude-design-request-m7-6.md)
(App Flow section 14). Both were written on 2026-10-08. The build's stage 0
writes `plans/plan-local-habits.md`, with the archive rule (§7.5c) for the
owner to approve. Spec §7.5 and GAME_SPEC.md stay as they are.

- [ ] Claude Design's delivery for section 14 (`nesty-design-m7-6`: welcome back on 2.1/2.1b, the month, the past dailies, the widget, the `habits` tokens, the art and the copy), imported through BACKLOG M7 "Importing a Claude Design delivery", then the stand-ins swapped — the design request, D274 (2026-10-08: copied into `design/` at the owner's request, D301; imported the same day, D304–D308: tokens v6, the copy, the welcome card, the month and 12.14 on the final look, Part 2's items; passed on both devices with its fidelity judged, D309; the month's hint, chip and taps, the past day and the widget wait for stages 3 and 4)
- [ ] design: 12.14's `DailyLockedCard` sizes (card radius 32, the 76 dp piece, title 26, body 16, the 58 dp button) have no tokens; they come from the NestyHabits `dailyLocked` scene. Ask Claude Design for a `layout` entry, then replace the `TODO(design)` in `apps/game/lib/features/daily/widgets/daily_locked_card.dart` — D306
- [ ] design: the family counter's Fredoka metrics: the bundled Fredoka measures "12 / 12" at 37 dp at 1x where the design's pill draws 44, so ours is 71 dp against 78 (and 48 against 57 at 1.3x). Ask whether the design's font differs from the pinned cut, or accept the gap — D307, `build/m7-6/reports/b-game.md`
- [ ] design (fidelity note): the figurine modal's count reads "0/20" (the shared `homeMuseumProgress`, "{done}/{total}") where NestyOverlay draws "15 / 20"; a spaced form needs its own key in nine catalogs. Predates m7-6 — stage E, `build/m7-6/reports/e-fidelity-android.md`
- [ ] design (fidelity note): the welcome card's close glyph stays at the bundled 600 cut while tokens say `dismissGlyphWeight` 700; no 700 cut is built, as for the gift's check. Accept, or cut a second weight — D307
- [ ] design: the Daily page's month card sits 16 dp under the puzzle card, not 12, and the card's header does not fade the content under it once scrolled (14.2: top 728, 16 dp fade); frames 14.2c-g and 14.1d were judged by tokens only. Settle in stage E's fidelity judging — D306
- [ ] design: 14.3d (a past day's win) on a short screen: the card keeps the frame's button top (630 from the safe top), so at 731 dp (the 16:9 Android emulator) Back to Daily sits on the top of the board's dimmed bar; the regular daily card's two buttons cover the bar whole there. Ask for 14.3d at 731 dp (or 16:9), then blend `PastDayWinCard`'s layout — D313, `build/local-habits/reports/stage3-fidelity.md`
- [ ] design: typed tokens for 14.3d's sizes: the Moves pill's Fredoka 700 28 #5B3A21 and the date cell's day at Fredoka 700 22 are only in `habits.pastDay.win`'s prose and the frame's CSS, so the app spells them out (`TODO(design)` in `win_result_chips.dart` and `past_day_win_card.dart`) — close review, D314
- [ ] design: the widget's first-run state (nothing stored yet) has no frame; both platforms borrow the locked look with the native strings (`TODO(design)` in `NestyWidgetViews.swift`, `NestyWidget.swift` (the gallery preview) and `NestyWidgetRenderer.kt`) — D312, design spec gap 3
- [ ] design: the widget's size tiers are the spec's defaults: iOS's short-widget tiers (gap 4), Android's locked and 4 × 2 tiers (gap 4 tiers only the 2 × 2's streak look), and the medium flame kept at 46 dp in the compact tier (`TODO(design)` in `NestyWidgetViews.swift`, `NestyWidgetRenderer.kt`) — D312
- [ ] design: the widget's text fits: the line on one line then the short form (gap 12), the label wrapping to two lines in the 104 column, 1000+ on the number's 0.8 floor alone (gap 16), the type cap at xxLarge (gap 19), and SwiftUI's greedy wrap where 14.4 balances the line (`TODO(design)` in `NestyWidgetViews.swift`, `NestyWidgetStyle.swift`) — D312
- [ ] design: the widget's dolls show the first N with no "+N" (gap 15), and past the last entry it shows the generic title with no sub or dolls (gap 18) (`TODO(design)` in `NestyWidgetViews.swift`, `NestyWidgetCore.swift`) — D312
- [ ] design: the widget's tinted look (14.4f draws mock values; the system applies its own tint) and StandBy (uses the dark tokens) (`TODO(design)` in `NestyWidgetStyle.swift`) — D312
- [ ] design: no widget face is drawn for tr, hi and ja, which use the system face (gap 10); Android draws the system sans in every language, with "sans-serif-medium" bold (weight 800 on API 28+) where the frames draw Roboto 700 (`TODO(design)` in `NestyWidgetStyle.swift`) — D312, `build/local-habits/reports/stage4-android.md`

The plan is [plans/plan-local-habits.md](plans/plan-local-habits.md) (stage 0, 2026-10-08, D297–D299). Its §7.5c (the past dailies) counts as spec: the owner approved it (Q189, D310). Checkpoints and reports are in `build/local-habits/`.

### Stage 0: the plan

- [x] `plans/plan-local-habits.md`: each habit's data, rules, stand-in UI, strings, host tests, device step and TEST_COVERAGE row; §7.5c as spec-prop text; the two Remote Config keys; the widget's native plan; this work list — D297–D299 (done 2026-10-08: written; `home_widget` 0.10.0 researched and not taken, D299)
- [x] The owner approves §7.5c and its defaults (Q189), and answers Q190 (the month boundary) and Q191 (a frozen day's mark) or keeps their defaults — plan "Open questions" (approved 2026-10-08 with the defaults, D310)

### Stage 1: welcome back (local-habits 1)

- [x] `welcome_back_days` (`RemoteConfigKey<int>`, 2, clamped 2–60) in the keys, defaults, fake and `all`, with its `remote_config_keys_test` row — plan §"What the admin tunes later", D269 (done 2026-10-08: `RemoteConfigKeys.welcomeBackDays`, clamped by `WelcomeBackRules.clampDays`; `remote_config_keys_test` expects 33 keys)
- [x] The settings `lastOpenDate` (a high-water date) and `welcomeBackDate` in `settings_schema.dart`. No save schema step. The open-date write happens in bootstrap and on each resume, after the previous value is read — plan §1, D298 (done 2026-10-08: `SettingsKeys` and `DatabaseService` accessors in Hive and the fake, the contract test; `WelcomeBackTracker.start()` in bootstrap before `runApp`, reading before it writes)
- [x] `WelcomeBackRules` (pure, `core/services/welcome_back/`) and `welcome_back_rules_test`: gaps of 0, 1, 2, 3 and 30 days; a first launch; the clock wound back (no card); forward then back; a resume on a new date; Remote Config clamped — plan §1 (done 2026-10-08: `welcome_back_rules_test` and `welcome_back_tracker_test` pass)
- [x] `WelcomeBackCubit` (`BaseAsyncCubit`, freezed `hidden` / `shown(variant, streak)`) with `bloc_test`: three variants; hidden while locked and once today is solved; a dismissal kept through a resume; gone on a new date — plan §1 (done 2026-10-08: `welcome_back_cubit_test` passes)
- [x] `WelcomeBackCard` inline on Home (2.1: the hero band under the chapter card; 2.1b: the chapter card's slot while it shows). It has the three variants, one Play button to today's daily, a 48 dp close control with its label, and a fade and rise (a fade under reduce motion). `TODO(design)` for 14.1. Widget tests and `home_page_test` beside the gift's ready dot — plan §1 (done 2026-10-08 on the stand-in: `HomeLayout.welcomeCardTop` on 2.1, the chapter card's slot from t≈0.04 on 2.1b, where it covers the tallest doll's head (for 14.1 to settle); Play pushes Daily then today's board, so Back to Daily lands on the Daily; the headline wraps before it shrinks; the card and Home tests pass)
- [x] About 7 strings in nine catalogs with the Opus review (D240); `welcome_back_overflow_test` in nine locales; `gen_font_subsets` (and `build_fonts.sh` if a hi or ja glyph is new) — plan §"Shared pieces" (done 2026-10-08: 2 new keys, the variant lines reused from the Daily; the Opus review fixed de, pt and ja; id "Halo lagi!", pt "Olá de novo!" and tr "Bulmacayı oyna" after the overflow suite's floor; the overflow suite passes in nine locales; `gen_font_subsets --check` passes, no new glyph)
- [x] `welcome_back_play` through `AnalyticsService`, with its `TODO(M4)` to the kid-path item — plan §"Shared pieces" (done 2026-10-08: logged by `WelcomeBackCubit.play`, with the `TODO(M4)`)
- [x] `test/ethics/local_habits_respect_test.dart` (code, streak-field, copy and pop-up scans) with welcome back's paths — plan §"Shared pieces" (done 2026-10-08: the code, streak-write, pop-up, navigation and red-mark scans, a 600-step clock walk, the copy in nine locales; `checkedPrefixes` gains `welcomeBack` and `dailyMonth`)
- [ ] Device: the `daily_states` scenario `welcome` (Home with the card, then dismissed), the playthrough's Home shot with the card, `nesty-test`'s scenario loop, and the TEST_COVERAGE row `features/welcome_back` — D169 (2026-10-08: written and passing on the iPhone 16e, shots judged; Android with the stage-3 run)

### Stage 2: a month of played days (local-habits 2)

- [x] `WeekStart.of(rendered, deviceLocales)` (`core/ui/week_start.dart`): the week's first day from `intl`, keeping the phone's region (`en_GB` → Monday). Tested for en_US, en_GB, de, pt_BR, ja, hi and tr — plan §"Shared pieces", D298 (done 2026-10-08: reads the date data `GlobalMaterialLocalizations` already loads, so no extra intl table; `week_start_test` passes)
- [x] `DailyMonth` (pure, `core/services/daily_month/`): the grid's cells from `daily.done` and `daily.frozen`, with `daily_month_test` covering the 1st and the 31st, a leap February, Monday and Sunday starts, 4–6 rows, freezes, and a Daily just unlocked — plan §2 (done 2026-10-08: `daily_month_test` passes; it already takes stage 3's `played` and `window`)
- [x] `MonthCard` under `PuzzleCard` on the Daily. It shows the title (`DateFormat.yMMMM`), the weekday header (`intl`), and lit, frozen (Q191), not-played and future days, with today marked. It has no red, no X and no "missed". `DayStrip` stays the streak's cycle. `TODO(design)` for 14.2; `month_card_test` — plan §2 (done 2026-10-08 on the stand-in: lit = the streak gradient, frozen = `acUnit`, today = a primary ring; `month_card_test` and `daily_page_test` pass)
- [x] About 6 strings (the day cells' labels) in nine catalogs with the Opus review; `daily_month_overflow_test` in nine locales with the readability floor in ja and hi — plan §2 (done 2026-10-08: one `select` key with nine states; the month's overflow suite passes in nine locales, with the readability floor in ja and hi)
- [x] The ethics test gains the month's copy and looks — plan §"Shared pieces" (done 2026-10-08)
- [ ] Device: the `daily_states` scenario `month` (`NESTY_FAKE_DATE` 2026-10-31, lit, frozen and blank days), the playthrough's Daily shot, and the `features/daily` row in TEST_COVERAGE — D169 (2026-10-08: written and passing on the iPhone 16e, shots judged; Android with the stage-3 run)

### Stage 3: the last 7 dailies, playable (local-habits 3; §7.5c approved, D310)

- [x] `daily_archive_days` (`RemoteConfigKey<int>`, 7, clamped 0–28) and `DailyArchiveRules` (pure: the window, `isPlayable`, `prune`) with `daily_archive_rules_test` — plan §3, §7.5c (done 2026-10-08, D311)
- [x] Save schema 3 → 4 (`migrations-engineer`): `dailyArchive {played, inProgress}` apart from `daily`. It needs the step, a real schema-3 fixture `fixtures/schema3_document.json`, the migration, codec, Hive backup and contract tests in both save services. If Q190 keeps its default, `maxDates` also goes from 31 to 62 — plan §3, D298 (done 2026-10-08: schema 4, `maxDates` 62, D311)
- [x] `PlayRequest.pastDaily` / `PlayKind.pastDaily` and `DefaultLevelResolver._pastDaily`: the same board as that date's daily, `rewardCoins: 0`, and a date outside the window refused (a board in progress excepted) — plan §3 (done 2026-10-08: the resolver takes the `AppClock`, D311)
- [x] The save and the bloc: a past-day win pays nothing and writes no `daily` field, `records.dailies`, `longestRun`, `lastSolve` or chest. It adds `dailyArchive.played`. It counts in stats, families and dolls like a replay. Its in-progress board goes to `dailyArchive.inProgress`, and today's board survives a past-day game — plan §3, §7.5c (done 2026-10-08, D311)
- [x] nesty_core `test/generator/daily_past_dates_test.dart`: the 7 past dates' boards are deterministic and equal the board built on that date, on the VM and the web parity run — plan §3 (done 2026-10-08 as `test/parity/daily_past_dates_test.dart`, so the node, chrome and dart2wasm runs take it by directory, D311)
- [x] The picker in `MonthCard` (the window's days tappable at 48 dp; older days plain, with no lock and no word; Q190's month paging), the past day's `PuzzleCard` (no coin chip, the calm line, Play again, back to today), the board's date pill, and the win card's past variant ("Moves N", no coins, streak card, chest, Share or reminder offer). `TODO(design)` for 14.3 — plan §3 (done 2026-10-08 on m7-6's final look, so no `TODO(design)`: `PastDayCard`, `PastDayWinCard`; the day targets are 48 dp tall and one column wide, and today's cell scrolls up to today's card, D311)
- [x] About 6 strings in nine catalogs with the Opus review; the overflow suite for the past day's card and win in nine locales — plan §3 (the strings came with m7-6's copy and its Opus review, D305; the overflow cases are in `daily_month_overflow_test` and `win_overlay_overflow_test`, D311)
- [x] `past_daily_complete {days_ago, again}` through `AnalyticsService`, with its `TODO(M4)` — plan §"Shared pieces" (done 2026-10-08, D311)
- [x] The ethics test gains a 400-step walk of past-day wins and replays that never changes the streak's fields or coins, and the archive's copy — plan §3 (done 2026-10-08, D311)
- [ ] Device: the `daily_states` scenario `archive` (today's board in progress and a paused streak, a past day played to its win, the streak card unchanged, today's board resumable), its shots, and TEST_COVERAGE's "The past dailies" row — D169
- [ ] The device run after stage 3: the full `nesty-test` on the iPhone 16e and the Android emulator, under `watch-run`, with every new shot judged against the plan's stand-in intent — the owner's brief

### Stage 4: the home-screen widget (local-habits 4; after 1–3 pass on both devices)

- [x] `HomeWidgetService` (interface, `ChannelHomeWidgetService`, `FakeHomeWidgetService`), `HomeWidgetSnapshot` (v1: `unlocked`, eight dated days `{streak, lit, solved}`, localized lines, the scheme), and `HomeWidgetBridge` started by bootstrap. It writes on start, resume, every `DailyService.changes` and a language change, and skips an unchanged write — plan §4, rule 4, D299 (2026-10-08: built by lane dart, D312; the snapshot carries `state` and every string localized, contract in PROGRESS D312)
- [x] `DailyService.projection(from, days)` (pure, no write), tested against `refresh()` walked day by day over 40 seeded saves — plan §4 (2026-10-08: done, D312)
- [x] The deep link: per-flavor URL schemes (`nesty`, `nesty-dev`, `nesty-stg`) and the engine's deep linking on both platforms; `deepLinkBuilder` through the splash to the Daily (locked → Home, first launch → L1) and a warm link; `widget_open` logged — plan §4 (2026-10-08: done; a warm link with the Daily locked changes nothing, D312)
- [x] iOS: the `NestyWidget` extension via `tools/ios/add_widget_target.rb`. It needs the nine configurations, `$(app id).widget` ids, an `APP_GROUP_ID` per flavor in both entitlements and Info.plists, the small and medium views (light, dark, iOS 17 background, iOS 18 tinted), midnight timeline entries, and `NestyWidgetCore.swift` tested in RunnerTests. `flutter build ios --no-codesign` must pass for dev, stg and prod — plan §4 (2026-10-08: built by lane ios; RunnerTests `NestyWidgetCoreTests` 18 pass on the host, the three no-codesign builds pass, D312)
- [x] Android: `NestyWidgetProvider` with its info XML (2 × 2 to 4 × 2, previews), small and medium RemoteViews layouts (light, dark), the midnight alarm and its reschedule broadcasts, the immutable tap intent, and `WidgetTimeline.kt` JVM tests (Robolectric layout tests if cheap). The three APKs must build — plan §4 (2026-10-08: built by lane android; the JVM tests pass, the three APKs build, no Robolectric, D312)
- [x] `gen_widget_strings` (a new `nesty_tools` script with `--check` in CI): the gallery name, description and first-run line for iOS `.lproj` and Android `values-<lang>` from the ARBs. Also in README and CLAUDE.md Commands — plan §4 (2026-10-08: done, with `--check` in CI and `nesty-test`'s gates, D312)
- [x] The package question recorded: no `home_widget` (D299). The test-only Gradle dependencies (JUnit 4, Robolectric if used) each get a rule-9 row in PROGRESS — rule 9 (2026-10-08: JUnit 4.13.2's row is in PROGRESS "Package reasons", D312)
- [x] About 9 strings in nine catalogs with the Opus review — plan §4 (2026-10-08: none new: m7-6's copy held all 19 `widget…` keys with its Opus review, D305, D312)
- [ ] Device: `integration_test/home_widget_test.dart` (`ready`, `solved`, `paused`, `locked`: the shared store read back, the App Group resolved, the in-app link). `nesty-test --only widget` adds the cold OS link (`simctl openurl` by UDID, `adb am start`) with judged shots, the embedded `.appex` and `dumpsys appwidget`. TEST_COVERAGE gets a row saying why a simulator can't place a widget — D169
- [ ] The device run after stage 4: the full `nesty-test` on both devices, every new shot judged — the owner's brief

### Close

- [ ] `/review` with the security scanner and the ethics lens, and its fixes — the owner's brief
- [ ] PROGRESS (the decisions, the Status row, "Next step"), BACKLOG ticked, CLAUDE.md's Code map, Commands and Current state, `todo_index`, and `nesty-test --only gates` — the owner's brief
- [ ] M4: the kid-path analytics item covers `welcome_back_play`, `past_daily_complete` and `widget_open`. M6: no interstitial or rewarded offer after a past day's win, or on the welcome-back and widget paths — D92, plan §"Shared pieces"
- [ ] Today's visitor (optional, not in the Q162 default): the date picks one bundled skin, the same doll on every phone that day, drawn on the daily card and named in the share line. A greeting, not a collectible: missing the day does not lose a doll. No new core rule — local-habits "Wider concepts", D237
- [ ] A spoiler-free picture share (optional, not in the Q162 default): a small local image of how many families were nested, with no board, beside E3's text share. No server — local-habits "Wider concepts", D237
- [ ] Local player vs player (pass-and-play on one device), if the owner wants it offline: a proposal after vs Computer (the basis: alternating turns on one board, a family scoring for whoever completes it; brainstorm §6) — D90 (moved from M7, 2026-10-05: a local proposal waiting on the owner, not in M7's ✅ line; D237 orders local work after M7 (5c-classify))
  - 2026-09-29: the proposal is written, with no code: [plans/pass-and-play-proposal.md](plans/pass-and-play-proposal.md). It sets out three rule options for the owner to pick from (a shared board with alternating moves, the same board one player after the other, or co-op), how each fits the respect rules, what each reuses, a rough effort, and eight open questions. Next: the owner's answer

## Daily gift (login reward) — approved, after M7 and before the local habits (D268, Q182)

The owner asked for a daily and weekly login reward on 2026-10-05 and approved the plan the same day with Q182's defaults:
- it starts after M7 closes, ahead of the local habits;
- Home gets a button with a dot, and no popup;
- the track is 20 · 30 · 1 hint · 40 · 50 · 1 hint · 100 coins + 1 extra slot;
- the kid path gets the same gift.

The rule is the plan's §7.5b text until the owner pastes it into the spec. The plan is [plans/plan-login-gift.md](plans/plan-login-gift.md), the research [plans/login-gift-research.md](plans/login-gift-research.md), and the design request [plans/claude-design-login-gift-prompt.md](plans/claude-design-login-gift-prompt.md). D272 let it start with M7's sign-offs open; it was built on 2026-10-05 (D276–D280), and its final look waits on the design delivery below.

- [x] Claude Design's delivery for section 13 (the gift button on 2.1/2.1b, the sheet and its four tile states, the claim, Day 7's chest, a new track, reduce motion, the `gift` tokens, the glyph and the copy), imported into `design/` by the owner and synced with `sync_design_assets` — the design prompt, D268 (done 2026-10-07: `nesty-design-m7-5`, copied into `design/` by the lead at the owner's request, D281)
- [x] Once section 13 is in `design/`: swap the stand-ins for it. That covers `widgets/gift_look.dart` and the other `TODO(design)` markers (`docs/TODO_INDEX.md`), the glyph (Q186: `tools/fonts/nesty_symbols.txt`, then the icon subset rebuild), and the `gift` tokens through `gen_design_tokens`. The copy.md "## Daily gift" lines go into the ARB, then the eight translations again with the Opus review, the overflow suite in nine locales, and `nesty-test --only gift,playthrough` on both devices with the shots judged — D277, D278 (done 2026-10-07: `gift_look.dart` is deleted, the gift tokens, glyph and copy are in, D282–D286; the device run and the shots judged are in PROGRESS "m7-5, Device run (stage D)")
- [ ] The final look's sign-off and the owner's paste of §7.5b into the spec (Q186 is answered; Q187, Q188 hold defaults) — D285
- [x] `LoginGiftRules` in `lib/core/services/login_gift/`, pure, beside `MilestoneChest`. It covers:
  - the track, and the next day from the claim count;
  - one claim per local date (`AppClock`);
  - no claim on a date before the latest one seen;
  - the wrap after Day 7;
  - locked until the Daily unlocks.

  Tested by `login_gift_rules_test`: gaps of 1, 3 and 30 days keep the day; a clock wound back; a clock wound forward then back — plan-login-gift, D268 (done 2026-10-05: `login_gift_rules.dart` + `login_gift_reward.dart`; `test/core/services/login_gift/login_gift_rules_test.dart` passes, with the malformed-track fallbacks and a date seen but not claimed)
- [x] `RemoteConfigKey<String>` in the service, its fake, the defaults and `all`, then `login_gift_track` with a fallback to the default when malformed (rule 6) — plan-login-gift, D268 (done 2026-10-05: `RemoteConfigKeys.loginGiftTrack`, a JSON array of 7 `{coins, hints, slots}` days; `LoginGiftRules.parseTrack` falls back whole; `remote_config_keys_test` has the key and a string override; the TODO(M4) names `getString`)
- [x] Save schema 3 (`migrations-engineer`):
  - `LoginGiftProgress {claims, lastClaim, latestSeen}` in `SaveDocument`;
  - the 2→3 step in `save_migrations.dart`;
  - `SaveService.claimLoginGift(today)`, which writes the claim, the coins and the boosters in one update, in the Hive save and the fake.

  Tested by the migration test and the contract tests. — plan-login-gift, D268 (done 2026-10-05: `currentSchema` 3, step 2 → 3 stamps the schema, `noteLoginGiftDate` raises the clock guard; a real schema-2 fixture `fixtures/schema2_document.json`, the codec, Hive (`doc_backup_v2`) and `login_gift_claim_test` pass, 222 in the save, contracts, gift and Remote Config suites; the full game suite 4787 passed)
- [x] `LoginGiftCubit` (`BaseAsyncCubit`, a freezed state: the track, the next day, `canClaim`) in `features/login_gift/cubit/`, with `bloc_test` — plan-login-gift, D268 (done 2026-10-05: phases locked/ready/claimed/waiting and the coin pill's cap; `test/features/login_gift/cubit/login_gift_cubit_test.dart`, 15 tests with the app-resume path; D277)
- [x] The UI in `features/login_gift/widgets/` and Home:
  - `GiftButton` with its dot;
  - `GiftSheet` with seven `GiftDayTile`s;
  - the claim's `RewardFlight` to the coin pill, and Day 7 through `ChestRewardSequence`;
  - reduce motion and screen-reader labels;
  - `TODO(design)` stand-ins until the delivery.

  Widget tests: all seven gifts visible before claiming, and no countdown text. — plan-login-gift, D268 (done 2026-10-05 on `TODO(design)` stand-ins in `gift_look.dart`: `GiftButton`, `GiftSheet`, `GiftDayTile`, `GiftChestModal`, `ChestRewardSequence`'s `slots`; the button, sheet, tile, slot-chip and Home tests, the 48 dp header test; D277, D280)
- [x] Strings: about 8 keys in the nine catalogs. Then the Opus translation review (D240), the overflow suite in nine locales, and `gen_font_subsets` + `build_fonts.sh` if hi or ja need new glyphs — plan-login-gift, D268 (done 2026-10-05: 20 keys; the Opus review fixed 14; `test/l10n` and the overflow suite pass in nine locales; no new hi or ja glyph, so no font rebuild; D278)
- [x] `test/ethics/login_gift_respect_test.dart` checks that:
  - the gift paths use no ad, purchase or `Random`;
  - nothing lowers `claims`;
  - the copy has no loss or countdown words.

  On the `stars_gate_nothing_test` pattern. — plan-login-gift, D268 (done 2026-10-05: the code scan, the `claims` writers, a 600-step clock walk, the copy in nine locales and one tap call site; it caught pt "Em breve"; D279)
- [x] On a device (the D169 rule):
  - `integration_test/login_gift_test.dart` with the `ready`, `claimed`, `day7` and `clock_back` scenarios (`NESTY_FAKE_DATE` and a seeded save);
  - `nesty-test --only gift`, also in README and CLAUDE.md Commands;
  - the playthrough's Home shot;
  - its TEST_COVERAGE row;
  - a pass on the iOS simulator and the Android emulator.

  — plan-login-gift, D268 (done 2026-10-05: `login_gift_test.dart` with its four scenarios, `nesty-test --only gift` (also in the default run, README and CLAUDE.md Commands), the playthrough's `13b_home_gift_ready` and the TEST_COVERAGE row; passed on the iPhone 16e and the Android emulator, 14/14 iOS shots judged; D279)
- [x] `login_gift_claim {day, claims}` logged through `AnalyticsService` (the fake until M4; M4's `FirebaseAnalyticsService` item sends it) — plan-login-gift, D268 (done 2026-10-05: `LoginGiftCubit.claim`, tested with a mock; the kid path keeps it off for under-13s, BACKLOG M4)
- [x] CLAUDE.md's Code map: `features/login_gift`, `services/login_gift/` and the Remote Config string key. Current state when the work starts and ends — D268 (done 2026-10-05: the Code map's `login_gift` and `services/login_gift/`, the Remote Config row, Commands' `gift`, Current state)

## Engagement research and the kid path — after the local habits (D259, D260)

Not a milestone. The reasoning, the age matrix and every source are in
[plans/engagement-research.md](plans/engagement-research.md). Two kinds of
item live here:
- **The kid path** (decided, D260): under-13s are a target too, so Nesty is
  a mixed audience.
  - Its local part lands after M7 and the local habits, and before M4,
    because M4's analytics must not start before a player's age is known.
  - Its M4, M6 and M8 parts are in those sections.
  - Its details are Q174's defaults.
- **Proposals ER1–ER11** (D259):
  - Nothing is built until M7 is closed and the owner answers Q173.
  - A picked proposal becomes spec-prop text before any code.
  - Each also needs Claude Design's frames and copy, host tests, a
    `nesty-test` step and a TEST_COVERAGE row (D169).

### The kid path (decided, D260)

- [ ] A neutral age question: month and year with no default, asked after the first win so L1 stays instant (E9, E13), kept only on the device, never blocking a child. Under 13, or unanswered, means the kid path. Store age signals replace it where available (M6). Claude Design draws it (engagement-research §6.5) — engagement-research §6, D260, Q174
- [ ] A parent area behind a parental gate: the daily reminder and its time, sharing, links out (privacy policy, support) and, from M6, purchases. On the kid path a child is never offered the reminder, and Share and the Settings links ask for a grown-up first. Claude Design draws the gate and the area (§6.5) — engagement-research §6, D260, Q174

### Proposals (Q173)

- [ ] ER1 Free Play by difficulty: Easy, Medium or Hard endless boards at the player's stage, from a new seed range. Pays nothing, never moves `currentLevel`, and never counts toward the chest, the Museum or stars. Reuses the Bonus Endless path in `default_level_resolver.dart` and the generator's tiers. Needs spec-prop text (its unlock, seeds and what it counts) — engagement-research ER1, Q173, D259
- [ ] ER2 Milestones you can feel: tiered lifetime milestones (dolls, families, dailies, levels), each with a short ceremony, the next one shown in Records, and a share card. Pays nothing, and nothing counts consecutive days. Reuses `SaveRecords`, `BadgeRules` and the chest FX. Needs spec-prop §7.8 text and a save step — engagement-research ER2, Q173, D259
- [ ] ER3 Your month in dolls: a recap on a new month's first open, and a yearly one in January, with a play-style persona, shareable as a picture (it picks the local habits' picture share). Never compares players or shames a quiet month. Needs per-month counters (a save step) — engagement-research ER3, Q173, D259
- [ ] ER4 Challenge codes: after a win or the daily, share a short code (the board's id or seed, the generator version, the moves). The recipient plays the same board offline and compares privately. No accounts, server, free text or strangers, and it pays nothing. Needs spec-prop text (the code format, levels not reached yet, other generator versions) — engagement-research ER4, Q173, D259
- [ ] ER5 Healthy-play kit: today's levels and minutes on the pause sheet, this week's time in Records, and an optional break card at a level's end (off by default; on the kid path a grown-up sets it). Nothing locks — engagement-research ER5, Q173, D259
- [ ] ER6 Doll Workshop: mix the face, apron detail and shine from owned skins, plus stamps from the Sergiev Posad, Semyonov and Polkhov-Maidan schools. All 7 skins share one layer geometry and the same tinted masks, so game colours never change. The made doll plays as a skin. Needs Claude Design's check of which mixes work, a composite skin id in the cache key, and a save step — engagement-research ER6, Q173, D259
- [ ] ER7 Larger text: menus follow the system text size up to 2.0× (not 1.3×) and reflow. The harness and the overflow suite add 2.0×. Needs the owner's change to spec §16 and Claude Design's large-text variants — engagement-research ER7, Q173, D259
- [ ] ER8 Seasons that come back: the date dresses Home, the daily card and the backgrounds each season, every year. Nothing to buy, nothing expires, and no seasonal-only reward. If picked, it replaces Later's seasonal skins and weekend events (§19). Needs art per season. TC10 and themes-characters-story §6's region-aware calendar extend it (D270) — engagement-research ER8, Q173, D259
- [ ] ER9 Stories of the doll families: a short illustrated beat at each chapter's start and end (20 beats), re-readable in the Museum. Needs Claude Design's illustrations and copy. TC4a absorbs it if picked (D270) — engagement-research ER9, Q173, D259
- [ ] ER10 Family profiles: up to 4 local players on one phone, each with their own progress, streak, Museum and Records. Owned skins, purchases and settings stay device-wide. Needs new save boxes (the existing one becomes profile 1, never renamed) and migrations — engagement-research ER10, Q173, D259, D260
- [ ] ER11a Icon actions: long-press the app icon for "Today's puzzle" and "Continue level N", offline (`quick_actions`, with its rule-9 reason) — engagement-research ER11, Q173, D259

The research also supports these existing items, which stay where they are:
- pass-and-play, with option C first (M7);
- the widget and the picture share (Local habits);
- the level-sharing code (Later), with ER4 as its first step;
- the Museum diorama (Later);
- about 20 new levels a week (Later).

## Themes, characters and story — proposals, after the local habits and beside the engagement research's wave 2 (D270, Q184)

The owner asked on 2026-10-05 for themes, animations and characters "like Marvel, Power Rangers, Barbie" and a story mode. The analysis and research are in [plans/themes-characters-story.md](plans/themes-characters-story.md). Its second pass (same day) checked the first against the code and added TC11–TC14, TC-FX and TC-DATA.
- Licensed characters can't be used without a licence (Later, TC-L). These are original characters in those genres, all local (D269), all within the respect rules (D92) and the kid path (D260).
- A **character** (a persona) is earned and never sold. A **skin** (a look with no persona) may be sold for coins (themes-characters-story §2).
- None of this is a rule: Q184 picks what to build. Anything that changes a rule needs owner-approved spec-prop text first.

- [ ] TC7 Character animation layer: idle blinks, sway and yawn on the board's dolls, tap squish and the "home" bounce. Flame tweens with no game truth (rule 10) and no per-frame allocation (rule 8), off under reduce motion, paused when idle 30 s or backgrounded. Per-theme celebration variants need TC-FX. Needs a Claude Design motion spec — themes-characters-story TC7, §5, Q184
- [ ] TC8 The Computer with a personality: a wave at the start, "nice one" when the player completes a family first, a polite bow (not a celebration) when it wins. These are two segments beside `ui_rival_react`'s. Always "Computer". Resolves Q183 if the owner agrees — TC8, Q183, Q184
- [ ] TC1 The Nest Keeper mascot: greets on Home, voices the tutorial, cheers wins, comforts after out of moves (never "you failed"), sleeps after long play (a natural break). One segmented Lottie and a wordless babble voice. A character, so never sold and never in the Shop, ads, purchases or loss offers. Its name is the owner's (Q184) — TC1
- [ ] TC4a Story panels and the Storybook ("The Long Way Home", told as hide-and-seek): about 32 wordless panels.
  - The panels play at one-time events, so there is no save step:
    - The prologue plays after Level 2's first win. The trigger is a per-level first-win flag in `_win`, not `tutorialDone`.
    - Each homecoming plays in `_openChapterComplete`, keyed on `completedChapterId` (not `PlayEntry.completesChapter`).
    - The next chapter's arrival plays before its first level.
    - Midpoint pages are Storybook-only, because the chest owns level 10.
  - Never in races, the daily, Bonus Endless or replays. One tap skips.
  - A Storybook button goes in the figurine dialog. `story` keys join `checkedPrefixes`.
  - It absorbs ER9. Needs spec-prop lines (§7.2, §9.1, §10.1, §11.3, §15, §16) and Claude Design's panels — themes-characters-story §4, TC4, ER9
- [ ] TC4b The town map: the campaign as the story's journey, from an optional Story entry (a §10.2 line). After TC4a — themes-characters-story §4.3
- [ ] TC13 Little Ones: on the first win of each chapter's levels 3, 7, 13 and 17, a tiny named friend bobs out of the smallest doll. Those levels stay clear of the chest, the chapter's end and the rate prompt.
  - Each is shown beforehand by name and silhouette.
  - They live in a Museum drawer, with no counter, collect-all badge, notification, randomness or stars.
  - Collected means the level is won, so there is no save step.
  - One reveal Lottie with a new `FxImageSlot`.
  - It replaces Later's sticker album. Needs spec-prop §7.2 or §7.8 — TC13
- [ ] TC2 The Nest Squad: one hero look tinted per family colour, with five named lead colours.
  - A badge ring frames the colour symbol outside r 96 (the Large disc) and still reads in Subtle mode.
  - A 1.2 s "suit up" (TC-FX).
  - Earned at a named chapter's end (Q184). Never random, never sold.
  - Names and emblems get a legal check (Owner inputs) — TC2
- [ ] TC3 The Atelier: fashion and dress-up doll skins, a runway celebration after a chapter win (TC-FX), and Atelier stamps for ER6's Doll Workshop. No outfit scores or comparison. Original designs only — TC3, ER6
- [ ] TC11 Pop Stage: a band skin (every colour, never a trio) and a harmony celebration where each completed family sings a wordless note. Optionally a pitch per `DollColor` (needs §11.3 and §16 text). No lyrics, votes or fans — TC11
- [ ] TC5 Folk-tale chapters: Firebird Grove, the Kind Grandmother of the Woods (a friendly Baba Yaga helper), Snow Maiden's Winter. Each is a theme, a skin and 3 story beats, with pan-folk framing and a sensitivity review. The ten chapters are fixed today, so new lands come with levels 201+ in M4 (the default) or as Shop-only themes (Q184) — TC5
- [ ] TC9 Themed booster animations (look only): Undo, Hint and +1 Slot wear the equipped theme's motion. Costs, counts and effects unchanged. Needs TC-FX — TC9
- [ ] TC12 Moonlight Dolls: a spooky-cute skin with no persona (ghost-sheet capes, lantern lids, a soft boo-poof). Never scary. On sale for coins all year; only TC10's free looks return each Halloween — TC12
- [ ] TC6 World Dolls chapters, matched to the locales where possible: Channapatna, kokeshi and daruma, Otomí Lele, and Karagöz and wayang golek for ch07's beats, plus wycinanki, Dala and alebrije. Each with a sensitivity reviewer, a Museum credit and "inspired by" framing. The new-lands route is as TC5's — TC6
- [ ] TC10 Costume days that come back every year (with ER8), on the region-aware calendar (Hinamatsuri, Holi, Diwali, Children's Days and more), with a "Seasonal looks" toggle. No countdown, nothing to buy, nothing expires — TC10, §6
- [ ] TC14 Nest House: the Museum as a dollhouse with a room per family. Furniture arrives at fixed chapter points and is placed freely (a save step), never bought with stars. Its lift is unproven: after TC4a, and only with post-release data. Replaces Later's Museum diorama — TC14
- [ ] TC-FX FX variants keyed by theme or skin, with a base fallback, loaded lazily. Today each `FxId` has exactly one Lottie. `gen_fx_spec`, LOTTIE.md and `sync_design_assets` learn variants, with a host test. Comes with the first of TC2, TC3, TC9, TC11 or TC12 — themes-characters-story TC-FX, §2
- [ ] TC-DATA The catalog's new data:
  - `characters`, `storyBeats`, `littleOnes`, `fxVariants` and `calendar` on `CatalogRepository`, as bundled Dart constants in `BundledCatalogRepository` and the fake (there is no catalog JSON);
  - a pure `StoryRules`;
  - the Remote Config key `story_beats_enabled` (default true).

  Admin-editable in M5, Firestore-served in M4 — themes-characters-story §9, D269
- [ ] The Claude Design request for the picked items, paste-ready with a character bible and a babble voice — themes-characters-story §10

## Retention research, round 3 — proposals (D300, Q192–Q193)

The owner asked on 2026-10-08 for web research on features that bring players back. The analysis and sources are in
[plans/retention-research.md](plans/retention-research.md). Each idea was checked against ER1–ER12, TC1–TC14, the
local habits, E1–E14 and the code. Only new ones are here; the doc's §3 says where the rest stand.
- None of this is a rule: Q193 picks what to build, and its default spreads the items over the existing waves.
- Anything that touches a rule needs owner-approved spec-prop text first.
- Each item also needs Claude Design's frames and copy, host tests, a `nesty-test` step and a TEST_COVERAGE row (D169).
- All are local (D269) except RR6. All are within the respect rules (D92) and the kid path (D260).

- [ ] RR1 Solve coach: after a win, an optional "See a shorter way" button replays the solver's line from the level's start on the board, beside "Your moves: N" (WordleBot's idea).
  - On the daily, only once it is solved.
  - Never after a loss, never opened by itself, never a grade.
  - Reuses the solver isolate, `BoardTimeline`, E7's replay and D125's par. The game has no solution replay today.
  - Needs a spec-prop line (§7.1 or §10) — retention-research RR1, Q193
- [ ] RR2 Helping hand: on a level's third try (`GameplayBloc._attemptNumber`, which feeds only analytics today), one free hint is offered: no ad, no coins, at most once per level. Needs Q192's answer and spec-prop economy text — retention-research RR2, Q192, Q193
- [ ] RR2b Mechanic-wall check (tools): run the casual bots (§6.4) over each chapter's intro levels and flag where a new mechanic makes them restart much more. These are SayGames' "mechanic switch" walls, found offline before M4's analytics. No rule change; stays if RR2 is dropped — retention-research RR2
- [ ] RR3 A living Home: Home follows the phone's clock (morning, day, evening lamps, night with the dolls asleep; a tap wakes them). Nothing is gained, lost or waiting to be collected.
  - The widget (local habit 4) mirrors it, as Finch's does.
  - A lighting overlay plus TC7's idle layer, not 10 themes × 4 backgrounds.
  - Off under reduce motion. No rule — retention-research RR3, Q193
- [ ] RR4 Nest Maker: build a board from your unlocked mechanics.
  - The validator (rules 1–8) and the solver must prove it solvable before it can be played or shared.
  - Shared as an ER4 code, after ER4.
  - No free text (a name from a word list), sharing behind the parental gate, no likes or rankings.
  - Shares editor work with M5's level editor. Needs spec-prop text — retention-research RR4, ER4, Q193
- [ ] RR5 Satisfying replay clip: a 6–10 s sped-up replay of a campaign solve, with sound, saved or shared as a video (GIF as a fallback). Never the daily.
  - Needs an encoder: platform code behind a channel, or a package with its rule-9 reason.
  - Behind the parental gate on the kid path.
  - Needs a §10 line — retention-research RR5, Q193
- [ ] RR6 Store re-engagement surfaces, with M8 (the owner's store accounts):
  - App Store In-App Events for chapter drops (M4) and returning seasons (ER8), with no countdown copy;
  - Google Play promotional content, and the Engage SDK or the "You" tab's continuation card ("Continue level N"), once its eligibility for games and the kid path's Families policy are checked — retention-research RR6, Q193
- [ ] RR7 Next-up peek: when the next level introduces a mechanic or closes a chapter, the win card adds one line and a silhouette ("Next: something icy…"). Today it shows only the chest distance. No rule — retention-research RR7, Q193

## M4 — Firebase content — after Local habits (D90, D237)

Not started. Starts only after M7 is closed and the Local habits the
owner picks (Q162) are done. The engagement proposals the owner picks
(Q173) come first too, and the kid path's local part (the age question and
the parent area, D260) must, because analytics waits for the age answer.
Firebase, the admin, purchases and the other backend work stay at the end
(D237).

Acceptance (§18): with airplane mode on first launch, the game is fully
playable. Levels published in the admin appear on the next app resume.

- [ ] Firebase init at the `TODO(M4)` in both bootstraps, failing silently offline. The owner runs `flutterfire configure` first (Q12) — §14, CLAUDE.md rule 3, `apps/game/lib/bootstrap.dart`
- [ ] Crashlytics: uncaught errors, plus non-fatals for `runGuarded` failures, the Hive fallback and level-validation failures — §14.4, D17
- [ ] `FirebaseRemoteConfigService` over the hard-coded defaults, with prices and rewards read from it — §9.4, CLAUDE.md rule 6
- [ ] Before Remote Config can serve a `daily_archive_days` other than 7: the month's hint (`dailyMonthHint`, `dailyMonthHintShort`) says "7 days", so it needs a `{days}` plural in the nine catalogs with the Opus review, or the hint hides off 7 (`TODO(M4)` in `month_card.dart`). A past day's board must also take its date's `dailyOverrides` entry, as that day's daily did — plan-local-habits §7.5c, stage 3 review
- [ ] `FirebaseAnalyticsService`, with every §14.4 event sent from the feature it belongs to — §14.4. The daily gift's `login_gift_claim` too (D268)
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
- [ ] Analytics and crash data by age (the kid path, D260): nothing is collected before the age answer, and ad-ID collection is off for everyone. For players under 13 and of unknown age, analytics stays off until the owner's legal check (every event, the daily gift's `login_gift_claim` included), and crash reports run only for the app's own operation. Play Families allows no AAID or other device identifier from them — engagement-research §6.2–§6.3, D260, Q174

## M5 — Admin panel — after Local habits (D90, D237)

Not started. Starts only after M4. The admin is backend, so it stays
at the end with Firebase (D237).

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

## M6 — Monetization — after Local habits (D90, D237)

Not started. Starts only after M5. Ads and purchases stay at the end
(D237).

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
- [ ] The interstitial counter skips a past daily: a past day's win leaves `adCounters` as it is today (D311), so `winsSinceInterstitial` must not count it when M6 starts counting, and no interstitial follows it — plan-local-habits §7.5c, D311
- [ ] `AdsService` calls `MusicService.pauseForAd()` before every interstitial or rewarded show and `resumeAfterAd()` in a `finally` when it closes; with the app's own trip to the background during an Android ad, the pause reasons don't double up — `TODO(M6)` in `music_service.dart`, audio A5
- [ ] A completed purchase calls `JingleCues.reward()` — `TODO(M6)` in `jingle_cues.dart`, Q62
- [ ] The respect rules hold for every ad and purchase surface (spec-prop §1.1):
  - no offer shown because the player failed or got stuck, and no countdown or limited-time offer;
  - the real-money price shown before the purchase flow, and no forcing an oversized coin pack (EU CPC key principles, March 2025);
  - a test per placement.
  - D92, brainstorm §5
- [ ] Ads for players of unknown age: non-personalized by default, and whether to read Apple's Declared Age Range API (Q86). The game may be "likely to be accessed by children" whatever its rating — D92, brainstorm §1
  - 2026-10-04 (D260): under-13s are now a target, so Play Families decides this. A player of unknown age gets the kid path's ads (the next item) until the age question is answered or a store signal arrives. Q174 holds the rest
- [ ] Ads by age (the kid path, D260):
  - Requests for players under 13 and of unknown age are child-directed with max ad content rating G (GMA SDK Android ≥ 20.6.0, iOS ≥ 7.67.0, so no ad ID is sent), from Families self-certified sources only, and never personalized.
  - §9.1's pacing stays, so there is no ad at launch. Every ad is closeable within 5 s. No rewarded placements on the kid path.
  - EU players under their country's consent age get the under-age-of-consent tag.
  - Expect lower fill.
  - engagement-research §6, D260, Q174, Q86
- [ ] Purchases by age (the kid path, D260): the paid Shop tabs (7.1, 7.8), the starter pack and the Remove Ads offer (7.9) sit behind the parental gate, and a child is shown no purchase offer. Coins are always shown apart from real money — engagement-research §6, D260, Q174
- [ ] Store age signals: read Apple's Declared Age Range (iOS 26+) and Google Play's Age Signals where available (`age_range_signals`, with its rule-9 reason), only to protect and never to market. The age question stays the fallback — engagement-research §6.2, D260, Texas SB 2420

## M8 — Release prep — after M6 (D237)

It stays last. Acceptance (§18) is a release build on real Android and iOS
devices with production Firebase, which lands in M4.

- [ ] Android Auto Backup: `allowBackup` is the default (true), so the Hive save and the widget's `nesty_widget` prefs go to the player's Google backup and come back on a new phone (the only way an offline, account-free player keeps progress). Decide with the privacy policy and the kid path (D260) whether to keep it, exclude something with `dataExtractionRules`, or turn it off — close review (security P2), D314
- [ ] ER11b Game Center and Play Games, with M4/M8 (network and accounts): achievements that mirror the badges and ER2, and a friends-only daily-moves leaderboard for iOS 26 Challenges and Activities. Sign-in is optional, Google Play's pre-loss Streaks notifications are never used, and it is off on the kid path. Check `games_services`'s maintenance first — engagement-research ER11, Q173, D259 (moved from "Engagement research and the kid path" on 2026-10-05: it needs accounts and the network, and the owner keeps every backend task last, D269)
- [ ] App icons: flatten the 1024 App Store icon (App Store Connect rejects alpha), and add an Android adaptive icon and a 512 px Play icon. `sync_design_assets` doesn't copy `design/store/` (its SVG uses unsupported features), so the launcher icons are generated separately — §18 M8, audit, `design/store/icon_1024.png`
- [ ] Native splash (the Android 12 splash API and the iOS LaunchScreen) matching frame 1.1 — §18 M8
- [ ] Store screenshot support: a clean capture mode — §18 M8
- [ ] App size under 60 MB (`--analyze-size`), keeping an eye on the bundled art — §18 M8, D20. On 2026-09-28 the prod fat APK (every ABI) was 73.3 MB: measure the per-ABI app bundle
- [ ] Performance profiling on a 2 GB Android — CLAUDE.md rule 8, `/perf-profile`. Include the level-load raster time of doll layers (design budget ≤ 250 ms; host flutter_tester measured 35–67 ms for 4 heights at DPR 3), board sprites and the theme background (r2/r3 reports)
- [ ] Release configs with the ad IDs from `--dart-define`, never committed — CLAUDE.md rule 5
- [ ] Android release signing with the upload key (`key.properties` kept out of git) — `apps/game/android/app/build.gradle.kts`
- [ ] iOS profile and release builds, `flutter build ipa` and Xcode Archive. Run `flutter build ipa --flavor <f> -t lib/main_<f>.dart` first, or the D8 guard fails the build — D8, PROGRESS M0 "Not verified yet"
- [ ] Privacy policy URL in both store listings, and a final check of the Settings link — §9.3, §17
- [ ] Store listing copy and screenshots in a family tone for every age. Play Console declares the under-13 age bands Q174 picks (default 9–12) plus 13+, under the Families policy. On the App Store, Nesty stays out of the Kids Category, so no name, subtitle, icon, screenshot or description implies children are the main audience (guidelines 2.3.8, 5.1.4). The IARC, PEGI, Data Safety and App Privacy answers match D260 and the kid path: local notifications only, opt-in, and nothing tracks a child — §1, §17, D92, D260 (changed 2026-10-04: D260 replaced "13+ declared" and "no kid-coded language")
- [ ] Age-assurance laws: Texas SB 2420 is in force, and Apple applies it from 4 Jun 2026. Assign the age rating, and notify the stores before any later "significant change" (new ads, purchases or data categories), which re-asks Texas parents. M6's ads and purchases ship in the first public release (D237's order). Recheck Utah (6 May 2027), Louisiana (1 Jul 2027) and California AB 1043 (1 Jan 2027) before release — engagement-research §6.2, D260
- [ ] IARC and PEGI answers under PEGI's June 2026 interactive-risk criteria. The daily, the streak, the chests and the daily gift (D268) are a reward for returning (at least PEGI 7). Keep no penalty for not returning and no time-limited offer (each at least 12), and no paid randomness (16) — engagement-research §5, §6.2, D92, D260
- [ ] The share card gains the store link once the listings exist — D92 E3
- [ ] Tabular figures for coins and counters (Q29: Fredoka has no `tnum`; pick a fixed-width digit layout, Nunito digits, or a patched Fredoka; `NestyNumberText` is the one place) — moved from M7 (2026-10-01, D225): Q29 is unanswered; the markers are `TODO(M8)` in `app_text_styles.dart` and `nesty_number_text.dart`; design/README.md "Typography & icons", tokens.json `fontSize.number.tabular`, tools/fonts audit
- [ ] Acceptance on real devices with production Firebase (owner) — §18 M8
- [ ] A native reader of each language before the store release (Q180, default none) — 5B; M8 (owner) (moved from M7, 2026-10-05: Q180, a store-release step (5c-classify))
- [ ] Before release, a levels-tool report of the smart and casual bots' star shares per chapter at the default slack, so the owner can tune the two keys — star-rating.md (moved from M7, 2026-10-05: "before release"; the report is built (`report --stars`), only the owner's reading and tuning are left (5c-classify))
  - 2026-09-29: `nesty_levels report --stars` is stars-core's (m7 P3.3); left after it: the owner reads it
  - 2026-09-29: built (D157); at 20/60 over all levels, the casual bot's wins are 24.0 / 47.9 / 27.9 % at 3★/2★/1★ and the smart bot's 98.6 / 1.3 / 0.0 %; the per-chapter table is in `tools/levels/README.md` "Par and the star shares". Left: the owner reads it and tunes the keys
- [ ] Re-check `UIRequiresFullScreen` (deprecated in iPadOS 26) together with the iPad orientation decision — Q16 (moved from M7, 2026-10-05: Q16, a release platform setting (5c-classify))

## v1.1

- [ ] Golden doll rules — §3.5, D22:
  - `colorsMatch`: a nest takes the color of its non-gold dolls, and an all-gold nest matches any color.
  - At most one gold doll per level, and it counts toward its set.
  - Validator rule-4 exemption.
  - Lift the v1 rejection.
- [ ] Gold in the solver, the simulator and the generator, the L101 intro, intro card 4.8 with its "v1.1" chip, and the admin palette — §3.5, §3.7, frame 4.8
- [ ] A `Nest` model and view for a nest that holds the golden doll among other dolls; `NestCode.toNest` drops the gold today (`TODO(v1.1)` in `packages/nesty_core/lib/src/rules/engine/nest_code.dart`); accept gold in the validator (`TODO(v1.1)` in `lib/src/validator/level_checks.dart`) and decide how gold counts toward rule 4 — §3.5, D22, kernel and codec reports
- [ ] Gold levels in `test/simulator/support/sim_levels.dart`, gold in `simref.py`, and new parity values (a `Generator.version` bump) — §3.5, simulator report
- [ ] Screen-reader play on the board (Q154): a semantics layer over the Flame board, one node per slot from `BoardGeometry`, with Claude Design's strings; the marker is `TODO(v1.1)` at `gameplay_board.dart:147` — M7 review R12, Q154 default, 5f-fd (the marker was already `TODO(v1.1)`, D258; listed here by 5f-fe, 2026-10-04)
- [ ] Rasterize the gold mask layers only for levels (or previews) that show gold: a gold flag through `DollRenderer.prepare` and the `SkinCache` key. Today every prepared height rasterizes them (23 % of layer bytes) — review RENDER-7
- [ ] The Not-enough-coins dialog's top anchor (the figurine modal hangs from the top at safe top + 69; the dialog stays centred) and `text-wrap: pretty` on the Museum modal's flavor and locked text (they would break about six exact-string tests) — 5f-fix2; M7 (low value) (moved from M7, 2026-10-05: polish, about 35 dp on one dialog; `text-wrap: pretty` would also change six exact-string tests (5c-classify))
- [ ] Screen-reader play on the board: a semantics layer over the Flame board (one node per slot from BoardGeometry, labelled from core's GameState, its tap through the board's input policy), the tutorial card as a live region, and Claude Design copy for the colour names and slot states. `TODO(v1.1)` at `gameplay_board.dart`, the question's default — M7 review R12 (owner decision, Q154) (moved from M7, 2026-10-05: Q154's default and D258; the marker is `TODO(v1.1)` already (5c-classify))
- [ ] With Android's "Remove animations" on, the in-app Reduce motion "Off" can't restore full motion: AnimationControllers run at 5 % under SemanticsBinding.disableAnimations; use AnimationBehavior.preserve on the app's own controllers. `TODO(v1.1)` in `reduce_motion_override.dart` — M7 review R7 note (D167) (moved from M7, 2026-10-05: already `TODO(v1.1)` at reduce_motion_override.dart (5c-classify))
- [ ] Japanese lines that end with one character alone (族 on a Museum plaque, Records and Museum lines): `bindLastWord` joins the last word only where words are spaced; give CJK a word joiner (U+2060) before the last character, with tests in ja — the gate's locale review (`build/m7-p5/reports/5c-loc-ios2.md`, `5c-loc-and2.md`), 2026-10-05

## Later (spec §19)

- [ ] Weekend events with special skins — §19
- [ ] Cloud save through anonymous Auth — §19, §13.2
- [ ] Server-side receipt verification (Cloud Functions) — §19, §9.2
- [ ] Ad mediation (AppLovin MAX or ironSource) — §19, §9.1
- [x] Relaxed mode with unlimited undo — §19 (moved to M7 "Engagement" as E6: the owner approved it for v1, D92)
- [x] Home-screen widget for the daily and the streak — brainstorm §6, D92 (moved 2026-10-02 to "Local habits", D237)
- [ ] A weekly puzzle, par and stars, no-undo challenges and time attack: revisit after M7 with the best-moves data (stars make a win feel like a failure, and speed pressure is off-brand) — brainstorm §6, D92
- [ ] A Museum diorama or a sticker album (large art cost), a Daily Duel against the computer, and a ghost race against your own best — brainstorm §6, D92, D93 (welcome-back moved 2026-10-02 to "Local habits", D237; if picked, TC14 Nest House replaces the diorama and TC13 Little Ones the album, D270)
- [ ] Doll micro-expressions (new face layers in all 7 skins), a dyslexia-friendly font option, and a favourite family on Home (ask Claude Design where it sits) — brainstorm §6, D92
- [ ] Online player vs player (matchmaking, a shared board or a race over the network): after the Firebase milestones — D90
- [ ] TC-L A licensed collaboration (Marvel-, Power Rangers- or Barbie-class characters): only after M8, with a publisher. It brings the licensor's minimum guarantee and royalty (typically 15–20%), approvals on every asset, and a kid-path and respect-rule review. Not planned work — themes-characters-story §0, TC-L, D270
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
- [ ] Optional: keep Nesty's music off while another app plays audio (iOS `secondaryAudioShouldBeSilencedHint`) — Q61, audio plan (moved from M7, 2026-10-05: optional (Q61), not in M7's ✅ line (5c-classify))
- [ ] A silent load-time catch-up that writes `museum`/`museumCollected` for a chapter whose levels are all won (like the badges' grant on load), so the stored Museum agrees with the one the screens derive (D118) — menus lane report (moved from M7, 2026-10-05: the screens derive the Museum from won levels (D118), so nothing visible disagrees; a save-schema step not worth M7 (5c-classify))

## Owner inputs needed

Content, assets, accounts and decisions only the owner can supply. Each item
names the milestone it blocks.

### Content and assets

- [x] (done 2026-10-07: delivered and imported, D281) **Wednesday 2026-10-07, when Claude Design is back: send [plans/claude-design-request-m7-5.md](plans/claude-design-request-m7-5.md)** (paste-ready, one message, delivered as `nesty-design-m7-5`). Part 1 is the daily gift's section 13. Part 2 is every M7 design question still open, gathered from "Follow-up after m7-3" in [plans/claude-design-request-m7.md](plans/claude-design-request-m7.md) and from BACKLOG M7's `design` items. Highlights:
  - §11: phase 5's ten questions (the undo's motion, Q160; the chest flights' values; the colours tokens.json lacks);
  - §12: the m7-4 device run's asks: the versus ribbon band (12.1: 336 dp where 9.4 and 9.5 draw about 290), the chest's rays, the badge toast's second line, 9.7b's Computer tag, the splash's arch;
  - §13: a Fredoka build with the Turkish letters;
  - §14: the race strip's two new forms (D271).

  The themes request (themes-characters-story §7) goes in a later round, after wave 1 (D275). Then import the delivery through the checks in BACKLOG M7 "Importing a Claude Design delivery" — owner, 2026-10-05

- [x] Send [plans/claude-design-login-gift-prompt.md](plans/claude-design-login-gift-prompt.md) (now Part 1 of `claude-design-request-m7-5.md`, the Wednesday item above) to Claude Design, then drop the delivery into `design/`. It blocks the daily gift's final look, not its start (`TODO(design)` stand-ins) — D268 (done 2026-10-07: sent as Part 1 of m7-5, delivered and imported, D281)
- [ ] **Send [plans/claude-design-request-m7-6.md](plans/claude-design-request-m7-6.md) in Claude Design's next round** (paste-ready, one message, delivered as `nesty-design-m7-6`). Part 1 is the local habits' section 14 (D274). Part 2 is the 21 design questions m7-5 left open: the ten m7-5 follow-ups in BACKLOG "M7" and eleven frames or tokens no delivery has covered. It blocks the habits' final look, not their start (`TODO(design)` stand-ins) — owner, 2026-10-08
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
- [x] design: phase 5's ten questions to Claude Design, "Follow-up after m7-3" §11 (the undo's motion, the wobble settle before a move, the relit card's twinkle sizes, the Museum's Play at 36, Chapters' "levels to go" inline, the spotlight's 300, `layout.chapters.scroll.foldedAbove`, four frame-only colours, a type token per surface, the all-home card's badge art); each ships its default — phase 5A, lanes B, O, M, RD (done 2026-10-07: m7-5 Part 2 items 1, 2, 14, 18 and 21 and Choices 12, 13, 15, 19 and 20, wired in D287, D289 and D296; `type.museum.count` 20 against the frames' 16 is asked again as an m7-5 follow-up)
- [x] design: the undo's motion (`TODO(design): Q160` in `timeline_plans.dart`) and the chest flights' values (`TODO(design)` FU 1.7 in `reward_ring.dart`, `reward_flight.dart`) — lanes B and O, D217, D221 (done 2026-10-07: the undo keeps its motion, Choice 13, D287; the flights take m7-5's `motion.chest.collect.pillRing` and `trail`, Part 2 item 3, D286)

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
- [ ] A legal check of the kid path: COPPA's amended rule for a mixed audience, the Play Families declaration, a UK Children's Code DPIA, GDPR Art. 8 consent ages and Texas SB 2420 — §17, D260 (M4: its analytics default waits on it; M8)

- [ ] The home-screen widget's App Groups in the Apple Developer account: register `group.com.futrix.nesty`, `group.com.futrix.nesty.dev` and `group.com.futrix.nesty.stg`, and turn on App Groups for the three app ids and the three widget ids (`<app id>.widget`). The exact steps: [plans/widget-apple-setup.md](plans/widget-apple-setup.md). Simulators need none of it; a signed build for a real iPhone or an upload does. Waiting: the owner has no Apple Developer account yet (D313) — plan-local-habits §4, D312 (Local habits, stage 4)

### Device checks (the owner's phone)

- [ ] The home-screen widget on a real iPhone and Android phone: add it in both sizes; see it ready, then solved after the daily; see it ready again past midnight with the app closed; tap it to reach the Daily — plan-local-habits §4 (Local habits, stage 4)

- [ ] The VoiceOver pass on a physical iPhone, with [plans/voiceover-checklist.md](plans/voiceover-checklist.md) (turn it on, the screens in the semantics tour's order with what each must say, what to report, the known limit Q154) — M7 review R12, phase 5 (owner)

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
- [x] Q158: a reminder the OS blocked has no off switch in the app (Settings draws the toggle off and opens the phone's settings, frame 10.2f), so it starts as asked if notifications are allowed later. Add a "Turn off" link on the blocked row? Default: no extra control (M7, D190, D207) (done 2026-10-04: answered "Build it" on 2026-10-01; D235, D244)
- [x] Q159: Records' families cell shows the rule's plain count, "Families completed" (every family a won board completed), not frame 10.6's "N of 10 Families home", which is the Museum's count. Keep it, or show the Museum's count? Default: the plain count (M7, D209) (done 2026-10-04: answered by the design, DELIVERY 8.5: "Families completed" with the doll mark)
- [x] Q160: the undo's motion. No frame draws one. Default: the moved doll flies back along its own path, `doll_move` reversed (260 ms, `whoosh`, 130 ms under reduce motion), with `TODO(design): Q160`. Or keep the cut until Claude Design draws one? (M7, D221, D227) (answered 2026-10-07: keep, m7-5 DELIVERY Choice 13; D287)
- [ ] Q161: close M7 with the owner-only items open? The "matches the design screens" acceptance needs your sign-off and several checks need a phone (VoiceOver, a real reminder, the haptic feel, the final mix, the ten flagged levels). Default: M7 is "code complete, acceptance waits on the owner", as M2 and M3 are (D90); M4 doesn't start until you say so (M7, phase 5)
- [x] Q162: which local habits to build after M7, if any? Welcome back, a month of played days, the last 7 dailies playable, and a home-screen widget. Default: the first three in that order, and the widget only after them. None starts until M7 is closed. Firebase, the admin and purchases stay after that (D237) — local-habits, D237 (answered 2026-10-05: all four, in that order, the widget last; D274)
- [ ] Q168: the freeze chip reads "0 left" in frames 5.2 and 7 of DELIVERY, and "left" is on the respect deny-list. Default: "No freeze" and "{count} streak freeze(s)" (M7, D242, D247; D110, Q95)
- [ ] Q169: the deepest tower silhouette sits 10.42 dp under the HUD where tokens' worked example says 10.8. Default: keep 10.42 (M7, D243)
- [ ] Q170: on four shelves the ice reaches about 13 dp into the plank above (the design's own numbers); the check is skipped for that preset and no level uses four shelves. Default: accept (M7, D243)
- [ ] Q171: the badge toast sits over the win ribbon on screens under about 800 dp (TalkBack T2). Default: no change (M7, D250)
- [ ] Q172: a picked rival card reads "Selected" and is also a checked radio, so TalkBack may say both. Default: as copy.md says (M7, D250)
- [ ] Q173: which engagement proposals to build after the local habits, and in what order? Default: wave 1 first (ER1 Free Play, ER2 milestones, ER3 the monthly recap, ER4 challenge codes, ER5 the healthy-play kit), then the wave 2 items you pick (ER6–ER9), with ER10 and ER11 later. None starts until M7 is closed (after M7, D259) — engagement-research
- [ ] Q174: the kid path's details. Defaults: Play bands 9–12 plus 13+; the age question after the first win, with store signals where available; kid-path ads child-directed, G and certified, with no rewarded placements; purchases behind the parental gate; the reminder and sharing turned on by a grown-up; analytics off for under-13 and unknown age until the legal check; not in Apple's Kids Category. Or no ads on the kid path, or younger bands? (the local phase, M4, M6, M8; D260) — engagement-research §6
- [ ] Q175: Spanish neutral Latin American and every `pt_*` phone to Brazilian Portuguese? Default: yes (M7, D261)
- [ ] Q176: a "Phone's language" row in the language sheet? Default: no, a fresh install follows the phone and a tap pins (M7, D261)
- [ ] Q177: rival names as translated meanings (Guijarro, Kiesel, コイシ…) or Pebble, Button, Comet everywhere? Default: translated (M7, D265)
- [ ] Q178: the registers, French "tu" in particular? Default: tu, as built (M7, D265)
- [ ] Q179: Hindi: everyday Hindi with the English game words (default), or formal Hindi? (M7, D265)
- [ ] Q180: a native reader of each language before the store release? Default: no; two Opus review passes are the check (M8, D240)
- [ ] Q181: the HUD level pill sits a few dp off-centre at 360 dp with a five-digit balance and a long tier instead of scaling under the 0.75 floor. Default: as built (M7, D263)
- [x] Q182: the daily gift (D268): (a) when, (b) button or daily sheet, (c) the track, (d) the kid path (answered 2026-10-05: the owner approved the plan with the defaults: after M7 and before the local habits; a Home button with a dot and no popup; 20 · 30 · hint · 40 · 50 · hint · 100 + slot; the same gift for everyone)
- [ ] Paste the daily gift's rule into GAME_SPEC.md (plan-login-gift §7.5b, a §7.3 row and the §9.4 key `login_gift_track`), or keep it as the approved text, as Q85 does for M7 (D268)
- [x] Q30–Q38: the M1 and render decisions to confirm (towerless grading, expert-only generated levels, solver targets, admin memory, the curve table, the recorded defaults, bundle policy, authored levels, render defaults) (done 2026-09-26: the owner confirmed the recorded defaults, D52)
- [ ] Update GAME_SPEC.md for this round's deviations, or keep them recorded only in PROGRESS? They are §2.2 tap policy (D22), §3.6 extra-slot placement (D22), §13.5 bundled art (D20), the §12.3/§13.3 symbols value (Q4), and the §12.3/§13.3 default symbols mode, now `large` (D91) — D19–D22, D91
- [x] Q183: the 9.5 race-loss card plays the Computer's `win` hop with confetti over the player's loss (the ethics lens's P1). Ship the design as delivered (default), or switch to TC8's polite bow? (M7 phase 5; themes-characters-story §11) (answered 2026-10-05: keep as designed, D273)
- [x] Q184: which themes, characters and story proposals (TC1–TC14) to build and in what order; TC-FX and TC-DATA come with the items that need them. Also: the mascot's name, and the squad's names and chapter, after a legal check; the route for new lands in TC5 and TC6 (default: with M4's weekly levels); whether the story keeps the tokens' figurine pairing (default: yes, as its plot); and whether passed beats replay in the flow (default: no, the Storybook only). Default order: wave 1 (TC7, TC8, TC1), then TC4a, then TC13 (themes-characters-story §11, D270) (answered 2026-10-05: wave 1 first, TC7, TC8, TC1, then the story mode; the names wait for the legal check; D275)
- [x] Q185: may the daily gift start before M7's owner sign-offs (the design sign-off Q161, the VoiceOver pass, Claude Design's follow-up)? Default: it starts when the owner says so, without waiting for them, as D90 did for M2 and M3 — PROGRESS Q185 (answered 2026-10-05: start it next, D272)
- [ ] Q186: the daily gift button's glyph. The stand-in reuses the chest's `redeem` (no gift glyph is in the icon subset). Default: Claude Design's section 13 names it, then `tools/fonts/nesty_symbols.txt` and the subset rebuild — PROGRESS Q186, D277
- [ ] Q187: `.claude/rules/hive.md` still says the save carries `"schema": 1` (now 3, D276); a rules file, so yours to change. Default: leave it; suggested text "the current `SaveDocument.currentSchema`" — PROGRESS Q187
- [ ] Q188: a date seen far ahead (a clock once set into the future, the app opened then) holds the gift at "Next gift: …" until that date, per §7.5b's "the latest date ever seen". Or count only claimed dates? Default: as built, until M4's server time — PROGRESS Q188, D276
- [x] Q189: approve §7.5c (the past dailies) and its defaults: a past day pays nothing; it isn't counted in Records' dailies; it is counted in wins, moves, families and dolls as a replay is; the month marks it "played later"; replays are allowed and pay nothing; no Share; one past-day board in progress at a time; a window that doesn't depend on the install date; only owned boosters on a past day's board, with no coin or ad buy (D301). Approved 2026-10-08 with Q190 and Q191's defaults, D310 — PROGRESS Q189, plan-local-habits
- [ ] Q190: on the 1st–7th of a month the last 7 dates reach into the previous month. Default: the month card pages back exactly one month, and `maxDates` goes from 31 to 62. Or: the grid's first row reaches back to the window's first date. Or: only the current month's part of the window is offered — PROGRESS Q190, plan-local-habits
- [ ] Q191: a day a freeze covered, in the month. Default: a quiet frost mark (`acUnit`), neither lit nor blank. Or: blank like any day not played — PROGRESS Q191, plan-local-habits
- [ ] Q192: is RR2's free hint on a level's third try within the never list ("no offers shown because a player failed")? Default: yes, since nothing is sold or shown for money — PROGRESS Q192, retention-research
- [ ] Q193: which retention proposals RR1–RR7 to build, and where. Default: RR3 and RR7 with the local habits (after the widget), RR1 and RR2 in engagement wave 1, RR4 (after ER4) and RR5 in wave 2, RR6 with M8 — PROGRESS Q193, retention-research
- [ ] A lawyer's clearance for any hero-squad or fashion-doll names, emblems and designs, including Claude Design's generated art, before they ship (TC2, TC3; themes-characters-story §0) — M8 at the latest

## Tech debt

- [ ] Retire the unused ARB key `chestContentsSlotSemantics` (and its description) from the nine catalogs; the chest reads `giftA11yChestContents` since m7-5. `IconUses.rewardSlot` is also unread — D283, D285
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
- [ ] `block-generated` hook could also guard `tools/fonts/subset/*.txt` (generated by `gen_font_subsets`); optional — 5b-fonts; M7 (moved from M7, 2026-10-05: optional tooling, not M7 scope (5c-classify))

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
