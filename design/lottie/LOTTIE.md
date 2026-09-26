# Lottie animations: Nesty: Doll Sort

For Claude Code. **Owner decision (2026-09-26): every animation in the design ships as Lottie.** This folder has 28 files that cover every animation in the flow (`prototypes/Nesty App Flow.dc.html`) and in `prototypes/Nesty Motion & Sound.dc.html`. Watch them all in `prototypes/Lottie FX.dc.html`. Timings come from `tokens.json` → `motion`. Sounds and haptics come from `tokens.json` → `sound` and `haptics`.

**Not Lottie:** widget transitions that wrap live content, such as button press, sheet in, modal in, tab lift and banners. They stay Flutter animations using `tokens.motion.ui`. Combo is sound-only. The dashed hint arc and the tutorial arc are static paths.

## Format
- Lottie 5.7 schema, 60 fps, transparent background. 1 canvas px = 1 dp at 390×844.
- Allowed features: shape, null, image, precomp and text layers, plus track mattes. The shine, the reveal wipe, the padlock ping and the loader stripes use mattes. No expressions, effects or merge paths.
- There are three kinds of file:
  - **In place.** The canvas surrounds one slot. Put the file's anchor point on the game point (table below). In Flame that is `Anchor(ax / w, ay / h)`.
  - **Board space** (390×844, placed over the board at 0,0): `doll_move`, `doll_complete`, `doll_invalid`, `ui_drag_hand`. A null named `travel` is authored between fixed points S and T. Remap it at runtime (see "Travel remap").
  - **Segmented.** Markers name the segments. Play one segment per event, and pause on a segment's first frame for the resting state.

## Files
| File | Canvas | Anchor | Length | Segments |
|---|---|---|---|---|
| `doll_pick` | 160×260 | doll base (80, 230) | 41 f | `lift` 0–7, `wobble` 7–31 (loop), `settle` 31–41 |
| `doll_move` | board | travel S (100, 500) → T (300, 500) | 16 f | |
| `doll_nest` | 160×260 | target base (80, 230) | 24 f | |
| `doll_swallow` | 180×380 | small target base (90, 350) | 24 f | |
| `doll_complete` | board | travel S (100, 650) → T (195, 144) | 75 f | |
| `doll_invalid` | board | travel S (100, 500) → T (300, 500), `target_pos` (300, 500) | 36 f | |
| `doll_reveal` | 160×260 | doll base (80, 230) | 24 f | |
| `doll_idle` | 160×260 | doll base (80, 230) | 180 f, loop | |
| `doll_win_dance` | 160×260 | doll base (80, 230) | 84 f, loop | |
| `doll_win_hop` | 160×260 | doll base (80, 230) | 78 f, loop | |
| `fx_select_glow` | 140×80 | ring center (70, 40) = (slot cx, stand surface − 2) | 113 f | `in` 0–7, `pulse` 7–103 (loop), `out` 103–113 |
| `fx_glass_unlock` | 180×240 | case top-left at (47, 40); doll base (90, 163) | 54 f | |
| `fx_ice` | 180×240 | ice top-left at (42, 40); doll base (90, 170.8) | 81 f | `crack_1` 0, `crack_2` 16, `crack_3` 32, `shatter` 48 |
| `fx_dust_puff` | 160×80 | stand surface under the doll (80, 62) | 24 f | |
| `fx_sparkle` | 64×64 | center (32, 32) | 16 f | |
| `fx_confetti` | 390×844 | full screen; bursts from (195, 190) | 102 f | |
| `fx_coin_burst` | 160×140 | coin in the "+25" pill (80, 100) | 40 f | |
| `fx_twinkle` | 32×32 | center (16, 16) | 120 f, loop | |
| `ui_family_counter` | 120×60 | counter center (60, 30) = (195, 129) | 12 f | `bump` 0–12 |
| `ui_hint_arrow` | 60×80 | arrow center at rest (30, 45) | 54 f, loop | |
| `ui_extra_slot` | 110×50 | stand center (55, 25) | 96 f, loop | |
| `ui_booster_glow` | 130×110 | booster center (65, 55); draw it behind the button | 84 f, loop | |
| `ui_win_ribbon` | 360×110 | ribbon center (180, 55) | 18 f, then hold | |
| `ui_chapter_ribbon` | 360×100 | ribbon center (180, 50) | 156 f | |
| `ui_toggle` | 54×30 | toggle box | 22 f | `on` 0–11, `off` 11–22; rest off = 0, on = 11 |
| `ui_spinner` | 16×16 | center | 54 f, loop | |
| `ui_splash_loader` | 278×22 | bar box (left/right 56, y 690) | 100 f | frame = load progress % |
| `ui_tap_hand` | 128×144 | fingertip (48, 32) on the target | 72 f, loop | |
| `ui_drag_hand` | board | travel S (100, 500) → T (300, 500) | 144 f, loop | |

## When each one plays
Play events in `MoveEvent` order. The board timeline starts each file, and a Lottie never changes game state. Times are ms from the event.

| Event | Lottie | Sound | Haptic |
|---|---|---|---|
| Picked | `doll_pick` lift, then wobble loop; `fx_select_glow` in, then pulse | `pick` @0 | light |
| Deselected | `doll_pick` settle; `fx_select_glow` out | none | none |
| Placed | `doll_move` (dst = target base) | `whoosh` @0 | none |
| NestedInto | `doll_move` (dst = hover), then `doll_nest` or `doll_swallow` | `whoosh` @0, `clack_*` when the lid shuts (nest/swallow +270) | medium at the clack |
| Revealed | `doll_reveal`, once the moving top nest has lifted off | none (the move carries `whoosh`) | none |
| Completed | `doll_complete`; `fx_dust_puff` @700; `fx_sparkle` every 60 ms from 700 to 1250; `ui_family_counter` bump and a 1.5× `fx_sparkle` @1250 | `complete_{comboStep}` @0 | success @0 |
| Unlocked | `fx_glass_unlock` | `unlock_glass` @0 | medium @0 |
| IceCracked | `fx_ice` segment `crack_n` (n = cracks so far) | `ice_crack` @0 | light |
| IceShattered | `fx_ice` segment `shatter` | `ice_shatter` @0 | none |
| Invalid move | `doll_invalid` | `bonk` @180 | soft error @180 |
| Won | `doll_win_dance` on every board doll (120 ms stagger), `fx_confetti`, `ui_win_ribbon` | `win` @0 | success |
| Win overlay | `doll_win_hop` per plank family (150 ms stagger); `fx_coin_burst` @700 | `coins` @700 | none |
| Hint | `ui_hint_arrow` over the source; `fx_select_glow` on the target | none | none |
| Soft stuck | `ui_booster_glow` behind Undo | none | none |
| +1 Slot added | `ui_extra_slot` | `button` | selection |
| New chapter (4.7) | `ui_chapter_ribbon` | none | none |
| Splash, Home | `doll_idle` per shelf doll (speed 0.8–1.2, random phase); `fx_twinkle`; `ui_splash_loader` | none | none |
| Win, Chapter complete, Shop | `fx_twinkle` (2.0–2.4 s, random phase) | none | none |
| Settings / Pause toggle | `ui_toggle` on or off | `button` | selection |
| Skin downloading (7.5) | `ui_spinner` | none | none |
| Tutorial 1.3 / 1.4, 1.6 | `ui_tap_hand`, `ui_drag_hand` | none | none |

## Image slots
Every doll and board piece is an image slot. The game fills each one with its own raster through `LottieDelegates(image: (composition, asset) => …)`, keyed by `asset.id`. `images/*.png` are placeholders (Cherry classic doll and board art) so that the files also play standalone.

| Asset id | What the game supplies |
|---|---|
| `doll_lid`, `mover_lid`, `target_lid` | The lid raster: `top_mask` (tinted), `face`, `top_detail` and `shine_top`, on the full 512×768 skin artboard |
| `doll_body`, `mover_body`, `target_body` | The body raster: `shadow`, `bottom_mask` (tinted), `bottom_detail`, `shine_bottom` and the belly symbol, on the full 512×768 artboard |
| `doll_silhouette` | The wood silhouette of the buried nest (512×768) |
| `glow_ring`, `hint_arrow`, `extra_slot` | `board/*.svg` rasters at 116×52, 40×50 and 90×34 dp |
| `glass_case_0/1/2`, `unlock_symbol` | Glass case frames (86×143) and the unlock color's symbol in ink (12×12) |
| `ice_0` … `ice_3`, `ice_shatter` | Ice frames (96×160) |

## Doll size, rim and tint
- **Size:** every doll has a null named `<role>_size`, where role is `doll`, `mover` or `target`. At 100 % the doll is 150 dp tall (size 6 on a 3-shelf board). Override it with `ValueDelegate.transformScale(const ['doll_size'], value: Offset(k, k))`, where k = dollHeight / 150. In `doll_nest` and `doll_swallow`, `mover_size` sits inside `target_size`, so give it moverHeight / targetHeight. Lift, hop, shake and arc distances stay in absolute dp. Lid lift and squash follow the doll's size.
- **Hover points:** nest ends the move with the mover's base 0.50 × target height above the target base, and swallow uses 1.06 × target height.
- **Rim:** fills named `rim_tint` take `DollSwatch.rimColor`.
- **Tint:** fills named `tint` take `DollSwatch.base` in `doll_reveal`, and `#FFF3B0` or `#F5B418` in `fx_twinkle`. Use `ValueDelegate.color(const ['**', 'tint'], value: c)`.

## Travel remap
Board-space files move a `travel` null from S to T. At runtime, map its authored position onto the real points by projecting it on S→T, so that the authored easing and overshoot are kept:

```dart
Offset remapTravel(LottieFrameInfo<Offset> f, Offset src, Offset dst, Offset s, Offset t) {
  final v = Offset.lerp(f.startValue, f.endValue, f.interpolatedKeyframeProgress)!;
  final st = t - s;
  final u = ((v - s).dx * st.dx + (v - s).dy * st.dy) / st.distanceSquared;
  return src + (dst - src) * u;
}

LottieDelegates(
  image: (composition, asset) => dollRasters.forAsset(asset.id),
  values: [
    ValueDelegate.transformPosition(const ['travel'],
        callback: (f) => remapTravel(f, src, dst, const Offset(100, 500), const Offset(300, 500))),
    ValueDelegate.transformScale(const ['doll_size'], value: Offset(k, k)),
  ],
)
```

| File | src | dst |
|---|---|---|
| `doll_move` | source doll base | target base (Placed), or the hover point (nest, swallow) |
| `doll_complete` | doll base | family counter center + (0, 0.1 × dollHeight) |
| `doll_invalid` | source doll base | target base − 0.5 × target height; also set `target_pos` to the target base |
| `ui_drag_hand` | tap point on the big doll | target surface − 0.4 × target height |

## Text layers
`ui_family_counter`, `ui_win_ribbon` and `ui_chapter_ribbon` use Fredoka Bold text layers. Swap the text with `LottieDelegates(text: (initial) => …)`, keyed by the authored text:
- Family counter: `'1 / 4'` → the current count, `'2 / 4'` → the count after the bump. The two swap at the peak.
- Ribbons: `'Level Complete!'` and `'CHAPTER 4 · Snowy Cabin'` → the localized ARB strings. The bands fit about 22 characters. For longer strings, shrink the font with a `textStyle` delegate.

## Rendering contract
- At rest the board draws sprites. While a doll animation plays, hide that doll's sprite and let the Lottie draw it. The first and last frames match the rest pose.
- A locked or iced slot draws its `fx_glass_unlock` / `fx_ice` composition paused on the rest frame (frame 0, or the current crack's segment start) the whole time. These files include the doll inside, so don't draw that sprite separately.

## Flutter and Flame
- **Packages:** `lottie` (widgets) and `flame_lottie` (board components). Neither is in spec §13.2, so write the rule-9 reason in `docs/PROGRESS.md` → Package reasons. Pin versions that resolve with the locked `flame` and Flutter 3.41.
- **Loading:** load each composition once at startup into an injectable `FxLibrary` (`@lazySingleton`). If a file fails to load, skip that animation and show the rest pose (rule 3).
- **Performance (rule 8):** pool components per file (sparkle 9, dust 4, dolls one per slot, others 2). Rasterize the doll layers once per skin, color and size, and reuse those images in every image delegate. No allocation per frame.
- **Reduced motion:** play everything at 2× speed (duration × 0.5), skip `fx_confetti`, and stop `doll_pick` on the last frame of `lift` instead of looping `wobble`.

## Asset pipeline
- Ship `design/lottie/*.json` and `design/lottie/images/` to `apps/game/assets/lottie/`. Extend `sync_design_assets` (folder list and `--check`), declare both folders in `apps/game/pubspec.yaml`, and extend `asset_manifest_test.dart`. When syncing, check that each JSON parses, `fr` is 60 and `w`/`h` match the table.
- `design/` is owner-managed. Don't edit these files. Tune speed with the controller duration, or ask the owner for a new export.
- Track the work in `docs/BACKLOG.md` under the milestone that builds `BoardTimeline` (M2), and add a PROGRESS decision entry for "all animations are Lottie".
