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
