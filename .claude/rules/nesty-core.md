---
name: nesty-core
description: Rules for packages/nesty_core — the only home of Nesty's game rules (pure Dart, deterministic).
paths:
  - "packages/nesty_core/**"
  - "tools/**"
---

# nesty_core rules

`nesty_core` is the **single implementation** of every game rule. The game,
the admin, the solver, the generator, the simulator and `tools/` all call it
(CLAUDE.md rule 2). If another package needs a rule, add it here and expose
it. Never re-implement it elsewhere, not even "just for the UI".

## Spec first — never invent rules

- The source of truth is `docs/GAME_SPEC.md`: §2 and §3 (mechanics), §4
  (formal rules and `tryMove`), §5 (level format and validation), §6 (solver,
  simulator, generator). Implement exactly what it says.
- If the spec is ambiguous or disagrees with the code, **stop and ask the
  user**. Write the question into `docs/PROGRESS.md`. Don't guess, and don't
  "improve" a rule.
- Cite the section in a comment (`// Spec §4: swallow — T goes inside M`).

## Pure Dart, platform-neutral

- No Flutter, Flame or `dart:ui`, and no `sdk: flutter` in the pubspec.
- `lib/` may use only `dart:` libraries that exist on both the VM and the web,
  because the admin runs Solve, Simulate and Playtest in the browser (spec §15).
  So no `dart:io` and no `dart:isolate`: isolates are the game's job (rule 8).
- `test/architecture_guard_test.dart` enforces all of this mechanically. Never
  weaken a guard to make code pass.
- **Web integers:** in the browser `int` is a JS number. Arithmetic is exact
  only to 2^53 and bitwise operators truncate to 32 bits. The solver's packed
  nest encoding and 64-bit canonical hash (spec §6.2) must give identical
  results on the VM and in dart2js/wasm. Design for that from the start, for
  example by hashing two 32-bit halves.

## Deterministic (CLAUDE.md rule 7, spec §6.5)

- The generator and simulator take an explicit `seed` and use core's own PRNG
  (xoshiro128** or PCG32). Never use `dart:math` `Random`, whose sequence may
  change between SDKs, and never read the clock (`DateTime.now()`, `Stopwatch`)
  inside core. The daily seed `yyyymmdd` (§7.5) and the bonus seed
  `1_000_000 + levelNumber` (§7.1) are computed by the app and passed in.
- The same seed and params must give byte-identical output. Any change that
  alters generated output **bumps `generatorVersion`**, because daily puzzles
  must match across devices on the same date (M3 acceptance).

## Model and API shape (spec §4, §13.1)

- Models are immutable with `==`/`hashCode`, hand-written with no codegen. The
  solver uses its own compact int state encoding. Open slots are
  interchangeable, so the canonical key sorts their contents (§6.2).
- Slot ids are stable: `r{row}c{col}`, plus `x{n}` for extra slots.
- `tryMove` returns a `MoveResult` with the new state and the `MoveEvent`s in
  the order the game animates them: `Picked`, `Placed`, `NestedInto(dstId, inside|swallow)`,
  `Revealed`, `Completed`, `Unlocked`, `IceCracked`/`IceShattered`, `Won`, `OutOfMoves`.
- Undo history is cleared whenever a set completes (§2.4).
- Solver budgets (§6.3): admin 500,000 nodes, hint 30,000, soft-stuck 20,000.
  When the budget runs out the result is **`unknown`, never `unsolvable`**.
- One validator (§5.3) serves both the admin and the game loader. Invalid
  levels are rejected in the admin and skipped with a log entry in the game.
- Apps import only `package:nesty_core/nesty_core.dart`, never `src/`. Export
  new public API from the barrel.

## Tests (must always pass; the Stop hook runs them)

- Every §4 rule has a unit test, **including invalid moves**.
- Solver fixtures go in `test/fixtures/` (known-solvable and known-unsolvable).
- The codec has round-trip tests and schema-validation tests (§5.3).
- Generator: the same seed and params give identical output, and every
  generated level validates and solves (M1: 100 levels).
- Run with `cd packages/nesty_core && dart test`. It is fast, so run it often.
