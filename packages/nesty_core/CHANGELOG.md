## Unreleased — M7 phase 3, star ratings (2026-09-29)

- `StarRating` (spec-prop §7.10, D125, D145): `threshold(par, slackPct)` =
  `par + ⌈par × slack ÷ 100⌉` in integers, `starsFor` (3★ at ≤ t3, 2★ at
  ≤ t2, else 1★; at most 2★ when assisted) and `starsForWin`, which reads
  the move count and the extra slots off a won board. `maxStars` 3,
  `minStars` 1, `assistedMaxStars` 2, and `maxSlackPct` 1000 (a technical
  bound that keeps `par × slack` exact on the web).
- `LevelBundleEntry.par` (D146): the solver's optimal moves, written after
  `rewardCoins` only when present (a par-less bundle encodes byte for byte
  as before) and read leniently: a bad par is one warning and no par, and
  the entry is kept.
- `Generator.version` stays 1: every golden and parity digest is unchanged.
- Tests: the threshold table (par 1–60 at 0/20/60/100 %), the bands, the
  cap, undo/restart/extra slots on a won board, the range errors; the
  codec's round trip, golden text and leniency; par equals the hand-worked
  optimum and an independent breadth-first search on every solvable fixture
  and the random rule-8 boards (`test/solver/par_oracle_test.dart`); web
  parity digests over 363,000 `starsFor` values and the lenient reads, from
  an independent Python reference (`test/rules/reference/starref.py`).

## Unreleased — M7 phase 2, vs Computer (2026-09-28)

- `RivalBot` and `RivalStep` (spec-prop §7.7): the race's computer rival,
  one allocation-free step at a time. It plays the simulator's casual or
  smart bot (`BotPlayer.stepRun`, now the body of `BotPlayer.play`'s loop),
  restarts a run that can't be won (no useful move, or the 250-move cap) as
  a step of its own, and seeds run `i` with
  `Prng.derive(raceSeed, 'RVL0' + bot, i)`, a stream apart from the
  generator's attempts and retries.
- `SimBot` is exported (`show SimBot`); `BotPlayer` and the engine stay
  internal.
- `DifficultyCurve.raceSeed` (`3 000 000 + rival × 100 000 + raceNo`),
  `racePolicy`, `raceTier`, `raceParams`, `raceRivals` and `maxRaceNo`.
- `Generator.version` stays 1: every golden and parity digest is unchanged.
- Tests: the rival against the simulator's runs, a mirrored `GameSession`,
  restarts, the race curve and three race goldens; parity digests from an
  independent Python reference (`test/simulator/reference/rivalref.py`) on
  the VM, node, Chrome and dart2wasm. Benchmarks: `rival_benchmark.dart`,
  `race_board_sweep.dart`.

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
