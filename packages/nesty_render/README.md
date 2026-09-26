# nesty_render

Flutter (no Flame) rendering shared by the Nesty game and the admin panel
([spec §13.1](../../docs/GAME_SPEC.md#131-packages)). The game draws through
it from Flame components; the admin's playtest board is a `CustomPainter` on
top of it, which is why Flame is not allowed here.

Game rules never live here. This package only turns `nesty_core` state into
pixels (CLAUDE.md rules 2 and 10). The design is
[docs/plans/design-foundation-m2-design.md](../../docs/plans/design-foundation-m2-design.md)
§1; decisions are D36–D38 in [docs/PROGRESS.md](../../docs/PROGRESS.md).

## Status

The design-foundation render work (plan phase 3, R1–R3) is done. The Flame
components that use it are M2 phase 4.

| Area | API | Spec |
|---|---|---|
| Palette | `DollPalette.of(DollColor)` → `DollSwatch` (base, ink, light, symbol, rim, modulate or gold gradient-map tint) from the generated tokens | §12.3, D19 |
| Skin pipeline | `SkinManifest`, `SkinSvgSplitter` (pure Dart), `SvgColorRewriter`, `AssetBundleSkinLoader`, `SkinRasterizer` (crop probe, whole-pixel crops), `SkinCache` (LRU, 16 MB), `SymbolAtlas` | §12.2 |
| Dolls | `DollRenderer` (`prepare`, `isReadyFor`, `canPaint`, `paint`, `dispose`) with `DollPaintParams`; `SvgSkinRenderer`, `PlaceholderDollPainter` (§12.5 fallback), `FallbackDollRenderer`, `DollPainter` (CustomPainter) | §12.5, §12.6 |
| Board layout | `BoardLayout.compute(BoardShape, BoardViewport)` → `BoardGeometry` (pure math: planks, stands, pips, glass, ice, tags, glow, hint, buried silhouettes, 48 dp column hit rects, extra-slot re-pitch) | §10.3, D21, D22 |
| Board art | `BoardSpriteLibrary` (parsed once) and `BoardSprites` (one board's images, eager + lazy frames), `DebugBoardPainter` (a static board for previews) | plan P3 |
| Themes | `ChapterTheme`, `ThemeBackground` (cover-fit, rasterized once, DPR ≤ 2, fallback colour) | §12.4 |

### Nest z-order

A nest draws one doll in passes around the other (`DollPart`), as the
design's nest frame does: nesting inside = host `lid` → host `interior` →
guest `full` with `shadow: false` → host `bodyFront`; swallow = moving `lid`
→ moving `interior` → target `full` → moving `bodyFront` (`shadow: false`
while in the air). `body` + `lid` is `full`.

### Re-layout

An extra slot re-pitches the bottom row and changes every doll's height. Call
`renderer.prepare(heights: newGeometry.dollHeights, …)` and
`sprites.prepare(newGeometry, …)`, then swap the geometry. Until then
`FallbackDollRenderer` keeps the skin on screen (`canPaint`: any prepared
raster, resampled) and `BoardSprites.image` returns the nearest held scale.
Animations scale the destination rect and pass the resting scale.

## Rules for this package

- **No per-frame allocation** in paint paths (CLAUDE.md rule 8). Every
  per-frame method sits between `// ── Hot path` markers, and
  `test/doll/hot_path_allocation_test.dart` scans them for allocating code.
- **Pure layout:** `lib/src/board/` layout files import only `dart:math`,
  `dart:ui`, `flutter/foundation`, `flutter/painting` and the tokens
  (`test/board/board_purity_test.dart`).
- **Stable Flutter only**: no `flutter_scene` or Flutter GPU (CLAUDE.md rule 1).
- Colors and sizes come from the generated tokens (`render_tokens.gen.dart`,
  never edited by hand), never hard-coded in the apps.

## Testing

```
cd packages/nesty_render && flutter test
flutter analyze --fatal-infos --fatal-warnings    # from the repo root
```

- `BoardLayout` against NestyBoard at 390×844 (±0.5), five screen sizes, and
  crowded undesigned boards (no collisions; sealed and frozen dolls keep the
  design's proportions; top-shelf silhouettes stay under the HUD).
- Renderer goldens without committed binaries: each classic reference render
  in `design/skins/classic/renders/` rasterized with flutter_svg and compared
  with `SvgSkinRenderer` (≥ 99.9 % of pixels within 8/255, mean < 0.5/255,
  plus a gate on the belly-symbol box), with negative controls.
- Splitter, rewriter, manifest, loader, palette parity, sprites, themes.
