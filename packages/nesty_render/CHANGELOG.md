## 0.2.0 — design foundation render (2026-09-26)

- Replaced the M0 `DollPalette` and `DollRenderer`: swatches from the
  generated tokens (gold as a gradient-map tint), and the `DollRenderer` API
  of design §1 with `DollPaintParams`, `DollPart` and `DollSymbols`.
- Skin pipeline: `SkinManifest`, `SkinSvgSplitter`, `SvgColorRewriter`,
  `AssetBundleSkinLoader`, `SkinRasterizer`, `SkinImageSet`, `SkinCache`,
  `SymbolAtlas`, and the `svg_raster` helpers.
- Renderers: `SvgSkinRenderer`, `PlaceholderDollPainter`,
  `FallbackDollRenderer`, `DollPainter`.
- `BoardLayout` / `BoardGeometry` (pure math), `BoardSprites`,
  `ThemeBackground`, `ChapterTheme`, `DebugBoardPainter`.
- Review fixes:
  - `DollPart.interior` and `DollPart.bodyFront`, and
    `DollPaintParams.shadow`, so a doll going into another covers the hollow
    instead of the rim painting across it (RENDER-1).
  - `DollRenderer.canPaint`: `FallbackDollRenderer` keeps the skin (resampled)
    for heights not prepared yet, so a re-layout no longer flashes the
    placeholder (RENDER-2).
  - On 5–6-slot rows the dolls shrink with the stands, cases and ice, so a
    sealed or frozen doll keeps fitting (RENDER-3).
  - `SlotGeometry.buriedBaseY(depth, buried:)`: top-shelf towers compress the
    18 dp step so silhouettes stay under the HUD (RENDER-4).
  - Golden gate tightened to ≥ 99.9 % / mean < 0.5, with a symbol-box gate and
    subtle-symbol negative controls (RENDER-5).
  - `BoardSprites.image` rasterizes a missed scale only when nothing held is
    within 10 % (RENDER-6).
  - The hot-path allocation guard also flags typed lists, `Offset & Size`,
    Rect/Offset makers, image/mask filters and closures (RENDER-8).
  - Upright, unscaled dolls land on whole device pixels (RENDER-9).

## 0.1.0 — skeleton

- Pre-M2 architecture skeleton (M0, 2026-09-25). No painters or layout math
  yet; those are M2 and M7 (spec §18).
- `DollPalette` / `DollSwatch`: every `DollColor` mapped to the exact spec §12.3
  hex values; gold uses a placeholder gradient until `design/tokens.json`
  exists.
- `DollRenderer`: the rendering interface of spec §12.6 (`prepare`,
  `paintDoll`, `dispose`). Implementations arrive in M2 (placeholder painter)
  and M7 (SVG skins).
- Removed the template `Calculator` class.
