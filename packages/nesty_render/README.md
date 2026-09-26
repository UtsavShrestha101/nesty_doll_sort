# nesty_render

Flutter (no Flame) rendering shared by the Nesty game and the admin panel
([spec §13.1](../../docs/GAME_SPEC.md#131-packages)). The game draws through
it from Flame components; the admin's playtest board is a `CustomPainter` on
top of it, which is why Flame is not allowed here.

Game rules never live here. This package only turns `nesty_core` state into
pixels (CLAUDE.md rules 2 and 10).

## Status

Pre-M2 skeleton.

| API | Status | Spec |
|---|---|---|
| `DollPalette.of(DollColor)` returning a `DollSwatch` | Done. Exact §12.3 hex for the ten flat colors; gold uses a placeholder gradient | §12.3 |
| `DollRenderer` interface: `prepare`, `paintDoll`, `dispose` | Done (interface only), so a 3D renderer can be swapped in later | §12.6 |
| `PlaceholderDollPainter` | M2. The procedural doll, and the fallback if a skin fails to load | §12.5 |
| `BoardLayout` | M2. Pure layout math: slot width, doll height by size, pip bars | §10.3 |
| `SvgSkinRenderer`, `SkinCache` | M7. Rasterize skin layers once into cached `ui.Image`s, tint the mask layers | §12.2, §13.5 |

Waiting on design (`design/tokens.json`): the `ink` and `light` shade of every
doll color and the final gold gradient (see the `TODO(design)` notes).

## Rules for this package

- **No per-frame allocation** in paint paths (CLAUDE.md rule 8). Swatches are
  compile-time constants; renderers cache rasterized images in `prepare`.
- **Stable Flutter only**: no `flutter_scene` or Flutter GPU (CLAUDE.md rule 1).
- Colors and sizes come from here or from design tokens, never hard-coded in
  the apps.

## Testing

```
cd packages/nesty_render && flutter test
flutter analyze
```
