---
name: perf-profile
description: |
  Profile a Nesty flow against the 60 fps / 2 GB Android budget (CLAUDE.md rule 8):
  frame times, per-frame allocation in Flame update/render, skin rasterization,
  solver off the UI isolate, rebuild storms around the GameWidget. Mostly
  coordination: the user runs a profile build on a physical device and shares
  numbers. Triggered by "/perf-profile <flow>", "the board is janky".
argument-hint: "<flow, e.g. \"level 12 drop + nest animation\" or \"home -> gameplay\">"
---

# /perf-profile: find what is slow and why

## Budget
- **60 fps on a low-end Android phone with 2 GB RAM** (CLAUDE.md rule 8). That
  means under 16.7 ms per frame on both the UI and the raster thread, with no
  GC-driven spikes during a move.
- M2 acceptance (spec §18): levels 1–30 at 60 fps on a mid-range Android. The
  2 GB phone is the stricter bar, so measure there.
- The solver (hint, soft-stuck) never costs a frame: it runs in an isolate.

## When to use
- A board animation, drag or screen transition stutters.
- After a Flame, `nesty_render` or gameplay-cubit change, to confirm there is no regression.
- M2 and M8 acceptance (performance profiling).

## Steps

### 1. Set up
- A **physical** device. Emulators and simulators don't count. Get the model,
  RAM and Android version, and prefer the 2 GB phone.
- **Profile mode** only. Debug numbers are meaningless.
  ```bash
  cd apps/game && flutter run --profile --flavor dev -t lib/main_dev.dart
  ```
  In VS Code, use "Game [DEV] (profile mode, physical device)". Keep Impeller
  (the default). Don't pass `--no-enable-impeller` without a measurement that justifies it.
- Open DevTools from the `flutter run` output, or press `P` in the terminal
  for the performance overlay.

### 2. Baseline
Play the exact flow 3 times and record:
- Frame times (DevTools Performance): average, worst, and the count over 16 ms,
  split into UI and raster.
- Memory (DevTools Memory): heap before and after 10 moves, and GC events during a move.
- What the user sees ("the stutter is on the lid lift").

### 3. Hypotheses
Cast a wide net, as in `/debug`. The usual Nesty suspects:
1. **Per-frame allocation** in `update(dt)`, `render(canvas)` or
   `DollRenderer.paintDoll`: `Paint()`, `Path()`, `Vector2(...)`, `a + b` on
   vectors, `toList()`, `map`/`where`, closures, string interpolation.
2. **Rasterizing every frame**: SVG or `Picture` drawn instead of a cached
   `ui.Image` (spec §12.2, §13.5), `Picture.toImage` or
   `TextPainter.layout()` inside `render`.
3. **Solver on the UI isolate**: a hint or soft-stuck search that is not in an
   isolate, or that is started inside `update`.
4. **Rebuild storms around the board**: a `BlocBuilder` above the `GameWidget`
   rebuilding on every emit (use `buildWhen` / `BlocSelector`), or the
   `NestyGame` instance created in `build`.
5. **Unbounded effects**: confetti or sparkles without a particle cap, or
   effects never removed when they finish (§11.1).
6. **I/O on the UI thread**: the save on every move (§13.3) or a Hive write on
   the hot path that blocks.
7. **Memory pressure** on 2 GB: oversized skin rasters, images cached at
   every size, or an unbounded image cache.

### 4. Investigate (cheapest check first)
- CPU profiler (profile mode) on the janky frame: which `update`/`render` is hot?
- Allocation audit of the hot paths:
  ```bash
  grep -nE 'Paint\(|Path\(|Vector2\(|toList\(|\.map\(|\.where\(|TextPainter\(' \
    -r apps/game/lib/features/gameplay/game/ packages/nesty_render/lib/
  ```
  A hit inside `update`, `render` or `paintDoll` is a finding. A hit in a
  constructor or `onLoad` is fine.
- Isolate check: `grep -rnE 'Isolate\.run|compute\(' apps/game/lib/`. The
  solver call must go through one of them.
- DevTools "Track widget rebuilds" on the gameplay page while dragging.

### 5. Fix the biggest thing first
One change, re-measure, repeat. Hand Flame and `nesty_render` changes to
`flame-engineer` and solver changes to `nesty-core-engineer`. A core
optimization must keep every `nesty_core` test green and the generator output
byte-identical, or bump `generatorVersion` (spec §6.5).

### 6. Record the numbers
Write device, flavor, build mode, date, baseline, change and result to
`docs/perf/<flow>.md`, and link it from the current milestone's section of
`docs/PROGRESS.md`.

## Output
```
## Flow
<description> · device <model, RAM, Android version> · profile · flavor dev

## Baseline
- UI avg / worst: <x> / <y> ms · raster avg / worst: <x> / <y> ms · frames > 16 ms: <n>
- Heap: <before> → <after 10 moves>; GCs during a move: <n>

## Hypotheses tested
1. <h> — <evidence>

## Top finding
<path:line — issue — fix>

## After the fix
<same numbers>, or "not measured"
```

## Anti-patterns
- Profiling in debug mode, or on an emulator, a simulator or a flagship phone only.
- Claiming "60 fps" without a device, a build mode and numbers.
- `RepaintBoundary` everywhere without measuring. It can cost more than it saves.
- Optimizing without a baseline, or several changes per measurement.
- Speeding up a core rule by changing its behavior.
