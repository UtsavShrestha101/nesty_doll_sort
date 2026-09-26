# Lottie analysis — packages (2026-09-26)

Read-only analysis of design/lottie/ against lottie 3.6.1 (probes run in a scratch project). Reference material for the M2 Lottie work; decisions live in docs/PROGRESS.md and docs/plans/m2-lottie-design.md.

## Lottie package support: lottie 3.6.1 works, flame_lottie is not worth adding, and five contract points need fixing

**Answer in brief:** use `lottie: 3.6.1`, pinned exactly, and do not add `flame_lottie`. Board effects should draw inside Flame through our own small component that wraps `LottieDrawable`. HUD, overlay and meta-screen files should use the `Lottie` widget. Five things in `LOTTIE.md` do not behave in lottie-flutter the way the doc assumes (section 1). I checked each one against the package source and in probe tests run on the owner's files.

Scope: I did not write anything under `/Users/utsav/Downloads/nesty`. All experiments are in the scratchpad at `/private/tmp/claude-501/-Users-utsav-Downloads-nesty/8a802507-1fb1-4775-b441-329bc52e16e7/scratchpad/`.

### 0. Versions and resolution
- **Flutter:** `flutter --version` reports "3.43.0-1.0.pre-35 • channel stable", Dart 3.11.0, framework revision 5408e0f304.
- **Resolved with `flame: 1.38.2`:**
  - `lottie 3.6.1` (latest on pub.dev, published 2026-09-18). It needs sdk ^3.11.0 and flutter >=3.41.0. Its dependencies are archive ^4.0.0, http ^1.0.0, path ^1.8.0 and vector_math ^2.1.0. It does not depend on path_provider, xml or flutter_svg.
  - `flame_lottie 0.4.3+23` (latest). It needs flame ^1.38.0, lottie ^3.1.2 and flutter >=3.41.0.
- **No other version works:**
  - lottie 3.4.0, 3.5.0 and 3.5.1 need Flutter >=3.44.0 and Dart ^3.12.0, so they can't be selected here.
  - 3.6.0 is retracted.
  - 3.3.3 (Flutter >=3.35) is the fallback, but it lacks 3.4+ matte-alpha fixes and the 3.6.1 fix for trim paths on web (`ui_spinner` uses trim paths).
- **Workspace check:** I copied the root and member pubspecs plus `pubspec.lock` to `scratchpad/ws`, added both packages to `apps/game` and ran `flutter pub get`. The lock diff shows only four new packages: `archive 4.3.0`, `posix 6.5.2`, `lottie 3.6.1` and `flame_lottie 0.4.3+23`. No locked version changed (flame 1.38.2, vector_math 2.2.0, http 1.6.0, path_provider 2.1.6, flutter_svg 2.3.0 and xml 7.0.1 are all unchanged).
- **Parsing:** all 29 JSON files parse with no unsupported-feature warnings. The only warning is the "You have N images" advisory on `fx_glass_unlock` and `fx_ice`. Note that `LOTTIE.md` says 28 files, but the folder and its table both have 29.

### 1. What in LOTTIE.md is wrong for lottie-flutter

1. **Images are drawn at their pixel size, not at the asset's declared `w`/`h`.**
   - Code: `image_layer.dart:34-46` draws with `dst = Rect.fromLTWH(0,0,bitmap.width,bitmap.height)`.
   - Probe T1, `doll_idle`: a 512×768 image gives a 100×151 box, which is correct. The shipped 256×384 `doll_body.png` gives a 40×36 box in the wrong place.
   - Probe T1, `fx_select_glow`: the 360×160 placeholder lands off-centre (centre x 86 instead of 70) and is clipped.
   - None of the placeholder PNGs match their declared size: doll 256×384 vs 512×768, glass 360×600 vs 86×143, ice 360×600 vs 96×160, glow 360×160 vs 116×52, hint arrow 160×200 vs 40×50, extra slot 320×120 vs 90×34, unlock symbol 24×24 vs 12×12. The viewer, which uses lottie-web, scales them, so they look right there.
   - **Consequence:** the image delegate must return exactly w×h pixels. That makes board sprites 1× resolution (blurry at DPR 3). Doll layers must be 512×768 each: 11 colours × 2 × 1.57 MB ≈ 35 MB, against the M2 budget of under 25 MB for all GPU images. "Rasterize once per skin, color and size" can't work.
   - **Fixes:** either ask the owner to declare the assets at the raster size the game will supply (for example 3× board art, dolls at 256×384 with a 39.06% layer scale), or override scale and anchor on each image layer by delegate.

2. **The `travel` position callback is skipped during hold keyframes.**
   - Code: `path_keyframe_animation.dart:16-18` returns `keyframe.startValue!` when the start and end values are equal, before it calls the value callback.
   - Probe T2, `doll_complete` frames 5, 30 and 41: the callback runs 0 times and the doll stays at the authored x=100 instead of the remapped 250.
   - Probe T2, `ui_drag_hand` frames 10 and 95: same result, 0 calls and the authored position.
   - `doll_move` and `doll_invalid` are fine.
   - **Workaround, verified in probe T10:** also set `ValueDelegate.transformAnchorPoint(['travel'])`, returning `S - src` when the position callback did not run for that matrix. `getMatrix` reads position before anchor, so a flag set in the position callback tells you. The cleaner fix is an export where `travel` has no equal consecutive keyframes.

3. **`LottieFrameInfo` is not exported.** It is missing from `lib/lottie.dart`, so `remapTravel(LottieFrameInfo<Offset> f, …)` as written in `LOTTIE.md` does not compile. Importing `src/` would break the zero-warnings rule. Pass `f.startValue`, `f.endValue` and `f.interpolatedKeyframeProgress` from a closure whose parameter type is inferred.

4. **A `textStyle` delegate cannot shrink the font.**
   - Code: `text_layer.dart:388` does `textStyle.copyWith(fontSize: textSize)`, which overrides it.
   - Probe T6b: `fontSize: 10` gives an identical 184 px box. `ValueDelegate.textSize(['label'], value: 14)` plus the same on `['label_shadow']` gives 92 px.
   - Use `textSize` on both layers. A per-layer `ValueDelegate.text` must also target both `label` and `label_shadow`.

5. **Board-space files are clipped to 390×844.**
   - Code: `layer_parser.dart:71` sets `preCompWidth: bounds.width`, and `composition_layer.dart:110` does `canvas.clipRect`.
   - Any doll going past x=390 (for example the right column on a 430×932 or tablet layout) is cut off. There is no option to turn this off. Either export these files on a larger canvas or offset src/dst into the canvas.

**Other traps found:**
- `LottieDrawable(c, delegates: d)` throws a `LateInitializationError` when `d.values` is non-empty, because `lottie_drawable.dart:32` sets delegates before line 33 builds `_compositionLayer`. Construct it first, then set `..delegates = d`.
- `LottieDelegates ==` ignores `image` and compares `values` by list identity (`lottie_delegates.dart:91,94`). Probe T4: an image-only swap is dropped.
- One `ValueDelegate` instance must not be shared between drawables, because `value_delegate.dart:405-407` stores `_resolved` on the delegate itself. Probe T5: updating drawable A changed drawable B.
- For scale (and any non-path point value), the two progress fields are swapped (`point_keyframe_animation.dart:39`): `f.linearKeyframeProgress` holds the eased value (0.918) and `f.interpolatedKeyframeProgress` the linear one (0.429). For path positions they are correct: linear 0.25, eased 0.816, and overshoot reaches 1.087 in `doll_move`.
- `Marker.end` is based on durationFrames = op − 0.01, so `settle` ends at 1.000244. Clamp it to 1.0, because `RenderLottie` and `LottieRenderer` assert progress ≤ 1.

### 2. Feature support (Q1)
- **Layers:**
  - Shape, null, image, precomp and text layers are all supported.
  - All four mattes are alpha (`tt=1`) with the matte source directly above and no `tp` field, so they work. Inverted mattes use dstOut and are supported.
  - Luma mattes are not supported (`layer_parser.dart:155-158` only emits a warning), and `tp` is ignored because pairing is by adjacency. The asset validator should reject `tt=3/4` and `tp`.
- **Fonts:**
  - The JSON `fonts` map is keyed by fName (`fonts[font.name]`, `lottie_composition_parser.dart:205`). The text layer looks up `fonts[documentData.fontName]`, so 'Fredoka-Bold' maps to family 'Fredoka', style 'Bold'.
  - The default delegate then builds `TextStyle(fontFamily:'Fredoka', fontWeight: bold)` (`lottie_delegates.dart:8-24`). That matches pubspec family Fredoka weight 700, so no FontLoader and no `textStyle` delegate are needed.
  - If the fName is missing, the layer draws nothing (`text_layer.dart:146`). If the family is wrong, Flutter falls back to its default font without warning (probe T6b).
  - Glyph mode is off because `chars` is empty.
- **`LottieDelegates.image`:**
  - Signature: `ui.Image? Function(LottieComposition, LottieImageAsset)`, keyed by `asset.id`.
  - It is called on every draw and every bounds check (probe T9: 6 calls per frame for `doll_complete` while the matte is active, 2 otherwise), with no caching. Returning null falls back to `asset.loadedImage`.
  - Loading through `AssetLottie`, `Lottie.asset` or `loadLottie` decodes every placeholder PNG, about 8.6 MB and all the wrong size. `LottieComposition.fromBytes` loads no images, so use that in FxLibrary.
  - The image filter defaults to `FilterQuality.low` (`image_layer.dart:27`). Set `drawable.filterQuality = FilterQuality.medium` for 512×768 art shrunk down to 63–117 dp dolls.
- **Value delegates:**
  - `transformPosition` works, apart from holds. Static `target_pos` overrides work (probe T17).
  - For `transformScale`, `Offset(1,1)` is 100% (`scale_xy_parser.dart` divides by 100). The override works even when the authored 100% scale was dropped by the parser.
  - `color(['**','tint'])` and `['**','rim_tint']` both work (probe T12).
- **Markers:** `composition.getMarker(name)` is case-insensitive and trimmed, and returns `startFrame`, `durationFrames`, `start` and `end`. `composition.markers` lists them all.
- **Sub-ranges and rest frames:**
  - Widget: use `controller.repeat(min: m.start, max: m.end)` or `animateTo`.
  - Rest frame: `drawable.setProgress(p)`, `controller.value = p`, or `AlwaysStoppedAnimation(p)`.
  - The default `FrameRate.composition` rounds down: `wobble.start` renders at frame 6.998. That is safe here because layers in these files start at marker+1.

### 3. flame_lottie (Q2)
- It is about 100 lines and compiles against flame 1.38.2.
- `LottieComponent` has a private `late final LottieRenderer _renderer` (`lottie_component.dart:12`). So there is no access to the drawable, no way to change delegates after construction, no marker API, and no pause: `update` always calls `_controller.advance(dt)` (`lottie_renderer.dart:50`).
- It mixes in `HasPaint`, but `render` ignores it. Probe T8: at opacity 0 the doll is still visible.
- `loadLottie(Lottie.asset(...))` loads the placeholders.
- Per-slot delegates are possible only by building a new component, and a new `LottieDrawable` takes 0.1–10 ms per build (confetti 8.6 ms on the host).
- Our own 80-line `LottieFxComponent` works: it plays a marker, runs segment callbacks, respects priority and anchor inside a mounted `FlameGame` (probe T14), and passes `flutter analyze` clean.

### 4. Performance (Q3)
Host numbers come from `flutter test` (JIT, debug) and are only useful for comparison. Profile on a device.

| File | µs per frame |
|---|---|
| `fx_sparkle` | 10 |
| `ui_spinner` | 11 |
| `doll_complete` | 51 |
| `fx_glass_unlock` | 64 |
| `doll_move` | 89 |
| `fx_ice` | 92 |
| `fx_confetti` | 165 |
| `ui_family_counter` | 472 |
| `ui_win_ribbon` | 1710 |
| `ui_chapter_ribbon` | 1893 |

- **Text is the hot spot.** Each character gets about three `TextPainter` layouts per frame (`text_layer.dart:498, 531/546, 684`), plus a `copyWith`.
- **Other allocations each frame:**
  - a new `Paint` per fill (`fill_content.dart:87`);
  - a `LottieFrameInfo` per callback evaluation, with no value caching when a callback is set (`base_keyframe_animation.dart:109`);
  - two `Rect`s per image;
  - `computeMetrics().toList()` for trim paths (`base_stroke_content.dart:225/238`).
  - Paths are reused. Rule 8's "zero allocation" can't be met inside lottie, so record that as a deviation.
- **Mattes:** each costs 2 `saveLayer` calls plus 2 clear rects per frame (`base_layer.dart:230,246`), but only while the matted layer is on screen: `doll_complete` frames 0–19, `doll_reveal` 0–24, the glass padlock 0–13, and the splash loader for its full run. Opacity-to-layers is off, so there are no extra layers.
- **Scenarios:**
  - Complete + 9 sparkles + dust puff costs about 0.25 ms on the host, which is fine.
  - Win (15–20 `doll_win_dance` + confetti + win ribbon) costs about 3 ms on the host. That is tight on a low-end phone, so stagger the dolls and profile.
  - Paused rest frames (glass and ice in every locked slot) still redraw every Flame frame. Record a `Picture` once per slot and reuse it.
- **Pooling:** it works. Keep one drawable per concurrently visible instance, one shared composition, and delegates set once with closures that read mutable per-instance state (probe T13: image and scale changes apply at the same progress, with no key-path re-resolve).
- **RenderCache** needs a `RenderBox`, so it is widget-only. Its key includes the hash of the delegate closures.
  - `raster` counts pixels, not bytes (`store_raster.dart:123,132`), so the default of 50 M really means about 200 MB of RGBA. `doll_idle` at DPR 2.75 would be about 226 MB per colour. Don't use it except for tiny files (spinner, twinkle).
  - `drawingCommands` stores one `Picture` per progress value. It suits Home idle dolls if they share one `LottieDelegates` object per colour.
  - Both need `FrameRate` to not be `max`.
- **FrameRate:** `composition` (the default) steps at 60 fps. `max` renders sub-frames, which gives smoother 0.8–1.2× speeds and 120 Hz, but costs more and can't be cached. The 3.6.1 throttled ticker only applies to auto-play widgets without a controller.

### 5. Text and ARB localization (Q4)
- `LottieDelegates.text` is a per-drawable `String Function(String)`, called every frame for every text layer (2 calls per frame for the ribbon). The counter's '1 / 4' and '2 / 4' both pass through it each frame. `ValueDelegate.text(['layer'])` works per layer.
- Shrink text with `ValueDelegate.textSize` on both the label and its shadow (see section 1, item 4).
- Missing glyphs fall back per character to system fonts.
  - ja and hi will render. Grapheme clusters come from `characters` 1.4.1 (Unicode 16), so Devanagari conjuncts stay together.
  - Kerning is lost, and the direction is hard-coded LTR (`text_layer.dart:22`).
  - The bundled `Fredoka-Bold.ttf` has 320 codepoints and lacks ğ, ş and İ, which matters for the planned tr locale. It has no Devanagari, Kana or CJK.
- If the ribbons measure as janky, hide the text layers and draw a Flutter `Text` instead.

### 6. Web (Q5)
A release web build of `Lottie.asset` compiled, and the wasm dry run passed. lottie and archive use conditional `dart:io` imports.

### 7. Recommendation
Run board effects inside Flame through our own component. Use Flutter widgets for everything outside the board.

- **Inside Flame** (a `LottieFxComponent` wrapping `LottieDrawable`, driven by `BoardTimeline`): `doll_*`, `fx_select_glow`, `fx_glass_unlock`, `fx_ice`, `fx_dust_puff`, `fx_sparkle`, `ui_hint_arrow`, `ui_extra_slot`, `ui_drag_hand`.
- **As `Lottie` widgets:** `ui_family_counter`, `ui_booster_glow`, the win overlay (ribbon, confetti, `doll_win_hop`, coin burst), the chapter ribbon, toggle, spinner, splash loader, tap hand, `doll_idle` and `fx_twinkle`.

Why Flame for the board:
- **z-order:** a moving doll must go under or over shelves and neighbours. Nesting draws host lid, then guest, then host body. The glow ring sits under the doll. An overlay above the `GameWidget` can only draw on top.
- **Per-slot delegates and pooling:** these need direct access to the drawable.
- **Hand-off timing:** the timeline's `advance(dt)` sets progress in the same frame that hides the sprite, so there is no one-frame jump.
- **Cost:** one canvas, with no extra `RepaintBoundary`s, tickers or widget rebuilds.
- **Input:** components don't catch taps, so there is no `IgnorePointer` juggling.

Widgets suit the HUD and screens because a paused `RenderLottie` does not repaint and costs nothing.

**pubspec line for `apps/game/pubspec.yaml`** (add the same line to `apps/admin` only if it previews animations):
```yaml
  lottie: 3.6.1
```
Pin it exactly: it is 8 days old and our workarounds depend on its internals. Do not add `flame_lottie`; if you insist, use `flame_lottie: 0.4.3+23`.

**Suggested rule-9 reason for PROGRESS:** "lottie 3.6.1: pure-Dart Lottie player; owner decision that all animations are Lottie; latest version resolving with Flutter 3.41/Dart 3.11; adds archive 4.3.0 and posix 6.5.2; no locked versions change."

### Scratch files
Everything is in `/private/tmp/claude-501/-Users-utsav-Downloads-nesty/8a802507-1fb1-4775-b441-329bc52e16e7/scratchpad/`:
- `lottie_probe/test/probe_test.dart`, then `probe2_test.dart` through `probe6_test.dart` (probes T0–T17)
- `lottie_probe/lib/fx_component.dart` (the sketch component)
- `ws/` (the workspace resolution check)