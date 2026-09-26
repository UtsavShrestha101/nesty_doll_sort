# Lottie re-export request — Nesty: Doll Sort

To the designer, from the game team (2026-09-26). About `design/lottie/` (29 files), played in the app by the Flutter `lottie` package 3.6.1.

**Nothing here blocks us.** Every point below already has a workaround in the game code, so the current export ships as it is (PROGRESS D43). A re-export lets us delete workarounds and makes the files play correctly outside our code, including in the Flutter preview. Where a point is marked *optional*, it is polish.

## How lottie-flutter differs from the web viewer

- **Image size.** `Lottie FX.dc.html` uses lottie-web, which stretches an image to the asset's declared `w`/`h`. lottie-flutter ignores `w`/`h` and draws the image at its own pixel size. That is why the placeholder PNGs look right in the viewer and wrong in the app: every PNG is a different size from its declared asset.
- **Holds.** When two consecutive keyframes of a position have the same value (a hold), lottie-flutter skips our runtime override of that position.
- **Clipping.** Everything outside a file's canvas is clipped.

## For every file

1. **Declare each image asset at the pixel size of the image that fills it, and compensate with the layer's scale.**
   - **Dolls:** keep 512×768 and the 19.53 % layer scale, but make the placeholder PNGs 512×768. Today they are 256×384.
   - **Board pieces, at 3×:**

     | Asset | Declared size |
     |---|---|
     | `glass_case_0/1/2` | 258×429 |
     | `ice_0…3`, `ice_shatter` | 288×480 |
     | `glow_ring` | 348×156 |
     | `hint_arrow` | 120×150 |
     | `extra_slot` | 270×102 |
     | `unlock_symbol` | 36×36 |

     Each with its image layer at 33.33 % scale and its anchor ×3, so the on-screen size is unchanged. This keeps board art sharp on 3× phones.
2. **Ship placeholder PNGs at exactly the declared sizes.** Today they are 256×384, 360×600, 360×160, 160×200, 320×120 and 24×24, all different from their declared sizes. The game never uses them, but the files should play correctly standalone.
3. **Keep image layers' transforms static.** Where an image pulses or bursts, put the animated scale on a parent null (for example `glow_pulse`), not on the image layer.
   - Affected: `glow_ring` (fx_select_glow), `extra_slot` (ui_extra_slot), `ice_shatter` (fx_ice).
4. **No two consecutive keyframes with the same value on a `travel` null.** A hold there stops the game from moving the doll to its real slot. Either start the keyframes where the motion starts, or nudge a held key by 0.5 px along the path.

## Per file

| File | Change | Why |
|---|---|---|
| `doll_complete` | Remove `travel`'s frame-0 key, so its keys are only at 42 and 75. Before 42 it then simply rests at S. *Optional:* fade over the last 5 frames (80 ms, the spec) instead of 3 | The 0–42 hold made the shine and hops draw at the authored point, not on the real slot |
| `ui_drag_hand` | Same for `travel`: no equal keys at 0–21.6 and 86.4–108. Nudge the held keys, or split the out and back moves over two nulls | Same hold problem |
| `fx_glass_unlock` | (a) Hide `padlock_ping` at rest: start the layer at frame 1, or opacity 0 at frame 0. (b) End the freed doll on the stand surface: `doll` null last key y **174** (case top + 134), not 163. (c) Keep flying shards inside the canvas (a shard reaches y 257 of 240), or make the canvas taller and keep the anchors | (a) At frame 0, the resting look of every locked slot, the ping covers the unlock colour's symbol, so the player can't see which family opens the case. (b) The doll floats 11 dp above the stand when the animation ends. (c) Anything outside the canvas is cut off |
| `doll_reveal` | (a) Add a named null `drop` that lowers the whole doll from (0, −18) to (0, 0) over the first 7 frames (120 ms) before the wipe starts. We override its offset per tower. (b) End the `doll_silhouette` layer when the wipe has covered the doll (the wipe's last frame). (c) Confirm the wipe centre at art (256, 476) is intended; the spec says "from the belly" (y 590) | (a) Buried nests sit 18 dp higher per depth at their true size (owner rule). Today the revealed nest jumps down 18 dp when the file starts. (b) The silhouette and the coloured doll both carry the ground shadow, so it is drawn twice at the end |
| `fx_ice` | (a) Add rest markers `rest_0` … `rest_3` on frames that show each stage fully cracked, not the previous one. (b) Add a stage-less `crack_hit` segment (the shake and flash without a new frame), used when the ice counter drops without reaching a new stage (counters of 4 or more). (c) Rename the three `crack_flash` layers `crack_flash_1/2/3`. (d) Keep ice chunks inside the canvas (a chunk reaches y 263 of 240) | (a) Each crack segment's first frame still shows the previous stage, so resting on it is ambiguous. (b) Only counters of exactly 3 are covered today. (c) Duplicate names make runtime overrides ambiguous |
| `doll_nest`, `doll_swallow` | Draw the `target_rim` / `mover_rim` above the body and below the lid, as `design/generator/nesty-doll.js` does. Or tell us the current order (rim under the body, so only its upper half shows) is intended | The two references disagree |
| `ui_win_ribbon`, `ui_chapter_ribbon` | Make the bands fit about 26 characters at the authored size (win band 260 → about 330, chapter band 290 → about 340), or give the band a named null we can stretch. The text layers can then go: we hide them and draw localized text ourselves | "Level Complete!" at 28 is 216 of 260; German "Level abgeschlossen!" is 281 and overflows. Text layers are also slow to draw on phones |
| `ui_family_counter` | *Optional:* the text layers can go (we draw the count ourselves). Keep the `counter` null | Same cost reason; the counter must use tabular digits |
| `fx_select_glow`, `ui_extra_slot` | Point 3: move the pulse scale onto a parent null | See point 3 |
| `ui_hint_arrow` | *Optional:* note in LOTTIE.md where the rest point (30, 45) goes. We use (slot centre, doll top − 33) | It isn't documented |

## LOTTIE.md

- **File count:** "28 files" → **29** (10 doll, 8 fx, 11 ui). The folder and the table already have 29.
- **Viewer anchors:** they differ from the table for `fx_glass_unlock` [90,111], `fx_ice` [90,120] and `ui_splash_loader` [0,11]. Align one or the other.
- **Features list:** the files use a static trim path (`ui_spinner`) and polystars (sparkle, twinkle, coin burst, glints). Both are fine; add them to the allowed list.
- **Text sizing:** "shrink the font with a `textStyle` delegate" doesn't work in lottie-flutter. Drop the sentence; we draw our own text.
- **Code sample:** the `remapTravel` sample doesn't compile, because `LottieFrameInfo` isn't exported. Replace it with an inline closure.

## When you send it

- Drop the files into `design/lottie/`, same names and the same 60 fps.
- Tell us which of the points above are done.
- We re-sync, regenerate the specs and remove the matching workarounds. Our tests check that everything still lines up with the board.
