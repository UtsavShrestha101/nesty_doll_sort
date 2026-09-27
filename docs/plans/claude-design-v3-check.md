# Claude Design v3: check verdict (2026-09-26)

> Claude Code's check of Claude Design's v3 export ([claude-design-v3-changes.md](claude-design-v3-changes.md)) before it was imported into `design/` (2026-09-27). The measurements, probes and the trial import ran in a scratch folder outside the repo; only this verdict is kept.

**Verdict: import v3 instead of our v2. Nothing needs to go back to Claude Design.**

v3 is an overlay: import order is repo `design/` ← `~/Downloads/Nesty_ Doll Sort Mobile Design (3).zip` (`export/nesty-audio/`; the owner removed the folder from `export/`) ← `export/nesty-v3/`. The check staged that merged result in the scratch folder; the import reproduced it file for file.

The evidence (static Lottie scans, runtime probes on lottie 3.6.1, audio measurements and a trial import) stayed in the scratch folder. The five check agents were cut off by the session limit before they reported, so this verdict was assembled inline from their saved measurements, plus targeted re-checks.

## CHANGES.md claims

| Claim | Status | Evidence |
|---|---|---|
| 17 files byte-identical to v2, 12 changed | verified | semantic diff against v2: every changed path maps to a CHANGES point |
| Declared image size = PNG size | verified | rules audit R1: 43 assets |
| No animated image-layer transforms | verified | R2: 50 image layers; lid lifts moved to `target_lid_lift`/`mover_lid_lift`, arrow bob to `arrow_bob` |
| New parent nulls: on screen unchanged | verified | transform check: 0.000 px max deviation, 1/8-frame steps |
| No equal consecutive travel/drop keys | verified | R3 |
| Only allowed features, 60 fps | verified | R4/R5 |
| Inside the canvas at every frame | verified | geometric bounds ≥ 0.5 dp. Toggle, spinner and loader touch the edge exactly. lottie-web's negative ribbon/counter margins come from the preview text layers the game hides; v2 had them too. |
| Ribbons: 410 canvas, anchors (205,55)/(205,50), band 336, tails +22 with 12 notch, ±201.4 at the 106 % pop | verified | semdiff vertices ±190, notch 178 |
| Ribbon text fits about 26 characters at Fredoka Bold 24/20 in 312 dp | verified for mixed case | about 305 dp. ALL-CAPS 26 characters is about 360 dp, so the overlay must scale down to fit. |
| fx_ice `crack_hit_0..3` at 82–98 / 99–115 / 116–132 / 133–149, shake + flash, no chips or new image, rests on `rest_n` | verified | runtime ice probe: frames 0–81 identical to v2, shatter ends at 81, length 150 |
| Glass unlock hop 42 → 47 (y 149) → 53 (y 174), 54 f | verified | runtime glass probe: y 174.000 at 53–53.99 |
| All 29 files work in lottie 3.6.1 | verified | load-and-draw run: 4,098 frames drawn, 0 exceptions. Compensation key paths resolve for every image layer; travel/drop callbacks fire on every frame. |
| `doll_silhouette.png` = wood-grain blank at 512×768 | verified | viewed |
| Jingles −17.0 RMS; true peaks −1.6 / −1.3 / −1.6 dBTP | verified | measured −17.03/−17.04/−16.97 RMS, true peaks −1.63/−1.30/−1.62 |
| Jingles: same music, notes and lengths | verified | frame counts identical, onsets match, about 98 % pitch-class agreement |
| Loops −20.7/−20.4 RMS, −1.2/−3.9 dBTP | verified | −20.68/−20.41, −1.16/−3.85 |
| Soundtrack page plays shipped files; music 0.5; jingles on SFX bus; clack by size | verified | loads `../audio/` over http; rate 2^(−2(size−3.5)/12) = tokens `semitonesBySize` with baked 0, the same as our A3 formula |
| support.js included; README 28 → 29 | verified | |
| tokens.json: only `layout.towerSilhouettes` and `motion.reveal.type` prose | verified | |

## Issues

1. **(us, minor) fx_ice frame 99.** In lottie 3.6.1 the shared boundary `ice_0_hit` op 99 = `ice_1_hit` ip 99 rounds unequal. A drawable that last drew 98.x and then seeks to 99 draws `ice_0` and `ice_1` together for one frame. A fresh seek is clean. Fix: reset a pooled drawable's progress before starting a segment. The other boundaries are equal.
2. **(us, expected import work).** A trial import into a scratch copy of the repo gave these results:
   - `gen_fx_spec` and `sync_design_assets` reject v3, because their contract table is LOTTIE.md v1 (sizes, lengths, canvases, markers).
   - Sync rejects OGG and AUDIO.md in `design/audio`. That is audio step A2.
   - `gen_design_tokens` throws on the new `motion.reveal.type` wording. Parse it to the centre (256, 476).
   - 18 app tests fail, as expected: pinned v1 numbers, and workaround tests for defects v3 fixed.
3. **(owner, listen).** `jingle_reward` reaches −17 RMS through up to 8.1 dB of limiting (more than 3 dB for 19 % of it; crest 20.3 → 15.7 dB). `jingle_chapter` gets up to 4.5 dB and `jingle_oom` 2.5 dB. Compare them in `Nesty Soundtrack.dc.html` (serve `design/` over http). If `jingle_reward` sounds squashed, ask Claude Design for a gentler master.
4. **(owner, accept).** At the 106 % pop the ribbon tails pass a 390 dp screen edge by up to 6 dp for about 100 ms. Recommend accepting.
5. **(info).** Confetti arcs now peak 7–91 dp lower (squeezed into the canvas). The v1/v2 arcs were clipped by the player anyway.
6. **(info, not v3).** At the end of `doll_complete`'s fly (30 dp tall), FilterQuality.medium minification differs by at most 13/255 from the reference. v2 was the same.
7. **Mix headroom.** Jingle true peaks are 0.3–0.8 dB lower than v1, so worst-case stacking is no worse. Keep the plan: enable SoLoud's limiter only if clipping is heard.

## Import plan (post-M2 round, with the audio steps A1–A6)

1. Move the files in, in overlay order. Copy `docs/plans/audio-integration.md` from the audio zip. Commit Claude Design's CHANGES.md as `docs/plans/claude-design-v3-changes.md` and PROMPT.md as `docs/plans/claude-design-lottie-audio-prompt.md`.
2. Tools:
   - Lottie contract table → LOTTIE.md v3: 3× board-piece sizes, `doll_reveal` 31 f, `fx_ice` 150 f + `rest_*` + `crack_hit_*`, ribbons 410.
   - Sync: copy OGG, skip AUDIO.md, validate OggS and WAV format.
   - `gen_design_tokens`: new sound leaves (A1) and the new reveal/silhouette prose.
   - Regenerate `fx_spec.gen.dart`.
3. Delete the workarounds v3 makes unnecessary:
   - travel-hold remap;
   - padlock_ping hide;
   - 11 dp glass settle;
   - hand-coded reveal drop (`doll_reveal` now 0–31 f including the drop; the timeline's reveal times shift);
   - animated-scale compensation for glow_ring, extra_slot and ice_shatter (static 33.33 % layers under pulse nulls).
   Keep doll-size compensation and raster compensation (compensated scale = k / raster.scale).
4. New wiring:
   - ribbon text overlay: anchor 205, box 312×40 / 312×32, scale-down fit;
   - `IceCracked` with no stage change → `crack_hit_n`, then rest `rest_n`;
   - buried nests use `board/doll-silhouette.svg` for every skin;
   - the drawable reset from issue 1.
5. Audio A1–A6 per the plan: shared engine host, MusicService, route observer + MusicDuck, iOS `.ambient`, lowLatency false in dev/stg.
6. Update the 18 tests plus new ones (crack_hit, reveal timing, ribbon overlay), PROGRESS (v3 adopted, answers 3c/3d/3e, jingle re-render), and BACKLOG (tick the Owner-inputs re-export items).
7. Run the gates, verify on device, commit, push main.

## Update 2026-09-26 17:51: `Nesty_ Doll Sort Mobile Design (5).zip`
The owner replaced `export/nesty-v3/` with this zip. It is the checked v3 (the (4) zip) plus `design/audio/music_home.ogg` and `music_game.ogg`, byte-identical to the audio export's, "included so the Soundtrack page has every loop", and one CHANGES.md line. Nothing else changed, so the verdict stands. The 17 SFX v2 WAVs, `generator/nesty-sfx.js` and `docs/plans/audio-integration.md` are still only in the (3) zip. Import order: design ← (3) `export/nesty-audio` ← `export/nesty-v3`.
