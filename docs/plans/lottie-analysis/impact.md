# Lottie analysis — impact (2026-09-26)

Read-only analysis of design/lottie/ against lottie 3.6.1 (probes run in a scratch project). Reference material for the M2 Lottie work; decisions live in docs/PROGRESS.md and docs/plans/m2-lottie-design.md.

The export is mostly usable, but LOTTIE.md can't be followed as written on the pinned `lottie` 3.6.1. Four things break it:

- **Image resolution:** the player draws every image slot at the image's own pixel size.
- **Screen size:** it clips each animation to its canvas, which breaks on screens that aren't 390 dp wide.
- **Lid/body split:** the lid and body images are cut hard at y 400, which differs from our renderer and its goldens.
- **Text cost:** text layers are expensive to draw.

All of these can be solved without editing the JSON. Some need owner sign-off. I changed nothing in the repo. The experiments are in `/private/tmp/claude-501/-Users-utsav-Downloads-nesty/8a802507-1fb1-4775-b441-329bc52e16e7/scratchpad/lt/test/{image_size_test,cost_test,parse_test}.dart` and `.../scratchpad/ws`.

## A. Verified facts

- **E1. Images draw at pixel size.** `lottie-3.6.1/lib/src/model/layer/image_layer.dart` draws with `dst = Rect.fromLTWH(0, 0, bitmap.width, bitmap.height)` and ignores the asset's declared w/h. Test on `doll_pick` frame 0:

  | Raster | Drawn bounds | Result |
  |---|---|---|
  | 512×768 | (40,92)–(120,230), height 138 | correct |
  | 256×384 (the placeholder PNG size) | (35,89)–(75,158), height 69 | half size, shifted |
  | 300×450 plus two delegates: `transformAnchorPoint` (256r, 742r) and `transformScale` 0.1953/r on `doll_lid` and `doll_body` | same as 512×768 | compensation works |

  - The `doll_size` delegate at 0.42 gives height 58, as expected.
  - `LottieComposition.fromBytes` decodes no images. With no delegate image, nothing is drawn. `Lottie.asset` would load the placeholder PNGs instead.
- **E2. The placeholder PNGs only look right in the viewer.**
  - Their sizes don't match the declared assets: doll 256×384 (declared 512×768), glass and ice 360×600 (declared 86×143 and 96×160), glow 360×160 (116×52), extra slot 320×120 (90×34), hint 160×200 (40×50), unlock symbol 24×24 (12×12).
  - They look right only in `Lottie FX.dc.html`, which uses lottie-web 5.12.2 and sizes images by the declared w/h.
  - They take 1.79 MB on disk and 8.2 MiB once decoded.
- **E3. Lid and body are cut hard at splitY = 400.**
  - `doll_body.png` first opaque row is px 200 (art y 400). `doll_lid.png` last opaque row is px 199.
  - `classic.svg` differs: `bottom_mask` starts at y 388 and `top_mask` / `clip-top` run to y 412. Our `SkinLayer` rasters and renderer overlap in that 388–412 band.
  - The rim in `doll_nest` / `doll_swallow` spans y 377–419: the outer ellipse (256,398) 296×42 is filled `rim_tint`, and the inner ellipse (256,401) 268×30 is filled #291708 at 88%.
- **E4. Everything is clipped to the canvas.** The root `__container` layer clips to the composition bounds (`composition_layer.dart` ~L87–110).
- **E5. Text layers are slow.** Every frame, each character gets a new `TextPainter` plus layout, twice (`text_layer.dart:498/531/684`). Per-frame cost on the dev Mac in flutter_test:

  | File | Per frame |
  |---|---|
  | `ui_chapter_ribbon` | 2.31 ms |
  | `ui_win_ribbon` | 1.18 ms |
  | `ui_family_counter` | 0.37 ms (also when paused) |
  | `fx_confetti` | 181 µs |
  | `doll_complete` | 87 µs |
  | `doll_reveal` | 77 µs |
  | `fx_glass_unlock` | 72 µs playing, 21 µs paused |
  | `fx_ice` | 72 µs playing, 9 µs paused |
  | everything else | 4–40 µs |

- **E6. `flame_lottie` 0.4.3+23 doesn't fit.** Its `LottieComponent` keeps its renderer private and runs its own `EffectController` (duration and infinite only). It has no markers, segments, speed, pause-on-frame, or way to swap delegates after construction.
  - A roughly 60-line component over `LottieDrawable` does the job without it.
  - Resolution check: in a scratch copy of the workspace, `flutter pub get --offline` resolves `lottie` 3.6.1, adding `archive` 4.3.0 and `posix` 6.5.2. `flame_lottie` also resolves against flame 1.38.2.
- **E7. There are 29 JSON files and 29 table rows.** LOTTIE.md and the plan both say 28.
- **E8. Parsing all 29 takes 60 ms cold and 12 ms warm on the dev Mac.**
- **E9. Clean feature set.** All files are v5.7.4 at 60 fps, with no expressions, effects, masks or merge paths, and no embedded glyphs (text renders with the bundled Fredoka 700).
  - Mattes appear in `doll_complete`, `doll_reveal`, `fx_glass_unlock` and `ui_splash_loader`.
  - There are no spatial tangents on `travel`, so the straight-line `remapTravel` is valid.

## B. (1) nesty_render: keep, change, drop

| Component | Verdict | Notes |
|---|---|---|
| `palette/*` | Keep | `rimColor` feeds `rim_tint` (gold uses #E9BE4E). `base` feeds the reveal drops' `tint`. `ink` is baked into the symbol. The gradient map feeds the baked gold masks |
| `skin/skin_manifest.dart`, `skin_loader.dart`, `svg/*`, `svg_tools/*`, `raster/svg_raster.dart` | Keep | Input side is unchanged. The manifest's `splitY` drives the new split clip |
| `skin/skin_rasterizer.dart` | Change | Add part rasters per (colour, symbols mode, px height) on the full 512·r × 768·r frame. Body = shadow, `bottom_mask` (tinted or gold), `bottom_detail`, symbol, `shine_bottom`, clipped to y ≥ 400. Lid = `top_mask`, `face`, `top_detail`, `shine_top`, clipped to y < 400. Silhouette = shadow plus the silhouette layer (the placeholder silhouette includes the shadow) |
| NEW `skin/doll_part_rasters.dart` | Add | Cache keyed by (skin@version, colour, symbols, artHeightPx), with the same clone/dispose rules as `SkinCache` |
| `skin/symbol_atlas.dart` | Keep | Needed only while building rasters; release it afterwards |
| `skin_layer`, `skin_image_set`, `skin_cache`, `svg_skin_renderer` | Demote | Keep for the admin and goldens. The game draws rest sprites from part rasters (next row) |
| NEW `doll/part_raster_doll_renderer.dart` | Add | Rest sprites as 2 image draws (body, then lid) or the silhouette, with the same filter quality as the Lottie. This makes the sprite-to-Lottie hand-off pixel-identical |
| `placeholder_doll_painter.dart`, `fallback_doll_renderer.dart` | Change | Also produce placeholder part rasters with the same split, as the rule-3 fallback for image slots |
| `DollPaintParams` / `DollPart` | Drop from game use | Game uses only colour, height, base, symbols, silhouette, shadow and `full`. Unused: rotation, scaleX/Y, opacity, shine, reveal, and `interior` / `bodyFront` (the D37 work; the Lottie draws the rim underneath). Keep `lidLift` / `open` for the admin's lid-lift preview (spec §15 #6) |
| `doll_effects.dart`, `DollArt` shine / reveal / `bodyFrontClip` | Drop from game | Only useful for a procedural admin preview |
| `doll_painter.dart` | Keep | Static dolls: shop 7.3/7.4 and the admin. Home idle dolls and win families move to Lottie widgets |
| `board_shape`, `board_layout`, `shelf_presets`, `board_layout_constants` | Keep | Every anchor matches at s = 1: glow centre (cx, surface − 2), ice doll base at ice top + 130.8, glass doll base at case top + 123, hint and stand centres. Keep `iceFrame` and `extraSlotRepitchMs` |
| `board_geometry.dart` | Change (additive) | Add a `BoardFit.toReference(x, y)` inverse and anchor getters. Also the post-unlock base (see D-i) |
| `board_sprites.dart` | Change | Expose image, crop offset and pixel scale so images can feed slots with compensation, or provide an uncropped variant. Glass, ice and glow still draw statically as the fallback when an animation file fails. The `dollSilhouette` HUD icon is dropped if the counter becomes the Lottie |
| `debug_board_painter`, `theme/*`, `tokens/*` | Keep | Motion durations become cross-checks only; frame counts from the files drive timing |

## C. M2 design element → Lottie, and what stays hand-coded

Times are at 1× speed from t = 0 of the batch.

| M2 element | Lottie | Still hand-coded |
|---|---|---|
| Selection (lift 120, wobble, settle) | `doll_pick`: lift 7 f, wobble 24 f loop, settle 10 f; plus `fx_select_glow` in 7, pulse 96, out 10 | Segment sequencing. Reduced motion stops after lift |
| Placed (260 + land 120, reserve 380) | `doll_move`, 16 f = 267 ms, landing included | BoardFit placement and remap. Reserve 267 |
| NestedInto inside / swallow | `doll_move` to the hover point (0.5 or 1.06 × target height), then `doll_nest` or `doll_swallow` (24 f). Rim is the bottom layer (fixes (h)) | Clack plus medium haptic at 267 + 270 = 537 ms (was 530). Reserve 667 (was 650) |
| Revealed | `doll_reveal`, 24 f: wipe 12 f = 200 ms (centre art (256,476)), plus drops | The D21 18 dp settle, deeper silhouettes shifting down, the "+N" tag |
| Completed (t0 = 650) | t0 = 667. `doll_complete`, 75 f: shine 0–19 f, hops to 42 f, fly 700–1250 ms. `fx_dust_puff` at t0 + 700. `fx_sparkle` every 60 ms from 700 to 1250 at the position captured in the `travel` callback. Counter bump plus a 1.5× sparkle at t0 + 1250, drawn in the HUD layer | Pools. HUD z-order: the Flame fly passes under the Flutter HUD |
| Unlocked | `fx_glass_unlock` (54 f) on the slot's paused composition, from t0 + 700 with 80 ms stagger | The 11 dp settle (see D-i) |
| Ice cracked / shattered | `fx_ice` `crack_n` (16 f) or `shatter` (33 f) | Stage mapping (Q4), ice badge number |
| Rejected | `doll_invalid` (36 f; `bonk` and haptic at 180 = frame 10.8) | Shaking glass/ice cases and tower silhouettes. Drag variants (see D-b) |
| Won | Batch end + 250 → overlay: `fx_confetti` (102 f = 1700 ✓), `ui_win_ribbon`, `doll_win_hop` per family with 150 ms stagger, `fx_coin_burst` and `coins` at 700 | Scrim, the "+N" count-up, the chapter card |
| FxLayer pools (dust, sparkles, drops, shards, burst) | Drops, shards and burst live inside the files. Pools: sparkle 9, dust 4, others 2; glass/ice use one composition per slot | — |
| HintLayer | `ui_hint_arrow` (54 f) plus `fx_select_glow` on the target | Dashed arc (static path) |
| Family counter, booster glow, extra slot pulse | `ui_family_counter` (12 f, 1.22 at 6 f); `ui_booster_glow` (84 f); `ui_extra_slot` (96 f, always on, matching NestyBoard's `nb-pulse 1.6s infinite`, which draws no pips on extra slots) | 300 ms row re-pitch |
| Splash, Home, toggles | `ui_splash_loader` (frame = progress), `doll_idle`, `fx_twinkle`, `ui_toggle` (on 0–11, off 11–22) | Seeded Random for phase and speed; 48 dp hit area |
| Tactile press, sheet, modal, tab lift, banners | Not Lottie (LOTTIE.md) | `tokens.motion.ui` |

- **Input gating.** Every duration comes from the frame counts: invalid 600, reveal 400, unlock 900, crack 267, shatter 550.
- **`BoardTimeline` must stay pure Dart.** Feed it a `fx_spec.gen.dart` generated at sync time, holding frames, markers, canvas sizes, anchors and S/T points. Add a drift test between that file and the JSON.
- **One haptics difference.** LOTTIE.md and tokens give `IceShattered` no haptic. The M2 design says medium.

## D. Conflicts with owner decisions

- **(a) Towers, D21.**
  - `doll_reveal` has no size change: the silhouette sits at `doll_size` on the rest base. That suits D21's true-size silhouettes better than the design's peek style, which would need a shrink.
  - Two things are still missing:
    - The revealed nest's 18 dp drop (a smaller step on top shelves).
    - The deeper silhouettes shifting down one step.
  - Its first frame therefore doesn't match the D21 rest pose. Fix: tween the component's position.
  - The silhouette image slot needs the shadow included.
  - A destination reveal (A2) starts at t0 + 700.
- **(b) Tap policy, frame 2.6.**
  - Tap invalid is covered, including a pickable nest of the wrong colour.
  - Drag invalid and drag cancel are not: `doll_invalid` travels S → 0.5 → S, so it would drift back to the finger. Use `doll_move` from the finger to the source base, plus `doll_invalid` with the mover hidden.
  - Locked, iced or tower targets: the file only shakes the target doll. Hide its target images and apply its `target` offset to the case, the ice or the silhouettes.
  - Missing roles must get a 1×1 transparent image (a null falls through to the asset's loaded image).
- **(c) Extra slot on the bottom shelf.** Fine: it's placed in place at the stand centre, scaled by `s·q`, and follows the 300 ms re-pitch. The re-pitch also changes `doll_size`.
- **(d) Gold.** Works once gold lid/body rasters are baked from the rewritten masks. The per-colour baking replaces the draw-time modulate filter.
- **(e) Symbols.** The body raster depends on (colour, mode). Rebuild the bodies when the setting changes.
- **(f) Reduced motion.** LOTTIE.md says 2× speed, no confetti, `doll_pick` stops after lift. Tokens also say no shake, and 2× on loops means more motion (Q6).
  - Shakes can be removed with static position delegates: `target` → (0,0) in `doll_invalid`, `ice` → (42,40) in `fx_ice`.
  - Cue times halve too, so the clack moves to 268 ms.
- **(g) Clack timing.** "+270" is measured from the start of the nest file. The absolute time is 536.7 ms, against our 530.
- **(h) Nest z-order.** `doll_nest`'s stack, top to bottom, is `target_lid`, `target_body`, `mover_lid`, `mover_body`, `target_rim`. The rim is only visible from frame 2 to 14–16.2. This fixes the rim-over-guest review finding, but only if the body raster starts exactly at y 400 (E3). Our overlapping 388+ body would cover the rim and the guest's lower edge. This is Q1.
- **(i) Locked and iced slots as paused compositions.**
  - **Z-order:** the shelf layer (stand, pips) draws first, then the composition (doll under the glass or ice), then the ice badge. Hit areas don't change.
  - **Size:** the doll inside needs `doll_size = h / (150·s·q)`.
  - **Images:** the board-piece images need compensation, or they're 1 px per dp and blurry at DPR 3.
  - **Placement:** the composition origin is `caseRect.topLeft − (47,40)·fs` for glass and `iceRect.topLeft − (42,40)·fs` for ice.
  - **Paused cost:** `fx_glass_unlock` at frame 0 still draws the `padlock_ping` precomp with its track matte (layer spans frames 0–13). That's an offscreen layer per locked slot every frame. Cache the rest frame.
  - **11 dp float:** `fx_glass_unlock` ends with the doll at 163 (case floor = surface − 11 dp), not on the stand. After unlock the doll floats or jumps 11 dp.
  - **Locked and iced together:** the codec allows ice on a locked slot, and both compositions draw the doll. Hide the doll in one of them.
  - **Iced towers:** silhouettes draw underneath correctly, but can poke above the ice.
  - **Scale:** the contract doesn't handle BoardLayout's scale or centring. At W ≠ 390 the 390-wide board-space canvas clips (on a 412 dp phone the rightmost doll reaches x ≈ 406). At s up to 1.5, dolls over 150 dp overflow the 160×260 in-place canvases.
  - **Fix:** board-space files translate by `(originX, originY − 142s)` and scale by s, with the remap done in reference units. In-place doll files scale by s; board-piece files by `s·q`. Then k = h / (150·s) (Q2).

## E. Sequencing against spec §11.1

| Event | Start |
|---|---|
| Completed | After the nest file ends (all its squash frames), at 667 ms |
| Unlock and ice | t0 + 700, when the fly starts (the file's frame 42) |
| Counter bump | t0 + 1250 = 1917 ms |
| Won | max(t0 + 1450, unlock end, ice end) + 250 ≈ 2.2–2.5 s |

- Spec §11.1 durations are all met to within one frame. Two exceptions:
  - The reveal file is 400 ms in total (the wipe is 200).
  - The fly's fade is the last 3 frames (50 ms) instead of 80 ms.
- If the player taps the target mid-wobble, `doll_move` starts at rotation 0, so the doll can snap by up to 3°.

## F. Memory against the 25 MB budget (RGBA8)

| Option | Image slots | Total |
|---|---|---|
| Literal (512×768 per slot) | 1.5 MiB each. 5 colours × lid/body + silhouette = 16.5 MiB (19.5 with gold). Board pieces 0.48 MiB, blurry | Plus the current SVG renderer (≤ 8), theme (5.3), board sprites (≤ 5), atlas (0.5), audio (1.1): ≈ 36 MB, over budget |
| Compensated (raster at tallest doll × DPR) | 150 dp @3 = 300×450 = 0.515 MiB each, 5.66 MiB total (+1.03 gold). At 117 dp @3: 3.45 MiB. At 150 dp @2.625: 4.35 MiB | Board pieces at 3× (4.29 MiB) reuse `BoardSprites`, so nothing extra |
| Compensated, rest sprites also from part rasters | Same as above | Drop the per-height set: ≈ 17.6 MB worst case; typical M2 level ≈ 12 MB. Keeping the SVG renderer too gives ≈ 25.6 MB, at the limit |

- Don't decode the placeholder PNGs (8.2 MiB).
- Mattes add about 0.5 MiB of temporary offscreen memory while playing.
- LOTTIE.md's "per skin, color and size" would be 6× these numbers if read literally. Interpret it as the board's raster height.

## G. Admin (M5)

- Preview only.
- The skins screen needs a "lid-lift animation" (spec §15 #6). Keep `lidLift` / `open`, or add `lottie` to the admin and reuse the nesty_render part rasters. Put the rasterizer in nesty_render so the admin and the Storage skins (M4) share it.
- No other impact. Solve playback and playtest stay on the CustomPainter board.

## H. (2) Revised Phase 4 (M2)

**C0, integrator, serial first:**
- The owner moves `export/nesty-lottie-only/design/*` into `design/`, and `docs/plans/lottie-integration.md` into `docs/plans/`.
- Record in PROGRESS:
  - the "all animations are Lottie" decision;
  - a rule-8 exception, since lottie allocates every frame;
  - the rule-9 reasons for lottie 3.6.1 plus archive 4.3.0 and posix 6.5.2, with no `flame_lottie`;
  - the compensation, split and BoardFit placement decisions.
- Freeze these contracts: `FxId`/`FxSpec`, `FxCue`, the `DollPartRasters` API, `FxImageSource`, `BoardEffect`.
- Rewrite the BACKLOG M2 timeline items.

Then parallel lanes:

| Lane | Owns | Work |
|---|---|---|
| L1 tools | `tools/lib/src/assets/design_asset_sync.dart`, new `tools/lib/src/fx/fx_spec_gen.dart`, `tools/test/**`, `tools/README.md`, `apps/game/assets/lottie/**`, `apps/game/lib/features/fx/fx_spec.gen.dart`, `apps/game/pubspec.yaml` (assets + lottie), `apps/game/test/core/assets/asset_manifest_test.dart` | Validate each file: 60 fps, w/h, no expressions/effects/merge paths, expected markers, asset ids and named nulls/fills. Don't ship `images/` (Q7) |
| L2 nesty_render, after the concurrent render work lands | `skin/skin_rasterizer.dart`, new `skin/doll_part_rasters.dart`, new `doll/part_raster_doll_renderer.dart`, `placeholder_doll_painter.dart`, `fallback_doll_renderer.dart`, `board/board_sprites.dart`, `board/board_geometry.dart`, `nesty_render.dart`, `test/**` | Tests: lid alpha is 0 for y ≥ 400r and body alpha is 0 for y < 400r; parity with the renderer outside 388–412; gold; symbol modes; silhouette includes shadow; byte budgets |
| L3 FX runtime | `apps/game/lib/features/fx/**` (except the gen file): `fx_library.dart` (`@lazySingleton`, `fromBytes`, null on failure) and its fake, `fx_images.dart`, `fx_delegates.dart` (size, rim, tint, travel, compensation, reduced motion, text), `fx_player.dart` (pure segment/loop/speed math), `lottie_fx_component.dart` (Flame), `lottie_fx_view.dart` (widget), `fx_pool.dart`; `test/features/fx/**` | Set drawable filter quality to medium |
| L4 timeline | `apps/game/lib/features/gameplay/game/timeline/**` (clips, reservations, feedback sink, combo tracker, motion spec from FxSpec); tests | Cue-time tests using the table in C |
| L5 Flame board | `game/nesty_game.dart`, `game/components/**` (board, shelf layer, slot with paused glass/ice composition and cached rest frame, nest with D21 settle, FX layer with BoardFit and priorities, hint layer); tests | Hand-off golden test: sprite vs frame 0 |
| L6 HUD and overlays | `gameplay/widgets/**`, `gameplay/overlays/**`, `core/ui/widgets/nesty_toggle.dart`, `features/splash/**`, `features/home/**`, ARB | Counter is the Lottie at rest. Ribbon text handled per R3 |
| L7 services | `core/services/skin/**` (SkinService: part rasters per level for the colours present × mode × tallest doll × DPR, placeholder fallback, `FxImageSource`), FxLibrary DI registration | — |
| L8 integrator | — | build_runner, gen-l10n, app_flow test, perf profile (Complete + sparkles + dust), builds, TODO index |

- **Order:** L1's FxSpec feeds L3 and L4; L4 can start from a stub. L2 feeds L7, and L7 plus L3 feed L5 and L6.
- **Glass and ice come last.** Locks start at L31 and ice at L51, so neither is on M2's levels 1–30 path.
- **Chapter ribbon.** L21 is ch02's first level, so the ribbon lands in M2. The tutorial hands, settings toggles and spinner go to M3.

## I. (3) Owner questions, with recommended defaults

1. **Closed-doll seam.** The Lottie rasters split hard at y 400; the SVG renders overlap lid over body in 388–412. Default: hard split everywhere (rest sprites use the same rasters), and exclude that band from the goldens.
2. **Board scaling.** The contract's "absolute dp, board files at screen (0,0)" clips on screens that aren't 390 wide and on tablets. Default: place everything through BoardFit, so every motion distance scales with s. It's identical at 390×844.
3. **Animations with no file.** These are exceptions to "every animation is Lottie":
   - the D21 reveal drop and the silhouettes shifting down;
   - the 11 dp settle after a glass unlock;
   - the 300 ms re-pitch;
   - shaking cases, ice and silhouettes on invalid;
   - drag cancel and drag invalid;
   - the tag and badge counts;
   - the coin count-up.

   Default: hand-code them, driven by the files' own nulls where possible, or the owner re-exports `doll_reveal` and `fx_glass_unlock`.
4. **Ice counters other than 3.** The file has only `crack_1` to `crack_3`. Core emits no crack on the 1 → 0 step (A9), so an ice of 3 never uses `crack_3`, and 5 or more would need a `crack_4` that doesn't exist. Default: use `BoardLayout.iceFrame`, play a crack only when the stage advances, and cap authored ice at 3 in M5.
5. **Where `doll_win_dance` plays.** The board is empty at Won; the motion sheet dances the families, while App Flow 2.8 hops them. Default: families hop, and the dance file stays unused.
6. **Reduced motion.** Default:
   - one-shot animations at half duration, with shakes removed by delegates, no confetti and no wobble;
   - ambient loops (idle, twinkle, dance, hop) paused on frame 0;
   - loops that carry information (glow, hint arrow, booster glow, extra slot, spinner) at 1×.
7. **Placeholder PNGs.** They're wrong in lottie-flutter (E2) and cost 1.79 MB. Default: don't ship them, or ship them in dev only.
8. **Still open from the plan.** Flame or an overlay for board effects: default Flame, with our own component and no `flame_lottie`. Ribbon strings over 22 characters: default scale the text to fit, with the text drawn by us (see R3).

## J. (4) Risks

- **R1. Resolution semantics (E1).** Without compensation, board pieces are blurry and oversized rasters draw in the wrong place. Pin `lottie` exactly and add the equivalence test.
- **R2. Memory (F).** The literal approach goes over 25 MB.
- **R3. Text cost (E5).** On a low-end phone this could be 5–10× the Mac numbers. Hide the Lottie text layers and draw Flutter text that follows the `ribbon` / `counter` null transforms, or profile early.
- **R4. Paused compositions.** The glass matte costs an offscreen layer per slot per frame; cache it.
- **R5. Hand-off jumps.** Sources: the E3 band, the wobble snap, the 11 dp glass float, the D21 drop, and resampled vs 1:1 filtering (unify the rest sprites).
- **R6. Canvas clipping (E4).** Dragging outside the board frame still clips, even with BoardFit.
- **R7. Rule 8.** Lottie allocates every frame internally, and the travel callback returns a new Offset each frame.
- **R8. Aliasing.** Size-1 dolls are drawn at 0.42× from one max-size raster. The default filter is `FilterQuality.low`; mipmaps on Impeller `toImage` still need checking.
- **R9. Seam line.** Two hard edges meet at y 400.
- **R10. Rule-3 fallback.** When a file fails to load, the static glass, ice, toggle and counter painting must still exist, because for those the Lottie is the rest look.
- **R11. Splash load.** Parsing takes about 60 ms cold on the Mac, likely around 300 ms on a phone. Spread it over frames at splash.
- **R12. Doc drift.** The docs say 28 files, but there are 29. The concurrent D37 `interior` / `bodyFront` work becomes obsolete.