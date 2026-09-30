# Lottie animations: Nesty: Doll Sort

## Changes

### m7-3 (2026-09-30, Claude Design)
Three new files and one fix; the other 31 are unchanged.
- **`ui_intro_towers`, `ui_intro_glass`, `ui_intro_ice` (new, D).** Looping animations for the intro cards 4.1–4.3, on the card's 302×230 illustration box, with no text layers. The plank and stands are shapes; dolls, the wood blank, glass case frames, the padlock symbol and ice frames are image slots, filled like the board's (the roles are in Image slots). Every scale and position change sits on a null; image layers only fade. The ice counter shows pips, not a number. Each loop ends on its first frame.
- **`ui_extra_slot` (E.21).** The pulse now starts and ends at the static pad's pose (100 % scale, 100 % opacity), with a `rest` marker at frame 0: 100 → 104 % (24) → 96 % (72) → 100 % (96), opacity 100 → 80 → 100. The hand-off from the static pad no longer pops, so the game can start at frame 0.

### m7-2 (2026-09-30, Claude Design)
Two new files; the other 30 are unchanged.
- **`ui_stars` (new).** The star rating on the win overlay (11.2, 11.3). Three empty stars at rest; segment `star_n` pops the n-th filled star in (scale 0 → 118 % → 100 % on its parent null, 20 f each) and `flourish` (60–120) adds a glow and six sparkles after the third. To show n stars, play 0 → 20·n and hold; for 3 stars go on through `flourish` and hold on 120. Canvas 240×110, star centers (64, 58), (120, 52), (176, 58), 44 dp; everything stays inside the canvas, including the 118 % pop and the glow.
- **`ui_chest` (new).** The milestone chest (10.3b, 10.3c), shared with the day-7 chest (5.6). `arrive` drops the closed chest in with a squash, `idle` breathes (loop), `wiggle` rocks it three times when Open is tapped, `open` swaps to the open chest with a flash, rays and a burst of coins and sparkles, and `open_idle` loops the rays. Canvas 200×200, chest base (100, 186), chest 130×108 dp.
- Both follow the rules: image layers never animate their transform (the pops sit on nulls), every PNG is at its declared size, no expressions, effects or mattes other than alpha.

### m7-1 (2026-09-30, Claude Design)
One new file; the 29 v3 files are unchanged.
- **`fx_glass_unlock_tall` (new).** The unlock for the tall glass case that holds a size-5 or size-6 doll (`board/glass-case-tall-*.svg`, tokens.json → `layout.board.glassCaseTall`). Built from `fx_glass_unlock` with the same 54 frames, timing, easing, padlock ping, flash, glints and 12 shards. The differences: the case is 93×152 dp at 100 % and the doll stands on the stand surface inside it (no plinth lift), so the freed doll hops from the surface to 16 dp up (frames 42–47) and lands back on it at 53. Every piece except the doll hangs from a new `case_size` null on the stand surface; set it and `doll_size` to the same value, h / 150 (94.7 % for size 6 on the tall preset, 89 % for size 5 on three shelves). Canvas 200×280; everything stays at least 3.9 dp inside it; no image layer animates its transform.
- **`fx_ice` on the tall preset.** Boards with size-6 dolls (`layout.boardPresets.threeShelvesTall`) use a 96×168 ice overlay. Play `fx_ice` there at scale (1, 1.05) from the ice bottom (anchor (90, 200) → the overlay's bottom centre); nothing else changes.

### v3 (2026-09-26, Claude Design)
Built from v2, which stays the baseline, with the owner's answers to the v2 questions. 17 files are byte-identical to v2 and 12 changed. File names, 60 fps, anchors and timings are unchanged except where listed.

- **Ribbons (`ui_win_ribbon`, `ui_chapter_ribbon`).** The canvas grows from 360 to 410 wide, so the ribbon centre (the anchor) moves to (205, 55) and (205, 50). Both bands are 336 wide. The tails reach 22 dp past the band with the full 12 dp notch, as in v1 and the Win screen mock. At the 106 % pop the ribbon spans ±201.4 dp, 3.6 dp inside the canvas. Heights, colours, timing and text layers are unchanged. At rest the ribbon is 380 dp wide, so on a 390 dp screen the tail tips pass the screen edge by up to 6 dp for about 100 ms during the pop.
- **`fx_ice`: `crack_hit_0` … `crack_hit_3`.** A hit that adds no crack: the crack shake and flash on the current stage, with no chips and no new image. The segments sit at 82–98, 99–115, 116–132 and 133–149 (16 f each), after the shatter with one empty frame, so `shatter` still ends on its own last frame at 81. Each has its own ice image layer (`ice_0_hit` … `ice_3_hit`, same assets as `ice_0` … `ice_3`) and flash (`crack_hit_flash_0` … `_3`); the shake runs on the `ice` null. Rest on `rest_n` afterwards. Length 81 → 150 f.
- **`fx_glass_unlock`.** The freed doll's hop is 42 → 47 (up to y 149) → 53 (lands at y 174), so frames 53–54 show it standing on the stand. Length stays 54 f.
- **No animated image transforms.** The lid lift of `target_lid` (`doll_nest`) and `mover_lid` (`doll_swallow`) moved to new parent nulls `target_lid_lift` and `mover_lid_lift`, and the hint arrow's bob moved to `arrow_bob`. These image layers now keep anchor, position, scale and rotation static, like every other image layer.
- **Inside the canvas at every frame.** v2 fixed the glass and ice debris. These files also drew outside their canvas: `fx_confetti` (up to 150 dp past the top and sides, and still visible below the bottom), `fx_coin_burst` (2.8 dp), `ui_tap_hand` (the ripple, 5.5 dp past the top), `ui_toggle` and `ui_splash_loader` (the `sunk` shade, 1.5 dp below). Confetti: upward travel runs through one smooth curve (short hops change little, the highest piece now peaks at the top margin, the order is kept), sideways travel past 40 % of the room eases into the rest, and each fall ends inside the canvas when its fade reaches 0 at frame 100. `coin_1` and `coin_8` travel ×0.84 and ×0.79 on their last segment. The tap ripple ends at 134.5 % instead of 160 %. The `sunk` shade is now an inner top shadow, as in the CSS (`inset 0 2px 3px`). Timing and easing are unchanged everywhere.
- **`images/doll_silhouette.png`** is now the wood-grain blank, `board/doll-silhouette.svg` at 512×768. Buried nests use that look (owner decision).
- **Confirmed as intended (owner):** the rim order in `doll_nest` and `doll_swallow`, and the `doll_reveal` wipe centre at art (256, 476). See "Doll size, rim and tint".
- **Checks.** Every file was sampled at 1/8-frame steps. Everything drawn stays at least 0.5 dp inside the canvas; `ui_toggle`, `ui_spinner` and `ui_splash_loader` touch their canvas edge exactly, because the canvas is the component box. No file uses a feature outside the allowed list, no image layer animates its transform, no `travel` or `drop` null has two equal consecutive keys, and every PNG in `images/` is exactly its declared size.

### v2 (2026-09-26, Claude Code re-export of v1)
- **Image sizes.** Every image asset is declared at the pixel size of the image that fills it, because lottie-flutter ignores the declared `w`/`h`. Board pieces are at 3×: `glass_case_0/1/2` 258×429, `ice_0…3` and `ice_shatter` 288×480, `glow_ring` 348×156, `hint_arrow` 120×150, `extra_slot` 270×102 and `unlock_symbol` 36×36. Their image layers are at 33.33 % with the anchor ×3, so nothing moves on screen. Dolls stay 512×768 at 19.53 %. The placeholder PNGs are exported at the declared sizes.
- **Static image transforms.** The pulse or burst scale of `glow_ring` (`fx_select_glow`), `extra_slot` (`ui_extra_slot`) and `ice_shatter` (`fx_ice`) moved to new parent nulls `glow_pulse`, `slot_pulse` and `shatter_burst`. The image layers keep their opacity animation.
- **No holds on `travel`.** `doll_complete` has keys only at 42 and 75. `ui_drag_hand` has no frame-0 key (it holds S until 21.6), and its key at 86.4 is nudged 0.5 px back along S→T to (299.5, 500). No two consecutive `travel` keys are equal.
- **`fx_glass_unlock`.** `padlock_ping` starts at frame 1, so the unlock symbol is visible at rest (frame 0). The freed doll lands on the stand surface at y 174 (case top + 134) instead of 163. Three shards fall or drift a little less far, with the same timing, so they stay inside the canvas.
- **`doll_reveal`.** A new `drop` null parents the whole doll and moves it from (0, −18) to (0, 0) over frames 0–7 (120 ms, easeOut). Everything else starts 7 frames later, so the file is now 31 frames. `doll_silhouette` ends at frame 19, when the wipe has covered the doll.
- **`fx_ice`.** New rest markers `rest_0` … `rest_3` (dr 0) at frames 0, 16, 32 and 48. Each one shows its crack stage fully cracked. The three flash layers are renamed `crack_flash_1/2/3`. Five chunks travel a little less far, with the same timing, so they stay inside the canvas. This includes `chunk_13`'s rise, which in v1 poked out of the top edge.
- **Ribbons.** Both bands 312 wide inside the 360 canvas. Superseded in v3.
- **This file.** It now counts 29 files, and the tables show the rest markers, the 3× sizes and the `drop` null. Trim paths and polystars are allowed. The travel sample compiles against lottie 3.6.1. The hint-arrow rest point and the rim order are documented.

---

For Claude Code. **Owner decision (2026-09-26): every animation in the design ships as Lottie.** This folder has 35 files (10 doll, 9 fx, 11 ui) that cover every animation in the flow (`prototypes/Nesty App Flow.dc.html`) and in `prototypes/Nesty Motion & Sound.dc.html`. Watch them all in `prototypes/Lottie FX.dc.html`. Timings come from `tokens.json` → `motion`. Sounds and haptics come from `tokens.json` → `sound` and `haptics`.

**Not Lottie:** widget transitions that wrap live content, such as button press, sheet in, modal in, tab lift and banners. They stay Flutter animations using `tokens.motion.ui`. Combo is sound-only. The dashed hint arc and the tutorial arc are static paths.

## Format
- Lottie 5.7 schema, 60 fps, transparent background. 1 canvas px = 1 dp at 390×844.
- Allowed features: shape, null, image, precomp and text layers, alpha track mattes, static trim paths (`ui_spinner`) and polystars (sparkle, twinkle, coin burst, glints). The shine, the reveal wipe, the padlock ping and the loader stripes use alpha mattes. Not used anywhere: expressions, effects, merge paths, luma mattes, layer styles, time remapping, 3D layers and blend modes.
- **Image layers.** Each image asset is declared at the pixel size of the image that fills it: lottie-flutter draws an image at its own pixel size and ignores `w`/`h`. An image layer never animates its transform (anchor, position, scale or rotation). A lift, bob, pulse, burst or shake is animated on a parent null (`target_lid_lift`, `mover_lid_lift`, `arrow_bob`, `glow_pulse`, `slot_pulse`, `shatter_burst`, `ice`, `doll`), while opacity stays on the image layer because opacity is not inherited through parenting.
- **Inside the canvas.** Everything drawn stays inside the canvas at every frame, including pops and flying debris, with at least 0.5 dp to spare. `ui_toggle`, `ui_spinner` and `ui_splash_loader` fill their canvas exactly, because the canvas is the component box.
- **Text layers** are previews only. The game hides them and draws localized text itself (see "Text layers").
- There are three kinds of file:
  - **In place.** The canvas surrounds one slot. Put the file's anchor point on the game point (table below). In Flame that is `Anchor(ax / w, ay / h)`.
  - **Board space** (390×844, placed over the board at 0,0): `doll_move`, `doll_complete`, `doll_invalid`, `ui_drag_hand`. A null named `travel` is authored between fixed points S and T. Remap it at runtime (see "Travel remap").
  - **Segmented.** Markers name the segments. Play one segment per event, and for the resting state pause on the file's `rest_*` marker where it has one (`fx_ice`), otherwise on a segment's first frame.

## Files
| File | Canvas | Anchor | Length | Segments |
|---|---|---|---|---|
| `doll_pick` | 160×260 | doll base (80, 230) | 41 f | `lift` 0–7, `wobble` 7–31 (loop), `settle` 31–41 |
| `doll_move` | board | travel S (100, 500) → T (300, 500) | 16 f | |
| `doll_nest` | 160×260 | target base (80, 230) | 24 f | |
| `doll_swallow` | 180×380 | small target base (90, 350) | 24 f | |
| `doll_complete` | board | travel S (100, 650) → T (195, 144) | 75 f | |
| `doll_invalid` | board | travel S (100, 500) → T (300, 500), `target_pos` (300, 500) | 36 f | |
| `doll_reveal` | 160×260 | doll base (80, 230); the `drop` null lowers the doll from (0, −18) to (0, 0) over 0–7 | 31 f | wipe 7–19 |
| `doll_idle` | 160×260 | doll base (80, 230) | 180 f, loop | |
| `doll_win_dance` | 160×260 | doll base (80, 230) | 84 f, loop | |
| `doll_win_hop` | 160×260 | doll base (80, 230) | 78 f, loop | |
| `fx_select_glow` | 140×80 | ring center (70, 40) = (slot cx, stand surface − 2) | 113 f | `in` 0–7, `pulse` 7–103 (loop), `out` 103–113 |
| `fx_glass_unlock` | 180×240 | case top-left at (47, 40); doll base (90, 163) at rest, landing on the stand surface (90, 174) = case top + 134 at frame 53 | 54 f | rest = frame 0 |
| `fx_glass_unlock_tall` | 200×280 | stand surface (100, 212) = the `case_size` null; at 100 % the case top-left is (53.5, 64) and the doll base rests on the surface, and lands there again at frame 53 | 54 f | rest = frame 0 |
| `fx_ice` | 180×240 | ice top-left at (42, 40); doll base (90, 170.8) | 150 f | `crack_1` 0–16, `crack_2` 16–32, `crack_3` 32–48, `shatter` 48–81; `crack_hit_0` 82–98, `crack_hit_1` 99–115, `crack_hit_2` 116–132, `crack_hit_3` 133–149; rest markers `rest_0` 0, `rest_1` 16, `rest_2` 32, `rest_3` 48 |
| `fx_dust_puff` | 160×80 | stand surface under the doll (80, 62) | 24 f | |
| `fx_sparkle` | 64×64 | center (32, 32) | 16 f | |
| `fx_confetti` | 390×844 | full screen; bursts from (195, 190) | 102 f | |
| `fx_coin_burst` | 160×140 | coin in the "+25" pill (80, 100) | 40 f | |
| `fx_twinkle` | 32×32 | center (16, 16) | 120 f, loop | |
| `ui_family_counter` | 120×60 | counter center (60, 30) = (195, 129) | 12 f | `bump` 0–12 |
| `ui_hint_arrow` | 60×80 | arrow center at rest (30, 45), placed at (slot cx, doll top − 33) | 54 f, loop | |
| `ui_extra_slot` | 110×50 | stand center (55, 25) | 96 f, loop | `rest` = frame 0 (matches the static pad) |
| `ui_booster_glow` | 130×110 | booster center (65, 55); draw it behind the button | 84 f, loop | |
| `ui_win_ribbon` | 410×110 | ribbon center (205, 55); band 336 wide | 18 f, then hold | |
| `ui_chapter_ribbon` | 410×100 | ribbon center (205, 50); band 336 wide | 156 f | |
| `ui_toggle` | 54×30 | toggle box | 22 f | `on` 0–11, `off` 11–22; rest off = 0, on = 11 |
| `ui_spinner` | 16×16 | center | 54 f, loop | |
| `ui_splash_loader` | 278×22 | bar box: top-left (0, 0) at (56, 690), left/right 56 | 100 f | frame = load progress % |
| `ui_tap_hand` | 128×144 | fingertip (48, 32) on the target | 72 f, loop | |
| `ui_drag_hand` | board | travel S (100, 500) → T (300, 500) | 144 f, loop | |
| `ui_stars` | 240×110 | stars centered at x 195, canvas top 176 on the win overlay (`layout.winStars`); star centers (64, 58), (120, 52), (176, 58) | 120 f | `star_1` 0–20, `star_2` 20–40, `star_3` 40–60, `flourish` 60–120; rest = frame 0 (three empty stars) |
| `ui_chest` | 200×200 | chest base (100, 186) on the card (`layout.chestCard`) | 410 f | `arrive` 0–36, `idle` 36–216 (loop), `wiggle` 216–245, `open` 245–290, `open_idle` 290–410 (loop) |
| `ui_intro_towers` | 302×230 | the intro card's illustration box (4.1) | 240 f, loop | `loop` 0–240 |
| `ui_intro_glass` | 302×230 | the intro card's illustration box (4.2) | 240 f, loop | `loop` 0–240 |
| `ui_intro_ice` | 302×230 | the intro card's illustration box (4.3) | 300 f, loop | `loop` 0–300 |

## When each one plays
Play events in `MoveEvent` order. The board timeline starts each file, and a Lottie never changes game state. Times are ms from the event.

| Event | Lottie | Sound | Haptic |
|---|---|---|---|
| Picked | `doll_pick` lift, then wobble loop; `fx_select_glow` in, then pulse | `pick` @0 | light |
| Deselected | `doll_pick` settle; `fx_select_glow` out | none | none |
| Placed | `doll_move` (dst = target base) | `whoosh` @0 | none |
| NestedInto | `doll_move` (dst = hover), then `doll_nest` or `doll_swallow` | `whoosh` @0, `clack_*` when the lid shuts (nest/swallow +270) | medium at the clack |
| Revealed | `doll_reveal`, once the moving top nest has lifted off | none (the move carries `whoosh`) | none |
| Completed | `doll_complete`; `fx_dust_puff` @700; `fx_sparkle` every 60 ms from 700 to 1250; `ui_family_counter` bump and a 1.5× `fx_sparkle` @1250 | `complete_{comboStep}` @0 | success @0 |
| Unlocked | `fx_glass_unlock` (`fx_glass_unlock_tall` for a size-5 or size-6 doll) | `unlock_glass` @0 | medium @0 |
| IceCracked | `fx_ice` segment `crack_n` (n = the stage it cracks to), then rest on `rest_n` | `ice_crack` @0 | light |
| IceCracked, no new stage | `fx_ice` segment `crack_hit_n` (n = the stage shown, 0–3), then rest on `rest_n`. For ice counters with more hits than stages (4 or more) | `ice_crack` @0 | light |
| IceShattered | `fx_ice` segment `shatter` | `ice_shatter` @0 | none |
| Invalid move | `doll_invalid` | `bonk` @180 | soft error @180 |
| Won | `doll_win_dance` on every board doll (120 ms stagger), `fx_confetti`, `ui_win_ribbon` | `win` @0 | success |
| Win overlay | `doll_win_hop` per plank family (150 ms stagger); `fx_coin_burst` @700 | `coins` @700 | none |
| Hint | `ui_hint_arrow` over the source; `fx_select_glow` on the target | none | none |
| Soft stuck | `ui_booster_glow` behind Undo | none | none |
| +1 Slot added | `ui_extra_slot` | `button` | selection |
| New chapter (4.7) | `ui_chapter_ribbon` | none | none |
| Splash, Home | `doll_idle` per shelf doll (speed 0.8–1.2, random phase); `fx_twinkle`; `ui_splash_loader` | none | none |
| Win, Chapter complete, Shop | `fx_twinkle` (2.0–2.4 s, random phase) | none | none |
| Settings / Pause toggle | `ui_toggle` on or off | `button` | selection |
| Skin downloading (7.5) | `ui_spinner` | none | none |
| Tutorial 1.3 / 1.4, 1.6 | `ui_tap_hand`, `ui_drag_hand` | none | none |
| Mechanic intro card (4.1–4.3) | `ui_intro_towers`, `ui_intro_glass` or `ui_intro_ice`, looping while the card is open. Reduce motion: frame 0, still | none | none |
| Win overlay with stars (11.2, 11.3) | `ui_stars` when the coin count-up ends (1,300 ms): `star_1` … `star_n` back to back, then `flourish` if n = 3. `fx_coin_burst` and `coins` keep @700. Reduce motion: the last frame of `star_n` at once | `star_n` at the start of each segment (reduce motion: the highest one only) | light per star, success after the flourish |
| Milestone or day-7 chest shown (10.3b, 5.6) | `ui_chest` `arrive`, then `idle` (loop) | none | none |
| Chest Open tapped | `ui_chest` `wiggle`, then `open`, then `open_idle` (loop); the content chips pop in 150 ms apart. Reduce motion: a 200 ms crossfade from `idle` to the last frame of `open`, no wiggle | `chest_wiggle` @0, `chest_open` @483 (segment `open`), `jingle_reward` @733 | medium @483 |
| Chest Collect (10.3d) | no Lottie: 6 `ui/sprites/coin_flight` fly to the coin pill (700 ms, 60 ms apart) and `hint_flight` to the Hint button (650 ms), whose badge bumps 1.3×. Reduce motion: no flights, the counts update | `coins` @0 | light as the hint lands |
| Race: the computer completes a family | none (the strip dot fills, `motion.rivalDot`) | `rival_complete` | none |

## Image slots
Every doll and board piece is an image slot. The game fills each one with its own raster through `LottieDelegates(image: (composition, asset) => …)`, keyed by `asset.id`. `images/*.png` are placeholders (Cherry classic doll and board art) so that the files also play standalone. Each one is exactly its asset's declared size.

| Asset id | What the game supplies |
|---|---|
| `doll_lid`, `mover_lid`, `target_lid` | The lid raster: `top_mask` (tinted), `face`, `top_detail` and `shine_top`, on the full 512×768 skin artboard |
| `doll_body`, `mover_body`, `target_body` | The body raster: `shadow`, `bottom_mask` (tinted), `bottom_detail`, `shine_bottom` and the belly symbol, on the full 512×768 artboard |
| `doll_silhouette` | The unpainted wood blank of a buried nest: `board/doll-silhouette.svg` at 512×768, the same for every skin (owner decision, 2026-09-26). The placeholder is that raster |
| `glow_ring`, `hint_arrow`, `extra_slot` | `board/*.svg` rasters at 3×: 348×156, 120×150 and 270×102 px (116×52, 40×50 and 90×34 dp) |
| `glass_case_0/1/2`, `unlock_symbol` | Glass case frames at 258×429 px (86×143 dp) and the unlock color's symbol in ink at 36×36 px (12×12 dp) |
| `glass_case_tall_0/1/2` | Tall glass case frames, `board/glass-case-tall-{0,1,2}.svg` at 279×456 px (93×152 dp at 100 %), in `fx_glass_unlock_tall` |
| `ice_0` … `ice_3`, `ice_shatter` | Ice frames at 288×480 px (96×160 dp) |
| `star_filled`, `star_empty` | `ui/stars/star_filled.svg`, `star_empty.svg` at 132×132 px (44 dp), in `ui_stars` |
| `star_glow` | `ui/stars/star_glow.svg` at 220×220 px (73 dp, 1.667 × the star), in `ui_stars` |
| `chest_closed`, `chest_open` | `ui/chest/chest_closed.svg`, `chest_open.svg` at 390×325 px (130×108 dp), in `ui_chest` |
| `mover`, `revealed` (lid and body) + `doll_silhouette` | `ui_intro_towers`: the top nest (any color), the doll revealed under it (another color), and the wood blank of the buried nest, at 512×768 |
| `family`, `family_2`, `freed` (lid and body) | `ui_intro_glass` and `ui_intro_ice`: the families that complete (their color is the padlock's symbol in glass), and the freed doll inside the case or ice, at 512×768 |
| `glass_case_0/1/2`, `unlock_symbol`, `ice_0`, `ice_1`, `ice_shatter` | the same rasters as the board files (258×429, 36×36, 288×480) |

Return every raster at exactly its asset's declared `w`×`h` in pixels, because lottie-flutter draws an image at its own pixel size. Board pieces are declared at 3× and their layers are at 33.33 % with the anchor ×3, so 3× art stays sharp and the on-screen size is the dp size above. Doll layers are 512×768 at 19.53 %.

## Doll size, rim and tint
- **Size:** every doll has a null named `<role>_size`, where role is `doll`, `mover` or `target`. At 100 % the doll is 150 dp tall (size 6 on a 3-shelf board). Override it with `ValueDelegate.transformScale(const ['doll_size'], value: Offset(k, k))`, where k = dollHeight / 150. In `doll_nest` and `doll_swallow`, `mover_size` sits inside `target_size`, so give it moverHeight / targetHeight. Lift, hop, shake and arc distances stay in absolute dp. Lid lift and squash follow the doll's size.
- **Case size:** `fx_glass_unlock_tall` also has a `case_size` null. Give it the same scale as `doll_size` (h / 150) with `ValueDelegate.transformScale(const ['case_size'], …)`, so the case, flash, shards, glints and padlock grow with the doll.
- **Hover points:** nest ends the move with the mover's base 0.50 × target height above the target base, and swallow uses 1.06 × target height.
- **Rim:** fills named `rim_tint` take `DollSwatch.rimColor`. In `doll_nest` and `doll_swallow` the drawing order, bottom to top, is: host rim (`target_rim` / `mover_rim`), guest doll, host body, host lid. This is intended (owner, 2026-09-26). The rim is the back lip of the opening and the host body is the front wall, which covers the guest's lower half, so only the rim's upper half shows. The hidden front half would be about 2 dp tall on a 150 dp doll. `generator/nesty-doll.js` draws one open doll on its own with the whole rim above the body; that is not the nesting order.
- **Reveal drop:** in `doll_reveal`, the `drop` null parents the whole doll and is authored from (0, −18) to (0, 0) over frames 0–7 (120 ms, easeOut). A buried nest sits 18 dp higher per depth, so override its start per tower with `ValueDelegate.transformPosition(const ['drop'], callback: …)`. The wipe starts at frame 7 and ends at 19, where `doll_silhouette` ends. The wipe is centred at art (256, 476), the doll's centre, 62 % down the artboard. This is intended (owner, 2026-09-26): it matches the approved prototype, the five splash drops start there, and the paint reaches the head and the base within the same 12 frames. From the belly (y 590) the head would be 560 art px away instead of 446 and would be painted last. `tokens.json` → `motion.reveal` now says so.
- **Tint:** fills named `tint` take `DollSwatch.base` in `doll_reveal`, and `#FFF3B0` or `#F5B418` in `fx_twinkle`. Use `ValueDelegate.color(const ['**', 'tint'], value: c)`.

## Travel remap
Board-space files move a `travel` null from S to T. At runtime, map its authored position onto the real points by projecting it on S→T, so that the authored easing and overshoot are kept:

```dart
// v is the authored travel position; s and t are the file's S and T.
Offset remapTravel(Offset v, Offset src, Offset dst, Offset s, Offset t) {
  final st = t - s;
  final u = ((v - s).dx * st.dx + (v - s).dy * st.dy) / st.distanceSquared;
  return src + (dst - src) * u;
}

LottieDelegates(
  image: (composition, asset) => dollRasters.forAsset(asset.id),
  values: [
    // package:lottie 3.6.1 does not export LottieFrameInfo, so the callback
    // stays an inline closure and Dart infers the type of `f`.
    ValueDelegate.transformPosition(const ['travel'],
        callback: (f) => remapTravel(
            Offset.lerp(f.startValue, f.endValue, f.interpolatedKeyframeProgress)!,
            src, dst, const Offset(100, 500), const Offset(300, 500))),
    ValueDelegate.transformScale(const ['doll_size'], value: Offset(k, k)),
  ],
)
```

lottie-flutter skips a position callback while two consecutive keyframes are equal. No `travel` or `drop` null has such a hold.

| File | src | dst |
|---|---|---|
| `doll_move` | source doll base | target base (Placed), or the hover point (nest, swallow) |
| `doll_complete` | doll base | family counter center + (0, 0.1 × dollHeight) |
| `doll_invalid` | source doll base | target base − 0.5 × target height; also set `target_pos` to the target base |
| `ui_drag_hand` | tap point on the big doll | target surface − 0.4 × target height |

## Text layers
`ui_family_counter`, `ui_win_ribbon` and `ui_chapter_ribbon` use Fredoka Bold text layers. Swap the text with `LottieDelegates(text: (initial) => …)`, keyed by the authored text:
- Family counter: `'1 / 4'` → the current count, `'2 / 4'` → the count after the bump. The two swap at the peak.
- Ribbons: `'Level Complete!'` and `'CHAPTER 4 · Snowy Cabin'` → the localized ARB strings. The game hides these text layers and draws its own localized text over the band. Both bands are 336 wide. Keep the text inside a 312 × 40 dp box (win) or a 312 × 32 dp box (chapter), centred on the ribbon anchor. That holds about 26 characters at Fredoka Bold 24 (win) and 20 (chapter); shrink the font for longer strings.

## Rendering contract
- At rest the board draws sprites. While a doll animation plays, hide that doll's sprite and let the Lottie draw it. The first and last frames match the rest pose.
- A locked or iced slot draws its `fx_glass_unlock` (or `fx_glass_unlock_tall`) / `fx_ice` composition paused on the rest frame (frame 0 for glass; for ice, `rest_n` for the stage shown, also after a `crack_hit_n`) the whole time. These files include the doll inside, so don't draw that sprite separately.

## Flutter and Flame
- **Packages:** `lottie` (widgets) and `flame_lottie` (board components). Neither is in spec §13.2, so write the rule-9 reason in `docs/PROGRESS.md` → Package reasons. Pin versions that resolve with the locked `flame` and Flutter 3.41.
- **Loading:** load each composition once at startup into an injectable `FxLibrary` (`@lazySingleton`). If a file fails to load, skip that animation and show the rest pose (rule 3).
- **Performance (rule 8):** pool components per file (sparkle 9, dust 4, dolls one per slot, others 2). Rasterize the doll layers once per skin, color and size, and reuse those images in every image delegate. No allocation per frame.
- **Reduced motion:** play everything at 2× speed (duration × 0.5), skip `fx_confetti`, and stop `doll_pick` on the last frame of `lift` instead of looping `wobble`.

## Asset pipeline
- Ship `design/lottie/*.json` and `design/lottie/images/` to `apps/game/assets/lottie/`. Extend `sync_design_assets` (folder list and `--check`), declare both folders in `apps/game/pubspec.yaml`, and extend `asset_manifest_test.dart`. When syncing, check that each JSON parses, `fr` is 60 and `w`/`h` match the table.
- `design/` is owner-managed. Don't edit these files. Tune speed with the controller duration, or ask the owner for a new export.
- Track the work in `docs/BACKLOG.md` under the milestone that builds `BoardTimeline` (M2), and add a PROGRESS decision entry for "all animations are Lottie".
