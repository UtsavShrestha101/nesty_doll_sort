## 0.2.0 — M1 (2026-09-26)

- Models: `Doll`, `Nest`, `OpenSlot` / `TowerSlot` / `LockedSlot` with ice,
  `Level`, `GameState` (a packed kernel board with model views), `Move`,
  `MoveEvent`s, `MoveResult`, `UndoEntry` / `UndoResult` / `ExtraSlotAdded`.
- One allocation-free §4 kernel (`src/rules/engine/`) behind `Rules`,
  `GameSession`, the solver, the simulator and the generator. Events in the §4
  order (destination `Revealed` after `Completed`, A2).
- `GameSession`: undo cleared on completion, restart, up to 2 extra slots on
  the bottom shelf kept through undo and restart (D22), `restore(...,
  undosUsed:)` for the M3 save.
- `LevelCodec` and `LevelBundleCodec`: strict, integers by value, issues with
  JSON pointers and ARB args; unknown keys reported in code-unit order and no
  parser text in args, so the VM and the web agree (review DETERMINISM-002).
- `Validator`: rules 1–8 and value checks, including ice ≤ `LayoutLimits.maxIce`
  (2^31 − 1) so a counter can't wrap in the engine (review SPEC-02); rule 8
  defaults to `Solver.solve`.
- Solver: A* over canonical boards with the §6.3 pruning, budgets, hints with
  the A3 fallback, `SolverRun`, `SolverSnapshot` (v1; decode rejects cells that
  contradict `completedSets`, review DETERMINISM-008). The node arena grows in
  chunks (no copy, no 1.5× peak), and `peakBytes` bounds the search's memory
  (review DETERMINISM-005).
- Simulator: casual and smart bots, 300 seeded runs, integer tier edges,
  expert only below half.
- Generator and `DifficultyCurve` (default stage table, A16, owner-confirmable).
- `Prng` (xoshiro128** + splitmix32 seeding, `derive`) and `Hash64` (two
  MurmurHash3_x86_32 halves), pinned by independent reference vectors.
- Tests: ~1,330 on the VM, parity suites on node, Chrome and dart2wasm, and
  architecture guards for web-safe arithmetic (`~`, 64-bit typed lists,
  `HashMap`/`HashSet`; review DETERMINISM-007).

## 0.1.0 — skeleton

- Pre-M1 architecture skeleton (M0, 2026-09-25). No game rules, codec,
  solver, simulator or generator yet; those are M1 (spec §18).
- `DollColor`: the 11 colors of spec §12.3 in table order, with a stable codec
  `id` (spec §5.1), an `isWild` flag for gold (spec §3.5) and a strict
  `fromId` that throws `FormatException` for unknown ids.
- Architecture guard test: fails if `lib/` imports Flutter, Flame, `dart:ui` or
  a platform-specific `dart:` library, references `dart:math` `Random`,
  constructs an unseeded `Random`, or reads the wall clock (CLAUDE.md rules 2
  and 7, spec §6.5).
- README documents the planned M1 module layout; `test/fixtures/README.md`
  documents the solver fixture convention.
