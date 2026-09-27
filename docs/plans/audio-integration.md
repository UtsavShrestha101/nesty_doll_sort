# Plan: Music, jingles and SFX v2

Status: ready to start. Owner delivery, 2026-09-26. Covers BACKLOG "Music playback (`music_home`, `music_game`)", the music part of "Final audio", and swaps in the v2 SFX.

Read first: `design/audio/AUDIO.md` (the contract), `design/tokens.json` → `sound`, `design/README.md` → Sound & haptics, and spec §11.3. Hear everything in `design/prototypes/Nesty Soundtrack.dc.html`.

## Decision to record
Add the next D-number to `docs/PROGRESS.md` → Decisions: **Music and jingles ship as OGG Vorbis in `design/audio`** (`music_home`, `music_game`, `jingle_chapter`, `jingle_reward`, `jingle_oom`). Loops stream (`LoadMode.disk`); jingles and SFX load into memory. Jingles are on the SFX bus. The 17 SFX were replaced in place with the same names, and the clack files are now baked at 0 semitones. `design/` stays owner-managed: never edit the audio. Ask the owner for a new render.

## Steps

### A1. Tokens
- Map the new `sound` leaves in the codegen: `events.chapterComplete`, `events.reward`, `events.outOfMoves`, `clackPitch.bakedSemitones`, `music.home.*`, `music.game.*`, `musicFadeMs.*`, `musicDuck.*` and `mix.jingleBus`. `format` and `music.*.screens` are prose, so document them as skipped.
- Regenerate `ui_tokens.gen.dart`. The parity test must pass.

### A2. Asset sync
- `sync_design_assets` copies `design/audio/*.ogg` as well as `*.wav`, but not `AUDIO.md`. Validate on sync: OGG files start with `OggS`, and WAV files are 44.1 kHz mono 16-bit.
- Update `asset_manifest_test.dart` and the `tools/README.md` table (17 WAV + 5 OGG).

### A3. SFX v2
- Replace the `clackBakedSemitones = 1` constant with `SoundTokens.clackBakedSemitones` (0). Rate = `2^((semitonesBySize[size] − baked) / 12)`.
- Update the audio rate test: size 1 → `2^(5/12)`, size 6 → `2^(−5/12)`.

### A4. MusicService
- Add `MusicService` behind an interface (rule 4), with `SoLoudMusicService` and `FakeMusicService` (records calls).
- API: `playHome()`, `playGame()`, `duck(DuckReason)`, `unduck(DuckReason)`, `stopForChapter()`, `pauseForAd()`, `resumeAfterAd()`, `setEnabled(bool)`, `setVolume(double)`.
- Hold one looping handle per track. Switching crossfades and pauses the other handle (AUDIO.md → Music rules). Ducks don't stack; the lowest active factor wins.
- Load loops with `LoadMode.disk`, lazily on first use. A load failure leaves the music silent with no UI (rule 3).
- Listen to the app lifecycle: pause on `paused` or `hidden`, fade in on `resumed`.

### A5. Wiring
- **Routes:** Splash done → `playHome()`. GameRoute enter → `playGame()`. Leaving for Home or a meta screen → `playHome()`.
- **Overlays:** Win → `duck(win)`, Continue → `unduck(win)`. Out of moves sheet open → `duck(outOfMoves)` + `jingle_oom`, close → `unduck`. Pause dialog → `duck(pause)`. ChapterComplete → `stopForChapter()` + `jingle_chapter`; the next level fades `music_game` in over 2000 ms.
- **Rewards:** a Museum figurine is added, a skin or theme unlocks, the daily chest opens, or a purchase succeeds → `duck(reward)` + `jingle_reward`, then `unduck` when it ends.
- **Ads (M6):** `pauseForAd()` before showing, `resumeAfterAd()` on dismiss. Leave a `// TODO(M6)` hook if ads aren't wired yet.
- **Settings and Pause toggles:** Music → `setEnabled`. Sound gates the SFX and jingles.

### A6. Tests
- Fake-clock tests for `MusicService`: start fade, crossfade pauses the old handle, duck stacking, toggle off and on, lifecycle pause and resume, ad pause.
- Widget and flow tests: the Out of moves sheet plays `jingle_oom` and ducks; Win ducks and Continue restores; with Music off there are no music calls.
- `app_flow_test`: Splash → Home (home music) → level (game music) → Home (home music resumes where it stopped).

## Acceptance
- Both loops wrap with no audible gap or click. Listen to 3 full cycles on a device.
- Crossfades, ducks and fades match AUDIO.md and the token values.
- With Music off, the music is silent within 300 ms and stays silent across routes, ads and lifecycle changes.
- Combo chimes, the win SFX and the jingles play over ducked music without clipping, on a mid-range Android phone and an iPhone.
- Streaming music adds less than 3 MB of resident memory. The app grows by about 2 MB.
