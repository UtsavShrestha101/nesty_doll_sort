# Plan: Lottie animations

Status: ready to start. Owner decision, 2026-09-26. Work it inside M2 (Playable game), then M3 for the meta screens.

Read first: `design/lottie/LOTTIE.md` (the contract for every file), `design/README.md` → Motion, `design/tokens.json` → `motion`, `sound`, `haptics`, and spec §11. Watch every file play in `design/prototypes/Lottie FX.dc.html`.

## Decision to record
Add the next D-number to `docs/PROGRESS.md` → Decisions: **Every animation in the design ships as Lottie** (28 files in `design/lottie/`). Widget transitions (button press, sheet, modal, tab lift, banners) stay Flutter animations using `tokens.motion.ui`. `BoardTimeline` still owns event order, SFX and haptic cues, but it draws doll motion and effects through these files instead of hand-coded tweens. `design/` stays owner-managed: never edit the JSON. Tune speed with the controller duration, or ask the owner for a new export.

## Steps

### P1. Packages
- Add `lottie` to `apps/game`. If board effects render inside Flame, also add `flame_lottie`. Neither is in spec §13.2, so write each rule-9 reason in PROGRESS → Package reasons. Pin versions that resolve with Flutter 3.41 and the locked `flame`.

### P2. Asset sync
- Extend `tools/lib/src/assets/design_asset_sync.dart` to copy `design/lottie/*.json` → `apps/game/assets/lottie/` and `design/lottie/images/*.png` → `apps/game/assets/lottie/images/`. Don't copy `LOTTIE.md`.
- Validate each JSON on sync: it parses, `fr == 60`, `w`/`h` match the LOTTIE.md table, and it has no expressions. Keep `--check` drift detection.
- Declare both folders in `apps/game/pubspec.yaml`. Extend `asset_manifest_test.dart` and the `tools/README.md` table.

### P3. FxLibrary
- Add `FxId`, an enum of the 28 file names, and `FxLibrary` (`@lazySingleton`). It loads every composition once, off the first frame (at splash), and exposes `LottieComposition? operator [](FxId id)`.
- A file that fails to load returns null. The caller then shows the rest pose, with no error UI (rule 3).
- Add `FxImages`, which maps image asset ids to `ui.Image`:
  - `doll_*`, `mover_*` and `target_*` lid/body come from the skin rasters (P4).
  - `doll_silhouette` is the wood silhouette.
  - `glow_ring`, `hint_arrow`, `extra_slot`, `glass_case_0…2` and `ice_0…3`/`ice_shatter` come from the board sprites already rasterized from `board/*.svg`.
  - `unlock_symbol` is the lock color's symbol in ink.
- Register a fake for tests (`AppEnv.fake`).

### P4. Doll layer rasters
- `SkinService` rasterizes two images per (skin, DollColor, symbols mode), each on the full 512×768 artboard:
  - **lid** = `top_mask` (tinted) + `face` + `top_detail` + `shine_top`
  - **body** = `shadow` + `bottom_mask` (tinted) + `bottom_detail` + `shine_bottom` + belly symbol
- Also rasterize the silhouette. Rasterize once and cache (rule 8). Gold uses the gradient-map tint.
- The Lottie scales them. Set the `<role>_size` null to dollHeight / 150 (LOTTIE.md → Doll size).

### P5. Board
- `BoardTimeline` plays `MoveEvent`s in order. For each event it starts the files listed in LOTTIE.md → "When each one plays", with the listed sound and haptic cues.
- While a doll animation runs, hide that doll's sprite and restore it on the last frame. First and last frames match the rest pose, so the hand-off has no jump.
- Implement `remapTravel` from LOTTIE.md for `doll_move`, `doll_complete`, `doll_invalid` and `ui_drag_hand`. Hover points are 0.50 × target height for nest and 1.06 × for swallow.
- Delegates: `doll_size` / `mover_size` / `target_size` scale, `rim_tint` = `DollSwatch.rimColor`, `tint` = `DollSwatch.base` (reveal drops).
- Segmented files: `doll_pick` (lift → wobble loop → settle), `fx_select_glow` (in → pulse → out), `fx_ice` (`crack_1/2/3`, `shatter`).
- A locked or iced slot renders `fx_glass_unlock` / `fx_ice` paused on its rest frame the whole time. Those files include the doll inside.
- Pool components per file (sparkle 9, dust 4, dolls one per slot, others 2). No allocation per frame.
- Reduced motion: speed × 2, no `fx_confetti`, and stop `doll_pick` after `lift` (no wobble).

### P6. HUD, overlays and meta screens
- Family counter: `ui_family_counter`, with a `TextDelegate` for `'1 / 4'` (now) and `'2 / 4'` (after the bump).
- Win overlay: `ui_win_ribbon` (localized text), `fx_confetti`, `doll_win_hop`, `fx_coin_burst` at 700 ms.
- Board HUD: `ui_hint_arrow`, `ui_booster_glow` behind Undo when soft stuck, `ui_extra_slot`.
- `ui_chapter_ribbon` on the first level of a new chapter (4.7).
- Settings and Pause toggles use `ui_toggle` segments `on`/`off`. Rest: off = frame 0, on = frame 11.
- `ui_spinner` for skin download (7.5). `ui_splash_loader` with `controller.value` = load progress.
- `ui_tap_hand` / `ui_drag_hand` in the Level 1–2 tutorial.
- `doll_idle` for the Splash and Home shelf dolls (speed 0.8–1.2, random phase). `fx_twinkle` wherever the flow shows twinkles.

### P7. Tests
- `remapTravel`: u = 0 at S, 1 at T, and an easeOutBack overshoot above 1.
- `FxLibrary` loads all 28 bundled files. Each file has its expected markers (`doll_pick`, `fx_select_glow`, `fx_ice`, `ui_toggle`, `ui_family_counter`) and image asset ids.
- Asset manifest and sync `--check`.
- `BoardTimeline`: for a scripted `MoveEvent` list, the right `FxId`s start in the right order with the right SFX and haptics (fake audio and haptics).

### P8. Docs
- BACKLOG: under M2, replace the hand-coded animation sub-items of `BoardTimeline` with the Lottie wiring above. Add the meta-screen items (Home, Splash, Settings toggle, Shop spinner) under M3, and speed tuning under M7.
- PROGRESS: the decision, package reasons, and open questions.
- `// TODO(M2)` or `// TODO(M3)` for anything deferred, then `dart run nesty_tools:todo_index`.

## Acceptance
- All 28 files ship in the bundle and play offline from first launch.
- Every event in LOTTIE.md plays its file with the listed sound and haptic, in `MoveEvent` order.
- Sprite ↔ Lottie hand-offs show no visible jump. Glass and ice slots look the same at rest as before.
- 60 fps on a 2 GB Android device with a Complete, sparkle trail and dust puff running together.
- Reduced motion is honored. `flutter analyze` is clean and all tests pass.

## Ask the owner (don't guess)
- Board effects inside Flame (`flame_lottie`) or as a Flutter overlay above the `GameWidget`? The recommendation is Flame, for z-order with the dolls.
- If a localized ribbon string needs more than 22 characters: shrink the font, or ask for a wider export?
