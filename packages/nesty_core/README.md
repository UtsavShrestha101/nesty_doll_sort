# nesty_core

Pure-Dart game rules for **Nesty: Doll Sort**: models, level codec, validator,
rules, game session, solver, simulator, generator and PRNG
([spec §13.1](../../docs/GAME_SPEC.md#131-packages)).

The mobile game, the Flutter Web admin, the level tools (`nesty_levels`), the
solver, the generator and the simulator all call the functions in this
package, so every rule is written exactly once (CLAUDE.md rule 2). The design
is [docs/plans/m1-core-design.md](../../docs/plans/m1-core-design.md); the
decisions taken while building it are D26–D39 in
[docs/PROGRESS.md](../../docs/PROGRESS.md).

## Status

M1 is done (2026-09-26, spec §18): every §4 rule is unit-tested, the solver
fixtures pass, the generator is deterministic on the VM, node, Chrome and
dart2wasm, and 100 generated bonus levels pass validation rules 1–8 and
replay to a win. Open owner questions and the benchmark numbers are in
PROGRESS.

## Hard rules for this package

| Rule | Why | Enforced by |
|---|---|---|
| No Flutter, Flame or `dart:ui` imports | Game, web admin and VM tools share one rule set (CLAUDE.md rule 2) | `test/architecture_guard_test.dart` |
| Only platform-neutral `dart:` libraries (no `dart:io`, `dart:isolate`, `dart:html`, ...) | Core runs in the web admin (Solve / Simulate / Playtest, §15) and on mobile | `test/architecture_guard_test.dart` |
| No `dart:math` `Random`, never an unseeded generator | Its sequence may change between SDK versions, which would change generated and daily levels (§6.5, CLAUDE.md rule 7) | `test/architecture_guard_test.dart` |
| No clock: `DateTime.now()`, `DateTime.timestamp()` or `Stopwatch` | Determinism: dates and seeds are passed in by the caller (§7.5, CLAUDE.md rule 7). Solver budgets are node counts (§6.3), so a time-based cutoff would make results depend on device speed | `test/architecture_guard_test.dart` |
| Web-safe 32-bit arithmetic: no `~`, no 64-bit typed lists, no `HashMap`/`HashSet` | dart2js numbers differ from the VM's for `~x` and for products above 2^53; 64-bit lists don't exist in dart2js; hash order isn't portable (design §3, Q9) | `test/architecture_guard_test.dart` + the parity suites on node, Chrome and wasm (CI) |
| Immutable models with `==` / `hashCode` | Undo history and solver states compare by value (CLAUDE.md "Code style") | review |
| No code generation, no dependencies | Keeps core a plain Dart package with no build step | review |

The guards scan `lib/**.dart` with a small lexer (`test/support/`) that
ignores comments and string contents, and `test/support/core_guards_test.dart`
proves each guard fires on offending code.

## Layout

```
lib/
  nesty_core.dart            # barrel (engine internals and util are not exported)
  src/
    models/                  # Doll, Nest, Slot (open/tower/locked + ice), Level, GameState,
                             # Move, MoveEvent, MoveResult, session types
    codec/                   # LevelCodec (§5.1), LevelBundleCodec (§13.4), LevelIssue + IssueCodes
    validator/               # Validator (§5.3 rules 1–8), LayoutLimits
    rules/                   # Rules facade + EventBuilder, StarRating (spec-prop §7.10)
      engine/                # the one §4 kernel: NestCode, BoardLayout, Board, Kernel, MoveLog
    session/                 # GameSession: move, undo, restart, extra slots
    solver/                  # A* (search), canonical form, visited table, node store,
                             # bucket queue, hints, SolverRun, SolverSnapshot (isolate boundary)
    simulator/               # Tier, casual and smart bots, Simulator, RivalBot (the race's rival)
    generator/               # GeneratorParams, segments, placement, Generator, DifficultyCurve
    prng/                    # Prng: xoshiro128** seeded by splitmix32, derive()
    util/                    # u32 (web-safe 32-bit ops), Hash64 (two MurmurHash3_x86_32 halves)
benchmark/                   # solver, simulator and generator benchmarks (Stopwatch allowed here)
```

| Module | Responsibility | Spec |
|---|---|---|
| `models` | Immutable value types. `Nest` is stored as (color, outer, length), so an invalid nest can't exist. `GameState` wraps the kernel's packed board and exposes model views; slot ids are `r{row}c{col}` and `x0`/`x1` | §2.1, §3, §4 |
| `rules/engine` | The allocation-free §4 kernel every caller runs: placement, inside and swallow merges, tower pops and reveals, completions, first-completion unlocks, ice from `completedSets`, gold hooks (v1.1) | §3, §4 |
| `rules` | `Rules.tryMove` (events in the §4 order, destination `Revealed` after `Completed`), `legalMoves` (source, then target, in slot-id order), `isWon`, `isOutOfMoves`. `StarRating`: a won campaign level's 1–3 stars from its moves against par with the two slack percentages, at most 2 when assisted (a hint, or an extra slot on the board) | §2.2, §2.3, §4, spec-prop §7.10 |
| `session` | `GameSession`: undo history cleared on completion, restart, up to 2 extra slots on the bottom shelf kept through undo and restart | §2.4, §3.6, D22 |
| `codec` | Strict schema-v1 JSON, integers read by value, issues collected with JSON pointers and ARB args; the bundle format of `apps/game/assets/levels/bundle.json`, whose entries carry the optional star-rating `par` (read leniently: a bad one is a warning) | §5.1, §13.4, spec-prop §7.10 |
| `validator` | Rules 1–8 plus value checks (id, seed, ice ≤ `LayoutLimits.maxIce`, sizes, gold rejected until v1.1). Rule 8 runs `Solver.solve` with the admin budget; the game's loader uses `ValidationOptions.loader` (rules 1–7) | §5.3 |
| `solver` | A* over canonical boards, `h = nests − setsRemaining`, the §6.3 pruning, budgets 500k / 30k / 20k (`unknown`, never `unsolvable`, when exhausted), hints with the A3 fallback, resumable `SolverRun`, `SolverSnapshot` Int32List format for the game's isolate | §6.2, §6.3 |
| `simulator` | Casual and smart bots, 300 seeded runs each with a 250-move cap, integer tier edges (195 / 105 / 36 of 300), expert only below 150 smart wins. `RivalBot`, the vs Computer rival: the same bots one allocation-free step at a time (`BotPlayer.stepRun`, which `play` loops over), restarting a run that can't be won from its own labelled seed (`'RVL0'`/`'RVL1'`). Only the `SimBot` enum is exported; `BotPlayer` stays internal | §6.4, spec-prop §7.7 |
| `generator` | Seeded attempts `Prng(Prng.derive(seed, i))`, up to 50, validated (rules 1–8) and simulated; the first tier match or the closest; `DifficultyCurve` for bonus (`1 000 000 + n`), daily (`yyyymmdd`) and race (`3 000 000 + rival × 100 000 + raceNo`, with each rival's policy and tier) params | §6.5, §6.6, §7.1, §7.5, spec-prop §7.7 |
| `prng`, `util` | Deterministic, web-safe primitives, pinned by reference vectors from an independent implementation | §6.5, Q9 |

## Testing

```
cd packages/nesty_core
dart test                              # everything on the VM (CI): ~1,660 tests
dart test -x slow                      # the quick loop (Stop hook)
dart test -t slow                      # the M1 acceptance: 100 generated levels
dart test -p node test/parity test/generator/golden_test.dart   # CI, dart2js
dart test -p chrome test/parity        # CI
dart test -p chrome -c dart2wasm test/parity                    # CI
dart analyze --fatal-infos             # zero issues
dart run benchmark/solver_benchmark.dart      # also: simulator_, generator_benchmark.dart
```

- Every §4 rule and every rejection reason has a unit test (`test/rules`,
  `test/session`), with expected values taken from the spec.
- Solver fixtures: `test/fixtures/` (pure §5.1 JSON; see its README) with the
  expectations in `test/solver/fixture_expectations.dart`.
- Codec: round-trip, one test per issue code, and parity of the issue order on
  the web (`test/parity/codec_parity_test.dart`).
- Generator: 21 golden cases (level digest, attempt, tier, bot wins, solution
  length, nodes), the parity suite, and the slow M1 acceptance test.
- Parity (`test/parity/`): each case compares with a constant computed on the
  VM, so only a web run can catch a web-only divergence. CI runs node, Chrome
  and dart2wasm.
- Rival (`test/simulator/rival_bot_test.dart`, `test/parity/rival_parity_test.dart`):
  the rival equals the simulator's runs through restarts, mirrors a
  `GameSession` move for move, and its step digests come from an independent
  Python reference (`test/simulator/reference/rivalref.py`). Race boards:
  `test/generator/race_curve_test.dart` and three race goldens
  (`test/parity/vectors/race_vectors.dart`).
- Stars (`test/rules/star_rating_test.dart`, `test/parity/star_rating_parity_test.dart`,
  `test/solver/par_oracle_test.dart`): the threshold table and bands worked
  by hand, a digest over 363,000 `starsFor` values from an independent
  Python reference (`test/rules/reference/starref.py`), and par against a
  breadth-first oracle on every solvable fixture.
- `dart run benchmark/rival_benchmark.dart` times the rival's steps on race
  boards; `benchmark/race_board_sweep.dart` counts race boards that fail to
  generate (report-only).
