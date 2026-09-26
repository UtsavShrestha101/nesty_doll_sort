# M2 phase 4 — Lottie design (authoritative)

Status: frozen by the contracts stage, 2026-09-26. Owner decisions of 2026-09-26 are PROGRESS D40–D52.

This is the design every M2 phase-4 lane builds against. It combines four sources: [design-foundation-m2-design.md](design-foundation-m2-design.md) (the earlier M2 design), [design/lottie/LOTTIE.md](../../design/lottie/LOTTIE.md) (the owner's Lottie contract), the verified behaviour of `lottie` 3.6.1 in [lottie-analysis/](lottie-analysis/) (audit, packages, impact), and the owner decisions.

**Precedence:**
- This file wins over the earlier M2 design for everything animated. That covers its `BoardTimeline` clip table, `DollRenderer` shine/reveal/lid-lift, the nest `DollPart` passes, `FxLayer` particles and the hint layer's arrow.
- The earlier design still holds for layout, the bloc, services, widgets, ARB and flows, except where §11 changes the bloc contract.
- Where LOTTIE.md can't be followed on lottie 3.6.1, this file says what to do instead. LOTTIE.md is never edited (`design/` is read-only).

Frozen Dart contracts:
- `apps/game/lib/features/fx/{fx_id,fx_spec,fx_cue,fx_image_source,fx_library,fake_fx_library}.dart`
- `packages/nesty_render/lib/src/skin/doll_part_rasters.dart` (the API; the render lane implements it)
- `apps/game/lib/features/gameplay/bloc/{board_effect,gameplay_event,gameplay_state,gameplay_bloc}.dart`
- the service interfaces `AudioService`, `HapticsService`, `SolverService`, `SkinService`/`LevelSkin` and `LevelRepository`

Lanes may add to these. Breaking one needs the integrator and a note in the lane's report.

Contents:
1. Decisions
2. Runtime architecture
3. Image-slot compensation
4. Doll part rasters, rest sprites, `FxImageSource`, `SkinService`
5. Placement: BoardFit
6. Travel remap and the hold workaround
7. Events → files, cues and reservations
8. Locked and iced slots: paused compositions
9. Hand-coded gap motions
10. Hand-off rules and rule-3 fallbacks
11. Gameplay bloc contract
12. Localized text on Lottie
13. Reduced motion
14. Pools and performance (rule 8)
15. M2 vs M3
16. Lanes, files and stages
17. Test plan
18. Designer re-export and swap

## 1. Decisions (PROGRESS D40–D52)

- **D40: every animation ships as Lottie.** All 29 files in `design/lottie/` ship. Widget transitions stay Flutter animations on `tokens.motion.ui`: tactile press, sheet, modal, tab lift and banners.
  - The board timeline still owns event order, cues and input gating. A Lottie never changes game state.
  - The motions with no file are hand-coded (§9).
- **D41: `lottie: 3.6.1`, pinned exactly.** It adds `archive` 4.3.0 and `posix` 6.5.2 transitively. No `flame_lottie`.
  - Board clips use our own Flame component over `LottieDrawable`.
  - The HUD, overlays and screens use our widget over `LottieDrawable`.
- **D42: rule-8 exception.** lottie allocates inside its own draw, and our position callbacks must return a new `Offset`. Nothing else in our code allocates per frame (§14).
- **D43: export defects are worked around in code.** A re-export request goes to the designer ([lottie-reexport-request.md](lottie-reexport-request.md), §18). The workarounds:
  - image-slot compensation (§3);
  - the travel-hold fix (§6);
  - `padlock_ping` hidden at rest (§8);
  - the 11 dp settle (§9);
  - `doll_reveal`'s silhouette hidden after the wipe (§7);
  - BoardFit placement (§5);
  - `LottieComposition.fromBytes`;
  - a 1×1 blank image for unused roles.
- **D44: text layers are hidden.** Localized Flutter text is drawn following the ribbon and counter nulls (§12).
- **D45: hard lid/body split at art y 400 everywhere.** Rest sprites draw from the same part rasters as the Lottie (§4). The goldens exclude the 388–412 band. D37's `interior`/`bodyFront` passes are obsolete in the game.
- **D46: BoardFit placement for every board file.** Every motion distance scales with the board scale `s`. At 390×844 it is identical to LOTTIE.md (§5).
- **D47: Win families hop.** They use `doll_win_hop` with a 150 ms stagger. `doll_win_dance` ships but is unused in M2.
- **D48: reduced motion** (§13):
  - one-shots play at half duration;
  - shakes are removed, and so are confetti and the wobble;
  - ambient loops pause on frame 0;
  - loops that carry information stay at 1×.
- **D49: `IceShattered` has no haptic**, per LOTTIE.md and tokens (the earlier design said medium).
- **D50: the placeholder PNGs are never shipped or decoded.**
- **D51: ice stages come from `BoardLayout.iceFrame`.** A crack plays only when the stage advances. Stage `n` rests on frame `16n`.
- **D52: effect names.**
  - The `BoardEffect`s are named `…Effect`, which resolves the D27 clash.
  - The bloc contract is §11.
  - Q30–Q38 are owner-confirmed.

Earlier decisions still in force:
- the tap policy of frame 2.6;
- the extra slot on the bottom shelf (at most 2, kept on restart);
- gold rendered through the gradient map;
- subtle and large symbols;
- the soft-stuck banner (3.4);
- tokens precedence;
- all art bundled;
- placeholder WAVs with the clack pitch compensation.

## 2. Runtime architecture

- **Loading.** `FxLibrary` (`@lazySingleton`) loads all 29 files once at splash. It reads `rootBundle.load(FxId.assetPath)`, parses with `LottieComposition.fromBytes`, and spreads the work over frames.
  - Parsing costs about 60 ms cold on the dev Mac, so it may take around 300 ms on a phone.
  - It reports progress to the splash loader and never throws. A failed file is left out and logged (rule 3, §10).
  - `fromBytes` decodes no images: no placeholder PNG is ever decoded (8.2 MiB saved).
  - `FxLibrary.blank` is the 1×1 transparent image returned for slots that must draw nothing.
- **Board: `LottieFxComponent`** (Flame `PositionComponent`), for every `FxId` whose `host == FxHost.board`.
  - It wraps one `LottieDrawable` and plays one segment (or a frame range) at a speed, looping or not, or rests on a frame.
  - Its progress comes from its own frame counter: `progress = (frame / composition.durationFrames).clamp(0, 1)`. lottie reports `durationFrames` as `op − 0.01`, so a marker's end can exceed 1; always clamp.
  - Set `drawable.frameRate = FrameRate.max` for sub-frame smoothness at 0.5×, 2× and 120 Hz. Set `filterQuality = FilterQuality.medium`, because 512-unit art is drawn at 63–150 dp.
  - The component runs inside the board timeline's `advance(dt)`, so a clip starts in the same frame its sprite is hidden (§10).
  - The probe sketch is `lottie_probe/lib/fx_component.dart`.
- **Widgets: `LottieFxView`**, for every `FxId` whose `host == FxHost.widget`.
  - It is a `CustomPainter` over one `LottieDrawable`, repainted by an `AnimationController`. A paused view costs nothing.
  - It is the only way to draw the text overlays of §12. Don't use `Lottie.asset` or `Lottie.network` anywhere: they decode the placeholders.
- **Drawable rules** (verified in the analysis):
  1. Construct `LottieDrawable(composition)` first, then set `..delegates = …`. Passing value delegates to the constructor throws `LateInitializationError`.
  2. Set a drawable's delegates once, when the pooled component is created. Per-use parameters (colours, points, sizes, flags) live in mutable fields that the delegate closures read. `LottieDelegates ==` ignores `image` and compares `values` by identity, so swapping delegates is unreliable and never done.
  3. Never share a `ValueDelegate` instance between drawables: it stores its resolved key paths on itself.
  4. `LottieFrameInfo` is not exported. Write callbacks as closures whose parameter type is inferred; never import `package:lottie/src/…`.
  5. For path positions (`travel`, nulls' `p`), the eased progress is `f.interpolatedKeyframeProgress`. For scale and other point values, the two fields are swapped on 3.6.1 and the eased value is `f.linearKeyframeProgress`. The equivalence tests (§17) pin this.
  6. A text size change uses `ValueDelegate.textSize`; a `textStyle` delegate can't change the size. The game hides text instead (§12).

### The 29 files (`FxId`)

- **Kind:** **P** = in place, **B** = board space, **S** = segmented (in place plus markers).
- **Host:** F = Flame, W = widget.
- **Pool:** the drawables alive at once (§14).
- **Frames:** at 60 fps.
- **Anchors** are LOTTIE.md's.

| FxId | Frames (ms) | Canvas | Kind | Anchor → game point | Host | Pool | Ms |
|---|---|---|---|---|---|---|---|
| dollPick | 41 (683): lift 0+7, wobble 7+24 loop, settle 31+10 | 160×260 | S | (80,230) → doll base | F | 2 | M2 |
| dollMove | 16 (267) | 390×844 | B | S (100,500) → T (300,500) | F | 2 | M2 |
| dollNest | 24 (400) | 160×260 | P | (80,230) → target base | F | 2 | M2 |
| dollSwallow | 24 (400) | 180×380 | P | (90,350) → target base | F | 2 | M2 |
| dollComplete | 75 (1250) | 390×844 | B | S (100,650) → T (195,144); travel holds 0–42 | F | 2 | M2 |
| dollInvalid | 36 (600) | 390×844 | B | S (100,500) → T (300,500); `target_pos` (300,500) | F | 2 | M2 |
| dollReveal | 24 (400) | 160×260 | P | (80,230) → tower surface | F | 2 | M2 |
| dollIdle | 180 (3000) loop | 160×260 | P | (80,230) → plank base | W | per doll | M2 |
| dollWinDance | 84 (1400) loop | 160×260 | P | (80,230) | W | — | unused |
| dollWinHop | 78 (1300) loop | 160×260 | P | (80,230) → win plank | W | per family | M2 |
| fxSelectGlow | 113 (1883): in 0+7, pulse 7+96 loop, out 103+10 | 140×80 | S | (70,40) → (cx, surface − 2) | F | 3 | M2 |
| fxGlassUnlock | 54 (900) | 180×240 | P | case top-left (47,40); doll base (90,163) | F | 1 per locked slot | M2 (L31+) |
| fxIce | 81 (1350): crack_1 0+16, crack_2 16+16, crack_3 32+16, shatter 48+33 | 180×240 | S | ice top-left (42,40); doll base (90,170.8) | F | 1 per iced slot | M2 (L51+) |
| fxDustPuff | 24 (400) | 160×80 | P | (80,62) → (cx, surface) | F | 4 | M2 |
| fxSparkle | 16 (267) | 64×64 | P | (32,32) → trail point | F | 9 | M2 |
| fxConfetti | 102 (1700) | 390×844 | P | burst (195,190) → ribbon centre | W | 1 | M2 |
| fxCoinBurst | 40 (667) | 160×140 | P | (80,100) → coin in "+N" pill | W | 1 | M2 |
| fxTwinkle | 120 (2000) loop | 32×32 | P | (16,16) | W | per twinkle | M2 (splash, home, win) |
| uiFamilyCounter | 12 (200): bump 0+12 | 120×60 | S | (60,30) → counter centre | W | 1 | M2 |
| uiHintArrow | 54 (900) loop | 60×80 | P | (30,45) → (cx, dollTop − 33·fs) | F | 1 | M2 |
| uiExtraSlot | 96 (1600) loop | 110×50 | P | (55,25) → stand centre | F | 2 | M2 |
| uiBoosterGlow | 84 (1400) loop | 130×110 | P | (65,55) → Undo centre, behind it | W | 1 | M2 |
| uiWinRibbon | 18 (300), then hold | 360×110 | P | (180,55) → ribbon centre | W | 1 | M2 |
| uiChapterRibbon | 156 (2600) | 360×100 | P | (180,50) | W | 1 | M2 (L21) |
| uiToggle | 22 (367): on 0+11, off 11+11; rest off 0, on 11 | 54×30 | S | toggle box | W | per toggle | M2 Pause, M3 Settings |
| uiSpinner | 54 (900) loop | 16×16 | P | centre | W | — | M3 |
| uiSplashLoader | 100, frame = progress % | 278×22 | P | bar box | W | 1 | M2 |
| uiTapHand | 72 (1200) loop | 128×144 | P | fingertip (48,32) → target | W | — | M3 |
| uiDragHand | 144 (2400) loop | 390×844 | B | S (100,500) → T (300,500); holds 0–21.6, 86.4–108 | W, through BoardFit | — | M3 |

- **Generated specs.** The per-file facts live in `fx_spec.gen.dart` (`const Map<FxId, FxSpec> fxSpecs`, plus `FxSpec fxSpecOf(FxId)`). The tools lane generates it from the JSON plus a contract table of the LOTTIE.md-only facts: anchor, S/T, kind and loop.
  - It holds frames, canvas, markers, travel S/T with holds, roles, image layers with their authored scale/anchor, text layers and colour fills.
  - The board timeline reads only this file, `FxTiming` and `FxCue`, so it stays pure Dart (no Flame, no lottie).
- **Before the generator lands,** lanes write local fixture `FxSpec`s from this table.

## 3. Image-slot compensation

- **The problem.** lottie 3.6.1 draws an image layer's bitmap at its own pixel size (`image_layer.dart`: `dst = (0,0,bitmap.width,bitmap.height)`) and ignores the asset's declared `w`/`h`.
  - The game can't supply the declared sizes. 512×768 per doll part would be over budget (impact §F), and 1 px per dp board pieces would be blurry at DPR 3.
  - So every image layer gets a scale and anchor delegate that compensates for the raster it actually receives.
- **Terms.** A raster comes as `FxRaster(image, scale, origin)`:
  - `scale` = raster px per declared px;
  - `origin` = where the raster's top-left sits in the declared box, in declared px (a crop).
  - For an image layer authored with scale `k` and anchor `a`:

```
compensated scale  = k / raster.scale                (per axis)
compensated anchor = (a − raster.origin) × raster.scale
```

- **Two proofs.** This reproduces the authored drawing exactly, whatever the raster size. It was verified in probes:
  - E1: 300×450 raster in `doll_pick` equals 512×768.
  - C0: `doll_reveal`'s precomp children at 0.35 % edge pixels. Without the precomp compensation, 28,497 pixels differ.
- **Static-scale layers** get `ValueDelegate.transformScale(keyPath, callback: (_) => …)` and `ValueDelegate.transformAnchorPoint(keyPath, callback: …)`. The callbacks read the clip's current `FxRaster`; a static value would freeze one raster.
- **Animated-scale layers** (`glow_ring`, `extra_slot`, `ice_shatter`) can't take a static replacement.
  - **The chosen fix** is a scale callback that returns the authored animated value divided by `raster.scale`: `Offset.lerp(f.startValue, f.endValue, f.linearKeyframeProgress)! / raster.scale`. On 3.6.1, `linearKeyframeProgress` holds the eased progress for point values. `PointKeyframeAnimation` calls the callback on every evaluation, holds included.
  - It was verified in the C0 probe (`scratchpad/lt/test/anim_scale_comp_test.dart`): a 3× raster with the callback draws the same bounds as the 1× raster at every sampled frame, within 1 px at 3×.
  - **Fallback if a lottie upgrade breaks the equivalence test:** give those three layers the declared-size raster (1 px per dp) with no compensation. It is soft but correct, and acceptable for a glow, a 300 ms shatter and the pulsing stand. The re-export request asks for the pulse to move onto a parent null (§18).

| File | Layer key path | Asset | Authored scale | Authored anchor | Scale |
|---|---|---|---|---|---|
| doll_pick, doll_move, doll_idle, doll_win_*, doll_complete, fx_glass_unlock, fx_ice | `doll_lid`, `doll_body` | doll_lid/body | 0.1953 | (256, 742) | static |
| doll_nest, doll_swallow, doll_invalid | `mover_lid`, `mover_body`, `target_lid`, `target_body` | mover_*/target_* | 0.1953 | (256, 742) | static |
| doll_reveal | `doll_silhouette` | doll_silhouette | 0.1953 | (256, 742) | static |
| doll_reveal | `color_doll` › `lid`, `body` | doll_lid/body | 1 | (0, 0) | static (inside the 512×768 precomp) |
| doll_complete | `shine_matte` › `lid`, `body` | doll_lid/body | 1 | (0, 0) | static (the shine's matte) |
| fx_glass_unlock | `glass_case_0/1/2` | glass_case_* | 1 | (0, 0) | static |
| fx_glass_unlock | `padlock_ping` › `lock` | glass_case_0 | 1 | (0, 0) | static |
| fx_glass_unlock | `unlock_symbol` | unlock_symbol | 1 | (6, 6) | static |
| fx_ice | `ice_0` … `ice_3` | ice_* | 1 | (0, 0) | static |
| fx_ice | `ice_shatter` | ice_shatter | animated | (48, 80) | **callback** |
| fx_select_glow | `glow_ring` | glow_ring | animated | (58, 26) | **callback** |
| ui_extra_slot | `extra_slot` | extra_slot | animated | (45, 17) | **callback** |
| ui_hint_arrow | `hint_arrow` | hint_arrow | 1 | (20, 25) | static (position animated, untouched) |

- **Precomp children** use the key path `[precompLayerName, childName]`, as verified above.
- **Supplied rasters:**
  - doll parts: `r = artHeightPx / 768` (§4);
  - board pieces: the `BoardSpriteImage` at the slot's furniture scale, `scale = pixelScale` (furniture scale × DPR), `origin = offset / pixelScale` (the crop);
  - the unlock symbol: rasterized at `12 × furnitureScale × DPR`.
- **Blank slots.** A slot whose role is unset or hidden returns `FxLibrary.blank`, never null. A null falls through to `asset.loadedImage`, which is null with `fromBytes` today, but blank is safe regardless.

## 4. Doll part rasters, rest sprites, `FxImageSource`, `SkinService`

- **`DollPartSet`** (nesty_render, frozen API) holds, per colour on the board, a **lid** and a **body**, plus one **silhouette**. Each is the whole artboard at `512·r × 768·r` px with `r = artHeightPx / 768`.
  - **The height:** `artHeightPx = DollPartRasters.artHeightPxFor(tallestDollHeight, dpr)` = `ceil(h × dpr)` rounded up to a multiple of 3, so the width `2/3·artHeightPx` is whole and the compensation is exact on both axes. The tallest doll samples 1:1; smaller ones draw down with `FilterQuality.medium`.
  - **Lid** = `top_mask` (tinted, or gold-rewritten), `face`, `top_detail`, `shine_top`, clipped to art y < 400.
  - **Body** = `shadow`, `bottom_mask` (tinted or gold), `bottom_detail`, the belly symbol, `shine_bottom`, clipped to y ≥ 400. There is no 388–412 overlap: `doll_nest`'s rim is drawn between the parts (impact D-h).
  - **Silhouette** = `shadow` + `SkinLayer.silhouette` (wood masks, shines at 45 %), whole.
  - **Gold** uses the ramp-rewritten masks (`SkinLayer.goldLidMask`/`goldBottomMask`), never a tint. `rim_tint` for gold is `#E9BE4E` (`DollSwatch.rimColor`).
  - **Symbols:** the body raster depends on (colour, mode). `none` has no symbol. `subtle` is ink at 94 % in the 110-unit box. `large` is the cream disc r 92 with an 8-unit ink ring and the symbol at 117. Rebuild the bodies when the setting changes.
  - **Placeholder fallback:** `DollPartRasters.preparePlaceholder` draws the same parts with `PlaceholderDollPainter`, with the same split. It is used when the skin fails to load (rule 3).
  - **Cache:** `DollPartRasters` caches sets per (skin@version, colours, mode, artHeightPx) with `SkinCache`'s clone/dispose rules.
- **Budget:**
  - At 150 dp × DPR 3 = 450 px, a part is 300×450 = 0.54 MB. Five colours plus the silhouette come to about 5.9 MB, and gold adds 1.1.
  - A typical M2 level, with every GPU image counted, is about 12 MB; the worst case is about 17.6 MB, under the 25 MB budget.
  - The SVG layer rasters of D37 (`SkinCache`/`SvgSkinRenderer`) are no longer prepared in the game. They stay for the admin and the goldens.
- **Rest sprites:** `PartRasterDollRenderer` (nesty_render, new) implements `DollRenderer`. It draws body then lid, or the silhouette.
  - It uses the same transform as the Lottie: the image's (256r, 742r) on the base point, scaled `h / (768 r)`, `FilterQuality.medium`, no pixel snapping. A sprite and a clip's end frame are therefore pixel-identical.
  - It honours only `color`, `height`, `base`, `silhouette`, `shadow` and `symbols`. The rest of `DollPaintParams` is unused in the game.
- **`FxImageSource`** (frozen) has one method: `FxRaster? rasterFor(FxImageSlot slot, FxImageRequest request)`.
  - It is a map lookup that never allocates: it runs up to 6 times per frame per clip.
  - `FxImageRequest` is mutable and one per pooled clip. It holds the colours of the doll, mover and target roles, the hide flags, the unlock colour, and the slot's furniture scale.
  - The skin service implements it over the level's `DollPartSet`, `BoardSprites` and unlock-symbol rasters.
- **`SkinService` / `LevelSkin`** (frozen):
  - `load()` runs once at splash. `prepareForLevel(level, geometry:, devicePixelRatio:, symbols:)` returns a `LevelSkin{images, restRenderer, sprites}`.
  - Call it behind the route transition, and again after an extra-slot re-pitch: swap in the new skin, then dispose the old one.
  - For Continue, the page prepares the next level's skin while the win overlay is up (`LevelSkinLoader.prefetch`, for `GameplayBoard.layoutFor`), and the board's first layout of that level adopts it in the same update: a skin holds only its own level's colours (PROGRESS D58, 2026-09-27).
  - It never throws: a failure falls back to placeholder rasters.
  - The fake env uses `FakeSkinService`: the placeholder painter, no images, no sprites.

## 5. Placement: BoardFit (reference units)

`BoardFit` maps reference units to logical px: `x = originX + X·s`, `y = originY + (Y − 142)·s`. Each file is placed as follows:

- **Board-space files** (`doll_move`, `doll_complete`, `doll_invalid`): the component is translated to `(fit.originX, fit.originY − 142·s)` and scaled by `s`.
  - The canvas is then exactly the 390×844 reference screen, so every authored distance (lift 14, arc 42 or 30, hop 22 or 14, shake 6) scales with `s`.
  - `src` and `dst` go into the remap in reference units, through `BoardFit.toReference` (render lane).
  - The family counter target (`BoardGeometry.familyCounterTarget`) is (195, 129) in reference units at 390×844. Vertical centring slack moves it up by `slack / (2s)`, which keeps it inside the canvas while `slack < 2·(142·s − 13)`. Assert it in debug.
- **In-place doll files** (`doll_pick`, `doll_nest`, `doll_swallow`, `doll_reveal`): the component sits at the game point with anchor `(ax/w, ay/h)` and scale `s`.
- **In-place board pieces** (`fx_select_glow`, `fx_glass_unlock`, `fx_ice`, `fx_dust_puff`, `ui_hint_arrow`, `ui_extra_slot`) use scale `fs = slot.furnitureScale` (s·q) instead. `fx_sparkle` uses `s`.
- **Doll size:** set every `<role>_size` null to `k = h / (150 · scale)`, where `scale` is the composition's scale. That is `s` for doll files and `fs` for glass and ice (whose doll is authored at 78 %).
  - In `doll_nest` and `doll_swallow` the mover chain sits inside `target_size`, so `target_size = hTarget/(150 s)` and `mover_size = hMover / hTarget`.
  - In `doll_invalid` the chains are separate: each role gets `h/(150 s)`.
- **Clipping:** the root composition clips to its canvas.
  - In-place canvases at `s` hold every doll (h ≤ 150·s).
  - A dragged doll's rendered position is clamped to the board frame, so a `doll_move` that starts from the finger never starts outside the canvas (fixes R6).
- **Widgets** outside the board use their own layout box.
  - The HUD is not board-scaled; `ui_family_counter` draws at 1× at the counter.
  - `fx_confetti` is scaled `W/390` about the ribbon's burst point.
  - The tutorial `ui_drag_hand` (M3) uses the board-space transform above inside a `Transform`.

## 6. Travel remap and the hold workaround

- **Position callback.** The board-space files use `ValueDelegate.transformPosition(['travel'], callback: …)`. It returns `FxTravel.remap(v, src, dst)` in reference units, with `v = Offset.lerp(f.startValue, f.endValue, f.interpolatedKeyframeProgress)`.
  - `remap` projects `v` on S→T (`u = ((v − S)·(T − S))/|T − S|²`) and returns `src + (dst − src)·u`. It keeps the easing and the easeOutBack overshoot: `doll_move` reaches u = 1.0875 at frame 8.
  - There are no spatial tangents on `travel`, so the straight projection is exact.

| File | src | dst |
|---|---|---|
| doll_move | the source base, or the finger's base after a drag | the target base (Placed), or the hover point: the target base − 0.50 × target height (nest), − 1.06 × target height (swallow) |
| doll_complete | the completed set's base | the family counter centre + (0, 0.1 × doll height) |
| doll_invalid | the source base | the target base − 0.5 × target height; `target_pos` = the target base (static value) |
| ui_drag_hand (M3) | the tap point on the big doll | the target surface − 0.4 × target height |

- **Holds (audit #2).** When two consecutive `travel` keyframes are equal, lottie returns the keyframe value without calling the position callback. That happens in `doll_complete` 0–42 f and `ui_drag_hand` 0–21.6 f and 86.4–108 f; `doll_move` and `doll_invalid` have no interior hold. Without a fix, the shine and hops draw at the authored (100, 650).
  - **Fix (verified, probe T10):** add `ValueDelegate.transformAnchorPoint(['travel'], callback: …)`. `getMatrix` evaluates position before anchor. So the position callback sets a flag, and the anchor callback reads and clears it.
  - When the flag is unset, the position was bypassed. The anchor callback then returns `hold.value − remap(hold.value)`, where `hold = spec.travel.nearestHold(currentFrame)`. `nearestHold` is robust to lottie's frame rounding at a boundary.
  - Otherwise it returns the authored anchor (0,0). The translation is then `S − (S − src) = src`, and `T − (T − dst) = dst` in a T-hold.
  - The callback still returns a new `Offset` per call (D42).
- **Sparkle trail.** The position callback also stores the remapped point in the clip's mutable state. The FX layer reads it to spawn `fx_sparkle` along the fly (§7).

## 7. Events → files, cues and reservations

- **Rules for the timeline.**
  - Every file's length comes from its `FxSpec`, and every cue from `FxTiming`/`FxCue`. Times are ms at 1× from the start of the batch (the effect).
  - All offsets, staggers and delays scale by `MotionSpec.durationScale` (0.5 under reduced motion, §13).
  - Events play in `MoveEvent` order (spec §4).
  - **Reservation:** a reserved slot drops taps and drags until its last clip ends.
  - **Global lock:** while won, paused, during an overlay, and during the 300 ms re-pitch.

| Trigger (effect / core event) | Files and start | Cues (sound, haptic) | Reserved |
|---|---|---|---|
| `SelectionChangedEffect(selected: X)` | `doll_pick` lift 0–117 → wobble loop; `fx_select_glow` in 0–117 → pulse loop, on X | `pick` + `pick` @0 | — (a tap on X cancels) |
| `SelectionChangedEffect(previous: X)` | `doll_pick` settle 0–167; glow out 0–167 | — | — |
| Drag start | as selection; the lifted doll then follows the finger, held on `lift`'s last frame (no wobble while dragging) | `pick` + `pick` @0 | — |
| Drag cancel (`previous`, `byDrag`) | `doll_move` finger → source base 0–267; glow out | — | source 267 |
| `Placed` | glow out @0 on the source; `doll_move` src → target base 0–267 | `whoosh` @0 | src and dst 267 |
| `NestedInto` inside | `doll_move` src → hover 0–267, then `doll_nest` at the target 267–667 | `whoosh` @0; `clack(merged.outer.size)` + `nest` @**537** (16 f + 16.2 f) | src and dst 667 |
| `NestedInto` swallow | `doll_move` src → hover (1.06 h) 0–267, then `doll_swallow` 267–667 | same | same |
| `Revealed` (source tower) | hand-coded D21 drop 0–120 (§9), then `doll_reveal` 120–520 | — | src 520 |
| `Completed` (t0 = end of the landing: **667**) | `doll_complete` at dst t0–t0+1250. At **t0+700** (1367): `fx_dust_puff` (400) at dst; `fx_sparkle` every 60 ms to t0+1240 (10 sparkles) on the trail. At **t0+1250** (1917): HUD `onFamilyLanded`, `ui_family_counter` bump 200 (text swaps at +100) and a 1.5× sparkle over the counter | `complete_{comboStep}` + `complete` @t0 | dst until t0+700 |
| `Revealed` (destination tower, after `Completed`) | drop t0+700 → t0+820, then `doll_reveal` t0+820 → t0+1220 | — | dst until t0+1220 |
| `Unlocked` (k-th slot event) | `fx_glass_unlock` on the slot's composition from t0+700 + 80k, 900 ms; the 11 dp settle is blended into its last hop (§9) | `unlockGlass` + `unlock` @start | slot to its end |
| `IceCracked` (k-th slot event) | when `iceFrame` advances to n: `fx_ice` `crack_n` from t0+700 + 80k, 267 ms; else no clip; the badge counts down at start | `iceCrack` + `iceCrack` @start | slot to its end |
| `IceShattered` (k-th slot event) | `fx_ice` `shatter` (48–81) from t0+700 + 80k, 550 ms | `iceShatter` @start, **no haptic** (D49) | slot to its end |
| `Won` | the batch's last clip ends (counter bump t0+1450 = 2117, or the last slot event), + **250** → `onWon` → win overlay | — | global |
| Win overlay (from its open, D47) | scrim (Flutter); `ui_win_ribbon` 0–300 then hold; `fx_confetti` 0–1700 (not under reduced motion); per completed family, `doll_win_hop` loop starting 150·i; at **700**: `fx_coin_burst` (667) and the "+N" count-up 700–1300; `fx_twinkle` ambient | `win` + `win` @0; `coins` @700 | global |
| `OutOfMoves` | the board goes idle → `onOutOfMoves` → sheet 3.5 | — | global while the sheet is open |
| `MoveRejectedEffect` (tap) | glow out @0; `doll_invalid` 0–600 (the mover drifts to u = 0.5 and back, the target shakes 180–420). On a locked, iced or tower target, hide the target roles and shake the slot composition or silhouettes by hand (§9) | `bonk` + `invalid` @**180** (10.8 f) | src and dst 600 |
| `MoveRejectedEffect` (`byDrag`) | `doll_move` finger → source base 0–267, plus `doll_invalid` with `hideMover` 0–600 | `bonk` + `invalid` @180 | src and dst 600 |
| `HintShownEffect(move)` | `ui_hint_arrow` loop over the source at (cx, dollTop − 33·fs); the dashed arc (static path); `fx_select_glow` in → pulse on the target | — | — |
| `HintClearedEffect` | arrow removed; target glow out | — | — |
| `softStuck` (state) | `ui_booster_glow` loop behind Undo (HUD) and banner 3.4 (Flutter) | — | — |
| `ExtraSlotAddedEffect` | the bottom row re-pitches 0–300 (§9); `ui_extra_slot` loop at the new stand from 300 | `button` + `button` @0 | global 300 |
| `BoardResetEffect` | clips cancelled, reservations cleared, sprites rebuilt; no clip in M2 (an animated undo is M7 polish) | — | — |
| Level start, first level of a chapter (L21) | `ui_chapter_ribbon` 0–2600 over the HUD | — | — |

- **Combos.** `ComboTracker` (injected clock) raises the step when a completion's t0 is within 4000 ms of the previous one, up to 5 (tokens `motion.combo`). The step feeds `complete_{step}`.
- **Picked.** It needs no clip: tap-tap already lifted the doll, and a drag holds it.
- **Wobble snap.** A move started mid-wobble begins `doll_move` at rotation 0, a snap of up to 3°. Accepted for M2; M7 may settle it first (impact §E).
- **Hover.** The hover point scales with the target through `target_size`: the nest file's mover starts at −75 units = 0.5 × 150 in target space.
- **`doll_reveal`'s silhouette.** It stays drawn under the colour doll to the last frame, so the shadow (in both the silhouette and the body raster) would be doubled at the hand-off. Hide `doll_silhouette` (opacity 0 through a callback) from frame 12, the wipe's end, when the colour doll covers it. The re-export asks for `op 12`.

## 8. Locked and iced slots: paused compositions

- **Setup.** Each locked slot owns one `fxGlassUnlock` drawable, and each iced slot one `fxIce` drawable. They are created at board build and always drawn: they are the rest look, including the doll inside.
  - `NestComponent` draws no sprite for such a slot.
  - The ice badge is drawn above the composition (Flutter-free `TextPainter`, cached per value).
- **Z-order:** shelf layer (plank, stand, pips) → the composition → the ice badge → the FX layer. Hit areas don't change.
- **Placement:**
  - Glass: anchor (90,163) → (cx, `lockedDollBaseY`), which puts the case's top-left at `caseRect.topLeft − (47,40)·fs`.
  - Ice: anchor (90,170.8) → (cx, `surfaceY`), which puts the ice at `iceRect.topLeft − (42,40)·fs`.
  - Scale `fs`, and `doll_size = h/(150·fs)`.
- **Rest frames:**
  - Glass: frame 0, with `padlock_ping` hidden (`transformOpacity` → 0 while resting). At frame 0 that layer covers the unlock symbol with an opaque copy of the padlock, so the player couldn't see which colour opens the case (audit #3). While playing it follows the authored opacity.
  - Ice: frame `16 × BoardLayout.iceFrame(remaining, initial)`, i.e. 0, 16, 32 or 48 (D51). Each segment's first frame still shows the previous stage (audit #6).
- **Cached rest picture.** While paused, the slot records `drawable.draw` into a `ui.Picture` once and replays it each frame with `drawPicture`. That saves lottie's Dart-side traversal and allocations; the GPU still replays the padlock's small matte `saveLayer`.
  - Re-record when the rest frame, the layout or the rasters change.
  - Dispose it on unlock or shatter.
  - If profiling shows the matte matters, rasterize the rest frame cropped to the case box instead (≈0.44 MB per slot at DPR 3).
- **Stage mapping.** `iceFrame(n, n0) = min(3, ⌊3(n0 − n)/n0⌋)`, and the stage never jumps by 2.
  - An `IceCracked` that doesn't advance the stage (n0 ≥ 4) plays no clip, but its cue fires and the badge counts down.
  - `shatter` always starts at frame 48: its first frame flashes stage 3.
  - Authored ice is capped at 3 in the M5 editor (Q-default from impact §I.4).
- **Locked and iced together** (the codec allows it; the generator never makes it): the glass composition draws the doll, and the ice composition sets `hideDoll`. After the unlock, the ice composition draws it.
- **Iced towers:** the buried silhouettes are rest sprites under the ice composition. The tallest may poke above the ice (`TODO(design)`, BACKLOG "Design gaps").
- **Rule-3 fallback.** A composition that failed to load is drawn statically by `BoardSprites` (glass case frame, doll sprite at `lockedDollBaseY`, padlock symbol; ice frame and badge). The unlock or crack then plays as a frame swap.

## 9. Hand-coded gap motions (no file covers them)

Every one is a pure tween in the timeline lane, driven where possible by the files' own timing (`FxTiming`), and scaled by `durationScale`.

1. **Tower reveal drop (D21).** The top leaves at 0 (source), or the set flies at t0+700 (destination).
   - The revealed nest's silhouette drops from `buriedBaseY(1)` to the surface. Each deeper silhouette moves from `buriedBaseY(d)` to `buriedBaseY(d − 1)`, keeping its true size.
   - It takes 120 ms, easeIn (`FxTiming.revealDropMs`, `TODO(M7)` tune).
   - The "+N" tag counts down at the start. Then `doll_reveal` plays on the surface.
2. **11 dp settle after unlock.** The freed doll ends `fx_glass_unlock` on the case floor (caseTop + 123), 11 units above the stand surface.
   - A position callback on the `doll` null adds `(0, 11 · e((f − 42)/12))` over the final hop (frames 42–54, `FxTiming.unlockHop*`, `unlockSettleUnits`), with `e` = easeInOut. The file then ends on the surface, and the sprite takes over with no jump.
   - Frames 0–42 are a hold, so the callback isn't called there, which is fine: the offset is 0.
   - Fallback: a 120 ms post-clip drop of the sprite.
3. **Case, ice and silhouette shake on invalid.** Use `doll_invalid`'s `target` keyframes (`FxTiming.invalidShake*`: 0, −6, 6, −6, 6, −6, 0 at 2.4-frame steps from 10.8 to 25.2), piecewise linear, times `s`.
   - The offset goes to the slot composition (locked or iced target) or to every buried silhouette of a tower target (the top doll shakes in the file).
   - Removed under reduced motion.
4. **Drag cancel and drag invalid:** `doll_move` from the finger (§7). The finger's base is clamped to the board frame.
5. **300 ms re-pitch** (`BoardLayoutConstants.extraSlotRepitchMs`). The bottom row's stands, pips and dolls lerp from the old geometry to the new one, easeInOut, and so do every doll's heights if `dollHeightScale` changed.
   - Rest sprites resample during it. `doll_size` of any live clip follows.
   - `ui_extra_slot` starts pulsing when it ends.
   - A second +1 Slot while one re-pitches waits for it, then re-pitches from its end layout; the global lock covers both (PROGRESS D58, 2026-09-27).
6. **Tag and badge counts:** the "+N" tower tag at the reveal start; the ice badge at the crack or shatter start. Cached `TextPainter` per value.
7. **Coin count-up** on the win card: "+N" from 0 to the reward over 700–1300 ms, easeOut, `coins` @700 (`TODO(M7)` tune).

## 10. Hand-off rules and rule-3 fallbacks

1. **Same-frame swap.** In the `update` where the timeline starts a clip, the doll's sprite is hidden and the clip draws its first frame. In the `update` where it ends, the sprite is shown at the new rest pose and the clip returns to its pool. The timeline's `advance(dt)` runs before any `render`.
2. **Identical pixels.** Sprites and clips draw the same part rasters with the same transform and filter (§4), so a first or last frame equals the sprite. The known sources of a jump, and their fixes:
   - the E3 band: the hard split (D45);
   - the 11 dp glass float: §9.2;
   - the D21 drop: §9.1;
   - the reveal's double shadow: §7;
   - the wobble snap: accepted, M7;
   - resampling: a medium filter everywhere.
3. **Selected doll.** While selected, the doll is drawn by its `doll_pick` clip (wobbling, or held on `lift`'s end under reduced motion). Its sprite stays hidden until `settle` ends or a move takes over.
4. **Moves.** A move hands the doll from `doll_pick` to `doll_move` in the same frame. `doll_move` starts from the lifted pose (−14, ×1.05), which is `doll_pick`'s wobble pose at rotation 0.
5. **Nest.** The target's sprite is hidden while `doll_nest`/`doll_swallow` plays, because the file draws both dolls. At the end, one sprite (the merged nest's outer doll) shows at the target.
6. **Locked and iced slots:** §8. Their composition is the sprite.
7. **A file that failed to load** (`FxLibrary[id] == null`):
   - the clip is skipped, and the sprite jumps to the final rest pose at the clip's end time;
   - its cues still fire and its reservations still hold, so feel and gating are unchanged;
   - glass, ice, the toggle, the family counter and the ribbons have static Flutter/`BoardSprites` fallbacks, because for them the Lottie *is* the rest look (R10);
   - no error UI.

## 11. Gameplay bloc contract (frozen skeleton)

- **`GameplayBloc`** extends `BaseAsyncBloc<GameplayEvent, GameplayState>`, which handles events strictly FIFO. It is `@injectable` with (`LevelRepository`, `SolverService`, `RemoteConfigService`); the bloc lane adds `SaveService` and analytics.
  - It owns a nesty_core `GameSession`.
  - `GameplayStarted` is implemented: it takes the entry from `LevelRepository.entryAt(order)` and emits a `BoardResetEffect(start)`.
  - The other handlers are the bloc lane's.
- **Events:**
  - `GameplayStarted(levelNumber)`
  - `SlotTapped(id)`
  - `SlotDragStarted(id)`
  - `SlotDragDropped(id?)`
  - `UndoPressed`, `RestartPressed`, `HintPressed`, `ExtraSlotPressed`
  - `PauseChanged(paused)`
  - `SoftStuckCheckDue(moveSeq)`
  - `HintResultArrived(result?, moveSeq)`
  - `SoftStuckResultArrived(verdict?, moveSeq)`
- **State** (freezed):
  - `entry` (`LevelBundleEntry`: order, chapter, tier, version, reward, level), `board` (`GameState`), `selectedSlotId`
  - `status` (playing | won | outOfMoves), `paused`, `softStuck`, `hint`
  - `freeUndosLeft`, `hintsLeft`, `extraSlotsLeft`, `canUndo`, `canAddSlot`
  - `moveSeq`, `effectSeq`, `effect`
  - derived: `levelNumber`, `setsCompleted`, `totalSets`
- **Effects** (sealed, all `…Effect`, D52): `SelectionChangedEffect(previous?, selected?, byDrag)`, `MoveAppliedEffect(result: MoveApplied, byDrag)`, `MoveRejectedEffect(source, target, reason, byDrag)`, `BoardResetEffect(snapshot, reason start|restart|undo, undo?)`, `HintShownEffect(move)`, `HintClearedEffect`, `ExtraSlotAddedEffect(result: ExtraSlotAdded)`.
  - Every new effect bumps `effectSeq`. The page's `BlocListener(listenWhen: effectSeq changed)` calls `game.apply(effect, board)`.
- **Tap policy** (frame 2.6, D22):
  - Nothing selected, and `Rules.canPick` → select.
  - Nothing selected, and not pickable → ignored (`TODO(design)`: no frame).
  - Tap on the selected slot → cancel.
  - Tap on a legal target (`Rules.legalTargets`) → `session.move`.
  - Any other tap → `MoveRejectedEffect` with core's reason (from `Rules.tryMove`). The selection clears.
  - Drag: start selects; a drop on a slot is the same as a tap there (move or invalid); a drop on nothing cancels.
- **Hints and soft stuck** (`SolverService`, latest wins):
  - The bloc never awaits the solver inside `handleEvent`. The call is fired, and the result is re-added as an event with the `moveSeq` it was asked for; stale results are dropped.
  - A soft-stuck check is requested 300 ms after each applied move (the `SoftStuckCheckDue` debounce).
  - A hint with no move and verdict `unsolvable` → `softStuck` and no charge (D22). A null result uses `Solver.fallbackHint`.
- **Won and OutOfMoves** come from core's events. Input locks at once; the overlays open when the board reports the batch done (`onWon`, `onOutOfMoves`).

## 12. Localized text on Lottie (D44)

- **Hide the text layers.** `ui_family_counter`, `ui_win_ribbon` and `ui_chapter_ribbon` are drawn with `LottieDelegates(text: (_) => '')`. No characters means none of text_layer's per-character `TextPainter` layouts, which cost 0.4–2.3 ms per frame on the Mac.
- **Draw our own text.** `LottieFxView` paints the composition, then a cached `TextPainter` per label with the app's Fredoka 700.
  - It follows the null's transform, captured in the same paint by callbacks that return the authored value unchanged: position with `interpolatedKeyframeProgress`, scale with `linearKeyframeProgress` (§2 rule 5).
  - Captured values reset to the rest values below before each draw, because a hold skips the callback.
  - Lottie ignores a null's opacity for its children, so the text doesn't fade either.
- **Fit, don't wrap.** A label wider than its band's max width is laid out once more at `fontSize × maxWidth / width`. Flutter text also fixes Lottie's hard-coded LTR and its missing-glyph fallback.

| File | Null (rest) | Label (baseline centre, in null space) | Shadow | Size | Max width |
|---|---|---|---|---|---|
| ui_family_counter | `counter` (60,30), scale 1 → 1.22 at 6 f → 1 | (7, 4.6), cream `#FFF5E0`; old count until frame 6, then the new one | — | 13 | 52 (`TODO(design)`) |
| ui_win_ribbon | `ribbon` (180,55), scale 0.6 → 1.06 → 1 | (0, 10.08), white | (0, 12.08), `#96400A` at 35 % | 28 | 232 (band 260 − 2·14) |
| ui_chapter_ribbon | `ribbon` (180,50), moving to (180,42) from 138 f; scale as the win ribbon | (0, 7.2), white | (0, 9.2), `#1C4F82` at 35 % | 20 | 262 (band 290 − 2·14) |

- **Copy.** The strings come from ARB: `winTitle`, the chapter ribbon's "CHAPTER {n} · {name}", and the counter's "{done} / {total}", which uses tabular digits per Q29 when that is decided.

## 13. Reduced motion (D48)

The source is `MediaQuery.disableAnimationsOf(context)`. The page passes it into `NestyGame` and the timeline's `MotionSpec`.

- **One-shots:** every clip, tween, cue offset, stagger and delay runs at `durationScale` 0.5 (speed 2×). For example, the clack lands at 268 ms, complete's t0 at 333 and the unlocks at t0+350.
- **Shakes removed:** `doll_invalid`'s `target` null gets a static `(0,0)`. `fx_ice`'s `ice` null gets a static `(42,40)`. The hand-coded case, ice and silhouette shake is off.
- **No confetti** (`fx_confetti` is skipped) and **no wobble**: `doll_pick` holds `lift`'s last frame instead of looping `wobble`.
- **Ambient loops** paused on frame 0: `doll_idle`, `fx_twinkle`, `doll_win_hop`.
- **Informational loops at 1×:** `fx_select_glow` pulse, `ui_hint_arrow`, `ui_booster_glow`, `ui_extra_slot`, and in M3 `ui_spinner` and the tutorial hands.
- **Widget transitions** follow `tokens.motion.ui` × 0.5.

## 14. Pools and performance (rule 8)

- **Pools** (per `FxId`, created at board build, never per event):

| FxId | Pool |
|---|---|
| doll_pick | 2 |
| doll_move | 2 |
| doll_nest | 2 |
| doll_swallow | 2 |
| doll_complete | 2 |
| doll_invalid | 2 |
| doll_reveal | 2 (a source and a destination reveal in one batch) |
| fx_select_glow | 3 (selection, hint target, one fading out) |
| fx_dust_puff | 4 |
| fx_sparkle | 9 (a 60 ms cadence with 267 ms each: ≤ 5 live, plus margin) |
| ui_hint_arrow | 1 |
| ui_extra_slot | 2 |
| glass/ice | 1 per slot |

  - An exhausted pool skips the extra clip (rest pose) and logs in debug.
  - Two batches can overlap (a move while a completion flies), hence 2 per doll file.
- **Rule-8 exception (D42), inside lottie only:** a `Paint` per fill (`fill_content.dart`), a `LottieFrameInfo` per callback evaluation, two `Rect`s per image, and trim-path metrics (the spinner). Our position and scale callbacks return a new `Offset` (the API's return type).
- **Everything else is ours and allocation-free per frame:**
  - delegates built once per pooled drawable;
  - mutable `FxImageRequest` and clip state;
  - prebuilt `FxRaster`s;
  - cached rest `Picture`s (§8);
  - cached `TextPainter`s;
  - indexed loops in `update`/`render`.
- **Measured costs** (Mac, `flutter test`, relative only):

| Scenario | Cost |
|---|---|
| Complete + 9 sparkles + dust | ≈ 0.25 ms/frame |
| Win: 15–20 dancing dolls + confetti + ribbon with its text | ≈ 3 ms. Expect less with the text hidden (the ribbon text was 1.2–1.7 ms of it) and ≤ 8 hopping families; unmeasured |
| Paused glass | 21 µs |
| Paused ice | 9 µs |
| Cached picture | ≈ 0 |

- **Profiling** is the integrator's: Complete + sparkles + dust, and Win, on a 2 GB Android in profile mode (`/perf-profile`, R11 splash parse).
- **Memory:** §4. The shipped JSON is 302 KB (the 1.7 MB of placeholder PNGs stay in `design/`); the parsed compositions are small.

## 15. M2 vs M3

- **M2:**
  - all board clips: pick, move, nest, swallow, complete, invalid, reveal (towers from L16), select glow, dust, sparkle, hint arrow, extra slot;
  - `fx_glass_unlock` and `fx_ice`, built and tested on fixture boards. They come last in the Flame lane's order: M2's levels 1–30 have no locks (L31) or ice (L51);
  - `ui_family_counter`, `ui_booster_glow`, and the win overlay (`ui_win_ribbon`, `fx_confetti`, `doll_win_hop`, `fx_coin_burst`, `fx_twinkle`);
  - `ui_chapter_ribbon` (L21 opens ch02);
  - `ui_toggle` in **Pause** (3.9);
  - `ui_splash_loader`, `doll_idle` and `fx_twinkle` on **Splash** (1.1) and the **Home** hero (2.1).
- **M3:**
  - `ui_tap_hand` and `ui_drag_hand` (tutorial 1.3, 1.4, 1.6);
  - `ui_toggle` in **Settings** (8.1);
  - `ui_spinner` (skin downloading 7.5);
  - `fx_twinkle` on Chapter complete (4.6) and the Shop.
- **Unused:** `doll_win_dance` (D47; it stays in the bundle).
- **M7:** speed and feel tuning of every clip's playback speed and the §9 tweens (`TODO(M7)`), plus swapping in the designer's re-export (§18).

## 16. Lanes, files and stages

- **Stage B (parallel):** tools, render, FX runtime, timeline, services, bloc, UI.
  - The **bloc lane is Stage B's codegen owner**: the only one that runs `dart run build_runner build` in `apps/game`.
  - The **UI lane is Stage B's gen-l10n owner**. It adds every M2 ARB key up front, so later lanes don't need gen-l10n.
- **Stage C (parallel, after B):** Flame board, screens. The **screens lane is Stage C's codegen owner** (router).
- **Stage D:** the integrator.
- **Rules for everyone:**
  - A lane edits only its own files.
  - It lists its codegen needs (new injectable registrations, freezed types, routes, ARB keys) in its report.
  - It builds classes directly in unit tests.
  - It never hand-edits a generated file (`*.gen.dart`, `*.freezed.dart`, `di.config.dart`, `app_router.gr.dart`, `app_localizations*.dart`, `docs/TODO_INDEX.md`).

| Lane | Owns | Delivers |
|---|---|---|
| **Tools** | `tools/lib/src/assets/design_asset_sync.dart`, new `tools/lib/src/fx/**` and its bin entry, `tools/test/**`, `tools/README.md`, `apps/game/assets/lottie/**` (synced), `apps/game/lib/features/fx/fx_spec.gen.dart` (generated), the `assets:` list of `apps/game/pubspec.yaml` (add `assets/lottie/`; dependencies are frozen), `apps/game/test/core/assets/asset_manifest_test.dart`, `apps/game/test/features/fx/fx_spec_drift_test.dart`, `.github/workflows/ci.yaml` (drift step) | Sync `design/lottie/*.json` only: never `images/`, never LOTTIE.md. Validate on sync and on `--check`: parses; v5.7; `fr` 60; `ip` 0; w/h/op and markers equal the contract table; asset ids ⊆ `FxImageSlot`; named nulls and fills present; reject expressions (`x`), effects (`ef`), merge paths (`mm`), luma or inverted mattes (`tt` 3/4), `tp`, 3D, time remap, embedded images, text outside the 3 text files (block features, don't allow-list: trim paths and polystars are fine). Generate `fxSpecs` (+ `fxSpecOf`) with holds and image layers. The asset manifest test: 29 files ship, each parses with `LottieComposition.fromBytes`, no PNG ships; plus the BACKLOG `bundle.json` item |
| **Render** | `packages/nesty_render/lib/src/skin/{doll_part_rasters,skin_rasterizer,symbol_atlas}.dart`, new `lib/src/doll/part_raster_doll_renderer.dart`, `lib/src/doll/{placeholder_doll_painter,fallback_doll_renderer}.dart`, `lib/src/board/{board_geometry,board_sprites}.dart` (additive), `lib/nesty_render.dart`, `test/**` | Implement `DollPartRasters.prepare`/`preparePlaceholder` (§4), `PartRasterDollRenderer`, `BoardFit.toReference(x, y)` and the board-space origin, a crop-offset accessor on `BoardSpriteImage` for `FxRaster.origin`, and an ink-tinted symbol raster for `unlock_symbol` |
| **FX runtime** | `apps/game/lib/features/fx/**` except the frozen contracts and the gen file (it may drop `AppEnv.real` from `FakeFxLibrary`), `apps/game/test/features/fx/**` (additive) | `AssetFxLibrary` (real, `@LazySingleton(as: FxLibrary, env: [real])`), `fx_player.dart` (pure segment/loop/speed/clamp math), `fx_delegates.dart` (one builder per file from `FxSpec`: compensation §3, sizes and rim/tint §5, travel remap and hold fix §6, glass settle §9, padlock hide §8, reveal silhouette hide §7, reduced motion §13, text hide and capture §12), `lottie_fx_component.dart`, `lottie_fx_view.dart`, `fx_text_overlay.dart`, `fx_pool.dart` |
| **Timeline** | `apps/game/lib/features/gameplay/game/timeline/**`, `apps/game/test/features/gameplay/timeline/**` | `BoardTimeline` (pure: `schedule(effect, board)`, `advance(dtMs)`, clip descriptors and hand-coded tweens as data, reservations, `FeedbackSink` interface to audio and haptics, `ComboTracker` with an injected clock, `MotionSpec`). It imports only `fx_spec`/`fx_cue`/`fx_id`, nesty_core and nesty_render geometry |
| **Services** | `apps/game/lib/core/services/{audio,haptics,solver,skin,save}/**`, `apps/game/lib/core/repository/**`, `apps/game/lib/core/models/symbols_mode.dart`, their tests | `SoLoudAudioService` (`play(effect, dollSize:, comboStep:)`, clack rate, silent failure); token haptic patterns; `IsolateSolverService` (latest wins); `AssetSkinService` + `LevelSkin` + the `FxImageSource` implementation; `BundledLevelRepository` (`entryAt`, fake with 3 fixtures); the in-memory M2 save with the wallet; `SymbolsMode.large` reading legacy `assist`. Drop `AppEnv.real` from each replaced fake |
| **Bloc** (codegen owner B) | `apps/game/lib/features/gameplay/bloc/**` (state fields additive), `apps/game/test/features/gameplay/bloc/**` | Every handler of §11, `tap_policy.dart`, reward and save on Won |
| **UI** (gen-l10n owner B) | `apps/game/lib/core/ui/**` (except the generated tokens and icons), `apps/game/lib/core/common_imports.dart`, `apps/game/lib/l10n/app_en.arb`, `apps/game/lib/features/gameplay/widgets/**`, new `apps/game/lib/features/gameplay/overlays/**`, their tests | `AppTheme` and the tactile component set; the HUD, booster bar, soft-stuck banner, OOM sheet, pause dialog, win overlay and all-levels-done layouts, with a `Widget` slot where a Lottie goes (wired by the screens lane); the full M2 ARB key list (earlier design §2 plus the chapter-ribbon and counter strings) |
| **Flame board** (stage C) | `apps/game/lib/features/gameplay/game/{nesty_game.dart,components/**}`, `apps/game/test/features/gameplay/game/**` | `BoardComponent` (tap/drag → intents, hit test, clamped drag), `ShelfLayer`, `SlotComponent` (paused glass/ice with cached rest picture, badge), `NestComponent` (rest sprites via `LevelSkin.restRenderer`, silhouettes, tags), `FxLayer` (BoardFit transform, priorities, pools), `HintLayer`, `apply(effect, board)` via the timeline, `onFamilyLanded`/`onWon`/`onOutOfMoves` |
| **Screens** (codegen owner C) | `apps/game/lib/features/gameplay/pages/**`, `apps/game/lib/features/splash/**`, `apps/game/lib/features/home/**`, new `apps/game/lib/features/dev/**`, `apps/game/lib/core/router/app_router.dart`, their tests | `GameplayPage` (the bloc, `NestyGame` built once, `BlocListener` → `apply`, `SkinService.prepareForLevel`, reduced-motion flag, and the Lottie pieces into the UI lane's slots); Splash (`FxLibrary.load` + `SkinService.load` progress → `ui_splash_loader`, `doll_idle`, `fx_twinkle`); Home hero; the dev level picker; routes |
| **Integrator** (stage D) | shared generated files, `docs/PROGRESS.md`, `docs/BACKLOG.md`, `docs/TODO_INDEX.md` | `build_runner`, `gen-l10n`, `di_test` flips, `app_flow_test`, analyze (`--fatal-infos --fatal-warnings`), all suites, TODO index, builds, the perf profile checklist |

- **Order inside stage B:**
  - tools → the gen file (FX runtime and timeline use local fixture specs until it lands);
  - render → services (`AssetSkinService` needs `DollPartRasters`; its fake works at once);
  - FX runtime → Flame board and screens.
- **Glass and ice go last** in the Flame lane.

## 17. Test plan

- **Contracts (this stage, green):**
  - `test/features/fx/{fx_id,fx_spec,fx_image_source,fx_cue}_test.dart`: the 29 ids match `design/lottie`; the remap maths and holds; every `FxTiming` constant against the JSON; slots against the declared asset sizes.
  - `test/features/gameplay/bloc/{gameplay_bloc,board_effect}_test.dart`
  - `test/core/services/{solver,skin}/*`, `test/core/repository/*`, the DI graph
  - `nesty_render/test/skin/doll_part_rasters_test.dart`
- **Tools:** sync is idempotent; `--check` catches drift, a missing file, a forbidden feature and a wrong w/h/op/marker; the generator is byte-stable; the drift test (gen == JSON).
- **Render:**
  - lid alpha is 0 for y ≥ 400r, body alpha 0 for y < 400r;
  - parity with `SvgSkinRenderer` outside 388–412;
  - gold masks; the three symbol modes; the silhouette includes the shadow;
  - byte budgets;
  - `PartRasterDollRenderer` equals a `DollPartSet` draw;
  - `BoardFit.toReference` round-trips.
- **FX runtime:**
  - **Compensation equivalence:** for every image layer in §3's table, at 2–3 frames, a compensated 3× (and 0.586×) raster draws the same pixels as the declared-size raster (≥ 99 % within 8/255). This pins lottie 3.6.1's behaviour, including the swapped progress fields.
  - The hold fix: `doll_complete` at frames 5/30/41 draws at src.
  - The remap overshoot; the padlock hidden at rest; the ice rest frames 0/16/32/48; the glass settle ends on the surface; reveal's last frame equals the colour sprite.
  - `doll_size` for nest and swallow; text hidden and overlay placement; reduced-motion shake removal.
  - Pools never allocate after warm-up (the allocation test style of `hot_path_allocation_test.dart`).
  - Marker end clamp; a failed load is null; `blank` is 1×1.
- **Timeline** (fake sink, fake clock):
  - the §7 table exactly: clack @536.7, bonk @180, complete @666.7, dust and sparkles @1366.7 + 60k, counter @1916.7, unlock @1366.7 + 80k, won @max + 250;
  - reservations and the global lock;
  - reduced motion halves every time;
  - combo steps (4 s, max 5);
  - a failed-load clip still fires its cues.
- **Services:** the audio rate, step and settings gate; haptic sequences (fake async); the solver's latest wins and stale drop; the bundled repository skips invalid levels; the skin service falls back to the placeholder; symbols migration.
- **Bloc:** select, cancel, invalid (including a pickable wrong target), move, drag drop and cancel, undo counts, restart keeps extras, hint and stale hint, soft stuck set and cleared, extra slot ≤ 2, win reward, out of moves.
- **Flame board:** the hand-off golden (sprite vs `doll_pick` frame 0 and `doll_move` last frame, within 1/255 mean); hit tests; the drag clamp; paused compositions drawn from the cached picture.
- **Screens and UI:** widget tests with fakes (HUD, booster bar sizes and text scales, OOM sheet, win overlay, pause toggles, splash progress); `app_flow_test` PLAY → board → boosters → pause → Home.
- **Integrator:** analyze, all suites, the TODO index check, the APK/iOS/web builds, and the profile checklist on a device (owner).

## 18. Designer re-export and swap

[lottie-reexport-request.md](lottie-reexport-request.md) lists every point for the designer.

When a re-export arrives:
1. The owner drops it into `design/lottie/`.
2. The tools lane syncs, regenerates `fx_spec.gen.dart` and updates the contract table.
3. Each workaround whose cause is fixed is removed behind its test: compensation stays (it is exact for any raster), but the hold fix, the padlock hide, the settle ramp, the reveal silhouette hide and the animated-scale callbacks go if the file no longer needs them.
4. The equivalence tests must stay green.

BACKLOG tracks it as "Swap in the designer's Lottie re-export" (M7).
