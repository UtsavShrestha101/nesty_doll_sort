# Audio

For Claude Code. Everything Nesty plays: 2 music loops, 5 jingles and 23 SFX. Hear them all in `prototypes/Nesty Soundtrack.dc.html`: it plays these exact files by default, and its live-synth mode can mute each part of a loop. Values live in `tokens.json` → `sound`. The SFX cue for each animation stays in `lottie/LOTTIE.md` and `prototypes/Nesty Motion & Sound.dc.html`.

The band is a small wooden folk set: balalaika, marimba, music box, bayan, nylon guitar, pluck bass, spoons, shaker, tambourine and a soft frame drum. Everything is in C major or F major, so the combo chimes (C6 D6 E6 G6 A6) always fit the chords under them. `generator/nesty-music.js` and `generator/nesty-sfx.js` synthesize every file. They are references only; the app plays the files.

## Files

| File | Kind | Length | Format | Size |
|---|---|---|---|---|
| `music_home.ogg` | loop | 66.667 s · 2,940,000 frames | OGG Vorbis q4, 44.1 kHz stereo | 1.0 MB |
| `music_game.ogg` | loop | 68.571 s · 3,024,000 frames | OGG Vorbis q4, 44.1 kHz stereo | 0.8 MB |
| `jingle_chapter.ogg` | one-shot | 4.875 s | OGG Vorbis q4, 44.1 kHz stereo | 70 KB |
| `jingle_reward.ogg` | one-shot | 3.759 s | OGG Vorbis q4, 44.1 kHz stereo | 51 KB |
| `jingle_oom.ogg` | one-shot | 4.380 s | OGG Vorbis q4, 44.1 kHz stereo | 51 KB |
| `jingle_versus_win.ogg` | one-shot | 4.42 s | OGG Vorbis q4, 44.1 kHz stereo | 67 KB |
| `jingle_versus_lose.ogg` | one-shot | 4.28 s | OGG Vorbis q4, 44.1 kHz stereo | 51 KB |
| 23 × `*.wav` | SFX | 0.15–2.0 s | WAV 44.1 kHz mono 16-bit | 1.5 MB total |

## Levels

Measured on the shipped files after decoding. RMS covers the whole file and both channels (a full-scale square wave is 0 dBFS). True peak uses 4× oversampling (ITU-R BS.1770). `NestyMusic.measure(buffer)` in `generator/nesty-music.js` computes the same numbers.

| File | RMS | True peak |
|---|---|---|
| `music_home` | −20.7 dBFS | −1.2 dBTP |
| `music_game` | −20.4 dBFS | −3.9 dBTP |
| `jingle_chapter` | −17.0 dBFS | −1.6 dBTP |
| `jingle_reward` | −17.0 dBFS | −1.3 dBTP |
| `jingle_oom` | −17.0 dBFS | −1.6 dBTP |
| `jingle_versus_win` | −17.0 dBFS | −1.4 dBTP |
| `jingle_versus_lose` | −17.0 dBFS | −1.6 dBTP |

The three jingles were re-rendered on 2026-09-26. Their first render capped the sample peak at −1 dBFS, which left `jingle_reward` at −21.3 dBFS RMS, `jingle_chapter` at −19.1 with a −0.74 dBTP true peak, and `jingle_oom` at −0.99 dBTP. They now go through a look-ahead true-peak limiter (4 ms ramp, 120 ms release, ceiling −1.8 dBTP before encoding) and are set to −17 dBFS RMS. The Vorbis encode adds up to 0.5 dB of true peak, so every jingle stays at or below −1.3 dBTP. Music, notes and lengths are unchanged.

SFX peaks are at or below −0.4 dBFS. Their relative levels are intentional, so don't normalize them.

## Music loops

- **`music_home` · Toy Shop Waltz** (C major, 3/4, 108 BPM, 40 bars). Splash, Home, Daily, Museum, Shop, Skin detail and Settings. A balalaika tune over guitar oom-pah-pah and spoons; the bayan takes over in the minor middle part.
- **`music_game` · Quiet Shelves** (F major, 4/4, 84 BPM, 24 bars). Every level: main, daily puzzle and bonus. A soft marimba pattern with a music box tune in the middle and nylon guitar at the end.
- Loop the whole file. There are no loop points and no intro. Each render wraps the loop's own note and reverb tails into its first seconds, so the last sample flows into the first.
- Load loops with `LoadMode.disk` so they stream. Decoded, one loop is about 23 MB of float PCM.
- Keep one handle per loop. Switching screens pauses the old loop and resumes the other from where it stopped. Don't restart from 0.

## Jingles

| File | Plays when | Music |
|---|---|---|
| `jingle_chapter` | The Chapter complete overlay (4.6) opens | Fades out over 400 ms first. `music_game` fades back in over 2000 ms when the next level opens |
| `jingle_reward` | A figurine joins the Museum, a skin or theme unlocks, the daily chest opens, a purchase completes | Ducks to 0.4, back over 800 ms when the jingle ends |
| `jingle_oom` | The Out of moves sheet opens (3.5, 3.7) | Ducks to 0.4 while the sheet is open |
| `jingle_versus_win` | The race is won (9.4). C major, bright | Ducks to 0.3 while the result is up, back over 800 ms after the next tap |
| `jingle_versus_lose` | The computer finishes first (9.5). F major, gentle, never sad | Ducks to 0.3 while the result is up, back over 800 ms after the next tap |

Jingles use the SFX bus: they follow the Sound toggle and the SFX volume, not the Music toggle. Load them with `LoadMode.memory`, like the SFX.

## Music rules

Timings from `sound.musicFadeMs`, duck factors from `sound.musicDuck`.

| Moment | What the music does |
|---|---|
| Splash ready | `music_home` starts at 0 and fades in over 1200 ms (`start`) |
| Home ↔ GameRoute | Crossfade over 800 ms. The outgoing handle pauses at 0 volume |
| Won (2.8) | Duck to 0.3 in 200 ms while the overlay is up. Back to full over 800 ms after Continue |
| ChapterComplete (4.6) | Fade out over 400 ms and pause, then `jingle_chapter`. `music_game` fades in over 2000 ms on the next level |
| Out of moves (3.5) | Duck to 0.4 in 200 ms, then `jingle_oom`. Back over 800 ms when the sheet closes |
| Reward | Duck to 0.4, then `jingle_reward`. Back over 800 ms when it ends (3.8 s) |
| Pause (3.9) | Duck to 0.5 while open |
| Race result (9.4, 9.5) | Duck to 0.3 in 200 ms (`musicDuck.raceResult`), then `jingle_versus_win` or `jingle_versus_lose`. Back over 800 ms after Rematch, New race or Home |
| Milestone or day-7 chest opens (10.3c, 5.6b) | `chest_open` with the `open` segment, then `jingle_reward` 250 ms later (the Reward row) |
| Interstitial or rewarded ad | Pause. Resume with a 600 ms fade when the ad closes |
| App backgrounded | Pause everything. On resume, fade music in over 600 ms |
| Music toggle | Off: fade out over 300 ms, then pause. On: resume and fade in over 600 ms |

Ducks don't stack; the lowest active factor wins. Target volume = music volume (default 0.5) × duck factor, or 0 when Music is off.

## SFX v2

Same 17 names, lengths and events as before (`sound.events`), with new sounds that match the band: a two-hit wooden lid clack with a hollow body, a wooden pick tick, a soft double bonk for invalid drops, marimba plus music box for the combo chimes and the win, metallic coins, glass shards, ice crackle, and a small wooden room on all of them.

- **Clack pitch offset changed.** The clack files are now baked at size 3.5 (0 semitones), so the baked offset is 0 (`sound.clackPitch.bakedSemitones`). Rate = `2^(semitonesBySize[size] / 12)`, which equals `2^(−2·(size − 3.5)/12)`: size 1 is +5 semitones, size 6 is −5.

## SFX m7-2

Six new SFX in the same wooden set, WAV 44.1 kHz mono 16-bit. Their events are in `sound.events`; the Lottie sync is in `lottie/LOTTIE.md`.

| File | Length | Peak | Plays when |
|---|---|---|---|
| `star_1` | 0.70 s | −6.2 dBFS | A star lands on the win overlay: the start of `ui_stars` segment `star_1`. Music box + marimba, E6 |
| `star_2` | 0.75 s | −5.8 dBFS | Segment `star_2`, G6 |
| `star_3` | 0.90 s | −5.3 dBFS | Segment `star_3`, C7, with a short shimmer tail |
| `chest_wiggle` | 0.60 s | −6.4 dBFS | `ui_chest` segment `wiggle` starts (Open tapped). Three wooden creaks at 0, 160 and 320 ms, one per wiggle |
| `chest_open` | 1.10 s | −3.1 dBFS | `ui_chest` segment `open` starts: lid thunk, coin chink, sparkle |
| `rival_complete` | 0.45 s | −6.7 dBFS | The computer completes a family during a race: its strip dot fills. Two soft wood notes, G5 → C6, quieter than `complete_n` so it never competes with the player's own chime |

The three star files rise E6 → G6 → C7, so a 1-, 2- or 3-star win always ends on a note of the C chord. Play them on the SFX bus at full SFX volume; `rival_complete` also plays at full volume (its level is baked in).

## flutter_soloud 4.1.7 sketch

Check the names against the pinned version.

```dart
final s = SoLoud.instance;
final homeSrc = await s.loadAsset('assets/audio/music_home.ogg', mode: LoadMode.disk);
final gameSrc = await s.loadAsset('assets/audio/music_game.ogg', mode: LoadMode.disk);
final home = await s.play(homeSrc, volume: 0, looping: true);
final game = await s.play(gameSrc, volume: 0, looping: true, paused: true);

s.fadeVolume(home, musicVolume, const Duration(milliseconds: 1200)); // Splash ready

// Home → level: crossfade, then park Home where it is
s.fadeVolume(home, 0, const Duration(milliseconds: 800));
s.schedulePause(home, const Duration(milliseconds: 800));
s.setPause(game, false);
s.fadeVolume(game, musicVolume, const Duration(milliseconds: 800));

// Win overlay
s.fadeVolume(game, musicVolume * 0.3, const Duration(milliseconds: 200));
```
