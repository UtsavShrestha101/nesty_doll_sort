> Source: Claude Design's `CHANGES.md` from the v3 export (`export/nesty-v3/`, the owner's `Nesty_ Doll Sort Mobile Design (5).zip`), imported into `design/` on 2026-09-27; verbatim below.

# Nesty design v3: Lottie, audio and docs (2026-09-26)

From Claude Design, in reply to `PROMPT.md` (Lottie v2 review). Unzip at the repo root: it only adds or replaces the files listed at the end.

## What changed, by point

**1. v2 is the baseline.** All 29 files start from `nesty-lottie-v2.zip`. 17 are byte-identical to v2, and 12 changed for the points below. `LOTTIE.md` keeps the v2 notes under "Changes → v2" and adds a v3 section.

**2. Rules.** Every file now follows them, including some that v2 didn't touch:
- No image layer animates its transform. v2 still animated position on `target_lid` (`doll_nest`), `mover_lid` (`doll_swallow`) and `hint_arrow` (`ui_hint_arrow`). Those moved to new parent nulls `target_lid_lift`, `mover_lid_lift` and `arrow_bob`, so the result on screen is unchanged.
- Everything stays inside the canvas at every frame. Besides v2's glass and ice debris, these drew outside: `fx_confetti` (up to 150 dp past the top and sides, and still visible below the bottom), `fx_coin_burst` (2.8 dp), `ui_tap_hand` (ripple, 5.5 dp past the top), and the `sunk` shade of `ui_toggle` and `ui_splash_loader` (1.5 dp below). Fixes: confetti travel is eased into the room it has and each fall ends inside when its fade reaches 0; two coins travel a little less; the ripple ends at 134.5 % instead of 160 %; the `sunk` shade is now an inner top shadow, as in the CSS. Timing and easing are unchanged.
- Checked for all 29 files at 1/8-frame steps: at least 0.5 dp inside the canvas (the box-filling `ui_toggle`, `ui_spinner` and `ui_splash_loader` touch their edge exactly), no feature outside the allowed list, no equal consecutive keys on `travel` or `drop`, and every PNG exactly its declared size.

**3a. Ribbons (changed).** Both canvases grow from 360 to 410 wide, so the anchor (ribbon centre) moves to (205, 55) for `ui_win_ribbon` and (205, 50) for `ui_chapter_ribbon`. `LOTTIE.md` has the new sizes and anchors. Both bands are 336 wide; the tails reach 22 dp past the band with the full 12 dp notch, as in v1. At the 106 % pop the ribbon spans ±201.4 dp, 3.6 dp inside the canvas. Text box for the game's own text: 312 × 40 dp (win) and 312 × 32 dp (chapter), centred on the anchor, about 26 characters at Fredoka Bold 24 and 20. Note: at rest the ribbon is 380 dp wide, so on a 390 dp screen the tail tips pass the screen edge by up to 6 dp for about 100 ms during the pop. I chose the wider canvas over a `band_stretch` null, because stretching the band would also stretch the tails or need two more delegates.

**3b. `fx_ice` `crack_hit` (changed).** New segments `crack_hit_0` 82–98, `crack_hit_1` 99–115, `crack_hit_2` 116–132 and `crack_hit_3` 133–149 (16 f each). Each plays the crack shake and flash on its stage, with no chips and no new crack image, then rests on `rest_n`. They come after `shatter` with one empty frame, so `shatter` still ends on frame 81. New layers: `ice_0_hit` … `ice_3_hit` (same image assets as `ice_0` … `ice_3`) and `crack_hit_flash_0` … `_3`. Length 81 → 150 f. `LOTTIE.md` adds an event row for hits that add no crack.

**3f. `fx_glass_unlock` landing (changed).** The hop is now 42 → 47 (up to y 149) → 53 (lands at y 174), so frames 53–54 show the doll standing on the stand. Length stays 54 f.

**4. Audio (changed).**
- The three jingles were re-rendered, not re-labelled. The first render capped the sample peak at −1 dBFS before it reached −17 RMS. Now a look-ahead true-peak limiter runs first (4 ms ramp, 120 ms release, ceiling −1.8 dBTP before encoding), then OGG Vorbis q4. Measured on the decoded files: `jingle_chapter` −17.0 dBFS RMS / −1.6 dBTP, `jingle_reward` −17.0 / −1.3, `jingle_oom` −17.0 / −1.6. Music, notes and lengths are unchanged. The loops were already right (−20.7 and −20.4 RMS, −1.2 and −3.9 dBTP), and `AUDIO.md` now lists all five measured levels and how they're measured.
- `generator/nesty-music.js` has the same mastering, so a re-render gives the same levels. It also gains `NestyMusic.measure(buffer)`. Its live volume defaults to 0.5.
- `Nesty Soundtrack.dc.html` plays the shipped files by default: loops, jingles, the 17 WAVs, and the clack by size at the game's playback rate. A "Live synth" switch keeps stem muting and WAV renders. The music volume defaults to 0.5 and jingles use the SFX bus. `support.js` is included next to it; every `.dc.html` page needs it in the same folder.
- `README.md`: 28 → 29 Lottie files, plus notes on `support.js`, buried nests and the reveal wipe.

## Answers

**3c. Rim under the host body in `doll_nest` / `doll_swallow`: intended.** The order, bottom to top, is host rim, guest, host body, host lid. The rim is the back lip of the opening and the host body is the front wall, which covers the guest's lower half. The front half of the rim that it hides is about 2 dp tall on a 150 dp doll. The generator draws one open doll with the full rim above the body; that is a different case. No change.

**3d. `doll_reveal` wipe: keep art (256, 476).** It matches the approved Motion & Sound prototype, which grows the circle from 50 % / 62 % of the doll. The five splash drops start around there, and the paint reaches the head and the base within the same 12 frames. From the belly (y 590) the head would be 560 art px away instead of 446, so it would be painted last in the same 200 ms. The spec wording was the thing to fix: `tokens.json` → `motion.reveal.type` now says "from the doll's centre (art 256, 476)".

**3e. Buried nests: the wood-grain blank, `board/doll-silhouette.svg`.** That is what the board and Motion & Sound prototypes show. The tinted skin silhouette keeps the face disc and details, so it reads as a painted tan doll rather than a hidden one. Use the same blank for every skin. `images/doll_silhouette.png` is now that blank at 512×768, and README step 5, the Tower line and `tokens.json` → `board.towerSilhouettes` say so. `skins/classic/renders/silhouette.svg` is a reference only.

## Files in this zip
```
design/lottie/*.json               29 files (12 changed, 17 identical to v2)
design/lottie/images/*.png         15 placeholders (doll_silhouette.png replaced)
design/lottie/LOTTIE.md            v3
design/audio/jingle_chapter.ogg, jingle_reward.ogg, jingle_oom.ogg   re-rendered
design/audio/music_home.ogg, music_game.ogg   unchanged, included so the Soundtrack page has every loop
design/audio/AUDIO.md              measured levels
design/generator/nesty-music.js    jingle mastering, measure(), volume 0.5
design/prototypes/Lottie FX.dc.html        v2 viewer + v3 sizes, segment chips
design/prototypes/Nesty Soundtrack.dc.html plays the shipped files
design/prototypes/nesty-music.js, nesty-sfx.js, support.js   loaded by the two pages
design/README.md, design/tokens.json
```
The Win screen mock in `NestyOverlay.dc.html` still draws its static ribbon with a 290 band; the game plays `ui_win_ribbon` there.
