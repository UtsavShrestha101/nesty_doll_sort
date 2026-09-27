# Audio integration analysis (2026-09-26)

> Claude Code's analysis of the audio export against flutter_soloud 4.1.7 and the repo, written before the import. Line numbers refer to the code at that time (M2, commit 2351b1e). Q39–Q41 below are this document's own numbering, not PROGRESS's. The owner answered them on 2026-09-26: the iOS audio session is `.ambient` (mix with the player's music, set in `AppDelegate.swift`); chapter complete plays only `jingle_chapter`, and `jingle_reward` is for skins, bought themes, the daily chest and purchases; SoLoud's `lowLatency` is false in dev and stg (screen-recordable) and true in prod. Companion: [audit.md](audit.md); the steps are [../audio-integration.md](../audio-integration.md).

Both deliveries can go into the game, but the audio drop has to land in the same change as the tools updates. On its own, unzipping it breaks two tools and CI. I checked every call in the handoff sketch against flutter_soloud 4.1.7 and ran them in a scratch macOS app. The loops wrap with no gap, and every fade and pause behaves the way the plan needs. The repo was only read; all experiments stayed in a scratch folder outside it.

## TL;DR
1. **What changed in the export.** In `tokens.json` only the `sound` section changed: 31 new leaves, 1 changed prose leaf, 2 object leaves replaced. `meta.version` was not bumped. `design/README.md` changed only in its audio lines, plus Lottie lines the repo copy never had. It says "28 Lottie files", but the repo and `FxId` have 29.
2. **Unzipping into `design/` breaks the build today:**
   - `gen_design_tokens` throws: `ui_tokens_codegen.dart:577-588` calls `t.string('sound.music.home')`, which is now an object.
   - `sync_design_assets` refuses to write anything: `_wavName` (`design_asset_sync.dart:30`) flags every `.ogg` and `AUDIO.md` as an unexpected file.
   - CI's drift job then fails too.
   - So the design drop, the tools lane and the regenerated files must be one change, landed after the M2 build finishes.
3. **The handoff's flutter_soloud calls all exist with those names.** A voice's fades and scheduled pause only advance while it plays. `setPause(h,false)` cancels a pending `schedulePause`, so a quick Home→level→Home is safe. `setVolume` cancels a running fade.
4. **Seamless loop confirmed in the engine.** I captured the mixer output across the loop end for both tracks. It matches the reference decode with correlation 1.00000 at 44.1 kHz, with no silent samples. The error around the wrap (0.140 / 0.114) is no larger than elsewhere (0.126 / 0.105).
5. **Recommended load path: `loadMem(name, bytes, mode: LoadMode.disk)`, not `loadAsset`.** It streams from a native copy of the compressed file. `loadAsset` first copies the whole asset to `<cache>/SoLoudLoader-Temp-Files/temp-sound-asset-0x…` on every launch and never cleans it up. Measured: two loops streamed, +3.96 MB RSS (noisy); one loop fully decoded, +27.3 MB.
6. **Bug to fix before music ships:** `SoLoudSfxEngine.setPaused` pauses and resumes every sound in the engine, and `dispose()` disposes them all and shuts the engine down. That hits the music too. The probe counted 6 loaded sources in one engine.
7. **OGG playback needs flutter_soloud's bundled Ogg/Vorbis libraries.** They are built in by default and already in the APK, so the app grows only by the OGG files: +2,034 KB. `NO_XIPH_LIBS` must never be set.
8. **iOS audio session.** flutter_soloud sets no category, so iOS uses its default, which stops other apps' audio. Android asks for no audio focus, so it mixes with them. This needs an owner decision (Q39).

---

## 1. Design diffs and token codegen

### README (`export/.../design/README.md` vs `design/README.md`)
- Line 28, the audio list: "17 SFX … v2 wooden-toy set; clacks baked at size 3.5", plus new `audio/*.ogg` and `audio/AUDIO.md` rows.
- New `lottie/*.json`, `lottie/images/*.png` and `lottie/LOTTIE.md` rows, and new prototypes `Lottie FX.dc.html` and `Nesty Soundtrack.dc.html`.
- New `generator/nesty-music.js`.
- New paragraph: "Every animation ships as Lottie" (owner decision).
- The Sound & haptics paragraph is rewritten: music, jingles, "Music bus 0.5, SFX bus 0.8", and jingles duck the music.
- Only documentation changed; no codegen reads the README.

### tokens.json
Every change is under `sound`. The table maps each new or changed leaf to the proposed `SoundTokens` member.

| Leaf | Change | Proposed `SoundTokens` member |
|---|---|---|
| `sound.format` | text changed | still documentation only (already in the documented set); the class doc text changes |
| `sound.events.chapterComplete` = `jingle_chapter` | new | `chapterComplete = SoundCue(['jingle_chapter'])` |
| `sound.events.reward` = `jingle_reward` | new | `reward = SoundCue(['jingle_reward'])` |
| `sound.events.outOfMoves` = `jingle_oom` | new | `outOfMoves = SoundCue(['jingle_oom'])` |
| `sound.clackPitch.bakedSemitones` = 0 | new | `clackBakedSemitones = 0` (int) |
| `sound.music.home` / `sound.music.game` (were strings) | removed; each is now an object with 7 leaves | `musicHome` / `musicGame` (kept, from `.file`), `musicHomeSeconds` 66.667, `musicHomeFrames` 2940000, `musicHomeBpm` 108, `musicHomeMeter` '3/4', `musicHomeKey` 'C major'; game: 68.571 / 3024000 / 84 / '4/4' / 'F major'. Cross-check that frames equals seconds × 44100 within 1 ms (both hold) |
| `sound.music.{home,game}.screens` | new | documentation only (prose) |
| `sound.musicFadeMs.{start 1200, crossfade 800, resume 600, toggleOff 300, toggleOn 600, duckIn 200, duckOut 800, chapterOut 400, chapterIn 2000}` | new | `musicFadeStartMs`, … `musicFadeChapterInMs` (ints) |
| `sound.musicDuck.{win 0.3, outOfMoves 0.4, reward 0.4, pause 0.5}` | new | `musicDuckWin`, … `musicDuckPause`, plus `musicDuckKeys` so an app test can pin the `DuckReason` names |
| `sound.mix.jingleBus` = `sfx` | new | `jingleBus = SoundBus.sfx`. Add `enum SoundBus { sfx, music }` to `ui_token_types.dart`; the codegen rejects any other value |

**Codegen traps:**
- **Keep `allFiles` WAV-only.** The three new events match the single-file pattern, so today's loop at `ui_tokens_codegen.dart:507-541` would add `jingle_*` to `allFiles`. Three things would then fail:
  - preload would try `assets/audio/jingle_chapter.wav` (`soloud_audio_service.dart:73`);
  - `asset_manifest_test.dart:65` would expect `.wav` files;
  - `sfx_mix_test.dart:103` (`gains.keys == allFiles`) would break.
- **Fix:**
  - Files named `jingle_*` go into a new `jingleFiles` list (OGG), and the codegen fails loudly if a `jingle_*` file appears in a random or combo cue.
  - Emit `musicFiles` for the manifest test.
- **Tools test update.** In `tools/test/tokens/design_tokens_codegen_test.dart:57-80`, add `sound.music.home.screens` and `sound.music.game.screens` to the expected documentation-only set.
- **Spot-check.** Add one for `static const clackBakedSemitones = 0;`.

## 2. flutter_soloud 4.1.7 (paths under `~/.pub-cache/hosted/pub.dev/flutter_soloud-4.1.7`)

### Sketch calls
- **`loadAsset(key, {LoadMode mode = LoadMode.memory, AssetBundle? assetBundle, bool autoDispose = false})`**, `lib/src/soloud.dart:1728`. It works as sketched.
  - `utils/loader_io.dart:206` calls `bundle.load`, which reads the whole asset into the Dart heap.
  - `:218-220` writes it to `getTemporaryDirectory()/SoLoudLoader-Temp-Files/temp-sound-asset-0x<hash>`.
  - `:230` then calls `loadFile(path, mode)`.
  - The temp file is cleaned only with `init(automaticCleanup: true)` (`soloud.dart:403`, `loader_io.dart:145`). The probe left an 841,659-byte copy behind.
- **`loadMem(path, Uint8List buffer, {mode, autoDispose})`**, `soloud.dart:978`.
  - Native side (`src/player.cpp:603-611`): memory mode is `Wav::loadMem`, which decodes everything to float PCM. Disk mode is `WavStream::loadMem(mem, len, copy=false, takeOwnership=true)`, which streams from the in-memory compressed bytes.
  - The Dart binding copies the bytes byte by byte into a native buffer inside a `compute` isolate (`bindings/bindings_player_ffi.dart:771-774`).
- **`SoundHandle play(AudioSource sound, {int busId = 0, double volume = 1, double pan = 0, bool paused = false, bool looping = false, Duration loopingStartAt = Duration.zero, Duration? loopingEndAt})`**, `soloud.dart:1996`.
  - Playing paused needs no running audio device (doc at :1990).
  - When the voice limit is reached it returns a zero handle instead of throwing (:4225).
- **Pause:** `setPause(h, bool)` :2466 (throws `SoLoudSoundHandleNotFoundCppException` or `…AudioDeviceFailedToStart…`), `getPause` :2480.
- **Fades:** `fadeVolume(h, to, Duration)` :3301, `schedulePause(h, Duration)` :3351, `scheduleStop` :3367.
- **Volume:** `setVolume` :2928, `getVolume` :2909.
- **Loop points:** `setLooping` :2667, `setLoopPoint` :2698, `setLoopEndPoint(h, Duration?)` :2731. The defaults (probe: `loopPoint=0`, `loopEnd=null`) loop the whole file, which is what the tracks need.
- **Also useful:** `getLength` :2778 (home 66.666664 s, game 68.571426 s), `seek` :2821, `getPosition` :2847.

### LoadMode.disk
- `enums.dart:320-328`: "Keep the file on disk and only load chunks as needed."
- For Flutter assets on Android/iOS, disk mode means the temp-file copy through `loadAsset`, or a native memory copy through `loadMem`. The APK asset itself is never read in place.

### OGG Vorbis decoding
- `WavStream::loadogg` (`src/soloud/src/audiosource/wav/soloud_wavstream.cpp:462-485`) uses `MBOggDecoder`, which is libvorbisfile: `ov_read_float` in `mb_ogg.cpp` `readVorbis`, and seek is `ov_pcm_seek` at `mb_ogg.cpp:1000`.
- With `NO_XIPH_LIBS` set it returns `FILE_LOAD_FAILED`. In-memory `Wav::loadogg` is the same (`soloud_wav.cpp:167-176`).
- Built in by default:
  - Android: `android/CMakeLists.txt:45-74` links prebuilt libogg, libvorbis, libvorbisfile, libopus and libFLAC from `android/libs/<abi>` (1.2–1.7 MB per ABI, already shipped).
  - iOS: podspec :27-34.
- The repo sets no `NO_XIPH_LIBS` anywhere (grep).

### Seamless looping with a streamed source
- `src/soloud/src/core/soloud_core_looping.cpp:36-109`: when a read comes back short and the voice is looping, it seeks to the loop point and fills the rest of the same block, so there is no gap.
- For OGG, "ended" is detected by an end-of-stream flag (`soloud_wavstream.cpp:399-414`), not by a sample count.
- The files' last Ogg page positions equal the token frame counts exactly (2,940,000 and 3,024,000). Decoded with libvorbis, the wrap step is ordinary: first-difference percentile 9.5–65.6 and second-difference percentile 38–92.5 among the 2 s around the wrap.
- Engine capture confirmed it (TL;DR 4). No known gaps.
- `loopingStartAt` is not needed (defaults 0 and null).

### Volume, buses and groups
- Per voice: `setVolume` / `fadeVolume`. For everything: `setGlobalVolume` / `fadeGlobalVolume` (:2885, :3284).
- Groups exist:
  - **Mixing buses:** `createMixingBus()` (:4211), `Bus.playOnEngine`, `Bus.play`, per-bus filters (`mixing_bus.dart:69-200`).
  - **Voice groups:** `createVoiceGroup` / `addVoicesToGroup` (:3225).
  - **Global limiter:** `filters.limiterFilter` (`filters/filters.dart:296`).
- **Recommendation: no native bus.** SFX volume stays per play (0.8 × gain, as `SfxMix` does now); music is fades on 2 handles; leave the global volume alone.
- **Voice limit:** the default is 16 active voices (:3194). Paused voices are not counted (`soloud.cpp:2024`). Above 16, the quietest voices are dropped, and a ducked loop at 0.15 is quiet. So protect both music handles with `setProtectVoice(h, true)` and `setInaudibleBehavior(h, true, false)`; the latter guarantees a slot (`soloud.cpp:2029-2033`).

### Clipping
- `player.cpp:279` calls `soloud.init(0, …)`, so there is no soft clip: the output is hard-clipped at ±1 and then scaled by 0.95 (`soloud.cpp:637`, clip function around :950).
- My mix simulation, worst realistic stack: clack, then `complete_*` 130 ms later, over full music at 0.5, peaks at −0.14 dBFS. Win over a ducked loop reaches −1.87; the out-of-moves jingle over ducked music −1.95.
- No limiter for now. If the device listening check hears clipping, turn on the global limiter rather than changing the levels.

### iOS session, Android focus, lifecycle
- **iOS:** `soloud_miniaudio.cpp:475-477` sets `sessionCategory = ma_ios_session_category_none` and never activates or deactivates the session. The default (SoloAmbient) applies: muted by the silent switch, and it stops other apps' audio.
  - On resume after a device pause it calls `setActive:YES` (:386-417).
  - Interruptions such as calls pause and resume the device automatically (`enums.dart:339-358`).
- **Android:**
  - With `init(lowLatency: true)`, the default the SFX engine uses today, Android takes the AAudio low-latency (MMAP) path, and screen recorders cannot capture it (`soloud.dart:381-400`).
  - `androidAAudioAttributes` applies only when `lowLatency` is false.
  - There is no focus request, so it mixes with other apps.
  - The device keeps running when idle (`soloud_miniaudio.cpp:331-341`).
- **App pause/resume:** SoLoud has no lifecycle hooks; that stays our job.
- **Init/deinit:** `init()` (:401) is queued and awaits any pending deinit; it also initializes the temp loader via path_provider (:545). `deinit()` (:629) and `deinitAsync()` (:638) dispose everything.
- **Errors:** almost every call throws `SoLoudNotInitializedException` before init. Loads throw `FlutterError` (missing asset), `SoLoudTemporaryFolderFailedException` or `SoLoudCppException`. So every engine call gets a try/catch (rule 3), the same pattern as `SoLoudAudioService._log`.

### Probe results (macOS, same native code)

| Test | Result |
|---|---|
| T3: fade 300 + `schedulePause` 300 | paused, volume 0.000; position frozen (1.532517 s, unchanged after 500 ms) |
| T4: resume + fade to 0.5 over 200 ms | 0.500 |
| T5: reversal mid-crossfade (volume was 0.326) | ends unpaused at 0.500; the scheduled pause was cancelled |
| T6: fade set on a paused voice | stays at 0.000 while paused, reaches 1.000 400 ms after unpausing |
| T7: `setVolume` during a fade | 0.700; the fade was cancelled |

The native sources confirm the same behaviour:
- `soloud.cpp:2175` updates fades only for voices that are not paused.
- `soloud_core_voiceops.cpp:56` clears the pause scheduler on `setPause`.
- `soloud_core_setters.cpp:241` cancels the fade on `setVolume`.
- Rule for resuming a parked track: `setVolume(h,0)`, then `setPause(false)`, then `fadeVolume(target)`.

## 3. Current audio code: required changes

What's in `apps/game/lib/core/services/audio/` now: `audio_service.dart`, `fake_audio_service.dart`, `sfx_engine.dart`, `sfx_mix.dart`, `soloud_audio_service.dart` (15:18) and 2 tests.

### SFX v2
- `sfx_mix.dart:19-23`: delete `clackBakedSemitones = 1` and its `TODO(M7)`. Use `SoundTokens.clackBakedSemitones` in `_clackRates` (:108-118), rate `2^((semitonesBySize[size] − baked)/12)`.
- Resolve `TODO(M7)` at :14-17 (SFX stay WAV) and :31-34 (AUDIO.md says don't normalize; gains stay 1).
- `sfx_mix_test.dart:65-97`:
  - Expect `2^(−2(size−3.5)/12)`: size 1 = 2^(5/12) = 1.3348, size 6 = 2^(−5/12) = 0.7492.
  - The sizeless clack (default size 3, :93) becomes 2^(1/12) = 1.0595, not 1.
- `soloud_audio_service_test.dart:128`: the sizeless clack's expected speed changes from 1.0 to `SfxMix.speedFor(SoundEffect.clack)`.
- The generator confirms the bake: v1 used `p.size || 3` (+1 semitone), v2 uses `p.size ?? 3.5` (0). All 17 WAVs are PCM, 44.1 kHz, mono, 16-bit, the same lengths as v1, with peaks ≤ −0.45 dBFS.

### Engine sharing (new `soloud_engine_host.dart`)
- One owner of `SoLoud.init` and `deinit`.
- `SoLoudSfxEngine.setPaused` (:72-81) must go through its own `_sources.values` handles only. `dispose` (:83-91) must dispose only its own sources, not call `disposeAllSources` + `deinit`.
- Otherwise returning from the background would restart the parked loop at volume 0 (it would drift and use CPU) and music that was toggled off.

### Jingles (SFX bus)
- Add `Duration? playJingle(Jingle jingle)` to `AudioService` (allowed: new members may be added to the frozen interfaces).
- `enum Jingle { chapter, reward, outOfMoves }`; loaded in memory with the SFX preload, but not awaited.
- Gated by the Sound setting and by the background state; volume `sfxVolumeDefault` × gain. It returns the length, or null when it didn't play.
- Memory: 4.6 MB decoded PCM (probe: +7.14 MB RSS for the 3).
- Also update the fake.
- Drop the music `TODO(M3)`s at `soloud_audio_service.dart:27-29` and `audio_service.dart:25`.

### MusicService (new files in the same folder)

```dart
enum MusicTrack { home, game }
enum DuckReason { win, outOfMoves, reward, pause }   // SoundTokens.musicDuck*
abstract interface class MusicService {
  void playHome(); void playGame();
  void duck(DuckReason r); void unduck(DuckReason r);
  void stopForChapter(); void pauseForAd(); void resumeAfterAd();
  void setEnabled(bool on); void setVolume(double v);   // default musicVolumeDefault 0.5
  Future<void> dispose();
}
```

- **Files:**
  - `music_service.dart` (interface and enums).
  - `music_mix.dart`, pure logic:
    - target = 0 when Music is off, paused (background or ad) or stopped for the chapter;
    - otherwise target = volume × the lowest active duck factor;
    - picks the fade length per transition: first start 1200, crossfade 800, `chapterIn` 2000 after `stopForChapter`, duck in 200 / out 800, resume 600, toggle 300 / 600.
  - `music_engine.dart`: the seam plus `SoLoudMusicEngine` (`loadMem` disk, `play(volume:0, looping:true, paused:true)`, protect + must-tick, fade, `schedulePause`, `setPause`).
  - `soloud_music_service.dart`: `@LazySingleton(as: MusicService, env:[real])`, `@disposeMethod`.
  - `fake_music_service.dart`: `env:[fake]`, records calls.
  - `music_coordinator.dart`: `reward()` = duck, jingle, then unduck after the jingle length through an injected timer factory (no `fake_async`: use `testWidgets`/`pump`). `chapterComplete()` = `stopForChapter()` + jingle.
- **How it behaves:**
  - It reconciles from state, not from a command log, so calls made during a lazy load apply once the load finishes.
  - One handle per track; crossfading parks the outgoing track (fade to 0 + `schedulePause`).
  - Its own `AppLifecycleListener`: `hidden`/`paused` pause both tracks at once; `resumed` fades in over 600 ms. Pause reasons are a set {background, ad}, so the Android ad screen's lifecycle event and `pauseForAd` don't double up.
  - With Music off at launch it loads nothing and issues no engine calls at all.
  - A load failure leaves the music silent.
- **Music toggle:** add `Stream<bool> musicEnabledChanges` to `DatabaseService` (Hive + fake). The service subscribes and calls `setEnabled`, so the Pause dialog and the M3 Settings toggles only write the setting.

## 4. Wiring map

### Route hook
- `core/router/music_route_observer.dart`: an `AutoRouterObserver` that tracks the top page route and ignores dialogs and sheets. It maps `HomeRoute` → home and `GameplayRoute` → game; unknown or meta routes → home; `SplashRoute` → none.
- Register it in `app.dart`: `widget.router.config(navigatorObservers: () => [get<MusicRouteObserver>()])` (auto_route 11.1.0 `root_stack_router.dart:19-24`).
- Overlays report their duck by mounting `core/ui/widgets/audio/music_duck.dart`: `MusicDuck(reason:, jingle:?)` ducks in `initState` and unducks in `dispose`, so a duck can't be left on.
- No rule goes into `nesty_core`.

### M2 (the screens exist now)
| Moment | Music action |
|---|---|
| Splash replaces itself with Home ("Splash ready") | first `playHome()`, fade in over 1200 ms |
| Home → Gameplay, and Pause "Home" / back to Home | `playGame()` / `playHome()`, 800 ms crossfade; Home resumes where it stopped |
| Win overlay (2.8) | `MusicDuck(win)`. Continue does `replace(GameplayRoute(n+1))`: game → game is a no-op, and the unduck happens when the overlay is disposed |
| Out-of-moves sheet (3.5) | `MusicDuck(outOfMoves, jingle: outOfMoves)` |
| Pause (3.9) | `MusicDuck(pause)`; its Music toggle writes the setting, which reaches `setEnabled` |
| Chapter ribbon (4.7), all-levels-done | no music action; AUDIO.md has no rule |

### M3
| Moment | Music action |
|---|---|
| Chapter complete (4.6) | `chapterComplete()`: the 400 ms fade-out takes over any running Win unduck; the next level fades in over 2000 ms |
| Rewards: skin 7.4, theme unlock or buy 7.7, daily chest 5.6 | `reward()`; the 4.6 figurine case depends on Q40 |
| Daily, Museum, Shop, SkinDetail, Settings | `music_home` |
| Daily board, bonus levels | `music_game` |

### M6
| Moment | Music action |
|---|---|
| Interstitial or rewarded ad | `pauseForAd()` before show, `resumeAfterAd()` in `finally`; leave `TODO(M6)` hooks until then |
| Purchase succeeds | `reward()` |

## 5. Assets, size, memory
- **`design_asset_sync.dart`:**
  - Accept `*.ogg`; skip `AUDIO.md` (as for LOTTIE.md).
  - WAV check: walk the RIFF chunks for `fmt ` = PCM, 1 channel, 44100 Hz, 16-bit, plus a `data` chunk. Today `_isWav` (:272-275) only checks the magic bytes.
  - OGG check:
    - `OggS` header, first page flagged as the stream start;
    - `\x01vorbis` identification header, 2 channels, 44100 Hz;
    - one logical stream, last page flagged as the end;
    - music files: last page position equals `sound.music.*.frames`.
  - Every `sound.events` and `music.*.file` entry must exist with the right extension.
- **`tools/test/assets/design_asset_sync_test.dart:111`:** audio count 17 → 22; add fixtures and rejection cases.
- **`tools/README.md:79`:** 17 WAV + 5 OGG. Also update the bin header comment.
- **Pubspec:** no change; `assets/audio/` already covers the new files (`pubspec.yaml:58`).
- **`asset_manifest_test.dart:64-66`:** WAV for `allFiles`; OGG for `jingleFiles` and `musicFiles`.
- **Size:** the OGGs total 2,034 KB (1.99 MiB) and don't compress further. The WAVs are 1,100 KB, the same as v1. Net app growth ≈ +2.0 MB.
- **Memory:**
  - Streamed loops: 1,910,099 B of native compressed data plus decoder state. The probe measured +3.96 MB RSS, including temporary copies, so device measurement is needed.
  - Decoded instead: 23.5 MB + 24.2 MB of float32 PCM.
  - If a device shows more than 3 MB, switch to `loadAsset(disk)`: nothing compressed stays in memory, at the cost of a 1.9 MB temp file.

## 6. Deliverables

### (a) Work breakdown (after M2 is closed; audio and Lottie v2 land together)
- **Stage 0 (owner and integrator):**
  - Diff both zips' `design/README.md` and `tokens.json` against the repo. Both zips may ship these files; if both change the same one, ask the designer for one merged file (`design/` is read-only for us).
  - Then drop both exports into `design/` in the same branch as Stage A.
- **Stage A, Tools lane** (the only one that regenerates):
  - Owns `tools/lib/src/tokens/ui_tokens_codegen.dart`, `tools/lib/src/assets/design_asset_sync.dart`, `tools/bin/sync_design_assets.dart`, `tools/lib/src/fx/**` (the v2 contract table), `tools/test/**` and `tools/README.md`.
  - Also the generated and synced outputs: `apps/game/lib/core/ui/tokens/ui_tokens.gen.dart`, `apps/game/lib/core/ui/tokens/ui_token_types.dart` (`SoundBus`), `apps/game/lib/features/fx/fx_spec.gen.dart`, `apps/game/assets/{audio,lottie}/**`.
  - And the tests `apps/game/test/core/assets/asset_manifest_test.dart` and `apps/game/test/features/fx/fx_spec_drift_test.dart`.
- **Stage B (in parallel; the Audio lane lands `music_service.dart`, `fake_music_service.dart` and `playJingle` first as the contract):**
  - **Audio lane:** `apps/game/lib/core/services/audio/**` and its tests; `core/services/database/**` (`musicEnabledChanges`) and its tests; `apps/game/ios/Runner/AppDelegate.swift` (if Q39 is approved).
  - **Wiring lane:** `core/router/music_route_observer.dart`, `core/ui/widgets/audio/music_duck.dart`, `app/app.dart`, the Win, out-of-moves and Pause overlays (`features/gameplay/overlays/**`), the Splash page if needed, their widget tests, and `test/app_flow_test.dart`.
  - **FX lane (Lottie v2):** `apps/game/lib/features/fx/**` except the generated file (remove the workarounds per lottie §18), `test/features/fx/**`, and `features/gameplay/game/{timeline,components}/**` only where a workaround or cue time lives.
- **Stage C, Integrator:**
  - `build_runner` for the new injectables (MusicService real + fake, engine host, observer, coordinator); no new ARB keys or routes.
  - DI test updates, the TODO_INDEX, analyze, all test suites, APK and iOS builds.
  - Updates to PROGRESS and BACKLOG.
  - The device checklist, run by the owner.

### (b) BACKLOG items
- **Sources list:** add "`audio An` is step An of plans/audio-integration.md". Tick the Owner-inputs "Music" and "Optional: final SFX" items (done 2026-09-26).
- **M3, Audio and haptics** (replaces "Music playback"):
  - [ ] Map the new `sound` token leaves (jingles to `jingleFiles`, baked 0, music.* with the frames check, fades, ducks, `jingleBus`); document `music.*.screens` — audio A1.
  - [ ] Sync OGGs, skip AUDIO.md, validate WAV and OGG formats plus music frame counts; update the manifest test and tools/README — audio A2.
  - [ ] SFX v2: use `SoundTokens.clackBakedSemitones`; update the rate tests; remove the placeholder `TODO(M7)` markers — audio A3, D19.
  - [ ] Shared `SoLoudEngineHost`; `SfxEngine.setPaused`/`dispose` touch SFX only — audio A4, `sfx_engine.dart`.
  - [ ] `AudioService.playJingle` (SFX bus, Sound setting, memory mode) — audio A4.
  - [ ] MusicService + SoLoud implementation + fake + MusicMix + MusicEngine: lazy `loadMem` disk, protected voices, duck = lowest factor, pause-reason set, lifecycle — audio A4.
  - [ ] Route observer + MusicDuck + M2 wiring (Splash, Home↔Gameplay, Win, out of moves, Pause); Music setting via `musicEnabledChanges` — audio A5.
  - [ ] Tests: MusicMix, fake-engine service tests, observer, widget flows, app_flow — audio A6.
  - [ ] Owner device acceptance: 3 loop cycles, fades, Music off within 300 ms, no clipping (limiter if needed), <3 MB, +2 MB app size — audio "Acceptance".
  - [ ] iOS session category (Q39); Android capture setting (Q41).
- **M3, Progression and Menus:**
  - [ ] Chapter complete (4.6) → `chapterComplete()` (Q40).
  - [ ] Reward jingle at skin, theme and daily chest call sites.
  - [ ] Meta routes → `music_home`; daily and bonus boards → `music_game`.
- **M3:** move "Swap in the designer's Lottie re-export" here (moved from M7: the re-export arrived).
- **M6:**
  - [ ] `pauseForAd`/`resumeAfterAd` around every ad show; idempotent with the lifecycle pause.
  - [ ] Purchase → `reward()`.
- **M7:**
  - [ ] "Final audio" shrinks to the by-ear device check.
  - [ ] Optional: keep music off while another app plays audio (Q39).
- **Tech debt:** never set `NO_XIPH_LIBS` (OGG decoding needs it unset).

### (c) PROGRESS decision (next free number: D53 at read time; re-check)

> **D53. Music and jingles ship as OGG Vorbis in `design/audio`** (`music_home`, `music_game`, `jingle_chapter`, `jingle_reward`, `jingle_oom`; owner delivery 2026-09-26). Loops stream (`LoadMode.disk`, loaded with `loadMem`, not `loadAsset`, so there is no temp-file copy); jingles and SFX load into memory. Jingles are on the SFX bus (Sound toggle, 0.8). The 17 SFX were replaced in place with the same names; the clacks are now baked at 0 semitones (`SoundTokens.clackBakedSemitones`), which supersedes D19's +1 offset. One engine host owns SoLoud; the music handles are protected and keep a voice slot; ducks don't stack (the lowest factor wins); background and ad pauses are one set of reasons. The engine's loop wrap was verified as gapless (mixer capture, correlation 1.0). `design/` stays owner-managed.

Also update the PROGRESS "Package reasons" row for `flutter_soloud`: it now also streams OGG music; the bundled Ogg/Vorbis libraries must stay enabled.

### (d) Risks and owner questions
**Risks**
1. The design drop breaks codegen, sync and CI until Stage A lands (see TL;DR 2).
2. The two zips may overwrite each other's `design/README.md` and `tokens.json`; the README says 28 Lottie files, but there are 29.
3. SFX pause/dispose side effects on music (fix in Stage B).
4. Clipping headroom is only 0.14 dB in the worst realistic stack.
5. Level deviations to pass to the designer, not blocking:
   - `jingle_chapter` peaks at −0.83 dBFS (AUDIO.md promises ≤ −1).
   - `jingle_reward` RMS is −21.3 dBFS (claimed −17); chapter −19.1, out of moves −17.9.
6. The printed resident memory numbers are noisy; measure natively on a device.
7. Run-time lazy loading costs 50–150 ms off the UI thread; start `music_game` loading when Home is idle.

**Owner questions**
- **Q39. iOS audio session.** Mix with the player's own music (`.ambient`), or stop it (the current default)? Both respect the silent switch.
  - Recommended: `.ambient`, set in 3 lines of `AppDelegate.swift`, no new package. This matches Android, which already mixes.
  - Optionally later (M7): keep Nesty's music off while other audio plays.
- **Q40. Chapter complete double trigger.** At 4.6 the figurine joins the Museum (AUDIO.md: `jingle_reward`) and the overlay opens (`jingle_chapter`); chapter themes unlock at the same moment too.
  - Recommended: play only `jingle_chapter` at 4.6; keep `jingle_reward` for skins, bought themes, the daily chest and purchases.
- **Q41. Android screen recording.** `init()` with the default `lowLatency: true` can't be captured by Android screen recorders, so store and ad videos recorded on Android would have no sound.
  - Recommended: `lowLatency: false` in dev and stg, and keep `true` in prod.

### Scratch files
The probe app (a minimal macOS Flutter app on flutter_soloud 4.1.7), its log, the mixer captures of both loop wraps and the analysis scripts stayed in the session's scratch folder; none of them is part of the repo. Two things were left outside that folder on the owner's machine:
- macOS build output at `~/.pub-cache/hosted/pub.dev/flutter_soloud-4.1.7/macos/cmake_build`.
- An 841,659-byte temp file at `~/Library/Caches/com.example.soloudProbe/SoLoudLoader-Temp-Files/`; deleting it was denied.
