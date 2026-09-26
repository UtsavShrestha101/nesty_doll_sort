# Lottie analysis — audit (2026-09-26)

Read-only analysis of design/lottie/ against lottie 3.6.1 (probes run in a scratch project). Reference material for the M2 Lottie work; decisions live in docs/PROGRESS.md and docs/plans/m2-lottie-design.md.

**Lottie export audit: 29 JSON files checked against LOTTIE.md, with runtime behaviour probed in lottie 3.6.1**

The files are clean on every forbidden feature, but four problems will visibly break the game when played through the Flutter `lottie` package. Two of them (image sizing and the travel remap) I confirmed by running the files through lottie 3.6.1 in a scratch test; the glass-case findings come from the JSON and PNG pixels, and the draw order was also probed.

Sources: all files under `/Users/utsav/Downloads/nesty/export/nesty-lottie-only/design/lottie/`. Nothing under `/Users/utsav/Downloads/nesty` was modified.

## Clean on every file
- `v` 5.7.4, `fr` 60, `ddd` 0. `w`/`h` and length (`op − ip`) match the LOTTIE.md table for every file. Markers match exactly.
- None of these appear anywhere: expressions, effects, merge paths, layer styles, time remapping, 3D, repeaters, gradient fills or strokes, blend modes, auto-orient, stretch other than 1, hidden layers, masks, `tp`, embedded images (`e` is always 0).
- No NaN or null values; at most 2 decimal places. Track mattes are alpha only (`tt` 1), always directly under their matte layer.
- Two features are used that LOTTIE.md doesn't list: a static trim path in `ui_spinner` (0–25 %) and polystars (sparkle, twinkle, coin burst, glints).
- Fonts: `Fredoka` / `Fredoka-Bold` / `Bold`, no chars. The default text style resolves this to family Fredoka at weight 700, which `apps/game/pubspec.yaml` registers.
- All 15 PNGs are referenced and none are missing. Every asset id in the "Image slots" table is used and there are no extra ids.

## Per file
Easing names below refer to `tokens.motion.easing`.

| File | Bytes | Frames (ms) | Canvas | Markers | Image asset ids | Layers (depth) | Hooks, text, timing notes |
|---|---|---|---|---|---|---|---|
| doll_pick | 2073 | 41 (683) | 160×260 | lift 0+7, wobble 7+24, settle 31+10 | doll_lid, doll_body | 2 image, 2 null (2) | `doll_size`. Lift 7 f = 117 ms (token 120), −14 dp, ×1.05, easeOut. Wobble 24 f = 400 ms ✓ at ±3° ✓. Settle 10 f = 167 ms (token 160), easeOut. |
| doll_move | 2104 | 16 (267) | board | – | doll_lid, doll_body | 2 image, 4 null (4) | `travel` (100,500)→(300,500), easeOutBack, no holds. Arc −42 is on its own `arc` null (8 f up easeOut, 8 f down easeIn). Starts from the lifted pose (−14, ×1.05). 267 ms vs 260. |
| doll_nest | 4344 | 24 (400) | 160×260 | – | target_lid, target_body, mover_lid, mover_body | 4 image, 1 shape, 4 null (4) | `target_size`, `mover_size` (authored 89). `rim_tint` at `$.layers[4].shapes[1].it[1]` (target_rim). Lid lift 0–4.8 f (80 ms, −45 = 0.3h) → drop 4.8–12 f (120 ms, ×0.92, easeIn) → lid snap 12–16.2 f (70 ms) → squash 1.08/0.92 at 16.2–23.4 f (120 ms): 390 ✓. Clack at 270 ms ✓. Hover −75 = 0.5h ✓. |
| doll_swallow | 4193 | 24 (400) | 180×380 | – | same 4 ids | 4 image, 1 shape, 4 null (4) | `target_size` 89, `mover_size` 112.36. `rim_tint` at `$.layers[4].shapes[1].it[1]` (mover_rim). Hover −159 × 0.89 = 141.5 = 1.06h ✓. Same timings as nest. |
| doll_complete | 4197 | 75 (1250) | board | – | doll_lid, doll_body; precomp doll_matte | 3 image + precomp holding 2 image, 1 shape, 3 null (3) | `travel` (100,650), **held 0–42 f**, then → (195,144) with fly easing. Shine 0–18 f (300 ms) ✓. Hops 22 and 14 dp, 200 ms each ✓. Fly 42–75 f (550 ms) to ×0.2 and 24° ✓. Fade 72–75 f is 50 ms (M2 design says 80). |
| doll_invalid | 4092 | 36 (600) | board | – | mover_lid, mover_body, target_lid, target_body | 4 image, 7 null (4) | `travel` goes S → (200,500), i.e. u = 0.5, in 180 ms, then back by 480 ms, settle to 600. `arc` −30. `target_pos` static (300,500), `mover_size`, `target_size`. Shake 180–420 ms, 3 × 80 ms at ±6 ✓. |
| doll_reveal | 7459 | 24 (400) | 160×260 | – | doll_silhouette, doll_lid, doll_body; precomp color_doll | 3 image, 6 shape, 2 null, 1 precomp (2) | `doll_size`. `tint` ×5 at `$.layers[0..4].shapes[0].it[1]`. Wipe 12 f (200 ms) ✓, centred at art (256,476) = 62 %, not the belly (y 590). Drops last 16 f. |
| doll_idle | 1642 | 180 (3000) | 160×260 | – | doll_lid, doll_body | 2 image, 2 null | `doll_size`; bob 5 dp, −2° / +1.5°. |
| doll_win_dance | 1932 | 84 (1400) ✓ | 160×260 | – | doll_lid, doll_body | 4 | `doll_size`; hops 18 and 12 dp at ±6°, then 840 ms rest. |
| doll_win_hop | 1823 | 78 (1300) ✓ | 160×260 | – | doll_lid, doll_body | 4 | `doll_size`; hop 22 dp, landing squash ×0.92. |
| fx_select_glow | 1105 | 113 (1883) | 140×80 | in 0+7, pulse 7+96, out 103+10 | glow_ring | 1 image | Pulse 96 f = 1600 ms ✓. Ring centre (70,40) ✓. |
| fx_glass_unlock | 23029 | 54 (900) | 180×240 | – | glass_case_0, glass_case_1, glass_case_2, unlock_symbol, doll_lid, doll_body; precomp padlock | 17 shape, 7 image, 2 null, 1 precomp | `doll_size` (78). Case at (47,40) ✓, doll (90,163) = caseTop + 123 ✓, symbol centre (90,156) = caseTop + 116 ✓. Padlock pop 0–12 f (200 ms) ✓, frame 1 at 12 f (200 ms) ✓, frame 2 at 24 f (400 ms) ✓, shards 24–54 f (500 ms) ✓, hop 42–54 f. |
| fx_ice | 58125 | 81 (1350) | 180×240 | crack_1 0+16, crack_2 16+16, crack_3 32+16, shatter 48+33 | ice_0, ice_1, ice_2, ice_3, ice_shatter, doll_lid, doll_body | 45 shape, 7 image, 3 null; `crack_flash` name used 3 times | `doll_size` (78). `ice` null (42,40) ✓, doll (90,170.8) ✓. Crack shake 7 f = 117 ms at ±2 ✓. Shatter 49–67 f (300 ms, ×1.15) ✓. |
| fx_dust_puff | 10638 | 24 (400) ✓ | 160×80 | – | – | 9 shape | Origin (80,62) ✓. |
| fx_sparkle | 1706 | 16 (267) | 64×64 | – | – | 1 shape | Centre (32,32) ✓. |
| fx_confetti | 102514 | 102 (1700) ✓ | 390×844 | – | – | 48 shape (39 rect, 9 ellipse) | Burst from (195,190) ✓. 1171 keyframes, 8 colours, separate x/y position. All pieces faded by frame 100. M2 design says 46 pieces. |
| fx_coin_burst | 19426 | 40 (667) | 160×140 | – | – | 12 shape (8 coins, 4 sparkles) | Origin (80,100) ✓. |
| fx_twinkle | 1478 | 120 (2000) | 32×32 | – | – | 1 shape | `tint` ×2 at `$.layers[0].shapes[0].it[1]` and `$.layers[0].shapes[1].it[1]`, #FFF3B0. |
| ui_family_counter | 3997 | 12 (200) ✓ | 120×60 | bump 0+12 | – | 2 text, 3 shape, 1 null | Text '2 / 4' (count_new) and '1 / 4' (count_old), Fredoka-Bold 13; they swap at 6 f, the peak ✓. Bump ×1.22 ✓. Pill 70×26 at (60,30) ✓. |
| ui_hint_arrow | 583 | 54 (900) ✓ | 60×80 | – | hint_arrow | 1 image | Bounces 45→35 (10 dp, upward only). |
| ui_extra_slot | 740 | 96 (1600) | 110×50 | – | extra_slot | 1 image | Pulses ×0.96–1.04. |
| ui_booster_glow | 3460 | 84 (1400) ✓ | 130×110 | – | – | 4 shape | Ring 83×61. |
| ui_win_ribbon | 5120 | 18 (300) ✓ | 360×110 | – | – | 2 text, 3 shape, 1 null | 'Level Complete!' ×2, Fredoka-Bold 28. Scales 0.6→1.06→1. Band 260 wide. |
| ui_chapter_ribbon | 5431 | 156 (2600) | 360×100 | – | – | 2 text, 3 shape, 1 null | 'CHAPTER 4 · Snowy Cabin' ×2, size 20. In 300 ms, hold 2000 ms, out 300 ms. Band 290 wide. |
| ui_toggle | 2452 | 22 (367) | 54×30 | on 0+11, off 11+11 | – | 2 shape | 11 f = 183 ms (token 180), toggle easing ✓. |
| ui_spinner | 1524 | 54 (900) | 16×16 | – | – | 2 shape | Trim path, 360° per 900 ms. |
| ui_splash_loader | 11426 | 100 | 278×22 | – | – | 4 shape (stripes under a matte) | Fill grows 16→272. |
| ui_tap_hand | 7975 | 72 (1200) | 128×144 | – | – | 2 shape, 1 null | Fingertip is at the hand's local (0,0), placed at (48,32) ✓. |
| ui_drag_hand | 7168 | 144 (2400) | board | – | – | 1 shape, 1 null | `travel` **holds at S for 0–21.6 f and at T for 86.4–108 f**. |

**PNGs** (all 8-bit RGBA; 1.79 MB on disk, 8.21 MiB once decoded):

| PNG | Pixels | Declared asset size | What it shows |
|---|---|---|---|
| doll_lid, doll_body, doll_silhouette | 256×384 each | 512×768 | Cherry classic lid with face, red body with heart belly symbol, wood silhouette |
| glass_case_0/1/2 | 360×600 | 86×143 | Intact, cracked, and shattered case with open padlock |
| ice_0…3, ice_shatter | 360×600 | 96×160 | Ice block cracking in stages, then chunks |
| glow_ring | 360×160 | 116×52 | Gold ring |
| hint_arrow | 160×200 | 40×50 | Orange down arrow |
| extra_slot | 320×120 | 90×34 | Green "+1" stand |
| unlock_symbol | 24×24 | 12×12 | Red heart |

No PNG matches its declared size. The doll PNGs are half the 512×768 artboard. `extra_slot` and `glow_ring` are also scaled unevenly by up to 0.8 %.

**Coordinates**: every anchor in the table matches the layers. Glass and ice match `NestyBoard.dc.html`: case at ct = surf − 134 with the doll at ct + 123, and ice top at plankTop + 9 − 152.5, which puts the doll base 130.8 below it. The counter centre (60,30) maps to (195,129), and `doll_complete`'s T (195,144) is that plus 0.1 × 150 ✓.

## Problems, most severe first

1. **Image layers draw at the image's pixel size; the declared asset `w`/`h` is ignored.** In `lottie-3.6.1/lib/src/model/layer/image_layer.dart` the destination rect is `Rect.fromLTWH(0, 0, bitmap.width, bitmap.height)`.
   - Probe: the 256×384 placeholder in `doll_pick` drew over (30,85)–(80,160.1), half size, instead of (30,85)–(130,235).
   - Consequence: the game must supply every raster at exactly the declared size.
   - Doll rasters must be full 512×768 (1.5 MiB each). That conflicts with the M2 design's cropped per-DPR rasters and its 25 MB GPU budget.
   - Board pieces would be 1× rasters (86×143, 96×160, 116×52, 40×50, 90×34, 12×12 px), which will look blurry at DPR 2–3. That fails the "glass and ice look the same at rest" acceptance criterion.
   - When the delegate returns null, lottie falls back to the placeholder PNG, which renders at the wrong size (glass 4.19× too big, dolls 0.5×).
   - Fix options: the owner re-exports board pieces at 3× with a compensating layer scale (the way the dolls use 512×768 at 19.53 %). Or the game adds scale and anchor delegates, which only works where the image layer's scale and anchor are static: not `glow_ring`, `extra_slot` or `ice_shatter`.

2. **The travel remap is skipped whenever `travel` holds still.** In `path_keyframe_animation.dart`, when start == end, `getValue` returns `keyframe.startValue` before it ever calls the value callback. This also defeats static `value:` overrides.
   - Probe: in `doll_complete`, frames 0–41 made 0 callback calls and the doll sat at the authored (100,650), hopping to (100,631.1). At frame 43 it jumped to the real source (50.2,299.8). So the doll is drawn in the wrong place for the whole 700 ms shine and hops.
   - `ui_drag_hand` does the same during 0–21.6 f (raw S) and 86.4–108 f (raw T).
   - `doll_move` and `doll_invalid` are fine.
   - Fix options: re-export without equal-value travel segments. Or translate the canvas by (src − S) during the S-hold (and by (dst − T) during the T-hold), subtracting the same offset in the callback.

3. **At rest, the locked-slot composition hides the unlock colour's symbol.** In `fx_glass_unlock`, `padlock_ping` (`layers[16]`) is drawn above `unlock_symbol` (`layers[17]`). At frame 0 it is a copy of `glass_case_0` masked to a 32×44 rect at (43,108), at 100 % scale and opacity.
   - Probe draw order (bottom first) at frames 0, 6 and 11: [doll_body, doll_lid, glass_case_0, unlock_symbol, glass_case_0].
   - The padlock pixels over the symbol are fully opaque (alpha 255, cream).
   - LOTTIE.md says every locked slot pauses on frame 0, so the player can never see which colour unlocks the case. Opaque parts are unchanged, but the semi-transparent parts of the masked padlock area (mean alpha 178) are drawn twice and look denser.
   - Workaround: `ValueDelegate.opacity(['padlock_ping'], 0)` while resting. Better: a re-export.

4. **The unlocked doll lands 11 dp too high.** `fx_glass_unlock` ends with the doll at (90,163), which is caseTop + 123 = surface − 11. After unlock the sprite rests on the surface (the board draws locked dolls at ct + 123 and open ones at surf), so the doll jumps 11 dp at hand-off. `fx_ice` correctly ends on the surface.

5. **Unused placeholder images use 8.2 MiB of memory.** `AssetLottie.load` decodes every referenced PNG even when the delegate supplies the rasters. Loading with `LottieComposition.fromBytes` avoids this (it loads no images). The trade-off is a null fallback, which is safer than a mis-sized placeholder anyway.

6. **Ice segments: the rest frame is ambiguous and ice counters other than 3 aren't covered.**
   - Probe: frame 16 shows ice_1, 32 shows ice_2, 48 shows ice_3. So each segment's first frame still shows the previous stage.
   - "Pause on the current crack's segment start" read literally puts crack 1 back on frame 0, showing the uncracked ice_0. The correct rest after n cracks is frame 16n.
   - `IceCracked(remaining)` with a starting count n0 of 1, 2 or 4+ has no segment mapping (there is no crack_4). It needs the M2 formula min(3, ⌊3(n0 − n)/n0⌋) or an owner decision.

7. **Text sizing.**
   - The LOTTIE.md advice to "shrink with a textStyle delegate" doesn't work: `text_layer.dart` runs `textStyle.copyWith(fontSize: documentData.size)`. Use `ValueDelegate.textSize(['label'])` and `(['label_shadow'])`.
   - Measured with the bundled Fredoka-Bold: 'Level Complete!' at size 28 is 216 px in the 260 px win band, so about 18 characters fit, not 22. 'Level abgeschlossen!' is 281 px and overflows.
   - The chapter band is fine: the chapter string is 250 px of 290.

8. **`flame_lottie` 0.4.3+23 can't do what LOTTIE.md asks.** Progress is driven only by an `EffectController` over the whole composition, and the drawable is private. So there are no segments, no pause-on-frame, and no swapping delegates on pooled components. A small custom component over `LottieDrawable` is needed, with delegates whose callbacks read mutable parameters.

9. **The LOTTIE.md sample code doesn't compile.** `LottieFrameInfo` is not exported from `package:lottie/lottie.dart`; the probe failed with "Type 'LottieFrameInfo' not found". Use an inline closure so the type is inferred.

10. **Tower reveal starts with a jump.** `doll_reveal` starts with the silhouette at the base, at the revealed doll's own size. Under the owner override, buried silhouettes sit 18 dp × depth higher, and M2 has a 120 ms settle to true size. Expect an 18 dp jump unless the timeline settles the silhouette first.

11. **`doll_invalid` always draws a plain target doll.** Tapping a glass, ice or tower slot counts as an invalid move under the tap policy, but the Lottie would draw a bare doll over the case or ice, or shake the top doll without its silhouettes. This case is undocumented.

12. **The file count is 29, not 28** (10 doll, 8 fx, 11 ui). "28" appears in LOTTIE.md line 3, `lottie-integration.md` lines 8, 21, 59 and 69, and the viewer. An `FxId` enum or a "loads all 28" test would be off by one.

**Low:**
- **Frame-rate rounding.** The default `FrameRate.composition` rounds to whole frames, so reduced motion (2× speed) gives only 30 distinct frames per second. Also, lottie reports `durationFrames` as `op − 0.01`, so compute progress from markers, not frame/op.
- **Small timing deviations from 60 fps rounding (≤ 7 ms):** lift 117, settle 167, move 267 (so the clack lands at 537 ms, not 530), toggle 183, crack shake 117. Complete fades over 50 ms (M2: 80), settle uses easeOut (M2: easeIn), and confetti has 48 pieces (M2: 46).
- **Move arc shape.** The arc peaks at 133 ms, but the easeOutBack travel passes the target at 99 ms and overshoots to 1.098 at 153 ms, so the top of the arc is past the target. The arc is 42 dp above the straight S→T line, not "above the higher endpoint" as M2 says.
- **Snaps between segments.** `settle`, `out` and `doll_move` start from the rest or lifted pose, so there is a snap of up to 3° or 8 % scale when leaving a wobble or pulse mid-cycle. For drag drops, `src` must be the dragged position.
- **Rim layer order.** The rim is drawn beneath the body, while the design's `nesty-doll.js` draws it above, so only the upper half of the rim ellipse shows.
- **Clipped debris.** Shards and chunks leave the canvas (glass shard to y 257, ice chunk to y 263, canvas 240 tall) and the root composition clips them.
- **Viewer anchors differ from the table** for `fx_glass_unlock` [90,111], `fx_ice` [90,120] and `ui_splash_loader` [0,11].
- **Duplicate layer name** `crack_flash` in `fx_ice`.
- **Undocumented hint-arrow placement.** LOTTIE.md doesn't say where the arrow's rest point goes. To match M2, put (30,45) at (cx, dollTop − 33).
- **Validator.** Trim paths and polystars are used, so the sync validator should block specific features rather than allow a fixed list.

**Environment note:** the scratchpad already held another agent's probe in `lottie_probe/`. I accidentally overwrote its `pubspec.yaml`, then restored it with lottie 3.6.1, flame 1.38.2 and flame_lottie 0.4.3+23 and re-ran `pub get`. The original file content is lost, so tell that agent in case its probe behaves differently. My own probe is in a separate folder.

Files are in `/private/tmp/claude-501/-Users-utsav-Downloads-nesty/8a802507-1fb1-4775-b441-329bc52e16e7/scratchpad/`:
- `audit.py`
- `report.json`
- `anim_dump.txt`
- `sheet.png`
- `lottie_audit_probe_x7/test/probe_test.dart`
- `lottie_audit_probe_x7/test/probe2_test.dart`