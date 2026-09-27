> Source: the prompt the owner pasted into Claude Design with `nesty-lottie-v2.zip` on 2026-09-26 (`~/Downloads/nesty-for-claude-design/PROMPT.md`), verbatim below. Claude Design's reply is the v3 export: [claude-design-v3-changes.md](claude-design-v3-changes.md).

# Paste into your Nesty Claude Design project (attach nesty-lottie-v2.zip)

```
Context: Claude Code has imported your Nesty exports (the design handoff, the Lottie animations and the audio). When your Lottie files were played in the game's player (the Flutter "lottie" package 3.6.1, not lottie-web), a few things broke, so Claude Code produced a corrected v2 of the 29 Lottie files. It's attached as nesty-lottie-v2.zip (design/lottie/*.json, design/lottie/images/*.png, design/lottie/LOTTIE.md v2, design/prototypes/Lottie FX.dc.html, and CHANGES.md with every change). Every file was checked against v1: only the intended changes differ.

1) Adopt v2 as your baseline. Use the attached files as the source for all 29 animations from now on, so future exports keep these fixes. In short, v2:
- declares every board-piece image at 3× its on-screen size (glass case 258×429, ice 288×480, glow ring 348×156, hint arrow 120×150, extra slot 270×102, unlock symbol 36×36) with the image layer at 33.33% scale and its anchor ×3; doll art stays 512×768 at 19.53%;
- moves animated scale/position off image layers onto parent nulls (glow_pulse, slot_pulse, shatter_burst);
- removes held (equal) keyframes on the "travel" nulls in doll_complete and ui_drag_hand;
- fx_glass_unlock: the padlock ping starts at frame 1 (so the unlock colour's symbol is visible at rest) and the freed doll lands on the stand (y 174);
- doll_reveal: a new "drop" null lowers the doll 18 px over the first 7 frames, then the wipe runs (length 24 → 31 frames); the silhouette ends when the wipe finishes;
- fx_ice: rest markers rest_0…rest_3, flash layers renamed crack_flash_1/2/3;
- all flying shards and ice chunks stay inside the canvas;
- ribbon bands widened to 312;
- placeholder PNGs at exactly their declared sizes;
- LOTTIE.md v2 (29 files, corrected code sample, allowed features, the new sizes and markers).

2) Rules for every Lottie file from now on:
- Declare each image asset at the exact pixel size of its PNG, and ship the placeholder PNG at that size. Board art at 3× with a 33.33% layer scale; doll art 512×768.
- Never animate an image layer's transform. Put scale/position/rotation animation on a parent null (opacity may stay on the image layer).
- No two consecutive keyframes with the same value on any "travel" or "drop" null. To hold, start the keyframes where the motion starts.
- Everything drawn stays inside the canvas at every frame, including scale "pop" peaks and flying debris.
- Allowed: shape, null, image, precomp and text layers, alpha track mattes, static trim paths, polystars. Not allowed: expressions, effects, merge paths, luma mattes, layer styles, time remapping, 3D, blend modes.
- Text layers are preview-only: the game hides them and draws localized text itself. Leave room for about 26 characters (German/Portuguese).
- Keep file names, layer/null names, markers and anchors exactly as LOTTIE.md documents. If timing or anchors change, update LOTTIE.md's table in the same export. 60 fps.

3) Please redesign or decide:
a. Win and chapter ribbons: the band must fit about 26 characters. In v2 the band is 312 wide inside the 360 canvas, which makes the folded tails stubby (13 px). Redesign so a 330–340 band keeps proper tails and the whole ribbon, including the 106% pop, stays inside the canvas: enlarge the canvas (and update the anchor in LOTTIE.md) or add a null named band_stretch that the game can scale horizontally.
b. fx_ice: add a stage-less "crack_hit" segment for each ice stage (shake + flash with no new crack image), so ice counters of 4 or more can show a hit.
c. Confirm: in doll_nest and doll_swallow the interior rim is drawn under the host body, so only its upper half shows. Intended?
d. Confirm: the doll_reveal paint wipe grows from art (256, 476). The spec says "from the belly" (about y 590). Which one?
e. Buried tower nests: v2's placeholder uses the tinted doll silhouette (skins/classic/renders/silhouette.svg); v1 used the wood-grain blank (board/doll-silhouette.svg). Which look should buried nests have in the game?
f. fx_glass_unlock: the landing key sits on the very last frame, so the last drawn frame shows the doll 1.45 px above the stand. End the landing one frame earlier (keep the 54-frame length).

4) Audio (from your audio export), please fix:
- AUDIO.md levels vs measured: jingle_chapter −19.1 dBFS RMS and −0.74 dBTP true peak; jingle_reward −21.3 RMS; jingle_oom −17.9 RMS and −0.99 dBTP. Either re-render the jingles to about −17 RMS with true peaks at or below −1 dBTP, or correct AUDIO.md.
- Nesty Soundtrack.dc.html synthesizes everything live. Make it also play the shipped .ogg/.wav files, so what we hear there is exactly what ships. Default music volume 0.5 (the token), not 0.6. It also needs support.js next to it: include it or note it.
- design/README.md says "28 Lottie files": it is 29.

5) Send back: the updated files in the same folder structure (design/lottie/…, design/audio/… if anything changed, design/README.md, design/tokens.json if anything changed), plus a short list of which points you changed and your answers to 3c, 3d and 3e.
```
