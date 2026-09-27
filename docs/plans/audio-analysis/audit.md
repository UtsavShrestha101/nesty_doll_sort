# Audio export audit (2026-09-26)

> Claude Code's audit of Claude Design's audio export (`~/Downloads/Nesty_ Doll Sort Mobile Design (3).zip`, `export/nesty-audio/`) before it was imported. It describes the export as delivered; the v3 export later re-rendered the three jingles (see [../claude-design-v3-check.md](../claude-design-v3-check.md)). Companion: [plan.md](plan.md).

The audit only read the repo; every experiment ran in a scratch folder outside it. The decoder and encoder tests are linked against the `libvorbisfile.a`, `libvorbis.a`, `libogg.a` and `libvorbisenc.a` that flutter_soloud 4.1.7 bundles in `~/.pub-cache/hosted/pub.dev/flutter_soloud-4.1.7/macos/flutter_soloud/libs/`, so they decode the way the app will.

**Verdict:**
- The files are sound. Both loops are exact to the frame, with no padding, no gap and no audible click in measurement.
- The v2 clacks are baked at 0 semitones, as claimed.
- Two things need action: the jingle levels don't match the stated figures, and unzipping the export mid-M2 breaks the current tooling and tests (problem 1).

### 1. OGG files

All five pass the same container checks:
- Every file starts with `OggS`, and the CRC is valid on every page.
- Each file holds one logical stream, with the start flag on the first page and the end flag on the last.
- The headers are Vorbis I version 0, 2 channels, 44,100 Hz, nominal 128,000 bit/s with no max or min (that is VBR q4), block sizes 256/2048.
- The encoder is "Xiph.Org libVorbis I 20200704" (libvorbis 1.3.7). There are no comment tags and no trailing bytes or C2PA data. The header pages take 4,311 B.
- libsndfile and libvorbisfile decode each file identically to within 3e-7.
- DC offset is below 7e-5. Left/right correlation is 0.94–0.98, and a mono downmix loses at most 0.19 dB.

| File | Bytes | Pages | Avg kbps | Frames (last granule = decoded) | Seconds | vs AUDIO.md | RMS dBFS (L/R) | Sample peak | 4× true peak | LUFS-I |
|---|---|---|---|---|---|---|---|---|---|---|
| music_home | 1,068,440 | 249 | 127.6 | 2,940,000 | 66.666667 | exact | −20.68 (−20.56/−20.81) | −1.17 | −1.16 | −17.44 |
| music_game | 841,659 | 198 | 97.4 | 3,024,000 | 68.571429 | exact | −20.41 (−19.83/−21.08) | −3.88 | −3.85 | −18.21 |
| jingle_chapter | 70,710 | 18 | 105.3 | 214,982 | 4.875 | 4.9 ok | **−19.11** (stated −17) | **−0.83** | **−0.74** | −13.16 |
| jingle_reward | 50,197 | 13 | 91.3 | 165,770 | 3.759 | 3.8 ok | **−21.32** (stated −17) | −1.06 | −1.06 | −13.67 |
| jingle_oom | 51,624 | 14 | 85.7 | 193,145 | 4.380 | 4.4 ok | −17.86 | −1.00 | **−0.99** | −12.62 |

- The jingles start with 6.4–6.8 ms of silence and end at exactly zero. Their last 290–415 ms are below −60 dBFS.
- The jingles miss the −17 dBFS RMS figure because the generator uses `g = min(0.89/peak, 0.14/rms)` (`nesty-music.js` render): the peak cap wins over the RMS target. Vorbis then pushes the peak up by about 0.2 dB. Their perceived loudness is still consistent (within 1 LU of each other).
- Every size in the table matches AUDIO.md, with KB meaning KiB: 1.0 MB, 0.8 MB, 69, 49 and 50 KB, and 1.1 MB for the 17 WAVs. The OGGs add 2,082,630 B, which matches "the app grows by about 2 MB".
- Loops and jingles are stereo and the SFX are mono, as documented.

### 2. Seamless loops

**No gap:**
- The last-page granule is 2,940,000 / 3,024,000, exactly the expected frame count. The first audio pages have granules 10,432 / 15,552.
- libvorbisfile's total length equals the last granule, so there is no start offset. Vorbis has no pre-skip field, and nothing was padded.
- I emulated SoLoud's loop logic from `soloud_core_looping.cpp` and `mb_ogg.cpp`: 512-frame `ov_read_float` reads, then `ov_pcm_seek(0)` at the end of the file. Over 3 cycles it produced exactly N frames per cycle, and the cycles were bit-identical.

**Sample step at the wrap:**
- Home: left 0.03974 → 0.03857 (step 0.00118, 12th percentile of all sample steps in the file); right 0.01880 → 0.01952 (step 0.00072, 7th percentile).
- Game: left 0.00523 → −0.00057 (step 0.0058, 77th percentile); right 0.00254 → −0.00163 (step 0.0042, 67th percentile).

**The wrap compared with every internal bar line (39 in home, 23 in game):**

| Metric | home wrap | home bar lines, max | game wrap | game bar lines, max |
|---|---|---|---|---|
| Sample step | 0.0012 (8th percentile) | 0.0140 | 0.0058 (96th percentile) | 0.0068 |
| 2nd difference | 0.0021 | 0.0120 | 0.0031 | 0.0007 |
| Prediction-error spike ÷ local 99.9th percentile | 1.81 | 0.98 | 8.25 | 0.89 |
| Energy above 6 kHz, jump in dB | +1.6 | +1.9 | +2.85 | +2.5 |
| 50 ms level step, dB | −0.03 | range −8.1 to +1.0 | −1.8 | range −2.6 to +0.35 |

For scale, these deliberate faults score on the prediction-error ratio (home / game):
- skipping 10 ms at the wrap: 335 / 270, with a +45 / +31 dB burst above 6 kHz;
- inserting a 20 ms silent gap: 38 / 12;
- dropping one frame: 1.4 / 17.8.

**Root cause of the small residue:** I re-encoded the decoded loop with the same libvorbisenc at q4, moving the file edge to bar lines that are continuous in the shipped file. The new edge alone scored 0.6–1.95 (home) and 2.8–6.2 (game). Coding error is also higher at the start of a stream: in the first 1024 frames it is −35.6 / −46.8 dBFS, against −45.0 / −51.5 dBFS on average. So the residue is Vorbis stream-edge coding noise, not a problem in the render. The absolute level is tiny: the energy above 6 kHz across the wrap is −64.4 / −74.2 dBFS, which is −73 / −83 dBFS after music volume 0.5 and SoLoud's pan. A downbeat lands 1–8 ms later and masks it.

**Level across the wrap:** the last 2 s against the first 2 s changes by −7.1 dB in home (−16.89 → −24.03) and +5.3 dB in game (−24.16 → −18.84). That is the arrangement changing section at the wrap (A″ → A and C → A), not a jump in the samples.

**Tempo:**
- Home: 40 bars × 3 beats = 120 beats × 60/108 s = 66.6667 s = 2,940,000.0 frames, with a bar of exactly 73,500 frames.
- Game: 24 bars × 4 beats = 96 beats × 60/84 s = 68.5714 s = 3,024,000.0 frames, with a bar of exactly 126,000 frames.
- Onset autocorrelation measures 108.006 and 84.004 BPM, and the onsets are locked to the beat grid from sample 0.

### 3. SFX v2 against v1

- The export has the same 17 names as the repo.
- Every file is PCM, mono, 44,100 Hz, 16-bit, with a canonical header and a correct RIFF size.
- **Both v1 and v2 carry a 5,758-byte `C2PA` chunk after the data chunk** (Anthropic Content Credentials, including a hash of the data). That adds about 98 KB in total.
- Frame counts, and therefore byte sizes, are identical between v1 and v2: 1,126,310 B in total for each. All 17 data chunks differ.

| File | Frames / s | v1 peak / RMS | v2 peak / RMS | v2 RMS change |
|---|---|---|---|---|
| pick | 6615 / 0.15 | −10.82 / −32.85 | −5.91 / −22.76 | +10.1 |
| clack_1 | 11025 / 0.25 | −3.92 / −25.81 | −1.41 / −18.29 | +7.5 |
| clack_2 | 11025 / 0.25 | −3.95 / −25.61 | **−0.45** / −18.46 | +7.2 |
| clack_3 | 11025 / 0.25 | −3.77 / −25.77 | −0.53 / −17.65 | +8.1 |
| whoosh | 15435 / 0.35 | −20.54 / −40.98 | −21.54 / −41.74 | −0.8 |
| bonk | 13230 / 0.30 | −7.43 / −25.01 | −3.93 / −16.58 | +8.4 |
| complete_1…5 | 48511 / 1.10 | −7.9 to −9.6 / −25.8 | −3.69 to −3.87 / −19.85 to −20.49 | +5.3 to +6.0 |
| win | 88200 / 2.00 | −6.74 / −23.35 | −1.32 / −18.91 | +4.4 |
| coins | 35280 / 0.80 | −16.06 / −30.68 | −10.72 / −25.59 | +5.1 |
| unlock_glass | 26460 / 0.60 | −11.20 / −30.26 | −8.63 / −27.04 | +3.2 |
| ice_crack | 15435 / 0.35 | −15.91 / −39.96 | −18.47 / −37.04 | +2.9 |
| ice_shatter | 30870 / 0.70 | −7.97 / −29.78 | −5.70 (true peak −4.96) / −26.41 | +3.4 |
| button | 6615 / 0.15 | −10.44 / −30.13 | −6.34 / −24.46 | +5.7 |

The claim that v2 peaks are at or below −0.4 dBFS holds: the loudest is clack_2 at −0.45.

**Clack pitch:**
- v1 onsets are 550.5 / 598.4 / 516.0 Hz. Against v1's size-3.5 base frequencies (520, 565, 488) that is +0.99 / +0.99 / +0.97 semitones, so v1 is baked at size 3 (+1 st). Confirmed.
- v2's main hit is 455.1 / 490.1 / 430.2 Hz and its body partial 236.6 / 254.7 / 223.5 Hz. Against v2's base (455, 490, 430) that is 0.00 / 0.00 / +0.01 semitones, so v2 is baked at 0 st. Confirmed.
- In absolute terms v2 sits 3.2–3.5 semitones below v1, because the sound was re-voiced as well as re-baked.

### 4. Generators and the prototype

**`nesty-music.js`** (the `generator/` and `prototypes/` copies are identical):
- It is a Web Audio synthesizer with the scores built in:
  - balalaika, guitar and bass by Karplus-Strong string synthesis, cached per note;
  - marimba (modes at 1, 3.99 and 9.9) and music box (partials at 1, 2, 3 and 6.27);
  - bayan reeds and pads (detuned saw and square waves through a low-pass, with a 5.2 Hz bellows tremolo);
  - kick, shaker, tambourine, spoons and tick.
- Each instrument has a channel strip. Everything shares a 2.4 s synthetic stereo reverb, then a master gain of 0.62 into a compressor (−16 dB threshold, 2.5:1).
- The scores are Toy Shop Waltz (C major, 3/4, 108 BPM, 40 bars in sections A A′ B B′ A″) and Quiet Shelves (F major, 4/4, 84 BPM, 24 bars in sections A B C), plus the three jingles.
- A seeded PRNG gives each event its own timing and velocity variation. Timing is only ever late (0–7 ms), so every cycle is identical.
- **How the loop is made seamless:** `render()` builds a buffer of 6 s pre-roll plus N frames. Each event is scheduled twice: once shifted back by a full cycle (kept only if it lands inside the pre-roll) and once shifted forward by 6 s. The render keeps exactly the window from 6 s to 6 s + N. The previous cycle's note and reverb tails are therefore baked into the first seconds, and the next cycle's first events start at least 1 ms after the end, so nothing is cut off.
- Normalization targets are −1 dBFS peak and −20.5 dBFS RMS for loops, −17 for jingles. Jingles are trimmed below 2e-4 and get a 30 ms fade.
- The OGG encoding (libvorbis 1.3.7 q4) happened outside the JS. No encoder is shipped.

**`nesty-sfx.js`, v1 to v2:**
- It adds a seeded PRNG, an additive `partials()` modal voice and the WOOD, MARIMBA, BOX and METAL mode tables. The old `tone`, `env` and `bell` helpers are removed.
- A new `bus()` puts a dry signal plus a 0.4 s wooden-room convolution at 0.14 wet on every sound.
- Every sound is re-voiced. In particular:
  - the clack is two wooden hits 14–20 ms apart plus a hollow body partial at 0.52 f, with base frequencies [455, 490, 430] and a default size of `?? 3.5` (it was `|| 3`);
  - the complete chime is marimba at f/2 plus music box at f and at 1.5 f;
  - the win is a marimba arpeggio plus a music-box chord.
- `wav()` adds a 30 ms fade-out at the end.
- The FILES list, lengths, events, haptics and `clackRate` are unchanged.

**`Nesty Soundtrack.dc.html`:**
- It has play/stop for the loops, with a section strip, playhead and bar counter, and stem mutes for Melody, Chords, Bass and Percussion.
- It can download a "WAV master" rendered offline.
- It has play and progress for the jingles, buttons for the 17 SFX, a "clack by size" row (+5 to −5 st), a Stop button and a rules table that is text only.
- **It synthesizes everything live and never loads the shipped .ogg or .wav files.**
- There is no demo of ducking, crossfades, fades or the toggles.
- The music volume defaults to 0.6, where the token is 0.5.
- It needs `./support.js`, which is not in the zip (the repo has it).

### 5. Mix headroom

In flutter_soloud 4.1.7:
- `soloud.init(0, …)` (`src/player.cpp:279`) means a hard clip at ±1.0 followed by ×0.95.
- Pan 0 gives 0.7071 per channel for both mono and stereo voices, which is −3 dB.

Alone, at their default volumes, the music peaks at −10.2 dBFS (home) and −12.9 dBFS (game). The SFX peak at −5.4 dBFS (clack_2) and the jingles at −5.8 to −6.0.

The simple arithmetic you asked for (music peak × 0.5 × duck + SFX peak × 0.8, before the pan) gives:
- win: −2.1 dBFS
- jingle_oom: −1.5
- jingle_reward: −1.1
- complete_5 with no duck: −1.5

The simulated worst case, sliding the SFX across the whole loop in 10 ms steps, gives:
- complete_5 over game music with no duck: −5.0 dBFS
- win over music ducked to 0.3: −5.45; before the duck lands: −3.8
- win plus coins 700 ms later: −5.45
- jingle_oom at 0.4: −4.85; jingle_reward at 0.4: −4.66; reward plus coins: −4.47
- **clack_2 and complete_5 on the same frame: +0.04 dBFS** (30 ms apart: −1.96; 100 ms apart: −3.27)
- whoosh, clack, complete and win all at once: +1.01 dBFS, clipping at 15.5% of positions
- Without SoLoud's −3 dB pan: clack plus complete reaches +3.05 dBFS.

### Ranked problems

1. **Unzipping mid-M2 breaks the build and tests.**
   - `tools/lib/src/tokens/ui_tokens_codegen.dart:579-583` reads `sound.music.*` as strings like "name (…)", but the new tokens are objects, so codegen throws.
   - The single-name jingle events get added to `SoundTokens.allFiles`. Then `soloud_audio_service.dart:73` preloads `assets/audio/jingle_*.wav`, because `SfxMix.fileExtension` is `wav`. `asset_manifest_test.dart:65` expects `.wav` files, and `sfx_mix_test.dart:103` expects gains for all of them.
   - `design_asset_sync.dart:30/199` rejects anything except `*.wav` in `design/audio`, so AUDIO.md and the OGGs become sync issues.
   - The unzip has to land together with steps A1–A3, and the codegen has to keep SFX (.wav) and jingles (.ogg) separate.
2. `clackBakedSemitones = 1` (`apps/game/lib/core/services/audio/sfx_mix.dart:23`) would play the v2 clacks 1 semitone flat at every size until step A3.
3. The jingle levels in AUDIO.md and the prototype are wrong: chapter is −19.1 RMS with a −0.74 dBTP true peak, reward is −21.3 RMS, and oom has a −0.99 dBTP true peak. This is harmless in the app (at least 4.5 dB of headroom), so it's a documentation fix, not something to normalize in the app.
4. There is no limiter. Stacked SFX on the same frame over undocked game music reach +0.04 dBFS, and +1.0 dBFS for the full stack. The margin depends on SoLoud's −3 dB pan. Keep cues staggered, or add flutter_soloud's limiter, and write a test for it.
5. Each loop wrap has a tiny Vorbis edge discontinuity: in game the prediction-error ratio is 8.3 against at most 0.9 at bar lines, and the burst is about −83 dBFS in the app. There is no gap. The acceptance step of listening to 3 cycles on a device still applies; ask the owner for a new render only if a tick is heard.
6. The prototype doesn't play the shipped files, has no duck or crossfade demo, defaults music to 0.6 against the 0.5 token, and needs `support.js` from the repo.
7. whoosh and ice_crack are quiet next to the music. Their loudest 50 ms is −38.5 and −33.9 dBFS in the app, against a median of −30.7 dBFS for game music over 50 ms windows, so check them by ear. Separately, BACKLOG:429 says "normalize levels", which contradicts the handoff's "don't normalize".
8. Loaded into memory, the jingles decode to 1.72 + 1.33 + 1.55 = 4.6 MB of float PCM (the SFX are about 2.1 MB). Load them lazily or accept the cost. Their 0.3–0.4 s of inaudible tail delays an "unduck on end" by about that much.
9. The C2PA chunks are in the v1 WAVs too, so they are not new. dr_wav skips them. Stripping them on sync is optional (about 98 KB).
10. v1 and v2 WAVs have identical byte sizes, so a check based on size or mtime would miss the swap. The sync compares bytes, so it is safe.
11. The handoff sketch's `await s.play(...)` is a problem: `play()` returns `SoundHandle` synchronously in 4.1.7 (`soloud.dart:1996`), so the analyzer would flag `await_only_futures` under the zero-warnings policy. `fadeVolume`, `schedulePause`, `setPause` and `loadAsset(mode:)` all exist. `loadAsset` copies the asset to a temp file and streams it from disk (`loader_io.dart:165-234`). A `busId` parameter (mixing buses) is also available.
12. The zip contains two `.DS_Store` files; leave them out when unzipping.

The measurement scripts stayed in that scratch folder and are not part of the repo: Python scripts for the Ogg pages, the loop wraps, the WAV and clack analysis, the tempo and the mix, and a C decoder and encoder linked against flutter_soloud's libraries.