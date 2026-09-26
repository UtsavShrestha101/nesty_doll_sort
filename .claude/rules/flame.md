---
name: flame
description: Flame 1.38 board rules — render core state, never own truth, zero per-frame allocation.
paths:
  - "apps/game/lib/features/gameplay/**"
  - "packages/nesty_render/**"
---

# Flame and rendering rules

## Flame renders, core decides (CLAUDE.md rules 2 and 10)

- `NestyGame` (`features/gameplay/game/nesty_game.dart`) hosts `BoardComponent`,
  `SlotComponent`, `NestComponent` and `FxLayer` (spec §13.1). **No component
  holds game truth.** Each renders the latest `nesty_core` state handed down by
  the gameplay controller (a cubit/bloc wrapping `GameSession`) and animates the
  `MoveEvent`s of the last move **in the order core emitted them** (spec §4).
- Input is only forwarded. Tap-tap and drag (§2.2) become intents such as
  "picked r0c1" or "dropped on r1c2", sent to the controller. A component never
  decides whether a move is legal. It plays the `Invalid` shake when core
  says so.
- Menus, sheets, popups, the top bar and the booster bar are Flutter widgets
  around the `GameWidget` (§13.1), not Flame components.
- Layout comes from `nesty_render`'s `BoardLayout` (§10.3), shared with the
  admin's `CustomPainter` board. Don't duplicate layout math in a component.
  The hit area is the whole slot column, at least 48 dp.
- `nesty_render` must not import Flame, because the admin uses it with a plain
  `CustomPainter`.

## 60 fps on a 2 GB Android phone (CLAUDE.md rule 8)

Nothing inside `update(dt)`, `render(canvas)` or `DollRenderer.paintDoll` may
allocate on the steady-state path:

- Create `Paint`, `Path`, `Rect`, `RRect`, gradients, `ColorFilter` and
  `TextPainter`/`TextPaint` objects once, as fields. Mutate or reuse them.
- Reuse `Vector2`s (`setFrom`, `setValues`) instead of `Vector2(...)` or
  `a + b` in `update`.
- No `map`, `where`, `toList()`, spread, closures or string interpolation in
  `update`/`render`. Iterate with indexed loops over pre-sized lists.
- Rasterize skins **once** per needed size into cached `ui.Image`s
  (`DollRenderer.prepare`, `SkinCache`, spec §12.2, §13.5). Never rasterize an
  SVG or `Picture` per frame. Tint with a cached
  `ColorFilter.mode(color, BlendMode.modulate)`.
- Effects (§11.1) are short-lived. Remove them when they finish and cap
  particle counts (confetti, sparkles). Reduced motion (§16) shortens
  animations and removes screen shake.
- The solver (hint, soft-stuck) runs in an isolate, never on the UI thread and
  never inside `update`.
- Keep Impeller (the default). Don't pass `--no-enable-impeller` unless a
  profile-mode measurement on a real low-end device justifies it.

## Art and fallbacks

- Before art exists, dolls are drawn by the procedural `PlaceholderDollPainter`
  (spec §12.5, M2). It remains the fallback whenever a skin fails to load.
- Colors come from the doll palette (`nesty_render` `doll_palette.dart`, spec
  §12.3) and every doll draws its color symbol (§16 accessibility).
- Missing design → use `design/tokens.json` and spec §12, and leave
  `// TODO(design): ...`. Never write into `design/`.

## Verifying

- Measure in **profile mode on a physical device** (VS Code config "Game [DEV]
  (profile mode, physical device)", or the `/perf-profile` skill). Debug mode
  and simulators don't count.
- Widget-test `GameplayPage` with fake services. Adding `flame_test` needs a
  reason in `docs/PROGRESS.md` (rule 9).
